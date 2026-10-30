# Engine2 game archive and local runtime

This section documents how to identify, capture, verify, and run Blockman GO Engine2 game packages with an older local Engine2 instance. Engine2 packages are separate from the encrypted engine1 `res.pack` workflow in [`../howto/`](../howto/).

## Documents

| File | Covers |
|---|---|
| [`01-discovery-and-versioning.md`](01-discovery-and-versioning.md) | g2xxx catalog API, Engine2 selection, package timestamps, latest-version checks. |
| [`02-capture-and-download.md`](02-capture-and-download.md) | Normal app request capture, safe URL-only logging, ZIP download and hash verification. |
| [`03-package-layout.md`](03-package-layout.md) | Engine2 ZIP structure, config bundle precedence, checksums, assets and client/server content. |
| [`04-run-on-older-runtime.md`](04-run-on-older-runtime.md) | Mounting a game package in an older local Engine2 server/client and compatibility checks. |
| [`05-g2041-case-study.md`](05-g2041-case-study.md) | Anime All Star package captured from the API on 2026-10-30. |

The small capture addon in [`scripts/capture_package_url.py`](scripts/capture_package_url.py) logs only whitelisted game metadata and public static ZIP URLs. It never records request headers, signatures, account tokens, or full response bodies.

## Safety and deployment

- Use the installed app's normal catalog/download flow; do not fabricate signed headers or copy account tokens into scripts.
- Local package editing is for an authorized development server. Official Blockman GO live deployment requires approval and server-side publishing by the game operator; client-side files cannot install authoritative gameplay changes.
- Keep original archives immutable and record the base ZIP hash, package URL timestamp, and extracted ZIP hash for every version.
