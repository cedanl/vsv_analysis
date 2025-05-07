@echo off
:: Save the original directory path WITHOUT the trailing backslash
cd > "%TEMP%\orig_dir.txt"
for /f "delims=" %%i in (%TEMP%\orig_dir.txt) do set "SCRIPT_DIR=%%i"

echo Original directory: "%SCRIPT_DIR%"

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c cd /d \"%SCRIPT_DIR%\" && \"%~f0\" ADMIN' -Verb RunAs"
    exit /b
)

:: If re-launched with "ADMIN" parameter
if /i "%1"=="ADMIN" (
    echo Running as administrator in: "%CD%"
)

:: Now add the trailing backslash for path operations if needed
if "%SCRIPT_DIR:~-1%" neq "\" set "SCRIPT_DIR=%SCRIPT_DIR%\"
set "SETUP_LOG=%SCRIPT_DIR%setup_log.txt"

echo Script started at %date% %time% >> "%SETUP_LOG%"
echo Current directory: %CD% >> "%SETUP_LOG%"
echo Download directory: %~dp0 >> "%SETUP_LOG%"
echo Script directory is: %SCRIPT_DIR% >> "%SETUP_LOG%"

echo Script started at %date% %time%
echo Current directory: %CD%
echo Download directory: %SCRIPT_DIR%
echo Script directory is: %SCRIPT_DIR%

:: Check if we're in the System32 directory and bail out early if so
echo "%CD%" | findstr /i "system32" > nul
if %errorlevel% equ 0 (
    echo ERROR: Script is running from System32 directory. This is not supported.
    echo Please run the script from the directory where it is located.
    echo Current directory: "%CD%"
    echo Script directory: "%SCRIPT_DIR%"
    pause
    exit /b 1
)

:: Enable delayed expansion
setlocal enabledelayedexpansion
if errorlevel 1 (
    echo Error enabling delayed expansion!
    echo Error enabling delayed expansion! >> "%SETUP_LOG%"
    pause
    exit /b 1
)

:: Define URLs before they're needed
set "R_URL=https://cran.r-project.org/bin/windows/base/old/4.4.3/R-4.4.3-win.exe"
set "RSTUDIO_URL=https://surfdrive.surf.nl/files/index.php/s/3FFZMKFXCM7zB3f/download"
set "REPO_URL=https://github.com/cedanl/vsv_analysis"
set "ZIP_URL=https://surfdrive.surf.nl/files/index.php/s/JB6RzGvaqfzqMLu/download"

:: Filenames - fixed path construction
set "R_INSTALLER=%SCRIPT_DIR%R-Installer.exe"
set "RSTUDIO_INSTALLER=%SCRIPT_DIR%RStudio-Installer.exe"
set "REPO_ZIP=%SCRIPT_DIR%repo.zip"
set "PACKAGES_ZIP=%SCRIPT_DIR%packages.zip"
set "REPO_DIR=%SCRIPT_DIR%vsv_analysis"
set "PROJECT_FILE=%REPO_DIR%\vsv_analysis.Rproj"
set "PACKAGES_DIR=%SCRIPT_DIR%packages"

:: Rest of the script - ensure all file paths are correctly constructed
:: ...

:: Initialize flags
set "R_FOUND=0"
:: set "RTOOLS_FOUND=0"
set "RSTUDIO_FOUND=0"
set "R_PATH="
:: set "RTOOLS_PATH=C:\rtools44\usr\bin"

:: Check for R installation
echo Checking for R installation...
echo Checking for R installation... >> %SETUP_LOG%


if exist "C:\Program Files\R\R-4.4.3\bin\R.exe" (
    echo Found R 4.4.3 in Program Files >> %SETUP_LOG%
    set "R_PATH=C:\Program Files\R\R-4.4.3\bin"
    set "R_FOUND=1"
    echo Found R 4.4.3 in Program Files and added to PATH
) else if exist "C:\Program Files (x86)\R\R-4.4.3\bin\R.exe" (
    echo Found R 4.4.3 in Program Files x86 >> %SETUP_LOG%
    set "R_PATH=C:\Program Files (x86)\R\R-4.4.3\bin"
    set "R_FOUND=1"
    echo Found R 4.4.3 in Program Files x86 and added to PATH
) else (
    echo R 4.4.3 not found, downloading
    echo R 4.4.3 not found, downloading >> %SETUP_LOG%
    
    curl -L %R_URL% -o %SETUP_LOG%%R_INSTALLER% --progress-bar
    if errorlevel 1 (
        echo Error downloading R!
        echo Error downloading R! >> %SETUP_LOG%
        pause
        exit /b 1
    )
    
    echo Installing R... - this might take a minute...
    echo Installing R... - this might take a minute... >> %SETUP_LOG%
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
        echo R installed successfully at !R_PATH! >> %SETUP_LOG%
    ) else (
        echo R installation failed!
        echo R installation failed! >> %SETUP_LOG%
        pause
        exit /b 1
    )
    
    :: Remove R installer
    if exist "%R_INSTALLER%" del "%R_INSTALLER%"
) 

