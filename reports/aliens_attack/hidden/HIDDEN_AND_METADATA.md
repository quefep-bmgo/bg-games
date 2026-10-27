# HIDDEN_AND_METADATA - g1019 Aliens Attack

**Analysis date:** 2026-10-25  
**Inputs:** all local g1019 versions `v10068`-`v10113`, v10113 decrypted engine/game source, extracted Android/server pieces, the leaked source archive, and selective public web searches.  
**Write root:** `reports/agents/hidden/`. No production/GitHub file was modified.

**Bottom line:** v10113 ships two live maps for g1019: `m1019_1` (the original 100-level normal map) and `m1019_10` (a separate, much harder 60-level map). `m1019_10` is the only content that can be the "hard mode." It is **not** selected by the game plugin and **not** gated by any player-level or data/config threshold in the shipped pack. Selection is upstream in the app/server dispatch or matchmaking/lobby layer. The exact production selector is missing: the archived `game-service-api` is a stub that hardcodes `m_1008`, and the Go dispatcher's `DispatchUser()` is an empty TODO.

---

## 0. Method and provenance

- Inventoried 41 local `g1019` versions (`v10068`-`v10113`, with gaps such as 10078/10081/10089/10092/10094) from `games/g1019/` and `manifest/game-resource-config.json`.
- Re-hashed every map ZIP and every plugin ZIP; parsed every map `config.yml`, scene YAML, and loose CSV. For `v10109+ m1019_1` the CSVs live inside `res.pack`; I used the prior local decrypted extraction and verified its CSV hashes match the last loose-CSV normal package (`v10108`).
- Compared readable game-plugin sources (`v10068`-`v10103` plaintext; `v10113` decrypted) and extracted the v10113 staging plugin for a live-vs-staging diff.
- Scanned the Android app source, game-api, dispatcher, CDN pieces, private-server setting tables, current APK assets, and the leaked archive for hard-mode/unlock/event/GM vocabulary.
- The archive password is documented at `C:\Users\quefep\Desktop\Decomp Temp\IDENTIFIERS_REPORT.md:4`. It was read at runtime only to list/extract the local archive; its value is not recorded here or in `evidence.json`, and nothing was replayed against a live service.
- Some readability aids come from existing local workspaces (`reports/agents/hard_mode/work_versions`, `reports/agents/features/_work`). Key hashes were checked back against the actual ZIPs; see `evidence.json` -> `inputs.verification_note`.

Artifacts:
- `reports/agents/hidden/scripts/scan_metadata.py` - version/map/plugin inventory + timeline.
- `reports/agents/hidden/scripts/analyze_plugin_history.py` - plugin source hashes and live/staging diff.
- `reports/agents/hidden/scripts/scan_archive.py` - leaked-archive audit.
- `reports/agents/hidden/scripts/scan_keywords.py` - targeted vocabulary scan.
- `reports/agents/hidden/work/*.json` - generated evidence data.
- `reports/agents/hidden/evidence.json` - claim-by-claim evidence with IDs.

---

## 1. Proven from local artifacts

### 1.1 Version and map catalog

| Fact | Evidence |
|---|---|
| 41 local versions, `v10068`-`v10113`. | `manifest/game-resource-config.json`; `reports/agents/hidden/work/version_inventory.json` |
| v10113 has two live maps and one staging map: `m1019_10`, `m1019_1`; staging `m1019_2`. | `manifest/game-resource-config.json` key `"10113".maps` / `.mapsStaging`; `games/g1019/v10113/version.json` lines 6-8 (`hasPluginStaging`, `hasMapsStaging` true) |
| `m1019_10` first appears in v10110, uploaded 2025-07-15. | `"10110".maps[1]`; `"10109".maps` has only `m1019_1`; URL timestamp `g1019.1752547520182.zip` |
| `m1019_10` ZIP is unchanged from v10110 through v10113: md5 `96aad549865807944d45cbb1212d5ebf`. | `games/g1019/v10110..v10113/maps/m1019_10.zip`; matches manifest `mapHash` |
| `m1019_2` exists only in v10113 `maps-staging`, uploaded 2026-03-12: md5 `6450a8139f35ae42523215b097f3a845`. | `games/g1019/v10113/maps-staging/m1019_2.zip`; manifest `mapsStaging` |
| v10113 lists `m1019_10` first and `m1019_1` second; v10110-v10112 list `m1019_1` first. | `"10110".maps` vs `"10113".maps` |

