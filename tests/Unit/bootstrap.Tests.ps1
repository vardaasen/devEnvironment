# tests/Unit/bootstrap.Tests.ps1

Describe "bootstrap.ps1" {

    BeforeAll {
        $BootstrapPath = "$PSScriptRoot/../../scripts/bootstrap.ps1"
        $BootstrapContent = Get-Content $BootstrapPath -Raw
    }

    Describe "File Structure" {
        It "Exists and is not empty" {
            $BootstrapPath | Should -Exist
            $BootstrapContent | Should -Not -BeNullOrEmpty
        }

        It "Uses PSScriptRoot for repo root" {
            $BootstrapContent | Should -Match 'PSScriptRoot'
        }
    }

    Describe "Privilege Check" {
        It "Checks for Administrator role" {
            $BootstrapContent | Should -Match 'WindowsBuiltInRole.*Administrator'
        }

        It "Warns if not running as admin" {
            $BootstrapContent | Should -Match 'Administrator privileges required'
        }
    }

    Describe "Sanity Check" {
        It "Verifies setup.ps1 exists in repo root" {
            $BootstrapContent | Should -Match 'Test-Path.*setup\.ps1'
        }

        It "Errors if setup.ps1 is missing" {
            $BootstrapContent | Should -Match 'setup\.ps1 not found'
        }
    }

    Describe "XDG Enforcement" {
        It "Sets XDG_CONFIG_HOME" {
            $BootstrapContent | Should -Match 'XDG_CONFIG_HOME'
        }

        It "Targets .config under USERPROFILE" {
            $BootstrapContent | Should -Match '\.config'
        }

        It "Sets environment variable at User scope" {
            $BootstrapContent | Should -Match "SetEnvironmentVariable.*User"
        }
    }

    Describe "Phase 1: Configuration" {
        It "Calls setup.ps1" {
            $BootstrapContent | Should -Match '\\setup\.ps1'
        }

        It "Uses ErrorAction Stop" {
            $BootstrapContent | Should -Match 'ErrorAction Stop'
        }
    }

    Describe "Phase 2: Provisioning" {
        It "Calls provision.ps1" {
            $BootstrapContent | Should -Match '\\provision\.ps1'
        }

        It "Does not break on provisioning failure" {
            $BootstrapContent | Should -Match 'Provisioning Phase Failed'
        }
    }

    Describe "Execution Order" {
        It "Runs setup before provision" {
            $setupIndex = $BootstrapContent.IndexOf('PHASE 1')
            $provisionIndex = $BootstrapContent.IndexOf('PHASE 2')
            $setupIndex | Should -BeLessThan $provisionIndex
        }

        It "Sets XDG before setup" {
            $xdgIndex = $BootstrapContent.IndexOf('ENFORCE XDG')
            $setupIndex = $BootstrapContent.IndexOf('PHASE 1')
            $xdgIndex | Should -BeLessThan $setupIndex
        }
    }
}
