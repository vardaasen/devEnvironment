# Fremdriftslogg

## Økt 1 — 2025-02-09 / 2025-02-10

### Infrastruktur

- [x] Repostruktur med alle mapper og tomme filer
- [x] `git init` + lokal gitconfig med auth
- [x] `gh repo create` — repo opprettet på GitHub
- [x] `.gitignore`, `.editorconfig`, `.gitattributes`
- [x] `.pre-commit-config.yaml` med trailing whitespace, EOF, line endings, Pester
- [x] `.pester.psd1` testkonfigurasjon (XML-rapport deaktivert lokalt)
- [x] `.github/workflows/test.yml` CI-pipeline med Pester + PSScriptAnalyzer (non-blocking)

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
- [x] Integrasjonstestet: `bootstrap.ps1` kjørt som admin, full hydration OK

### Konfigurasjonsfiler (alle med valideringstester)

- [x] Starship TOML (PowerShell + WSL)
- [x] WezTerm Lua
- [x] Windows Terminal JSONC
- [x] Clink settings + Lua scripts
- [x] CMD autorun batch
- [x] Conhost registry theme
- [x] VS Dev Profile (.vsconfig)

### Sikkerhet og identitet

- [x] SSH commit-signering konfigurert og verifisert
- [x] Signert all git-historikk via rebase
- [x] Security Considerations i README
- [x] ADR-005: Admin-kjøring og sikkerhetsvurderinger
- [x] ADR-006: Identitets- og autentiseringsarkitektur (under utredning)
- [x] ADR-006/007: Secrets management (under vurdering, duplikat beholdt bevisst)
- [x] PSScriptAnalyzer som valgfri CI-jobb

### Dokumentasjon

- [x] README.md med arkitektur, struktur, bruk, sikkerhet
- [x] AVV-001 til AVV-010 (avvikslogg)
- [x] ADR-001 til ADR-007 (beslutningslogg)
- [x] LICENSE (MIT)

### Teststatus

- Totalt: 201 Pester-tester passert, 2 skipped (WezTerm-spesifikke)
- Pre-commit hooks: trailing whitespace, EOF, merge conflicts, YAML, line endings, Pester
- CI: GitHub Actions med Pester + PSScriptAnalyzer

### Repo

- [x] Publisert som offentlig repo
- [x] Alle commits signert med SSH

### Uløst / neste økt

- [ ] Lande på miljøstrategi (native/WSL2/devcontainer/nix)
- [ ] Implementere automatisert identitetsflyt (`Initialize-DevIdentity`)
- [ ] `.env.template` og onboarding-dokumentasjon
- [ ] SSH config template
- [ ] Integrere `Set-GitIdentity` i PowerShell-profilen
- [ ] Vurdere vault-integrasjon (1Password/Bitwarden)