### 1.2 The two live variants are genuinely different

Normal `m1019_1` (v10108 loose-CSV package; v10113 payload hashes match):

- 100 levels; kills sum 8159; monsterLv 1-800; 20 monster definitions; 2000 monster_num definitions; 30 max monsters.
- 60s wait, 60s prepare, 190s per level, refresh every 6s.
- Player base 1500 HP / 300 attack / 300 defense; boss level every 10 levels (kills = 1).
- Config: `games/g1019/v10113/maps/m1019_1.zip:config.yml` lines 8 and 20; metrics in `work/version_inventory.json`.

Hard candidate `m1019_10` (same bytes in v10110-v10113):

- 60 levels; kills sum 7986; monsterLv 0-900; 32 monster definitions; 1920 monster_num definitions; 33 max monsters.
- 30s wait, 30s prepare, 310s per level, refresh every 5s.
- Player base 1500 HP / **450 attack** / **330 defense**, +10 HP per upgrade.
- All 20 shared monster definitions change at least one stat; 12 new monsters are added: `1033,1043,1053,1063,1064,1065,2013,2023,2033,2034,2035,3031`. `3031` is a 600k-HP boss.
- Config: `games/g1019/v10113/maps/m1019_10.zip:config.yml` lines 8, 11, 20, 26, 35, 61-62; metrics in `work/version_inventory.json`; detailed diff in `work/features_compare_modes_output.txt`.

`m1019_2` (staging) is a balance variant of `m1019_10`, not a new world:

- All four MCAs and all three scene YAMLs are byte-identical to `m1019_10`.
- 42/60 `game_level` rows, 11/32 monster rows, 12/30 arms rows, and 40/60 basement rows differ.
- Config deltas vs `m1019_10`: `maxMonsters` 33->30, `PlayerUpgradeHealthReply` 0.15->0.2, `BasementUpgradeHealthReply` 0.33->0.35, `gameOverTime` 10->8.
- It is staging-only at v10113; no later version is in the corpus.

### 1.3 The game plugin does not select a map, a mode, or a difficulty

The v10113 game plugin (`server/`) is small and has no map-id or hard-mode branch:

- `Match.lua:11` - `GameMatch.gameType = "g1019"`.
- `Match.lua:273-280` - `selectMap()` calls `SceneConfig:randomScene()` and announces the scene name; it does not read a map id, mode, player level, or difficulty flag.
- `GameConfig.lua:66-67` - only `config.yml` `scenes` entries are loaded; `GameConfig.lua:81-88` loads the map's CSVs from the working directory.
- `SceneConfig.lua:19-49` - supports multiple scenes, but every map config lists only `scene1.yml`.
- `GameLevelConfig.lua:30-47` - `getMaxLevel()` and `getKillsByLevel()` are per-match wave thresholds, not unlock/selector thresholds.

Across readable plugin history:

- `Match.lua` is md5 `b1f50cc4228cf1ef4ad9ca973478423f` in v10068-v10103 and v10113; `GameConfig.lua` is `52fd28a900c6af64b0779b9cacb3c5f4` throughout.
- The only game-server source change from v10103 to v10113 is `data/GameRankNpc.lua` (week/day rank expiry changed to Greenwich time). See `work/plugin_history.json`.
- The v10113 staging plugin differs from live in exactly five engine files: `engine_base/util/FileUtil.lua`, `engine_client/ui/UIAnimation.lua`, `anti-hack/AntiHackConfig.lua`, `anti-hack/HackReport.lua`, `anti-hack/dynamic_script/check_fake_app.lua`. No game-server file changes. It is an anti-cheat/UI test build, not a hidden hard-mode build.

