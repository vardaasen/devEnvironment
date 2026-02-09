# provision.ps1
# LAYER 2: USER TOOLING
# RUN AS ADMIN

[CmdletBinding()]
param( [switch]$Upgrade )

function Test-Command { param([string]$Name) return [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ==============================================================================
# 1. CARGO CRATES (User Tools)
# ==============================================================================
Write-Host "--- 1. CARGO TOOLS ---" -ForegroundColor Cyan

if (-not (Test-Command "cargo")) {
    Write-Error "Cargo not found! Please run platform.ps1 first."
} else {
    $CargoCrates = @("eza", "jj-cli", "macchina", "uv", "ripgrep", "fd-find")
    foreach ($crate in $CargoCrates) {
        $BinaryName = switch ($crate) { "jj-cli" { "jj" }; "fd-find" { "fd" }; default { $crate } }

        if (Test-Command $BinaryName) {
            if ($Upgrade) {
                Write-Host " [Up] Updating $crate..." -ForegroundColor Magenta
                cargo install $crate --locked
            } else {
                Write-Host " [OK] $BinaryName found." -ForegroundColor DarkGray
            }
        } else {
            Write-Host "Installing $crate via Cargo..." -ForegroundColor Yellow
            cargo install $crate --locked
        }
    }
}

# ==============================================================================
# 2. WINGET APPS
# ==============================================================================
Write-Host "--- 2. WINGET APPS ---" -ForegroundColor Cyan
$WingetApps = @(
    @{ Cmd = "wt";         Id = "Microsoft.WindowsTerminal" }
    @{ Cmd = "go";         Id = "GoLang.Go" }
    @{ Cmd = "7z";         Id = "7zip.7zip" }
    @{ Cmd = "wezterm";    Id = "wez.wezterm" }
    @{ Cmd = "starship";   Id = "Starship.Starship" }
    @{ Cmd = "fastfetch";  Id = "Fastfetch-cli.Fastfetch" }
    @{ Cmd = "clink";      Id = "chrisant996.Clink" }
    @{ Cmd = "nvim";       Id = "Neovim.Neovim" }
    @{ Cmd = "cmake";      Id = "Kitware.CMake" }
    @{ Cmd = "ninja";      Id = "Ninja-build.Ninja" }
)

foreach ($app in $WingetApps) {
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

# ==============================================================================
# 3. CHOCOLATEY TOOLS
# ==============================================================================
Write-Host "--- 3. CHOCO TOOLS ---" -ForegroundColor Cyan
$ChocoTools = @(
    @{ Cmd = "make";  Pkg = "make" }
    @{ Cmd = "gcc";   Pkg = "mingw" }
    @{ Cmd = "wget";  Pkg = "wget" }
    @{ Cmd = "unzip"; Pkg = "unzip" }
    @{ Cmd = "gzip";  Pkg = "gzip" }
)

foreach ($tool in $ChocoTools) {
    if (Test-Command $tool.Cmd) {
        if ($Upgrade) {
            Write-Host " [Up] Checking update for $($tool.Pkg)..." -ForegroundColor Magenta
            choco upgrade $tool.Pkg -y
        } else {
            Write-Host " [OK] $($tool.Cmd) found." -ForegroundColor DarkGray
        }
    } else {
        Write-Host " [..] Installing $($tool.Pkg)..." -ForegroundColor Yellow
        choco install $tool.Pkg -y
    }
}

Write-Host "`n[DONE] Provisioning complete." -ForegroundColor Green
