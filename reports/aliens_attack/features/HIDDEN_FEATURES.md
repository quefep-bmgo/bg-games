# g1019 (Aliens Attack) — Hidden / Unused / Disabled Feature Audit

All paths relative to `aliens_attack\`. “Hidden” means present in the shipped package but not reachable through normal g1019 UI/gameplay without GM/test/debug or platform changes. Credentials/secrets are reported by location only and are not reproduced.

## 1. Summary

| Area | Finding | Status |
|---|---|---|
| GM commands | Full server/client GM command set, GM password gate, GM grants, server shutdown, DB wipe, AI spawning | Test/ID-gated; production GMCommand auto-kicks |
| Debug port | Localhost telnet 6600–6666 with arbitrary Lua/file execution, attach/kick/GM | `isTest` only |
| Telemetry | DebugPort sends sys info/UDP to hardcoded `47.243.80.43:10086` | `isTest` only |
| Anti-cheat switches | Client Lua check hard-disabled; g1019 not covered by g1008-only check; empty So whitelists mean allow-all | Disabled/gap |
| Plugin loader | Only `pay_activity` enabled; `data_report`/`new_vip` force-added; `red_dot` loaded by pay_activity; all other plugin folders dead | Dormant |
| Paid events | `pay_activity` enabled but all shipped events expired in 2023 | Stale |
| Normal map | `scene2.yml`/`scene3.yml` shipped but never loaded | Dead content |
| Normal config | Monster 1022 unused; 1,475 unused `monster_num` rows (one non-zero) | Unused |
| Hard mode | `m1019_10` live but no distinct UI/localization; `m1019_2` staged | Hidden/staging |
| Thresholds | Normal levels 1/21/25 silently clamped 40/75/69 → 15/61/61 | Bug |
| Ranking | v10113 weekly key expires daily; level “daily” key has no date suffix | Bug |
| Combat validation | Attack packet has no range/cooldown/weapon validation | Risk |
| Data mapping | Hard weapon model/item IDs shifted one level from L14 | Bug-like |
| Final boss | Hard10 L60 boss 600k HP / 99,999 atk; hard2 rebalances to 360k / 100k / faster | Suspicious balance |

## 2. GM / debug / test surface

### 2.1 Server GM commands (`engine_server\helper\GMHelper.lua`)

- GM identity: `isGMOpen()` returns true for every user when `isTest`; otherwise only IDs in `GmIds` (`GMHelper.lua:19-24`).
- Password gate: `checkPsd` loads an obfuscated/rotated base64 Lua chunk (`GMHelper.lua:9-31`; credential check at line 28). **Credential not reproduced.**
- Production GMCommand handler: if `not isTest and not isStaging`, the sender is immediately sent gameover with `[verify] cheat detected [gm][2]` before the GM check (`GMHelper.lua:34-51`). This is both an anti-GM-spoof guard and a self-kick / packet-DoS vector.
- Commands verified in code (`GMHelper.lua`):
  - movement/teleport: `setAllowFlying` (172), `changeRunSpeed` (182), `findLifePlayer` (202), `teleport` (415);
  - match manipulation: `tryStartGame` (192), `addGameTime` (231);
  - inventory/economy: `addItem`/`addInputItem` (209–229), `clearInventory` (275), `resetSumRecharge` (260), `addTimeoutOrder` (468);
  - destructive: `clearDBAndLogout` (243), `closeServer` (256), `moniRoomKickOut` (431);
  - debug/cheat toggles: `openCommonPacketDebug` (248), `openConnectorLog` (279), `addSpeedCheat` (398), `blockDestoryDisUnlimit` (390), `attackDisUnlimit` (394);
  - AI/test: `addAIPlayer`/`addAIPlayer10` (523–529), `watchAIBtTree` (531), `useLowClient` (372), `useFakeApp` (379);
  - logs/secrets: `copyServerLog` (437) redacts lines containing `secret` before sending to client (lines 452–456).
- `GMHelper:onPlayerReady` opens the GM panel only for `AdminIds` (`GMHelper.lua:102-114`); logout removes non-admin temporary GM grants (`:116-126`).

### 2.2 Client GM panel (`engine_client\helper\GMHelper.lua`)

- Full command list at lines 49–153 and 204–250: AI, flight, run speed, force start, find live player, teleport, clear DB/logout, reset first recharge, clear inventory, query prefs, generate timeout order, debug logs, hot update, screen record, close server, global GM grants, performance/render toggles.
- Dangerous tab includes `closeServer`, `GMæƒé™(å…¨å±€)`, `GMæƒé™(æœ€è¿‘)`, render API disabling and shader updates (`:115-153`).
- `GMHelper:enableGM()` clears all settings when `not isTest and not isStaging` (`:254-273`); production clients therefore get an empty GM panel.
- The client sends any command name/params via `PacketSender:sendLuaCommonData("GMCommand", ...)` (`:291-299`), which is exactly what the server auto-kicks in production.
- Commented-out “æžªç«é…ç½®” GM tabs remain at lines 154–202 and platform-decoration code at 225–238; they are unreachable.

### 2.3 Debug port / arbitrary Lua

- `engine_base\Base.lua:93-94` calls `debugport.Init(..., 6600, 6666)` at startup. `DebugPort.Init` returns immediately unless `isTest` (`DebugPort.lua:274-277`).
- When enabled it listens on `127.0.0.1` (not external) but has **no authentication** (`DebugPort.lua:282-299,320-363`).
- `DebugCmd:d` executes arbitrary Lua (`DebugCmd.lua:157-185`); `DebugCmd:f` loads an arbitrary file (`:187-193`); `l` lists/reads the filesystem (`:352-427`); `q` disconnects (`:429-439`).
- Server-only commands: `gm <userId>` grants GM, `a <userId>` attaches debug output to a player, `ko <userId>` kicks (`DebugCmdServer.lua:15-42`).
- DebugPort sends `misc.sys_info()` including port, directory, game type, engine version and client user ID via UDP to `REPORT_SERVER = "47.243.80.43"`, port `10086` (`DebugPort.lua:17,300-317`). **Location only.**
- `GMHelper:telnetServer`/`telnetClient` open Windows `telnet.exe 127.0.0.1 <port>` (`server GMHelper.lua:363-370`; client `:555-562`).

## 3. Disabled / unreachable branches

### 3.1 Anti-cheat disabled switches

- `AntiHackConfig:isOpenScriptCheck()` unconditionally returns `false` (`AntiHackConfig.lua:104-106`).
  - In VM mode, `check_client_lua` is only registered if that returns true (`dynamic_script_mgr.lua:103-105`).
  - In plaintext mode, the same guard applies (`dynamic_script_mgr.lua:113-115`).
  - `HandleClientLuaCheckResult` only reports/kicks when the same function is true (`HandleClientLuaCheckResult.lua:330-349`).
- `AntiHackConfig:isVMProtectionEnabled()` ignores config and returns `true` (`AntiHackConfig.lua:153-157`); the commented-out line is the original config check.
- `check_so_md5` registration is commented out in the VM path (`dynamic_script_mgr.lua:99`).
- `SoWhiteList` and `SoWhiteListInMem` default to empty lists; `checkSo`/`checkSoInMem` treat an empty list as **allow all** (`AntiHackConfig.lua:38-39,108-133`).
- `HandleClientLuaCheckResult:AddRequest` only runs for `gtype == "g1008"` and Android (`HandleClientLuaCheckResult.lua:223-241`). **g1019 is not covered.**
- `AntiHackConfig` default kick flags are mostly `false`; actual enforcement depends on remote `GetAntiConfig` (`AntiHackConfig.lua:12-44,89-97`).
- Certificate allowlist is hardcoded (`AntiHackConfig.lua:45-81`). It is a public whitelist, not a secret, but it is a static bypass surface.
- `KickUserWhiteList` exempts listed user IDs from several checks (`NewChecker.lua:32-45`; `HandleClientLuaCheckResult.lua:338-343`).

### 3.2 Empty / no-op handlers

- `GMHelper:noBloodLossCheat(player)` has an empty body (`GMHelper.lua:386-388`).
- `SceneConfig:randomScene()` can only return scene 1 because `GameConfig` loads one scene; its “avoid same scene 3 times” logic is therefore unreachable in g1019 (`SceneConfig.lua:19-49`, `GameConfig.lua:66-68`, `m1019_1\config.yml:3-5`).
- `MonsterConfig` stores `isEnterHint` but no g1019 Lua reads it (`MonsterConfig.lua:34`); enter-hint behavior would have to be engine-side.
- `Messages:upgradePlayerHint(name)` ignores `name` (`Messages.lua:19-21`).

## 4. Unused / unreachable content

### 4.1 Dead scenes

Every map zip contains `scene1.yml`, `scene2.yml`, `scene3.yml`, but every `config.yml` lists only `scene1.yml`:

- normal `m1019_1\config.yml:3-5`; hard10 `m1019_10\config.yml:3-5`; hard2 `m1019_2\config.yml:3-5`.
- `scene2.yml` has 23 monster spawns and 1 boss spawn; `scene3.yml` has 6 monster spawns and 2 boss spawns (counted from the YAML files).
- Only `scene1.yml` is ever created by `SceneConfig:addScene()` (`GameConfig.lua:66-68`, `SceneConfig.lua:14-17`).
- Consequence: 29 normal/hard spawn definitions and 3 boss spawn definitions are dead content.

### 4.2 Unused monster and wave rows

- Normal monster `1022` is defined (`m1019_1\monster.csv:6`) but never referenced by normal waves; hard10/hard2 do use it.
- Normal `monster_num.csv` has 2,000 rows, 1,475 unreferenced; all but one are `num=0` placeholders. The only non-zero unused row is `10011021` → monster 1021 ×25 (`m1019_1\monster_num.csv:5`).
- Hard10 `monster_num.csv` has 1,920 rows, 1,516 unreferenced; non-zero unused rows: `10382013` → 2013 ×1 (`m1019_10\monster_num.csv:1207`) and `10461033` → 1033 ×5 (`:1449`).
- Hard10/hard2 define all 32 monsters, all used; normal has one unused monster.
- Many zero-count rows are likely reserved future waves; they are still unreachable from the current `game_level` table.

### 4.3 Player progression table gap

- `player_level.csv` has 30 rows (levels 1–30). `PlayerLevelConfig:getUpgradeExpByLv()` falls back to `GameConfig.defaultUpgradeExp` (1000) for any missing level (`PlayerLevelConfig.lua:22-28`).
- `config.yml` sets `playerAttr.maxLv: 1000` (`m1019_10\config.yml:65`). Levels 31–1000 therefore all cost the flat 1000 exp; only the first 30 levels use the authored curve.

### 4.4 Expired event content

- `setting\pay_activity\PayActivity.json` main button is valid only 2022-11-24..2022-11-30 (`PayActivity.json:19-20`).
- `PayActivityList.csv` has one activity, `LimitedTimeGiftSignal`, valid 2022-10-15..2023-01-02 (`PayActivityList.csv:3`).
- `PayActivityMgr:onSecondTick` creates activities only inside their date window (`PayActivityMgr.lua:45-60`). In 2026 there are no active pay activities even though the plugin is loaded.
- The UI string “common.activity.end.tip” is shown when an activity is removed while its window is open (`PlayerPayActivity.lua:74-90`), confirming the stale-event path is expected/known.

## 5. Plugin loader: most shipped plugins are dead code in g1019

The package contains 459 Lua files, but g1019 enables very few plugins.

- `Global:loadGlobalSetting()` reads `setting.json` into `Global.setting` (`engine_base\Global.lua:12-21`).
- `Plugins.LoadAllPlugins()` loads only `Global.setting.plugins`, then force-adds `data_report` and `new_vip` (`engine_base\Plugins.lua:22-40`, especially 34-36).
- The shipped g1019 `setting\setting.json` is:
  ```json
  { "plugins": [ "pay_activity" ] }
  ```
  (`reports\agents\features\_work\plugins\v10113\setting\setting.json:1-5`).
- `pay_activity` loads `red_dot` on the client (`pay_activity\common\config\PayActivityConfig.lua:84`).
- No g1019 code under `lua\server` or `lua\client` calls `Plugins.LoadPlugin`; grep of v10113 source finds only `Plugins.LoadAllPlugins()` in the engine listeners and the `red_dot` load inside pay_activity.
- Therefore, unless the platform injects a different `plugins_setting.json` (none present in the supplied artifacts), these are **dormant dead code for g1019**:
  - `activity` (blind box/lottery), `trigger_gift`, `check_in`, `video`, `vf_app_activity`, `voice_pack`, `chat_bubble`, `db_lock`, `translation`, `CommonAdActivity` (inside pay_activity), and the associated UI.
- Live/forced plugins:
  - `data_report` = telemetry (`Plugins.lua:35`);
  - `new_vip` = cosmetic name banner/pendant (`Plugins.lua:36`);
  - `pay_activity` = loaded but expired;
  - `red_dot` = loaded through pay_activity.

This is the single largest hidden-content finding: the repository contains event/UI features that the g1019 build never activates.

## 6. Hidden maps / modes

### 6.1 m1019_10

- Manifest: first live at key `10110` (`manifest\game-resource-config.json`), map hash `96aad549865807944d45cbb1212d5ebf`, unchanged through `10113`.
- It is not referenced anywhere in game Lua; map selection is external/platform-side. No g1019 string or UI distinguishes “hard mode”.
- Scene name is `20059`, identical to normal (`m1019_10\scene1.yml:5`); `Messages:selectMapHint` uses that scene name (`server\messages\Messages.lua:15-17`).
- Terrain differs from normal (all four `.mca` hashes differ); scene2 differs only by adding yaw 50 to initPos; scene3 is byte-identical; both are still unused.

### 6.2 m1019_2

- Only in `mapsStaging` at manifest key `10113`; not in live `maps[]`.
- Shares m1019_10 terrain and scene files exactly, but rebalances config/CSVs (basement 3.7M at L60, final boss 360k/100k/faster, higher late rewards).
- No mode label or UI string exists; if shipped, it would be indistinguishable from m1019_10 in game data.
- Staging plugin decrypt shows no m1019_2-specific code; the variant is data-only.

### 6.3 Hard-mode weapon mapping

- Normal L14 = item 703 (`m1019_1\arms.csv:16`), normal L28 = item 713 (`:30`).
- Hard L14 = item 704 (`m1019_10\arms.csv:16`), hard L28 = item 703 (`:30`). The hard ladder is shifted one row from L14; stats remain level-based.
- This is present in both hard10 and m1019_2 and looks like a data/off-by-one defect rather than an intentional “different weapon”.

## 7. Threshold and ranking defects

### 7.1 Normal-mode kill-threshold clamp

`GameLevelConfig:getMonstersByLevel()` sums the wave counts and overwrites the CSV threshold if the sum is smaller (`GameLevelConfig.lua:55-64`). Affected normal rows:

| Level | CSV kills | Wave sum | Effective | Evidence |
|---:|---:|---:|---:|---|
| 1 | 40 | 15 | 15 | `m1019_1\game_level.csv:3` |
| 21 | 75 | 61 | 61 | `:23` |
| 25 | 69 | 61 | 61 | `:27` |

Total configured 8,159 becomes 8,112 effective. This is independent of player skill/UI and is not documented in config. Hard10/hard2 have no mismatches.

### 7.2 Weekly rank expiry regression

- v10103: weekly key uses `DateUtil.getWeekLastTime()`, day key uses `getDayLastTime()` (`norm2\v10103\lua\server\data\GameRankNpc.lua:29-35`).
- v10113: **both** weekly and daily keys use `getGreenwichDayLastTime()` (`server\data\GameRankNpc.lua:29-35`). Weekly ranks expire daily.
- Level NPC day key is `g1019.level` with no date suffix, and `setZExpireat` returns before setting its expiry (`GameRankNpc.lua:31-34,121-127`), so the level “daily” board is all-time.

### 7.3 UI threshold hint

`Scene:onMonsterDie()` and `GameMatch:upgradeGameLevel()` both send `10 - level % 10` to `HostApi.updateMonsterInfo` (`Scene.lua:86`, `Match.lua:233`). This is a countdown-style UI value (likely “next boss in N levels”), not a difficulty or reward threshold; no Lua code uses it for gameplay.

## 8. Suspicious mechanics / server-side validation gaps

- **Attack validation**: `PlayerListener.onPlayerAttackCreature(rakssid, entityId, attackType)` only rejects `attackType == 0`, resolves the player and monster, then applies damage (`PlayerListener.lua:83-98`). It does not verify distance, line of sight, weapon cooldown, ammo, or that the client is allowed to attack that entity. `GameMonster:onAttacked` trusts `player.attack/attackX` (`GameMonster.lua:77-104`). A modified client that can emit `PlayerAttackCreatureEvent` can hit any live monster entity ID.
- **Config fallbacks hide bad IDs**: `MonsterNumConfig:getMonsterNumById` and `BasementConfig:getBasementById` return an arbitrary first row when the requested ID is missing (`MonsterNumConfig.lua:23-31`, `BasementConfig.lua:45-53`). A typo in `game_level.csv` would silently spawn the wrong monster or use the wrong basement instead of failing.
- **Damage attribution / killer bonus**: `GameMonster:onDie` divides by `totalDamage`; every attacker has positive damage by construction, but the code assumes at least one attacker. `onAttacked` creates the attacker entry only after damage>0, so a zero-damage configuration would skip rewards entirely instead of erroring (`GameMonster.lua:77-104,137-157`).
- **Hard mode economy spikes**: L17/L19/L37/L39 give 9k–18k gold for 150–180 kills, and L57–59 give 240 kills for 5k gold/1k exp in hard10; m1019_2 raises late rewards to 18k gold/2k exp. These are visible in `game_level.csv` but have no UI explanation. They are plausible “bonus levels”, but they are also the most efficient farm spots.
- **Final boss spike**: hard10 L60 boss 3031 has 600,000 HP and 99,999 attack with 60,000 gold; m1019_2 changes it to 360,000 HP / 100,000 attack / attackSpeed 6 / attackCd 6 / 90,000 gold. The order-of-magnitude gap between normal bosses (16k–30k HP) and 3031 is deliberate but extreme.
- **Rank score farming**: `GameRankNpc:savePlayerRankScore` increments Redis week/day scores every 30 ticks from `player.gameScore` (`Match.lua:81-89`), and `gameScore` is increased by every `addMoney` (kill gold), not only wins. Rank is therefore farmable by repeated normal runs; no anti-cheat correlation is applied.
- **Hard-mode basement vs boss**: hard10 L60 basement is only 138,750 HP while the boss is 600k/99,999; m1019_2 flips this to 3.7M basement and a faster 360k boss. The two variants encode very different failure modes; neither is documented in UI.

## 9. Anti-cheat coverage summary

| Check | Default | g1019 coverage | Evidence |
|---|---|---|---|
| APK/cert check | `NewChecker` | yes (all games) | `NewChecker.lua:42-61` |
| So whitelist | empty = allow all | no effective restriction | `AntiHackConfig.lua:108-133` |
| Client Lua check | `isOpenScriptCheck=false` | disabled | `AntiHackConfig.lua:104-106` |
| g1008-only client Lua result | only g1008 Android | **g1019 not covered** | `HandleClientLuaCheckResult.lua:223-241` |
| VM protection | always true | enabled | `AntiHackConfig.lua:153-157` |
| Packet error kick | after 3 errors | yes | `PacketChecker.lua:11-18` |
| GMCommand spoof | production auto-kick | yes | `GMHelper.lua:34-51` |

## 10. Staging / preview content

- **v10095 plugin-staging** contains 21 files absent from v10095 production; all 21 appear in v10096 production, including LimitedTimeWeekGift, LimitedTimeMonthGift, LimitedTimeDraw, GUILimitTimeWeek*, GUILimitTimeMonth*, and TriggerGiftActivityMgr/Obj. This is a verified preview of the v10096 pay_activity/trigger_gift release.
- **v10113 plugin-staging** decrypts to 459/459 Lua files, semantically identical to production except:
  - `engine_base\util\FileUtil.lua`: switches CSV loading from `all_configs.lbc` to `lua/base/all_csv_configs.lua`;
  - `engine_client\ui\UIAnimation.lua`: adds `UIAnimation:rotate`;
  - `engine_server\antihack\AntiHackConfig.lua`: adds `kickOutExecuteServerScriptError`, `kickOut102And26`, Yidun token flags;
  - `engine_server\antihack\HackReport.lua`: adds Yidun action types 33/34 and 102+26 kick logic;
  - `engine_server\antihack\dynamic_script\check_fake_app.lua`: changes the inner-cert flag name and official-cert logic.
  None of these are m1019_2-specific.

## 11. Secrets / sensitive locations (locations only)

- Obfuscated GM password check: `engine_server\helper\GMHelper.lua:9-31` (payload at line 28). Not decoded/reproduced.
- DebugPort telemetry target: `engine_base\debug\DebugPort.lua:17` (`REPORT_SERVER = "47.243.80.43"`), send at `:316`.
- Hardcoded certificate SHA1 allowlist: `engine_server\antihack\AntiHackConfig.lua:45-81`.
- Server-log “secret” redaction: `engine_server\helper\GMHelper.lua:452-456` (shows the code expects secrets in logs; no secret value present).
- Debug history path is writable client storage: `engine_base\Base.lua:93-94` / `DebugPort.lua:280`.

## 12. Verification notes

- Normal/hard CSV counts, monster sets, boss rows, weapon rows, basement curves and scene counts were parsed from the raw files with `_scripts\parse_maps.py` and `_scripts\compare_modes.py`; the generated comparison is `_work\compare_modes_out.txt` and `_work\maps_parsed.json`.
- Threshold clamp was verified by summing each level's `monster_num.num`; results are in `_scripts\thresholds.py`. The hard-mode agent's `map_characteristics.json` independently reports normal `total_kills=8159`, `total_spawn=8112`, `total_effective_kills=8112`.
- Plugin enablement was verified from `setting.json`, `Global.lua:12-21`, `Plugins.lua:22-40`, and a grep for `LoadPlugin`/`CallPluginFunc` across v10113 `lua\server` and `lua\client` (no game-side `LoadPlugin`).
- Unreadable revisions: v10104–v10108 wrapped Lua, v10109–v10112 legacy packed Lua. See `FEATURE_TIMELINE.md` §7 and `SOURCE_COVERAGE.md`.


