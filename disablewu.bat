@echo off
setlocal

set "targetFile=Wub_x64.exe"
set "searchDir=%userprofile%\Downloads"
set "params=/D /P"

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

echo.
set /p action="Would you like to shut down or reboot the system? (S for shutdown / R for reboot): "
if /i "%action%"=="S" (
    echo Initiating system shutdown...
    shutdown /s /t 5
) else if /i "%action%"=="R" (
    echo Initiating system reboot...
    shutdown /r /t 5
) else (
    echo No valid option selected. Exiting.
)

endlocal
timeout 5
