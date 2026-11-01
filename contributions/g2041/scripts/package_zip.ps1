[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GameRoot,

    [Parameter(Mandatory = $true)]
    [string]$OutputZip,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path -LiteralPath $GameRoot).Path.TrimEnd('\')
$output = [System.IO.Path]::GetFullPath($OutputZip)
$parent = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $parent)) {
    throw "Output directory does not exist: $parent"
}
if ((Test-Path -LiteralPath $output) -and -not $Force) {
    throw "Output already exists; pass -Force to replace it: $output"
}

$temporary = $output + '.tmp'
if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }

$stream = [System.IO.File]::Open($temporary, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
$archive = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $directories = Get-ChildItem -LiteralPath $root -Recurse -Directory | Sort-Object FullName
    foreach ($directory in $directories) {
        $relative = $directory.FullName.Substring($root.Length).TrimStart('\').Replace('\','/') + '/'
        [void]$archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
    }

    $files = Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName
    foreach ($file in $files) {
        $relative = $file.FullName.Substring($root.Length).TrimStart('\').Replace('\','/')
        $entry = $archive.CreateEntry($relative, [System.IO.Compression.CompressionLevel]::Optimal)
        $destination = $entry.Open()
        $source = [System.IO.File]::OpenRead($file.FullName)
        try { $source.CopyTo($destination) }
        finally { $source.Dispose(); $destination.Dispose() }
    }
}
finally {
    $archive.Dispose()
    $stream.Dispose()
}

$check = [System.IO.Compression.ZipFile]::OpenRead($temporary)
try {
    $entries = @($check.Entries)
    if (-not ($entries | Where-Object FullName -eq 'setting.json')) {
        throw 'ZIP does not contain setting.json at its package root.'
    }
    if ($entries | Where-Object { $_.FullName.Contains('\') }) {
        throw 'ZIP contains backslash-separated entries; expected forward slashes.'
    }
    if (($entries | Group-Object FullName | Where-Object Count -gt 1).Count -gt 0) {
        throw 'ZIP contains duplicate paths.'
    }
    "Validated entries: $($entries.Count)"
}
finally { $check.Dispose() }

if (Test-Path -LiteralPath $output) {
    $backup = $output + '.bak'
    if (Test-Path -LiteralPath $backup) {
        $backup = $output + '.' + (Get-Date -Format 'yyyyMMddHHmmss') + '.bak'
    }
    Move-Item -LiteralPath $output -Destination $backup
    Write-Output "Previous ZIP backed up to: $backup"
}
Move-Item -LiteralPath $temporary -Destination $output
Write-Output "Package written: $output"
