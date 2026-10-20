import hashlib
import json
import os
import pickle
import struct
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis")

from emu_lib import decrypt, make_uc
from unicorn.arm64_const import UC_ARM64_REG_LR, UC_ARM64_REG_SP, UC_ARM64_REG_X0, UC_ARM64_REG_X1, UC_ARM64_REG_X2

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
APK = r"C:\Users\quefep\AppData\Local\Temp\opencode\bgmap\base.apk"


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


def load_toc(path):
    d = open(path, "rb").read()
    out = []
    o = 0
    while o + 2 <= len(d):
        n = struct.unpack_from("<H", d, o)[0]
        if n == 0 or n > 511 or o + 2 + n + 13 > len(d):
            break
        name = d[o + 2:o + 2 + n].decode("latin1")
        j = o + 2 + n
        off, size, size2 = struct.unpack_from("<III", d, j)
        flag = d[j + 12]
        out.append((name, off, size, size2, flag))
        o = j + 13
    return out


def pack_content(path):
    d = open(path, "rb").read()
    o = 4 + struct.unpack_from("<I", d, 0)[0]
    o = o + 4 + struct.unpack_from("<I", d, o)[0]
    size = struct.unpack_from("<I", d, o)[0]
    return d[o + 4:o + 4 + size]


def parse_lists(data, o, n):
    lists = []
    for _ in range(n):
        c = struct.unpack_from("<H", data, o)[0]
        o += 2
        if c > 64:
            raise ValueError("bad list count")
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
            raise ValueError("key length %d at %d" % (kl, o))
        key = data[o + 2:o + 34].decode("ascii")
        o += 34
        h1 = struct.unpack_from("<H", data, o)[0]
        h2 = data[o + 2]
        w10 = struct.unpack_from("<I", data, o + 3)[0]
        nl = struct.unpack_from("<H", data, o + 7)[0]
        lists, o = parse_lists(data, o + 9, nl)
        recs.append({"key": key, "h1": h1, "h2": h2, "w10": w10, "lists": lists})
    return recs, o


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
        else:
            raise ValueError(hex(v))
    return x


def decrypt_content(raw, rec):
    if len(raw) % 3:
        raise ValueError("payload not multiple of 3")
    out = bytearray()
    for i in range(0, len(raw), 3):
        sel, a, b = raw[i], raw[i + 1], raw[i + 2]
        out.append(apply_list(a, rec["lists"][sel >> 4]))
        out.append(apply_list(b, rec["lists"][sel & 0x0F]))
    return bytes(out)


def engine_keyfile():
    z = zipfile.ZipFile(APK)
    sb = z.read("assets/resources/Media/Scripts/Engine/sandboxol")
    o = 0
    frames = []
    while o + 2 <= len(sb):
        l1 = struct.unpack_from("<H", sb, o)[0]
        if l1 == 0 or l1 > 500 or o + 2 + l1 + 2 > len(sb):
            break
        name = sb[o + 2:o + 2 + l1].decode("latin1")
        o += 2 + l1
        l2 = struct.unpack_from("<H", sb, o)[0]
        key = sb[o + 2:o + 2 + l2].decode("latin1")
        o += 2 + l2
        bl = struct.unpack_from("<I", sb, o)[0]
        frames.append((name, key, sb[o + 4:o + 4 + bl]))
        o += 4 + bl
    plain = decrypt(frames[0][2], gen([int(x) for x in frames[0][1].split("-")]), 0)[0]
    recs, end = parse_records(plain)
    if end != len(plain):
        raise ValueError("engine keyfile trailing %d" % (len(plain) - end))
    return recs


def safe_rel(name):
    name = name.replace("\\", "/")
    if name.startswith("/") or ".." in name.split("/"):
        raise ValueError(name)
    return name


