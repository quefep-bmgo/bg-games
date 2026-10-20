import hashlib
import json
import os
import pickle
import struct
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis")

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
OUT = os.path.join(B, "VERIFICATION")
os.makedirs(OUT, exist_ok=True)


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
        else:
            raise ValueError(hex(v))
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


def content_of(path):
    d = open(path, "rb").read()
    l1 = struct.unpack_from("<I", d, 0)[0]
    o = 4 + l1
    l2 = struct.unpack_from("<I", d, o)[0]
    cb = o + 4 + l2 + 4
    return d, cb


def md5(b):
    return hashlib.md5(b).hexdigest()


def verify_pack(label, pack, toc, keys, source_root=None, wrapped_root=None):
    d, cb = content_of(pack)
    entries = parse_toc(open(toc, "rb").read())
    failures = []
    ok = 0
    for name, off, size, size2, flag in entries:
        if flag == 1:
            continue
        raw = d[cb + off:cb + off + size]
        rec = keys.get(md5(raw))
        if rec is None:
            failures.append({"name": name, "error": "missing key"})
            continue
        if wrapped_root is not None:
            rel = name
            if rel.startswith("Media/Scripts/Game/g1100/"):
                rel = rel[len("Media/Scripts/Game/g1100/"):]
            wp = os.path.join(wrapped_root, rel)
            if not os.path.exists(wp):
                failures.append({"name": name, "error": "missing wrapped file"})
                continue
            plain = open(wp, "rb").read()
        elif source_root is not None and not name.endswith(".csv"):
            rel = name
            if rel.startswith("Media/Scripts/Engine/"):
                rel = rel[len("Media/Scripts/Engine/"):]
            sp = os.path.join(source_root, rel + ".luac")
            if not os.path.exists(sp):
                failures.append({"name": name, "error": "missing bytecode"})
                continue
            plain = open(sp, "rb").read()
        else:
            continue
        if len(raw) != len(plain) * 3 // 2:
            failures.append({"name": name, "error": "length mismatch"})
            continue
        if encrypt_payload(plain, raw, rec) == raw:
            ok += 1
        else:
            failures.append({"name": name, "error": "re-encrypt mismatch"})
    return {"label": label, "entries": len(entries), "verified": ok, "failures": failures}


def verify_csv_roundtrip(pack, toc, sub):
    d, cb = content_of(pack)
    entries = parse_toc(open(toc, "rb").read())
    ok = 0
    fail = []
    for name, off, size, size2, flag in entries:
        if flag != 1:
            continue
        raw = d[cb + off:cb + off + size]
        dst = os.path.join(B, "decrypted_map", name)
        if not os.path.exists(dst):
            fail.append({"name": name, "error": "missing"})
            continue
        plain = open(dst, "rb").read()
        if bytes(sub.get(x, x) for x in plain) == raw:
            ok += 1
        else:
            fail.append({"name": name, "error": "substitution mismatch"})
    return {"entries": ok + len(fail), "verified": ok, "failures": fail}


def main():
    report = {}

    plugin_keys = {r["key"]: r for r in json.load(open(os.path.join(B, "keyobjects_plugin.json"), encoding="utf-8"))}
    report["plugin_508"] = verify_pack("plugin_508", os.path.join(B, "plugin", "res.pack"), os.path.join(B, "toc_plugin.bin"), plugin_keys, wrapped_root=os.path.join(B, "decrypted_plugin", "wrapped"))

    engine_recs = json.load(open(os.path.join(B, "keyobjects_engine_current.json"), encoding="utf-8"))
    engine_keys = {r["key"]: r for r in engine_recs}
    report["engine_343"] = verify_pack("engine_343", os.path.join(B, "native", "bgmap_engine_res.pack"), os.path.join(B, "toc_engine.bin"), engine_keys, source_root=os.path.join(B, "decrypted_engine", "bytecode"))

    g1100_keys = {r["key"]: r for r in json.load(open(os.path.join(B, "decrypted_games", "g1100", "keyobjects_g1100.json"), encoding="utf-8"))}
    report["g1100_base_187"] = {"skipped": "validated by separate g1100 round-trip script"}

    sub = pickle.load(open(os.path.join(B, "sub_table.pkl"), "rb"))
    report["map_csv_37"] = verify_csv_roundtrip(os.path.join(B, "map", "res.pack"), os.path.join(B, "toc_map.bin"), sub)

    json.dump(report, open(os.path.join(OUT, "verification.json"), "w"), indent=2)
    lines = ["# Verification Report", ""]
    for k, v in report.items():
        lines.append("## " + k)
        lines.append("```json")
        lines.append(json.dumps(v, indent=2)[:6000])
        lines.append("```")
    open(os.path.join(OUT, "VALIDATION_REPORT.md"), "w", encoding="utf-8").write("\n".join(lines))
    for k, v in report.items():
        print(k, v.get("entries", ""), v.get("verified", ""), "failures", len(v.get("failures", [])))


if __name__ == "__main__":
    main()
