# tests/Unit/20-bindings.Tests.ps1

Describe "20-bindings" {

    BeforeAll {
        # 20-bindings depends on $Global:e from 00-history
        . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
    }

    Describe "Vi Mode" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
            $Options = Get-PSReadLineOption
        }

        It "Sets EditMode to Vi" {
            $Options.EditMode | Should -Be 'Vi'
        }

        It "Sets ViModeIndicator to Script" {
            $Options.ViModeIndicator | Should -Be 'Script'
        }

        It "Defines OnViModeChange function" {
            Get-Command OnViModeChange -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Describe "Zoxide Cache" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
            $CacheDir = "$env:LOCALAPPDATA\PowerShell\Cache"
            $ZoxideCache = "$CacheDir\zoxide.init.ps1"
        }

        It "Creates zoxide cache file" {
            if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because "Zoxide not installed"
            }
            $ZoxideCache | Should -Exist
        }

        It "Cache file is not empty" {
            if (-not (Test-Path $ZoxideCache)) {
                Set-ItResult -Skipped -Because "Cache file not created"
            }
            (Get-Item $ZoxideCache).Length | Should -BeGreaterThan 0
        }
    }

    Describe "Posh-Git" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
        }

        It "Loads posh-git if available" {
            if (-not (Get-Module -ListAvailable posh-git)) {
                Set-ItResult -Skipped -Because "posh-git not installed"
            }
            Get-Module posh-git | Should -Not -BeNullOrEmpty
        }

        It "Disables posh-git prompt status" {
            if (-not (Get-Module posh-git)) {
                Set-ItResult -Skipped -Because "posh-git not loaded"
            }
            $GitPromptSettings.EnablePromptStatus | Should -Be $false
        }
    }

    Describe "PSFzf" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
        }

        It "Loads PSFzf if available" {
            if (-not (Get-Module -ListAvailable PSFzf)) {
                Set-ItResult -Skipped -Because "PSFzf not installed"
            }
            Get-Module PSFzf | Should -Not -BeNullOrEmpty
        }
    }

    Describe "Chocolatey Lazy Load" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
        }

        It "Defines refreshenv as a function when Chocolatey is installed" {
            if (-not (Test-Path "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1")) {
                Set-ItResult -Skipped -Because "Chocolatey not installed"
            }
            Get-Command refreshenv -CommandType Function -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "refreshenv is a lazy-loader, not the real module" {
            if (-not (Get-Command refreshenv -CommandType Function -ErrorAction SilentlyContinue)) {
                Set-ItResult -Skipped -Because "refreshenv not defined"
            }
            # The dummy function contains Remove-Item - the real one doesn't
            (Get-Command refreshenv).ScriptBlock.ToString() | Should -Match 'Remove-Item'
        }
    }

    Describe "Cleanup" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/20-bindings.ps1"
        }

        It "Removes temp variables after execution" {
            Get-Variable -Name ChocoProfile -Scope Local -ErrorAction SilentlyContinue |
                Should -BeNullOrEmpty
        }
    }
}
