# Paso 4b: prueba de poses. Dobla patas ±35° (hombro/cadera y codo/rodilla), cola 30° y
# cabeza 20°, y renderiza una hoja con textura y otra en alambre para revisar la piel.
# Uso: python3 04_poses.py <salida.png> [blend]
import sys, os, math, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

salida = sys.argv[1]
bpy.ops.wm.open_mainfile(filepath=sys.argv[2] if len(sys.argv) > 2 else C.BLEND_RIG)
m = bpy.data.objects["Felipe"]
a = bpy.data.objects["FelipeRig"]
for o in list(bpy.data.objects):
    if o.name.startswith("Felipe_alambre"):
        bpy.data.objects.remove(o)
a.animation_data_clear()
R.escena(420, 10)
R.luz()
w = R.alambre_de(m, grosor=0.0028)

# (nombre, vista, {hueso: (eje, grados)}); eje en el espacio local (X local = X del mundo).
POSES = [
    ("reposo", "perfil_d", {}),
    ("delantera +35/-35", "perfil_d", {"upper_arm.R": ("X", 35), "forearm.R": ("X", -35)}),
    ("delantera -35/+35", "perfil_d", {"upper_arm.R": ("X", -35), "forearm.R": ("X", 35)}),
    ("trasera +35/-35", "perfil_d", {"thigh.R": ("X", 35), "shin.R": ("X", -35)}),
    ("trasera -35/+35", "perfil_d", {"thigh.R": ("X", -35), "shin.R": ("X", 35)}),
    ("cola 30 atrás", "perfil_d", {"tail.001": ("X", 30), "tail.002": ("X", 15)}),
    ("cola 30 al lado", "atras", {"tail.001": ("Z", 30), "tail.002": ("Z", 15)}),
    ("cabeza 20 abajo", "perfil_d", {"spine.006": ("X", -20)}),
    ("cabeza 20 al lado", "tres_cuartos", {"spine.006": ("Z", 20)}),
    ("todo junto 3/4", "tres_cuartos", {"upper_arm.L": ("X", -35), "forearm.L": ("X", 35),
                                       "thigh.R": ("X", 35), "shin.R": ("X", -35),
                                       "tail.001": ("X", 30), "spine.006": ("X", -20)}),
]
cuadros = []
for i, (nombre, vista, pose) in enumerate(POSES):
    for pb in a.pose.bones:
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = (0, 0, 0)
        pb.location = (0, 0, 0)
    for h, (eje, g) in pose.items():
        pb = a.pose.bones[h]
        e = list(pb.rotation_euler)
        e["XYZ".index(eje)] = math.radians(g)
        pb.rotation_euler = e
    bpy.context.view_layer.update()
    if "delantera" in nombre or "trasera" in nombre:
        R.camara(vista, centro=(0, 0, 0.32), tam=1.25)  # de cerca: la piel de las patas
    else:
        R.camara(vista, centro=(0, 0, 0.78), tam=1.95)
    fila = []
    for tipo, objs in (("tex", [m]), ("alambre", [m, w])):
        if tipo == "alambre":
            mat_tex = m.data.materials[0]
            m.data.materials[0] = R.material_liso()
        R.mostrar_solo(objs)
        ruta = os.path.join(C.TRABAJO, "pose_%d_%s.png" % (i, tipo))
        R.render(ruta)
        if tipo == "alambre":
            m.data.materials[0] = mat_tex
        fila.append(ruta)
    cuadros.append((nombre, fila))

T = 420
hoja = Image.new("RGB", (T * 5, (T + 24) * 4), (240, 240, 240))
d = ImageDraw.Draw(hoja)
for i, (nombre, fila) in enumerate(cuadros):
    col, filab = i % 5, (i // 5) * 2
    for k, ruta in enumerate(fila):
        y = (filab + k) * (T + 24)
        hoja.paste(Image.open(ruta).convert("RGB"), (col * T, y + 24))
        d.text((col * T + 6, y + 5), nombre + (" (alambre)" if k else ""), fill=(20, 20, 20))
hoja.save(salida)
print("hoja", salida)
