# Source coverage and limitations — g1019

## 1. What was available

| Source | Path | Coverage | Notes |
|---|---|---|---|
| v10113 decrypted plugin source | `decrypted\v10113\source\lua` | 459/459 Lua resolved | Production plugin `res.pack` (current format) + `sandboxol`; 0 cipher. |
| v10113 decrypted staging plugin | `reports\agents\features\_work\plugin_staging_decrypted\v10113\source\lua` | 459/459 Lua resolved | `pluginStaging` from manifest key `10113`; 5 semantic diffs vs production. |
| v10068–v10103 plugin zips | `games\g1019\<ver>\plugin.zip` | 116–424 Lua per version, all plaintext | Verified by byte inspection; full engine + game server + plugins. |
| v10104–v10108 plugin zips | same | 421–434 Lua names/sizes; **content wrapped/cipher** | No source recovered; source-MD5 recovery from v10103 produced 0 hits. |
| v10109–v10112 plugin zips | same | 5 files; TOC names/sizes available; **Lua unresolved** | Legacy `res.pack`/keyfile format; keyfile blob key unknown. Config CSVs decoded. |
| Maps (all versions) | `games\g1019\<ver>\maps\*.zip` | `config.yml`, `scene1..3.yml`, `.mca`, checksums, CSVs where plaintext | v10109+ `m1019_1` CSVs are inside map `res.pack` (decoded). |
| m1019_10 / m1019_2 CSVs | `maps\v10113\m1019_10`, `maps-staging\v10113\m1019_2` | full plaintext CSV/yml | m1019_2 only in staging. |
| Manifest | `manifest\game-resource-config.json` | 41 revisions, 10068–10113 | Missing 10078/10081/10089/10092/10094. |
| Hard-mode agent cross-check | `reports\agents\hard_mode\map_characteristics.json` | map1 v10068/v10113, map10 v10110/v10113 | Independent counts used; no narrative report was present. |

## 2. Readability by revision

- **Plaintext Lua (31 revisions):** v10068, 10069, 10070, 10071, 10072, 10073, 10074, 10075, 10076, 10077, 10079, 10080, 10082, 10083, 10084, 10085, 10086, 10087, 10088, 10090, 10091, 10093, 10095, 10096, 10097, 10098, 10099, 10100, 10101, 10102, 10103.
- **Wrapped/cipher plugin Lua (5 revisions):** v10104, 10105, 10106, 10107, 10108.
- **Packed legacy `res.pack` (4 revisions):** v10109, 10110, 10111, 10112 (TOC/config decoded; Lua unresolved).
- **Decrypted current `res.pack` (1 revision):** v10113 (production + staging trees).
- **Missing revisions in manifest:** 10078, 10081, 10089, 10092, 10094.

## 3. Extraction / normalization

- Extracted all 41 plugin zips and all map zips into `reports\agents\features\_work\plugins` and `_work\maps`; staging maps into `_work\maps_staging`; staging plugins into `_work\plugin_staging`.
- Normalized the pre-v10073 layout (`Match.lua`, `ScriptMain.lua`, `config/`, `data/`, `listener/`, `messages/`, `task/`, `base/`) to `lua/server/...` and `lua/engine_server/...`, then hashed every file (`_scripts\normalize2.py`, `_work\norm2\MANIFEST.json`).
- v10113 source taken from the decrypted tree; v10109–v10112 names taken from the decrypted TOC.
- Content decryption used `howto\scripts\bmg_extract.py` + `decrypt_g1100_latest.py`/`emu_lib`:
  - v10113 plugin: 459 source, 0 unresolved;
  - v10113 staging plugin: 459 source, 0 unresolved;
  - v10109–v10112 map `res.pack` CSVs decoded; plugin Lua intentionally unresolved (legacy keyfile);
  - v10113 map `res.pack` CSVs decoded; m1019_10/m1019_2 already plaintext.

## 4. Limitations

1. **v10104–v10108 and v10109–v10112 plugin Lua could not be read.** File-level additions/removals are known from names/TOC, and config/map data is known, but semantic code changes in those nine revisions are not provable from the supplied artefacts. Statements about those ranges are limited to file presence and map/config changes.
2. **v10104–v10108 source-MD5 recovery failed** because the wrapper changes the ciphertext MD5; no key records are in the plaintext packages.
3. **No UI layout assets/localization tables** are in the extracted trees beyond the Lua that references them. UI strings/IDs are known only where hardcoded (e.g. messages 20052–20063, scene names 20059–20061).
4. **Plugin enablement** is inferred from `setting/setting.json` + `Plugins.LoadAllPlugins()`. A platform-injected `plugins_setting.json` is not present in any supplied artifact and cannot be ruled out.
5. **Map exposure** is a platform/room decision. The game Lua never references `m1019_10`/`m1019_2`; it receives a map/config from the host. The manifest proves publication, not which players see which map.
6. **No live server, database, Redis or backend configuration** was available. Server-side validation claims are static-analysis observations from Lua, not runtime proof.
7. **v10113 staging is not the live v10113 build.** Its 5 engine diffs are reported separately; it is not used for live-feature claims.
8. **Hard-mode agent report**: only `map_characteristics.json` and work artefacts were present. Counts were cross-checked; no narrative conclusions were available to reconcile.

## 5. Checksums / reproducibility anchors

- Normal terrain (all versions): `r.3.-1.mca` `7fa61a875634...`, `r.3.-2.mca` `75f52cca93a2...`, `r.4.-1.mca` `65cc38efb456...`, `r.4.-2.mca` `1bee2cc25a55...`.
- Hard terrain (m1019_10 and m1019_2): `0852dba43b3a...`, `ee8861ae23ee...`, `7f5871c9349b...`, `ac1a9e8800b8...`.
- m1019_10 config `e4bc18849ecf...`, `game_level.csv` `85a46ecc952a...`, `monster.csv` `708705828b40...`, `monster_num.csv` `3ce1be2ed256...`, `basement.csv` `6d055ed16c01...`.
- v10110 manifest map hash `96aad549865807944d45cbb1212d5ebf`; v10113 mapsStaging `m1019_2` hash `6450a8139f35ae42523215b097f3a845`.
- Scripts: `reports\agents\features\_scripts\*.py`; generated data: `_work\maps_parsed.json`, `_work\compare_modes_out.txt`, `_work\norm2\MANIFEST.json`.
