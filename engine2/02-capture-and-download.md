# 02 — Capture and download an Engine2 package

## Requirements

- A logged-in Blockman GO app in an authorized Android/Mumu test environment.
- ADB and mitmproxy/mitmdump installed on the host.
- The proxy certificate already trusted by the test environment if HTTPS interception is needed.
- [`scripts/capture_package_url.py`](scripts/capture_package_url.py), which stores only whitelisted game metadata and ZIP URL/timestamp. It does not record request headers, signatures, tokens, or full response bodies.

## Mumu example

Find the active Mumu ADB endpoint first:

```powershell
& "C:\Program Files\Netease\MuMuPlayer\nx_main\mumu-cli.exe" info --vmindex all
```

The example below uses Mumu's `127.0.0.1:16384`; substitute the `adb_host_ip` and `adb_port` for the active player. Using `adb reverse` allows the emulator's localhost proxy to reach the host listener.

```powershell
$adb = "C:\Program Files\Netease\MuMuPlayer\nx_main\adb.exe"
$mitm = "C:\Users\<you>\AppData\Local\Programs\Python\Python312\Scripts\mitmdump.exe"
$addon = ".\engine2\scripts\capture_package_url.py"
$conf = "$env:USERPROFILE\AppData\Local\Temp\engine2-mitm"
$env:ENGINE2_GAME_IDS = "g2041"
$env:ENGINE2_UPDATE_OUT = "$env:TEMP\engine2-package-capture.jsonl"
New-Item -ItemType Directory -Path $conf -Force | Out-Null

& $adb connect 127.0.0.1:16384
& $adb -s 127.0.0.1:16384 reverse tcp:8081 tcp:8081
& $adb -s 127.0.0.1:16384 shell settings put global http_proxy 127.0.0.1:8081
& $mitm --listen-host 0.0.0.0 -p 8081 --set confdir="$conf" -s "$addon"
```

With mitmdump running, open the game detail page and tap **Start**. A deep link can open details directly:

```text
blockmango://com.sandboxol.blockymods/android/page?deep_link_value=gamedetail_g2041
```

If the game ZIP is cached, the app may not request it again. Preserve the cached directory before moving it aside; do not clear app data or credentials. After the fresh request, the safe capture file will contain `game_api_metadata` and `game_package` records.

## Download and verify

Once the exact public static URL is captured:

```powershell
curl.exe -L --fail --output .\g2041.zip "<captured-package-url>"
Get-FileHash .\g2041.zip -Algorithm SHA256
7z t .\g2041.zip
```

Record the URL timestamp, bytes, SHA-256, and API `engineVersion`/`appVersion`. The static package can use HTTP range requests (HTTP 206); that is normal. Do not treat the size of one range response as the total ZIP size.

## Reset test capture networking

```powershell
& $adb -s 127.0.0.1:16384 shell settings put global http_proxy :0
& $adb -s 127.0.0.1:16384 reverse --remove tcp:8081
```

Stop mitmdump when finished. The addon output is metadata-only; still keep it in the local analysis workspace unless there is a reason to publish it.
