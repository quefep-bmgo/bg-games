# Blockman GO — Repository Extraction & Identifier Analysis Report

**Source:** `Copy of Copie de Blockman-Go (2).zip` (3.63 GB / 3458 MiB, Zip64)
**Password supplied:** `I_TAKE_FULL_RESPONSIBILITY_THAT_I_WILL_NOT_INFRINGE_BLOCKMAN_GO_COPYRIGHT_2023` (not required — the outer archive is not encrypted; it was supplied to every nested extraction as well)
**Analysis date:** 2026-10-19

---

## 1. Extraction coverage (every file)

| Step | Result |
|---|---|
| Outer archive | 16 member ZIPs + 1 folder |
| Level-2 archives extracted (7-Zip) | 16/16 |
| Nested archives found inside extracted tree | 162 (incl. map bundles `m1008_1.zip` … `m1101*.zip`, per-map zips inside `cdn-serve`/`cdn-api-service`/`maps`) |
| Nested archives extracted (recursive, Python `zipfile`) | 162/162, 3 passes, 0 failures |
| **Total files after full extraction** | **159,079** |
| **Total bytes** | **14.90 GB** |
| Directories | 16 top-level projects |

Top-level projects and sizes:

| Project | Files | Size | What it is |
|---|---|---|---|
| `Engine2` | 104,296 | 7.03 GB | Engine v2 (C++ client+server, WorldEditor2, WELauncher, lua client, PhysX) |
| `game-maps` | 18,250 | 1.44 GB | All game map packs (`g1001`–`g1063`+) |
| `Engine2-PhysX-4.1` | 7,359 | 0.65 GB | NVIDIA PhysX 4.1 source |
| `cdn-serve` | 1,092 | 0.57 GB | CDN server (js + go) + APK snapshots |
| `engine-dependencies` | 71 | 0.47 GB | Prebuilt engine dependency blobs |
| `engine-v10096-client-debug` | 10,937 | 0.43 GB | Engine v10096 client debug build |
| `maps` | 382 | 0.32 GB | BMF map source master |
| `engine-main` | 7,936 | 0.11 GB | Engine main (C++ client/server) |
| `engine-resources` | 3,391 | 0.10 GB | Engine resource assets |
| `cdn-api-service` | 508 | 0.06 GB | CDN API service (node) |
| `cdn-serve-dev` | 510 | 0.06 GB | CDN dev server (go) |
| `android-client-dev` | 2,869 | 0.03 GB | Android client (Java/Gradle) |
| `main-api-dev` | 1,291 | 0.02 GB | Main API (Node.js) |
| `inner-api-dev` | 105 | <0.01 GB | Inner API (Node.js) |
| `game-service-api` | 49 | <0.01 GB | Game service API (Node.js) |
| `game-service-dispatcher` | 17 | <0.01 GB | Dispatcher/room server (Go) |

Scanning: 100% of files were read (byte-level) for high-signal markers; 66,450 text/source files were additionally regex-parsed for structured identifiers. No `.git` directories survived in the dump (no git metadata / author history available).

---

## 2. DISCORD

### 2.1 Invite links (5 distinct)

| Invite | Where | Purpose |
|---|---|---|
| `https://discord.gg/9yhFqvmgfN` | `android-client-dev/.../blockymods/config/UrlConstant.java:26` (`String DISCORD_URL`) | Main Blockman GO community invite shown in the in-app Help/Contact dialog (`HelpContactDialog.java` → `Uri.parse(UrlConstant.DISCORD_URL)`) |
| `https://discord.gg/Qpue8XBhxc` | `Engine2/.../dev/tools/WorldEditor2/src/ini_manager.cpp` + `ini_manager.h` + `res/tools/newpack/zip_pgc_test/worldeditor_template.ini` (`helpcenter`) | Blockman Editor / WorldEditor2 help center |
| `https://discord.gg/MFaTsAt` | `Engine2/.../engine-core/dev/tools/WorldEditor2/src/ui/mainmenubar.cpp` (`MainMenuBar::OpenHelp()`) | "Official discord" button in the WorldEditor2 main menu |
| `https://discord.gg/f4HsV3QH3C` | `game-maps/game-map-main/games/g1061/.../setting/CommunitySharing.yml` (`copyTextKey`) | "Copy content" share link in the Sky Block / community-sharing map |
| `https://discord.com/invite/bgskyblock` | `game-maps/game-map-main/games/g1050/.../setting/lang/*.lang` (14 languages) | **Sky Block (g1050) map community server** |

