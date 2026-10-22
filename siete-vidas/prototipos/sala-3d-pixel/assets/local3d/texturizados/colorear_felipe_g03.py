"""Colorea g03.glb (Felipe con patas visibles) con colores por vértice.

1. Orienta la malla: mirando a +z, de pie en y, centrada en sus 4 patas (la IA la
   dejó girada como la imagen 3/4 de entrada).
2. Pinta limpio por zonas según las fotos reales: casi todo blanco, gorra atigrada
   gris pardo con franja en V, interior de orejas rosado, 2 manchas grandes y simétricas
   en el lomo con rayas sutiles, cola entera café casi negro con bandas.
3. Proyecta de frente la imagen de entrada (`entrada_gemini_v2_1.jpg`) solo en la cara y
   el pecho que miran a la cámara (ojos, nariz, boca, V y gorra alrededor), con el
   color corregido a la paleta y el borde fundido con lo pintado.
Uso: python3 colorear_felipe_g03.py [salida]
"""
import json
import os
import sys
import numpy as np
import trimesh
from PIL import Image
from scipy.cluster.vq import kmeans2
from trimesh import remesh

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import proyeccion as pr  # noqa: E402

LOCAL = os.path.dirname(AQUI)
SRC = os.path.join(LOCAL, "felipe_variantes_v2", "g03.glb")
IMG = os.path.join(LOCAL, "felipe_variantes", "entrada_gemini_v2_1.jpg")
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(AQUI, "felipe_g03_color.glb")


def hexc(h):
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float)


BLANCO = hexc("f3efe8")
ATIG = hexc("8b7864")
RAYA = hexc("6b5c4e")
COLA = hexc("4a3f36")
COLA_R = hexc("362d26")
OREJA = hexc("e0a7a5")


def suave(t):
    t = np.clip(t, 0, 1)
    return t * t * (3 - 2 * t)


# ---------------------------------------------------------------- orientar
m = trimesh.load(SRC, force="mesh")
m = trimesh.Trimesh(m.vertices, m.faces, process=True)
V = m.vertices.copy()
bajos = V[V[:, 1] < V[:, 1].min() + 0.06]
centros, _ = kmeans2(bajos[:, [0, 2]], 4, minit="++", seed=1)
orden = np.argsort(centros @ np.array([1.0, 1.0]))  # la cabeza está hacia +x+z
adelante = centros[orden[2:]].mean(0) - centros[orden[:2]].mean(0)
adelante /= np.linalg.norm(adelante)
th = np.arctan2(-adelante[0], adelante[1])
R = np.array([[np.cos(th), 0, np.sin(th)], [0, 1, 0], [-np.sin(th), 0, np.cos(th)]])
V = V @ R.T
pc = np.c_[centros[:, 0], np.zeros(4), centros[:, 1]] @ R.T
V[:, 0] -= pc[:, 0].mean()
V[:, 2] -= pc[:, 2].mean()
F = m.faces.copy()

# Subdivide la cara dos veces (ojos y nariz con detalle para la proyección).
for _ in range(2):
    c = V[F].mean(axis=1)
    idx = np.where((c[:, 2] > 0.55) & (c[:, 1] > -0.2) & (c[:, 1] < 0.75) & (np.abs(c[:, 0] + 0.08) < 0.75))[0]
    V, F = remesh.subdivide(V, F, face_index=idx)
tm = trimesh.Trimesh(V, F, process=False)
N = tm.vertex_normals
x, y, z = V[:, 0], V[:, 1], V[:, 2]
nv = len(V)
nbr = [[] for _ in range(nv)]
for a, b in tm.edges_unique:
    nbr[a].append(b)
    nbr[b].append(a)

