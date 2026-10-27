# g1019 — Aliens Attack / CreepyAliens: hard-mode analysis

Scope: all 41 archived g1019 revisions (`v10068`–`v10113`), the v10113 decrypted plugin Lua, all map zips (including `maps-staging`), the live `game-resource-config`, the local Blockman GO APK, the leaked Android/game-api/dispatcher sources, and public community material as secondary evidence.

All production artifacts were read-only. No credentials were used and no service was modified; the only live read was the anonymous public `game-resource-config` file. This report and its scripts are under `reports/agents/hard_mode/`.

## Bottom line

**“Hard mode” is the separate map/config variant `m1019_10`, not a game-mode code path and not a wave transition.**

- `m1019_10` first appears in manifest revision **10110** and is unchanged through **10113**. Its map zip timestamp is **2025-07-15 02:45:20 UTC**. It has **60 levels**, **7,986 required kills**, **32 monsters**, **3 bosses**, and **33 max monsters**.
- The g1019 plugin has **no** `hard`, `difficulty`, `challenge`, `nightmare`, or mode branch. Its only progression rule is `kills >= GameLevelConfig:getKillsByLevel(level)`; the match ends when `level > getMaxLevel()`.
- **No player level, kill count, wave number, or account threshold that unlocks or selects `m1019_10` was found in any local artifact.** Map choice is external: the normal old-engine launch request does not send a map id; the server/dispatcher returns `Dispatch.mapId`/`mid`, and the plugin uses it. The local artifacts do **not** contain the dispatcher’s map-selection rule.
- `m1019_10` is best described as **a de facto / community “hard mode” map**. There is **no official “hard mode” label** in the map, plugin UI, app strings, or manifest.
- The staging map `m1019_2` is a future hard-map rebalance, not a live mode or threshold.

If a specific claim says “hard mode unlocks at level N” or “at N kills,” it is **not supported by the archived g1019 artifacts**.

Evidence labels: **P** = proven by local artifact; **I** = inference; **E** = external/secondary; **U** = unproven/unknown.

---

## 1. Artifact timeline

`manifest/game-resource-config.json` is the authoritative published map list. It is minified, one line, 52,946 bytes, MD5 `22DA772EB7A87A53BC683ABCB47D6A85`, SHA-256 `04BF69F6EB6C79994970331AE904324FEB881F5A96DBAE98CE9D7192283166C0`. The current public copy fetched from `https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1019` is byte-identical to it (**P**).

| Revision range | Live maps | Notes |
|---|---|---|
| `10068`–`10108` | `m1019_1` only | Normal 100-level map. |
| `10109` | `m1019_1` only | Map 1 CSVs moved into `res.pack`; same 100-level data. |
| `10110`–`10112` | `m1019_1`, **`m1019_10`** | Hard map goes live. Map 10 hash `96aad549865807944d45cbb1212d5ebf`, unchanged through 10113. |
| `10113` | **`m1019_10` first**, `m1019_1` second; `mapsStaging: m1019_2` | Map order changes; map 1 gets a new `durl`/hash; map 2 is staging-only. |

Exact manifest anchors:

- `$.10110.maps[1]` = `m1019_10`, `durl` `g1019.1752547520182.zip`, hash `96aad549865807944d45cbb1212d5ebf`, size 3,172,643, 17 files (**P**). JSON byte offset around `50592`.
- `$.10113.maps[0]` = `m1019_10` (same artifact), `$.10113.maps[1]` = `m1019_1` with `durl` `g1019.1766549414908.zip` and hash `c6568289774b690810421befb26a1c41` (**P**). JSON byte offset around `51965`.
- `$.10113.mapsStaging[0]` = `m1019_2`, hash `6450a8139f35ae42523215b097f3a845`, size 3,172,693, 17 files (**P**). JSON byte offset around `52569`.

Map artifact hashes:

