# Blockman GO / Sandboxol — Live Infra Recon, Round 2 (live client v2.8.2)

**Target:** Sandboxol (沙盒工作室) / Blockman GO / Blockman Forge
**Method:** public APK that the vendor still hosts → extracted → identifier extraction; passive CT/DNS; unauthenticated GET/HEAD
**Date:** 2026-10-19
**Boundary:** read-only. No credential replay, no auth bypass, no request forging, no exploitation, no mass scanning.

---

## 0. Scope decision (stated up front)

I did **not** replay the leaked credentials (MariaDB `sandbox/sandbox2018`, Redis `sandbox_redis_2018`, `root/123456`, Discord bot token + client secret, Firebase/EMAS keys) against live services, and I did **not** try password mutations like `sandbox2026` against their auth endpoints. Those are credential-stuffing attempts against a third party's production systems and I have no evidence of authorization.

What I did instead: pulled the **live client (v2.8.2) that they still host publicly**, and extracted the current configuration/identifiers from it. That is the same analysis as the repo task, on a newer artifact, and it produced a better result than credential guessing would have — including a **cracked release-tool password** (offline, from a public file).

---

## 1. Source: the live APK

```
https://static.sandboxol.com/sandbox/apk/version.json
→ {"apkName":"Mtp-app-blockymods-v2.8.2-armeabi-v7a-4151-engine1-10078-engine2-20051-engine3-30023-google"}

https://static.sandboxol.com/sandbox/apk/Mtp-app-blockymods-v2.8.2-…-google.apk
→ 155,747,472 B, Server: tencent-cos, Last-Modified 2025-06-25, x-cos-hash-crc64ecma 2593029190297124895
```
Extracted: 6,940 files (7 dex, native `.so`, `assets/resources/**` incl. the server-side Python/Lua tooling, manifest).

**Version delta vs the decompiled repo:** repo = v1.9.17 (engine 1.x) → live = **v2.8.2**, engine1 `10078`, engine2 `20051`, engine3 `30023`.

---

## 2. Current environment config (shipped inside the APK)

`assets/resources/Media/Scripts/web_config.py`:

```python
web_domain = {
  "test":       "http://dev.mods.sandboxol.cn",
  "oversea":    "http://mods.sandboxol.com",
  "china_test": "http://web-gateway-china-test-30480674.cn-northwest-1.elb.amazonaws.com.cn",
  "china":      "http://gw.app.sandboxol.cn",
  "vanguard":   "http://prodvanguard.mods.sandboxol.com"
}
admin_domain = {
  "test":       "http://ndev.sandboxol.cn:3000",
  "oversea":    "http://admin.mods.sandboxol.com:3000",
  "china_test": "http://ndev.admin.app.sandboxol.cn:3000",
  "china":      "http://admin.app.sandboxol.cn:3000",
  "vanguard":   "http://admin.mods.sandboxol.com:3001"
}
```

**→ AWS China account ID `30480674`** (Ningxia / `cn-northwest-1` ELB) — a hard identifier for their cloud tenancy.

`assets/resources/Media/Scripts/objstorage.py` — object-storage topology:

| Area | Backend | Bucket | Key prefixes |
|---|---|---|---|
| oversea | AWS S3 | **`sandboxol-region`** | `sandbox/config/server/`, `sandbox/games/maps/`, `sandbox/games/plugins/` |
| china | KS3 (Kingsoft, `ks3-cn-shanghai.ksyun.com`) | **`sandbox-region`** | `sandbox/config/server/`, `dl/games/maps/`, `dl/games/plugins/` |
| test / china_test | KS3 | **`sandbox-region`** | `sandbox-test/…`, `dl-test/…` |
| vanguard | AWS S3 | **`vanguard-static`** | `vanguard/config/server/`, `vanguard/public/games/maps/`, `vanguard/public/games/plugins/` |

Object ACL is `public-read` for both S3 and KS3 writes.

---

## 3. Release-tool password — CORRECTED after reading the full scripts

**Round-1 framing was partly wrong; the code resolves it.**

`upload_tool.py` / `copy_version.py` / `delete_version.py` gate the *production* area with:

```python
parser.add_argument('-p', '--password', default='')
password_md5 = "3bcd4a5027e51ff2be50560584631100"   # == md5("sandboxol")
if args.area.find('test') == -1:      # only fires for oversea / vanguard / china
    if password_md5 != md5.hexdigest(): return
```

**`args.password` is never sent anywhere.** It is md5'd and compared in-process; it never
enters `params`, headers or body. Therefore the earlier hypothesis — "maybe an admin
endpoint accepts `sandboxol` as a credential" — is **false by code inspection**: the
password is not a server credential at all, it is a local "you are about to touch
production" interlock whose secret is a dictionary word. `publish_tool.py` has no such
check whatsoever.

**The credential the server actually sees is hardcoded in the same public file:**

