#!/usr/bin/env python3
"""Multi-crib v10105 decoder (the method that finished the unique files).

For a v10105 ciphertext:
  1. build vote tables from the longest conflict-free prefix of every known
     same-path version (the prefix stops at the first edit, so it is clean);
  2. decode;
  3. align every crib to the decoded text with difflib and vote from *all*
     aligned positions (including replace blocks), seeding with the prefix
     votes at weight 3;
  4. iterate; cut the source at the last `--[[` or at the pad-length rule;
  5. for files whose exact source is known (sandboxol), verify the MD5.

Pair structure being decoded (see howto/16-v10104-v10105-formats.md):

    p0 = D0[(b0, b1 >> 4)]      p1 = D1[(b2, b1 & 7)]

The full-vote pass fixes symbols poisoned by insertions/deletions; a final
"repair" pass replaces only the opcodes that touch a conflicting pair or an
invalid UTF-8 byte with the crib's bytes, which recovers damaged comment
strings (e.g. the Chinese anti-cheat comment in ClientFileChecker.lua).
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
    out = []
    j = off
    while j + 3 <= len(ct):
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        out.append((b0, b1 >> 4, 0))
        out.append((b2, b1 & 7, 1))
        j += 3
    return out


def prefix_tables(crib, ct, off):
    syms = syms_of(ct, off)
    seen = {}
    t0, t1 = {}, {}
    k = 0
    while 2 * k + 1 < len(crib) and off + 3 * k + 3 <= len(ct):
        i = 2 * k
        pair = crib[i:i + 2]
        trip = ct[off + 3 * k:off + 3 * k + 3]
        old = seen.get(pair)
        if old is not None and old != trip:
            break
        seen[pair] = trip
        b0, b1, b2 = trip
        t0[(b0, b1 >> 4)] = crib[i]
        t1[(b2, b1 & 7)] = crib[i + 1]
        k += 1
    return t0, t1, k


def decode(syms, t0, t1):
    return [(t0 if s[2] == 0 else t1).get((s[0], s[1]), 0x100) for s in syms]


def vote(crib, text, syms, acc0, acc1):
    c = crib.decode("latin1")
    sm = difflib.SequenceMatcher(None, c, text, autojunk=False)
    for tag, a1, a2, b1, b2 in sm.get_opcodes():
        if tag == "insert":
            continue
        n = min(a2 - a1, b2 - b1)
        for k in range(n):
            ci = a1 + k
            ti = b1 + k
            if ti >= len(syms):
                break
            sym = syms[ti]
            (acc0 if sym[2] == 0 else acc1)[(sym[0], sym[1])][ord(c[ci])] += 1


def decode_file(game, rel, off, rounds=8):
    ct = C.get_ct(game, rel)
    syms = syms_of(ct, off)
    cribs = list(C.candidates(game, rel))
    best = None
    for tag, crib in cribs:
        a, b, k = prefix_tables(crib, ct, off)
        if best is None or k > best[0]:
            best = (k, tag, crib, a, b)
    k, tag, crib, p0, p1 = best
    t0, t1 = dict(p0), dict(p1)
    d = decode(syms, t0, t1)
    for _ in range(rounds):
        txt = "".join("?" if x > 255 else chr(x) for x in d)
        m = txt.rfind("--[[")
        text = txt[:m] if m > 0 else txt
        a0 = collections.defaultdict(collections.Counter)
        a1 = collections.defaultdict(collections.Counter)
        for kk, v in p0.items():
            a0[kk][v] += 3
        for kk, v in p1.items():
            a1[kk][v] += 3
        for tag2, cr in cribs:
            vote(cr, text, syms, a0, a1)
        n0 = {kk: c.most_common(1)[0][0] for kk, c in a0.items()}
        n1 = {kk: c.most_common(1)[0][0] for kk, c in a1.items()}
        if n0 == t0 and n1 == t1:
            break
        t0, t1 = n0, n1
        d = decode(syms, t0, t1)
    txt = "".join("?" if x > 255 else chr(x) for x in d)
    m = txt.rfind("--[[")
    L = m if m > 0 else len(d)
    return ct, syms, d, L, tag, k


def repair(dec_bytes, ct, off, crib):
    """Patch opcodes that touch conflicts / invalid UTF-8 with crib text."""
    D = dec_bytes.decode("latin1")
    Ctxt = crib.decode("latin1")
    bad = set()
    m = {}
    j = off
    n = len(dec_bytes) - (len(dec_bytes) % 2)
    i = 0
    while i + 1 < n:
        pair = (dec_bytes[i], dec_bytes[i + 1])
        trip = ct[j:j + 3]
        old = m.get(pair)
        if old is None:
            m[pair] = trip
        elif old != trip:
            bad.update((i, i + 1))
        i += 2
        j += 3
    try:
        dec_bytes.decode("utf-8")
    except UnicodeDecodeError as e:
        for k in range(max(0, e.start - 4), min(len(dec_bytes), e.start + 4)):
            bad.add(k)
    sm = difflib.SequenceMatcher(None, D, Ctxt, autojunk=False)
    T = list(D)
    for tag, a1, a2, b1, b2 in reversed(sm.get_opcodes()):
        if tag == "equal":
            continue
        if not any(k in bad for k in range(a1, a2)):
            continue
        T[a1:a2] = list(Ctxt[b1:b2])
    return "".join(T).encode("latin1")


def main():
    A = json.load(open(os.path.join(C.OUT, "..", "V10105_AUDIT.json")))
    for game, missing in A["missing"]:
        for rel in missing:
            ct = C.get_ct(game, rel)
            offs = [o for o in range(13, 61) if ct[o - 1] == 0]
            for off in offs:
                ct2, syms, d, L, tag, k = decode_file(game, rel, off)
                src = bytes(x if x <= 255 else 0 for x in d[:L])
                print("%s %s off=%d crib=%s prefix=%d L=%d md5=%s" %
                      (game, rel, off, tag, k, L, hashlib.md5(src).hexdigest()[:10]))


if __name__ == "__main__":
    main()
