# Aliens Attack v10113 — weapon charts and tables

Folder: `C:\Users\quefep\Desktop\Decomp Temp\aliens_attack\v10113\charts`

This folder is a self-contained breakdown of every gun in the latest version, with source data, calculated damage, cost, and charts.

## What the folders contain

```text
v10113\charts\
  guns_normal.csv                 30 normal-map weapons
  guns_hard.csv                   30 hard-map weapons
  guns_staging.csv                30 not-yet-live staging-map weapons
  guns_all_latest.csv             all maps + player levels 1/100/250/500/750/1000
  guns_by_player_level_latest.csv same data, filtered to the six player levels
  guns_summary_latest.csv         one-row summary for each map
  chart_definitions.json          formulas and assumptions
  source\                         original v10113 arms.csv and config.yml files
  charts\                         5 chart pairs in PNG and SVG
  README.md                       this file
```

Charts:

- `01_damage_per_shot_by_weapon_level`
- `02_dps_by_weapon_level`
- `03_cumulative_cost_vs_dps`
- `04_price_vs_damage_per_shot`
- `05_endgame_dps_by_weapon_level`

Each chart is saved as both `.png` and `.svg`.

## Important: what “damage per shot” means here

The game stores a weapon’s **attack bonus**, not a fixed “damage” number. The real hit uses:

```text
damage per pellet = attack multiplier × total attack² ÷ (total attack + monster defense)
damage per shot   = damage per pellet × pellets per shot
DPS               = damage per shot ÷ cooldown
total attack      = player base attack + weapon attack bonus
```

Therefore the CSV gives three values:

- `damage_per_pellet_def0` — one pellet against 0 defense
- `damage_per_shot_def0` — all pellets against 0 defense
- `dps_def0` — all pellets per second against 0 defense

The same three are repeated for **150 defense** and **372 defense**, which are common reference points used in the analysis.

“Player level 1” in these tables means **level 1 in that match**, not the player’s Blockman GO account level. The player’s in-match attack grows during a run.

Base attack used at match level 1:

- normal map: **300.9**
- hard map: **451.35**
- staging map: **451.35**

At player level 1000:

- normal map: **1200**
- hard/staging map: **1800**

## Quick findings

| Metric | Normal | Hard | Staging |
|---|---:|---:|---:|
| Weapons | 30 | 30 | 30 |
| Total gold to buy every weapon | 6,403,500 | 6,403,500 | 6,403,500 |
| Max damage per shot at level 1, 0 defense | 14,967.48 (weapon 26) | 15,269.83 (weapon 25) | 15,269.83 (weapon 25) |
| Max DPS at level 1, 0 defense | 6,576.73 (weapon 30) | 8,920.58 (weapon 28) | 8,801.63 (weapon 28) |
| Best early price-per-DPS | weapon 2 | weapon 2 | weapon 2 |

The big hard-map spike is **weapon level 28**:

- normal: attack multiplier 0.38, cooldown 0.125 s, **1 pellet**
- hard: attack multiplier 0.18, cooldown 0.24 s, **6 pellets**
- staging: attack multiplier 0.37, cooldown 0.25 s, **3 pellets**

That is why hard map level 28 is a huge jump, despite the lower attack multiplier.

## About “required player level 687.9”

That number is **not** an account-level requirement and it is **not** a hard-mode unlock.

It comes from a separate single-player, single-target math model:

- hard map, final level 60
- total monster HP: 3,598,620
- time available: 310 seconds
- required sustained DPS: 11,608.45
- best weapon/player-level combination needed to reach that DPS: about **level 687.9**
- simulated player level after earning the run’s total EXP before the final level: **678**

So the model says a **solo player who never misses, fights one target at a time, and has all weapons** would need roughly level 688 in that run to meet the final-level HP check. The normal simulated run reaches 678, giving a DPS margin of **0.995** — very close, slightly below.

This is not a game rule. In real play:

- other players can help
- armor and movement help
- you do not have to kill every monster instantly
- travel time, spawn caps, and missed pellets are not in the model
- the game itself never checks “level 687” before letting you play hard mode

**No player needs to be account level 687, and no player needs to reach level 687 to enter hard mode.** Hard mode is a separate map chosen outside the game plugin.

## Column guide

Key columns in `guns_*.csv`:

| Column | Meaning |
|---|---|
| `weapon_level` | Weapon tier, 1–30 |
| `item_id` | In-game item ID |
| `name_key` | Localization key |
| `display_name_hint_cn` | Chinese name hint from the source table |
| `type_id` | Raw game weapon-type number |
| `attack_bonus` | Attack added to player base |
| `attack_x` | Damage multiplier |
| `range` | Weapon range |
| `cooldown_s` | Seconds between shots |
| `shots_per_second` | 1 ÷ cooldown |
| `bullet_per_shoot` | Pellets per trigger pull |
| `price` | One-time price for that tier |
| `cumulative_price` | Total spent from tier 1 through this tier |
| `damage_per_shot_def*` | All pellets, before/after monster defense |
| `dps_def*` | Sustained damage per second |
| `price_per_dps_def0` | Price ÷ DPS (lower is better value) |
| `player_level` | In-match player level used for the calculation |

## Source and checks

The `source\` folder contains the exact v10113 `arms.csv` and `config.yml` files used. Values were cross-checked against the independent data extraction:

- `aliens_attack\decrypted\all_versions\v10113`
- `aliens_attack\reports\agents\data\WEAPON_PROGRESSION.csv`
- `aliens_attack\reports\agents\data\DATA_MODEL.md`

Everything in this folder is derived from local files. No game or GitHub file was modified.
