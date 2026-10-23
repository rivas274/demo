# Paso 3b (v7): la cola como un tubo articulado aparte.
# Pedido del creador (2026-10-23): «cuando se agachó para jugar y se sentó, la cola se deformó
# horrible». La cola venía pegada a la malla del cuerpo, con pesos de calor que se mezclaban con
# la grupa. La receta estándar de colas de personaje es otra:
# - una malla de tubo aparte a lo largo de la línea central, con anillos regulares;
# - la base metida en la grupa, sin costura a la vista;
# - pesos suaves de a 2 huesos por anillo;
# - UV continuo a lo largo del tubo.
# Corre después de 03_rig.py y sobre su archivo (03_rig.blend). No toca el resto del cuerpo:
# solo borra las caras de la cola vieja, tapa el agujero y pasa a "spine" los restos de peso
# de la cola que quedaban en la grupa.
import sys, os, math, json, bpy, bmesh, mathutils
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
from scipy.sparse import coo_matrix
from scipy.sparse.csgraph import dijkstra
from scipy.spatial import cKDTree
from skimage.morphology import skeletonize
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

V = mathutils.Vector
COLA = ["tail.%03d" % i for i in range(1, 6)]
ANILLOS = int(os.environ.get("FELIPE_COLA_ANILLOS", "20"))   # anillos a lo largo (sin la punta)
LADOS = int(os.environ.get("FELIPE_COLA_LADOS", "14"))
PUNTA = 3                                                   # anillos de la punta redonda
ADENTRO = float(os.environ.get("FELIPE_COLA_ADENTRO", "0.08"))  # la base entra en la grupa (u)
R_BASE = float(os.environ.get("FELIPE_COLA_RBASE", "0.13"))     # radio en la base (angosta)
ENGORDA = float(os.environ.get("FELIPE_COLA_ENGORDA", "1.15"))   # factor sobre el radio de perfil medido
SUAVE = float(os.environ.get("FELIPE_COLA_SUAVE", "48"))         # suavizado de la línea (x 0,005 u)
PLIEGUE_IN = float(os.environ.get("FELIPE_COLA_ADENTRO_CURVA", "0.8"))  # radio de adentro / radio de curvatura
RES = 400.0                                                     # px por unidad en la silueta

bpy.ops.wm.open_mainfile(filepath=C.BLEND_RIG)
m = bpy.data.objects["Felipe"]
arm = bpy.data.objects["FelipeRig"]
me = m.data
if m.get("cola_v7"):
    raise SystemExit("03b_cola.py ya corrió sobre 03_rig.blend: corre antes 03_rig.py")
# El alto del modelo (con la cola vieja) fija la escala a metros en anima_base.preparar(): se
# guarda aquí para que la cola nueva no cambie el tamaño de Felipe.
m["alto_u"] = max((m.matrix_world @ v.co).z for v in me.vertices)

nombre = {g.index: g.name for g in m.vertex_groups}
co = np.array([v.co[:] for v in me.vertices])
wt = np.zeros(len(co))
for v in me.vertices:
    for g in v.groups:
        if nombre[g.group] in COLA:
            wt[v.index] += g.weight

# --- 1. Línea central y radios: eje medio (esqueleto) de la silueta de perfil de la cola vieja.
cara_cola = np.array([wt[list(p.vertices)].mean() >= 0.5 for p in me.polygons])
tv = co[wt >= 0.5]
y0, z0 = tv[:, 1].min() - 0.05, tv[:, 2].min() - 0.05
W = int((tv[:, 1].max() + 0.05 - y0) * RES) + 1
H = int((tv[:, 2].max() + 0.05 - z0) * RES) + 1
img = Image.new("L", (W, H), 0)
d = ImageDraw.Draw(img)
for p, es in zip(me.polygons, cara_cola):
    if es:
        d.polygon([((co[i, 1] - y0) * RES, (co[i, 2] - z0) * RES) for i in p.vertices], fill=255)
