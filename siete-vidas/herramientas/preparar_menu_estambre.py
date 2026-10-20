"""Prepara el arte del menú de estambre (Gemini, 2026-10-20) para el juego: quita el fondo blanco, separa las piezas
de la hoja y las lleva a su tamaño en 640×360 sin suavizar.

La hoja está dibujada con pixeles de unos 5,5 px: se divide por PIXEL_ARTE para que cada pixel del dibujo quede en
un pixel del juego (nítido y legible: el letrero mide unos 86 × 39 px con su argolla). Las 5 madejas en ocho del
medio no se usan.

Uso: python3 preparar_menu_estambre.py
Lee siete-vidas/arte/referencias/gemini/menu-estambre.png y escribe siete-vidas/juego/assets/ui/.
Necesita numpy y scipy (las funciones de recorte son las de preparar_arte_nivel.py).
"""
from pathlib import Path

from PIL import Image

from preparar_arte_nivel import escalar, piezas, sin_huecos

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "juego" / "assets" / "ui"
PIXEL_ARTE = 5.5
# nombre en el juego -> índice de la pieza en la hoja (orden de piezas(): filas de arriba abajo, luego izquierda a derecha)
PIEZAS = {
    "letrero": 0,
    "letrero_resaltado": 1,
    "letrero_principal": 2,
    "hilo": 3,
    "ovillo": 9,
    "pelusa_1": 10,
    "pelusa_2": 11,
    "pelusa_3": 12,
}


def main():
    DESTINO.mkdir(parents=True, exist_ok=True)
    imagen, cajas = piezas("menu-estambre")
    for nombre, indice in PIEZAS.items():
        recorte = sin_huecos(imagen.crop(cajas[indice]))
        tamano = (max(1, round(recorte.width / PIXEL_ARTE)), max(1, round(recorte.height / PIXEL_ARTE)))
        final = escalar(recorte, tamano)
        final.save(DESTINO / f"menu_{nombre}.png")
        print(nombre, final.size)


if __name__ == "__main__":
    main()
