"""Mitmproxy addon: capture only selected Engine2 game metadata and ZIP URLs.

Environment:
  ENGINE2_GAME_IDS=g2041,g2033
  ENGINE2_UPDATE_OUT=C:\\temp\\engine2-package-capture.jsonl

The addon intentionally does not log request headers, signatures, account tokens, or full response bodies.
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


TARGETS = {
    value.strip().lower()
    for value in os.environ.get("ENGINE2_GAME_IDS", "g2041").split(",")
    if value.strip()
}
OUT = Path(
    os.environ.get(
        "ENGINE2_UPDATE_OUT",
        str(Path.home() / "AppData/Local/Temp/engine2-package-capture.jsonl"),
    )
)
ENGINE_ZIP_RE = re.compile(r"(?:^|/)(?P<game>g[0-9a-z]+)\.(?P<ms>\d{13})\.zip$", re.IGNORECASE)
SAFE_FIELDS = (
    "gameId",
    "gameTitle",
    "engineType",
    "isNewEngine",
    "engineVersion",
    "appVersion",
    "version",
    "isUgcGame",
    "isPublish",
    "createTime",
    "updateTime",
    "lastUpdateTime",
    "resourceVersion",
    "resVersion",
    "gameVersion",
)
SEEN_PACKAGES: set[str] = set()


def _write(record: dict) -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with OUT.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(record, ensure_ascii=False, separators=(",", ":")) + "\n")


def _find_target_records(value):
    records = []
    if isinstance(value, dict):
        game_id = str(value.get("gameId", "")).lower()
        if game_id in TARGETS:
            records.append({key: value[key] for key in SAFE_FIELDS if key in value})
        for child in value.values():
            records.extend(_find_target_records(child))
    elif isinstance(value, list):
        for child in value:
            records.extend(_find_target_records(child))
    return records


def _package_size(response: http.Response) -> int | None:
    content_range = response.headers.get("Content-Range", "")
    match = re.search(r"/(\d+)$", content_range)
    if match:
        return int(match.group(1))
    content_length = response.headers.get("Content-Length")
    if content_length and content_length.isdigit():
        return int(content_length)
    return None


def response(flow: http.HTTPFlow) -> None:
    response = flow.response
    if response is None:
        return

    host = flow.request.host.lower()
    path = urlsplit(flow.request.pretty_url).path
    now = dt.datetime.fromtimestamp(time.time(), dt.timezone.utc).isoformat()

    if "sandboxol.com" in host and "/game/api/" in path:
        try:
            payload = json.loads(response.get_text(strict=False) or "null")
        except (ValueError, UnicodeError):
            payload = None
        records = _find_target_records(payload)
        if records:
            deduplicated = {
                json.dumps(record, sort_keys=True, ensure_ascii=False): record
                for record in records
            }
            _write(
                {
                    "kind": "game_api_metadata",
                    "capturedAtUtc": now,
                    "requestPath": path,
                    "httpStatus": response.status_code,
                    "games": list(deduplicated.values()),
                }
            )

    if host not in {"staticgs.sandboxol.com", "static.sandboxol.com", "bstaticgs.sandboxol.com"}:
        return
    if not path.lower().endswith(".zip"):
        return

    match = ENGINE_ZIP_RE.search(path)
    game_id = match.group("game").lower() if match else None
    if game_id is None:
        # Opaque editor-file ZIP names are associated only when one game is being tested at a time.
        if len(TARGETS) != 1:
            return
        game_id = next(iter(TARGETS))
    if game_id not in TARGETS:
        return

    parsed = urlsplit(flow.request.pretty_url)
    safe_url = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
    if safe_url in SEEN_PACKAGES:
        return
    SEEN_PACKAGES.add(safe_url)

    package_ms = int(match.group("ms")) if match else None
    package_updated = (
        dt.datetime.fromtimestamp(package_ms / 1000, dt.timezone.utc).isoformat()
        if package_ms is not None
        else None
    )
    _write(
        {
            "kind": "game_package",
            "capturedAtUtc": now,
            "gameId": game_id,
            "url": safe_url,
            "httpStatus": response.status_code,
            "totalBytes": _package_size(response),
            "packageTimestampMs": package_ms,
            "packageUpdatedAtUtc": package_updated,
        }
    )
