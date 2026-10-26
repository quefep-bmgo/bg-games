# v10113 res.pack — plain-English guide

This guide explains, without assuming reverse-engineering knowledge:

- where v10113 comes from
- how to download it
- what files the API gives you
- what `res.pack` is
- how to unpack it with the tools in this folder
- what you actually get when it is unpacked

The short version:

> `v10113` is a version key in Blockman GO’s game-resource manifest.  
> It is not the engine version. It tells the CDN which plugin zip and map zips belong to that game at that resource revision.

---

## 1. What v10113 means

Blockman GO stores game resources in a public manifest.

The manifest URL is:

```text
https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>
```

Examples:

```text
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1042
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1100
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1048
```

The response is a JSON object. Its keys are resource revisions:

```json
{
  "10112": { ... },
  "10113": { ... }
}
```

So `v10113` means:

> “The copy of this minigame that the CDN published under revision 10113.”

It does **not** mean:

- engine build 10113
- client version 10113
- all games were rebuilt for 10113

It is a resource-package revision.

Most active `g1xxx` minigames currently have a `10113` entry. Some older or separate games do not.

---

## 2. Get the manifest

### Browser method

Open:

```text
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1042
```

Search the JSON for:

```json
"10113"
```

Inside it you will see something like:

```json
{
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
```

The important fields:

| Field | Meaning |
|---|---|
| `plugin` | the game’s plugin zip |
| `pluginHash` | expected hash of that plugin zip |
| `maps[].durl` | a map zip |
| `mapHash` | expected hash of that map zip |
| `configFiles` | older per-file map configs; may be empty on v10113 |
| `pluginStaging` / `mapsStaging` | staged/unreleased versions, if present |

### PowerShell method

```powershell
$config = Invoke-RestMethod `
  "https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1042"

$v = $config.'10113'
$v.plugin
$v.maps | Select-Object name,durl,mapHash
```

### Downloader method

The folder includes a tested downloader:

```text
C:\Users\quefep\Desktop\Decomp Temp\howto\scripts\download_game_resources.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\howto\scripts\download_game_resources.py" `
  --game g1042 `
  --out "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --version 10113
```

It creates:

```text
games\g1042\v10113\plugin.zip
games\g1042\v10113\maps\m1042_1.zip
games\g1042\v10113\version.json
games\g1042\game-resource-config.json
```

The folder uses `v10113`; the API uses `10113`.

---

## 3. What did you actually download?

For v10113 of g1042, the API gives you:

```text
plugin.zip       1,487,744 bytes
m1042_1.zip      4,331,961 bytes
```

The plugin zip is small because it does not contain textures or terrain.

Inside `plugin.zip` for v10113 you typically see:

```text
res.pack
sandboxol
setting/
checksums.md5
```

The map zip contains:

```text
config.yml
r.0.0.mca
r.3.-2.mca
lang/
GameTip/
dynamic/
res.pack
checksums.md5
```

The `.mca` files are the actual terrain.

The `res.pack` files are the code/config containers.

---

## 4. What is res.pack?

Think of `res.pack` as a locked index plus a pile of locked files.

It is not a ZIP, and you cannot open it with 7-Zip.

Its layout is:

```text
small header
encrypted table of contents
content area
```

The table of contents records:

- file name
- position
- size
- whether the entry is Lua or CSV

The content area holds the actual entries.

To read it you need:

1. the table-of-contents key
2. the per-entry keys
3. the correct payload decoder

Those are what the tools in this folder implement.

---

## 5. What is inside the plugin res.pack?

For g1042 v10113, the plugin `res.pack` has:

- **508 Lua files**
- **21 CSV files**
- **529 total entries**

The Lua files include:

```text
lua/server/...
lua/client/...
lua/engine_base/...
lua/engine_client/...
lua/engine_server/...
lua/plugins/...
lua/common/...
```

These are things like:

- lobby and matchmaking logic
- mode selection
- shop and rewards
- player data
- packet handlers
- shared engine code
- UI code
- pay-activity and VIP systems
- anti-cheat checks

The CSVs are game settings such as:

- probabilities
- shop data
- VIP/subscription rewards
- pay-activity configuration

For other games the counts differ. Examples:

