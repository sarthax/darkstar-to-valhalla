@echo off
REM Restore/Import Script for DSP
REM Usage: restore.bat [backup_file.sql]
REM Location: D:\Claude\old-dsp-reference\tools

set SCRIPT_DIR=%~dp0
set MYSQL_BIN=%SCRIPT_DIR%..\..\MySQL\bin\
set CONFIG_FILE=%SCRIPT_DIR%..\conf\map_darkstar.conf

REM Read database info from config
for /f "tokens=1,2 delims=:" %%a in ('findstr "^mysql_database" %CONFIG_FILE% 2^>nul') do set MYSQL_DATABASE=%%b
for /f "tokens=1,2 delims=:" %%a in ('findstr "^mysql_host" %CONFIG_FILE% 2^>nul') do set MYSQL_HOST=%%b
for /f "tokens=1,2 delims=:" %%a in ('findstr "^mysql_port" %CONFIG_FILE% 2^>nul') do set MYSQL_PORT=%%b
for /f "tokens=1,2 delims=:" %%a in ('findstr "^mysql_login" %CONFIG_FILE% 2^>nul') do set MYSQL_LOGIN=%%b
for /f "tokens=1,2 delims=:" %%a in ('findstr "^mysql_password" %CONFIG_FILE% 2^>nul') do set MYSQL_PASSWORD=%%b

if not defined MYSQL_DATABASE (
    echo [ERROR] Could not read database name from config file.
    pause
    exit /b 1
)

REM Check if a backup file was specified
if "%~1"=="" (
    echo.
    echo ============================================
    echo    DSP Database Restore Tool
    echo ============================================
    echo.

    REM List available backups
    if exist "%SCRIPT_DIR%..\sql\backups" (
        echo Available backups:
        echo ===================
        for %%F in ("%SCRIPT_DIR%..\sql\backups"*.sql) do (
            echo [%%~nF] %%~zF bytes
        )
    ) else (
        echo No backups directory found.
    )

    echo.
    echo Type the number of backup to restore or file name directly.
    echo Type 'full' to create full backup first, 'lite' for lite backup.
    echo.
)

:MENU
REM Create fresh backup before restore (safety first!)
set /p BACKUP_TYPE="Create new backup first? [y/N] "

if /i "%BACKUP_TYPE%"=="y" (
    call backup.bat %~1

    if errorlevel 1 (
        echo.
        echo [ERROR] Backup failed. Please fix the issue and try again.
        pause
        exit /b 1
    )
)

REM Get backup file from user input or argument
if "%~1"=="" (
    set /p BACKUP_FILE="Enter backup filename: "
) else (
    set BACKUP_FILE=%~1
)

REM Check if file exists
if not exist "%SCRIPT_DIR%..\sql\backups\%BACKUP_FILE%.sql" (
    echo.
    echo [ERROR] File not found: %SCRIPT_DIR%..\sql\backups\%BACKUP_FILE%.sql
    pause
    exit /b 1
)

REM Confirm restore
echo.
echo ============================================
echo    RESTORE WARNING
echo ============================================
echo.
echo This will import: %BACKUP_FILE%.sql
echo.
echo IMPORTANT: If this is a full backup, you should manually update
echo            the DB_VER in ..\conf\version.conf to match the
echo            database version from the filename before restoring!
echo.

set /p CONFIRM="Are you sure you want to restore? [y/N] "

if /i not "%CONFIRM%"=="y" (
    echo Restore cancelled.
    pause
    exit /b 0
)

REM Determine MySQL command path
if exist "%MYSQL_BIN%mysql.exe" (
    set MYSQL_CMD="%MYSQL_BIN%mysql.exe"
) else (
    where mysql >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set MYSQL_CMD=mysql
    ) else (
        echo.
        echo [ERROR] MySQL not found in PATH or bin directory.
        pause
        exit /b 1
    )
)

echo.
echo ============================================
echo    Restoring database...
echo ============================================
echo.
echo Running: %MYSQL_CMD% -h %MYSQL_HOST% -P %MYSQL_PORT% -u %MYSQL_LOGIN% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < "%SCRIPT_DIR%..\sql\backups\%BACKUP_FILE%.sql%" 2>>"%SCRIPT_DIR%..\tools\restore_error.log"

REM Run restore
"%MYSQL_CMD%" -h %MYSQL_HOST% -P %MYSQL_PORT% -u %MYSQL_LOGIN% -p%MYSQL_PASSWORD% %MYSQL_DATABASE% < "%SCRIPT_DIR%..\sql\backups\%BACKUP_FILE%.sql%" >>"%SCRIPT_DIR%..\tools\restore_error.log" 2>&1

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Database restored from: %BACKUP_FILE%.sql

    REM Check for errors
    if exist "%SCRIPT_DIR%..\tools\restore_error.log" (
        findstr /c"Error" "%SCRIPT_DIR%..\tools\restore_error.log" >nul 2>&1
        if %ERRORLEVEL% equ 0 (
            echo.
            echo [WARNING] There may be some errors in the restore. Check restore_error.log
        )
    )
) else (
    echo.
    echo [ERROR] Restore failed. Check restore_error.log for details.
)

echo.
pause
