# setup.ps1
# RUN AS ADMIN

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='Interactive setup script needs colored output')]
[CmdletBinding()]
param()

$RepoRoot = Split-Path $PSScriptRoot -Parent
$GlobalConfig = "$env:USERPROFILE\.config"

# --- 1. LINK .CONFIG FOLDERS ---
if (-not (Test-Path $GlobalConfig)) { New-Item -ItemType Directory -Path $GlobalConfig | Out-Null }

$FoldersToLink = Get-ChildItem -Path "$RepoRoot\.config" -Directory
foreach ($folder in $FoldersToLink) {
    if ($folder.Name -match "^(clink)$") { continue }

    $DestPath = "$GlobalConfig\$($folder.Name)"

    if (Test-Path $DestPath) {
        if ((Get-Item $DestPath).LinkType -match "SymbolicLink|Junction") {
            if ((Get-Item $DestPath).Target -eq $folder.FullName) { continue }
        }
        Rename-Item -Path $DestPath -NewName "$($folder.Name).bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
    }

    New-Item -ItemType SymbolicLink -Path $DestPath -Target $folder.FullName | Out-Null
    Write-Host " [Link] $($folder.Name) -> .config\$($folder.Name)" -ForegroundColor Cyan
}

# --- 2. SPECIALTY LINKS ---

# A. CLINK (Local Container, Linked Content)
$ClinkLocal = "$GlobalConfig\clink"
$ClinkRepo  = "$RepoRoot\.config\clink"

if (-not (Test-Path $ClinkLocal)) { New-Item -ItemType Directory -Path $ClinkLocal -Force | Out-Null }

if (Test-Path "$ClinkRepo\clink_settings") {
    $Target = "$ClinkLocal\clink_settings"
    if (-not (Test-Path $Target)) {
        New-Item -ItemType HardLink -Path $Target -Target "$ClinkRepo\clink_settings" | Out-Null
        Write-Host " [Link] Clink Settings (HardLink)" -ForegroundColor Cyan
    }
}
if (Test-Path "$ClinkRepo\scripts") {
    $Target = "$ClinkLocal\scripts"
    if (-not (Test-Path $Target)) {
        New-Item -ItemType Junction -Path $Target -Target "$ClinkRepo\scripts" | Out-Null
        Write-Host " [Link] Clink Scripts (Junction)" -ForegroundColor Cyan
    }
}

# --- 3. POWERSHELL SHIM ---
$MasterProfile = "$GlobalConfig\PowerShell\Microsoft.PowerShell_profile.ps1"
$StandardPaths = @(
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)
foreach ($path in $StandardPaths) {
    if (-not (Test-Path (Split-Path $path))) { New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null }
    if (Test-Path $path) { if ((Get-Content $path -Raw) -like "*$MasterProfile*") { continue } }
    Set-Content -Path $path -Value ". `"$MasterProfile`""
    Write-Host " [Shim] PowerShell Profile linked." -ForegroundColor Cyan
}

# --- 4. CMD AUTORUN ---
$RegPath = "HKCU:\Software\Microsoft\Command Processor"
$TargetCmd = "$GlobalConfig\cmd\cmd.bat"
if (Test-Path $TargetCmd) {
    Set-ItemProperty -Path $RegPath -Name "AutoRun" -Value $TargetCmd
    Write-Host " [CMD] AutoRun registry key set." -ForegroundColor Cyan
}

# --- 5. WINDOWS TERMINAL CONFIG ---
Write-Host "`n--- WINDOWS TERMINAL ---" -ForegroundColor Cyan
$TerminalSource = "$RepoRoot\.config\terminal\settings.json"
$TerminalTargets = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)

if (Test-Path $TerminalSource) {
    foreach ($dest in $TerminalTargets) {
        if (Test-Path (Split-Path $dest)) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c mklink `"$dest`" `"$TerminalSource`"" -NoNewWindow -Wait
            Write-Host " [Link] WT Settings -> $(Split-Path $dest -Leaf)" -ForegroundColor Cyan
        }
    }
}
