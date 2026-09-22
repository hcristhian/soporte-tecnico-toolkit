<#
.SINOPSIS
    Automatiza el checklist de onboarding de un empleado nuevo (Caso 11),
    leyendo los datos desde un archivo CSV.

.DESCRIPCION
    Lee un CSV con una fila por empleado nuevo (columnas: Nombre,
    Usuario, Departamento, Gerente) y por cada uno genera el checklist
    de onboarding. Corre en modo "simulacro" (DryRun) por defecto, para
    que se pueda mostrar en una entrevista o portafolio sin necesitar un
    servidor de Active Directory real.

    Si el equipo SI tiene el modulo ActiveDirectory instalado y se usa
    -DryRun:$false, el script crea la cuenta de verdad.

.USO
    Primero crea un archivo "nuevos_empleados.csv" con este formato:

        Nombre,Usuario,Departamento,Gerente
        Ana Torres,ana.torres,Ventas,Carlos Mejia

    Luego ejecuta (modo simulacro, no crea nada real):
        .\New-UserOnboarding.ps1 -RutaCSV .\nuevos_empleados.csv

    Para crear las cuentas de verdad en un dominio real (requiere modulo
    ActiveDirectory y permisos):
        .\New-UserOnboarding.ps1 -RutaCSV .\nuevos_empleados.csv -DryRun:$false
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$RutaCSV,

    [bool]$DryRun = $true
)

if (-not (Test-Path $RutaCSV)) {
    Write-Host "No se encontro el archivo: $RutaCSV" -ForegroundColor Red
    exit
}

$empleados = Import-Csv -Path $RutaCSV
$tieneAD = Get-Module -ListAvailable -Name ActiveDirectory

foreach ($empleado in $empleados) {
    Write-Host "`n=== Onboarding: $($empleado.Nombre) ===" -ForegroundColor Yellow

    $checklist = @(
        "[ ] Crear cuenta de usuario: $($empleado.Usuario)"
        "[ ] Asignar al departamento/grupo: $($empleado.Departamento)"
        "[ ] Asignar gerente: $($empleado.Gerente)"
        "[ ] Crear buzon de correo"
        "[ ] Generar contrasena temporal (ver New-TempPassword.ps1)"
        "[ ] Instalar software base (ofimatica, antivirus, VPN si aplica)"
        "[ ] Dar acceso a carpetas compartidas del departamento"
        "[ ] Probar inicio de sesion antes de entregar el equipo"
    )
    $checklist | ForEach-Object { Write-Host $_ }

    if (-not $DryRun -and $tieneAD) {
        Write-Host "`nCreando cuenta real en Active Directory..." -ForegroundColor Cyan
        try {
            $passwordTemporal = "CambiaEsto$(Get-Random -Minimum 1000 -Maximum 9999)!"
            New-ADUser -Name $empleado.Nombre `
                       -SamAccountName $empleado.Usuario `
                       -Department $empleado.Departamento `
                       -Manager $empleado.Gerente `
                       -AccountPassword (ConvertTo-SecureString $passwordTemporal -AsPlainText -Force) `
                       -ChangePasswordAtLogon $true `
                       -Enabled $true
            Write-Host "Cuenta creada. Contrasena temporal: $passwordTemporal" -ForegroundColor Green
        }
        catch {
            Write-Host "Error creando la cuenta: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    elseif (-not $DryRun -and -not $tieneAD) {
        Write-Host "`nNo se encontro el modulo ActiveDirectory en este equipo; se muestra solo el checklist." -ForegroundColor DarkYellow
    }
    else {
        Write-Host "`n(modo simulacro: no se creo ninguna cuenta real)" -ForegroundColor DarkGray
    }
}
