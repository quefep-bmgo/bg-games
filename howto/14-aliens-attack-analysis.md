# 14 — Aliens Attack (`g1019`) analysis index

This is the index for the complete g1019 / Aliens Attack / CreepyAliens analysis.

## What is included

- 41 available resource revisions: `v10068`–`v10113`
- five missing revisions in the capture: `v10078`, `v10081`, `v10089`, `v10092`, `v10094`
- full source extraction for every readable revision
- hard-mode map analysis
- feature and hidden-content audit
- balance, economy, weapon, monster, and level data
- v10113 gun charts and CSVs

## The main finding: “hard mode” is `m1019_10`

Hard mode is a **separate map**, not a difficulty switch or a wave transition.

- first live in revision **10110**
- unchanged through **10113**
- 60 levels
- 7,986 required kills
- 32 monsters, 3 bosses
- 33 monsters on screen at once
- 310 seconds per level
- 15 spawn batches per level
- 30-second wait / 30-second prepare
- different terrain

Normal `m1019_1` has 100 levels, 30 max monsters, 190 seconds per level, 10 spawn batches, and 60-second wait/prepare.

There is **no player-level, kill-count, wave-count, or unlock threshold** for `m1019_10` in the game package. Map selection happens outside the plugin, in the host/dispatcher. Claims such as “hard mode unlocks at level 60/100” are unsupported by the archived artifacts.

## Hard-mode thresholds

Boss gates:

| Level | Kills that level | Cumulative kills | Bosses |
|---:|---:|---:|---|
| 10 | 21 | 496 | 3011 |
| 20 | 31 | 1,311 | 3021 |
| 30 | 41 | 2,337 | 3011 + 3021 |
| 40 | 51 | 3,847 | 3011 ×2 + 3021 |
| 50 | 60 | 5,698 | 3011 ×2 + 3021 ×2 |
| 60 | 258 | 7,986 | 3031 + 3011 ×2 + 3021 ×3 |

Final boss `3031`:

- 600,000 HP
- 99,999 attack
- 60,000 gold / 5,000 EXP
- final level also contains 252 × `1065` fodder

## Staging map

`m1019_2` appears only under `mapsStaging` in v10113. It is not live. It uses the same terrain as `m1019_10` but rebalances:

- final basement: 3,700,000 HP
- final boss: 360,000 HP / 100,000 attack / faster cycle
- higher late-level rewards
- same 60 levels / 7,986 kills

## Important numbers

| Metric | Normal | Hard |
|---|---:|---:|
| Levels | 100 | 60 |
| Effective kills | 8,112 | 7,986 |
| Total effective HP | 23,903,894 | 58,294,546 |
| Total gold | 3,405,820 | 6,286,293 |
| Total EXP | 385,899 | 701,216 |
| Final-level HP | 312,800 | 3,598,620 |
| Final boss HP | 312,800 | 2,852,700 |
| Final basement HP | 70,000 | 138,750 |
| Max monsters | 30 | 33 |

Hard vs normal ratios:

- effective HP: 2.44×
- gold: 1.85×
- EXP: 1.82×
- final-level HP: 11.5×
- final boss HP: 9.12×

## The 687.9 number

The data model says the final hard wave would require about **in-match player level 687.9** for a solo player who never misses, fights one target at a time, and has all weapons. The simulated level after the run’s EXP is **678**, giving a DPS margin of **0.995**.

This is not an account-level requirement and not a hard-mode unlock. Co-op, armor, positioning, multi-target shots, and not needing instant kills all change the outcome.

## Defects and oddities

- Normal waves 1/21/25 silently clamp kill requirements from 40/75/69 to 15/61/61.
- v10113 weekly rank keys expire daily; the level daily key has no date suffix.
- Hard weapon model/item IDs shift by one level from gun level 14.
- `scene2.yml` and `scene3.yml` exist in every map but are never loaded.
- Normal monster `1022` is defined but never spawned in normal waves.
- `player_level.csv` has 30 levels; every level above 30 costs a flat 1,000 EXP.
- Most shipped plugin folders are dormant; live/forced plugins are `pay_activity`, `data_report`, `new_vip`, and `red_dot` through pay_activity.
- The shipped paid events expired in 2023.

## Where the detailed data is

Under `reports/aliens_attack/`:

- `hard_mode/REPORT.md`, `evidence.json`, `map10_levels.csv`, `map1_levels.csv`, `map_characteristics.json`
- `features/FEATURE_TIMELINE.md`, `FEATURE_MATRIX.csv`, `HIDDEN_FEATURES.md`, `CHANGES.tsv`, `SOURCE_COVERAGE.md`
- `data/DATA_MODEL.md`, `CHART_INDEX.md`, `BALANCE_STATS.csv`, `WEAPON_PROGRESSION.csv`, `LEVEL_THRESHOLDS.csv`, `MAP_SUMMARY.csv`, `MAP_COMPARISON.csv`, `CHARTS/`
- `extraction/REPORT.md`, `UNRESOLVED.md`, `verification.json`, `ALL_VERSIONS_MANIFEST.json`, `COVERAGE.md`
- `hidden/HIDDEN_AND_METADATA.md`, `evidence.json`
- `v10113_weapons/` — gun CSVs, source configs, and five chart pairs
- `COOL_IMPORTANT_AND_SECRET_THINGS.md` — plain-English version

The full decrypted source trees are local-only and are not committed because of size. The extraction reports and manifests record exactly what was produced and validated.