### 2.2 Discord application / bot credentials

`main-api-dev/main-api-dev/src/config/discord.json` (identical values in `inner-api-dev/inner-api-dev/src/config/discord.json`):

```
CLIENT_ID      : 1217767872718311424
CLIENT_SECRET  : QGPWz47RWqKa49AGKdDcKtcrzGhiBTg_
BOT_TOKEN      : MTI0Mzk4MTc4NzUzMzkzNDYyMw.G-A2Xq.H2ysP2UJlOmPdz0kG-d9CamRIrQMLq65g22FgI
BOT_PREFIX     : ?
BOT_OWNERS     : 1227864557641404510
OWNER_ONLY     : true
LOG_CHANNEL    : 1244651956648149072
GUILD_ID       : 1236910125068058706
BASE_ENDPOINT  : https://discord.com/api
CDN_BASE       : https://cdn.discordapp.com
```

Decoded: `BOT_TOKEN` base64 segment → **bot user ID `1243981787533934623`**.
So the Discord IDs present are: Application `1217767872718311424`, Bot `1243981787533934623`, Owner `1227864557641404510`, Log channel `1244651956648149072`, Guild `1236910125068058706`.

### 2.3 Discord API surface (server side)
`main-api-dev/src/services/discord/{controller,service}.js`, `inner-api-dev/src/services/discord/*`:
`GET /discord/api/v1/auth/info` · `POST /discord/api/v1/auth/bind` · `POST /discord/api/v1/auth/cancel` · `GET /discord/api/v1/bind/status` · `DELETE /discord/api/v1/bind/delete` (user-to-Discord account binding, `AccountBinding.connectId` = Discord user id).

### 2.4 Discord — false positives excluded
`https://img.shields.io/discord/846584335921840148` → `discord.com/channels/846584335921840148` belongs to **atframework/cmake-toolset** (third-party library), *not* Blockman.

---

## 3. TELEGRAM

**No Telegram identifiers found anywhere in the repository.** The only `telegram` string occurrences are CSS icon classes in third-party assets (FontAwesome `.fa-telegram` in PhysX docs theme, and a Chinese OBJ-format .mhtml page). Zero `t.me/` links, zero Telegram bot tokens (pattern `[0-9]{8,10}:[A-Za-z0-9_-]{35}`), zero `@telegram` handles. The game also has **no QQ group numbers, WeChat IDs, WeChat groups, or QQ contact info** — the only `wechat/weixin` hits are SDK enum names (`ENTRY_ID_MM // wechat`), an iOS `CFBundleURLName = weixin` URL-scheme stub, and FontAwesome icons. The only real QQ reference is a third-party library author's QQ (`493749449`, libiniloader) and a Tencent log4z author's group (`19811947`).

---

## 4. PHONE NUMBERS

**No genuine phone numbers are present.** Exhaustive check:
- Chinese mobile pattern `(?<!\d)1[3-9]\d{9}(?!\d)` over every file ≤2 MB: **222 hits, all false positives** (MD5/hash substrings, texture binary payloads, `.ini` numeric IDs, `1_release_server_files_cache.json` hash lists).
- International `+CC` format: **0 hits**.
- The Android client only has UI strings for binding a phone (`bind_phone_phone_hint` = "输入手机号码") — no hardcoded numbers.

---

## 5. EMAIL ADDRESSES (first-party / personal)

