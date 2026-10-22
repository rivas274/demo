# Paso 8: hojas de comparación (retopología en alambre y textura original vs. horneada).
# Uso: python3 07_hojas.py <carpeta de salida>
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

sal = sys.argv[1]
os.makedirs(sal, exist_ok=True)
T = 560


def hoja(filas, titulo_cols, ruta):
    """filas: [(etiqueta, [rutas de imagen])]."""
    ancho = 150 + T * len(titulo_cols)
    img = Image.new("RGB", (ancho, 30 + T * len(filas)), (238, 238, 238))
    d = ImageDraw.Draw(img)
    for j, t in enumerate(titulo_cols):
        d.text((150 + j * T + 10, 8), t, fill=(20, 20, 20), font=R.letra())
    for i, (et, rutas) in enumerate(filas):
        d.text((10, 30 + i * T + T // 2), et, fill=(20, 20, 20), font=R.letra())
        for j, r in enumerate(rutas):
            img.paste(Image.open(r).convert("RGB"), (150 + j * T, 30 + i * T))
    img.save(ruta)
    print("hoja", ruta)


# --- Retopología: original de Meshy (89 mil triángulos) y QuadriFlow, en alambre.
bpy.ops.wm.open_mainfile(filepath=C.BLEND_TEXTURA)
R.escena(T, 8)
R.luz()
orig = bpy.data.objects["Original"]
ret = bpy.data.objects["Retopo"]
orig.data.materials.clear(); orig.data.materials.append(R.material_liso())
ret.data.materials.clear(); ret.data.materials.append(R.material_liso())
wo = R.alambre_de(orig, grosor=0.0015)
wr = R.alambre_de(ret, grosor=0.0028)
vistas = [("perfil_d", (0, 0, 0.81), 2.0), ("tres_cuartos", (0, 0, 0.81), 2.0), ((-0.5, -1, -0.15), (0, -0.25, 0.3), 1.0)]
filas = []
for nombre, objs in (("Meshy original\n%d triángulos" % sum(len(p.vertices) - 2 for p in orig.data.polygons), [orig, wo]),
                     ("Retopología\nQuadriFlow\n%d cuadriláteros" % len(ret.data.polygons), [ret, wr])):
    rutas = []
    for k, (v, c, tam) in enumerate(vistas):
        R.camara(v, centro=c, tam=tam)
        R.mostrar_solo(objs)
        r = os.path.join(C.TRABAJO, "h_retopo_%d_%d.png" % (len(filas), k))
        R.render(r)
        rutas.append(r)
    filas.append((nombre, rutas))
hoja(filas, ["perfil", "3/4", "patas y pecho de cerca"], os.path.join(sal, "felipe-rig-retopo.png"))

# --- Textura: original (textura de Meshy) y horneada en la malla nueva.
bpy.ops.wm.open_mainfile(filepath=C.BLEND_TEXTURA)
R.escena(T, 16)
R.luz()
orig = bpy.data.objects["Original"]
ret = bpy.data.objects["Retopo"]
vistas = [("frente", (0, 0, 0.81), 2.0), ("perfil_d", (0, 0, 0.81), 2.0), ("tres_cuartos", (0, 0, 0.81), 2.0),
          ("atras", (0, 0, 0.81), 2.0), ((-0.4, -1, 0.1), (0, -0.4, 1.05), 0.9)]
filas = []
for nombre, o in (("Meshy original\n(88.912 caras,\nPBR)", orig), ("Horneada\n(2048 px,\nsolo color)", ret)):
    rutas = []
    for k, (v, c, tam) in enumerate(vistas):
        R.camara(v, centro=c, tam=tam)
        R.mostrar_solo([o])
        r = os.path.join(C.TRABAJO, "h_tex_%d_%d.png" % (len(filas), k))
        R.render(r)
        rutas.append(r)
    filas.append((nombre, rutas))
hoja(filas, ["frente", "perfil", "3/4", "atrás (cola con anillos)", "cara de cerca"], os.path.join(sal, "felipe-rig-textura.png"))
