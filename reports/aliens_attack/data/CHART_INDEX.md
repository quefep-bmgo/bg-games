# Chart index — g1019 (Aliens Attack)

All charts are in `reports/agents/data/CHARTS/`. Each name is saved as both `.png` and `.svg`. The numeric source of truth is the listed CSV; charts are visual summaries.

**Global reading notes**

- `m1019_1` = normal map 1 (41 live versions).
- `m1019_10` = hard map 10 (v10110–v10113).
- `m1019_2` = staging map 2 (v10113 only).
- `m1019_1` staging copies are identical to live and are omitted from most charts.
- DPS/required-level charts use the single-player, single-target model documented in `DATA_MODEL.md §4` and §7.3. They are not a gameplay simulation.
- Version ranges and row hashes are in `VERSION_RANGES.csv`; extraction/validation is in `EXTRACTION_MANIFEST.csv` and `DATA_QUALITY.csv`.

---

## 01 — `01_version_map_timeline.png` / `.svg`

**Question:** Which map/channel exists in which of the 41 versions?  
**Source:** `VERSIONS.csv` (`version`, `live_maps`, `staging_maps`), `MAP_ARTIFACTS.csv`.  
**Data-derived reading:** `m1019_1` live exists in all 41 versions. `m1019_1` staging exists in 11 versions (two blocks). `m1019_10` is added at `v10110` and continues through `v10113`. `m1019_2` appears only at `v10113` staging.  
**Caveat:** The x-axis is download/version order; gaps (`v10078`, `v10081`, `v10089`, `v10092`, `v10094`) are not in the dataset.

## 02 — `02_weapon_attack_price.png` / `.svg`

**Question:** How do weapon attack bonus and purchase price progress by weapon level?  
**Source:** `tidy/arms.csv` / `WEAPON_PROGRESSION.csv` columns `level`, `attack`, `price`.  
**Data-derived reading:** Attack rises monotonically from 30 at level 1 to 1,800 at level 30 on all maps. Prices rise from 0 at level 1 to 672,000 at level 30; cumulative cost is 6,403,500. Map weapon attack/price tables are identical except hard/staging substitutions at several levels.  
**Caveat:** Price is the one-time level purchase price, not cumulative. The chart does not include weapon 28’s pellet-count effect; see chart 03.

## 03 — `03_weapon_nominal_dps.png` / `.svg`

**Question:** Which weapon levels are DPS spikes after accounting for attack, attackX, cooldown, and pellet count?  
**Source:** `WEAPON_PROGRESSION.csv` columns `attack`, `attack_x`, `speed`, `bullet_per_shoot`, `nominal_dps_def150`; `config.yml` `playerAttr.attack`, `growthX`, `correctionX`.  
**Formula:** `attackX * (base_attack + attack)^2 / ((base_attack + attack) + 150) * bulletPerShoot / speed`, at player level 1.  
**Data-derived reading:** Normal map has early multi-pellet spikes at levels 4/7/10/14 and a late spike at 28 (1 pellet). Hard/staging have the large multi-pellet spike at level 28: 6 pellets on hard (8,293 nominal DPS), 3 on staging (8,182), versus 1 on normal (5,147). Hard/staging curves sit above normal for most levels because their player base attack is 450 vs 300.  
**Caveat:** This is a nominal single-target DPS at a fixed reference defense; actual damage depends on the target’s defense and on hitting all pellets.

## 04 — `04_weapon_cost_efficiency.png` / `.svg`

**Question:** How much gold does each weapon level cost in total, and how does cumulative gold per nominal DPS change?  
**Source:** `WEAPON_PROGRESSION.csv` columns `cumulative_price`, `cumulative_price_per_dps`, `nominal_dps_def150`.  
**Data-derived reading:** Cumulative cost grows from 0 to 6,403,500 by level 30. Gold per nominal DPS falls sharply early and then flattens; weapon 28 is a strong efficiency point on hard/staging because of its pellet count.  
**Caveat:** Cumulative price assumes buying every prior level; it ignores gold spent on equipment.

## 05 — `05_equipment_stat_progression.png` / `.svg`

**Question:** How do the four equipment slots’ stats progress?  
**Source:** `EQUIPMENT_PROGRESSION.csv` / `tidy/equipment.csv` columns `part`, `level`, `addHp`, `defense`, `hp`, `speed`, `itemId`.  
**Data-derived reading:** Helmet `addHp` 0→1,500, plate `defense` 0→1,800, legs `hp` 0→9,000, boots `speed` 0→150. Armor parts run 0–100; boots 0–20. Red dots mark item-ID tier changes (25/50/75 armor; 5/10/15 boots).  
**Caveat:** Equipment `attack` is 0 on every row, so these stats do not increase DPS; they affect survivability/regen/speed.

