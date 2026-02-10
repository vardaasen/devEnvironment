# devEnvironment

Windows dotfiles and development environment bootstrapper. Opinionated setup for PowerShell, CMD, WezTerm, and Windows Terminal with a layered provisioning system.

## Architecture
```
Layer 0: platform.ps1    → Package managers, Rust toolchain, runtimes, fonts
Layer 1: setup.ps1       → Symlinks, registry keys, profile shims
Layer 2: provision.ps1   → User tools via Cargo, Winget, Chocolatey
         bootstrap.ps1   → Orchestrator (runs all layers in order)
```

## Quick Start

### Prerequisites

PowerShell requires script execution to be enabled. Run this **once** as Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

`RemoteSigned` allows local scripts to run but requires downloaded scripts to be signed. This is Microsoft's recommended setting for developers.

### Bootstrap
```powershell
# Clone and enter
git clone https://github.com/vardaasen/devEnvironment.git
cd devEnvironment

# First time: install system-level dependencies (admin required)
.\scripts\platform.ps1

# Bootstrap everything (admin required)
.\scripts\bootstrap.ps1
```

## Project Structure
```
devEnvironment/
├── .config/
│   ├── powershell/
│   │   ├── Microsoft.PowerShell_profile.ps1   # Profile loader
│   │   └── modules/
│   │       ├── 00-history.ps1                 # XDG history, escape char, git filter
│   │       ├── 05-checks.ps1                  # Environment detection, caching
│   │       ├── 10-visuals.ps1                 # Starship init cache, PSReadLine colors
│   │       ├── 20-bindings.ps1                # Vi mode, zoxide, PSFzf, posh-git
│   │       ├── 90-banner.ps1                  # Startup banner with performance info
│   │       └── 99-aliases.ps1                 # iA Writer, note, VS DevShell, choco wrapper
│   ├── starship/                              # Starship prompt configs
│   ├── wezterm/                               # WezTerm GPU terminal config
│   ├── terminal/                              # Windows Terminal settings (JSONC)
│   ├── clink/                                 # CMD enhancement (Clink + Lua)
│   │   ├── clink_settings
│   │   └── scripts/
│   │       ├── welcome.lua                    # CMD startup banner
│   │       └── starship.lua                   # Starship prompt for CMD
│   └── cmd/
│       └── cmd.bat                            # CMD autorun (Clink injection, UTF-8)
├── scripts/
│   ├── bootstrap.ps1                          # Orchestrator
│   ├── platform.ps1                           # Layer 0: system infrastructure
│   ├── setup.ps1                              # Layer 1: symlinks and config
│   └── provision.ps1                          # Layer 2: user tooling
├── tests/
│   └── Unit/                                  # Pester test suite
├── docs/
│   ├── deviations.md                          # Deviation log (AVV-001 through AVV-010)
│   ├── decisions.md                           # Architecture Decision Records
│   └── progress.md                            # Session progress log
├── conhost_theme.reg                          # Legacy console green-on-black theme
├── dev_profile.vsconfig                       # Visual Studio workload manifest
├── .editorconfig                              # Editor formatting rules
├── .gitattributes                             # Line ending enforcement
├── .pre-commit-config.yaml                    # Pre-commit hooks
└── .pester.psd1                               # Test framework config
```

## Design Principles

**XDG Compliance** — All config lives under `~/.config/`, enforced via `XDG_CONFIG_HOME` environment variable.

**Idempotent** — Every script can be run repeatedly without side effects. Existing symlinks are verified, installed tools are skipped.

**Layered Provisioning** — Platform dependencies first, then config linking, then user tools. Each layer can be run independently.

**Graceful Degradation** — Optional tools (Obsidian, PSFzf, posh-git) are detected at runtime. Missing tools are skipped, not errors.

**Performance** — Starship and Zoxide init scripts are cached to disk with 24hr TTL. Module load times are tracked per-file.

## PowerShell Modules

Modules are loaded in numeric order by the profile loader. Each module has a specific responsibility:

| Module | Responsibility | Key Feature |
|---|---|---|
| 00-history | History management | Git commands filtered to memory-only |
| 05-checks | Environment detection | 24hr cache for slow operations |
| 10-visuals | Prompt and colors | Starship init cached to disk |
| 20-bindings | Keybindings and tools | Vi mode with cursor shape switching |
| 90-banner | Startup display | Performance warning if >1000ms |
| 99-aliases | Custom commands | `note` with editor fallback chain |

## Terminal Support

| Terminal | Renderer | Theme |
|---|---|---|
| Windows Terminal | DirectX (GPU) | Frost (default), Retro (CMD) |
| WezTerm | OpenGL/WebGPU | Tomorrow Night Burns |
| Legacy Conhost | GDI (Software) | Green-on-black (Matrix) |

## Tools Provisioned

**Cargo:** eza, jj-cli, macchina, uv, ripgrep, fd-find

**Winget:** Windows Terminal, WezTerm, Starship, Clink, Neovim, Go, CMake, Ninja, 7-Zip, Fastfetch

**Chocolatey:** make, mingw (gcc), wget, unzip, gzip

## Testing
```powershell
# Run all tests
Invoke-Pester -Configuration (Import-PowerShellDataFile .pester.psd1)

# Run specific test file
Invoke-Pester ./tests/Unit/00-history.Tests.ps1 -Output Detailed
```

Tests are enforced on every commit via pre-commit hooks and on push via GitHub Actions.

## Line Ending Strategy

LF everywhere except legacy batch files. Enforced by `.gitattributes` and pre-commit `mixed-line-ending` hook. See `.editorconfig` for editor-level rules.

## Documentation

- `docs/deviations.md` — Issues encountered and solutions (AVV-001 through AVV-010)
- `docs/decisions.md` — Architecture Decision Records (ADR-001 through ADR-007)
- `docs/progress.md` — Work session log


## Security Considerations

This project requires **Administrator privileges** for symlink creation, package installation, and registry writes. Before running:

1. **Read the code** — all scripts are open source and intentionally readable
2. **Understand what runs as admin** — only `bootstrap.ps1`, `setup.ps1`, and `platform.ps1`
3. **No remote code execution** — scripts install named packages from Chocolatey, Winget, and Cargo. No arbitrary URLs are piped to `Invoke-Expression` (except the official Chocolatey installer)
4. **Registry changes are scoped** — only `HKCU\Console` (theme) and `HKCU\Command Processor` (CMD autorun)
5. **PSScriptAnalyzer** — not enforced as a pre-commit hook due to intentional use of `Write-Host` in interactive scripts, but recommended for contributors

### Developer Mode Alternative

Windows 10 (1703+) supports symlinks without admin if Developer Mode is enabled:
```powershell
# Settings → For Developers → Developer Mode: On
# Then bootstrap.ps1 can run without elevation for symlink operations
```

This does not remove the admin requirement for package installation.

## License

Personal dotfiles. Use as inspiration.
