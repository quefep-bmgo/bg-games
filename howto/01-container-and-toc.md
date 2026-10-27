# 01 — Container layout and TOC decryption

## 1. Container layout

Every `res.pack` is a simple indexed container:

```text
offset 0        u32   len1                 usually 16
offset 4        byte[len1]                 support/header blob
offset 4+len1   u32   len2                 encrypted TOC length
offset ...      byte[len2]                 encrypted TOC
offset ...      u32   content_size
offset ...      byte[content_size]         entry payloads
```

The content base is:

```text
content_base = 4 + len1 + 4 + len2 + 4
```

`len2` is the **encrypted** TOC length, not the unpadded plaintext length. Use `len2` when calculating `content_base`; use the padded plaintext only for parsing.

Reference:

```text
C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\decrypt_pack.py
```

## 2. TOC entry format

After decrypting the TOC:

```text
u16 name_len
byte[name_len] name
u32 offset
u32 size
u32 size2
u8  flag
```

`offset` is relative to `content_base`.

- `flag = 0`: encrypted Lua payload
- `flag = 1`: substitution-encoded CSV/other text

The parser stops when `name_len == 0`, `name_len > 511`, or the record would overflow.

Reference:

```text
C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\decrypt_pack.py
function load_toc()
```

## 3. Two TOC formats

### Current packs

Current packs use the game’s modified AES-128 implementation, not OpenSSL AES.

Examples:

```text
g1042 v10113  header 00 03 c1 e9 2c 11 5e d7 e4 8d 4e e1 d4 0d 92 42
g1100 v10113  header 00 03 c1 e9 2c 11 5e d7 e4 8d 4e e1 d4 0d 92 42
g1048 v10113  header 00 03 c1 e9 2c 11 5e d7 e4 8d 4e e1 d4 0d 92 42
```

Key:

```text
blrsp20241212345
```

The easiest reliable implementation is the Unicorn-based one in:

```text
...\howto\scripts\emu_lib.py
```

It calls the native routines:

```text
0x1f348d0   cipher context init
0x1f35acc   decrypt
```

Example:

```python
from emu_lib import decrypt
toc_plain = decrypt(toc_cipher, b"blrsp20241212345", 0)[0]
```

`emu_lib.decrypt` uses the modified AES tables and returns the unpadded plaintext.

The native library is:

```text
C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\native\bg_libBlockMan_arm64.so
```

### Legacy packs

Legacy packs use ordinary AES-128-ECB with PKCS#7 padding and the same 16-byte literal key.

Legacy header:

```text
c9 2e a8 41 b5 87 ea c4 a1 75 1b f5 19 87 36 82
```

Example with `pycryptodome`:

```python
from Crypto.Cipher import AES

def unpad(b):
    n = b[-1]
    assert 1 <= n <= 16 and b[-n:] == bytes([n]) * n
    return b[:-n]

toc_plain = unpad(
    AES.new(b"blrsp20241212345", AES.MODE_ECB).decrypt(toc_cipher)
)
```

Legacy TOC lengths are multiples of 16 and include PKCS#7 padding.

Do not use the current emulation path for legacy TOCs; use standard AES-ECB.

Reference:

```text
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
```

## 4. Detecting the format

Read 16 bytes at offset `4 + len1`:

```python
hdr = d[4 + l1:4 + l1 + 16]

if hdr == bytes.fromhex("0003c1e92c115ed7e48d4ee1d40d9242"):
    current = True
elif hdr == bytes.fromhex("c92ea841b587eac4a1751bf519873682"):
    legacy = True
```

## 5. Why the TOC matters

The TOC gives you:

- every exact entry name and path
- ciphertext size
- flag (`Lua` vs `CSV`)
- the content offset
- the ordering used by the runtime

Once the TOC is parsed, the rest of the pack can be processed entry by entry.

## 6. Reference values

| Pack | TOC cipher bytes | TOC plain bytes | Entries |
|---|---:|---:|---:|
| g1042 plugin v10113 | 32,464 | 32,454 | 529 |
| engine | 29,584 | 29,574 | 343 |
| map | 1,424 | 1,411 | 37 |
| g1100 base | 17,264 | 17,250 | 202 |
| g1100 v10113 | 39,552 | 39,540 | 631 |
| g1042 v10109 legacy | 30,880 | 30,874 | 504 |
