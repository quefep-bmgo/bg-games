# 10 — End-to-end walkthrough: how this archive was made

This is the full chronological method used to go from the public game manifest to verified Lua source, bytecode, maps, and configuration.

It covers:

- finding the game/version API
- downloading every version
- identifying the pack container
- decrypting the TOC
- extracting KeyObject lists
- reversing the payload cipher
- removing source wrappers
- decoding CSV substitution
- decompiling Lua bytecode
- proving the outputs are real
- producing the reusable extractor
- documenting the remaining gaps

---

## 1. Seed the game IDs

The APK was used as the starting point.

Relevant assets included:

```text
Media/Scripts/Engine/...
Media/Scripts/Game/gXXXX/...
```

The game ID list was seeded from the APK’s:

```text
ScriptSetting.csv
```

That list was then expanded by probing nearby IDs:

```text
g1000–g1199
g2000–g2199
g3000–g3199
g9000–g9199
```

This produced the live game inventory:

```text
...\reports\GAME_INVENTORY.md
```

Not every probe returned content. The returned IDs are the real game packages.

---

## 2. Query the public game manifest

Every game has a public manifest:

```text
GET https://static.sandboxol.com/sandbox/config/server/game-resource-config_<gameId>
```

Examples:

```text
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1042
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1100
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1048
https://static.sandboxol.com/sandbox/config/server/game-resource-config_g1005
```

It returned HTTP 200 without authentication during this work.

The response is a JSON object keyed by version number:

```json
{
  "10113": {
    "plugin": "http://staticgs.sandboxol.com/sandbox/games/plugins/g1042.1770004775563.zip",
    "pluginHash": "6dc5b67499d9229a2653d3b7d4291b47",
    "fileSize": 1487744,
    "fileCount": 7,
    "maps": [
      {
        "name": "m1042_1",
        "durl": "http://staticgs.sandboxol.com/sandbox/games/maps/g1042.1766550369931.zip",
        "mapHash": "4339c2d285938b4547119a8513aff497",
        "fileSize": 4331961,
        "fileCount": 43
      }
    ]
  }
}
```

Key fields:

- `plugin`: plugin zip
- `pluginHash`: expected plugin hash
- `fileSize` / `fileCount`: artifact metadata
- `maps[].durl`: map zip
- `maps[].mapHash`: expected map hash
- `maps[].configFiles[]`: older maps with individual config files
- `pluginStaging` / `mapsStaging`: unreleased or staged artifacts

---

## 3. Download the artifacts

The download layout is:

```text
games\<gameId>\game-resource-config.json
game_configs\<gameId>.json
games\<gameId>\v<version>\plugin.zip
games\<gameId>\v<version>\maps\<map>.zip
games\<gameId>\v<version>\maps-staging\<map>.zip
games\<gameId>\v<version>\version.json
```

The manifest keys are numeric (`10113`); the local folders use `v` prefixes (`v10113`).

The current downloader is:

```text
...\howto\scripts\download_game_resources.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "...\howto\scripts\download_game_resources.py" `
  --game g1042 `
  --out "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --version 10113
```

All versions:

```powershell
... --game g1042 --out "...\games"
```

The script was tested by downloading the live g1042 `v10113` plugin and map.

Artifact hosts observed:

```text
staticgs.sandboxol.com      main CDN
txstaticgs.sandboxol.com    Tencent mirror
static.sandboxol.com        manifest/older artifacts
bstaticgs.sandboxol.com     asset/upload host
```

The same objects were sometimes available from more than one host.

---

## 4. Identify the pack container

A `res.pack` has this structure:

```text
u32 len1
byte[len1] header blob
u32 len2
byte[len2] encrypted TOC
u32 content_size
byte[content_size] content
```

Content base:

```text
content_base = 4 + len1 + 4 + len2 + 4
```

`len2` is the encrypted TOC length, not the unpadded plaintext length.

The TOC entry format:

```text
u16 name_len
byte[name_len] name
u32 offset
u32 size
u32 size2
u8 flag
```

Offset is relative to `content_base`.

Flags:

- `0`: encrypted Lua
- `1`: substituted CSV/text

---

## 5. Decrypt the TOC

Two pack generations were found.

### Current packs

Header:

```text
00 03 c1 e9 2c 11 5e d7 e4 8d 4e e1 d4 0d 92 42
```

