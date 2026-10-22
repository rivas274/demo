"""Segmentación de Felipe (felipe_meshy.glb) con los cortes que marcó el creador (plantilla_esqueleto/).

Uso: python segmentar_v8.py <felipe.glb> <dir_plantilla> <dir_salida>

Proyección (igual que vistas.gd): modelo centrado en su AABB, cámara ortográfica de lado = 1,15 x mayor
extensión para 1024 px. Frente: px = x, py = -y. Perfil (mira a la derecha): px = z, py = -y.
Izquierda/derecha son las de Felipe: su izquierda es +X (en el frente sale a la derecha de la imagen).

Piezas (orden de prioridad, la última gana):
  cuerpo_grupa / cuerpo_pecho  dos círculos del perfil (creador_perfil_cuerpo.png), la cara va al más cercano
  pata_*                       contornos grandes de perfil (desde hombro y cadera, por el flanco); izquierda o
                               derecha por el contorno del frente (delanteras) o por el signo de X (traseras);
                               la franja central de la panza (|x| chico) queda en el cuerpo
  melena                       contorno del pecho en el frente, solo la mitad delantera
  cola_base / cola_medio / cola_punta   contorno de la cola en perfil, partido por las curvas del dibujo
  cabeza                       contorno de perfil (con la papada)
  oreja_* / mechon_*           contorno de frente y de perfil a la vez
Salidas: etiquetas.npy (por cara, trimesh force="mesh", process=False), piezas.json (nombres),
entrada_holopart.glb (una malla por pieza), segmentacion.glb (colores) y control.png (proyección sobre la
plantilla, para revisar la alineación).
"""
import json
import os
import sys

import numpy as np
import trimesh
from PIL import Image
from scipy import ndimage
from scipy.sparse import coo_matrix
from scipy.sparse.csgraph import connected_components

entrada, dir_pl, dir_salida = sys.argv[1:4]
os.makedirs(dir_salida, exist_ok=True)

PIEZAS = ["cuerpo_grupa", "cuerpo_pecho", "melena", "cabeza", "oreja_izq", "oreja_der", "mechon_izq",
          "mechon_der", "cola_base", "cola_medio", "cola_punta", "pata_del_izq", "pata_del_der",
          "pata_tras_izq", "pata_tras_der"]
P = {n: i for i, n in enumerate(PIEZAS)}
COLORES = np.array([[240, 220, 190], [250, 200, 160], [255, 255, 255], [230, 90, 80], [200, 40, 60],
                    [250, 140, 120], [240, 200, 40], [200, 160, 20], [90, 90, 220], [70, 140, 240],
                    [150, 110, 240], [80, 200, 90], [30, 120, 50], [230, 160, 40], [160, 90, 20]], np.uint8)
BITS_PERFIL = {"cabeza": 0, "oreja": 1, "mechon": 2, "pata_del": 3, "pata_tras": 4, "cola": 5}
BITS_FRENTE = {"oreja_i": 0, "oreja_d": 1, "mechon_i": 2, "mechon_d": 3, "pecho": 4, "pata_i": 5, "pata_d": 6}

malla = trimesh.load(entrada, force="mesh", process=False)
mn, mx = malla.bounds
centro = (mn + mx) / 2
lado = (mx - mn).max() * 1.15
c = malla.triangles_center
rel = c - centro
px_f = np.clip((512 + rel[:, 0] / lado * 1024).astype(int), 0, 1023)
px_p = np.clip((512 + rel[:, 2] / lado * 1024).astype(int), 0, 1023)
py = np.clip((512 - rel[:, 1] / lado * 1024).astype(int), 0, 1023)
x = c[:, 0]

perfil = np.asarray(Image.open(os.path.join(dir_pl, "mascaras_perfil.png")))[..., 0]
frente = np.asarray(Image.open(os.path.join(dir_pl, "mascaras_frente.png")))[..., 0]


def bit_p(nombre):
    return ((perfil[py, px_p] >> BITS_PERFIL[nombre]) & 1) == 1


def bit_f(nombre):
    return ((frente[py, px_f] >> BITS_FRENTE[nombre]) & 1) == 1


def lineas(nombre, grosor=2):
    im = np.array(Image.open(os.path.join(dir_pl, nombre)).convert("RGB")).astype(int)
    r, g, b = im[..., 0], im[..., 1], im[..., 2]
    return ndimage.binary_dilation((r > 90) & (r - g > 55) & (r - b > 40) & (g < 90), iterations=grosor)


# Cuerpo: dos círculos del perfil. Se ajusta un círculo a cada trazo (los dos se cortan, así que se separan por
# el lado: grupa a la izquierda de la imagen, pecho a la derecha) y cada cara va al círculo más cercano.
lc = lineas("creador_perfil_cuerpo.png", 1)
ys, xs = np.where(lc[60:])  # sin el título
ys = ys + 60
circulos = []
for lado_img in (xs < 600, xs >= 600):  # aprox.: el trazo de la grupa queda casi todo a la izquierda
    X, Y = xs[lado_img].astype(float), ys[lado_img].astype(float)
    A = np.c_[2 * X, 2 * Y, np.ones_like(X)]
    sol, *_ = np.linalg.lstsq(A, X ** 2 + Y ** 2, rcond=None)
    cx, cy = sol[0], sol[1]
    circulos.append((cx, cy, np.sqrt(sol[2] + cx ** 2 + cy ** 2)))
