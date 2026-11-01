# Contributing content to `g2041`

## Ground rules

1. Keep `engine2_packs/g2041/g2041.1735114999081.zip` and `engine2_work/g2041_original` immutable.
2. Apply changes to a disposable extracted package or through `scripts/apply_local_overlay.ps1`.
3. Add content with new IDs and names; do not renumber original IDs or replace an existing asset in place unless the patch explicitly intends that.
4. Keep gameplay decisions server-side. A client-only image, GUI, or animation does not grant a skill, item, damage result, or level.
5. Use the original tab-separated config headers and keep the descriptive second row. These `.csv` files are tab-delimited.
6. Use `templates/` for a contribution checklist and record every new ID/path in `manifest.json`.

## Models and appearances

Start with `templates/model.md`. Typical locations:

- Entity actors: `asset/Necessary/actor/`
- Models/textures: `asset/Necessary/mesh/`, `asset/Necessary/Dress up/`
- Animations: `asset/Necessary/anim/`
- Effects: `asset/Necessary/effect/`
- Entity config: `plugin/myplugin/entity/<entity-id>/setting.json`
- Dress mapping: `config/game_dress.csv`

For a player/entity model, check the actor's subactors, skeleton, sockets, default body parts, and every referenced mesh/skin/texture. A missing asset can yield a headless or partially invisible model even when the actor file itself loads.

## Skills: full level-up-to-damage loop

Start with `templates/skill.md`. The common card path is:

```text
config/attribute_level.csv
  -> level-up server handler
  -> blessing slot/pool roll
  -> config/blessing.csv
  -> config/blessing_lottery_pool.csv
  -> config/blessing_pool_group.csv
  -> client ChooseBlessing / Blessing card UI
  -> server grants skill/passive/property
  -> skill appears in Role/Skill UI and/or one of 5 attack slots
  -> client plays cast/action/effect and reports hit targets
  -> server validates skill/cooldown and applies damage/buffs
```

Relevant runtime tables:

- `config/skill.csv`: `skillId`, class, cooldown, icons, damage attributes, class, engine-plugin paths.
- `config/game_skill.csv`: data-driven attack animation, projectile/effect, range, hit count, sound, and combo data. Join on `skillId`.
- `config/blessing.csv`: card ID/type/`realId`; types 1/2 are active/normal skills, 3 passive, 4 property.
- `config/blessing_lottery_pool.csv`, `config/blessing_pool_group.csv`, `config/blessing_slot.csv`: how cards can be rolled and at which levels/slot types.
- `config/game_skill_sound.csv`: sound ID to sound asset.
- `config/game_dress.csv`: visual group mapping; `skill.csv.dressId` refers to `groupId`, not the row `id`.

Both a non-interactive level-up banner (`UpgradeLevel`) and the three-card Blessing selection screen (`ChooseBlessing`) exist. The level-up banner is not the card-selection screen. GUI JSON edits require matching `.binary` output from the Engine2 UI compiler.

For server-authoritative attacks, supply matching data to client and server. Data-driven `AttackSkill` can reuse the built-in server damage class; custom skill classes or passive types require explicit server registration. Preserve the original protocol and never rely on client-reported damage values.

## Items and stats

Start with `templates/item.md`. The primary joins are:

```text
config/equip.csv.equipId
  -> config/chest_equip.csv.equipId + chestId
  -> config/equip_chest.csv.chestId
  -> config/reward_pool.csv for reward grants

config/equip.csv.equipImage
  -> resource/imageset/g2041_equip_*.json/.png

config/game_dress.csv.groupId
  -> actor/model dress assets and sockets

config/property.csv.propertyId / dressId
  -> blessing type 4 card / optional visual group
```

`equipId` is not a model filename. Stats and equip icons come from `equip.csv`; 3D appearance is a separate `game_dress.csv`/asset mapping. Maintain unique IDs across all linked tables.

## Bosses

Start with `templates/boss.md`. A listed boss uses `config/boss.csv` for level, recommendation, position, rewards, and base attributes; `plugin/myplugin/entity/boss_lv*/setting.json` supplies the actor, AI, attack range, and `gameSkills`; each skill has its own skill/missile/hit/effect assets. `recommend` is a UI recommendation, not the boss's actual computed fight value.

## Level cap and progression

Player level is data-driven through `config/attribute_level.csv`; the original table ends at 90. Extending the table is not the same as extending gear or chest progression. If high-level gear is desired, add the corresponding equipment/chest/loot rows as well. This overlay extends to level 150 with a documented starter curve; review and rebalance it before an authorized release.

## Generated artifacts and packaging

- Keep all new files inside the original package-root layout.
- Update `checksums.md5` for changed files; add hashes for new files.
- Preserve ZIP member paths with `/` and avoid an extra top-level directory.
- `all_configs.lbc` and GUI `.binary` files are generated artifacts. This overlay removes the stale `all_configs.lbc` to use the Engine2 raw CSV/JSON fallback; if the target release requires a compiled bundle, regenerate it from the final data with the operator's matching compiler. Regenerate GUI `.binary` files if GUI JSON is changed; do not hand-edit binary output.
- `res_download_order.txt` is not a full manifest. Add new downloadable assets only if the target packer/runtime requires them.
- Run the overlay validator, start both local server and client, verify no missing assets/config rows, and test the skill/item/boss from server-authoritative handlers.

## Live deployment

Local server/client package compatibility does not grant access to official live servers. A live deployment requires approval and server-side publishing by the game operator. Do not attempt to inject these files into an official client session or bypass server validation.
