<#
.SINOPSIS
    Genera contrasenas temporales seguras (Caso 1 y 2: contrasena olvidada
    / cuenta bloqueada), listas para entregar al usuario y forzar cambio
    en el primer inicio de sesion.

.DESCRIPCION
    Crea una o varias contrasenas aleatorias que cumplen con requisitos
    tipicos de complejidad: mayusculas, minusculas, numeros y un simbolo,
    evitando caracteres confusos (0/O, 1/l/I).

.USO
    .\New-TempPassword.ps1                 -> genera 1 contrasena de 12 caracteres
    .\New-TempPassword.ps1 -Cantidad 5      -> genera 5 contrasenas
    .\New-TempPassword.ps1 -Longitud 16     -> contrasenas de 16 caracteres
#>

param(
    [int]$Longitud = 12,
    [int]$Cantidad = 1
)

function New-Password($longitud) {
    $mayus   = "ABCDEFGHJKLMNPQRSTUVWXYZ"        # sin I, O para evitar confusion
    $minus   = "abcdefghijkmnopqrstuvwxyz"        # sin l
    $numeros = "23456789"                          # sin 0, 1
    $simbolos = "!@#$%&*?"

    $todos = $mayus + $minus + $numeros + $simbolos

    # Garantizar al menos un caracter de cada tipo
    $password = @(
        $mayus[(Get-Random -Maximum $mayus.Length)]
        $minus[(Get-Random -Maximum $minus.Length)]
        $numeros[(Get-Random -Maximum $numeros.Length)]
        $simbolos[(Get-Random -Maximum $simbolos.Length)]
    )

    for ($i = $password.Count; $i -lt $longitud; $i++) {
        $password += $todos[(Get-Random -Maximum $todos.Length)]
    }

    # Mezclar el orden para que no siempre empiece igual
    -join ($password | Sort-Object { Get-Random })
}

Write-Host "Contrasenas temporales generadas:" -ForegroundColor Yellow
Write-Host "(entregar al usuario y marcar 'debe cambiar la contrasena en el proximo inicio de sesion')`n"

for ($i = 1; $i -le $Cantidad; $i++) {
    Write-Host (New-Password $Longitud) -ForegroundColor Green
}