sil = ndimage.binary_fill_holes(ndimage.binary_closing(np.array(img) > 0, iterations=2))
dist = ndimage.distance_transform_edt(sil) / RES
esq = skeletonize(sil)
ys, xs = np.nonzero(esq)
idx = -np.ones(esq.shape, int)
idx[ys, xs] = np.arange(len(xs))
fil, col_, peso = [], [], []
for dy in (-1, 0, 1):
    for dx in (-1, 0, 1):
        if dy == 0 and dx == 0:
            continue
        yy, xx = ys + dy, xs + dx
        ok = (yy >= 0) & (yy < H) & (xx >= 0) & (xx < W)
        j = np.full(len(xs), -1)
        j[ok] = idx[yy[ok], xx[ok]]
        k = j >= 0
        fil += list(np.nonzero(k)[0]); col_ += list(j[k]); peso += [math.hypot(dx, dy)] * int(k.sum())
grafo = coo_matrix((peso, (fil, col_)), shape=(len(xs), len(xs))).tocsr()
vecinos = np.diff(grafo.indptr)
h0 = arm.data.bones[COLA[0]].head_local
t5 = arm.data.bones[COLA[-1]].tail_local
def mas_cerca(y, z, cand):
    py_, px_ = (z - z0) * RES, (y - y0) * RES
    return cand[np.argmin((xs[cand] - px_) ** 2 + (ys[cand] - py_) ** 2)]
todos = np.arange(len(xs))
ini = mas_cerca(h0.y, h0.z, todos)
puntas = todos[vecinos == 1]
fin = mas_cerca(t5.y, t5.z, puntas)
dd, pred = dijkstra(grafo, indices=ini, return_predecessors=True)
camino = [fin]
while camino[-1] != ini:
    camino.append(pred[camino[-1]])
camino = camino[::-1]
pts = np.array([((xs[i] / RES) + y0, (ys[i] / RES) + z0) for i in camino])   # (y, z)
rad = np.array([dist[ys[i], xs[i]] for i in camino])
# Remuestreo cada 0,005 u y suavizado (el esqueleto en píxeles es dentado).
s_px = np.r_[0, np.cumsum(np.linalg.norm(np.diff(pts, axis=0), axis=1))]
s_nuevo = np.arange(0, s_px[-1], 0.005)
pts = np.stack([np.interp(s_nuevo, s_px, pts[:, 0]), np.interp(s_nuevo, s_px, pts[:, 1])], 1)
rad = np.interp(s_nuevo, s_px, rad)
# Los extremos del esqueleto se doblan (en la unión con la grupa y hacia la esquina de la pluma):
# se descartan RECORTE u al inicio y RECORTE_PUNTA u al final. La base se rehace recta desde la
# cabeza de tail.001 (donde nace la cola) y sigue ADENTRO u más dentro de la grupa, en la
# dirección del hueso; después se suaviza todo junto (tangente continua).
RECORTE, RECORTE_PUNTA = 0.15, float(os.environ.get("FELIPE_COLA_RECORTE_PUNTA", "0.10"))
pts = pts[int(RECORTE / 0.005):len(pts) - int(RECORTE_PUNTA / 0.005)]
rad = rad[int(RECORTE / 0.005):len(rad) - int(RECORTE_PUNTA / 0.005)]
p0 = np.array([h0.y, h0.z])
dir0 = pts[0] - p0
largo0 = np.linalg.norm(dir0)
dir0 /= largo0
recta = [p0 + dir0 * a for a in np.arange(-ADENTRO, largo0, 0.005)]
pts = np.vstack([recta, pts])
rad = np.r_[np.full(len(recta), rad[0]), rad]
n_ext = 3 * int(SUAVE)
pts_ext = np.vstack([pts[0] - (pts[1] - pts[0]) * np.arange(n_ext, 0, -1)[:, None], pts,
                     pts[-1] + (pts[-1] - pts[-2]) * np.arange(1, n_ext + 1)[:, None]])
