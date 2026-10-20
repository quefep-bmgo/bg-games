# Blockman GO / Sandboxol — API Route Tables (complete working map)

Generated 2026-10-19 from: (a) the live gateway at `https://editorgs.sandboxol.com/`,
(b) the decompiled Node/Go services in the repo, (c) the live web JS bundles,
(d) the live Android client v2.8.2 APK. All requests used to build this were
unauthenticated GET/HEAD.

---

## 1. The live gateway route table (13 services)

Source: `GET https://editorgs.sandboxol.com/routes` and `GET /health`
Health: `{"registry":"etcd","routes_count":13,"status":"ok"}`

| # | Public prefix | Internal etcd service | Backend | Rewrite | Live status (probed) |
|---|---|---|---|---|---|
| 1 | /community-api | sandbox.server-gz.apps.m.api.community-api | community-api | — | routed; root 404 (Go 18B) |
| 2 | /gamedata-api | sandbox.server-gz.apps.api.creator-api | creator-api | -> /creator-api | routed; root 404 — alias of #3 |
| 3 | /creator-api | sandbox.server-gz.apps.api.creator-api | creator-api | — | routed; root 404 |
| 4 | /meditor-api | sandbox.server-gz.apps.m.api.meditor-api | meditor-api | — | routed; `v1/editor/beta_test_games` -> EC_INVALID_PARAMS (needs signed headers) |
| 5 | /version-api | sandbox.server-gz.apps.m.api.version-api | version-api | — | routed; root 404 |
| 6 | /editor-api | sandbox.server-gz.apps.api.editor-api | editor-api | — | routed; root 404 |
| 7 | /notice-api | sandbox.server-gz.apps.api.notice-api | notice-api | — | routed; root 404 |
| 8 | /admin-api | sandbox.server-gz.apps.api.admin-api | admin-api | — | routed by gateway BUT blocked at EdgeOne (branded 404, 1064B HTML) |
| 9 | /event-api | sandbox.server-gz.apps.api.event-api | eventtrack-api | — | routed; root 404 |
| 10 | /inner-api | sandbox.server-gz.apps.api.inner-api | inner-api | — | routed by gateway BUT blocked at EdgeOne (branded 404, 1064B HTML) |
| 11 | /muser-api | sandbox.server-gz.apps.m.api.muser-api | muser-api | — | routed; root 404 |
| 12 | /file-api | sandbox.server-gz.apps.api.file-api | file-api | — | routed; `user/api/v1/file` -> EC_UNAUTHENTICATED (empty uid) |
| 13 | /user-api | sandbox.server-gz.apps.api.user-api | user-api | — | routed; `v1/captcha_id` -> 200 (live captcha) |

**Namespace decoding:** `sandbox` = org/product, `server-gz` = Guangzhou deployment,
`apps` = application group. `*.api.*` = web/creator/ops plane (creator, editor, notice,
admin, eventtrack, inner, file, user). `*.m.api.*` = mobile plane (community, meditor,
version, muser).

**Route-table triage method (GET-only, no auth):** the backends share one error envelope,
so each probed path returns one of three distinguishable states:

| Response | Meaning |
|---|---|
| `404 page not found` (19 B, Go) | route does not exist |
| `{"code":400001,"detail":"invalid custom headers","msg":"EC_INVALID_PARAMS"}` | route EXISTS, needs signed/tenant headers |
| `{"code":400003,"detail":"empty uid","msg":"EC_UNAUTHENTICATED"}` | route EXISTS, needs identity |

---

## 2. Endpoint inventory — v1 generation (from the decompiled Node/Go services)

This is the *older* API generation (repo = Blockman GO v1.9.17). Live v2 uses a different
path scheme (`/user-api/v1/...` style), so most v1 paths now return 404 against the live
prefixes.


### `main-api-dev` — 79 route paths

