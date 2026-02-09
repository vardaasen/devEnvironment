# tests/Unit/99-aliases.Tests.ps1

Describe "99-aliases" {

    BeforeAll {
        . "$PSScriptRoot/../../.config/powershell/modules/99-aliases.ps1"
    }

    Describe "iA Writer Shortcut" {
        It "Defines ia function" {
            Get-Command ia -CommandType Function -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }
    }

    Describe "Visual Studio DevShell" {
        It "Defines Enter-DevShell function" {
            Get-Command Enter-DevShell -CommandType Function -ErrorAction SilentlyContinue |
                Should -Not -BeNullOrEmpty
        }

        It "Has vs alias pointing to Enter-DevShell" {
            $alias = Get-Alias vs -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.Definition | Should -Be 'Enter-DevShell'
        }
    }

    Describe "Choco Wrapper" {
        It "Defines choco as a function (not the raw exe)" {
            $cmd = Get-Command choco -CommandType Function -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
        }

        It "Contains admin check logic" {
            $body = (Get-Command choco -CommandType Function).ScriptBlock.ToString()
            $body | Should -Match 'Administrator'
        }

        It "Contains refreshenv call on success" {
            $body = (Get-Command choco -CommandType Function).ScriptBlock.ToString()
            $body | Should -Match 'refreshenv'
        }

        It "Defines admin action list" {
            $body = (Get-Command choco -CommandType Function).ScriptBlock.ToString()
            $body | Should -Match 'install'
            $body | Should -Match 'upgrade'
            $body | Should -Match 'uninstall'
        }
    }
}
