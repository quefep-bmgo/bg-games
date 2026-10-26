# DATA_MODEL — Blockman GO g1019 (Aliens Attack)

**Scope:** 41 downloaded versions `v10068` … `v10113` of `g1019`, maps `m1019_1`, `m1019_10`, staging map `m1019_2`, plus plaintext/decrypted Lua source used only to confirm formulas.
**Root:** `C:\Users\quefep\Desktop\Decomp Temp\aliens_attack`
**Output root:** `reports\agents\data\`
**Production/GitHub:** not modified. All writes are under `reports\agents\data\`.

This document separates **data-derived facts** from **interpretation**. Every derived metric has its formula and source columns listed. The DPS/required-level model is explicitly a single-target, single-player model, not a game simulation.

---

## 1. Inputs and inventory

### 1.1 Versions

- 41 versions, ordered by version number: `v10068` … `v10113`.
- Missing version numbers in the downloaded set: `v10078`, `v10081`, `v10089`, `v10092`, `v10094`.
- `VERSIONS.csv` has one row per version with local plugin hash/size, manifest hash/size/file count, `gamesetting.nummin/nummax`, and live/staging map lists.
- `MAP_ARTIFACTS.csv` has one row per version/map/channel with manifest URL, manifest `mapHash`, size/file count, config-file count, local MD5/SHA-256, and hash-match status.

### 1.2 Map availability

| Map / channel | Versions present | Count |
|---|---|---:|
| `m1019_1` / live | `v10068` … `v10113` | 41 |
| `m1019_1` / staging | `v10079, v10080, v10082, v10083, v10084, v10085, v10086, v10087, v10088, v10104, v10105` | 11 |
| `m1019_10` / live | `v10110` … `v10113` | 4 |
| `m1019_2` / staging | `v10113` | 1 |

`m1019_2` exists only as a staging artifact in `v10113`. `m1019_1` staging copies are table-for-table and config-identical to `m1019_1` live; only the channel/version metadata differs.

### 1.3 Extracted data volume

| Item | Count |
|---|---:|
| Total extraction records | 689 |
| Direct zip-member config files | 644 |
| CSV entries decoded from `res.pack` | 40 |
| `res.pack` containers inspected | 5 |
| Table-file records | 456 |
| `config.yml` records | 57 |
| Scene YAML records | 171 |
| Data-quality rows | 684 |
| MD5 mismatches | 0 |
| Parse errors / empty tables | 0 |
| Duplicate row IDs | 0 |
| Missing required numeric values | 0 |

The 57 map instances are: 41 live `m1019_1` + 4 live `m1019_10` + 11 staging `m1019_1` + 1 staging `m1019_2`. All 57 map artifacts match their manifest `mapHash`. All direct file MD5s match the map `checksums.md5`; all `res.pack` container MD5s match as well.

### 1.4 Table row inventory per map instance

| Table | `m1019_1` (100 levels) | `m1019_10` / `m1019_2` (60 levels) |
|---|---:|---:|
| `arms.csv` | 30 | 30 |
| `equipment.csv` | 324 | 324 |
| `basement.csv` | 100 | 60 |
| `game_level.csv` | 100 | 60 |
| `monster.csv` | 20 | 32 |
| `monster_num.csv` | 2,000 (20 groups/level) | 1,920 (32 groups/level) |
| `player_level.csv` | 30 | 30 |
| `skill.csv` | 3 | 3 |

`equipment.csv` is identical on all three map variants. `player_level.csv` is identical on all three. `skill.csv` is identical on `m1019_10` and `m1019_2` but differs from `m1019_1` in effect width/height.

---

## 2. Source formats and extraction

### 2.1 Direct map CSVs

Most versions store map config tables directly in the map zip. Files are tab-separated UTF-8 with a BOM. They contain two header rows:

1. Chinese header (human-readable; ignored by the parser).
2. English field header (used as the canonical header).

`player_level.csv` has no `id` column; its first column is `level`. Some files have extra trailing blank/Chinese-note columns; these are ignored. Non-blank extra columns are recorded in `DATA_QUALITY.csv` (for example, `arms.csv` in `v10068` has three non-blank extra columns). All canonical fields are present in every table instance.

### 2.2 `res.pack` map CSVs (`m1019_1` v10109+)

From `v10109` through `v10113`, `m1019_1` stores its eight config CSVs inside `res.pack`.

- `v10109`–`v10112`: legacy container, AES-128-ECB/PKCS#7 TOC with key `blrsp20241212345`.
- `v10113`: current container, decoded with the emulated native AES path used by the archive’s extraction tooling.
- All eight entries have `flag=1` and are byte-substitution encoded. Decoding uses `howto\data\sub_table.pkl` (plain → cipher; inverse applied).
- Decoded text is UTF-8 and matches the canonical table schema.

The `res.pack` container is validated by its own `checksums.md5` entry. Decoded CSVs are validated by successful schema parsing and row-level equality with the direct-CSV versions of the same map.

### 2.3 YAML

`config.yml` and `scene1.yml`/`scene2.yml`/`scene3.yml` are always direct UTF-8 YAML. They are parsed with PyYAML. The config’s `scenes` list references **only `scene1.yml`** in every map; scene2 and scene3 are present but unreferenced.

### 2.4 Formula source

Lua formula files were checked from:

- `v10068` plaintext plugin source,
- `v10103` plaintext plugin source,
- `v10113` decrypted source,
- `v10104`–`v10108` obfuscated/encrypted source (not readable as source, but hashes/format recorded).

`GameMonster.lua`, `Match.lua`, `GameConfig.lua`, `GameLevelConfig.lua`, `ArmsConfig.lua`, and `EquipmentConfig.lua` are content-identical across readable versions after newline normalization. `GamePlayer.lua` has one cosmetic change at `v10091` (`PlayerIdentityCache:buildNameList` argument/return shape), with no combat formula change. `v10072`–`v10074` change only line endings (LF→CRLF), and `v10075` returns to LF.

---

## 3. Canonical schemas

### 3.1 `arms.csv` — weapon levels

`id, level, itemId, name, image, type, attack, range, speed, maxBullet, knockback, sniperDistance, bulletPerShoot, bulletOffset, attackX, price`

- `id` is the row ID; `level` is the weapon level (1–30).
- `attack` is the additive attack bonus applied to the player’s base attack.
- `attackX` is the damage multiplier used in the damage formula.
- `speed` is the shot cooldown in seconds (`cdTime`).
- `bulletPerShoot` is the pellet count.
- `price` is the one-time purchase price for that weapon level.

### 3.2 `equipment.csv` — armor levels

`id, part, itemId, level, name, image, description, hp, attack, defense, speed, addHp, price`

- `part` ∈ `helmet`, `plate`, `legs`, `boots`.
- Helmet uses `addHp` (regen per 10 s), plate uses `defense`, legs use `hp`, boots use `speed`.
- `attack` is **0 on every row**. Equipment cannot increase attack.
- Armor parts run level 0–100; boots run level 0–20.

### 3.3 `basement.csv` — base HP

`id, level, hp, defense`

- `defense` is 0 on every row.
- `hp` is the player’s base/tower HP for that game level.

### 3.4 `game_level.csv` — level thresholds and completion rewards

`level, kills, monsterLv, monsterNumIds, basementId, gold, exp`

- `monsterNumIds` is a `#`-separated list of `monster_num` group IDs.
- `kills` is the configured kill threshold.
- `monsterLv` is the monster scaling level passed to `GameMonster`.
- `gold`/`exp` are the per-level completion bonus (separate from monster rewards).

