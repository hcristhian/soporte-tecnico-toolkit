# Herramientas de soporte tecnico (portafolio)

Estos scripts resuelven, de forma automatizada, los mismos casos documentados
en el portafolio ("Portafolio: Casos de Soporte Tecnico"). Sirven para dos
cosas: (1) ahorrar tiempo real en el trabajo del dia a dia, y (2) subirse a
un repositorio de GitHub como evidencia de que sabes programar soluciones,
no solo seguir un manual.

Hay dos familias de scripts:

- **PowerShell (`.ps1`):** solo corren en Windows, pero pueden hacer cambios
  reales en Active Directory / el sistema (mas potentes en una empresa real
  con Windows Server).
- **Python (`.py`):** corren igual en Windows, macOS y Linux. Son la opcion
  a usar si no estas seguro en que sistema operativo trabajaras, o si
  quieres probarlos en tu propio computador sin depender de Windows.

## Que hace cada uno

| Script | Lenguaje | Sistemas operativos | Para que sirve | Caso |
| --- | --- | --- | --- | --- |
| `network_check.py` | Python | Windows, macOS, Linux | Diagnostica sin internet / wifi intermitente en 4 pasos | Caso 3 y 4 |
| `system_health.py` | Python | Windows, macOS, Linux | Revisa disco, RAM, CPU y procesos que mas consumen | Caso 6 |
| `generate_password.py` | Python | Windows, macOS, Linux | Genera contrasenas temporales seguras | Caso 1 y 2 |
| `reset_print_queue.py` | Python | Windows, macOS, Linux | Limpia la cola de impresion atascada (detecta el SO solo) | Caso 5 |
| `ticket_logger.py` | Python | Windows, macOS, Linux | Documenta casos resueltos en Markdown | Todos |
| `Test-NetworkConnection.ps1` | PowerShell | Solo Windows | Version Windows del diagnostico de red, con mas detalle (adaptadores, puerta de enlace) | Caso 3 y 4 |
| `Get-SystemHealthReport.ps1` | PowerShell | Solo Windows | Version Windows del reporte de salud, con programas de inicio | Caso 6 |
| `Reset-PrintSpooler.ps1` | PowerShell | Solo Windows | Version Windows del reinicio de impresion | Caso 5 |
| `New-TempPassword.ps1` | PowerShell | Solo Windows | Version Windows del generador de contrasenas | Caso 1 y 2 |
| `New-UserOnboarding.ps1` | PowerShell | Solo Windows (necesita Active Directory) | Automatiza el checklist de onboarding desde un CSV (modo simulacro por defecto) | Caso 11 |

**Recomendacion:** si solo vas a mostrar un puñado en la entrevista o en
GitHub, usa las versiones en Python (`.py`): funcionan en cualquier equipo
en el que las quieras demostrar, incluido el tuyo.

## Como usarlos

**Scripts de Python (`.py`):** necesitan Python 3 instalado (en Windows se
descarga de [python.org](https://python.org); en macOS y Linux normalmente
ya viene instalado). Para comprobarlo:

```
python3 --version
```

Luego cada script se corre asi (desde la carpeta donde lo guardaste):

```
python3 network_check.py
python3 system_health.py
python3 generate_password.py 3 14      (3 contrasenas de 14 caracteres)
python3 reset_print_queue.py            (en Windows) 
sudo python3 reset_print_queue.py       (en macOS o Linux)
python3 ticket_logger.py
```

`system_health.py` necesita la libreria `psutil` para revisar RAM/CPU/procesos
(el espacio en disco funciona siempre sin instalar nada). Si falta, el
script lo avisa; se instala con:

```
python3 -m pip install psutil
```

**Scripts de PowerShell (`.ps1`):** solo corren en Windows. Si Windows
bloquea la ejecucion la primera vez, abre PowerShell como administrador y
corre una vez:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Luego cada script se corre con `.\NombreDelScript.ps1`. Los que necesitan
permisos de administrador lo dicen en su encabezado (comentario `.USO`).

**Nota honesta:** estos `.ps1` los revise linea por linea con mucho cuidado,
pero no los pude ejecutar de verdad porque este entorno de trabajo es Linux
(no tiene PowerShell). Los `.py` si los corri y probe en este entorno antes
de entregartelos. Antes de usar cualquiera de los dos en un equipo real,
pruebalos primero en tu propio computador o en una maquina de prueba.

## Como subirlos a GitHub como portafolio

1. Crear una cuenta gratuita en [github.com](https://github.com) si no
   tienes una.
2. Crear un repositorio nuevo, por ejemplo `soporte-tecnico-toolkit`.
3. Subir esta carpeta completa (los `.ps1`, los `.py` y este `README.md`).
4. En la descripcion del repositorio escribir algo como: "Scripts de
   automatizacion para soporte tecnico Tier 1 (Windows, macOS y Linux):
   diagnostico de red, salud del equipo, gestion de impresoras, contrasenas
   temporales y documentacion de casos."
5. Poner el enlace del repositorio en el CV y en LinkedIn, en la seccion de
   proyectos.

## Importante

- `Reset-PrintSpooler.ps1`, `reset_print_queue.py` y el modo real de
  `New-UserOnboarding.ps1` hacen cambios en el sistema: pruebalos primero en
  un equipo de prueba o en tu propio computador, nunca en un equipo de
  produccion sin permiso.
- `New-UserOnboarding.ps1` corre en modo simulacro por defecto (no crea
  nada real) para que se pueda mostrar de forma segura en una entrevista.
- Si en tu primer trabajo te dan acceso a un escritorio virtual (VDI /
  Citrix) en vez de tu propio computador, revisa con tu supervisor si esta
  permitido correr scripts propios antes de usarlos ahi.