> Caveat: v10110-v10112 plugin sources are wrapped/legacy-encrypted in the local corpus, so their exact source is not readable. The v10113 plugin that ships with `m1019_10` demonstrably contains no selector; the map addition did not require a plugin gameplay change.

### 1.4 The old app shell is a dispatch consumer, not a selector

- `GameApi.getMiniGameDispatch` sends only `clz`, `name`, `pioneer`, `targetId`, `resVersion`, `ever` and the region. It does not send a map id or hard-mode flag (`GameApi.java:181-240`).
- The dispatcher response supplies `mname`/`mid`/`downurl`; `Dispatch.java:28-44` maps these to `mapName`/`mapId`/`mapUrl`.
- `EnterGameViewModel.java:203-208` copies `game.getGameMode()` (generic game field), `dispatch.mapName`, and `dispatch.mapId` into the launch result.
- The 2018 app snapshot's g1019 entry has `gameMode: 0` (`last_online.json:47-48`). All nearby games also have 0, so this field is not a hard-mode discriminator.
- Current app assets contain only `g1019.csv` (3 tips), `creepy_aliens.json` (UI texture atlas), and the title strings. No `m1019_10`/`m1019_2`/hard-mode string was found in the current `base.apk` DEX byte scan or assets.

### 1.5 The archived server code cannot explain the selection

- `game-api/game-service-api-main/src/dispatcher/service.js:47-53` - `// TODO: Map`; returns `name/mname/mid = "m_1008"` and `downurl = .../m1008.zip`.
- `dispatcher/game-service-dispatcher-master/internal/controllers/dispatch_controller.go:3-5` - `// TODO: Implementation needed`; `DispatchUser()` empty.
- The dispatcher service/DB files are generic room/DB plumbing; no g1019 or map-catalog logic.
- The `main-api` game model/table has no mode/map field (`game.sql`, `Game.js`), and no g1019 row.

### 1.6 No hard-mode label, unlock condition, threshold, or event schedule was found

Searched text in the game plugin, all map payloads, Android source/resources, dispatcher, game-api, CDN pieces, private-server setting tables, and current assets:

- 0 hits for `hard mode`, `hard_mode`, `difficulty`, `m1019_10`, `m1019_2`, `hidden mode`, `test build` in g1019-specific text (`work/keyword_hits.json`).
- No g1019 map-unlock field in `game-resource-config.json` (`gamesetting` only has category/team/player counts) or in the app/server code.
- `GameTip/g1019.csv` (current and private server) contains only `Minute`, `Second`, `MsgWelcomePlayer`. Scene names are shared numeric ids `20059`/`20060`/`20061`, not distinct map names.
- The only dated g1019-adjacent activity is a generic `pay_activity` button in `plugin/setting/pay_activity/PayActivity.json`: 2022-11-24 to 2022-11-30 (expired). No Aliens Attack event schedule or rotation was found.
- The only "unlock" string in the game plugin is the generic pay-activity toast `gui.limit.time.discount.store.item.unlock` (`PlayerListener.lua`); it is unrelated to maps.

### 1.7 Hidden/unused/test content

| Item | Finding |
|---|---|
| `scene2.yml` / `scene3.yml` | Shipped in every map package but never referenced by any `config.yml`; only `scene1.yml` is loaded. Dormant arenas, not hidden map selection. |
| `m1019_10` | Live hard-difficulty variant introduced silently in v10110; no label, promo, or unlock field. |
| `m1019_2` | Unreleased staging rebalance of `m1019_10`; same world, different stats/rewards. |
| Unused monster IDs | `m1019_1`: 1475/2000 `monster_num` ids are not referenced by its `game_level.csv`; monster def `1022` is also unreferenced. `m1019_10`: 1516/1920 unreferenced. These look like unused pools/variants, not a mode. |
| `v10113` staging plugin | Anti-cheat/UI changes only; no game logic. |
| Earlier staging channels | `v10079`-`v10088` maps-staging are duplicate `m1019_1`; `v10091/95/98/99` plugin-staging have the same `Match.lua` hash. No earlier hard-mode test build found. |
| GM/debug paths | Generic engine/base GM helpers and panels exist (paths only in section5); no g1019-specific GM/debug/test branch in `server/`. |

