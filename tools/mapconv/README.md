# mapconv

Convert a legacy Blockman GO `.mca` map bundle into a **Minecraft Java 26.3**
world.

See also: [`../../howto/15-bg-map-to-minecraft.md`](../../howto/15-bg-map-to-minecraft.md)
for the full v10113 format specification, GitHub repository workflow, and
conversion/validation contract.

The source maps use the old (<=1.12) Anvil section format with numeric
`Blocks` / `Data` arrays. The output uses the 26.3 world layout
(`DataVersion 5023`):

```
world/
  level.dat
  dimensions/minecraft/overworld/region/r.x.z.mca
  dimensions/minecraft/overworld/data/minecraft/*.dat
  ...
```

## Requirements

- Python 3.8+ (tested with Python 3.12)
- No third-party Python packages
- Java / Minecraft 26.3 are only needed to open the result, not to convert

## Usage

```powershell
python tools/mapconv/mapconv.py "games\g1001\v10068\maps\m1001_1.zip" `
  -o "converted\m1001_1_26.3" --name "m1001_1" --gamemode creative
```

Or drag a map zip onto `convert-map.cmd`.

Useful options:

```
-o PATH                 output world folder, or a .zip of the world
--name NAME             level name shown in Minecraft
--gamemode MODE         survival | creative | adventure | spectator
--difficulty DIFF       peaceful | easy | normal | hard
--spawn X Y Z           override the computed spawn
--offset-x N            shift output chunks on X
--offset-z N            shift output chunks on Z
--no-empty-chunks       let Minecraft generate empty areas instead of void
--force                 overwrite an existing output
```

Then copy the output folder into `.minecraft\saves` (or unzip the `.zip`
there) and open it in Minecraft 26.3.

## What is converted

- All legacy numeric block IDs and metadata, including colours, wood types,
  stairs, slabs, logs, leaves, doors, fences, signs, crops, and common
  redstone/decorative blocks.
- Source chunk coordinates are preserved (`level.xPos/zPos`).
- Signs become 26.3 `minecraft:sign` block entities with their front text.
- Empty source chunks are written as full-status air chunks so Minecraft does
  not generate random terrain inside the map area.
- A spawn point is computed near the map centre (override with `--spawn`).
- The output is relit by Minecraft (`isLightOn=0`) on first load.

Not converted: chest/furnace inventories and other non-sign block entities,
entities/mobs, scoreboards, and map-specific game logic from the Blockman GO
plugin. Those are outside the terrain map bundle.

## Format notes

- Target data version: `5023` (Minecraft Java 26.3).
- Block palettes with properties are written as `{id, properties}` compounds;
  all-default palettes are written as plain block-ID strings.
- `block_states.data` and heightmaps use the padded 64-bit packing expected by
  26.3.
- Region files use standard 4 KiB sector Anvil records with zlib compression.
- The small `world_template/` directory contains the 26.3 world metadata
  (`level.dat`, game rules, worldgen settings) used as a base. It does not
  contain terrain.
