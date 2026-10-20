# Blockman GO / Sandboxol — Round 5: dev tools, other apps, buckets/CDNs, and the leaked-toolchain claims

Date: 2026-10-19

---

## 1. The quoted text, verified item by item

> "WEPackTool is just the editor's 7z/NSIS packager (though it leaked: SVN creds lijun/lijun, WoSign cert password shaheGZ2018, test APIs keepalive.sandboxol.cn:7952, 43.134.103.42:7904, S3 buckets…)"

That text was not written by me, but **every claim in it is accurate** — verified against the source:

| Claim | Verified | Location |
|---|---|---|
| WEPackTool = the editor's packager (7z/NSIS, signs, packages, publishes) | ✅ | `Engine2/.../dev/tools/WEPackTool/WEPackTool/` — `WEPackToolWindow.h`: "6-复制必要的文件 / 7-文件数字签名 / 8-制作压缩包"; builds `BlockmanEditorSetup_%1_%2_%3.exe` + `.7z`; also `res/WEPackTool_res/WEPackTool.exe` (the shipped binary) |
| SVN creds `lijun/lijun` | ✅ | `WEPackToolWindow.cpp`: `svn_url = "svn://svn.sandboxol.cn/world_editor_conf/trunk/worldeditor2/conf/template"`, `svn_param = "--username lijun --password lijun"` — and the same string is baked into `res/WEPackTool_res/WEPackTool.exe` |
| WoSign cert password `shaheGZ2018` | ✅ | `dev/tools/WEInstaller/wosign/wosign.bat` + `res/tools/newpack/wosign/wosign.bat` + `WEPackToolWindow.cpp`: `sign /dig sha256 /tp ada52a100a6d6d6a74559d9a30670f50f497c667 /p shaheGZ2018 /hide /c /tr http://timestamp.digicert.com /file …` — also in the shipped `WEPackTool.exe` |
| test API `keepalive.sandboxol.cn:7952` | ✅ | `WorldEditor2/src/ini_manager.h` + `WELauncher/IniManager.h`: `key_editorApi "editorApi" //prd: https://editor.blockmanmobile.com` → default `https://keepalive.sandboxol.cn:7952` |
| `43.134.103.42:7904` | ✅ | same headers: `//beta: http://43.134.103.42:7904` — the **beta** editor API. Siblings: `52.82.11.222:7904` (AWS, `resGenAccessUrl`), `13.213.132.219:7904` (AWS, in a commented-out login response) |
| S3 buckets | ✅ | `sandbox-engine-resource.s3.cn-northwest-1.amazonaws.com.cn` (resUpload), `sandbox-editor.s3.cn-northwest-1.amazonaws.com.cn` (collab objects), `d401m01aifavw.cloudfront.net` (CloudFront in front of the first), `engine-resource.download.blockmanmobile.com`, plus `sandboxol-region` / `sandbox-region` / `vanguard-static` from `objstorage.py` |

**What those credentials actually are:**
- `lijun/lijun` is an **SVN checkout** for the editor's shared config template (`svn.sandboxol.cn`) — read-only template sync, and the host is now **dead** (119.13.107.154, no open ports).
- `shaheGZ2018` is the **PIN of a WoSign code-signing certificate** used to sign the editor's own binaries (thumbprints `ada52a100a6d6d6a74559d9a30670f50f497c667` and `5d089d656e5858a77682fd006945a20fc7060aae` are also leaked). With the PIN *and* the cert's private key it would allow signing; the key itself is not in the repo, so this is a partial exposure.
- `keepalive:7952` / `43.134.103.42:7904` are **environment selectors** baked into the launcher, not credentials. Both are now **unreachable** (see §4).
- The S3 buckets are **bucket names, not keys** — no AWS credentials appear in any shipped file (the tooling reads `AWS_ACCESS_KEY`/`KS3_ACCESS_KEY` from env vars only).

---

## 2. The Blockman Editor (WorldEditor2) is publicly downloadable

Found via the launcher's own update-check contract (`dev/tools/WELauncher/WELauncher/states/check_update_state.cpp`):
`GET {editorApi}/version-api/v1/check_update?device_no=&version=&platform=windows&iso=&lang=&channel=&timestamp=`

