#!/usr/bin/env python3
"""
reset_print_queue.py
-----------------------
Version MULTIPLATAFORMA del Caso 5 ("la impresora no imprime"): detecta
el sistema operativo y corre el comando correcto para limpiar la cola de
impresion atascada.

IMPORTANTE: en los tres sistemas operativos esta accion necesita permisos
de administrador (Windows) o "sudo" (macOS/Linux). Si el script dice
"permiso denegado", hay que volver a correrlo con esos permisos.

USO:
    Windows (PowerShell o CMD "Como administrador"):
        python3 reset_print_queue.py

    macOS / Linux (Terminal):
        sudo python3 reset_print_queue.py
"""

import platform
import subprocess
import sys

SISTEMA = platform.system()


def correr(comando, descripcion):
    print(f"-> {descripcion} ({' '.join(comando)})")
    try:
        resultado = subprocess.run(comando, capture_output=True, text=True)
        if resultado.returncode != 0:
            print(f"   Aviso: {resultado.stderr.strip() or 'termino con codigo ' + str(resultado.returncode)}")
        return resultado.returncode == 0
    except FileNotFoundError:
        print(f"   El comando '{comando[0]}' no existe en este equipo.")
        return False
    except PermissionError:
        print("   Permiso denegado: vuelve a correr el script como administrador/sudo.")
        return False


def windows():
    correr(["net", "stop", "spooler"], "Deteniendo el servicio de impresion")
    correr(["cmd", "/c", "del", "/Q", r"%systemroot%\System32\spool\PRINTERS\*.*"], "Borrando trabajos atascados")
    correr(["net", "start", "spooler"], "Iniciando el servicio de impresion")


def macos():
    correr(["cupsenable", "-a"], "Habilitando todas las colas")
    correr(["cancel", "-a"], "Cancelando trabajos atascados")
    correr(["launchctl", "stop", "org.cups.cupsd"], "Reiniciando cups (parte 1)")
    correr(["launchctl", "start", "org.cups.cupsd"], "Reiniciando cups (parte 2)")


def linux():
    correr(["cancel", "-a"], "Cancelando trabajos atascados")
    correr(["systemctl", "restart", "cups"], "Reiniciando el servicio cups")


def main():
    print(f"Sistema detectado: {SISTEMA}\n")

    if SISTEMA == "Windows":
        windows()
    elif SISTEMA == "Darwin":
        macos()
    elif SISTEMA == "Linux":
        linux()
    else:
        print(f"Sistema no reconocido: {SISTEMA}. No se hizo ningun cambio.")
        sys.exit(1)

    print("\nListo. Pide al usuario que intente imprimir de nuevo.")


if __name__ == "__main__":
    main()
