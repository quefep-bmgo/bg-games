import hashlib
import json
import os
import pickle
import struct
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis")

from emu_lib import decrypt, make_uc
from unicorn.arm64_const import UC_ARM64_REG_LR, UC_ARM64_REG_SP, UC_ARM64_REG_X0, UC_ARM64_REG_X1, UC_ARM64_REG_X2

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
SRC = r"C:\Users\quefep\AppData\Local\Temp\opencode\mmf\g1100x\Media\Scripts\Game\g1100"
SMALL = r"C:\Users\quefep\AppData\Local\Temp\opencode\bg\alllua\assets\resources\Media\Scripts\Game\g1100\res.pack"
OUT = os.path.join(B, "decrypted_games", "g1100")
TOC_KEY = b"blrsp20241212345"


def gen(nums):
    me, h = make_uc()
    arr = h.alloc(me, len(nums) * 8)
    me.mem_write(arr, b"".join(struct.pack("<Q", n & 0xFFFFFFFFFFFFFFFF) for n in nums))
    me.reg_write(UC_ARM64_REG_X0, arr)
    me.reg_write(UC_ARM64_REG_X1, len(nums) * 8)
    me.reg_write(UC_ARM64_REG_X2, 0x22BA7B0)
    me.reg_write(UC_ARM64_REG_SP, 0x70000000)
    me.reg_write(UC_ARM64_REG_LR, 0)
    me.emu_start(0x1F3655C, 0, count=100000000)
    ptr = me.reg_read(UC_ARM64_REG_X0)
    return bytes(me.mem_read(ptr, len(nums))) if ptr else b""


def parse_frames(data):
    o = 0
    out = []
    while o + 6 <= len(data):
        n1 = struct.unpack_from("<H", data, o)[0]
        if n1 == 0 or n1 > 500:
            break
        o += 2 + n1
        n2 = struct.unpack_from("<H", data, o)[0]
        key = data[o + 2:o + 2 + n2].decode("latin1")
        o += 2 + n2
        blen = struct.unpack_from("<I", data, o)[0]
        if o + 4 + blen > len(data):
            break
        out.append((key, data[o + 4:o + 4 + blen]))
        o += 4 + blen
    return out


def parse_lists(data, o, n):
    lists = []
    for _ in range(n):
        c = struct.unpack_from("<H", data, o)[0]
        o += 2
        lists.append(list(struct.unpack_from("<%dH" % c, data, o)))
        o += 2 * c
    return lists, o


def parse_records(data):
    recs = []
    o = 0
    while o + 2 <= len(data):
        kl = struct.unpack_from("<H", data, o)[0]
        if kl == 0:
            break
        if kl != 32:
            raise ValueError("key length")
        key = data[o + 2:o + 34].decode("ascii")
        o += 34
        h1 = struct.unpack_from("<H", data, o)[0]
        h2 = data[o + 2]
        w10 = struct.unpack_from("<I", data, o + 3)[0]
        nl = struct.unpack_from("<H", data, o + 7)[0]
        lists, o = parse_lists(data, o + 9, nl)
        recs.append({"key": key, "h1": h1, "h2": h2, "w10": w10, "lists": lists})
    return recs


def parse_toc(toc):
    out = []
    o = 0
    while o + 2 <= len(toc):
        nl = struct.unpack_from("<H", toc, o)[0]
        if nl == 0 or nl > 511 or o + 2 + nl + 13 > len(toc):
            break
        name = toc[o + 2:o + 2 + nl].decode("latin1")
        j = o + 2 + nl
        off, size, size2 = struct.unpack_from("<III", toc, j)
        flag = toc[j + 12]
        out.append((name, off, size, size2, flag))
        o = j + 13
    return out


def apply_list(x, ls):
    for v in reversed(ls):
        op = v >> 8
        p = v & 0xFF
        if op == 0:
            x = (x - p) & 0xFF
        elif op == 1:
            x ^= p
        elif op == 2:
            x = ((x << 4) | (x >> 4)) & 0xFF
    return x


def decrypt_content(raw, rec):
    out = bytearray()
    for i in range(0, len(raw), 3):
        sel, a, b = raw[i], raw[i + 1], raw[i + 2]
        out.append(apply_list(a, rec["lists"][sel >> 4]))
        out.append(apply_list(b, rec["lists"][sel & 0x0F]))
    return bytes(out)


def unpack(path):
    d = open(path, "rb").read()
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    toc = decrypt(d[o + 4:o + 4 + l2], TOC_KEY, 0)[0]
    cb = o + 4 + l2 + 4
    return d, parse_toc(toc), cb


def main():
    os.makedirs(OUT, exist_ok=True)
    sb = open(os.path.join(SRC, "sandboxol"), "rb").read()
    frames = parse_frames(sb)
    plain = decrypt(frames[0][1], gen([int(x) for x in frames[0][0].split("-")]), 0)[0]
    recs = parse_records(plain)
    keys = {r["key"]: r for r in recs}
    json.dump(recs, open(os.path.join(OUT, "keyobjects_g1100.json"), "w"), indent=2)

    sub = pickle.load(open(os.path.join(B, "sub_table.pkl"), "rb"))
    inv_sub = {v: k for k, v in sub.items()}
    d, entries, cb = unpack(os.path.join(SRC, "res.pack"))
    manifest = []
    for name, off, size, size2, flag in entries:
        raw = d[cb + off:cb + off + size]
        raw_md5 = hashlib.md5(raw).hexdigest()
        rel = name
        if rel.startswith("Media/Scripts/Game/g1100/"):
            rel = rel[len("Media/Scripts/Game/g1100/"):]
        if flag == 1:
            plain = bytes(inv_sub.get(x, x) for x in raw)
            dst = os.path.join(OUT, "csv", rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, "wb").write(plain)
            manifest.append({"name": name, "type": "csv", "raw_md5": raw_md5, "size": len(plain), "md5": hashlib.md5(plain).hexdigest(), "path": dst})
            continue
        rec = keys[raw_md5]
        plain = decrypt_content(raw, rec)
        if not plain.startswith(b"\x1bLua"):
            raise ValueError("not bytecode: %s %s" % (name, plain[:8].hex()))
        dst = os.path.join(OUT, "bytecode", rel + ".luac")
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(plain)
        manifest.append({"name": name, "type": "bytecode", "raw_md5": raw_md5, "size": len(plain), "md5": hashlib.md5(plain).hexdigest(), "path": dst})

    os.makedirs(OUT, exist_ok=True)
    json.dump(manifest, open(os.path.join(OUT, "manifest.json"), "w"), indent=2)
    print("g1100 entries", len(entries), "records", len(recs), "decoded", len(manifest), "lua", sum(1 for x in manifest if x["type"] == "bytecode"), "csv", sum(1 for x in manifest if x["type"] == "csv"))

    sd, sentries, scb = unpack(SMALL)
    raw = sd[scb + sentries[0][1]:scb + sentries[0][1] + sentries[0][2]]
    found = None
    for rec in recs:
        try:
            p = decrypt_content(raw, rec)
        except Exception:
            continue
        if p.startswith(b"\x1bLua") or p.startswith(b"--") or p.startswith(b"local"):
            found = (rec["key"], p)
            break
    if found:
        dst = os.path.join(OUT, "hotfix", "Loader.lua")
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(found[1])
        print("small Loader decrypted with", found[0], "head", found[1][:24])
    else:
        print("small Loader: no matching key")


if __name__ == "__main__":
    main()
