@echo off
REM Local dev use only — for the real multi-machine rollout, the backend
REM runs once on a central server (see README: "Deploying across your
REM organization"), not launched per-employee like this.
cd /d "%~dp0"
call venv\Scripts\activate.bat
uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
