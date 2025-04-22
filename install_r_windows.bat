@echo off
:: =============================================
:: Auto-elevate to admin if not already running
:: =============================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -Verb RunAs -FilePath '%~f0'"
    exit /b
)

setlocal enabledelayedexpansion

:: URLs
set "R_URL=https://cran.r-project.org/bin/windows/base/old/4.4.3/R-4.4.3-win.exe"
set "RTOOLS_URL=https://cran.r-project.org/bin/windows/Rtools/rtools44/files/rtools44-6459-6401.exe"
set "RSTUDIO_URL=https://surfdrive.surf.nl/files/index.php/s/3FFZMKFXCM7zB3f/download
:: https://download1.rstudio.org/desktop/windows/RStudio-2023.12.1-402.exe"

:: Filenames
set "R_INSTALLER=R-Installer.exe"
set "RTOOLS_INSTALLER=RTools-Installer.exe"
set "RSTUDIO_INSTALLER=RStudio-Installer.exe"

:: Initialize flags
set "R_FOUND=0"
set "RTOOLS_FOUND=0"
set "RSTUDIO_FOUND=0"
set "R_PATH="
set "RTOOLS_PATH=C:\rtools44\usr\bin"

:: Check for R installation in both Program Files locations
echo Checking for R installation...
for /f "delims=" %%i in ('dir /b /ad "C:\Program Files\R\R-*" 2^>nul') do (
    if exist "C:\Program Files\R\%%i\bin\R.exe" (
        set "R_PATH=C:\Program Files\R\%%i\bin"
        set "R_FOUND=1"
    )
)
if "!R_FOUND!"=="0" (
    for /f "delims=" %%i in ('dir /b /ad "C:\Program Files (x86)\R\R-*" 2^>nul') do (
        if exist "C:\Program Files (x86)\R\%%i\bin\R.exe" (
            set "R_PATH=C:\Program Files (x86)\R\%%i\bin"
            set "R_FOUND=1"
        )
    )
)

:: Check for RTools
echo Checking for RTools...
if exist "%RTOOLS_PATH%\" (
    set "RTOOLS_FOUND=1"
)

:: Check for RStudio
echo Checking for RStudio...
if exist "C:\Program Files\RStudio\bin\rstudio.exe" (
    set "RSTUDIO_FOUND=1"
)
if exist "C:\Program Files\RStudio\rstudio.exe" (
    set "RSTUDIO_FOUND=1"
)

:: Install R
if "%R_FOUND%"=="0" (
    echo R not found, downloading and installing...
    curl -L %R_URL% -o %R_INSTALLER%
    start /wait %R_INSTALLER% /VERYSILENT

    :: Re-check R path after installation
    for /f "delims=" %%i in ('dir /b /ad "C:\Program Files\R\R-*" 2^>nul') do (
        if exist "C:\Program Files\R\%%i\bin\R.exe" (
            set "R_PATH=C:\Program Files\R\%%i\bin"
            set "R_FOUND=1"
        )
    )
    if "!R_FOUND!"=="0" (
        for /f "delims=" %%i in ('dir /b /ad "C:\Program Files (x86)\R\R-*" 2^>nul') do (
            if exist "C:\Program Files (x86)\R\%%i\bin\R.exe" (
                set "R_PATH=C:\Program Files (x86)\R\%%i\bin"
                set "R_FOUND=1"
            )
        )
    )
) else (
    echo R is already installed.
)

:: Install RTools
if "%RTOOLS_FOUND%"=="0" (
    echo RTools not found, downloading and installing...
    curl -L %RTOOLS_URL% -o %RTOOLS_INSTALLER%
    start /wait %RTOOLS_INSTALLER% /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- ADDPATH=1
) else (
    echo RTools is already installed.
)

:: Install RStudio
if "%RSTUDIO_FOUND%"=="0" (
    echo RStudio not found, downloading and installing...
    curl -L %RSTUDIO_URL% -o %RSTUDIO_INSTALLER%
    start /wait %RSTUDIO_INSTALLER% /S
) else (
    echo RStudio is already installed.
)

:: Safely check and update PATH
echo Checking and updating PATH...

echo %PATH% | find /I "%R_PATH%" >nul
if errorlevel 1 (
    echo Adding R to PATH: "%R_PATH%"
    setx /M PATH "%PATH%;%R_PATH%"
)

echo %PATH% | find /I "%RTOOLS_PATH%" >nul
if errorlevel 1 (
    echo Adding RTools to PATH: "%RTOOLS_PATH%"
    setx /M PATH "%PATH%;%RTOOLS_PATH%"
)

echo.
echo Setup complete.
