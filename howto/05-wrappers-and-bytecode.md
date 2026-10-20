# 05 — Wrappers and Lua 5.1 bytecode

## 1. Plugin source wrapper

Most plugin `flag = 0` entries decrypt to a Lua source wrapper, not directly to the original file.

Shape:

```text
--[[R1]]
<fixed length/integrity code>
local len = <N>
local checkFileName = "<basename>"
...
table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[R2]]
<ORIGINAL SOURCE>
--[[R3]]---
```

The wrapper adds hundreds of bytes and randomizes comment text. The original source is between the `R2` marker and the final `--[[` marker.

Extraction rule used:

```python
def extract_source(plain):
    marker = b"table.insert(F_L_Check_C_NEW[checkFileName], len)"
    i = plain.find(marker)
    c = plain.find(b"--[[", i)
    e = plain.find(b"]]", c)
    suf = plain.rfind(b"--[[")
    if i >= 0 and c >= 0 and e >= 0 and suf > e + 2:
        return plain[e + 2:suf]
    return None
```

The full decrypted wrapper is stored in `wrapped\`; the extracted source is stored in `source\`.

This is why the panel-frame “source MD5” is the MD5 of the extracted source, while the raw ciphertext MD5 is the KeyObject lookup key.

## 2. Lua 5.1 bytecode

Engine and several game packs store compiled Lua 5.1 bytecode.

Header:

```text
1b 4c 75 61 53 00
```

ASCII:

```text
\x1bLuaS\x00
```

Recognize it with:

```python
if plain.startswith(b"\x1bLua"):
    ...
```

Bytecode is stored in `bytecode\<name>.luac`.

The bytecode is not encrypted at this point. It is the decrypted output of the 3-byte cipher.

## 3. Decompile with unluac

The working jar is:

```text
C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar
```

Command:

```powershell
& "C:\Program Files\Zulu\zulu-25\bin\java.exe" `
  -jar "C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar" `
  "path\to\file.luac"
```

Example output directory:

```text
...\DECRYPTED\g1100_rooms\v10113\decompiled
...\DECRYPTED\g1005_clanwar\v10072\source
```

Engine decompiled output:

```text
...\DECRYPTED\g1042_build_and_shoot\v10113\decompiled
```

The validation pass re-ran unluac and compared the fresh output byte-for-byte with the stored decompiled files.

## 4. Source vs bytecode by package

| Package | Plaintext form |
|---|---|
| g1042 v10113 plugin | wrapped source |
| g1100 v10113 plugin | wrapped source |
| g1048 v10113 plugin | wrapped source |
| engine | Lua 5.1 bytecode |
| g1100 base | Lua 5.1 bytecode |
| many APK game packs | Lua 5.1 bytecode |
| early g1042/g1005 packages | plain source |
| legacy v10109-v10112 | unresolved Lua ciphertext |

## 5. Wrapper invariants

For a valid plugin wrapper:

- the length marker exists
- `local len` exists
- `local checkFileName = "<basename>"` matches the entry basename
- the embedded source is non-empty
- `len` equals plaintext length or plaintext length minus 3, depending on the trailing `---`

These checks were used to distinguish a real decryption from a wrong key.

## 6. Useful scripts

```text
...\howto\scripts\decrypt_pack.py
...\howto\scripts\decrypt_all.py
...\howto\scripts\decompile_engine.py
...\howto\scripts\decompile_games.py
...\howto\scripts\verify_pipeline.py
```
