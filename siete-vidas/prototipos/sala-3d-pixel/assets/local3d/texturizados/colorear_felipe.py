"""Colorea f07.glb (Felipe) con colores por vértice por zonas."""
import sys
import numpy as np
import trimesh
from trimesh import remesh

SRC = "/home/user/demo/siete-vidas/prototipos/sala-3d-pixel/assets/local3d/felipe_variantes/f07.glb"
OUT = sys.argv[1] if len(sys.argv) > 1 else "/home/user/demo/siete-vidas/prototipos/sala-3d-pixel/assets/local3d/texturizados/felipe_color.glb"


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float)


BLANCO = hexc("f3efe8")
ATIG = hexc("8b7864")
RAYA = hexc("5b4d41")
COLA = hexc("4a3f36")
COLA_R = hexc("2e2621")
OREJA_IN = hexc("cfb2aa")
ROSA = hexc("e59aa2")
OJO = hexc("a3b06a")
PUPILA = hexc("1b1714")
LINEA = hexc("3a302a")
BRILLO = hexc("ffffff")

m = trimesh.load(SRC, force="mesh")
V, F = m.vertices.copy(), m.faces.copy()

# Subdivide solo la cara (dos veces) para que ojos y nariz salgan nítidos.
for _ in range(2):
    c = V[F].mean(axis=1)
    idx = np.where((c[:, 2] > 0.6) & (c[:, 1] > -0.2) & (c[:, 1] < 0.3) & (np.abs(c[:, 0]) < 0.42))[0]
    V, F = remesh.subdivide(V, F, face_index=idx)
m = trimesh.Trimesh(V, F, process=False)
N = m.vertex_normals
x, y, z = V[:, 0] - 0.01, V[:, 1], V[:, 2]
nv = len(V)
col = np.tile(BLANCO, (nv, 1))

# vecinos para suavizar bordes
edges = m.edges_unique
nbr = [[] for _ in range(nv)]
for a, b in edges:
    nbr[a].append(b)
    nbr[b].append(a)


def suavizar(c, mask=None, it=1):
    for _ in range(it):
        nc = c.copy()
        for i in range(nv):
            if mask is not None and not mask[i]:
                continue
            if nbr[i]:
                nc[i] = 0.5 * c[i] + 0.5 * c[nbr[i]].mean(axis=0)
        c = nc
    return c


# --- zonas grandes ---
cabeza = ((z > 0.12) & (y > -0.32)) | ((z > -0.28) & (y > 0.14))
cola = ((z < -0.32) & (y > 0.12)) | ((z < -0.62) & (y > -0.05))
cuerpo = ~cabeza & ~cola

# Gorra: arriba de la cabeza, orejas y nuca; baja por los lados.
lado = np.clip((np.abs(x) - 0.2) / 0.25, 0, 1)          # 0 al centro, 1 a los lados
atras = np.clip((0.75 - z) / 0.35, 0, 1)                 # 0 en la cara, 1 en la nuca
linea_gorra = 0.22 - 0.10 * lado - 0.16 * atras
gorra = cabeza & (y > linea_gorra)
# franja blanca en V (frente, entre los ojos, se angosta hacia arriba)
ancho_v = np.clip(0.60 - y, 0, None) * 0.42
franja = (z > 0.62) & (N[:, 2] > 0.2) & (np.abs(x) < ancho_v)
gorra &= ~franja
col[gorra] = ATIG
# rayas de la gorra: líneas que corren de la frente a la nuca (como la "M")
r_g = np.sin(np.abs(x) * 30 + 3.0 * np.sin(z * 4)) > 0.55
col[gorra & r_g & (y > 0.28)] = RAYA
# interior de las orejas
oreja = gorra & (y > 0.42) & (np.abs(x) > 0.22) & (N[:, 2] > 0.35) & (z > 0.45)
col[oreja] = OREJA_IN

# Manchas del lomo (2 grandes + 1 en la grupa), sin tocar patas ni panza.
def mancha(cx, cy, cz, rx, ry, rz, fase):
    d = np.sqrt(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 + ((z - cz) / rz) ** 2)
    borde = 1 + 0.10 * np.sin(5 * np.arctan2(y - cy, z - cz) + fase)
    return d < borde

lomo = cuerpo & (y > -0.45) & (N[:, 1] > -0.35)
m1 = mancha(0.32, 0.02, 0.12, 0.42, 0.42, 0.34, 0.0)   # costado derecho, detrás del hombro
m2 = mancha(-0.32, -0.02, -0.18, 0.42, 0.42, 0.40, 1.7)  # costado izquierdo, cadera
m3 = mancha(0.02, 0.05, -0.55, 0.36, 0.36, 0.30, 3.1)   # grupa, bajo la cola
manchas = lomo & (m1 | m2 | m3)
col[manchas] = ATIG
r_c = np.sin(z * 24 + 2.5 * np.sin(y * 5)) > 0.45
col[manchas & r_c] = RAYA

# Cola oscura con anillos
base = np.array([0.0, 0.1, -0.5])
dcol = np.linalg.norm(V - base, axis=1)
col[cola] = COLA
col[cola & (np.sin(dcol * 22) > 0.35)] = COLA_R

col = suavizar(col, it=2)

# --- cara: ojos, nariz y boca proyectados desde la imagen de entrada (gemini b) ---
# La forma salió de esa imagen, así que sus rasgos calzan con los relieves esculpidos.
# La cámara (giro, escala, desplazamiento) se ajustó igualando siluetas (felipe_prm.json).
import json, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import proyeccion as pr
from mascara_felipe import rasgos_felipe
prm = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "felipe_prm.json")))
img, w_img = rasgos_felipe()
H, W = w_img.shape
vis, q = pr.visibles(V, F, N, prm, W, H, umbral_normal=0.4)
vis &= (z > 0.5) & (y > -0.3) & (y < 0.35)
w = pr.muestrear(w_img, q)[:, 0] * vis
c_img = pr.muestrear(img, q)
col = col * (1 - w[:, None]) + c_img * w[:, None]
# El ojo lejano (izquierdo del gato) no se ve entero en la imagen 3/4: su borde
# exterior se completa con la proyección espejada del ojo cercano.
X0 = 0.005  # eje de simetría de la cara
Vm = V * [-1, 1, 1] + [2 * X0, 0, 0]
Nm = N * [-1, 1, 1]
vis_m, q_m = pr.visibles(Vm, F, Nm, prm, W, H, umbral_normal=0.4)
lejano = np.hypot(V[:, 0] - 0.235, (V[:, 1] - 0.085) * 1.3) < 0.15
w_m = pr.muestrear(w_img, q_m)[:, 0] * vis_m * lejano * (z > 0.5)
exterior = np.clip((V[:, 0] - 0.245) / 0.03, 0, 1)
a = w_m * np.clip((0.4 - w) / 0.4, 0, 1) * exterior
col = col * (1 - a[:, None]) + pr.muestrear(img, q_m) * a[:, None]

rgba = np.c_[np.clip(col, 0, 255), np.full(nv, 255)].astype(np.uint8)
out = trimesh.Trimesh(V, F, vertex_colors=rgba, process=False)
out.export(OUT, include_normals=True)
print("ok", nv, len(F), OUT)