pts = ndimage.gaussian_filter1d(pts_ext, SUAVE, axis=0, mode="nearest")[n_ext:-n_ext]
rad = ndimage.gaussian_filter1d(rad, 10, mode="nearest")
s = np.r_[0, np.cumsum(np.linalg.norm(np.diff(pts, axis=0), axis=1))]
s -= s[np.argmin(np.linalg.norm(pts - p0, axis=1))]
ADENTRO = -s[0]
S_FIN = s[-1]
# Sección elíptica, como la cola vieja: de perfil (r_n) el medio grosor de la silueta; de lado
# (r_x) lo que mide la cola vieja en X, por tramos a lo largo de la línea nueva.
_, cerca = cKDTree(pts).query(tv[:, 1:3])
s_v = s[cerca]
r_x = np.zeros(len(s))
for i in range(len(s)):
    k = np.abs(s_v - s[i]) < 0.04
    r_x[i] = np.percentile(np.abs(tv[k, 0]), 95) if k.sum() > 8 else np.nan
ok = ~np.isnan(r_x)
r_x = np.interp(s, s[ok], r_x[ok])
crece = np.clip(s / 0.25, 0, 1)
crece = crece * crece * (3 - 2 * crece)
def perfil_radio(r_med, engorda=1.0):
    r_med = r_med * engorda
    r = R_BASE * (1 - crece) + np.maximum(r_med, R_BASE) * crece
    return ndimage.gaussian_filter1d(r, 6, mode="nearest")
# El eje medio no queda justo al centro (la cola es curva), así que la distancia al borde mide
# menos que el medio ancho: ENGORDA lo compensa (1,15 deja el área de perfil en el 97 % de la cola vieja).
radio_n, radio_x = perfil_radio(rad, ENGORDA), perfil_radio(r_x)
# Curvatura: donde la curva dobla más cerrado que el grosor, el lado de adentro se plegaba.
d1 = np.gradient(pts, s, axis=0); d2 = np.gradient(d1, s, axis=0)
kappa = np.abs(d1[:, 0] * d2[:, 1] - d1[:, 1] * d2[:, 0]) / np.maximum(1e-9, np.linalg.norm(d1, axis=1) ** 3)
print("radio de curvatura mínimo %.3f (en s=%.3f), grosor de perfil ahí %.3f" % (1 / kappa.max(), s[np.argmax(kappa)], radio_n[np.argmax(kappa)]))
# Solo el lado de adentro de la curva se achica (como lo haría un modelador); el de afuera
# conserva el volumen de la pluma.
signo = np.sign(d1[:, 0] * d2[:, 1] - d1[:, 1] * d2[:, 0])
radio_in = ndimage.gaussian_filter1d(np.minimum(radio_n, PLIEGUE_IN / np.maximum(kappa, 1e-6)), 4, mode="nearest")
print("cola: largo %.3f u; radio de perfil base %.3f, máx %.3f, punta %.3f; de lado base %.3f, máx %.3f" % (
    S_FIN, np.interp(0, s, radio_n), radio_n.max(), radio_n[-1], np.interp(0, s, radio_x), radio_x.max()))
if os.environ.get("FELIPE_DEPURA"):
    dep = Image.fromarray((sil * 90).astype(np.uint8)).convert("RGB")
    dd_ = ImageDraw.Draw(dep)
    dd_.point([(xs[i], ys[i]) for i in camino], fill=(0, 255, 0))
    dd_.line([((p[0] - y0) * RES, (p[1] - z0) * RES) for p in pts], fill=(255, 0, 0), width=2)
    for i in range(0, len(pts), 12):
        t = d1[i] / np.linalg.norm(d1[i]); nn = np.array([-t[1], t[0]])
        a_ = pts[i] + nn * radio_n[i]; b_ = pts[i] - nn * radio_n[i]
        dd_.line([((a_[0] - y0) * RES, (a_[1] - z0) * RES), ((b_[0] - y0) * RES, (b_[1] - z0) * RES)], fill=(80, 160, 255))
    dep.transpose(Image.FLIP_TOP_BOTTOM).save(os.environ["FELIPE_DEPURA"])


