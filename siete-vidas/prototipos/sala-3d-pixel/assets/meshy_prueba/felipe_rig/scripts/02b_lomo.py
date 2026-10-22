# Paso 2b: repinta las manchas atigradas del lomo y los costados en la textura horneada.
# La textura de Meshy traía las manchas con bordes rotos, deshilachados e islas sueltas, y
# el horneado los empeoró. Método:
#  1. Rasteriza la malla en el espacio UV: cada texel sabe su punto 3D.
#  2. Pasa la zona del lomo (sin cabeza, cola ni patas) a un mapa "cilíndrico" del cuerpo
#     (largo del cuerpo x ángulo alrededor de su eje). Ahí las costuras UV no existen.
#  3. En ese mapa saca la máscara de las manchas (lo oscuro), la limpia (suavizado, cierre y
#     apertura, sin islas chicas ni huecos) y la hace casi simétrica (izquierda y derecha).
#  4. Vuelve a la textura: dentro de la mancha, gris pardo de la gorra con rayas atigradas
#     sutiles; fuera, blanco limpio; bordes suaves de pocos texels. Rellena el padding.
# Prueba varias limpiezas (VARIANTES), mide cada una y usa la elegida (o la que diga argv[1]).
# Uso: python3 02b_lomo.py [variante] [carpeta para la hoja de comparación]
import sys, os, math, json, bpy
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

# (nombre, umbral de oscuro, suavizado previo, radio de cierre, radio de apertura, isla mínima
# en celdas, peso de la simetría 0..1)
VARIANTES = [
    ("a_umbral_bajo", 0.42, 1.0, 2, 2, 60, 0.5),
    ("b_medio", 0.50, 1.5, 3, 2, 80, 0.5),
    ("c_mas_suave", 0.50, 2.5, 4, 3, 120, 0.5),
    ("d_umbral_alto", 0.58, 1.5, 3, 2, 80, 0.5),
    ("e_suave_simetrico", 0.50, 2.5, 4, 3, 120, 1.0),
    ("f_muy_suave", 0.50, 3.5, 5, 4, 160, 0.7),
]
ELEGIDA = "c_mas_suave"
GY, GA = 260, 180   # celdas del mapa cilíndrico (largo x ángulo)

eleccion = sys.argv[1] if len(sys.argv) > 1 else ELEGIDA
hoja = sys.argv[2] if len(sys.argv) > 2 else None

bpy.ops.wm.open_mainfile(filepath=C.BLEND_TEXTURA)
ret = bpy.data.objects["Retopo"]
me = ret.data
ruta_tex = os.path.join(C.TRABAJO, "felipe_rig_color.png")
ruta_horneada = os.path.join(C.TRABAJO, "felipe_rig_color_horneado.png")
tex = np.array(Image.open(ruta_horneada).convert("RGB")).astype(np.float32) / 255.0
H, W = tex.shape[:2]

# --- 1. Rasterizar la malla en UV (centro de cada texel -> punto 3D).
me.calc_loop_triangles()
uv = me.uv_layers.active.data
pos = np.zeros((H, W, 3), np.float32)
cubre = np.zeros((H, W), bool)
co = np.array([v.co[:] for v in me.vertices], np.float32)
for t in me.loop_triangles:
    p = np.array([[uv[l].uv[0] * W - 0.5, (1 - uv[l].uv[1]) * H - 0.5] for l in t.loops])
    q = co[list(t.vertices)]
    x0, y0 = np.floor(p.min(0)).astype(int)
    x1, y1 = np.ceil(p.max(0)).astype(int)
    x0, y0 = max(x0, 0), max(y0, 0)
    x1, y1 = min(x1, W - 1), min(y1, H - 1)
    if x1 < x0 or y1 < y0:
        continue
    xs, ys = np.meshgrid(np.arange(x0, x1 + 1), np.arange(y0, y1 + 1))
    d = (p[1, 1] - p[2, 1]) * (p[0, 0] - p[2, 0]) + (p[2, 0] - p[1, 0]) * (p[0, 1] - p[2, 1])
    if abs(d) < 1e-12:
        continue
    l0 = ((p[1, 1] - p[2, 1]) * (xs - p[2, 0]) + (p[2, 0] - p[1, 0]) * (ys - p[2, 1])) / d
    l1 = ((p[2, 1] - p[0, 1]) * (xs - p[2, 0]) + (p[0, 0] - p[2, 0]) * (ys - p[2, 1])) / d
    l2 = 1 - l0 - l1
    dentro = (l0 >= -1e-4) & (l1 >= -1e-4) & (l2 >= -1e-4)
    if not dentro.any():
        continue
    yy, xx = ys[dentro], xs[dentro]
    pos[yy, xx] = l0[dentro, None] * q[0] + l1[dentro, None] * q[1] + l2[dentro, None] * q[2]
    cubre[yy, xx] = True
