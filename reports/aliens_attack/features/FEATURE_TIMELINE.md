# Blockman GO g1019 (Aliens Attack) — Feature Timeline

Scope: resource revisions `v10068`–`v10113` under `games\g1019`, the v10113 decrypted Lua tree under `decrypted\v10113\source`, all map/config zips, and the manifest at `manifest\game-resource-config.json`.

Method: every feature below is traced to code/config, not to a filename. Paths are relative to `aliens_attack\`. CSV line numbers are physical lines in the shipped/extracted file (many v10109+ CSVs have a garbled first line followed by the real ASCII header on line 2).

## 1. Executive summary

- The **normal mode is content-frozen**: `m1019_1` has 100 levels, 20 monster types, 2 bosses, 30 weapons, 4 equipment slots and 100 basements from v10068 through v10113. Terrain `.mca` hashes are identical in every version. Only arms CSV formatting (v10079) and the Chinese skill header (v10109) changed; no numeric balance change.
- The only **new game mode/content** in this range is hard mode map `m1019_10`, first live in **v10110**: 60 levels, 32 monsters (12 new IDs), 3 bosses (new 3031), 60 basements, 30 weapon levels with a different item/model mapping, and a different terrain.
- A second variant of the same 60-level hard-mode content, **`m1019_2`**, exists only as `mapsStaging` in **v10113**. It shares `m1019_10` terrain and spawn layout but rebalances basement HP, boss stats and rewards.
- Most plugin folders shipped with g1019 are **not enabled by the game's own settings**: `setting/setting.json` lists only `pay_activity`; the loader force-adds `data_report` and `new_vip`. `pay_activity` then loads `red_dot`. No g1019 server/client code calls `Plugins.LoadPlugin` for activity, trigger_gift, check_in, video, voice_pack, vf_app_activity, chat_bubble, db_lock, translation or CommonAdActivity.
- The `pay_activity` events that are enabled are **expired** (2022-10-15..2023-01-02 and 2022-11-24..2022-11-30), so the live v10113 build exposes almost no event content.
- Two threshold defects are material: (a) `GameLevelConfig:getMonstersByLevel` silently lowers normal levels 1/21/25 from 40/75/69 kills to 15/61/61; (b) v10113 expires the weekly rank key with a *daily* timestamp.

## 2. Version-by-version timeline

Readability legend: **T** = plaintext Lua readable; **W** = wrapped/cipher Lua (unreadable); **P** = packed `res.pack` (Lua unreadable, TOC names available); **D** = decrypted v10113 source. `fileCount` is from each `version.json`.

| Version | fileCount | Readability | Normal map | Hard/staging | Verified changes |
|---|---:|---|---|---|---|
| v10068 | 117 | T | m1019_1 (17 entries) | — | Baseline game: 100 levels, 20 monsters, 2 bosses, 30 weapons, 4 equipment slots, 100 basements, 2 shop tabs, respawn, score/level rank NPCs. |
| v10069 | 131 | T | m1019_1 | — | Engine-side CommonActivity/BlindBox/LuckyLottery/MustLottery tables; `ScriptMain.lua` drops the old `package.path` hack. No game rule change. |
| v10070 | 131 | T | m1019_1 | — | No game-content additions/removals. |
| v10071 | 131 | T | m1019_1 | — | No game-content additions/removals. |
| v10072 | 132 | T | m1019_1 | — | `ConfigLoader.lua` added; server Lua re-encoded CRLF→LF; only 3 engine files change semantically. |
| v10073 | 228 | T | m1019_1 | — | Engine tree split into `lua/engine_base`, `engine_client`, `engine_server`; first game client plugin (`lua/client/PluginMain.lua`, `lua/client/listener/GameListener.lua`). |
| v10074 | 228 | T | m1019_1 | — | No functional change vs v10073. |
| v10075 | 275 | T | m1019_1 | — | `red_dot` plugin; connector/UI engine layer; `DBDataListener` migrates to `Events.GetDataFromDBEvent`; large line-ending rewrite. |
| v10076 | 274 | T | m1019_1 | — | Event API migration to `CEvents.*` in 6 server listeners; no new gameplay. |
| v10077 | 274 | T | m1019_1 | — | No game-content additions/removals. |
| v10079 | 308 | T | m1019_1 (17 entries) | — | `activity` plugin (blind box / lucky lottery / must-lottery), `trigger_gift` plugin; `CurrencyId`/`ExchangeItemReason` defines. Map CSV only formatting/note-column change; numeric data identical. |
| v10080 | 308 | T | m1019_1 | — | `trigger_gift` use-item trigger (`recordPlayerUseItem`, `onWinCheckUseItemTriggerGift`). |
| v10082 | 324 | T | m1019_1 | — | `check_in` plugin; debug/GM and manager files moved into engine tree. |
| v10083 | 291 | T | m1019_1 | — | No game-content additions/removals. |
| v10084 | 293 | T | m1019_1 | — | No game-content additions/removals. |
| v10085 | 293 | T | m1019_1 | — | No game-content additions/removals. |
| v10086 | 297 | T | m1019_1 | — | Anti-cheat: `APKChecker`, `GameDynamicConfig`, client/server `PreventCheatService`. |
| v10087 | 311 | T | m1019_1 | — | `data_report` telemetry plugin; `AntiHacker`, `HackReport`, `Version10086Checker`; `GameRankNpc` callback signature fix. |
| v10088 | 311 | T | m1019_1 | — | No new feature; plugin file updates only. |
| v10090 | 320 | T | m1019_1 | — | `video` ad-reward plugin; `dynamic_script_mgr` + `check_so`; `GamePlayer` name-list API change. |
| v10091 | 341 | T | m1019_1 | — | `vf_app_activity` app-badge plugin; `voice_pack` plugin; engine vfs/zip utilities; `GamePlayer` name API. |
| v10093 | 408 | T | m1019_1 | — | `pay_activity` limited-time paid-activity framework; `trigger_gift` v2; PlayerListener common-reward callbacks; `setting/setting.json` starts listing only `pay_activity`. |
| v10095 | 358 | T | m1019_1 | — | Common-reward callbacks removed; plugin-staging previews 21 pay_activity/trigger_gift files that ship in v10096. No new live game content. |
| v10096 | 419 | T | m1019_1 | — | Common-reward callbacks restored; `chat_bubble`; `new_vip` cosmetic banner/pendant; math/UI engine additions. |
| v10097 | 419 | T | m1019_1 | — | No game-content additions/removals. |
| v10098 | 419 | T | m1019_1 | — | No new live feature; plugin-staging contains engine-only fixes. |
| v10099 | 419 | T | m1019_1 | — | No new live feature; plugin-staging contains engine-only fixes. |
| v10100 | 422 | T | m1019_1 | — | `db_lock` server DB-lock plugin. |
| v10101 | 425 | T | m1019_1 | — | `AntiHackConfig`, `GMChecker`, `PacketChecker`; small plugin updates. |
| v10102 | 428 | T | m1019_1 | — | `Md5Util` added. |
| v10103 | 431 | T | m1019_1 | — | `GMCheckerCode`, `ReadyChecker`, `ReadyCheckerCode`, `SandboxolChecker`. Last plaintext plugin. |
| v10104 | 428 | W | m1019_1 | — | Lua wrapped; `ClientFileChecker` added; `GMChecker`/`ReadyChecker` removed. |
| v10105 | 430 | W | m1019_1 | — | `check_gg_in_mem`, `check_so_in_mem`; all Lua wrapped. |
| v10106 | 430 | W | m1019_1 | — | No additions/removals. |
| v10107 | 441 | W | m1019_1 | — | `HandleClientLuaCheckResult`, `check_client_lua`, `check_fake_app`, `check_virtual_app`; CommonAdActivity files added. |
| v10108 | 441 | W | m1019_1 | — | No additions/removals. |
| v10109 | 5 | P | m1019_1 res.pack (10 entries) | — | Plugin switches to `res.pack`; map switches to `res.pack`; TOC/config names same. `skill.csv` Chinese header corrupted, values identical. Plugin Lua unresolved (legacy keyfile). |
| v10110 | 5 | P | m1019_1 res.pack | **m1019_10 live** | **Hard mode first appears** (60 levels, 32 monsters, 3 bosses, 60 basements, different terrain). Adds `translation`, AI players (`AIPlayer`, `AIPlayerManager`, `AIAttributeConfig`), `GUIFakeAdvertPanel`. |
| v10111 | 5 | P | m1019_1 res.pack | m1019_10 | `NewChecker`, server `Lang` util. |
| v10112 | 5 | P | m1019_1 res.pack | m1019_10 | `check_base`, `check_illegal_lua_files`. |
| v10113 | 5 | D | m1019_1 res.pack | m1019_10 live; **m1019_2 mapsStaging** | VM anti-cheat suite (`LuaVM`, `RealLuaToVMConverter`, `VMObfuscator`, `VMCompileCache`, `AutoVMWrapper`, `code_encoder`, `quick_fix`, `init_vm`, `check_lua_hook`, `check_so_md5`); `GameRankNpc` weekly-expiry regression; no game-rule changes. |

Missing revisions in the supplied manifest: `10078`, `10081`, `10089`, `10092`, `10094`.

## 3. Content timeline

### 3.1 Normal mode m1019_1

- First present v10068, live through v10113. Map zip contains 17 entries in v10068–v10108 (`config.yml`, `scene1..3.yml`, 8 CSV tables, 4 `.mca` region files, checksums) and 10 entries from v10109 (CSV tables moved into `res.pack`).
- All four `.mca` terrain hashes are identical in v10068/v10079/v10108/v10113:
  - `r.3.-1.mca` = `7fa61a875634...`, `r.3.-2.mca` = `75f52cca93a2...`, `r.4.-1.mca` = `65cc38efb456...`, `r.4.-2.mca` = `1bee2cc25a55...`.
- CSV numeric data is identical v10068→v10113:
  - 100 `game_level` rows, 100 basements, 30 player-level exp rows, 30 arms, 324 equipment rows, 20 monsters, 2,000 `monster_num` rows.
  - v10068→v10079 only `arms.csv` trailing note columns/order changed; numeric fields are equal.
  - v10109 changed only the Chinese header bytes of `skill.csv`; skill rows are unchanged.
- `config.yml` loads only `scene1.yml` (`config.yml:3-5`). `scene2.yml` (23 monster spawns) and `scene3.yml` (6 spawns) are shipped but unreachable. `SceneConfig:randomScene()` can only ever choose scene 1 (`SceneConfig.lua:19-49`).

### 3.2 Hard mode m1019_10

- First manifest appearance: `manifest\game-resource-config.json` key `10110`, `maps[]` entry `m1019_10`; map durl/hash stays constant through `10113` (`96aad549865807944d45cbb1212d5ebf`).
- Map zip: 17 entries, plaintext CSV/yml throughout v10110–v10113. Config hash `e4bc18849ecf...`, `game_level.csv` `85a46ecc952a...`, `monster.csv` `708705828b40...`, `monster_num.csv` `3ce1be2ed256...`, `basement.csv` `6d055ed16c01...`.
- Terrain differs from m1019_1: `r.3.-1.mca` `0852dba43b3a...`, `r.3.-2.mca` `ee8861ae23ee...`, `r.4.-1.mca` `7f5871c9349b...`, `r.4.-2.mca` `ac1a9e8800b8...`.
- `config.yml:3-5` also loads only `scene1.yml`; `scene2.yml` and `scene3.yml` are dead.
- `scene1.yml` has 30 monster spawns (normal 24); boss point moves from `[1725, 37, -469, 50]` (normal `scene1.yml:56-58`) to `[1764, 37, -420, 50]` (hard `scene1.yml:68-70`). `scene2.yml` differs only by adding yaw `50` to `initPos` (`7c2f67820dfa...` vs normal `1f74ac77257a...`); `scene3.yml` is byte-identical (`63b9e45e0f50...`). Both are unused.

Key config deltas normal → hard10 (`m1019_10\config.yml`):

| Key | Normal (v10108) | Hard10 (v10113) | Evidence |
|---|---:|---:|---|
| waitingTime | 60 | 30 | `m1019_10\config.yml:8` |
| prepareTime | 60 | 30 | `:11` |
| gamePrepareTime | 10 | 8 | `:17` |
| gameLevelTime | 190 | 310 | `:20` |
| gameOverTime | 10 | 10 | `:23` |
| refreshMonsterTime | 6 | 5 | `:26` |
| refreshMonsterTimes | 10 | 15 | `:29` |
| maxMonsters | 30 | 33 | `:35` |
| PlayerUpgradeHealthReply | 0.10 | 0.15 | `:53` |
| BasementUpgradeHealthReply | 0.20 | 0.33 | `:56` |
| playerAttr hp/attack/defense/addHp | 1500/300/300/0 | 1500/450/330/10 | `:60-64` |
| respawn time/price | 180 / [1,4,80] | 310 / [1,1,80] | `:124-130` (normal) / hard tail |

### 3.3 Hard mode monsters and bosses

Hard10 has 32 monsters. Twelve IDs are absent from normal (`m1019_10\monster.csv`):

| ID | Line | Name key | Actor | HP | Attack | Role |
|---|---:|---|---|---:|---:|---|
| 1033 | 9 | creepyalients_mon_name05 | greens.actor | 3,000 | 150 | tough variant |
| 1043 | 12 | creepyalients_mon_name10 | insectosaurus.actor | 50 | 1,000 | glass cannon |
| 1053 | 15 | creepyalients_mon_name13 | bobo.actor | 3,000 | 200 | tough variant |
| 1063 | 18 | creepyalients_mon_name16 | demon.actor | 3,500 | 1,500 | demon |
| 1064 | 19 | creepyalients_mon_name17 | demon.actor | 2,700 | 1,200 | demon |
| 1065 | 20 | creepyalients_mon_name18 | demon.actor | 800 | 1,000 | demon |
| 2013 | 23 | creepyalients_mon_name21 | unknown_rabbits.actor | 2,700 | 640 | ranged |
| 2023 | 26 | creepyalients_mon_name24 | bat.actor | 1,350 | 100 | ranged |
| 2033 | 29 | creepyalients_mon_name27 | angel.actor | 10,000 | 450 | tank |
| 2034 | 30 | creepyalients_mon_name28 | angel.actor | 6,000 | 100 | support-ish |
| 2035 | 31 | creepyalients_mon_name29 | angel.actor | 1,500 | 240 | fast support |
| 3031 | 34 | creepyalients_mon_name32 | doctor_octopus.actor | 600,000 | 99,999 | **new boss** |

- New boss 3031: `isBoss=1`, boss AI `BossAlien`, `skillId=3`, `skillCd=60`, `exp=5000`, `gold=60000` (`m1019_10\monster.csv:34`).
- Boss 3011 is buffed normal→hard: 30,000→45,000 HP, 600→800 atk, skill CD 8→10 (`monster.csv:21` vs `:32`).
- Boss 3021 buffed 16,000→27,000 HP, skill CD 8→5 (`:22` vs `:33`).
- Hard monsters use additional effects: `2#2#2`, `2#3#4`, `2#6#9`, `2#4#9` (PotionID 2 = movement slowdown; see `engine_base\define\PotionID.lua:6`).

