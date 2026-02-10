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
# 2. CONTAINER RUNTIME
# ==============================================================================
Write-Host "--- 2. CONTAINER RUNTIME ---" -ForegroundColor Cyan

# Detect nested virtualization capability
$NestedVirt = $false
try {
    $hyperv = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
    if ($hyperv.HypervisorPresent) {
        # Check if we're in a VM (Parallels, Hyper-V, etc.)
        $model = $hyperv.Model
        if ($model -match "Parallels|Virtual|VMware") {
            Write-Host " [Warn] Running inside VM ($model) — nested virtualization may be unavailable" -ForegroundColor Yellow
            Write-Host "        Consider remote Docker: set DOCKER_HOST=tcp://<host>:2375" -ForegroundColor Yellow
            Write-Host "        Or use SSH tunnel: DOCKER_HOST=ssh://user@host" -ForegroundColor Yellow
            Write-Host "        macOS host: OrbStack (recommended) or Colima" -ForegroundColor Yellow
        } else {
            $NestedVirt = $true
        }
    } else {
        $NestedVirt = $true
    }
} catch {
    Write-Host " [Warn] Could not detect virtualization status" -ForegroundColor Yellow
}

# Docker Desktop (only if nested virt is available or native)
if (Test-Command "docker") {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for Docker Desktop..." -ForegroundColor Magenta
        winget upgrade Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] Docker found." -ForegroundColor DarkGray
    }
} elseif ($NestedVirt) {
    Write-Host " [..] Installing Docker Desktop..." -ForegroundColor Yellow
    Write-Host "      License: Free for personal use and small business (<250 employees, <$10M)" -ForegroundColor DarkGray
    winget install Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
} else {
    Write-Host " [Skip] Docker Desktop skipped (no nested virtualization)" -ForegroundColor Yellow
    Write-Host "        Configure DOCKER_HOST to point to a remote Docker daemon" -ForegroundColor Yellow
    Write-Host "        Options for remote host:" -ForegroundColor DarkGray
    Write-Host "          macOS: OrbStack, Colima, Lima, Docker Desktop" -ForegroundColor DarkGray
    Write-Host "          Linux: Docker Engine, Podman" -ForegroundColor DarkGray
    Write-Host "          VPS:   Docker Engine over SSH" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "        Secure connection (never expose Docker socket without TLS):" -ForegroundColor Red
    Write-Host "          DOCKER_HOST=ssh://user@host        (recommended)" -ForegroundColor DarkGray
    Write-Host "          DOCKER_HOST=tcp://host:2376 + TLS  (advanced)" -ForegroundColor DarkGray
}

# ==============================================================================
# 3. AI TOOLING
# ==============================================================================
Write-Host "--- 3. AI TOOLING ---" -ForegroundColor Cyan

# A. Claude Code (requires Node.js 18+)
if (Test-Command "claude") {
    if ($Upgrade) {
        Write-Host " [Up] Updating claude-code..." -ForegroundColor Magenta
        npm update -g @anthropic-ai/claude-code
    } else {
        Write-Host " [OK] claude-code found." -ForegroundColor DarkGray
    }
} else {
    if (Test-Command "node") {
        $nodeVer = (node --version) -replace 'v',''
        if ([version]$nodeVer -ge [version]"18.0.0") {
            Write-Host " [..] Installing claude-code..." -ForegroundColor Yellow
            npm install -g @anthropic-ai/claude-code
        } else {
            Write-Host " [Skip] claude-code requires Node.js 18+ (found $nodeVer)" -ForegroundColor Yellow
        }
    } else {
        Write-Host " [Skip] claude-code requires Node.js — install via:" -ForegroundColor Yellow
        Write-Host "        winget install OpenJS.NodeJS.LTS" -ForegroundColor DarkGray
    }
}

# B. Warp Terminal (MCP-native terminal)
$WarpInstalled = winget list --id dev.warp.Warp 2>$null | Select-String "Warp"
if ($WarpInstalled) {
    if ($Upgrade) {
        Write-Host " [Up] Checking update for Warp..." -ForegroundColor Magenta
        winget upgrade dev.warp.Warp --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] Warp found." -ForegroundColor DarkGray
    }
} else {
    Write-Host " [..] Installing Warp Terminal..." -ForegroundColor Yellow
    winget install dev.warp.Warp --silent --accept-package-agreements --accept-source-agreements
}

# C. Dagger (CI/CD engine, requires Docker)
if (Test-Command "dagger") {
    if ($Upgrade) {
        Write-Host " [Up] Updating Dagger..." -ForegroundColor Magenta
        winget upgrade Dagger.Dagger --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [OK] Dagger found." -ForegroundColor DarkGray
    }
} else {
    if (Test-Command "docker") {
        Write-Host " [..] Installing Dagger..." -ForegroundColor Yellow
        winget install Dagger.Dagger --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host " [Skip] Dagger requires Docker — install Docker first" -ForegroundColor Yellow
    }
}

# ==============================================================================
# 4. IDEs AND EDITORS (Opinionated)
# ==============================================================================
Write-Host "--- 4. IDEs AND EDITORS ---" -ForegroundColor Cyan

$IdeApps = @(
    @{ Cmd = "";       Id = "JetBrains.Toolbox";              Name = "JetBrains Toolbox" }
    @{ Cmd = "code";   Id = "Microsoft.VisualStudioCode";     Name = "VS Code" }
    @{ Cmd = "cursor"; Id = "Anysphere.Cursor";               Name = "Cursor" }
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
# 5. MATRIX CLIENTS
# ==============================================================================
Write-Host "--- 5. MATRIX CLIENTS ---" -ForegroundColor Cyan

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
# 6. MUSIC (Terminal-based player)
# ==============================================================================
Write-Host "--- 6. MUSIC ---" -ForegroundColor Cyan
Write-Host " [Info] Terminal music player: https://codeberg.org/vardaasen/resistance" -ForegroundColor DarkGray
Write-Host "        Clone and follow setup instructions in that repo." -ForegroundColor DarkGray

Write-Host "`n[DONE] Fun provisioning complete." -ForegroundColor Green
