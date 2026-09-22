#!/usr/bin/env python3
"""
ticket_logger.py
-----------------
Herramienta de linea de comandos para documentar casos de soporte tecnico
resueltos, en el mismo formato que el portafolio (Problema / Diagnostico /
Solucion / Herramientas). Cada caso se agrega a un archivo Markdown
(casos_resueltos.md) con fecha, listo para copiar al portafolio o subir a
GitHub como evidencia de experiencia real.

Funciona en Windows, Mac o Linux (no depende de PowerShell).

USO:
    python3 ticket_logger.py

    El script pregunta los datos del caso y los agrega al final de
    "casos_resueltos.md" (se crea si no existe).
"""

import datetime
from pathlib import Path

ARCHIVO_SALIDA = Path("casos_resueltos.md")


def preguntar(texto):
    respuesta = input(f"{texto}\n> ").strip()
    return respuesta if respuesta else "(sin especificar)"


def preguntar_multilinea(texto):
    print(f"{texto} (escribe tu respuesta y presiona Enter dos veces para terminar)")
    lineas = []
    while True:
        linea = input()
        if linea == "" and lineas and lineas[-1] == "":
            break
        lineas.append(linea)
    return "\n".join(lineas).strip() or "(sin especificar)"


def siguiente_numero_de_caso():
    if not ARCHIVO_SALIDA.exists():
        return 1
    contenido = ARCHIVO_SALIDA.read_text(encoding="utf-8")
    numeros = [
        int(linea.split("Caso ")[1].split(":")[0])
        for linea in contenido.splitlines()
        if linea.startswith("### Caso ")
    ]
    return max(numeros, default=0) + 1


def main():
    print("=== Registrar caso resuelto ===\n")

    titulo = preguntar("Titulo corto del caso (ej: 'Usuario no podia acceder al VPN')")
    categoria = preguntar(
        "Categoria (Cuentas y acceso / Redes / Hardware / Software / Correo / Onboarding / Otro)"
    )
    problema = preguntar_multilinea("Problema: que reporto el usuario")
    diagnostico = preguntar_multilinea("Diagnostico: como identificaste la causa")
    solucion = preguntar_multilinea("Solucion: que hiciste para resolverlo")
    herramientas = preguntar("Herramientas usadas (separadas por coma)")

    numero = siguiente_numero_de_caso()
    fecha = datetime.date.today().isoformat()

    bloque = f"""
### Caso {numero}: {titulo}

**Fecha:** {fecha}  **Categoria:** {categoria}

**Problema:** {problema}

**Diagnostico:** {diagnostico}

**Solucion:** {solucion}

**Herramientas:** {herramientas}
"""

    nuevo = not ARCHIVO_SALIDA.exists()
    with ARCHIVO_SALIDA.open("a", encoding="utf-8") as f:
        if nuevo:
            f.write("# Casos resueltos\n")
        f.write(bloque)

    print(f"\nGuardado como Caso {numero} en {ARCHIVO_SALIDA.resolve()}")


if __name__ == "__main__":
    main()
