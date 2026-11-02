# Shared PowerShell helpers for patch.ps1 / unpatch.ps1 (Windows; also works in pwsh on Linux/macOS). Dot-sourced.
$Root = Split-Path -Parent $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-Cfg([string]$Key) {
    (Get-Content (Join-Path $Root 'common/config.env') | Where-Object { $_ -like "$Key=*" } | Select-Object -First 1) -replace "^$Key=", ''
}
$Marker = Get-Cfg 'MARKER_PREFIX'

# Plugin version dir to patch: -Dir > env override > newest installed version.
function Find-PluginDir([string]$Dir) {
    if (-not $Dir) { $Dir = [Environment]::GetEnvironmentVariable((Get-Cfg 'OVERRIDE_ENV')) }
    if (-not $Dir) {
        $base = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
        $Dir = Get-ChildItem (Join-Path $base (Get-Cfg 'PLUGIN_CACHE_GLOB')) -Directory -ErrorAction SilentlyContinue |
            Sort-Object { try { [version]($_.Name -replace '[^\d.].*$', '') } catch { [version]'0.0' } } |
            Select-Object -Last 1 -ExpandProperty FullName
    }
    if (-not $Dir -or -not (Test-Path (Join-Path $Dir 'skills'))) { throw 'mattpocock-skills not found (pass -Dir <version dir>)' }
    $Dir
}

# Invoke $Action with (target, fragment path, fragment name) for each manifest entry.
function Invoke-Entries([scriptblock]$Action) {
    foreach ($line in Get-Content (Join-Path $Root 'common/manifest.txt')) {
        if (-not $line.Trim() -or $line.StartsWith('#')) { continue }
        $target, $frag = $line -split '\|', 2
        & $Action $target (Join-Path $Root "common/fragments/$frag") ($frag -replace '\.md$', '')
    }
}

function Test-Patched([string]$File, [string]$Name) { (Get-Content $File -Raw).Contains("<!-- ${Marker}:$Name begin -->") }

function Read-Lf([string]$File) { [IO.File]::ReadAllText($File) -replace "`r`n", "`n" }

function Remove-Block([string]$File, [string]$Name) {
    $b = [regex]::Escape("<!-- ${Marker}:$Name begin -->"); $e = [regex]::Escape("<!-- ${Marker}:$Name end -->")
    $text = (Read-Lf $File) -replace "(?s)\n?$b\n.*?$e\n?", ''
    [IO.File]::WriteAllText($File, $text, $Utf8)
}
