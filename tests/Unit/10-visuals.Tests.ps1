# tests/Unit/10-visuals.Tests.ps1

Describe "10-visuals" {

    BeforeAll {
        # 10-visuals depends on $Global:e from 00-history
        . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
    }

    Describe "Starship Cache" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/10-visuals.ps1"
            $CacheDir = "$env:LOCALAPPDATA\PowerShell\Cache"
            $StarshipCache = "$CacheDir\starship.init.ps1"
        }

        It "Creates cache directory" {
            $CacheDir | Should -Exist
        }

        It "Creates starship init cache file" {
            if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because "Starship not installed"
            }
            $StarshipCache | Should -Exist
        }

        It "Cache file is not empty" {
            if (-not (Test-Path $StarshipCache)) {
                Set-ItResult -Skipped -Because "Cache file not created"
            }
            (Get-Item $StarshipCache).Length | Should -BeGreaterThan 0
        }

        It "Sets STARSHIP_CONFIG env var" {
            $ENV:STARSHIP_CONFIG | Should -Not -BeNullOrEmpty
            $ENV:STARSHIP_CONFIG | Should -BeLike "*starship.toml"
        }
    }

    Describe "PSReadLine Color Map" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/10-visuals.ps1"
            $Options = Get-PSReadLineOption
        }

        It "Sets command color" {
            $Options.CommandColor | Should -Not -BeNullOrEmpty
        }

        It "Sets string color" {
            $Options.StringColor | Should -Not -BeNullOrEmpty
        }

        It "Sets variable color" {
            $Options.VariableColor | Should -Not -BeNullOrEmpty
        }

        It "Sets keyword color" {
            $Options.KeywordColor | Should -Not -BeNullOrEmpty
        }

        It "Sets inline prediction color" {
            $Options.InlinePredictionColor | Should -Not -BeNullOrEmpty
        }
    }

    Describe "Cleanup" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/10-visuals.ps1"
        }

        It "Removes TempColorMap after execution" {
            Get-Variable -Name TempColorMap -Scope Local -ErrorAction SilentlyContinue |
                Should -BeNullOrEmpty
        }
    }
}