print("texels cubiertos: %.1f %%" % (100 * cubre.mean()))

# --- 2. Zona del lomo y costados, en coordenadas de las plantillas (perfil, 1024 px).
mp = np.array(Image.open(os.path.join(C.PLANTILLA, "mascaras_perfil.png")))[..., 0]
cabeza = ((mp >> 0) & 1).astype(bool) | ((mp >> 1) & 1).astype(bool)
cola = ((mp >> 5) & 1).astype(bool)
cabeza = ndimage.binary_dilation(cabeza, iterations=6)
cola = ndimage.binary_dilation(cola, iterations=4)
zoff = C.CENTRO_ORIGINAL[2] - C.Z_PISO_ORIGINAL
px = np.clip(np.round(512 - pos[..., 1] / C.PX).astype(int), 0, 1023)
py = np.clip(np.round(512 - (pos[..., 2] - zoff) / C.PX).astype(int), 0, 1023)
# Lomo y costados: entre la cola y la cabeza, por encima de la mitad de la panza.
Y0, Y1 = 290, 780      # px de perfil (de la grupa al pecho)
zona = cubre & ~cabeza[py, px] & ~cola[py, px] & (px >= Y0) & (px <= Y1) & (py <= 700)
# Bordes de la zona que se funden con lo original (no hay corte con cabeza, cola y patas).
borde = ndimage.distance_transform_edt(zona) if zona.any() else np.zeros_like(pos[..., 0])
peso_zona = np.clip(borde / 10.0, 0, 1)

# Mapa cilíndrico: largo (px de perfil) y ángulo alrededor del eje del cuerpo.
zc = -(640 - 512) * C.PX + zoff
ang = np.arctan2(pos[..., 2] - zc, pos[..., 0])                     # pi/2 = lomo
gy = np.clip(((px - Y0) / (Y1 - Y0) * (GY - 1)).round().astype(int), 0, GY - 1)
ga = np.clip(((ang + math.pi) / (2 * math.pi) * (GA - 1)).round().astype(int), 0, GA - 1)
lum = tex @ np.array([0.299, 0.587, 0.114], np.float32)
blanco_ref = np.median(tex[zona & (lum > 0.8)], axis=0)
oscuro_ref = np.median(tex[zona & (lum < 0.45)], axis=0)
osc = np.clip((blanco_ref @ [0.299, 0.587, 0.114] - lum) / max(1e-3, (blanco_ref - oscuro_ref) @ [0.299, 0.587, 0.114]), 0, 1)
suma = np.zeros((GY, GA)); cuenta = np.zeros((GY, GA))
np.add.at(suma, (gy[zona], ga[zona]), osc[zona])
np.add.at(cuenta, (gy[zona], ga[zona]), 1)
hay = cuenta > 0
mapa = np.where(hay, suma / np.maximum(cuenta, 1), 0.0)
# Celdas vacías: el valor de la celda con dato más cercana.
idx = ndimage.distance_transform_edt(~hay, return_distances=False, return_indices=True)
mapa = mapa[idx[0], idx[1]]

# Color de la gorra (gris pardo atigrado) para rellenar: lo oscuro de la cabeza, arriba.
gorra = cubre & cabeza[py, px] & (py < 330) & (lum < 0.55)
gris = np.median(tex[gorra], axis=0) if gorra.any() else oscuro_ref
raya = gris * 0.72
print("blanco", blanco_ref, "gris de la gorra", gris)


