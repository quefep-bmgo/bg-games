# Blockman GO res.pack decryption — how-to

This folder documents how the `res.pack`, `sandboxol` keyfiles, Lua wrappers, map CSVs, and Lua 5.1 bytecode were decrypted, extracted, and verified.

It covers the formats used by:

- `g1042` Build and Shoot / Pixel Gun Hall
- `g1100` Rooms
- `g1048` Skyblock
- `g1005` ClanWar
- current packs such as `g1032`, `g1033`, `g1035`, `g1080`, `g1149`, `g1188`
- legacy packs `v10109`–`v10112`
- per-file inline-MD5 packs `v10105`–`v10108`

## Quick algorithm summary

```text
res.pack container
  u32 len1 = 16
  byte[16] support/header blob
  u32 len2
  byte[len2] encrypted TOC
  u32 content_size
  byte[content_size] content

TOC current: custom AES-128 implemented by the native library
TOC legacy:  standard AES-128-ECB + PKCS#7, key b"blrsp20241212345"
TOC entry:   u16 nameLen, name, u32 offset, u32 size, u32 size2, u8 flag

flag 0 content:
  every 3 ciphertext bytes (selector, a, b) -> 2 plaintext bytes
  p0 = apply_list(a, lists[selector >> 4])
  p1 = apply_list(b, lists[selector & 0x0f])
  KeyObject record selected by MD5(ciphertext)

flag 1 content:
  one-byte substitution; sub_table.pkl is plaintext -> ciphertext
```

## Where the outputs are

```text
C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED
```

Latest fully decrypted trees:

```text
...\DECRYPTED\g1042_build_and_shoot\v10113\source
...\DECRYPTED\g1100_rooms\v10113\source
...\DECRYPTED\g1048_skyblock\v10113\source
...\DECRYPTED\g1005_clanwar\v10072\source
```

Every processed version uses this layout:

```text
DECRYPTED\<game>\<version>\
  source\           Lua source (wrapper removed when present)
  wrapped\          full decrypted wrapper (where applicable)
  bytecode\         Lua 5.1 bytecode (.luac)
  csv\              decoded config CSV
  cipher\           entries that could not be decrypted
  config\           plugin settings outside res.pack
  map_config\       map zip configs
  map_csv\          flag=1 CSVs from map res.pack
  MANIFEST.json
  UNRESOLVED.txt    present only when cipher\ is non-empty
```

## Reproduce

The reusable extractor is:

```text
...\howto\scripts\bmg_extract.py
```

Example:

```powershell
& "C:\Users\quefep\AppData\Local\Programs\Python\Python312\python.exe" `
  "C:\Users\quefep\Desktop\Decomp Temp\howto\scripts\bmg_extract.py" `
  --games-root "C:\Users\quefep\Desktop\Decomp Temp\games" `
  --out "C:\Users\quefep\Desktop\Decomp Temp\DECRYPTED_NEW" `
  --games g1042,g1100,g1048,g1005
```

Only one version:

```powershell
... --games g1048 --versions v10113
```

## Verification

Current-pack validation is byte-exact, not just "it looks like Lua":

- g1042 plugin: 508/508 Lua re-encrypt byte-identically
- g1100 v10113: 615/615 Lua re-encrypt byte-identically
- g1048 v10113: 431/431 Lua re-encrypt byte-identically
- engine: 343/343 Lua bytecode re-encrypt byte-identically
- map CSVs: 37/37 reverse-substitute byte-identically
- TOCs: 5/5 re-encrypt byte-identically

See:

```text
...\DECRYPTED\REPORTS\INDEPENDENT_VALIDATION.md
...\DECRYPTED\REPORTS\LEGACY_FORMAT_REPORT.md
```

## Important limits

- `res.pack` holds scripts and tables, not terrain, textures, or models.
- Map terrain is in `maps\mXXXX_N.zip` as `r.*.mca` region files.
- The live backend is not in the pack. Request authorization, purchases, and server-side validation cannot be proven from Lua alone.
- Legacy `v10109`–`v10112` is **solved**: the two `sandboxol` blobs are ordinary AES-128-ECB with fixed keys `blsle20240112345` and `bmlle20240922345`. See `13-legacy-sandboxol-decryption.md`.
- `g1019` v10105 is partially recovered: 417/423 sources; 6 unique entries still use an unknown per-file codebook.
- `g1042` v10104 and v10105 remain partially or fully unresolved.
- `g1100` has one malformed-key entry, `ItemSkillEvents.lua`.
- `g1188` has one entry with no key record, `WorldPlotRuntime.lua`.
- `g1100` `lang.csv` is partially decoded because the substitution table does not cover all Unicode bytes.

## Document map

| File | Contents |
|---|---|
| `01-container-and-toc.md` | container layout, current and legacy TOC ciphers |
| `02-content-cipher.md` | 3-byte selector cipher, list ops, encryption inverse |
| `03-keyfiles.md` | `sandboxol` framing, KeyObject records, patch maps, MD5 lookup |
| `04-csv-and-maps.md` | CSV substitution, map packs, `.mca`, mode/map tables |
| `05-wrappers-and-bytecode.md` | anti-tamper wrapper and Lua 5.1 bytecode decompilation |
| `06-validation-and-reproduction.md` | commands, counts, failure cases, reusable tool |
| `07-artifact-index.md` | where every important artifact and script lives |
| `08-other-obfuscation.md` | wrappers, bytecode, v10104/v10105, inline-MD5, legacy gaps |
| `09-download-api.md` | manifest API, CDN download workflow, live version check |
| `10-end-to-end-walkthrough.md` | full discovery, download, decryption, validation, outputs, and gaps |
| `11-v10113-laymans-guide.md` | plain-English v10113 download, unpack, res.pack contents, and limitations |
| `12-discord-unpack-bot-spec.md` | `/unpack game option version` bot spec for sandboxol, res.pack, or both |
| `13-legacy-sandboxol-decryption.md` | corrected v10109-v10112 AES keys, KeyObject and patch-map formats, validation |
| `14-aliens-attack-analysis.md` | complete g1019 hard-mode, feature, balance, and hidden-content index |
| `15-bg-map-to-minecraft.md` | Blockman GO map ZIP to Minecraft Java 26.3 world conversion guide |
| `16-v10104-v10105-formats.md` | v10104 static S-box (solved) and v10105 2→3 codebook: structure, recovery methods, status |
| `scripts/` | working reference scripts, including `download_game_resources.py`, `decrypt_legacy_sandboxol.py`, `v10104_harvest.py`, `v10105_*.py` |
| `data/sub_table.pkl` | full known plaintext->ciphertext CSV table |
| `data/v10104_sbox.json` | recovered v10104 cipher→plain byte pairs |