### 3.4 Hard mode levels, thresholds and rewards

`m1019_10\game_level.csv` has 60 rows and 7,986 total kills. `GameLevelConfig.lua:62-64` does not clamp any hard row (all kill thresholds equal the sum of their wave counts).

- Boss levels: 10, 20, 30, 40, 50, 60.
- Special high-reward levels (single elite / small wave):
  - L17: 150 kills, 9,000 gold / 600 exp, wave `10171043#10172035` (`game_level.csv:19`).
  - L19: 180 kills, 12,000 gold / 800 exp, `10191043#10192035` (`:21`).
  - L37: 150 kills, 15,000 gold / 1,200 exp, 4 wave IDs (`:39`).
  - L39: 180 kills, 18,000 gold / 1,600 exp, 4 wave IDs (`:41`).
  - L57–59: 240 kills each, 5,000 gold / 1,000 exp in hard10 (`:59-61`).
- L60: 258 kills, 60,000 gold / 6,000 exp, wave `10603031#10601065#10603011#10603021` (`:62`).

Normal comparison: 100 levels / 8,159 configured kills / 2 bosses; L60 is a normal single-boss level (1 kill, 8,000 gold/1,600 exp).

### 3.5 m1019_2 staging variant

`m1019_2` is present only under `mapsStaging` in `manifest\game-resource-config.json` key `10113`; it is not in live `maps[]`. It is a 60-level, 32-monster variant that shares m1019_10 terrain and scene files (all four `.mca` and `scene1/2/3.yml` hashes identical) but changes balance:

