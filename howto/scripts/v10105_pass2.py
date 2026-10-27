#!/usr/bin/env python3
"""Second-pass recovery for the v10105 files still unresolved.

Uses the exact trailing-pad length rule (extra in 27..87, validated on 932
sandbox-md5-verified files) and the per-byte structure check, so a truncated
prefix candidate can no longer win over a correct full-length candidate.
"""
from __future__ import annotations

import hashlib
import json
import os
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from extract import find_pair_offset  # noqa: E402

PKG = r"C:\Users\quefep\AppData\Local\Temp\opencode\recover\packages"
OUT = r"C:\Users\quefep\Desktop\Decomp Temp\recover\out"
GAMES = ["g1019", "g1042", "g1048"]
PAD = range(27, 88, 3)
PLAIN = [( "g1019", "v%05d" % i) for i in range(10068, 10104)] + [("g1042", "v10103")]


def md5(b):
    return hashlib.md5(b).hexdigest()


def structural_conflicts(src, ct, off):
    m0, m2, conf = {}, {}, 0
    j = off
    for i in range(0, len(src) - 1, 2):
        if j + 3 > len(ct):
            break
        p0, p1 = src[i], src[i + 1]
        b0, b1, b2 = ct[j], ct[j + 1], ct[j + 2]
        v0, v2 = (b0, b1 >> 4), (b2, b1 & 0x0F)
        if p0 in m0 and m0[p0] != v0:
            conf += 1
        else:
            m0.setdefault(p0, v0)
        if p1 in m2 and m2[p1] != v2:
            conf += 1
        else:
            m2.setdefault(p1, v2)
        j += 3
    return conf


def load_unresolved():
    audit = json.load(open(os.path.join(OUT, "..", "V10105_AUDIT.json")))
    out = {}
    for g, rel, note in audit["quarantined"]:
        if isinstance(note, dict) and note.get("sandbox") == "ok":
            continue
        out.setdefault(g, []).append(rel)
    for g, missing in audit["missing"]:
        out.setdefault(g, []).extend(missing)
    return audit, out


def main():
    audit, unres = load_unresolved()
    print("unresolved:", {g: len(v) for g, v in unres.items()})

    # candidate pool: same rel from plaintext packs + every out source tree
    packs = {}
    for g, v in PLAIN:
        p = os.path.join(PKG, g, v, "plugin.zip")
        if os.path.exists(p):
            packs[(g, v)] = zipfile.ZipFile(p)
    print("plaintext packs:", len(packs))

    recovered = []
    still = {}
    for game, rels in unres.items():
        z = zipfile.ZipFile(os.path.join(PKG, game, "v10105", "plugin.zip"))
        for rel in rels:
            ct = z.read(rel)
            cands = []
            for (g, v), zp in packs.items():
                if rel in zp.namelist():
                    cands.append(("%s/%s" % (g, v), zp.read(rel)))
            for root, _, files in os.walk(os.path.join(OUT)):
                pass
            # out sources
            for g2 in os.listdir(OUT):
                gd = os.path.join(OUT, g2)
                if not os.path.isdir(gd):
                    continue
                for v2 in os.listdir(gd):
                    p = os.path.join(gd, v2, "source", rel)
                    if os.path.exists(p):
                        cands.append(("%s/%s/out" % (g2, v2), open(p, "rb").read()))
            best = None
            seen = set()
            for tag, src in cands:
                h = md5(src)
                if h in seen:
                    continue
                seen.add(h)
                r = find_pair_offset(src, ct)
                if not r:
                    continue
                off, _ = r
                extra = (len(ct) - off) - 3 * ((len(src) + 1) // 2)
                if extra not in PAD:
                    continue
                conf = structural_conflicts(src, ct, off)
                if conf:
                    continue
                score = (len(src), -abs(extra - 57))
                if best is None or score > best[0]:
                    best = (score, tag, src, h, extra)
            if best is None:
                still.setdefault(game, []).append(rel)
                continue
            _, tag, src, h, extra = best
            dest = os.path.join(OUT, game, "v10105", "source", rel)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            open(dest, "wb").write(src)
            # remove rejected copy if present
            rj = os.path.join(OUT, game, "v10105", "_rejected", rel)
            if os.path.exists(rj):
                os.remove(rj)
            recovered.append({"game": game, "rel": rel, "source": tag, "md5": h,
                              "extra": extra, "size": len(src)})
            print("  RECOVERED", game, rel, "from", tag, "len", len(src), "extra", extra)
    print("recovered:", len(recovered), "still:", {g: len(v) for g, v in still.items()})
    json.dump({"recovered": recovered, "still": still},
              open(os.path.join(OUT, "..", "V10105_PASS2.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
