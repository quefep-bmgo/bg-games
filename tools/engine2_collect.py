#!/usr/bin/env python3
import argparse
import datetime as dt
import json
import re
import subprocess
import time
from pathlib import Path
from urllib.parse import urlsplit

ADB = r"C:\Program Files\Netease\MuMuPlayer\nx_main\adb.exe"
SERIAL = "emulator-5554"
SCHEME = "blockmango://com.sandboxol.blockymods/android/page?deep_link_value=gamedetail_{game_id}"
URL_RE = re.compile(r"\.(?P<ms>\d{13})\.zip(?:$|\?)")
ALLOWED_HOSTS = {"staticgs.sandboxol.com", "static.sandboxol.com", "bstaticgs.sandboxol.com"}


def adb(*args, timeout=30):
    return subprocess.run(
        [ADB, "-s", SERIAL, *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
    )


def line_count(path):
    if not path.exists():
        return 0
    with path.open("rb") as f:
        return sum(1 for _ in f)


def scan_log(path, offset):
    found = {}
    if not path.exists():
        return found
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for index, line in enumerate(f):
            if index < offset:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            url = event.get("url", "")
            parsed = urlsplit(url)
            if parsed.scheme not in {"http", "https"} or (parsed.hostname or "").lower() not in ALLOWED_HOSTS:
                continue
            if "/engine-resources/" not in parsed.path and "/editorfile/" not in parsed.path:
                continue
            match = URL_RE.search(parsed.path)
            if not match:
                continue
            # Catalog only the public static path; never propagate query-string credentials.
            safe_url = f"{parsed.scheme}://{parsed.netloc}{parsed.path}"
            found[safe_url] = int(match.group("ms"))
    return found


def collect(game_id, log, wait_detail, wait_start, tap_x, tap_y, retries):
    offset = line_count(log)
    adb("shell", "am", "force-stop", "com.sandboxol.blockymods")
    time.sleep(1)
    adb(
        "shell",
        "am",
        "start",
        "-a",
        "android.intent.action.VIEW",
        "-d",
        SCHEME.format(game_id=game_id),
    )
    time.sleep(wait_detail)
    top = adb("shell", "dumpsys", "activity", "activities").stdout
    if "GameDetailTemplateActivity" not in top:
        time.sleep(wait_detail)
        top = adb("shell", "dumpsys", "activity", "activities").stdout
    found = {}
    for attempt in range(retries):
        if "GameDetailTemplateActivity" in top:
            adb("shell", "input", "tap", str(tap_x), str(tap_y))
        time.sleep(wait_start)
        found = scan_log(log, offset)
        if found:
            break
        if attempt + 1 < retries:
            adb("shell", "input", "keyevent", "KEYCODE_BACK")
            time.sleep(1)
            adb(
                "shell",
                "am",
                "start",
                "-a",
                "android.intent.action.VIEW",
                "-d",
                SCHEME.format(game_id=game_id),
            )
            time.sleep(wait_detail)
            top = adb("shell", "dumpsys", "activity", "activities").stdout
    adb("shell", "am", "force-stop", "com.sandboxol.blockymods")
    if not found:
        return game_id, None, None
    url = max(found, key=found.get)
    ms = found[url]
    stamp = dt.datetime.fromtimestamp(ms / 1000, tz=dt.timezone.utc)
    return game_id, url, stamp.isoformat()


def main():
    global ADB, SERIAL
    parser = argparse.ArgumentParser()
    parser.add_argument("--ids", required=True)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--adb", default=ADB, help="Path to adb.exe")
    parser.add_argument("--serial", default=SERIAL, help="ADB device serial or host:port")
    parser.add_argument("--wait-detail", type=float, default=7)
    parser.add_argument("--wait-start", type=float, default=7)
    parser.add_argument("--tap-x", type=int, default=450)
    parser.add_argument("--tap-y", type=int, default=1490)
    parser.add_argument("--retries", type=int, default=2)
    args = parser.parse_args()
    ADB, SERIAL = args.adb, args.serial
    ids = [x.strip() for x in args.ids.split(",") if x.strip()]
    write_header = not args.out.exists() or args.out.stat().st_size == 0
    with args.out.open("a", encoding="utf-8") as out:
        if write_header:
            out.write("game_id\turl\tlast_updated_utc\n")
        for game_id in ids:
            row = collect(
                game_id,
                args.log,
                args.wait_detail,
                args.wait_start,
                args.tap_x,
                args.tap_y,
                args.retries,
            )
            out.write("\t".join("" if value is None else str(value) for value in row) + "\n")
            out.flush()
            print("\t".join("" if value is None else str(value) for value in row), flush=True)


if __name__ == "__main__":
    main()
