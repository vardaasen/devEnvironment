# Arkitekturbeslutninger (ADR)

## ADR-001: Pester som testrammeverk

**Dato:** 2025-02-09
**Status:** Vedtatt

### Kontekst

Prosjektet er primært PowerShell-basert. Trenger et testrammeverk som kan validere moduler, symlinking og idempotens.

### Beslutning

Pester v5+ med `.pester.psd1`-konfigurasjon og NUnit3-rapportering.

### Begrunnelse

- De facto standard for PowerShell-testing
- Innebygd i GitHub Actions (windows-latest)
- Støtter mocking av filsystem, registry og kommandoer

---

## ADR-002: `uv` som Python-verktøymanager

**Dato:** 2025-02-09
**Status:** Vedtatt

### Kontekst

`pre-commit` krever Python. Trenger en lettvekts måte å installere Python-verktøy uten å administrere virtuelle miljøer manuelt.

### Beslutning

Bruk `uv tool install` for Python CLI-verktøy. Fallback til `uvx` for engangskjøring.

### Begrunnelse

- Allerede i prosjektets toolchain (installert via Cargo i `provision.ps1`)
- Raskere enn pip, ingen venv-overhead
- Se [AVV-001](deviations.md#avv-001-pre-commit-ikke-i-path-etter-uv-tool-install) for PATH-avvik

---

## ADR-005: Admin-kjøring og sikkerhetsvurderinger

**Dato:** 2025-02-10
**Status:** Vedtatt

### Kontekst

`bootstrap.ps1`, `setup.ps1` og `platform.ps1` krever Administrator-privilegier for å:
- Opprette symbolske lenker (Windows-restriksjon)
- Installere pakker via Chocolatey/Winget
- Skrive til registry (`HKCU`, `HKLM`)
- Kopiere fonter til `%SystemRoot%\Fonts`

Dette er en kjent angrepsflate for dotfiles-prosjekter generelt.

### Risikovurdering

| Risiko | Nivå | Mitigering |
|---|---|---|
| Ondsinnet kode i scripts | Høy | All kode er åpen kildekode og reviewbar |
| Supply chain (Chocolatey/Winget/Cargo) | Middels | Pakker er navngitt eksplisitt, ingen wildcard |
| Registry-endringer | Lav | Kun `HKCU\Console` og `HKCU\Command Processor` |
| Symlink-manipulering | Lav | Idempotent, backup av eksisterende |

### Beslutning

1. **Ingen scripts laster ned og kjører ukjent kode** — unntaket er Chocolatey-installasjon som bruker offisiell installscript
2. **PSScriptAnalyzer er ikke inkludert som pre-commit hook** — vurdert, men nedprioritert fordi:
   - Prosjektet bruker `Write-Host` bevisst (interaktive scripts)
   - `Invoke-Expression` brukes kun for Chocolatey-installasjon (kjent mønster)
   - Falske positiver ville støyet mer enn de hjelper for dette prosjektets omfang
3. **Admin-sjekk er eksplisitt** — `bootstrap.ps1` verifiserer og avbryter tidlig hvis ikke admin
4. **Brukere oppfordres til å lese koden før kjøring**

### Fremtidig forbedring

- Vurder PSScriptAnalyzer som valgfri CI-sjekk med tilpasset regelset
- Vurder Developer Mode for symlinks uten admin (Windows 10 1703+)
- Vurder checksums for eksterne installscripts

---

## ADR-006: Secrets and Identity Management Strategy

**Dato:** 2025-02-10
**Status:** SUPERSEDED by ADR-011 (Go-basert arkitektur)

### Kontekst

Prosjektet trenger en strategi for:
1. Git author identity (navn, e-post) per repo
2. SSH-nøkler for GitHub-autentisering
3. Commit-signering
4. Generisk onboarding uten å lekke personlig info i repoet

### Problemstilling

Dotfiles-repoer har en iboende spenning: de skal automatisere personlig oppsett, men personlig informasjon skal ikke commites. Enhver løsning må balansere:
- **Enkelhet** — en nybegynner må kunne følge instruksjonene
- **Sikkerhet** — private nøkler og credentials skal aldri ligge i repoet
- **Fleksibilitet** — ulike brukere har ulike identiteter og vault-løsninger

### Alternativer vurdert

#### A) `.env`-fil (gitignored)
```
GIT_USER_NAME=Fornavn Etternavn
GIT_USER_EMAIL=bruker@example.com
SSH_KEY_PATH=~/.ssh/id_ed25519
```

**Fordeler:** Enkelt, kjent mønster, lett å dokumentere
**Ulemper:** Ingen kryptering, lett å glemme å gitignore, ingen rotasjon

#### B) Vault-basert (1Password / Bitwarden / ProtonPass)

SSH-nøkler i vault, SSH agent bridge til lokal maskin.

**Fordeler:** Nøkler forlater aldri vaulten, fungerer på tvers av maskiner
**Ulemper:** Krever vault-oppsett, ekstra avhengighet, høyere terskel for nybegynnere

#### C) Hybrid — `.env.template` + vault-anbefaling

Repoet inneholder en template, dokumentasjon anbefaler vault for private nøkler:
```
# .env.template (committed — ingen hemmeligheter)
GIT_USER_NAME=
GIT_USER_EMAIL=
SSH_SIGNING_KEY=~/.ssh/id_ed25519.pub

# .env (gitignored — brukerens faktiske verdier)
```

**Fordeler:** Lav terskel, progressiv sikkerhet, fungerer uten vault

### Anbefalt mønster

Hybrid (C) med progressiv sikkerhet:

1. **Nivå 1 (Minimum):** `.env` med git identity, gitignored
2. **Nivå 2 (Anbefalt):** SSH-nøkler med passphrase, signering aktivert
3. **Nivå 3 (Avansert):** Vault-basert SSH agent (1Password/Bitwarden)

### Git-konfigurasjon

Repo inkluderer en generisk `.gitconfig.template` som scripts kan konsumere:
```ini
# .gitconfig.template
[user]
    name = ${GIT_USER_NAME}
    email = ${GIT_USER_EMAIL}
    signingkey = ${SSH_SIGNING_KEY}
[gpg]
    format = ssh
[commit]
    gpgsign = true
[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers
```

Per-repo aktivering via alias (allerede i bruk):
```powershell
# PowerShell alias i profilen
function Set-GitIdentity {
    param([string]$Profile = "default")
    $env = Get-Content ".env" | ConvertFrom-StringData
    git config --local user.name $env.GIT_USER_NAME
    git config --local user.email $env.GIT_USER_EMAIL
    git config --local user.signingkey $env.SSH_SIGNING_KEY
}
```

### SSH-konfigurasjon
```
# .ssh/config.template (committed)
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

### Referanser

- OWASP Secrets Management Cheat Sheet
- GitHub SSH key documentation
- 1Password SSH Agent documentation

---

## ADR-007: Identitets- og autentiseringsarkitektur

**Dato:** 2025-02-10
**Oppdatert:** 2026-02-11
**Status:** Vedtatt — Hybrid interaktiv tilnærming

### Kjerneinnsikt

Hvis OS-brukernavn samsvarer med forge-brukernavn (GitHub/Gitea), kan hele autentiseringsflyten automatiseres uten manuell secret-håndtering:
```
$env:USERNAME (OS) → git user.name → gh auth login (OAuth/SSO)
→ ssh-keygen → gh ssh-key add → ferdig
```

### Åpne spørsmål

1. **Miljøstrategi** — Native Windows vs WSL2 vs Devcontainer vs Nix?
   Valget påvirker alt nedstrøms: hvor nøkler lagres, hvordan PATH fungerer, hvilke verktøy som er tilgjengelige.

2. **Forge-agnostisk?** — `gh cli` (GitHub), `tea cli` (Gitea), `glab` (GitLab) har alle OAuth-flyt. Bør scriptet støtte flere, eller er GitHub nok?

3. **Nøkkellivssyklus** — Generere ny nøkkel per maskin? Per repo? Rotere automatisk? Revoke ved deprovisionering?

4. **Progressiv kompleksitet** — Bør grunnoppsettet fungere uten vault, men *støtte* vault for de som vil?

### Mulig automatisert flyt
```powershell
# Hele onboarding i én kommando
function Initialize-DevIdentity {
    $username = $env:USERNAME

    # 1. Generer nøkkel hvis den ikke finnes
    if (-not (Test-Path "~/.ssh/id_ed25519")) {
        ssh-keygen -t ed25519 -C "$username" -f "$HOME/.ssh/id_ed25519" -N '""'
    }

    # 2. Autentiser mot GitHub via OAuth
    gh auth login --web --git-protocol ssh

    # 3. Last opp SSH-nøkkel
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "$env:COMPUTERNAME"

    # 4. Konfigurer signering
    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/id_ed25519.pub
    git config --global commit.gpgsign true

    # 5. Allowed signers
    "$username $(Get-Content ~/.ssh/id_ed25519.pub)" |
        Set-Content ~/.ssh/allowed_signers
    git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
}
```

### Vault-integrasjon (Nivå 2)

For de som vil, kan private nøkler delegeres til vault etter initial setup:
- 1Password SSH Agent (mest modent)
- Bitwarden/Vaultwarden (gratis, self-hostable)
- ProtonPass (nyere)

Vault erstatter ikke OAuth-flyten — den sikrer nøklene *etter* at de er generert.

### Beslutning

**Hybrid tilnærming med interaktiv prompt:**

1. **Interaktivitet først** — ved `devenv identity` kommando, spør brukeren om de vil:
   - Bruke eksisterende `.env` (hvis den finnes)
   - Oppgi identitet interaktivt
   - Automatisk deteksjon via `$env:USERNAME` (hvis samsvarer med forge-bruker)

2. **Progressiv sikkerhet** — tre nivåer:
   - **Nivå 1:** `.env` med git identity (gitignored)
   - **Nivå 2:** SSH-nøkler med passphrase, signering aktivert
   - **Nivå 3:** Vault-basert SSH agent (1Password/Bitwarden/ProtonPass)

3. **Per-repo konfigurasjon** — alltid `git config --local`, aldri `--global`

**Implementasjon:** Se ADR-011 for Go-basert CLI med Bubbletea TUI.

---

## ADR-008: Container- og virtualiseringsstrategi

**Dato:** 2025-02-10
**Oppdatert:** 2026-02-11
**Status:** Vedtatt — OrbStack (macOS) / Podman (cross-platform)

### Kontekst

AI-verktøy (Claude Code, Warp MCP, Dagger MCP) krever Docker/containere. Miljøet kan kjøre på ulike plattformer med ulike begrensninger.

### Kjøremiljøer

| Scenario | Nested Virt | Container-løsning | Merknad |
|---|---|---|---|
| Native Windows | Ja | Docker Desktop / WSL2 | Enklest |
| Native Linux | Ja | Docker Engine / Podman | Enklest |
| Native macOS | Ja | OrbStack / Docker Desktop | OrbStack anbefalt |
| Windows i Parallels (macOS) | Nei | Remote Docker til macOS-host | Parallels blokkerer Hyper-V |
| Windows på billig VPS | Varierer | Remote Docker til separat host | KVM-avhengig |
| WSL2 på Windows | Ja (via host) | Docker Desktop med WSL2-backend | Delt daemon |

### Problemstilling: Nested Virtualisering

Docker krever en hypervisor (Hyper-V / KVM). Når Windows kjører som gjest i Parallels, er nested virtualisering ofte utilgjengelig eller ustabil. Da trengs en annen strategi:
```
┌─ macOS Host ─────────────────────────┐
│  OrbStack / Docker Desktop           │
│  ┌─ Container Engine ──────────────┐ │
│  │  Dagger, DevContainers, MCP     │ │
│  └─────────────────────────────────┘ │
│                                      │
│  ┌─ Parallels VM ──────────────────┐ │
│  │  Windows (ingen nested virt)    │ │
│  │  DOCKER_HOST=tcp://host:2375    │ │
│  │  → Snakker med macOS Docker     │ │
│  └─────────────────────────────────┘ │
└──────────────────────────────────────┘
```

### Container-løsninger rangert

#### macOS (host)

1. **OrbStack** — Raskest, lavest ressursbruk, drop-in Docker-erstatning
2. **Colima** — CLI-basert, bruker Lima, gratis
3. **Lima** — Lavnivå VM-manager, manuelt oppsett
4. **Docker Desktop** — Offisiell, tungt, lisensbegrensninger for enterprise

#### Windows (native)

1. **Docker Desktop + WSL2** — Standard, best integrasjon med VS Code devcontainers
2. **Podman Desktop** — Rootless, daemonless, OCI-kompatibel
3. **WSL2 + Docker Engine** — Manuelt, men lettere enn Docker Desktop
4. **Rancher Desktop** — Alternativ med nerdctl

#### Linux

1. **Docker Engine** — Standard
2. **Podman** — Rootless, systemd-integrasjon
3. **nerdctl + containerd** — Minimalt

### AI-verktøy

| Verktøy | Type | Krav | Installasjon |
|---|---|---|---|
| Claude Code | CLI agent | Node.js 18+ | npm install -g @anthropic-ai/claude-code |
| Warp Terminal | Terminal + MCP | — | Winget / dmg |
| Dagger | CI/CD engine | Docker | curl + Docker |

### Sikkerhetsvurderinger

1. **Docker socket-eksponering** — `DOCKER_HOST=tcp://` uten TLS er usikret. Produksjon krever TLS-sertifikater eller SSH-tunnel.
2. **Remote Docker over nettverk** — Kun på lokalt nett eller via SSH-tunnel (`ssh -L`). Aldri eksponér Docker-socket direkte på internett.
3. **Devcontainer-sikkerhet** — Containere kjører som root som standard. Bruk `remoteUser` og `--userns` for isolasjon.
4. **MCP-servere** — Hver MCP-server er en prosess med tilgang til miljøet. Begrens med allowlists og sandboxing.
5. **Docker Desktop lisens** — Gratis for personlig bruk og små bedrifter (<250 ansatte, <$10M). Verifiser for enterprise.
6. **WSL2-isolasjon** — Deler kernel med Windows-host. Ikke en sikkerhetsgrense for container-escape.

### Beslutning

**Prioritert container runtime:**

| Platform | Native Virt | Anbefalt Runtime | Fallback |
|----------|-------------|------------------|----------|
| macOS (native) | Ja | **OrbStack** | Docker Desktop |
| Windows (native) | Ja | Docker Desktop + WSL2 | Podman Desktop |
| Linux | Ja | Docker Engine | **Podman** |
| VM uten nested virt (Parallels/VMware) | Nei | **Remote Docker via SSH** | N/A |

**Begrunnelse:**
- **OrbStack** (macOS): Raskest, lavest ressursbruk, beste brukeropplevelse
- **Podman** (cross-platform): Rootless, daemonless, gratis, bedre sikkerhet
- **Remote Docker**: For miljøer uten nested virtualization support

**Implementasjon:** Go-basert deteksjon av nested virt capability (se ADR-011).

**Sikkerhet:**
- Remote Docker kun via SSH tunnel (aldri ukryptert TCP)
- TLS-sertifikater for produksjon
- Devcontainers med `remoteUser` og `--userns`

---

## ADR-009: Oppdateringsnotifikasjoner ved terminaloppstart

**Dato:** 2025-02-10
**Status:** Under utredning

### Kontekst

Mange verktoy installeres via ulike pakkemanagere (Winget, Cargo, Choco, npm, native). Noen auto-oppdaterer (Claude Code native, JetBrains Toolbox), andre gjor det ikke (Winget-pakker, Cargo crates). Brukeren har ingen enhetlig oversikt over hva som er utdatert.

### Problemstilling

Bor `90-banner.ps1` eller en ny modul sjekke for utdaterte pakker ved oppstart?

### Fordeler

- Proaktiv sikkerhet — utdaterte verktoy er en angrepsflate
- Bevissthet — brukeren vet hva som trenger oppmerksomhet
- Sentralisert — en plass i stedet for mange

### Ulemper

- Oppstartstid — `winget upgrade --include-unknown` tar 3-8 sekunder
- Stoy — for mange meldinger drukner i banneren
- Kompleksitet — flere pakkemanagere, ulike sjekk-metoder

### Mulige tilnaerminger

1. **Bakgrunnsjobb** — Kjor sjekk async, cache resultat, vis ved neste oppstart
2. **Dedikert kommando** — `Update-DevTools` funksjon som kjorer `provision.ps1 -Upgrade`
3. **Ukentlig cache** — Sjekk en gang i uka, lagre i `$env:TEMP`, vis i banner hvis funn
4. **Ekstern monitor** — Dependabot/Renovate for dotfiles-repoet selv

### Relevant eksisterende arkitektur

- `05-checks.ps1` har allerede 24hr cache for Starship/PSReadline-versjoner
- `90-banner.ps1` har allerede ytelsesadvarsel (>1000ms)
- `provision.ps1 -Upgrade` finnes allerede som manuell metode

### Beslutning

Utsatt. Implementerer ikke automatiske oppdateringssjekker naa. Manuell `provision.ps1 -Upgrade` og `provision-fun.ps1 -Upgrade` er tilstrekkelig for forste iterasjon.

Vurderes naar oppstartstid-budsjett og cache-strategi er avklart.

---

## ADR-010: Runtime-valg — Deno over Node.js, native Claude Code

**Dato:** 2025-02-11
**Status:** Vedtatt

### Kontekst

`provision-fun.ps1` trengte en JavaScript/TypeScript-runtime for AI-verktøy og Claude Code skills. Tre alternativer ble vurdert: Node.js, Bun og Deno.

### Alternativer

| Runtime | Fordeler | Ulemper |
|---|---|---|
| Node.js | Størst økosystem, mest utbredt | Ingen isolasjon, stor installasjon, npm-avhengigheter |
| Bun | Rask, npm-kompatibel, Claude Code bruker Bun internt | `node_modules`-deteksjon kan bryte auto-install (bekreftet av magarcia jan 2026) |
| Deno | Permissions-basert isolasjon, TypeScript native, npm-kompatibel | Mindre økosystem, noen npm-pakker trenger tilpasning |

### Claude Code-installasjon

Anthropic lanserte en native binary-installer (okt 2025) som den anbefalte metoden. Binæren er bygget med Buns standalone executable-funksjon, men krever ingen ekstern runtime.

To installasjonsmetoder tilbys via interaktivt valg i scriptet:

1. **Native installer** (`irm https://claude.ai/install.ps1 | iex`) — auto-oppdaterer i bakgrunnen
2. **Winget** (`Anthropic.ClaudeCode`) — manuell kontroll, krever `winget upgrade`

### Beslutning

1. **Deno som valgfri runtime** — installeres via `DenoLand.Deno` i Winget. Brukes for Claude Code skills og generell TypeScript-kjøring. Denos permissions-modell gir bedre isolasjon enn Node.js.

2. **Node.js fjernet som avhengighet** — Claude Code trenger det ikke lenger med native installer.

3. **Interaktivt valg for Claude Code** — brukeren velger mellom native (auto-update) og Winget (manuell kontroll) ved installasjon.

### Referanser

- magarcia: "Why I Switched from Bun to Deno for Claude Code Skills" (jan 2026)
- Anthropic: Native installer announcement (okt 2025)
- claudefa.st: "Claude Code Native Installer: Skip Node.js Entirely"

---

## ADR-011: Go-basert cross-platform arkitektur

**Dato:** 2026-02-11
**Status:** Vedtatt — Arkitektonisk pivot

### Kontekst

devEnvironment-prosjektet ble opprettet som et Windows-first PowerShell-basert dotfiles- og utviklermiljø. Etter to økter med stabil Windows-implementasjon (4 layers, 14 test suites, 223+ tester, komplett dokumentasjon), oppstod behovet for cross-platform support (macOS, Linux).

**Nåværende tilstand (v1.0.0-rc):**
- 100% PowerShell-basert (scripts/, .config/powershell/modules/)
- Pester v5+ testing framework
- Windows-spesifikke operasjoner (symlinks, registry, fonts)
- Modent og velfungerende på Windows

**Utfordring:**
Å portere PowerShell-scripts til bash for macOS/Linux ville gi:
- Dobbelt vedlikeholdsarbeid (PowerShell + bash)
- Ulike package manager APIs (winget vs brew vs apt)
- Plattformspesifikk kompleksitet i hvert script
- Vanskelig testing (Pester for PS, bats for bash)

### Alternativer vurdert

#### A) PowerShell Core (cross-platform)

**Fordeler:** Beholder eksisterende kode, PS Core fungerer på macOS/Linux

**Ulemper:**
- PowerShell er uvanlig på macOS/Linux (ikke i standard developer toolkit)
- Package manager abstraksjon fortsatt nødvendig
- Større runtime footprint (~200MB)
- Kulturelt mismatch (bash/zsh er normen på Unix)

**Hvorfor avvist:** Påtvinger Windows-sentrisk verktøy på Unix-brukere

---

#### B) Bash + PowerShell parallelt

**Fordeler:** Native på hver platform, følger konvensjoner

**Ulemper:**
- Dobbelt vedlikeholdsarbeid (hver feature skrevet to ganger)
- Potensielt divergerende funksjonalitet
- To testframeworks (Pester + bats)
- Kompleks release-prosess

**Hvorfor avvist:** Ikke skalerbart, høy vedlikeholdskostnad

---

#### C) Go (kompilert, cross-platform)

**Fordeler:**
- ✅ Én kodebase, alle platformer (Windows/macOS/Linux, AMD64/ARM64)
- ✅ Statisk kompilert binær (ingen runtime-avhengigheter)
- ✅ Raskere kjøretid enn interpretert PowerShell/bash
- ✅ Kraftig standard library (os, exec, filepath)
- ✅ Etablerte CLI-biblioteker (Cobra, Bubbletea)
- ✅ Cross-compilation triviell (`GOOS=linux go build`)
- ✅ Enklere distribusjon (GitHub Releases, Homebrew, Winget)
- ✅ Type safety og compile-time sjekker
- ✅ Enkelt å teste (Go testing standard library)

**Ulemper:**
- ⚠️ Omskriving av ~2000 linjer PowerShell
- ⚠️ Må lære Go konvensjoner
- ⚠️ Mister Pester (men får Go testing, som er bedre)

**Hvorfor valgt:** Best langsiktige trade-off mellom vedlikeholdbarhet og cross-platform support

---

### Beslutning

**Refaktorer devEnvironment til Go-basert CLI verktøy (`devenv`).**

**Arkitektur:**
```
devenv (Go binary)
├── cmd/devenv/main.go                 # Entrypoint
├── internal/
│   ├── platform/                      # OS abstraksjon (Windows/macOS/Linux)
│   ├── provisioner/                   # Package manager wrappers (winget/brew/apt/cargo)
│   ├── identity/                      # Git/SSH setup med interaktiv TUI
│   ├── container/                     # Docker/OrbStack/Podman detection
│   └── symlink/                       # XDG symlink logic
├── configs/tools.yaml                 # Deklarativ tool manifest
└── .config/                           # Beholdes uendret (PowerShell, Starship, etc.)
```

**CLI kommandoer:**
```bash
devenv install [--upgrade]             # Installer alle verktøy fra manifest
devenv identity [--non-interactive]    # Setup Git/SSH med TUI eller .env
devenv setup                           # Opprett XDG symlinks
devenv container [--runtime=orbstack]  # Installer container runtime
devenv status                          # Vis miljøstatus
```

**Interaktivitet:**
- Bubbletea TUI for `devenv identity` (erstatter .env-prompt)
- Valgfri `--non-interactive` flag for CI/scripting

**Konfigurasjon:**
- YAML manifest (`configs/tools.yaml`) for tool lists
- Samme `.config/` struktur (ingen endringer for brukere)

---

### Migrasjonsstrategi

**v1.0.0 (PowerShell baseline):**
- Tag nåværende PowerShell implementasjon som `v1.0.0`
- Release notes: "Stable Windows implementation, Go rewrite in progress"
- Brukere kan fortsette å bruke PowerShell-versjon

**v2.0.0-alpha (Go port):**
- Utvikles i `go-port` branch
- Parallelldrift: både PowerShell og Go tilgjengelig
- PowerShell scripts får deprecation warning

**v2.0.0 (Go stable):**
- Go versjon blir standard
- PowerShell scripts flyttes til `legacy/` folder
- Breaking change: CLI API endret fra `.ps1` scripts til `devenv` subcommands

**Backward compatibility:**
- `.config/` structure uendret (100% kompatibel)
- Brukere kan migrere når de er klare

---

### Implementasjonsplan

**Fase 1: Foundation (Uke 1)**
- [ ] Go module init (`github.com/vardaasen/devenv`)
- [ ] Cobra CLI setup
- [ ] Platform abstraction (`internal/platform/`)
- [ ] Package manager interfaces (`internal/provisioner/`)

**Fase 2: Core Features (Uke 2)**
- [ ] Tool installation fra YAML manifest
- [ ] Identity setup med Bubbletea TUI
- [ ] SSH agent integration (1Password/Bitwarden)

**Fase 3: Container & Symlinks (Uke 3)**
- [ ] Nested virt detection
- [ ] OrbStack/Podman installation
- [ ] XDG symlink creation

**Fase 4: Testing & Docs (Uke 4)**
- [ ] Go testing suite (erstatter Pester)
- [ ] CI pipeline (Windows/macOS/Linux)
- [ ] Dokumentasjon oppdatering

**Fase 5: Distribusjon (Uke 5)**
- [ ] GoReleaser setup
- [ ] GitHub Releases (6 platformer: windows/darwin/linux × amd64/arm64)
- [ ] Homebrew tap
- [ ] Winget manifest

---

### Konsekvenser

#### Positive
- Cross-platform support uten dobbelt vedlikeholdsarbeid
- Raskere kjøretid (~10x speedup for parsing og tool checks)
- Enklere distribusjon (statisk binær)
- Bedre type safety (compile-time feilhåndtering)
- Moderne TUI med Bubbletea (bedre UX enn PowerShell-prompts)

#### Negative
- Omskriving tar tid (~5 uker estimat)
- Brukere av PowerShell-versjon må migrere (men kan utsette)
- Go learning curve for bidragsytere

#### Nøytrale
- Test framework bytter fra Pester til Go testing
- CLI API endrer fra `.\scripts\bootstrap.ps1` til `devenv install`
- Konfigurasjon fra PowerShell-tables til YAML

---

### Suksesskriterier

**Funksjonelle:**
- ✅ Feature parity med PowerShell v1.0.0
- ✅ Fungerer på Windows 11, macOS Sequoia, Ubuntu 24.04
- ✅ Støtter AMD64 og ARM64
- ✅ < 10s for full provisioning (ekskludert downloads)

**Ikke-funksjonelle:**
- ✅ Binær < 20MB
- ✅ Test coverage > 80%
- ✅ Dokumentasjon fullstendig oppdatert
- ✅ CI pipeline grønn på alle platformer

**Distribusjon:**
- ✅ GitHub Releases automatisert
- ✅ `brew install vardaasen/tap/devenv` fungerer
- ✅ `winget install vardaasen.devenv` fungerer

---

### Referanser

- **Relaterte ADRer:**
  - ADR-007: Identity strategi (implementeres med Bubbletea)
  - ADR-008: Container strategi (implementeres med Go detection)
  - ADR-010: Deno over Node.js (uendret)

- **Tekniske ressurser:**
  - [Cobra CLI framework](https://github.com/spf13/cobra)
  - [Bubbletea TUI library](https://github.com/charmbracelet/bubbletea)
  - [GoReleaser](https://goreleaser.com/)

- **Eksempler på lignende prosjekter:**
  - [chezmoi](https://github.com/twpayne/chezmoi) — dotfiles manager i Go
  - [mise](https://github.com/jdx/mise) — dev tools installer i Rust
  - [devbox](https://github.com/jetpack-io/devbox) — Nix-basert, Go wrapper

---

### Historikk

- **2026-02-11:** Opprettet (status: VEDTATT)
- **2026-02-11:** Brukervalg for cross-platform fra start
  - Container: OrbStack/Podman prioritert
  - Identity: Hybrid med interaktiv TUI
  - Updates: Utsatt (manuell provision.ps1 -Upgrade tilstrekkelig)
