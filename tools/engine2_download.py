#!/usr/bin/env python3
import argparse
import concurrent.futures
import datetime as dt
import os
import re
import zipfile
from pathlib import Path
from urllib.parse import unquote, urlsplit

import requests

TS_RE = re.compile(r"\.(?P<ms>\d{13})\.zip$")
ALLOWED_HOSTS = {"staticgs.sandboxol.com", "static.sandboxol.com", "bstaticgs.sandboxol.com"}


def read_catalog(path):
    rows = []
    for line in path.read_text(encoding="utf-8-sig").splitlines():
        parts = line.split("\t")
        if len(parts) < 2 or not parts[0]:
            continue
        parsed = urlsplit(parts[1])
        if parsed.scheme not in {"http", "https"} or (parsed.hostname or "").lower() not in ALLOWED_HOSTS:
            continue
        if not parsed.path.lower().endswith(".zip") or parsed.query or parsed.fragment:
            continue
        rows.append({"game_id": parts[0], "url": parts[1], "last_updated": parts[2] if len(parts) > 2 else ""})
    return rows


def filename_for(url):
    return unquote(Path(urlsplit(url).path).name)


def download_one(row, dest_root):
    game_dir = dest_root / row["game_id"]
    game_dir.mkdir(parents=True, exist_ok=True)
    target = game_dir / filename_for(row["url"])
    if target.exists() and target.stat().st_size > 0:
        return inspect_pack(row, target)
    part = target.with_suffix(target.suffix + ".part")
    session = requests.Session()
    session.trust_env = False
    last_error = None
    for attempt in range(3):
        try:
            with session.get(row["url"], stream=True, timeout=90) as response:
                response.raise_for_status()
                expected = response.headers.get("content-length")
                with part.open("wb") as out:
                    for chunk in response.iter_content(1024 * 1024):
                        if chunk:
                            out.write(chunk)
                size = part.stat().st_size
                if expected and size != int(expected):
                    raise IOError(f"size {size} != {expected}")
                os.replace(part, target)
                return inspect_pack(row, target)
        except Exception as exc:
            last_error = exc
            if part.exists():
                part.unlink()
    return {**row, "file": str(target), "size": "", "entries": "", "zip_min": "", "zip_max": "", "status": f"error: {last_error}"}


def inspect_pack(row, target):
    result = {**row, "file": str(target), "size": target.stat().st_size, "entries": "", "zip_min": "", "zip_max": "", "status": "ok"}
    try:
        with zipfile.ZipFile(target) as archive:
            infos = archive.infolist()
            result["entries"] = len(infos)
            if infos:
                result["zip_min"] = min(info.date_time for info in infos)
                result["zip_max"] = max(info.date_time for info in infos)
            bad = archive.testzip()
            if bad:
                result["status"] = f"bad_zip_entry: {bad}"
    except Exception as exc:
        result["status"] = f"zip_error: {exc}"
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--catalog", type=Path, required=True)
    parser.add_argument("--dest", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--workers", type=int, default=3)
    args = parser.parse_args()
    rows = read_catalog(args.catalog)
    args.dest.mkdir(parents=True, exist_ok=True)
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(download_one, row, args.dest): row for row in rows}
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            results.append(result)
            print(
                result["game_id"],
                result["status"],
                result.get("size", ""),
                result.get("entries", ""),
                result["url"],
                flush=True,
            )
    order = {row["game_id"]: index for index, row in enumerate(rows)}
    results.sort(key=lambda row: order[row["game_id"]])
    fields = ["game_id", "url", "last_updated", "file", "size", "entries", "zip_min", "zip_max", "status"]
    with args.out.open("w", encoding="utf-8", newline="") as out:
        out.write("\t".join(fields) + "\n")
        for result in results:
            out.write("\t".join(str(result.get(field, "")) for field in fields) + "\n")


if __name__ == "__main__":
    main()
