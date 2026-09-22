#!/usr/bin/env python3
"""
network_check.py
------------------
Version MULTIPLATAFORMA (Windows, macOS y Linux) del diagnostico de red
del Caso 3 y 4 ("sin internet / wifi intermitente" y "VPN no conecta").

A diferencia de Test-NetworkConnection.ps1 (que solo corre en Windows con
PowerShell), este script usa solo la libreria estandar de Python, asi que
funciona igual en los tres sistemas operativos.

REQUISITOS: solo tener Python 3 instalado (no necesita instalar nada mas).

USO:
    python3 network_check.py

    Muestra el diagnostico en pantalla y lo guarda en
    "reporte-red-AAAAMMDD-HHMM.txt".
"""

import datetime
import platform
import socket
import subprocess
from pathlib import Path

SISTEMA = platform.system()  # "Windows", "Darwin" (macOS) o "Linux"


def titulo(texto):
    print(f"\n== {texto} ==")


def ping(host, intentos=2):
    """Hace ping a 'host' con la sintaxis correcta segun el sistema operativo."""
    if SISTEMA == "Windows":
        comando = ["ping", "-n", str(intentos), host]
    else:  # macOS y Linux usan la misma bandera
        comando = ["ping", "-c", str(intentos), host]

    try:
        resultado = subprocess.run(
            comando, capture_output=True, text=True, timeout=10
        )
        return resultado.returncode == 0, resultado.stdout
    except Exception as e:
        return False, str(e)


def obtener_puerta_de_enlace():
    """Intenta detectar la puerta de enlace (router) segun el sistema operativo."""
    try:
        if SISTEMA == "Windows":
            salida = subprocess.run(
                ["ipconfig"], capture_output=True, text=True
            ).stdout
            for linea in salida.splitlines():
                if "Default Gateway" in linea or "Puerta de enlace" in linea:
                    partes = linea.split(":")
                    if len(partes) > 1 and partes[1].strip():
                        return partes[1].strip()
        elif SISTEMA == "Darwin":
            salida = subprocess.run(
                ["route", "-n", "get", "default"], capture_output=True, text=True
            ).stdout
            for linea in salida.splitlines():
                if "gateway:" in linea:
                    return linea.split(":")[1].strip()
        else:  # Linux
            salida = subprocess.run(
                ["ip", "route"], capture_output=True, text=True
            ).stdout
            for linea in salida.splitlines():
                if linea.startswith("default"):
                    return linea.split()[2]
    except Exception:
        pass
    return None


def main():
    reporte = []
    fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    def agregar(t, r):
        reporte.append(f"== {t} ==")
        reporte.append(r)
        reporte.append("")
        titulo(t)
        print(r)

    print(f"Diagnostico de red - {fecha}  (sistema detectado: {SISTEMA})")
    print("-" * 50)

    # 1. Nombre de equipo e IP local
    try:
        nombre_equipo = socket.gethostname()
        ip_local = socket.gethostbyname(nombre_equipo)
    except Exception:
        ip_local = "no se pudo detectar"
    agregar("1. Equipo e IP local", f"Nombre: {socket.gethostname()} | IP local: {ip_local}")

    # 2. Puerta de enlace (router)
    gateway = obtener_puerta_de_enlace()
    if gateway:
        ok, _ = ping(gateway)
        resultado2 = f"OK: {gateway} responde" if ok else f"FALLA: {gateway} no responde. Revisar cable/router/wifi."
    else:
        resultado2 = "No se pudo detectar la puerta de enlace."
    agregar("2. Ping a la puerta de enlace", resultado2)

    # 3. Resolucion DNS
    try:
        ip_google = socket.gethostbyname("google.com")
        resultado3 = f"OK: google.com resuelve a {ip_google}"
    except Exception:
        resultado3 = "FALLA: no resuelve nombres de dominio (problema de DNS o sin internet)."
    agregar("3. Resolucion DNS", resultado3)

    # 4. Conectividad real a internet
    ok_internet, _ = ping("8.8.8.8")
    resultado4 = "OK: hay salida a internet" if ok_internet else "FALLA: no hay respuesta desde internet (8.8.8.8). Revisar modem/ISP."
    agregar("4. Conectividad a internet (8.8.8.8)", resultado4)

    # Guardar reporte
    archivo = Path(f"reporte-red-{datetime.datetime.now().strftime('%Y%m%d-%H%M')}.txt")
    archivo.write_text("\n".join(reporte), encoding="utf-8")
    print(f"\nReporte guardado en: {archivo.resolve()}")


if __name__ == "__main__":
    main()
