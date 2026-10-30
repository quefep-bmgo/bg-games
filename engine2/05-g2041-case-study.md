# 05 — Anime All Star (`g2041`) current package check

This case study was refreshed through the normal app flow on **2026-10-30**.

## Current API record

The app's game catalog/detail responses returned:

| Field | Value |
|---|---|
| `gameId` | `g2041` |
| `gameTitle` | Anime All Star |
| `engineType` / `isNewEngine` | `2` / `1` |
| `isPublish` | `1` |
| `engineVersion` | `20046` |
| `appVersion`/detail `version` | `4060` |

The API metadata did not expose a separate package last-edit date.

## Fresh package download

After preserving and moving the cached g2041 folder aside, the app requested:

```text
http://staticgs.sandboxol.com/sandbox/games/engine-resources/g2041.1735114999081.zip
```

The 13-digit package timestamp converts to **2024-12-25 08:23:19.081 UTC**. The completed Mumu download was 32,768,071 bytes with SHA-256:

```text
530CB8826ADB4FD3605C4579D73908A99BFB45DE9E5599193DE4B630740E7E41
```

That hash matches the local archive byte-for-byte. As of the 2026-10-30 app/API request, this is the latest package the service delivered for g2041. The filename timestamp is the package build/upload timestamp, not a claim about the exact date content was edited.

## Older local Engine2 instance

The local older runtime reports Engine2 `20075`; its extracted `res/engine2Version.json` says `20055`, while the current API game record reports `20046`. This is a known version mismatch and may explain some physics differences. The package itself is a plain ZIP with 2,658 original files, not `res.pack`.

The safe local workflow is: keep the original archive immutable, extract to a package-root folder, mount the ZIP and extracted tree in `gameconfig.json`, verify config lookup precedence, then test map collision with the local debug draw. A live Blockman GO deployment still requires the game operator's approval and server-side release.
