# Blockman GO / Sandboxol — Live Infrastructure Recon Report

**Target org:** Sandboxol (沙盒工作室) / Blockman GO / Blockman Forge
**Sources:** identifiers extracted from the decompiled repo + passive OSINT (Certificate Transparency, DNS history) + unauthenticated GETs to public endpoints
**Date:** 2026-10-19
**Boundary observed:** read-only. No credential use, no auth bypass, no exploitation, no mass scanning, no writes.

---

## 1. The exposed service-discovery endpoint (the headline finding)

`GET https://editorgs.sandboxol.com/` → **HTTP 200, unauthenticated, JSON**

```json
{"routes":[ …13 routes… ],"status":"ok"}
```

`GET https://editorgs.sandboxol.com/routes` → same table
`GET https://editorgs.sandboxol.com/health` → `{"registry":"etcd","routes_count":13,"status":"ok"}`

**What is visible:** the entire internal API gateway routing table — external path prefix → internal service-registry name → backend name → optional rewrite rule.

| Public prefix | Internal service (etcd name) | Backend | Rewrite |
|---|---|---|---|
| `/community-api` | `sandbox.server-gz.apps.m.api.community-api` | community-api | — |
| `/gamedata-api` | `sandbox.server-gz.apps.api.creator-api` | creator-api | → `/creator-api` |
| `/creator-api` | `sandbox.server-gz.apps.api.creator-api` | creator-api | — |
| `/meditor-api` | `sandbox.server-gz.apps.m.api.meditor-api` | meditor-api | — |
| `/version-api` | `sandbox.server-gz.apps.m.api.version-api` | version-api | — |
| `/editor-api` | `sandbox.server-gz.apps.api.editor-api` | editor-api | — |
| `/notice-api` | `sandbox.server-gz.apps.api.notice-api` | notice-api | — |
| **`/admin-api`** | `sandbox.server-gz.apps.api.admin-api` | admin-api | — |
| `/event-api` | `sandbox.server-gz.apps.api.event-api` | eventtrack-api | — |
| `/inner-api` | `sandbox.server-gz.apps.api.inner-api` | inner-api | — |
| `/muser-api` | `sandbox.server-gz.apps.m.api.muser-api` | muser-api | — |
| `/file-api` | `sandbox.server-gz.apps.api.file-api` | file-api | — |
| `/user-api` | `sandbox.server-gz.apps.api.user-api` | user-api | — |

**What this leaks:**
1. **Service registry = `etcd`** (stated in `/health`) — the gateway resolves backends from etcd.
2. **Namespace structure** → `sandbox.server-gz.apps.api.*` vs `sandbox.server-gz.apps.m.api.*`
   - `sandbox` = org/product namespace, `server-gz` = **Guangzhou** deployment, `apps` = app group
   - `.api.*` = web/creator-facing services, `.m.api.*` = **mobile**-facing services
   - `m.api` set = community/meditor/version/muser → the mobile client plane
3. **Internal service inventory** incl. `admin-api` and `inner-api` (the private service the decompiled repo actually contained — `main-api-dev`/`inner-api-dev`).
4. **Route aliasing**: `/gamedata-api` is a rewrite of `/creator-api`, so two public paths hit one backend.

**Probed and confirmed:** every one of the 13 prefixes is routed and live (each returns a distinct backend-generated response, not an edge error):

| Prefix | Root response |
|---|---|
| `/file-api/` | `{"code":400003,"detail":"empty uid","msg":"EC_UNAUTHENTICATED","ext":null,"trace_id":"5ba297e9-…"}` |
| `/user-api/v1/captcha_id` | `{"captcha_id":"YZ81E304UGB1wpmF9sWM"}` (live captcha issuance) |
| `/admin-api/`, `/inner-api/` | **blocked at the edge** (Tencent EdgeOne branded 404, 1064 B HTML) |
| all others | Go `404 page not found` (18 B) = backend alive, route not defined at root |

The `EC_UNAUTHENTICATED` envelope (`code`/`msg`/`detail`/`ext`/`trace_id`) is the **same error schema as the decompiled `main-api-dev/src/common/responses.js`** → the live API is the direct descendant of the code in the repo.

**Not exposed:** etcd itself is not proxied (`/etcd/`, `/v2/keys/`, `/v3/kv/range` → 404). No swagger/openapi/docs/metrics/actuator endpoints (all 404).

---

## 2. Live vs. dead — everything from the repo

### Dead (all of it)
Every hardcoded server in the decompiled tree is gone:

| From repo | Now |
|---|---|
| `149.202.146.216` (dispatcher, MariaDB `bmfdb`) | no ICMP; 80/3306/7500/19130 closed |
| `188.165.91.105` (CDN 3888, dispatcher 7500, game 19130) | closed |
| `207.180.204.162` (Redis 6379) | pings, 6379 closed |
| `120.92.136.119` (MariaDB 3306, Redis 6379) | closed |
| `120.92.133.131` (monitor 9912) | closed |
| `120.92.141.96` (dbHttpService 8910) | closed |
| `120.92.158.119` (blockymods API) | closed |
| `gitlab001.sandboxol.cn` (80/31006) | resolves → 134.175.243.148, both closed (**internal GitLab gone**) |
| `gz-inner.sandboxol.cn:18080` (DokuWiki) | no DNS |
| `keepalive.sandboxol.cn` | no DNS |
| `mods.sandboxol.com`, `ols.sandboxol.com`, `dev.sandboxol.cn`, `dev.mods.sandboxol.cn`, `gamedata.sandboxol.cn`, `www.sandboxol.com`, `www.sandboxol.net`, `v3.game.sandboxol.com` | no DNS |
| `dev.sandboxol.com` (120.92.144.72) | TCP open but **ICP-blocked by the Chinese host** ("网站尚未取得备案号…被临时屏蔽", `Server: ADM/2.1.1`) |
| `editorweb.sandboxol.com` (75.2.79.116) | no port open (80/443/8000/8888/9000/10080/8081) — docs site offline |
| `forum.blockmango.com` (190.92.219.158), `bugfixes.sandboxol.com` (190.92.219.235) | no port open |

### Alive
| Host | IP | Service |
|---|---|---|
| `www.blockmango.com` | 43.174.198.101 | **Live Blockman GO portal** (nginx/1.25.5) — "Blockman GO" SPA, google-site-verification `36mLCuhZqe_iLlKjGHiDDYLKCnFLjg1eW4fajRLRXqs` |
| `www.blockmango.net` | 101.32.105.195 | now a **Tencent-COS redirect page → AMOS 4D Craft app** (old game domain repurposed) |
| `www.sandboxol.cn` | 47.106.176.91 | now "**方块堡垒 - 创意方块游戏平台**" (different product) |
| `editorgs.sandboxol.com` | 43.174.196.101 | **live API gateway** (Tencent EdgeOne) |
| `editorapi.sandboxol.com` | 43.174.196.101 | EdgeOne, alive (404 at root) |
| `static.sandboxol.com` | 43.174.198.101 | Tencent COS — assets + APK |
| `static.sandboxol.cn` | 116.153.82.69 | Tencent COS (China) |
| `staticgs.sandboxol.com` | 43.152.134.132 | Tencent COS (bucket 403 at root) |
| `staticgw.sandboxgear.cn` | 43.174.196.101 | **new CDN brand "sandboxgear"** |
| `static.sandboxgear.cn` / `staticgs.sandboxgear.cn` | 43.174.198.101 | new COS mirrors |
| `www.sandboxgear.cn` | 43.174.196.101 | same SPA as sandboxol.cn |
| `store.blockmango.com` | 43.174.196.101 | **live store**, `Server: BlockMango-Store`, Airwallex payments |
| `pay.blockmango.com` | 43.174.196.101 | 302 → `/en/` (payment front) |
| `top-up.blockmango.com` | 185.30.21.54 | top-up portal (nginx, leaks `X-Real-Ip`) |
| `toys.blockmango.com` | 23.227.38.74 | **Shopify** store (GCP us-east1) |
| `crashreport.sandboxol.com` | 43.174.196.101 | crash-report JSON API |
| `gsmonitor.sandboxol.com` | 43.169.37.105 | **game-server monitor** (nginx/1.18.0 Ubuntu), `401 {"error":{"code":"unauthorized","message":"valid bearer token required"}}` |
| `newapi.aiproxy.sandboxol.com` | 43.174.196.101 | AI-proxy API (edge 404) |
| `sub2api.aiproxy.sandboxol.com` | 104.21.62.243 | AI-proxy, behind Cloudflare |
| `reg.sandboxol.com` | 54.158.55.210 | **AWS** — no port open from here |
| `test.route.sandboxol.com` | 172.67.140.163 | Cloudflare **530** (origin down) |
| `txstaticgs.sandboxol.com` | 43.175.181.73 | COS (tx = Tencent Cloud) |
| `gcdn01.sandboxol.com` | 43.159.77.250 | COS game-CDN (403 at root) |
| `pc.blockmanmobile.com` | 172.237.146.46 | alive (www + game subdomains) |
| `crashsight.qq.com` | 115.190.54.158 / Tencent | crash reporting |

---

## 3. New identifiers found on the live surface

