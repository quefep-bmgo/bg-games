# Aliens Attack (`g1019`) analysis

Complete local analysis of Blockman GO g1019 / Aliens Attack / CreepyAliens.

## Reports

| File | Description |
| --- | --- |
| `hard_mode/REPORT.md` | Full hard-mode identification, map-10 thresholds, boss gates, manifest timeline, and negative search for an unlock |
| `hard_mode/map10_levels.csv` | All 60 hard-map levels with kills, cumulative kills, monster level, rewards and bosses |
| `hard_mode/map1_levels.csv` | All 100 normal-map levels |
| `hard_mode/map_characteristics.json` | Parsed map/config/level data used by the report |
| `features/FEATURE_TIMELINE.md` | Version-by-version content and feature timeline |
| `features/FEATURE_MATRIX.csv` | 85 verified feature/bug/gap rows with first version and evidence |
| `features/HIDDEN_FEATURES.md` | GM/debug surface, dormant plugins, dead scenes, unused content, validation gaps |
| `features/CHANGES.tsv` | Path-level changes across all 41 available revisions |
| `features/SOURCE_COVERAGE.md` | Readability and extraction coverage by revision |
| `data/DATA_MODEL.md` | Data schemas, formulas, assumptions and limits |
| `data/CHART_INDEX.md` | Index and explanation of all balance charts |
| `data/BALANCE_STATS.csv` | 8,610 long-format balance statistics |
| `data/WEAPON_PROGRESSION.csv` | Normal/hard/staging weapon table with calculated DPS |
| `data/LEVEL_THRESHOLDS.csv` | Per-level HP, required DPS, player-level model, rewards and boss data |
| `data/MAP_SUMMARY.csv` | Normal/hard/staging aggregate comparison |
| `data/MAP_COMPARISON.csv` | Normal-to-hard and hard-to-staging ratios |
| `data/CHARTS/` | 19 balance charts, PNG and SVG |
| `extraction/REPORT.md` | Full extraction status and validation |
| `extraction/UNRESOLVED.md` | Remaining v10105 per-file codebook entries |
| `extraction/verification.json` | Independent verifier output |
| `extraction/validation.json` | Extraction validation output |
| `extraction/ALL_VERSIONS_MANIFEST.json` | Per-version file/hash manifest |
| `extraction/COVERAGE.md` | Coverage by version |
| `hidden/HIDDEN_AND_METADATA.md` | App/server/source archive metadata audit |
| `hidden/evidence.json` | Claim-level evidence for the metadata audit |
| `v10113_weapons/` | Latest-version gun CSVs, source configs, and five chart pairs |
| `COOL_IMPORTANT_AND_SECRET_THINGS.md` | Plain-English cool/important/hidden facts |

## Bottom line

- Hard mode is the separate `m1019_10` map, not a mid-match mode switch.
- It first appears live in revision 10110 and is unchanged through 10113.
- It has 60 levels, 7,986 kills, 32 monsters, 3 bosses and 33 max monsters.
- Boss gates are levels 10/20/30/40/50/60; cumulative kills 496/1,311/2,337/3,847/5,698/7,986.
- No player-level, kill-count or wave-count unlock exists in the game package; the map is chosen by the host/dispatcher.
- The 687.9 number in the data model is a solo, single-target, all-weapons estimate of the in-match level needed for the final hard wave. It is not an account requirement or unlock.
- Normal-mode gameplay data is unchanged across all 41 available revisions.
- `m1019_2` is a v10113 staging-only hard-map rebalance, not live.

## Full source

Extracted source trees are local-only because of size. The extraction manifest and reports record what was produced and validated. Latest v10113 source and older readable versions remain under the local working tree.
