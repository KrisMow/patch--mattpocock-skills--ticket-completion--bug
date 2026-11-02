# Remove every block added by patch.ps1, restoring the original skill text.
# Usage: .\unpatch.ps1 [-Dir <plugin version dir>]
param([string]$Dir)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')
$Plugin = Find-PluginDir $Dir
Write-Host "Plugin: $Plugin"
Invoke-Entries {
    param($target, $fragment, $name)
    $f = Join-Path $Plugin $target
    if ((Test-Path $f) -and (Test-Patched $f $name)) { Remove-Block $f $name; Write-Host "  REVERTED $target" }
    else { Write-Host "  ok       $target (not patched)" }
}
