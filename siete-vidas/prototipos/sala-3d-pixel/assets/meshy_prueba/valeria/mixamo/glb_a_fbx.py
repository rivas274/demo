"""GLB -> FBX con textura incrustada, de pie y escalado a una altura dada (para subir a Mixamo).

Uso: blender -b -P glb_a_fbx.py -- <entrada.glb> <salida.fbx> [altura_m=1.65]
"""
import sys

import bpy

args = sys.argv[sys.argv.index("--") + 1:]
entrada, salida = args[0], args[1]
altura = float(args[2]) if len(args) > 2 else 1.65

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=entrada)
mallas = [o for o in bpy.context.scene.objects if o.type == "MESH"]
for o in bpy.context.scene.objects:
    o.select_set(o in mallas)
bpy.context.view_layer.objects.active = mallas[0]
if len(mallas) > 1:
    bpy.ops.object.join()
obj = bpy.context.view_layer.objects.active
obj.parent = None
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Escala a la altura pedida y pies en el suelo (Z arriba en Blender), centrado en X/Y.
zs = [v.co.z for v in obj.data.vertices]
xs = [v.co.x for v in obj.data.vertices]
ys = [v.co.y for v in obj.data.vertices]
escala = altura / (max(zs) - min(zs))
obj.scale = (escala, escala, escala)
bpy.ops.object.transform_apply(scale=True)
zs = [v.co.z for v in obj.data.vertices]
obj.location = (-(min(xs) + max(xs)) / 2 * escala, -(min(ys) + max(ys)) / 2 * escala, -min(zs))
bpy.ops.object.transform_apply(location=True)

bpy.ops.export_scene.fbx(filepath=salida, use_selection=True, path_mode="COPY", embed_textures=True,
                         axis_forward="-Z", axis_up="Y", apply_scale_options="FBX_SCALE_ALL")
print("ok", salida, "caras:", len(obj.data.polygons), "altura:", altura)