- `/activity/api/v1/activity/action`
- `/activity/api/v1/activity/title`
- `/activity/api/v1/lucky/turntable`
- `/activity/api/v1/lucky/turntable/block/reward`
- `/activity/api/v1/lucky/turntable/gold/status`
- `/clan/api/v1/clan/decorations/purchase`
- `/clan/api/v1/clan/free/verification`
- `/clan/api/v1/clan/personal/tasks`
- `/clan/api/v1/clan/rank`
- `/clan/api/v1/clan/tasks`
- `/clan/api/v1/clan/tasks/accept`
- `/clan/api/v1/clan/tribe`
- `/clan/api/v1/clan/tribe/base`
- `/clan/api/v1/clan/tribe/blurry/info`
- `/clan/api/v1/clan/tribe/bulletin`
- `/clan/api/v1/clan/tribe/currency`
- `/clan/api/v1/clan/tribe/donation`
- `/clan/api/v1/clan/tribe/donation/history`
- `/clan/api/v1/clan/tribe/id`
- `/clan/api/v1/clan/tribe/member`
- `/clan/api/v1/clan/tribe/member/agreement`
- `/clan/api/v1/clan/tribe/member/agreement/invitation`
- `/clan/api/v1/clan/tribe/member/invite`
- `/clan/api/v1/clan/tribe/member/message`
- `/clan/api/v1/clan/tribe/member/rejection`
- `/clan/api/v1/clan/tribe/member/rejection/invitation`
- `/clan/api/v1/clan/tribe/member/remove`
- `/clan/api/v1/clan/tribe/recommendation`
- `/clan/api/v1/clan/user/rank`
- `/decoration/api/v1/decorations/using`
- `/discord/api/v1/auth/bind`
- `/discord/api/v1/auth/cancel`
- `/discord/api/v1/auth/info`
- `/discord/api/v1/bind/delete`
- `/discord/api/v1/bind/status`
- `/friend/api/v1/friends`
- `/friend/api/v1/friends/recommendation`
- `/friend/api/v1/friends/requests`
- `/friend/api/v1/friends/status`
- `/game/api/v1/game/chat/room`
- `/game/api/v1/games`
- `/game/api/v1/games/all/open/party`
- `/game/api/v1/games/announcement/info`
- `/game/api/v1/games/app-engine/upgrade`
- `/game/api/v1/games/engine`
- `/game/api/v1/games/playlist/friends`
- `/game/api/v1/games/playlist/recently`
- `/game/api/v1/games/resource/version`
- `/game/api/v1/games/stop/announcement/info`
- `/game/api/v1/games/ugc`
- `/game/api/v1/games/ugc/status`
- `/game/api/v1/party/auth`
- `/game/api/v2/game/auth`
- `/game/api/v2/games/recommendation`
- `/game/api/v2/games/recommendation/type`
- `/mailbox/api/v1/mail`
- `/mailbox/api/v1/mail/attachment`
- `/mailbox/api/v1/mail/new`
- `/msg/api/v1/group/chat/price`
- `/msg/api/v1/msg/group/chat/list`
- `/pay/api/v1/first/punch/reward`
- `/pay/api/v1/pay/payssion/flag`
- `/pay/api/v1/pay/products`
- `/pay/api/v1/pay/products/vip`
- `/pay/api/v1/wealth/user`
- `/shop/api/v1/shop/decorations/buy`
- `/user/api/v1/app/auth-token`
- `/user/api/v1/app/login`
- `/user/api/v1/app/renew`
- `/user/api/v1/app/set-password`
- `/user/api/v1/file`
- `/user/api/v1/login-out`
- `/user/api/v1/report/push`
- `/user/api/v1/user/details/info`
- `/user/api/v1/user/info`
- `/user/api/v1/user/language`
- `/user/api/v1/user/password/modify`
- `/user/api/v1/user/player/info`
- `/user/api/v1/user/register`

### `inner-api-dev` — 1 route paths

- `/discord/api/v1/bind/status`

### `game-service-api` — 1 route paths

- `/v1/dispatch`

### `game-service-dispatcher` — 1 route paths

- `/v1/dispatch`

---

## 3. Controller route tables (method + path) as declared in source

`controller.js` route objects from the Node services:

- `inner-api-dev` — **GET** `/discord/api/v1/bind/status`  — `inner-api-dev\inner-api-dev\src\services\discord\controller.js`
- `inner-api-dev` — **GET** `/pay/i/api/v1/wealth/users/:userId`  — `inner-api-dev\inner-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/activity/api/v1/activity/action`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET** `/activity/api/v1/activity/title`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET, POST** `/activity/api/v1/lucky/turntable`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET** `/activity/api/v1/lucky/turntable/block/reward`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET** `/activity/api/v1/lucky/turntable/gold/status`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET, POST** `/activity/api/v1/signIn`  — `main-api-dev\main-api-dev\src\services\activity\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/decorations/:typeId`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/decorations/details/:decorationId`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/decorations/purchase`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/free/verification`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/personal/tasks`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/rank`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET, PUT** `/clan/api/v1/clan/tasks`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/tasks/accept`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET, POST, PUT, DELETE** `/clan/api/v1/clan/tribe`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/base`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/blurry/info`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET, POST** `/clan/api/v1/clan/tribe/bulletin`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/currency`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET, POST** `/clan/api/v1/clan/tribe/donation`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/donation/history`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/id`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET, POST, PUT, DELETE** `/clan/api/v1/clan/tribe/member`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/tribe/member/agreement`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/tribe/member/agreement/invitation`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **POST** `/clan/api/v1/clan/tribe/member/invite`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/member/message`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/tribe/member/rejection`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **PUT** `/clan/api/v1/clan/tribe/member/rejection/invitation`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **DELETE** `/clan/api/v1/clan/tribe/member/remove`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/tribe/recommendation`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/clan/api/v1/clan/user/rank`  — `main-api-dev\main-api-dev\src\services\clan\controller.js`
- `main-api-dev` — **GET** `/config/files/:configFile`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **GET** `/decoration/api/v1/decorations/:otherId/using`  — `main-api-dev\main-api-dev\src\services\decoration\controller.js`
- `main-api-dev` — **GET** `/decoration/api/v1/decorations/using`  — `main-api-dev\main-api-dev\src\services\decoration\controller.js`
- `main-api-dev` — **PUT, DELETE** `/decoration/api/v1/decorations/using/:decorationId`  — `main-api-dev\main-api-dev\src\services\decoration\controller.js`
- `main-api-dev` — **GET** `/decoration/api/v:version/decorations/:typeId`  — `main-api-dev\main-api-dev\src\services\decoration\controller.js`
- `main-api-dev` — **POST** `/discord/api/v1/auth/bind`  — `main-api-dev\main-api-dev\src\services\discord\controller.js`
- `main-api-dev` — **POST** `/discord/api/v1/auth/cancel`  — `main-api-dev\main-api-dev\src\services\discord\controller.js`
- `main-api-dev` — **GET** `/discord/api/v1/auth/info`  — `main-api-dev\main-api-dev\src\services\discord\controller.js`
- `main-api-dev` — **DELETE** `/discord/api/v1/bind/delete`  — `main-api-dev\main-api-dev\src\services\discord\controller.js`
- `main-api-dev` — **GET** `/discord/api/v1/bind/status`  — `main-api-dev\main-api-dev\src\services\discord\controller.js`
- `main-api-dev` — **GET, POST, DELETE** `/friend/api/v1/friends`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **PUT** `/friend/api/v1/friends/:friendId/agreement`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **POST, DELETE** `/friend/api/v1/friends/:friendId/alias`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **PUT** `/friend/api/v1/friends/:friendId/rejection`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v1/friends/info/:nickName`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v1/friends/info/id/:friendId`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v1/friends/recommendation`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v1/friends/requests`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v1/friends/status`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET** `/friend/api/v2/friends/:friendId`  — `main-api-dev\main-api-dev\src\services\friend\controller.js`
- `main-api-dev` — **GET, PUT** `/game/api/v1/game/:gameId/turntable`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/game/:gameId/turntable/props`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **POST, DELETE** `/game/api/v1/game/chat/room`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **PUT** `/game/api/v1/games/:gameId/appreciation`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/:gameId/rank`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/:gameId/uses/rank`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/all/open/party`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/announcement/info`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/app-engine/upgrade`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/config/app/:gameId`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **PUT** `/game/api/v1/games/engine`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/playlist/friends`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/playlist/recently`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/resource/version`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/stop/announcement/info`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/team/member/:teamId`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/ugc`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/ugc/status`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/update/list/:userId`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/update/tip/info/app/:gameId`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/games/warmup/:gameId/languages/:language`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v1/party/auth`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v2/game/auth`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v2/games/:gameId`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v2/games/recommendation`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET** `/game/api/v2/games/recommendation/type`  — `main-api-dev\main-api-dev\src\services\game\controller.js`
- `main-api-dev` — **GET, PUT** `/mailbox/api/v1/mail`  — `main-api-dev\main-api-dev\src\services\mail\controller.js`
- `main-api-dev` — **PUT** `/mailbox/api/v1/mail/attachment`  — `main-api-dev\main-api-dev\src\services\mail\controller.js`
- `main-api-dev` — **GET** `/mailbox/api/v1/mail/new`  — `main-api-dev\main-api-dev\src\services\mail\controller.js`
- `main-api-dev` — **GET** `/msg/api/v1/group/chat/price`  — `main-api-dev\main-api-dev\src\services\msg\controller.js`
- `main-api-dev` — **GET** `/msg/api/v1/msg/group/chat/list`  — `main-api-dev\main-api-dev\src\services\msg\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/first/punch/reward`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/pay/payssion/flag`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/pay/products`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/pay/products/vip`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/wealth/record/users/:userId`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **GET** `/pay/api/v1/wealth/user`  — `main-api-dev\main-api-dev\src\services\pay\controller.js`
- `main-api-dev` — **PUT** `/shop/api/:version/shop/game/props`  — `main-api-dev\main-api-dev\src\services\shop\controller.js`
- `main-api-dev` — **PUT** `/shop/api/v1/pay/game/:gameId`  — `main-api-dev\main-api-dev\src\services\shop\controller.js`
- `main-api-dev` — **GET** `/shop/api/v1/shop/decorations/:typeId`  — `main-api-dev\main-api-dev\src\services\shop\controller.js`
- `main-api-dev` — **PUT** `/shop/api/v1/shop/decorations/buy`  — `main-api-dev\main-api-dev\src\services\shop\controller.js`
- `main-api-dev` — **GET** `/shop/api/v1/shop/decorations/pages/:typeId`  — `main-api-dev\main-api-dev\src\services\shop\controller.js`
- `main-api-dev` — **GET** `/user/api/v1/app/auth-token`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/app/login`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/app/renew`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/app/set-password`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **PUT** `/user/api/v1/login-out`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/report/push`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/user/details/info`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **PUT** `/user/api/v1/user/info`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/user/language`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **PUT** `/user/api/v1/user/nickName`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **GET** `/user/api/v1/user/nickName/free`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/user/password/modify`  — `main-api-dev\main-api-dev\src\services\account\controller.js`
- `main-api-dev` — **GET** `/user/api/v1/user/player/info`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/user/register`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **GET** `/user/api/v1/users/:userId/daily/tasks/ads/config`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **POST** `/user/api/v1/users/prefect/info/reward/:userId`  — `main-api-dev\main-api-dev\src\services\user\controller.js`
- `main-api-dev` — **GET, PUT** `/user/api/v2/users/:userId/daily/sign/in`  — `main-api-dev\main-api-dev\src\services\user\controller.js`

---

## 4. Endpoint inventory — v2 generation (live)

### 4a. Live web portal (`www.blockmango.com`, bundle `index_v1.f161662bce645aa1a340.js`)

Base: `https://www.blockmango.com/cubo-api/*` (geo-locked: returns `423 Locked` from
non-China IPs). The same services are reachable through the gateway prefixes.

