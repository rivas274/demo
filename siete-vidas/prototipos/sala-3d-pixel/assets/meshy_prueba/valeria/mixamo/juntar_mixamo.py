"""Junta las animaciones de Mixamo (un FBX con piel y varios sin piel) en un solo GLB con una acción por animación,
y renderiza cuadros de cada una para revisarlas.

Uso: blender -b -P juntar_mixamo.py -- <con_piel.fbx> <salida.glb> <dir_cuadros> nombre=archivo.fbx [...]
El primer FBX (con piel) da la malla y el esqueleto; su animación se llama como el primer nombre=... que lo repite.
"""
import math
import os
import sys

import bpy

args = sys.argv[sys.argv.index("--") + 1:]
con_piel, salida, dir_cuadros = args[:3]
anims = [a.split("=", 1) for a in args[3:]]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=con_piel)
arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
malla = next(o for o in bpy.data.objects if o.type == "MESH")
acciones = {}
for nombre, ruta in anims:
    if os.path.abspath(ruta) == os.path.abspath(con_piel):
        ac = arm.animation_data.action
    else:
        antes = set(bpy.data.objects)
        bpy.ops.import_scene.fbx(filepath=ruta)
        nuevos = [o for o in bpy.data.objects if o not in antes]
        otro = next(o for o in nuevos if o.type == "ARMATURE")
        ac = otro.animation_data.action
        for o in nuevos:
            bpy.data.objects.remove(o, do_unlink=True)
    ac.name = nombre
    ac.use_fake_user = True
    acciones[nombre] = ac
    print("accion", nombre, ac.frame_range[:])

# Una pista NLA por acción: el exportador glTF las saca como animaciones separadas con su nombre.
arm.animation_data.action = None
for nombre, ac in acciones.items():
    pista = arm.animation_data.nla_tracks.new()
    pista.name = nombre
    pista.strips.new(nombre, int(ac.frame_range[0]), ac)
    pista.mute = True

bpy.ops.export_scene.gltf(filepath=salida, export_format="GLB", export_animations=True,
                          export_animation_mode="NLA_TRACKS", export_apply=False)
print("ok", salida)

# Cuadros de revisión: cámara fija en 3/4, 4 cuadros por acción.
escena = bpy.context.scene
escena.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items] else "BLENDER_EEVEE"
escena.render.resolution_x = escena.render.resolution_y = 384
mundo = bpy.data.worlds.new("w")
mundo.use_nodes = True
mundo.node_tree.nodes["Background"].inputs[0].default_value = (1, 1, 1, 1)
mundo.node_tree.nodes["Background"].inputs[1].default_value = 0.6
escena.world = mundo
sol = bpy.data.objects.new("sol", bpy.data.lights.new("sol", "SUN"))
sol.data.energy = 1.6
sol.rotation_euler = (math.radians(50), 0, math.radians(30))
escena.collection.objects.link(sol)
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
escena.collection.objects.link(cam)
escena.camera = cam
from mathutils import Vector  # noqa: E402

zs = [(malla.matrix_world @ Vector(c)).z for c in malla.bound_box]
alto = max(zs) - min(zs)  # en el mundo: el FBX de Mixamo trae la armadura a escala 0,01
cam.data.type = "ORTHO"
cam.data.ortho_scale = alto * 2.2
os.makedirs(dir_cuadros, exist_ok=True)
for pista in arm.animation_data.nla_tracks:
    pista.mute = True
for nombre, ac in acciones.items():
    arm.animation_data.action = ac
    f0, f1 = int(ac.frame_range[0]), int(ac.frame_range[1])
    for i in range(4):
        fr = f0 + (f1 - f0) * i // 4
        escena.frame_set(fr)
        # Sigue a la raíz (Walking avanza): la cámara apunta a las caderas.
        cad = arm.matrix_world @ arm.pose.bones[0].head
        cam.location = (cad.x + alto * 1.6, cad.y - alto * 1.6, alto * 0.6)
        cam.rotation_euler = (math.radians(80), 0, math.radians(45))
        escena.render.filepath = os.path.join(dir_cuadros, f"{nombre}_{i}.png")
        bpy.ops.render.render(write_still=True)
print("cuadros ok")
