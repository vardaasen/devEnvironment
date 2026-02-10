@echo off
:: 1. Tell Clink where your scripts live
set CLINK_PATH=%USERPROFILE%\.config\clink\scripts
set CLINK_PROFILE=%USERPROFILE%\.config\clink

:: 2. Inject Clink
if exist "C:\Program Files (x86)\clink\clink.bat" (
    call "C:\Program Files (x86)\clink\clink.bat" inject --quiet
)

:: 3. Force UTF-8
chcp 65001 >nul

:: 4. Go to User Home
cd /d "%USERPROFILE%"