def main():
    plugin_toc = load_toc(os.path.join(B, "toc_plugin.bin"))
    plugin_content = pack_content(os.path.join(B, "plugin", "res.pack"))
    plugin_keys = {r["key"]: r for r in json.load(open(os.path.join(B, "keyobjects_plugin.json"), encoding="utf-8"))}
    sub = pickle.load(open(os.path.join(B, "sub_table.pkl"), "rb"))
    inv_sub = {v: k for k, v in sub.items()}

    engine_toc = load_toc(os.path.join(B, "toc_engine.bin"))
    engine_content = pack_content(os.path.join(B, "native", "bgmap_engine_res.pack"))
    engine_recs = engine_keyfile()
    json.dump(engine_recs, open(os.path.join(B, "keyobjects_engine_current.json"), "w"), indent=2)
    engine_keys = {r["key"]: r for r in engine_recs}

    plugin_manifest = []
    engine_manifest = []

    for name, off, size, size2, flag in plugin_toc:
        rel = safe_rel(name)
        raw = plugin_content[off:off + size]
        raw_md5 = hashlib.md5(raw).hexdigest()
        if flag == 1 and rel.endswith(".csv"):
            plain = bytes(inv_sub.get(x, x) for x in raw)
            dst = os.path.join(B, "decrypted_plugin", "csv", rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            open(dst, "wb").write(plain)
            plugin_manifest.append({"name": name, "type": "csv", "raw_md5": raw_md5, "size": len(raw), "plain_size": len(plain), "plain_md5": hashlib.md5(plain).hexdigest(), "path": dst})
            continue
        rec = plugin_keys[raw_md5]
        plain = decrypt_content(raw, rec)
        dst_wrapped = os.path.join(B, "decrypted_plugin", "wrapped", rel)
        os.makedirs(os.path.dirname(dst_wrapped), exist_ok=True)
        open(dst_wrapped, "wb").write(plain)
        marker = b"table.insert(F_L_Check_C_NEW[checkFileName], len)"
        i = plain.find(marker)
        c = plain.find(b"--[[", i)
        e = plain.find(b"]]", c)
        suff = plain.rfind(b"--[[")
        src = plain[e + 2:suff] if i >= 0 and c >= 0 and e >= 0 and suff > e + 2 else None
        if src is None:
            raise ValueError("source wrapper missing: %s" % name)
        dst = os.path.join(B, "decrypted_plugin", "source", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(src)
        plugin_manifest.append({"name": name, "type": "lua", "raw_md5": raw_md5, "size": len(raw), "plain_size": len(plain), "source_size": len(src), "source_md5": hashlib.md5(src).hexdigest(), "path": dst})

    for name, off, size, size2, flag in engine_toc:
        rel = safe_rel(name)
        if rel.startswith("Media/Scripts/Engine/"):
            rel = rel[len("Media/Scripts/Engine/"):]
        raw = engine_content[off:off + size]
        raw_md5 = hashlib.md5(raw).hexdigest()
        rec = engine_keys[raw_md5]
        plain = decrypt_content(raw, rec)
        if not plain.startswith(b"\x1bLua"):
            raise ValueError("engine output is not Lua bytecode: %s %s" % (name, plain[:8].hex()))
        dst = os.path.join(B, "decrypted_engine", "bytecode", rel + ".luac")
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(plain)
        engine_manifest.append({"name": name, "raw_md5": raw_md5, "size": len(raw), "plain_size": len(plain), "plain_md5": hashlib.md5(plain).hexdigest(), "path": dst})

    json.dump(plugin_manifest, open(os.path.join(B, "decrypted_plugin", "manifest.json"), "w"), indent=2)
    json.dump(engine_manifest, open(os.path.join(B, "decrypted_engine", "manifest.json"), "w"), indent=2)
    print("plugin_entries", len(plugin_manifest), "engine_entries", len(engine_manifest))
    print("plugin_lua", sum(1 for x in plugin_manifest if x["type"] == "lua"), "plugin_csv", sum(1 for x in plugin_manifest if x["type"] == "csv"))
    print("engine_key_records", len(engine_recs))


if __name__ == "__main__":
    main()
