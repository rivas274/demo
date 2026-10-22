"""Pinta anillos atigrados en la cola de un GLB texturizado (Meshy), sin regenerar nada.

Uso: python pintar_cola.py <entrada.glb> <salida.glb> [anillos=6] [umbral_oscuro=70]

1. Toma el color de la textura en cada cara; la cola es el componente conectado más grande de caras oscuras
   (las caras se conectan por posición, no por índice, porque el GLB duplica vértices en las costuras UV).
2. Distancia geodésica desde la base de la cola (borde con el cuerpo) hasta la punta.
3. En los texels de la cola: color base y rayas del atigrado del resto del modelo, por bandas de esa distancia;
   se conserva el sombreado de la textura original (luminancia relativa). La punta queda oscura.
"""
import sys

import numpy as np
import trimesh
from PIL import Image
from scipy import ndimage
from scipy.sparse import coo_matrix
from scipy.sparse.csgraph import connected_components, dijkstra

entrada, salida = sys.argv[1], sys.argv[2]
ANILLOS = int(sys.argv[3]) if len(sys.argv) > 3 else 6
UMBRAL = float(sys.argv[4]) if len(sys.argv) > 4 else 70

escena = trimesh.load(entrada, force="scene")
nombre, malla = next(iter(escena.geometry.items()))
material = malla.visual.material
tex = np.asarray(material.baseColorTexture.convert("RGB")).astype(float)
alto_t, ancho_t = tex.shape[:2]
uv = malla.visual.uv
v, f = malla.vertices, malla.faces


def lum(c):
    return c @ np.array([0.299, 0.587, 0.114])


# Color por vértice (muestreo de la textura; trimesh deja v con origen abajo).
px = np.clip((uv[:, 0] * (ancho_t - 1)).round().astype(int), 0, ancho_t - 1)
py = np.clip(((1 - uv[:, 1]) * (alto_t - 1)).round().astype(int), 0, alto_t - 1)
col_v = tex[py, px]
lum_f = lum(col_v[f]).mean(1)

# Vértices fusionados por posición.
_, unico, inv = np.unique(v.round(5), axis=0, return_index=True, return_inverse=True)
inv = inv.ravel()
fu = inv[f]
nv = len(unico)

oscuras = np.where(lum_f < UMBRAL)[0]
# Componentes de caras oscuras: grafo vértice-cara restringido a las oscuras.
filas = np.repeat(np.arange(len(oscuras)), 3)
cols = fu[oscuras].ravel()
inc = coo_matrix((np.ones_like(filas), (filas, cols)), shape=(len(oscuras), nv)).tocsr()
adj = (inc @ inc.T).tocoo()
n, etiqueta = connected_components(adj, directed=False)
tam = np.bincount(etiqueta)
cola = oscuras[etiqueta == tam.argmax()]
print("caras oscuras:", len(oscuras), "componentes:", n, "cola:", len(cola),
      "centro cola:", v[f[cola]].reshape(-1, 3).mean(0).round(3), "caja malla:", malla.bounds.round(3).tolist())

es_cola = np.zeros(len(f), bool)
es_cola[cola] = True
v_cola = np.unique(fu[cola])
v_resto = np.unique(fu[~es_cola])
base = np.intersect1d(v_cola, v_resto)
print("vértices cola:", len(v_cola), "base:", len(base))

# Geodésica dentro de la cola.
pos = v[unico]
aristas = np.concatenate([fu[cola][:, [0, 1]], fu[cola][:, [1, 2]], fu[cola][:, [2, 0]]])
largo = np.linalg.norm(pos[aristas[:, 0]] - pos[aristas[:, 1]], axis=1)
g = coo_matrix((largo, (aristas[:, 0], aristas[:, 1])), shape=(nv, nv)).tocsr()
# Punta: el vértice de la cola más lejano del centro del cuerpo. La "base" por borde no sirve: las manchas
# claras dentro de la cola también son borde.
punta = v_cola[np.linalg.norm(pos[v_cola] - malla.centroid, axis=1).argmax()]
desde_punta = dijkstra(g, directed=False, indices=punta)
ok = v_cola[np.isfinite(desde_punta[v_cola])]
# Línea central: centroides por tramos de distancia geodésica desde la punta, suavizados. Los anillos se miden
# sobre esa línea (proyección de cada vértice), así quedan parejos aunque la superficie tenga mechones.
tramos = 30
d_ok = desde_punta[ok]
bordes = np.linspace(0, d_ok.max() + 1e-9, tramos + 1)
idx = np.digitize(d_ok, bordes) - 1
centro = np.array([pos[ok][idx == k].mean(0) for k in range(tramos) if (idx == k).any()])
centro = ndimage.uniform_filter1d(centro, size=3, axis=0, mode="nearest")
seg_a, seg_b = centro[:-1], centro[1:]
seg_l = np.linalg.norm(seg_b - seg_a, axis=1)
s0 = np.concatenate([[0], np.cumsum(seg_l)])
dirs = (seg_b - seg_a) / seg_l[:, None]


