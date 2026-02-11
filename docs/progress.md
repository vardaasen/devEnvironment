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

---

## Økt 2 — 2025-02-10 / 2025-02-11

### provision-fun.ps1 (Layer 3)

- [x] Opprettet `provision-fun.ps1` — valgfri, meningsbasert verktøy
- [x] Tester: `provision-fun.Tests.ps1` — 22 tester, alle grønne
- [x] Refaktorert til tabell-drevet mønster (matcher `provision.ps1`)

#### Runtimes

- [x] LLVM/Clang installasjon med PATH-refresh i sesjon
- [x] Deno erstatter Node.js som valgfri runtime (isolasjon via permissions)
- [x] Node.js fjernet som avhengighet for Claude Code (native installer)

#### Container Runtime

- [x] Nested virtualization-deteksjon via `Win32_ComputerSystem`
- [x] Parallels/VMware-gjenkjenning → advarsel om manglende nested virt
- [x] Remote Docker-veiledning (SSH anbefalt, TLS for avansert)
- [x] Docker Desktop kun installert når nested virt er tilgjengelig
- [x] ADR-008: Container- og virtualiseringsstrategi

#### AI Tooling

- [x] Claude Code: Interaktivt valg mellom native installer og Winget
  - Native: `irm https://claude.ai/install.ps1 | iex` (auto-oppdatering)
  - Winget: `Anthropic.ClaudeCode` (manuell kontroll)
- [x] Warp Terminal: `Warp.Warp` (korrigert fra `dev.warp.Warp`)
- [x] Dagger: `Dagger.Dagger` (krever Docker)
- [x] ADR-010: Runtime-valg — Deno over Node.js, native Claude Code

#### IDEs og Editorer

- [x] VS Code, Cursor, JetBrains Toolbox via tabell-loop
- [x] IDE-extensions informasjon (Claude dev, Continue, Copilot)

#### Matrix-klienter

- [x] iamb via Cargo (Vim-basert terminal-klient)
- [x] Cinny: `cinnyapp.cinny-desktop` (korrigert fra `niceredink.Cinny`)
- [x] Neoment: dokumentert som Neovim-plugin

#### Cargo Crates

- [x] iamb isolert i egen Cargo-seksjon med `Test-Command`-sjekk

#### External Repos

- [x] resistance (terminal-musikkspiller) klones som søskenmappe
- [x] `-Upgrade` gjør `git pull` på eksisterende repos

### Winget-ID fikser

- [x] Warp: `dev.warp.Warp` → `Warp.Warp`
- [x] Cinny: `niceredink.Cinny` → `cinnyapp.cinny-desktop`
- [x] Bekreftet på ARM64 (Parallels)

### Arkitekturbeslutninger

- [x] ADR-008: Container- og virtualiseringsstrategi (under utredning)
- [x] ADR-009: Oppdateringsnotifikasjoner ved terminaloppstart (utsatt)
- [x] ADR-010: Runtime-valg — Deno og native Claude Code

### Dokumentasjon

- [x] README.md oppdatert med Layer 3, nøyaktige AVV/ADR-tellere
- [x] Fremdriftslogg oppdatert med økt 2
- [x] docs/README.md oppdatert

### Teststatus (økt 2)

- provision-fun.Tests.ps1: 22 tester passert
- Totalt etter økt 2: 223+ Pester-tester

### Uløst / neste økt

- [ ] Lande på miljøstrategi (native/WSL2/devcontainer/nix) — ADR-006
- [ ] Implementere automatisert identitetsflyt (`Initialize-DevIdentity`)
- [ ] Integrere `Set-GitIdentity` i PowerShell-profilen
- [ ] Vurdere vault-integrasjon (1Password/Bitwarden/ProtonPass)
- [ ] Oppdateringsnotifikasjoner — velge tilnærming fra ADR-009
- [ ] Neovim-konfigurasjon (init.lua med Neoment, etc.)
- [ ] testResults.xml bør legges til .gitignore