print("círculos del cuerpo (px):", [tuple(round(v) for v in ci) for ci in circulos])
d_grupa = np.hypot(px_p - circulos[0][0], py - circulos[0][1]) / circulos[0][2]
d_pecho = np.hypot(px_p - circulos[1][0], py - circulos[1][1]) / circulos[1][2]
et = np.where(d_grupa <= d_pecho, P["cuerpo_grupa"], P["cuerpo_pecho"])

# Patas.
centro_x = 0.06 * (mx[0] - mn[0])  # franja central de la panza que queda en el cuerpo
pd, pt = bit_p("pata_del"), bit_p("pata_tras")
et[pd & bit_f("pata_d")] = P["pata_del_izq"]  # pata_d = derecha de la imagen = izquierda de Felipe (+X)
et[pd & bit_f("pata_i")] = P["pata_del_der"]
et[pd & ~bit_f("pata_d") & ~bit_f("pata_i") & (x > centro_x)] = P["pata_del_izq"]
et[pd & ~bit_f("pata_d") & ~bit_f("pata_i") & (x < -centro_x)] = P["pata_del_der"]
et[pt & (x > centro_x)] = P["pata_tras_izq"]
et[pt & (x < -centro_x)] = P["pata_tras_der"]

# Melena: contorno del pecho visto de frente, solo la mitad delantera (si no, entraría el lomo de atrás).
et[bit_f("pecho") & (px_p > circulos[1][0] - 0.2 * circulos[1][2])] = P["melena"]

# Cola en 3 tramos, por las curvas del dibujo (en px del perfil): la punta es lo que queda arriba de la
# línea horizontal ~y 325; la base, lo que queda bajo la curva inferior del tramo medio.
cola = bit_p("cola")
punta = py < 325
base = py > 500 - (px_p - 155) * 0.41
# Mechones de la cola que se salen del contorno dibujado: lo que está detrás y por encima del lomo es cola.
rel_y_lomo = -0.12 - centro[1]
cola |= (rel[:, 2] < -0.42 - centro[2]) & (rel[:, 1] > rel_y_lomo) & ~bit_p("cabeza")
et[cola] = P["cola_medio"]
et[cola & punta] = P["cola_punta"]
et[cola & base & ~punta] = P["cola_base"]

# Cabeza, orejas y mechones.
et[bit_p("cabeza")] = P["cabeza"]
et[bit_p("oreja") & bit_f("oreja_d")] = P["oreja_izq"]
et[bit_p("oreja") & bit_f("oreja_i")] = P["oreja_der"]
et[bit_p("mechon") & bit_f("mechon_d")] = P["mechon_izq"]
et[bit_p("mechon") & bit_f("mechon_i")] = P["mechon_der"]

# Suavizado por mayoría entre caras vecinas e islas chicas a la pieza vecina dominante.
adj = malla.face_adjacency
n = len(c)
A = coo_matrix((np.ones(len(adj) * 2), (np.r_[adj[:, 0], adj[:, 1]], np.r_[adj[:, 1], adj[:, 0]])),
               shape=(n, n)).tocsr()
for _ in range(4):
    votos = np.zeros((n, len(PIEZAS)))
    votos[np.arange(n), et] += 1.5
    for k in range(len(PIEZAS)):
        votos[:, k] += A @ (et == k).astype(float)
    et = votos.argmax(1)
for k in range(len(PIEZAS)):
    caras = np.where(et == k)[0]
    if len(caras) == 0:
        continue
    ncomp, comp = connected_components(A[caras][:, caras], directed=False)
    if ncomp > 1:
        tam = np.bincount(comp)
        for ci in np.where(tam < tam.max() * 0.2)[0]:
            isla = caras[comp == ci]
            vec = A[isla].nonzero()[1]
            vec = vec[et[vec] != k]
            if len(vec):
                et[isla] = np.bincount(et[vec], minlength=len(PIEZAS)).argmax()

for k, nombre in enumerate(PIEZAS):
    print(f"{nombre}: {(et == k).sum()} caras")

np.save(os.path.join(dir_salida, "etiquetas.npy"), et)
json.dump(PIEZAS, open(os.path.join(dir_salida, "piezas.json"), "w"), ensure_ascii=False, indent=1)
escena = trimesh.Scene()
for k, nombre in enumerate(PIEZAS):
    caras = np.where(et == k)[0]
    if len(caras):
        sub = malla.submesh([caras], append=True)
        sub.visual = trimesh.visual.ColorVisuals(sub, face_colors=np.tile(np.r_[COLORES[k], 255], (len(sub.faces), 1)))
        escena.add_geometry(sub, node_name=nombre, geom_name=nombre)
escena.export(os.path.join(dir_salida, "entrada_holopart.glb"))
vista = trimesh.Trimesh(malla.vertices, malla.faces, process=False)
vista.visual = trimesh.visual.ColorVisuals(vista, face_colors=np.c_[COLORES[et], np.full(len(et), 255)])
vista.export(os.path.join(dir_salida, "segmentacion.glb"))

# Control de alineación: centros de cara proyectados sobre la plantilla de perfil, con el color de su pieza.
for nombre, pxs in (("perfil", px_p), ("frente", px_f)):
    base_im = np.asarray(Image.open(os.path.join(dir_pl, f"plantilla_{nombre}.png")).convert("RGB")).copy()
    orden = np.argsort(rel[:, 0] if nombre == "perfil" else rel[:, 2])  # lo de atrás primero
    base_im[py[orden], pxs[orden]] = COLORES[et[orden]]
    Image.fromarray(base_im).resize((512, 512)).save(os.path.join(dir_salida, f"control_{nombre}.png"))
print("ok", dir_salida)
