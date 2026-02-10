# provision-fun.ps1
# LAYER 3: OPTIONAL / OPINIONATED TOOLING
# RUN AS ADMIN

[CmdletBinding()]
param( [switch]$Upgrade )

function Test-Command { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ==============================================================================
# 1. LLVM / CLANG (Freenet, C/C++ tooling)
# ==============================================================================
Write-Host "--- 1. LLVM / CLANG ---" -ForegroundColor Cyan

if (Test-Command "clang") {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for LLVM..." -ForegroundColor Magenta
        winget upgrade LLVM.LLVM --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] clang found." -ForegroundColor DarkGray
    }
} else {
    Write-Host " [..] Installing LLVM..." -ForegroundColor Yellow
    winget install LLVM.LLVM --silent --accept-package-agreements --accept-source-agreements
}

# ==============================================================================
# 2. MATRIX CLIENTS
# ==============================================================================
Write-Host "--- 2. MATRIX CLIENTS ---" -ForegroundColor Cyan

# A. iamb (Terminal Matrix client with Vim keybindings, Rust)
if (Test-Command "iamb") {
    if ($Upgrade) {
        Write-Host " [Up] Updating iamb..." -ForegroundColor Magenta
        cargo install iamb --locked
    } else {
        Write-Host " [OK] iamb found." -ForegroundColor DarkGray
    }
} else {
    Write-Host " [..] Installing iamb via Cargo..." -ForegroundColor Yellow
    cargo install iamb --locked
}

# B. Cinny (Desktop Matrix client)
$CinnyInstalled = winget list --id niceredink.Cinny 2>$null | Select-String "Cinny"
if ($CinnyInstalled) {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for Cinny..." -ForegroundColor Magenta
        winget upgrade niceredink.Cinny --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] Cinny found." -ForegroundColor DarkGray
    }
} else {
    Write-Host " [..] Installing Cinny..." -ForegroundColor Yellow
    winget install niceredink.Cinny --silent --accept-package-agreements --accept-source-agreements
}

# C. Neoment (Neovim plugin — manual setup required)
Write-Host " [Info] Neoment: Install via Neovim plugin manager" -ForegroundColor DarkGray
Write-Host "        Add to init.lua: { 'Massolari/neoment', dependencies = { 'nvim-lua/plenary.nvim' } }" -ForegroundColor DarkGray

# ==============================================================================
# 3. IDEs AND EDITORS (Opinionated)
# ==============================================================================
Write-Host "--- 3. IDEs AND EDITORS ---" -ForegroundColor Cyan

$IdeApps = @(
    @{ Cmd = ""; Id = "JetBrains.Toolbox";             Name = "JetBrains Toolbox" }
    @{ Cmd = "code"; Id = "Microsoft.VisualStudioCode"; Name = "VS Code" }
    @{ Cmd = "cursor"; Id = "Anysphere.Cursor";         Name = "Cursor" }
)

foreach ($app in $IdeApps) {
    if ($app.Cmd -and (Test-Command $app.Cmd)) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($app.Name)..." -ForegroundColor Magenta
            winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host " [OK] $($app.Name) found." -ForegroundColor DarkGray
        }
    } else {
        # JetBrains Toolbox has no CLI — check via winget list
        if (-not $app.Cmd) {
            $installed = winget list --id $app.Id 2>$null | Select-String $app.Id
            if ($installed) {
                if ($Upgrade) {
                    Write-Host " [Up] Checking update for $($app.Name)..." -ForegroundColor Magenta
                    winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
                } else {
                    Write-Host " [OK] $($app.Name) found." -ForegroundColor DarkGray
                }
                continue
            }
        }
        Write-Host " [..] Installing $($app.Name)..." -ForegroundColor Yellow
        winget install $app.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

Write-Host ""
Write-Host " [Recommended] JetBrains IDEs (install via Toolbox):" -ForegroundColor DarkGray
Write-Host "   - PyCharm (Python)" -ForegroundColor DarkGray
Write-Host "   - GoLand (Go)" -ForegroundColor DarkGray
Write-Host "   - Rider (.NET / C#)" -ForegroundColor DarkGray
Write-Host "   - CLion (C/C++)" -ForegroundColor DarkGray

# ==============================================================================
# 4. MUSIC (Terminal-based player)
# ==============================================================================
Write-Host "--- 4. MUSIC ---" -ForegroundColor Cyan
Write-Host " [Info] Terminal music player: https://codeberg.org/vardaasen/resistance" -ForegroundColor DarkGray
Write-Host "        Clone and follow setup instructions in that repo." -ForegroundColor DarkGray

Write-Host "`n[DONE] Fun provisioning complete." -ForegroundColor Green
