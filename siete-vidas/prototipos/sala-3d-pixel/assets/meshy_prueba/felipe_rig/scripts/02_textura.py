# Paso 2: UV nuevas (Smart UV Project) y horneado del color difuso (solo color, sin luz)
# desde la malla original de Meshy, en Cycles con "Selected to Active".
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

TAM = 2048
bpy.ops.wm.open_mainfile(filepath=C.BLEND_RETOPO)
orig = bpy.data.objects["Original"]
retopo = bpy.data.objects["Retopo"]

# UV: islas por ángulo, con margen para que el horneado no se mezcle entre islas.
bpy.ops.object.select_all(action="DESELECT")
bpy.context.view_layer.objects.active = retopo
retopo.select_set(True)
while retopo.data.uv_layers:
    retopo.data.uv_layers.remove(retopo.data.uv_layers[0])
retopo.data.uv_layers.new(name="UVMap")
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.004, area_weight=0.0, scale_to_bounds=False)
bpy.ops.uv.pack_islands(margin=0.004, rotate=True)
bpy.ops.object.mode_set(mode="OBJECT")

# Material nuevo con la imagen de destino como nodo activo.
img = bpy.data.images.new("felipe_rig_color", TAM, TAM, alpha=False)
img.generated_color = (1, 0, 1, 1)
mat = bpy.data.materials.new("FelipeRig")
mat.use_nodes = True
nt = mat.node_tree
bsdf = nt.nodes.get("Principled BSDF")
bsdf.inputs["Roughness"].default_value = 0.85
tex = nt.nodes.new("ShaderNodeTexImage")
tex.image = img
nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
nt.nodes.active = tex
retopo.data.materials.clear()
retopo.data.materials.append(mat)

sc = bpy.context.scene
sc.render.engine = "CYCLES"
sc.cycles.device = "CPU"
sc.cycles.samples = 4
bk = sc.render.bake
bk.use_selected_to_active = True
bk.use_cage = False
bk.cage_extrusion = 0.012
bk.max_ray_distance = 0.04
bk.margin = 12
bk.margin_type = "EXTEND"
bpy.ops.object.select_all(action="DESELECT")
orig.select_set(True)
retopo.select_set(True)
bpy.context.view_layer.objects.active = retopo
bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, use_selected_to_active=True,
                    cage_extrusion=0.012, max_ray_distance=0.04, margin=12)
ruta = os.path.join(C.TRABAJO, "felipe_rig_color.png")
img.filepath_raw = ruta
img.file_format = "PNG"
img.save()
# Copia sin retoques: de aquí parte 02b_lomo.py (que repinta el lomo sobre felipe_rig_color.png).
img.filepath_raw = os.path.join(C.TRABAJO, "felipe_rig_color_horneado.png")
img.save()
img.filepath_raw = ruta
# Rosado puro = texel sin dato (rayo que no encontró la original).
px = list(img.pixels)
sin = sum(1 for i in range(0, len(px), 4) if px[i] > 0.99 and px[i + 1] < 0.01 and px[i + 2] > 0.99)
print("texels sin dato (rosado):", sin, "de", TAM * TAM)
img.filepath = ruta
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_TEXTURA)
print("guardado", C.BLEND_TEXTURA, ruta)
