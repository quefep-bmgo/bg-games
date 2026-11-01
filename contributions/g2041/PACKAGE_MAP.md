# Anime All Stars (`g2041`) original-package map

This map describes the pristine package at `engine2_packs/g2041/g2041.1735114999081.zip` and its extraction at `engine2_work/g2041_original`. The original ZIP SHA-256 is `530CB8826ADB4FD3605C4579D73908A99BFB45DE9E5599193DE4B630740E7E41`; it contains 2,658 files and extracts to 68,477,479 bytes.

## Package root

| Path | Role |
|---|---|
| `setting.json` | Game mode, map, plugins, UI lists, player config, progression/economy tuning. |
| `all_configs.lbc` | Compiled config table. The Engine2 loader consults this before raw CSV/JSON. |
| `checksums.md5` | MD5 entries for package files; update through the package build process. |
| `config/*.csv` | Tab-separated server/client gameplay tables; line 1 is the field header and line 2 is annotation. |
| `lang/*.lang` | Localization catalogs in 15 languages. |
| `lua/` | Shared, client, server, GUI, and plugin scripts. Many files are compiled bytecode despite the `.lua` extension. |
| `plugin/myplugin/` | Entity, boss, skill, passive, missile, buff, region, sound, and effect settings/assets. |
| `asset/` | Actor/mesh/skin/skeleton/animation/effect resources for map, player, boss, monster, and equipment visuals. |
| `resource/gui/` | GUI JSON layouts plus compiled `.binary` siblings. |
| `resource/imageset/` | Atlas metadata and texture pairs for icons/cards/UI. |
| `map/` | `map001` main world and `arena` map, scenes, configs, and object resources. |
| `modules/` | Feature modules, including subscription privileges. |
| `res_download_order.txt` | Ordered asset filename list; not a full manifest. |
| `coin.json` | Custom currency definitions; platform `gDiamonds`/`golds` are engine-owned. |
| `guide.csv` | Tutorial steps and UI events. |

## Gameplay configuration map

| Table | Main responsibility | Important joins |
|---|---|---|
| `config/attribute_level.csv` (90 rows) | Player levels, upgrade price, core stats, cumulative fight. | `level` is the progression key. The UI/server detect the cap from available rows. |
| `config/attribute.csv` (26 rows) | Attribute defaults, fight weights, max values, UI order/colors. | Drives fight computation and stat display. |
| `config/skill.csv` (105 rows) | Skill identity, class, cooldown, damage, icon, quality, engine-plugin settings. | Runtime content join uses `skillId`. |
| `config/game_skill.csv` (142 rows) | Data-driven normal-attack/combo action, effect, range, hits, sound. | Join on `skillId`. |
| `config/blessing.csv` (1,028 rows) | Card data that grants active/normal skill, passive, or property. | `realId` joins `skillId`, `passiveId`, or `propertyId` by type. |
| `config/blessing_lottery_pool.csv` (1,027 rows) | Weighted card selection. | `poolId` + `blessingId`. |
| `config/blessing_pool_group.csv` (372 rows) | Pools available to slot groups and pity weights. | `groupId` joins `blessing_slot.csv`; `poolId` joins lottery pools. |
| `config/blessing_slot.csv` (42 rows) | Free/Gold/GCube slot unlock levels, prices, pools, refresh costs. | 14 thresholds × 3 slot types. |
| `config/passive.csv` (117 rows) | Passive stat/hook definitions. | Type maps to a server passive implementation. |
| `config/property.csv` (858 rows) | Attribute-card definitions and stat/dress effects. | `propertyId`, optional `dressId`. |
| `config/equip.csv` (2,399 rows) | Equipment stats, item IDs, slot, quality, icon, sale/gold fields. | `equipId` joins chest loot. |
| `config/equip_quality.csv` (6 rows) | Quality color/frame/autosell metadata. | `equipQuality`. |
| `config/equip_chest.csv` (830 rows) | Chest definitions, currencies/prices, level, refresh, first-item fields. | `chestId` joins chest loot. |
| `config/chest_equip.csv` (31,611 rows) | Weighted equipment drops from chests. | `chestId` + `equipId`. |
| `config/game_dress.csv` (201 rows) | Visual/equipment dress groups and sockets. | `groupId` is the visual dress key, not the row ID. |
| `config/boss.csv` (7 rows) | Boss levels, recommendation, positions, rewards, base attributes. | `bossId` maps to `plugin/myplugin/entity/boss_lv*/`. |
| `config/monster.csv` (195 rows) | Map monster spawns and stats. | `fullName` maps to monster entity settings. |
| `config/reward_pool.csv` | Reward grants for boss/chest/other activities. | `poolId`, `rewardType`, `rewardId`. |
| `config/game_skill_sound.csv` (35 rows) | Numeric sound IDs to audio assets. | `soundName` is referenced by `game_skill.csv`. |