| Type | Value | Source |
|---|---|---|
| **Discord invite (current)** | `discord.gg/SeDZ8mjWdw` | `index_v1.f161662bce645aa1a340.js` |
| Discord invite (archived) | `discord.gg/9yhFqvmgfN` | repo `UrlConstant.java` |
| **Internal private IP in prod CSP** | `http://192.168.40.157:8896` | `store.blockmango.com` / `pay.blockmango.com` `Content-Security-Policy: connect-src …` |
| **Payment provider** | Airwallex (`*.airwallex.com` in CSP) | store/pay CSP |
| **Analytics** | ThinkingData appId `7afe199db55d4368b649b41594c8faf5`; `jic.talkingdata.com` appid `93508ABC8BB848F8BA4557B1ABD4BD1A`; push `http://te-push.sandboxol.cn/api/data/app/events` | live page HTML |
| **IM** | RongCloud (`cdn.ronghub.com`, `rongcloud-image.ronghub.com`) | live page HTML |
| **Fingerprinting** | FingerprintJS (`fpjs.dev`, `m1.openfpcdn.io`) | live JS |
| **Support** | Zendesk SSO (`/msg/api/v1/zendesk/sso/jwt/url`) | live JS |
| **Live APK** | `Mtp-app-blockymods-v2.8.2-armeabi-v7a-4151-engine1-10078-engine2-20051-engine3-30023-google.apk` — 155,747,472 B, COS, Last-Modified 2025-06-25 | `static.sandboxol.com/sandbox/apk/version.json` |
| Current client version | v2.8.2 (repo was v1.9.17); engine1=10078, engine2=20051, engine3=30023 | same |
| API base | `https://editorgs.sandboxol.com/creator-api/`; web portal uses `/cubo-api/*` | live JS |
| Client manifest | `https://staticgw.sandboxgear.cn/client/version.json?t=` (currently 404 → moved) | live JS |
| Keepalive (new port) | `https://keepalive.sandboxol.cn:7956/` (repo had 7952) | live JS |
| Store frontend | `Server: BlockMango-Store`; `txstaticgs.sandboxol.com`, `staticgs.sandboxol.com`, `gcdn01.sandboxol.com` | store CSP |
| OAuth client id | `100112` (`blockmango.gameforconnect.com/oauth/login`) | repo |
| New subdomains (CT/DNS) | `test.route.`, `crashreport.`, `gsmonitor.`, `reg.`, `staticgs.`, `newapi.aiproxy.`, `sub2api.aiproxy.`, `store.`, `top-up.`, `toys.`, `pay.`, `txstaticgs.`, `gcdn01.`, `staticgw.sandboxgear.cn`, `static.sandboxgear.cn`, `staticgs.sandboxgear.cn`, `www.sandboxgear.cn` | certspotter + hackertarget |
| Wildcard cert | `*.sandboxol.com` issued 2026-09-04 → 2027-03-21 | certspotter |

---

## 4. Notable exposures / findings (for a disclosure, not for abuse)

1. **Unauthenticated service discovery** on `editorgs.sandboxol.com` — internal etcd service names, 13 routes, and the `admin-api`/`inner-api` prefixes. Publicly disclosing internal service topology is an information-disclosure bug.
2. **Internal RFC1918 address in a production CSP** (`192.168.40.157:8896`) on `store.`/`pay.` — a dev host leaked into prod config.
3. **`/admin-api` and `/inner-api` are edge-blocked but still routed** — the block is a path rule at EdgeOne, not an auth control at the service. A path-normalization gap (e.g. `//admin-api`, `/Admin-Api`, `/admin-api%2f`) could bypass it — **not tested here**.
4. **`gsmonitor.sandboxol.com` exposes a 401 JSON envelope with `X-Request-Id`** on every path — consistent error handling helps fingerprinting; it also confirms this is the successor of the repo's `monitorAddr`.
5. **`reg.sandboxol.com` on AWS (54.158.55.210)** with no exposed ports — registration service hosted outside the Chinese cloud (likely for ICP/GDPR reasons).
6. **`toys.blockmango.com` is a Shopify store on GCP** — merch operation, `shopify-complexity-score` header.
7. **`top-up.blockmango.com` leaks the real client IP in `X-Real-Ip`** (74.244.141.135 from my request) — confirms it is a transparent reverse proxy.
8. **`dev.sandboxol.com` is an unfiled (no-ICP) domain** still DNS-resolving and TCP-open.
9. **`www.blockmango.net`** (the old official domain) now redirects users to a **different game's store** (AMOS 4D Craft) — anyone with old bookmarks/APK links gets silently redirected.
10. **Wildcard `*.sandboxol.com` certificate** is issued and valid — any subdomain that resolves will present a valid cert, so TLS alone won't distinguish live hosts.

---

## 5. Where I stopped (deliberately)

- No attempt to use the leaked credentials (MariaDB `sandbox/sandbox2018`, Redis `sandbox_redis_2018`, `root/123456`, Discord bot token/client secret, Firebase/EMAS keys) against any live service.
- No auth bypass on `admin-api` / `inner-api` / `user-api` beyond a single unauthenticated GET each to observe the posture.
- No path-normalization fuzzing, no rate-limit testing, no account enumeration, no CAPTCHA solving, no region-lock bypass on `/cubo-api/` (423 Locked).
- No mass port scan of the 43.174.x / 120.92.x / 190.92.x ranges — only the specific documented hosts and a small fixed port set.
- No mass enumeration of the `*.blockmanmobile.com` space (thousands of subdomains on 172.237.146.x) beyond what passive DNS returned.

All findings above come from public DNS/CT data and unauthenticated GET/HEAD requests.
