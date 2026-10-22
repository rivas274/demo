"""Convierte las marcas del creador (líneas rojo oscuro) en máscaras de piezas para la v8.

Salida: mascaras_perfil.png y mascaras_frente.png (1024 x 1024). El canal R es un campo
de bits: cada bit es una pieza (ver BITS_*). Las cuenta felipe_meshy.gd con el mismo
mapeo que vistas.gd: modelo centrado en su AABB, cámara ortográfica de 1,15 x 1,899
unidades para 1024 px; perfil = piv girado 90° en Y (mira a la derecha).
Uso: python3 mascaras_v8.py  (y revisa mascaras_control.png)
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage

AQUI = os.path.dirname(os.path.abspath(__file__))

BITS_PERFIL = {"cabeza": 0, "oreja": 1, "mechon": 2, "pata_del": 3, "pata_tras": 4, "cola": 5}
BITS_FRENTE = {"oreja_i": 0, "oreja_d": 1, "mechon_i": 2, "mechon_d": 3, "pecho": 4, "pata_i": 5, "pata_d": 6}


def lineas(nombre, grosor=2):
    im = np.array(Image.open(os.path.join(AQUI, nombre)).convert("RGB")).astype(int)
    r, g, b = im[..., 0], im[..., 1], im[..., 2]
    m = (r > 90) & (r - g > 55) & (r - b > 40) & (g < 90)
    return ndimage.binary_dilation(m, iterations=grosor)


def rellenar(m):
    return ndimage.binary_fill_holes(m)


def componentes(m):
    lab, n = ndimage.label(m)
    return [lab == i for i in range(1, n + 1)]


def por_semillas(lin, semillas):
    """Regiones interiores (sin las líneas) que contienen alguna semilla, más su borde."""
    lab, _ = ndimage.label(~lin)
    out = np.zeros_like(lin)
    for x, y in semillas:
        out |= lab == lab[y, x]
    return ndimage.binary_dilation(out, iterations=3)


perfil = np.zeros((1024, 1024), np.uint8)
frente = np.zeros((1024, 1024), np.uint8)


def poner(img, bit, m):
    img[m] |= np.uint8(1 << bit)


# Cabeza, oreja y mechón de mejilla (perfil): regiones por semillas.
lc = lineas("creador_perfil_cabeza.png")
oreja = por_semillas(lc, [(760, 200), (722, 290), (745, 250)])
mechon = por_semillas(lc, [(745, 480), (740, 420), (735, 530)])
cabeza = rellenar(lc) & ~oreja & ~mechon
cabeza = cabeza | (oreja & rellenar(lc) & False)
poner(perfil, BITS_PERFIL["cabeza"], rellenar(lc))
poner(perfil, BITS_PERFIL["oreja"], oreja)
poner(perfil, BITS_PERFIL["mechon"], mechon)

# Patas (perfil): cada contorno cerrado relleno; la trasera es la de la izquierda.
lp = lineas("creador_perfil_patas.png", 3)
for c in componentes(rellenar(lp)):
    if c.sum() < 2000:
        continue
    xs = np.where(c)[1]
    poner(perfil, BITS_PERFIL["pata_tras" if xs.mean() < 560 else "pata_del"], c)

# Cola (perfil): la unión de los 3 contornos (los tramos se cortan por planos).
poner(perfil, BITS_PERFIL["cola"], rellenar(lineas("creador_perfil_cola.png", 3)))

# Orejas y mechones (frente).
lo = lineas("creador_frente_orejas_mejillas.png", 3)
for c in componentes(rellenar(lo)):
    if c.sum() < 300:
        continue
    ys, xs = np.where(c)
    lado = "i" if xs.mean() < 512 else "d"
    poner(frente, BITS_FRENTE[("oreja_" if ys.mean() < 360 else "mechon_") + lado], c)

# Pecho (frente).
for c in componentes(rellenar(lineas("creador_frente_pecho.png", 3))):
    if c.sum() > 5000:
        poner(frente, BITS_FRENTE["pecho"], c)

# Patas delanteras (frente).
for c in componentes(rellenar(lineas("creador_frente_patas.png", 3))):
    if c.sum() < 2000:
        continue
    xs = np.where(c)[1]
    poner(frente, BITS_FRENTE["pata_i" if xs.mean() < 512 else "pata_d"], c)

for nombre, img in (("perfil", perfil), ("frente", frente)):
    rgba = np.zeros((1024, 1024, 4), np.uint8)
    rgba[..., 0] = img
    rgba[..., 3] = 255
    Image.fromarray(rgba).save(os.path.join(AQUI, "mascaras_%s.png" % nombre))

# Control: cada bit de un color sobre la plantilla.
colores = np.array([[230, 60, 60], [60, 160, 230], [240, 200, 40], [70, 200, 90], [180, 80, 220], [240, 130, 40], [40, 220, 200]])
ctl = []
for nombre, img, bits in (("perfil", perfil, BITS_PERFIL), ("frente", frente, BITS_FRENTE)):
    base = np.array(Image.open(os.path.join(AQUI, "plantilla_%s.png" % nombre)).convert("RGB")).astype(float)
    for b in bits.values():
        m = (img >> b) & 1 == 1
        base[m] = base[m] * 0.45 + colores[b] * 0.55
    ctl.append(base.astype(np.uint8))
Image.fromarray(np.concatenate(ctl, axis=1)).resize((1024, 512)).save(os.path.join(AQUI, "mascaras_control.png"))
print("ok", {k: int(((perfil >> v) & 1).sum()) for k, v in BITS_PERFIL.items()},
      {k: int(((frente >> v) & 1).sum()) for k, v in BITS_FRENTE.items()})
