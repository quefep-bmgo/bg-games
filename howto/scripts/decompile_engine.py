import json
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

B = r"C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis"
JAVA = r"C:\Program Files\Zulu\zulu-25\bin\java.exe"
JAR = r"C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar"
SRC = os.path.join(B, "decrypted_engine", "bytecode")
DST = os.path.join(B, "decrypted_engine", "decompiled")

manifest = json.load(open(os.path.join(B, "decrypted_engine", "manifest.json"), encoding="utf-8"))
out = []
fail = []
for i, row in enumerate(manifest):
    src = row["path"]
    rel = os.path.relpath(src, SRC)
    if rel.endswith(".luac"):
        rel = rel[:-5]
    dst = os.path.join(DST, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    r = subprocess.run([JAVA, "-jar", JAR, src], capture_output=True)
    if r.returncode == 0 and r.stdout:
        open(dst, "wb").write(r.stdout)
        out.append({"name": row["name"], "path": dst, "size": len(r.stdout)})
    else:
        fail.append({"name": row["name"], "returncode": r.returncode, "stderr": r.stderr.decode("utf-8", "replace")[:500]})
    if (i + 1) % 50 == 0:
        print("done", i + 1, "of", len(manifest))

json.dump(out, open(os.path.join(B, "decrypted_engine", "decompiled_manifest.json"), "w"), indent=2)
json.dump(fail, open(os.path.join(B, "decrypted_engine", "decompile_failures.json"), "w"), indent=2)
print("decompiled", len(out), "failed", len(fail))
for x in fail[:10]:
    print(x)
