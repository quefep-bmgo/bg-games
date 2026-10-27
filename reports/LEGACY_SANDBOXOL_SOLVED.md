# Legacy `sandboxol` reverse-engineering result (g1042 / g1100 v10109–v10112)

Work dir: `C:\Users\quefep\AppData\Local\Temp\opencode\v10112_re\native_trace`
No production files were modified.

## TL;DR

The legacy `sandboxol` blobs are **standard AES-128-ECB + PKCS#7**, not the custom AES
used by `bg_libBlockMan_arm64.so`, and the keys are the **same two fixed ASCII keys**
already known from the v10113 numeric-frame format:

| Record | AES key (ASCII) | AES key hex | Plaintext |
|---|---|---|---|
| 0 | `blsle20240112345` | `626c736c653230323430313132333435` | 501 × 116-byte KeyObject records |
| 1 | `bmlle20240922345` | `626d6c6c653230323430393232333435` | 501 × 68-byte patch-map records |

This was verified structurally and byte-exactly on **all eight** legacy packs:
g1042 v10109–v10112 and g1100 v10109–v10112. All blobs decrypt, parse to exactly the
end of the unpadded plaintext, all 501/483/497/499/426/466/467/469 KeyObject MD5s
match the corresponding `res.pack` ciphertext MD5s, all patch-map ciphertext MD5s
match the TOC, and re-encrypting a real `res.pack` entry with the recovered lists
reproduces the ciphertext byte-for-byte.

The 8 names + 4 keys in the legacy outer header are **not** used to derive the blob
key. They are 32-big-endian-u32 (128-byte) opaque values; their exact semantic role
is still unproven, but exhaustive evidence rules them out as the AES key material.

## 1. Exact legacy `sandboxol` container

```
repeat twice:
    u16 count = 8
      8 × (u16 len + bytes)        # "names": 32 hyphen-separated hex u32
    u16 count = 4
      4 × (u16 len + bytes)        # "keys":  32 hyphen-separated hex u32
    u32 blob_len
    byte[blob_len] blob             # AES-128-ECB(PKCS#7)
```

* The strings are **not UUIDs**. Split on `-`; each string is exactly **32 groups**
  of 1–8 hex digits, i.e. 32 big-endian u32 = 128 bytes.
* g1042 v10112: record 0 blob 58128 B, record 1 blob 34080 B, parse_end = 99113
  (the last 4 bytes of the file are an ignored trailer; v10109 parse_end = file size).
* Blob lengths are consistent with `116 × N + pad` and `68 × N + pad`:
  * g1042 v10109: 56032−4 = 116×483, 32848−4 = 68×483
  * g1042 v10110: 57664−12 = 116×497, 33808−12 = 68×497
  * g1042 v10111: 57888−4 = 116×499, 33936−4 = 68×499
  * g1042 v10112: 58128−12 = 116×501, 34080−12 = 68×501
  * g1100 v10109: 49424−8 = 116×426, 29040−4 = 68×427
  * g1100 v10110: 54064−8 = 116×466, 31760−4 = 68×467
  * g1100 v10111: 54176−4 = 116×467, 31840−16 = 68×468
  * g1100 v10112: 54416−12 = 116×469, 31968−8 = 68×470
  The record-1 count is sometimes one larger than record-0 (a trailing patch entry).

## 2. Record 0 plaintext (KeyObject database)

```
u16 key_len = 32
char[32] key                   # ASCII MD5 of the encrypted res.pack entry
u16 nlists = 8
repeat 8:
    u16 count = 4
    u16[count] instruction     # (op << 8) | param
```

* op 0 = subtract param, op 1 = XOR param, op 2 = nibble swap; instructions are
  applied in **reverse** storage order (same as the documented entry cipher).
* g1042 v10112: 501 records, 501/501 MD5s found in the TOC, all flag=0, parse_end
  58116 = 116×501.
* g1042 v10109: 483 records; v10110: 497; v10111: 499.
* g1100 v10109: 426; v10110: 466; v10111: 467; v10112: 469.

Example first record (g1042 v10112):

```
md5 = d41b80377ce74fd7761e8641b48d634f
lists = [[512,512,512,512],[455,401,199,512],[332,309,380,447],
         [336,147,437,141],[512,90,512,512],[512,176,396,386],
         [346,376,512,123],[512,113,512,183]]
```

## 3. Record 1 plaintext (patch map)

```
u16 src_len = 32
char[32] source_md5             # MD5 of the original source file
u16 cipher_len = 32
char[32] ciphertext_md5         # MD5 of the encrypted res.pack entry
```