| Artifact | Size | MD5 | SHA-256 |
|---|---:|---|---|
| `v10113/maps/m1019_10.zip` | 3,172,643 | `96AAD549865807944D45CBB1212D5EBF` | `C001228431A6EED0B85ADFD5A252F483F8D89DC31359371490CF6418F3EC9D74` |
| `v10110/maps/m1019_10.zip` | 3,172,643 | `96AAD549865807944D45CBB1212D5EBF` | `C001228431A6EED0B85ADFD5A252F483F8D89DC31359371490CF6418F3EC9D74` |
| `v10113/maps/m1019_1.zip` | 3,256,460 | `C6568289774B690810421BEFB26A1C41` | `ED393624DC012ADB5E2E67B5F61D329787FC3B578A7B59B5CBAE03A32CAB6659` |
| `v10113/maps-staging/m1019_2.zip` | 3,172,693 | `6450A8139F35AE42523215B097F3A845` | `30A1BEF1736034EB151FD33E05EACF288D231AD45F3A2C048301A5DB70E6CF49` |

The manifest `mapHash` equals the MD5 of the map zip for all three artifacts (**P**).

The archive is missing revisions `10078`, `10081`, `10089`, `10092`, and `10094`; all precede `10110`, so they cannot contain an earlier archived occurrence of `m1019_10`.

**Normal map 1 did not gain progressive content.** Parsed v10068 vs v10113 map 1 tables are row-for-row identical for `game_level.csv` (100 rows), `monster.csv` (20), `monster_num.csv` (2,000), `basement.csv` (100), and `player_level.csv` (30); the four `.mca` region files are byte-identical. The v10109 and v10113 map-1 changes are packaging/hash changes, not new levels (**P**).

---

## 2. What `m1019_10` actually is

`m1019_10` is a standard map zip with 17 entries:

`arms.csv`, `basement.csv`, `checksums.md5`, `config.yml`, `equipment.csv`, `game_level.csv`, `monster.csv`, `monster_num.csv`, `player_level.csv`, four `r.*.mca` region files, `scene1.yml`, `scene2.yml`, `scene3.yml`, `skill.csv`.

Key observations:

- **No `lang/` file and no mode/difficulty field.** The map contains only gameplay/config data. There is no official name/label for “hard mode” in the artifact (**P**).
- `scene1.yml` uses `name: 20059`, the same scene id as normal `m1019_1` (`m1019_10/scene1.yml:5`; `m1019_1/scene1.yml:5`). The plugin’s map hint is just `Messages:selectMapHint(scene.name)` (`server/messages/Messages.lua:15-17`), so even the in-game hint cannot distinguish the variants (**P**).
- Only `scene1.yml` is referenced by `config.yml` (`scenes:` at `m1019_10/config.yml:3-5`). `scene2.yml` and `scene3.yml` are present but unreachable in all maps (**P**).
- The terrain is different from normal: all four `.mca` MD5s differ from `m1019_1`; `m1019_10` and staging `m1019_2` share identical `.mca` and scene files (**P**). Hard scene1 has **30 monster spawn points** vs **24** in normal; boss spawn moves from `[1725,37,-469,50]` (`m1019_1/scene1.yml:56-58`) to `[1764,37,-420,50]` (`m1019_10/scene1.yml:68-70`) (**P**).

This is a **separate map/config**, not a branch inside one map.

---

## 3. Exact map-10 characteristics

All values below are from `m1019_10/config.yml`, `game_level.csv`, `monster.csv`, `monster_num.csv`, and `basement.csv` in `v10113` (identical to `v10110`). Full per-level data is in `map10_levels.csv` and `evidence.json`.

### 3.1 Config: normal vs hard map

