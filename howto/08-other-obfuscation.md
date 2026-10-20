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

Status: not fully deobfuscated.

All 470 `.lua` entries start with an obfuscated wrapper (`777...`) instead of normal Lua.

They are preserved under:

```text
...\DECRYPTED\g1042_build_and_shoot\v10104\cipher
```

The `v10103` and `v10113` sources are available for comparison, but the v10104 wrapper itself was not reduced to source.

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

Status: TOC and CSV solved; Lua blocked.

What works:

- legacy TOC via AES-128-ECB/PKCS#7 with `blrsp20241212345`
- all `flag=1` CSVs
- known-plaintext proof for one Lua entry, re-encrypted byte-exactly

What remains blocked:

- blind decryption of legacy Lua entries, because the legacy `sandboxol` blob key/KDF was not recovered

The Lua ciphertext is preserved in `cipher\`; the entry names/sizes/hashes are in `MANIFEST.json`.

## 8. Map terrain

`r.*.mca` files are region/terrain data, not encrypted Lua. They were inventoried but not converted to another format.

Map configs are extracted into `map_config\`.

## 9. What was not deobfuscated

- live server/backend logic
- anti-cheat native routines beyond the AES path
- legacy `sandboxol` blob encryption
- g1042 v10104 wrapper
- g1042 v10105 encryption
- `lang.csv` Unicode bytes absent from the substitution table

Everything else in the current packs is represented as source, bytecode, CSV, or explicit ciphertext.
