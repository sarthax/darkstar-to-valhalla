@echo off
REM DSP Database Management Tool launcher. Finds Python (py launcher, then python) and runs DBtool.py.
setlocal
set "TOOL=%~dp0DBtool.py"
cd /d "%~dp0"

where py >nul 2>&1
if %ERRORLEVEL% equ 0 ( set "PY=py -3" & goto run )
where python >nul 2>&1
if %ERRORLEVEL% equ 0 ( set "PY=python" & goto run )
echo [ERROR] Python not found. Install Python 3 or add it to PATH.
pause
exit /b 1

:run
%PY% "%TOOL%" %*
set RC=%ERRORLEVEL%
if not "%RC%"=="0" echo. & echo [DBtool exited with code %RC%] see error.log
echo.
pause
exit /b %RC%
