# tests/Unit/platform.Tests.ps1

Describe "platform.ps1" {

    BeforeAll {
        $PlatformPath = "$PSScriptRoot/../../scripts/platform.ps1"
        $PlatformContent = Get-Content $PlatformPath -Raw
    }

    Describe "File Structure" {
        It "Exists and is not empty" {
            $PlatformPath | Should -Exist
            $PlatformContent | Should -Not -BeNullOrEmpty
        }

        It "Defines Test-Command helper" {
            $PlatformContent | Should -Match 'function Test-Command'
        }

        It "Defines Install-Font-From-Url helper" {
            $PlatformContent | Should -Match 'function Install-Font-From-Url'
        }
    }

    Describe "Package Managers" {
        It "Checks for Chocolatey" {
            $PlatformContent | Should -Match 'Test-Command.*choco'
        }

        It "Installs Chocolatey if missing" {
            $PlatformContent | Should -Match 'Installing Chocolatey'
            $PlatformContent | Should -Match 'chocolatey\.org/install\.ps1'
        }

        It "Upgrades Chocolatey if present" {
            $PlatformContent | Should -Match 'choco upgrade chocolatey'
        }

        It "Checks for Winget" {
            $PlatformContent | Should -Match 'Test-Command.*winget'
        }
    }

    Describe "Rust Toolchain" {
        It "Checks for cargo" {
            $PlatformContent | Should -Match 'Test-Command.*cargo'
        }

        It "Installs Rustup if missing" {
            $PlatformContent | Should -Match 'rustup-init\.exe'
        }

        It "Updates toolchain if present" {
            $PlatformContent | Should -Match 'rustup update'
        }

        It "Adds cargo bin to PATH" {
            $PlatformContent | Should -Match '\.cargo\\bin'
        }
    }

    Describe "Core Runtimes" {
        It "Installs PowerShell Core" {
            $PlatformContent | Should -Match 'Microsoft\.PowerShell'
        }

        It "Installs Git" {
            $PlatformContent | Should -Match 'Git\.Git'
        }
    }

    Describe "Fonts" {
        It "Installs iA Writer Duo font" {
            $PlatformContent | Should -Match 'iAWriterDuoV'
        }

        It "Installs Monaspace Radon font" {
            $PlatformContent | Should -Match 'MonaspaceRadonVar'
        }

        It "Checks for existing fonts before downloading" {
            $PlatformContent | Should -Match 'FontFileFilter.*found'
        }

        It "Copies fonts to Windows Fonts directory" {
            $PlatformContent | Should -Match 'SystemRoot.*Fonts'
        }

        It "Registers fonts in registry" {
            $PlatformContent | Should -Match 'Windows NT\\CurrentVersion\\Fonts'
        }

        It "Cleans up temp directory after install" {
            $PlatformContent | Should -Match 'Remove-Item.*TempDir'
        }
    }
}
