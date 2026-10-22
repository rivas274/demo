# Paso 2b: repinta el lomo y la cola en la textura horneada, con el patrón del Felipe real
# (fotos del creador: felipe-lomo-arriba-1/2.jpg, felipe-lomo-costado.jpg). De adelante
# hacia atrás, visto desde arriba: gorra (no se toca), nuca blanca, un PAR de manchas a media
# espalda separadas por una franja blanca sobre la columna, una banda blanca atravesada, un
# PAR de manchas sobre la cadera que bajan por el muslo, base de la cola blanca y cola gris
# muy oscuro casi lisa (más clara al centro). Manchas: atigrado pardo grisáceo con rayas
# finas de la columna hacia abajo, bordes suaves. Método:
#  1. Rasteriza la malla en el espacio UV: cada texel sabe su punto 3D.
#  2. Mapa "cilíndrico" del cuerpo (largo x ángulo alrededor de su eje): ahí se dibujan las
#     manchas, así las costuras UV no las cortan y, con la malla simétrica, quedan espejadas.
#  3. Vuelve a la textura con bordes suaves y rellena el padding de las islas UV.
# Prueba varias variantes de manchas (VARIANTES), las mide y usa la elegida (o argv[1]).
# Uso: python3 02b_lomo.py [variante] [carpeta para la hoja de comparación]
import sys, os, math, json, bpy
import numpy as np
from PIL import Image
from scipy import ndimage
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

# Variantes del patrón: (nombre, manchas del medio (t0, t1), manchas de la cadera (t0, t1),
# media franja de la columna (°), hasta dónde bajan por el costado (°) medio y cadera,
# exponente de la superelipse). t: 0 = arranque de la cola, 1 = pecho.
VARIANTES = [
    ("a_base", (0.36, 0.62), (0.02, 0.30), 6, (88, 100), 2.0),
    ("b_franja_angosta", (0.36, 0.62), (0.02, 0.30), 3, (88, 100), 2.0),
    ("c_franja_ancha", (0.36, 0.62), (0.02, 0.30), 10, (88, 100), 2.0),
    ("d_grandes", (0.33, 0.66), (0.00, 0.33), 6, (98, 110), 2.0),
    ("e_chicas", (0.39, 0.60), (0.05, 0.28), 6, (78, 90), 2.0),
    ("f_cuadradas", (0.36, 0.62), (0.02, 0.30), 6, (88, 100), 2.6),
    # Elegida: tamaño cercano a las fotos (como d) sin cerrar la banda blanca (como a).
    ("g_medianas", (0.345, 0.64), (0.01, 0.315), 6, (94, 106), 2.0),
]
ELEGIDA = "g_medianas"
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
# El rulo de arriba de la cola se sale del contorno del creador: todo lo que está arriba y
# atrás de la grupa también es cola.
fy, fx = np.mgrid[0:1024, 0:1024]
cola |= (fx < 400) & (fy < 520)
zoff = C.CENTRO_ORIGINAL[2] - C.Z_PISO_ORIGINAL
px = np.clip(np.round(512 - pos[..., 1] / C.PX).astype(int), 0, 1023)
py = np.clip(np.round(512 - (pos[..., 2] - zoff) / C.PX).astype(int), 0, 1023)
# Mapa del lomo: largo entre la grupa (Y0) y el pecho (Y1), en px de perfil.
Y0, Y1 = 290, 800      # px de perfil (de la grupa al pecho y la nuca)
cab_sola = ((mp >> 0) & 1).astype(bool) | ((mp >> 1) & 1).astype(bool)
# Nuca: lo de atrás y abajo de la cabeza (no la cara ni la gorra de arriba) también va blanco.
nuca = cab_sola[py, px] & (py > 470) & (px < 700)
# Todo el cuerpo salvo la cabeza (sin la nuca) y la cola: así no quedan restos del gris
# deshilachado de Meshy (la panza y las patas, fuera de las manchas, quedan blancas).
zona = cubre & (~cabeza[py, px] | nuca) & ~cola[py, px]
# Bordes de la zona que se funden con lo original (no hay corte con cabeza, cola y patas).
# La distancia se mide solo contra los bordes reales de la zona (cabeza, cola): los texels
# fuera de las islas UV cuentan como zona. Si no, junto a cada costura UV volvía la textura
# vieja (líneas dentadas en escalera).
borde = ndimage.distance_transform_edt(zona | ~cubre)
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