:: Check for RTools
:: echo Checking for RTools...
:: echo Checking for RTools... >> %SETUP_LOG%
::
:: if exist "%RTOOLS_PATH%\" (
::     echo RTools found at %RTOOLS_PATH%
::     echo RTools found at %RTOOLS_PATH% >> %SETUP_LOG%
::     set "RTOOLS_FOUND=1"
:: ) else (
::     echo RTools not found, downloading and installing...
::     echo RTools not found, downloading and installing... >> %SETUP_LOG%
::     
::     curl -L %RTOOLS_URL% -o %RTOOLS_INSTALLER% --progress-bar
::     if errorlevel 1 (
::         echo Error downloading RTools!
::         echo Error downloading RTools! >> %SETUP_LOG%
::         pause
::         exit /b 1
::     )
::     
::     echo Installing RTools...
::     echo Installing RTools... >> %SETUP_LOG%
::     start /wait %RTOOLS_INSTALLER% /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- ADDPATH=1
::     
::     echo RTools installation completed
::     echo RTools installation completed >> %SETUP_LOG%
::     
::     :: Remove RTools installer
::     if exist "%RTOOLS_INSTALLER%" del "%RTOOLS_INSTALLER%"
:: )

:: Check for RStudio
echo Checking for RStudio...
echo Checking for RStudio... >> %SETUP_LOG%

if exist "C:\Program Files\RStudio\bin\rstudio.exe" (
    echo RStudio found at C:\Program Files\RStudio\bin\rstudio.exe
    echo RStudio found at C:\Program Files\RStudio\bin\rstudio.exe >> %SETUP_LOG%
    set "RSTUDIO_FOUND=1"
)
if exist "C:\Program Files\RStudio\rstudio.exe" (
    echo RStudio found at C:\Program Files\RStudio\rstudio.exe
    echo RStudio found at C:\Program Files\RStudio\rstudio.exe >> %SETUP_LOG%
    set "RSTUDIO_FOUND=1"
)

if "%RSTUDIO_FOUND%"=="0" (
    echo RStudio not found, downloading and installing...
    echo RStudio not found, downloading and installing... >> %SETUP_LOG%
    
    curl -L %RSTUDIO_URL% -o %RSTUDIO_INSTALLER% --progress-bar
    if errorlevel 1 (
        echo Error downloading RStudio!
        echo Error downloading RStudio! >> %SETUP_LOG%
        pause
        exit /b 1
    )
    
    echo Installing RStudio... - this might take a minute...
    echo Installing RStudio... - this might take a minute... >> %SETUP_LOG%
    start /wait %RSTUDIO_INSTALLER% /S
    
    echo RStudio installation completed
    echo RStudio installation completed >> %SETUP_LOG%

    :: Configure RStudio settings
    echo Configuring RStudio settings...
    echo Configuring RStudio settings... >> %SETUP_LOG%

    :: Create RStudio preferences directory if it doesn't exist
    if not exist "%LOCALAPPDATA%\RStudio" mkdir "%LOCALAPPDATA%\RStudio"

    :: Create rstudio-prefs.json with desired settings
    (
    echo {
    echo   "restore_last_project": true,
    echo   "restore_source_documents": false,
    echo   "load_workspace": false,
    echo   "save_workspace": "never",
    echo   "always_save_history": false,
    echo   "restore_workspace": false,
    echo   "rmd_chunk_output_inline": false
    echo }
    ) > "%LOCALAPPDATA%\RStudio\rstudio-prefs.json"

    :: Remove RStudio installer
    if exist "%RSTUDIO_INSTALLER%" del "%RSTUDIO_INSTALLER%"
) else (
    echo RStudio is already installed.
    echo RStudio is already installed. >> %SETUP_LOG%
)

:: Update PATH - Fixed version
echo Checking and updating PATH...
echo Checking and updating PATH... >> %SETUP_LOG%

if defined R_PATH (
    echo Checking if R is in PATH...
    echo Checking if R is in PATH... >> %SETUP_LOG%
    echo "%PATH%" | find /I "%R_PATH%" >nul
    if errorlevel 1 (
        echo Adding R to PATH: "%R_PATH%"
        echo Adding R to PATH: "%R_PATH%" >> %SETUP_LOG%
        setx /M PATH "%PATH%;%R_PATH%"
        if errorlevel 1 (
            echo Failed to add R to PATH
            echo Failed to add R to PATH >> %SETUP_LOG%
        ) else (
            echo Successfully added R to PATH
            echo Successfully added R to PATH >> %SETUP_LOG%
        )
    ) else (
        echo R is already in PATH
        echo R is already in PATH >> %SETUP_LOG%
    )
)