### 3.5 `monster.csv` — monster definitions

`id, name, actor, aiFile, isUp, hp, attack, defense, attackX, attackSpeed, attackDistance, moveSpeed, attackCd, addHp, exp, gold, isEnterHint, isBoss, isChangeTarget, changeTargetCd, isAutoAttack, patrolDistance, attackType, skillId, skillCd, effect`

- `isUp=1` means HP/attack/defense/addHp scale with `monsterLv`; `isUp=0` means they do not scale.
- `isBoss=1` marks boss definitions.
- `effect` is a `#`-separated `id#time#lv` string; derived `effect_id/effect_time/effect_lv` are in the tidy table.

### 3.6 `monster_num.csv` — spawn-group counts

`id, monsterId, num`

- One row per level/group combination.
- `num=0` groups are present but spawn nothing.
- The ID naming pattern is `1` + 2-digit level + 2-digit group + 2-digit variant (e.g. `10011011`), but analysis uses the referenced IDs, not the naming pattern.

### 3.7 `player_level.csv` — player upgrade costs

`level, exp`

- 30 rows. `exp` is the exp needed to reach the next level when the current level is `level` (used as `getUpgradeExpByLv(level+1)`).
- Levels above 30 fall back to `defaultUpgradeExp` (1,000 in every map config).

### 3.8 `skill.csv` — visual/area effects

`id, name, duration, width, height, color, density`

`m1019_1` uses width/height 10/10 for all three skills. `m1019_10`/`m1019_2` use 9/9 (skill 1), 6/6 (skill 2), and 18/18 (skill 3).

### 3.9 YAML objects

