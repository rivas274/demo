# Paso 1a: prueba las variantes de simetría del Felipe de Meshy (qué mitad conservar y con
# qué umbral soldar la costura central), las mide y las renderiza de frente, atrás, arriba y
# de perfil para elegir. Uso: python3 01a_simetria_variantes.py <carpeta de salida>
import sys, os, json, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R, simetria as S
from PIL import Image, ImageDraw

sal = sys.argv[1]
os.makedirs(sal, exist_ok=True)
VARIANTES = [(m, u) for m in ("NEGATIVE_X", "POSITIVE_X") for u in (0.0005, 0.002, 0.005)]
K = C.ALTO_M / 1.6149

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=C.GLB_ORIGINAL)
orig = [o for o in bpy.data.objects if o.type == "MESH"][0]
orig.name = "Meshy"
bpy.context.view_layer.objects.active = orig
orig.select_set(True)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
vs = [v.co for v in orig.data.vertices]
mn = [min(v[i] for v in vs) for i in range(3)]
mx = [max(v[i] for v in vs) for i in range(3)]
for v in orig.data.vertices:
    v.co.x -= (mn[0] + mx[0]) / 2; v.co.y -= (mn[1] + mx[1]) / 2; v.co.z -= mn[2]
orig.data.update()
print("manos delanteras sin simetría:", S.patas_delanteras(orig, K))
x0, yaw, e = S.ajustar_plano(orig)
print("costura (bordes en el centro) sin simetría:", S.medir_costura(orig))

R.escena(300, 8)
R.luz()
VISTAS = [("frente", (0, -1, 0.05)), ("atras", (0, 1, 0.35)), ("arriba", (0, 0, 1)), ("perfil_d", (-1, 0, 0.05))]
filas = []
datos = {"plano": {"x0": x0, "giro": yaw, "error": e}}
casos = [("sin simetría", orig)]
for mitad, umbral in VARIANTES:
    o = orig.copy(); o.data = orig.data.copy(); o.name = "sim_%s_%g" % (mitad, umbral)
    bpy.context.collection.objects.link(o)
    soldados = S.simetrizar(o, mitad, umbral)
    m = {"vertices": len(o.data.vertices), "soldados": soldados, "costura_abierta": S.medir_costura(o),
         "manos": S.patas_delanteras(o, K)}
    datos[o.name] = m
    print(o.name, m)
    casos.append(("%s, %g" % ("mitad -X (derecha)" if mitad == "NEGATIVE_X" else "mitad +X (izquierda)", umbral), o))
for nombre, o in casos:
    fila = []
    for v, d in VISTAS:
        R.camara(d, centro=(0, 0, 0.81), tam=2.0)
        R.mostrar_solo([o])
        r = os.path.join(C.TRABAJO, "sv_%s_%s.png" % (o.name, v))
        R.render(r)
        fila.append(r)
    filas.append((nombre, fila))
T = 300
hoja = Image.new("RGB", (220 + T * 4, T * len(filas)), (240, 240, 240))
dr = ImageDraw.Draw(hoja)
for i, (nombre, fila) in enumerate(filas):
    dr.text((8, i * T + T // 2 - 10), nombre, fill=(20, 20, 20), font=R.letra(15))
    for j, r in enumerate(fila):
        hoja.paste(Image.open(r).convert("RGB"), (220 + j * T, i * T))
hoja.save(os.path.join(sal, "simetria_variantes.png"))
with open(os.path.join(C.TRABAJO, "simetria_variantes.json"), "w") as fh:
    json.dump(datos, fh, indent=1)
print("hoja", os.path.join(sal, "simetria_variantes.png"))