### 1.8 Source archive audit

The leaked archive (`C:\Users\quefep\Desktop\Decomp Temp\Copy of Copie de Blockman-Go (2).zip`, 3.63 GB) was audited read-only:

- Outer archive: 16 member ZIPs, timestamped 2024-08/09.
- `Blockman-Go/game-maps.zip` has exactly one g1019 entry: `game-map-main/games/g1019/g1019.1679368153307.zip` (3,255,782 bytes; md5 `d6db7c4aa9ea1c1b63ea27025f720304`; upload 2023-03-21).
- That snapshot contains 17 loose files: all normal `m1019_1` CSVs, config, scenes, and MCAs. All 17 match v10108 exactly except `checksums.md5`.
- The archive has **no** `m1019_10`, **no** `m1019_2`, and no hard-mode metadata. `game-map.md` only says `Game Id: g1019` / `Game Name: CreepyAliens`.
- `maps.zip` (`bmf-maps-master`) does not contain g1019 at all.
- `cdn-serve.zip` contains only `game-banners/g1019.png` and `game-icons/g1019.png`; no game config.
- `main-api-dev.zip` has a generic game model/schema but no g1019 record or mode field.

This is consistent with the archive predating the hard map by about two years.

---

## 2. Inferred

| ID | Inference | Confidence | Basis / caveat |
|---|---|---|---|
| I01 | `m1019_10` is what players would call the v10113 "hard mode"; it is a separate harder map, not a plugin branch or threshold. | High | P03/P04/P05/P06/P11. No artifact contains the literal label "hard mode"; the name is inferred from difficulty metrics. |
| I02 | Map selection happens upstream of the game plugin: in app/server dispatch, lobby, or matchmaking. | High | P06/P09/P10/P14. Production dispatch implementation is absent; game-api is a stub and dispatcher is TODO. |
| I03 | v10113 listing `m1019_10` first may mean hard mode became the preferred/default map, or may just be a CDN/config reorder. | Medium | P14. No default-map or room-creation field found. |
| I04 | `m1019_2` is a future/unreleased rebalance of the hard map, not a third mode. | High | P05. Staging-only; release name unknown. |
| I05 | There is no player/account-level unlock gate inside the shipped pack; if access is gated, it is external feature-flag/rollout logic. | Medium | P12/P15; absence of evidence in local pack. |

---

## 3. Secondary web evidence

| ID | Evidence | Notes |
|---|---|---|
| W01 | Archive.org BlockmanGO map archive lists `g1019 Aliens Attack.zip` but has no hard-mode/m1019_10 page: https://archive.org/details/blockmango | Secondary mirror; local archive is the stronger copy. |
| W02 | NamuWiki mini-game list mentions "Aliens attack" but no hard mode or map detail: https://en.namu.wiki/w/Blockman%20Go/%EB%AF%B8%EB%8B%88%EA%B2%8C%EC%9E%84 | Generic community list. |
| W03 | Targeted searches for `m1019_10`, "Aliens Attack hard mode", and Blockman GO hard-mode pages returned no first-party/reliable community documentation. | Negative search result; not proof of absence. |

**Secondary local capture (not web):** the 2026-10-20 live app capture `_capture/room_flows.jsonl` (lines 31/34/91) shows the g1019 game-list object with `gameId`, title, types, online count, praise count, `isNewEngine: 0`, `engineVersion: 0` - but **no** map list, mode, hard-mode, or unlock field. This is consistent with selection being server-driven, not exposed in the game-list payload.

---

## 4. How is the v10113 hard mode selected? - verdict

