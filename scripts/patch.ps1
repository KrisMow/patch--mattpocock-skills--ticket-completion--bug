# Apply the ticket-completion patch to the installed mattpocock-skills plugin.
# Usage: .\patch.ps1 [-Check] [-Dir <plugin version dir>]   (safe to re-run after plugin updates)
param([switch]$Check, [string]$Dir)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib.ps1')
$Plugin = Find-PluginDir $Dir
Write-Host "Plugin: $Plugin"
$script:missing = 0
Invoke-Entries {
    param($target, $fragment, $name)
    $f = Join-Path $Plugin $target
    if (-not (Test-Path $f)) { Write-Host "  SKIP    $target (file not found; see prompts/check-patch-needed.md)"; return }
    if (Test-Patched $f $name) { Write-Host "  ok      $target (already patched)"; return }
    if ($Check) { Write-Host "  NEEDS   $target"; $script:missing = 1; return }
    $text = Read-Lf $f
    if ($text -and -not $text.EndsWith("`n")) { $text += "`n" }
    $text += "`n<!-- ${Marker}:$name begin -->`n" + (Read-Lf $fragment) + "<!-- ${Marker}:$name end -->`n"
    [IO.File]::WriteAllText($f, $text, $Utf8)
    Write-Host "  PATCHED $target"
}
exit $script:missing