## 06 — `06_equipment_price_tiers.png` / `.svg`

**Question:** Where are the equipment price spikes and tier changes?  
**Source:** `EQUIPMENT_PROGRESSION.csv` columns `price`, `cumulative_price`, `price_spike_ratio`, `is_price_spike`, `is_tier_change`.  
**Data-derived reading:** Every part has a large price spike at level 1 and then at levels 6, 11, 16, … (every 5 levels). Cumulative costs to max: helmet 481,100; plate 762,340; legs 1,497,220; boots 305,500; total 3,046,160.  
**Caveat:** Price spikes are a sawtooth pattern, not a continuous exponential; the log y-axis makes the small upgrade steps look flatter than they are.

## 07 — `07_monster_base_stats.png` / `.svg`

**Question:** Which monsters are HP/attack outliers, and which are bosses?  
**Source:** `tidy/monster.csv` columns `id`, `hp`, `attack`, `isBoss`; usage from `monster_num.csv` + `game_level.csv`.  
**Data-derived reading:** Boss `3031` is the extreme outlier: 600,000 HP / 99,999 attack on hard, 360,000 / 100,000 on staging. Other bosses are 3011 (45,000 HP) and 3021 (27,000 HP). Hard/staging use 32 monsters; normal uses 18 of 20 (1012/1022 have num=0).  
**Caveat:** Base stats are before the `isUp` scaling factor; effective stats at level 900 are 3.7x base.

## 08 — `08_monster_effective_hp_by_level.png` / `.svg`

**Question:** How does total effective HP per level change, and where are boss gates?  
**Source:** `LEVEL_THRESHOLDS.csv` columns `level`, `effective_hp_total`, `boss_spawns`; `MONSTER_SCALING.csv`.  
**Formula:** sum over spawned groups of `num * base_hp * (1 + growthX * monsterLv^correctionX)` where `isUp=1`.  
**Data-derived reading:** Hard/staging totals are much higher than normal from the early levels; normal peaks at level 98 (940,572), not at the final level (312,800). Hard peaks at the final level 60 (3,598,620); staging peaks at level 59 (3,149,250) and final is 2,710,620. Dots mark boss gates (every 10 levels).  
**Caveat:** This is total spawned HP, not “HP that must be killed before the timer”; effective kill thresholds can be lower when configured kills exceed spawned totals.

## 09 — `09_level_kill_thresholds.png` / `.svg`

**Question:** Do configured kill thresholds match the number of monsters actually spawned?  
**Source:** `LEVEL_THRESHOLDS.csv` columns `kills_configured`, `spawned_total`, `effective_kill_threshold`, `clamp_shortfall`.  
**Data-derived reading:** Normal map has three clamps: L1 40→15, L21 75→61, L25 69→61. Every hard/staging level has configured kills equal to spawned total. Normal thresholds range 1–153; hard/staging 21–258.  
**Caveat:** The game clamps the threshold in memory in `GameLevelConfig:getMonstersByLevel`; the CSV records both the configured and effective values.

## 10 — `10_round_time_waves.png` / `.svg`

**Question:** How do round time, wave count, max monsters, and total run-time cap compare?  
**Source:** `config.yml` (`gameLevelTime`, `gamePrepareTime`, `refreshMonsterTimes`, `maxMonsters`, `waitingTime`, `prepareTime`); level count from `game_level.csv`.  
**Data-derived reading:** Normal: 190 s/level, 10 waves, 30 max monsters; hard: 310 s, 15 waves, 33; staging: 310 s, 15 waves, 30. Total maximum caps are 20,120 s normal, 19,140 s hard, 19,140 s staging (waiting + prepare + every level’s time + prepare).  
**Caveat:** The cap ignores early completion when the kill threshold is reached before the timer.

## 11 — `11_economy_rewards.png` / `.svg`

**Question:** How do cumulative gold and exp rewards grow over a run?  
**Source:** `ECONOMY_LEVEL.csv` columns `cumulative_gold`, `cumulative_exp`, from monster rewards + per-level completion rewards.  
**Data-derived reading:** Full-clear totals: normal 3,405,820 gold / 385,899 exp; hard 6,286,293 / 701,216; staging 6,382,893 / 706,306. Hard/staging pull ahead mainly after the mid-game because their monster gold/exp per kill is ~1.86x normal.  
**Caveat:** Assumes a single player receives the full monster reward pool; multiplayer splits rewards by damage share.