| Email | Where | Note |
|---|---|---|
| `blockymods@sandboxol.com` (also `Blockymods@sandboxol.com`) | `android-client-dev/.../view/dialog/HelpContactDialog.java` (`mailto:`), `FiveStarsDialog.java`, all `res/values*/strings.xml` (en/zh/es/pt/ru/ja/vi/in), `cdn-serve/cdn-bmf-master/apks/snapshots/1.0.1/app-blockyforge-...apk` | **Official public support address** (mailto target in the app) |
| `zhouwei@sandboxol.com` | `Engine2/.../dev/tools/BugReport/BugReport/BugReport.cpp`, `WEInstaller/nsisQt/*`, `WELauncher/WELauncher/*`, `WorldEditor2/src/download/download_task.h`, `WorldEditor2/src/game_mgr/*.h` | Developer contact address for the WorldEditor/Launcher tools (author tags "Kandy", "Administrator") |
| `getao@sandboxol.com` | `Engine2/.../engine-core/dev/libraries/optick/include/optick_core.linux.h` (comment: `// by <getao@sandboxol.com> copy from 'https://source...`) | sandboxol engineer account |
| `luoxiaoke@yuntutv.net` | `android-client-dev/.../common/utils/PermissionUtils.java` (`Created by Fungo_Xiaoke ... eamil:luoxiaoke@yuntutv.net`) | Individual developer (Luo Xiaoke / "Fungo_Xiaoke") |
| `1101255053@qq.com` | `android-client-dev/PhotoPicker/.../utils/FileUtils.java` (`Created by myc ... More Code on 1101255053@qq.com`) | Individual developer "myc" (also a QQ number) |
| `huimiao638@163.com` | `Engine2/.../dev/tools/WorldEditor2/src/Tool/tools.h` (`\author freeyun  Contact: huimiao638@163.com`) | Individual developer "freeyun" |
| `lijia-liao@outlook.com` | `Engine2/.../dev/client/Src/Audio/ObjectAudio.h` (`//Author:LIGA lijia-liao@outlook.com`) | Individual developer "LIGA" |

Every other email in the tree (3,857 unique) belongs to vendored open-source projects (curl, FreeType, FreeImage, RakNet, zlib, Godot translators, LuaJIT, etc.) and is not attributable to Blockman.

**Corporate naming rule found in the git hook** (`Engine2/.../hook/pre-commit`): employee git identity must be `<name>@sandboxol.com`, and the commit message must reference a TAPD ticket; failures print *"修改后仍有问题请联系赵宗晟"* (contact **赵宗晟 / Zhao Zongsheng**) and link the internal wiki `https://gz-inner.sandboxol.cn:18080/dokuwiki/doku.php?id=流程优化:如何配置git名字和邮箱`.

---

## 6. PERSON / DEVELOPER NAMES

All extracted from first-party file headers, `Created by`, `Author:`, `author:` and EmmyLua generation stamps.

### 6.1 Blockman / sandboxol staff (aliases seen in code)

