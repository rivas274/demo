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

for s in (-1, 1):
    ox, oy = 0.061 * s, 0.632
    dx, dy = (x - ox) / 0.036, (y - oy) / 0.03
    r = np.hypot(dx, dy)
    ojo = frente & (r < 1)
    col[ojo] = ESCLERA
    ix, iy = (x - ox) / 0.024, (y - oy + 0.002) / 0.027
    col[ojo & (np.hypot(ix, iy) < 1)] = OJO
    col[ojo & (np.hypot(ix * 1.9, iy * 1.9) < 1)] = PUPILA
    bx, by = (x - (ox - 0.008)) / 0.008, (y - (oy + 0.01)) / 0.008
    col[ojo & (np.hypot(bx, by) < 1)] = BRILLO
    # pestañas: arco grueso arriba y línea fina abajo
    arco = frente & (r >= 0.85) & (r < 1.3) & (y > oy - 0.004)
    col[arco] = PESTANA
    ext = frente & (np.abs(y - (oy + 0.012 - 0.6 * (np.abs(x - ox) - 0.034))) < 0.005) & (np.abs(x - ox) > 0.03) & (np.abs(x - ox) < 0.045) & (np.sign(x - ox) == s)
    col[ext] = PESTANA
    # ceja
    cx = (x - (ox + 0.004 * s)) / 0.04
    cy = oy + 0.05 - 0.012 * cx ** 2
    ceja = frente & (np.abs(cx) < 1) & (np.abs(y - cy) < 0.0075 * (1 - 0.5 * np.abs(cx)) + 0.002)
    col[ceja] = CEJA

# boca: arco pequeño
bx = x / 0.026
by = 0.546 - 0.006 * (1 - bx ** 2)
boca = frente & (np.abs(bx) < 1) & (np.abs(y - by) < 0.0045)
col[boca] = BOCA

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

rgba = np.c_[np.clip(col, 0, 255), np.full(len(V), 255)].astype(np.uint8)
trimesh.Trimesh(V, F, vertex_colors=rgba, process=False).export(OUT, include_normals=True)
print("ok", len(V), len(F), OUT)