## 12 — `12_boss_gates.png` / `.svg`

**Question:** How much effective boss HP sits at each boss gate?  
**Source:** `LEVEL_THRESHOLDS.csv` `boss_hp`, embedded per-boss entries; `tidy/monster.csv` `hp`, `isBoss`.  
**Data-derived reading:** Normal has 10 gates (10–100), 17 boss spawns, bosses 3011/3021, final gate 312,800 effective HP. Hard/staging have 6 gates (10–60), 17 boss spawns; hard final gate is 2,852,700 (79.27% of final level HP), staging final is 1,964,700 (72.48%). Boss 3031 appears only at the final gate.  
**Caveat:** Stacked bars can hide the 3031 outlier; logs compress the early gates. The final gate is also the only gate with 6 boss spawns on hard/staging.

## 13 — `13_basement_hp.png` / `.svg`

**Question:** How much HP does the defended basement have by level?  
**Source:** `LEVEL_THRESHOLDS.csv` `basement_hp`; `tidy/basement.csv` `id`, `level`, `hp`, `defense`.  
**Data-derived reading:** Normal 8,200→70,000; hard 9,200→138,750; staging 9,200→3,700,000 (final level 60). Staging is 26.667x hard at the final level. Every basement `defense` is 0.  
**Caveat:** Basement HP is a survival buffer, not a DPS requirement; high staging final HP makes the final level more forgiving, not harder.

## 14 — `14_dps_margin.png` / `.svg`

**Question:** Is available single-target DPS above the HP-only required DPS, and where is it below 1?  
**Source:** `LEVEL_THRESHOLDS.csv` columns `required_dps`, `available_dps_all`, `available_dps_affordable`, `dps_margin_all`, `dps_margin_affordable`, `best_weapon_affordable`, `gold_before`; `WEAPON_PROGRESSION.csv` cumulative price.  
**Data-derived reading:** Normal has shortfalls at levels 91–99 (minimum 0.771 at L96); hard at 41, 43, 44, 46, 48, 51–56, 60 (minimum 0.775 at L51); staging at 41, 46, 48, 51, 53–56 (minimum 0.812 at L53). Hard final is 0.995 with all weapons; staging final is 1.305.  
**Caveat:** “Affordable” assumes all gold is spent on weapons and only weapons with cumulative price ≤ gold-before-level are allowed. “All weapons” is an upper bound. Neither line models co-op, multi-target, travel, or equipment spending.

## 15 — `15_required_vs_actual_player_level.png` / `.svg`

**Question:** What player level does the DPS model require at each level, versus the cumulative-exp level?  
**Source:** `LEVEL_THRESHOLDS.csv` `required_player_level`, `player_level_start`; `PLAYER_LEVEL_EXP.csv`; `config.yml` `growthX`, `playerAttr.attack`, `playerAttr.maxLv`.  
**Data-derived reading:** Normal has no positive requirement (clamped at 0). Hard’s requirement rises to 687.9 at the final level, while the simulated actual level is 678; staging’s final requirement is 228.5 vs actual 680. The `maxLv=1000` line is well above both.  
**Caveat:** The required level is the minimum over all weapons and uses spawn-weighted defense. Negative requirements are shown as 0; they mean the weapon alone already exceeds required DPS. The actual level is simulated from cumulative exp starting at level 1, not an account’s saved level.

## 16 — `16_player_progression.png` / `.svg`

**Question:** How do base player stats and max equipment contributions scale?  
**Source:** `PLAYER_PROGRESSION.csv` `base_hp`, `base_attack`, `base_defense`, `player_level`; `tidy/equipment.csv` max `addHp`, `defense`, `hp`, `speed`.  
**Data-derived reading:** Base HP/attack/defense scale linearly with player level (`1+0.003*level`); at level 1,000 normal is 6,000 HP / 1,200 attack / 1,200 defense; hard/staging are 6,000 / 1,800 / 1,320. Max equipment adds 1,500 `addHp`, 1,800 defense, 9,000 HP, 150 speed; equipment attack is 0.  
**Caveat:** The chart uses the normal map’s base stats for the left panel; hard/staging attack/defense are higher at the same level. It does not model potions or temporary buffs.

