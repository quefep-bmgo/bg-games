[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $GameRoot).Path
$utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
$culture = [System.Globalization.CultureInfo]::InvariantCulture
$patchRoot = Split-Path -Parent $PSScriptRoot

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $script:utf8NoBom)
}

function Get-RelativePath([string]$Path) {
    return $Path.Substring($script:root.Length).TrimStart('\').Replace('\', '/')
}

function Format-Number([double]$Value, [string]$Format = '0') {
    return $Value.ToString($Format, $script:culture)
}

$settingPath = Join-Path $root 'setting.json'
$settingText = Read-Utf8 $settingPath
$settingObject = $settingText | ConvertFrom-Json
if (-not $settingObject.buyGoldPrice) {
    throw 'setting.json is missing buyGoldPrice.'
}
$settingObject.buyGoldPrice.maxBuyMinute = 18000
$settingText = $settingText -replace '(?m)("maxBuyMinute"\s*:\s*)\d+', '${1}18000'
if ($settingText -notmatch '(?m)"maxBuyMinute"\s*:\s*18000\b') {
    throw 'Could not update setting.json buyGoldPrice.maxBuyMinute.'
}
Write-Utf8 $settingPath $settingText

$bossPath = Join-Path $root 'config\boss.csv'
$bossLines = [System.IO.File]::ReadAllLines($bossPath, [System.Text.Encoding]::UTF8)
$bossRowsChanged = 0
for ($i = 2; $i -lt $bossLines.Length; $i++) {
    if ([string]::IsNullOrWhiteSpace($bossLines[$i])) { continue }
    $fields = $bossLines[$i].Split([char]9)
    if ($fields.Count -lt 26) {
        throw "Unexpected boss.csv column count on line $($i + 1): $($fields.Count)"
    }
    if ($fields[1] -eq '70') {
        $fields[5] = '500000'
        foreach ($index in 10, 11, 12, 13) { $fields[$index] = '264' }
        $fields[18] = '155279'
        foreach ($index in 19, 20, 21, 22) { $fields[$index] = '3' }
        $fields[23] = '123'
        $bossLines[$i] = $fields -join "`t"
        $bossRowsChanged++
    }
}
if ($bossRowsChanged -ne 1) {
    throw "Expected exactly one bossId=70 row; changed $bossRowsChanged."
}
Write-Utf8 $bossPath (($bossLines -join "`r`n") + "`r`n")

$levelPath = Join-Path $root 'config\attribute_level.csv'
$levelLines = [System.IO.File]::ReadAllLines($levelPath, [System.Text.Encoding]::UTF8)
if ($levelLines.Length -lt 3 -or $levelLines[0] -notmatch '^id\s+level\s+upgradePrice') {
    throw 'Unexpected attribute_level.csv header.'
}
$keptLines = New-Object System.Collections.Generic.List[string]
$keptLines.Add($levelLines[0])
$keptLines.Add($levelLines[1])
for ($i = 2; $i -lt $levelLines.Length; $i++) {
    if ([string]::IsNullOrWhiteSpace($levelLines[$i])) { continue }
    $fields = $levelLines[$i].Split([char]9)
    if ($fields.Count -ne 21) {
        throw "Unexpected attribute_level.csv column count on line $($i + 1): $($fields.Count)"
    }
    $level = 0
    if (-not [int]::TryParse($fields[1], [ref]$level)) {
        throw "Non-numeric level row in attribute_level.csv line $($i + 1)."
    }
    if ($level -le 90) { $keptLines.Add($levelLines[$i]) }
}

for ($level = 91; $level -le 150; $level++) {
    $n = $level - 90
    $upgradePrice = 100000000 + (6000000 * $n)
    $legacyUpgradeValue = 13887900 + (150000 * $n)
    $attack = 800 + (18 * $n)
    $maxHp = 8003 + (180 * $n)
    $defense = 10 + [math]::Floor($n / 10)
    $regen = [math]::Round($maxHp / 100.0, 2, [System.MidpointRounding]::AwayFromZero)
    $fight = [math]::Floor((4 * $attack * 25) + ($maxHp * 3) + (4 * $defense * 50) + ($regen * 60) + (2 * $defense * 50))

    $row = @(
        (Format-Number $level),
        (Format-Number $level),
        (Format-Number $upgradePrice),
        (Format-Number $legacyUpgradeValue),
        (Format-Number $attack),
        (Format-Number $attack),
        (Format-Number $attack),
        (Format-Number $attack),
        '0', '150', '0', '0',
        (Format-Number $maxHp),
        (Format-Number $defense),
        (Format-Number $defense),
        (Format-Number $defense),
        (Format-Number $defense),
        (Format-Number $regen '0.00'),
        (Format-Number $defense),
        (Format-Number $defense),
        (Format-Number $fight)
    )
    $keptLines.Add(($row -join "`t"))
}
Write-Utf8 $levelPath (($keptLines -join "`r`n") + "`r`n")

$sceneRelativePath = 'map/map001/DM2_CJ_02.scene'
$scenePath = Join-Path $root 'map\map001\DM2_CJ_02.scene'
$sceneText = Read-Utf8 $scenePath
$airWallIds = @(1428, 1429, 1430, 1431, 1432) + @(1438..1456)
$airWallAlternation = ($airWallIds | ForEach-Object { [regex]::Escape([string]$_) }) -join '|'
$scenePattern = '(?ms)^[\t ]*<GameObject\b(?=[^>]*\bname="(?:' + $airWallAlternation + ')"[^>]*)[^>]*>.*?^[\t ]*</GameObject>\r?\n'
$removedAirWalls = [regex]::Matches($sceneText, $scenePattern).Count
if ($removedAirWalls -notin @(0, 24)) {
    throw "Expected 0 or 24 invisible air-wall objects, found $removedAirWalls."
}
$sceneText = [regex]::Replace($sceneText, $scenePattern, '')
if ($sceneText -match 'obj_resource" value="g2041_kongqiqiang\.mesh"') {
    throw 'Air-wall scene objects remain after patch.'
}
Write-Utf8 $scenePath $sceneText

$colliderSets = @(
    @{ Dir = 'asset\Necessary\mesh\sharenzhecun'; Names = @('g2041_sharen_9_1', 'g2041_sharen_9_3', 'g2041_sharen_9_4', 'g2041_sharen_9_5', 'g2041_sharen_9_6') },
    @{ Dir = 'asset\Necessary\mesh\zhuangshi'; Names = @('g2041_guanzi_01_01', 'g2041_guanzi_01_02', 'g2041_liangchayejiazi_02', 'g2041_liangroujia', 'g2041_liangyijia_01', 'g2041_ludeng_01', 'g2041_muxiangzi_02_02', 'g2041_shuijing_02', 'g2041_shuijing_03') }
)
$removedColliderFiles = New-Object System.Collections.Generic.List[string]
foreach ($set in $colliderSets) {
    foreach ($name in $set.Names) {
        foreach ($extension in '.convex', '.convex.editor') {
            $path = Join-Path (Join-Path $root $set.Dir) ($name + $extension)
            if (Test-Path -LiteralPath $path) {
                Remove-Item -LiteralPath $path -Force
                $removedColliderFiles.Add((Get-RelativePath $path))
            }
        }
    }
}

$checksumsPath = Join-Path $root 'checksums.md5'
$checksumLines = [System.IO.File]::ReadAllLines($checksumsPath, [System.Text.Encoding]::UTF8)
$allConfigsPath = Join-Path $root 'all_configs.lbc'
if (Test-Path -LiteralPath $allConfigsPath) {
    Remove-Item -LiteralPath $allConfigsPath -Force
    $checksumLines = @($checksumLines | Where-Object { $_ -notmatch '^([0-9a-fA-F]{32})\s+\*?all_configs\.lbc$' })
}
$changedPaths = @('setting.json', 'config/boss.csv', 'config/attribute_level.csv', $sceneRelativePath)
foreach ($relativePath in $changedPaths) {
    $fullPath = Join-Path $root ($relativePath.Replace('/', '\'))
    $md5 = (Get-FileHash -LiteralPath $fullPath -Algorithm MD5).Hash.ToLowerInvariant()
    $pattern = '^[0-9a-fA-F]{32}\s+\*?' + [regex]::Escape($relativePath) + '$'
    $matchingIndexes = @()
    for ($i = 0; $i -lt $checksumLines.Length; $i++) {
        if ($checksumLines[$i] -match $pattern) { $matchingIndexes += $i }
    }
    if ($matchingIndexes.Count -gt 1) { throw "Duplicate checksum entries for $relativePath." }
    if ($matchingIndexes.Count -eq 1) {
        $checksumLines[$matchingIndexes[0]] = "$md5 *$relativePath"
    } else {
        $checksumLines += "$md5 *$relativePath"
    }
}
Write-Utf8 $checksumsPath (($checksumLines -join "`r`n") + "`r`n")

Write-Output "Overlay applied to: $root"
Write-Output "Gold exchange maximum: 3000 gCubes (maxBuyMinute=18000)."
Write-Output "Final listed boss: bossId=70; recommendation=500000; computed fight approx 500.21K."
Write-Output 'Player level rows: 91-150 generated.'
Write-Output "Invisible air-wall objects removed: $removedAirWalls."
Write-Output "Local collider files removed: $($removedColliderFiles.Count)."
Write-Output 'Removed stale all_configs.lbc so this overlay uses the runtime CSV/JSON fallback.'
Write-Warning 'For operator/live deployment, confirm raw-config fallback is enabled or regenerate all_configs.lbc with the matching Engine2 compiler.'