| Candidate | Verdict | Exact evidence |
|---|---|---|
| **Game plugin** | **No.** | `Match.lua:273-280` selects only a scene via `SceneConfig:randomScene()`; `GameConfig.lua:66-67` loads only the map's configured scenes; no `m1019_10`, map-id, mode, difficulty, player-level, or unlock reference anywhere in `server/`. Plugin gameplay source is unchanged from v10103 except rank expiry. |
| **App shell** | **No selector; dispatch consumer only.** | `GameApi.getMiniGameDispatch` sends no map/mode. `Dispatch.java` receives `mname/mid/downurl`. `EnterGameViewModel.java:203-208` forwards them. `last_online.json` has `gameMode: 0` for g1019. Current APK scan found no `m1019_10` string. |
| **Matchmaking / dispatch** | **Most likely.** | The only component that can supply a map id is the server dispatch (`mname`/`mid`/`downurl`). The manifest is a two-map catalog. But the archived `game-service-api` hardcodes `m_1008` (`service.js:47-53`) and the Go dispatcher is a TODO stub, so the production implementation is missing. |
| **Data/config threshold** | **No.** | No level/unlock/threshold field in `config.yml`, `game-resource-config.json`, `GameRule.csv`, `UIDisplay.csv`, `game_party_config` schema, or plugin code. `game_level.csv` "kills" are per-match wave requirements, not a hard-mode selector. |
| **Random map rotation** | **Possible, not proven.** | A two-entry `maps` array plus server-supplied `mapName`/`mapId` is consistent with rotation/assignment. No rotation code or capture exists. |

**Conclusion:** the v10113 hard mode is the `m1019_10` map package, selected outside the game plugin. The strongest local evidence points to the server dispatch/matchmaking/lobby layer, but the exact selector, its default, and any gate are unresolved because the production dispatch code and g1019 dispatch responses are not in the corpus.

---

## 5. Timeline

All dates are UTC from CDN URL timestamps unless noted.

| Date | Event | Confidence |
|---|---|---|
| 2018-12-13 | `m1019_1` normal map uploaded (`CreepyAliens.1544670764995.zip`). | High |
| 2020-12-21 | `CreepyAliens` plugin baseline in corpus (v10068). | High |
| 2021-08-04 | `m1019_1` repack/CSV revision; semantic rows unchanged. | High |
| 2023-03-21 | `m1019_1` snapshot used by the leaked source archive. | High |
| 2025-01-08 | v10109 `m1019_1` repacked into `res.pack`; normal mode only. | High |
| 2025-07-04 | v10110 plugin uploaded. | High |
| 2025-07-15 | `m1019_10` hard-difficulty map uploaded; listed second in v10110-v10112. | High |
| 2025-10-24 | v10112 plugin uploaded. | High |
| 2025-12-24 | v10113 `m1019_1` repacked (`res.pack` md5 `8bb48c...`). | High |
| 2026-01-16 | v10113 plugin uploaded; live maps reordered `[m1019_10, m1019_1]`. | High |
| 2026-02-02 | v10113 plugin-staging uploaded (anti-cheat/UI changes only). | High |
| 2026-03-12 | `m1019_2` staging map uploaded (rebalance of `m1019_10`; same world). | High |
| 2026-10-20 | Live capture: g1019 game-list object has no mode/map field. | Secondary-local |
| 2026-10-25 | This analysis. | - |

---

## 6. Unresolved - exactly where I looked and what is missing

