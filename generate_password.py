#!/usr/bin/env python3
"""
generate_password.py
----------------------
Version MULTIPLATAFORMA del generador de contrasenas temporales
(Caso 1 y 2: contrasena olvidada / cuenta bloqueada).

Usa el modulo "secrets" de Python, disenado especificamente para generar
valores aleatorios seguros (a diferencia de "random"). Funciona igual en
Windows, macOS y Linux sin instalar nada.

USO:
    python3 generate_password.py            -> 1 contrasena de 12 caracteres
    python3 generate_password.py 5          -> 5 contrasenas
    python3 generate_password.py 5 16       -> 5 contrasenas de 16 caracteres
"""

import secrets
import sys

MAYUS = "ABCDEFGHJKLMNPQRSTUVWXYZ"     # sin I, O (se confunden con 1, 0)
MINUS = "abcdefghijkmnopqrstuvwxyz"     # sin l
NUMEROS = "23456789"                     # sin 0, 1
SIMBOLOS = "!@#$%&*?"


def generar_password(longitud=12):
    todos = MAYUS + MINUS + NUMEROS + SIMBOLOS

    # Garantizar al menos un caracter de cada tipo
    password = [
        secrets.choice(MAYUS),
        secrets.choice(MINUS),
        secrets.choice(NUMEROS),
        secrets.choice(SIMBOLOS),
    ]
    password += [secrets.choice(todos) for _ in range(longitud - len(password))]

    # Mezclar el orden de forma segura
    for i in range(len(password) - 1, 0, -1):
        j = secrets.randbelow(i + 1)
        password[i], password[j] = password[j], password[i]

    return "".join(password)


def main():
    cantidad = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    longitud = int(sys.argv[2]) if len(sys.argv) > 2 else 12

    print("Contrasenas temporales generadas:")
    print("(entregar al usuario y marcar 'debe cambiar la contrasena en el proximo inicio de sesion')\n")
    for _ in range(cantidad):
        print(generar_password(longitud))


if __name__ == "__main__":
    main()
