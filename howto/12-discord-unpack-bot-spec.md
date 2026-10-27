# Discord `/unpack` bot — v10113 implementation spec

This document defines a Discord bot command that downloads a v10113 game package from the GitHub repo and unpacks either:

1. `sandboxol`
2. `res.pack`
3. both

Proposed command:

```text
/unpack game:<gXXXX> option:<1|2|3> version:<10113>
```

Recommended slash-command description:

```text
1 = decode sandboxol
2 = unpack res.pack
3 = both
```

The bot must be authenticated to the private repo:

```text
https://github.com/quefep-bmgo/bg-games
```

---

## 1. Source paths in GitHub

Current snapshot layout:

```text
games/<game>/v<version>/plugin.zip
games/<game>/v<version>/maps/<map>.zip
games/<game>/v<version>/version.json
games/<game>/game-resource-config.json
```

Example:

```text
games/g1042/v10113/plugin.zip
```

The `plugin.zip` contains:

```text
res.pack
sandboxol
setting/
checksums.md5
```

The command should use `plugin.zip` only. Map zips are not required for the base res.pack/sandboxol operation.

---

## 2. Validate input

Before doing anything:

```python
import re

assert re.fullmatch(r"g\d{4}", game)
assert re.fullmatch(r"v?\d{5}", version)
assert option in (1, 2, 3)
```

Normalize:

```python
version_key = version[1:] if version.startswith("v") else version
version_dir = "v" + version_key
```

Optional allowlist: check that the path exists before downloading.

---

## 3. Download `plugin.zip`

The repo is private. Do not put a token in source code.

Required environment variable:

```text
GITHUB_TOKEN
```

Recommended approaches:

### Git Blob API

```text
GET https://api.github.com/repos/quefep-bmgo/bg-games/git/trees/main?recursive=1
```

Find the tree entry for:

```text
games/<game>/v<version>/plugin.zip
```

Then fetch its blob SHA:

```text
GET https://api.github.com/repos/quefep-bmgo/bg-games/git/blobs/<sha>
```

The response has base64 `content`.

This is safer than the Contents API for large plugin zips.

### Authenticated raw URL

An alternative, if the deployment supports it:

```text
https://raw.githubusercontent.com/quefep-bmgo/bg-games/main/games/<game>/v<version>/plugin.zip
```

with an `Authorization: Bearer <GITHUB_TOKEN>` header.

### Cache

Cache downloaded `plugin.zip` files on disk by:

```text
<game>:<version>
```

Use the `pluginHash` from the repo’s `version.json` or the game manifest to validate the cache.

---

## 4. Extract safely

`plugin.zip` is a normal ZIP.

Rules:

- Reject absolute paths.
- Reject `..` path components.
- Reject symlinks.
- Cap extracted size.
- Cap entry count.
- Extract only:

```text
res.pack
sandboxol
```

Do not extract or execute arbitrary Lua.

```python
if name not in ("res.pack", "sandboxol"):
    continue
```

Work in a per-request temporary directory.

---

## 5. Option 1 — decode sandboxol

### What “unpack sandboxol” means

Send back:

- the raw `sandboxol`
- decrypted frame blobs
- parsed JSON

Suggested output:

```text
sandboxol.raw
sandboxol_frames/frame0.bin
sandboxol_frames/frame1.bin
keyobjects.json
patch_map.json
summary.json
```

### Current v10113 sandboxol format

Repeated frames:

```text
u16 name_len
name
u16 key_len
numeric key
u32 blob_len
byte[blob_len] encrypted blob
```

The numeric key is split on `-`:

```python
nums = [int(x) for x in key.split("-")]
```

The blob is decrypted with the game’s modified AES implementation.

Working bridge:

```text
...\howto\scripts\emu_lib.py
```

Dependency:

```text
bg_libBlockMan_arm64.so
```

Native entry points:

```text
0x1f348d0   context init
0x1f35acc   decrypt
```

Conceptual call:

```python
plain_frame = decrypt_large(blob, gen(nums), 0)
```

### Frame 0 — KeyObject database

Flat record form:

```text
u16 key_len = 32
char[32] key
u16 nlists
repeat:
    u16 count
    u16[count] instructions
```

Header record form:

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

Output for each record:

```json
{
  "key": "ciphertext md5 hex",
  "h1": 0,
  "h2": 0,
  "w10": 0,
  "lists": [[512, 32, 512, 369], "..."]
}
```

Some newer keyfiles have a special trailing block and a key that is only 22 hex characters. Support suffix matching:

```python
if raw_md5.endswith(special_key):
    ...
```

### Frame 1 — patch map

Usually pairs:

```text
u16 key_len = 32
char[32] source_md5
u16 value_len = 32
char[32] ciphertext_md5
```

Output:

```json
{
  "source_md5_to_ciphertext_md5": {
    "...": "..."
  }
}
```

### Option 1 result

Return a ZIP containing the raw file, frame blobs, JSON databases, and a summary.

Do not include `res.pack` source in option 1.

---

## 6. Option 2 — unpack res.pack

### What “unpack res.pack” means

Decrypt the plugin `res.pack` into:

```text
source/      original Lua source
wrapped/     full anti-tamper wrapper
csv/         decoded CSV settings
bytecode/    Lua 5.1 bytecode if present
manifest.json
```

Option 2 still needs `sandboxol` internally. Do not expose the sandboxol files in option 2 unless the caller also chose option 3.

