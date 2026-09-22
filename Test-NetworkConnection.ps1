<#
.SINOPSIS
    Diagnostico rapido de red para soporte tecnico (Caso 3 y 4 del portafolio:
    "sin internet / wifi intermitente" y "VPN no conecta").

.DESCRIPCION
    Corre una serie de pruebas basicas -en el orden en que normalmente se
    descarta un problema de red- y genera un reporte de texto con resultado
    y hora, listo para pegar en un ticket.

.USO
    Abrir PowerShell (no hace falta ser administrador) y ejecutar:
        .\Test-NetworkConnection.ps1

    El reporte queda guardado en la misma carpeta como
    "reporte-red-AAAAMMDD-HHmm.txt".

.NOTA PARA EL PORTAFOLIO
    Este script muestra el orden logico de diagnostico que se ensena en el
    Caso 3: primero adaptador y IP, luego puerta de enlace, luego DNS,
    luego internet real. Ese orden (de lo mas cercano a lo mas lejano) es
    justo lo que un entrevistador espera escuchar.
#>

$ErrorActionPreference = "SilentlyContinue"
$reporte = @()
$fecha   = Get-Date -Format "yyyy-MM-dd HH:mm"

function Agregar($titulo, $resultado) {
    $script:reporte += "== $titulo =="
    $script:reporte += $resultado
    $script:reporte += ""
    Write-Host "== $titulo ==" -ForegroundColor Cyan
    Write-Host $resultado
    Write-Host ""
}

Write-Host "Diagnostico de red - $fecha" -ForegroundColor Yellow
Write-Host "-----------------------------------------`n"

# 1. Adaptadores de red y direccion IP asignada
$adaptadores = Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq "Up" }
$texto1 = $adaptadores | ForEach-Object {
    "Adaptador: $($_.InterfaceAlias) | IP: $($_.IPv4Address.IPAddress) | Puerta de enlace: $($_.IPv4DefaultGateway.NextHop)"
} | Out-String
Agregar "1. Adaptadores activos e IP" $texto1.Trim()

# 2. Ping a la puerta de enlace (router local)
$gateway = ($adaptadores | Select-Object -First 1).IPv4DefaultGateway.NextHop
if ($gateway) {
    $pingGateway = Test-Connection -ComputerName $gateway -Count 2 -ErrorAction SilentlyContinue
    $resultado2 = if ($pingGateway) { "OK: respondio en $([math]::Round(($pingGateway | Measure-Object ResponseTime -Average).Average,0)) ms" } else { "FALLA: la puerta de enlace ($gateway) no responde. Revisar cable/router/wifi." }
} else {
    $resultado2 = "No se detecto puerta de enlace. El equipo no tiene ruta de salida configurada."
}
Agregar "2. Ping a la puerta de enlace ($gateway)" $resultado2

# 3. Resolucion DNS
$dnsTest = Resolve-DnsName -Name "google.com" -ErrorAction SilentlyContinue
$resultado3 = if ($dnsTest) { "OK: google.com resuelve a $($dnsTest[0].IPAddress)" } else { "FALLA: no resuelve nombres de dominio. Puede ser DNS mal configurado o sin internet." }
Agregar "3. Resolucion DNS" $resultado3

# 4. Conectividad real a internet
$pingInternet = Test-Connection -ComputerName "8.8.8.8" -Count 2 -ErrorAction SilentlyContinue
$resultado4 = if ($pingInternet) { "OK: hay salida a internet" } else { "FALLA: no hay respuesta desde internet (8.8.8.8). Revisar modem/ISP." }
Agregar "4. Conectividad a internet (8.8.8.8)" $resultado4

# 5. Limpiar cache DNS (accion correctiva comun)
ipconfig /flushdns | Out-Null
Agregar "5. Cache DNS" "Se vacio la cache DNS del equipo (ipconfig /flushdns)."

# Guardar reporte
$archivo = "reporte-red-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"
$reporte -join "`r`n" | Out-File -FilePath $archivo -Encoding UTF8
Write-Host "Reporte guardado en: $archivo" -ForegroundColor Green