* g1042 v10112: 501 records, parse_end 34068 = 68×501; all 501 ciphertext MD5s
  are in the TOC; source MD5s are the original source hashes (not ciphertext MD5s).
* Example first pair:
  `0885311e1e4c91098b75bac3dd78fb73 -> d41b80377ce74fd7761e8641b48d634f`
  which is `lua/engine_base/connector/IConnectorDispatch.lua`.

## 4. Full-chain validation (keyfile → entry plaintext → exact re-encryption)

`LEGACY_FULL_CHAIN_RESULT.json` / `legacy_full_chain.py`:

* Target: `lua/plugins/db_lock/db_lock.lua`, all 8 packs.
* Recovered lists from the decrypted KeyObject DB (record 0) are looked up by
  `MD5(raw entry)` and used with the 3-byte → 2-byte selector cipher.
* Results:
  * g1042 v10112: raw 3030 B → plain 2020 B; `reencrypt_match = true`;
    declared `local len = 2020`; source MD5 `63c3fa02b6f0d3f41cf09c23a28917a9`.
  * g1042 v10109/v10110: raw 3294 B → plain 2196 B; `reencrypt_match = true`;
    declared len 2196.
  * g1042 v10111: raw 3030 → 2020; `reencrypt_match = true`.
  * g1100 v10109: 3294 → 2196; v10110–v10112: 3030 → 2020; all exact.
* The exact 1139-byte source (`MD5 63c3fa...`) is found at plaintext offset:
  * 1013 in v10109/v10110 (44 trailing bytes)
  * 838 in v10111/v10112 (43 trailing bytes)
* `CHAIN_<game>_<ver>_source.lua` and `CHAIN_<game>_<ver>_wrapped.lua` are saved.

## 5. What the 8 names and 4 keys are (evidence)

Measured properties (`legacy_arrays.py`, `legacy_array_inventory.json`):

* Each is 128 bytes = 32 big-endian u32.
* The 8 names are **unique per (game/version, record, index)**: 96 unique arrays
  across the six sampled files. They are **not** MD5/SHA of plaintext records,
  ciphertext records, TOC entries, source MD5s, list regions, or whole blobs.
* The 4 keys are **constant across every legacy pack**: six unique arrays total.
  `key1` and `key3` are shared between record 0 and record 1; `key0` and `key2`
  differ between record 0 and record 1.
* They are not the blob AES key in any tested interpretation:
  raw/hex/ASCII windows, MD5/SHA1/SHA256, `gen` KDF outputs (decimal and hex),
  `T`/`T^-1`, XOR constants, standard AES-ECB/CBC, and both custom AES builds
  (bg `0x72bfe8` S-box and engine1 3.30.2 `0x7a34e8` S-box) all fail.
* They are not standard AES key schedules and are not AES-ECB ciphertexts under
  the blob keys.

Conclusion: for v10109–v10112 the blob key is **fixed** (`blsle...` / `bmlle...`),
not derived from these arrays. The arrays are opaque legacy header metadata
(size-compatible with 1024-bit values), likely license/anti-tamper or an obsolete
key-array block. Their exact semantic role is not proven; it is not needed to
decrypt the blobs.

## 6. Correction to the previous report: the supplied .so is the v10113 parser

`harness_read2keys.py` emulates `0x1a299f4` with a mocked stream and logs every read
and every `gen` token. Results (`read2keys_*.json`):

* v10113 (current numeric frame):
  * read u16 `0x00e4` = 228, name bytes
  * read u16 `0x0075` = 117, key bytes
  * first gen = `098276c840c765f44d7adb387959ace5` (32 ASCII chars = MD5(blob 0))
  * second gen = `626c736c653230323430313132333435` = `blsle20240112345` (16 bytes)
* v10112 (legacy 8+4):
  * first u16 `0x0008` is read as a **length 8**, then bytes `1d01393739613533`
  * first gen = 1 byte `d8` (the `stoull` of the non-numeric 8-byte string yields 0)
  * second u16 `0x6139` = 24889, so it reads the next 24889 bytes as a "key"
  * no MD5-length comparison can succeed (1-byte generated string vs 32-char MD5),
    and `0x1a29cc8` is never reached.

Therefore `0x1a28f2c → 0x1a299f4 → 0x1a2a050/0x1a2942c → 0x1a29cc8` implements the
**current numeric-frame** format, not the legacy 8+4 format. The legacy format was
handled by an older engine build whose loader is not in the supplied `.so`.
The legacy blobs use standard AES-128-ECB, which is why the custom-AES native path
in the old report failed.

