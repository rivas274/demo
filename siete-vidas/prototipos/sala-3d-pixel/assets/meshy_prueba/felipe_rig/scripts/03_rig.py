# Paso 3 y 4: esqueleto (desde el metarig de gato de Rigify, recortado) ubicado con las
# marcas del creador, y pesos automáticos (calor) con limpieza por script.
import sys, os, math, bpy, mathutils
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

P = C.perfil
X = C.frente_x
V = mathutils.Vector

bpy.ops.wm.open_mainfile(filepath=C.BLEND_TEXTURA)
malla = bpy.data.objects["Retopo"]
malla.name = "Felipe"
orig = bpy.data.objects["Original"]
orig.hide_render = True
orig.hide_viewport = True

# --- Anchos (x) de las patas traseras medidos en la malla: centro de cada pata cerca del piso.
vs = np.array([v.co[:] for v in malla.data.vertices])
def x_pata(y0, y1, z1):
    sel = vs[(vs[:, 1] > y0) & (vs[:, 1] < y1) & (vs[:, 2] < z1) & (vs[:, 0] > 0.02)]
    return float(sel[:, 0].mean()), len(sel)
xt, nt_ = x_pata(P(470, 0)[1], P(370, 0)[1], 0.10)
xd, nd_ = x_pata(P(840, 0)[1], P(720, 0)[1], 0.10)
print("x pata trasera %.3f (%d vért.), delantera medida %.3f (%d) vs marca %.3f" % (xt, nt_, xd, nd_, -X(445)))

# --- Puntos de cada hueso (lado izquierdo, +X; el derecho es su espejo).
def pf(px, py, x=0.0):
    return V(P(px, py, x))

PUNTOS = {
    # Columna: grupa y pecho (las 2 masas del creador) por el centro del cuerpo.
    "spine": (pf(340, 632), pf(450, 642)),
    "spine.001": (pf(450, 642), pf(560, 646)),
    "spine.002": (pf(560, 646), pf(660, 636)),
    "spine.003": (pf(660, 636), pf(728, 592)),
    "spine.004": (pf(728, 592), pf(728, 522)),          # cuello
    "spine.006": (pf(728, 522), pf(736, 250)),          # cabeza
    "ear.L": (V((X(665), P(742, 0)[1], C.frente_z(285))), V((X(700), P(765, 0)[1], C.frente_z(185)))),
    # Cola en 5 (los 3 tramos del creador; el del medio y la punta en gancho, largos, van
    # en 2 cada uno): gruesa y esponjada, así se dobla en curva y no en codo.
    "tail.001": (pf(345, 560), pf(240, 485)),
    "tail.002": (pf(240, 485), pf(228, 405)),
    "tail.003": (pf(228, 405), pf(222, 305)),
    "tail.004": (pf(222, 305), pf(196, 243)),
    "tail.005": (pf(196, 243), pf(110, 195)),
    # Pata delantera: perfil (y, z) y frente (x).
    "shoulder.L": (pf(675, 600, 0.13), pf(690, 683, -X(378))),
    "upper_arm.L": (pf(690, 683, -X(378)), pf(745, 770, -X(380))),
    "forearm.L": (pf(745, 770, -X(380)), pf(745, 860, -X(445))),
    "hand.L": (pf(745, 860, -X(445)), pf(800, 868, -X(445))),
    "f_toe.L": (pf(800, 868, -X(445)), pf(832, 872, -X(445))),
    # Pata trasera: perfil del creador; x medida en la malla.
    "pelvis.L": (pf(400, 600, 0.06), pf(420, 625, xt + 0.05)),
    "thigh.L": (pf(420, 625, xt + 0.05), pf(470, 712, xt + 0.03)),
    "shin.L": (pf(470, 712, xt + 0.03), pf(385, 800, xt)),
    "foot.L": (pf(385, 800, xt), pf(430, 865, xt)),
    "r_toe.L": (pf(430, 865, xt), pf(468, 872, xt)),
}
PADRE = {
    "spine": "root", "spine.001": "spine", "spine.002": "spine.001", "spine.003": "spine.002",
    "spine.004": "spine.003", "spine.006": "spine.004", "ear.L": "spine.006",
    "tail.001": "spine", "tail.002": "tail.001", "tail.003": "tail.002", "tail.004": "tail.003",
    "tail.005": "tail.004",
    "shoulder.L": "spine.003", "upper_arm.L": "shoulder.L", "forearm.L": "upper_arm.L",
    "hand.L": "forearm.L", "f_toe.L": "hand.L",
    "pelvis.L": "spine", "thigh.L": "pelvis.L", "shin.L": "thigh.L", "foot.L": "shin.L", "r_toe.L": "foot.L",
}
CONECTADO = {"spine.001", "spine.002", "spine.003", "spine.004", "spine.006", "tail.002", "tail.003",
             "tail.004", "tail.005", "upper_arm.L", "forearm.L", "hand.L", "f_toe.L", "thigh.L", "shin.L",
             "foot.L", "r_toe.L"}


def espejo(n):
    return n[:-2] + ".R" if n.endswith(".L") else n


