# BedWars: Smash (`g1108`) MuMu capture — 2026-10-30

This directory preserves the game-specific resource files captured from the installed Blockman GO app in MuMu. The ZIPs are byte-for-byte copies; `res-packs/` contains selected entries extracted without modification.

## Game metadata observed in the app

| Field | Value |
| --- | --- |
| `gameId` / title | `g1108` / BedWars: Smash |
| App game version | `5662` |
| `engineVersion` | `10114` |
| `engineType` / `isNewEngine` | `0` / `0` |
| `latestResVersions` | `gresVersion=41427027`, `cresVersion=41426986`, `dresVersion=607` |

The API exposed a `Hall` lobby mode and a `default` team match mode (four teams, four players per team; 16-player maximum). The game's English resource strings label the match mode “Ranked Match.” These are modes of `g1108`, not separate game IDs.

**Engine compatibility:** this is a legacy Engine1 game, not an Engine2 package. Its `res.pack` and `sandboxol` files use the Engine1 container format. This raw capture is not a ready-to-run Engine2 conversion.

## Captured artifacts

| File | Bytes | Source / notes |
| --- | ---: | --- |
| `appres-g1108.zip` | 117,793,422 | MuMu app resource bundle; internal `appres/g1108.json` reports version `10114`. |
| `common.zip` | 6,707,341 | Shared app resources copied alongside the game bundle. |
| `map-g1108.1793348333799.zip` | 4,751,865 | MuMu cache `map/m1108_1/g1108.1793348333799.zip`; the app log reported `http://txstaticgs.sandboxol.com/sandbox/games/maps/g1108.1793348333799.zip`. |
| `plugin-g1108-v10113.zip` | 4,141,898 | Public manifest's `10113` staging plugin. Its MD5 matches the manifest value `6063e57364b13411fbca93469e1cfe7c` and the repository's `games/g1108/v10113/plugin.zip`. |

`res-packs/` contains the `res.pack` and `sandboxol` entries from each game-specific appres, map, and plugin ZIP. `SHA256SUMS.txt` records SHA-256 hashes for all captured binary files.

## Version boundary

The live game detail API reported `engineVersion=10114`, while the public `game-resource-config_g1108` manifest available during capture exposed only resource revision `10113` as staging. Therefore the appres bundle and map ZIP are the MuMu-cached resources observed on 2026-10-30, but the plugin ZIP here is **not independently confirmed as the live 10114 plugin**.

## Local Engine2 test

The raw Engine1 plugin ZIP was staged on the local Engine2 server as a compatibility probe. The server could not find the game's Engine2 Lua plugin modules and started without the game's logic, so this capture should be treated as source material for an Engine1-compatible run or a deliberate Engine1-to-Engine2 port.
