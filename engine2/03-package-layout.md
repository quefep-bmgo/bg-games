# 03 — Engine2 package layout and data precedence

Engine2 game resources are plain ZIP packages, not the engine1 encrypted `res.pack` format. Extract the ZIP so the package files are at the root, without an extra enclosing folder:

```text
all_configs.lbc
setting.json
config/
lang/
lua/
plugin/
asset/
resource/
map/
modules/
assert/
checksums.md5
res_download_order.txt
```

Some games are map-only/editor-file packages and will not contain every directory above.

## Important files

| Path | Purpose |
|---|---|
| `setting.json` | Game/map defaults, enabled plugins, UI list, progression/economy values. |
| `config/*.csv` | Gameplay tables (tab-separated in the inspected g2041 package). |
| `lua/script_common/` | Shared configs/helpers/packet definitions. |
| `lua/script_client/` | Client UI and presentation handlers. |
| `lua/script_server/` | Server-authoritative gameplay handlers. |
| `lua/plugins/` and `plugin/myplugin/` | Built-in plugin scripts and game-specific entity/skill/missile/buff settings. |
| `asset/` | Actors, models, skins, animations, effects, and textures. |
| `resource/gui/*.json` | Readable UI layouts; most have compiled `.binary` siblings. |
| `resource/imageset/*.json/.png` | Atlas metadata and textures. |
| `map/` | Scene, terrain, map settings, and placed objects. |
| `checksums.md5` | File integrity manifest used by tooling/package workflows. |
| `all_configs.lbc` | Optional compiled config table; can override source files. |

## Config lookup precedence

In the inspected Engine2 runtime (`lua/common/lib.lua`):

1. A per-CSV `<filename>.lbc`, if present.
2. A matching path in `all_configs.lbc`, if the bundle loads.
3. The raw CSV through the Engine2 CSV reader.

JSON reads similarly consult the compiled config table before raw JSON. Therefore, editing CSV/JSON while retaining a stale `all_configs.lbc` can leave the running game on old values. Either regenerate the bundle with the matching compiler or remove the stale bundle only when the target runtime's raw-file fallback is verified. The local older Engine2 instance in this archive was verified using raw fallback.

## Generated output and integrity

- Do not hand-edit `all_configs.lbc` or GUI `.binary` files.
- Rebuild compiled outputs with the matching Engine2 toolchain if the target deployment requires them.
- Update `checksums.md5` for changed files through the package build workflow.
- Keep ZIP entry names forward-slash separated and validate the root contains `setting.json`.
- `res_download_order.txt` is not a complete inventory; add new assets only when the target packer/runtime requires it.
