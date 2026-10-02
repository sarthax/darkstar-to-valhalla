@echo off
REM Stops the local old-dsp-reference DSP server processes started by start_dsp_server.bat.
REM Does NOT touch anything under C:\topaz (that server is started/stopped separately).
echo Stopping DSP server processes...
taskkill /IM DSGame-server_64.exe /F 2>nul
taskkill /IM DSConnect-server_64.exe /F 2>nul
taskkill /IM DSSearch-server_64.exe /F 2>nul
echo Done.
pause
