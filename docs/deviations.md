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

---

## AVV-004: `$HOME` er read-only i PowerShell

**Dato:** 2025-02-09
**Fase:** Testing / Pester
**Alvorlighet:** Lav

### Beskrivelse

Første versjon av `00-history.Tests.ps1` forsøkte å overstyre `$HOME` i `BeforeAll` for å isolere tester mot `TestDrive:\`:
```powershell
$Global:HOME = "TestDrive:\"
```

Alle 6 tester feilet med:
```
SessionStateUnauthorizedAccessException: Cannot overwrite variable HOME
because it is read-only or constant.
```

### Årsak

`$HOME` er en PowerShell automatisk variabel markert som read-only. Den kan ikke overstyres, heller ikke med `$Global:` scope.

### Løsning

Testet mot faktisk `$HOME` i stedet for å forsøke isolering. Akseptabelt fordi:
- Modulen kun oppretter mapper under `$HOME\.local\` (ufarlig side-effekt)
- Idempotens-testen bekrefter at rerun ikke feiler

### Lærdom

- PowerShell automatic variables (`$HOME`, `$PID`, `$PSVersionTable` etc.) er read-only
- For filsystem-isolering i Pester, mock `New-Item`/`Test-Path` heller enn å overstyre path-variabler

---

## AVV-005: NUnit XML-export krasjer på VT escape-tegn (0x1B)

**Dato:** 2025-02-09
**Fase:** Testing / Pester
**Alvorlighet:** Middels

### Beskrivelse

Pester XML-rapport (NUnit3) feilet med:
```
"Hexadecimal value 0x1B, is an invalid character"
```

Escape-tegnet `[char]27` fra `$Global:e`-testen lekket inn i testresultatet. XML-standarden tillater ikke kontroll-tegn under 0x20 (unntatt 0x09, 0x0A, 0x0D).

### Løsning

1. Tester omskrevet til å sammenlikne numerisk (`[int][char]`) i stedet for rå escape-verdier
2. XML-rapport deaktivert lokalt — kun aktiv i CI ved behov

### Lærdom

- Unngå at binære/kontroll-tegn havner i Pester assertion-verdier når XML-export er aktiv
- Hold testresultat-format separat for lokal utvikling vs CI

---

## AVV-006: Falsk grønt — sesjonsvariabel overlevde mellom testkjøringer

**Dato:** 2025-02-09
**Fase:** Testing / TDD
**Alvorlighet:** Høy

### Beskrivelse

Tester for `00-history.ps1` passerte manuelt (`Invoke-Pester`) men feilet i pre-commit hook. Tre tester ga feil:

- `$Global:e` var `0` i stedet for `27`
- VT-sekvens lengde var `3` i stedet for `4`
- History handler returnerte `MemoryAndFile` for git-kommandoer

### Årsak

Kildefilen `.config/powershell/modules/00-history.ps1` var **tom**. Testene passerte manuelt fordi `$Global:e` og history handler allerede var satt i den aktive PowerShell-sesjonen fra tidligere kjøringer.

Pre-commit kjører `pwsh -NoProfile` — en ren sesjon der variablene ikke eksisterer.

### Lærdom

- **Falsk grønt er verre enn rødt** — det gir falsk trygghet
- Pre-commit hooks fungerer som en uavhengig verifikasjon nettopp fordi de kjører isolert
- Verifiser alltid at kildefiler har innhold før du stoler på grønne tester
- Vurder å legge til en test som sjekker at kildefilen ikke er tom

### Løsning

Lagt inn faktisk kildekode i `00-history.ps1`. Bekreftet grønt i både manuell kjøring og pre-commit.

---

## AVV-007: Regex `.*` matcher ikke på tvers av linjeskift i Pester

**Dato:** 2025-02-09
**Fase:** Testing / Pester
**Alvorlighet:** Lav

### Beskrivelse

4 tester for `setup.ps1` feilet fordi regex-mønstrene brukte `.*` for å matche mellom to nøkkelord som lå på forskjellige linjer:
```powershell
# Feilet — .* stopper ved linjeskift
$SetupContent | Should -Match 'New-Item.*Directory.*\.config'
$SetupContent | Should -Match 'Command Processor.*AutoRun'
$SetupContent | Should -Match 'mklink.*settings\.json'
$SetupContent | Should -Match '\.\s*".*Microsoft\.PowerShell_profile\.ps1"'
```

### Årsak

`Get-Content -Raw` returnerer hele filen som én streng med `\n`-tegn. I .NET regex matcher `.` som standard **ikke** linjeskift (`\n`). Mønsteret `A.*B` feiler dersom A og B er på forskjellige linjer.

### Løsning

Delte opp sammensatte regex til separate assertions som matcher enkeltlinjer:
```powershell
# Passerer — hvert nøkkelord testes separat
$SetupContent | Should -Match 'New-Item -ItemType Directory'
$SetupContent | Should -Match 'GlobalConfig'
```

### Lærdom

- For flerlinjet innhold: test hvert nøkkelord separat, eller bruk `(?s)` (SingleLine-flagg) for å la `.` matche `\n`
- Enklere assertions er lettere å debugge og gir bedre feilmeldinger
