# tests/Unit/provision.Tests.ps1

Describe "provision.ps1" {

    BeforeAll {
        $ProvisionPath = "$PSScriptRoot/../../scripts/provision.ps1"
        $ProvisionContent = Get-Content $ProvisionPath -Raw
    }

    Describe "File Structure" {
        It "Exists and is not empty" {
            $ProvisionPath | Should -Exist
            $ProvisionContent | Should -Not -BeNullOrEmpty
        }

        It "Accepts Upgrade switch parameter" {
            $ProvisionContent | Should -Match '\[switch\]\$Upgrade'
        }

        It "Defines Test-Command helper" {
            $ProvisionContent | Should -Match 'function Test-Command'
        }
    }

    Describe "Cargo Crates" {
        It "Checks for cargo before installing" {
            $ProvisionContent | Should -Match 'Test-Command.*cargo'
        }

        It "Defines a crate list" {
            $ProvisionContent | Should -Match 'CargoCrates'
        }

        It "Includes eza" {
            $ProvisionContent | Should -Match 'eza'
        }

        It "Includes ripgrep" {
            $ProvisionContent | Should -Match 'ripgrep'
        }

        It "Includes fd-find" {
            $ProvisionContent | Should -Match 'fd-find'
        }

        It "Includes jj-cli" {
            $ProvisionContent | Should -Match 'jj-cli'
        }

        It "Includes uv" {
            $ProvisionContent | Should -Match '"uv"'
        }

        It "Maps jj-cli to jj binary name" {
            $ProvisionContent | Should -Match 'jj-cli.*jj'
        }

        It "Maps fd-find to fd binary name" {
            $ProvisionContent | Should -Match 'fd-find.*fd'
        }

        It "Uses --locked flag for cargo install" {
            $ProvisionContent | Should -Match 'cargo install.*--locked'
        }
    }

    Describe "Winget Apps" {
        It "Defines WingetApps list" {
            $ProvisionContent | Should -Match 'WingetApps'
        }

        It "Includes Windows Terminal" {
            $ProvisionContent | Should -Match 'Microsoft\.WindowsTerminal'
        }

        It "Includes Starship" {
            $ProvisionContent | Should -Match 'Starship\.Starship'
        }

        It "Includes WezTerm" {
            $ProvisionContent | Should -Match 'wez\.wezterm'
        }

        It "Includes Neovim" {
            $ProvisionContent | Should -Match 'Neovim\.Neovim'
        }

        It "Includes Clink" {
            $ProvisionContent | Should -Match 'chrisant996\.Clink'
        }

        It "Uses silent install flags" {
            $ProvisionContent | Should -Match '--silent'
            $ProvisionContent | Should -Match '--accept-package-agreements'
        }
    }

    Describe "Chocolatey Tools" {
        It "Defines ChocoTools list" {
            $ProvisionContent | Should -Match 'ChocoTools'
        }

        It "Includes make" {
            $ProvisionContent | Should -Match "Pkg = .make."
        }

        It "Includes mingw (gcc)" {
            $ProvisionContent | Should -Match 'mingw'
        }

        It "Uses -y flag for unattended install" {
            $ProvisionContent | Should -Match 'choco install.*-y'
        }
    }

    Describe "Upgrade Logic" {
        It "Checks Upgrade flag before updating cargo crates" {
            $ProvisionContent | Should -Match 'if \(\$Upgrade\)'
        }

        It "Checks Upgrade flag for winget apps" {
            $ProvisionContent | Should -Match 'winget upgrade'
        }

        It "Checks Upgrade flag for choco tools" {
            $ProvisionContent | Should -Match 'choco upgrade'
        }
    }

    Describe "Idempotency" {
        It "Skips already installed cargo crates" {
            $ProvisionContent | Should -Match 'Test-Command \$BinaryName'
        }

        It "Skips already installed winget apps" {
            $ProvisionContent | Should -Match 'Test-Command \$app\.Cmd'
        }

        It "Skips already installed choco tools" {
            $ProvisionContent | Should -Match 'Test-Command \$tool\.Cmd'
        }
    }
}