| Name | Sample location | Company field |
|---|---|---|
| `qutianxiang` | `Engine2/.../dev/client/Src/Global.h` (`author: qutianxiang  company: sandboxol  date: 2017/06/23`) | **sandboxol** |
| `ajohn` | `Engine2/.../dev/client/Src/Blockman/cWorld/Blockman.h` (`author: ajohn  company: supernano  date: 2016-11-15`) | **supernano** |
| `Kandy` / `kandy` | `WELauncher/*.h`, `WorldEditor2/src/download/download_task.h`, `BugReport/utils/frameless_dialog.h` (contact `zhouwei@sandboxol.com`) | sandboxol |
| `Administrator` | `WEInstaller/nsisQt/QDragDialog.h`, `QPushButtonEx.h`, `res/lua/client/ui/cui/GUIActorWindow.lua` | sandboxol |
| `Zongsheng` (赵宗晟) | `Engine2/.../engine-core/dev/tools/ConvertMap/.../CommandLineArgument.java`; named in `hook/pre-commit` | sandboxol |
| `liangxl` | `android-client-dev/.../CrashHandler.java` (2016/5/18), `Engine2/.../Blockmango/app/.../CrashHandler.java` | sandboxol |
| `luo` | `Engine2/.../Blockmango/app/jni/mtp/Mtp.cpp` (2020/8/3), `res/lua/client/function_setting.lua` | sandboxol |
| `Mr.Luo` | `android-client-dev/.../entity/Lang.java`, `.../router/ControllerType.java`, `.../web/Dispatch.java` | sandboxol |
| `gavin gu` | `Engine2/.../Blockmango/app/jni/mtp/tp2_sdk.h` (`Author: gavin gu`, 2013-3-14) | — |
| `tom` | `Engine2/.../dev/server/src/ATProxy.cpp` (2020/1/10) | sandboxol |
| `jory` | `Engine2/.../IOS/BlockMangoServer/BlockMangoServer.h` (2020/10/30) | — |
| `KiBen` / `KiBen Hung` | `Engine2/.../IOS/BlockWorld/BlockWorld/BMUtils.h`, `BlockModsGameKit.h` (2013–2018) | — |
| `zhangyi` | `Engine2/.../IOS/backup/IOSSoundEngine.cpp` (13-11-22), `IOS/BlockWorld/BlockWorld/AppDelegate.h` (14-6-4) | — |
| `zhouyou` | `Engine2/.../IOS/BlockWorld/BlockMan/AppDelegate.h` (14-6-4) | — |
| `luoweiyi` | `android-client-dev/.../utils/IconCrop.java`, `.../router/StartMc.java` | sandboxol |
| `Fungo_Xiaoke` | `android-client-dev/.../common/utils/PermissionUtils.java` (2017/5/4) | sandboxol |
| `Bob` | `android-client-dev/.../App.java`, `.../WebViewHelper.java`, `.../anim/DressUpDownAnim.java` | sandboxol |
| `marvin` / `Marvin` | `android-client-dev/.../adapter/TribeCreateLabelsAdapter.java`, `.../view/activity/friends/FriendInfoViewModel.java` | sandboxol |
| `Jimmy` / `JiMMy` | `android-client-dev/.../common/base/app/BaseApplication.java`, `.../web/adapter/DataOnResponseAdapter.java` | sandboxol |
| `royal` | `android-client-dev/.../ShakeListener.java` | sandboxol |
| `gaozhidong` | `android-client-dev/.../adapter/NineGridImageViewAdapter.java` (2019) | sandboxol |
| `ender` | `android-client-dev/.../entity/LatestVersion.java` | sandboxol |
| `dongjunpeng` | `android-client-dev/.../common/utils/SymmetricEncryptUtil.java` (`@author`) | sandboxol |
| `donglua` / `Donglu` | `android-client-dev/PhotoPicker/.../*` | — |
| `myc` | `android-client-dev/PhotoPicker/.../utils/FileUtils.java` | — |
| `黄东鲁` (Huang Donglu) | `android-client-dev/PhotoPicker/.../utils/PhotoDirectoryLoader.java` | — |
| `Ortiz` | `android-client-dev/PhotoPicker/.../widget/TouchImageView.java` (`@author`) | — |
| `huzj` | `Engine2/.../dev/client/Src/Blockman/Render/GuideLineRenderer.cpp` | — |
| `huzijian` | `Engine2/.../dev/client/Src/Blockman/Render/RenderBlock.cpp` (2020.2.7) | — |
| `maxicheng` | `Engine2/.../dev/client/Src/Blockman/cWorld/Blockman.cpp` | — |
| `liuzhanjie` | `Engine2/.../engine-core/dev/engine/Src/Core/Scene/SceneManager.cpp` (`by liuzhanjie -- 2022.7.1`) | — |
| `freeyun` | `Engine2/.../WorldEditor2/src/Tool/tools.h` | — |
| `LIGA` | `Engine2/.../dev/client/Src/Audio/ObjectAudio.h` | — |
| `wangpq` | `Engine2/.../res/lua/client/define.lua` (EmmyLua stamp 2020/6/30) | — |
| `Jimmy` / `cs` / `hlm` / `bell` / `GIGABYTE` / `williamoj` / `work` / `great90` / `Anybook` / `qinjiancai` / `Administrator` / `luo` / `Luanalysis` / `PluginCreator` | `Engine2/.../res/lua/**` EmmyLua "Created by X" stamps (2018-2022) | sandboxol |
| `Perfect` | `Engine2/.../IOS/BlockWorld/BlockMan/RootViewController.h` (13-8-20) | — |
| `admin` | `Engine2/.../IOS/BlockModsGameNewKit/.../GameEnditBoxImpIOS.h` (2020/12/30) | — |
| `BytePulse` | `main-api-dev/main-api-dev/package.json` (`"author": "BytePulse"`) | main-api team |
| `Velaire` | `game-service-api/game-service-api-main/package.json` (`"author": "Velaire"`) | game-service team |

### 6.2 Other company/team names in headers
`sandboxol`, `supernano`, `sandboxol.com`, `blockmango`, `BytePulse`, `Velaire`, `atframework` (3rd-party lib).