- `config.yml`: `initPos`, `scenes`, `waitingTime`, `prepareTime`, `selectMapTime`, `gamePrepareTime`, `gameLevelTime`, `gameOverTime`, `refreshMonsterTime`, `refreshMonsterTimes`, `startPlayers`, `maxMonsters`, `defaultUpgradeExp`, `growthX`, `correctionX`, `basePercentage`, `killPercentage`, `PlayerUpgradeHealthReply`, `BasementUpgradeHealthReply`, `playerAttr {hp, attack, defense, attackX, addHp, maxLv}`, `rankNpc[]`, `shop[]`, `respawn[]`.
- `shop[].goods[].price` is `[gid, gmt, gc, eid, ec1, ec2, limit]`.
- `respawn[].price` is `[coinId, blockymodsPrice, blockmanPrice]`.

### 3.10 Common columns in tidy/stat tables

- `map_id`, `channel`: `m1019_1/live`, `m1019_10/live`, `m1019_2/staging`, plus `m1019_1/staging` in tidy tables.
- `row_id`: canonical table ID (`id` or `level`), always stored as text.
- `first_version`, `last_version`, `n_versions`, `versions`: the version range in which this exact row/stat is present. `versions` is a semicolon-separated list, not a numeric span; missing versions are omitted.
- `content_hash`: SHA-256 of the canonical row JSON; used to prove dedupe/ranges.
- `BALANCE_STATS.csv` additionally has `stat_id`, `category`, `scope`, `entity_id`, `entity_name`, `metric`, `value`, `unit`, `formula`, `source_table`, `source_columns`, `notes`.
- Derived values are numbers; undefined ratios are blank, not zero.

---

## 4. Source-grounded formulas

All formulas below come from `GameMonster.lua`, `GamePlayer.lua`, `GameLevelConfig.lua`, `Match.lua`, and `GameConfig.lua`; they are not inferred from chart shapes.

### 4.1 Monster scaling

If `isUp=1`:

```
scale(monsterLv) = 1 + growthX * monsterLv ^ correctionX
effective_hp     = base_hp     * scale
effective_attack = base_attack * scale
effective_defense= base_defense* scale
effective_addHp  = base_addHp  * scale
```

If `isUp=0`, the scale is 1. `growthX=0.003` and `correctionX=1` on all maps.

### 4.2 Damage

Player → monster:

```
damage = attackX * attack^2 / (attack + monster_effective_defense)
```

Monster → player:

```
damage = monster_attackX * monster_effective_attack^2
         / (monster_effective_attack + player_defense)
```

`attack` on the player side is the total attack: base player attack + equipped weapon attack + equipment attack (equipment attack is 0).

### 4.3 Nominal DPS

Used in `WEAPON_PROGRESSION.csv` and the DPS charts:

```
A = base_attack(player level) + weapon.attack
nominal_dps(D) = weapon.attackX * A^2 / (A + D)
                 * weapon.bulletPerShoot / weapon.speed
```

- `D=0` is raw nominal DPS.
- `D=150` is the reference “vs 150 defense— line used in most charts.
- `D=372` is a late-game reference close to the hard-map weighted defense.

This is a single-target, steady-state DPS estimate. It ignores travel, reload, target switching, spawn caps, AoE, and multi-target overlap.

### 4.4 Kill threshold and level advance

```
spawned_total = sum(monster_num.num for referenced groups with num>0)
effective_kill_threshold = min(game_level.kills, spawned_total)
```

`GameLevelConfig:getMonstersByLevel` clamps `level.kills` to `spawned_total` when the configured value is larger. The match advances when `scene.kills >= effective threshold` (the code checks the configured value, which has already been clamped in memory).

### 4.5 Wave spawning

```
wave_spawn_target = spawned_total / refreshMonsterTimes
```

Every `refreshMonsterTime` seconds, `prepareMonster` attempts to distribute `levelMonsterNum / refreshMonsterTimes` spawns across the level’s groups, subject to `maxMonsters`. The target is not an exact per-wave count because distribution is randomized.

### 4.6 Rewards

Monster rewards are split by damage share:

```
exp_share  = monster.exp  * basePercentage * attacker_damage / total_damage
gold_share = monster.gold * attacker_damage / total_damage
killer_exp_bonus = monster.exp * killPercentage
```

`basePercentage=0.8` and `killPercentage=0.2` on every map. For a single player, the full monster exp/gold is received. Per-level completion rewards (`game_level.gold/exp`) are added on level advance.

### 4.7 Player level and stats

```
base_hp      = playerAttr.hp      * (1 + growthX * level^correctionX)
base_attack  = playerAttr.attack  * (1 + growthX * level^correctionX)
base_defense = playerAttr.defense * (1 + growthX * level^correctionX)
```

Player upgrade cost uses `player_level.csv` for levels 1–30 and `defaultUpgradeExp=1000` for every level above 30. `maxLv=1000` in config. The simulation starts at level 1 and adds all exp earned before the level in question.

### 4.8 Required DPS and required player level

`LEVEL_THRESHOLDS.csv` reports:

```
required_dps = total_effective_hp / gameLevelTime
```

This is an HP-only lower bound: it ignores travel, spawn time, defense, and multi-target effects.