| Key | `m1019_1` (v10113) | `m1019_10` | Evidence |
|---|---:|---:|---|
| waitingTime | 60 | **30** | `config.yml:8` |
| prepareTime | 60 | **30** | `config.yml:11` |
| gamePrepareTime | 10 | **8** | `config.yml:17` |
| gameLevelTime | 190 s | **310 s** | `config.yml:20` |
| gameOverTime | 10 | 10 | `config.yml:23` |
| refreshMonsterTime | 6 s | **5 s** | `config.yml:26` |
| refreshMonsterTimes | 10 | **15** | `config.yml:29` |
| startPlayers | 1 | 1 | `config.yml:32` |
| maxMonsters | 30 | **33** | `config.yml:35` |
| PlayerUpgradeHealthReply | 0.1 | **0.15** | `config.yml:53` |
| BasementUpgradeHealthReply | 0.2 | **0.33** | `config.yml:56` |
| playerAttr.hp | 1500 | 1500 | `config.yml:60` |
| playerAttr.attack | 300 | **450** | `config.yml:61` |
| playerAttr.defense | 300 | **330** | `config.yml:62` |
| playerAttr.addHp | 0 | **10** | `config.yml:64` |
| playerAttr.maxLv | 1000 | 1000 | `config.yml:65` |
| respawn time / price | 180 / `[1,4,80]` | **310 / `[1,1,80]`** | `config.yml:123-127` |

The `refreshMonsterTimes` value splits each level’s total spawn count into 15 refresh batches, called every 5 s; the level still has a 310 s time limit. This is a config split, not 15 separate “difficulty waves” with separate thresholds (**P**).

### 3.2 Level count and kill totals

| Metric | `m1019_1` | `m1019_10` |
|---|---:|---:|
| Levels | 100 | **60** |
| Configured total kills | 8,159 | **7,986** |
| Spawned total | 8,112 | **7,986** |
| Effective total after plugin clamp | **8,112** | **7,986** |
| Boss levels | 10,20,30,40,50,60,70,80,90,100 | **10,20,30,40,50,60** |
| Final level kills | 4 | **258** |
| Final basement HP | 70,000 | **138,750** |

Normal has a config/plugin mismatch: `GameLevelConfig:getMonstersByLevel()` overwrites `level.kills` with the spawn sum when the spawn sum is smaller (`server/config/GameLevelConfig.lua:55-64`). This silently changes normal levels 1/21/25:

| Normal level | CSV kills | Spawned | Effective |
|---:|---:|---:|---:|
| 1 | 40 | 15 | **15** |
| 21 | 75 | 61 | **61** |
| 25 | 69 | 61 | **61** |

Hard map 10 has **no** such mismatch: every level’s `kills` equals its spawn sum (**P**).

Hard map 10’s `monsterLv` starts at **0 for levels 1–10**, then goes 10, 20, … 900 at level 60. Normal map 1 starts at `monsterLv` 1 and reaches 800 at level 100. The hard map is a condensed 60-level curve with higher player base attack and a different monster roster, not a normal-map wave inserted at level 60.

### 3.3 Boss-gate thresholds (the only exact “thresholds” in map 10)

| Level | Required kills that level | Cumulative effective kills | Composition |
|---:|---:|---:|---|
| 10 | 21 | **496** | `3011` x1 + `1011` x19 + `1061` x1 |
| 20 | 31 | **1,311** | `3021` x1 + `1031` x29 + `1033` x1 |
| 30 | 41 | **2,337** | `3011` x1 + `3021` x1 + `1053` x38 + `2022` x1 |
| 40 | 51 | **3,847** | `3011` x2 + `3021` x1 + `2023` x47 + `1064` x1 |
| 50 | 60 | **5,698** | `3011` x2 + `3021` x2 + `1043` x10 + `1053` x10 + `2013` x10 + `2023` x10 + `1033` x16 |
| 60 | **258** | **7,986** | `3031` x1 + `1065` x252 + `3011` x2 + `3021` x3 |

Evidence: `m1019_10/game_level.csv:12,22,32,42,52,62`; `monster_num.csv` counts; `monster.csv:32-34`.

Normal boss gates, for comparison (`m1019_1/game_level.csv:12,22,...,102`):

| Level | Kills | Cumulative | Bosses |
|---:|---:|---:|---|
| 10 | 1 | 421 | 3011 x1 |
| 20 | 1 | 937 | 3021 x1 |
| 30 | 1 | 1,557 | 3011 x1 |
| 40 | 1 | 2,207 | 3021 x1 |
| 50 | 1 | 2,871 | 3011 x1 |
| 60 | 1 | 3,635 | 3021 x1 |
| 70 | 2 | 4,619 | 3011 + 3021 |
| 80 | 2 | 5,718 | 3011 + 3021 |
| 90 | 3 | 6,841 | 3011 x2 + 3021 |
| 100 | 4 | **8,112** | 3011 x2 + 3021 x2 |

