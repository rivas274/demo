# Hoja con 6 cuadros clave de cada acción (de perfil arriba y en 3/4 abajo), en Cycles.
# Uso: python3 08_acciones_cuadros.py <salida.png> [acción[:cuadro,cuadro,...]] ...
# Sin acciones: arañar (entrada, bucle y salida juntas), pedir (entrada y bucle) y saltar.
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

salida = sys.argv[1]
# (título, [(acción, cuadro)] x 6)
GRUPOS = {
    "arañar": [("aranar_entrada", 0), ("aranar_entrada", 6), ("aranar", 0), ("aranar", 3), ("aranar", 11),
               ("aranar_salida", 9)],
    "pedir": [("pedir_entrada", 6), ("pedir_entrada", 18), ("pedir", 9), ("pedir", 12), ("pedir", 15),
              ("pedir", 31)],
    "saltar": [("saltar", 8), ("saltar", 12), ("saltar", 16), ("saltar", 22), ("saltar", 24), ("saltar", 27)],
}
pedidos = sys.argv[2:]
if pedidos:
    GRUPOS = {}
    for p in pedidos:
        nombre, _, cs = p.partition(":")
        GRUPOS[nombre] = [(nombre, float(c)) for c in (cs.split(",") if cs else "0,4,8,12,16,20".split(","))]

bpy.ops.wm.open_mainfile(filepath=C.BLEND_ANIM)
arm = bpy.data.objects["FelipeRig"]
m = bpy.data.objects["Felipe"]
for t in arm.animation_data.nla_tracks:
    t.mute = True
R.escena(300, 10)
R.luz()
bpy.ops.mesh.primitive_plane_add(size=3, location=(0, 0, 0))
piso = bpy.context.object
pm = bpy.data.materials.new("piso"); pm.use_nodes = True
pm.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (0.6, 0.56, 0.5, 1)
piso.data.materials.append(pm)
T = 300
VISTAS = [((-1, 0, 0.12), "perfil"), ((-0.75, -1, 0.35), "3/4")]
filas = len(GRUPOS) * len(VISTAS)
hoja = Image.new("RGB", (150 + T * 6, (T + 22) * filas), (240, 240, 240))
d = ImageDraw.Draw(hoja)
fila = 0
for titulo, cuadros in GRUPOS.items():
    for vista, nombre_vista in VISTAS:
        y = fila * (T + 22)
        d.text((8, y + T // 2), "%s\n(%s)" % (titulo, nombre_vista), fill=(20, 20, 20), font=R.letra(18))
        for j, (accion, f) in enumerate(cuadros):
            acc = bpy.data.actions[accion]
            arm.animation_data.action = acc
            try:
                if acc.slots:
                    arm.animation_data.action_slot = acc.slots[0]
            except AttributeError:
                pass
            bpy.context.scene.frame_set(int(f), subframe=f - int(f))
            R.camara(vista, centro=(0, 0.02, 0.27), tam=0.78)
            R.mostrar_solo([m, piso])
            ruta = os.path.join(C.TRABAJO, "ac_%d_%d.png" % (fila, j))
            R.render(ruta)
            hoja.paste(Image.open(ruta).convert("RGB"), (150 + j * T, y + 22))
            d.text((150 + j * T + 6, y + 3), "%s %g" % (accion, f), fill=(20, 20, 20), font=R.letra(14))
        fila += 1
hoja.save(salida)
print("hoja", salida)