echo Checking if RTools is in PATH...
echo Checking if RTools is in PATH... >> %SETUP_LOG%
:: echo "%PATH%" | find /I "%RTOOLS_PATH%" >nul
:: if errorlevel 1 (
::     echo Adding RTools to PATH: "%RTOOLS_PATH%"
::     echo Adding RTools to PATH: "%RTOOLS_PATH%" >> %SETUP_LOG%
::     setx /M PATH "%PATH%;%RTOOLS_PATH%"
::     if errorlevel 1 (
::         echo Failed to add RTools to PATH
::         echo Failed to add RTools to PATH >> %SETUP_LOG%
::     ) else (
::         echo Successfully added RTools to PATH
::         echo Successfully added RTools to PATH >> %SETUP_LOG%
::     )
:: ) else (
::     echo RTools is already in PATH
::     echo RTools is already in PATH >> %SETUP_LOG%
:: )

:: Handle repository files
echo Downloading repository files...
echo Downloading repository files... >> %SETUP_LOG%

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
    echo Error downloading R Packages! >> %SETUP_LOG%
    pause
    exit /b 1
)

echo Downloading repository...
curl -L %REPO_URL%/archive/refs/heads/main.zip -o %REPO_ZIP% -s
if not exist "%REPO_ZIP%" (
    echo Error downloading repository!
    echo Error downloading repository! >> %SETUP_LOG%
    pause
    exit /b 1
)

:: Unzip files
echo Extracting archives to: %SETUP_LOG%
echo Extracting archives to: %SETUP_LOG% >> %SETUP_LOG%

echo Extracting R Packages - this might take a minute...
echo Extracting R Packages - this might take a minute... >> %SETUP_LOG%
powershell -Command "Expand-Archive -Force '%PACKAGES_ZIP%' '%PACKAGES_DIR%'"
echo Done!

if errorlevel 1 (
    echo Error extracting R Packages!
    echo Error extracting R Packages! >> %SETUP_LOG%
    pause
    exit /b 1
)

echo Extracting repository...
:: First extract to temp directory
powershell -Command "Expand-Archive -Force '%REPO_ZIP%' '%SCRIPT_DIR%temp_repo'"
if errorlevel 1 (
    echo Error extracting repository!
    echo Error extracting repository! >> %SETUP_LOG%
    pause
    exit /b 1
)

:: Create vsv_analysis directory if it doesn't exist
if not exist "%REPO_DIR%" mkdir "%REPO_DIR%"

:: Move contents of vsv_analysis-main to vsv_analysis
echo Moving repository files...
echo Moving repository files... >> %SETUP_LOG%
xcopy /Y /E "%SCRIPT_DIR%temp_repo\vsv_analysis-main\*" "%REPO_DIR%\" >nul 2>&1
rd /S /Q "%SCRIPT_DIR%temp_repo" >nul 2>&1

:: Merge files
echo Merging renv files...
echo Merging renv files... >> %SETUP_LOG%

xcopy /Y /E "%PACKAGES_DIR%\renv\*" "%REPO_DIR%\utils\renv\" >nul 2>&1
if errorlevel 1 (
    echo Error merging files!
    echo Error merging files! >> %SETUP_LOG%
    pause
    exit /b 1
)

:: Cleanup
echo Cleaning up...
echo Cleaning up... >> %SETUP_LOG%

rd /S /Q "%PACKAGES_DIR%" >nul 2>&1
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
echo Repository files extracted to: %SCRIPT_DIR%%REPO_DIR%
echo.
echo Total duration: %duration_minutes% minutes and %remaining_seconds% seconds
echo.
echo Setup complete! >> %SETUP_LOG%
echo Repository files extracted to: %REPO_DIR% >> %SETUP_LOG%
echo Script finished at %date% %time% >> %SETUP_LOG%
echo Total duration: %duration_minutes% minutes and %remaining_seconds% seconds >> %SETUP_LOG%

del %SETUP_LOG%

:: Open the project in RStudio
echo.
echo Opening VSV Analysis project in RStudio...

:: Find RStudio executable
set "RSTUDIO_EXE="
if exist "C:\Program Files\RStudio\bin\rstudio.exe" (
    set "RSTUDIO_EXE=C:\Program Files\RStudio\bin\rstudio.exe"
) else if exist "C:\Program Files\RStudio\rstudio.exe" (
    set "RSTUDIO_EXE=C:\Program Files\RStudio\rstudio.exe"
) else if exist "C:\Program Files (x86)\RStudio\bin\rstudio.exe" (
    set "RSTUDIO_EXE=C:\Program Files (x86)\RStudio\bin\rstudio.exe"
) else if exist "C:\Program Files (x86)\RStudio\rstudio.exe" (
    set "RSTUDIO_EXE=C:\Program Files (x86)\RStudio\rstudio.exe"
)

:: Open project if RStudio is found
if defined RSTUDIO_EXE (
    if exist "%PROJECT_FILE%" (
        start "" "%RSTUDIO_EXE%" "%PROJECT_FILE%"
        timeout /t 5 >nul
    ) else (
        echo Project file not found: %PROJECT_FILE%
        echo Opening RStudio without project...
        start "" "%RSTUDIO_EXE%"
    )

    :: Keep window open for 10 seconds before closing
    echo.
    echo This window will close in 10 seconds...
    timeout /t 10 >nul

) else (
    echo RStudio executable not found. Please open RStudio manually and load the project.
    :: Keep window open
    echo.
    echo Press any key to exit...
    pause >nul
)