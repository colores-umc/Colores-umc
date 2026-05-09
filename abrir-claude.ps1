# Launcher para modificar la pagina de Colores con Claude Code (extension de VS Code).
# Levanta un servidor local, abre el navegador y abre VS Code en el repo.
# Cuando aprietas una tecla en esta ventana, apaga el servidor.

$repoPath = $PSScriptRoot
Set-Location $repoPath

$port = 8000
$url = "http://localhost:$port"

function Write-Header {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Modificar pagina de Colores" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Find-VSCode {
    # Devuelve la ruta a code.cmd, o $null si no se encuentra.
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
        "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

function Stop-PortProcess([int]$portNumber) {
    try {
        $conn = Get-NetTCPConnection -LocalPort $portNumber -State Listen -ErrorAction SilentlyContinue
        if ($conn) {
            $procId = $conn[0].OwningProcess
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
        }
    } catch { }
}

Write-Header

# Verificaciones
$pythonOk = [bool](Get-Command python -ErrorAction SilentlyContinue)
$vscodePath = Find-VSCode

if (-not $vscodePath) {
    Write-Host "ERROR: No encontre Visual Studio Code instalado." -ForegroundColor Red
    Write-Host "Instalalo desde https://code.visualstudio.com y volve a abrir este acceso directo." -ForegroundColor Yellow
    Write-Host ""
    Pause
    exit 1
}

if (-not $pythonOk) {
    Write-Host "ATENCION: Python no esta instalado. No voy a poder levantar el preview local." -ForegroundColor Yellow
    Write-Host "Vas a poder editar igual con Claude, pero solo veras los cambios cuando se publiquen." -ForegroundColor Yellow
    Write-Host ""
}

# Liberar puerto si quedo ocupado de una sesion anterior
if ($pythonOk) {
    Stop-PortProcess -portNumber $port
}

# Levantar servidor local en background
$server = $null
if ($pythonOk) {
    Write-Host "Levantando preview local en $url ..." -ForegroundColor Yellow
    $server = Start-Process -FilePath "python" `
        -ArgumentList "-m","http.server",$port `
        -WorkingDirectory $repoPath `
        -PassThru -WindowStyle Hidden

    Start-Sleep -Seconds 2

    Write-Host "Abriendo navegador..." -ForegroundColor Yellow
    Start-Process $url
    Start-Sleep -Milliseconds 500
}

# Abrir VS Code en la carpeta del repo
Write-Host "Abriendo Visual Studio Code..." -ForegroundColor Yellow
& $vscodePath $repoPath

Write-Host ""
Write-Host "Listo. En VS Code podes abrir Claude desde el panel lateral o con Ctrl+Esc." -ForegroundColor Green
Write-Host ""
Write-Host "Algunos ejemplos de lo que pueden pedirle a Claude:" -ForegroundColor Green
Write-Host "  - cambia la pagina con tema navideno"
Write-Host "  - actualiza el horario de atencion"
Write-Host "  - subi esta foto al banner principal"
Write-Host "  - desha el ultimo cambio"
Write-Host ""
Write-Host "Cuando Claude haga un cambio, refresca el navegador (F5) para verlo." -ForegroundColor Cyan
Write-Host "Si te gusta, deci a Claude:  subilo  o  publicalo" -ForegroundColor Cyan
Write-Host "Si no te gusta, deci:  sacalo  o  volve como estaba" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "Cuando termines de trabajar, apreta cualquier tecla aca para apagar el preview." -ForegroundColor Yellow
Write-Host "(VS Code lo podes cerrar normalmente)" -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor DarkGray

# Esperar tecla para apagar el servidor
try {
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} finally {
    if ($server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
    }
    Stop-PortProcess -portNumber $port
    Write-Host ""
    Write-Host "Servidor apagado. Hasta la proxima!" -ForegroundColor Green
    Start-Sleep -Seconds 1
}
