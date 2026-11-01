[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $GameRoot).Path
$failures = New-Object System.Collections.Generic.List[string]

$setting = Get-Content -LiteralPath (Join-Path $root 'setting.json') -Raw | ConvertFrom-Json
if ([int]$setting.buyGoldPrice.maxBuyMinute -ne 18000) {
    $failures.Add('setting.json buyGoldPrice.maxBuyMinute is not 18000.')
}

$bossRows = @(Import-Csv -LiteralPath (Join-Path $root 'config\boss.csv') -Delimiter "`t" |
    Where-Object { $_.bossId -eq '70' })
if ($bossRows.Count -ne 1) {
    $failures.Add("Expected one bossId=70 row; found $($bossRows.Count).")
} else {
    $boss = $bossRows[0]
    if ([int]$boss.recommend -ne 500000 -or [int]$boss.maxHp -ne 155279 -or
        [int]$boss.attDamage -ne 264 -or [int]$boss.attFire -ne 264 -or
        [int]$boss.attPoison -ne 264 -or [int]$boss.attIce -ne 264) {
        $failures.Add('bossId=70 recommendation or core attributes do not match the overlay.')
    }
}

$levelRows = Import-Csv -LiteralPath (Join-Path $root 'config\attribute_level.csv') -Delimiter "`t" |
    Where-Object { $_.level -match '^\d+$' }
$levels = @($levelRows | ForEach-Object { [int]$_.level })
$duplicateLevels = @($levels | Group-Object | Where-Object Count -gt 1)
if ($levels.Count -ne 150 -or ($levels | Measure-Object -Minimum).Minimum -ne 1 -or ($levels | Measure-Object -Maximum).Maximum -ne 150) {
    $failures.Add("Expected exactly levels 1-150; found $($levels.Count) numeric rows.")
}
if ($duplicateLevels.Count -gt 0) {
    $failures.Add('attribute_level.csv contains duplicate level values.')
}
$level150 = $levelRows | Where-Object { $_.level -eq '150' } | Select-Object -First 1
if (-not $level150 -or [int]$level150.fight -ne 260490) {
    $failures.Add('Level 150 row is missing or its fight value differs from the overlay curve.')
}

$scene = Get-Content -LiteralPath (Join-Path $root 'map\map001\DM2_CJ_02.scene') -Raw
if ($scene -match 'obj_resource" value="g2041_kongqiqiang\.mesh"') {
    $failures.Add('Invisible kongqiqiang scene objects remain in map001.')
}

foreach ($name in 'g2041_sharen_9_1','g2041_sharen_9_3','g2041_sharen_9_4','g2041_sharen_9_5','g2041_sharen_9_6') {
    foreach ($extension in '.convex','.convex.editor') {
        $path = Join-Path (Join-Path $root 'asset\Necessary\mesh\sharenzhecun') ($name + $extension)
        if (Test-Path -LiteralPath $path) {
            $failures.Add("Local-added collider remains: $name$extension")
        }
    }
}

$checksumPath = Join-Path $root 'checksums.md5'
$checksumLines = [System.IO.File]::ReadAllLines($checksumPath, [System.Text.Encoding]::UTF8)
if (Test-Path -LiteralPath (Join-Path $root 'all_configs.lbc')) {
    $failures.Add('Stale all_configs.lbc is present and would override the patched CSV/JSON values.')
}
foreach ($relativePath in 'setting.json','config/boss.csv','config/attribute_level.csv','map/map001/DM2_CJ_02.scene') {
    $fullPath = Join-Path $root ($relativePath.Replace('/','\'))
    $expected = (Get-FileHash -LiteralPath $fullPath -Algorithm MD5).Hash.ToLowerInvariant()
    $match = $checksumLines | Where-Object { $_ -match ('^([0-9a-fA-F]{32})\s+\*?' + [regex]::Escape($relativePath) + '$') } | Select-Object -First 1
    if (-not $match -or $match.Substring(0,32).ToLowerInvariant() -ne $expected) {
        $failures.Add("checksums.md5 is stale for $relativePath")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "Overlay validation failed with $($failures.Count) issue(s)."
}

Write-Output "Overlay validation passed: $root"
Write-Output 'Verified: 3000-gCube gold exchange cap, bossId 70 tuning, levels 1-150, open-navigation scene, and updated file hashes.'
Write-Output 'Verified: stale all_configs.lbc removed; runtime CSV/JSON fallback will be used.'
Write-Warning 'For operator/live deployment, confirm raw-config fallback is enabled or regenerate all_configs.lbc with the matching Engine2 compiler.'