## 7. Current v10113 format (verified reference)

Exact parser reconstruction:

* `0x1a299f4`: read `u16 len`, bytes, `gen()`; then read `u16 len`, bytes, `gen()`.
  `gen` = `0x1f36878` (split on `-`, decimal `stoull`, core `0x1f3655c` with fixed
  16-byte key at runtime VA `0x22ba7b0`: `391b2500000000000111160000000000`).
* `0x1a2a050`: read `u32 blob_len` + blob; compute MD5(blob) hex; compare to the
  **first** generated string; decrypt blob with the **second** generated string via
  `0x1a29cc8`; parse the decrypted KeyObject stream.
* `0x1a2942c`: same for the second frame (patch map).
* `0x1a29cc8`: `0x1f348d0(ctx, 0)` (AES-128 mode) then `0x1f35acc`; the custom
  AES S-box is build-specific (bg `.so` S-box at `0x72bfe8`), not standard AES.

Verified v10113 results (`CURRENT_v10113_RESULT.json`):

* record 0: name gen = `098276c840c765f44d7adb387959ace5` = MD5(blob);
  key gen = `blsle20240112345`; plaintext 58928 B = 116×508; 508 KeyObject records.
* record 1: name gen = `70341ae4d4ab7a44fd3f827a8163670f` = MD5(blob);
  key gen = `bmlle20240922345`; plaintext 34544 B = 68×508; 508 patch records.

## 8. Deliverable files (all under `v10112_re\native_trace\`)

Results / plaintexts:

```
LEGACY_v10112_RESULT.json          exact v10112 keys + structural validation
LEGACY_v10112_blob0_plain.bin      58116 B, KeyObject DB, SHA-256 8e2448b1...
LEGACY_v10112_blob1_plain.bin      34068 B, patch map,    SHA-256 4457d8c3...
LEGACY_ALL_VERSIONS_RESULT.json    all 8 legacy packs
LEGACY_FULL_CHAIN_RESULT.json      entry decrypt + exact re-encryption
CHAIN_g1042_v10112_source.lua      recovered 1139-B source (MD5 63c3fa...)
CHAIN_g1042_v10112_wrapped.lua     recovered 2020-B wrapper
CURRENT_v10113_RESULT.json         v10113 reference keys + plaintext hashes
CURRENT_v10113_blob0_plain.bin     58928 B
CURRENT_v10113_blob1_plain.bin     34544 B
legacy_array_inventory.json        the 6 unique key arrays / 96 name arrays
legacy_name_key_hash_matches.json  (empty: no hash correlation)
read2keys_v10112_legacy.json       mocked-stream trace (legacy misparse)
read2keys_v10113_current.json      mocked-stream trace (current success)
```

Scripts:

```
decrypt_legacy_final.py    standard AES-ECB decrypt + KeyObject/patch parse
decrypt_all_legacy.py      all 8 legacy packs
legacy_full_chain.py       keyfile lists -> res.pack entry -> exact re-encryption
save_current_result.py     v10113 reference decryption/parse
harness_read2keys.py       Unicorn mock-stream harness for 0x1a299f4
native_aes.py              native custom-AES oracle (0x1f348d0 + 0x1f35048)
native_aes_fast.py         reusable native oracle
gen_string2.py             gen emulator with decimal stoull hook
gen_core.py                fast core gen emulator
legacy_search1.py          exhaustive raw-window/hash screen (custom AES)
legacy_stdaes.py           exhaustive standard-AES screen
legacy_gen_kdf.py          gen-KDF screen (decimal/hex, subwindows, AES variants)
legacy_arrays.py           array inventory / cross-version comparison
legacy_meta_correlate.py   name/key vs plaintext hash correlation
```

## 9. Reproduction commands

```powershell
$py = "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe"
& $py "...\v10112_re\native_trace\decrypt_legacy_final.py"
& $py "...\v10112_re\native_trace\decrypt_all_legacy.py"
& $py "...\v10112_re\native_trace\legacy_full_chain.py"
& $py "...\v10112_re\native_trace\save_current_result.py"
& $py "...\v10112_re\native_trace\harness_read2keys.py"
```

## 10. Remaining unknowns

* Exact semantic role of the 8 names / 4 keys (not the blob key; likely license or
  obsolete key-array metadata). No hash/derivation correlation was found.
* The older engine build/loader that consumed the legacy 8+4 container. It is not
  the supplied `bg_libBlockMan_arm64.so`; that `.so` parses only the v10113
  numeric-frame format. Decryption no longer depends on that loader.
