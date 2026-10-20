# 06 — Validation and reproduction

## 1. What “verified” means here

A candidate is only accepted if it survives all applicable checks:

1. TOC decrypts with valid PKCS#7 padding or valid custom-AES output.
2. TOC parses cleanly to the exact unpadded length.
3. Every entry has a matching KeyObject record.
4. Plaintext length equals `ciphertext_length * 2 / 3`.
5. Re-encryption reproduces the original ciphertext byte-for-byte.
6. Plugin source produces a valid wrapper and extracted source.
7. Bytecode starts with `1bLuaS`.
8. unluac produces non-empty output.
9. Source MD5 matches the patch map where a patch pair exists.

## 2. Reported validation results

Independent verification results:

| Pack | Entries | Pass | Lua | CSV |
|---|---:|---:|---:|---:|
| g1042 plugin v10113 | 529 | 529 | 508/508 | 21/21 |
| engine | 343 | 343 | 343/343 | 0/0 |
| map | 37 | 37 | 0/0 | 37/37 |
| g1100 base | 202 | 201 | 187/187 | 14/15 |
| g1100 v10113 | 631 | 629 | 615/616 | 14/15 |

Known exceptions:

- `g1100/setting/lang/lang.csv` — partial substitution table, present in both room packs
- `g1100_v10113/lua/plugins/item_skill/common/event/ItemSkillEvents.lua` — malformed/incomplete key record
- `g1188/WorldPlotRuntime.lua` — no key record

g1048 v10113 was validated separately:

```text
g1048 v10113: 431/431 Lua entries re-encrypt byte-exactly
```

## 3. Run the verifier

From the analysis workspace:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\verify_pipeline.py"
```

Example output:

```text
plugin_508 529 508 failures 0
engine_343 343 343 failures 0
g1100_base_187   failures 0
map_csv_37 37 37 failures 0
```

The g1100-specific verifier:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\verify_g1100.py"
```

Expected:

```text
base 202 201 fail 1
latest 631 629 fail 2
```

The failures are the known `lang.csv` and `ItemSkillEvents.lua` exceptions.

## 4. Run unluac

```powershell
& "C:\Program Files\Zulu\zulu-25\bin\java.exe" `
  -jar "C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar" `
  "C:\...\decrypted_engine\bytecode\lua\plugins\db_lock\db_lock.lua.luac"
```

## 5. Extract another minigame

The reusable extractor is:

```text
...\howto\scripts\bmg_extract.py
```

It expects:

```text
<games-root>\<game>\<version>\plugin.zip
<games-root>\<game>\<version>\maps\*.zip
<games-root>\<game>\<version>\maps-staging\*.zip
```

Run one game:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "...\howto\scripts\bmg_extract.py" `
  --games-root "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --out "C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED_NEW" `
  --games g1044
```

Run one version:

```powershell
... --games g1044 --versions v10113
```

Run several:

```powershell
... --games g1043,g1044,g1045,g1053
```

## 6. Dependencies

The scripts use:

- Python 3.12
- `pycryptodome` for legacy AES-ECB
- `unicorn` for the current modified AES path
- `pyelftools`, `capstone`
- Java + `unluac` for bytecode decompilation

Paths used during the analysis:

```text
Python:
C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe

Java:
C:\Program Files\Zulu\zulu-25\bin\java.exe

unluac:
C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar

Native library:
C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\native\bg_libBlockMan_arm64.so
```

## 7. Reproducing the legacy gap

Legacy TOCs can be decrypted with:

```python
from Crypto.Cipher import AES
plain = unpad(AES.new(b"blrsp20241212345", AES.MODE_ECB).decrypt(toc))
```

Legacy Lua remains blocked on the `sandboxol` blob key. Do not claim those entries are decrypted until the blob key is recovered and the corresponding re-encryption test passes.

See:

```text
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
```

## 8. Version coverage in the supplied data

- g1005: v10057-v10072 only
- g1042: v10068-v10113
- g1048: v10105-v10113
- g1100: v10108-v10113

The extractor processes whatever versions are present; it cannot invent missing CDN artifacts.
