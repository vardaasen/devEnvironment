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
**Status:** Under vurdering

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

## ADR-006: Identitets- og autentiseringsarkitektur

**Dato:** 2025-02-10
**Status:** Under utredning

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

Utsatt. Implementerer ikke secrets-håndtering i dette prosjektet ennå. Trenger å lande på miljøstrategi først, da den påvirker resten av designet.

Grunnleggende `.env.template` og onboarding-dokumentasjon kan legges til som midlertidig løsning uten å låse arkitekturen.
