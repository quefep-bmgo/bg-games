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
from unicorn.arm64_const import UC_ARM64_REG_LR, UC_ARM64_REG_SP, UC_ARM64_REG_X0, UC_ARM64_REG_X1, UC_ARM64_REG_X2, UC_ARM64_REG_X8

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
ZIP = r"C:\Users\quefep\Desktop\Decomp Temp\games\g1100\v10113\plugin.zip"
OUT = os.path.join(B, "decrypted_games", "g1100_v10113")


def gen(nums):
    me, h = E.make_uc()
    arr = h.alloc(me, len(nums) * 8)
    me.mem_write(arr, b"".join(struct.pack("<Q", n & 0xFFFFFFFFFFFFFFFF) for n in nums))
    me.reg_write(UC_ARM64_REG_X0, arr)
    me.reg_write(UC_ARM64_REG_X1, len(nums) * 8)
    me.reg_write(UC_ARM64_REG_X2, 0x22BA7B0)
    me.reg_write(UC_ARM64_REG_SP, E.SP)
    me.reg_write(UC_ARM64_REG_LR, 0)
    me.emu_start(0x1F3655C, 0, count=100000000)
    ptr = me.reg_read(UC_ARM64_REG_X0)
    return bytes(me.mem_read(ptr, len(nums))) if ptr else b""


def decrypt_large(data, key, mode=0):
    me, h = E.make_uc()
    big = 0x60000000
    me.mem_map(big, 0x800000)
    inp = big + 0x10000
    keybuf = big + 0x20000
    ds = big + 0x1000
    ks = big + 0x1040
    os_ = big + 0x1080
    me.mem_write(inp, data)
    me.mem_write(keybuf, key)
    me.mem_write(E.CTX, b"\x00" * 0x200)
    me.reg_write(UC_ARM64_REG_X0, E.CTX)
    me.reg_write(UC_ARM64_REG_X1, mode)
    me.reg_write(UC_ARM64_REG_SP, E.SP)
    me.reg_write(UC_ARM64_REG_LR, 0)
    me.emu_start(0x1F348D0, 0, count=1000)
    me.mem_write(ds, struct.pack("<B7xQ", 1, len(data)) + struct.pack("<Q", inp))
    me.mem_write(ks, struct.pack("<B7xQ", 1, len(key)) + struct.pack("<Q", keybuf))
    me.mem_write(os_, b"\x00" * 0x20)
    me.reg_write(UC_ARM64_REG_X0, E.CTX)
    me.reg_write(UC_ARM64_REG_X1, ds)
    me.reg_write(UC_ARM64_REG_X2, ks)
    me.reg_write(UC_ARM64_REG_X8, os_)
    me.reg_write(UC_ARM64_REG_SP, E.SP)
    me.reg_write(UC_ARM64_REG_LR, 0)
    me.emu_start(0x1F35ACC, 0, count=50000000)
    b0 = me.mem_read(os_, 1)[0]
    if b0 & 1:
        ln = struct.unpack("<Q", bytes(me.mem_read(os_ + 8, 8)))[0]
        ptr = struct.unpack("<Q", bytes(me.mem_read(os_ + 16, 8)))[0]
        return bytes(me.mem_read(ptr, ln))
    return bytes(me.mem_read(os_ + 1, b0 >> 1))


def parse_frames(data):
    o = 0
    out = []
    while o + 6 <= len(data):
        n1 = struct.unpack_from("<H", data, o)[0]
        if n1 == 0 or n1 > 600:
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


def parse_flat_records(data):
    out = []
    o = 0
    while o + 2 <= len(data):
        kl = struct.unpack_from("<H", data, o)[0]
        if kl == 0:
            break
        if kl != 32 or o + 34 > len(data):
            break
        key = data[o + 2:o + 34].decode("ascii")
        o += 34
        nl = struct.unpack_from("<H", data, o)[0]
        o += 2
        if nl > 16:
            break
        lists = []
        ok = True
        for _ in range(nl):
            c = struct.unpack_from("<H", data, o)[0]
            o += 2
            if c > 16 or o + 2 * c > len(data):
                ok = False
                break
            lists.append(list(struct.unpack_from("<%dH" % c, data, o)))
            o += 2 * c
        if not ok:
            break
        out.append({"key": key, "lists": lists})
    return out, o


