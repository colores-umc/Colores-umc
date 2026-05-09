# Script para crear el acceso directo en el escritorio.
# Correr una sola vez (click derecho > Ejecutar con PowerShell).

$ws = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop 'Modificar pagina Colores.lnk'
$repoPath = $PSScriptRoot

$sc = $ws.CreateShortcut($shortcutPath)
$sc.TargetPath = Join-Path $repoPath 'abrir-claude.bat'
$sc.WorkingDirectory = $repoPath
$sc.Description = 'Abrir Claude Code para modificar la pagina de Colores'
$sc.IconLocation = 'shell32.dll,165'
$sc.Save()

Write-Host ''
Write-Host 'Acceso directo creado en el escritorio:' -ForegroundColor Green
Write-Host "  $shortcutPath"
Write-Host ''
Write-Host 'Ya pueden hacer doble click ahi para empezar.' -ForegroundColor Cyan
Write-Host ''
Pause
