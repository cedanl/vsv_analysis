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
set "RSTUDIO_URL=https://surfdrive.surf.nl/files/index.php/s/3FFZMKFXCM7zB3f/download"
set "REPO_URL=https://github.com/cedanl/vsv_analysis"
set "ZIP_URL=https://surfdrive.surf.nl/files/index.php/s/I4D0d2RgaQ2Kyc3/download"

:: Filenames
set "R_INSTALLER=R-Installer.exe"
set "RTOOLS_INSTALLER=RTools-Installer.exe"
set "RSTUDIO_INSTALLER=RStudio-Installer.exe"
set "REPO_ZIP=repo.zip"
set "UTILS_ZIP=utils.zip"
set "REPO_DIR=vsv_analysis"
set "UTILS_DIR=utils"

:: Initialize flags
set "R_FOUND=0"
set "RTOOLS_FOUND=0"
set "RSTUDIO_FOUND=0"
set "R_PATH="
set "RTOOLS_PATH=C:\rtools44\usr\bin"

:: Check installations
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

if exist "%RTOOLS_PATH%\" set "RTOOLS_FOUND=1"
if exist "C:\Program Files\RStudio\bin\rstudio.exe" set "RSTUDIO_FOUND=1"
if exist "C:\Program Files\RStudio\rstudio.exe" set "RSTUDIO_FOUND=1"

:: Install R
if "%R_FOUND%"=="0" (
    echo R not found, downloading and installing...
    curl -L %R_URL% -o %R_INSTALLER%
    start /wait %R_INSTALLER% /VERYSILENT
    timeout /t 60 >nul
    for /f "delims=" %%i in ('dir /b /ad "C:\Program Files\R\R-*" 2^>nul') do (
        if exist "C:\Program Files\R\%%i\bin\R.exe" set "R_PATH=C:\Program Files\R\%%i\bin"
    )
)

:: Install RTools
if "%RTOOLS_FOUND%"=="0" (
    echo RTools not found, downloading and installing...
    curl -L %RTOOLS_URL% -o %RTOOLS_INSTALLER%
    start /wait %RTOOLS_INSTALLER% /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- ADDPATH=1
)

:: Install RStudio
if "%RSTUDIO_FOUND%"=="0" (
    echo RStudio not found, downloading and installing...
    curl -L %RSTUDIO_URL% -o %RSTUDIO_INSTALLER%
    start /wait %RSTUDIO_INSTALLER% /S
)

:: Update PATH
if defined R_PATH (
    echo %PATH% | find /I "%R_PATH%" >nul || setx /M PATH "%PATH%;%R_PATH%"
)
echo %PATH% | find /I "%RTOOLS_PATH%" >nul || setx /M PATH "%PATH%;%RTOOLS_PATH%"

:: Handle repository files
echo Downloading repository files...
curl -L %ZIP_URL% -o %UTILS_ZIP%
curl -L %REPO_URL%/archive/refs/heads/main.zip -o %REPO_ZIP%

:: Unzip files
echo Extracting archives...
powershell -Command "Expand-Archive -Force '%~dp0%UTILS_ZIP%' '%~dp0%UTILS_DIR%'"
powershell -Command "Expand-Archive -Force '%~dp0%REPO_ZIP%' '%~dp0%REPO_DIR%'"

:: Corrected file merging
echo Merging renv files...
xcopy /Y /E "%~dp0%UTILS_DIR%\renv\*" "%~dp0%REPO_DIR%\vsv_analysis-main\utils\renv\" >nul 2>&1

:: Cleanup
rd /S /Q "%~dp0%UTILS_DIR%" >nul 2>&1
del %UTILS_ZIP% %REPO_ZIP%

echo Setup complete. 
timeout /t 25
exit