def proyectar(puntos):
    """Posición a lo largo de la línea central (0 base, 1 punta) y distancia a ella."""
    p = puntos[:, None, :]
    lam = np.clip(((p - seg_a) * dirs).sum(-1), 0, seg_l)
    d2 = np.linalg.norm(p - (seg_a + lam[..., None] * dirs), axis=-1)
    k = d2.argmin(1)
    s = s0[k] + lam[np.arange(len(puntos)), k]
    return 1 - s / s0[-1], d2.min(1)


t_ok, r_ok = proyectar(pos[ok])
# Caras algo menos oscuras pegadas a la cola (mechones, motas negras sueltas): entran si quedan dentro del radio
# de la cola alrededor de la línea central.
r_max = np.percentile(r_ok, 95)
cand = np.where(~es_cola & (lum_f < 75))[0]
t_c, r_c = proyectar(pos[fu[cand]].mean(1))
# Lejos de la base: ahí la cola toca las manchas del lomo, que no se tocan.
extra = cand[(r_c < r_max) & (t_c > 0.2)]
cola = np.concatenate([cola, extra])
v_todos = np.unique(fu[cola])
t_u = np.zeros(nv)
t_u[v_todos], _ = proyectar(pos[v_todos])
t_v = t_u[inv]  # por vértice original
print("largo de la línea central:", round(s0[-1], 3), "caras extra:", len(extra))

# Paleta del atigrado del resto del modelo: tonos grises sin mucho color.
resto = tex.reshape(-1, 3)
l_resto = lum(resto)
sat = resto.max(1) - resto.min(1)
medio = resto[(l_resto > 95) & (l_resto < 160) & (sat < 30)]
oscuro = resto[(l_resto > 45) & (l_resto < 90) & (sat < 30)]
c_base = np.median(medio, 0)
c_raya = np.median(oscuro, 0) * 0.85  # un poco más oscuro: en la cola, con sombra, se perdía
print("color base:", c_base.round(), "color raya:", c_raya.round())

# Rasterizar las caras de la cola en la textura: t interpolado y máscara.
uvp = np.stack([uv[:, 0] * (ancho_t - 1), (1 - uv[:, 1]) * (alto_t - 1)], 1)
t_tex = np.full((alto_t, ancho_t), np.nan)
for tri in f[cola]:
    a, b, c = uvp[tri]
    x0, y0 = np.floor(np.minimum(np.minimum(a, b), c)).astype(int)
    x1, y1 = np.ceil(np.maximum(np.maximum(a, b), c)).astype(int)
    gx, gy = np.meshgrid(np.arange(x0, x1 + 1), np.arange(y0, y1 + 1))
    pts = np.stack([gx.ravel(), gy.ravel()], 1).astype(float)
    m = np.array([b - a, c - a]).T
    if abs(np.linalg.det(m)) < 1e-12:
        continue
    l12 = np.linalg.solve(m, (pts - a).T).T
    l0 = 1 - l12.sum(1)
    dentro = (l0 >= -0.02) & (l12[:, 0] >= -0.02) & (l12[:, 1] >= -0.02)
    if not dentro.any():
        continue
    tt = np.stack([l0, l12[:, 0], l12[:, 1]], 1)[dentro] @ t_v[tri]
    xs = np.clip(gx.ravel()[dentro], 0, ancho_t - 1)
    ys = np.clip(gy.ravel()[dentro], 0, alto_t - 1)
    t_tex[ys, xs] = tt

mascara = ~np.isnan(t_tex)
# Dos texels más de borde para que no quede un filo negro en las costuras.
_, (by, bx) = ndimage.distance_transform_edt(~mascara, return_indices=True)
cerca = ndimage.binary_dilation(mascara, iterations=2)
t_tex = t_tex[by, bx]
ys, xs = np.where(cerca)
t = t_tex[ys, xs]
orig = tex[ys, xs]

# Anillos: la raya ocupa ~55 % de cada período, con bordes suaves; la punta (t > 0.88) va oscura.
fase = (t * ANILLOS) % 1.0
raya = np.clip(1.4 - np.abs(fase - 0.5) / 0.2, 0, 1)
raya = np.maximum(raya, np.clip((t - 0.86) / 0.06, 0, 1))
color = (1 - raya[:, None]) * c_base + raya[:, None] * c_raya
# Sombreado: luminancia relativa de la textura original dentro de la cola (suave).
l_o = lum(orig)
sombra = np.clip((l_o / (np.median(l_o) + 1e-6)) ** 0.5, 0.7, 1.25)
nuevo = tex.copy()
nuevo[ys, xs] = np.clip(color * sombra[:, None], 0, 255)

material.baseColorTexture = Image.fromarray(nuevo.astype(np.uint8))
escena.export(salida)
Image.fromarray(nuevo.astype(np.uint8)).save(salida.rsplit(".", 1)[0] + "_textura.png")
print("ok", salida, "texels pintados:", len(ys))
