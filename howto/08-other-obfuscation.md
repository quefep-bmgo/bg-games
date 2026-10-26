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

## 4. g1019 v10104 obfuscated source

Status: solved for g1019.

All `.lua` entries use a static byte substitution with a `777...` prefix. The S-box was recovered from 407 same-length v10103/v10104 pairs; 421/421 entries re-encode exactly and 407 decode identically to v10103.

The g1042 v10104 wrapper is still not reduced to source; that is a different build, not the same solved transform.

## 5. g1042 v10105 encrypted source

Status: unresolved.

All 478 `.lua` entries are high-entropy encrypted containers.

Preserved under:

```text
...\DECRYPTED\g1042_build_and_shoot\v10105\cipher
```

No matching keyfile source was recovered for this format.

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
- g1042 v10104 wrapper
- g1042 v10105 encryption
- g1019 v10105: 6 unique files whose per-file codebook is not present
- `lang.csv` Unicode bytes absent from the substitution table

The legacy `sandboxol` blobs are no longer on this list.

Everything else in the current packs is represented as source, bytecode, CSV, or explicit ciphertext.
