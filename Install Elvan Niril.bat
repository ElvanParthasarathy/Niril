@echo off
setlocal enabledelayedexpansion
title Elvan Niril - Installer
color 0B

echo.
echo  ========================================================
echo.
echo     Elvan Niril
echo     Free - Offline - Open Source
echo     by elvan parthasarathy
echo.
echo  ========================================================
echo.
echo     One-time setup. Takes 1-2 minutes.
echo     You will NOT be asked for admin / UAC permissions
echo     (we install everything to your user profile only).
echo.
echo     If Windows shows a blue "Windows protected your PC"
echo     screen, click "More info" then "Run anyway".
echo     This is normal for free open-source apps that aren't
echo     code-signed. The full source is on GitHub:
echo       github.com/ElvanParthasarathy/Niril
echo.
echo     What this installer will do:
echo       1. Install Node.js (if you don't have it) via winget
echo       2. Run "npm install" to fetch app dependencies
echo       3. Build the app
echo       4. Make a Desktop shortcut + Start Menu entry
echo       5. Auto-start the local server when you log in
echo.
echo     What it will NOT do:
echo       * No admin rights needed
echo       * No data leaves your computer
echo       * No telemetry, no signup, no account
echo       * Nothing is written to Program Files or HKLM
echo.
echo  ========================================================
echo.

cd /d "%~dp0"

:: ========================================
:: Step 0: Verify we are in the project folder
:: ========================================
:: A misleading error people hit when they run Install.bat from
:: somewhere it shouldn't be (e.g. Downloads). Catch it early.
if not exist "package.json" (
    echo  [!] Could not find package.json in the current folder.
    echo      Make sure you extracted the ZIP and you're running
    echo      this script from inside the extracted folder.
    echo.
    pause
    exit /b 1
)

:: ========================================
:: Step 1: Check / Install Node.js
:: ========================================
echo  [1/4] Checking Node.js...

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo         Node.js not found. Installing automatically...
    echo.

    :: Try winget first (Windows 10 1709+ and Windows 11)
    where winget >nul 2>nul
    if %errorlevel% equ 0 (
        echo         Installing Node.js LTS via winget...
        echo         (This may take 1-2 minutes, please wait)
        echo.
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent
        if %errorlevel% equ 0 (
            echo.
            echo         Node.js installed successfully!
            echo.
            echo         IMPORTANT: Please close this window and run the installer again.
            echo         (Windows needs to refresh the PATH to find Node.js)
            echo.
            pause
            exit /b 0
        ) else (
            echo         winget install failed. Trying alternative method...
        )
    )

    :: Try chocolatey
    where choco >nul 2>nul
    if %errorlevel% equ 0 (
        echo         Installing Node.js LTS via Chocolatey...
        choco install nodejs-lts -y --no-progress
        if %errorlevel% equ 0 (
            echo.
            echo         Node.js installed successfully!
            echo         Please close this window and run the installer again.
            echo.
            pause
            exit /b 0
        )
    )

    :: Fallback: open the official Node.js download page in the user's browser.
    :: We deliberately don't auto-download the MSI here — antivirus heuristics often
    :: flag .bat files that fetch and run executables. Letting the user grab the
    :: signed MSI from nodejs.org themselves is safer AND less scary for non-tech
    :: users than seeing a SmartScreen prompt for an MSI in their %TEMP% folder.
    echo.
    echo  [!] Automatic Node.js install is not available on this machine.
    echo.
    echo      Please install Node.js manually (it's quick and safe):
    echo        1. We're opening https://nodejs.org/en/download/ for you.
    echo        2. Download the "LTS" version (default Windows Installer).
    echo        3. Run the downloaded MSI - just click Next through every step.
    echo        4. Come back here and run Install ElvanNiril.bat again.
    echo.
    echo      Why this isn't automated: antivirus sometimes flags scripts that
    echo      download and run executables. Downloading from nodejs.org yourself
    echo      avoids that, and the MSI is signed by Node.js Foundation.
    echo.
    start https://nodejs.org/en/download/
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node -v') do set NODE_VER=%%v
echo         Found Node.js %NODE_VER%
echo.

:: ========================================
:: Step 2: Install dependencies
:: ========================================
echo  [2/4] Installing dependencies...

if exist "node_modules" (
    echo         Dependencies already installed
) else (
    echo         Running npm install (this may take 1-2 minutes)...
    npm install --silent 2>nul
    if %errorlevel% neq 0 (
        echo  [!] Failed to install dependencies. Check your internet connection.
        pause
        exit /b 1
    )
    echo         Dependencies installed
)
echo.

:: ========================================
:: Step 3: Build the application
:: ========================================
echo  [3/4] Building application...

if exist "dist\index.html" (
    echo         Application already built
) else (
    npm run build --silent 2>nul
    if %errorlevel% neq 0 (
        echo  [!] Build failed. Please check for errors above.
        pause
        exit /b 1
    )
    echo         Build complete
)
echo.

:: ========================================
:: Step 4: Create Desktop Shortcut
:: ========================================
echo  [4/5] Creating shortcuts...

set "TARGET_PATH=%~dp0Start ElvanNiril.bat"

:: Desktop shortcut
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\Elvan Niril.lnk"

:: Start Menu shortcut (searchable from Windows Start)
set "STARTMENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Elvan Niril"
if not exist "%STARTMENU_DIR%" mkdir "%STARTMENU_DIR%"
set "STARTMENU_SHORTCUT=%STARTMENU_DIR%\Elvan Niril.lnk"

:: Create VBS shortcut creator script (creates both shortcuts)
set "TEMP_VBS=%TEMP%\create_shortcut.vbs"
(
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
    echo.
    echo Set desktopShortcut = WshShell.CreateShortcut("%DESKTOP_SHORTCUT%"^)
    echo desktopShortcut.TargetPath = "%TARGET_PATH%"
    echo desktopShortcut.WorkingDirectory = "%~dp0"
    echo desktopShortcut.Description = "Elvan Niril"
    echo desktopShortcut.WindowStyle = 1
    echo desktopShortcut.Save
    echo.
    echo Set startShortcut = WshShell.CreateShortcut("%STARTMENU_SHORTCUT%"^)
    echo startShortcut.TargetPath = "%TARGET_PATH%"
    echo startShortcut.WorkingDirectory = "%~dp0"
    echo startShortcut.Description = "Elvan Niril"
    echo startShortcut.WindowStyle = 1
    echo startShortcut.Save
) > "%TEMP_VBS%"

cscript //nologo "%TEMP_VBS%" 2>nul
del "%TEMP_VBS%" 2>nul

if exist "%DESKTOP_SHORTCUT%" (
    echo         Desktop shortcut created
) else (
    echo         Could not create desktop shortcut
)
if exist "%STARTMENU_SHORTCUT%" (
    echo         Start Menu shortcut created (search "Elvan Niril" in Start)
) else (
    echo         Could not create Start Menu shortcut
)
echo.

:: ========================================
:: Step 5: Auto-start on Windows login + Protocol
:: ========================================
echo  [5/5] Setting up auto-start...

:: Add to Windows Startup folder (server starts silently on login)
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "STARTUP_SHORTCUT=%STARTUP_DIR%\Elvan Niril Server.lnk"
set "SERVER_BAT=%~dp0start-server-silent.bat"

:: Create a silent server starter (no window, just runs node)
(
    echo @echo off
    echo cd /d "%~dp0"
    echo if not exist "node_modules" exit /b
    echo if not exist "dist\index.html" exit /b
    echo start "" /min cmd /c "node server.js"
) > "%SERVER_BAT%"

:: Create startup shortcut
set "TEMP_VBS2=%TEMP%\create_startup.vbs"
(
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)
    echo Set startupShortcut = WshShell.CreateShortcut("%STARTUP_SHORTCUT%"^)
    echo startupShortcut.TargetPath = "%SERVER_BAT%"
    echo startupShortcut.WorkingDirectory = "%~dp0"
    echo startupShortcut.Description = "Elvan Niril Server Auto-Start"
    echo startupShortcut.WindowStyle = 7
    echo startupShortcut.Save
) > "%TEMP_VBS2%"
cscript //nologo "%TEMP_VBS2%" 2>nul
del "%TEMP_VBS2%" 2>nul

if exist "%STARTUP_SHORTCUT%" (
    echo         Auto-start on login enabled
) else (
    echo         Could not enable auto-start
)

:: Register elvanniril:// protocol (so browser "Start Server" button works)
powershell -Command "New-Item -Path 'HKCU:\Software\Classes\elvanniril' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril' -Name '(default)' -Value 'URL:Elvan Niril Protocol'; New-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril' -Name 'URL Protocol' -Value '' -Force | Out-Null; New-Item -Path 'HKCU:\Software\Classes\elvanniril\shell\open\command' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril\shell\open\command' -Name '(default)' -Value '%TARGET_PATH%'" 2>nul
echo         Start button registered

:: Register elvanniril-update:// protocol (so browser "Update Now" button works)
set "UPDATE_PATH=%~dp0Update ElvanNiril.bat"
powershell -Command "New-Item -Path 'HKCU:\Software\Classes\elvanniril-update' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril-update' -Name '(default)' -Value 'URL:Elvan Niril Update Protocol'; New-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril-update' -Name 'URL Protocol' -Value '' -Force | Out-Null; New-Item -Path 'HKCU:\Software\Classes\elvanniril-update\shell\open\command' -Force | Out-Null; Set-ItemProperty -Path 'HKCU:\Software\Classes\elvanniril-update\shell\open\command' -Name '(default)' -Value '%UPDATE_PATH%'" 2>nul
echo         Update button registered
echo.

:: ========================================
:: Done!
:: ========================================
echo.
echo  ========================================================
echo.
echo     Installation Complete!
echo.
echo  ========================================================
echo.
echo  Starting Elvan Niril...
echo  (Your browser will open automatically)
echo.

start "" "%~dp0Start ElvanNiril.bat"

echo.
echo  ========================================================
echo.
echo     Elvan Niril is running!
echo.
echo     HOW IT WORKS:
echo       - Server starts automatically when you turn on PC
echo       - Just click "Elvan Niril" on Desktop to open
echo       - Or search "Elvan Niril" in Start Menu
echo       - Your data is always safe on your computer
echo.
echo     Tip: When the app opens, click "Install App"
echo     to use it like a normal desktop application.
echo.
echo     Need help?
echo       - Read START HERE.txt next to this installer
echo       - Or open docs\USER_GUIDE.md for the full handbook
echo         (covers backups, multi-business, troubleshooting)
echo.
echo  ========================================================
echo.
pause