def limpiar(umbral, sigma, r_cierre, r_apertura, isla, simetria):
    m = ndimage.gaussian_filter(mapa, sigma, mode="nearest") > umbral
    est = lambda r: ndimage.generate_binary_structure(2, 1) if r <= 1 else \
        (np.add.outer(np.arange(-r, r + 1) ** 2, np.arange(-r, r + 1) ** 2) <= r * r)
    m = ndimage.binary_closing(m, est(r_cierre), border_value=0)
    m = ndimage.binary_opening(m, est(r_apertura))
    m = ndimage.binary_fill_holes(m)
    lab, n = ndimage.label(m)
    tam = ndimage.sum(m, lab, range(1, n + 1))
    for i, t in enumerate(tam):
        if t < isla:
            m[lab == i + 1] = False
    # Simetría: el espejo (x -> -x) en el mapa es ángulo a -> pi - a.
    a = np.linspace(-math.pi, math.pi, GA)
    espejo = np.clip(((np.where(a >= 0, math.pi - a, -math.pi - a) + math.pi) / (2 * math.pi) * (GA - 1)).round().astype(int), 0, GA - 1)
    suave = ndimage.gaussian_filter(m.astype(float), 1.2)
    suave = (1 - simetria / 2) * suave + (simetria / 2) * suave[:, espejo]
    m = suave > 0.5
    m = ndimage.binary_fill_holes(m)
    # Borde suave: distancia con signo -> 0..1 en ~2 celdas.
    dentro = ndimage.distance_transform_edt(m)
    fuera = ndimage.distance_transform_edt(~m)
    alfa = np.clip(0.5 + (dentro - fuera) / 2.5, 0, 1)
    return m, alfa, espejo


def medir(m, espejo):
    lab, n = ndimage.label(m)
    area = m.sum()
    per = (m & ~ndimage.binary_erosion(m)).sum()
    redondez = per / (2 * math.sqrt(math.pi * max(area, 1)) + 1e-6)   # 1 = círculo
    sim = (m & m[:, espejo]).sum() / max(1, (m | m[:, espejo]).sum())
    huecos = ndimage.label(ndimage.binary_fill_holes(m) & ~m)[1]
    return {"islas": int(n), "huecos": int(huecos), "area": int(area), "borde_por_isla": round(redondez / max(n, 1), 2),
            "simetria": round(float(sim), 3)}


def aplicar(alfa):
    a = alfa[gy, ga]
    # Rayas atigradas sutiles, transversales al lomo y algo curvas (siguen el cuerpo).
    largo = (px - Y0) / (Y1 - Y0)
    rayas = 0.5 + 0.5 * np.sin(2 * math.pi * (largo * 9.0 + 0.18 * np.abs(ang - math.pi / 2)))
    rayas = np.clip((rayas - 0.55) * 3.0, 0, 1) * 0.6
    dentro = gris[None, None, :] * (1 - rayas[..., None]) + raya[None, None, :] * rayas[..., None]
    nuevo = dentro * a[..., None] + blanco_ref[None, None, :] * (1 - a[..., None])
    w = peso_zona[..., None]
    out = tex * (1 - w) + nuevo * w
    out[~cubre] = tex[~cubre]
    # Padding: los texels fuera de las islas UV copian el texel cubierto más cercano.
    idx = ndimage.distance_transform_edt(~cubre, return_distances=False, return_indices=True)
    out = out[idx[0], idx[1]]
    return np.clip(out, 0, 1)


resultados = {}
mapas = {}
for nombre, *params in VARIANTES:
    m, alfa, espejo = limpiar(*params)
    resultados[nombre] = medir(m, espejo)
    mapas[nombre] = (m, alfa)
    print(nombre, resultados[nombre])
base = mapa > VARIANTES[1][1]
resultados["original"] = medir(base, espejo)
print("original (sin limpiar)", resultados["original"])
with open(os.path.join(C.TRABAJO, "lomo_variantes.json"), "w") as fh:
    json.dump(resultados, fh, indent=1)

if hoja:
    os.makedirs(hoja, exist_ok=True)
    Image.fromarray((np.clip(mapa, 0, 1) * 255).astype(np.uint8)).resize((GA * 2, GY * 2)).save(os.path.join(hoja, "mapa_original.png"))
    for nombre, (m, alfa) in mapas.items():
        Image.fromarray((alfa * 255).astype(np.uint8)).resize((GA * 2, GY * 2)).save(os.path.join(hoja, "mapa_%s.png" % nombre))
        Image.fromarray((aplicar(alfa) * 255).astype(np.uint8)).save(os.path.join(hoja, "tex_%s.png" % nombre))

m, alfa = mapas[eleccion]
Image.fromarray((aplicar(alfa) * 255).astype(np.uint8)).save(ruta_tex)
img = bpy.data.images.get("felipe_rig_color")
img.filepath = ruta_tex
img.reload()
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_TEXTURA)
print("textura del lomo repintada con", eleccion, "->", ruta_tex)
