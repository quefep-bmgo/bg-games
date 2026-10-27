# 04 — CSV substitution and map packs

## 1. `flag = 1` is not the 3-byte cipher

Entries with `flag = 1` are byte-substitution encoded.

The table in:

```text
...\howto\data\sub_table.pkl
```

is oriented:

```text
plaintext byte -> ciphertext byte
```

To decrypt:

```python
import pickle

T = pickle.load(open("sub_table.pkl", "rb"))
inv = {cipher: plain for plain, cipher in T.items()}

plain = bytes(inv.get(byte, byte) for byte in raw)
```

To verify:

```python
enc = bytes(T.get(byte, byte) for byte in plain)
assert enc == raw
```

## 2. How the table was built

The table was built from known plaintext/ciphertext pairs, then broadened using the plaintext CSVs present in the older map zips.

The final table has 157 bijective pairs.

It covers every raw byte in:

- g1042 plugin CSVs (21/21)
- g1042 map CSVs (37/37)
- g1100 CSVs except the language table (14/15 in each room pack)
- g1048 CSVs (281/281)

The one partial case is g1100:

```text
setting/lang/lang.csv
```

It contains Unicode byte values not present in the known table. The file is decoded for readable regions, but some bytes remain substitutions. This is recorded as a known exception in the validation report.

## 3. Why table construction is safe

For every known plaintext/ciphertext pair:

```text
same plaintext byte always maps to the same ciphertext byte
```

There were no conflicts on the files used for the final table.

This is why the map CSV operation is a substitution and not XOR/add with a position-dependent key.

## 4. What a map pack contains

A map zip is not the same as the plugin `res.pack`.

Example:

```text
C:\Users\quefep\Desktop\Decomp Temp\games\g1042\v10113\maps\m1042_1.zip
```

contains:

```text
config.yml
r.0.0.mca
r.3.-2.mca
lang/*.lang
GameTip/g1045.csv
dynamic/*.json
dynamic/*.png
res.pack
checksums.md5
```

### `config.yml`

Contains the actual map settings:

- `initPos`
- `standByTime`
- `refreshTime`
- `prepareTime`
- `gameTime`
- `extraTime`
- `gameOverTime`
- `showRankTick`
- `waitRespawnTime`
- `autoRespawnTime`
- `invincibleTime`
- team caps, for combat modes

### `r.*.mca`

Minecraft-style region files. These contain the block terrain, not Lua and not CSV.

### `res.pack`

The map `res.pack` exposes map/game config tables, such as:

- `ModeSelect.csv`
- `ModeSelectMap.csv`
- `GunSetting.csv`
- `GunLevelSetting.csv`
- `Armor.csv`
- `RewardSetting.csv`
- task/season/shop/chest tables

For g1042, the map `res.pack` produced 37 CSVs:

```text
...\g1042_analysis\decrypted_map
```

## 5. g1042 mode/map mapping

The hub is g1042 itself. The combat modes are separate game packages.

| Mode | Package | Map IDs | Actual map zips |
|---|---|---|---|
| Team Fight | g1043 | 1001-1004 | `games\g1043\v10113\maps\m1043_*.zip` |
| Solo / FFA | g1044 | 2001-2004 | `games\g1044\v10113\maps\m1044_*.zip` |
| Duel | g1045 | 3001-3004 | `games\g1045\v10113\maps\m1045_*.zip` |
| Battle Royale | g1053 | 5001 | `games\g1053\v10113\maps\m1053_1.zip` |

The ID `1000`, `2000`, `3000` in `ModeSelectMap.csv` is a **Random Map** selector, not a physical map.

### FFA / Solo maps

```text
m1044_1.zip  -> 2001 Giant Chessboard
m1044_2.zip  -> 2002 Giant Kitchen
m1044_3.zip  -> 2003 Transport Ship
m1044_4.zip  -> 2004 Water World
```

### Team Fight maps

```text
m1043_1.zip  -> 1001 Giant Chessboard
m1043_2.zip  -> 1002 Giant Kitchen
m1043_3.zip  -> 1003 Transport Ship
m1043_4.zip  -> 1004 Grey Desert
```

### Duel maps

```text
m1045_1.zip  -> 3001 Storage
m1045_2.zip  -> 3002 Transport Ship
m1045_3.zip  -> 3003 Village
m1045_4.zip  -> 3004 Grey Desert
```

### Battle Royale

```text
m1053_1.zip  -> 5001 Radiation City
```

The mode/map tables are:

```text
...\g1042_analysis\decrypted_map\ModeSelect.csv
...\g1042_analysis\decrypted_map\ModeSelectMap.csv
```

## 6. Important distinction

`g1042` plugin `res.pack`:

- hub logic
- lobby UI
- matchmaking
- shared engine
- economy and progression
- mode/map selection tables
- no FFA combat logic
- no terrain

`g1044` plugin `res.pack`:

- actual Solo/FFA mode host logic

`m1044_*.zip`:

- actual FFA terrain and map config

If the goal is FFA map layout, start with `games\g1044\v10113\maps\m1044_*.zip`.

If the goal is FFA rules, extract `g1044`’s plugin pack too.
