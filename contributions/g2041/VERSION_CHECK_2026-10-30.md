# Fresh `g2041` package check — 2026-10-30

The game list was refreshed through the normal Blockman Go app/API flow on Mumu; an anonymous direct request to the gateway is rejected with `illegal header`, so no signature or account header was fabricated. The capture addon recorded only whitelisted game metadata and package URL/timestamp, not request headers, account tokens, or full response bodies.

## Current API metadata

Catalog and detail requests returned HTTP 200:

- Game: `g2041`, Anime All Star
- `engineType=2`, `isNewEngine=1`, `isPublish=1`
- `engineVersion=20046`
- `appVersion/version=4060`

The API records contain no separate package `lastUpdate` field. `createTime` is the game's creation time, not the package update time.

## Fresh package request

The app made a fresh package request after the cached `map_temp/g2041` folder was moved aside:

```text
http://staticgs.sandboxol.com/sandbox/games/engine-resources/g2041.1735114999081.zip
```

The request used HTTP `206` range responses; the completed cache file was:

```text
Mumu: map_temp/g2041/g2041.zip
Size: 32,768,071 bytes
SHA-256: 530CB8826ADB4FD3605C4579D73908A99BFB45DE9E5599193DE4B630740E7E41
```

The SHA-256 matches the original local archive `engine2_packs/g2041/g2041.1735114999081.zip` byte-for-byte. Its filename timestamp is **2024-12-25 08:23:19.081 UTC**. This is the newest `g2041` package currently returned by the app/API as of 2026-10-30; it is not a claim about an unexposed internal content-edit date.

Sanitized capture was retained in the local analysis workspace and is not included in this repository.
