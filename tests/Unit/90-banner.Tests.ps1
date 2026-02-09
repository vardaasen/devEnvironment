# tests/Unit/90-banner.Tests.ps1

Describe "90-banner" {

    BeforeAll {
        # Banner depends on globals from 00-history and 05-checks
        . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
        . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"

        # Banner reads $Script:StartTime — simulate the profile loader
        $Script:StartTime = Get-Date
    }

    Describe "Output" {
        BeforeAll {
            $Output = . "$PSScriptRoot/../../.config/powershell/modules/90-banner.ps1" *>&1 |
                ForEach-Object { $_.ToString() }
        }

        It "Prints welcome message" {
            $Output | Should -Contain 'Welcome to your custom terminal session!'
        }

        It "Prints date line" {
            $Output -match 'Today is' | Should -Not -BeNullOrEmpty
        }

        It "Prints environment info with PS version" {
            $Output -match "PS $([regex]::Escape($Global:PSDisplay))" | Should -Not -BeNullOrEmpty
        }

        It "Prints Starship version" {
            $Output -match 'Starship' | Should -Not -BeNullOrEmpty
        }

        It "Prints modules line" {
            $Output -match 'Modules:' | Should -Not -BeNullOrEmpty
        }

        It "Prints font line" {
            $Output -match 'Font:' | Should -Not -BeNullOrEmpty
        }

        It "Prints terminal line" {
            $Output -match 'Terminal:' | Should -Not -BeNullOrEmpty
        }

        It "Prints startup time" {
            $Output -match 'Startup Time:' | Should -Not -BeNullOrEmpty
        }

        It "Prints border lines" {
            ($Output -match '={10,}').Count | Should -BeGreaterOrEqual 2
        }
    }

    Describe "Performance Warning" {
        It "Shows slow warning when startup exceeds 1000ms" {
            $Script:StartTime = (Get-Date).AddMilliseconds(-1500)
            $Output = . "$PSScriptRoot/../../.config/powershell/modules/90-banner.ps1" *>&1 |
                ForEach-Object { $_.ToString() }
            $Output -match 'Slow' | Should -Not -BeNullOrEmpty
        }

        It "Does not show slow warning for fast startup" {
            $Script:StartTime = (Get-Date).AddMilliseconds(-100)
            $Output = . "$PSScriptRoot/../../.config/powershell/modules/90-banner.ps1" *>&1 |
                ForEach-Object { $_.ToString() }
            $Output -match 'Slow' | Should -BeNullOrEmpty
        }
    }

    Describe "Border Color" {
        It "Uses green border for Windows Terminal" {
            if (-not $env:WT_SESSION) {
                Set-ItResult -Skipped -Because "Not running in Windows Terminal"
            }
            # If we get here, TermHost is Windows Terminal
            $Global:TermHost | Should -Be 'Windows Terminal'
        }

        It "Uses magenta border for WezTerm" {
            if (-not $env:WEZTERM_EXECUTABLE) {
                Set-ItResult -Skipped -Because "Not running in WezTerm"
            }
            $Global:TermHost | Should -Be 'WezTerm (GPU)'
        }
    }
}
