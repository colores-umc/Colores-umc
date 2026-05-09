# Launcher para modificar la pagina de Colores con Claude Code (extension de VS Code).
# Levanta un mini servidor HTTP en PowerShell puro, abre el navegador,
# y abre VS Code en una ventana nueva apuntando al repo.
# Al apretar cualquier tecla en esta ventana, apaga el servidor y cierra todo.

$ErrorActionPreference = 'Continue'
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
            foreach ($c in $conn) {
                Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
            }
            Start-Sleep -Milliseconds 500
        }
    } catch { }
}

function Wait-ForPort([int]$portNumber, [int]$timeoutSec = 10) {
    $start = Get-Date
    while (((Get-Date) - $start).TotalSeconds -lt $timeoutSec) {
        $tcp = New-Object Net.Sockets.TcpClient
        try {
            $tcp.Connect("127.0.0.1", $portNumber)
            $tcp.Close()
            return $true
        } catch {
            Start-Sleep -Milliseconds 200
        } finally {
            $tcp.Dispose()
        }
    }
    return $false
}

Write-Header

# Verificar VS Code
$vscodePath = Find-VSCode
if (-not $vscodePath) {
    Write-Host "ERROR: No encontre Visual Studio Code instalado." -ForegroundColor Red
    Write-Host "Instalalo desde https://code.visualstudio.com" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Apreta una tecla para cerrar..." -ForegroundColor Yellow
    [Console]::ReadKey($true) | Out-Null
    exit 1
}

# Liberar puerto si quedo ocupado
Stop-PortProcess -portNumber $port

# Levantar mini server PowerShell en proceso oculto
Write-Host "Levantando preview local en $url ..." -ForegroundColor Yellow
$serveScript = Join-Path $repoPath 'serve-local.ps1'

$server = Start-Process powershell `
    -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy","Bypass",
        "-File",$serveScript,
        "-Port",$port,
        "-Root",$repoPath
    ) `
    -WindowStyle Hidden -PassThru

# Esperar a que el puerto este escuchando
$ready = Wait-ForPort -portNumber $port -timeoutSec 10
if (-not $ready) {
    Write-Host "ERROR: el preview local no arranco. Avisa a Gaston." -ForegroundColor Red
    Write-Host ""
    Write-Host "Apreta una tecla para cerrar..." -ForegroundColor Yellow
    [Console]::ReadKey($true) | Out-Null
    if ($server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

# Abrir navegador
Write-Host "Abriendo navegador..." -ForegroundColor Yellow
Start-Process $url
Start-Sleep -Milliseconds 500

# Abrir VS Code en nueva ventana, apuntando explicitamente a la carpeta del repo
Write-Host "Abriendo Visual Studio Code en $repoPath ..." -ForegroundColor Yellow
& $vscodePath --new-window $repoPath

Write-Host ""
Write-Host "Listo. En VS Code abri Claude desde el panel lateral o con Ctrl+Esc." -ForegroundColor Green
Write-Host ""
Write-Host "Algunos ejemplos de lo que pueden pedirle a Claude:" -ForegroundColor Green
Write-Host "  - cambia la pagina con tema navideno"
Write-Host "  - actualiza el horario de atencion"
Write-Host "  - subi esta foto al banner principal"
Write-Host "  - desha el ultimo cambio"
Write-Host ""
Write-Host "Cuando Claude haga un cambio, refresca el navegador (F5) para verlo." -ForegroundColor Cyan
Write-Host "Si te gusta, deci a Claude: subilo  o  publicalo" -ForegroundColor Cyan
Write-Host "Si no te gusta, deci: sacalo  o  volve como estaba" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host "Cuando termines de trabajar, apreta cualquier tecla aca para apagar el preview." -ForegroundColor Yellow
Write-Host "(VS Code y el navegador podes cerrarlos normalmente cuando quieras)" -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host ""

# Esperar tecla con [Console]::ReadKey (mas confiable que $Host.UI.RawUI.ReadKey)
try {
    [Console]::ReadKey($true) | Out-Null
} catch {
    # Si no hay consola interactiva (raro), igual seguimos al cleanup
    Write-Host "No detecto teclado, cerrando en 5 segundos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
}

Write-Host ""
Write-Host "Apagando preview local..." -ForegroundColor Yellow

# Cleanup
if ($server -and -not $server.HasExited) {
    Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
}
Stop-PortProcess -portNumber $port

Write-Host "Listo. Hasta la proxima!" -ForegroundColor Green
Start-Sleep -Seconds 1
