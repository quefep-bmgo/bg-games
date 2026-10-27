import argparse
import json
import os
import sys
import urllib.request

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

MANIFEST = "https://static.sandboxol.com/sandbox/config/server/game-resource-config_{game}"


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def download(url, path):
    data = fetch(url)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)
    print("downloaded", path, len(data))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--version", default="")
    ap.add_argument("--include-staging", action="store_true")
    args = ap.parse_args()

    game = args.game
    out = os.path.abspath(args.out)
    game_root = os.path.join(out, game)
    os.makedirs(game_root, exist_ok=True)

    raw = fetch(MANIFEST.format(game=game))
    manifest = json.loads(raw)
    with open(os.path.join(game_root, "game-resource-config.json"), "wb") as f:
        f.write(raw)

    versions = [args.version] if args.version else sorted(manifest)
    for v in versions:
        key = v[1:] if v.startswith("v") else v
        if key not in manifest:
            print("missing version", v)
            continue
        meta = manifest[key]
        vdir = os.path.join(game_root, "v" + key)
        os.makedirs(vdir, exist_ok=True)

        if meta.get("plugin"):
            download(meta["plugin"], os.path.join(vdir, "plugin.zip"))

        for m in meta.get("maps", []):
            name = m.get("name") or os.path.basename(m["durl"]).split(".")[0]
            download(m["durl"], os.path.join(vdir, "maps", name + ".zip"))
            for c in m.get("configFiles", []):
                if c.get("url"):
                    download(c["url"], os.path.join(vdir, "maps-config", c["name"]))

        if args.include_staging:
            if meta.get("pluginStaging", {}).get("plugin"):
                download(meta["pluginStaging"]["plugin"], os.path.join(vdir, "plugin-staging.zip"))
            for m in meta.get("mapsStaging", []):
                name = m.get("name") or os.path.basename(m["durl"]).split(".")[0]
                download(m["durl"], os.path.join(vdir, "maps-staging", name + ".zip"))

        info = {
            "fileSize": meta.get("fileSize"),
            "fileCount": meta.get("fileCount"),
            "pluginHash": meta.get("pluginHash"),
            "hasPluginStaging": bool(meta.get("pluginStaging")),
            "hasMapsStaging": bool(meta.get("mapsStaging")),
        }
        with open(os.path.join(vdir, "version.json"), "w", encoding="utf-8") as f:
            json.dump(info, f, indent=1)
        print("version", key, "done")


if __name__ == "__main__":
    main()