def en(sv):
    """Punto (y, z), tangente y radio de la línea central en el largo sv (extrapola en la punta)."""
    if sv <= S_FIN:
        y = np.interp(sv, s, pts[:, 0]); z = np.interp(sv, s, pts[:, 1])
        k = min(np.searchsorted(s, sv), len(s) - 2)
        k = max(k, 1)
        t = pts[k + 1] - pts[k - 1]
        ki = int(np.clip(np.searchsorted(s, sv), 0, len(s) - 1))
        return np.array([y, z]), t / np.linalg.norm(t), (float(np.interp(sv, s, radio_n)), float(np.interp(sv, s, radio_x)),
                                                          float(np.interp(sv, s, radio_in)), float(signo[ki]))
    p, t, r = en(S_FIN)
    return p + t * (sv - S_FIN), t, r


# --- 2. Huesos de la cola sobre la línea central nueva (mismas proporciones que antes).
largos = np.array([arm.data.bones[b].length for b in COLA])
R_PUNTA = float(radio_n[-1])
RX_PUNTA = float(radio_x[-1])
RIN_PUNTA = float(radio_in[-1])
S_HUESOS = S_FIN + 0.5 * R_PUNTA
juntas = np.r_[0, np.cumsum(largos) / largos.sum() * S_HUESOS]
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="EDIT")
eb = arm.data.edit_bones
for b in eb:
    b.select = False
for i, b in enumerate(COLA):
    e = eb[b]
    ph, _, _ = en(juntas[i]); pt, _, _ = en(juntas[i + 1])
    e.head = V((0.0, ph[0], ph[1])); e.tail = V((0.0, pt[0], pt[1]))
    e.select = True
bpy.ops.armature.calculate_roll(type="GLOBAL_POS_X")
bpy.ops.object.mode_set(mode="OBJECT")
print("juntas de la cola (largo u):", np.round(juntas, 3))

# --- 3. Borrar la cola vieja del cuerpo, tapar el agujero y quitar los pesos de cola que
# quedaban en la grupa (pasan a "spine": la grupa ya no se mueve con la cola).
bm = bmesh.new()
bm.from_mesh(me)
capa_aro = bm.verts.layers.int.new("aro")      # (agregar capas también invalida referencias)
capa_tapa = bm.faces.layers.int.new("tapa")
bm.verts.ensure_lookup_table(); bm.faces.ensure_lookup_table()
borrar = [f for f in bm.faces if cara_cola[f.index]]
bmesh.ops.delete(bm, geom=borrar, context="FACES_ONLY")
sueltos = [v for v in bm.verts if not v.link_faces]
bmesh.ops.delete(bm, geom=sueltos, context="VERTS")
borde = [e for e in bm.edges if e.is_boundary]
aro = set(v for e in borde for v in e.verts)
# Tapa en domo: se llena el agujero, se subdivide, se relaja con el borde fijo (membrana) y se
# infla un poco hacia afuera, como sigue la grupa. Queda casi toda bajo la base del tubo.
n_aro = V((0, 0, 0))
for e in borde:
    for f in e.link_faces:
        n_aro += f.normal
n_aro.normalize()
# (subdivide_edges invalida las referencias de Python: el aro y la tapa se marcan en capas.)
for v in aro:
    v[capa_aro] = 1
nuevas = bmesh.ops.holes_fill(bm, edges=borde, sides=0)["faces"]
pk = bmesh.ops.poke(bm, faces=nuevas)
for f in pk["faces"]:
    f[capa_tapa] = 1
aristas = list(set(e for f in pk["faces"] for e in f.edges if not (e.verts[0][capa_aro] and e.verts[1][capa_aro])))
bmesh.ops.subdivide_edges(bm, edges=aristas, cuts=2, use_grid_fill=True)
tapa = set(f for f in bm.faces if f[capa_tapa])
aro = set(v for v in bm.verts if v[capa_aro])
interior = set(v for f in tapa for v in f.verts) - aro
c_aro = sum((v.co for v in aro), V()) / len(aro)
r_aro = max((v.co - c_aro).length for v in aro)
for _ in range(40):
    nuevo = {v: sum((e.other_vert(v).co for e in v.link_edges), V()) / len(v.link_edges) for v in interior}
    for v, c in nuevo.items():
        v.co = c
