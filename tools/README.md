# tools/

Reference copies of the extraction, decryption, and decompilation scripts used while building
the archive. The scripts are preserved as-is and still contain the original absolute paths from
the working environment, so they are documentation/reference material rather than a standalone
toolkit.

## Extraction and decryption

| File | Purpose |
| --- | --- |
| `bmg_extract.py` | Extract and decrypt plugin bundles into `DECRYPTED/` |
| `decrypt_all.py` | Batch decryption driver for the analysis workspace |
| `decrypt_games.py` | Decrypt game payloads |
| `decrypt_pack.py` | Decrypt a single `res.pack` using its TOC and key objects |
| `decrypt_g1100.py` | Decrypt the g1100 payload |
| `decrypt_g1100_latest.py` | Decrypt the newest g1100 plugin bundle |
| `emu_lib.py` | Unicorn-based ARM64 decryption helper |
| `sub_table.pkl` | Substitution table used by the decryption helpers |

## Map conversion

| Path | Purpose |
| --- | --- |
| `mapconv/mapconv.py` | Convert legacy Blockman GO `.mca` map bundles to Minecraft Java 26.3 worlds |
| `mapconv/legacy_blocks.py` | Legacy numeric block ID + metadata to modern block-state mapping |
| `mapconv/world_template/` | Minecraft 26.3 world metadata template (no terrain) |
| `mapconv/README.md` | Usage and conversion limitations |
| `../V10113_TO_MC_26.3_AI_GUIDE.md` | Full v10113 format and GitHub-to-26.3 conversion contract |
| `mapconv/convert-map.cmd` | Windows wrapper for drag-and-drop conversion |

## Decompilation

| File | Purpose |
| --- | --- |
| `decompile_engine.py` | Decompile decrypted engine Lua bytecode with unluac |
| `decompile_games.py` | Decompile decrypted game Lua bytecode with unluac |

## Engine2 packages

| File | Purpose |
| --- | --- |
| `engine2_collect.py` | Open engine2 game detail via app deep link, tap Start, capture static ZIP URLs from the proxy log |
| `engine2_download.py` | Download and verify the engine2 ZIP corpus from `engine2_packs/catalog.tsv` |

See `../howto/17-engine2.md`.

## Runtime expectations

- Python 3 with `pyelftools`, `capstone`, and `unicorn` for the decryption helpers.
- Java plus `unluac.jar` for the decompilers.
- Companion data (`native/bg_libBlockMan_arm64.so`, TOC files, key-object JSON, and decrypted
  trees) lives in the original `g1042_analysis/` workspace and is not part of this repository.
