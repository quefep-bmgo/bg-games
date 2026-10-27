#!/usr/bin/env python3
"""Decrypt the legacy (v10109-v10112) Blockman GO sandboxol keyfile."""
import argparse
import csv
import hashlib
import json
import os
import struct
import sys
import zipfile

from Crypto.Cipher import AES

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

KEYOBJECT_KEY = b"blsle20240112345"
PATCH_KEY = b"bmlle20240922345"


def unpad(data):
    if not data:
        raise ValueError("empty ciphertext")
    n = data[-1]
    if not 1 <= n <= 16 or data[-n:] != bytes([n]) * n:
        raise ValueError("invalid PKCS#7 padding")
    return data[:-n]


def parse_records(data):
    records = []
    off = 0
    while off + 2 <= len(data):
        groups = []
        for _ in range(2):
            if off + 2 > len(data):
                return records, off
            count = struct.unpack_from("<H", data, off)[0]
            off += 2
            if count > 64:
                return records, off
            strings = []
            for _ in range(count):
                if off + 2 > len(data):
                    return records, off
                n = struct.unpack_from("<H", data, off)[0]
                off += 2
                if n > 4096 or off + n > len(data):
                    return records, off
                strings.append(data[off:off + n])
                off += n
            groups.append(strings)
        if len(groups[0]) != 8 or len(groups[1]) != 4:
            return records, off
        if off + 4 > len(data):
            return records, off
        blob_len = struct.unpack_from("<I", data, off)[0]
        off += 4
        if blob_len > len(data) or off + blob_len > len(data):
            return records, off
        records.append({
            "names": groups[0],
            "keys": groups[1],
            "blob": data[off:off + blob_len],
        })
        off += blob_len
    return records, off


def parse_keyobjects(data):
    off = 0
    rows = []
    while off + 36 <= len(data):
        key_len = struct.unpack_from("<H", data, off)[0]
        if key_len != 32:
            break
        key = data[off + 2:off + 34]
        if not all(c in b"0123456789abcdef" for c in key):
            break
        off += 34
        nlists = struct.unpack_from("<H", data, off)[0]
        off += 2
        if nlists > 64:
            break
        lists = []
        ok = True
        for _ in range(nlists):
            if off + 2 > len(data):
                ok = False
                break
            count = struct.unpack_from("<H", data, off)[0]
            off += 2
            if count > 32 or off + count * 2 > len(data):
                ok = False
                break
            lists.append(list(struct.unpack_from("<%dH" % count, data, off)))
            off += count * 2
        if not ok:
            break
        rows.append({"key": key.decode("ascii"), "lists": lists})
    return rows, off


def parse_patch_map(data):
    off = 0
    rows = []
    while off + 68 <= len(data):
        a = struct.unpack_from("<H", data, off)[0]
        b = struct.unpack_from("<H", data, off + 34)[0]
        if a != 32 or b != 32:
            break
        src = data[off + 2:off + 34]
        dst = data[off + 36:off + 68]
        if not all(c in b"0123456789abcdef" for c in src + dst):
            break
        rows.append({"source_md5": src.decode("ascii"), "cipher_md5": dst.decode("ascii")})
        off += 68
    return rows, off


def write_keyobjects(path, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["md5", "nlists", "list0", "list1", "list2", "list3", "list4", "list5", "list6", "list7"])
        for r in rows:
            vals = [" ".join("%d" % x for x in lst) for lst in r["lists"]]
            vals += [""] * (8 - len(vals))
            w.writerow([r["key"], len(r["lists"])] + vals[:8])


def write_patch_map(path, rows):
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["source_md5", "cipher_md5"])
        w.writeheader()
        w.writerows(rows)


def load_input(path):
    if os.path.isdir(path):
        for name in ("plugin.zip", "sandboxol"):
            p = os.path.join(path, name)
            if os.path.exists(p):
                path = p
                break
        else:
            raise SystemExit("directory has no plugin.zip or sandboxol")
    if zipfile.is_zipfile(path):
        z = zipfile.ZipFile(path)
        if "sandboxol" not in z.namelist():
            raise SystemExit("zip has no sandboxol entry")
        return z.read("sandboxol"), z.read("res.pack") if "res.pack" in z.namelist() else None
    return open(path, "rb").read(), None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input", help="legacy plugin.zip, sandboxol file, or directory")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    sandboxol, _ = load_input(args.input)
    records, end = parse_records(sandboxol)
    if len(records) < 2:
        raise SystemExit("could not parse two legacy sandboxol records (parse end %d)" % end)

    os.makedirs(args.out, exist_ok=True)
    report = {
        "input": os.path.abspath(args.input),
        "sandboxol_size": len(sandboxol),
        "sandboxol_parse_end": end,
        "records": [],
    }
    for i, rec in enumerate(records[:2]):
        key = KEYOBJECT_KEY if i == 0 else PATCH_KEY
        plain = unpad(AES.new(key, AES.MODE_ECB).decrypt(rec["blob"]))
        blob_path = os.path.join(args.out, "blob%d.bin" % i)
        open(blob_path, "wb").write(plain)
        info = {
            "record": i,
            "key_ascii": key.decode("ascii"),
            "key_hex": key.hex(),
            "cipher_size": len(rec["blob"]),
            "plain_size": len(plain),
            "plain_sha256": hashlib.sha256(plain).hexdigest(),
            "blob_file": os.path.abspath(blob_path),
        }
        if i == 0:
            rows, used = parse_keyobjects(plain)
            info.update({"keyobject_count": len(rows), "keyobject_parse_end": used})
            write_keyobjects(os.path.join(args.out, "keyobjects.csv"), rows)
        else:
            rows, used = parse_patch_map(plain)
            info.update({"patch_count": len(rows), "patch_parse_end": used})
            write_patch_map(os.path.join(args.out, "patch_map.csv"), rows)
        report["records"].append(info)

    with open(os.path.join(args.out, "report.json"), "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
