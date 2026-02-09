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

---

## AVV-003: `testResults.xml` spores av Git tross `.gitignore`

**Dato:** 2025-02-09
**Fase:** Infrastruktur
**Alvorlighet:** Lav

### Beskrivelse

Pester-konfigurasjonen i `.pester.psd1` bruker `OutputPath = './TestResults/results.xml'` (mappe med stor T), men Pester genererte `testResults.xml` i rot-mappen. Filen ble staget og pushet før `.gitignore` fanget den opp.

Pre-commit hookene `end-of-file-fixer` og `mixed-line-ending` feilet gjentatte ganger på denne filen.

### Årsak

- Case-mismatch mellom `.gitignore` (`TestResults/`) og faktisk output (`testResults.xml` i rot)
- Filen ble commitet før ignore-regelen var på plass — Git tracker filer som allerede er commitet uansett `.gitignore`

### Løsning
```powershell
git rm --cached testResults.xml
Add-Content .gitignore "testResults.xml"
```

### Lærdom

- Kjør `Invoke-Pester` og sjekk hvor output havner *før* første commit
- Ignorer både mappe og rot-nivå artefakter i `.gitignore`