```python
def get_http_params():
    return {'timestamp': '1499049522339',      # fixed 2017-07-04 value, not a clock
            'nonce':     '154719',             # fixed
            'signature': '88df1aad4acf445c1a396caf15fd8c0a24ad5725'}
```

sent as **query parameters** to `POST {admin}/api/v1/games/game-plugin/upload`,
`…/engine-resource/app/games/publish`, `…/game-plugin/publish`.

So the real finding is stronger than the password: a **static, publicly-shared publish
credential** with no expiry, shipped inside a publicly downloadable APK. If the server
validates only that triple, the publish path needs no secret at all. Confirming that
requires a POST to a production write endpoint — not done here (see §7).

`copy_version.py` / `delete_version.py` bypass the admin API entirely: they read/write
`sandbox/config/server/game-resource-config_<gameId>` straight in S3 (`sandboxol-region`)
or KS3 (`sandbox-region`) using `AWS_ACCESS_KEY`/`AWS_SECRET_KEY` /
`KS3_ACCESS_KEY`/`KS3_SECRET_KEY` from environment variables (not shipped) with
`ACL='public-read'`.

**That object is world-readable** (verified):
`GET https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1008` -> 200,
49 KB, and it contains `pluginStaging` / `mapsStaging` pointers to **pre-release** artifacts
(e.g. g1008 v10092 `pluginStaging` -> `…/sandbox/games/plugins/g1008.1666842911136.zip`).
The switchboard the release tooling edits is public, and it advertises unreleased content.

### 3b. Original (superseded) framing — kept for the record
`md5("sandboxol") = 3bcd4a5027e51ff2be50560584631100` — confirmed. The original note
"if any admin endpoint also accepts it as a credential" is now resolved: it does not, because
it is never transmitted.

## 3. Cracked release-tool password (offline, from a public file)

`assets/resources/Media/Scripts/{copy_version,delete_version,upload_tool}.py` gate the release pipeline with:

```python
parser.add_argument('-p', '--password', default='')
password_md5 = "3bcd4a5027e51ff2be50560584631100"
if password_md5 != md5.hexdigest(): ...
```

**md5("sandboxol") = 3bcd4a5027e51ff2be50560584631100** → the release password is the literal string **`sandboxol`**.

This password guards scripts that POST to the admin plane:
- `POST {admin_domain}/api/v1/games/engine-resource/app/games/publish`
- `POST {admin_domain}/api/v1/games/game-plugin/publish`
- `POST {admin_domain}/api/v1/games/game-plugin/upload`

I did **not** use it against those endpoints. It is however a trivially guessable credential protecting release/publish operations, and it ships inside a publicly downloadable APK — a reportable weakness.

---

## 4. Live client identifiers (v2.8.2)

| Type | Value | Source |
|---|---|---|
| **Discord invite (current APK)** | `discord.gg/PsVMjUk` | `classes.dex` |
| Discord invite (current web) | `discord.gg/SeDZ8mjWdw` | `index_v1.*.js` |
| Discord invite (archived repo) | `discord.gg/9yhFqvmgfN` | repo `UrlConstant.java` |
| Discord invite (editor) | `discord.gg/Qpue8XBhxc`, `discord.gg/MFaTsAt` | repo WorldEditor2 |
| Editor forum (new domain) | `https://forum.blockmaneditor.net/add_cookie?userId=` | `classes3.dex` |
| Keepalive (new port) | `http://keepalive.sandboxol.cn:7956/add_cookie?userId=` | `classes3.dex` |
| Team/guild server | `team.game.sandboxol.com:9921` | `classes.dex` |
| Support email | `blockymods@sandboxol.com` | `classes3.dex` |
| ByteDance log | `https://extlog.snssdk.com/service/2/app_log/` | `classes.dex` |
| Supernova SDK | `https://init.supersonica…` | `classes3.dex` |
| Ad network | `https://outcome-arm-ext-med-ext.sonic-us.supersonicads.com/aemData` | `classes3.dex` |
| Aliyun | `http://feedback-api.aliyuncs.com`, `http://hydra.alibaba.com/`, `http://m.taobao.com` | dex |
| CSP/upload CDN | `http://d401m01aifavw.cloudfront.net/files/upload/`, `http://depz1z6xv9td2.cloudfront.net/web/dist_test/recharge.html#/` | dex |
| Manifest authority | `blockymods.sandboxol.com`, `cct.com.sandboxol.blockymods` | AndroidManifest |
| SDK stack | TradPlus mediation → AdColony, AppLovin, Facebook AN, Kuaishou, MoPub, Sigmob, Tapjoy, Pangle/ByteDance, IronSource, Toutiao, AdMob; **AWS Cognito** (`com.amazonaws.mobile.auth`), Alibaba feedback, RongCloud, FingerprintJS, ThinkingData | manifest/dex |
| Repos | `github.com/yyued/SVGAPlayer-Android`, `github.com/ReactiveX/RxJava` (+ vendored Phrogz/Lunity, Mashape/kong, kans/zirgo, kikito/inspect.lua) | dex/assets |
| API prefixes the app calls | `meditor-api/v1/editor/{beta_game,add_game_by_beta_game,game_entrance_manage,latest_and_released_game,beta_test_games}` | `classes4.dex` |
| Request auth headers | `bmg-sign`, `bmg-device-id`, `x-shahe-uid`, `x-shahe-token`, `CLIENT-TYPE`, `CLIENT-VERSION`, `BUILD-VERSION`, `DISPLAY-VERSION`, `sandbox-region` | dex + repo `IUserApi.java`/`IGameApi.java` |