For every weapon, the model solves

```
required_dps = attackX * A^2/(A+D) * bulletPerShoot/speed
A = (c + sqrt(c^2 + 4cD))/2,  c = required_dps*speed/(attackX*bulletPerShoot)
required_player_level = ((A - weapon.attack)/playerAttr.attack - 1)/growthX
```

and takes the minimum over all weapons. `D` is the spawn-weighted effective defense of the level. Negative results mean the weapon alone (with no player-level investment) already exceeds the required DPS; they are shown as negative in the CSV and clamped to 0 in the chart.

### 4.9 Cost metrics

- Weapon `cumulative_price` = sum of `price` from level 1 through that level.
- Equipment `cumulative_price` = sum of `price` from level 0 through that level.
- `runs_to_afford_all = (weapon_cost_to_max + equipment_cost_to_max) / total_gold_per_full_clear`.
- `gold_per_effective_hp` / `exp_per_effective_hp` use total single-player rewards / total effective HP.

---

## 5. Version history and deduplication

### 5.1 No row-level balance changes within a map

For every table and every map/channel, the row-level content is identical across every version in which the map exists. `VERSION_RANGES.csv` contains one content range per table/map/channel (plus config/scene ranges), and `VERSION_CHANGES.csv` contains no `row_modified` events.

The only version-level changes are:

| Version | Change |
|---|---|
| `v10079` | `m1019_1` staging copy first appears |
| `v10088` → `v10090` | `m1019_1` staging copy disappears |
| `v10104` | `m1019_1` staging copy reappears |
| `v10105` → `v10106` | `m1019_1` staging copy disappears |
| `v10109` | `m1019_1` config tables move from direct zip files into legacy `res.pack` |
| `v10110` | `m1019_10` (hard map) first appears |
| `v10113` | `m1019_1` switches to current `res.pack`; `m1019_2` staging appears |
| `v10091` | cosmetic `GamePlayer.lua` identity API change |
| `v10072`–`v10074` | CRLF line-ending-only change in server Lua; reverted in `v10075` |
| `v10104`–`v10108` | plugin Lua source becomes obfuscated/encrypted |

### 5.2 Dedupe and version ranges

`tidy/<table>.csv` stores one row per unique row content per map/channel, with:

- `first_version`, `last_version`, `n_versions`, `versions` (semicolon list), `content_hash`.

If a row changes, it appears in multiple ranges. Because no row changes within a map, each row has one range per map/channel.

`VERSION_RANGES.csv` does the same at whole-table level and records `same_as` when a table is byte-identical on other maps/channels (notably equipment, player level, and map1 staging).

---

## 6. Normal vs hard vs staging: data-derived facts

### 6.1 Config

| Field | `m1019_1` normal | `m1019_10` hard | `m1019_2` staging |
|---|---:|---:|---:|
| waitingTime | 60 | 30 | 30 |
| prepareTime | 60 | 30 | 30 |
| gamePrepareTime | 10 | 8 | 8 |
| gameLevelTime | 190 | 310 | 310 |
| gameOverTime | 10 | 10 | 8 |
| refreshMonsterTime | 6 | 5 | 5 |
| refreshMonsterTimes | 10 | 15 | 15 |
| maxMonsters | 30 | 33 | 30 |
| player HP | 1500 | 1500 | 1500 |
| player attack | 300 | 450 | 450 |
| player defense | 300 | 330 | 330 |
| player addHp | 0 | 10 | 10 |
| PlayerUpgradeHealthReply | 0.1 | 0.15 | 0.2 |
| BasementUpgradeHealthReply | 0.2 | 0.33 | 0.35 |
| respawn time | 180 | 310 | 310 |
| respawn prices `[coinId, blockymods, blockman]` | `[1,4,80]` | `[1,1,80]` | `[1,1,80]` |

All maps use `growthX=0.003`, `correctionX=1`, `basePercentage=0.8`, `killPercentage=0.2`, `defaultUpgradeExp=1000`, `playerAttr.maxLv=1000`.

### 6.2 Level and difficulty totals

