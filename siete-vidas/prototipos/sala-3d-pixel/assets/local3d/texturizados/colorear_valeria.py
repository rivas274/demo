"""Limpia y colorea v04.glb (Valeria) con colores por vértice por zonas."""
import sys
import numpy as np
import trimesh
from trimesh import remesh

SRC = "/home/user/demo/siete-vidas/prototipos/sala-3d-pixel/assets/local3d/valeria_variantes/v04.glb"
OUT = sys.argv[1] if len(sys.argv) > 1 else "/home/user/demo/siete-vidas/prototipos/sala-3d-pixel/assets/local3d/texturizados/valeria_color.glb"


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float)


VERDE, GRIS, PELO, ROSA, PIEL, CREMA = range(6)
ORIG = np.array([hexc(h) for h in ("2e807a", "4e4e56", "5c3a28", "e2929c", "e8b48c", "ece2ce")])
PALETA = np.array([hexc(h) for h in ("2f7f78", "45454d", "4f3123", "e0909b", "d9a27e", "ece2ce")])
OJO = hexc("3b2417")
PUPILA = hexc("1e130d")
ESCLERA = hexc("f6f1ea")
PESTANA = hexc("2a1a12")
CEJA = hexc("5a3a28")
BOCA = hexc("b35f5f")
BRILLO = hexc("ffffff")

m = trimesh.load(SRC, force="mesh")
V, F = m.vertices.copy(), m.faces.copy()
C = m.visual.vertex_colors[:, :3].astype(float)
lab = np.argmin(((C[:, None, :] - ORIG[None]) ** 2).sum(-1), axis=1)
x, y, z = V[:, 0] + 0.005, V[:, 1], V[:, 2]
N = trimesh.Trimesh(V, F, process=False).vertex_normals
nv = len(V)

nbr = [[] for _ in range(nv)]
for a, b in trimesh.Trimesh(V, F, process=False).edges_unique:
    nbr[a].append(b)
    nbr[b].append(a)

# --- reglas por zona ---
cara = (((x / 0.158) ** 2 + ((y - 0.605) / 0.165) ** 2) < 1) & (z > 0.06) & (N[:, 2] > -0.1)
cabeza = y > 0.43
cuello = (y > 0.36) & (y <= 0.43)
sudadera = (y > -0.165) & (y <= 0.36)
pantalon = (y > -0.76) & (y <= -0.165)
calcetin = (y > -0.84) & (y <= -0.76)
pantufla = y <= -0.84
brazo = np.abs(x) > 0.232
mano = brazo & (y < -0.035) & (y > -0.5)

L = lab.copy()
L[cabeza & ~cara & ~np.isin(lab, [PELO, PIEL])] = PELO
L[cara] = PIEL
# orejas: piel solo si ya era piel y está a los lados, el resto pelo
L[cuello & ~np.isin(lab, [VERDE, PIEL]) & ~((lab == PELO) & (np.abs(x) > 0.11))] = VERDE
rizo = (y > 0.396) & (y <= 0.45) & (np.abs(x) > 0.135) & (np.abs(x) < 0.2) & (z > 0.02)
L[rizo] = PELO
cordon = (np.abs(np.abs(x) - 0.045) < 0.022) & (z > 0.1) & (y > 0.08) & (y < 0.34) & (N[:, 2] > 0.3)
sud = sudadera & ~mano
L[sud] = VERDE
L[mano] = PIEL
L[pantalon & ~mano] = GRIS
L[calcetin] = ROSA
L[pantufla] = CREMA


def mayoria(L, mask, it=3, k=6):
    for _ in range(it):
        nl = L.copy()
        for i in np.where(mask)[0]:
            if nbr[i]:
                cnt = np.bincount(L[nbr[i]], minlength=k)
                if cnt.max() > len(nbr[i]) * 0.5:
                    nl[i] = cnt.argmax()
        L = nl
    return L


# limpia salpicaduras sin mover los bordes de las zonas forzadas
L = mayoria(L, (cabeza & ~cara) | (cuello & ~rizo))
col = PALETA[L].copy()


def suavizar(c, nb, mask=None, it=1):
    n = len(c)
    for _ in range(it):
        nc = c.copy()
        idx = range(n) if mask is None else np.where(mask)[0]
        for i in idx:
            if nb[i]:
                nc[i] = 0.5 * c[i] + 0.5 * c[nb[i]].mean(axis=0)
        c = nc
    return c