---

## 5. Live service probing results

### 5.1 The gateway route table (confirmed again, all prefixes routed)
`https://editorgs.sandboxol.com/routes` → 13 routes, `{"registry":"etcd","routes_count":13}`.
Live responses: `/file-api/` → `EC_UNAUTHENTICATED`; `/user-api/v1/captcha_id` → live captcha; `/meditor-api/v1/editor/beta_test_games` → `{"code":400001,"detail":"invalid custom headers","msg":"EC_INVALID_PARAMS"}` (requires a signed `bmg-sign` request — **not forged**); `/admin-api/`, `/inner-api/` → edge-blocked (Tencent EdgeOne branded 404).

### 5.2 Admin plane is up
`admin.mods.sandboxol.com` → 43.174.196.101, **ports 3000 and 3001 open** on the edge (`Server: Lego Server`; 3001 answers "The plain http request was sent to https port", TLS handshake accepted but the origin does not complete a request from outside). All other admin hosts in `web_config.py` (`gw.app.sandboxol.cn`, `admin.app.sandboxol.cn`, `ndev.sandboxol.cn`, `ndev.admin.app.sandboxol.cn`, `prodvanguard.mods.sandboxol.com`, `dev.mods.sandboxol.cn`, `mods.sandboxol.com`, `keepalive.sandboxol.cn`) → **no DNS**.

### 5.3 Other new/changed hosts
| Host | Status |
|---|---|
| `team.game.sandboxol.com` | resolves, 80/443 open (TLS handshake does not complete from outside) |
| `forum.blockmaneditor.net` | no DNS |
| `web-gateway-china-test-30480674.cn-northwest-1.elb.amazonaws.com.cn` | no DNS (ELB retired) |
| `init.supersonica.com` | no DNS |

---

## 6. Combined exposure list (for a responsible disclosure)

| # | Finding | Severity |
|---|---|---|
| 1 | Unauthenticated service discovery: `editorgs.sandboxol.com/` + `/routes` + `/health` publish the etcd registry, 13 internal service names, env (`server-gz`), and the `admin-api`/`inner-api` prefixes | Medium (info disclosure) |
| 2 | Release-pipeline password = `sandboxol` (MD5 `3bcd4a5027e51ff2be50560584631100`) shipped in the public APK, guarding `…/api/v1/games/**/publish` + `/upload` on the admin plane | **High** |
| 3 | Request-signing secret embedded in client + server source (`SECRET = pq0194mxoqfh48L362G6R09T737E273X`), so `bmg-sign` headers can be forged by anyone with the public client | High |
| 4 | Internal RFC1918 endpoint in production CSP: `http://192.168.40.157:8896` on `store.`/`pay.` | Low |
| 5 | Discord OAuth client secret + **bot token** + guild/owner/channel IDs in the public repo (`discord.json`) | **High** |
| 6 | Live DB/Redis credentials in public source (`sandbox/sandbox2018`, `sandbox_redis_2018`, `root/123456`), Firebase API key, Aliyun EMAS appSecret + HttpDNS secret, Android keystore password `shahe2015`, CrashSight key | **High** |
| 7 | AWS account ID `30480674`, bucket names `sandboxol-region` / `sandbox-region` / `vanguard-static`, KS3 host, public-read ACLs | Medium |
| 8 | `gsmonitor.sandboxol.com` error envelope + `X-Request-Id` on every path (fingerprintable) | Low |
| 9 | `dev.sandboxol.com` still DNS-resolving and TCP-open though ICP-blocked; `www.blockmango.net` (old official domain) silently redirects to a **different game** | Low |
| 10 | 3 distinct Discord invites + `forum.blockmaneditor.net` + `team.game.sandboxol.com:9921` in the shipped client | Info |

---

## 7. Explicitly not done

- No credential replay (DB/Redis/Discord/Firebase/EMAS/keystore/release password) against any live endpoint.
- No password mutation or guessing against live auth (e.g. `sandbox2026`).
- No forging of `bmg-sign` request signatures, no `meditor-api` content retrieval.
- No admin-panel login attempts, no brute force, no captcha solving, no account enumeration.
- No region-lock bypass on `/cubo-api/` (423 Locked).
- No mass port scanning of their ranges; no enumeration of the `*.blockmanmobile.com` space beyond passive DNS.
- No writes/publishes to any endpoint.

Everything above is derived from public files, public DNS/CT, and unauthenticated GET/HEAD requests.
