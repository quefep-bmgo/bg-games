# Blockman GO v10113 map -> Minecraft Java 26.3 world

This document is a complete hand-off for another AI or developer. It describes:

1. the `v10113` Blockman GO map format,
2. the Minecraft Java 26.3 world/chunk format,
3. the exact conversion algorithm,
4. how to fetch maps from the GitHub repository,
5. how to install and validate the finished worlds.

The reference implementation used for this repository is:

```text
tools/mapconv/mapconv.py       # CLI + region/NBT/chunk/world conversion
tools/mapconv/legacy_blocks.py # legacy numeric block id + data -> 26.3 state
tools/mapconv/world_template/  # 26.3 level.dat/data metadata, no terrain
tools/mapconv/README.md        # end-user usage
```

A working CLI invocation is:

```powershell
python tools/mapconv/mapconv.py "path/to/m1001_1.zip" `
  -o "path/to/m1001_1_26.3" `
  --name "m1001_1" `
  --gamemode creative
```

Use `--force` to replace an existing output.

---

## 1. Repository interaction

Repository:

```text
https://github.com/quefep-bmgo/bg-games
```

Games live under:

```text
games/
  g1001/
  g1002/
  g1042/
  ...
```

Each game has a latest snapshot directory such as `v10113/`:

```text
games/<game>/v10113/
  version.json
  config-files.json
  plugin.zip
  maps/
    m<game>_1.zip
    m<game>_2.zip
    ...
```

### 1.1 Do not assume a full checkout

The local workstation clone may have a huge working tree, a sparse checkout, or
`skip-worktree` entries. In this workspace many `games/g1042`, `g1043`,
`g1044`, `g1045`, and `g1053` files exist in Git history/HEAD but are absent
from the checkout. Always verify:

```powershell
git -C <repo> ls-tree --name-only HEAD:games/g1042/v10113/maps
```

If files are not on disk, read the exact blob from Git:

```powershell
# Binary-safe on Windows: use cmd redirection, not PowerShell '>'
cmd /c "git -C <repo> show HEAD:games/g1042/v10113/maps/m1042_1.zip > m1042_1.zip"
```

Or, more safely, use Python to preserve bytes:

```python
import subprocess
data = subprocess.check_output([
    "git", "-C", repo,
    "show", "HEAD:games/g1042/v10113/maps/m1042_1.zip",
])
open("m1042_1.zip", "wb").write(data)
```

GitHub raw URLs also work for individual files:

```text
https://raw.githubusercontent.com/quefep-bmgo/bg-games/main/games/g1042/v10113/maps/m1042_1.zip
```

These map zips are normal binary Git blobs, not LFS pointers.

### 1.2 Find the latest version

The current archive uses `v10113` for the examples below, but do not hardcode
that for every game. List versions and choose the numerically highest `vNNNNN`:

```powershell
git -C <repo> ls-tree --name-only HEAD:games/g1001
```

Then list that version's maps:

```powershell
git -C <repo> ls-tree --name-only HEAD:games/g1001/v10113/maps
```

### 1.3 Known game / mode mapping

| Game | Meaning |
| --- | --- |
| `g1001` | Survival Games |
| `g1002` | Sky Wars |
| `g1042` | Build and Shoot hub/lobby |
| `g1043` | Build and Shoot: Team Fight |
| `g1044` | Build and Shoot: Solo / FFA |
| `g1045` | Build and Shoot: Duel |
| `g1053` | Build and Shoot: Battle Royale |

Build and Shoot mode maps are **not** in `g1042`; only the lobby is there.
Team Fight, Solo/FFA, Duel, and Battle Royale maps are under `g1043`, `g1044`,
`g1045`, and `g1053`.

For other games, inspect the plugin/map localization to identify the title. The
repository also contains `game-resource-config.json`, `game_configs/<game>.json`,
and per-game READMEs. A reliable source of map display names is the map bundle's
`lang/en_map.lang` (look for `gui_map_<id>=...`).

**Full game title index:** see
[`games/INDEX.md`](../games/INDEX.md) for the best-known
`gXXXX -> English title` mapping, including Bird Simulator (`g1041`),
Sky Block (`g1048`-`g1050`), Bed Wars (`g1008`, `g1046`, `g1061`-`g1063`,
`g1065`), Survival Games, Sky Wars, and the Build and Shoot modes. Some
newer/internal IDs are marked `unidentified`.

---

## 2. What a v10113 map bundle contains

A map is a ZIP such as:

```text
games/g1002/v10113/maps/m1002_1.zip
```

Typical entries:

```text
checksums.md5
config.yml
lang/en_map.lang
lang/zh_map.lang
r.<x>.<z>.mca
res.pack
dynamic/
GameTip/
minimap/
```

Not every map contains every entry. The only terrain payload is the `.mca`
region files. `res.pack`, `dynamic/`, `GameTip/`, and `minimap/` are game assets
and can be ignored for a Minecraft terrain conversion.

### 2.1 `config.yml`

`config.yml` contains spawn positions and game timing. Important fields:

```yaml
initPos:
  - x: 1790
    y: 60
    z: -616
