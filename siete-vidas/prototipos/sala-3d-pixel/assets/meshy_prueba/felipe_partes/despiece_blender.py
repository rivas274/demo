"""Render de partes: armado y en despiece, un color por parte.

Uso: blender -b -P despiece_blender.py -- <partes.glb> <salida.png> [factor=0.6]
Arriba: armado (frente 3/4 y lado). Abajo: despiece (cada parte se aleja del centro del modelo).
"""
import math
import os
import sys

import bpy
from mathutils import Vector

args = sys.argv[sys.argv.index("--") + 1:]
entrada, salida = args[0], args[1]
factor = float(args[2]) if len(args) > 2 else 0.6

import colorsys  # noqa: E402

# Un tono distinto por pieza (ángulo áureo en el círculo de color), alternando claro y oscuro.
COLORES = [colorsys.hsv_to_rgb((i * 0.618) % 1, 0.65, 0.95 if i % 2 == 0 else 0.7) for i in range(24)]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=entrada)
mallas = sorted([o for o in bpy.context.scene.objects if o.type == "MESH"], key=lambda o: o.name)
for i, o in enumerate(mallas):
    mat = bpy.data.materials.new(o.name)
    mat.use_nodes = True
    mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*COLORES[i % len(COLORES)], 1)
    mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.7
    o.data.materials.clear()
    o.data.materials.append(mat)


def centro(o):
    pts = [o.matrix_world @ Vector(c) for c in o.bound_box]
    return sum(pts, Vector()) / 8


centros = {o.name: centro(o) for o in mallas}
c_total = sum(centros.values(), Vector()) / len(mallas)
pts = [o.matrix_world @ Vector(c) for o in mallas for c in o.bound_box]
tam = max(max(p[k] for p in pts) - min(p[k] for p in pts) for k in range(3))

escena = bpy.context.scene
escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in [
    e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items] else "BLENDER_EEVEE"
escena.render.resolution_x = escena.render.resolution_y = 512
escena.render.film_transparent = False
mundo = bpy.data.worlds.new("w")
mundo.use_nodes = True
mundo.node_tree.nodes["Background"].inputs[0].default_value = (1, 1, 1, 1)
mundo.node_tree.nodes["Background"].inputs[1].default_value = 0.6
escena.world = mundo
sol = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN"))
sol.data.energy = 2.0
sol.rotation_euler = (math.radians(45), 0, math.radians(35))
escena.collection.objects.link(sol)
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
cam.data.type = "ORTHO"
escena.collection.objects.link(cam)
escena.camera = cam

base = {o.name: o.location.copy() for o in mallas}
cuadros = []
tmp = os.path.splitext(salida)[0] + "_tmp"
os.makedirs(tmp, exist_ok=True)
# Blender: Z arriba. El GLB (Y arriba, cabeza en +Z) entra con la cabeza hacia -Y.
for despiece in (0.0, factor):
    for o in mallas:
        o.location = base[o.name] + (centros[o.name] - c_total) * despiece
    for ang in (35, 90):
        a = math.radians(ang)
        d = tam * 3
        cam.location = (c_total.x + d * math.sin(a), c_total.y - d * math.cos(a), c_total.z + tam * 0.5)
        cam.rotation_euler = (math.radians(80), 0, a)
        cam.data.ortho_scale = tam * (1.25 + despiece * 1.6)
        ruta = os.path.join(tmp, f"{despiece}_{ang}.png")
        escena.render.filepath = ruta
        bpy.ops.render.render(write_still=True)
        cuadros.append(ruta)

# Hoja 2x2.
hoja = bpy.data.images.new("hoja", 1024, 1024)
pix = [0.0] * (1024 * 1024 * 4)
for k, ruta in enumerate(cuadros):
    im = bpy.data.images.load(ruta)
    p = list(im.pixels)
    ox, oy = (k % 2) * 512, (1 - k // 2) * 512
    for y in range(512):
        fila = p[y * 512 * 4:(y + 1) * 512 * 4]
        ini = ((oy + y) * 1024 + ox) * 4
        pix[ini:ini + 512 * 4] = fila
hoja.pixels = pix
hoja.filepath_raw = salida
hoja.file_format = "PNG"
hoja.save()
print("ok", salida, [o.name for o in mallas])
