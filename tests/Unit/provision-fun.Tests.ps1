# tests/Unit/provision-fun.Tests.ps1

Describe "provision-fun.ps1" {
    BeforeAll {
        $ScriptPath = "$PSScriptRoot/../../scripts/provision-fun.ps1"
        $ScriptContent = Get-Content $ScriptPath -Raw
    }

    Describe "Structure" {
        It "Exists" {
            $ScriptPath | Should -Exist
        }

        It "Has CmdletBinding" {
            $ScriptContent | Should -Match 'CmdletBinding'
        }

        It "Has Upgrade switch" {
            $ScriptContent | Should -Match '\[switch\]\$Upgrade'
        }

        It "Has Test-Command helper" {
            $ScriptContent | Should -Match 'function Test-Command'
        }
    }

    Describe "LLVM / Clang" {
        It "Installs LLVM" {
            $ScriptContent | Should -Match 'LLVM'
        }

        It "Checks for clang binary" {
            $ScriptContent | Should -Match 'clang'
        }
    }

    Describe "Matrix Clients" {
        It "Installs iamb via Cargo" {
            $ScriptContent | Should -Match 'iamb'
        }

        It "Installs Cinny via Winget" {
            $ScriptContent | Should -Match 'Cinny'
        }

        It "Documents Neoment as Neovim plugin" {
            $ScriptContent | Should -Match 'Neoment'
        }
    }

    Describe "AI Tooling" {
        It "Has dedicated AI section" {
            $ScriptContent | Should -Match 'AI TOOLING'
        }

        It "References Claude Code" {
            $ScriptContent | Should -Match 'claude'
        }

        It "Installs Warp" {
            $ScriptContent | Should -Match 'Warp'
        }

        It "References Dagger" {
            $ScriptContent | Should -Match 'Dagger'
        }

        It "Documents Docker requirement" {
            $ScriptContent | Should -Match 'Docker'
        }
    }

    Describe "IDEs and Editors" {
        It "Has dedicated IDE section" {
            $ScriptContent | Should -Match 'IDEs AND EDITORS'
        }

        It "Installs JetBrains Toolbox" {
            $ScriptContent | Should -Match 'JetBrains\.Toolbox'
        }

        It "Installs VS Code" {
            $ScriptContent | Should -Match 'Microsoft\.VisualStudioCode'
        }

        It "Installs Cursor" {
            $ScriptContent | Should -Match 'Cursor'
        }
    }

    Describe "Container Strategy" {
        It "Has container detection section" {
            $ScriptContent | Should -Match 'CONTAINER RUNTIME'
        }

        It "Checks for nested virtualization" {
            $ScriptContent | Should -Match 'nested'
        }

        It "Supports remote Docker fallback" {
            $ScriptContent | Should -Match 'DOCKER_HOST'
        }
    }

    Describe "Music" {
        It "References resistance project" {
            $ScriptContent | Should -Match 'resistance'
        }
    }
}
