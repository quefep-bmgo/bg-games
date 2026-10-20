import json
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
JAVA = r"C:\Program Files\Zulu\zulu-25\bin\java.exe"
JAR = r"C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar"
ROOT = os.path.join(B, "decrypted_games")

out = []
fail = []
for game in ["g1032", "g1033", "g1035", "g1080", "g1149", "g1188", "g1100"]:
    mp = os.path.join(ROOT, game, "manifest.json")
    if not os.path.exists(mp):
        continue
    manifest = json.load(open(mp, encoding="utf-8"))
    srcroot = os.path.join(ROOT, game, "bytecode")
    for row in manifest:
        if row["type"] != "bytecode":
            continue
        src = row["path"]
        rel = os.path.relpath(src, srcroot)
        if rel.endswith(".luac"):
            rel = rel[:-5]
        dst = os.path.join(ROOT, game, "decompiled", rel)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        r = subprocess.run([JAVA, "-jar", JAR, src], capture_output=True)
        if r.returncode == 0 and r.stdout:
            open(dst, "wb").write(r.stdout)
            out.append({"game": game, "name": row["name"], "path": dst, "size": len(r.stdout)})
        else:
            fail.append({"game": game, "name": row["name"], "returncode": r.returncode, "stderr": r.stderr.decode("utf-8", "replace")[:500]})
    print(game, "decompiled", sum(1 for x in out if x["game"] == game), "failed", sum(1 for x in fail if x["game"] == game))

json.dump(out, open(os.path.join(ROOT, "decompiled_manifest.json"), "w"), indent=2)
json.dump(fail, open(os.path.join(ROOT, "decompile_failures.json"), "w"), indent=2)
print("total", len(out), "fail", len(fail))