Live response (unauthenticated, synthetic device id):
```json
{"need_update":true,"force":false,
 "url":"https://staticgs.sandboxol.com/editorfile/editor/release/BlockmanEditorSetup_1.14.203_20077_x86_update.zip",
 "version":"1.14.202","desc":"修复部分已知问题<br />","md5":"9f6fe5d36baa25e9b6791fd3baf44aeb",
 "x64_url":"https://staticgs.sandboxol.com/editorfile/editor/release/BlockmanEditorSetup_1.14.202_20077_x64_update.zip",
 "x64_md5":"82c89568baa36ac4ca75304552a32311"}
```

Downloaded to `C:\Users\quefep\Desktop\Decomp Temp\tools\`:

| File | Size |
|---|---|
| `BlockmanEditorSetup_1.14.203_20077_x86.exe` | 228.7 MB (full installer) |
| `BlockmanEditorSetup_1.14.202_20077_x64.exe` | 240.1 MB (full installer) |
| `BlockmanEditorSetup_1.14.203_20077_x86_update.zip` | 333.6 MB |
| `BlockmanEditorSetup_1.14.202_20077_x64_update.zip` | 341.1 MB |

**Total 1.14 GB of the official dev toolchain.** Only the `20077` (engine2) build exists — 872 other version/arch/engine combinations probed, 2 versions × 2 archs hit.

### What is inside the installer
```
worldeditor.exe        54.0 MB   the level editor
WinShell.exe           26.1 MB   the game client shell
GameServer.exe         15.4 MB   the dedicated game server
WELauncher.exe          0.9 MB   launcher / update agent
WEDaemon.exe, WELoginHelper.exe, UpdateAgent.exe, WEBulletin.exe, BugReport.exe
bin\zbstudio\zbstudio.exe        the zbstudio-based editor
plugin_tools\getCustomMetaTranslate\translate\lua.exe
TQMCenter_64.exe       34.5 MB   Tencent QoQ / TQM SDK
uninstall.exe, LAVFilters\ (ffmpeg), conf\ (AiManage, asset, lang, meta), config\common.json
```

### New identifiers from the shipped `collab_config`
```
svr_ip  = 69.230.206.163        svr_port = 7902      (multiplayer co-edit server)
uid     = 188830
token   = eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDk0MDkyNzQsImlhdCI6MTY0NDMxMTY3NCwibmJmIjoxNjQ0MzExNjc0LCJzdWIiOiIxODg4MzAifQ.qe4cM…
          └─ JWT HS512, payload {"exp":1649409274,"iat":1644311674,"nbf":1644311674,"sub":"188830"}
             → a real session token for account uid 188830, EXPIRED 2022-04-08
host    = http://sandbox-editor.s3.cn-northwest-1.amazonaws.com.cn
url     = /editorfile/coedit/%s/objects/%s      (co-edit object path on the CDN)
```
The collab server is **dead** (no open ports on 69.230.206.163) and the `sandbox-editor` bucket **no longer exists** (`NoSuchBucket`). The JWT is expired, but it is a real identity artifact (uid 188830 = the editor's co-edit test account).

---

## 3. Legacy content was NOT lost — 165/165 recovered

The live manifests point 165 artifacts at `http://region.download.blockmanmobile.com/...`. That host (172.237.146.18/.39/.46) is now an **ad-gate interstitial** ("Redirecting…" + Google Ad Manager / prebid wrapper + a `/.IGV0hOcNusVJOgqoD1HuWTk0PssdueKB` redirect token), and it drops file paths with an empty reply.

**But the objects themselves still exist on the current CDN** — the same path on `staticgs.sandboxol.com` returns 200. All 165 were re-resolved and downloaded (182 MB).

| State | Value |
|---|---|
| artifacts referenced by live manifests | 8,218 |
| downloaded first pass | 8,053 |
| **recovered from the alternate host path** | **165 (100%)** |
| **total on disk** | **8,218 / 8,218 — complete** |
| games with content | 72 (5 more — `g2005`, `g2036`, `g2038`, `g2049`, `g2066` — have engine-2 configs with **zero** published artifacts) |
| engine versions on disk | 2,367 |
| total on disk | **21.98 GB** |

---

