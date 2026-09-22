<#
.SINOPSIS
    Reporte de salud del equipo (Caso 6: "el computador esta muy lento").

.DESCRIPCION
    Revisa disco, memoria RAM, CPU y los 5 procesos que mas recursos
    consumen en este momento. No necesita permisos de administrador.

.USO
    .\Get-SystemHealthReport.ps1
    El reporte se muestra en pantalla y se guarda como
    "salud-equipo-AAAAMMDD-HHmm.txt".
#>

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

Write-Host "Reporte de salud del equipo - $fecha" -ForegroundColor Yellow
Write-Host "--------------------------------------------`n"

# 1. Tiempo encendido (uptime)
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Agregar "1. Tiempo encendido" ("{0} dias, {1} horas, {2} minutos" -f $uptime.Days, $uptime.Hours, $uptime.Minutes)

# 2. Espacio en disco
$discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$texto2 = $discos | ForEach-Object {
    $libreGB = [math]::Round($_.FreeSpace / 1GB, 1)
    $totalGB = [math]::Round($_.Size / 1GB, 1)
    $pctLibre = [math]::Round(($_.FreeSpace / $_.Size) * 100, 0)
    $alerta = if ($pctLibre -lt 15) { "  <-- POCO ESPACIO, revisar" } else { "" }
    "$($_.DeviceID) $libreGB GB libres de $totalGB GB ($pctLibre% libre)$alerta"
} | Out-String
Agregar "2. Espacio en disco" $texto2.Trim()

# 3. Memoria RAM
$memTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$memLibre = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$memUsadaPct = [math]::Round((($memTotal - $memLibre) / $memTotal) * 100, 0)
$alertaMem = if ($memUsadaPct -gt 85) { "  <-- USO ALTO DE MEMORIA" } else { "" }
Agregar "3. Memoria RAM" ("Total: $memTotal GB | Libre: $memLibre GB | Uso: $memUsadaPct%$alertaMem")

# 4. Uso de CPU actual
$cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average
Agregar "4. Uso de CPU" ("$([math]::Round($cpu.Average,0))% en este momento")

# 5. Top 5 procesos que mas memoria consumen
$topProcesos = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 |
    ForEach-Object { "{0,-25} {1,8:N0} MB" -f $_.ProcessName, ($_.WorkingSet64/1MB) } | Out-String
Agregar "5. Top 5 procesos por consumo de RAM" $topProcesos.Trim()

# 6. Programas que inician con Windows (candidatos a deshabilitar)
$inicio = Get-CimInstance Win32_StartupCommand | Select-Object -First 8 Name, Command
$textoInicio = ($inicio | ForEach-Object { "- $($_.Name)" }) -join "`r`n"
Agregar "6. Programas en el inicio de Windows" $textoInicio

# Guardar reporte
$archivo = "salud-equipo-$(Get-Date -Format 'yyyyMMdd-HHmm').txt"
$reporte -join "`r`n" | Out-File -FilePath $archivo -Encoding UTF8
Write-Host "Reporte guardado en: $archivo" -ForegroundColor Green
