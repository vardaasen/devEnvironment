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
