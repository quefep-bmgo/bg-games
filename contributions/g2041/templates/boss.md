# New boss contribution checklist

- [ ] Allocate a unique boss ID, entity full name, actor name, skill IDs, and reward pool; record them in `manifest.json`.
- [ ] Add the boss row to `config/boss.csv`: `bossLevel`, `recommend`, spawn/challenge positions, reward pool, and base attributes.
- [ ] Add `plugin/myplugin/entity/boss_lv<level>/setting.json` or a uniquely named boss entity setting with actor, AI, `gameSkills`, attack range, and base behavior.
- [ ] Add actor/model/animation/effect assets and boss skill, hit, missile, and sound settings.
- [ ] Add boss spawn/portal/region references and reward-pool entries.
- [ ] Validate computed runtime fight separately from `boss.csv.recommend`; recommendation is UI guidance, not actual fight stats.
- [ ] Test spawn, AI, damage, death, settlement, rewards, respawn, and collision/navigation.
- [ ] Regenerate config bundle/checksums and use the operator's authorized server release pipeline for live deployment.
