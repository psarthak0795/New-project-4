@echo off
REM ============================================================
REM  THE ONE FILE TO RUN. Double-click this and Org Tracker starts.
REM
REM  First time on a computer: automatically builds what's needed
REM  (venvs + dependencies), which takes a minute or two.
REM  Every time after that: starts in a few seconds, silently,
REM  with no visible windows (check the system tray for the agent).
REM ============================================================

cd /d "%~dp0"

set "NEED_SETUP="

if not exist "backend\venv\Scripts\python.exe" set "NEED_SETUP=1"
if not exist "desktop-agent\venv\Scripts\python.exe" set "NEED_SETUP=1"
if not exist "frontend\node_modules" set "NEED_SETUP=1"

REM Even if the venv files exist, they may be broken (e.g. this project
REM folder was copied from a different computer). Check they actually run
REM - using the console python.exe, not pythonw.exe, so a broken venv
REM prints an error here instead of risking a silent blocking popup.
if not defined NEED_SETUP (
    "backend\venv\Scripts\python.exe" --version >nul 2>nul
    if errorlevel 1 set "NEED_SETUP=1"
)
if not defined NEED_SETUP (
    "desktop-agent\venv\Scripts\python.exe" --version >nul 2>nul
    if errorlevel 1 set "NEED_SETUP=1"
)

if defined NEED_SETUP (
    echo First run on this computer - setting up now, this only happens once
    echo and may take a minute or two. Please wait...
    echo.
    call "%~dp0setup.bat" --auto
    if errorlevel 1 (
        echo.
        echo Setup failed - see the messages above, fix the issue, and run
        echo run.bat again.
        pause
        exit /b 1
    )
    echo.
)

echo Ensuring the PostgreSQL database and tables are ready...
"backend\venv\Scripts\python.exe" -c "from app.database import engine; from app import models; models.Base.metadata.create_all(bind=engine); print('PostgreSQL schema ready')"

echo If you have not created the first admin account yet, run:
    echo   backend\venv\Scripts\python.exe backend\create_admin.py
    echo.

echo Starting Org Tracker...
call "%~dp0start-all-background.bat"

echo.
echo Org Tracker is now running in the background.
echo   Dashboard: http://localhost:5173
echo   Look for the tracker icon in the system tray.
echo   To stop it, run stop-all.bat.
echo.
echo This window will close automatically in a few seconds.
timeout /t 6 >nul