| Metric | `m1019_1` | `m1019_10` | `m1019_2` |
|---|---:|---:|---:|
| Game levels | 100 | 60 | 60 |
| Configured kills | 8,159 | 7,986 | 7,986 |
| Spawned total | 8,112 | 7,986 | 7,986 |
| Effective kill threshold total | 8,112 | 7,986 | 7,986 |
| Total effective HP | 23,903,894.05 | 58,294,545.50 | 55,384,319.50 |
| HP per effective kill | 2,946.73 | 7,299.59 | 6,935.18 |
| Total gold (monster + level) | 3,405,820 | 6,286,293 | 6,382,893 |
| Total exp (monster + level) | 385,899 | 701,216 | 706,306 |
| Gold per kill | 417.43 | 787.16 | 799.26 |
| Exp per kill | 47.30 | 87.81 | 88.44 |
| Max level HP (level) | 940,572 (L98) | 3,598,620 (L60) | 3,149,250 (L59) |
| Final level HP | 312,800 (L100) | 3,598,620 (L60) | 2,710,620 (L60) |
| Max required DPS (level) | 4,950.38 (L98) | 11,608.45 (L60) | 10,158.87 (L59) |
| Final required DPS | 1,646.32 | 11,608.45 | 8,743.94 |
| Max basement HP | 70,000 | 138,750 | 3,700,000 |
| Final basement HP | 70,000 | 138,750 | 3,700,000 |
| Boss-gate levels | 10,20,…,100 | 10,20,…,60 | 10,20,…,60 |
| Boss spawns | 17 | 17 | 17 |
| Final boss HP | 312,800 | 2,852,700 | 1,964,700 |
| Final boss count | 4 | 6 | 6 |
| Final boss HP share | 100% | 79.27% | 72.48% |

### 6.3 Hard map / normal map ratios (`v10110`–`v10113`)

| Metric | Ratio `m1019_10 / m1019_1` |
|---|---:|
| Levels | 0.600 |
| Total kills | 0.979 |
| Total effective HP | 2.439 |
| HP per kill | 2.477 |
| Total gold | 1.846 |
| Total exp | 1.817 |
| Gold per kill | 1.886 |
| Exp per kill | 1.857 |
| Max level HP | 3.826 |
| Final level HP | 11.505 |
| Max required DPS | 2.345 |
| Final required DPS | 7.051 |
| Max/final basement HP | 1.982 |
| Final boss HP | 9.120 |
| Final boss count | 1.500 |
| Weapon 28 nominal DPS | 1.611 |
| Max weapon nominal DPS | 1.351 |
| Runs to afford all max gear | 0.542 |
| Final all-weapon DPS margin | 0.257 |
| Final required player level | negative on normal, 687.9 on hard |

### 6.4 Staging map 2 vs hard map 10 (`v10113`)

| Metric | Ratio `m1019_2 / m1019_10` |
|---|---:|
| Total effective HP | 0.950 |
| Total gold | 1.015 |
| Total exp | 1.007 |
| Final required DPS | 0.753 |
| Final boss HP | 0.689 |
| Final basement HP | 26.667 |
| Final all-weapon DPS margin | 1.311 |
| Runs to afford all max gear | 0.985 |
| Weapon 28 nominal DPS | 0.987 |

`m1019_2` has the same 60 levels and the same kills/spawned totals as `m1019_10`, but 42 of 60 levels differ in `monsterLv` and/or rewards, 20 spawns are shifted from monster 2022 to monster 1052, and the final basement is 3.7M HP. The final boss `3031` has 360,000 base HP (vs 600,000), 100,000 base attack (vs 99,999), speed 6 (vs 1), cooldown 45 (vs 60), exp 9,000 (vs 5,000), and gold 90,000 (vs 60,000).

### 6.5 Monster composition

- `m1019_1` defines 20 monsters and uses 18; monsters `1012` and `1022` have `num=0` in every spawn group.
- `m1019_10`/`m1019_2` define 32 monsters and use all 32.
- The 12 hard-only monster IDs (`1033, 1043, 1053, 1063, 1064, 1065, 2013, 2023, 2033, 2034, 2035, 3031`) account for 2,000 / 7,986 spawns (25.0%) and 20,118,588 / 58,294,545.5 effective HP (34.5%).
- Shared monster IDs have a median HP ratio of 1.111 (hard/normal) and a median attack ratio of 1.021; defense is mostly unchanged. Hard mode is therefore not a uniform stat multiplier; composition and new high-stat monsters carry much of the increase.
- Monster `1021`/`1022` have `isUp=0` in all maps, so they do not scale with `monsterLv`.
- Boss `3031` is the largest outlier: 600,000 base HP / 99,999 base attack on hard map, 2,220,000 effective HP at monsterLv 900, and 61.7% of the final level’s effective HP by itself (79.27% for all bosses).

### 6.6 Weapons

`WEAPON_PROGRESSION.csv` has 30 levels per map; the table is static per map.

- Cumulative weapon cost to level 30: **6,403,500 gold**.
- Weapon 28 is the key divergence:
  - `m1019_1`: attack 1531, attackX 0.38, speed 0.125, pellets 1, price 574,000, cumulative 5,109,500, nominal DPS (D=150, player level 1) 5,147.49.
  - `m1019_10`: attack 1531, attackX 0.18, speed 0.24, pellets 6, same price/cumulative, nominal DPS 8,293.06.
  - `m1019_2`: attack 1531, attackX 0.37, speed 0.25, pellets 3, nominal DPS 8,182.48.
