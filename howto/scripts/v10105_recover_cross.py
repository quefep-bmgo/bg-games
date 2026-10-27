#!/usr/bin/env python3
"""Recover remaining v10105 files using the full plaintext corpus.

Every v10105 plugin ships checksums.md5 (plaintext "md5 *path" lines).  For each
still-missing .lua member we look up its expected source md5 anywhere in the
corpus (plaintext packs g1019 v10068-v10103 / g1042 v10103, recovered sources
under out/), then verify the v10105 2->3 byte encoding.  Fallback: same-relative
path candidates from the plaintext packs, verified by encoding consistency.

Only writes files that are currently missing; existing recoveries are untouched.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract import find_pair_offset, verify_pair_encode  # noqa: E402

PKG = r"C:\Users\quefep\AppData\Local\Temp\opencode\recover\packages"
OUT = r"C:\Users\quefep\Desktop\Decomp Temp\recover\out"
TARGETS = [("g1019", "v10105"), ("g1042", "v10105"), ("g1048", "v10105")]
PLAIN_ZIPS = (
    [("g1019", "v%05d" % i) for i in list(range(10068, 10104))]
    + [("g1042", "v10103")]
)
CACHE = {}


def md5(b):
    return hashlib.md5(b).hexdigest()


def zread(game, ver, name):
    key = (game, ver)
    if key not in CACHE:
        p = os.path.join(PKG, game, ver, "plugin.zip")
        CACHE[key] = zipfile.ZipFile(p) if os.path.exists(p) else None
    z = CACHE[key]
    if z is None or name not in z.namelist():
        return None
    return z.read(name)


def parse_checksums(z):
    out = {}
    if "checksums.md5" not in z.namelist():
        return out
    txt = z.read("checksums.md5")
    for line in txt.replace(b"\r\n", b"\n").split(b"\n"):
        m = re.match(rb"^([0-9a-f]{32}) \*(.+?)\s*$", line)
        if m:
            out[m.group(2).decode("utf-8", "replace")] = m.group(1).decode()
    return out


def out_dirs():
    dirs = []
    for g in os.listdir(OUT):
        gp = os.path.join(OUT, g)
        if not os.path.isdir(gp):
            continue
        for v in os.listdir(gp):
            sp = os.path.join(gp, v, "source")
            if os.path.isdir(sp):
                dirs.append((g, v, sp))
    return dirs


def collect_missing():
    miss = []
    for game, ver in TARGETS:
        z = zipfile.ZipFile(os.path.join(PKG, game, ver, "plugin.zip"))
        checks = parse_checksums(z)
        lua = sorted(n for n in z.namelist() if n.endswith(".lua"))
        for rel in lua:
            if os.path.exists(os.path.join(OUT, game, ver, "source", rel)):
                continue
            miss.append((game, ver, rel, checks.get(rel)))
    return miss


def main():
    deps = out_dirs()
    miss = collect_missing()
    print("missing v10105 files:", len(miss))
    wanted = {e for _, _, _, e in miss if e}
    print("distinct expected md5s:", len(wanted))

    index = {}
    scanned = 0
    for game, ver in PLAIN_ZIPS:
        zp = os.path.join(PKG, game, ver, "plugin.zip")
        if not os.path.exists(zp):
            continue
        z = zipfile.ZipFile(zp)
        for n in z.namelist():
            if not n.endswith(".lua"):
                continue
            b = z.read(n)
            scanned += 1
            h = md5(b)
            if h in wanted and h not in index:
                index[h] = ("pack %s/%s:%s" % (game, ver, n), b)
    for g, v, sp in deps:
        for root, _, files in os.walk(sp):
            for fn in files:
                if not fn.endswith(".lua"):
                    continue
                p = os.path.join(root, fn)
                try:
                    b = open(p, "rb").read()
                except OSError:
                    continue
                scanned += 1
                h = md5(b)
                if h in wanted and h not in index:
                    index[h] = ("out %s/%s:%s" % (g, v, os.path.relpath(p, sp)), b)
    print("scan:", scanned, "corpus files; resolved by md5:", len(index))

    recovered = []
    fallback = []
    still = []
    for game, ver, rel, exp in miss:
        ct = zread(game, ver, rel)
        hit = None
        src = index.get(exp) if exp else None
        if src is not None:
            tag, b = src
            r = find_pair_offset(b, ct)
            if r and verify_pair_encode(b, ct, r[0], r[1]):
                hit = (b, {"method": "checksum-md5+2to3-verify", "source": tag,
                           "expected_md5": exp, "md5": md5(b), "ok": True, "offset": r[0]})
        if hit is None:
            seen = set()
            for g, v in PLAIN_ZIPS:
                b = zread(g, v, rel)
                if b is None:
                    continue
                h = md5(b)
                if h in seen:
                    continue
                seen.add(h)
                if not (0.25 * len(ct) <= len(b) <= 0.85 * len(ct)):
                    continue
                r = find_pair_offset(b, ct)
                if r and r[1] >= max(2, len(b) // 2 - 2) and verify_pair_encode(b, ct, r[0], r[1]):
                    hit = (b, {"method": "same-path-plaintext-2to3", "source": "%s/%s" % (g, v),
                               "expected_md5": exp, "md5": h, "ok": (h == exp) if exp else None,
                               "offset": r[0]})
                    break
            if hit is None:
                for g, v, sp in deps:
                    p = os.path.join(sp, rel)
                    if not os.path.exists(p):
                        continue
                    b = open(p, "rb").read()
                    h = md5(b)
                    if h in seen or not (0.25 * len(ct) <= len(b) <= 0.85 * len(ct)):
                        continue
                    seen.add(h)
                    r = find_pair_offset(b, ct)
                    if r and r[1] >= max(2, len(b) // 2 - 2) and verify_pair_encode(b, ct, r[0], r[1]):
                        hit = (b, {"method": "same-path-corpus-2to3", "source": "%s/%s" % (g, v),
                                   "expected_md5": exp, "md5": h, "ok": (h == exp) if exp else None,
                                   "offset": r[0]})
                        break
        if hit is None:
            still.append([game, ver, rel, exp])
            continue
        b, info = hit
        dest = os.path.join(OUT, game, ver, "source", rel)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        open(dest, "wb").write(b)
        info.update({"game": game, "version": ver, "rel": rel, "size": len(b)})
        recovered.append(info)

    print("recovered now:", len(recovered), "still missing:", len(still))
    if recovered:
        json.dump(recovered, open(os.path.join(OUT, "..", "RECOVERED_V10105_CROSS.json"), "w"), indent=1)
        for r in recovered[:10]:
            print("  ", r["game"], r["rel"], r["md5"], r["ok"])
    if still:
        json.dump(still, open(os.path.join(OUT, "..", "STILL_MISSING_V10105.json"), "w"), indent=1)
        print("  still examples:", still[:5])


if __name__ == "__main__":
    main()
