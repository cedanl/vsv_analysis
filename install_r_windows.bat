@echo off
:: =============================================
:: Auto-elevate to admin if not already running
:: =============================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd.exe -Verb RunAs -ArgumentList '/k cd /d %CD% && %~f0 ADMIN'"
    exit /b
)

:: Keep window open for debugging
if "%1"=="ADMIN" (
    echo Running as administrator...
)

:: Record start time
set "start_time=%time%"

echo Script started at %date% %time% >> setup_log.txt
echo Current directory: %CD% >> setup_log.txt

echo Script started at %date% %time%
echo Current directory: %CD%

:: Enable delayed expansion
setlocal enabledelayedexpansion
if errorlevel 1 (
    echo Error enabling delayed expansion!
    echo Error enabling delayed expansion! >> setup_log.txt
    pause
    exit /b 1
)

:: URLs
set "R_URL=https://cran.r-project.org/bin/windows/base/old/4.4.3/R-4.4.3-win.exe"
:: set "RTOOLS_URL=https://cran.r-project.org/bin/windows/Rtools/rtools44/files/rtools44-6459-6401.exe"
set "RSTUDIO_URL=https://surfdrive.surf.nl/files/index.php/s/3FFZMKFXCM7zB3f/download"
set "REPO_URL=https://github.com/cedanl/vsv_analysis"
set "ZIP_URL=https://surfdrive.surf.nl/files/index.php/s/I4D0d2RgaQ2Kyc3/download"

:: Filenames
set "R_INSTALLER=R-Installer.exe"
:: set "RTOOLS_INSTALLER=RTools-Installer.exe"
set "RSTUDIO_INSTALLER=RStudio-Installer.exe"
set "REPO_ZIP=repo.zip"
set "PACKAGES_ZIP=packages.zip"
set "REPO_DIR=vsv_analysis"
set "PACKAGES_DIR=packages"

:: Initialize flags
set "R_FOUND=0"
:: set "RTOOLS_FOUND=0"
set "RSTUDIO_FOUND=0"
set "R_PATH="
:: set "RTOOLS_PATH=C:\rtools44\usr\bin"

:: Check for R installation
echo Checking for R installation...
echo Checking for R installation... >> setup_log.txt


if exist "C:\Program Files\R\R-4.4.3\bin\R.exe" (
    echo Found R 4.4.3 in Program Files >> setup_log.txt
    set "R_PATH=C:\Program Files\R\R-4.4.3\bin"
    set "R_FOUND=1"
    echo Found R 4.4.3 in Program Files and added to PATH
) else if exist "C:\Program Files (x86)\R\R-4.4.3\bin\R.exe" (
    echo Found R 4.4.3 in Program Files x86 >> setup_log.txt
    set "R_PATH=C:\Program Files (x86)\R\R-4.4.3\bin"
    set "R_FOUND=1"
    echo Found R 4.4.3 in Program Files x86 and added to PATH
) else (
    echo R 4.4.3 not found, downloading
    echo R 4.4.3 not found, downloading >> setup_log.txt
    
    curl -L %R_URL% -o %R_INSTALLER% --progress-bar
    if errorlevel 1 (
        echo Error downloading R!
        echo Error downloading R! >> setup_log.txt
        pause
        exit /b 1
    )
    
    echo Installing R... - this might take a minute...
    echo Installing R... - this might take a minute... >> setup_log.txt
    start /wait %R_INSTALLER% /VERYSILENT
    
    :: Wait for installation to complete
    timeout /t 60 >nul
    
    :: Re-check for R installation
    if exist "C:\Program Files\R\R-4.4.3\bin\R.exe" (
        set "R_PATH=C:\Program Files\R\R-4.4.3\bin"
        set "R_FOUND=1"
    )
    if exist "C:\Program Files (x86)\R\R-4.4.3\bin\R.exe" (
        set "R_PATH=C:\Program Files (x86)\R\R-4.4.3\bin"
        set "R_FOUND=1"
    )
    
    if "!R_FOUND!"=="1" (
        echo R installed successfully at !R_PATH!
        echo R installed successfully at !R_PATH! >> setup_log.txt
    ) else (
        echo R installation failed!
        echo R installation failed! >> setup_log.txt
        pause
        exit /b 1
    )
    
    :: Remove R installer
    if exist "%R_INSTALLER%" del "%R_INSTALLER%"
) 



