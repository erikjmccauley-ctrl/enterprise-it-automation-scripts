@echo off
setlocal

:: Prompt for target computer
set /p targetPC=Enter target computer name: 

:: Message to send
set message="IT SUPPORT: Please approve the pending remote session request so installation can be completed."

if "%targetPC%"=="" (
    echo No computer name entered. Exiting.
    exit /b
)

echo Sending message to %targetPC%...
msg * /server:%targetPC% %message%

endlocal