# --- Metarig de gato de Rigify, recortado a los huesos de arriba y reubicado.
import addon_utils
try:
    addon_utils.enable("rigify", default_set=True)
except Exception as e:
    print("rigify (aviso):", e)
bpy.ops.object.select_all(action="DESELECT")
bpy.ops.object.armature_cat_metarig_add()
arm = bpy.context.object
arm.name = "FelipeRig"
arm.data.name = "FelipeRig"
arm.location = (0, 0, 0)
bpy.ops.object.mode_set(mode="EDIT")
eb = arm.data.edit_bones
quedan = set(PUNTOS) | {espejo(n) for n in PUNTOS}
for b in list(eb):
    if b.name not in quedan:
        eb.remove(b)
root = eb.new("root")
root.head = (0, 0, 0); root.tail = (0, -0.25, 0)
for n, (h, t) in PUNTOS.items():
    for lado in (n, espejo(n)):
        b = eb.get(lado) or eb.new(lado)
        s = -1.0 if lado != n else 1.0
        b.head = V((h.x * s, h.y, h.z)); b.tail = V((t.x * s, t.y, t.z))
for n in PUNTOS:
    for lado in (n, espejo(n)):
        b = eb[lado]
        b.use_connect = False
        b.parent = eb[espejo(PADRE[n]) if lado != n else PADRE[n]]
        b.use_connect = n in CONECTADO
# Rol uniforme: el eje Z local de cada hueso apunta a +X del mundo. Las animaciones giran
# en ejes del mundo (05_anima.py, q_mundo), así que no dependen de esto.
for b in eb:
    b.select = True
bpy.ops.armature.calculate_roll(type="GLOBAL_POS_X")
bpy.ops.object.mode_set(mode="OBJECT")
for b in arm.data.bones:
    b.use_deform = b.name != "root"
print("huesos:", len(arm.data.bones), sorted(b.name for b in arm.data.bones))

# --- Pesos automáticos (calor).
bpy.ops.object.select_all(action="DESELECT")
malla.select_set(True)
arm.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.parent_set(type="ARMATURE_AUTO")
cuenta = {g.name: 0 for g in malla.vertex_groups}
for v in malla.data.vertices:
    for g in v.groups:
        if g.weight > 0.05:
            cuenta[malla.vertex_groups[g.group].name] += 1
print("vértices por hueso (peso > 0,05):", cuenta)
sin_peso = sum(1 for v in malla.data.vertices if sum(g.weight for g in v.groups) < 1e-4)
print("vértices sin ningún peso tras el calor:", sin_peso)

# Suavizado de todos los grupos.
bpy.ops.object.select_all(action="DESELECT")
bpy.context.view_layer.objects.active = malla
malla.select_set(True)
bpy.ops.object.mode_set(mode="WEIGHT_PAINT")
bpy.ops.object.vertex_group_smooth(group_select_mode="ALL", factor=0.5, repeat=3, expand=0.0)
bpy.ops.object.mode_set(mode="OBJECT")

# --- Limpieza por reglas (cabeza entera, orejas, patas sin cruzar de lado).
def mascara(nombre):
    return np.array(Image.open(os.path.join(C.PLANTILLA, "mascaras_%s.png" % nombre)))[..., 0]

mp, mf = mascara("perfil"), mascara("frente")
cabeza_m = ((mp >> 0) & 1).astype(bool)
# Por columna, el borde de abajo de la cabeza: la mezcla con el cuello se mide hacia abajo.
filas = np.arange(1024)[:, None]
fondo = np.where(cabeza_m.any(axis=0), np.where(cabeza_m, filas, -1).max(axis=0), -1)
oreja_f = (((mf >> 0) & 1) | ((mf >> 1) & 1)).astype(bool)


def a_px(co):
    px = 512 - co.y / C.PX
    py = 512 - (co.z - (C.CENTRO_ORIGINAL[2] - C.Z_PISO_ORIGINAL)) / C.PX
    fx = 512 + co.x / C.PX
    return int(round(px)), int(round(py)), int(round(fx))


# Alturas de la rampa de muslo y brazo: (z donde el peso ya es 0, z donde vuelve a ser entero).
RAMPA = {}
for lado in ("L", "R"):
    th, ua = arm.data.bones["thigh." + lado], arm.data.bones["upper_arm." + lado]
    RAMPA["thigh." + lado] = (th.head_local.z + 0.02, th.tail_local.z + 0.02)
    RAMPA["upper_arm." + lado] = (ua.head_local.z + 0.04, ua.tail_local.z + 0.02)
