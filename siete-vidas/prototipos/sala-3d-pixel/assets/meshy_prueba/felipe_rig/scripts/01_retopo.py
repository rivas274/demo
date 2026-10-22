# Paso 1: retopología. Importa el Felipe de Meshy, aplica transformaciones, lo centra
# (piso en z=0) y hace una malla nueva de cuadriláteros con QuadriFlow.
# Uso: python3 01_retopo.py [caras=8000]
import sys, os, bpy, bmesh
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

CARAS = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=C.GLB_ORIGINAL)
orig = [o for o in bpy.data.objects if o.type == "MESH"][0]
orig.name = "Original"
bpy.context.view_layer.objects.active = orig
orig.select_set(True)
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
ws = [v.co for v in orig.data.vertices]
mn = [min(v[i] for v in ws) for i in range(3)]
mx = [max(v[i] for v in ws) for i in range(3)]
centro = [(mn[i] + mx[i]) / 2 for i in range(3)]
print("AABB", mn, mx, "centro", centro)
desp = (-centro[0], -centro[1], -mn[2])
for v in orig.data.vertices:
    v.co.x += desp[0]; v.co.y += desp[1]; v.co.z += desp[2]
orig.data.update()

# Islas sueltas de la original (solo informativo: el remallado por vóxeles las une).
bm = bmesh.new(); bm.from_mesh(orig.data)
bm.verts.ensure_lookup_table()
visto = set(); islas = []
for v in bm.verts:
    if v.index in visto:
        continue
    pila = [v]; n = 0; visto.add(v.index)
    while pila:
        a = pila.pop(); n += 1
        for e in a.link_edges:
            o = e.other_vert(a)
            if o.index not in visto:
                visto.add(o.index); pila.append(o)
    islas.append(n)
bm.free()
islas.sort(reverse=True)
print("islas de la original:", len(islas), islas[:10])

# Copia de trabajo sin material ni UV: vóxeles (cerrada, sin islas) y luego QuadriFlow.
retopo = orig.copy(); retopo.data = orig.data.copy(); retopo.name = "Retopo"
bpy.context.collection.objects.link(retopo)
retopo.data.materials.clear()
bpy.ops.object.select_all(action="DESELECT")
bpy.context.view_layer.objects.active = retopo
retopo.select_set(True)
retopo.data.remesh_voxel_size = 0.006
retopo.data.use_remesh_fix_poles = True
bpy.ops.object.voxel_remesh()
print("vóxeles:", len(retopo.data.polygons), "caras")

# Pieza principal: si quedaron islas sueltas, se borran las chicas.
bm = bmesh.new(); bm.from_mesh(retopo.data); bm.verts.ensure_lookup_table()
visto = set(); grupos = []
for v in bm.verts:
    if v.index in visto:
        continue
    pila = [v]; g = []; visto.add(v.index)
    while pila:
        a = pila.pop(); g.append(a)
        for e in a.link_edges:
            o = e.other_vert(a)
            if o.index not in visto:
                visto.add(o.index); pila.append(o)
    grupos.append(g)
grupos.sort(key=len, reverse=True)
print("islas tras vóxeles:", [len(g) for g in grupos[:5]])
for g in grupos[1:]:
    bmesh.ops.delete(bm, geom=g, context="VERTS")
bm.to_mesh(retopo.data); bm.free()

ok = False
for intento, (sim, bordes) in enumerate([(True, True), (False, True), (False, False)]):
    try:
        r = bpy.ops.object.quadriflow_remesh(
            use_mesh_symmetry=sim, use_preserve_sharp=bordes, use_preserve_boundary=bordes,
            preserve_attributes=False, smooth_normals=True, mode="FACES",
            target_faces=CARAS, seed=7)
        n = len(retopo.data.polygons)
        quads = sum(1 for p in retopo.data.polygons if len(p.vertices) == 4)
        print("quadriflow", r, "simetría", sim, "->", n, "caras,", quads, "cuadriláteros")
        if n > 1000 and quads > 0.9 * n:
            ok = True
            break
    except Exception as e:
        print("quadriflow falló", sim, bordes, e)
if not ok:
    raise SystemExit("QuadriFlow no dio una malla usable")

# Suavizado leve para que los anillos queden parejos, reproyectado sobre la original.
mod = retopo.modifiers.new("ajuste", "SHRINKWRAP")
mod.target = orig
mod.wrap_method = "PROJECT"
mod.use_negative_direction = True
mod.use_positive_direction = True
bpy.ops.object.modifier_apply(modifier="ajuste")
for p in retopo.data.polygons:
    p.use_smooth = True
print("final:", len(retopo.data.vertices), "vértices,", len(retopo.data.polygons), "caras")
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_RETOPO)
print("guardado", C.BLEND_RETOPO)