The current TOC uses the game’s modified AES implementation.

The key literal is:

```text
blrsp20241212345
```

The implementation was reached through the native library:

```text
0x1f348d0   context init
0x1f35acc   decrypt
```

The working bridge is:

```text
...\howto\scripts\emu_lib.py
```

It uses Unicorn to call the native routines with the modified AES tables.

Example:

```python
from emu_lib import decrypt
toc_plain = decrypt(toc_cipher, b"blrsp20241212345", 0)[0]
```

### Legacy packs

Header:

```text
c9 2e a8 41 b5 87 ea c4 a1 75 1b f5 19 87 36 82
```

The legacy TOC is standard AES-128-ECB with PKCS#7:

```python
from Crypto.Cipher import AES

def unpad(b):
    n = b[-1]
    assert 1 <= n <= 16 and b[-n:] == bytes([n]) * n
    return b[:-n]

plain = unpad(AES.new(b"blrsp20241212345", AES.MODE_ECB).decrypt(toc_cipher))
```

The current modified-AES path must not be used for legacy TOCs.

---

## 6. Understand the TOC’s role

Once the TOC is parsed, every entry is known:

- exact path
- offset
- ciphertext size
- flag
- order

No guessing or string scanning is needed for normal extraction.

---

## 7. Recover the KeyObject database

The payload cipher needs per-entry lists.

Those come from `sandboxol`.

### Current numeric frames

Shape:

```text
u16 name_len
name
u16 key_len
numeric key
u32 blob_len
encrypted blob
```

The numeric key is split on `-`:

```python
nums = [int(x) for x in key.split("-")]
```

The blob is decrypted with the same native AES path:

```python
plain_keyfile = decrypt_large(blob, gen(nums), 0)
```

The first frame is the KeyObject database.

### Flat records

Used by newer plugin packs:

```text
u16 key_len = 32
char[32] key
u16 nlists
repeat:
  u16 count
  u16[count] instructions
```

### Header records

Used by engine/some game packs:

```text
u16 key_len = 32
char[32] key
u16 h1
u8 h2
u32 w10
u16 nlists
repeat:
  u16 count
  u16[count] instructions
```

### Special trailing records

Some g1100/g1048 keyfiles have a normal block followed by a special block.

The special case included:

```text
12-byte prefix
22-hex key
8 lists
```

The 22-hex key is matched against the suffix of a raw ciphertext MD5:

```text
raw_md5.endswith("f16f1d21cc5f0a28b0b81c")
```

This is why a plain `keys[raw_md5]` lookup missed one g1100 entry.

---

## 8. Payload cipher

For every `flag=0` entry:

```text
selector, a, b
```

produces:

```text
p0 = apply_list(a, lists[selector >> 4])
p1 = apply_list(b, lists[selector & 0x0f])
```

The record is selected by:

```python
hashlib.md5(ciphertext).hexdigest()
```

List instruction:

```text
(op << 8) | param
```

Ops:

```text
0 subtract
1 xor
2 swap nibbles
```

Decryption applies the list in reverse storage order.

Encryption:

```text
0 add
1 xor
2 swap nibbles
```

and applies the list in forward order, preserving the selector byte.

This inverse is the proof:

```python
encrypt(decrypt(ciphertext)) == ciphertext
```

---

## 9. Remove the source wrapper

Most plugin plaintext is not the original source. It is:

```text
--[[R1]]
... integrity/length code ...
local len = N
local checkFileName = "<basename>"
...
table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[R2]]
original source
--[[R3]]---
```

The original source is extracted between the `R2` marker and the final `--[[`.

The full wrapper is kept for audit.

---

## 10. Decode CSV entries

`flag=1` entries use byte substitution.

`data/sub_table.pkl` maps:

```text
plaintext byte -> ciphertext byte
```

Decrypt:

```python
inv = {c: p for p, c in table.items()}
plain = bytes(inv.get(b, b) for b in ciphertext)
```

Verify:

```python
enc = bytes(table.get(b, b) for b in plain)
assert enc == ciphertext
```

This was verified on:

- g1042 plugin CSVs 21/21
- g1042 map CSVs 37/37
- g1048 CSVs 281/281
- g1100 14/15 per room pack