gameTime: 600
enableBreak: false
```

`initPos` is the intended player spawn in the original map. If present, it is
usually better than an automatically computed spawn. Support both:

- a single `initPos: [x, y, z]` value,
- a YAML list of `{x, y, z}` entries.

Use the first valid position; add 1 to Y if the point is the block below the
player's feet.

### 2.2 `lang/en_map.lang`

Map mode names and map display names are here:

```text
mode1_name=Team Fight
mode2_name=Solo
mode3_name=Duel
mode5_name=Battle Royale
gui_map_1001=▢FFFFFF00Giant Chessboard
gui_map_2004=▢FFFFFF00Water World
gui_map_5001=▢FFFFFF00Radiation City
```

The `▢FFFFFF00` prefix is a color/format code. Strip it for a clean world name.
For Build and Shoot this gives names such as `Giant Chessboard`, `Giant Kitchen`,
`Transport Ship`, `Grey Desert`, `Water World`, `Storage`, `Village`,
`Radiation City`.

### 2.3 Region files

Each `r.<x>.<z>.mca` is an Anvil-style region:

```text
bytes 0..4095      1024 location entries
bytes 4096..8191   1024 timestamp entries
bytes 8192..       chunk records, 4096-byte sectors
```

Each location entry is four bytes:

```text
3-byte big-endian sector offset | 1-byte sector count
```

The chunk record at `sector_offset * 4096` is:

```text
4-byte big-endian payload length (includes the compression-type byte)
1-byte compression type
payload
```

Source exports disagree with the spec in three ways; tolerate all of them:

1. **The sector-count byte is unreliable.** Do not trust it. Derive the record
   span from the length field:
   `ceil((length + 4) / 4096)` sectors.
2. **The compression type may be mislabelled.** These maps commonly write
   `compression type = 2` but the payload starts with gzip magic `1f 8b`.
   Detect the codec from the payload magic first, then fall back to the type:
   gzip -> zlib -> raw.
3. **External chunks.** Bit `0x80` of the first offset byte can mark an
   external `.mcc` chunk. Skip those entries for these legacy map bundles.

Repeated offsets can occur. Deduplicate offsets so one record is not parsed
twice. The authoritative chunk coordinates are the `xPos` / `zPos` values
inside the NBT, not the table index.

### 2.4 Legacy chunk NBT

These maps use the pre-1.13 numeric block format. Root is a compound, usually:

```text
DataVersion = 0        (sometimes absent or 0)
Level = {
  xPos, zPos
  TerrainPopulated
  InhabitedTime
  Biomes          byte[256]       // 16x16 legacy biome ids
  HeightMap       int[256]        // legacy heightmap
  Sections        list of section compounds
  TileEntities    list of compounds
}
```

Each section:

```text
Y       byte
Blocks  byte[4096]       // block id per cell
Data    byte[2048]       // 4-bit metadata per cell
Add     byte[2048]       // optional; high nibble for ids >= 256
```

Cell index layout:

```text
i = (y_local << 8) | (z_local << 4) | x_local
y_local = i >> 8
z_local = (i >> 4) & 15
x_local = i & 15
```

Metadata nibble:

```python
b = Data[i >> 1]
data = (b >> 4) & 15 if (i & 1) else b & 15
```

Extended id:

```python
b = Add[i >> 1]
add = (b >> 4) & 15 if (i & 1) else b & 15
block_id = Blocks[i] | (add << 8)
```

Source sections are normally `Y = 0..7` (128 blocks tall). Do not assume every
chunk has all eight sections; missing sections are air.

`TileEntities` often contains old ids such as `Sign`, `Chest`, `Beacon`,
`Bed`, `Furnace`, `FlowerPot`, `Hopper`, `Skull`, `DLDetector`, etc.
The reference converter preserves signs and skips other block entities. If
another AI wants full fidelity, convert chest inventories, banners, etc.
separately; that is outside the terrain payload.

---

## 3. Minecraft Java 26.3 target format

Target: **Minecraft Java 26.3**, data version **5023** (minimum Java 25).

### 3.1 World directory layout

26.3 no longer uses the old top-level `region/` layout. A world looks like:

```text
World/
  level.dat
  data/minecraft/
    game_rules.dat
    world_gen_settings.dat
    weather.dat
    ...
  dimensions/minecraft/overworld/
    region/r.<x>.<z>.mca
    data/minecraft/
      chunk_tickets.dat
      raids.dat
      world_border.dat
  dimensions/minecraft/the_nether/
  dimensions/minecraft/the_end/
  players/data/
  datapacks/