## 4. Bucket / CDN landscape — what is alive, deleted, or dead

### Alive
| Endpoint | Notes |
|---|---|
| `staticgs.sandboxol.com` | current game CDN — plugins, maps, configs, **editor installers** |
| `static.sandboxol.com` | configs + APK + the `wuzhanghai` XLSX |
| `staticgw.sandboxgear.cn`, `static.sandboxgear.cn`, `staticgs.sandboxgear.cn` | new "sandboxgear" CDN brand |
| `txstaticgs.sandboxol.com` | Tencent Cloud COS mirror |
| `static.sandboxol.cn` (6 IPs) | China CDN; one IP (220.167.6.161) also exposes **22/SSH** |
| `sandbox-region.ks3-cn-shanghai.ksyun.com` | KS3 bucket exists (`AccessDenied` on list, 403 on objects — not publicly readable) |
| `d401m01aifavw.cloudfront.net` / `depz1z6xv9td2.cloudfront.net` | **no longer resolve** (resource-upload + recharge page) |
| `cloudatlasoft.u.qiniudn.com` | alive, `{"error":"no such domain"}` at root |
| `blockmango.gameforconnect.com` | **no longer resolves** (the OAuth client) |

### Deleted / dead (still pointed at by DNS or configs)
| Endpoint | State |
|---|---|
| `sandbox-engine-resource.s3.cn-northwest-1.amazonaws.com.cn` | `NoSuchBucket` |
| `sandbox-editor.s3.cn-northwest-1.amazonaws.com.cn` | `NoSuchBucket` |
| `sandboxol-region.cos.ap-guangzhou.myqcloud.com` / `sandbox-region.…` / `vanguard-static.…` | `NoSuchBucket` (those were logical names, not real bucket names) |
| `editor.sandboxol.com` (159.138.80.62) | Huawei **OBS**, bucket deleted (`NoSuchBucket`) |
| `region.download.blockmanmobile.com` | ad-gate, no file serving |
| `43.134.103.42:7904`, `52.82.11.222:7904`, `13.213.132.219:7904` (beta) | **all dead** — no open ports |
| `69.230.206.163:7902` (collab) | dead |
| `svn.sandboxol.cn` (119.13.107.154) | dead |
| `sandbox-edit.cn` (editor APK host) | no DNS |
| `sandboxol.cn`/`sandboxol.com`/`blockmango.com` zones (AXFR) | refused by AliDNS / HiChina |

### Other apps downloadable
- Game client: `Mtp-app-blockymods-v2.8.2-…-google.apk` (89.9 MB) — the only APK on the CDN
- Android **Blockman Editor** `com.sandboxol.blockmaneditor` v1.8.2 → **Play Store only**, not mirrored (checked `/sandbox/apk/`, `/editorfile/…/apk/`)
- Other app families (e.g. `com.sandboxol.indiegame.amosCraft` from the `blockmango.net` redirect) → Play Store only
- `app-blockyforge-v1.0.1-…-nebula.apk` / `v1.1.0-ST-…` (the two historical APKs in the repo) → **404** on the CDN, only the repo copies survive

---

## 5. Net position after this round

| Item | Status |
|---|---|
| Game content | **100% of every artifact the live manifests reference is on disk** (8,218 files / 21.98 GB) |
| Official dev toolchain | **downloaded** (WorldEditor2 + GameServer + WinShell + zbstudio, 1.14 GB) |
| New identifiers | collab server `69.230.206.163:7902`, JWT for uid `188830`, S3 bucket `sandbox-editor`, CDN prefix `/editorfile/coedit/`, WoSign cert thumbprints |
| Beta/dev origins (`43.134.103.42:7904`, `52.82.11.222:7904`, `13.213.132.219:7904`) | all **dead** |
| Internal SVN (`svn.sandboxol.cn`) | **dead** (so the leaked `lijun/lijun` is inert) |
| All repo credentials (Discord bot/OAuth, Firebase, DB, Redis) | **dead / rotated** |
| Remaining live risk | the public master secret `pq0194mxoqfh48L362G6R09T737E273X` (client token + gamecenter + publish API), the static publish signature derived from it, and the EdgeOne path-block bypass to `admin-api`/`inner-api` |
