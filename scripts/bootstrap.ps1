# bootstrap.ps1
# RUN AS ADMIN FROM INSIDE THE REPO
# Purpose: Hydrate the local system using the files already present in this folder.

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification='Interactive setup')]
[CmdletBinding()]
param()

$RepoRoot = $PSScriptRoot

# --- 1. PREREQ: PRIVILEGE ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges required to create Symlinks and install packages."
    Write-Warning "Please right-click and 'Run as Administrator'."
    Break
}

# --- 2. PREREQ: SANITY CHECK ---
if (-not (Test-Path "$RepoRoot\setup.ps1")) {
    Write-Error "Critical: setup.ps1 not found in $RepoRoot."
    Write-Error "Please run this script from the root of your dotfiles repository."
    Break
}

# --- 3. ENVIRONMENT: ENFORCE XDG ---
$XdgPath = "$env:USERPROFILE\.config"
if ([System.Environment]::GetEnvironmentVariable('XDG_CONFIG_HOME', 'User') -ne $XdgPath) {
    Write-Host " [Env] Setting XDG_CONFIG_HOME to $XdgPath..." -ForegroundColor Yellow
    [System.Environment]::SetEnvironmentVariable('XDG_CONFIG_HOME', $XdgPath, 'User')
    $env:XDG_CONFIG_HOME = $XdgPath
}

# --- 4. EXECUTION: PHASE 1 (Configuration) ---
Write-Host "`n--- PHASE 1: CONFIGURATION (Linking) ---" -ForegroundColor Green
try {
    Set-Location $RepoRoot
    .\setup.ps1 -ErrorAction Stop
} catch {
    Write-Error "Setup Phase Failed: $_"
    Break
}

# --- 5. EXECUTION: PHASE 2 (Provisioning) ---
Write-Host "`n--- PHASE 2: PROVISIONING (Tooling) ---" -ForegroundColor Green
try {
    .\provision.ps1 -ErrorAction Stop
} catch {
    Write-Error "Provisioning Phase Failed: $_"
    # We don't break here, because partial tooling is better than no tooling.
}

Write-Host "`n[SUCCESS] System Hydration Complete." -ForegroundColor Green