for v in interior:
    d = (v.co - c_aro).length / r_aro
    v.co += n_aro * (0.25 * r_aro * max(0.0, 1 - d * d))
bmesh.ops.triangulate(bm, faces=[f for f in tapa if len(f.verts) > 4])
bm.faces.index_update(); bm.verts.index_update()
tapa_idx = [f.index for f in bm.faces if f[capa_tapa]]
tapa_vs = sorted(set(v.index for f in bm.faces if f[capa_tapa] for v in f.verts if not v[capa_aro]))
print("cola vieja: %d caras borradas, %d bordes, tapa de %d caras (radio %.3f)" % (len(borrar), len(borde), len(tapa_idx), r_aro))
bm.to_mesh(me)
bm.free()
me.update()
grupos = {g.name: g for g in m.vertex_groups}
nombre = {g.index: g.name for g in m.vertex_groups}
movidos = 0
for v in me.vertices:
    extra = 0.0
    for g in list(v.groups):
        if nombre[g.group] in COLA:
            extra += g.weight
    if extra > 0:
        for b in COLA:
            grupos[b].remove([v.index])
        grupos["spine"].add([v.index], extra, "ADD")
        movidos += 1
for b in [g.name for g in m.vertex_groups]:
    grupos[b].remove(tapa_vs)
grupos["spine"].add(tapa_vs, 1.0, "REPLACE")
print("vértices de la grupa sin peso de cola:", movidos)
n_cuerpo = len(me.vertices)

# --- 4. El tubo: anillos de LADOS lados a lo largo y punta redonda (hemisferio); la base se
# cierra adentro de la grupa.
X = np.array([1.0, 0.0, 0.0])
anillos = []   # (largo, centro 3D, normal 3D, radio)
for sv in np.linspace(-ADENTRO, S_FIN, ANILLOS):
    p, t, r = en(sv)
    anillos.append((sv, p, t, r))
for k in range(1, PUNTA + 1):
    th = k / (PUNTA + 1) * math.pi / 2
    sv = S_FIN + R_PUNTA * math.sin(th)
    p, t, _ = en(sv)
    c_ = math.cos(th)
    anillos.append((sv, p, t, (R_PUNTA * c_, RX_PUNTA * c_, min(R_PUNTA, RIN_PUNTA) * c_, 0.0)))
S_POLO = S_FIN + R_PUNTA
verts, uvs_s = [], []
for sv, p, t, r in anillos:
    T = np.array([0.0, t[0], t[1]])
    N = np.cross(X, T)
    c = np.array([0.0, p[0], p[1]])
    for k in range(LADOS):
        a = 2 * math.pi * k / LADOS
        rn = r[2] if math.sin(a) * r[3] > 0 else r[0]   # lado de adentro de la curva: más chico
        verts.append(c + r[1] * math.cos(a) * X + rn * math.sin(a) * N)
p_fin, t_fin, _ = en(S_POLO)
p_ini, t_ini, _ = en(-ADENTRO)
verts.append(np.array([0.0, p_fin[0], p_fin[1]]))
verts.append(np.array([0.0, p_ini[0], p_ini[1]]) - np.array([0.0, t_ini[0], t_ini[1]]) * 0.02)
NA = len(anillos)
POLO, BASE = NA * LADOS, NA * LADOS + 1
# Medida de pliegue: cada arista a lo largo, proyectada en la tangente, sobre el paso medio. Si
# baja de ~0,3 los anillos se juntan del lado de adentro de la curva (se ve un pliegue).
_vv = np.array(verts[:NA * LADOS]).reshape(NA, LADOS, 3)
_tt = np.array([[0.0, a_[2][0], a_[2][1]] for a_ in anillos])
_paso = np.einsum("ikc,ic->ik", _vv[1:] - _vv[:-1], _tt[:-1])
_medio = np.linalg.norm(_tt[:-1] * 0 + (_vv[1:].mean(1) - _vv[:-1].mean(1)), axis=1)
PLIEGUE_MIN = float((_paso / _medio[:, None]).min())
print("pliegue: paso mínimo del lado de adentro / paso medio = %.2f" % PLIEGUE_MIN)