---

## 7. USER IDs / ACCOUNT IDs

- **Blockman user ID format:** 64-bit integer, e.g. `1623294195183512` (seen in `res/Media/.../win_modMain.lua` → `http://static.sandboxol.cn/avatar/1623294195183512.jpg`). Also `request.getUserId()` in the Node API layer; `UserInfo`/`Friend`/`TribeMember` GreenDao entities.
- **Discord-side user id** stored as `AccountBinding.connectId` (Discord snowflake).
- **No hardcoded real player accounts / admin accounts / whitelists** were found. `cdn-api-service/cdn-serve-js-master/config.json` has `"useWhitelist": false, "whitelistedIPs": []`; `cdn-serve-dev/main.go` has the same empty structure. No GM/admin UID tables exist in the dump.
- **Room-server internal message constants** (`game-service-api/src/dispatcher/room/constants.js`): `GAME_SERVER_USER_IN=151`, `USER_OUT=152`, `SYNC_USERS=155`, `MANOR_SOLD=156`, `KICK_USER_OUT=160`, `REPORT_FRAME_TIME=161`, `ROOM_MANAGER_HTTP_SECRET=163`, `GAME_SERVER_HTTP_SECRET=164` (these are message-type IDs, not user IDs).
- Seeded/sample data only: `main-api-dev/database/appconfigs/indiegame-recommend.json` (nickNames "Wtf123", "E", "What", "No", "Bruh", "Real" with country/sex — marketing placeholders).

---

## 8. INFRASTRUCTURE — HOSTS, IPs, PORTS

### 8.1 Public / production infrastructure (first-party)

| Host | Port(s) | File |
|---|---|---|
| `149.202.146.216` | 3306 (MariaDB `bmfdb`, user `root`), 80 | `game-service-dispatcher/.../configs/host.json`, `configs/database.json` |
| `188.165.91.105` | 3888 (CDN), 7500 (dispatcher), 19130 (game) | `game-service-dispatcher/.../configs/host.json` |
| `207.180.204.162` | 6379 (Redis) | `game-service-dispatcher/.../configs/database.json` |
| `120.92.136.119` | 3306 (MariaDB `game`), 6379 (Redis) | `engine-main/bmf-engine-main/server/src/main.cpp` |
| `120.92.133.131` | 9912 (monitor) | `engine-main/.../server/src/main.cpp` |
| `120.92.141.96` | 8910 (DB HTTP service) | `engine-main/.../server/src/main.cpp` |
| `120.92.158.119` | 80 (blockymods API / rewards) | `engine-main/.../server/src/main.cpp` |
| `dev.sandboxol.com` | 8943 (prop), 8945 (rank/reward), 8961 (blockman) | `engine-main/.../server/src/main.cpp` |
| `d401m01aifavw.cloudfront.net` | 80 | `Engine2/.../dev/client/Src/StartParameter.h` (resource upload) |
| `gitlab001.sandboxol.cn` | 31006 (SSH) | `Engine2/.../dev/deploy/pullcore.sh` |
| `gitlab001.sandboxol.cn` | 18080 | `Engine2/.../hook/pre-commit` (internal DokuWiki at `gz-inner.sandboxol.cn:18080`) |
| `crashsight.qq.com` | 443 | crash-report links in `Engine2/.../game.cpp`, `ActorManager.cpp`, `MergeActor.cpp` |
| `keepalive.sandboxol.cn` | 7952 | `WorldEditor2/src/ini_manager.h`, `WELauncher/IniManager.h` |
| `gz.sandboxol.cn` | 5000 (`/sign/pc`) | `Engine2/.../dev/client/Shells/Win32/Delivery/_packing_tools.py` |
| `www.sandboxol.net` | 18090 | `Engine2/.../dev/tools/WEInstaller/nsisQt/QtMainDlg.cpp` |

### 8.2 Internal / developer LAN (private IPs) — dev configuration left in the tree