```

The overworld terrain must go under:

```text
dimensions/minecraft/overworld/region/
```

Putting it in `World/region/` will not work.

The easiest reliable base is a world created by a real 26.3 server. The
reference `tools/mapconv/world_template/` is exactly such a world with all
terrain/region/POI files removed. It contains `level.dat`, the data files, and
the dimensions metadata. Copy it, replace the overworld region files, and
update `level.dat`.

### 3.2 `level.dat`

Root is a compound with a `Data` compound. Relevant fields:

```text
Data:
  DataVersion = 5023
  Version = { Snapshot: 0, Series: "main", Id: 5023, Name: "26.3" }
  version_history = [5023]
  LevelName = "Some Map Name"
  initialized = 1
  allowCommands = 1
  GameType = 1                     // 0 survival, 1 creative, 2 adventure, 3 spectator
  LastPlayed = <epoch ms>
  spawn = {
    pos: [x, y, z]                 // note: object, not SpawnX/SpawnY/SpawnZ
    pitch: 0.0
    yaw: 0.0
    dimension: "minecraft:overworld"
  }
  difficulty_settings = { difficulty: "easy", hardcore: 0, locked: 0 }
  DataPacks = { Enabled: ["vanilla"], Disabled: [...] }
```

`world_gen_settings.dat` is separate from `level.dat` in this layout. Keep the
template's file unless the world should use a special generator. Normal world
generation outside the converted map is the default.

Remove `session.lock` and `level.dat_old` from upload/staging worlds.

### 3.3 Chunk NBT

Root compound observed in a real 26.3 chunk:

```text
DataVersion = 5023
xPos, zPos
yPos = -4
Status = "minecraft:full"
LastUpdate = 0L
InhabitedTime = 0L
sections = list of 24 section compounds
Heightmaps = { MOTION_BLOCKING: long[37], WORLD_SURFACE: long[37] }
block_entities = list
block_ticks = list
fluid_ticks = list
structures = { References: {}, starts: {} }
PostProcessing = list of 24 lists
isLightOn = 0
```

24 sections cover `Y = -4 .. 19`, i.e. world Y `-64 .. 319`.

Each section:

```text
Y = byte
block_states = {
  palette = list
  data = long[...]        // omitted when palette length is 1
}
biomes = {
  palette = list
  data = long[...]        // omitted when palette length is 1
}
BlockLight = byte[2048]   // optional
SkyLight = byte[2048]     // optional
```

### 3.4 26.3 block-state palette format

26.3 renamed the old `Name` / `Properties` fields:

- `Name` -> `id`
- `Properties` -> `properties`

A palette may be a list of strings when every entry is a default state:

```text
["minecraft:air", "minecraft:stone", "minecraft:grass_block"]
```

If **any** entry has properties, the entire palette list must be compounds.
Default-state entries can be represented as `{"id": "minecraft:stone"}`;
states with properties add a `properties` compound:

```text
{ id: "minecraft:oak_stairs",
  properties: { facing: "east", half: "bottom", shape: "straight" } }