# ---------------------------------------------------------------- zonas
XH = -0.085  # centro de la cabeza en x (la cabeza está algo corrida)
BL, AT, CO, OR = 0, 1, 2, 3
lab = np.zeros(nv, int)
cabeza = (((x - XH) / 0.75) ** 2 + ((y - 0.33) / 0.62) ** 2 + ((z - 0.55) / 0.62) ** 2 < 1.0) & (y > -0.22)
cola = ((z < -0.68) & (y > 0.0)) | ((z < -0.5) & (y > 0.3)) | ((z < -0.8) & (y > -0.15))
# Gorra: arriba de la cabeza; baja más por los lados y la nuca que por la cara.
linea = -0.02 + 0.28 * suave((z - 0.15) / 0.8)
gorra = cabeza & (y > linea)
v_blanca = (z > 0.7) & (np.abs(x - XH) < np.clip(0.80 - y, 0, None) * 0.30)
lab[gorra & ~v_blanca] = AT
# Interior de las orejas.
for ox in (-0.48, 0.33):
    oreja = (y > 0.6) & (np.abs(x - ox) < 0.11) & (N[:, 2] > 0.3) & (z > 0.25)
    lab[oreja] = OR
# Manchas del lomo: una silla grande sobre las caderas y otra en los hombros, simétricas.
lomo = ~cabeza & ~cola & (y > -0.42)
xb = 0.0
silla = ((x - xb) / 0.72) ** 2 + ((y - 0.1) / 0.45) ** 2 + ((z + 0.5) / 0.36) ** 2 < 1.0
hombro = ((x - xb) / 0.62) ** 2 + ((y - 0.16) / 0.36) ** 2 + ((z - 0.08) / 0.17) ** 2 < 1.0
lab[lomo & (silla | hombro)] = AT
lab[cola] = CO


def mayoria(L, it=3):
    for _ in range(it):
        nl = L.copy()
        for i in range(nv):
            if nbr[i]:
                cnt = np.bincount(L[nbr[i]], minlength=4)
                if cnt.max() > len(nbr[i]) * 0.5:
                    nl[i] = cnt.argmax()
        L = nl
    return L


lab = mayoria(lab)  # sin islas de pocos vértices
col = np.array([BLANCO, ATIG, COLA, OREJA])[lab]
# Rayas sutiles dentro de lo atigrado y bandas en la cola.
raya_lomo = (lab == AT) & ~cabeza & (np.sin(z * 20 + 2.0 * np.sin(y * 4)) > 0.55)
raya_gorra = (lab == AT) & cabeza & (y > 0.5) & (z < 0.6) & (np.sin(np.abs(x - XH) * 16 + 2 * np.sin(z * 3)) > 0.75)
col[raya_lomo | raya_gorra] = RAYA
d_cola = np.linalg.norm(V - np.array([0.0, 0.05, -0.75]), axis=1)
col[(lab == CO) & (np.sin(d_cola * 16) > 0.45)] = COLA_R


def suavizar(c, mask=None, it=1):
    for _ in range(it):
        nc = c.copy()
        idx = range(nv) if mask is None else np.where(mask)[0]
        for i in idx:
            if nbr[i]:
                nc[i] = 0.5 * c[i] + 0.5 * c[nbr[i]].mean(axis=0)
        c = nc
    return c


col = suavizar(col, it=3)  # borde suave de 2 o 3 vértices

# ---------------------------------------------------------------- proyección
# La imagen trae luz y sombra horneadas (el blanco en sombra es tan gris como la gorra),
# así que no se copia tal cual: se arma una "pintura plana" en el espacio de la imagen.
# - Frente (sobre la línea de los ojos): blanco o gorra según el brillo, con sus rayas;
#   de ahí salen la V blanca y la gorra alrededor, en colores de la paleta.
# - Rasgos (ojos, nariz, boca): el color de la imagen, ajustado a la paleta.
from scipy import ndimage  # noqa: E402

prm = json.load(open(os.path.join(AQUI, "felipe_g03_prm.json")))
img = np.array(Image.open(IMG).convert("RGB")).astype(float)
H, W = img.shape[:2]
lum = img @ np.array([0.3, 0.59, 0.11])
plana = np.zeros_like(img)
peso = np.zeros((H, W))