| Host | Port | File |
|---|---|---|
| `192.168.99.116` | 7999 (main-api), 3888 (CDN), 7500 (dispatcher), 80, 8899 | `main-api-dev/src/config/host.json`, `android-client-dev/build.gradle`, `app/build.gradle` |
| `192.168.1.35` | 8899, 3888, 19130 | `game-service-api/src/config/host.json` |
| `192.168.1.11` | 8086 | `android-client-dev/game/.../EchoesHandler.java` |
| `192.168.1.105` | 8079 (patch server) | `engine-main/.../client/Shells/Android/Blockmango/app/src/main/assets/resources/game.ini` |
| `172.28.80.238` | 6379 (Redis) | `game-service-api/src/config/database.json` |

### 8.3 First-party domains (all)

`static.sandboxol.com` · `static.sandboxol.cn` · `mods.sandboxol.com` · `admin.mods.sandboxol.com` · `prodvanguard.mods.sandboxol.com` · `dev.mods.sandboxol.cn` · `dev.sandboxol.com` · `dev.sandboxol.cn` · `ols.sandboxol.com` · `editorapi.sandboxol.com` · `editorweb.sandboxol.com` · `bugfixes.sandboxol.com` · `gamedata.sandboxol.cn` · `gz.sandboxol.cn` · `ndev.sandboxol.cn` · `keepalive.sandboxol.cn` · `pre-keepalive.sandboxol.cn` · `pre.sandboxol.com` · `v3.game.sandboxol.com` · `www.sandboxol.cn` · `www.sandboxol.net` · `gitlab001.sandboxol.cn` · `gz-inner.sandboxol.cn` · `www.blockmango.net` · `www.blockmango.com` · `blockmango.net` · `editordocs.blockmango.com` · `blockmango.gameforconnect.com` · `cloudatlasoft.u.qiniudn.com` (Qiniu CDN) · `registry.npmjs.org` · `maven.aliyun.com`

Public-facing product URLs of note:
`https://www.blockmango.net/#/editor` · `https://www.blockmango.net/me.html#/writing-center/game/manage` · `https://www.blockmango.net/recharge.html#/` (top-up) · `https://www.blockmango.net/be/be_login.html?showThrid=true` · `https://editordocs.blockmango.com/docs/user_guide` · `https://editorweb.sandboxol.com/viki-v2/docs/user_guide` · `https://mods.sandboxol.com/web/public/pay/api/v2/public/pay/signature` (payment API) · `https://blockmango.gameforconnect.com/oauth/login?client_id=100112&response_type=token&redirect_uri=…` (OAuth client id **100112**) · `https://keepalive.sandboxol.cn/third-party-middle-page.html#/` (3rd-party login middle page).

---

## 9. REPOSITORIES

### 9.1 Internal GitLab (`gitlab001.sandboxol.cn`) — first-party source repos

| Repo | File |
|---|---|
| `http://gitlab001.sandboxol.cn/game/blockmango-engine.git` | `Engine2/.../cmake.cmd` (cloned into `engine-core`, branches `core_new_*`) |
| `ssh://git@gitlab001.sandboxol.cn:31006/game/blockmango-engine.git` | `Engine2/.../dev/deploy/pullcore.sh` |
| `http://gitlab001.sandboxol.cn/game/blockmango-client.git` | `Engine2/.../dev/Jenkinsfile_PC` (branch `engine2_dev_999`), `dev/client/Shells/Win32/Delivery/Jenkinsfile` (branch `engine2_pc_garena`) |
| `http://gitlab001.sandboxol.cn/web/blogo` | `Engine2/.../dev/atproxy/doc/atproxy.md` (deploy scripts `/scripts/deployer`) |
| `https://gitlab001.sandboxol.cn/physics/physx.git` | `Engine2/.../engine-core/dev/libraries/physX/CMakeLists.txt` |

### 9.2 External repos referenced by first-party code
`github.com/grpc/grpc-java` (Android connector), `github.com/donglua/PhotoPicker` (vendored Android photo picker), `github.com/gin-gonic/gin` (Go dispatcher), `github.com/Mashape/kong` (lua oauth), `github.com/Phrogz/Lunity`, `github.com/Phrogz/SLAXML`, `github.com/bluebird75/luaunit`, `github.com/kans/zirgo`, `github.com/kikito/inspect.lua`, `github.com/curl/curl`, `github.com/redis/hiredis`, `github.com/benhoyt/inih`, `github.com/mateidavid/zstr`, `github.com/preshing/cpp11-on-multicore`, `github.com/glennrp/libpng`, `github.com/MSOpenTech/redis`, `github.com/pietern/hiredis-rb`.
Total unique repo URLs anywhere in the tree: **359** (the rest are vendored 3rd-party deps).

