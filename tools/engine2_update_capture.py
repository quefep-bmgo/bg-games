"""Mitmproxy addon that records only g2041 package/version metadata.

It intentionally does not log request headers, auth/signature values, or full response bodies.
Run with: mitmdump -p 8081 -s tools/engine2_update_capture.py
"""

from __future__ import annotations

import datetime as dt
import json
import os
import re
import time
from pathlib import Path
from urllib.parse import urlsplit

from mitmproxy import http


OUT = Path(
    os.environ.get(
        "ENGINE2_UPDATE_OUT",
        str(Path.home() / "AppData/Local/Temp/opencode/webview_test/engine2_update_check.jsonl"),
    )
)
ZIP_RE = re.compile(r"(?:^|/)g2041\.(\d{13})\.zip$", re.IGNORECASE)
SAFE_GAME_FIELDS = (
    "gameId",
    "gameTitle",
    "engineType",
    "isNewEngine",
    "engineVersion",
    "appVersion",
    "isUgcGame",
    "isPublish",
    "createTime",
    "updateTime",
    "resourceVersion",
    "version",
)


def _write(record: dict) -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(record, ensure_ascii=False, separators=(",", ":")) + "\n")


def _find_g2041(value):
    found = []
    if isinstance(value, dict):
        if value.get("gameId") == "g2041":
            found.append({key: value[key] for key in SAFE_GAME_FIELDS if key in value})
        for child in value.values():
            found.extend(_find_g2041(child))
    elif isinstance(value, list):
        for child in value:
            found.extend(_find_g2041(child))
    return found


def response(flow: http.HTTPFlow) -> None:
    response = flow.response
    if response is None:
        return

    host = flow.request.host.lower()
    path = urlsplit(flow.request.pretty_url).path
    timestamp = time.time()

    if "sandboxol.com" in host and "/game/api/" in path:
        try:
            payload = json.loads(response.get_text(strict=False) or "null")
        except (ValueError, UnicodeError):
            payload = None
        records = _find_g2041(payload)
        if records:
            _write(
                {
                    "kind": "game_api_metadata",
                    "capturedAtUtc": dt.datetime.fromtimestamp(timestamp, dt.timezone.utc).isoformat(),
                    "requestPath": path,
                    "httpStatus": response.status_code,
                    "g2041": records,
                }
            )

    if host in {"staticgs.sandboxol.com", "static.sandboxol.com", "bstaticgs.sandboxol.com"}:
        match = ZIP_RE.search(path)
        if match:
            package_ms = int(match.group(1))
            parsed = urlsplit(flow.request.pretty_url)
            safe_url = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
            _write(
                {
                    "kind": "game_package",
                    "capturedAtUtc": dt.datetime.fromtimestamp(timestamp, dt.timezone.utc).isoformat(),
                    "url": safe_url,
                    "httpStatus": response.status_code,
                    "bytes": len(response.content or b""),
                    "packageTimestampMs": package_ms,
                    "packageUpdatedAtUtc": dt.datetime.fromtimestamp(
                        package_ms / 1000, dt.timezone.utc
                    ).isoformat(),
                }
            )
