@echo off
setlocal

:: List of target endpoints (sanitized)
set endpoints=PC001 PC002 PC003 PC004 PC005 PC006 PC007 PC008

:: Message to send
set message="IT NOTICE: Please contact the IT Service Desk regarding your device."

:: Loop through each endpoint
for %%E in (%endpoints%) do (
    echo Sending message to %%E...
    msg * /server:%%E %message%
)

endlocal