:: Check for RTools
echo Checking for RTools...
echo Checking for RTools... >> setup_log.txt

:: if exist "%RTOOLS_PATH%\" (
::     echo RTools found at %RTOOLS_PATH%
::     echo RTools found at %RTOOLS_PATH% >> setup_log.txt
::     set "RTOOLS_FOUND=1"
:: ) else (
::     echo RTools not found, downloading and installing...
::     echo RTools not found, downloading and installing... >> setup_log.txt
::     
::     curl -L %RTOOLS_URL% -o %RTOOLS_INSTALLER% --progress-bar
::     if errorlevel 1 (
::         echo Error downloading RTools!
::         echo Error downloading RTools! >> setup_log.txt
::         pause
::         exit /b 1
::     )
::     
::     echo Installing RTools...
::     echo Installing RTools... >> setup_log.txt
::     start /wait %RTOOLS_INSTALLER% /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- ADDPATH=1
::     
::     echo RTools installation completed
::     echo RTools installation completed >> setup_log.txt
::     
::     :: Remove RTools installer
::     if exist "%RTOOLS_INSTALLER%" del "%RTOOLS_INSTALLER%"
:: )

:: Check for RStudio
echo Checking for RStudio...
echo Checking for RStudio... >> setup_log.txt

if exist "C:\Program Files\RStudio\bin\rstudio.exe" (
    echo RStudio found at C:\Program Files\RStudio\bin\rstudio.exe
    echo RStudio found at C:\Program Files\RStudio\bin\rstudio.exe >> setup_log.txt
    set "RSTUDIO_FOUND=1"
)
if exist "C:\Program Files\RStudio\rstudio.exe" (
    echo RStudio found at C:\Program Files\RStudio\rstudio.exe
    echo RStudio found at C:\Program Files\RStudio\rstudio.exe >> setup_log.txt
    set "RSTUDIO_FOUND=1"
)

if "%RSTUDIO_FOUND%"=="0" (
    echo RStudio not found, downloading and installing...
    echo RStudio not found, downloading and installing... >> setup_log.txt
    
    curl -L %RSTUDIO_URL% -o %RSTUDIO_INSTALLER% --progress-bar
    if errorlevel 1 (
        echo Error downloading RStudio!
        echo Error downloading RStudio! >> setup_log.txt
        pause
        exit /b 1
    )
    
    echo Installing RStudio... - this might take a minute...
    echo Installing RStudio... - this might take a minute... >> setup_log.txt
    start /wait %RSTUDIO_INSTALLER% /S
    
    echo RStudio installation completed
    echo RStudio installation completed >> setup_log.txt
    
    :: Remove RStudio installer
    if exist "%RSTUDIO_INSTALLER%" del "%RSTUDIO_INSTALLER%"
) else (
    echo RStudio is already installed.
    echo RStudio is already installed. >> setup_log.txt
)

:: Update PATH - Fixed version
echo Checking and updating PATH...
echo Checking and updating PATH... >> setup_log.txt

if defined R_PATH (
    echo Checking if R is in PATH...
    echo Checking if R is in PATH... >> setup_log.txt
    echo "%PATH%" | find /I "%R_PATH%" >nul
    if errorlevel 1 (
        echo Adding R to PATH: "%R_PATH%"
        echo Adding R to PATH: "%R_PATH%" >> setup_log.txt
        setx /M PATH "%PATH%;%R_PATH%"
        if errorlevel 1 (
            echo Failed to add R to PATH
            echo Failed to add R to PATH >> setup_log.txt
        ) else (
            echo Successfully added R to PATH
            echo Successfully added R to PATH >> setup_log.txt
        )
    ) else (
        echo R is already in PATH
        echo R is already in PATH >> setup_log.txt
    )
)

echo Checking if RTools is in PATH...
echo Checking if RTools is in PATH... >> setup_log.txt
echo "%PATH%" | find /I "%RTOOLS_PATH%" >nul
:: if errorlevel 1 (
::     echo Adding RTools to PATH: "%RTOOLS_PATH%"
::     echo Adding RTools to PATH: "%RTOOLS_PATH%" >> setup_log.txt
::     setx /M PATH "%PATH%;%RTOOLS_PATH%"
::     if errorlevel 1 (
::         echo Failed to add RTools to PATH
::         echo Failed to add RTools to PATH >> setup_log.txt
::     ) else (
::         echo Successfully added RTools to PATH
::         echo Successfully added RTools to PATH >> setup_log.txt
::     )
:: ) else (
::     echo RTools is already in PATH
::     echo RTools is already in PATH >> setup_log.txt
:: )

