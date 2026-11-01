# Engine2 game package collection and parsing

This page documents the live engine2 package corpus collected on 2026-10-28. It is separate from the engine1 `res.pack` format in the rest of this folder.

## Scope and result

- 31 engine2 games were selected from the live hall game list.
- All 31 map/resource ZIPs downloaded successfully.
- Total size: `1,033,689,465` bytes (`985.8 MiB`, about `1.03 GB`).
- Local root: `engine2_packs\<gameId>\`
- Repository indexes: `engine2_packs\catalog.tsv`, `engine2_packs\analysis.tsv`.
- `catalog_verified.tsv` is generated locally and not committed because it contains machine-specific paths.

The effective engine2 test is:

```text
engineType == 2
OR
(engineType == 0 AND isNewEngine == 1)
```

Raw `g2xxx` IDs are not enough: several current engine2 games have `engineType=0`.

## Discovery

The live game list came from:

```text
GET https://gw.sandboxol.com/game/api/v2/game/revision/all/list/by/condition/combine
```

The response is a normal hall list. Its game objects contain `gameId`, `gameTitle`, `engineType`, `isNewEngine`, `engineVersion`, `appVersion`, and `isUgcGame`. The current list contains 65 games; 31 match the engine2 predicate above.

`https://staticgs.sandboxol.com/sandbox/config/server/game-resource-config_g2033` returns `404 NoSuchKey`. Engine2 packages are not published through the engine1 manifest.

### Rechecking the current `g2041` version

The in-app request observed for the list endpoint uses `filterTypeId=0`, `isFilter=0`, `os=android`, `pageNo=0`, and `pageSize=20`. An anonymous direct GET returns HTTP 400 `illegal header`; the supported way to recheck is to let the installed app make its ordinary catalog request, then inspect the response for the `g2041` record. Do not forge the app signature or copy account headers into a script.

For a low-data capture, use `engine2/scripts/capture_package_url.py`. It logs only whitelisted catalog fields and static ZIP URL/status/size/timestamp; it does **not** write request headers, tokens, URL query strings, or full response bodies. `tools/engine2_update_capture.py` is a g2041-only legacy helper; prefer the generic addon for new captures. Example Mumu setup (adjust the ADB endpoint if the player index/port changes):

```powershell
$adb = "C:\Program Files\Netease\MuMuPlayer\nx_main\adb.exe"
$mitm = "mitmdump.exe" # Or provide its full path.
$repo = (Resolve-Path ".").Path # Run from the bg-games repository root.
$addon = Join-Path $repo "engine2\scripts\capture_package_url.py"
$conf = Join-Path $env:TEMP "engine2-mitm-conf"
$out = Join-Path $env:TEMP "engine2-package-capture.jsonl"
$env:ENGINE2_GAME_IDS = "g2041"
$env:ENGINE2_UPDATE_OUT = $out
& $adb connect 127.0.0.1:16384
& $adb -s 127.0.0.1:16384 reverse tcp:8081 tcp:8081
& $adb -s 127.0.0.1:16384 shell settings put global http_proxy 127.0.0.1:8081
Start-Process -FilePath $mitm -ArgumentList "--listen-host 0.0.0.0 -p 8081 --set confdir=`"$conf`" -s `"$addon`"" -PassThru
```

Open the game catalog and press Start on `Anime All Star (g2041)`. Then compare the `game_api_metadata` record with the captured `game_package` timestamp and downloaded ZIP hash. After the check, stop mitmdump and reset the emulator:

```powershell
& $adb -s 127.0.0.1:16384 shell settings put global http_proxy :0
& $adb -s 127.0.0.1:16384 reverse --remove tcp:8081
```

The timestamped static ZIP URL is the package-version evidence; the game-list record alone is not enough to prove the package is the newest downloadable build.

## Capture workflow

The package URL is delivered while the game is launched. It is not in the game-detail JSON and is not returned by the public engine1 config endpoint.

1. Run mitmproxy with `engine2/scripts/capture_package_url.py` and set the Android global HTTP proxy to the host.
2. Force-stop the app so the deep link starts a fresh task.
3. Open game detail directly:

```text
blockmango://com.sandboxol.blockymods/android/page?deep_link_value=gamedetail_<gameId>
```

4. Wait for `GameDetailTemplateActivity`, then tap the portrait `Start` button. On the 900x1600 test profile its center is about `(450, 1490)`.
5. Read the new `game_package` record from the capture JSONL file. The addon stores a sanitized static URL without query parameters.
6. Force-stop the app after the URL is captured; download the ZIP directly instead of letting the app finish the transfer.

The detail deep link dispatches a `GameDetail` command and does not require a token in the URL. The app still needs to be logged in for the Start flow.

The reusable URL collector is:

```powershell
$env:ENGINE2_GAME_IDS = "g2033,g2020" # Set before starting/restarting mitmdump.
# For opaque editor-file ZIP names, capture one game at a time so its URL can be associated.
py -3 "tools\engine2_collect.py" `
  --ids "g2033,g2020" `
  --log "$env:TEMP\engine2-package-capture.jsonl" `
  --out ".\engine2_packs\catalog.tsv" `
  --serial 127.0.0.1:16384
