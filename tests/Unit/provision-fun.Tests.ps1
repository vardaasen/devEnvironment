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

    Describe "IDEs and Editors" {
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

    Describe "Music" {
        It "References resistance project" {
            $ScriptContent | Should -Match 'resistance'
        }
    }
}