| Field | hard10 | hard2 | Evidence |
|---|---:|---:|---|
| gameOverTime | 10 | 8 | `m1019_2\config.yml:23` |
| maxMonsters | 33 | 30 | `:35` |
| PlayerUpgradeHealthReply | 0.15 | 0.20 | `:53` |
| BasementUpgradeHealthReply | 0.33 | 0.35 | `:56` |
| L60 basement HP | 138,750 | 3,700,000 | `basement.csv:62` |
| Boss 3031 HP/atk/attackSpeed/attackCd | 600,000 / 99,999 / 1 / 1 | 360,000 / 100,000 / 6 / 6 | `monster.csv:34` |
| Boss 3031 exp/gold/skillCd | 5,000 / 60,000 / 60 | 9,000 / 90,000 / 45 | `monster.csv:34` |
| L17/L19/L37/L39/L57-59 gold/exp | 9k/600, 12k/800, 15k/1.2k, 18k/1.6k, 5k/1k | 9k/900, 12k/1.2k, 15k/3k, 18k/4.5k, 18k/2k | `game_level.csv:19,21,39,41,59-61` |
| L30 weapon maxBullet | 150 | 180 | `arms.csv:32` |

The staging plugin (`pluginStaging` in manifest key `10113`, hash `b7e27763...`) has no m1019_2-specific code: after decrypting it, all 459 Lua files are semantically identical to production except five engine files (CSV loader, UI rotate, anti-cheat flags/reporting). The m1019_2 difference is entirely map/config data.

