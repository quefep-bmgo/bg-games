# 02 — The payload cipher

This is the cipher used for every `flag = 0` entry in current and legacy packs.

## 1. Input framing

Ciphertext is processed in groups of three bytes:

```text
selector, a, b
```

Plaintext is produced in groups of two bytes:

```text
p0, p1
```

Therefore:

```text
plaintext_length = ciphertext_length * 2 / 3
```

A valid payload has a ciphertext length divisible by three.

## 2. Selector

The selector byte has two 4-bit indices:

```text
high = selector >> 4
low  = selector & 0x0f
```

They select two entries from the KeyObject’s list bank:

```text
p0 = apply_list(a, lists[high])
p1 = apply_list(b, lists[low])
```

In valid packs the high and low nibbles are in `0..7`, and the bank has eight lists.

The selector byte itself is stored in the ciphertext. It is not encrypted.

## 3. List operations

Each list is four `u16` instructions.

```text
v = (op << 8) | param
```

Operations:

| `op` | Meaning |
|---:|---|
| `0` | subtract `param` modulo 256 |
| `1` | XOR `param` |
| `2` | swap the two nibbles of the byte |

Decryption applies the four instructions in **reverse storage order**:

```python
def swap_nibbles(x):
    return ((x << 4) | (x >> 4)) & 0xff

def apply_list(x, instructions):
    for v in reversed(instructions):
        op = v >> 8
        p = v & 0xff
        if op == 0:
            x = (x - p) & 0xff
        elif op == 1:
            x ^= p
        elif op == 2:
            x = swap_nibbles(x)
        else:
            raise ValueError(hex(v))
    return x
```

Not every list uses four non-zero instructions; many entries use `(0, 0)` as a no-op pair, which is still a subtract-zero.

## 4. Decrypt function

```python
def decrypt_payload(raw, record):
    if len(raw) % 3:
        raise ValueError("payload length is not a multiple of 3")

    out = bytearray()

    for i in range(0, len(raw), 3):
        selector = raw[i]
        a = raw[i + 1]
        b = raw[i + 2]

        out.append(apply_list(a, record["lists"][selector >> 4]))
        out.append(apply_list(b, record["lists"][selector & 0x0f]))

    return bytes(out)
```

## 5. Encryption inverse

Encryption keeps the original selector and inverts each list operation.

```python
def invert_list(x, instructions):
    for v in instructions:
        op = v >> 8
        p = v & 0xff
        if op == 0:
            x = (x + p) & 0xff
        elif op == 1:
            x ^= p
        elif op == 2:
            x = swap_nibbles(x)
        else:
            raise ValueError(hex(v))
    return x


def encrypt_payload(plain, raw, record):
    out = bytearray()

    for i in range(0, len(raw), 3):
        selector = raw[i]
        a = invert_list(plain[i // 3 * 2], record["lists"][selector >> 4])
        b = invert_list(plain[i // 3 * 2 + 1], record["lists"][selector & 0x0f])
        out += bytes((selector, a, b))

    return bytes(out)
```

This inverse is the definitive test:

```python
encrypt_payload(decrypted, original_ciphertext, record) == original_ciphertext
```

## 6. Key record selection

The KeyObject record is selected by the **MD5 of the raw ciphertext**, not by the file name and not by the source MD5.

```python
import hashlib

raw_md5 = hashlib.md5(raw).hexdigest()
record = keyobjects[raw_md5]
```

That is why:

- the KeyObject database key is the ciphertext MD5
- the patch/hotupdate map can have a different source MD5 -> ciphertext MD5 pair
- changing even one ciphertext byte selects a different or missing record

One g1100 entry uses a 22-hex suffix key instead of a full 32-hex key. The extractor supports that special case by checking whether the raw MD5 ends with the special key.

## 7. What the plaintext can be

For `flag = 0` the decrypted bytes are one of:

### Lua source wrapper

Most plugin entries use an anti-tamper wrapper:

```text
--[[R1]]
... length-check Lua ...
local len = <N>
local checkFileName = "<basename>"
...
table.insert(F_L_Check_C_NEW[checkFileName], len)
--[[R2]]
<original source file>
--[[R3]]---
```

The original source is between the `--[[R2]]` marker and the final `--[[R3]]` marker.

### Lua 5.1 bytecode

Engine and several game packs store compiled Lua 5.1 bytecode:

```text
1b 4c 75 61 53 00
```

That is `\x1bLuaS\x00`.

### Raw source

Some early/plaintext packages store source directly.

## 8. Verified example

Known pair from g1042 plugin v10113:

```text
entry: lua/engine_base/Lua51Compat.lua
source size: 1230 bytes
source MD5: 9e7d517029c9ac37939019da2abe403d
ciphertext size: 3147 bytes
```

The wrapper explains the size difference: the ciphertext is 1.5x the wrapped plaintext, and the wrapper adds hundreds of bytes around the original source.

The source tree in `DECRYPTED` contains the extracted 1230-byte source, not the wrapper.

## 9. References

```text
...\howto\scripts\decrypt_pack.py
...\howto\scripts\decrypt_all.py
...\howto\scripts\decrypt_g1100_latest.py
...\howto\scripts\bmg_extract.py
```