```

The collector uses the deep link, waits for the detail activity, taps Start, scans new engine2 ZIP requests, and force-stops the app. Adjust `--tap-y` if the device resolution differs.

## URL formats

Engine2 uses at least two static-package layouts:

```text
https://staticgs.sandboxol.com/sandbox/games/engine-resources/<gameId>.<epoch_ms>.zip
https://staticgs.sandboxol.com/editorfile/editor/file/[<hash>/]<name>.<epoch_ms>.zip
https://static.sandboxol.com/editorfile/editor/file/[<hash>/]<name>.<epoch_ms>.zip
```

Examples:

```text
https://staticgs.sandboxol.com/sandbox/games/engine-resources/g2033.1747914416145.zip
https://staticgs.sandboxol.com/editorfile/editor/file/3cd7030d4ed7b322f43328c7748a7006/wsoymjtvij.1658114495850.zip
https://static.sandboxol.com/editorfile/editor/file/spupenukne.1629913162788.zip
```

`epoch_ms` is the package's last-update timestamp. Convert it as UTC:

```python
datetime.fromtimestamp(1747914416145 / 1000, tz=timezone.utc)
# 2025-05-22 11:46:56.145+00:00
```

The filename timestamp is the reliable last-update value. Internal ZIP entry timestamps usually match for `engine-resources` packs, but editor-file packs can have internal dates a few days earlier than the filename timestamp.

The editor-file layout is map-only for some games: those ZIPs have no `all_configs.lbc` and no `lua/` directory. `g20151434` and `g2361482g` currently reference the same map ZIP.

## Download

`engine2_download.py` reads `catalog.tsv`, downloads each ZIP into `engine2_packs\<gameId>\`, verifies ZIP integrity, and writes `catalog_verified.tsv`:

```powershell
py -3 "tools\engine2_download.py" `
  --catalog ".\engine2_packs\catalog.tsv" `
  --dest ".\engine2_packs" `
  --out ".\engine2_packs\catalog_verified.tsv" `
  --workers 3
