Describe "Test Infrastructure" {
    It "Pester is running" {
        $true | Should -BeTrue
    }

    It "Project structure exists" {
        './scripts' | Should -Exist
        './.config/powershell/modules' | Should -Exist
        './tests/Unit' | Should -Exist
    }

    It ".editorconfig is present" {
        './.editorconfig' | Should -Exist
    }
}
