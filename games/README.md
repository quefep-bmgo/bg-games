# games/

Downloaded game resources, organized by game ID and engine version.

- **72 games**
- **2,367 version directories**
- **12,927 resource files**
- **20.49 GiB** checked out

## Indexes

- [INDEX.md](INDEX.md) - per-version table for every game (files, size, maps, staging)
- [MANIFEST.csv](MANIFEST.csv) - machine-readable manifest with one row per version
- Every `gXXXX/README.md` - per-game summary and version table

## Layout

```text
gXXXX/
  README.md                   Generated summary for the game
  game-resource-config.json   Raw game-resource-config payload
  v<version>/                 One directory per engine version
    version.json              fileSize, fileCount, pluginHash, staging flags
    config-files.json         Asset URLs, names, and MD5 hashes
    plugin.zip                Plugin bundle (when present)
    maps/
      mXXXX_N.zip             Map bundles (when present)
```

`g1100` also contains `decompiled_latest/`, a decompiled copy of its newest Lua sources and
CSV settings.

## Field reference

`version.json`:

| Field | Meaning |
| --- | --- |
| `fileSize` | Reported size of the plugin payload |
| `fileCount` | Reported file count |
| `pluginHash` | MD5 of the plugin payload |
| `hasPluginStaging` | Whether plugin staging files were published |
| `hasMapsStaging` | Whether map staging files were published |

`config-files.json` is a list of objects with `name`, `url`, `hash` (MD5), and `key` for each
individual asset that belongs to the version.

Version directories are named after the numeric engine version. Gaps in the sequence mean
that the CDN did not publish that version for the game.