```

The static hosts serve the packages without authentication or signed query parameters once the exact URL is known. Keep the original `http` or `https` scheme from the capture; some editor-file hosts work on both.

## Parse

The packages are plain ZIP files. No engine1 `res.pack`, custom AES TOC, or per-file inline-MD5 layer is involved.

Typical contents:

```text
all_configs.lbc
asset/
resource/
plugin/myplugin/
setting.json
lua/script_client/
lua/script_server/
```

- `all_configs.lbc` starts with Lua 5.3 bytecode magic `1B 4C 75 61 53 ...`. Inspect it with `luac5.3 -l`; decompile with a Lua 5.3-compatible decompiler.
- `lua/script_client/` and `lua/script_server/` are plain source in the engine-resource packs. Server-side packet handlers, rewards, shops, and GM logic are visible there.
- `plugin/myplugin/` contains plugin scripts and settings.
- Editor-file map packs may contain only map assets and plugin content.

Basic commands:

```powershell
7z l "engine2_packs\g2033\g2033.1747914416145.zip"
7z x "engine2_packs\g2033\g2033.1747914416145.zip" -o"engine2_packs\g2033\extracted"
```

The server Lua source is sensitive. It should stay in the local private analysis tree and must not be published with the how-to or game archive.

## Last-update findings

### Fresh Anime All Star (`g2041`) API check — 2026-10-30

The current app was used to make the normal read-only game-catalog and package requests; no request headers, signatures, or account tokens were recorded. The API returned `Anime All Star` as published (`engineType=2`, `isNewEngine=1`, `engineVersion=20046`, `appVersion=4060`). The app then requested:

```text
http://staticgs.sandboxol.com/sandbox/games/engine-resources/g2041.1735114999081.zip
```

The package filename timestamp converts to `2024-12-25T08:23:19.081Z`. A fresh Mumu download on 2026-10-30 completed as `g2041.zip` (32,768,071 bytes); its SHA-256 is `530CB8826ADB4FD3605C4579D73908A99BFB45DE9E5599193DE4B630740E7E41`, identical to the local archive `g2041.1735114999081.zip`. Thus **2024-12-25 is the latest g2041 package timestamp currently served by the app/API as of 2026-10-30**. The API game-list/detail records do not expose a separate last-content-edit date; the URL timestamp is the package-build/upload timestamp.

Sanitized evidence was retained in the local analysis workspace; the repository does not contain the captured app traffic.

All 31 packages are older than one year as of 2026-10-28. The newest package is `g2061` at 2025-08-19; there is no package update in the preceding 12 months.

- 23 packages are more than three years old.
- 4 packages are more than five years old.
- Oldest: `g20019902` Crafty Battle, 2020-11-23.
- Next oldest: `g20164923`, `g20368480`, `g20471460`.

Full table, oldest first:

| Game | Title | Last update (UTC) | Age (days) | Size |
|---|---|---|---:|---:|
| g20019902 | Crafty Battle | 2020-11-23 | 2164 | 13.2 MB |
| g20164923 | BLOCKMAN SERVER 3 демо | 2021-05-27 | 1979 | 2.1 MB |
| g20368480 | 5v5 Brawl | 2021-08-23 | 1891 | 2.1 MB |
| g20471460 | Dungeon Wars | 2021-08-25 | 1889 | 2.1 MB |
| g20543283 | Express X | 2022-04-08 | 1663 | 15.3 MB |
| g20555652 | The Backrooms | 2022-06-16 | 1594 | 2.1 MB |
| g20151434 | The Backrooms | 2022-07-12 | 1568 | 2.2 MB |
| g2361482g | Insane Elevator [horror game] | 2022-07-12 | 1568 | 2.2 MB |
| g20551240 | [UP3.0]TowerWorld：Champion | 2022-07-18 | 1562 | 7.5 MB |
| g2251215g | King Miner | 2022-07-26 | 1554 | 3.3 MB |
| g2021 | Block Dungeon | 2022-10-27 | 1461 | 58.2 MB |
| g2020 | Grow with Me | 2022-10-27 | 1461 | 56.5 MB |
| g2036 | Murder Mystery2 | 2022-10-27 | 1461 | 4.0 MB |
| g2037 | Horror 1VS4 | 2022-10-27 | 1461 | 14.9 MB |
| g2046 | Night at the school | 2022-10-27 | 1461 | 31.8 MB |
| g2049 | Aircraft Frontier | 2022-10-27 | 1461 | 32.8 MB |
| g2050 | Block Invasion | 2022-10-27 | 1461 | 66.5 MB |
| g2044 | Titan | 2022-12-22 | 1405 | 33.7 MB |
| g2030 | Ninja: Skyrim | 2023-01-12 | 1384 | 59.9 MB |
| g2053 | Rodent Evil | 2023-03-24 | 1313 | 42.1 MB |
| g2063 | The Exorcists | 2023-06-14 | 1231 | 62.1 MB |
| g2042 | Paradise Island | 2023-08-03 | 1181 | 62.7 MB |
| g2066 | SOCIAL HALL | 2023-12-28 | 1034 | 70.1 MB |
| g2060 | Party Street | 2024-06-04 | 875 | 97.3 MB |
| g2069 | Anime Showdown | 2024-08-14 | 804 | 37.9 MB |
| g2041 | Anime All Star | 2024-12-25 | 671 | 31.3 MB |
| g2065 | BMG Football | 2025-03-17 | 589 | 31.5 MB |
| g2033 | Anime Fighting Simulator | 2025-05-22 | 523 | 28.8 MB |
| g2052 | Free City RP | 2025-05-22 | 523 | 46.4 MB |
| g2038 | Trainers Arena | 2025-08-13 | 440 | 56.2 MB |
| g2061 | Frontline | 2025-08-19 | 434 | 9.0 MB |

Machine-readable data: `engine2_packs\analysis.tsv`.

## Caveats

- The filename timestamp is the package upload/build value; the live game server can still push different runtime configuration.
- A package being downloadable does not mean the game is still joinable; all 31 URLs returned `200` on 2026-10-28.
- `g20151434` and `g2361482g` share one editor map ZIP.
- The game list and package URLs are dynamic; rerun the collector instead of assuming the IDs and timestamps are permanent.
