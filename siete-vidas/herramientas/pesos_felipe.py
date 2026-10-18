"""Genera las formas de peso de Felipe (Flaco, Normal y Gordito) a partir de una hoja de animación.

Solo ensancha el cuerpo: la cabeza y la cola no cambian. El ensanche crece desde el cuello
hasta la panza y se aplica fila por fila con vecino más cercano, así sigue siendo pixel art.

Uso: python3 pesos_felipe.py <hoja.png> <cuadros> <carpeta_salida> <prefijo>
"""
import sys
from pathlib import Path

from PIL import Image

# Modo Buda no se hace aquí: es una pose propia de SpriteCook (felipe-buda-base.png).
FORMAS = {"flaco": 0.84, "normal": 1.0, "gordito": 1.22}
CUELLO, PANZA = 0.56, 0.84  # posiciones relativas a la altura del personaje
MARGEN = 24


def smooth(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


def bbox_rows(img):
    a = img.split()[3]
    box = a.getbbox()
    return box


def ensanchar(frame, factor):
    w, h = frame.size
    out = Image.new("RGBA", (w + MARGEN * 2, h))
    box = bbox_rows(frame)
    if not box:
        return out
    top, bottom = box[1], box[3]
    alto = bottom - top
    cuello = top + alto * CUELLO
    panza = top + alto * PANZA
    src = frame.load()
    dst = out.load()
    # Centro del cuerpo: el promedio de columnas opacas en la fila de la panza.
    fila = int(panza)
    cols = [x for x in range(w) if src[x, fila][3]]
    cx = (min(cols) + max(cols)) / 2 if cols else w / 2
    for y in range(h):
        k = smooth((y - cuello) / max(1, panza - cuello))
        f = 1 + (factor - 1) * k
        for x in range(w + MARGEN * 2):
            sx = round(cx + (x - MARGEN - cx) / f)
            if 0 <= sx < w and src[sx, y][3]:
                dst[x, y] = src[sx, y]
    return out


def main():
    hoja = Image.open(sys.argv[1]).convert("RGBA")
    n = int(sys.argv[2])
    salida = Path(sys.argv[3])
    prefijo = sys.argv[4]
    salida.mkdir(parents=True, exist_ok=True)
    fw = hoja.width // n
    frames = [hoja.crop((i * fw, 0, (i + 1) * fw, hoja.height)) for i in range(n)]
    for nombre, factor in FORMAS.items():
        outs = [ensanchar(f, factor) for f in frames]
        w, h = outs[0].size
        sheet = Image.new("RGBA", (w * n, h))
        for i, f in enumerate(outs):
            sheet.alpha_composite(f, (i * w, 0))
        sheet.save(salida / f"{prefijo}-{nombre}-sheet.png")


if __name__ == "__main__":
    main()
