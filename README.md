# Blockman GO game resource archive

Private research archive of Blockman GO game resources and live configuration metadata.

This repository contains **72 games**, **2,367 version snapshots**, and **77 live game configs**.
Game assets are stored byte-for-byte as downloaded; no ZIP was recompressed or modified.

## Statistics

| Item | Value |
| --- | --- |
| Games | 72 |
| Version snapshots | 2,367 |
| Resource files | 12,927 |
| Checked-out size | 20.49 GiB (21,997,069,570 bytes) |
| Unique content in Git | about 11.44 GiB (7,781 unique blobs) |
| Live game configs | 77 |
| Largest single file | 73.9 MiB |

Git stores identical files only once. Many map and plugin ZIPs repeat across versions, so a
fresh clone is roughly 11.4 GiB even though the checked-out tree is 20.49 GiB.

## Repository layout

```text
games/
  README.md                     Layout and field reference
  INDEX.md                      Per-version index for every game
  MANIFEST.csv                  Machine-readable version manifest
  g1001/
    README.md                   Version table for this game
    game-resource-config.json   Raw CDN manifest for the game
    v10068/
      version.json              Download metadata (size, file count, plugin hash)
      config-files.json         Per-asset URLs and MD5 hashes
      plugin.zip                Game plugin bundle
      maps/
        m1001_1.zip             Map bundle
        ...
game_configs/
  README.md
  g1001.json                    Live game-resource-config keyed by version
  ...
reports/
  README.md                     Index of analysis reports
tools/
  README.md                     Index of extraction/decryption scripts
```

Each version directory is named after its engine version (`v<version>`). Not every version
ships a plugin, maps, or staging files; the per-game README and `games/MANIFEST.csv` record
what is present.

## Game index

- Human-readable: [games/INDEX.md](games/INDEX.md)
- Machine-readable: [games/MANIFEST.csv](games/MANIFEST.csv)
- Per-game version tables: open `games/<game>/README.md`

## Analysis and guides

- [`howto/`](howto/README.md) - container/TOC, payload cipher, keyfiles, wrappers, CSV/maps,
  validation, download API, legacy `sandboxol` decryption, and map conversion.
- [`howto/15-bg-map-to-minecraft.md`](howto/15-bg-map-to-minecraft.md) - convert Blockman GO
  map ZIPs to Minecraft Java 26.3 worlds.
- [`reports/aliens_attack/`](reports/aliens_attack/README.md) - complete g1019 Aliens Attack
  hard-mode, feature, balance, extraction, and hidden-content analysis.
- [`tools/mapconv/`](tools/mapconv/README.md) - map conversion implementation.

## Engine2 packages

Engine2 games use a separate plain-ZIP package/runtime workflow rather than engine1's encrypted `res.pack` path. See [`engine2/README.md`](engine2/README.md) for app-flow capture, version/hash checks, local staging, older-runtime setup, and debugging.

## Provenance

- Game assets were downloaded from the public Blockman GO CDN endpoints recorded in each
  version's `config-files.json` and in `games/<game>/game-resource-config.json`.
- `game_configs/` contains live responses from the game resource configuration endpoint,
  keyed by game ID and version.
- `reports/` documents extraction coverage, identifiers, live infrastructure, and routes.
- `tools/` contains reference copies of the extraction and decryption scripts used while
  assembling the archive.

## Local-only material

The following are intentionally not committed:

- the original 3.6 GB source archive;
- `DECRYPTED/`, `_capture/`, and `g1042_analysis/`;
- `_scan_data/`, which contains credential material.

Root-level copies of the report files are ignored in favour of the organized `reports/`
directory. The originals remain on the local workstation.
