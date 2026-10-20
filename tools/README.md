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

## Decompilation

| File | Purpose |
| --- | --- |
| `decompile_engine.py` | Decompile decrypted engine Lua bytecode with unluac |
| `decompile_games.py` | Decompile decrypted game Lua bytecode with unluac |

## Runtime expectations

- Python 3 with `pyelftools`, `capstone`, and `unicorn` for the decryption helpers.
- Java plus `unluac.jar` for the decompilers.
- Companion data (`native/bg_libBlockMan_arm64.so`, TOC files, key-object JSON, and decrypted
  trees) lives in the original `g1042_analysis/` workspace and is not part of this repository.
