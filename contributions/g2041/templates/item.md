# New item contribution checklist

- [ ] Allocate unique `equipId` and row ID; record them in `manifest.json`.
- [ ] Add the stat row to `config/equip.csv`: level, quality, type/slot, name key, icon reference, sale/gold values, and all stat/range columns.
- [ ] Add localization keys for the item name and any description.
- [ ] Add or reuse the icon in the correct `resource/imageset/g2041_equip_*.json/.png` atlas.
- [ ] If the item has a 3D appearance, add a `config/game_dress.csv` mapping with a unique `groupId`, socket, dress name, and required actor/mesh/skin/texture assets.
- [ ] If obtained from a chest, add a `config/chest_equip.csv` row with chest ID, equip ID, and weight; ensure the chest is defined in `config/equip_chest.csv`.
- [ ] If granted by a reward pool, add the appropriate `config/reward_pool.csv` row.
- [ ] If it is a blessing/property card, add a `config/property.csv` row and a type-4 `config/blessing.csv` entry plus pool links.
- [ ] Test server-side ownership, equip/unequip, stat updates, sale, chest/reward acquisition, and UI icons.
- [ ] Regenerate `all_configs.lbc` and checksums with the matching Engine2 tools for operator deployment.
