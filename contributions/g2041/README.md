# Anime All Stars (`g2041`) contribution overlay

This folder holds a repeatable, additive local contribution set for the original Anime All Stars package. It is kept separate from both the immutable archive extraction and the current local test worktree.

## Baseline

- Original archive: `engine2_packs/g2041/g2041.1735114999081.zip`
- SHA-256: `530CB8826ADB4FD3605C4579D73908A99BFB45DE9E5599193DE4B630740E7E41`
- Original extracted tree: `engine2_work/g2041_original` (2,658 files; 68,477,479 unpacked bytes)
- Current editable local test tree: `engine2_work/g2041`
- Original archive is the source of truth. Do not edit it or `g2041_original` in place.

## Contribution layout

```text
contributions/g2041/
  manifest.json
  README.md
  CONTRIBUTING.md
  patches/
    boss_70.json
    level_curve.json
    open_navigation.json
  templates/
    boss.md
    item.md
    model.md
    skill.md
  scripts/
    apply_local_overlay.ps1
    validate_local_overlay.ps1
    package_zip.ps1
```

The patch script changes only the supplied extracted package root. Start from a copy of `g2041_original` for a clean contribution build; the script is also repeatable on the current worktree.

## Included local changes

- Raise the gold exchange cap from 300 to 3,000 gCubes by setting `setting.json` `buyGoldPrice.maxBuyMinute` to `18000` (`10` gCubes per `60` minutes).
- Tune final listed boss `bossId=70`: set the visible recommendation to `500000` and base attributes to the tested values in `patches/boss_70.json`. The local runtime calculation is about `500.21K` fight.
- Extend player levels from 90 to 150 using the explicit progression recipe in `patches/level_curve.json`.
- Open the map for local navigation by removing the 24 invisible `g2041_kongqiqiang` scene instances. Also remove the five locally added `sharen_9_*` collider pairs and any old approximate donor colliders.

The contribution layout and full skill/item/model/boss workflows are mapped, but no new art assets or skill/item designs have been invented in this patch. Use the templates after choosing their gameplay/art specs and reserving IDs.

The five `sharen_9_*` colliders and donor colliders were not in the pristine archive; they created additional collision shapes. The `kongqiqiang` objects are original invisible arena boundaries. This contribution removes them in the open-navigation variant while leaving their shared mesh/collider assets untouched.

## Build/test

```powershell
powershell -ExecutionPolicy Bypass -Command "Copy-Item .\engine2_work\g2041_original .\engine2_work\g2041_contribution_stage -Recurse"

powershell -ExecutionPolicy Bypass -File .\contributions\g2041\scripts\apply_local_overlay.ps1 `
  -GameRoot .\engine2_work\g2041_contribution_stage

powershell -ExecutionPolicy Bypass -File .\contributions\g2041\scripts\validate_local_overlay.ps1 `
  -GameRoot .\engine2_work\g2041_contribution_stage

powershell -ExecutionPolicy Bypass -File .\contributions\g2041\scripts\package_zip.ps1 `
  -GameRoot .\engine2_work\g2041_contribution_stage `
  -OutputZip .\engine2_work\zip\g2041\g2041-contribution-local.zip -Force
```

The pristine extraction remains untouched. The packager writes forward-slash ZIP members and does not add an extra parent directory.

## Server compatibility boundary

The overlay uses the original game package layout and server-authoritative config paths. The local Engine2 loader explicitly falls back to raw CSV/JSON when `all_configs.lbc` is absent; that fallback has been verified with the changed cap, boss, and level-150 row. It is **not** a way to inject changes into Blockman Go's official live servers. Live use requires the game operator to approve and deploy the matching server package.

The local runtime reports Engine2 `20075`; the extracted `res/engine2Version.json` reports `20055`. That mismatch remains a possible source of physics differences. In the local run, the open-navigation patch removed the 24 authored air-wall objects and physics `conv` count dropped from `7001` to `6964` after also removing 13 locally-added `sharen_9_*` hulls. The patch does not claim to make the older runtime's physics identical to the original game runtime.

`all_configs.lbc` is removed by this overlay because the server loads its stale table ahead of raw CSV/JSON files. The raw-config fallback is verified locally. For an operator release, the operator should either regenerate the bundle from the final data with their matching toolchain or confirm the target runtime supports raw-config fallback. The bundled `gen_config_common.exe` is a resource-packaging tool, not the `all_configs.lbc` config compiler. The local free-purchase shim in `plugin/quefep_test` and the test account are deliberately not part of this contribution overlay.
