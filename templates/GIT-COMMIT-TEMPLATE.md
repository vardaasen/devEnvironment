# Git Commit Message Template

## Format

```
<type>: <summary> [— ADR/AVV reference]

[valgfri body med mer kontekst]

[valgfri footer: Co-Authored-By, Resolves, etc.]
```

---

## Type prefixes

### Primære typer (mest brukt)

- **feat:** — Ny funksjonalitet (nytt script, modul, verktøy, Layer addition)
  - Eksempel: `feat: add provision-fun.ps1 with AI tooling and container strategy`

- **fix:** — Bugfiks (løser AVV, retter oppførsel)
  - Eksempel: `fix: resolve PSScriptRoot path after scripts/ relocation (AVV-010)`

- **docs:** — Dokumentasjonsendringer (README, ADR, progress, deviations)
  - Eksempel: `docs: ADR-006 identity architecture — deferred pending env strategy`

- **refactor:** — Kodeomstrukturering uten oppførselsendring
  - Eksempel: `refactor: extract tool installation logic to shared function`

### Sekundære typer

- **ci:** — CI/GitHub Actions endringer
  - Eksempel: `ci: add PSScriptAnalyzer as non-blocking CI job`

- **chore:** — Repository vedlikehold (ignore rules, opprydding)
  - Eksempel: `chore: add ._* to gitignore for macOS artifacts`

- **test:** — Test-relaterte endringer (nye tester, test-fixes)
  - Eksempel: `test: add integration tests for bootstrap orchestration`

- **perf:** — Ytelsesoptimaliseringer
  - Eksempel: `perf: cache starship init with 24hr TTL`

- **style:** — Formatering, whitespace (ikke funksjonell endring)
  - Eksempel: `style: fix trailing whitespace in provision.ps1`

- **build:** — Build system endringer (ikke CI, men f.eks. package.json, go.mod)
  - Eksempel: `build: update go dependencies`

- **revert:** — Revertering av tidligere commit
  - Eksempel: `revert: "feat: add experimental feature X"`

---

## Summary guidelines

- **Maksimal lengde:** 72 tegn (ideelt under 50)
- **Imperativ form:** "add feature", ikke "added feature" eller "adds feature"
- **Ikke punktum på slutten**
- **Små bokstaver etter colon:** `feat: add tool` ikke `feat: Add tool`
- **Vær spesifikk:** "fix login validation" bedre enn "fix bug"

---

## ADR/AVV referanser

Hvis commiten er direkte relatert til en beslutning eller avvik:

```
feat: implement hybrid identity strategy — ADR-007

docs: document nested virtualization detection issue — AVV-011
```

---

## Body (valgfritt)

Bruk body når summary ikke er nok til å forklare **hvorfor** endringen gjøres.

**Format:**
- Blank linje etter summary
- Wrapping på 72 tegn
- Fokuser på "hvorfor" og "hva", ikke "hvordan" (koden viser "hvordan")

**Eksempel:**

```
feat: add automated Docker host detection

Detects nested virtualization capability via Win32_ComputerSystem.
On Parallels/VMware (no nested virt), guides user to remote Docker
via SSH tunnel instead of attempting local Docker Desktop install.

Resolves ADR-008 container strategy decision.
```

---

## Footer (valgfritt)

### Co-Authored-By (AI assistanse)

Når Claude Code eller annen AI har bidratt:

```
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Issue tracking

```
Resolves #42
Closes #123
Refs #456
```

### Breaking changes

```
BREAKING CHANGE: removes support for PowerShell v5
```

---

## Eksempler fra prosjektet

### Feature (ny funksjonalitet)

```
feat: add provision-fun.ps1 with AI tooling and container strategy
```

### Fix (bugfiks med AVV referanse)

```
fix: resolve PSScriptRoot path after scripts/ relocation (AVV-010)
```

### Dokumentasjon (ADR oppdatering)

```
docs: ADR-006 identity architecture — deferred pending env strategy
```

### CI/CD endring

```
ci: add PSScriptAnalyzer as non-blocking CI job
```

### Refaktorering

```
refactor: extract tool table iteration to reusable function
```

### Med body og footer

```
feat: implement 24hr cache for Starship version check

Reduces profile load time by ~200ms on cold start. Cache stored
in $env:TEMP with JSON serialization. Checks if cache is stale
before running slow `starship --version` command.

Addresses performance concern raised in AVV-006.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Anti-patterns (unngå)

❌ **Vage beskrivelser:**
```
fix: stuff
docs: update
chore: changes
```

❌ **For lange summary:**
```
feat: add comprehensive multi-platform container orchestration system with Docker Desktop WSL2 backend integration and remote SSH tunnel fallback (142 chars)
```

❌ **Feil imperativ form:**
```
fixed bug          # fortid
fixing bug         # pågående
fixes bug          # tredjeperson
```

✅ **Riktig:**
```
fix: correct validation in login form
```

❌ **Kapitalisering etter colon:**
```
feat: Add new feature
```

✅ **Riktig:**
```
feat: add new feature
```

---

## Konvensjon for merge commits

Hvis du merger branches manuelt (ikke squash):

```
merge: integrate feature-branch-name into main

[valgfri body med kontekst]
```

---

## Pre-commit hook reminder

Prosjektet har `.pre-commit-config.yaml` som validerer:
- Trailing whitespace
- End-of-file fixer
- YAML syntax
- Mixed line endings
- Pester tests

Commit message formatet valideres **ikke** automatisk (vurder `commitlint` hvis strengere enforcing ønskes).

---

## Signing (SSH)

Alle commits skal signeres med SSH nøkkel (per ADR-007 Level 2):

```powershell
git config --global commit.gpgsign true
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
```

Verify signering:
```powershell
git log --show-signature -1
```

---

## Oppsummering

**God commit message anatomie:**

1. **Type prefix** som beskriver *hva slags* endring
2. **Kort summary** som beskriver *hva* som ble gjort
3. **Valgfri ADR/AVV referanse** hvis relevant
4. **Valgfri body** som forklarer *hvorfor*
5. **Valgfri footer** for Co-Authors, issue refs, breaking changes

**Mål:** Gjøre git historikken selvdokumenterende og semantisk søkbar.
