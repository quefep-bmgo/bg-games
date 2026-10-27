#!/usr/bin/env python3
"""Recover v10105 unique files by searching edit subsets between known versions.

For a pair of known versions (A,B) we build candidates by applying subsets of
B's edits to A, then keep candidates whose pair->triple map against the v10105
ciphertext has zero conflicts (the decisive oracle).  Candidate length is
constrained by the stream length and the 18..59 byte trailer.
"""
from __future__ import annotations

import difflib
import hashlib
import itertools
import json
import os
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v10105_crib as C

PKG = C.PKG
OUT = C.OUT


def conflicts(text, ct, off, limit=1):
    m = {}
    conf = 0
    j = off
    for i in range(0, len(text) - 1, 2):
        if j + 3 > len(ct):
            break
        pair = text[i:i + 2]
        trip = ct[j:j + 3]
        old = m.get(pair)
        if old is None:
            m[pair] = trip
        elif old != trip:
            conf += 1
            if conf >= limit:
                return conf
        j += 3
    return conf


def known_versions(game, rel):
    """Yield (tag, bytes) for all known same-rel plaintexts."""
    seen = set()

    def emit(tag, b):
        h = hashlib.md5(b).hexdigest()
        if h in seen:
            return False
        seen.add(h)
        return True

    # plaintext packs
    for g, v in C.PLAIN:
        p = os.path.join(PKG, g, v, "plugin.zip")
        if not os.path.exists(p):
            continue
        z = zipfile.ZipFile(p)
        for key in (rel, rel[4:] if rel.startswith("lua/") else "lua/" + rel):
            if key in z.namelist():
                b = z.read(key)
                if emit("%s/%s" % (g, v), b):
                    yield "%s/%s" % (g, v), b
    # recovered
    for g in os.listdir(OUT):
        gd = os.path.join(OUT, g)
        if not os.path.isdir(gd):
            continue
        for v in os.listdir(gd):
            sp = os.path.join(gd, v, "source", rel)
            if os.path.exists(sp):
                b = open(sp, "rb").read()
                if emit("%s/%s/out" % (g, v), b):
                    yield "%s/%s/out" % (g, v), b
    # other repo games
    GM = r"C:\Users\quefep\Desktop\Decomp Temp\games"
    if os.path.isdir(GM):
        for g in os.listdir(GM):
            gp = os.path.join(GM, g)
            if not os.path.isdir(gp):
                continue
            for v in os.listdir(gp):
                zp = os.path.join(gp, v, "plugin.zip")
                if not os.path.exists(zp):
                    continue
                try:
                    z = zipfile.ZipFile(zp)
                except Exception:
                    continue
                for key in (rel, rel[4:] if rel.startswith("lua/") else "lua/" + rel):
                    if key in z.namelist():
                        b = z.read(key)
                        if b and (b[:3] == b"---" or b[:5] == b"local" or b[:2] == b"--"):
                            tag = "%s/%s" % (g, v)
                            if emit(tag, b):
                                yield tag, b


def length_ok(L, ct, off):
    n = (len(ct) - off) // 3
    total = 2 * n
    pad = total - L
    return 16 <= pad <= 61


def apply_edits(A, B, ops, mask):
    T = bytearray(A)
    for k, op in reversed(list(enumerate(ops))):
        if not (mask >> k) & 1:
            continue
        tag, i1, i2, j1, j2 = op
        if tag == "equal":
            continue
        T[i1:i2] = B[j1:j2]
    return bytes(T)


def candidate_offsets(ct):
    out = []
    for off in range(13, 61):
        if ct[off - 1] == 0 and ct[0] in range(5, 11):
            out.append(off)
    return out or [off for off in range(13, 61) if ct[off - 1] == 0]


def solve(game, rel, max_ops=14, verbose=True):
    z = zipfile.ZipFile(os.path.join(PKG, game, "v10105", "plugin.zip"))
    ct = z.read(rel)
    offs = candidate_offsets(ct)
    vers = list(known_versions(game, rel))
    hits = []
    # single versions
    for tag, b in vers:
        for off in offs:
            if conflicts(b, ct, off) == 0:
                hits.append((tag, b, off, "single"))
    # pairs
    pairs = 0
    for (ta, A), (tb, B) in itertools.combinations(vers, 2):
        sm = difflib.SequenceMatcher(None, A, B, autojunk=False)
        ops = [op for op in sm.get_opcodes() if op[0] != "equal"]
        if not ops or len(ops) > max_ops:
            continue
        # skip pairs with huge rewrite ratio
        span = sum(max(i2 - i1, j2 - j1) for _, i1, i2, j1, j2 in ops)
        if span > max(len(A), len(B)) * 0.6:
            continue
        pairs += 1
        for mask in range(1 << len(ops)):
            T = apply_edits(A, B, ops, mask)
            if not any(length_ok(len(T), ct, off) for off in offs):
                continue
            for off in offs:
                if conflicts(T, ct, off) == 0:
                    hits.append(("%s|%s#%d" % (ta, tb, mask), T, off, "edit"))
                    if verbose:
                        print("   HIT", ta, tb, "mask", mask, "len", len(T), "off", off,
                              "md5", hashlib.md5(T).hexdigest()[:10])
                    break
            if hits:
                break
        if hits:
            break
    if verbose:
        print("   %s %s: versions %d pairs %d hits %d" % (game, rel, len(vers), pairs, len(hits)))
    return hits, ct


def main():
    A = json.load(open(os.path.join(OUT, "..", "V10105_AUDIT.json")))
    targets = []
    for g, ms in A["missing"]:
        for rel in ms:
            if (g, rel) not in targets:
                targets.append((g, rel))
    for g, rel in targets:
        print("== %s %s" % (g, rel))
        hits, ct = solve(g, rel)
        for tag, T, off, kind in hits[:3]:
            print("   candidate %-30s len=%-6d md5=%-12s" % (tag, len(T), hashlib.md5(T).hexdigest()[:12]))


if __name__ == "__main__":
    main()
