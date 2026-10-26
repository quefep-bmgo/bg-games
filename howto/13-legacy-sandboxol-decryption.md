# 13 — Legacy `sandboxol` decryption (corrected)

This document replaces the earlier “legacy blob is blocked” conclusion.

It covers the old keyfile generation used by g1042, g1100, and g1019 in versions **v10109–v10112**, plus the per-file formats immediately before it.

## 1. Result

Legacy `sandboxol` blobs are **ordinary AES-128-ECB with PKCS#7 padding**.

| Blob | Purpose | Key |
|---|---|---|
| first blob | KeyObject database | `blsle20240112345` |
| second blob | source-MD5 / ciphertext-MD5 patch map | `bmlle20240922345` |

The keys are ASCII, 16 bytes each:

```text
blsle20240112345
bmlle20240922345
```

They are **not** derived from the eight names or four key arrays in the outer header. Those arrays are 32-word/128-byte opaque metadata. They vary by version, but decrypting the blobs does not require them.

This discovery was validated on every available legacy pack for g1042 and g1100 (v10109–v10112), and on g1019 v10109–v10112.

## 2. Legacy `sandboxol` layout

```text
repeat twice:
    u16 count = 8
      8 × (u16 length + bytes)
    u16 count = 4
      4 × (u16 length + bytes)
    u32 blob_len
    byte[blob_len] blob
```

The blob is decrypted directly:

```python
from Crypto.Cipher import AES

def unpad(b):
    n = b[-1]
    if not 1 <= n <= 16 or b[-n:] != bytes([n]) * n:
        raise ValueError("bad PKCS#7 padding")
    return b[:-n]

keyobjects = unpad(AES.new(b"blsle20240112345", AES.MODE_ECB).decrypt(blob0))
patchmap  = unpad(AES.new(b"bmlle20240922345", AES.MODE_ECB).decrypt(blob1))
```

The first blob contains the KeyObject records. The second blob contains source-MD5 → ciphertext-MD5 pairs.

## 3. Why the old native trace failed

The supplied `bg_libBlockMan_arm64.so` parser at `0x1a28f2c` is the **current numeric-frame** parser, not the legacy 8+4 parser.

The legacy format was handled by an older engine build. Using the current `.so` on a v10112 `sandboxol` makes it read the first `u16=8` as a length, then read a non-numeric “key” and fail before any decrypt call.

That is why the earlier report only got as far as “blob is AES-like, key unknown.” The correct implementation is standard AES-ECB, not the custom native AES path used for v10113.

## 4. KeyObject database

```text
u16 key_len = 32
char[32] key                  # ASCII MD5 of the encrypted res.pack entry
u16 nlists = 8
repeat 8:
    u16 count = 4
    u16[count] instructions   # (op << 8) | param
```

Opcodes:

- `0` = subtract param
- `1` = XOR param
- `2` = nibble swap

Apply in **reverse** storage order.

Lookup rule:

```python
record = keyobjects[hashlib.md5(ciphertext).hexdigest()]
```

Do not look up by source MD5. The patch map is separate.

## 5. Patch map

```text
u16 source_len = 32
char[32] source_md5
u16 cipher_len = 32
char[32] ciphertext_md5
```

This maps:

```text
MD5(original source) -> MD5(encrypted entry)
```

It is an independent validation source, not the keyfile for entry decryption. It can also recover a source when the same original source exists in another version.

## 6. Validation

For g1042 v10112:

- 501 Lua entries
- 501/501 KeyObject MD5s match the TOC
- 501/501 entries decrypt and re-encrypt byte-for-byte
- 500/501 sources match the patch map
- one stale patch entry: `plugins/new_vip/new_vip.lua`

For g1019 v10112:

- 452 Lua entries
- 452/452 entries re-encrypt exactly
- patch map validates all but the same stale `new_vip.lua` record

For g1042 v10109–v10111 and g1100 v10109–v10112, all available keyfiles and entries validate structurally; the historical report’s single-entry proof also re-encrypts exactly.

## 7. Per-file generations

### g1019 v10104 — `777` substitution

The v10104 g1019 Lua entries are a static byte substitution.

The substitution table was recovered from 407 same-length v10103/v10104 pairs:

- 407/407 pairs decode identically
- 421/421 entries re-encode exactly
- 172 byte values observed, no conflicts

The transform is a static S-box, not compression and not a stream cipher.

### v10105 — per-file codebook

The v10105 per-file format uses a **2-byte → 3-byte codebook**, different for every file.

For g1019:

- 417/423 sources recovered by exact known-plaintext matching
- 6 unique sources remain unresolved
- no global S-box explains the codebooks

This is the only remaining unresolved format in the g1019 corpus.

### v10106–v10108 — inline source MD5

```text
20 00
32 ASCII source MD5
3-byte selector ciphertext
```

The 32-character field is the original source MD5, not the key. The key records are in the legacy `sandboxol` first blob (`blsle20240112345`).

For g1019:

- v10106: 423/423 re-encrypt exactly, 422 source-MD5 matches
- v10107: 434/434 re-encrypt exactly, 433 source-MD5 matches
- v10108: 434/434 re-encrypt exactly, 433 source-MD5 matches

The one mismatch in each is the stale `new_vip.lua` publisher hash; the decrypted content is valid.

## 8. Reference script

`howto/scripts/decrypt_legacy_sandboxol.py` decrypts a legacy plugin or a legacy `sandboxol` file and writes the KeyObject and patch-map tables.

Example:

```powershell
python howto\scripts\decrypt_legacy_sandboxol.py `
  "games\g1019\v10112\plugin.zip" `
  --out "work\g1019_v10112_legacy"
```

The script writes:

```text
keyobjects.csv
patch_map.csv
blob0.bin
blob1.bin
report.json
```

## 9. Remaining limits

- g1042 v10104 (`777` wrapper) is still not reduced to source in this repository.
- g1042 v10105 remains unresolved.
- g1019 v10105 has 6 unique unresolved files.
- The legacy outer 8 names / 4 key arrays are opaque metadata; their exact purpose is still unproven.
- The v10105 per-file codebook is per-file and is not stored in the capture.

Everything else described above is byte-validated.
