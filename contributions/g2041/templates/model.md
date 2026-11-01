# New model/appearance contribution checklist

- [ ] Assign a unique model/entity/dress name and record every referenced file in `manifest.json`.
- [ ] Place actor templates under `asset/Necessary/actor/`; inspect every `<SubActor>`, `<BodyPart>`, socket, skeleton, skin, texture, effect, and animation reference.
- [ ] Place static mesh resources under the appropriate `asset/Necessary/mesh/` or `asset/Necessary/Dress up/` subtree.
- [ ] For a skinned model, include the `.actor`, `.skel`, `.skin`, textures, and action animations needed by the skeleton.
- [ ] For dress/equipment visuals, add a `config/game_dress.csv` row; use `groupId` as the runtime dress key.
- [ ] For entity models, add `plugin/myplugin/entity/<entity-id>/setting.json` and link it from the game/map/spawn config.
- [ ] Check collisions separately: runtime static-mesh collision uses `.convex.editor`; never copy an unrelated collider as a shortcut.
- [ ] Verify both first-person and third-person/character-preview rendering and inspect logs for missing resources.
- [ ] Update checksums and package download metadata through the matching Engine2 packaging pipeline.
