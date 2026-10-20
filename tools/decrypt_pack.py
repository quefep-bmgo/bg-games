import json
import re
import struct
import sys
import hashlib
import os

B = os.path.dirname(os.path.abspath(__file__))
PACK = os.path.join(B, "plugin", "res.pack")
TOC = os.path.join(B, "toc_plugin.bin")
KEYS = os.path.join(B, "keyobjects_plugin.json")


def load_pack():
    d = open(PACK, "rb").read()
    o = 4 + struct.unpack("<I", d[:4])[0]
    o = o + 4 + struct.unpack("<I", d[o:o + 4])[0]
    size = struct.unpack("<I", d[o:o + 4])[0]
    return d[o + 4:o + 4 + size]


def load_toc():
    d = open(TOC, "rb").read()
    i = 0
    out = []
    while i + 2 <= len(d):
        n = struct.unpack("<H", d[i:i + 2])[0]
        if n == 0 or n > 511 or i + 2 + n + 13 > len(d):
            break
        name = d[i + 2:i + 2 + n].decode("latin1")
        j = i + 2 + n
        off, size, size2 = struct.unpack("<III", d[j:j + 12])
        flag = d[j + 12]
        out.append((name, off, size, size2, flag))
        i = j + 13
    return out


def load_keys():
    return {r["key"]: r for r in json.load(open(KEYS))}


def apply_list(x, ls):
    for v in reversed(ls):
        hi = v >> 8
        p = v & 0xFF
        if hi == 0:
            x = (x - p) & 0xFF
        elif hi == 1:
            x = (x ^ p) & 0xFF
        elif hi == 2:
            x = ((x << 4) | (x >> 4)) & 0xFF
        else:
            raise ValueError(hex(v))
    return x


def invert_list(x, ls):
    for v in ls:
        hi = v >> 8
        p = v & 0xFF
        if hi == 0:
            x = (x + p) & 0xFF
        elif hi == 1:
            x = (x ^ p) & 0xFF
        elif hi == 2:
            x = ((x << 4) | (x >> 4)) & 0xFF
        else:
            raise ValueError(hex(v))
    return x


def decrypt(raw, rec):
    if len(raw) % 3:
        raise ValueError("payload length is not a multiple of 3")
    out = bytearray()
    for i in range(0, len(raw), 3):
        sel, a, b = raw[i], raw[i + 1], raw[i + 2]
        out.append(apply_list(a, rec["lists"][sel >> 4]))
        out.append(apply_list(b, rec["lists"][sel & 0xF]))
    return bytes(out)


def encrypt(plain, raw, rec):
    out = bytearray()
    for i in range(0, len(raw), 3):
        sel = raw[i]
        a = invert_list(plain[i // 3 * 2], rec["lists"][sel >> 4])
        b = invert_list(plain[i // 3 * 2 + 1], rec["lists"][sel & 0xF])
        out += bytes((sel, a, b))
    return bytes(out)


def extract_source(plain):
    marker = b"table.insert(F_L_Check_C_NEW[checkFileName], len)"
    i = plain.find(marker)
    if i < 0:
        return None
    c = plain.find(b"--[[", i)
    e = plain.find(b"]]", c)
    if c < 0 or e < 0:
        return None
    start = e + 2
    suff = plain.rfind(b"--[[")
    if suff <= start:
        return None
    return plain[start:suff]


def entry(name, toc, content, keys):
    for e in toc:
        if e[0] == name:
            if e[4] != 0:
                return None
            raw = content[e[1]:e[1] + e[2]]
            rec = keys[hashlib.md5(raw).hexdigest()]
            return raw, rec, decrypt(raw, rec)
    return None


if __name__ == "__main__":
    content = load_pack()
    toc = load_toc()
    keys = load_keys()
    if len(sys.argv) < 2:
        counts = {"entries": 0, "decoded": 0, "source": 0, "len_ok": 0, "name_ok": 0}
        for name, off, size, size2, flag in toc:
            if flag != 0:
                continue
            counts["entries"] += 1
            raw = content[off:off + size]
            rec = keys.get(hashlib.md5(raw).hexdigest())
            if rec is None or size % 3:
                continue
            plain = decrypt(raw, rec)
            counts["decoded"] += 1
            src = extract_source(plain)
            if src is not None:
                counts["source"] += 1
            m = re.search(rb"local len\s*=\s*(\d+)", plain)
            if m and int(m.group(1)) == len(plain) - (3 if plain.endswith(b"---") else 0):
                counts["len_ok"] += 1
            m = re.search(rb'local checkFileName = "([^"]+)"', plain)
            if m and m.group(1).decode("latin1") == os.path.basename(name):
                counts["name_ok"] += 1
        print(counts)
    else:
        needle = sys.argv[1]
        for e in toc:
            if needle not in e[0] or e[4] != 0:
                continue
            r = entry(e[0], toc, content, keys)
            if r is None:
                continue
            raw, rec, plain = r
            print("entry", e[0], "size", len(raw), "plain", len(plain), "md5", hashlib.md5(raw).hexdigest())
            print(plain.decode("latin1"))
            print("---source---")
            print(extract_source(plain).decode("latin1"))
