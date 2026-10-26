# Unresolved formats / entries

## Only unresolved format: v10105 per-file 2-byte -> 3-byte codebook

All other requested formats are decoded and validated:

- v10068-v10103 plaintext Lua: extracted.
- v10104 `777...` byte substitution: S-box recovered; 421/421 entries
  re-encode byte-exactly.
- v10106-v10108 `20 00` + source MD5 + selector cipher: 423/423, 434/434,
  434/434 re-encode; source MD5 headers validate all but the known stale
  `new_vip.lua` hash.
- v10109-v10112 legacy `res.pack`: 434/448/450/452 entries re-encode;
  patch source-MD5 lists validate all but the same `new_vip.lua` stale hash.
- v10113 current `res.pack`: 459/459 re-encode; 459/459 main sources and
  459/459 staging sources match independent reference trees.
- Maps: direct assets plus all legacy/current `res.pack` CSV entries decoded;
  verifier re-decoded every CSV.
- v10078/v10081/v10089/v10092/v10094 are absent from the local capture
  (`source_missing`), not extraction failures.

## The six unresolved v10105 entries

| entry | expected source MD5 | ciphertext |
|---|---|---|
| `lua/engine_base/annotation.lua` | `b0668ee73c2e230faeb5a82967170648` | `decrypted\all_versions\v10105\cipher\lua\engine_base\annotation.lua` |
| `lua/engine_base/util/StringUtil.lua` | `82c64c20b64d88a7241e5665f8dc3735` | `decrypted\all_versions\v10105\cipher\lua\engine_base\util\StringUtil.lua` |
| `lua/engine_client/packet/PidPacketHandler.lua` | `f881193de06d2823702e899e0e4489d9` | `decrypted\all_versions\v10105\cipher\lua\engine_client\packet\PidPacketHandler.lua` |
| `lua/engine_client/util/DressUtil.lua` | `cad31877ba8e56d4235537d26413a533` | `decrypted\all_versions\v10105\cipher\lua\engine_client\util\DressUtil.lua` |
| `lua/engine_server/antihack/ClientFileChecker.lua` | not listed | `decrypted\all_versions\v10105\cipher\lua\engine_server\antihack\ClientFileChecker.lua` |
| `lua/engine_server/packet/PidPacketHandler.lua` | not listed | `decrypted\all_versions\v10105\cipher\lua\engine_server\packet\PidPacketHandler.lua` |

(The four expected MD5s come from the decoded v10105 `lua/sandboxol`
checksum list.)

## Blocker

The v10105 Lua container is a per-file 2-byte -> 3-byte codebook. The
codebook differs for every file and is not stored in the capture: v10105 has
no binary `sandboxol` KeyObject blob or keyfile, unlike v10106+. The codebook
cannot be inferred from other files because the 417 recovered tables are
independent and do not form a global S-box under index/output XOR/add,
additive/XOR offsets, bit rotations, affine maps, or GF(2)-linear maps.

The six files changed in v10105 only. Their source is not present in any other
version, and a source-MD5 preimage search is infeasible.

## Attempted methods

1. Tested every same-name source from v10068-v10113 at every plausible
   ciphertext offset, requiring a unique offset and zero pair conflicts over
   all complete pairs, plus exact re-encoding of the source span.
2. Tried every v10106-v10112 legacy KeyObject record (AES blob
   `blsle20240112345`) and all engine/plugin `keyobjects_*.json` records
   (2,493 records) against the six bodies, including suffix-key matching.
3. Tried the v10107-v10112 second-packet patch MD5 list and the v10104/v10105
   checksum lists (hashes only; no plaintext).
4. Tested global-table hypotheses (bit rotation, index XOR/add, output
   XOR/add, affine, GF(2) linear); none fit the known files.
5. Scanned 34,294 `.lua` files under `reports\` and `server_src\` for the four
   known expected MD5s; no match. Checked v10114 extracted sources; they differ.
6. Parsed all `sandboxol` packets (legacy and numeric-frame), including the
   AES `bmlle20240922345` patch list; no v10105 key material.

Do not treat the six as decoded. Their ciphertext and expected hashes are
retained for a future key-schedule recovery.

## Known non-blocking anomalies

`lua/plugins/new_vip/new_vip.lua` has a stale publisher hash:

- v10104 checksum expects `c1ac...`, decoded source is `1bde...`.
- v10105 checksum and v10106-v10108 headers expect `3e4a...`, decoded source
  is `de9d...`.

The decoded source is valid Lua, re-encrypts byte-exactly, and v10105-v10108
are byte-identical; this is a hash-record lag, not an unresolved decode.
