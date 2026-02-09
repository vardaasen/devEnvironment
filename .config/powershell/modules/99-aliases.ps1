# --- modules\99-aliases.ps1 ---

# 1. iA Writer Shortcut (Personal, paid)
function ia { & 'C:\Program Files\iA Writer\iAWriter.exe' $args }

# 2. Generic Note Editor (Graceful Degradation)
function note {
    $editors = @(
        @{ Cmd = 'obsidian'; Path = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe" }
        @{ Cmd = 'code';     Path = $null }
        @{ Cmd = 'notepad';  Path = 'notepad.exe' }
    )
    foreach ($ed in $editors) {
        if (Get-Command $ed.Cmd -ErrorAction SilentlyContinue) {
            & $ed.Cmd $args; return
        }
    }
}

# 3. Dynamic Visual Studio DevShell
function Enter-DevShell {
    $startTime = Get-Date

    $vsPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
        -latest -products * `
        -requires Microsoft.VisualStudio.Component.Roslyn.Compiler `
        -property installationPath

    if (-not $vsPath) {
        Write-Error "Visual Studio installation not found via vswhere."
        return
    }

    $dllPath = Join-Path $vsPath "Common7\Tools\Microsoft.VisualStudio.DevShell.dll"

    if (Test-Path $dllPath) {
        Import-Module $dllPath
        Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation

        $elapsed = ((Get-Date) - $startTime).TotalMilliseconds
        Write-Host "VS Dev Environment loaded in $($elapsed.ToString('N0')) ms." -ForegroundColor Green
    } else {
        Write-Error "DevShell DLL not found at: $dllPath"
    }
}
Set-Alias -Name vs -Value Enter-DevShell

# 4. Smart Choco Wrapper (Admin Protection)
function choco {
    $command = $args[0]
    $AdminActions = @('install', 'upgrade', 'uninstall', 'enable', 'disable')

    if ($command -in $AdminActions) {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $isAdmin) {
            Write-Host "[BLOCK] 'choco $command' requires Administrator privileges." -ForegroundColor Red
            Write-Host "Please start a new terminal as Admin (Run as Administrator)." -ForegroundColor DarkGray
            return
        }
    }

    & choco.exe @args

    if ($command -in $AdminActions) {
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n[Auto-Refreshing Environment...]" -ForegroundColor DarkGray
            refreshenv
        }
    }
}