A_ESPEJO = None


def _espejo():
    a = np.linspace(-math.pi, math.pi, GA)
    return np.clip(((np.where(a >= 0, math.pi - a, -math.pi - a) + math.pi) / (2 * math.pi) * (GA - 1)).round().astype(int), 0, GA - 1)


def _alfa(m):
    dentro = ndimage.distance_transform_edt(m)
    fuera = ndimage.distance_transform_edt(~m)
    return np.clip(0.5 + (dentro - fuera) / 2.5, 0, 1)


def campo(T, LAT, medio, cadera, franja, baja, expo):
    """Opacidad (0..1) de las manchas en el largo T (0 cola .. 1 pecho) y la distancia LAT (°)
    a la línea del lomo. Se evalúa directo en cada texel (sin grilla: sin cortes ni escalones)."""
    f = np.full(T.shape, 9.0)
    for (t0, t1), hasta in ((medio, baja[0]), (cadera, baja[1])):
        tc, rt = (t0 + t1) / 2, (t1 - t0) / 2
        ac, ra = (franja + hasta) / 2, (hasta - franja) / 2
        # Borde orgánico: el radio ondula un poco (no recto).
        onda = 1 + 0.07 * np.sin(9 * T * math.pi + 0.07 * LAT) + 0.05 * np.sin(0.13 * LAT + 1.0)
        u = np.abs(T - tc) / (rt * onda)
        v = np.abs(LAT - ac) / (ra * onda)
        f = np.minimum(f, u ** expo + v ** expo)
    alfa = np.clip((1.08 - f) / 0.16, 0, 1)
    # Franja blanca sobre la columna, de borde suave.
    alfa *= np.clip((LAT - franja) / 3.0, 0, 1)
    return alfa


def limpiar(*params):
    espejo = _espejo()
    T = (np.arange(GY) / (GY - 1))[:, None] * np.ones((1, GA))
    A = (np.linspace(-math.pi, math.pi, GA))[None, :] * np.ones((GY, 1))
    lat = np.degrees(np.abs(A - math.pi / 2))
    lat = np.minimum(lat, 360 - lat)
    alfa = campo(T, lat, *params)
    return alfa > 0.5, alfa, espejo


def medir(m, espejo):
    lab, n = ndimage.label(m)
    area = m.sum()
    per = (m & ~ndimage.binary_erosion(m)).sum()
    tam = ndimage.sum(m, lab, range(1, n + 1)) if n else [0]
    # Redondez media de las manchas: 1 = círculo (perímetro / perímetro de un círculo de igual área).
    red = np.mean([((lab == i + 1) & ~ndimage.binary_erosion(lab == i + 1)).sum() / (2 * math.sqrt(math.pi * t))
                   for i, t in enumerate(tam) if t > 0]) if n else 0
    sim = (m & m[:, espejo]).sum() / max(1, (m | m[:, espejo]).sum())
    huecos = ndimage.label(ndimage.binary_fill_holes(m) & ~m)[1]
    ref = (ndimage.gaussian_filter(mapa, 2.0) > 0.6).sum()
    return {"manchas": int(n), "huecos": int(huecos), "area_vs_original": round(float(area / max(ref, 1)), 2),
            "redondez": round(float(red), 2), "simetria": round(float(sim), 3)}


# Cola: parámetro a lo largo de la cola (0 = base, 1 = punta) por su línea central de perfil.
COLA_LINEA = np.array([(345, 560), (240, 485), (228, 405), (222, 305), (196, 243), (110, 195)], float)
seg = np.diff(COLA_LINEA, axis=0)
largos = np.linalg.norm(seg, axis=1)
acum = np.concatenate([[0], np.cumsum(largos)]) / largos.sum()


