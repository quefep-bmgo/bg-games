# 04 — Run an Engine2 game on an older local runtime

This describes an authorized local/private test server, not an official live-server deployment.

## Stage the game

Keep the downloaded ZIP immutable. Make a separate extracted game root with `setting.json` at its top level:

```text
engine2_work/
  g2041/                 # extracted package root
  zip/g2041/g2041.zip     # same package, used by the server/client resource loader
```

For a game ID other than g2041, use that ID for both directory names. Avoid placing the package inside an extra `g2041.1735....zip/` directory.

Example using 7-Zip from PowerShell (run from the folder containing the downloaded ZIP):

```powershell
$gameId = 'g2041'
$work = 'C:\engine2_work'
$sourceZip = (Resolve-Path '.\g2041.zip').Path
$extractRoot = Join-Path $work $gameId
$zipRoot = Join-Path (Join-Path $work 'zip') $gameId

New-Item -ItemType Directory -Path $extractRoot, $zipRoot -Force | Out-Null
& 7z.exe x $sourceZip "-o$extractRoot" -y
Copy-Item -LiteralPath $sourceZip -Destination (Join-Path $zipRoot "$gameId.zip") -Force
if (-not (Test-Path (Join-Path $extractRoot 'setting.json'))) {
    throw 'The extracted package root must contain setting.json.'
}
Get-FileHash -LiteralPath $sourceZip -Algorithm SHA256
```

Keep the SHA-256 output with the test notes. The extracted tree is for inspection/edits; the copied ZIP is the resource archive mounted by the local client/server. Do not modify the only copy of the downloaded archive.

## Configure the older server

Use the matching local Engine2 runtime's `res` directory as the working directory. A minimal local `gameconfig.json` needs the following shape; retain other fields from the runtime's config template:

```json
{
  "gtype": "g2041",
  "dataDir": "C:/absolute/ascii/path/engine2_work",
  "dataZipDir": "C:/absolute/ascii/path/engine2_work/zip",
  "ip": "127.0.0.1",
  "publicIp": "127.0.0.1",
  "port": 12936,
  "gameDataServiceAddr": "local:localdata.csv",
  "blockymodsUrl": "http://127.0.0.1:1",
  "secret": "",
  "multiPlayer": true,
  "isEditor": false,
  "isDebug": true,
  "gm": true
}
```

Use only a dedicated local test account and local data file. Do not copy live account tokens into `testacc.json` or config files. A dead local service address is useful for isolated testing, but it is not a substitute for production services.

If the engine source is under a Unicode path and fails to initialize resources, place an ASCII junction to the runtime `res` directory and launch the binaries from that junction. Keep `dataDir`/`dataZipDir` paths ASCII too.

## Start and verify

From the runtime `res` directory or its ASCII junction:

```powershell
Start-Process .\GameServer_d.exe -WorkingDirectory $PWD
Start-Process .\WinShell_d.exe -WorkingDirectory $PWD
```

Confirm the server log shows the intended `gameType` and that the client loads the same game ZIP. The debug port (commonly 6600 in the inspected local config) supports `help`, `p` (players/positions), `o` (map objects), and `dc on/off` (collision drawing) when enabled.

## Debug a failed or broken load

Use this order so package-path problems are separated from engine-version or gameplay problems:

1. **Check the paths first.** Confirm the `setting.json` is at `dataDir/<gameId>/setting.json` and the package ZIP is at `dataZipDir/<gameId>/<gameId>.zip`. Check the server's working directory and `gameconfig.json` before changing the package.
2. **Check server startup logs.** Confirm the selected game ID, data directories, runtime version, and map name. Resolve missing plugin modules, absent assets, malformed JSON/CSV, or config-bundle errors before testing movement.
3. **Check client package loading.** Confirm the client receives the intended ZIP and that its timestamp/hash matches the test notes. If the app is loading a cached copy, close it, preserve the cache, then move only the game's cached package aside before retrying the normal download flow.
4. **Inspect the live scene.** If the debug console is enabled, run `help`, then `p` for player positions and `o` for loaded map objects. Turn on `dc on`, reproduce the issue, and record the approximate position, travel direction, and nearby collider/object names. Turn it back off with `dc off` after the check.
5. **Compare versions and assets.** Compare the package/API engine version with both the runtime binary and its `res/engine2Version.json`. Check warnings for missing mesh, convex, actor, texture, effect, or font files. A missing decorative collision file can produce warnings without causing the movement issue, so verify in-game before adding/removing colliders.
6. **Change one thing at a time.** Make a copy of the package root, change one config/scene/asset, update package checksums where applicable, rebuild the ZIP, and repeat the same reproduction path. Keep the original ZIP and a known-good staged copy untouched for rollback.

If a local debug port does not respond, verify `isDebug` and `gm` in the local `gameconfig.json`, inspect the server log for the listener startup, and confirm the port is actually listening before concluding the command syntax or map is at fault.

## Older-engine compatibility

- Compare the package/API `engineVersion` to the local runtime's own version. A mismatched physics/resource version may alter collisions or asset interpretation.
- Inspect logs for missing plugin modules, font config assertions, missing assets, and absent CSVs. Some games reference optional live-service features or plugins not shipped in the older runtime.
- Use narrowly scoped local compatibility stubs only in the local test runtime. Do not put free-currency/test-account stubs in a contribution ZIP.
- A local package may use raw CSV/JSON fallback if that behavior is verified; production packaging should follow the game operator's compiler and release pipeline.
- Keep server Lua, credentials, and API signatures private.

The g2041 case study records the exact local version mismatch and package load details.
