@echo off
REM Launcher: invoca el script de PowerShell que arma todo el flujo.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0abrir-claude.ps1"
