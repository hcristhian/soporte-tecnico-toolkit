#!/usr/bin/env python3
"""
system_health.py
------------------
Version MULTIPLATAFORMA (Windows, macOS y Linux) del reporte de salud del
equipo del Caso 6 ("el computador esta muy lento").

El espacio en disco usa solo la libreria estandar (funciona siempre). La
memoria RAM, el uso de CPU y los procesos que mas consumen usan la
libreria "psutil": si no esta instalada, el script lo detecta y explica
como instalarla en una sola linea.

REQUISITOS:
    python3 -m pip install psutil
    (si el pip normal no funciona, probar: python3 -m pip install --user psutil)

USO:
    python3 system_health.py
"""

import datetime
import platform
import shutil
from pathlib import Path

try:
    import psutil
    TIENE_PSUTIL = True
except ImportError:
    TIENE_PSUTIL = False


def main():
    reporte = []
    fecha = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    def agregar(t, r):
        reporte.append(f"== {t} ==")
        reporte.append(r)
        reporte.append("")
        print(f"\n== {t} ==")
        print(r)

    print(f"Reporte de salud del equipo - {fecha}  (sistema: {platform.system()})")
    print("-" * 50)

    # 1. Espacio en disco (siempre disponible, sin instalar nada)
    total, usado, libre = shutil.disk_usage(Path.home().anchor or "/")
    pct_libre = round(libre / total * 100)
    alerta_disco = "  <-- POCO ESPACIO, revisar" if pct_libre < 15 else ""
    agregar(
        "1. Espacio en disco",
        f"{libre / 1e9:.1f} GB libres de {total / 1e9:.1f} GB ({pct_libre}% libre){alerta_disco}",
    )

    if not TIENE_PSUTIL:
        agregar(
            "2-4. Memoria, CPU y procesos",
            "No se pudo revisar: falta instalar la libreria 'psutil'.\n"
            "Instalarla con: python3 -m pip install psutil\n"
            "y volver a correr este script.",
        )
    else:
        # 2. Memoria RAM
        mem = psutil.virtual_memory()
        alerta_mem = "  <-- USO ALTO DE MEMORIA" if mem.percent > 85 else ""
        agregar(
            "2. Memoria RAM",
            f"Total: {mem.total / 1e9:.1f} GB | Libre: {mem.available / 1e9:.1f} GB | Uso: {mem.percent}%{alerta_mem}",
        )

        # 3. Uso de CPU (medido durante 1 segundo para que sea preciso)
        uso_cpu = psutil.cpu_percent(interval=1)
        agregar("3. Uso de CPU", f"{uso_cpu}% en este momento")

        # 4. Top 5 procesos por uso de memoria
        procesos = []
        for p in psutil.process_iter(["name", "memory_info"]):
            try:
                mb = p.info["memory_info"].rss / 1e6
                procesos.append((p.info["name"] or "?", mb))
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        procesos.sort(key=lambda x: x[1], reverse=True)
        texto_top5 = "\n".join(f"{nombre:<25} {mb:8.0f} MB" for nombre, mb in procesos[:5])
        agregar("4. Top 5 procesos por consumo de RAM", texto_top5)

    # Guardar reporte
    archivo = Path(f"salud-equipo-{datetime.datetime.now().strftime('%Y%m%d-%H%M')}.txt")
    archivo.write_text("\n".join(reporte), encoding="utf-8")
    print(f"\nReporte guardado en: {archivo.resolve()}")


if __name__ == "__main__":
    main()