# --- subdivide la cara dos veces para los rasgos ---
for _ in range(2):
    cc = V[F].mean(axis=1)
    idx = np.where(((np.abs(cc[:, 0]) < 0.19) & (cc[:, 1] > 0.36) & (cc[:, 1] < 0.8) & (cc[:, 2] > 0.0)) | ((np.abs(cc[:, 0]) < 0.1) & (cc[:, 1] > 0.08) & (cc[:, 1] < 0.36) & (cc[:, 2] > 0.08)))[0]
    V, F, col = remesh.subdivide(V, F, face_index=idx, vertex_attributes={"c": col})
    col = col["c"]
# una vez más solo en ojos, cejas, nariz y boca
cc = V[F].mean(axis=1)
idx = np.where((np.abs(cc[:, 0]) < 0.13) & (cc[:, 1] > 0.5) & (cc[:, 1] < 0.7) & (cc[:, 2] > 0.08))[0]
V, F, col = remesh.subdivide(V, F, face_index=idx, vertex_attributes={"c": col})
col = col["c"]
tm = trimesh.Trimesh(V, F, process=False)
N = tm.vertex_normals
x, y, z = V[:, 0] + 0.005, V[:, 1], V[:, 2]
# borde de la cara nítido: se recalcula el óvalo en la malla fina
zona = (np.abs(x) < 0.19) & (y > 0.43) & (y < 0.8) & (z > 0.0)
r_cara = (x / 0.158) ** 2 + ((y - 0.605) / 0.165) ** 2
en_cara = (r_cara < 1) & (z > 0.06) & (N[:, 2] > -0.1)
col[zona & en_cara] = PALETA[PIEL]
col[zona & ~en_cara] = PALETA[PELO]
# escote en V bajo la barbilla
cuello2 = (y > 0.36) & (y <= 0.45) & (z > 0.0) & (np.abs(x) < 0.19)
v_esc = cuello2 & (np.abs(x) < 0.02 + (y - 0.36) * 0.9) & (N[:, 2] > 0.0)
col[cuello2 & ~v_esc & (y < 0.43) & (np.abs(x) < 0.11)] = PALETA[VERDE]
col[v_esc] = PALETA[PIEL]
frente = (z > 0.08) & (N[:, 2] > 0.25) & (np.abs(x) < 0.16) & (y > 0.48) & (y < 0.72)

# cordones de la sudadera: dos líneas crema con su puntera
for s_ in (-1, 1):
    t = np.clip((0.33 - y) / (0.33 - 0.13), 0, 1)
    cxl = s_ * (0.040 + 0.008 * t)
    linea = (np.abs(x - cxl) < 0.0065) & (y > 0.13) & (y < 0.33)
    punta = (np.abs(x - s_ * 0.048) < 0.0095) & (y > 0.115) & (y < 0.15)
    pecho = (z > 0.1) & (N[:, 2] > 0.3)
    col[pecho & (linea | punta)] = PALETA[CREMA]
    col[pecho & punta & (y < 0.128)] = hexc("cfc4ae")

nb2 = [[] for _ in range(len(V))]
for a, b in tm.edges_unique:
    nb2[a].append(b)
    nb2[b].append(a)
col = suavizar(col, nb2, mask=frente | zona | cuello2 | ((np.abs(x) < 0.1) & (y > 0.08) & (y < 0.36)), it=1)

# --- cara proyectada desde la imagen de entrada (gemini frente 1) ---
# La forma salió de esa imagen: sus ojos, cejas, nariz y boca calzan con los relieves.
# Cámara ajustada igualando siluetas (valeria_prm.json). Solo caras que miran a la
# cámara (normal·vista > 0,4) y dentro del óvalo de la cara, con borde fundido.
import json, os
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proyeccion as pr
AQUI = os.path.dirname(os.path.abspath(__file__))
prm = json.load(open(os.path.join(AQUI, "valeria_prm.json")))
img = np.array(Image.open(SRC.replace("v04.glb", "entrada_gemini_frente.png")).convert("RGB").crop((0, 60, 340, 1010))).astype(float)
H, W = img.shape[:2]
vis, q = pr.visibles(V, F, N, prm, W, H, umbral_normal=0.4)
r_cara = (x / 0.158) ** 2 + ((y - 0.605) / 0.165) ** 2
c_img = pr.muestrear(img, q)
fondo = (c_img.min(axis=1) > 215) & (np.ptp(c_img, axis=1) < 20) & (r_cara > 0.72)
w = np.clip((0.88 - r_cara) / 0.2, 0, 1) * vis * (z > 0.05) * ~fondo
col = col * (1 - w[:, None]) + c_img * w[:, None]

rgba = np.c_[np.clip(col, 0, 255), np.full(len(V), 255)].astype(np.uint8)
trimesh.Trimesh(V, F, vertex_colors=rgba, process=False).export(OUT, include_normals=True)
print("ok", len(V), len(F), OUT)
