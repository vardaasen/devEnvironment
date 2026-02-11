# provision-fun.ps1
# LAYER 3: OPTIONAL / OPINIONATED TOOLING
# RUN AS ADMIN

[CmdletBinding()]
param( [switch]$Upgrade )

function Test-Command { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ==============================================================================
# 1. RUNTIMES
# ==============================================================================
Write-Host "--- 1. RUNTIMES ---" -ForegroundColor Cyan

$Runtimes = @(
    @{ Cmd = "clang"; Id = "LLVM.LLVM" }
    @{ Cmd = "deno";  Id = "DenoLand.Deno" }
)

foreach ($app in $Runtimes) {
    if (Test-Command $app.Cmd) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($app.Id)..." -ForegroundColor Magenta
            winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host " [OK] $($app.Cmd) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Installing $($app.Id)..." -ForegroundColor Yellow
        winget install $app.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

# PATH refresh for LLVM
foreach ($p in @("$env:ProgramFiles\LLVM\bin", "${env:ProgramFiles(x86)}\LLVM\bin")) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) { $env:PATH = "$p;$env:PATH" }
}

# ==============================================================================
# 2. CONTAINER RUNTIME
# ==============================================================================
Write-Host "--- 2. CONTAINER RUNTIME ---" -ForegroundColor Cyan

$NestedVirt = $true
try {
    $sys = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
    if ($sys.Model -match "Parallels|Virtual|VMware") {
        $NestedVirt = $false
        Write-Host " [Warn] VM detected ($($sys.Model)) — nested virtualization likely unavailable" -ForegroundColor Yellow
        Write-Host "        Remote Docker: DOCKER_HOST=ssh://user@host (recommended)" -ForegroundColor DarkGray
        Write-Host "        macOS host: OrbStack or Colima" -ForegroundColor DarkGray
    }
} catch { Write-Host " [Warn] Could not detect virtualization status" -ForegroundColor Yellow }

if (Test-Command "docker") {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for Docker..." -ForegroundColor Magenta
        winget upgrade Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] docker found." -ForegroundColor DarkGray
    }
} elseif ($NestedVirt) {
    Write-Host " [..] Installing Docker Desktop..." -ForegroundColor Yellow
    winget install Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
} else {
    Write-Host " [Skip] Docker Desktop — no nested virtualization" -ForegroundColor Yellow
    Write-Host "        Set DOCKER_HOST to a remote daemon (never without TLS)" -ForegroundColor Red
}

# ==============================================================================
# 3. AI TOOLING
# ==============================================================================
Write-Host "--- 3. AI TOOLING ---" -ForegroundColor Cyan

# A. Claude Code
if (Test-Command "claude") {
    if ($Upgrade) {
        Write-Host " [Up] Updating claude-code..." -ForegroundColor Magenta
        # Native install self-updates; winget needs manual upgrade
        if (winget list --id Anthropic.ClaudeCode 2>$null | Select-String "Anthropic") {
            winget upgrade Anthropic.ClaudeCode --silent --accept-package-agreements --accept-source-agreements
        } else {
            claude update
        }
    } else {
        Write-Host " [OK] claude-code found." -ForegroundColor DarkGray
    }
} else {
    Write-Host ""
    Write-Host " Claude Code installation method:" -ForegroundColor White
    Write-Host "   [1] Native installer (auto-updates, recommended)" -ForegroundColor Cyan
    Write-Host "   [2] Winget (manual updates, better control)" -ForegroundColor Cyan
    Write-Host "   [3] Skip" -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "   Select (1/2/3)"
    switch ($choice) {
        "1" {
            Write-Host " [..] Installing claude-code (native)..." -ForegroundColor Yellow
            irm https://claude.ai/install.ps1 | iex
        }
        "2" {
            Write-Host " [..] Installing claude-code (winget)..." -ForegroundColor Yellow
            winget install Anthropic.ClaudeCode --silent --accept-package-agreements --accept-source-agreements
        }
        default {
            Write-Host " [Skip] claude-code" -ForegroundColor DarkGray
        }
    }
}

# B. Winget AI tools
$AiWinget = @(
    @{ Cmd = "warp";   Id = "Warp.Warp";    Name = "Warp Terminal" }
    @{ Cmd = "dagger"; Id = "Dagger.Dagger"; Name = "Dagger"; Requires = "docker" }
)

