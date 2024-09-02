@echo off
setlocal

set "targetFile=Wub_x64.exe"
set "searchDir=%userprofile%\Downloads"
set "params=/E"

echo Searching for %targetFile% in %searchDir% and all subfolders...

for /f "delims=" %%i in ('dir /s /b "%searchDir%\%targetFile%" 2^>nul') do (
    set "foundFile=%%i"
    goto :runFile
)

echo %targetFile% not found.
pause
exit
goto :eof

:runFile
echo %targetFile% found at %foundFile%
echo Running %foundFile% with parameters %params%...
start "" "%foundFile%" %params%
timeout /t 5 /nobreak >nul

echo Checking if wuauserv is running...
sc query wuauserv | findstr /i "RUNNING" >nul
if %errorlevel% equ 0 (
    echo wuauserv is already running.
    echo.
    set /p startGGLeap="Would you like to start the ggLeap client? (Y/N): "
    if /i "%startGGLeap%"=="Y" (
        echo Stopping clientinterface.exe if it's running...
        taskkill /f /im clientinterface.exe >nul 2>&1
        echo Starting GGLeap client...
        start "" "C:\ggLeap\clientinterface.exe"
    ) else (
        echo GGLeap client will not be started.
    )
) else (
    echo wuauserv failed to start, reboot may be required.
    echo.
    set /p rebootChoice="Would you like to reboot the system now? (Y/N): "
    if /i "%rebootChoice%"=="Y" (
        echo Initiating system reboot...
        shutdown /r /t 30
    ) else (
        echo No reboot selected. Exiting.
    )
)

endlocal
timeout 5
exit
