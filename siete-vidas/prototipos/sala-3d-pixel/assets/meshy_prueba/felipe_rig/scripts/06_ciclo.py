# Paso 8: hoja con 8 cuadros del ciclo de caminar de perfil (y otros cuadros para revisar).
# Uso: python3 06_ciclo.py <salida.png> [accion=caminar] [vista=perfil_d] [cuadros=8]
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

salida = sys.argv[1]
accion = sys.argv[2] if len(sys.argv) > 2 else "caminar"
vista = sys.argv[3] if len(sys.argv) > 3 else "perfil_d"
n = int(sys.argv[4]) if len(sys.argv) > 4 else 8
bpy.ops.wm.open_mainfile(filepath=C.BLEND_ANIM)
arm = bpy.data.objects["FelipeRig"]
m = bpy.data.objects["Felipe"]
acc = bpy.data.actions[accion]
arm.animation_data.action = acc
try:
    if acc.slots and arm.animation_data.action_slot is None:
        arm.animation_data.action_slot = acc.slots[0]
except AttributeError:
    pass
for t in arm.animation_data.nla_tracks:
    t.mute = True
R.escena(400, 10)
R.luz()
# Piso con rayas cada 5 cm para ver que el pie apoyado no se corre.
bpy.ops.mesh.primitive_plane_add(size=3, location=(0, 0, 0))
piso = bpy.context.object
pm = bpy.data.materials.new("piso"); pm.use_nodes = True
nt = pm.node_tree
bs = nt.nodes.get("Principled BSDF")
ch = nt.nodes.new("ShaderNodeTexChecker"); ch.inputs["Scale"].default_value = 30
ch.inputs["Color1"].default_value = (0.55, 0.5, 0.45, 1); ch.inputs["Color2"].default_value = (0.62, 0.57, 0.52, 1)
nt.links.new(ch.outputs[0], bs.inputs["Base Color"])
piso.data.materials.append(pm)
cuadro0, cuadro1 = int(acc.frame_range[0]), int(acc.frame_range[1])
largo = cuadro1 - cuadro0
T = 400
COL = 4
hoja = Image.new("RGB", (T * min(n, COL), (T + 20) * ((n + COL - 1) // COL)), (240, 240, 240))
d = ImageDraw.Draw(hoja)
for i in range(n):
    f = cuadro0 + largo * i / n
    bpy.context.scene.frame_set(int(f), subframe=f - int(f))
    dirs = {"perfil_d": (-1, 0, 0.12), "tres_cuartos": (-0.75, -1, 0.35), "frente": (0, -1, 0.1)}
    R.camara(dirs.get(vista, vista), centro=(0, 0.04, 0.3), tam=0.8)
    R.mostrar_solo([m, piso])
    ruta = os.path.join(C.TRABAJO, "ciclo_%02d.png" % i)
    R.render(ruta)
    x, y = (i % COL) * T, (i // COL) * (T + 20)
    hoja.paste(Image.open(ruta).convert("RGB"), (x, y + 20))
    d.text((x + 6, y + 4), "%s %d/%d (cuadro %.1f)" % (accion, i + 1, n, f), fill=(20, 20, 20), font=R.letra())
hoja.save(salida)
print("hoja", salida)