```

The real game also serializes some default states as a compound with an empty
key, e.g. `{"": "minecraft:bedrock"}`. That is accepted by 26.3, but a writer
should use the explicit `id` form for clarity.

Do **not** write old 1.13-1.21 `Name`/`Properties` keys into a 5023 world.

### 3.5 Block-state `data` packing: use padded packing

This is the most common failure when writing 26.3 chunks.

For a palette of `n` states:

```python
bits = max(4, (n - 1).bit_length())
per_long = 64 // bits
length = ceil(4096 / per_long)
```

Pack `per_long` values in each 64-bit long, in order, with no value straddling
a long. This is **padded** packing, not the dense/bit-straddling packing used
by some 1.16-1.21 writers.

Example: `bits = 5` means 12 values per long and **342 longs** for 4096 cells.
A dense writer produces 320 longs and 26.3 will fail with:

```text
Failed to read PalettedContainer: Invalid length given for storage,
got: 320 but expected: 342
```

When palette length is 1, omit `data`; all cells use palette index 0.

### 3.6 Biomes

The simplest safe conversion is one biome per section:

```text
biomes = { palette: ["minecraft:plains"] }
```

Omit `data`. If multiple biomes are needed, use a `bits = max(1, ceil(log2(n)))`
padded packing for the 64 biome cells in a section. The reference tool always
writes plains to avoid this ambiguity.

### 3.7 Heightmaps

26.3 heightmaps are 9-bit values, **padded** 7 values per long, producing
**37 longs** for 256 columns.

Value semantics:

```text
height = 0                                if the column has no block
height = (highest_block_y + 1) + 64       otherwise
```

In the reference implementation `top` already equals `highest_block_y + 1`, so
the code is `min(511, top + 64)`, with `0` for empty columns.

Write both `MOTION_BLOCKING` and `WORLD_SURFACE`. The reference tool uses the
same height for both, except `MOTION_BLOCKING` ignores non-solid ids (air,
water, lava, plants, torches, rails, etc.).

### 3.8 Lighting

The reference tool sets:

```text
isLightOn = 0
```

and omits `BlockLight` / `SkyLight` arrays. Minecraft relights the chunk when it
loads. This avoids implementing the 26.3 light engine. Do not set `isLightOn=1`
with missing light data; chunks can render dark.

### 3.9 Region output

Write standard Anvil region files:

- header: 1024 location entries + 1024 timestamp entries = 8192 bytes,
- location entry: 3-byte big-endian sector offset + 1-byte sector count,
- payload: 4-byte big-endian length, 1-byte compression type `2` (zlib),
  zlib-compressed chunk NBT,
- length includes the compression-type byte, so `length = len(zlib_data) + 1`,
- pad the record to a 4096-byte sector boundary.

Do not use gzip for output. 26.3 expects standard zlib in normal region files.

### 3.10 Empty chunks

A source region file may contain only some of the 1024 possible chunks. In a
Sky Wars/Survival Games map those missing positions are void. To prevent
Minecraft from generating normal terrain inside the map area, write a
**full-status air chunk** for every missing position within each source region
file's 32x32 area.

An empty chunk still needs:

- `Status = "minecraft:full"`,
- 24 sections with an air palette `["minecraft:air"]`,
- single-biome plains sections,
- zeroed heightmaps,
- `DataVersion = 5023`, `yPos = -4`.

Use `--no-empty-chunks` only when surrounding generated terrain is desired.

---

## 4. Conversion algorithm

### 4.1 Input handling

1. Accept a map ZIP or a directory of `.mca` files.
2. If ZIP, read every entry ending in `.mca`; ignore `lang/`, `res.pack`,
   `dynamic/`, `GameTip/`, `minimap/`, and checksums.
3. For each region file, parse chunks with the tolerant reader described above.
4. Use the chunk's `Level.xPos` / `Level.zPos` as global coordinates.
5. Collect source region coordinates from the filenames so missing chunks can
   be filled with air chunks.
6. Optionally apply `--offset-x` / `--offset-z` to all global coordinates.

### 4.2 Block mapping

Map each source `(id, metadata)` pair to a modern 26.3 state. The reference
mapping is `tools/mapconv/legacy_blocks.py`; use it directly if possible.

Important legacy rules:

- stairs: `data & 3` facing (east, west, south, north), `data & 4` = top half,
  add `shape=straight`.
- slabs: material in low metadata bits; `data & 8` = top; double slabs become
  the full material block or a slab with `type=double`.
- logs: low 2 bits select wood; bits `0xC` select axis (`y`, `x`, `z`, or
  all-bark `wood`).
- leaves: modern leaves should get `persistent=true`, `distance=1` to avoid
  decay.
- water/lava: use `level` 0-7; a static map can use `level=0`.
- wool/carpet/glass/concrete/terracotta: metadata is the 16-color index.
- double plants: `data & 7` type, `data & 8` upper half; write `half=upper`.
- signs: block id 63/68; preserve the `TileEntities` text (see below).
- ids >255 can come from the `Add` nibble. If the id is a custom Blockman GO
  block, it has no vanilla equivalent. The reference tool falls back to stone
  and reports it (for example `917:0` in Battle Royale `Radiation City`).

State properties are dictionaries of strings. Booleans must be written as
`"true"` / `"false"`.

### 4.3 Per-chunk conversion

For each global chunk `(x, z)`:

1. Build 24 target sections `Y = -4 .. 19`.
2. For target `Y` in `0..15`, read the source section with the same `Y`.
   (The source is normally only 0..7; higher target sections are air.)
3. For every source cell:
   - get `(id, metadata)` from `Blocks` / `Data` / optional `Add`,
   - map it via `legacy_blocks.py`,
   - store the resulting `(name, props)` key in the target cell.
4. Build the section palette:
   - start with air at index 0,
   - add unique states in first-seen order,
   - if any state has properties, write a compound palette; otherwise write a
     string palette,
   - pack 4096 indices with the **padded** algorithm.
5. Build biomes: one plains palette entry.
6. Compute heightmaps as described above.
7. Convert signs from source `TileEntities`:
   - modern block entity id `minecraft:sign`,
   - `front_text.messages` = four JSON strings derived from `Text1..Text4`,
   - `back_text` = four empty strings,
   - `is_waxed = 0`.
8. Add empty `block_ticks`, `fluid_ticks`, `structures`, and the template's
   `PostProcessing`.
9. Compress and write the chunk into its output region.

### 4.4 Spawn

Prefer `config.yml`'s first `initPos` entry. If unavailable, choose a solid
chunk near the map center (the reference tool prefers the chunk containing the
center, then the nearest non-empty chunk, then the densest nearby chunk).
Spawn Y should be above the highest solid block.

Set `Data.spawn.pos` accordingly in `level.dat`. Optionally allow a CLI override
`--spawn X Y Z`.

### 4.5 Output world

1. Copy the 26.3 world template.
2. Remove stale `session.lock`, `level.dat_old`, overworld `region/`, `poi/`,
   and `chunk_tickets.dat`.
3. Write converted region files under
   `dimensions/minecraft/overworld/region/`.
4. Update `level.dat`:
   `LevelName`, `DataVersion=5023`, `Version`, `version_history`,
   `GameType`, `allowCommands`, `spawn`, `LastPlayed`, difficulty.
5. Keep `data/minecraft/world_gen_settings.dat` and dimension data files.
6. Optionally zip the world.

For Planet Minecraft uploads, put the world inside a top-level folder in the
ZIP:

```text
m1002_1 - Wooden Wars/
  level.dat
  dimensions/...
  data/...