## Skill and level-up flow

1. Player upgrades via `GUIAttr` → client packet `onUpgradeLevelByMoney` → server checks `attribute_level.csv` and charges `upgradePrice`.
2. Server applies the next level and calls the level-up blessing helper.
3. The level-up banner is `lua/gui/win_upgradeLevel.lua` + `resource/gui/UpgradeLevel.json`; it is separate from card selection.
4. Server rolls via `blessing_slot.csv` → `blessing_pool_group.csv` → `blessing_lottery_pool.csv` → `blessing.csv`.
5. Client `win_chooseBlessing.lua` shows the three-card modal; selecting sends `onChooseBlessing(slotId, blessingId)`.
6. Server grants a skill/passive/property. Skills enter `Skills`/`EquippedSkills`, then appear in the skill list or one of five attack slots.
7. Data-driven skills use `skill.csv` + `game_skill.csv`; engine skills use `plugin/myplugin/skill`, `missile`, and hit settings. Client handles animation/target reporting; server handles cooldown, damage, buffs, and persistence.

`templates/skill.md` gives the complete contributor checklist and links. The original package has a complete normal-attack exemplar at `skillId=2002300` and engine-skill exemplar `1005301`.

## Items, models, and bosses

- Items: `equip.csv` carries stats and icon references; `equip_chest.csv` defines chests; `chest_equip.csv` determines weighted drops; `reward_pool.csv` grants rewards.
- Visuals are separate: `game_dress.csv.groupId` resolves to dress assets. Do not infer a model filename from `equipId`.
- Models need every referenced actor/skeleton/mesh/skin/texture/action/effect. Static collision runtime uses `.convex.editor`; never reuse another prop's collider.
- Bosses use `boss.csv`, entity settings under `plugin/myplugin/entity/boss_lv10..70`, actor assets, `gameSkills`, reward pools, map portal/spawn positions, and boss region scripts.
- `boss.csv.recommend` is the displayed recommendation, not computed fight. Boss 70's original recommendation is 430,000, while runtime attributes compute approximately 6.97M fight.

## Map and local navigation patch

`map/map001/DM2_CJ_02.scene` has hundreds of objects. Original `g2041_kongqiqiang.mesh` invisible air-wall objects (IDs 1428–1432 and 1438–1456) form the boss7 boundary, with one isolated outlier (1456). The local open-navigation variant removes those scene instances but keeps visible `weiqiang_01`, `weiqiang_02`, and `men_01` walls/gate.

Five local `.convex`/`.convex.editor` pairs were previously generated for `sharen_9_1/3/4/5/6`; they were not in the original archive and added 13 collision hulls. They are removed by the contribution overlay. The baseline game had no collision file for those props, so the open-map variant prioritizes removing invisible barriers over giving those props solid collision.

The local runtime uses Engine2 `20075`; extracted `res/engine2Version.json` says `20055`. This mismatch can affect physics interpretation. The scene-level air-wall removal is a deterministic local fix; if a barrier remains, record the player coordinates and compare against visible wall colliders before changing more geometry.

Local validation after removing the 24 air-wall instances and the 13 locally-added `sharen_9_*` hulls: server physics `conv` count changed from `7001` to `6964`. The remaining startup warning for `g2041_muxiangzi_02_02.mesh.convex.editor` is a missing collider on a small decorative prop, not a new solid barrier.

## Config bundle and deployment

`engine2_server/lua/common/lib.lua` checks per-file `.lbc`, then `all_configs.lbc`, then raw CSV/JSON. The original `all_configs.lbc` contains stale config values when only CSV/JSON is edited. The local overlay removes that stale bundle and has been verified to load the modified CSV/JSON through the fallback. The local packer `gen_config_common.exe` is a resource packaging tool, not a generator for `all_configs.lbc`.

For an authorized release, the game operator must either rebuild `all_configs.lbc` with their matching config compiler or approve raw-config fallback on the target server. Official live deployment is server-side and operator-authorized; client-side changes cannot install new authoritative skills, items, or stats on an official server.
