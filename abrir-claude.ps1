# Launcher para modificar la pagina de Colores con Claude Code (extension de VS Code).
# - Levanta un mini servidor HTTP en PowerShell puro (mismo proceso, via runspace).
# - Abre el navegador en localhost.
# - Abre VS Code en una ventana nueva apuntando a la carpeta del repo.
# Al apretar cualquier tecla apaga el servidor y cierra.

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

# Crear el listener en el thread principal: asi podemos pararlo desde aca
# y forzar que el runspace salga del while loop.
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
} catch {
    Write-Host "ERROR levantando el preview local: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Posibles causas: antivirus o firewall bloqueando localhost." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Apreta una tecla para cerrar..." -ForegroundColor Yellow
    [Console]::ReadKey($true) | Out-Null
    exit 1
}

Write-Host "Preview local levantado en $url" -ForegroundColor Green

# Mime map - lo pasamos al runspace por valor
$mimeMap = @{
    '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
    '.css'='text/css; charset=utf-8'; '.js'='application/javascript; charset=utf-8'
    '.json'='application/json; charset=utf-8'; '.xml'='application/xml; charset=utf-8'
    '.txt'='text/plain; charset=utf-8'; '.png'='image/png'
    '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'
    '.webp'='image/webp'; '.svg'='image/svg+xml'; '.ico'='image/x-icon'
    '.bmp'='image/bmp'; '.woff'='font/woff'; '.woff2'='font/woff2'
    '.ttf'='font/ttf'; '.otf'='font/otf'; '.eot'='application/vnd.ms-fontobject'
    '.pdf'='application/pdf'; '.mp4'='video/mp4'; '.webm'='video/webm'
    '.mp3'='audio/mpeg'; '.wav'='audio/wav'
}

# Worker que atiende requests. El listener se le pasa por argumento y lo
# para el thread principal cuando termina, lo que rompe GetContext().
$workerScript = {
    param($listener, $Root, $mimeMap)
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $rel = [System.Net.WebUtility]::UrlDecode($request.Url.LocalPath).TrimStart('/')
            if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
            $filePath = Join-Path $Root $rel
            if (Test-Path $filePath -PathType Container) {
                $filePath = Join-Path $filePath 'index.html'
            }

            if (Test-Path $filePath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = $mimeMap[$ext]
                if (-not $mime) { $mime = 'application/octet-stream' }
                $response.ContentType = $mime
                $response.ContentLength64 = $bytes.Length
                $response.StatusCode = 200
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
            }
            $response.OutputStream.Close()
        } catch {
            # GetContext lanza excepcion cuando se para el listener: salimos limpio
            if (-not $listener.IsListening) { break }
        }
    }
}

$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()
$psInstance = [powershell]::Create()
$psInstance.Runspace = $runspace
[void]$psInstance.AddScript($workerScript).AddArgument($listener).AddArgument($repoPath).AddArgument($mimeMap)
$asyncResult = $psInstance.BeginInvoke()

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

# Cleanup ordenado: primero parar el listener (lo cual rompe GetContext en el runspace),
# despues limpiar runspace y psInstance, despues forzar puerto libre.
try { $listener.Stop() } catch { }
try { $listener.Close() } catch { }

# Le damos un margen al runspace para que termine solo
$timeout = (Get-Date).AddSeconds(2)
while (-not $asyncResult.IsCompleted -and (Get-Date) -lt $timeout) {
    Start-Sleep -Milliseconds 100
}

try { $psInstance.Dispose() } catch { }
try { $runspace.Close() } catch { }
try { $runspace.Dispose() } catch { }
Stop-PortProcess -portNumber $port

Write-Host "Listo. Hasta la proxima!" -ForegroundColor Green
Start-Sleep -Seconds 1