## 4. Feature chronology by category

### Weapons
- Normal 30-level ladder exists at v10068. Levels 1–30 use item IDs 426,436,435,437,438,439,440,428,427,429,700,701,702,703,704,705,431,430,706,707,708,709,710,711,712,432,434,713,714,433 (`m1019_1\arms.csv:3-32`).
- Hard10 adds a **distinct 30-level ladder** at v10110. From L14 onward the item/model sequence is shifted: hard L14 is item 704 (normal L15), hard L15 is 705 (normal L16), … hard L28 is 703 (normal L14), hard L29/30 match normal. Stats remain level-based. See `m1019_10\arms.csv:16-30` vs `m1019_1\arms.csv:16-30`.
- m1019_2 keeps the hard ladder and tweaks 12 rows (attackX, `maxBullet`, `bulletPerShoot`, `bulletOffset`); see `m1019_2\arms.csv:3-32`.
- No normal-mode weapon was added after v10068.

### Equipment
- 4 slots at v10068: helmet/plate/legs levels 0–100, boots 0–20; 324 rows. The file is byte-identical in normal, hard10 and hard2 (`equipment.csv` MD5 `226e32715bac...`). No equipment additions.

### Monsters and bosses
- Normal: 20 monsters / 2 bosses at v10068; no additions.
- Hard10: 32 monsters / 3 bosses at v10110 (12 new monster IDs, new boss 3031).
- m1019_2: same 32/3 roster, but stat rebalance (e.g. 1065 attack 1,000→25,000; 2034 addHp 12,000→24,000; 3031 HP 600k→360k but attackSpeed 1→6).

