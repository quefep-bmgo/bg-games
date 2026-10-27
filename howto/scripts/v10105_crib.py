#!/usr/bin/env python3
"""Crib-based v10105 decoder with majority-vote symbol tables.

Each triple independently encodes p0=(b0,b1>>4) and p1=(b2,b1&7), so a crib
that is mostly identical yields a reliable symbol->byte table by majority vote.
Plaintext layout: [source]["--[[<random>--]]"], so the source end is visible.
"""
from __future__ import annotations

import collections
import hashlib
import json
import os
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

PKG = r"C:\Users\quefep\AppData\Local\Temp\opencode\recover\packages"
OUT = r"C:\Users\quefep\Desktop\Decomp Temp\recover\out"
ENG = r"C:\Users\quefep\AppData\Local\Temp\opencode\bmg_extract\engine10096\engine-v10096-client-debug\client\Media\Scripts\Engine\lua"
PLAIN = [("g1019", "v%05d" % i) for i in range(10068, 10104)] + [("g1042", "v10103")]


def get_ct(g, rel):
    z = zipfile.ZipFile(os.path.join(PKG, g, "v10105", "plugin.zip"))
    return z.read(rel)


def candidates(g, rel):
    seen = set()

    def emit(tag, b):
        h = hashlib.md5(b).hexdigest()
        if h in seen:
            return False
        seen.add(h)
        return True

    for gg, vv in PLAIN:
        p = os.path.join(PKG, gg, vv, "plugin.zip")
        if not os.path.exists(p):
            continue
        z = zipfile.ZipFile(p)
        for key in (rel, rel[4:] if rel.startswith("lua/") else "lua/" + rel):
            if key in z.namelist():
                b = z.read(key)
                if emit("%s/%s" % (gg, vv), b):
                    yield "%s/%s" % (gg, vv), b
    for gg in os.listdir(OUT):
        gd = os.path.join(OUT, gg)
        if not os.path.isdir(gd):
            continue
        for vv in os.listdir(gd):
            sp = os.path.join(gd, vv, "source", rel)
            if os.path.exists(sp):
                b = open(sp, "rb").read()
                if emit("%s/%s/out" % (gg, vv), b):
                    yield "%s/%s/out" % (gg, vv), b
    p = os.path.join(ENG, rel[4:] if rel.startswith("lua/") else rel)
    if os.path.exists(p):
        b = open(p, "rb").read()
        if emit("engine10096", b):
            yield "engine10096", b


def align_score(crib, ct, off):
    j = off
    m = {}
    matched = total = 0
    for i in range(0, len(crib) - 1, 2):
        if j + 3 > len(ct):
            break
        pair = crib[i:i + 2]
        trip = ct[j:j + 3]
        if pair in m:
            if m[pair] == trip:
                matched += 1
        else:
            m[pair] = trip
            matched += 1
        total += 1
        j += 3
    return matched, total


def best_align(crib, ct):
    best = None
    for off in range(0, 241):
        matched, total = align_score(crib, ct, off)
        if total < 10:
            continue
        key = (matched / total, total)
        if best is None or key > best[0]:
            best = (key, off, total)
    return best


def vote_tables(crib, ct, off):
    v0 = collections.defaultdict(collections.Counter)
    v1 = collections.defaultdict(collections.Counter)
    j = off
    for i in range(0, len(crib) - 1, 2):
        if j + 3 > len(ct):
            break
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        v0[(b0, b1 >> 4)][crib[i]] += 1
        v1[(b2, b1 & 7)][crib[i + 1]] += 1
        j += 3
    t0 = {k: c.most_common(1)[0][0] for k, c in v0.items()}
    t1 = {k: c.most_common(1)[0][0] for k, c in v1.items()}
    return t0, t1


def decode(ct, off, t0, t1):
    out = []
    j = off
    while j + 3 <= len(ct):
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        out.append(t0.get((b0, b1 >> 4), 0x100))
        out.append(t1.get((b2, b1 & 7), 0x100))
        j += 3
    return out


def try_decode(g, rel, crib_tag, crib, verbose=True):
    ct = get_ct(g, rel)
    r = best_align(crib, ct)
    if not r:
        return None
    (rate, total), off, _ = r
    t0, t1 = vote_tables(crib, ct, off)
    dec = decode(ct, off, t0, t1)
    txt = "".join("?" if v > 255 else chr(v) for v in dec)
    return {"off": off, "rate": rate, "total": total, "dec": dec, "txt": txt,
            "t0": t0, "t1": t1}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "targets"
    if mode == "validate":
        # validate on known files using cribs from other-content versions
        tests = [("g1019", "lua/server/Match.lua"),
                 ("g1019", "lua/engine_base/hotupdate/hotupdatelist.lua"),
                 ("g1042", "lua/engine_base/util/StringUtil.lua"),
                 ("g1019", "lua/plugins/new_vip/new_vip.lua")]
        for g, rel in tests:
            truth = open(os.path.join(OUT, g, "v10105", "source", rel), "rb").read()
            best = None
            for tag, crib in candidates(g, rel):
                if crib == truth:
                    continue
                r = try_decode(g, rel, tag, crib)
                if r and (best is None or (r["rate"], r["total"]) > (best[1]["rate"], best[1]["total"])):
                    best = (tag, r)
            if not best:
                print("no crib", g, rel)
                continue
            tag, r = best
            dec = r["dec"]
            marker = r["txt"].rfind("--[[")
            cand = bytes(v if v <= 255 else 0 for v in dec[:marker])
            oklen = len(cand) == len(truth)
            print("%s %s crib=%s off=%d rate=%.3f marker=%d len %d vs %d exact=%s" %
                  (g, rel, tag, r["off"], r["rate"], marker, len(cand), len(truth), cand == truth))
            if not cand == truth and oklen:
                diffs = [(i, cand[i], truth[i]) for i in range(len(cand)) if cand[i] != truth[i]]
                print("   diffs", len(diffs), diffs[:10])
        return
    A = json.load(open(os.path.join(OUT, "..", "V10105_AUDIT.json")))
    for g, ms in A["missing"]:
        for rel in ms:
            best = None
            for tag, crib in candidates(g, rel):
                r = try_decode(g, rel, tag, crib)
                if r and (best is None or (r["rate"], r["total"]) > (best[1]["rate"], best[1]["total"])):
                    best = (tag, r)
            if not best:
                print("== %s %s : no crib" % (g, rel))
                continue
            tag, r = best
            print("== %s %s crib=%s off=%d rate=%.3f total=%d" % (g, rel, tag, r["off"], r["rate"], r["total"]))
            print("   unk=%d head=%r" % (sum(1 for v in r["dec"] if v > 255), r["txt"][:100]))
            print("   tail=%r" % r["txt"][-140:])


if __name__ == "__main__":
    main()