:: Handle repository files
echo Downloading repository files...
echo Downloading repository files... >> setup_log.txt

:: Clean up any existing files/directories before proceeding
if exist "%REPO_ZIP%" del "%REPO_ZIP%"
if exist "%PACKAGES_ZIP%" del "%PACKAGES_ZIP%"
if exist "%REPO_DIR%" rd /S /Q "%REPO_DIR%"
if exist "%PACKAGES_DIR%" rd /S /Q "%PACKAGES_DIR%"

:: Download R Packages with clean progress
echo Downloading R Packages...
curl -L %ZIP_URL% -o %PACKAGES_ZIP% --progress-bar
if not exist "%PACKAGES_ZIP%" (
    echo Error downloading R Packages!
    echo Error downloading R Packages! >> setup_log.txt
    pause
    exit /b 1
)

echo Downloading repository...
curl -L %REPO_URL%/archive/refs/heads/main.zip -o %REPO_ZIP% -s
if not exist "%REPO_ZIP%" (
    echo Error downloading repository!
    echo Error downloading repository! >> setup_log.txt
    pause
    exit /b 1
)

:: Unzip files
echo Extracting archives to: %CD%
echo Extracting archives to: %CD% >> setup_log.txt

echo Extracting R Packages - this might take a minute...
echo Extracting R Packages - this might take a minute... >> setup_log.txt
powershell -Command "Expand-Archive -Force '%~dp0%PACKAGES_ZIP%' '%~dp0%PACKAGES_DIR%'"
echo Done!

if errorlevel 1 (
    echo Error extracting R Packages!
    echo Error extracting R Packages! >> setup_log.txt
    pause
    exit /b 1
)

echo Extracting repository...
:: First extract to temp directory
powershell -Command "Expand-Archive -Force '%~dp0%REPO_ZIP%' '%~dp0temp_repo'"
if errorlevel 1 (
    echo Error extracting repository!
    echo Error extracting repository! >> setup_log.txt
    pause
    exit /b 1
)

:: Create vsv_analysis directory if it doesn't exist
if not exist "%~dp0%REPO_DIR%" mkdir "%~dp0%REPO_DIR%"

:: Move contents of vsv_analysis-main to vsv_analysis
echo Moving repository files...
echo Moving repository files... >> setup_log.txt
xcopy /Y /E "%~dp0temp_repo\vsv_analysis-main\*" "%~dp0%REPO_DIR%\" >nul 2>&1
rd /S /Q "%~dp0temp_repo" >nul 2>&1

:: Merge files
echo Merging renv files...
echo Merging renv files... >> setup_log.txt

xcopy /Y /E "%~dp0%PACKAGES_DIR%\renv\*" "%~dp0%REPO_DIR%\utils\renv\" >nul 2>&1
if errorlevel 1 (
    echo Error merging files!
    echo Error merging files! >> setup_log.txt
    pause
    exit /b 1
)

:: Cleanup
echo Cleaning up...
echo Cleaning up... >> setup_log.txt

rd /S /Q "%~dp0%PACKAGES_DIR%" >nul 2>&1
del %PACKAGES_ZIP% %REPO_ZIP%

:: Calculate duration
for /f "tokens=1-4 delims=:.," %%a in ("%start_time%") do (
    set /a "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
for /f "tokens=1-4 delims=:.," %%a in ("%time%") do (
    set /a "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /a "duration=end-start"
set /a "duration_seconds=duration/100"
set /a "duration_minutes=duration_seconds/60"
set /a "remaining_seconds=duration_seconds%%60"

echo.
echo ===================================================
echo     Congratulations! Setup completed!
echo ===================================================
echo.
echo Repository files extracted to: %CD%\%REPO_DIR%
echo.
echo Total duration: %duration_minutes% minutes and %remaining_seconds% seconds
echo.
echo Setup complete! >> setup_log.txt
echo Repository files extracted to: %CD%\%REPO_DIR% >> setup_log.txt
echo Script finished at %date% %time% >> setup_log.txt
echo Total duration: %duration_minutes% minutes and %remaining_seconds% seconds >> setup_log.txt

del setup_log.txt

:: Keep window open
echo.
echo Press any key to exit...
pause >nul