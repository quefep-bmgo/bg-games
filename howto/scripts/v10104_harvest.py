#!/usr/bin/env python3
"""Harvest the global v10104 byte S-box from known plaintext and decode packages.

v10104 format: every source byte b is replaced by SBOX[b] (length preserved).
We harvest (cipher, plain) pairs from same-path sources in adjacent versions,
enforce that the map is a single-valued function cipher->plain, then decode
every .lua member and verify against the source MD5 checksum list embedded in
lua/sandboxol (base64 of "<md5> *<path>" lines).
"""
from __future__ import annotations

import argparse
import base64
import collections
import hashlib
import json
import os
import re
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
PKG_ROOT = r"C:\Users\quefep\AppData\Local\Temp\opencode\recover\packages"
OUT_ROOT = r"C:\Users\quefep\Desktop\Decomp Temp\recover\out"
SBOX_JSON = r"C:\Users\quefep\Desktop\Decomp Temp\aliens_attack\tools\v10104_sbox.json"


def md5(b):
    return hashlib.md5(b).hexdigest()


def parse_checksums(z):
    """Return {path: md5hex} from lua/sandboxol (base64 text after 1-byte prefix)."""
    if "lua/sandboxol" not in z.namelist():
        return {}
    raw = z.read("lua/sandboxol")
    s = raw[1:]
    s += b"=" * ((4 - len(s) % 4) % 4)
    try:
        txt = base64.b64decode(s, validate=False)
    except Exception:
        return {}
    out = {}
    for line in txt.split(b"\n"):
        m = re.match(rb"^([0-9a-f]{32}) \*(.+?)\s*$", line)
        if m:
            out[m.group(2).decode("utf-8", "replace")] = m.group(1).decode()
    return out


def load_known():
    d = json.load(open(SBOX_JSON, encoding="utf-8"))
    return {int(k): v for k, v in d["cipher_to_plain"].items()}


def candidates_for(game, ver, rel):
    """Yield plaintext candidates for rel from adjacent versions / games."""
    vers = ["v10103", "v10105", "v10106", "v10104"]
    games = [game, "g1019", "g1042", "g1048", "g1100"]
    for g in games:
        for v in vers:
            if (g, v) == (game, ver):
                continue
            p = os.path.join(OUT_ROOT, g, v, "source", rel)
            if os.path.exists(p):
                try:
                    yield ("%s/%s" % (g, v), open(p, "rb").read())
                except OSError:
                    pass


def harvest(game, ver, z, known, verbose=True):
    sbox = dict(known)
    conflict = collections.Counter()
    added_rounds = 0
    for _ in range(4):
        added = 0
        for n in sorted(z.namelist()):
            if not n.endswith(".lua"):
                continue
            rel = n
            ct = z.read(n)
            for tag, pt in candidates_for(game, ver, rel):
                if len(pt) != len(ct):
                    continue
                ok = True
                new = {}
                for c, p in zip(ct, pt):
                    if c in sbox:
                        if sbox[c] != p:
                            ok = False
                            break
                    elif c in new and new[c] != p:
                        ok = False
                        break
                    else:
                        new[c] = p
                if not ok or not new:
                    continue
                sbox.update(new)
                added += len(new)
        added_rounds += added
        if verbose:
            print("  round done: +%d pairs (total %d/256)" % (added, len(sbox)))
        if not added:
            break
    # report conflicts if any candidate disagrees with final map
    for n in sorted(z.namelist()):
        if not n.endswith(".lua"):
            continue
        ct = z.read(n)
        for tag, pt in candidates_for(game, ver, n):
            if len(pt) != len(ct):
                continue
            bad = sum(1 for c, p in zip(ct, pt) if c in sbox and sbox[c] != p)
            if bad and bad < len(ct) * 0.02:
                conflict[(tag, bad)] += 1
    return sbox, conflict


def decode(ct, sbox):
    return bytes(sbox.get(b, b) for b in ct)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True)
    ap.add_argument("--version", required=True)
    ap.add_argument("--write", action="store_true")
    ap.add_argument("--sbox-out", default="")
    args = ap.parse_args()

    zp = os.path.join(PKG_ROOT, args.game, args.version, "plugin.zip")
    z = zipfile.ZipFile(zp)
    checks = parse_checksums(z)
    print("== %s %s: %d members, %d checksums" % (args.game, args.version, len(z.namelist()), len(checks)))

    known = load_known()
    sbox, conflicts = harvest(args.game, args.version, z, known)
    print("sbox coverage: %d/256" % len(sbox))
    missing = [c for c in range(256) if c not in sbox]
    print("missing cipher bytes:", [hex(c) for c in missing])
    if conflicts:
        print("suspect candidates:", list(conflicts.items())[:5])
    if args.sbox_out:
        json.dump({str(k): v for k, v in sorted(sbox.items())}, open(args.sbox_out, "w"), indent=1)

    stats = collections.Counter()
    ok_files, bad_files = [], []
    for n in sorted(z.namelist()):
        if not n.endswith(".lua"):
            continue
        ct = z.read(n)
        src = decode(ct, sbox)
        exp = checks.get(n)
        if exp is None:
            for pref in ("Scripts/Engine/", "Scripts/", "Engine/"):
                if pref + n in checks:
                    exp = checks[pref + n]
                    break
        if exp is None:
            stats["no_checksum"] += 1
            continue
        got = md5(src)
        if got == exp:
            stats["md5_ok"] += 1
            ok_files.append(n)
        else:
            stats["md5_bad"] += 1
            bad_files.append((n, got, exp, sum(1 for b in ct if b not in sbox)))
    print("validation:", dict(stats))
    print("bad examples:", bad_files[:5])

    if args.write:
        out = os.path.join(OUT_ROOT, args.game, args.version, "source")
        os.makedirs(out, exist_ok=True)
        man = {"game": args.game, "version": args.version, "format": "v10104-byte-substitution",
               "sbox_coverage": len(sbox), "files": {}}
        for n in sorted(z.namelist()):
            if not n.endswith(".lua"):
                continue
            ct = z.read(n)
            src = decode(ct, sbox)
            p = os.path.join(out, n)
            os.makedirs(os.path.dirname(p), exist_ok=True)
            open(p, "wb").write(src)
            exp = checks.get(n)
            man["files"][n] = {"md5": md5(src), "expected": exp,
                               "ok": (md5(src) == exp) if exp else None}
        json.dump(man, open(os.path.join(OUT_ROOT, args.game, args.version, "MANIFEST.json"), "w"), indent=1)
        print("wrote", out)


if __name__ == "__main__":
    main()
