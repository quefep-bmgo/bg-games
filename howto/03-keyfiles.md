# 03 — `sandboxol`, KeyObject records, and patch maps

The payload cipher needs per-entry lists. Those lists come from the game’s `sandboxol` keyfile.

There are three different keyfile/container generations in the recovered corpus.

## 1. Current numeric-frame keyfile

Current `sandboxol` files are a sequence of frames:

```text
u16 name_len
char[name_len] name
u16 key_len
char[key_len] key
u32 blob_len
byte[blob_len] encrypted_blob
```

The `name` and `key` are usually long numeric strings joined by dashes:

```text
6328-533252-954880-200964-...
```

The numeric key is converted to an array of integers:

```python
nums = [int(x) for x in key.split("-")]
```

The blob is decrypted with the modified AES routine:

```python
plain_keyfile = decrypt_large(blob, gen(nums), 0)
```

The first frame contains the KeyObject database.

## 2. Current KeyObject record formats

### Plugin / flat records

`g1042`, `g1048`, and `g1100` plugin keyfiles use flat records:

```text
u16 key_len = 32
char[32] key
u16 nlists
repeat nlists:
    u16 count
    u16[count] instructions
```

Each `key` is an ASCII MD5 hex string.

Each instruction is:

```text
(op << 8) | param
```

Record size is usually 116 bytes:

```text
2 + 32 + 2 + 8 * (2 + 4 * 2) = 116
```

### Engine / header records

Engine and some game keyfiles use a 123-byte header record:

```text
u16 key_len = 32
char[32] key
u16 h1
u8  h2
u32 w10
u16 nlists
repeat nlists:
    u16 count
    u16[count] instructions
```

`w10` is an engine-side parameter. In the plugin database it is always zero.

### Special trailing records

Some later keyfiles contain a normal flat block followed by a special block.

For `g1100` v10113:

```text
565 normal flat records
then a 12-byte prefix
then a 22-hex key: f16f1d21cc5f0a28b0b81c
then 8 lists
then 50 more 116-byte records
```

The 22-hex key is matched against the **suffix** of a raw ciphertext MD5:

```text
raw_md5 = e17ea7c9c3f16f1d21cc5f0a28b0b81c
special_key = f16f1d21cc5f0a28b0b81c
raw_md5.endswith(special_key) == True
```

This is why a normal `keys[raw_md5]` lookup alone misses one entry.

For `g1048` v10113 the same outer pattern expands to:

```text
565 normal records
1 special 22-hex record
1782 further 116-byte records
```

The reusable extractor parses both the normal and trailing blocks.

## 3. Patch/hotupdate map

The plugin `sandboxol` usually has a second frame containing pairs:

```text
u16 key_len = 32
char[32] source_md5
u16 value_len = 32
char[32] ciphertext_md5
```

This is the patch map.

It maps:

```text
MD5(original source) -> MD5(encrypted pack entry)
```

It is useful for:

- proving a decrypted source is the exact original
- recovering source files from older encrypted versions
- linking versions together

The extracted plugin frames are:

```text
...\g1042_analysis\plugin_frame0.bin
...\g1042_analysis\plugin_frame1.bin
```

## 4. Keyfile lookup rule

Do not look up by source MD5. The runtime does:

```python
record = keyobjects[hashlib.md5(ciphertext).hexdigest()]
```

The patch map and the KeyObject DB are different maps:

- KeyObject DB: ciphertext MD5 -> lists
- Patch map: source MD5 -> ciphertext MD5

## 5. Inline per-file generation

`v10105`–`v10108` often store each Lua file separately instead of using a `res.pack`:

```text
20 00
<32 ASCII source MD5>
<3-byte ciphertext>
```

The 32-byte field is the source MD5, not the key.

Recovery strategy:

1. Build an index of all known plaintext Lua files by MD5.
2. Read the inline MD5.
3. If the exact plaintext source exists in the corpus, recover it.
4. Otherwise the entry remains ciphertext.

This is why some old versions have `recovered_source\` next to `cipher\`.

## 6. Legacy keyfile

Legacy `v10109`–`v10112` keyfiles start with a different layout:

```text
08 00 1e 01 <UUID-like strings> ...
```

The strings are not normal UUIDs; each is a sequence of 32-bit hex words.

What is known:

- the legacy **TOC** is standard AES-128-ECB with key `blrsp20241212345`
- legacy entry plaintext uses the same 3-byte cipher
- one legacy entry was fully recovered from known plaintext and re-encrypted byte-exactly
- the first legacy keyfile blob is **AES-128-ECB** with key `blsle20240112345`
- the second blob (patch map) is **AES-128-ECB** with key `bmlle20240922345`
- both blobs use PKCS#7 padding
- the eight names and four key arrays in the outer header are opaque metadata; they are not the blob keys

Therefore:

- legacy TOCs are parsed
- legacy `flag=1` CSVs are decoded
- legacy `flag=0` Lua is fully decryptable with the KeyObject database
- the earlier "blocked on the blob key" conclusion is obsolete

The supplied `bg_libBlockMan_arm64.so` parser is the **current numeric-frame** parser; it is not the legacy 8+4 loader.

See:

```text
howto\13-legacy-sandboxol-decryption.md
howto\scripts\decrypt_legacy_sandboxol.py
```

## 7. Reference files

```text
...\g1042_analysis\keyobjects_plugin.json
...\g1042_analysis\keyobjects_engine_current.json
...\DECRYPTED\g1100_rooms\v10113\keyobjects.json
...\DECRYPTED\g1100_rooms\base\keyobjects_g1100.json
...\g1042_analysis\plugin_frame0.bin
...\g1042_analysis\plugin_frame1.bin
```
