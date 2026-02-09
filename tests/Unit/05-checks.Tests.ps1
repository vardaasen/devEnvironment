# tests/Unit/05-checks.Tests.ps1

Describe "05-checks" {

    BeforeAll {
        # Clean globals before sourcing
        Remove-Variable -Name PSDisplay, PSEnv, TermHost, TermFont,
            StarshipVer, PSReadlineVer -Scope Global -ErrorAction SilentlyContinue
    }

    Describe "Environment Detection" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"
        }

        It "Sets PSDisplay to a version string" {
            $Global:PSDisplay | Should -Not -BeNullOrEmpty
            $Global:PSDisplay | Should -Match '^\d+\.\d+\.\d+'
        }

        It "Sets PSEnv to Core or Desktop" {
            $Global:PSEnv | Should -BeIn @('Core', 'Desktop')
        }

        It "Detects current PS edition correctly" {
            if ($PSVersionTable.PSEdition -eq 'Core') {
                $Global:PSEnv | Should -Be 'Core'
            } else {
                $Global:PSEnv | Should -Be 'Desktop'
            }
        }
    }

    Describe "Terminal Host Detection" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"
        }

        It "Sets TermHost to a known value" {
            $Global:TermHost | Should -BeIn @(
                'Windows Terminal',
                'WezTerm (GPU)',
                'Windows Console Host'
            )
        }

        It "Detects Windows Terminal when WT_SESSION is set" {
            if ($env:WT_SESSION) {
                $Global:TermHost | Should -Be 'Windows Terminal'
            } else {
                Set-ItResult -Skipped -Because "Not running in Windows Terminal"
            }
        }

        It "Detects WezTerm when WEZTERM_EXECUTABLE is set" {
            if ($env:WEZTERM_EXECUTABLE) {
                $Global:TermHost | Should -Be 'WezTerm (GPU)'
            } else {
                Set-ItResult -Skipped -Because "Not running in WezTerm"
            }
        }
    }

    Describe "Font Detection" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"
        }

        It "Sets TermFont to a non-empty string" {
            $Global:TermFont | Should -Not -BeNullOrEmpty
        }

        It "Returns Client Managed for modern terminals" {
            if ($env:WT_SESSION -or $env:WEZTERM_EXECUTABLE) {
                $Global:TermFont | Should -Be 'Client Managed'
            } else {
                Set-ItResult -Skipped -Because "Not running in a modern terminal"
            }
        }
    }

    Describe "Cache Logic" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"
        }

        It "Sets StarshipVer global" {
            $Global:StarshipVer | Should -Not -BeNullOrEmpty
        }

        It "Sets PSReadlineVer global" {
            $Global:PSReadlineVer | Should -Not -BeNullOrEmpty
        }

        It "Creates cache file in TEMP" {
            "$env:TEMP\terminal_system_cache.json" | Should -Exist
        }

        It "Cache file contains valid JSON" {
            $json = Get-Content "$env:TEMP\terminal_system_cache.json" -Raw
            { $json | ConvertFrom-Json } | Should -Not -Throw
        }

        It "Cache contains expected keys" {
            $data = Get-Content "$env:TEMP\terminal_system_cache.json" -Raw | ConvertFrom-Json
            $data.PSObject.Properties.Name | Should -Contain 'StarshipVer'
            $data.PSObject.Properties.Name | Should -Contain 'PSReadlineVer'
        }
    }

    Describe "DotNet Info" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/05-checks.ps1"
        }

        It "Get-DotNetRuntimeInfo returns FrameworkDescription" {
            $info = Get-DotNetRuntimeInfo
            $info.FrameworkDescription | Should -Not -BeNullOrEmpty
        }

        It "Get-DotNetRuntimeInfo returns CLRVersion" {
            $info = Get-DotNetRuntimeInfo
            $info.CLRVersion | Should -Not -BeNullOrEmpty
        }
    }
}