foreach ($app in $AiWinget) {
    if ($app.Requires -and -not (Test-Command $app.Requires)) {
        Write-Host " [Skip] $($app.Name) requires $($app.Requires)" -ForegroundColor Yellow
        continue
    }
    if (Test-Command $app.Cmd) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($app.Name)..." -ForegroundColor Magenta
            winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host " [OK] $($app.Cmd) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Installing $($app.Name)..." -ForegroundColor Yellow
        winget install $app.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

# ==============================================================================
# 4. IDEs AND EDITORS
# ==============================================================================
Write-Host "--- 4. IDEs AND EDITORS ---" -ForegroundColor Cyan

$Editors = @(
    @{ Cmd = "code";   Id = "Microsoft.VisualStudioCode"; Name = "VS Code" }
    @{ Cmd = "cursor"; Id = "Anysphere.Cursor";           Name = "Cursor" }
)

foreach ($app in $Editors) {
    if (Test-Command $app.Cmd) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($app.Name)..." -ForegroundColor Magenta
            winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host " [OK] $($app.Cmd) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Installing $($app.Name)..." -ForegroundColor Yellow
        winget install $app.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

# JetBrains Toolbox (no CLI binary)
$JbInstalled = winget list --id JetBrains.Toolbox 2>$null | Select-String "JetBrains"
if ($JbInstalled) {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for JetBrains Toolbox..." -ForegroundColor Magenta
        winget upgrade JetBrains.Toolbox --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] JetBrains Toolbox found." -ForegroundColor DarkGray
    }
} else {
    Write-Host " [..] Installing JetBrains Toolbox..." -ForegroundColor Yellow
    winget install JetBrains.Toolbox --silent --accept-package-agreements --accept-source-agreements
}
Write-Host "        Recommended: PyCharm, GoLand, Rider, CLion" -ForegroundColor DarkGray

# IDE Extensions reminder
Write-Host ""
Write-Host " [Info] Recommended extensions:" -ForegroundColor DarkGray
Write-Host "        VS Code:  claude-dev (Cline), Continue, GitHub Copilot" -ForegroundColor DarkGray
Write-Host "        Cursor:   Ships with built-in AI (configure API keys in settings)" -ForegroundColor DarkGray
Write-Host "        JetBrains: AI Assistant, GitHub Copilot (via Toolbox plugins)" -ForegroundColor DarkGray

# ==============================================================================
# 5. CARGO CRATES
# ==============================================================================
Write-Host "--- 5. CARGO CRATES ---" -ForegroundColor Cyan

$FunCrates = @(
    @{ Crate = "iamb"; Bin = "iamb" }
)

if (Test-Command "cargo") {
    foreach ($c in $FunCrates) {
        if (Test-Command $c.Bin) {
            if ($Upgrade) {
                Write-Host " [Up] Updating $($c.Crate)..." -ForegroundColor Magenta
                cargo install $c.Crate --locked
            } else {
                Write-Host " [OK] $($c.Bin) found." -ForegroundColor DarkGray
            }
        } else {
            Write-Host " [..] Installing $($c.Crate)..." -ForegroundColor Yellow
            cargo install $c.Crate --locked
        }
    }
} else {
    Write-Host " [Skip] Cargo not found — run platform.ps1 first" -ForegroundColor Yellow
}

# ==============================================================================
# 6. WINGET APPS (Communication & Media)
# ==============================================================================
Write-Host "--- 6. APPS ---" -ForegroundColor Cyan

$FunWinget = @(
    @{ Cmd = "cinny"; Id = "cinnyapp.cinny-desktop"; Name = "Cinny (Matrix)" }
)

foreach ($app in $FunWinget) {
    $installed = winget list --id $app.Id 2>$null | Select-String $app.Id
    if ($installed) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($app.Name)..." -ForegroundColor Magenta
            winget upgrade $app.Id --silent --accept-package-agreements --accept-source-agreements
        } else {
            Write-Host " [OK] $($app.Name) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Installing $($app.Name)..." -ForegroundColor Yellow
        winget install $app.Id --silent --accept-package-agreements --accept-source-agreements
    }
}

# ==============================================================================
# 7. EXTERNAL REPOS
# ==============================================================================
Write-Host "--- 7. EXTERNAL REPOS ---" -ForegroundColor Cyan

$RepoRoot = Split-Path $PSScriptRoot -Parent
$ProjectsDir = Split-Path $RepoRoot -Parent  # Sibling level

$ExternalRepos = @(
    @{
        Name   = "resistance"
        Url    = "https://codeberg.org/vardaasen/resistance.git"
        Path   = "$ProjectsDir\resistance"
    }
)

foreach ($repo in $ExternalRepos) {
    if (Test-Path "$($repo.Path)\.git") {
        if ($Upgrade) {
            Write-Host " [Up] Pulling $($repo.Name)..." -ForegroundColor Magenta
            git -C $repo.Path pull --quiet
        } else {
            Write-Host " [OK] $($repo.Name) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Cloning $($repo.Name) to $($repo.Path)..." -ForegroundColor Yellow
        git clone $repo.Url $repo.Path
    }
}


# ==============================================================================
# 8. MANUAL SETUP
# ==============================================================================
Write-Host "--- 8. MANUAL ---" -ForegroundColor Cyan
Write-Host " [Info] Neoment (Matrix in Neovim):" -ForegroundColor DarkGray
Write-Host "        { 'Massolari/neoment', dependencies = { 'nvim-lua/plenary.nvim' } }" -ForegroundColor DarkGray

Write-Host "`n[DONE] Fun provisioning complete." -ForegroundColor Green
