# --- Microsoft.PowerShell_profile.ps1 ---
$Script:StartTime = Get-Date
$Global:ModulePerformance = [Ordered]@{}

$ConfigDir = Join-Path $PSScriptRoot "modules"

if (Test-Path $ConfigDir) {
    Get-ChildItem -Path $ConfigDir -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
        $stepStart = Get-Date

        . $_.FullName

        $duration = ((Get-Date) - $stepStart).TotalMilliseconds
        $Global:ModulePerformance[$_.Name] = "{0:N0} ms" -f $duration
    }
}

Remove-Variable -Name stepStart, duration, ConfigDir -ErrorAction SilentlyContinue
