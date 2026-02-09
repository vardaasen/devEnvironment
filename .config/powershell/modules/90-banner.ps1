# --- modules/90-banner.ps1 ---

# 1. Calculate Elapsed Time
$elapsed = (Get-Date) - $Script:StartTime

# 2. Build Date String
$DateStr = Get-Date -Format "ddd MM/dd/yyyy  H:mm:ss.ff"

# 3. Dynamic Module Detection
$UserModules = Get-Module | Where-Object {
    $_.Name -notlike "Microsoft.PowerShell.*" -and
    $_.Name -notlike "Appx" -and
    $_.Name -notlike "CimCmdlets" -and
    $_.Name -notlike "ISE"
} | Sort-Object Name

if ($UserModules) {
    $ModuleStr = ($UserModules | ForEach-Object { "$($_.Name) $($_.Version)" }) -join ", "
} else {
    $ModuleStr = "None"
}

# 4. Print the Banner
$Gray    = "DarkGray"
$Cyan    = "Cyan"
$Green   = "Green"
$White   = "White"
$Yellow  = "Yellow"
$Magenta = "Magenta"

$BorderColor = $Gray
if ($Global:TermHost -match "WezTerm")          { $BorderColor = $Magenta }
if ($Global:TermHost -match "Windows Terminal")  { $BorderColor = $Green }

Write-Host "========================================" -ForegroundColor $BorderColor
Write-Host "Welcome to your custom terminal session!" -ForegroundColor $Cyan
Write-Host "Today is $DateStr"
Write-Host "Environment: PS $Global:PSDisplay ($Global:PSEnv) | Starship $Global:StarshipVer" -ForegroundColor $Green
Write-Host "Modules: $ModuleStr" -ForegroundColor $White

if ($Global:TermFont -eq "Client Managed") {
    Write-Host "Font: Client Managed" -ForegroundColor $Gray
} else {
    Write-Host "Font: $Global:TermFont" -ForegroundColor $Yellow
}

Write-Host "Terminal: $Global:TermHost" -ForegroundColor $Gray

# 5. Performance Warning
if ($elapsed.TotalMilliseconds -gt 1000) {
    Write-Host "Startup Time: $($elapsed.TotalMilliseconds.ToString('N0')) ms (Slow)" -ForegroundColor $Yellow
} else {
    Write-Host "Startup Time: $($elapsed.TotalMilliseconds.ToString('N0')) ms" -ForegroundColor $Gray
}

Write-Host "========================================" -ForegroundColor $BorderColor
Write-Host ""