```

The reference CLI's `-o world.zip` zips the world contents at ZIP root, which is
fine for direct extraction into `.minecraft/saves`, but a top-level folder is
more user-friendly for Planet Minecraft.

---

## 5. Validation

Use a real Minecraft Java 26.3 server (Java 25+).

1. Copy the world into the server directory (or use a temp copy).
2. Set `server.properties`:
   - `level-name=<world folder>`
   - `online-mode=false`
   - `enable-rcon=true`, password, port
   - `allow-nether=false` for faster checks
3. Start the server and wait for `Done`.
4. Force-load a sample area. `/forceload add` is limited to **256 chunks** per
   command; load 16x16-chunk blocks.
5. Run `save-all flush`, then `stop`.
6. Scan the log for:

```text
ERROR
Failed to load chunk
Failed to read PalettedContainer
Invalid length given for storage
Recoverable errors when loading section
Unknown block
```

A healthy conversion produces zero hits for these patterns.

Also verify:

- each chunk's `DataVersion` is `5023`,
- the source non-air block count equals the output non-air block count
  (palette decoding required),
- heightmaps and spawn are sane,
- signs have `front_text`,
- the world appears under `dimensions/minecraft/overworld/region/`.

Full validation of a 1024x1024 map requires loading 4 regions x 4 forceload
commands (16 commands total) or starting the server with a player/spawn ticket.

---

## 6. Installing into a CurseForge instance

Typical Windows path:

```text
C:\Users\<user>\curseforge\minecraft\Instances\<Instance>\saves\
```

Copy each converted world folder there. The folder name is the save name shown
by the launcher; `level.dat`'s `LevelName` controls the in-game display name.

For a 26.3 Forge instance, the converted world is vanilla-compatible. Avoid
running a different-version server on the world before opening it.

If the instance is open, do not delete or overwrite a currently loaded world.
Close Minecraft first.

---

## 7. Reference implementation map

`tools/mapconv/mapconv.py`:

| Function / area | Purpose |
| --- | --- |
| typed `Byte`/`Int`/`Long`/`List`/`Compound` classes | NBT read/write with exact types |
| `read_nbt` / `write_nbt` | NBT codec |
| `pack_dense` | dense packing (not used for 26.3 block states) |
| `pack_padded` | 26.3 block-state/heightmap packing |
| `iter_region_chunks` | tolerant old-region reader |
| `build_sections` | legacy sections -> 26.3 sections, palette, heightmaps |
| `build_modern_chunk` | complete 26.3 chunk root |
| `build_empty_chunk` | full-status air chunk |
| `write_region` | Anvil writer with zlib |
| `copy_template` | copies `world_template/` and removes stale files |
| `update_level_dat` | writes 26.3 `level.dat` |
| `main` | CLI, spawn stats, region grouping, ZIP support |

`tools/mapconv/legacy_blocks.py`:

- `legacy_state(id, data)` returns `(modern_name, props)` or `None` for air,
- `LEGACY_TABLE` is the precomputed 256x16 table,
- extend this table when a map uses a block that is not mapped.

---

## 8. Known pitfalls checklist

- [ ] Source region compression may be gzip despite type `2`.
- [ ] Source sector counts may be wrong; derive span from the length field.
- [ ] Deduplicate repeated chunk offsets.
- [ ] Use `Level.xPos/zPos`, not table indices.
- [ ] Handle optional `Add` nibbles and custom ids >255.
- [ ] 26.3 palette uses `id` / `properties`, not `Name` / `Properties`.
- [ ] 26.3 block-state data uses **padded** packing; length must match.
- [ ] 26.3 heightmaps are 9-bit padded, 37 longs, value = top+65.
- [ ] Chunks live under `dimensions/minecraft/overworld/region/`.
- [ ] `yPos=-4` and 24 sections `-4..19`.
- [ ] Set `isLightOn=0` if not writing light arrays.
- [ ] Write full-status air chunks to stop terrain generation inside the map.
- [ ] Copy a real 26.3 world template for `level.dat`/worldgen metadata.
- [ ] Prefer `config.yml` `initPos` for spawn.
- [ ] Skip `res.pack`, `dynamic/`, `GameTip/`, `minimap/` for terrain.
- [ ] Signs need block entities; chests/beacons/etc. are skipped by the reference
  tool.
- [ ] Validate against a real 26.3 server, not just an NBT parser.

---

## 9. Copy-ready task prompt for another AI

```text
You are converting Blockman GO v10113 map bundles into Minecraft Java 26.3
worlds (DataVersion 5023).