### Pack layout

```text
u32 len1
byte[len1] header
u32 len2
byte[len2] encrypted TOC
u32 content_size
byte[content_size] content
```

Content base:

```text
content_base = 4 + len1 + 4 + len2 + 4
```

TOC entry:

```text
u16 name_len
name
u32 offset
u32 size
u32 size2
u8 flag
```

### Current TOC decryption

Key:

```text
blrsp20241212345
```

Use the modified AES bridge:

```python
toc_plain = decrypt(toc_cipher, b"blrsp20241212345", 0)[0]
```

Do not use standard AES for v10113.

### flag 0 — Lua entries

Three ciphertext bytes:

```text
selector, a, b
```

becomes two plaintext bytes:

```text
p0 = apply_list(a, lists[selector >> 4])
p1 = apply_list(b, lists[selector & 0x0f])
```

The record is selected by:

```python
md5(raw_ciphertext)
```

Instruction:

```text
(op << 8) | param
```

Ops:

```text
0 = subtract
1 = xor
2 = swap nibbles
```

Decryption applies the list in reverse storage order.

Re-encryption:

```text
0 = add
1 = xor
2 = swap nibbles
```

applied in forward order, preserving the selector byte.

A decryption is accepted only if:

```python
encrypt(decrypted) == raw_ciphertext
```

### Source wrapper

Most Lua plaintext is wrapped:

```text
--[[R1]]
... length check ...
--[[R2]]
original source
--[[R3]]---
```

Extract the original source between the `R2` marker and the final `--[[`.

Save both:

```text
source/      original source
wrapped/     full decrypted wrapper
```

### flag 1 — CSV

Use the substitution table:

```text
...\howto\data\sub_table.pkl
```

Orientation:

```text
plaintext byte -> ciphertext byte
```

Decrypt with the inverse map.

Verify by re-encoding:

```python
enc = bytes(table.get(b, b) for b in plaintext)
assert enc == ciphertext
```

### Bytecode

If the decrypted data starts with:

```text
1b 4c 75 61 53 00
```

save it as `.luac`.

Decompile with unluac if the bot is allowed to run Java:

```text
unluac.jar file.luac
```

### Option 2 result

Return a ZIP:

```text
<game>_v10113_res_pack.zip
  source/
  wrapped/
  csv/
  bytecode/          optional
  manifest.json
  README.txt
```

Do not include the original encrypted `res.pack` unless requested.

---

## 7. Option 3 — both

Run option 1 and option 2.

Return one bundle:

```text
<game>_v10113_unpack.zip
  sandboxol/
    sandboxol.raw
    frames/
    keyobjects.json
    patch_map.json
    summary.json
  res_pack/
    source/
    wrapped/
    csv/
    bytecode/
    manifest.json
  README.txt
```

Option 3 is the recommended default for debugging.

---

## 8. Response format for Discord

For `option 1`:

```text
Sandboxol decoded for g1042 v10113
frames: 2
KeyObjects: 616
patch pairs: 616
```

Attach `g1042_v10113_sandboxol.zip`.

For `option 2`:

```text
res.pack unpacked for g1042 v10113
Lua source: 508
CSV: 21
bytecode: 0
unresolved: 0
```

Attach `g1042_v10113_res_pack.zip`.

For `option 3`, attach the combined bundle.

Use ephemeral responses when available.

---

## 9. Required dependencies

For current v10113 packs:

- Python 3.10+
- `unicorn`
- `pyelftools`
- `capstone`
- `pycryptodome`
- the native `bg_libBlockMan_arm64.so`
- Java + unluac only for bytecode decompilation

The native library is required because v10113 uses a modified AES implementation, not stock AES.

If the bot runs on Linux, the native helper must be ported or run in a compatible environment.

---

## 10. Safety and reliability

- Do not execute extracted Lua.
- Do not follow symlinks in ZIPs.
- Reject path traversal.
- Limit output size.
- Limit CPU time for decryption.
- Clean temporary files after upload.
- Never log or expose `GITHUB_TOKEN`.
- Return clear errors for:
  - unknown game
  - unknown version
  - missing `plugin.zip`
  - missing `sandboxol`
  - TOC failure
  - missing KeyObject record
  - malformed payload length
- If a decrypt fails re-encryption, mark that entry unresolved instead of pretending it succeeded.

---

## 11. Existing code to reuse

```text
...\howto\scripts\download_game_resources.py
...\howto\scripts\bmg_extract.py
...\howto\scripts\decrypt_pack.py
...\howto\scripts\decrypt_all.py
...\howto\scripts\decrypt_g1100_latest.py
...\howto\scripts\emu_lib.py
...\howto\scripts\verify_pipeline.py
...\howto\data\sub_table.pkl
```

`bmg_extract.py` already performs the complete v10113 pipeline. A bot can:

1. download `plugin.zip`
2. call the extractor internals
3. split the output into option 1/2/3 bundles

---

## 12. Minimal flow

```text
/unpack g1042 2 10113
      |
      v
validate game/version/option
      |
      v
download games/g1042/v10113/plugin.zip from GitHub
      |
      v
extract res.pack and sandboxol
      |
      +-- option 1 -> parse sandboxol -> bundle
      |
      +-- option 2 -> parse sandboxol -> decrypt res.pack -> bundle
      |
      +-- option 3 -> both -> combined bundle
      |
      v
upload ZIP + summary
```