def parse_extra_records(data, o):
    out = []
    if o >= len(data):
        return out
    rest = data[o:]
    if len(rest) < 116:
        return out
    first = rest[:116]
    p = 12
    q = p
    while q < len(first) and 48 <= first[q] < 103:
        q += 1
    if q == p:
        return out
    key = first[p:q].decode("ascii", "replace")
    p = q
    nl = struct.unpack_from("<H", first, p)[0]
    p += 2
    lists = []
    for _ in range(nl):
        c = struct.unpack_from("<H", first, p)[0]
        p += 2
        lists.append(list(struct.unpack_from("<%dH" % c, first, p)))
        p += 2 * c
    out.append({"key": key, "lists": lists})
    i = 1
    while i * 116 + 116 <= len(rest):
        b = rest[i * 116:(i + 1) * 116]
        p = 0
        kl = struct.unpack_from("<H", b, p)[0]
        p += 2
        if kl != 32:
            break
        key = b[p:p + 32].decode("ascii")
        p += 32
        nl = struct.unpack_from("<H", b, p)[0]
        p += 2
        lists = []
        for _ in range(nl):
            c = struct.unpack_from("<H", b, p)[0]
            p += 2
            lists.append(list(struct.unpack_from("<%dH" % c, b, p)))
            p += 2 * c
        out.append({"key": key, "lists": lists})
        i += 1
    return out


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


def source_from_wrapper(plain):
    marker = b"table.insert(F_L_Check_C_NEW[checkFileName], len)"
    i = plain.find(marker)
    c = plain.find(b"--[[", i)
    e = plain.find(b"]]", c)
    suff = plain.rfind(b"--[[")
    if i >= 0 and c >= 0 and e >= 0 and suff > e + 2:
        return plain[e + 2:suff]
    return None


def main():
    os.makedirs(OUT, exist_ok=True)
    z = zipfile.ZipFile(ZIP)
    frames = parse_frames(z.read("sandboxol"))
    plain_keydb = decrypt_large(frames[0][1], gen([int(x) for x in frames[0][0].split("-")]), 0)
    recs, rec_end = parse_flat_records(plain_keydb)
    recs.extend(parse_extra_records(plain_keydb, rec_end))
    keys = {r["key"]: r for r in recs}
    suffix_keys = {r["key"]: r for r in recs if len(r["key"]) == 22}
    json.dump(recs, open(os.path.join(OUT, "keyobjects.json"), "w"), indent=2)

    fallbacks = {}
    for p in [
        os.path.join(B, "keyobjects_g1100.json"),
        os.path.join(B, "keyobjects_engine_current.json"),
        os.path.join(B, "keyobjects_plugin.json"),
        os.path.join(B, "decrypted_games", "g1100", "keyobjects_g1100.json"),
    ]:
        if os.path.exists(p):
            for r in json.load(open(p, encoding="utf-8")):
                fallbacks.setdefault(r["key"], r)

    sub = pickle.load(open(os.path.join(B, "sub_table.pkl"), "rb"))
    inv_sub = {v: k for k, v in sub.items()}
    pack = z.read("res.pack")
    l1 = struct.unpack_from("<I", pack, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", pack, o)[0]
    toc = decrypt_large(pack[o + 4:o + 4 + l2], b"blrsp20241212345", 0)
    cb = o + 4 + l2 + 4
    entries = parse_toc(toc)
    manifest = []
    missing = []
    for name, off, size, size2, flag in entries:
        raw = pack[cb + off:cb + off + size]
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
        rec = keys.get(raw_md5)
        if rec is None:
            for sk, sr in suffix_keys.items():
                if raw_md5.endswith(sk):
                    rec = sr
                    break
        if rec is None:
            rec = fallbacks.get(raw_md5)
        if rec is None:
            missing.append({"name": name, "raw_md5": raw_md5, "size": size, "head": raw[:16].hex()})
            dst = os.path.join(OUT, "encrypted", rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, "wb").write(raw)
            continue
        plain = decrypt_content(raw, rec)
        if plain.startswith(b"\x1bLua"):
            dst = os.path.join(OUT, "bytecode", rel + ".luac")
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, "wb").write(plain)
            manifest.append({"name": name, "type": "bytecode", "raw_md5": raw_md5, "size": len(plain), "md5": hashlib.md5(plain).hexdigest(), "path": dst})
            continue
        src = source_from_wrapper(plain)
        if src is not None:
            dst = os.path.join(OUT, "source", rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, "wb").write(src)
            wdst = os.path.join(OUT, "wrapped", rel)
            os.makedirs(os.path.dirname(wdst), exist_ok=True)
            open(wdst, "wb").write(plain)
            manifest.append({"name": name, "type": "source", "raw_md5": raw_md5, "size": len(src), "md5": hashlib.md5(src).hexdigest(), "path": dst})
            continue
        dst = os.path.join(OUT, "raw", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(plain)
        manifest.append({"name": name, "type": "raw", "raw_md5": raw_md5, "size": len(plain), "md5": hashlib.md5(plain).hexdigest(), "path": dst})

    json.dump(manifest, open(os.path.join(OUT, "manifest.json"), "w"), indent=2)
    json.dump(missing, open(os.path.join(OUT, "missing_keys.json"), "w"), indent=2)
    print("entries", len(entries), "records", len(recs), "decoded", len(manifest), "missing", len(missing))
    print("types", {t: sum(1 for x in manifest if x["type"] == t) for t in ("source", "bytecode", "csv", "raw")})
    for x in missing[:10]:
        print(" missing", x["name"], x["raw_md5"])


if __name__ == "__main__":
    main()
