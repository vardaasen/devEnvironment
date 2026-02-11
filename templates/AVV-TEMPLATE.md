# AVV-XXX: [Kortfattet beskrivelse av avviket]

**Alvorlighetsgrad:** [LOW / MEDIUM / HIGH / CRITICAL]
**Fase:** [Infrastructure / Development / Testing / CI / Deployment]
**Oppdaget:** YYYY-MM-DD
**Løst:** YYYY-MM-DD eller "Pågående"

## Symptom

[Hva var det observerbare symptomet? Hva gikk galt?]

```
[Feilmelding eller uventet oppførsel hvis relevant]
```

## Rotårsak

[Hva var den underliggende årsaken til avviket?]

**Teknisk forklaring:**
[Detaljert beskrivelse av hvorfor det skjedde]

**Hvorfor ble dette ikke fanget opp tidligere?**
- [Årsak 1: f.eks. manglende test coverage]
- [Årsak 2: f.eks. edge case ikke vurdert]

## Kontekst

[Hva var situasjonen da avviket oppstod?]

- **Miljø:** [Windows 11, macOS Sequoia, Ubuntu 24.04, etc.]
- **Versjoner:** [Relevante versjoner av tools/runtimes]
- **Forutsetninger:** [Hva som var antatt eller forventet]

## Løsning

[Hvordan ble problemet løst?]

### Umiddelbar fiks

```powershell
# Kode eller kommando som løste problemet
```

### Langsiktig tiltak

- [ ] [Preventiv tiltak 1]
- [ ] [Preventiv tiltak 2]
- [ ] [Dokumentasjon oppdatert]

## Læring

**Hva lærte vi:**
1. [Konkret læring 1]
2. [Konkret læring 2]

**Forbedringer implementert:**
- [Test/validering lagt til]
- [Dokumentasjon forbedret]
- [Kodeendring for å forhindre repeat]

**Potensielt relaterte risikoer:**
- [Andre steder i kodebasen som kan ha samme problem]

## Reproduksjon

[Hvis relevant: steg for å reprodusere avviket]

1. [Steg 1]
2. [Steg 2]
3. [Forventet resultat]
4. [Faktisk resultat]

## Referanser

- **Commit:** [git SHA hvis relevant]
- **Relaterte ADRer:** [ADR-XXX hvis relevant]
- **Eksterne kilder:** [Stack Overflow, GitHub issues, etc.]
- **Testfil:** [Filnavn til test som nå dekker dette]

## Kategorisering

**Type avvik:**
- [ ] Konfigurasjonsfeil
- [ ] Testfeil (false positive/negative)
- [ ] Platform-spesifikk oppførsel
- [ ] Dependencies/versjonering
- [ ] Sikkerhetsproblem
- [ ] Dokumentasjonsfeil
- [ ] Antagelse feil

**Påvirkning:**
- [ ] Kun utviklingsmiljø
- [ ] Påvirker CI/CD
- [ ] Påvirker produksjonsutrulling
- [ ] Påvirker sluttbruker
