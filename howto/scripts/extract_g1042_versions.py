import hashlib
import json
import os
import re
import struct
import sys
import zipfile

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = r"C:\Users\quefep\Desktop\Decomp Temp\games\g1042"
OUT = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\g1042_versions"
LATEST_SOURCE = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\decrypted_plugin\source"


def safe_rel(name):
    name = name.replace("\\", "/")
    if name.startswith("/") or ".." in name.split("/"):
        raise ValueError(name)
    return name


def md5(b):
    return hashlib.md5(b).hexdigest()


def main():
    os.makedirs(OUT, exist_ok=True)
    versions = sorted(d for d in os.listdir(BASE) if re.fullmatch(r"v\d+", d))
    plain_sources = {}
    manifests = {}

    for v in versions:
        vp = os.path.join(BASE, v, "plugin.zip")
        if not os.path.exists(vp):
            continue
        z = zipfile.ZipFile(vp)
        m = {"version": v, "plugin_entries": len(z.namelist()), "source": [], "encrypted": [], "config": [], "map": [], "other": []}
        outroot = os.path.join(OUT, v)
        for n in z.namelist():
            if n.endswith("/"):
                continue
            b = z.read(n)
            rel = safe_rel(n)
            h = md5(b)
            if rel.endswith(".lua"):
                if b.startswith((b"--", b"local", b"return", b"function", b"require", b"module", b"#!")):
                    dst = os.path.join(outroot, "source", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                    m["source"].append({"name": rel, "size": len(b), "md5": h, "path": dst})
                    plain_sources[h] = (v, rel, b)
                elif len(b) >= 34 and b[:2] == b"\x20\x00" and re.fullmatch(rb"[0-9a-f]{32}", b[2:34]):
                    inline = b[2:34].decode()
                    dst = os.path.join(outroot, "encrypted", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                    m["encrypted"].append({"name": rel, "size": len(b), "md5": h, "inline_md5": inline, "path": dst})
                else:
                    dst = os.path.join(outroot, "other", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
                    m["other"].append({"name": rel, "size": len(b), "md5": h, "path": dst})
            elif rel.startswith("setting/") or rel.endswith((".json", ".yml", ".yaml", ".csv", ".ini", ".txt")):
                dst = os.path.join(outroot, "config", rel)
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                open(dst, "wb").write(b)
                m["config"].append({"name": rel, "size": len(b), "md5": h, "path": dst})
            elif rel == "res.pack" or rel == "sandboxol" or rel == "checksums.md5":
                m["other"].append({"name": rel, "size": len(b), "md5": h})
            else:
                m["other"].append({"name": rel, "size": len(b), "md5": h})

        mp = os.path.join(BASE, v, "maps", "m1042_1.zip")
        if os.path.exists(mp):
            mz = zipfile.ZipFile(mp)
            for n in mz.namelist():
                if n.endswith("/"):
                    continue
                b = mz.read(n)
                rel = safe_rel(n)
                h = md5(b)
                m["map"].append({"name": rel, "size": len(b), "md5": h})
                if rel.endswith((".csv", ".json", ".yml", ".yaml", ".lang", ".txt", ".cfg")):
                    dst = os.path.join(outroot, "map_config", rel)
                    os.makedirs(os.path.dirname(dst), exist_ok=True)
                    open(dst, "wb").write(b)
        manifests[v] = m
        print(v, "source", len(m["source"]), "enc", len(m["encrypted"]), "config", len(m["config"]), "map", len(m["map"]))

    for v, m in manifests.items():
        for e in m["encrypted"]:
            hit = plain_sources.get(e["inline_md5"])
            if hit:
                srcv, srcname, data = hit
                dst = os.path.join(OUT, v, "recovered_source", e["name"])
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                open(dst, "wb").write(data)
                e["recovered_from"] = srcv
                e["recovered_name"] = srcname
                e["source_md5"] = hashlib.md5(data).hexdigest()

    latest = {}
    if os.path.isdir(LATEST_SOURCE):
        for dp, dn, fn in os.walk(LATEST_SOURCE):
            for f in fn:
                p = os.path.join(dp, f)
                rel = os.path.relpath(p, LATEST_SOURCE).replace("\\", "/")
                b = open(p, "rb").read()
                latest[rel] = {"size": len(b), "md5": md5(b)}
    manifests["v10113"]["latest_source"] = latest

    json.dump(manifests, open(os.path.join(OUT, "versions_manifest.json"), "w"), indent=2)
    print("versions", len(manifests), "out", OUT)


if __name__ == "__main__":
    main()