# Lugar del tubo en el atlas: el rectángulo libre más grande del UV del cuerpo (con margen).
N_UV = 1024
ocupado = Image.new("L", (N_UV, N_UV), 0)
dd_ = ImageDraw.Draw(ocupado)
uvl = me.uv_layers.active.data
for p in me.polygons:
    dd_.polygon([(uvl[l].uv[0] * N_UV, (1 - uvl[l].uv[1]) * N_UV) for l in p.loop_indices], fill=255)
libre = ~ndimage.binary_dilation(np.array(ocupado) > 0, iterations=6)
alto = np.zeros(N_UV, int)
mejor = (0, None)
for yy in range(N_UV):
    alto = np.where(libre[yy], alto + 1, 0)
    pila = []
    for xx in range(N_UV + 1):
        hh = alto[xx] if xx < N_UV else 0
        ini_ = xx
        while pila and pila[-1][1] >= hh:
            ini_, ph = pila.pop()
            if ph * (xx - ini_) > mejor[0]:
                mejor = (ph * (xx - ini_), (ini_, yy - ph + 1, xx - ini_, ph))
        pila.append((ini_, hh))
rx, ry, rw, rh = mejor[1]
print("rectángulo del tubo en el atlas (px de 1024):", mejor[1])
MARGEN = 4
u0, u1 = (rx + MARGEN) / N_UV, (rx + rw - MARGEN) / N_UV          # a lo largo (s)
v0, v1 = 1 - (ry + rh - MARGEN) / N_UV, 1 - (ry + MARGEN) / N_UV  # alrededor
def uv_de(sv, k):
    return ((u0 + (sv + ADENTRO) / (S_POLO + ADENTRO) * (u1 - u0)), v0 + k / LADOS * (v1 - v0))

bm = bmesh.new()
bv = [bm.verts.new(V(p)) for p in verts]
bm.verts.ensure_lookup_table()
uv_capa = bm.loops.layers.uv.new("UVMap")
caras = []
for i in range(NA - 1):
    for k in range(LADOS):
        k2 = (k + 1) % LADOS
        f = bm.faces.new((bv[i * LADOS + k], bv[i * LADOS + k2], bv[(i + 1) * LADOS + k2], bv[(i + 1) * LADOS + k]))
        uvq = (uv_de(anillos[i][0], k), uv_de(anillos[i][0], k + 1), uv_de(anillos[i + 1][0], k + 1), uv_de(anillos[i + 1][0], k))
        for l, u in zip(f.loops, uvq):
            l[uv_capa].uv = u
        caras.append(f)
for k in range(LADOS):
    k2 = (k + 1) % LADOS
    i = NA - 1
    f = bm.faces.new((bv[i * LADOS + k], bv[i * LADOS + k2], bv[POLO]))
    for l, u in zip(f.loops, (uv_de(anillos[i][0], k), uv_de(anillos[i][0], k + 1), uv_de(S_POLO, k + 0.5))):
        l[uv_capa].uv = u
    f = bm.faces.new((bv[k2], bv[k], bv[BASE]))
    for l, u in zip(f.loops, (uv_de(-ADENTRO, k + 1), uv_de(-ADENTRO, k), uv_de(-ADENTRO, k + 0.5))):
        l[uv_capa].uv = u
bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
for f in bm.faces:
    f.smooth = True
tubo_me = bpy.data.meshes.new("ColaTubo")
bm.to_mesh(tubo_me)
bm.free()
tubo = bpy.data.objects.new("ColaTubo", tubo_me)
bpy.context.scene.collection.objects.link(tubo)
tubo.matrix_world = m.matrix_world.copy()
tubo.data.materials.append(me.materials[0])

