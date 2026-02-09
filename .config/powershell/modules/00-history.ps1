# --- modules\00-history.ps1 ---

# 0. ENSURE DIRECTORIES EXIST (XDG Standard)
$XdgHistoryDir = "$HOME\.local\share\powershell\PSReadLine"
if (-not (Test-Path $XdgHistoryDir)) {
    New-Item -ItemType Directory -Path $XdgHistoryDir -Force | Out-Null
}

# 1. Set Custom History File Location
$HistoryFile = Join-Path $XdgHistoryDir "$($Host.Name)_history.txt"
Set-PSReadLineOption -HistorySavePath $HistoryFile

# 2. Define Global Escape Character
$Global:e = [char]27

# 3. Set History Options
$TempHistoryOptions = @{
    HistorySaveStyle    = "SaveIncrementally"
    HistoryNoDuplicates = $true
    MaximumHistoryCount = 10000
}
Set-PSReadLineOption @TempHistoryOptions

# 4. Custom History Handler: Ignore 'git' commands
$ScriptBlock = {
    param ([string]$Line)
    if ($Line -match "^git") {
        return 'MemoryOnly'
    } else {
        return 'MemoryAndFile'
    }
}
Set-PSReadLineOption -AddToHistoryHandler $ScriptBlock