- Weapon 30: attack 1800, attackX 0.36, speed 0.115, pellets 1 on all maps; price 672,000; cumulative 6,403,500.
- Map 1 also has early multi-pellet weapons at levels 4/7/10/14; hard/staging move the large pellet spike to level 28.

### 6.7 Equipment

`EQUIPMENT_PROGRESSION.csv` is shared by all maps.

- 324 rows: helmet/plate/legs 0–100 (101 each), boots 0–20 (21).
- Max stats: helmet `addHp` 1,500; plate `defense` 1,800; legs `hp` 9,000; boots `speed` 150.
- All `attack` values are 0.
- Cumulative costs to max: helmet 481,100; plate 762,340; legs 1,497,220; boots 305,500; **total 3,046,160**.
- Price spikes occur at level 1 and then every 5 levels (1, 6, 11, 16, …). Item-ID tiers change at 25/50/75 for armor and 5/10/15 for boots.
- Total max gear cost (weapons + equipment): **9,449,660 gold**.
- Full-clear gold: map1 3,405,820; map10 6,286,293; map2 6,382,893. Runs to afford all max gear: 2.77 / 1.50 / 1.48.

### 6.8 Economy

| Metric | `m1019_1` | `m1019_10` | `m1019_2` |
|---|---:|---:|---:|
| Monster gold | 3,218,350 | 6,091,533 | 6,140,133 |
| Level gold | 187,470 | 194,760 | 242,760 |
| Total gold | 3,405,820 | 6,286,293 | 6,382,893 |
| Monster exp | 369,999 | 674,236 | 669,126 |
| Level exp | 15,900 | 26,980 | 37,180 |
| Total exp | 385,899 | 701,216 | 706,306 |
| Gold per effective HP | 0.14248 | 0.10784 | 0.11525 |
| Exp per effective HP | 0.01614 | 0.01203 | 0.01275 |
| Player level after full clear | 402 | 717 | 722 |
| Player level before final level | 395 | 678 | 680 |

Level completion bonuses are a small fraction of total rewards: 5.5% of gold / 4.1% of exp on map1, 3.1% / 3.8% on map10, 3.8% / 5.3% on map2. Monster rewards dominate.

Shop (identical on all maps): six cash packages from 10,000 to 1,000,000 cash, prices from 4 to 125 blockymods or 800 to 25,000 blockman; three utility goods (gold 1 for 80/1600, exp 1 for 50/1000, speed 1 for 30/600). Cash per blockymods rises from 2,500 to 8,000; cash per blockman rises from 12.5 to 40 across the package ladder.

### 6.9 Player progression

- `player_level.csv` has 30 rows. Cumulative exp to reach level 30 is 13,540.
- Levels above 30 cost 1,000 exp each (`defaultUpgradeExp`); `maxLv` is 1,000.
- Base stats at level 1 (normal): HP 1,504.5, attack 300.9, defense 300.9. At level 1,000: HP 6,000, attack 1,200, defense 1,200.
- Hard/staging base attack/defense at level 1 are 451.35 / 330.99; at level 1,000 they are 1,800 / 1,320.
- Full-clear exp reaches player level 402 / 717 / 722. Before the final level, the simulated levels are 395 / 678 / 680.

---

## 7. Thresholds and likely balance breakpoints

### 7.1 Data-derived facts

1. **Boss gates are every 10 levels.** Boss groups with `num>0` appear at 10,20,…,100 on map1 and 10,20,…,60 on map10/map2. Each map has 17 boss spawns. Map1 uses bosses 3011/3021; map10/map2 add 3031 only on the final level.
2. **Map1 has three configured-threshold clamps.** Level 1: 40 configured vs 15 spawned (effective 15). Level 21: 75 vs 61 (effective 61). Level 25: 69 vs 61 (effective 61). All other map1 levels have `kills <= spawned`; map10/map2 have no clamps.
3. **Map1 level 98 is the HP peak, not the final level.** Level 98 has 940,572 effective HP; final level 100 has 312,800. Level 100 is 4 bosses only; level 20 is 1 boss only.
4. **Map1 single-run affordability wall at levels 91–99.** Under the model, best affordable weapon DPS / required DPS is below 1 at levels 91–99, minimum 0.771 at level 96. Weapon 28 cumulative cost 5,109,500 exceeds gold available before those levels (2.997M before L96). Final level 100 is 2.227 because it is only four bosses.
5. **Hard map 10 has single-run affordability shortfalls at levels 41, 43, 44, 46, 48, 51–56, and 60.** Minimum 0.775 at level 51. Level 56 is 0.888 with weapon 27; weapon 28 becomes affordable at level 57, where the ratio jumps to 1.223.
6. **Hard map 10 final is a near-exact DPS check.** With all weapons considered unlocked and the cumulative-exp player level, final DPS is 11,549 vs 11,608 required, ratio 0.9949. Required player level is 687.9; simulated actual level is 678.
7. **Staging map 2 final is easier than hard map 10 final but more rewarding.** Final required DPS 8,743.9 vs 11,608.5 (0.753); final DPS margin 1.3046 vs 0.9949; final boss HP 1,964,700 vs 2,852,700 (0.689); final basement 3,700,000 vs 138,750 (26.667x). Level 57–59 gold is 18,000/18,000/27,000 vs 5,000/5,000/5,000; exp is 2,000/2,000/4,000 vs 1,000/1,000/1,000.
8. **Weapon 28 is a large pellet spike.** Hard map: 6 pellets, 8,293 nominal DPS; staging: 3 pellets, 8,182; normal: 1 pellet, 5,147. The weapon’s price and cumulative cost are identical on all maps.
9. **Equipment cannot add attack.** Every equipment row has `attack=0`; the max equipment contribution is survivability/regen/speed only.
10. **Player exp table ends at 30 but levels do not.** Levels 31–1000 use 1,000 exp each. A full map10/map2 clear reaches ~717–722, so late-game player stats continue to scale linearly with level.
11. **No row-level balance changes across 41 versions.** All table/config differences are map availability, packaging, or staging variants. Map10 appears at v10110; map2 only at v10113 staging.

