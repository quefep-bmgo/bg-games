# 07 — Artifact and script index

## Core decryption scripts

```text
...\howto\scripts\emu_lib.py
```

Native modified-AES/Unicorn bridge. Needed for current TOCs and current `sandboxol` blobs.

```text
...\howto\scripts\decrypt_pack.py
```

Minimal plugin pack reader/decryptor for one known pack.

```text
...\howto\scripts\decrypt_all.py
```

Decrypts the plugin, engine, and map packs using the known TOCs/KeyObjects.

```text
...\howto\scripts\decrypt_g1100_latest.py
```

Current `g1100` pack/keyfile parser, including the special trailing keyfile records.

```text
...\howto\scripts\bmg_extract.py
```

Generic game/version extractor. Processes plaintext zips, inline-MD5 zips, current packs, and legacy CSV/TOC packs.

```text
...\howto\scripts\verify_pipeline.py
...\howto\scripts\verify_g1100.py
```

Round-trip validators.

## Data files

```text
...\howto\data\sub_table.pkl
```

Known plaintext -> ciphertext substitution table for `flag = 1` entries.

```text
...\g1042_analysis\keyobjects_plugin.json
```

508 plugin KeyObject records from the plugin keyfile.

```text
...\g1042_analysis\keyobjects_engine_current.json
```

438 engine KeyObject records from the current APK engine keyfile.

```text
...\g1042_analysis\plugin_frame0.bin
...\g1042_analysis\plugin_frame1.bin
```

Decrypted plugin keyfile frame 0 (KeyObjects) and frame 1 (patch map).

```text
...\g1042_analysis\toc_plugin.bin
...\g1042_analysis\toc_engine.bin
...\g1042_analysis\toc_map.bin
```

Decrypted TOCs.

## Decrypted output roots

```text
C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED
```

Fast latest paths:

```text
...\DECRYPTED\g1042_build_and_shoot\v10113\source
...\DECRYPTED\g1100_rooms\v10113\source
...\DECRYPTED\g1048_skyblock\v10113\source
...\DECRYPTED\g1005_clanwar\v10072\source
```

Base g1100 room build:

```text
...\DECRYPTED\g1100_rooms\base\decompiled
```

Map config extraction:

```text
...\DECRYPTED\g1042_build_and_shoot\v10113\map_config
...\g1042_analysis\decrypted_map
```

## Game/map source data

```text
C:\Users\quefep\Desktop\Decomp Temp\games\<game>\<version>\plugin.zip
C:\Users\quefep\Desktop\Decomp Temp\games\<game>\<version>\maps\*.zip
C:\Users\quefep\Desktop\Decomp Temp\games\<game>\<version>\maps-staging\*.zip
```

g1042 mode/map hosts:

```text
games\g1043\v10113\maps\m1043_*.zip   Team Fight
games\g1044\v10113\maps\m1044_*.zip   Solo / FFA
games\g1045\v10113\maps\m1045_*.zip   Duel
games\g1053\v10113\maps\m1053_1.zip   Battle Royale
```

## Reports

```text
...\DECRYPTED\REPORTS\INDEPENDENT_VALIDATION.md
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
...\g1042_analysis\reports\G1042_MECHANICS.md
...\g1042_analysis\reports\G1042_VERSION_TIMELINE.md
...\g1042_analysis\reports\G1100_ROOM_ANALYSIS.md
...\g1042_analysis\reports\G1100_LUA_API.md
...\g1042_analysis\reports\G1100_SYSTEMS_PENTEST.md
```

## Native analysis

```text
...\g1042_analysis\native\bg_libBlockMan_arm64.so
```

Used only to reproduce the current modified AES.

Important native locations:

```text
0x1f348d0   cipher context init
0x1f35acc   decrypt
0x1f28d98   KeyObject list transform (historical disassembly)
```

## Unluac

```text
C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar
```
