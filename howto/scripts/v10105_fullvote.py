#!/usr/bin/env python3
"""Full-alignment iterative v10105 decoder (final method).

1. initial tables: positional crib votes
2. decode
3. align crib to decoded text (difflib), vote from *all* aligned positions (not
   just equal blocks), fall back to initial votes for uncovered symbols
4. repeat; the target MD5 validates.
"""
from __future__ import annotations

import collections
import difflib
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v10105_crib as C


def syms_of(ct, off):
    s = []
    j = off
    while j + 3 <= len(ct):
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        s.append((b0, b1 >> 4, 0))
        s.append((b2, b1 & 7, 1))
        j += 3
    return s


def decode_stream(ct, off, t0, t1, syms=None):
    syms = syms or syms_of(ct, off)
    return [(t0 if sym[2] == 0 else t1).get((sym[0], sym[1]), 0x100) for sym in syms]


def initial_tables(crib, ct, off, syms, s=0):
    v0 = collections.defaultdict(collections.Counter)
    v1 = collections.defaultdict(collections.Counter)
    for j, ch in enumerate(crib):
        t = s + j
        if t >= len(syms):
            break
        sym = syms[t]
        (v0 if sym[2] == 0 else v1)[(sym[0], sym[1])][ch] += 1
    return ({k: x.most_common(1)[0][0] for k, x in v0.items()},
            {k: x.most_common(1)[0][0] for k, x in v1.items()})


def vote_full(crib, T, syms, s=0):
    c = crib.decode("latin1")
    t0 = collections.defaultdict(collections.Counter)
    t1 = collections.defaultdict(collections.Counter)
    sm = difflib.SequenceMatcher(None, c, T, autojunk=False)
    for tag, a1, a2, b1, b2 in sm.get_opcodes():
        if tag == "insert":
            continue
        n = min(a2 - a1, b2 - b1)
        for k in range(n):
            ci = a1 + k
            ti = b1 + k
            pos = s + ti
            if pos < len(syms):
                sym = syms[pos]
                (t0 if sym[2] == 0 else t1)[(sym[0], sym[1])][ord(c[ci])] += 1
    return ({k: x.most_common(1)[0][0] for k, x in t0.items()},
            {k: x.most_common(1)[0][0] for k, x in t1.items()})


def decode_file(g, rel, crib, off, rounds=8):
    ct = C.get_ct(g, rel)
    syms = syms_of(ct, off)
    i0, i1 = initial_tables(crib, ct, off, syms)
    t0, t1 = dict(i0), dict(i1)
    d = decode_stream(ct, off, t0, t1, syms)
    for _ in range(rounds):
        txt = "".join("?" if x > 255 else chr(x) for x in d)
        m = txt.rfind("--[[")
        if m <= 0:
            break
        T = txt[:m]
        a0, a1 = vote_full(crib, T, syms)
        for k, v in i0.items():
            a0.setdefault(k, v)
        for k, v in i1.items():
            a1.setdefault(k, v)
        if a0 == t0 and a1 == t1:
            break
        t0, t1 = a0, a1
        d = decode_stream(ct, off, t0, t1, syms)
    txt = "".join("?" if x > 255 else chr(x) for x in d)
    m = txt.rfind("--[[")
    L = m if m > 0 else len(d)
    src = bytes(x if x <= 255 else 0 for x in d[:L])
    return src, L, d, syms, t0, t1


def conflict_count(src, ct, off):
    m = {}
    conf = 0
    j = off
    n = len(src) if len(src) % 2 == 0 else len(src) - 1
    i = 0
    while i + 1 < n:
        if j + 3 > len(ct):
            break
        pair = (src[i], src[i + 1])
        trip = ct[j:j + 3]
        old = m.get(pair)
        if old is None:
            m[pair] = trip
        elif old != trip:
            conf += 1
        i += 2
        j += 3
    return conf


def best_off_and_crib(g, rel):
    ct = C.get_ct(g, rel)
    best = None
    for tag, crib in C.candidates(g, rel):
        for off in range(13, 61):
            if ct[off - 1] != 0:
                continue
            m, t = C.align_score(crib, ct, off)
            if t < 10:
                continue
            rate = m / t
            if best is None or (rate, t) > (best[1], best[2]):
                best = (tag, rate, t, off, crib)
    return best


def main():
    A = json.load(open(os.path.join(C.OUT, "..", "V10105_AUDIT.json")))
    targets = {}
    for g, ms in A["missing"]:
        for rel in ms:
            targets[(g, rel)] = None
    report = []
    for (g, rel) in list(targets):
        best = best_off_and_crib(g, rel)
        if not best:
            print("== %s %s no crib" % (g, rel))
            continue
        tag, rate, total, off, crib = best
        src, L, d, syms, t0, t1 = decode_file(g, rel, crib, off)
        ct = C.get_ct(g, rel)
        conf = conflict_count(src, ct, off)
        h = hashlib.md5(src).hexdigest()
        print("== %-5s %-52s crib=%-18s off=%-3d len=%-5d conf=%-3d md5=%s" %
              (g, rel, tag, off, L, conf, h[:10]))
        report.append({"game": g, "rel": rel, "crib": tag, "off": off, "len": L,
                       "conf": conf, "md5": h})
    json.dump(report, open(os.path.join(C.OUT, "..", "V10105_FULLVOTE.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
