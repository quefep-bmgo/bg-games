# New skill contribution checklist

Record the assigned IDs and paths in `manifest.json` before implementation.

## Identity and card

- [ ] Allocate unique `skillId`, `skill.csv.id`, `game_skill.csv.id`, and `blessingId`.
- [ ] Add `config/skill.csv` row. `skillId` is the runtime join key; `id` is the row/editor ID.
- [ ] Add `config/blessing.csv` row. Type 1 = active skill; type 2 = normal attack. Set `realId` to the skill ID.
- [ ] Add the card to `config/blessing_lottery_pool.csv`, and ensure the pool is linked from `config/blessing_pool_group.csv`.
- [ ] Confirm the intended level/slot group in `config/blessing_slot.csv`.
- [ ] Add `skill_name_<id>` and `skill_desc_<id>` to all 15 `lang/*.lang` files.

## Mechanics

- [ ] Choose `AttackSkill`, `BaseSkill`, or an existing engine skill pipeline.
- [ ] For a data-driven normal attack, add a matching `config/game_skill.csv` row with the same `skillId`.
- [ ] Define cooldown, damage attributes, range, hit type/target, hit count, buffs, combo behavior, and interrupt policy.
- [ ] For an engine skill, add the `plugin/myplugin/skill/<id>/setting.json`, hit config, and missile config; point `engineSkill` and `engineDmgSkill` at those names.
- [ ] Keep hit validation and damage server-authoritative; do not trust client-reported damage.

## Presentation

- [ ] Add or reuse a skill icon in `resource/imageset/g2041_skill_icon.json/.png` (or the normal-attack atlas).
- [ ] Add cast/idle animations, effects, sounds, and any weapon/dress model under the package asset tree.
- [ ] Add the sound ID to `config/game_skill_sound.csv` when using the data-driven sound table.
- [ ] Reuse existing quality frames unless a new quality is explicitly designed.
- [ ] Add new asset paths to the package manifest and download order if required by the deployment packer.

## Validation

- [ ] Verify all IDs are unique across linked tables.
- [ ] Verify every referenced icon, actor, mesh, animation, effect, missile, sound, and localization key exists.
- [ ] Verify blessing acquisition, skill inventory, equip/replace UI, skill bar, cooldown, hit, damage, and server logs.
- [ ] Regenerate `all_configs.lbc`, GUI binaries if changed, and checksums with the matching Engine2 toolchain before operator deployment.
