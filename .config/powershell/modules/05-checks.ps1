# --- modules\05-checks.ps1 ---

# 1. DETECT ENVIRONMENT & HOST (Live Check)
$Global:PSDisplay = $PSVersionTable.PSVersion.ToString()
if ($PSVersionTable.PSEdition -eq 'Core') { $Global:PSEnv = "Core" } else { $Global:PSEnv = "Desktop" }

$Global:TermHost = switch ($true) {
    ([bool]$env:WT_SESSION)        { "Windows Terminal" }
    ([bool]$env:WEZTERM_EXECUTABLE) { "WezTerm (GPU)" }
    Default                         { "Windows Console Host" }
}

# 2. DETECT FONT (Live Check)
function Get-TerminalFont {
    if ($env:WT_SESSION -or $env:WEZTERM_EXECUTABLE) {
        return "Client Managed"
    }
    $reg = Get-ItemProperty "HKCU:\Console" -Name "FaceName" -ErrorAction SilentlyContinue
    if ($reg.FaceName) { return $reg.FaceName }
    return "System Default"
}
$Global:TermFont = Get-TerminalFont

# 3. CACHE LOGIC (Only for Slow Operations)
$SystemCacheFile = "$env:TEMP\terminal_system_cache.json"
$CacheData = @{ StarshipVer = "Unknown"; PSReadlineVer = "Unknown" }

if (Test-Path $SystemCacheFile -NewerThan (Get-Date).AddDays(-1)) {
    try {
        $LoadedData = Get-Content $SystemCacheFile -Raw | ConvertFrom-Json
        if ($LoadedData.PSObject.Properties.Name -contains "StarshipVer") {
            $CacheData = $LoadedData
        }
    } catch {}
}
else {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        $CacheData.StarshipVer = (starship --version).Split(' ')[1]
    }
    $psr = Get-Module PSReadline
    if (-not $psr) { $psr = Get-Module -ListAvailable PSReadline | Select-Object -First 1 }
    if ($psr) { $CacheData.PSReadlineVer = $psr.Version.ToString() }
    $CacheData | ConvertTo-Json | Set-Content -Path $SystemCacheFile
}

$Global:StarshipVer = $CacheData.StarshipVer
$Global:PSReadlineVer = $CacheData.PSReadlineVer

# 4. DOTNET INFO
function Get-DotNetFrameworkVersion {
    $release = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Release
    if (-not $release) { return '4.5 or earlier' }
    switch ($release) {
        { $_ -ge 533320 } { return '4.8.1' }
        { $_ -ge 528040 } { return '4.8' }
        { $_ -ge 461808 } { return '4.7.2' }
        { $_ -ge 461308 } { return '4.7.1' }
        { $_ -ge 460798 } { return '4.7' }
        { $_ -ge 394802 } { return '4.6.2' }
        { $_ -ge 394254 } { return '4.6.1' }
        { $_ -ge 393295 } { return '4.6' }
        default { return '4.5 or earlier' }
    }
}

function Get-DotNetRuntimeInfo {
    $desc = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
    $clr  = [System.Environment]::Version
    [PSCustomObject]@{ FrameworkDescription = $desc; CLRVersion = $clr }
}

# 5. PRINT DOTNET INFO
$techColor = "DarkYellow"
if ($Global:PSEnv -eq 'Desktop') {
    Write-Host ("PS Desktop (Windows PowerShell)") -ForegroundColor $techColor
    Write-Host (".NET Framework {0}" -f (Get-DotNetFrameworkVersion)) -ForegroundColor $techColor
    if ($PSVersionTable.CLRVersion) {
        Write-Host ("CLR {0}" -f $PSVersionTable.CLRVersion) -ForegroundColor $techColor
    } else {
        Write-Host ("CLR {0}" -f [System.Environment]::Version) -ForegroundColor $techColor
    }
}
elseif ($Global:PSEnv -eq 'Core') {
    Write-Host ("PS Core (PowerShell 6/7+).") -ForegroundColor $techColor
    $info = Get-DotNetRuntimeInfo
    Write-Host ("Runtime {0}" -f $info.FrameworkDescription) -ForegroundColor $techColor
    Write-Host ("CLR {0}" -f $info.CLRVersion) -ForegroundColor $techColor
}
