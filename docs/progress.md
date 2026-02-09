# Fremdriftslogg

## Økt 1 — 2025-02-09

### Utført

- [x] Opprettet repostruktur med alle mapper og tomme filer
- [x] `git init` + lokal gitconfig med auth
- [x] `gh repo create` — repo opprettet på GitHub
- [x] `.gitignore`, `.editorconfig`, `.gitattributes` fylt inn
- [x] `.pre-commit-config.yaml` konfigurert
- [x] `.pester.psd1` testkonfigurasjon
- [x] `.github/workflows/test.yml` CI-pipeline
- [x] `tests/Unit/infrastructure.Tests.ps1` — smoke test
- [x] Dokumenterte AVV-001 til AVV-006
- [x] Dokumenterte ADR-001 til ADR-004

### PowerShell-moduler (alle med tester)

- [x] `00-history.ps1` — XDG history, escape char, git filter
- [x] `05-checks.ps1` — miljødeteksjon, caching, .NET info
- [x] `10-visuals.ps1` — Starship cache, PSReadLine fargetema
- [x] `20-bindings.ps1` — Vi mode, posh-git, zoxide, PSFzf, choco lazy-load
- [x] `90-banner.ps1` — startup banner, ytelsesmåling
- [x] `99-aliases.ps1` — iA Writer, note fallback, VS DevShell, choco wrapper

### Neste steg

- [ ] `Microsoft.PowerShell_profile.ps1` — profile loader
- [ ] Scripts: `setup.ps1`, `provision.ps1`, `platform.ps1`, `bootstrap.ps1`
- [ ] Konfig: Lua, TOML, JSON, bat, reg
- [ ] README.md