The known partial case is g1100 `setting/lang/lang.csv`, whose Unicode byte set is not fully covered by the known table.

---

## 11. Bytecode

Engine and some game packs decrypt to Lua 5.1 bytecode:

```text
1b 4c 75 61 53 00
```

Bytecode is saved as `.luac`.

Decompile with:

```powershell
& "C:\Program Files\Zulu\zulu-25\bin\java.exe" `
  -jar "C:\Users\quefep\AppData\Local\Temp\opencode\bg\tools\unluac\unluac.jar" `
  "file.luac"
```

Batch drivers:

```text
...\howto\scripts\decompile_engine.py
...\howto\scripts\decompile_games.py
```

---

## 12. Verify, do not trust

The critical rule was:

```text
A plaintext file is accepted only if re-encryption reproduces the original ciphertext.
```

Checks:

1. TOC parses exactly to unpadded length.
2. Every flag=0 entry has a KeyObject.
3. Payload size is `2/3` ciphertext size.
4. Re-encryption is byte-exact.
5. Wrapper markers and basename match.
6. Bytecode starts with `1bLuaS`.
7. unluac output is non-empty.
8. Source MD5 matches patch map where available.

Results:

| Pack | Result |
|---|---|
| g1042 plugin v10113 | 508/508 Lua |
| g1100 v10113 | 615/615 Lua |
| g1048 v10113 | 431/431 Lua |
| engine | 343/343 Lua |
| map CSVs | 37/37 |
| g1100 base | 187/187 Lua |
| TOCs | 5/5 byte-exact |

Known exceptions:

- g1100 `ItemSkillEvents.lua` — malformed key record
- g1100 `lang.csv` — incomplete Unicode substitution coverage
- g1188 `WorldPlotRuntime.lua` — no key record

---

## 13. What `res.pack` is and is not

It is:

- Lua source or bytecode
- client/server/engine logic
- UI code
- packet handlers
- reward/economy logic
- config tables
- anti-cheat checks
- mode/map routing

It is not:

- terrain
- textures
- models
- live backend logic
- server secrets beyond what the client ships

Map terrain is in:

```text
games\<game>\v<version>\maps\mXXXX_N.zip
```

as `r.*.mca` region files.

Map configuration is in `config.yml`, `setting/`, and the map `res.pack` CSVs.

---

## 14. Outputs

Latest fully decrypted source:

```text
...\DECRYPTED\g1042_build_and_shoot\v10113\source
...\DECRYPTED\g1100_rooms\v10113\source
...\DECRYPTED\g1048_skyblock\v10113\source
...\DECRYPTED\g1005_clanwar\v10072\source
```

Version tree:

```text
...\DECRYPTED\<game>\<version>\
  source
  wrapped
  bytecode
  csv
  cipher
  config
  map_config
  map_csv
  MANIFEST.json
  UNRESOLVED.txt
```

Reports:

```text
...\DECRYPTED\REPORTS\INDEPENDENT_VALIDATION.md
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
...\g1042_analysis\reports\G1042_MECHANICS.md
...\g1042_analysis\reports\G1042_VERSION_TIMELINE.md
...\g1042_analysis\reports\G1100_ROOM_ANALYSIS.md
...\g1042_analysis\reports\G1100_LUA_API.md
...\g1042_analysis\reports\G1100_SYSTEMS_PENTEST.md
```

---

## 15. Reusable extractor

```text
...\howto\scripts\bmg_extract.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "...\howto\scripts\bmg_extract.py" `
  --games-root "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --out "C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED_NEW" `
  --games g1042,g1100,g1048,g1005
```

One version:

```powershell
... --games g1044 --versions v10113
```

---

## 16. Remaining gaps

Legacy `v10109`–`v10112`:

- TOC solved with AES-128-ECB
- CSV solved
- Lua blocked on the legacy `sandboxol` blob key

g1042 v10104:

- obfuscated wrapper not reduced to source

g1042 v10105:

- encrypted per-file format without a recovered key

g1042 v10106–v10108:

- partially recovered via inline source MD5

g1048 v10106–v10108 and g1100 v10108:

- same inline-MD5 recovery strategy

g1005:

- only v10057–v10072 are present in the supplied dataset
- all are plaintext source

These are documented in:

```text
...\howto\08-other-obfuscation.md
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
```