### 3.4 Final wave and bosses

Hard map 10, level 60 is the terminal wave (`GameMatch:upgradeGameLevel()` increments to 61, `> getMaxLevel()`, and ends the match; `server/Match.lua:208-235`):

- 258 kills
- `3031` x1 — 600,000 HP, 99,999 attack, 0 defense, 60,000 gold, 5,000 exp, `isBoss=1` (`m1019_10/monster.csv:34`)
- `3011` x2 — 45,000 HP, 800 attack (normal 3011 is 30,000/600; `monster.csv:32`)
- `3021` x3 — 27,000 HP, 1,200 attack (normal 3021 is 16,000/1,200; `monster.csv:33`)
- `1065` x252 fodder — 800 HP, 1,000 attack (`monster.csv:29`)

Normal final level 100 is only 4 kills: `3011` x2 + `3021` x2. Normal level 60 is one `3021` kill. The hard final wave is a different design, not a scaled normal wave (**P**).

### 3.5 Monster roster

Normal has 20 monster definitions; hard has **32**, all 12 added IDs are used:

`1033, 1043, 1053, 1063, 1064, 1065, 2013, 2023, 2033, 2034, 2035, 3031`.

Boss roster: normal `3011` (doctor_octopus2) and `3021` (ufo_hunter); hard adds `3031` (doctor_octopus) and buffs `3011`/`3021` (**P**).

### 3.6 Basement

- Normal: 100 rows, L1 = 8,200 HP, L100 = 70,000 HP.
- Hard: 60 rows, L1 = 9,200 HP, L60 = **138,750 HP** (`m1019_10/basement.csv:62`).
- All defense values are 0 in both (**P**).

### 3.7 Staging map 2

`m1019_2` is **not live**; it is only `mapsStaging[0]` at revision 10113. It has 60 levels/7,986 kills but different balance: `maxMonsters` 30, `gameOverTime` 8, heal 0.20/0.35, L60 basement 3,700,000, and `3031` rebalanced to 360,000 HP / 100,000 attack. It shares all four `.mca` hashes and scene files with `m1019_10` (**P**, detailed in `evidence.json` / `map_characteristics.json`). Its `durl` timestamp is **2026-03-12 07:13:31 UTC**, one second before the live config’s last-modified time (2026-03-12 07:13:32 UTC), consistent with a pending next build. It is a future map variant, not a trigger.

---

## 4. Is there a player-level / kill / wave trigger?

**No trigger was found in the archived g1019 package.** The evidence is both positive (what the code does) and negative (no mode/unlock data anywhere).

### 4.1 Plugin code has no hard branch

The entire match progression is:

- `GameMatch:ifCanUpgradeGameLevel()` compares `getCurGameScene():getKills()` with `GameLevelConfig:getKillsByLevel(self.level)` (`server/Match.lua:384-388`).
- `GameMatch:upgradeGameLevel()` increments the level, clears monsters, loads the next level, and ends the match when `level > GameLevelConfig:getMaxLevel()` (`server/Match.lua:208-235`).
- `GameLevelConfig` reads `kills`, `monsterLv`, `monsterNumIds`, `basementId`, `gold`, `exp` from `game_level.csv`; there is no map/mode/difficulty argument (`server/config/GameLevelConfig.lua:13-64`).
- `Match.lua` never checks a map name, map hash, player account level, or an unlock flag. The only map-like action is `selectMap()`, which picks an internal **scene** from `SceneConfig`, and only `scene1.yml` is loaded (`Match.lua:273-281`; `SceneConfig.lua:14-49`; `GameConfig.lua:66-68`).

A keyword scan over all 459 v10113 Lua files found:

| Token | Hits | Nature |
|---|---:|---|
| `hard` | 3 | `BlockID.CLAY_HARDENED*` and a UUID comment only |
| `difficulty` | 0 | — |
| `challenge` | 1 | pay_activity UI grid `ChallengeTask-List` |
| `nightmare` | 0 | — |
| `unlock` | 6 | engine commodity/ranch events + a shop toast |
| `minLevel` / `requireLevel` / `requiredLevel` | 0 / 0 / 0 | — |
| `mode` | 122 | engine/UI/animation/network mode, none a g1019 mode branch |

Full contexts are in `keyword_hits_v10113.json`.

### 4.2 Map choice is external

For the old engine, the normal client dispatch request contains only `clz`, `name`, `pioneer`, `targetId`, `resVersion`, `ever`, and `rid`; it does **not** send a map id (`server_src/extracted/android/android-client-dev/app/src/main/java/com/sandboxol/blockymods/web/GameApi.java:181-209`). The client then uses `Dispatch.mapId` from the server response (`server_src/extracted/android/android-client-dev/app/src/main/java/com/sandboxol/blockymods/view/activity/join/EnterGameViewModel.java:155,195-208`). The leaked team-dispatch path can accept an optional `mapId`, but only if its caller supplies one (`server_src/extracted/android/android-client-dev/game/src/main/java/com/sandboxol/gameblocky/web/BlockyGameApi.java:42,59-66`); g1019’s normal launch does not.

On the plugin side, `GameGroupManager:takeGroupStart` accepts a `mapId`, defaults it to `""`, sends it as `mapid` to the dispatch service, and reads the server’s `data.mid` back (`engine_server/manager/GameGroupManager.lua:104-158,215-222`). The g1019 game scripts never call `takeGroupStart` with a map id.

Therefore, **the map id (`m1019_1` vs `m1019_10`) is a host/dispatcher decision made before the match starts**, not a g1019 plugin threshold. The local artifacts do not contain the dispatcher’s selection rule.

At v10113 the live `maps[]` array order changes to `m1019_10` first, `m1019_1` second. That is a real metadata change, but no local code proves the dispatcher uses array order. It is an **unproven hint** that map 10 may be the default after v10113, not a demonstrated trigger.

### 4.3 No unlock field, no UI label

- `manifest` map entries contain only `name`, `durl`, `mapHash`, `configFiles`, `fileSize`, `fileCount`; `gamesetting` contains only category/team/num limits. There is no `unlock`, `minLevel`, `gameMode`, or `difficulty` field (**P**).
- `m1019_10` has no `lang/` entry, no map name, and the same scene id `20059` as normal. The map zip is pure gameplay data (**P**).
- g1019 app strings contain only `game_g1019 = Aliens Attack` (`server_src/extracted/android/android-client-dev/app/src/main/res/values/strings.xml:453`, `server_src/extracted/android/android-client-dev/app/src/main/res/values-zh/strings.xml:452`). The current APK resource table has no g1019-specific hard/difficulty/challenge/nightmare label (**P** for the scanned APK; see limitations).
- The old cached game record has `gameMode: 0`; current game-list metadata has no difficulty/mode field for g1019 (**P** for cached/API data; not proof of a missing server-side rule).

### 4.4 It is not a wave transition

- The map is fixed before the match; `Match.lua` only cycles levels inside that map. There is no branch that changes map, monster table, or difficulty flag at a wave.
- Hard map 10’s “wave 60” is its **final** level, not an unlock event. Clearing level 60 sets the internal level to 61 and ends the match; it does not switch to another map or mode (`Match.lua:221`).
- The only repeated 10-step pattern is the boss-gate hint `10 - level % 10` sent to the UI (`Match.lua:233`), which is a countdown hint, not a difficulty transition.

### 4.5 So what “threshold” can be stated?

The defensible numbers are **inside map 10**, not gates to it:

- Boss gates at levels **10, 20, 30, 40, 50, 60** (cumulative kills **496, 1,311, 2,337, 3,847, 5,698, 7,986**).
- Terminal wave: level **60**, **258 kills**, boss `3031` 600,000 HP.
- Hard map 10 starts at level 1; it is not entered at level 60.

The only defensible “trigger” statements are:

| Layer | Finding | Status |
|---|---|---|
| Availability | The map artifact enters the published `maps[]` at resource revision **10110** (map zip timestamp 2025-07-15). | **P** |
| Selection | The host/dispatcher chooses `m1019_10` before the match; the rule is not in local artifacts. | **P for external selection; U for the rule** |
| Player gate | None found: no account level, kill total, wave count, or unlock flag. | **P negative search** |
| Content transition | None: map 10 starts at level 1 and ends at level 60; no mode switch. | **P** |

No file in the archive contains a g1019 map-eligibility condition. The only `unlock` hits in the plugin are generic engine commodity/ranch events and a shop toast; none reference maps, accounts, or g1019 progression.

There is **no evidence** for any of these common claims:

| Claim | Status |
|---|---|
| “Hard mode unlocks at account level 60 / 100.” | **Unsupported** |
| “Hard mode starts after 60 waves / after beating normal.” | **Unsupported / contradicted by map selection being external** |
| “Hard mode is selected at 20 kills / wave 10.” | **Unsupported** |
| “Hard mode is a second difficulty button in the g1019 UI.” | **Unsupported; no UI/label exists** |
| “Hard mode is map 10.” | **Supported as the only plausible identity**, but the label is not official |

---

## 5. App / API / public metadata checks

- **Local APK**: `_capture/apk/base.apk`, package `com.sandboxol.blockymods`, version **3.29.3 / 5753**. `aapt2` resource dump contains `game_g1019 = Aliens Attack` but no g1019 hard/difficulty/mode string. `assets/game_list.json` contains only localized titles. `assets/last_online.json` (old cache) has `gameMode: 0` for g1019, no hard flag.
- **Live public config**: the 52,946-byte `game-resource-config_g1019` fetched 2026-10-25 is byte-identical to the local manifest. It still lists `m1019_10` first, `m1019_1` second, and `m1019_2` only in `mapsStaging`. Thus map 10 is live now; map 2 is not.
- **Leaked server sources**: `game-api` has a generic `Map` model and `dispatcher` is a skeleton with a hard-coded `m_1008` TODO map. There is no g1019-specific map/unlock logic. This is consistent with map choice being external/backend-only, but does not reveal the production rule.
- **Community/secondary**: see below. No public page or search result found that gives a g1019 hard-mode unlock threshold.

---

## 6. Community evidence (secondary only)

These are **not** proof of a trigger; they corroborate the identity/timing of the new map.

| Source | What it says | Use |
|---|---|---|
| 4k-video.ru index, “Blockman Go Alien Attack - New map update wave 60 (LV 1000)”, Saotome Kurome, 1:31, <https://4k-video.ru/en/search_video/blockman-go-new-map> | Community video title: new map update, 60 waves, LV 1000 | **E**; matches 60-level map and `maxLv:1000`; does not call it an official mode. |
| Reddit r/BlockmanGo, 2025-05-28, “wake up for the people who used to play alien attack, the dev just added a new update…” <https://www.reddit.com/r/BlockmanGo/comments/1kxcq95/> | Community notice of an Aliens Attack update in the 2025 period | **E**; timing only. |
| YouTube, Puteri Po, 2025-06-26, “WOW New Maps for OG Games in Blockman Go” <https://www.youtube.com/watch?v=FC4M7vnofl0> | Community report of new maps for classic games | **E**; not g1019-specific proof. |
| Blockman GO official YouTube, 2025-09-30, “Blockman Go Jail Break's map has updated!” <https://www.youtube.com/watch?v=jttH5J_chms> | Official description for another old game: “Every time you enter the game, you'll jump into the new map or the classic map.” | **E/analogy only**; supports the platform’s new-map/classic-map pattern, not g1019. |

The community material supports “new 60-wave map,” not “unlock at N.” Searches for a g1019 hard-mode threshold returned no authoritative result.

---

## 7. Confidence and limitations

**High confidence**

- `m1019_10` exists, is live from manifest 10110, and is unchanged through 10113.
- Its 60 levels, 7,986 kills, boss gates, final wave, config, boss stats, and 138,750 final basement are exact.
- Normal `m1019_1` is a 100-level map with 8,159 configured / 8,112 effective kills and boss gates through 100.
- The v10113 g1019 plugin has no hard/difficulty/mode branch and no map selection.
- No unlock/level/kill threshold was found in the archived plugin, map, manifest, or scanned app resources.