### Levels / maps / modes
- Normal 100 levels / 100 basements / m1019_1 at v10068.
- Hard10 60 levels / 60 basements / m1019_10 at v10110.
- m1019_2 60 levels / 60 basements, staging only at v10113.
- `scene2.yml`/`scene3.yml` exist in every map but are unreachable because `config.yml` lists only `scene1.yml`.
- Normal terrain never changes. Hard10 and hard2 share a second terrain.

### UI / client
- v10073: first client plugin; hides sneak/move-state, shows spectator respawn, disables sprint/collision/gun-action/gun-normal-attack/get-goods background (`v10073\lua\client\PluginMain.lua:9-19`, `...\GameListener.lua:25-34`).
- v10075: red-dot notification plumbing (only loaded via pay_activity after v10093).
- v10082: GM/debug UI files relocated; GM panel remains test-only.
- v10090/v10091: video and voice UI code present but dormant.
- v10110: translation UI, fake-advert panel, AI player UI/GM hooks.
- v10113: no new g1019 UI.

### Shop / events / monetization
- v10068: two shop tabs (diamonds, stat boosts), paid respawn.
- v10093: pay_activity framework and `setting.json` enabling only that plugin; event data in v10113 is expired.
- v10079/v10080/v10082/v10087/v10090/v10091/v10096/v10100/v10107: activity, trigger_gift, check_in, data_report, video, vf_app_activity, voice_pack, chat_bubble, new_vip, db_lock, CommonAdActivity code shipped but **not enabled for g1019** except forced data_report/new_vip and pay_activity/red_dot.
- No new items were added to the in-game shop after v10068; shop goods are in `config.yml`, not the plugin folders.