def param_cola(pxs, pys):
    p = np.stack([pxs, pys], -1).astype(float)
    mejor_d = np.full(p.shape[:-1], 1e9); mejor_s = np.zeros(p.shape[:-1])
    for i in range(len(seg)):
        a0 = COLA_LINEA[i]
        u = np.clip(((p - a0) @ seg[i]) / (largos[i] ** 2), 0, 1)
        d = np.linalg.norm(p - (a0 + u[..., None] * seg[i]), axis=-1)
        mejor = d < mejor_d
        mejor_d[mejor] = d[mejor]
        mejor_s[mejor] = (acum[i] + u * largos[i] / largos.sum())[mejor]
    return mejor_s


en_cola = cubre & cola[py, px] & (py < 610)
s_cola = np.zeros(px.shape)
s_cola[en_cola] = param_cola(px[en_cola], py[en_cola])
GRIS_COLA = np.array([0.20, 0.19, 0.19], np.float32)


def aplicar(params):
    T = np.clip((px - Y0) / (Y1 - Y0), -0.2, 1.2)
    LAT = np.degrees(np.abs(ang - math.pi / 2))
    LAT = np.minimum(LAT, 360 - LAT)
    a = campo(T, LAT, *params)
    # Rayas atigradas finas: de la columna hacia abajo (líneas a lo largo del costado), con
    # una leve ondulación; oscuras y angostas.
    largo = (px - Y0) / (Y1 - Y0)
    lat = np.abs(ang - math.pi / 2)
    rayas = 0.5 + 0.5 * np.sin(2 * math.pi * (largo * 15.0 + 0.5 * np.sin(lat * 1.6) + 0.15 * np.sin(largo * 40)))
    rayas = np.clip((rayas - 0.70) * 3.0, 0, 1) * 0.40
    dentro = gris[None, None, :] * (1 - rayas[..., None]) + raya[None, None, :] * rayas[..., None]
    nuevo = dentro * a[..., None] + blanco_ref[None, None, :] * (1 - a[..., None])
    w = peso_zona[..., None]
    out = tex * (1 - w) + nuevo * w
    # Cola: base blanca (anillo corto) y luego gris muy oscuro casi liso, más clara al centro.
    sc = s_cola
    base = np.clip((0.13 - sc) / 0.04, 0, 1)
    centro = 1 + 0.18 * np.exp(-((sc - 0.55) / 0.22) ** 2)
    oscuro = GRIS_COLA[None, None, :] * centro[..., None]
    col = blanco_ref[None, None, :] * base[..., None] + oscuro * (1 - base[..., None])
    wc = (en_cola * np.clip((sc - 0.0) / 0.02, 0, 1))[..., None]
    out = out * (1 - wc) + col * wc
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
    mapas[nombre] = (m, alfa, params)
    print(nombre, resultados[nombre])
base = ndimage.gaussian_filter(mapa, 2.0) > 0.6
resultados["original"] = medir(base, espejo)
print("original (sin limpiar)", resultados["original"])
with open(os.path.join(C.TRABAJO, "lomo_variantes.json"), "w") as fh:
    json.dump(resultados, fh, indent=1)

if hoja:
    os.makedirs(hoja, exist_ok=True)
    Image.fromarray((np.clip(mapa, 0, 1) * 255).astype(np.uint8)).resize((GA * 2, GY * 2)).save(os.path.join(hoja, "mapa_original.png"))
    for nombre, (m, alfa, params) in mapas.items():
        Image.fromarray((alfa * 255).astype(np.uint8)).resize((GA * 2, GY * 2)).save(os.path.join(hoja, "mapa_%s.png" % nombre))
        Image.fromarray((aplicar(params) * 255).astype(np.uint8)).save(os.path.join(hoja, "tex_%s.png" % nombre))

m, alfa, params = mapas[eleccion]
Image.fromarray((aplicar(params) * 255).astype(np.uint8)).save(ruta_tex)
img = bpy.data.images.get("felipe_rig_color")
img.filepath = ruta_tex
img.reload()
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_TEXTURA)
print("textura del lomo repintada con", eleccion, "->", ruta_tex)
