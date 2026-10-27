# 08 — Other obfuscation and partial formats

This file records every non-standard format encountered, so nothing is mistaken for plain source.

## 1. Plugin source wrapper

Status: fully removed.

Format:

```text
--[[R1]]
... File_Len_Check code ...
--[[R2]]
original source
--[[R3]]---
```

The extracted original is in `source\`; the full wrapper is in `wrapped\`.

## 2. Lua 5.1 bytecode

Status: extracted and decompiled.

Header:

```text
1b 4c 75 61 53 00
```

Saved as `.luac`, then decompiled with unluac.

## 3. CSV byte substitution

Status: decoded with `data/sub_table.pkl`.

```text
plain -> cipher table
inverse used for decryption
```

Known limitation: g1100 `lang.csv` has Unicode bytes not covered by the known table.

## 4. g1042 v10104 obfuscated source

Status: SOLVED (static byte substitution).

All 470 `.lua` entries are a length-preserving single-byte substitution with a
global S-box (the leading `777...` is just the encoded `---\n` header).  The
172 observed cipher→plain pairs decode 317/318 checksum-verified engine files
in both g1019 and g1042; the single mismatch is a stale `sandboxol` checksum
(`new_vip.lua`, whose listed MD5 is the v10103 copy).

Full method, table and decoder:

```text
howto/16-v10104-v10105-formats.md
howto/data/v10104_sbox.json
howto/scripts/v10104_harvest.py
```

Decoded sources: `recover/out/<game>/v10104/source/`.

## 5. g1019/g1042/g1048 v10105 encrypted source

Status: format solved; 1289/1300 entries recovered (99.1%).

Each Lua entry is `[raw per-file header][2 plaintext bytes -> 3 ciphertext
bytes]`; every plaintext byte has an 11-bit per-file code:

```text
p0 = D0[(b0, b1 >> 4)]     p1 = D1[(b2, b1 & 7)]
```

The plaintext is `source + "--[[<random>--]]"`, the header is a 13..54 byte
salt ending in `0x00`, and the tables `D0`/`D1` are content-derived.  Recovery
uses known plaintext, a zero-conflict pair-map oracle, the 16..61 byte pad
length rule, `lua/sandboxol` source MD5s, an edit-subset search between
adjacent versions, and an iterative crib decoder.  The per-file KDF from the
header to `D0`/`D1` is the only unknown.

Full method and tools:

```text
howto/16-v10104-v10105-formats.md
howto/scripts/v10105_crib.py
howto/scripts/v10105_fullvote.py
howto/scripts/v10105_editsearch.py
howto/scripts/v10105_recover_cross.py
howto/scripts/v10105_pass2.py
howto/scripts/v10105_audit.py
```

Recovered sources: `recover/out/<game>/v10105/source/` (+ `MANIFEST.json`).

## 6. Inline-MD5 per-file format

Status: partially recovered.

Format:

```text
20 00
32 ASCII source MD5
3-byte ciphertext
```

The 32-byte field is the original source MD5. If that exact source exists in the plaintext corpus, it is copied to `recovered_source\`. Otherwise the entry stays in `cipher\` with the inline MD5 recorded.

Applies to:

```text
g1042 v10106-v10108
g1048 v10106-v10108
g1100 v10108
```

Recovery counts are in each `MANIFEST.json`.

## 7. Legacy v10109-v10112 packs

Status: fully solved for the tested packs.

- legacy TOC: AES-128-ECB/PKCS#7 with `blrsp20241212345`
- KeyObject blob: AES-128-ECB/PKCS#7 with `blsle20240112345`
- patch map: AES-128-ECB/PKCS#7 with `bmlle20240922345`
- 501/501 g1042 v10112 entries and 452/452 g1019 v10112 entries re-encrypt exactly
- 500/501 and 451/452 source hashes match the patch map; the one miss is the stale `new_vip.lua` publisher hash

See `13-legacy-sandboxol-decryption.md`.

## 8. Map terrain

`r.*.mca` files are region/terrain data, not encrypted Lua. They were inventoried but not converted to another format.

Map configs are extracted into `map_config\`.

## 9. What was not deobfuscated

- live server/backend logic
- anti-cheat native routines beyond the AES path
- v10105 per-file KDF from the raw header to the code tables (format itself is solved; see ?5)
- 11 unique-content v10105 entries whose exact source is absent from the known corpus
- `lang.csv` Unicode bytes absent from the substitution table

The legacy `sandboxol` blobs are no longer on this list.
Everything else in the current packs is represented as source, bytecode, CSV, or explicit ciphertext.