### Anti-cheat
- v10086: APKChecker/GameDynamicConfig/PreventCheat.
- v10087: AntiHacker/HackReport/Version10086Checker.
- v10090: dynamic_script + check_so.
- v10101: AntiHackConfig/GMChecker/PacketChecker.
- v10102: Md5Util.
- v10103: GMCheckerCode/ReadyChecker/SandboxolChecker.
- v10104: ClientFileChecker.
- v10105: in-memory checks.
- v10107: HandleClientLuaCheckResult + client Lua/fake app/virtual app checks.
- v10111: NewChecker.
- v10112: check_base/illegal Lua files.
- v10113: VM anti-cheat suite.
- Disabled/gaps: `AntiHackConfig:isOpenScriptCheck()` hard-returns false (`AntiHackConfig.lua:104-106`), so `check_client_lua` is never registered (`dynamic_script_mgr.lua:103-105,113-115`); `HandleClientLuaCheckResult` only starts for `g1008` Android (`HandleClientLuaCheckResult.lua:223-241`); `SoWhiteList`/`SoWhiteListInMem` are empty and empty means allow-all (`AntiHackConfig.lua:108-133`).

### Engine
- v10073 tree split into base/client/server.
- v10075 connector/UI primitives.
- v10082 debug/GM + managers.
- v10086 prevent-cheat services.
- v10090 dynamic script + recorder.
- v10091 vfs/zip.
- v10100 DB lock.
- v10110 AI player framework + fake ad panel.
- v10113 Lua VM anti-cheat.

## 5. Hard mode / threshold deep dive

### 5.1 How a level advances

1. `GameMatch:ifCanUpgradeGameLevel()` compares `scene:getKills()` with `GameLevelConfig:getKillsByLevel(self.level)` (`Match.lua:384-390`). `self.level` starts at 0; the first running level is level 1 after `upgradeGameLevel()` increments it (`Match.lua:208-235`).
2. `upgradeGameLevel()` clears monsters, increments level, fetches the new row, calls `getMonstersByLevel()`, updates basement, then `updateMonsterInfo(level, levelMonsterNum, 10 - level % 10)` (`Match.lua:219-233`).
3. `getMonstersByLevel()` sums `monster_num.num` for every wave ID. If that sum is **less than** the CSV `kills`, it **overwrites the CSV threshold** with the sum (`GameLevelConfig.lua:55-64`).
4. `Scene:onMonsterDie()` increments kills and refreshes UI with `10 - level % 10` (`Scene.lua:80-88`) — a countdown-to-boss style hint, not a difficulty threshold.
5. `GameMatch:ifRunningEnd()` spawns `levelMonsterNum / refreshMonsterTimes` every `refreshMonsterTime` seconds (`Match.lua:184-190`); `prepareMonster()` distributes the count across the configured monster types and can spawn fewer than the nominal total (`GameLevelConfig.lua:69-105`).

### 5.2 Normal-mode threshold defect

`m1019_1\game_level.csv` rows 1, 21 and 25 request more kills than their waves contain:

| Level | CSV kills | Sum of `monster_num.num` | Effective after clamp | Evidence |
|---:|---:|---:|---:|---|
| 1 | 40 | 15 | 15 | `game_level.csv:3`; `monster_num.csv:3-6` |
| 21 | 75 | 61 | 61 | `game_level.csv:23` |
| 25 | 69 | 61 | 61 | `game_level.csv:27` |

Consequence: configured total 8,159 kills becomes **8,112 effective kills** (25+14+8 lost). The hard_mode agent's `map_characteristics.json` independently reports `total_kills=8159`, `total_spawn=8112`, `total_effective_kills=8112` for normal, matching this finding. Hard10 and hard2 have no such mismatch (`total_spawn=7986=total_kills`).

### 5.3 Hard mode economy / difficulty spikes

- L60 hard10 is a 258-kill finale with boss 3031 (600k HP, 99,999 atk) plus 1065 fodder (252 count) and 2×3011 + 3×3021 adds. It is the only level with 4 wave entries and 60k gold.
- m1019_2 changes the finale to a faster, lower-HP boss (360k, attackSpeed 6, attackCd 6) and a 3.7M-HP basement; this is a large, deliberate rebalance rather than a small tuning pass.
- L17/19/37/39 are "elite reward" levels: few monsters, 9k–18k gold. In m1019_2 their reward is further increased (L37/L39 3k/4.5k exp).
- Hard10's weapon ladder shift from L14 is likely a data defect: the model/item ID sequence is offset by one while attack stats remain level-based. The same shift exists in m1019_2.

