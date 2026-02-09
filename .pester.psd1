@{
    Run = @{
        Path = './tests'
        Exit = $true
    }
    Output = @{
        Verbosity = 'Detailed'
    }
    TestResult = @{
        Enabled    = $true
        OutputPath = './TestResults/results.xml'
        OutputFormat = 'NUnit3'
    }
    CodeCoverage = @{
        Enabled    = $false
        Path       = @('./scripts/*.ps1', './.config/powershell/**/*.ps1')
        OutputPath = './coverage/coverage.xml'
    }
}
