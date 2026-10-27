import hashlib
import json
import os
import pickle
import re
import struct
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis")

import decrypt_g1100_latest as D

GAMES_BASE = r"C:\Users\quefep\Desktop\Decomp Temp\games"
OUT = r"C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED"
TOC_KEY = b"blrsp20241212345"
CURRENT_HEADER = bytes.fromhex("0003c1e92c115ed7e48d4ee1d40d9242")
LEGACY_HEADER = bytes.fromhex("c92ea841b587eac4a1751bf519873682")
T = pickle.load(open(r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\sub_table.pkl", "rb"))
INV = {v: k for k, v in T.items()}
GAME_NAMES = {"g1042": "g1042_build_and_shoot", "g1005": "g1005_clanwar", "g1100": "g1100_rooms", "g1048": "g1048_skyblock"}
SOURCE_INDEX = {}
MANIFEST = {}


def md5(b):
    return hashlib.md5(b).hexdigest()


def safe(name):
    name = name.replace("\\", "/")
    if name.startswith("/") or ".." in name.split("/"):
        raise ValueError(name)
    return name


def toc_parse(t):
    out = []
    o = 0
    while o + 2 <= len(t):
        nl = struct.unpack_from("<H", t, o)[0]
        if nl == 0 or nl > 511 or o + 2 + nl + 13 > len(t):
            break
        name = t[o + 2:o + 2 + nl].decode("latin1")
        j = o + 2 + nl
        off, size, size2 = struct.unpack_from("<III", t, j)
        flag = t[j + 12]
        out.append((name, off, size, size2, flag))
        o = j + 13
    return out


def unpack_current(d):
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    toc = D.decrypt_large(d[o + 4:o + 4 + l2], TOC_KEY, 0)
    return toc, o + 4 + l2 + 4


def unpack_legacy(d):
    from Crypto.Cipher import AES
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    raw = AES.new(TOC_KEY, AES.MODE_ECB).decrypt(d[o + 4:o + 4 + l2])
    pad = raw[-1]
    if not 1 <= pad <= 16 or raw[-pad:] != bytes([pad]) * pad:
        raise ValueError("legacy TOC padding")
    return raw[:-pad], o + 4 + l2 + 4


def key_records(sandboxol):
    frames = D.parse_frames(sandboxol)
    pt = D.decrypt_large(frames[0][1], D.gen([int(x) for x in frames[0][0].split("-")]), 0)
    recs, end = D.parse_flat_records(pt)
    recs += D.parse_extra_records(pt, end)
    return recs


def decrypt_payload(raw, rec):
    return D.decrypt_content(raw, rec)


def extract_source(plain):
    marker = b"table.insert(F_L_Check_C_NEW[checkFileName], len)"
    i = plain.find(marker)
    c = plain.find(b"--[[", i)
    e = plain.find(b"]]", c)
    suff = plain.rfind(b"--[[")
    if i >= 0 and c >= 0 and e >= 0 and suff > e + 2:
        return plain[e + 2:suff]
    return None


def write_entry(outroot, game, ver, name, raw, flag, keys, suffix):
    rel = safe(name)
    prefix = "Media/Scripts/Game/%s/" % game
    if rel.startswith(prefix):
        rel = rel[len(prefix):]
    rec = keys.get(md5(raw))
    if rec is None:
        for sk, sr in suffix.items():
            if md5(raw).endswith(sk):
                rec = sr
                break
    if flag == 1:
        plain = bytes(INV.get(x, x) for x in raw)
        dst = os.path.join(outroot, "csv", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(plain)
        return {"name": rel, "type": "csv", "size": len(plain), "md5": md5(plain), "path": dst}
    if rec is None:
        dst = os.path.join(outroot, "cipher", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(raw)
        return {"name": rel, "type": "encrypted_unresolved", "size": len(raw), "md5": md5(raw), "path": dst}
    plain = decrypt_payload(raw, rec)
    if plain.startswith(b"\x1bLua"):
        dst = os.path.join(outroot, "bytecode", rel + ".luac")
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(plain)
        return {"name": rel, "type": "bytecode", "size": len(plain), "md5": md5(plain), "path": dst}
    src = extract_source(plain)
    if src is not None:
        dst = os.path.join(outroot, "source", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(src)
        wdst = os.path.join(outroot, "wrapped", rel)
        os.makedirs(os.path.dirname(wdst), exist_ok=True)
        open(wdst, "wb").write(plain)
        return {"name": rel, "type": "source", "size": len(src), "md5": md5(src), "path": dst}
    dst = os.path.join(outroot, "raw", rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    open(dst, "wb").write(plain)
    return {"name": rel, "type": "raw", "size": len(plain), "md5": md5(plain), "path": dst}


def looks_text(b):
    if not b or b"\x00" in b[:128]:
        return False
    try:
        s = b.decode("utf-8")
    except Exception:
        return False
    good = sum(1 for c in s[:2000] if c in "\t\r\n" or 32 <= ord(c) < 127 or ord(c) >= 0x80)
    return good >= max(1, int(len(s[:2000]) * 0.92))


def index_plain_zip(z, game, ver):
    for n in z.namelist():
        if n.endswith(".lua"):
            b = z.read(n)
            if looks_text(b):
                SOURCE_INDEX[md5(b)] = (game, ver, n, b)


def copy_config(z, outroot, ver):
    for n in z.namelist():
        if n.endswith("/") or n.endswith(".lua") or n in ("res.pack", "sandboxol", "checksums.md5"):
            continue
        rel = safe(n)
        dst = os.path.join(outroot, "config", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        open(dst, "wb").write(z.read(n))


def extract_maps(game, ver, outroot):
    base = os.path.join(GAMES_BASE, game, ver)
    rows = []
    for sub in ("maps", "maps-staging"):
        d = os.path.join(base, sub)
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if not f.endswith(".zip"):
                continue
            zp = os.path.join(d, f)
            z = zipfile.ZipFile(zp)
            for n in z.namelist():
                if n.endswith("/"):
                    continue
                b = z.read(n)
                rows.append({"archive": sub + "/" + f, "name": n, "size": len(b), "md5": md5(b)})
                if n.endswith((".csv", ".json", ".yml", ".yaml", ".lang", ".txt", ".cfg", ".ini")):
                    dst = os.path.join(outroot, "map_config", sub, f, safe(n))
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                if n == "res.pack":
                    try:
                        hdr = b[4:20]
                        if hdr == CURRENT_HEADER:
                            toc, cb = unpack_current(b)
                            entries = toc_parse(toc)
                            for name, off, size, s2, fl in entries:
                                if fl == 1:
                                    plain = bytes(INV.get(x, x) for x in b[cb + off:cb + off + size])
                                    dst = os.path.join(outroot, "map_csv", sub, f, safe(name))
                                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                                    open(dst, "wb").write(plain)
                        elif hdr == LEGACY_HEADER:
                            toc, cb = unpack_legacy(b)
                            entries = toc_parse(toc)
                            for name, off, size, s2, fl in entries:
                                if fl == 1:
                                    plain = bytes(INV.get(x, x) for x in b[cb + off:cb + off + size])
                                    dst = os.path.join(outroot, "map_csv", sub, f, safe(name))
                                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                                    open(dst, "wb").write(plain)
                    except Exception as e:
                        rows.append({"archive": sub + "/" + f, "res_pack_error": str(e)})
    return rows


def process_version(game, ver):
    base = os.path.join(GAMES_BASE, game, ver)
    outroot = os.path.join(OUT, GAME_NAMES.get(game, game), ver)
    os.makedirs(outroot, exist_ok=True)
    result = {"game": game, "version": ver, "source": [], "bytecode": [], "csv": [], "unresolved": [], "config_files": 0, "map": []}
    zp = os.path.join(base, "plugin.zip")
    if os.path.exists(zp):
        z = zipfile.ZipFile(zp)
        copy_config(z, outroot, ver)
        lua_names = [n for n in z.namelist() if n.endswith(".lua")]
        if "res.pack" in z.namelist():
            d = z.read("res.pack")
            hdr = d[4:20]
            if hdr == CURRENT_HEADER:
                toc, cb = unpack_current(d)
                entries = toc_parse(toc)
                recs = key_records(z.read("sandboxol"))
                keys = {r["key"]: r for r in recs}
                suffix = {r["key"]: r for r in recs if len(r["key"]) == 22}
                for name, off, size, s2, fl in entries:
                    row = write_entry(outroot, game, ver, name, d[cb + off:cb + off + size], fl, keys, suffix)
                    result["source" if row["type"] == "source" else "bytecode" if row["type"] == "bytecode" else "csv" if row["type"] == "csv" else "unresolved"].append(row)
            elif hdr == LEGACY_HEADER:
                toc, cb = unpack_legacy(d)
                entries = toc_parse(toc)
                for name, off, size, s2, fl in entries:
                    raw = d[cb + off:cb + off + size]
                    if fl == 1:
                        plain = bytes(INV.get(x, x) for x in raw)
                        rel = safe(name)
                        dst = os.path.join(outroot, "csv", rel)
                        os.makedirs(os.path.dirname(dst), exist_ok=True)
                        open(dst, "wb").write(plain)
                        result["csv"].append({"name": rel, "type": "csv", "size": len(plain), "md5": md5(plain)})
                    else:
                        rel = safe(name)
                        dst = os.path.join(outroot, "cipher", rel)
                        os.makedirs(os.path.dirname(dst), exist_ok=True)
                        open(dst, "wb").write(raw)
                        result["unresolved"].append({"name": rel, "type": "encrypted_unresolved", "size": len(raw), "md5": md5(raw), "path": dst})
            else:
                result["error"] = "unknown res.pack header"
        else:
            index_plain_zip(z, game, ver)
            for n in lua_names:
                b = z.read(n)
                rel = safe(n)
                if looks_text(b):
                    dst = os.path.join(outroot, "source", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                    result["source"].append({"name": rel, "type": "source", "size": len(b), "md5": md5(b), "path": dst})
                elif len(b) >= 34 and b[:2] == b"\x20\x00" and re.fullmatch(rb"[0-9a-f]{32}", b[2:34]):
                    h = b[2:34].decode()
                    hit = SOURCE_INDEX.get(h)
                    if hit:
                        _g, _v, _n, data = hit
                        dst = os.path.join(outroot, "recovered_source", rel)
                        os.makedirs(os.path.dirname(dst), exist_ok=True)
                        open(dst, "wb").write(data)
                        result["source"].append({"name": rel, "type": "recovered_source", "size": len(data), "md5": h, "recovered_from": _g + "/" + _v, "path": dst})
                    else:
                        dst = os.path.join(outroot, "cipher", rel)
                        os.makedirs(os.path.dirname(dst), exist_ok=True)
                        open(dst, "wb").write(b)
                        result["unresolved"].append({"name": rel, "type": "cipher_with_source_md5", "size": len(b), "md5": md5(b), "source_md5": h, "path": dst})
                else:
                    dst = os.path.join(outroot, "cipher", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                    result["unresolved"].append({"name": rel, "type": "cipher_unknown", "size": len(b), "md5": md5(b), "path": dst})
    result["map"] = extract_maps(game, ver, outroot)
    json.dump(result, open(os.path.join(outroot, "MANIFEST.json"), "w"), indent=2)
    unresolved = result["unresolved"]
    if unresolved:
        lines = ["# Unresolved entries", "", "These entries are ciphertext. Reasons: no key record, legacy keyfile blob, or missing source-MD5 recovery.", ""]
        for x in unresolved:
            lines.append("- `%s` size=%s md5=%s" % (x["name"], x.get("size"), x.get("md5")))
        open(os.path.join(outroot, "UNRESOLVED.txt"), "w", encoding="utf-8").write("\n".join(lines))
    return result


def main():
    os.makedirs(OUT, exist_ok=True)
    all_results = []
    versions_by_game = {}
    for game in ["g1005", "g1042", "g1100", "g1048"]:
        p = os.path.join(GAMES_BASE, game)
        if not os.path.isdir(p):
            continue
        versions = sorted(d for d in os.listdir(p) if re.fullmatch(r"v\d+", d))
        versions_by_game[game] = versions
        for ver in versions:
            print("indexing", game, ver)
            zp = os.path.join(p, ver, "plugin.zip")
            if os.path.exists(zp):
                z = zipfile.ZipFile(zp)
                if "res.pack" in z.namelist() and z.read("res.pack")[4:20] == CURRENT_HEADER:
                    try:
                        recs = key_records(z.read("sandboxol"))
                        for r in recs:
                            pass
                    except Exception:
                        pass
                if "res.pack" not in z.namelist():
                    index_plain_zip(z, game, ver)
    for game, versions in versions_by_game.items():
        for ver in versions:
            print("processing", game, ver)
            all_results.append(process_version(game, ver))
    json.dump(all_results, open(os.path.join(OUT, "ALL_MANIFEST.json"), "w"), indent=2)
    json.dump(versions_by_game, open(os.path.join(OUT, "VERSIONS.json"), "w"), indent=2)

    lines = ["# Decrypted game/version source", "", "Root: `C:\\Users\\quefep\\Desktop\\Decomp Temp\\DECRYPTED`", ""]
    for game, versions in versions_by_game.items():
        lines.append("## %s" % GAME_NAMES.get(game, game))
        lines.append("")
        for ver in versions:
            r = next(x for x in all_results if x["game"] == game and x["version"] == ver)
            lines.append("- `%s\\%s` — source=%d bytecode=%d csv=%d unresolved=%d" % (GAME_NAMES.get(game, game), ver, len(r["source"]), len(r["bytecode"]), len(r["csv"]), len(r["unresolved"])))
        lines.append("")
    open(os.path.join(OUT, "START_HERE.md"), "w", encoding="utf-8").write("\n".join(lines))
    print("done", len(all_results), "versions")


if __name__ == "__main__":
    main()
