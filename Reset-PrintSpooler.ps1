<#
.SINOPSIS
    Arregla el caso mas comun de "la impresora no imprime" (Caso 5):
    limpia la cola de impresion atascada y reinicia el servicio.

.DESCRIPCION
    Detiene el servicio de cola de impresion (Spooler), borra los
    trabajos de impresion atascados y vuelve a iniciar el servicio.

.USO
    Requiere ejecutar PowerShell "Como administrador".
        .\Reset-PrintSpooler.ps1
#>

# Verificar que se esta corriendo como administrador
$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $esAdmin) {
    Write-Host "Este script necesita permisos de administrador." -ForegroundColor Red
    Write-Host "Cierra esta ventana y vuelve a abrir PowerShell con 'Ejecutar como administrador'." -ForegroundColor Red
    exit
}

Write-Host "Reiniciando el servicio de impresion..." -ForegroundColor Yellow

try {
    Write-Host "1. Deteniendo el servicio Spooler..."
    Stop-Service -Name Spooler -Force -ErrorAction Stop

    Write-Host "2. Borrando trabajos de impresion atascados..."
    $carpetaCola = "$env:SystemRoot\System32\spool\PRINTERS"
    Get-ChildItem -Path $carpetaCola -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    Write-Host "3. Iniciando el servicio Spooler de nuevo..."
    Start-Service -Name Spooler -ErrorAction Stop

    $estado = (Get-Service -Name Spooler).Status
    Write-Host "Listo. Estado actual del servicio: $estado" -ForegroundColor Green
    Write-Host "Pide al usuario que intente imprimir de nuevo." -ForegroundColor Green
}
catch {
    Write-Host "Algo fallo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Si el servicio no arranca, revisa el Visor de eventos > Sistema para mas detalle." -ForegroundColor Red
}
