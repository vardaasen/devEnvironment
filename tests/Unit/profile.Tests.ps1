# tests/Unit/profile.Tests.ps1

Describe "Microsoft.PowerShell_profile" {

    BeforeAll {
        $ProfilePath = "$PSScriptRoot/../../.config/powershell/Microsoft.PowerShell_profile.ps1"
        $ProfileContent = Get-Content $ProfilePath -Raw
    }

    Describe "File Structure" {
        It "Exists and is not empty" {
            $ProfilePath | Should -Exist
            $ProfileContent | Should -Not -BeNullOrEmpty
        }

        It "Sets StartTime for performance tracking" {
            $ProfileContent | Should -Match 'StartTime'
        }

        It "Initializes ModulePerformance tracking" {
            $ProfileContent | Should -Match 'ModulePerformance'
        }

        It "Resolves modules directory from PSScriptRoot" {
            $ProfileContent | Should -Match 'PSScriptRoot'
            $ProfileContent | Should -Match 'modules'
        }
    }

    Describe "Module Loading" {
        It "Uses Get-ChildItem to discover modules" {
            $ProfileContent | Should -Match 'Get-ChildItem'
        }

        It "Filters for .ps1 files" {
            $ProfileContent | Should -Match '\.ps1'
        }

        It "Sorts modules by name for deterministic order" {
            $ProfileContent | Should -Match 'Sort-Object\s+Name'
        }

        It "Dot-sources each module" {
            $ProfileContent | Should -Match '\.\s+\$_\.FullName'
        }
    }

    Describe "Performance Tracking" {
        It "Records duration per module" {
            $ProfileContent | Should -Match 'TotalMilliseconds'
        }

        It "Cleans up loader variables" {
            $ProfileContent | Should -Match 'Remove-Variable'
        }
    }

    Describe "Integration" {
        BeforeAll {
            # Simulate what the profile does
            $Script:StartTime = Get-Date
            $Global:ModulePerformance = [Ordered]@{}
            . $ProfilePath
        }

        It "Loads all expected modules" {
            $Global:ModulePerformance.Keys | Should -Contain '00-history.ps1'
            $Global:ModulePerformance.Keys | Should -Contain '05-checks.ps1'
            $Global:ModulePerformance.Keys | Should -Contain '10-visuals.ps1'
            $Global:ModulePerformance.Keys | Should -Contain '20-bindings.ps1'
            $Global:ModulePerformance.Keys | Should -Contain '90-banner.ps1'
            $Global:ModulePerformance.Keys | Should -Contain '99-aliases.ps1'
        }

        It "Records timing for each module" {
            foreach ($key in $Global:ModulePerformance.Keys) {
                $Global:ModulePerformance[$key] | Should -Match 'ms$'
            }
        }

        It "Loads modules in correct order" {
            $keys = @($Global:ModulePerformance.Keys)
            $keys[0] | Should -Be '00-history.ps1'
            $keys[-1] | Should -Be '99-aliases.ps1'
        }
    }
}
