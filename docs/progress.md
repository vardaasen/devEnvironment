# Fremdriftslogg

## Økt 1 — 2025-02-09

### Infrastruktur

- [x] Repostruktur med alle mapper og tomme filer
- [x] `git init` + lokal gitconfig med auth
- [x] `gh repo create` — repo opprettet på GitHub
- [x] `.gitignore`, `.editorconfig`, `.gitattributes`
- [x] `.pre-commit-config.yaml` med trailing whitespace, EOF, line endings, Pester
- [x] `.pester.psd1` testkonfigurasjon (XML-rapport deaktivert lokalt)
- [x] `.github/workflows/test.yml` CI-pipeline

### PowerShell-moduler (alle med Pester-tester)

- [x] `00-history.ps1` — XDG history, escape char, git filter
- [x] `05-checks.ps1` — miljødeteksjon, caching, .NET info
- [x] `10-visuals.ps1` — Starship cache, PSReadLine fargetema
- [x] `20-bindings.ps1` — Vi mode, posh-git, zoxide, PSFzf, choco lazy-load
- [x] `90-banner.ps1` — startup banner, ytelsesmåling
- [x] `99-aliases.ps1` — iA Writer, note fallback, VS DevShell, choco wrapper
- [x] `Microsoft.PowerShell_profile.ps1` — profile loader med per-modul timing

### Scripts (alle med Pester-tester)

- [x] `setup.ps1` — symlinks, registry, profile shims
- [x] `provision.ps1` — Cargo, Winget, Chocolatey provisioning
- [x] `platform.ps1` — pakkemanagere, Rust, runtimes, fonter
- [x] `bootstrap.ps1` — orkestrator

### Konfigurasjonsfiler (alle med valideringstester)

- [x] Starship TOML (PowerShell + WSL)
- [x] WezTerm Lua
- [x] Windows Terminal JSONC
- [x] Clink settings + Lua scripts
- [x] CMD autorun batch
- [x] Conhost registry theme
- [x] VS Dev Profile (.vsconfig)

### Dokumentasjon

- [x] AVV-001 til AVV-009 (avvikslogg)
- [x] ADR-001 til ADR-004 (beslutningslogg)
- [x] README.md

### Teststatus

- Totalt: 80+ Pester-tester
- Alle grønne lokalt og via pre-commit
- CI-pipeline konfigurert for GitHub Actions
