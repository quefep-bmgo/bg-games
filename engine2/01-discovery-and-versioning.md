# 01 — Discover Engine2 games and check package versions

## Engine2 selection

Do not identify an Engine2 game from its `g2xxx` name alone. The app's catalog record should match either:

```text
engineType == 2
OR
(engineType == 0 AND isNewEngine == 1)
```

The catalog record also exposes fields such as `gameId`, `gameTitle`, `engineVersion`, `appVersion`, `isNewEngine`, `isUgcGame`, and `isPublish`.

## Catalog API

The observed catalog endpoint is:

```text
GET https://gw.sandboxol.com/game/api/v2/game/revision/all/list/by/condition/combine
    ?filterTypeId=0&isFilter=0&os=android&pageNo=0&pageSize=20
```

The installed app makes this request with its normal app headers. Anonymous `curl`/browser GETs returned HTTP 400 `illegal header`; use the ordinary app flow for read-only discovery rather than fabricating signed headers or copying account tokens.

## Package URL and timestamp

Engine-resource packages use a timestamped URL such as:

```text
https://staticgs.sandboxol.com/sandbox/games/engine-resources/g2041.1735114999081.zip
```

Convert the 13-digit suffix from Unix milliseconds in UTC:

```powershell
[DateTimeOffset]::FromUnixTimeMilliseconds(1735114999081).UtcDateTime.ToString('o')
```

The result is the package's build/upload timestamp, not necessarily the date the game content was last edited. Capture both the API metadata and the package URL; the API record may not contain a separate update timestamp.

Other observed package forms include editor-file/map ZIPs with opaque filenames. For those, capture the package request while the target game is open and record the game ID at the same time.

## Latest-version check

1. Open the game's details through the app.
2. Capture the current API record for that `gameId`.
3. Start the game with a fresh cache or after a version check, and capture the static ZIP request.
4. Download the package and compare its byte count/SHA-256 to the local archive.
5. Report the package URL timestamp separately from `engineVersion` and `appVersion`.

See [`05-g2041-case-study.md`](05-g2041-case-study.md) for a fresh check of Anime All Star.