| Path | Notes |
|---|---|
| `/user-api/v1/account/email/register` | live (200 on gateway for `/user-api/v1/captcha_id`) |
| `/user-api/v1/account/email/sendcode/register` | |
| `/user-api/v1/captcha_code/`, `/user-api/v1/captcha_id` | captcha issuance, 200 |
| `/user-api/v1/region/recommend/list` | |
| `/user-api/v1/register` | |
| `/cubo-api/{user,clan,shop,pay,game,decoration,msg,mailbox,activity,friend,web,config,geoinfo,process,editorpay,editorproxy,editorstatistic}/…` | 16 resource families |
| `/game/api/v1/inner/region/disp-cluster-list` | dispatcher/room cluster discovery (GET) |
| `/msg/api/v1/zendesk/sso/jwt/url` | support = Zendesk SSO |
| `/datareport/api/v1/pc/data/upload` | telemetry upload |
| `/api/v1/app/set-password` | account |
| `/sessions/login/web`, `/token-info` | session |

### 4b. Live Android client v2.8.2 (APK `classes*.dex`)

| Path prefix | Endpoints |
|---|---|
| `/meditor-api/v1/editor/` | `add_game_by_beta_game`, `beta_game/`, `beta_test_games`, `game_entrance_manage`, `latest_and_released_game` |
| `/creator-api/` (from bundle) | `https://editorgs.sandboxol.com/creator-api/` |
| `/gamedata-api/` | alias of `/creator-api` |

### 4c. Client auth headers (from `IUserApi.java` / `IGameApi.java` in the repo + dex)

`bmg-sign`, `bmg-device-id`, `x-shahe-uid`, `x-shahe-token`, `CLIENT-TYPE`, `CLIENT-VERSION`,
`BUILD-VERSION`, `DISPLAY-VERSION`, `sandbox-region`.

The signing secret is present in public client AND server source
(`SECRET = pq0194mxoqfh48L362G6R09T737E273X` — `engine-main/.../server/src/main.cpp` and
`Engine2/.../Blockmango/app/jni/Blockman.cpp`), so `bmg-sign` can be computed by anyone
holding the public client.

---

## 5. The admin plane (exact, from the shipped release tooling)

