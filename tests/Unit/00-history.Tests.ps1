# tests/Unit/00-history.Tests.ps1

Describe "00-history" {

    BeforeAll {
        $XdgHistoryDir = "$HOME\.local\share\powershell\PSReadLine"
    }

    Describe "XDG Directory Setup" {
        It "Creates PSReadLine history directory" {
            . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
            $XdgHistoryDir | Should -Exist
        }

        It "Is idempotent - does not fail if directory already exists" {
            { . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1" } | Should -Not -Throw
        }
    }

    Describe "Global Escape Character" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
        }

        It "Defines Global:e as ASCII 27" {
            [int][char]$Global:e | Should -Be 27
        }

        It "Produces valid VT sequence" {
            $seq = "$($Global:e)[0m"
            $seq.Length | Should -Be 4
            [int][char]$seq[0] | Should -Be 27
        }
    }

    Describe "History Handler" {
        BeforeAll {
            . "$PSScriptRoot/../../.config/powershell/modules/00-history.ps1"
            $Handler = (Get-PSReadLineOption).AddToHistoryHandler
        }

        It "Filters git commands to MemoryOnly" {
            $Handler.Invoke("git status") | Should -Be 'MemoryOnly'
        }

        It "Saves non-git commands to MemoryAndFile" {
            $Handler.Invoke("Get-Process") | Should -Be 'MemoryAndFile'
        }
    }
}
