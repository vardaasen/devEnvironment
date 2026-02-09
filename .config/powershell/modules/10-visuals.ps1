# --- modules\10-visuals.ps1 ---

# 1. Starship Init Cache
$CacheDir = "$env:LOCALAPPDATA\PowerShell\Cache"
if (-not (Test-Path $CacheDir)) { New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null }
$StarshipCache = "$CacheDir\starship.init.ps1"

$CacheIsValid = (Test-Path $StarshipCache) -and ((Get-Item $StarshipCache).LastWriteTime -gt (Get-Date).AddDays(-1))

if (-not $CacheIsValid) {
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Host " [Rebuilding Starship Cache...] " -NoNewline -ForegroundColor DarkGray
        (& starship init powershell) | Out-File $StarshipCache -Encoding utf8 -Force
    }
}

if (Test-Path $StarshipCache) { . $StarshipCache }

$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"

# 2. PSReadLine Color Map
$TempColorMap = @{
    Colors = @{
        "ContinuationPrompt"    = "$Global:e[37m"
        "Emphasis"              = "$Global:e[96m"
        "Error"                 = "$Global:e[91m"
        "Selection"             = "$Global:e[30;47m"
        "Default"               = "$Global:e[32m"
        "Comment"               = "$Global:e[32m"
        "Keyword"               = "$Global:e[92m"
        "String"                = "$Global:e[36m"
        "Operator"              = "$Global:e[90m"
        "Variable"              = "$Global:e[92m"
        "Command"               = "$Global:e[93m"
        "Parameter"             = "$Global:e[90m"
        "Type"                  = "$Global:e[37m"
        "Number"                = "$Global:e[97m"
        "Member"                = "$Global:e[37m"
        "InlinePrediction"      = "$Global:e[97;2;3m"
        "ListPrediction"        = "$Global:e[33m"
        "ListPredictionSelected"= "$Global:e[48;5;238m"
        "ListPredictionTooltip" = "$Global:e[97;2;3m"
    }
}
Set-PSReadLineOption @TempColorMap

# 3. Cleanup
Remove-Variable -Name TempColorMap, TempHistoryOptions, ScriptBlock,
    PSReadLineOptions, HistoryHandler -ErrorAction SilentlyContinue
