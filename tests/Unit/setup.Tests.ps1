# tests/Unit/setup.Tests.ps1

Describe "setup.ps1" {

    BeforeAll {
        $SetupPath = "$PSScriptRoot/../../scripts/setup.ps1"
        $SetupContent = Get-Content $SetupPath -Raw
    }

    Describe "File Structure" {
        It "Exists and is not empty" {
            $SetupPath | Should -Exist
            $SetupContent | Should -Not -BeNullOrEmpty
        }

        It "Uses PSScriptRoot for repo root" {
            $SetupContent | Should -Match 'PSScriptRoot'
        }

        It "Targets .config directory under USERPROFILE" {
            $SetupContent | Should -Match '\.config'
        }
    }

    Describe "Symlink Logic" {
        It "Creates .config directory if missing" {
            $SetupContent | Should -Match 'New-Item -ItemType Directory'
            $SetupContent | Should -Match 'GlobalConfig'
        }

        It "Iterates over folders in repo .config" {
            $SetupContent | Should -Match 'Get-ChildItem.*\.config.*Directory'
        }

        It "Skips Clink from standard symlink loop" {
            $SetupContent | Should -Match 'clink.*continue'
        }

        It "Creates symbolic links" {
            $SetupContent | Should -Match 'New-Item.*SymbolicLink'
        }

        It "Backs up existing non-link directories" {
            $SetupContent | Should -Match 'Rename-Item.*\.bak'
        }

        It "Skips if symlink already points correctly" {
            $SetupContent | Should -Match 'LinkType.*SymbolicLink|Junction'
        }
    }

    Describe "Clink Special Handling" {
        It "Creates Clink directory as local container" {
            $SetupContent | Should -Match 'ClinkLocal'
        }

        It "Uses HardLink for clink_settings" {
            $SetupContent | Should -Match 'New-Item.*HardLink.*clink_settings'
        }

        It "Uses Junction for clink scripts" {
            $SetupContent | Should -Match 'New-Item.*Junction.*scripts'
        }
    }

    Describe "PowerShell Shim" {
        It "Creates shim for WindowsPowerShell profile" {
            $SetupContent | Should -Match 'WindowsPowerShell'
        }

        It "Creates shim for PowerShell Core profile" {
            $SetupContent | Should -Match 'Documents\\PowerShell'
        }

        It "Shim dot-sources the master profile" {
            $SetupContent | Should -Match 'MasterProfile'
            $SetupContent | Should -Match 'Set-Content.*Value'
        }

        It "Skips if shim already contains correct content" {
            $SetupContent | Should -Match 'continue'
        }
    }

    Describe "CMD AutoRun" {
        It "Sets registry key for Command Processor" {
            $SetupContent | Should -Match 'Command Processor'
        }

        It "Sets AutoRun property" {
            $SetupContent | Should -Match 'AutoRun'
        }

        It "Points to cmd.bat in .config" {
            $SetupContent | Should -Match 'cmd\\cmd\.bat'
        }
    }

    Describe "Windows Terminal Config" {
        It "Handles both stable and preview WT paths" {
            $SetupContent | Should -Match 'Microsoft\.WindowsTerminal_'
            $SetupContent | Should -Match 'Microsoft\.WindowsTerminalPreview_'
        }

        It "Creates symlink via mklink" {
            $SetupContent | Should -Match 'mklink'
        }

        It "Links settings.json" {
            $SetupContent | Should -Match 'settings\.json'
        }
    }
}
