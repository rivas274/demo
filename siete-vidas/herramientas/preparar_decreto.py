"""Prepara el arte del menú «Decreto real» y del kit de interfaz (Gemini, 2026-10-20) para el juego: quita el fondo
blanco, separa las piezas de cada hoja, las recorta a su borde opaco y las lleva a un tamaño legible en 640×360 sin
suavizar (cada pixel de la imagen final es un pixel del juego). El blanco puro que queda se tiñe de crema.

Uso: python3 preparar_decreto.py
Lee siete-vidas/arte/referencias/gemini/{decreto-real,kit-interfaz-decreto,kit-interfaz-decreto-correccion}.png y
escribe siete-vidas/juego/assets/ui/decreto/. Necesita numpy y scipy (usa las funciones de preparar_arte_nivel.py).
"""
from pathlib import Path

import numpy as np
from PIL import Image

from preparar_arte_nivel import escalar, piezas, sin_huecos

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "juego" / "assets" / "ui" / "decreto"
CREMA = (243, 239, 232)

# nombre -> (hoja, índice de la pieza en la hoja, (ancho, alto) en el juego). El índice sigue el orden de piezas().
PIEZAS = {
    "pergamino": ("decreto-real", 0, (156, 212)),
    "sello": ("decreto-real", 1, (40, 39)),
    "sello_estampado": ("decreto-real", 2, (50, 41)),
    "boton": ("decreto-real", 4, (112, 44)),
    "boton_resaltado": ("decreto-real", 5, (112, 44)),
    "boton_apretado": ("decreto-real", 6, (112, 44)),
    "cojin": ("decreto-real", 7, (110, 56)),
    "corona": ("decreto-real", 8, (26, 21)),
    "destello_1": ("decreto-real", 9, (16, 17)),
    "destello_2": ("decreto-real", 10, (26, 27)),
    "destello_3": ("decreto-real", 11, (12, 13)),
    "marco_ficha": ("kit-interfaz-decreto", 0, (120, 167)),
    "etiqueta_logro": ("kit-interfaz-decreto", 2, (180, 44)),
    "relleno_verde": ("kit-interfaz-decreto", 3, (96, 10)),
    "relleno_dorado": ("kit-interfaz-decreto", 4, (96, 10)),
    "relleno_rojo": ("kit-interfaz-decreto", 6, (96, 10)),
    "relleno_azul": ("kit-interfaz-decreto", 7, (96, 10)),
    "panel": ("kit-interfaz-decreto", 8, (92, 106)),
    "marco_retrato": ("kit-interfaz-decreto", 9, (52, 50)),
    "icono_defensa": ("kit-interfaz-decreto", 10, (24, 24)),
    "icono_carisma": ("kit-interfaz-decreto", 11, (24, 24)),
    "icono_ataque": ("kit-interfaz-decreto", 12, (24, 24)),
    "icono_peso": ("kit-interfaz-decreto", 13, (24, 24)),
    "cinta": ("kit-interfaz-decreto", 14, (176, 42)),
    "hud_corazon": ("kit-interfaz-decreto", 15, (20, 20)),
    "hud_libreta": ("kit-interfaz-decreto", 16, (20, 20)),
    "hud_calcetin": ("kit-interfaz-decreto", 17, (20, 20)),
    "hud_foto": ("kit-interfaz-decreto", 18, (20, 20)),
    "foto_unicornio": ("kit-interfaz-decreto-correccion", 0, (48, 48)),
    "marco_barra": ("kit-interfaz-decreto-correccion", 1, (64, 12)),
    "marco_barra_jefe": ("kit-interfaz-decreto-correccion", 2, (236, 25)),
}
# Piezas con el interior crema que se vacía (se ve el relleno de la barra por dentro): rectángulo interior en fracciones.
VACIAR = {"marco_barra_jefe": (0.09, 0.22, 0.91, 0.78)}


def sin_blanco_puro(imagen):
    """Tiñe de crema el blanco puro (no queda ningún pixel 255, 255, 255)."""
    a = np.asarray(imagen).copy()
    blanco = (a[:, :, 0] >= 250) & (a[:, :, 1] >= 250) & (a[:, :, 2] >= 250) & (a[:, :, 3] > 0)
    a[blanco, 0], a[blanco, 1], a[blanco, 2] = CREMA
    return Image.fromarray(a, "RGBA")


def main():
    DESTINO.mkdir(parents=True, exist_ok=True)
    hojas = {}
    for nombre, (hoja, indice, tamano) in PIEZAS.items():
        if hoja not in hojas:
            hojas[hoja] = piezas(hoja)
        imagen, cajas = hojas[hoja]
        recorte = imagen.crop(cajas[indice])
        if nombre not in ("marco_ficha", "marco_retrato", "panel"):
            recorte = sin_huecos(recorte)
        final = escalar(recorte, tamano)
        if nombre in VACIAR:
            a = np.asarray(final).copy()
            x0, y0, x1, y1 = VACIAR[nombre]
            h, w = a.shape[:2]
            a[int(y0 * h):int(y1 * h), int(x0 * w):int(x1 * w), 3] = 0
            final = Image.fromarray(a, "RGBA")
        final = sin_blanco_puro(final)
        final.save(DESTINO / f"{nombre}.png")
        print(nombre, final.size)


if __name__ == "__main__":
    main()