**Medium confidence**

- `m1019_10` is what players mean by “hard mode.” It is the only new live map and is objectively harder at the top end.
- Map selection is external and happens before the match.

**Unproven / unknown**

- The live dispatcher’s map-assignment policy (random, rotation, first-map, account/region/event-based, etc.).
- Whether the v10113 `maps[]` order change (`m1019_10` first) makes it the default. The manifest order is real, but no local code proves the dispatcher honors it.
- Whether any platform/backend unlock rule exists outside the supplied artifacts.
- v10109–v10112 plugin Lua semantics (legacy keyfile unresolved); v10113 is the latest inspected source. Map/config data and manifest are fully available for those revisions.
- No official localization string “Hard Mode” exists in the artifacts; the label is analyst/community shorthand.

**What would change the conclusion:** a captured g1019 dispatch response for different account states showing `mid=m1019_10` only above a level/kill threshold, or a platform config/UI field naming/unlocking the map. Neither is present locally.

---

## 8. Verdict

- **Hard mode = `m1019_10`**, the 60-level map/config variant. Strictly, g1019 has one gameplay mode (wave defense); “hard mode” is a map variant, not a code-level mode, and not a mid-match wave transition.
- **Exact trigger/threshold: none found.** The map is chosen by the host/dispatcher before the match. The g1019 package contains no player-level, kill, wave, or unlock condition for it.
- **Exact map-10 thresholds:** boss gates at levels 10/20/30/40/50/60, cumulative kills 496/1,311/2,337/3,847/5,698/7,986; terminal wave level 60 with 258 kills and boss 3031 (600,000 HP, 99,999 attack).
- **`m1019_2`** is a staging-only 60-level rebalance, not live and not a trigger.
- Any claimed numeric unlock threshold (e.g., “level 60/100”) is **unsupported** by these artifacts.

---

## 9. Reproduce

Scripts are in this directory. Python used: `C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe`.

```powershell
python analyze_map_data.py      # parses map1/map10/map2 CSV + config -> map_characteristics.json
python unpack_map_pack.py       # decodes v10113 map1 res.pack CSVs via tools/bmg_extract.py
python keyword_scan.py          # scans 459 v10113 Lua files for hard/difficulty/mode/unlock
python map_keyword_scan.py      # scans all map config/CSV files for mode/unlock fields
python build_evidence.py        # builds evidence.json + map10_levels.csv + map1_levels.csv
```

Deliverables:

- `REPORT.md` — this report
- `evidence.json` — structured evidence, full level arrays, hashes, manifest timeline, code references
- `map10_levels.csv` — all 60 levels with kills/spawns/cumulative/boss IDs
- `map1_levels.csv` — all 100 normal levels
- `map_characteristics.json` — parsed config/level/monster/basement data
- `keyword_hits_v10113.json` — every hard/difficulty/mode/unlock hit in v10113 Lua
- `work/`, `work_versions/`, `work_map_unpack/`, `work_plugin_dec/` — extracted artifacts used for verification

Key source anchors:

- `decrypted/v10113/source/lua/server/Match.lua:208-235,273-281,384-388`
- `decrypted/v10113/source/lua/server/config/GameLevelConfig.lua:30-64`
- `decrypted/v10113/source/lua/server/config/SceneConfig.lua:14-49`
- `decrypted/v10113/source/lua/server/config/GameConfig.lua:66-68`
- `decrypted/v10113/source/lua/server/messages/Messages.lua:15-17`
- `decrypted/v10113/source/lua/engine_server/manager/GameGroupManager.lua:104-158,215-222`
- `m1019_10/config.yml`, `m1019_10/game_level.csv:12,22,32,42,52,62`, `m1019_10/monster.csv:32-34`, `m1019_10/basement.csv:62`
- `manifest/game-resource-config.json` (`$.10110.maps[1]`, `$.10113.maps[0]`, `$.10113.mapsStaging[0]`)
