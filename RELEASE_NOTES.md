# Release Notes

## v1.0.0 — PowerShell Baseline (2026-02-11)

**Status:** Stable Windows implementation — Go rewrite in progress (see `go-port` branch)

### Oversikt

Dette er den stabile PowerShell-baserte implementasjonen av devEnvironment. Prosjektet er modent og produksjonsklar for Windows-brukere, men vil bli refaktorert til Go for cross-platform support (se [ADR-011](docs/decisions.md#adr-011-go-basert-cross-platform-arkitektur)).

**Anbefaling:**
- Windows-brukere: Bruk denne versjonen med tillit — den er vel-testet og stabil
- macOS/Linux-brukere: Vent på v2.0.0 (Go-versjon)

---

### Hva er inkludert?

#### 4-lags provisioning arkitektur

1. **Layer 0: Platform Infrastructure** (`platform.ps1`)
   - Chocolatey, Winget, rustup/Cargo
   - PowerShell Core, Git (interactive install)
   - Fonter: iA Writer Duo, Monaspace Radon

2. **Layer 1: Configuration** (`setup.ps1`)
   - XDG-compliant symlinks (`.config/powershell`, `starship`, `wezterm`, `terminal`)
   - Clink hardlinks og junctions
   - PowerShell profile shims (PSv5 + PSv7)
   - CMD autorun registry key

3. **Layer 2: Core Tooling** (`provision.ps1`)
   - Cargo: eza, jj-cli, macchina, uv, ripgrep, fd-find
   - Winget: Windows Terminal, WezTerm, Starship, Clink, Neovim, Go, CMake, Ninja, 7-Zip
   - Chocolatey: make, mingw, wget, unzip, gzip

4. **Layer 3: Optional Extras** (`provision-fun.ps1`)
   - Runtimes: LLVM/Clang, Deno
   - Container: Docker Desktop (med nested virt detection)
   - AI: Claude Code, Warp Terminal, Dagger
   - IDEs: VS Code, Cursor, JetBrains Toolbox
   - Matrix: iamb, Cinny, Neoment

---

### Testing & Kvalitet

**Test suite:** 14 Pester test filer, 223+ tester
- Alle PowerShell moduler testet (00-history, 05-checks, 10-visuals, 20-bindings, 90-banner, 99-aliases)
- Alle provision scripts testet (bootstrap, platform, setup, provision, provision-fun)
- Infrastruktur og konfigurasjon testet
- Pre-commit hooks: trailing whitespace, EOF, YAML, line endings, Pester

**CI:** GitHub Actions
- Pester (blocking)
- PSScriptAnalyzer (non-blocking)

---

### Dokumentasjon

**ADRer (Architecture Decision Records):**
- ADR-001: Pester som testrammeverk (VEDTATT)
- ADR-002: `uv` som Python package manager (VEDTATT)
- ADR-005: Admin-kjøring og sikkerhetsvurderinger (VEDTATT)
- ADR-006: Secrets management (SUPERSEDED by ADR-011)
- ADR-007: Identitetsarkitektur (VEDTATT — hybrid interaktiv)
- ADR-008: Container strategi (VEDTATT — OrbStack/Podman)
- ADR-009: Update notifications (UTSATT)
- ADR-010: Deno over Node.js (VEDTATT)
- **ADR-011: Go-basert cross-platform arkitektur (VEDTATT — fremtidig)**

**AVVer (Avvik/Deviations):**
- 10 dokumenterte avvik med læring og løsninger
- Viktigste: AVV-006 (false green test), AVV-010 (PSScriptRoot path issue)

**Guider:**
- `docs/onboarding.md` — Git/SSH setup (3 nivåer)
- `docs/progress.md` — Session logs
- `README.md` — Hovedguide

**Templates (nye i v1.0.0):**
- `templates/ADR-TEMPLATE.md` — For nye beslutninger
- `templates/AVV-TEMPLATE.md` — For nye avvik
- `templates/PROGRESS-TEMPLATE.md` — For økter
- `templates/GIT-COMMIT-TEMPLATE.md` — Commit message konvensjoner
- `templates/DOCS-TEMPLATE.md` — Generell dokumentasjon

---

### Design Prinsipper

1. **XDG Compliance** — All config under `~/.config/`
2. **Idempotent** — Kan kjøres flere ganger uten side-effekter
3. **Graceful Degradation** — Manglende optional tools skippes, ikke errors
4. **Layered Provisioning** — Dependencies først, deretter config, deretter tools
5. **Performance** — Starship/Zoxide init cached med 24hr TTL
6. **Table-Driven** — Deklarative loops for tool management

---

### Quick Start

```powershell
# 1. Clone repo
git clone https://github.com/vardaasen/devEnvironment
cd devEnvironment

# 2. Kjør bootstrap (krever admin)
.\scripts\bootstrap.ps1

# 3. (Valgfritt) Installer ekstra verktøy
.\scripts\provision-fun.ps1
```

**Første gang shell åpnes:**
PowerShell profile lastes fra `.config/powershell/modules/` med module timing.

---

### Kjente Begrensninger

**Windows-only:**
- Ingen macOS/Linux support i denne versjonen
- Se `go-port` branch for cross-platform utvikling

**Container support:**
- Docker Desktop krever nested virtualization
- Parallels/VMware VMs må bruke remote Docker (se ADR-008)

**Update notifications:**
- Ingen automatiske oppdateringsmeldinger (ADR-009 utsatt)
- Bruk manuell `provision.ps1 -Upgrade` eller `provision-fun.ps1 -Upgrade`

---

### Sikkerhet

**Admin-privilegier påkrevd:**
- Symlinks (Windows-restriksjon)
- Package installation (Chocolatey, Winget)
- Registry writes (kun `HKCU`)
- Font installation

**Mitigering:**
- ✅ All kode åpen kildekode og reviewbar
- ✅ Eksplisitt admin-sjekk i bootstrap.ps1
- ✅ Ingen remote code execution (unntatt Chocolatey installer)
- ✅ PSScriptAnalyzer som non-blocking CI

**Se:** [ADR-005](docs/decisions.md#adr-005-admin-kjøring-og-sikkerhetsvurderinger)

---

### Oppgradering fra tidligere versjoner

**Fra session 1 (pre-v1.0.0):**
```powershell
# Pull latest
git pull origin master

# Kjør bootstrap på nytt (idempotent)
.\scripts\bootstrap.ps1

# Oppgrader verktøy
.\scripts\provision.ps1 -Upgrade
.\scripts\provision-fun.ps1 -Upgrade
```

---

### Hva kommer i v2.0.0?

**Go-basert cross-platform CLI** (estimert: 5 uker)

**Nye features:**
- ✅ Windows, macOS, Linux support (én binær)
- ✅ Raskere kjøretid (kompilert)
- ✅ Interaktiv TUI (Bubbletea) for identity setup
- ✅ Automatisk nested virt detection
- ✅ Distribusjon via Homebrew, Winget, GitHub Releases

**Breaking changes:**
- CLI API endres fra `.\scripts\bootstrap.ps1` til `devenv install`
- PowerShell scripts deprecated (men `.config/` struktur uendret)

**Migrering:**
- `.config/` directory er 100% kompatibel
- Brukere kan migrere når de er klare
- PowerShell scripts fortsetter å fungere (med deprecation warning)

**Se:** [ADR-011](docs/decisions.md#adr-011-go-basert-cross-platform-arkitektur)

---

### Bidragsytere

- vardaasen — Hovedutvikler
- Claude Sonnet 4.5 — AI-assistent (dokumentasjon, testing, ADR-utforming)

---

### Lisens

MIT License — Se [LICENSE](LICENSE)

---

### Support

**Rapporter issues:** [GitHub Issues](https://github.com/vardaasen/devEnvironment/issues)

**Diskusjon:** [GitHub Discussions](https://github.com/vardaasen/devEnvironment/discussions)

---

**Thank you for using devEnvironment!**

For the latest updates, star the repo and watch for v2.0.0 announcements.