### 5.4 Rank threshold/expiry defects

- v10113 `GameRankNpc:setZExpireat()` sets the **week key** expiry to `DateUtil.getGreenwichDayLastTime()` (`GameRankNpc.lua:29-35`), while v10103 used `getWeekLastTime()` (`norm2\v10103\lua\server\data\GameRankNpc.lua:29-35`). Weekly ranks therefore expire daily in v10113.
- `getDayKey()` for the level NPC returns `g1019.level` with no date suffix, and `setZExpireat()` returns before setting its expiry (`GameRankNpc.lua:31-34,121-127`). The "daily" level leaderboard is effectively all-time unless the platform expires the key externally.

## 6. Cross-check with hard-mode agent

`reports\agents\hard_mode\map_characteristics.json` exists and was used as an independent cross-check. It agrees on:
- normal 100 levels / 8,159 configured kills / 8,112 effective kills;
- hard10 60 levels / 7,986 kills / 7,986 effective;
- hard10 config values and monster stats;
- m1019_10 is present in v10110 and unchanged through v10113;
- m1019_2 is not covered by that JSON (only map1/map10), so the m1019_2 analysis above is this agent's addition.

The hard-mode agent produced work artefacts but no narrative report at the time of writing; no conflicting claims were found.

## 7. Source coverage and limitations

Readable:
- `v10068`–`v10103`: all 116–424 `.lua` files are plaintext (verified by byte inspection). This includes the full game server, engine server/client/base and plugins.
- `v10113`: 459 plaintext Lua files from `decrypted\v10113\source` (production plugin `res.pack` decrypted; 459/459 resolved, 0 cipher). Source hashes match the extracted tree.
- `v10113` plugin-staging: 459/459 decrypted separately into `reports\agents\features\_work\plugin_staging_decrypted\v10113`; 5 semantic diffs vs production.
- All map `config.yml`/`scene*.yml` and the m1019_10/m1019_2 CSV tables are plaintext. m1019_1 CSV tables are plaintext v10068–v10108 and were decoded from map `res.pack` for v10109–v10113.

Not readable:
- `v10104`–`v10108`: plugin Lua is wrapped/ciphertext. Entry names, sizes and ciphertext hashes are available, but no source. Source-MD5 recovery from v10103 recovered 0 files (wrapper MD5s differ).
- `v10109`–`v10112`: plugin `res.pack` uses the legacy keyfile format; Lua content is unresolved because the sandboxol blob key is unknown (see `C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md`). TOC names/sizes and config CSVs were decoded.
- v10113 `pluginStaging` is decrypted and inspected; the v10109–v10112 staging plugin zips are not present (only v10091/v10095/v10098/v10099/v10113 staging zips exist).
- No resource/UI layout assets, localization tables, server logs, live backend or platform room configuration were supplied. Therefore:
  - plugin enablement conclusions are based on `setting/setting.json` + `Plugins.LoadAllPlugins()`; a platform-injected `plugins_setting.json` cannot be ruled out but is not present in any supplied artifact;
  - map exposure (which map a player can select) is a platform/room decision; the game Lua never references `m1019_10`/`m1019_2`;
  - hard-mode labels are not in the game data (both use scene name 20059 and `Messages:selectMapHint`).

Coverage counts used in this report: 41 manifest revisions, 31 readable full-source revisions (v10068-v10103), 2 decrypted v10113 source trees (production + staging), 9 unreadable plugin revisions (v10104-v10112), 5 missing revisions (v10078/v10081/v10089/v10092/v10094).

## 8. Reproduce

- Normalization / CHANGES: `reports\agents\features\_scripts\normalize2.py` → `CHANGES.tsv`, `_work\norm2\MANIFEST.json`.
- CSV parsing / comparisons: `_scripts\parse_maps.py`, `compare_modes.py`, `thresholds.py`.
- Matrix: `_scripts\build_matrix.py` → `FEATURE_MATRIX.csv`.
- Diffs: `reports\agents\features\diff\` (`*_game.diff` plus `*_server.diff` / `*_client.diff` / `*_plugins.diff` splits).
- Hard-mode cross-check: `reports\agents\hard_mode\map_characteristics.json`.




