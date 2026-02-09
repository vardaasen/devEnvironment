# platform.ps1
# LAYER 0: PLATFORM INFRASTRUCTURE
# RUN AS ADMIN

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='Interactive setup')]
[CmdletBinding()]
param()

# Helper Functions
function Test-Command { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
function Install-Font-From-Url {
    param( [string]$Url, [string]$FontFileFilter )
    $TempDir = "$env:TEMP\FontInstall_$(Get-Random)"
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    $ZipFile = "$TempDir\font.zip"
    $Existing = Get-ChildItem "$env:SystemRoot\Fonts" -Filter $FontFileFilter
    if ($Existing) { Write-Host "   [Check] Font $FontFileFilter found." -ForegroundColor DarkGray; return }
    Write-Host "   [Down] Downloading font $FontFileFilter..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $Url -OutFile $ZipFile; Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force
        $Fonts = Get-ChildItem -Path $TempDir -Recurse -Include $FontFileFilter
        foreach ($Font in $Fonts) {
            Copy-Item -Path $Font.FullName -Destination "$env:SystemRoot\Fonts" -Force
            New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $Font.Name -Value $Font.Name -PropertyType String -Force | Out-Null
        }
    } catch { Write-Error "Font Install Failed: $_" } finally { Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host "--- LAYER 0: PLATFORM SETUP ---" -ForegroundColor Magenta

# 1. PACKAGE MANAGERS (System)
Write-Host "--- 1. SYSTEM PACKAGE MANAGERS ---" -ForegroundColor Cyan

if (-not (Test-Command "choco")) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else { Write-Host " [OK] Chocolatey detected." -ForegroundColor DarkGray; choco upgrade chocolatey -y }

if (-not (Test-Command "winget")) { Write-Warning "Winget missing! (Requires App Installer)" } else { Write-Host " [OK] Winget detected." -ForegroundColor DarkGray }

# 2. RUST TOOLCHAIN (Cargo Infrastructure)
Write-Host "--- 2. RUST TOOLCHAIN ---" -ForegroundColor Cyan
if (Test-Command "cargo") {
    Write-Host " [OK] Rust detected. Updating toolchain..." -ForegroundColor DarkGray
    rustup update
} else {
    Write-Host "Installing Rustup..." -ForegroundColor Yellow
    $rustupUrl = "https://win.rustup.rs/x86_64"
    Invoke-WebRequest $rustupUrl -OutFile "$env:TEMP\rustup-init.exe"
    Start-Process -FilePath "$env:TEMP\rustup-init.exe" -ArgumentList "-y --default-host x86_64-pc-windows-msvc" -Wait
    $env:Path += ";$env:USERPROFILE\.cargo\bin"
}

# 3. CORE RUNTIMES
Write-Host "--- 3. CORE RUNTIMES ---" -ForegroundColor Cyan

if (-not (Test-Command "pwsh")) {
    Write-Host "Installing PowerShell Core..." -ForegroundColor Yellow; winget install Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
} else {
    Write-Host " [Up] PowerShell Core..." -ForegroundColor DarkGray; winget upgrade Microsoft.PowerShell --silent --accept-package-agreements --accept-source-agreements
}

if (-not (Test-Command "git")) {
    Write-Host "Installing Git (Interactive)..." -ForegroundColor Yellow; winget install Git.Git --interactive
} else {
    Write-Host " [Up] Git..." -ForegroundColor DarkGray; winget upgrade Git.Git --silent --accept-package-agreements --accept-source-agreements
}

# 4. FONTS
Write-Host "--- 4. FONTS ---" -ForegroundColor Cyan
Install-Font-From-Url -Url "https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip" -FontFileFilter "iAWriterDuoV.ttf"
Install-Font-From-Url -Url "https://github.com/githubnext/monaspace/releases/download/v1.101/monaspace-v1.101.zip" -FontFileFilter "MonaspaceRadonVar-*.ttf"

Write-Host "`n[DONE] Platform Ready." -ForegroundColor Green
