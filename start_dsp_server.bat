@echo off
REM Starts the local old-dsp-reference (DarkstarProject) server, fully separate from C:\topaz's
REM own tpzdb database (uses dspdb instead). Uses the SAME ports as Topaz (54xxx) -- do NOT run
REM this at the same time as the Topaz server, since they would collide on those ports.
REM Requires DSGame-server_64.exe / DSConnect-server_64.exe / DSSearch-server_64.exe to already be
REM built (win32/darkstar.sln, Release|x64 -- OutDir places them at the repo root, not win32\x64\Release).
cd /d "%~dp0"

set BINDIR=%~dp0

if not exist "%BINDIR%DSSearch-server_64.exe" (
    echo [ERROR] DSSearch-server_64.exe not found in %BINDIR% -- build the solution first.
    pause
    exit /b 1
)
if not exist "%BINDIR%DSConnect-server_64.exe" (
    echo [ERROR] DSConnect-server_64.exe not found in %BINDIR% -- build the solution first.
    pause
    exit /b 1
)
if not exist "%BINDIR%DSGame-server_64.exe" (
    echo [ERROR] DSGame-server_64.exe not found in %BINDIR% -- build the solution first.
    pause
    exit /b 1
)

echo Starting DSSearch-server (search_server.conf, port 54002)...
start "DSP Search Server" "%BINDIR%DSSearch-server_64.exe"

echo Starting DSConnect-server (login_darkstar.conf, ports 54230/54001/54231)...
start "DSP Connect Server" "%BINDIR%DSConnect-server_64.exe"

echo Starting DSGame-server (map_darkstar.conf, port 54230, msg 54003)...
start "DSP Map Server" "%BINDIR%DSGame-server_64.exe"

echo.
echo All 3 DSP server processes launched in separate windows.
echo Use stop_dsp_server.bat to stop them, or close each window.
