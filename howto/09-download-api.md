# 09 — Where the games were downloaded from

## 1. Public manifest API

The game/version manifest came from this endpoint:

```text
GET https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>
```

Examples:

```text
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1042
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1100
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1048
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1005
```

This was observed as an anonymous, public read returning HTTP 200.

The response is a JSON object keyed by version number:

```json
{
  "10113": {
    "plugin": "http://staticgs.sandboxol.com/sandbox/games/plugins/g1042.1770004775563.zip",
    "pluginHash": "6dc5b67499d9229a2653d3b7d4291b47",
    "fileSize": 1487744,
    "fileCount": 7,
    "maps": [
      {
        "name": "m1042_1",
        "durl": "http://staticgs.sandboxol.com/sandbox/games/maps/g1042.1766550369931.zip",
        "mapHash": "4339c2d285938b4547119a8513aff497",
        "fileSize": 4331961,
        "fileCount": 43
      }
    ]
  }
}
```

The actual artifact URLs are in the manifest. The hostnames observed:

```text
static.sandboxol.com        manifest API, older artifact host
staticgs.sandboxol.com      main current CDN
txstaticgs.sandboxol.com    Tencent Cloud mirror
bstaticgs.sandboxol.com     asset/upload host
```

## 2. How the local archive was built

The workflow was:

1. Seed game IDs from the APK’s `ScriptSetting.csv`.
2. Sweep additional IDs in the g1000–g1199, g2000–g2199, g3000–g3199, and g9000–g9199 ranges.
3. For each ID, fetch:

   ```text
   https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>
   ```

4. Save the manifest to:

   ```text
   games\<gameId>\game-resource-config.json
   ```

   A global copy is also kept under:

   ```text
   game_configs\<gameId>.json
   ```

5. For each version key in the manifest, download `plugin` to:

   ```text
   games\<gameId>\<version>\plugin.zip
   ```

6. Download each `maps[].durl` to:

   ```text
   games\<gameId>\<version>\maps\<map name>.zip
   ```

7. Download `mapsStaging[].durl` to:

   ```text
   games\<gameId>\<version>\maps-staging\<map name>.zip
   ```

8. When `configFiles[]` are listed, download each `configFiles[].url`; newer packs generally carry the config inside the map `res.pack` instead.

9. Write:

   ```text
   games\<gameId>\<version>\version.json
   ```

   with the manifest’s `fileSize`, `fileCount`, and `pluginHash`.

The evidence for this method is in:

```text
...\reports\GAME_INVENTORY.md
...\reports\LIVE_INFRA_REPORT.md
...\reports\LIVE_INFRA_REPORT_round2.md
...\reports\LIVE_INFRA_REPORT_round3.md
...\reports\ROUTE_TABLES.md
```

`GAME_INVENTORY.md` states the source endpoint explicitly:

```text
GET https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>
```

## 3. Downloader script

A minimal downloader is included at:

```text
...\howto\scripts\download_game_resources.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "...\howto\scripts\download_game_resources.py" `
  --game g1042 `
  --out "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --version 10113
```

All versions:

```powershell
... --game g1042 --out ...\games
```

The script writes the same layout:

```text
games\g1042\10113\plugin.zip
games\g1042\10113\maps\m1042_1.zip
games\g1042\10113\version.json
games\g1042\game-resource-config.json
```

Note: the local folders use `v10113`, while the manifest keys use `10113`. The downloader accepts either form.

## 4. Current live version check

Checked against the live public manifest on 2026-10-20:

| Game | Latest live key | Plugin |
|---|---|---|
| g1042 | `10113` | `g1042.1770004775563.zip` |
| g1100 | `10113` | `g1100.1779768628704.zip` |
| g1048 | `10113` | `g1048.1780649054424.zip` |
| g1005 | `10072` | `ClanWar.1617108843935.zip` |

There is no `10114` or `100114` key in the live manifests at that time.

A `100114` key would be inconsistent with the version naming scheme. If you see it later, query the same manifest endpoint again; the newest key is the release to download.
