# tests/Unit/config.Tests.ps1

Describe "Configuration Files" {

    Describe "Starship" {
        It "starship.toml exists and has schema" {
            $f = "$PSScriptRoot/../../.config/starship/starship.toml"
            $f | Should -Exist
            Get-Content $f -Raw | Should -Match 'starship\.rs/config-schema'
        }

        It "starship_wsl.toml exists and has schema" {
            $f = "$PSScriptRoot/../../.config/starship/starship_wsl.toml"
            $f | Should -Exist
            Get-Content $f -Raw | Should -Match 'starship\.rs/config-schema'
        }

        It "Disables package module" {
            Get-Content "$PSScriptRoot/../../.config/starship/starship.toml" -Raw |
                Should -Match 'disabled = true'
        }

        It "Sets custom success symbol" {
            Get-Content "$PSScriptRoot/../../.config/starship/starship.toml" -Raw |
                Should -Match 'success_symbol'
        }
    }

    Describe "WezTerm" {
        It "wezterm.lua exists" {
            "$PSScriptRoot/../../.config/wezterm/wezterm.lua" | Should -Exist
        }

        It "Returns a config object" {
            Get-Content "$PSScriptRoot/../../.config/wezterm/wezterm.lua" -Raw |
                Should -Match 'return config'
        }

        It "Uses pwsh as default shell" {
            Get-Content "$PSScriptRoot/../../.config/wezterm/wezterm.lua" -Raw |
                Should -Match 'pwsh\.exe'
        }

        It "Configures Monaspace Radon font" {
            Get-Content "$PSScriptRoot/../../.config/wezterm/wezterm.lua" -Raw |
                Should -Match 'Monaspace Radon'
        }

        It "Uses GPU rendering" {
            Get-Content "$PSScriptRoot/../../.config/wezterm/wezterm.lua" -Raw |
                Should -Match 'OpenGL'
        }
    }

    Describe "Windows Terminal" {
        It "settings.json exists" {
            "$PSScriptRoot/../../.config/terminal/settings.json" | Should -Exist
        }

        It "Has valid JSONC structure" {
            $content = Get-Content "$PSScriptRoot/../../.config/terminal/settings.json" -Raw
            $content | Should -Match '"profiles"'
            $content | Should -Match '"schemes"'
            $content | Should -Match '"defaultProfile"'
        }

        It "Defines color schemes" {
            Get-Content "$PSScriptRoot/../../.config/terminal/settings.json" -Raw |
                Should -Match '"schemes"'
        }

        It "Has Frost scheme" {
            Get-Content "$PSScriptRoot/../../.config/terminal/settings.json" -Raw |
                Should -Match '"Frost"'
        }

        It "Has Retro scheme" {
            Get-Content "$PSScriptRoot/../../.config/terminal/settings.json" -Raw |
                Should -Match '"Retro"'
        }

        It "Sets PowerShell Core as default profile" {
            Get-Content "$PSScriptRoot/../../.config/terminal/settings.json" -Raw |
                Should -Match 'pwsh\.exe'
        }
    }

    Describe "Clink" {
        It "clink_settings exists" {
            "$PSScriptRoot/../../.config/clink/clink_settings" | Should -Exist
        }

        It "Disables logo" {
            Get-Content "$PSScriptRoot/../../.config/clink/clink_settings" -Raw |
                Should -Match 'clink\.logo = none'
        }

        It "Enables substring matching" {
            Get-Content "$PSScriptRoot/../../.config/clink/clink_settings" -Raw |
                Should -Match 'match\.substring = True'
        }

        It "welcome.lua exists" {
            "$PSScriptRoot/../../.config/clink/scripts/welcome.lua" | Should -Exist
        }

        It "welcome.lua prints banner" {
            Get-Content "$PSScriptRoot/../../.config/clink/scripts/welcome.lua" -Raw |
                Should -Match 'Welcome to your custom terminal session'
        }

        It "welcome.lua detects terminal host" {
            Get-Content "$PSScriptRoot/../../.config/clink/scripts/welcome.lua" -Raw |
                Should -Match 'WT_SESSION'
        }

        It "starship.lua exists" {
            "$PSScriptRoot/../../.config/clink/scripts/starship.lua" | Should -Exist
        }

        It "starship.lua sets STARSHIP_CONFIG" {
            Get-Content "$PSScriptRoot/../../.config/clink/scripts/starship.lua" -Raw |
                Should -Match 'STARSHIP_CONFIG'
        }

        It "starship.lua registers prompt filter" {
            Get-Content "$PSScriptRoot/../../.config/clink/scripts/starship.lua" -Raw |
                Should -Match 'clink\.promptfilter'
        }
    }

    Describe "CMD" {
        It "cmd.bat exists" {
            "$PSScriptRoot/../../.config/cmd/cmd.bat" | Should -Exist
        }

        It "Sets CLINK_PATH" {
            Get-Content "$PSScriptRoot/../../.config/cmd/cmd.bat" -Raw |
                Should -Match 'CLINK_PATH'
        }

        It "Injects Clink" {
            Get-Content "$PSScriptRoot/../../.config/cmd/cmd.bat" -Raw |
                Should -Match 'clink\.bat.*inject'
        }

        It "Forces UTF-8" {
            Get-Content "$PSScriptRoot/../../.config/cmd/cmd.bat" -Raw |
                Should -Match 'chcp 65001'
        }
    }

    Describe "Conhost Theme" {
        It "conhost_theme.reg exists" {
            "$PSScriptRoot/../../conhost_theme.reg" | Should -Exist
        }

        It "Targets HKCU Console" {
            Get-Content "$PSScriptRoot/../../conhost_theme.reg" -Raw |
                Should -Match 'HKEY_CURRENT_USER\\Console'
        }

        It "Sets green color scheme" {
            Get-Content "$PSScriptRoot/../../conhost_theme.reg" -Raw |
                Should -Match '0000ff00'
        }

        It "Sets cursor color" {
            Get-Content "$PSScriptRoot/../../conhost_theme.reg" -Raw |
                Should -Match 'CursorColor'
        }
    }

    Describe "VS Dev Profile" {
        It "dev_profile.vsconfig exists" {
            "$PSScriptRoot/../../dev_profile.vsconfig" | Should -Exist
        }

        It "Is valid JSON" {
            $content = Get-Content "$PSScriptRoot/../../dev_profile.vsconfig" -Raw
            { $content | ConvertFrom-Json } | Should -Not -Throw
        }

        It "Includes C++ workload" {
            Get-Content "$PSScriptRoot/../../dev_profile.vsconfig" -Raw |
                Should -Match 'NativeDesktop'
        }

        It "Includes .NET MAUI workload" {
            Get-Content "$PSScriptRoot/../../dev_profile.vsconfig" -Raw |
                Should -Match 'NetCrossPlat'
        }
    }
}
