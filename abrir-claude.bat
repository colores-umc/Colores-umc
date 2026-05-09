@echo off
REM Acceso rapido para modificar la pagina de Colores con Claude Code.
REM Abre PowerShell en la carpeta del repo y arranca Claude.

cd /d "%~dp0"
echo.
echo ========================================
echo   Modificar pagina de Colores
echo ========================================
echo.
echo Carpeta: %CD%
echo.
echo Escribi lo que queres cambiar y Claude lo va a hacer.
echo Ejemplos:
echo   - cambia la pagina con tema navideno
echo   - actualiza el horario de atencion
echo   - desha el ultimo cambio
echo.
echo ========================================
echo.

REM Lanzar Claude Code. Si no esta instalado, mostrar mensaje claro.
where claude >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Claude Code no esta instalado.
    echo.
    echo Para instalarlo, abrir PowerShell como administrador y correr:
    echo   npm install -g @anthropic-ai/claude-code
    echo.
    pause
    exit /b 1
)

claude
