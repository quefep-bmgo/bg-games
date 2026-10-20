import hashlib
import json
import os
import pickle
import struct
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis")

import emu_lib as E
import decrypt_g1100_latest as L

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
OUT = os.path.join(B, "VERIFICATION")
os.makedirs(OUT, exist_ok=True)
T = pickle.load(open(os.path.join(B, "sub_table.pkl"), "rb"))
INV = {v: k for k, v in T.items()}


def invert_list(x, ls):
    for v in ls:
        op = v >> 8
        p = v & 0xFF
        if op == 0:
            x = (x + p) & 0xFF
        elif op == 1:
            x ^= p
        elif op == 2:
            x = ((x << 4) | (x >> 4)) & 0xFF
    return x


def encrypt_payload(plain, raw, rec):
    out = bytearray()
    for i in range(0, len(raw), 3):
        sel = raw[i]
        a = invert_list(plain[i // 3 * 2], rec["lists"][sel >> 4])
        b = invert_list(plain[i // 3 * 2 + 1], rec["lists"][sel & 0x0F])
        out += bytes((sel, a, b))
    return bytes(out)


def parse_toc(data):
    out = []
    o = 0
    while o + 2 <= len(data):
        nl = struct.unpack_from("<H", data, o)[0]
        if nl == 0 or nl > 511 or o + 2 + nl + 13 > len(data):
            break
        name = data[o + 2:o + 2 + nl].decode("latin1")
        j = o + 2 + nl
        off, size, size2 = struct.unpack_from("<III", data, j)
        flag = data[j + 12]
        out.append((name, off, size, size2, flag))
        o = j + 13
    return out


def base_pack():
    p = r"C:\Users\quefep\AppData\Local\Temp\opencode\mmf\g1100x\Media\Scripts\Game\g1100\res.pack"
    d = open(p, "rb").read()
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    toc = E.decrypt(d[o + 4:o + 4 + l2], b"blrsp20241212345", 0)[0]
    return d, parse_toc(toc), o + 4 + l2 + 4


def latest_pack():
    z = zipfile.ZipFile(L.ZIP)
    d = z.read("res.pack")
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    toc = L.decrypt_large(d[o + 4:o + 4 + l2], b"blrsp20241212345", 0)
    return d, L.parse_toc(toc), o + 4 + l2 + 4


def verify_base():
    d, entries, cb = base_pack()
    keys = {r["key"]: r for r in json.load(open(os.path.join(B, "decrypted_games", "g1100", "keyobjects_g1100.json"), encoding="utf-8"))}
    manifest = json.load(open(os.path.join(B, "decrypted_games", "g1100", "manifest.json"), encoding="utf-8"))
    paths = {x["name"]: x["path"] for x in manifest}
    ok = 0
    fail = []
    for name, off, size, size2, flag in entries:
        raw = d[cb + off:cb + off + size]
        if flag == 1:
            rel = name.split("Media/Scripts/Game/g1100/")[-1]
            p = os.path.join(B, "decrypted_games", "g1100", "csv", rel)
            plain = open(p, "rb").read()
            if bytes(T.get(x, x) for x in plain) == raw:
                ok += 1
            else:
                fail.append({"name": name, "error": "csv roundtrip"})
            continue
        rec = keys.get(hashlib.md5(raw).hexdigest())
        p = paths.get(name)
        if rec is None or p is None or not os.path.exists(p):
            fail.append({"name": name, "error": "key/path"})
            continue
        plain = open(p, "rb").read()
        if encrypt_payload(plain, raw, rec) == raw:
            ok += 1
        else:
            fail.append({"name": name, "error": "roundtrip"})
    return {"entries": len(entries), "verified": ok, "failures": fail}


def verify_latest():
    d, entries, cb = latest_pack()
    recs = json.load(open(os.path.join(B, "decrypted_games", "g1100_v10113", "keyobjects.json"), encoding="utf-8"))
    keys = {r["key"]: r for r in recs}
    suffix = {r["key"]: r for r in recs if len(r["key"]) == 22}
    manifest = json.load(open(os.path.join(B, "decrypted_games", "g1100_v10113", "manifest.json"), encoding="utf-8"))
    paths = {x["name"]: x["path"] for x in manifest}
    ok = 0
    fail = []
    for name, off, size, size2, flag in entries:
        raw = d[cb + off:cb + off + size]
        h = hashlib.md5(raw).hexdigest()
        if flag == 1:
            rel = name.split("Media/Scripts/Game/g1100/")[-1]
            p = os.path.join(B, "decrypted_games", "g1100_v10113", "csv", rel)
            plain = open(p, "rb").read()
            if bytes(T.get(x, x) for x in plain) == raw:
                ok += 1
            else:
                fail.append({"name": name, "error": "csv roundtrip"})
            continue
        rec = keys.get(h)
        if rec is None:
            for sk, sr in suffix.items():
                if h.endswith(sk):
                    rec = sr
                    break
        if rec is None:
            fail.append({"name": name, "error": "key"})
            continue
        p = paths.get(name)
        rel = name.split("Media/Scripts/Game/g1100/")[-1]
        wp = os.path.join(B, "decrypted_games", "g1100_v10113", "wrapped", rel)
        if not os.path.exists(wp):
            fail.append({"name": name, "error": "wrapped"})
            continue
        plain = open(wp, "rb").read()
        if encrypt_payload(plain, raw, rec) == raw:
            ok += 1
        else:
            fail.append({"name": name, "error": "roundtrip"})
    return {"entries": len(entries), "verified": ok, "failures": fail}


def main():
    r = {"base": verify_base(), "latest": verify_latest()}
    json.dump(r, open(os.path.join(OUT, "g1100_verification.json"), "w"), indent=2)
    for k, v in r.items():
        print(k, v["entries"], v["verified"], "fail", len(v["failures"]))
        for f in v["failures"][:5]:
            print(" ", f)


if __name__ == "__main__":
    main()
