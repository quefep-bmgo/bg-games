# g1019 (Aliens Attack) v10068-v10113 extraction report

## Scope and result

Working tree: `C:\Users\quefep\Desktop\Decomp Temp\aliens_attack`
Output tree: `decrypted\all_versions\<version>\`
Global manifest: `ALL_VERSIONS_MANIFEST.json` (also copied to
`decrypted\all_versions\ALL_VERSIONS_MANIFEST.json`)
Coverage: `COVERAGE.md`
Independent verification: `reports\agents\extraction\verification.json`

Status:

- 41 source versions were present and extracted; 5 version slots in the
  requested range are absent from the capture (`v10078`, `v10081`, `v10089`,
  `v10092`, `v10094`) and are recorded as `source_missing`, not failures.
- 13,759 source files, 13,342 wrapped files, 15 plugin CSV files, 456 map CSV
  files, 285 map config files, 934 map assets, 2,003 staging source files,
  459 staging wrapped files and 3 staging CSV files were written (32,971
  output files, 1,117,633,536 bytes).
- 6 plugin entries remain unresolved, all unique-source entries in v10105.
  Their ciphertext is preserved under `v10105\cipher\` with expected source
  MD5s where the v10105 checksum list provides one.
- The independent verifier re-read every source pack and re-decrypted every
  plugin entry (including v10113 staging) and every map `res.pack` CSV. Result:
  `ok: true`, `error_count: 0`. It also re-hashed all 32,971 output files and
  recomputed every per-version tree SHA-256.

## Methods and validation by era

### v10068-v10103 — plaintext

Lua entries in `plugin.zip` are plaintext UTF-8 Lua; source and wrapped are the
same bytes. Every entry was copied, hashed and re-read from the zip by the
verifier (116-424 entries/version). Maps are direct CSV/YML/MCA zips.

### v10104 — static byte substitution

`plugin.zip` Lua entries are prefixed `777...`. The transform is a static
byte-for-byte substitution. The S-box was derived from the 407 same-length
v10103/v10104 pairs (`tools/v10104_sbox.json`), with 172 observed byte values
and zero conflicts. Validation:

- 407/407 same-length pairs decode byte-identically to v10103.
- 421/421 entries re-encode byte-exactly with the inverse table.
- 407 entries are identical to v10103; 7 are identical to v10106; 7 are unique
  to v10104.
- The v10104 `lua/sandboxol` checksum list has 318 entries; 317 match the
  decoded source MD5 exactly. The one mismatch is `new_vip.lua` (stale
  publisher hash; see Warnings).
- The 7 v10104-unique entries (including `new_vip.lua`) have no independent
  plaintext to compare against. They are validated structurally by the global
  S-box re-encode: the transform is proven on 407 byte-identical pairs and
  re-encodes all 421 entries exactly.

### v10105 — per-file 2-byte -> 3-byte codebook (partial)

The 423 Lua entries use a per-file 2-byte -> 3-byte codebook. The codebook is
content-independent per file but differs file-to-file and is not the v10106
selector cipher. 417/423 entries were recovered by exact known-plaintext
matching:

- Candidate sources from every decoded version (v10068-v10113) were tested at
  every plausible ciphertext offset. A hit requires a unique offset with zero
  pair conflicts over all complete source pairs and exact re-encoding of the
  source span.
- 412 entries matched the v10106 source and 5 matched the v10104 source.
- The v10105 `lua/sandboxol` checksum list has 318 entries. 313 recovered
  sources match the expected MD5, 1 is the stale `new_vip` value, and 4 are
  the unresolved unique files below. This independently validates 313/314
  available source hashes.
- No plaintext source was written for the 6 unresolved entries; their raw
  ciphertext is preserved.

### v10106-v10108 — `20 00` + source MD5 + selector cipher

Entry format: `20 00` + 32 ASCII source MD5 + 3-byte -> 2-byte selector
ciphertext. Key records are in `sandboxol`: the first packet is a legacy
`[8 names][4 keys][u32 blob]` layout; the blob is AES-128-ECB with
`blsle20240112345` and parses as 423/434/434 KeyObject records.

Validation:

| version | entries | source MD5 ok | re-encrypt ok | patch MD5 list |
|---|---:|---:|---:|---:|
| v10106 | 423 | 422 | 423/423 | n/a (single packet) |
| v10107 | 434 | 433 | 434/434 | 433/868 |
| v10108 | 434 | 433 | 434/434 | 433/868 |

The one header/patch mismatch in each version is `new_vip.lua` (stale hash;
content is valid and equals the v10105 source).

### v10109-v10112 — legacy `res.pack` + selector cipher

TOC is AES-128-ECB with `blrsp20241212345`. Key records are in `sandboxol`
(same first-packet blob). Entries are selected by `md5(raw entry)`.

Validation:

| version | Lua entries | re-encrypt ok | CSV entries | patch MD5 list |
|---|---:|---:|---:|---:|
| v10109 | 434 | 434/434 | 3 | 433/868 |
| v10110 | 448 | 448/448 | 3 | 447/896 |
| v10111 | 450 | 450/450 | 3 | 449/900 |
| v10112 | 452 | 452/452 | 3 | 451/904 |

The patch-list misses are `new_vip.lua` only (the same stale-hash anomaly as
v10104-v10108). The second `sandboxol` packet (AES `bmlle20240922345`) is an
868-904 entry patch source-MD5 list and was used as an independent source hash
check.

### v10113 — current `res.pack` + numeric-frame `sandboxol`

TOC uses the native/emulated current decrypt. `sandboxol` has two numeric
frames; the first decrypts to 459 KeyObject records and covers all 459 Lua
entries. The second frame is not a KeyObject list (36-byte prefix, non-list
layout) and is not needed.

Validation:

- 459/459 Lua entries re-encrypt byte-exactly.
- 459/459 extracted sources are byte-identical to the pre-existing independent
  `decrypted\v10113\source` tree.
- `plugin-staging.zip` has its own 459-record keyfile; 459/459 staging sources
  were decoded, re-encrypted exactly, and match the independent
  `reports\agents\features\_work\plugin_staging_decrypted\v10113\source` tree.
- 3 plugin CSV entries per pack were decoded with the CSV substitution table.

### Maps

Direct map entries are copied to `map_assets`; CSV to `map_csv`; YML/JSON/
checksum text to `map_config`. `res.pack` entries with flag 1 are decoded with
the CSV substitution table.

- v10068-v10108 maps contain direct CSV/YML/MCA.
- v10109-v10112 `m1019_1` has a legacy `res.pack` with 8 CSV entries, all
  decoded. v10110+ also contain direct `m1019_10` CSV maps.
- v10113 `m1019_1` has a current `res.pack` with 8 CSV entries, all decoded;
  `m1019_10` and staging `m1019_2` contain direct CSV.
- 456 map CSV, 285 map config and 934 map asset files were produced; no map
  entries are unresolved. The verifier re-decoded every `res.pack` CSV and
  matched the output byte-for-byte.

## Unresolved format and exact blockers

Only one format remains incomplete: the **v10105 per-file 2-byte -> 3-byte
codebook**. Six v10105 Lua sources are unique and have no exact plaintext in
any available version or work tree:

| entry | expected source MD5 | ciphertext |
|---|---|---|
| `lua/engine_base/annotation.lua` | `b0668ee73c2e230faeb5a82967170648` | `v10105\cipher\lua\engine_base\annotation.lua` |
| `lua/engine_base/util/StringUtil.lua` | `82c64c20b64d88a7241e5665f8dc3735` | `v10105\cipher\lua\engine_base\util\StringUtil.lua` |
| `lua/engine_client/packet/PidPacketHandler.lua` | `f881193de06d2823702e899e0e4489d9` | `v10105\cipher\lua\engine_client\packet\PidPacketHandler.lua` |
| `lua/engine_client/util/DressUtil.lua` | `cad31877ba8e56d4235537d26413a533` | `v10105\cipher\lua\engine_client\util\DressUtil.lua` |
| `lua/engine_server/antihack/ClientFileChecker.lua` | not listed | `v10105\cipher\lua\engine_server\antihack\ClientFileChecker.lua` |
| `lua/engine_server/packet/PidPacketHandler.lua` | not listed | `v10105\cipher\lua\engine_server\packet\PidPacketHandler.lua` |

Attempted methods, all without a valid match:

1. Exact 2->3 known-plaintext matching against every v10068-v10113 source of
   the same name, with a zero-conflict pair map and exact re-encoding of the
   source span.
2. Cross-check against all v10106-v10112 KeyObject records (legacy `sandboxol`
   first packet, AES `blsle20240112345`) and all engine/plugin
   `keyobjects_*.json` records (2,493 records): no record/offset decodes the
   six bodies to the expected content.
3. v10107-v10112 second-packet patch MD5 list and v10104/v10105 checksum
   lists: the expected hashes are recorded but provide no plaintext.
4. Tested whether the per-file tables are a global S-box under bit rotation,
   index XOR/add, output XOR/add, affine or GF(2)-linear transforms; none fit
   all known files. The v10105 tables are independent per file, so the six
   cannot be inferred from the 417 known files.
5. Scanned all 34,294 `.lua` files under `reports\` and `server_src\` for the
   four known expected MD5s; no file has any of those hashes. Checked the
   v10114 extracted tree; its versions of these files differ.
6. Parsed all `sandboxol` packets and the decoded v10105 checksum list; the
   v10105 build has no binary KeyObject blob/keyfile in the plugin, and the
   checksum list contains only hashes.

Blocker: the per-file codebook/key schedule for v10105 is not stored in the
capture (no binary `sandboxol`, no keyfile, no MD5-selected record table), and
the six files changed in v10105 only, so there is no adjacent plaintext or
reference source to validate a reconstruction. A source-MD5 preimage search
is infeasible, so these are left as unresolved ciphertext rather than guessed.

## Warnings / known anomalies

- `lua/plugins/new_vip/new_vip.lua` has a stale publisher hash in v10104-v10108:
  - v10104 checksum expects `c1ac62915269c05664a3706d905db525`; decoded source
    MD5 is `1bde35d8a820b44160ba72959a50b387`.
  - v10105 checksum and v10106-v10108 headers expect
    `3e4ada73beadc3941a1c484f54769e5f`; decoded source MD5 is
    `de9db99d524cdfa6dc0df4db2933323f`.
  - The decoded content is valid Lua, re-encrypts byte-exactly, and is
    byte-identical to the v10105 source across v10105-v10108. It is retained;
    the mismatch is recorded as a warning, not treated as an unresolved decode.
- v10113's second numeric `sandboxol` frame does not parse as a KeyObject
  record list (36-byte prefix with a different layout). The first frame has all
  459 records required by the pack; staging has its own 459-record keyfile.
- The five missing version directories are genuinely absent from the capture,
  not extraction failures.

## Reproduce

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\aliens_attack\tools\extract_all.py"

& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\aliens_attack\tools\verify_outputs.py"

& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\aliens_attack\tools\make_coverage.py"
```

Logs: `reports\agents\extraction\run.log`,
`run_console.log`, `verify_console.log`,
`verification.json`, `validation.json`.
The shared tools under `DECRYPTED\tools` and `g1042_analysis` were read only;
no GitHub repository or production document was modified.