### 9.3 Build / CI references
Jenkins pipelines: `Engine2/.../dev/Jenkinsfile_PC`, `dev/client/Shells/Win32/Delivery/Jenkinsfile` (GitLab CI-style `branches:`/`url:` blocks), plus `cmake.cmd`, `cmake_mobile_editor.bat`, `cmake_pc_editor.bat`, `merge-request.cmd`.
Maven repos: `maven.google.com`, `maven.aliyun.com/nexus/...`, `dl.bintray.com/umsdk/release`, `jitpack.io`, `maven.fabric.io`.
Other: `https://www.tapd.cn/…` (see §11), `https://gz-inner.sandboxol.cn:18080/dokuwiki/…`.

---

## 10. CREDENTIALS / SECRETS FOUND IN THE TREE

> These are live-format secrets committed to source. Treat as sensitive.

| Secret | Value | File |
|---|---|---|
| Discord OAuth client secret | `QGPWz47RWqKa49AGKdDcKtcrzGhiBTg_` | `main-api-dev/src/config/discord.json`, `inner-api-dev/src/config/discord.json` |
| Discord bot token | `MTI0Mzk4MTc4NzUzMzkzNDYyMw.G-A2Xq.H2ysP2UJlOmPdz0kG-d9CamRIrQMLq65g22FgI` | `main-api-dev/src/config/discord.json` |
| Game server signing secret | `pq0194mxoqfh48L362G6R09T737E273X` | `engine-main/.../server/src/main.cpp`, `Engine2/.../Blockmango/app/jni/Blockman.cpp` (`SECRET`) |
| MariaDB password | `sandbox2018` (user `sandbox`, db `game`) | `engine-main/.../server/src/main.cpp` |
| Redis password | `sandbox_redis_2018` | `engine-main/.../server/src/main.cpp` |
| MariaDB/Redis password | `123456` (user `root`, dbs `ugodb` / `bmfdb`) | `game-service-api/src/config/database.json`, `game-service-dispatcher/configs/database.json` |
| Android keystore | storePassword `shahe2015`, keyPassword `blockymods`, keyAlias `blockymods`, file `sandbox.jks` | `android-client-dev/app/build.gradle` |
| Firebase / Google API key | `AIzaSyCbfVxISM9yUrMU8uf5jmRCU7T5pBhih2c` | `android-client-dev/app/google-services.json` |
| Firebase project | `320914605590` / `blockymods-android` / `blockymods-android.appspot.com` / `blockymods-android.firebaseio.com` | `android-client-dev/app/google-services.json` |
| Google OAuth client IDs | `320914605590-588jrrha1revrqfsptk60p44jnavcb8e.apps.googleusercontent.com`, `…-fabe34qi9ld5c7o3gsf54i6sqpf1jq3…`, `…-mgl65gvelo61gdonilq7lhj4jiherb24…`, `…-9d6uu5jet7g7kc6db415ecsinuriip05…` | `android-client-dev/app/google-services.json` |
| Google Play services key (RSA pubkey) | `MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArZ1Y9l2zkLi6NlDlj89wU/zKhqo30+4Rv+JbKL878c3Oe+ZgvtE9+njdD8Yx3b5mZ91G8ZEDcgOB9WztUDPd/PoqDZmY…` | `android-client-dev/app/build.gradle` (`GOOGLE_KEY`) |
| Aliyun EMAS | appKey `25828878`, appSecret `26701c0c4e9e7e0c16d5863243d79da4`, hotfix.idSecret `25828878-1`, RSA hotfix secret (long base64) | `android-client-dev/app/aliyun-emas-services.json` |
| Aliyun HttpDNS | accountId `199011`, secretKey `9643170920cea59907eb0a021c1cf2b5` | `android-client-dev/app/aliyun-emas-services.json` |
| CrashSight app key | `3984bac8-9c89-4b20-8c96-7f8541fa5e9d` | `Engine2/.../WorldEditor2/src/crash_report/crash_sight.h` |
| Resource-upload credential | password `liyuan` | `Engine2/.../engine-core/dev/tools/ResourceUpload/pocket_edition_resource_process.py` |
| App package names | `com.sandboxol.blockymods`, `com.velaire.blockforge`, `test.sandboxol.blockymods` | `android-client-dev` |
| Android certificate hash | `2b6d73d83bde7792d8a6717e4efb8370612509fb` | `android-client-dev/app/google-services.json` |