Repository: https://github.com/quefep-bmgo/bg-games
Maps:       games/<game>/v10113/maps/m<game>_<n>.zip
Reference:  tools/mapconv/mapconv.py and tools/mapconv/legacy_blocks.py

Steps:
1. Discover the requested game IDs and their latest vNNNNN directory from Git.
2. Fetch the requested map ZIPs from Git HEAD (use git show; do not assume the
   working tree has them).
3. For each map, read every r.*.mca region with tolerance for gzip/zlib
   mislabelling, unreliable sector counts, and repeated offsets.
4. Convert legacy numeric Blocks/Data/Add sections to 26.3 block_states.
   Use a compound palette with `id`/`properties` when any state has properties;
   otherwise use a string palette.
5. Pack block indices with PADDED 64-bit packing:
   bits = max(4, ceil(log2(palette_len))); per_long = 64 // bits.
   Do not use dense/bit-straddling packing.
6. Build 24 sections Y=-4..19, yPos=-4, DataVersion=5023, Status full,
   isLightOn=0, 9-bit padded heightmaps, single plains biome.
7. Fill missing chunks inside each source region with full-status air chunks.
8. Copy the 26.3 world_template, write regions under
   dimensions/minecraft/overworld/region, and update level.dat (LevelName,
   GameType, allowCommands, spawn, DataVersion/version history).
9. Install the worlds into the requested CurseForge instance saves folder, or
   package them as ZIPs with a top-level world folder.
10. Validate each world on a real 26.3 server with forceload and scan logs for
    PalettedContainer / chunk-load / unknown-block errors.

Report the game title, mode names, map names, and any custom Blockman GO blocks
that had to be substituted.
```