### 7.2 Interpretation (not raw data)

- The data are consistent with **weapon 28 being the intended late-game power gate**. Level 56 on hard/staging is the last level before weapon 28 is affordable; the final hard level is tuned to be just below the all-weapon DPS line at the simulated level. This looks like a deliberate “just clearable / co-op or prior progression— check rather than an accident.
- Map1’s difficulty peak is **not** the final boss. Levels 91–99 combine high normal-wave HP with weapon affordability constraints; the final level is a short boss gate. This is consistent with a victory-lap final level and a late-game economy wall.
- Hard mode is **not a uniform 2.4x stat inflation**. Shared monsters are close to normal (median HP 1.111x), and a set of 12 new monster IDs plus the 3031 boss supplies much of the extra effective HP. Hard mode also gives the player 1.5x base attack and longer levels.
- Hard mode’s reward rate is higher in absolute terms (1.85x gold, 1.82x exp) but lower per effective HP (gold/HP 0.108 vs 0.142; exp/HP 0.0120 vs 0.0161). It accelerates gear acquisition (1.50 vs 2.77 runs to afford all max gear) without making each HP cheaper.
- Staging map 2 reads as a **tuning/test variant**: same level count and kills as map10, lower final boss HP, much higher final basement HP, higher late-level rewards, and a lower required final DPS. Its 3.7M final basement is likely a survivability test value, not a live difficulty statement.
- The final hard-map DPS shortfall (0.995) is within model noise: a small change in player level, weapon choice, co-op damage, or target uptime flips it. It should be treated as “tight,— not “impossible.— The required level 687.9 is below the 1,000 cap, so a sufficiently leveled player can clear it under the model.

### 7.3 DPS model assumptions and caveats

The DPS/required-level model is **not** a simulation. It assumes:

- Single player, single target, steady-state fire, no travel/reload/target-switch time.
- All monsters in a level are spawned and must be damaged; no spawn-cap losses, no early level completion.
- `required_dps` is HP/time only; it ignores monster defense. The available-DPS side uses spawn-weighted defense.
- “All weapons— assumes every weapon is unlocked; “affordable— allows only weapons whose cumulative price is ≤ cumulative gold before the level, and assumes all gold is spent on weapons (no equipment spending).
- Player level is simulated from cumulative exp with `start_level=1`; persistent account level, `isExpAddition`, `isGoldAddition`, potions, and co-op are not modeled.
- Boss skills, monster attack pressure, basement survival, and terrain are not modeled.

The manifest’s `gamesetting.nummin=2` / `nummax=10` and map `startPlayers=1` are both present; co-op aggregate DPS would change the final-map conclusions.

---

## 8. Data quality, failures, and limitations

### 8.1 Validation results

- 689 extraction records; 0 extraction errors.
- All 57 map artifacts match manifest `mapHash`.
- All direct table/config/scene MD5s match `checksums.md5`; all `res.pack` container MD5s match.
- 684 data-quality rows: all `ok`; 0 duplicate row IDs; 0 missing required numeric values.
- 40 `res_pack_csv` entries decoded via substitution; no encoding fallback was needed (all UTF-8 after decode).
- `res.pack` formats: 4 legacy AES-ECB (`v10109`–`v10112`), 1 current emulated AES (`v10113`).
- CSV headers: all table instances use the English header on row 2 (1-based); Chinese row 1 is ignored.
- Extra columns: some files have trailing blank/Chinese-note columns. Non-blank extras are recorded in `DATA_QUALITY.csv`; all canonical fields are present and parsed.