| Question | Where I looked | What is missing |
|---|---|---|
| Exact selector for `m1019_10` (lobby vote, rotation, matchmaking, region flag) | Android source; `game-api`; `dispatcher`; `cdn-api`/`cdn-dev`; `game-resource-config`; `room_flows.jsonl`; source archive; `main-api` | Production g1019 dispatch service; a captured g1019 dispatch response; room-creation DB/feature-flag data. Included game-api hardcodes `m_1008`; Go dispatcher `DispatchUser()` is an empty TODO. |
| Official/UI name of `m1019_10` ("Hard Mode" or something else) | `g1019.csv` (current + private server); all Android `strings.xml` locales; plugin `Messages.lua`/scene YAMLs; current APK assets; public web | Any hard-mode label. All scene names are shared ids 20059-20061; no `m1019_10` string exists in app assets. |
| Whether hard mode is user-selectable, random, level-gated, event-gated, or region-gated | `game-resource-config.gamesetting`; `GameRule.csv`; `UIDisplay.csv`; `game_party_config` schema; plugin/map CSVs; live capture | Any gate/selector field or production feature flag. No g1019 event schedule; only an expired generic pay activity (2022-11-24-30). |
| Did v10113 make hard mode default, and did `m1019_2` ship later? | manifest 10110-10113; `version.json`; map ZIPs; live capture | A default-map field or post-v10113 version. Corpus ends at v10113. |
| Why did v10113 repack `m1019_1` `res.pack`? | res.pack hashes; decrypted CSV hashes; map entry hashes | An explained content delta. World/CSV hashes match the older normal map; the repack may be anti-cheat/container churn. |
| Are there missing versions with selector/hard-mode changes? | `games/g1019`; manifest; source archive | Versions 10078/10081/10089/10092/10094 and anything after 10113 are absent. |
| Does a current client UI render a map/mode chooser outside the 2018 Android source? | current `base.apk` DEX byte scan; `assets.apk` names; 2018 Android source | A full decompile of app 3.29.3. The APK scan found no `m1019_10`/`m1019_2` strings and only the g1019 tip/art assets. |

---

## 7. Security-relevant locations (locations only; nothing replayed)

- **Archive password:** `C:\Users\quefep\Desktop\Decomp Temp\IDENTIFIERS_REPORT.md:4` - value redacted; used locally only to list/extract the archive.
- **GM/debug facilities (generic engine/base, not g1019 server code):**
  - `decrypted/v10113/source/lua/engine_client/helper/GMHelper.lua`
  - `decrypted/v10113/source/lua/engine_client/ui/layout/GUIGMControlPanel.lua`
  - `decrypted/v10113/source/lua/plugins/data_report/client/GMDataReport.lua`
  - `reports/agents/hard_mode/work/plugin/base/helper/GMHelper.lua`
- **Signing key:** `server_src/extracted/android/android-client-dev/app/sandbox.jks` (not opened).
- **Server credential/config paths:** `server_src/extracted/dispatcher/game-service-dispatcher-master/configs/{auth,database,host}.json`; `main-api-dev.zip` member `main-api-dev/src/config/discord.json` (not extracted).
- **Test-channel flags:** `games/g1019/v10113/version.json` (`hasPluginStaging`, `hasMapsStaging`), `maps-staging/m1019_2.zip`, `plugin-staging.zip`. No GM/debug flag was found in the g1019 game plugin.

No credential value, token, or password is reproduced in this report or in `evidence.json`.

---

## 8. Reproduction

```powershell
$py = "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe"
& $py reports\agents\hidden\scripts\scan_metadata.py
& $py reports\agents\hidden\scripts\analyze_plugin_history.py
& $py reports\agents\hidden\scripts\scan_keywords.py
& $py reports\agents\hidden\scripts\scan_archive.py   # reads archive password from IDENTIFIERS_REPORT.md at runtime
```

The archive script writes only under `reports/agents/hidden/work/archive/` and never prints the password. The output files are listed in `evidence.json` -> `artifacts.work`.

---

## 9. Answer to the specific question

**The v10113 "hard mode" is the `m1019_10` map package.** It is not selected by the game plugin, the app shell, or a data/config threshold. The plugin only picks a scene from whatever map the host supplies; the old app only forwards a server-supplied `mapName`/`mapId`; and no unlock/level threshold exists in the pack. The most likely selector is server dispatch/matchmaking/lobby logic, but the exact implementation is missing from the archive (game-api hardcodes `m_1008`; dispatcher `DispatchUser()` is a TODO). `m1019_2` is an unreleased staging rebalance of `m1019_10`; `scene2`/`scene3` are dormant; and the leaked source archive contains only the 2023 normal `m1019_1` snapshot, so it predates the hard map and cannot corroborate its selection.


