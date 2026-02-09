# --- modules\20-bindings.ps1 ---

# 1. PSReadLine Vi Mode
Set-PSReadLineOption -EditMode Vi

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        Write-Host -NoNewline "$Global:e[1 q"
    } else {
        Write-Host -NoNewline "$Global:e[5 q"
    }
}
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange

# 2. Posh-Git (Tab Completion Only)
if (Get-Module -ListAvailable posh-git) {
    Import-Module posh-git -ErrorAction SilentlyContinue
    $GitPromptSettings = @{ EnablePromptStatus = $false }
}

# 3. Zoxide (Smart CD)
$CacheDir = "$env:LOCALAPPDATA\PowerShell\Cache"
$ZoxideCache = "$CacheDir\zoxide.init.ps1"
if (-not (Test-Path $ZoxideCache) -or ((Get-Item $ZoxideCache).LastWriteTime -lt (Get-Date).AddDays(-1))) {
    if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        Write-Host " [Rebuilding Zoxide Cache...] " -NoNewline -ForegroundColor DarkGray
        (& zoxide init powershell) | Out-File $ZoxideCache -Encoding utf8 -Force
    }
}
if (Test-Path $ZoxideCache) { . $ZoxideCache }

# 4. PSFzf (Fuzzy Finder)
if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        Set-PsFzfOption -PSReadlineHistoryChordProvider 'Ctrl+r'
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
    }
}

# 5. Chocolatey (Lazy Load)
if (Test-Path "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1") {
    function refreshenv {
        Remove-Item Function:\refreshenv -ErrorAction SilentlyContinue
        Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
        & refreshenv
    }
}

# Cleanup
Remove-Variable -Name ChocoProfile, ZoxideCache, CacheDir -ErrorAction SilentlyContinue