def caja(x0, y0, x1, y1):
    k = np.zeros((H, W), bool)
    k[y0:y1, x0:x1] = True
    return k


gato = pr.mascara_imagen(img.astype(np.uint8), tol=12)
frente_img = gato & (np.arange(H)[:, None] < 412)
clase = np.where(lum > 188, 0, np.where(lum < 125, 2, 1))
clase = ndimage.median_filter(clase, size=7)  # sin brillos sueltos
plana[frente_img] = np.array([BLANCO, ATIG, RAYA])[clase[frente_img]]
peso[frente_img] = 1.0
peso *= np.clip((412 - np.arange(H)[:, None]) / 25.0, 0, 1)  # se funde sobre los ojos
# Rasgos.
verde = (img.max(axis=2) - img.min(axis=2)) > 28  # iris verde amarillento (el pelaje es gris)
oscuro = lum < 85
ojos = np.zeros((H, W), bool)
for b in [(575, 410, 695, 478), (765, 412, 852, 478)]:
    o = (verde | oscuro) & caja(*b)
    o = ndimage.binary_fill_holes(ndimage.binary_closing(o, iterations=2))
    lab_o, n_o = ndimage.label(o)
    if n_o > 1:
        o = lab_o == (np.argmax(ndimage.sum(o, lab_o, range(1, n_o + 1))) + 1)
    ojos |= ndimage.binary_dilation(o, iterations=2)
nariz = (img[..., 0] > img[..., 1] + 25) & (img[..., 0] > 140) & caja(728, 458, 778, 495)
nariz = ndimage.binary_dilation(ndimage.binary_fill_holes(nariz), iterations=1)
boca = (lum < 150) & caja(712, 495, 775, 532) & ~nariz
plana[ojos] = img[ojos]
plana[nariz] = hexc("e59aa2")
plana[boca] = img[boca] * 0.8
peso = np.maximum(peso, ndimage.gaussian_filter(ojos.astype(float), 1.2) * 1.5)
peso_nb = np.clip(ndimage.gaussian_filter((nariz | boca).astype(float), 1.2) * 1.5, 0, 1)
plana = ndimage.gaussian_filter(plana, (1.0, 1.0, 0))
peso = np.clip(ndimage.gaussian_filter(peso, 1.0), 0, 1)
if os.environ.get('DEPURAR'):
    Image.fromarray(np.clip(plana * peso[..., None] + 128 * (1 - peso[..., None]), 0, 255).astype(np.uint8)).crop((380, 180, 900, 600)).save(os.environ['DEPURAR'])

vis, q = pr.visibles(V, F, N, prm, W, H, umbral_normal=0.4, tolerancia=0.008)
Nv = pr.vista(N, prm["yaw"], prm["pitch"])
frente = suave((Nv[:, 2] - 0.4) / 0.25)
oreja_m = np.zeros(nv, bool)
for ox in (-0.48, 0.33):
    oreja_m |= (y > 0.55) & (np.abs(x - ox) < 0.14)
zona = cabeza & (z > 0.4) & ~oreja_m
# Nariz y boca solo sobre su relieve (no en la mejilla de atrás, que asoma junto a la nariz).
cerca_nariz = (np.hypot(x + 0.2, y - 0.12) < 0.16) & (z > 0.95)  # nariz en (-0,2; 0,17; 1,07)
w = vis * frente * zona * np.clip(pr.muestrear(peso, q)[:, 0] + pr.muestrear(peso_nb, q)[:, 0] * cerca_nariz, 0, 1)
col = col * (1 - w[:, None]) + pr.muestrear(plana, q) * w[:, None]
col = suavizar(col, mask=(w > 0.02) & (w < 0.98), it=1)

rgba = np.c_[np.clip(col, 0, 255), np.full(nv, 255)].astype(np.uint8)
trimesh.Trimesh(V, F, vertex_colors=rgba, process=False).export(OUT, include_normals=True)
print("ok", nv, len(F), OUT)
