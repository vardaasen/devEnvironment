# Avvikslogg

## AVV-001: `pre-commit` ikke i PATH etter `uv tool install`

**Dato:** 2025-02-09
**Fase:** Infrastruktur / Testrammeverk
**Alvorlighet:** Lav

### Beskrivelse

Etter installasjon av pre-commit med `uv tool install pre-commit` ble kommandoen ikke gjenkjent av PowerShell:

```
pre-commit:: The term 'pre-commit:' is not recognized as a name of a cmdlet,
function, script file, or executable program.
```

### Årsak

`uv tool install` plasserer binærfiler i `$env:USERPROFILE\.local\bin`, som ikke er i systemets PATH som standard.

### Løsning

To alternativer ble identifisert:

**A) Permanent PATH-utvidelse (valgt):**

```powershell
[System.Environment]::SetEnvironmentVariable('Path',
    [System.Environment]::GetEnvironmentVariable('Path', 'User') + ";$env:USERPROFILE\.local\bin",
    'User')
```

**B) Bruk `uvx` i stedet for direkte kall:**

```powershell
uvx pre-commit install
uvx pre-commit run --all-files
```

### Konsekvens for prosjektet

- `provision.ps1` bør inkludere `$env:USERPROFILE\.local\bin` i PATH dersom `uv` er installert
- CI-workflow bruker `pip`/`uvx` direkte og er ikke berørt
- Dokumentert her for reproduserbarhet ved ny maskinoppsett

---

## AVV-002: macOS preview-artefakter i Windows via Parallels

**Dato:** 2025-02-09
**Fase:** Infrastruktur
**Alvorlighet:** Lav

### Beskrivelse

Når filer forhåndsvises med macOS Quick Look (spacebar) fra Parallels-delt filsystem, opprettes midlertidige filer med prefiks `._` (f.eks. `._decisions.md`). Disse er macOS resource forks og skal ikke spores i Git.

### Løsning

Lagt til `._*` i `.gitignore`.
