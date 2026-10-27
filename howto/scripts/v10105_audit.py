#!/usr/bin/env python3
"""Final audit of v10105 recoveries.

Checks each recovered source against
  * the 2->3 byte structure: b0 = V0(p0), b2 = V1(p1), b1.hi = S0(p0), b1.lo = S1(p1)
    (any violation proves the candidate is not the encoded plaintext)
  * the trailing-pad length rule learned from 932 sandbox-validated files
    (extra = len(ct)-off-3*ceil(len(src)/2) in {27..87})
  * lua/sandboxol source md5 where present

Files that fail are moved to out/<game>/<version>/_rejected/ (with a note) and
a final MANIFEST is written.
"""
from __future__ import annotations

import base64
import collections
import hashlib
import json
import os
import re
import shutil
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract import find_pair_offset  # noqa: E402

PKG = r"C:\Users\quefep\AppData\Local\Temp\opencode\recover\packages"
OUT = r"C:\Users\quefep\Desktop\Decomp Temp\recover\out"
GAMES = ["g1019", "g1042", "g1048"]
VER = "v10105"
PAD_MIN, PAD_MAX = 27, 87


def md5(b):
    return hashlib.md5(b).hexdigest()


def sandbox_map(z):
    d = {}
    if "lua/sandboxol" not in z.namelist():
        return d
    raw = z.read("lua/sandboxol")
    s = raw[1:] + b"=" * ((4 - len(raw[1:]) % 4) % 4)
    try:
        txt = base64.b64decode(s, validate=False)
    except Exception:
        return d
    for line in txt.replace(b"\r\n", b"\n").split(b"\n"):
        m = re.match(rb"^([0-9a-f]{32}) \*(.+?)\s*$", line)
        if m:
            d[m.group(2).decode()] = m.group(1).decode()
    return d


def structural(src, ct, off):
    """Return (conflicts, checked) for the per-byte function structure."""
    m0, m2 = {}, {}
    conf = 0
    j = off
    n = 0
    for i in range(0, len(src) - 1, 2):
        if j + 3 > len(ct):
            break
        p0, p1 = src[i], src[i + 1]
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        v0 = (b0, b1 >> 4)
        v2 = (b2, b1 & 0x0F)
        if p0 in m0 and m0[p0] != v0:
            conf += 1
        else:
            m0.setdefault(p0, v0)
        if p1 in m2 and m2[p1] != v2:
            conf += 1
        else:
            m2.setdefault(p1, v2)
        j += 3
        n += 1
    return conf, n


def main():
    report = {"generated": None, "games": {}, "quarantined": [], "missing": [],
              "files": []}
    for g in GAMES:
        zp = os.path.join(PKG, g, VER, "plugin.zip")
        z = zipfile.ZipFile(zp)
        sb = sandbox_map(z)
        sd = os.path.join(OUT, g, VER, "source")
        rj = os.path.join(OUT, g, VER, "_rejected")
        stats = collections.Counter()
        for root, _, files in os.walk(sd):
            for fn in files:
                if not fn.endswith(".lua"):
                    continue
                p = os.path.join(root, fn)
                rel = os.path.relpath(p, sd).replace("\\", "/")
                src = open(p, "rb").read()
                ct = z.read(rel)
                r = find_pair_offset(src, ct)
                exp = sb.get("Scripts/Engine/" + rel) or sb.get(rel)
                sbm = "ok" if exp and md5(src) == exp else ("bad" if exp else "none")
                if not r:
                    stats["no_align"] += 1
                    report["quarantined"].append([g, rel, "no_align", sbm])
                    continue
                off, _ = r
                extra = (len(ct) - off) - 3 * ((len(src) + 1) // 2)
                conf, npair = structural(src, ct, off)
                keep = (sbm == "ok") or ((PAD_MIN <= extra <= PAD_MAX) and conf == 0)
                report["files"].append({"game": g, "rel": rel, "md5": md5(src),
                                        "sandbox": sbm, "extra": extra,
                                        "conflicts": conf, "pairs": npair,
                                        "keep": keep})
                if keep:
                    stats["kept"] += 1
                    stats["kept_sandbox_" + sbm] += 1
                else:
                    stats["rejected"] += 1
                    stats["rejected_sandbox_" + sbm] += 1
                    dest = os.path.join(rj, rel)
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    shutil.move(p, dest)
                    report["quarantined"].append([g, rel, {"extra": extra,
                                                           "conflicts": conf,
                                                           "sandbox": sbm}])
        # missing = lua members with no source and no rejected copy
        missing = []
        for n in z.namelist():
            if not n.endswith(".lua"):
                continue
            if os.path.exists(os.path.join(sd, n)) or os.path.exists(os.path.join(rj, n)):
                continue
            missing.append(n)
        report["missing"].append([g, missing])
        report["games"][g] = dict(stats)
        print("==", g, dict(stats), "missing", len(missing))

    # global md5 lookup for still-missing sandbox entries
    wanted = {}
    for g, missing in report["missing"]:
        sb = sandbox_map(zipfile.ZipFile(os.path.join(PKG, g, VER, "plugin.zip")))
        for rel in missing:
            exp = sb.get("Scripts/Engine/" + rel) or sb.get(rel)
            if exp:
                wanted.setdefault(exp, []).append((g, rel))
    print("missing with sandbox checksum:", sum(len(v) for v in wanted.values()))
    if wanted:
        found = {}
        for g in GAMES:
            z = zipfile.ZipFile(os.path.join(PKG, g, VER, "plugin.zip"))
            for n in z.namelist():
                if n.endswith(".lua"):
                    b = z.read(n)
                    h = md5(b)
                    if h in wanted:
                        found.setdefault(h, ("cipher " + g + ":" + n, b))
        for g in GAMES:
            for v in os.listdir(os.path.join(OUT, g)):
                sp = os.path.join(OUT, g, v, "source")
                if not os.path.isdir(sp):
                    continue
                for root, _, files in os.walk(sp):
                    for fn in files:
                        if not fn.endswith(".lua"):
                            continue
                        p = os.path.join(root, fn)
                        b = open(p, "rb").read()
                        h = md5(b)
                        if h in wanted:
                            found.setdefault(h, ("%s/%s:%s" % (g, v, os.path.relpath(p, sp)), b))
        report["missing_md5_hits"] = []
        for h, users in wanted.items():
            if h in found:
                report["missing_md5_hits"].append({"md5": h, "source": found[h][0],
                                                   "targets": users})
        print("missing md5 hits:", [x["source"] for x in report["missing_md5_hits"]])

    json.dump(report, open(os.path.join(OUT, "..", "V10105_AUDIT.json"), "w"), indent=1)
    print("audit written")


if __name__ == "__main__":
    main()