print("rampas:", {k: (round(x, 3), round(y, 3)) for k, (x, y) in RAMPA.items()})
grupos = {g.name: g for g in malla.vertex_groups}
idx_nombre = {g.index: g.name for g in malla.vertex_groups}
ANILLO = 30.0  # px de mezcla entre cabeza y cuello
z_cuello = P(0, 560)[2]
n_cab = n_ore = 0
final = {}     # índice -> {hueso: peso}, antes de suavizar y limitar
fijos = set()  # vértices de la cabeza: no se suavizan
for v in malla.data.vertices:
    px, py, fx = a_px(v.co)
    pesos = {idx_nombre[g.group]: g.weight for g in v.groups}
    if 0 <= px < 1024 and 0 <= py < 1024 and cabeza_m[py, px] and v.co.z > z_cuello - 0.06:
        # El anillo de mezcla solo abajo y atrás de la cabeza (donde nace el cuello); la cara,
        # la boca y el mentón (px >= 790) van enteros a la cabeza.
        d = fondo[px] - py
        w = min(1.0, max(0.0, d) / ANILLO) if px < 790 else 1.0
        nuevo = {"spine.006": w}
        if w < 1.0:
            resto = {k: x for k, x in pesos.items() if k not in ("spine.006",) and not k.startswith("ear")}
            s = sum(resto.values())
            if s > 1e-6:
                for k, x in resto.items():
                    nuevo[k] = nuevo.get(k, 0) + (1 - w) * x / s
            else:
                nuevo["spine.004"] = 1 - w
        # Orejas: dentro de la máscara de frente y arriba de la cabeza.
        if 0 <= fx < 1024 and oreja_f[py, fx] and py < 330:
            lado = "ear.L" if v.co.x > 0 else "ear.R"
            k = min(1.0, (330 - py) / 40.0)
            nuevo = {lado: k, "spine.006": 1 - k}
            n_ore += 1
        pesos = nuevo
        n_cab += 1
    # Patas: no toman vértices del otro lado y su peso se desvanece suave hacia el centro de
    # la panza (de x = 0,12 a 0,02). Un corte duro aquí plegaba la piel entre las patas y la
    # panza al caminar (franjas oscuras bajo el vientre).
    PATA = ("shoulder", "upper_arm", "forearm", "hand", "f_toe", "pelvis", "thigh", "shin", "foot", "r_toe")
    for k in list(pesos):
        if k.startswith(PATA):
            lado_x = v.co.x if k.endswith(".L") else -v.co.x
            t = min(1.0, max(0.0, (lado_x - 0.02) / 0.10))
            pesos[k] *= t * t * (3 - 2 * t)
            if pesos[k] <= 1e-4:
                pesos.pop(k)
    # Muslo y brazo solo toman la piel de la pata: entre la rodilla (o el codo) y la cadera
    # (o el hombro) su peso baja suave a 0 y lo que sobra pasa a la pelvis o la escápula,
    # que siguen al cuerpo. Sin esto, la grupa y el flanco giraban con la pata y en el toon
    # se veía una sombra que aparecía y desaparecía sobre la pata trasera.
    for k in list(pesos):
        if k.startswith(("thigh", "upper_arm")):
            arriba, abajo = RAMPA[k]
            t = min(1.0, max(0.0, (arriba - v.co.z) / (arriba - abajo)))
            f = t * t * (3 - 2 * t)
            quita = pesos[k] * (1 - f)
            pesos[k] -= quita
            fijo = ("pelvis" if k.startswith("thigh") else "shoulder") + k[-2:]
            pesos[fijo] = pesos.get(fijo, 0.0) + quita
    s = sum(pesos.values())
    final[v.index] = {k: x / s for k, x in pesos.items()} if s > 1e-6 else {"spine.001": 1.0}
    if 0 <= px < 1024 and 0 <= py < 1024 and cabeza_m[py, px] and v.co.z > z_cuello - 0.06:
        fijos.add(v.index)
print("vértices de cabeza:", n_cab, "de orejas:", n_ore)

# Suavizado de pesos entre vecinos fuera de la cabeza (3 pasadas, mitad propio y mitad
# promedio de los vecinos): quita los saltos de peso que pliegan la piel.
vecinos = [[] for _ in malla.data.vertices]
for e in malla.data.edges:
    a_, b_ = e.vertices
    vecinos[a_].append(b_); vecinos[b_].append(a_)
for _ in range(3):
    nuevo = {}
    for i, ps in final.items():
        if i in fijos or not vecinos[i]:
            continue
        acc = {k: 0.5 * x for k, x in ps.items()}
        for j in vecinos[i]:
            for k, x in final[j].items():
                acc[k] = acc.get(k, 0.0) + 0.5 * x / len(vecinos[i])
        nuevo[i] = acc
    final.update(nuevo)

# Máximo 4 huesos y suma 1. Se guardan los índices antes de borrar: borrar mientras se
# recorre v.groups corre la colección y dejaba restos de los pesos de calor.
for v in malla.data.vertices:
    top = sorted(final[v.index].items(), key=lambda kv: -kv[1])[:4]
    s = sum(x for _, x in top)
    for gi in [g.group for g in v.groups]:
        grupos[idx_nombre[gi]].remove([v.index])
    for k, x in top:
        if x / s > 0.002:
            grupos[k].add([v.index], x / s, "REPLACE")

malla.modifiers["Armature"].use_deform_preserve_volume = False  # Godot usa skinning lineal
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_RIG)
print("guardado", C.BLEND_RIG)