### 8.2 Known anomalies / caveats

- Map1 L1/L21/L25 configured thresholds exceed spawned totals and are clamped; see `ANOMALIES.csv`.
- Map1 L98 has more effective HP than the final level 100.
- Map1 has a single-run affordability wall at L91–99; map10 at several levels including L56 and L60; map2 at selected levels between 41 and 56.
- Map10 final DPS margin is 0.995; required level 687.9 vs simulated 678.
- Map2 final basement is 3.7M vs 138,750 on map10.
- Boss 3031 has 99,999/100,000 base attack and 600k/360k base HP.
- Map1 monsters 1012/1022 are unused (`num=0`); map10/map2 use all 32 monsters.
- `scene2.yml`/`scene3.yml` are present but unreferenced; only `scene1.yml` is in `config.scenes`.
- All basement `defense` values are 0; all equipment `attack` values are 0.
- Localization **text** is not available in the downloaded artifacts; only localization keys and UI image/actor references are captured in `tidy/localization_keys.csv`.
- Terrain `.mca` files and map geometry are not analyzed.
- Version gaps are listed in §1.1; no data was fabricated for missing versions.

---

## 9. File inventory

### Root

| File | Contents |
|---|---|
| `DATA_MODEL.md` | This document |
| `BALANCE_STATS.csv` | 8,610 long-format stats: config, level summary, weapon, equipment, monster, level, economy, map comparison, breakpoints |
| `MAP_SUMMARY.csv` | One-row-per-map summary of difficulty/economy/DPS |
| `WEAPON_PROGRESSION.csv` | 30 weapon levels × 3 map variants with DPS/price/cumulative cost |
| `EQUIPMENT_PROGRESSION.csv` | 324 equipment rows with stats/price/cumulative cost |
| `MONSTER_SCALING.csv` | Monster base/effective stats for every monsterLv present per map |
| `LEVEL_THRESHOLDS.csv` | 220 game levels with thresholds, HP, rewards, DPS model |
| `ECONOMY_SUMMARY.csv`, `ECONOMY_LEVEL.csv`, `ECONOMY_SHOP.csv`, `ECONOMY_RESPAWN.csv` | Economy views |
| `MAP_COMPARISON.csv` | Normal/hard, hard/staging, normal/staging ratios |
| `BREAKPOINTS.csv` | 22 curated threshold/breakpoint rows |
| `ANOMALIES.csv` | 21 curated anomalies with severity |
| `VERSIONS.csv`, `MAP_ARTIFACTS.csv`, `EXTRACTION_MANIFEST.csv`, `DATA_QUALITY.csv`, `TABLE_HEADERS.csv`, `VERSION_RANGES.csv`, `VERSION_CHANGES.csv`, `FORMULA_VERSIONS.csv` | Provenance and validation |
| `PLAYER_LEVEL_EXP.csv`, `PLAYER_PROGRESSION.csv` | Player exp/stat model |
| `CHART_INDEX.md` | Chart index (also `CHARTS/INDEX.md`) |

### `tidy/`

| File | Contents |
|---|---|
| `arms.csv`, `equipment.csv`, `basement.csv`, `game_level.csv`, `monster.csv`, `monster_num.csv`, `player_level.csv`, `skill.csv` | Deduped rows with `map_id`, `channel`, `row_id`, version range, content hash |
| `config.csv`, `player_attr.csv`, `shop_groups.csv`, `shop_goods.csv`, `respawn.csv`, `rank_npc.csv` | YAML-derived tidy tables |
| `scenes.csv`, `scene_positions.csv` | Scene summaries and every spawn/init position |
| `localization_keys.csv` | Localization/UI keys extracted from names, descriptions, images, rank/shop metadata |

### `CHARTS/`

19 charts, each saved as PNG and SVG. See `CHART_INDEX.md` / `CHARTS/INDEX.md` for the question, source columns, and data-derived reading of every chart.

---

## 10. Reproduction notes

- The canonical data is read from the raw map zips under `games\g1019\v*\maps` and `maps-staging`, and the raw files are cached under the temp work directory during extraction.
- `res.pack` decoding uses the archive’s `emu_lib.py` path for current packs, AES-128-ECB for legacy packs, and `howto\data\sub_table.pkl` for `flag=1` entries.
- The analysis uses `C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe` with `matplotlib`, `numpy`, `PyYAML`, `pycryptodome`, `unicorn`, `capstone`, and `pyelftools` available.
- `FORMULA_VERSIONS.csv` hashes are normalized for CRLF so line-ending-only changes are not mistaken for formula changes. The v10113 row is hashed from the decrypted source (not the packed Lua), because the plugin is a `res.pack`.
- The chart-reading text is intentionally separated from the numeric CSVs: charts show the shape; the CSVs are the source of truth.