| Game | Lua entries | CSV entries |
|---|---:|---:|
| g1042 v10113 | 508 | 21 |
| g1100 v10113 | 616 | 15 |
| g1048 v10113 | 431 | 281 |

One g1100 entry is a known malformed-key exception.

---

## 6. What is inside the map res.pack?

Do not confuse the plugin `res.pack` with the map `res.pack`.

For g1042, the map `res.pack` contains **37 CSV tables**:

- `ModeSelect.csv`
- `ModeSelectMap.csv`
- `GunSetting.csv`
- `GunLevelSetting.csv`
- `Armor.csv`
- `RewardSetting.csv`
- task, season, shop, chest, and other tables

The map `res.pack` does **not** contain the terrain.

The terrain is in:

```text
r.0.0.mca
r.3.-2.mca
...
```

and the visual assets are in `dynamic/`, `lang/`, and other map files.

---

## 7. What you do not get just from the plugin res.pack

You do **not** get:

- the actual FFA maps
- Team Fight maps
- Duel maps
- Battle Royale maps
- textures
- 3D models
- the live server backend
- moderation/payment server logic

For g1042, the hub points at separate game packages:

| Mode | Package | Maps |
|---|---|---|
| Team Fight | g1043 | m1043_*.zip |
| Solo / FFA | g1044 | m1044_*.zip |
| Duel | g1045 | m1045_*.zip |
| Battle Royale | g1053 | m1053_1.zip |

FFA maps are at:

```text
games\g1044\v10113\maps\m1044_1.zip
games\g1044\v10113\maps\m1044_2.zip
games\g1044\v10113\maps\m1044_3.zip
games\g1044\v10113\maps\m1044_4.zip
```

The plugin `res.pack` for g1042 contains the hub and shared systems, not the FFA combat logic.

---

## 8. Unpack v10113

Use the extractor:

```text
C:\Users\quefep\Desktop\Decomp Temp\howto\scripts\bmg_extract.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\howto\scripts\bmg_extract.py" `
  --games-root "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --out "C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED" `
  --games g1042 `
  --versions v10113
```

Output:

```text
DECRYPTED\g1042_build_and_shoot\v10113\
  source\       readable Lua
  wrapped\      full decrypted anti-tamper wrapper
  csv\          decoded CSV settings
  config\       plugin settings outside res.pack
  map_config\   extracted map configs
  map_csv\      CSV tables from map res.pack
  MANIFEST.json
```

If a file could not be decrypted, it appears in:

```text
cipher\
```

with an `UNRESOLVED.txt` explanation.

---

## 9. What does a Lua source file look like?

Before extraction, most plugin Lua entries are encrypted and wrapped in an anti-tamper wrapper.

After extraction, `source\` contains the original Lua source.

Example:

```text
DECRYPTED\g1042_build_and_shoot\v10113\source\lua\server\ScriptMain.lua
```

The extractor also keeps the full wrapper in `wrapped\` so you can inspect the length-check code.

Some game packs use compiled Lua 5.1 bytecode instead. That is saved as `.luac` and decompiled with unluac.

---

## 10. Does v10113 mean everything changed?

No.

The version key is a **manifest revision**, and not every game changes every time.

Examples from the live data:

- `g1036` has 41 manifest snapshots and 35 distinct plugin hashes.
- `g1042` has 43 snapshots and 40 distinct plugin hashes.
- `g1100` has 6 snapshots; the maps stayed the same across all six, but the plugin changed.
- `g1048` has 9 snapshots and 9 different plugin hashes.
- `g1005` stopped at `10072`.

So:

- `v10113` is the current key for most active `g1xxx` games.
- It is not an engine version.
- It does not mean every minigame received the same update.
- It does not mean every map changed.

---

## 11. Fastest path

If you only want the latest source:

1. Download with `download_game_resources.py`.
2. Run `bmg_extract.py` for the game and `v10113`.
3. Open:

   ```text
   DECRYPTED\<game>\v10113\source
   ```

If you want map terrain, open:

```text
games\<game>\v10113\maps\<map>.zip
```

If you want the rules/config instead of terrain, open:

```text
DECRYPTED\<game>\v10113\csv
DECRYPTED\<game>\v10113\map_csv
```