## 17 — `17_shop_prices.png` / `.svg`

**Question:** How do shop package prices/conversions scale?  
**Source:** `tidy/shop_goods.csv` / `ECONOMY_SHOP.csv` `gc`, `ec1`, `ec2`, `units_per_blockymods`, `units_per_blockman`.  
**Data-derived reading:** Cash per blockymods rises from 2,500 (10k package) to 8,000 (1M package); cash per blockman rises from 12.5 to 40. The shop is identical on all three map variants. Utility goods are 1 gold for 80/1,600, 1 exp for 50/1,000, 1 speed for 30/600.  
**Caveat:** These are list prices, not observed purchase rates or player spending.

## 18 — `18_map10_vs_map1_ratios.png` / `.svg`

**Question:** Which hard-map changes are largest relative to normal?  
**Source:** `MAP_COMPARISON.csv` `pair=A1_A10`, `ratio`; `MAP_SUMMARY.csv`.  
**Data-derived reading:** Final-level HP 11.5x, final boss HP 9.12x, final required DPS 7.05x, total effective HP 2.44x, HP/kill 2.48x, total gold 1.85x, total exp 1.82x. Runs to afford all max gear falls to 0.542x, and final DPS margin falls to 0.257x. Weapon 28 nominal DPS is 1.61x.  
**Caveat:** Ratios are hard/normal; values below 1 mean the hard map is lower (levels, runs to afford all gear, final DPS margin). The final required-player-level ratio is omitted because the normal value is negative (no requirement).

## 19 — `19_map2_vs_map10_ratios.png` / `.svg`

**Question:** How does the staging variant differ from live hard mode?  
**Source:** `MAP_COMPARISON.csv` `pair=A10_A2`, `ratio`; `MAP_SUMMARY.csv`.  
**Data-derived reading:** Staging total HP 0.950x hard, gold 1.015x, exp 1.007x, final required DPS 0.753x, final boss HP 0.689x, final basement 26.667x, final DPS margin 1.311x, runs to afford all gear 0.985x, weapon 28 nominal DPS 0.987x.  
**Caveat:** Staging is not a live difficulty statement; its final basement 3.7M and reward changes look like tuning/test values. The ratio chart omits zero/undefined ratios.

---

## Chart ↔ source quick map

| Chart | Primary CSV | Key columns |
|---|---|---|
| 01 | `VERSIONS.csv`, `MAP_ARTIFACTS.csv` | `version`, `live_maps`, `staging_maps` |
| 02 | `WEAPON_PROGRESSION.csv` | `level`, `attack`, `price` |
| 03 | `WEAPON_PROGRESSION.csv` | `attack_x`, `speed`, `bullet_per_shoot`, `nominal_dps_def150` |
| 04 | `WEAPON_PROGRESSION.csv` | `cumulative_price`, `cumulative_price_per_dps` |
| 05 | `EQUIPMENT_PROGRESSION.csv` | `part`, `level`, `stat_value`, `itemId` |
| 06 | `EQUIPMENT_PROGRESSION.csv` | `price`, `cumulative_price`, `is_price_spike` |
| 07 | `tidy/monster.csv` | `id`, `hp`, `attack`, `isBoss` |
| 08 | `LEVEL_THRESHOLDS.csv` | `level`, `effective_hp_total`, `boss_spawns` |
| 09 | `LEVEL_THRESHOLDS.csv` | `kills_configured`, `spawned_total`, `effective_kill_threshold` |
| 10 | `config.yml`, `game_level.csv` | `gameLevelTime`, `refreshMonsterTimes`, `maxMonsters` |
| 11 | `ECONOMY_LEVEL.csv` | `cumulative_gold`, `cumulative_exp` |
| 12 | `LEVEL_THRESHOLDS.csv` | `boss_hp`, `boss_spawns` |
| 13 | `LEVEL_THRESHOLDS.csv` | `basement_hp` |
| 14 | `LEVEL_THRESHOLDS.csv` | `required_dps`, `available_dps_*`, `dps_margin_*` |
| 15 | `LEVEL_THRESHOLDS.csv` | `required_player_level`, `player_level_start` |
| 16 | `PLAYER_PROGRESSION.csv`, `equipment.csv` | `base_*`, max equipment stats |
| 17 | `ECONOMY_SHOP.csv` | `gc`, `ec1`, `ec2`, `units_per_*` |
| 18/19 | `MAP_COMPARISON.csv` | `pair`, `metric`, `ratio` |
