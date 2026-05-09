# Launcher para modificar la pagina de Colores con Claude Code (extension de VS Code).
# - Verifica que Node y VS Code esten instalados.
# - Si es la primera vez, corre npm install.
# - Levanta el dev server de Astro (npm run dev) en background.
# - Espera a que el server este listo y abre el navegador.
# - Abre VS Code en el repo.
# - Al apretar cualquier tecla, apaga el dev server limpiamente y cierra.

$ErrorActionPreference = 'Continue'
$repoPath = $PSScriptRoot
Set-Location $repoPath

$port = 4321
$basePath = '/Colores-umc'
$url = "http://localhost:$port$basePath/"
$devLog = Join-Path $env:TEMP 'colores-dev.log'
$devErrLog = Join-Path $env:TEMP 'colores-dev-err.log'

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

function Find-Node {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    return ($cmd -ne $null)
}

function Find-Npm {
    # npm.cmd se prefiere sobre npm.ps1 porque no requiere ExecutionPolicy.
    $cmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command npm -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Stop-ProcessTree {
    param([int]$ProcessId)
    try {
        Get-CimInstance Win32_Process -Filter "ParentProcessId = $ProcessId" -ErrorAction SilentlyContinue | ForEach-Object {
            Stop-ProcessTree -ProcessId $_.ProcessId
        }
        Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
    } catch { }
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

function Wait-AnyKeyAndExit([int]$exitCode = 0) {
    Write-Host ""
    Write-Host "Apreta una tecla para cerrar..." -ForegroundColor Yellow
    try { [Console]::ReadKey($true) | Out-Null } catch { Start-Sleep -Seconds 5 }
    exit $exitCode
}

Write-Header

# Verificar Node
if (-not (Find-Node)) {
    Write-Host "ERROR: Node.js no esta instalado." -ForegroundColor Red
    Write-Host ""
    Write-Host "Para instalarlo:" -ForegroundColor Yellow
    Write-Host "  1. Andate a https://nodejs.org" -ForegroundColor Yellow
    Write-Host "  2. Descarga la version LTS (boton verde)" -ForegroundColor Yellow
    Write-Host "  3. Instalalo (Next, Next, Next, Install)" -ForegroundColor Yellow
    Write-Host "  4. Volve a abrir este acceso directo" -ForegroundColor Yellow
    Wait-AnyKeyAndExit 1
}

# Verificar VS Code
$vscodePath = Find-VSCode
if (-not $vscodePath) {
    Write-Host "ERROR: No encontre Visual Studio Code instalado." -ForegroundColor Red
    Write-Host "Instalalo desde https://code.visualstudio.com" -ForegroundColor Yellow
    Wait-AnyKeyAndExit 1
}

# Verificar npm
$npmPath = Find-Npm
if (-not $npmPath) {
    Write-Host "ERROR: npm no esta disponible." -ForegroundColor Red
    Write-Host "Reinstala Node.js desde https://nodejs.org" -ForegroundColor Yellow
    Wait-AnyKeyAndExit 1
}

# Si es primera vez, instalar dependencias
if (-not (Test-Path "node_modules")) {
    Write-Host "Primera vez ejecutando: instalando dependencias..." -ForegroundColor Yellow
    Write-Host "(Esto tarda 30-60 segundos solo la primera vez)" -ForegroundColor DarkGray
    Write-Host ""
    & $npmPath install
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR instalando dependencias." -ForegroundColor Red
        Write-Host "Revisa el output de arriba para ver que paso." -ForegroundColor Yellow
        Wait-AnyKeyAndExit 1
    }
    Write-Host ""
    Write-Host "Dependencias instaladas." -ForegroundColor Green
    Write-Host ""
}

# Limpiar logs previos y liberar puerto
Remove-Item $devLog -ErrorAction SilentlyContinue
Remove-Item $devErrLog -ErrorAction SilentlyContinue
Stop-PortProcess -portNumber $port

# Levantar el dev server como proceso hijo, redirigiendo stdout/stderr a archivos
Write-Host "Levantando preview local..." -ForegroundColor Yellow
$devProcess = Start-Process -FilePath $npmPath -ArgumentList 'run','dev' `
    -PassThru -NoNewWindow `
    -RedirectStandardOutput $devLog `
    -RedirectStandardError $devErrLog

# Esperar a que el server este listo (hasta 60s)
$timeout = (Get-Date).AddSeconds(60)
$ready = $false
while ((Get-Date) -lt $timeout) {
    if ($devProcess.HasExited) {
        Write-Host ""
        Write-Host "ERROR: el server se cerro inesperadamente." -ForegroundColor Red
        if (Test-Path $devErrLog) {
            Write-Host "Errores:" -ForegroundColor Yellow
            Get-Content $devErrLog | Select-Object -Last 20
        }
        Wait-AnyKeyAndExit 1
    }
    if (Test-Path $devLog) {
        $content = Get-Content $devLog -Raw -ErrorAction SilentlyContinue
        if ($content -match "ready in") {
            $ready = $true
            break
        }
    }
    Start-Sleep -Milliseconds 500
}

if (-not $ready) {
    Write-Host "ADVERTENCIA: el server tardo mucho. Revisa $devErrLog si hay problemas." -ForegroundColor Yellow
}

Write-Host "Preview local levantado en $url" -ForegroundColor Green

# Abrir navegador
Write-Host "Abriendo navegador..." -ForegroundColor Yellow
Start-Process $url
Start-Sleep -Milliseconds 500

# Abrir VS Code en ventana nueva apuntando al repo
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
Write-Host "Cuando termines, apreta cualquier tecla aca para apagar el preview." -ForegroundColor Yellow
Write-Host "(VS Code y el navegador podes cerrarlos normalmente cuando quieras)" -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor DarkGray
Write-Host ""

# Esperar tecla
try {
    [Console]::ReadKey($true) | Out-Null
} catch {
    Start-Sleep -Seconds 5
}

Write-Host ""
Write-Host "Apagando preview local..." -ForegroundColor Yellow

# Terminar el proceso npm y todos sus hijos (especialmente node)
Stop-ProcessTree -ProcessId $devProcess.Id

# Por las dudas, liberar el puerto si quedo ocupado
Start-Sleep -Milliseconds 500
Stop-PortProcess -portNumber $port

Write-Host "Listo. Hasta la proxima!" -ForegroundColor Green
Start-Sleep -Seconds 1