# Pesos: de a 2 huesos por anillo, con mezcla suave (smoothstep) alrededor de cada junta. La
# parte metida en la grupa pasa de "spine" a tail.001: la base queda anclada al cuerpo.
def pesos_en(sv):
    if sv <= 0:
        t = min(1.0, max(0.0, (sv + ADENTRO) / ADENTRO))
        t = t * t * (3 - 2 * t)
        return {"spine": 1 - t, COLA[0]: t}
    for j in range(1, len(COLA)):
        h = 0.45 * min(largos[j - 1], largos[j]) / largos.sum() * S_HUESOS
        if abs(sv - juntas[j]) < h:
            t = (sv - juntas[j] + h) / (2 * h)
            t = t * t * (3 - 2 * t)
            return {COLA[j - 1]: 1 - t, COLA[j]: t}
    j = int(np.clip(np.searchsorted(juntas, sv) - 1, 0, len(COLA) - 1))
    return {COLA[j]: 1.0}
for g in ["spine"] + COLA:
    tubo.vertex_groups.new(name=g)
tg = {g.name: g for g in tubo.vertex_groups}
for i, (sv, _, _, _) in enumerate(anillos):
    for b, w in pesos_en(sv).items():
        if w > 1e-4:
            tg[b].add(list(range(i * LADOS, (i + 1) * LADOS)), w, "REPLACE")
tg[COLA[-1]].add([POLO], 1.0, "REPLACE")
tg["spine"].add([BASE], 1.0, "REPLACE")

# Unir el tubo a la malla de Felipe (un solo objeto, un solo material y una sola textura).
bpy.ops.object.select_all(action="DESELECT")
tubo.select_set(True)
m.select_set(True)
bpy.context.view_layer.objects.active = m
bpy.ops.object.join()
m["cola_v7"] = True
m["cola_desde"] = n_cuerpo
print("tubo: %d anillos x %d lados, %d vértices (desde el %d)" % (NA, LADOS, len(verts), n_cuerpo))

# La tapa del agujero toma el color de la base de la cola (no se ve: queda bajo el tubo).
uvl = me.uv_layers.active.data
ub, vb = uv_de(-ADENTRO, LADOS / 2)
for fi in tapa_idx:
    for l in me.polygons[fi].loop_indices:
        uvl[l].uv = (ub, vb)

# --- 5. Pintar el tubo en su rectángulo: el tono de la gorra con anillos atigrados, más oscuro
# hacia la punta; la base nace del color del lomo (sin mancha ni anillo blanco).
col = json.load(open(os.path.join(C.TRABAJO, "colores_lomo.json")))
gris, raya = np.array(col["gris"]), np.array(col["raya"])
RAYAS_COLA = col["rayas_cola"]
ruta = os.path.join(C.TRABAJO, "felipe_rig_color.png")
tex = np.array(Image.open(ruta).convert("RGB")).astype(np.float32) / 255
NT = tex.shape[0]
X0, X1 = int(rx * NT / N_UV), int((rx + rw) * NT / N_UV)
Y0_, Y1_ = int(ry * NT / N_UV), int((ry + rh) * NT / N_UV)
xx = (np.arange(X0, X1) + 0.5) / NT
sv = (np.clip((xx - u0) / (u1 - u0), 0, 1)) * (S_POLO + ADENTRO) - ADENTRO
sc = np.clip(sv / S_FIN, 0, 1)
osc = 0.92 - 0.18 * sc
an = 0.5 + 0.5 * np.cos(2 * math.pi * sc * RAYAS_COLA)
an = 0.8 * np.clip((an - 0.74) / 0.10, 0, 1) * np.clip(sc / 0.08, 0, 1)
fila = (gris[None, :] * (1 - an[:, None]) + raya[None, :] * an[:, None]) * osc[:, None]
tex[Y0_:Y1_, X0:X1] = fila[None, :, :]
Image.fromarray((np.clip(tex, 0, 1) * 255).astype(np.uint8)).save(ruta)
im = bpy.data.images.get("felipe_rig_color")
im.filepath = ruta
im.reload()
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_RIG)
print("guardado", C.BLEND_RIG)