Host: `admin.mods.sandboxol.com` -> 43.174.196.101 (Tencent EdgeOne). Ports **3000**
(oversea) and **3001** (vanguard) accept TCP; `:3001` answers `Server: Lego Server`.

| Endpoint (from `upload_tool.py` / `publish_tool.py`) | Method | Params |
|---|---|---|
| `/api/v1/games/game-plugin/upload` | POST | `timestamp`, `nonce`, `signature`, `force`, `gid`, `engineVersion` + multipart `file` |
| `/api/v1/games/engine-resource/app/games/publish` | POST | `timestamp`, `nonce`, `signature`, `gameId`, `engineVersion` |
| `/api/v1/games/game-plugin/publish` | POST | `timestamp`, `nonce`, `signature`, `gameId`, `engineVersion`, `force` |

**Request credential actually used by the tooling (hardcoded in the public APK):**

```
timestamp : 1499049522339        (fixed 2017-07-04 value — not a live clock)
nonce     : 154719               (fixed)
signature : 88df1aad4acf445c1a396caf15fd8c0a24ad5725
```

The `-p/--password` argument (`md5 == 3bcd4a5027e51ff2be50560584631100` -> `sandboxol`) is a
**purely local interlock**: it is md5'd and compared in the client script and is *never
placed in params, headers or body*. It only fires when `area` does not contain `test`, i.e.
it is an "are you sure you meant production" prompt, not authentication. `publish_tool.py`
has no password check at all.

`copy_version.py` / `delete_version.py` do not use the admin API at all — they write
directly to object storage (`sandbox/config/server/game-resource-config_<gameId>`) with
`AWS_ACCESS_KEY`/`AWS_SECRET_KEY` or `KS3_ACCESS_KEY`/`KS3_SECRET_KEY` from **environment
variables** (not shipped) and `ACL='public-read'`.

---

## 6. The public "switchboard" — what the release tooling edits is publicly readable

`GET https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>`
returns **200** for every game tested (g1008 49 KB, g1011 73 KB, g1022 48 KB, g1050 26 KB).

Content per engine version:
`plugin` (zip URL + md5) · `maps[]` (durl + mapHash + per-file `configFiles` with key/url/hash)
· `fileSize` / `fileCount` · **`pluginStaging`** and **`mapsStaging`** — pointers to
*pre-release* artifacts, e.g. `g1008` v10092 -> `pluginStaging.plugin` =
`…/sandbox/games/plugins/g1008.1666842911136.zip`, and v10103 -> `mapsStaging` with
`10076.1624611597106.zip`.

So: the exact object that `copy_version.py`/`delete_version.py` mutate is world-readable, and
it advertises unreleased content paths and hashes.

---

## 7. What is still open for testing, and what needs written authorization

### Safe / already done (GET-only, unauthenticated)
- Enumerate the 13 prefixes and their service names — done.
- Enumerate public objects in `static.sandboxol.com` / `staticgs.sandboxol.com` — done.
- Enumerate the live client + web bundle endpoint lists — done.
- Differential route probing via the error envelope — done.

### Requires written authorization from Sandboxol (do NOT run without a signed scope)
1. `POST /api/v1/games/game-plugin/upload` with the hardcoded `signature` — a **write** to the
   production content pipeline. The lowest-impact variant would be a non-existent
   `gid=g9999` / `engineVersion=1` so the request is provably a no-op, but it is still an
   authenticated write attempt against a production admin API.
2. Path-normalization testing of the EdgeOne block on `/admin-api` and `/inner-api`
   (`//admin-api`, `/Admin-Api`, `/admin-api%2f`, `/admin-api/..;/`, trailing dot) — this is
   deliberate evasion of an access control.
3. Any use of the recovered DB/Redis/Discord/Firebase/EMAS credentials, or password
   mutations against live auth.
4. Reading or writing the object-storage bucket with any credential other than an anonymous
   public read.

### If you do hold an engagement, the exact minimal checks are
```
# A. is the static signature accepted? (expect non-200 or "game not found" => signature rejected)
curl -i -X POST "https://admin.mods.sandboxol.com:3000/api/v1/games/game-plugin/publish?timestamp=1499049522339&nonce=154719&signature=88df1aad4acf445c1a396caf15fd8c0a24ad5725&gameId=g9999&engineVersion=1&force=0"

# B. does the edge block apply to the gateway path or the origin? (read-only GET)
for p in /admin-api/ //admin-api/ /Admin-Api/ /admin-api%2f /admin-api/..;/admin-api/; do
  curl -sk -o /dev/null -w "%{http_code} $p\n" "https://editorgs.sandboxol.com$p"
done
```

