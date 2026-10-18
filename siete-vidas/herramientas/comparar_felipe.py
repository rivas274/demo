"""Hoja de consistencia: pone a Felipe A junto a un cuadro de cada animación, al tamaño del juego y sobre el mismo piso.

Sirve para revisar, antes de usar una animación nueva, que sea el mismo gato: vista 3/4, cabeza cerca del 40 %
de la altura, mismos rasgos y la misma expresión de reojo. Lee las escalas de ESCALAS (las mismas del juego).

Uso: python3 comparar_felipe.py <salida.png> [hoja.png:escala ...]
Sin hojas extra compara todas las de ESCALAS.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ARTE = Path(__file__).resolve().parent.parent / "arte" / "felipe"
# hoja -> [cuadros, escala en el juego]
ESCALAS = {
    "felipe-idle-sheet.png": [8, 0.72],
    "felipe-walk-sheet.png": [8, 0.72],
    "felipe-run-sheet.png": [8, 0.72],
    "felipe-jump-sheet.png": [8, 0.72],
    "felipe-caida-sheet.png": [2, 0.72],
    "felipe-gatear-sheet.png": [8, 0.72],
    "felipe-attack-sheet.png": [8, 0.72],
    "felipe-eat-sheet.png": [8, 0.72],
    "felipe-purr-sheet.png": [8, 0.72],
    "felipe-faint-sheet.png": [8, 0.72],
    "felipe-acicalarse-sheet.png": [8, 0.72],
    "felipe-jugar-sheet.png": [8, 0.72],
    "felipe-vueltas-sheet.png": [8, 0.72],
}
ANCHO_CELDA, PISO = 130, 118


def recortar(im, escala):
    caja = im.split()[3].point(lambda v: 255 if v > 127 else 0).getbbox()
    c = im.crop(caja)
    return c.resize((round(c.width * escala), round(c.height * escala)), Image.NEAREST)


def main():
    hojas = [(h, *ESCALAS[h]) for h in ESCALAS]
    for extra in sys.argv[2:]:
        ruta, escala = extra.rsplit(":", 1)
        hojas.append((ruta, 8, float(escala)))
    base = Image.open(ARTE / "felipe-A-base.png").convert("RGBA")
    celdas = [("Felipe A", recortar(base, 0.72))]
    for nombre, cuadros, escala in hojas:
        ruta = Path(nombre) if Path(nombre).exists() else ARTE / nombre
        if not ruta.exists():
            continue
        hoja = Image.open(ruta).convert("RGBA")
        ancho = hoja.width // cuadros
        celdas.append((ruta.stem.replace("felipe-", "").replace("-sheet", ""), recortar(hoja.crop((0, 0, ancho, hoja.height)), escala)))
    salida = Image.new("RGBA", (ANCHO_CELDA * len(celdas), 140), (236, 230, 221, 255))
    dibujo = ImageDraw.Draw(salida)
    for i, (etiqueta, c) in enumerate(celdas):
        salida.alpha_composite(c, (i * ANCHO_CELDA + max(0, (ANCHO_CELDA - c.width) // 2), PISO - c.height))
        dibujo.line((i * ANCHO_CELDA, PISO, (i + 1) * ANCHO_CELDA - 6, PISO), fill=(180, 160, 140))
        dibujo.text((i * ANCHO_CELDA + 4, PISO + 6), etiqueta, fill=(43, 35, 32))
    salida = salida.resize((salida.width * 2, salida.height * 2), Image.NEAREST)
    salida.save(sys.argv[1])


if __name__ == "__main__":
    main()
