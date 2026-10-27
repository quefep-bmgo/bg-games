# Scripts

These are working reference scripts copied from the analysis workspace. Many contain absolute paths from that environment. Read the top of each script before running.

## Primary tool

```text
bmg_extract.py
```

Generic extractor:

```powershell
python bmg_extract.py `
  --games-root "C:\path\to\games" `
  --out "C:\path\to\output" `
  --games g1042,g1100,g1048,g1005
```

Options:

- `--games-root`: folder containing `<game>\<version>\plugin.zip`
- `--out`: output root
- `--games`: comma-separated game IDs
- `--versions`: optional comma-separated version filter

## Specialized scripts

```text
decrypt_pack.py
```

Minimal plugin pack decryptor; useful for understanding the format.

```text
decrypt_all.py
```

Decrypts the known plugin/engine/map packs using precomputed key/TOC references.

```text
decrypt_g1100_latest.py
```

Current g1100 keyfile/parser including the special trailing records and large-blob AES path.

```text
extract_g1042_versions.py
```

Extracts plaintext g1042 versions, inline-MD5 entries, and map configs.

```text
build_multi_decrypted.py
```

Historical all-game builder used to produce `DECRYPTED`. It contains fixed game/data paths.

```text
verify_pipeline.py
verify_g1100.py
```

Byte-exact re-encryption validators.

```text
decompile_engine.py
decompile_games.py
```

Batch unluac drivers.

## Dependencies

```text
pip install pycryptodome unicorn pyelftools capstone
```

Java and unluac are required only for decompilation.

## Native dependency

`emu_lib.py` points at:

```text
C:\Users\quefep\AppData\Local\Temp\opencode\g1042_analysis\native\bg_libBlockMan_arm64.so
```

Change that path if the workspace moves.

## Safety rule

Never trust a plaintext file only because it “looks like Lua.” Verify:

```text
encrypt(plaintext, original_ciphertext, key_record) == original_ciphertext
```

and for CSV:

```text
substitute(plaintext) == original_ciphertext
```