---

## 11. INTERNAL TOOLING / TRACKERS (organizational identifiers)

| System | Identifiers / URLs | Where |
|---|---|---|
| **TAPD** (Tencent project & bug tracker) | Workspace **42218996** (bugs, stories, wikis), workspace **38329646** (markdown wiki), workspace **65288818** (docs) | ~22 `tapd.cn` links in `Engine2` source comments, e.g. `https://www.tapd.cn/42218996/bugtrace/bugs/view?bug_id=1142218996001012859`, `…/prong/stories/view/1142218996001073966`, `https://www.tapd.cn/38329646/markdown_wikis/show/#1138329646001000421`, `https://www.tapd.cn/65288818/documents/show/1165288818001002704` |
| **Internal DokuWiki** | `https://gz-inner.sandboxol.cn:18080/dokuwiki/doku.php?id=流程优化:如何配置git名字和邮箱` | `Engine2/.../hook/pre-commit` |
| **Commit↔TAPD linkage** | `Engine2/.../强制commit-msg关联TAPD工单的方案.docx` ("scheme for binding commit-msg to TAPD tickets") | Engine2 root |
| **Crash reporting** | CrashSight `crashsight.qq.com` crash-report deep links with crash hashes + `pid=10&version=20058` | `Engine2/.../game.cpp`, `ActorManager.cpp`, `MergeActor.cpp` |
| **Tencent SSO platform** | `SSOPlatform.dll`, `TQMCenter.exe` in `Engine2/.../res/TQM64/` | binary SDKs |

---

## 12. EXTERNAL / THIRD-PARTY DOMINANTS (for completeness)

The tree is ~70% vendored open-source. Dominant domains: `github.com` (977 URLs), `www.opengl.org`, `en.wikipedia.org`, `registry.npmjs.org`, `msdn.microsoft.com`, `dl.google.com`, `docs.godotengine.org`, `stackoverflow.com`, `www.open-std.org`, `code.google.com`, `pypi.org`, `www.lua.org`. Vendored SDKs: PhysX 4.1, Godot engine, Godot physics, OpenSSL/mbedTLS, curl, FreeImage, FreeType, RakNet, LuaJIT, zlib, RapidJSON, CEGUI, g3log, GoogleTest, tolua++, PhysX PVD, Recast, atframework, Optick, log4z, ImGui, LuaCheck/zbstudio, PyInstaller venv.

---

## 13. KEY NEGATIVE FINDINGS (explicitly verified)

- ❌ **No Telegram** identifiers, links, bot tokens, or channels.
- ❌ **No phone numbers** (no CN mobiles, no international `+CC` numbers, no landlines).
- ❌ **No QQ group / WeChat ID / WeChat group** contact data.
- ❌ **No real player accounts, admin accounts, GM accounts, or UID whitelists.**
- ❌ **No `.git` metadata** → no git author list, no commit history, no remote URLs beyond the ones hard-coded in scripts.
- ❌ **No Discord webhooks** (`discord.com/api/webhooks/…` → 0 hits).
- ⚠️ 5 Discord servers/invites, 1 live Discord app + bot token, 2 bot owner IDs, 1 guild ID, 1 channel ID.
- ⚠️ ~20 hardcoded credentials for Google/Aliyun/Discord/DB/Redis/keystore.
- ⚠️ 3 internal GitLab repos + internal DokuWiki + 3 TAPD workspaces exposed.

---

## 14. ARTIFACTS

Extraction root: `C:\Users\quefep\AppData\Local\Temp\opencode\extracted\Blockman-Go` (159,079 files, 14.9 GB)
Raw scan outputs: `C:\Users\quefep\AppData\Local\Temp\opencode\`
(`text_scan.json`, `fast_results.json`, `names_u8.txt`, `authors.txt`, `creds.txt`, `bywho.txt`, `contact.txt`, `cn_contact.txt`, `firstparty.txt`, `kw.txt`)
