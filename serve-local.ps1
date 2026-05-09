# Mini servidor HTTP estatico en PowerShell puro.
# Sirve los archivos de la carpeta Root en el puerto Port.
# Se llama desde abrir-claude.ps1 como proceso oculto.

param(
    [int]$Port = 8000,
    [string]$Root = $PSScriptRoot
)

$mimeMap = @{
    '.html'  = 'text/html; charset=utf-8'
    '.htm'   = 'text/html; charset=utf-8'
    '.css'   = 'text/css; charset=utf-8'
    '.js'    = 'application/javascript; charset=utf-8'
    '.json'  = 'application/json; charset=utf-8'
    '.xml'   = 'application/xml; charset=utf-8'
    '.txt'   = 'text/plain; charset=utf-8'
    '.png'   = 'image/png'
    '.jpg'   = 'image/jpeg'
    '.jpeg'  = 'image/jpeg'
    '.gif'   = 'image/gif'
    '.webp'  = 'image/webp'
    '.svg'   = 'image/svg+xml'
    '.ico'   = 'image/x-icon'
    '.bmp'   = 'image/bmp'
    '.woff'  = 'font/woff'
    '.woff2' = 'font/woff2'
    '.ttf'   = 'font/ttf'
    '.otf'   = 'font/otf'
    '.eot'   = 'application/vnd.ms-fontobject'
    '.pdf'   = 'application/pdf'
    '.mp4'   = 'video/mp4'
    '.webm'  = 'video/webm'
    '.mp3'   = 'audio/mpeg'
    '.wav'   = 'audio/wav'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")

try {
    $listener.Start()
} catch {
    exit 1
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rel = [System.Net.WebUtility]::UrlDecode($request.Url.LocalPath).TrimStart('/')
        if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }

        $filePath = Join-Path $Root $rel

        if ((Test-Path $filePath -PathType Container)) {
            $filePath = Join-Path $filePath 'index.html'
        }

        if (Test-Path $filePath -PathType Leaf) {
            try {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = $mimeMap[$ext]
                if (-not $mime) { $mime = 'application/octet-stream' }
                $response.ContentType = $mime
                $response.ContentLength64 = $bytes.Length
                $response.StatusCode = 200
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } catch {
                $response.StatusCode = 500
            }
        } else {
            $response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - $rel")
            $response.ContentType = 'text/plain; charset=utf-8'
            $response.ContentLength64 = $msg.Length
            $response.OutputStream.Write($msg, 0, $msg.Length)
        }

        $response.OutputStream.Close()
    } catch {
        if (-not $listener.IsListening) { break }
    }
}
