@echo off
setlocal

:: Define variables
set "versionFile=%programdata%\ggLeap\installed-salad-version.txt"
set "requiredVersion=1.6.4"
set "tempFile=%temp%\current_version.txt"
set "targetFile=Wub_x64.exe"
set "searchDir=%userprofile%\Downloads"
set "params=/E"
set "url=https://github.com/ggtristams/ggc/raw/main/Wub.zip"
set "tempDir=%temp%\Wub"

:: Cleanup any existing temporary files
if exist "%tempFile%" del "%tempFile%"
if exist "%tempDir%" rmdir /s /q "%tempDir%"

goto :checkFileExistence

:checkFileExistence
echo Checking if Salad is already installed...
if exist "%versionFile%" (
    echo - Salad is already installed.
    goto :extractVersion
) else (
    echo %versionFile% not found.
    goto :searchAndRun
)

:extractVersion
echo Extracting installed version...
type "%versionFile%" > "%tempFile%"
goto :compareVersion

:compareVersion
echo Checking if installed version is the latest...
set /p installedVersion=<"%tempFile%"
echo - Installed Version: %installedVersion%

if /i "%installedVersion%"=="%requiredVersion%" (
    goto :abort
) else (
    echo Salad version is outdated or different.
)

:searchAndRun
echo Searching for %targetFile% in %searchDir% and all subfolders...
for /f "delims=" %%i in ('dir /s /b "%searchDir%\%targetFile%" 2^>nul') do (
    set "foundFile=%%i"
    goto :runFile
)

echo %targetFile% not found in %searchDir%. Checking temporary directory...
if exist "%tempDir%\%targetFile%" (
    echo %targetFile% already exists in %tempDir%.
    goto :runFile
) else (
    echo %targetFile% not found in %tempDir%. Downloading and extracting...
    goto :downloadAndRun
)

:runFile
echo %targetFile% found at %foundFile%.
echo Running %foundFile% with parameters %params%...
start "" "%foundFile%" %params%
goto :checkService

:downloadAndRun
echo Creating temporary directory...
mkdir "%tempDir%"

echo Downloading Wub.zip...
bitsadmin /transfer downloadWub /download /priority high %url% "%tempDir%\Wub.zip"

echo Extracting Wub.zip...
powershell -command "Expand-Archive -Path '%tempDir%\Wub.zip' -DestinationPath '%tempDir%'"

if exist "%tempDir%\%targetFile%" (
    echo %targetFile% found at %tempDir%\%targetFile%.
    echo Running %targetFile% with parameters %params%...
    start "" "%tempDir%\%targetFile%" %params%
) else (
    echo %targetFile% not found in %tempDir%.
    goto :cleanup
)

:checkService
timeout /t 5 /nobreak >nul

echo Checking if wuauserv is running...
sc query wuauserv | findstr /i "RUNNING" >nul
if %errorlevel% equ 0 (
    echo wuauserv is already running.
    echo.
    choice /c YN /n /t 10 /d N /m "Would you like to restart the ggLeap client? (Y/N): "
    if %errorlevel% equ 1 (
        echo Stopping clientinterface.exe if it's running...
        taskkill /f /im clientinterface.exe >nul 2>&1
        echo Starting ggLeap client...
        start "" "C:\ggLeap\clientinterface.exe"
    ) else (
        echo No response or 'N' selected. ggLeap client will not be started.
    )
) else (
    echo wuauserv failed to start, reboot may be required.
    echo.
    choice /c YN /n /t 10 /d N /m "Would you like to reboot the system now? (Y/N): "
    if %errorlevel% equ 1 (
        echo Initiating system reboot...
        shutdown /r /t 5
    ) else (
        echo No response or 'N' selected. No reboot will occur. Exiting.
    )
)

:abort
echo Salad version is the latest.
goto :cleanup

:cleanup
echo Cleaning up temporary files...
if exist "%tempFile%" del "%tempFile%"
if exist "%tempDir%" rmdir /s /q "%tempDir%"

:end
echo - Cleanup completed.
endlocal
timeout /t 10
exit /b
