# Paso 1: retopología. Importa el Felipe de Meshy, aplica transformaciones, lo centra
# (piso en z=0), lo hace SIMÉTRICO (flujo estándar: se arma simétrico en reposo y la
# asimetría la pone la animación) y hace una malla nueva de cuadriláteros con QuadriFlow,
# también simétrica (mismos anillos y mismos pesos de los dos lados).
# Mitad y soldadura elegidas con 01a_simetria_variantes.py: la mitad -X (derecha de Felipe),
# que tiene la mano delantera en su lugar (la izquierda venía 6 cm atrás, bajo el pecho) y es
# el lado donde el creador marcó el esqueleto; soldadura de 0,005 (deja la costura cerrada).
# Uso: python3 01_retopo.py [caras=8000]
import sys, os, bpy, bmesh
import numpy as np
from scipy.spatial import cKDTree
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C
import simetria as S

MITAD = "NEGATIVE_X"
SOLDADURA = 0.005
RELAJAR = int(os.environ.get("FELIPE_RELAJAR", "6"))   # pasadas de suavizado del cuerpo
PIERNA = float(os.environ.get("FELIPE_PIERNA", "0.06"))  # cuánto se inflan las patas traseras (u)

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
# Copia sin simetría (solo para comparar) y simetría de la de alta.
meshy = orig.copy(); meshy.data = orig.data.copy(); meshy.name = "Meshy"
bpy.context.collection.objects.link(meshy)
meshy.hide_render = True
S.ajustar_plano(orig)
print("manos antes:", S.patas_delanteras(meshy, C.ALTO_M / 1.6149))
print("soldados:", S.simetrizar(orig, MITAD, SOLDADURA), "costura abierta:", S.medir_costura(orig))
print("manos después:", S.patas_delanteras(orig, C.ALTO_M / 1.6149))
# Soldar toda la de alta: Meshy la trae en pedazos con grietas entre ellos; en el plano medio
# los rayos del horneado pasaban por esas grietas y pintaban una línea blanca en el lomo.
# (Las UV son por esquina de cara: soldar vértices no las cambia.)
bm = bmesh.new(); bm.from_mesh(orig.data)
antes_b = sum(1 for e in bm.edges if e.is_boundary)
bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.0015)
despues_b = sum(1 for e in bm.edges if e.is_boundary)
bm.to_mesh(orig.data); bm.free(); orig.data.update()
print("soldadura total: bordes abiertos %d -> %d, costura central %d" % (antes_b, despues_b, S.medir_costura(orig)))
bpy.ops.object.select_all(action="DESELECT")

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
# Sin la simetría de QuadriFlow: deja las dos mitades sin unir (una franja sin caras en el
# plano medio). La simetría se hace después cortando al medio y espejando (Mirror).
for intento, (sim, bordes) in enumerate([(False, True), (False, False)]):
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


def simetria_exacta(obj):
    """Empareja cada vértice con su espejo y promedia: la malla queda exactamente simétrica.
    Devuelve la peor distancia de emparejamiento (si es grande, la topología no es simétrica)."""
    co = np.array([v.co[:] for v in obj.data.vertices])
    espejo = co.copy(); espejo[:, 0] *= -1
    d, j = cKDTree(co).query(espejo)
    nuevo = co.copy()
    for i in range(len(co)):
        par = j[i]
        if j[par] != i:
            continue
        if i == par:
            nuevo[i, 0] = 0.0
        else:
            m = (co[i] + espejo[par]) / 2
            nuevo[i] = m
    for v, c in zip(obj.data.vertices, nuevo):
        v.co = c
    obj.data.update()
    no_par = int(sum(1 for i in range(len(co)) if j[j[i]] != i))
    return float(np.percentile(d, 99)), float(d.max()), no_par


# Relajar el cuerpo: la malla de Meshy trae escalones en los bordes de sus manchas viejas
# (crestas dentadas en el lomo y la grupa) y la retopo los copia al pegarse a ella. Suavizado
# laplaciano solo fuera de la cabeza (la cara y las orejas quedan como están).
from PIL import Image
from scipy import ndimage
mp = np.array(Image.open(os.path.join(C.PLANTILLA, "mascaras_perfil.png")))[..., 0]
cab = ndimage.binary_dilation(((mp >> 0) & 1).astype(bool) | ((mp >> 1) & 1).astype(bool), iterations=4)
zoff = C.CENTRO_ORIGINAL[2] - C.Z_PISO_ORIGINAL
bm = bmesh.new(); bm.from_mesh(retopo.data); bm.verts.ensure_lookup_table()
cuerpo = []
for v in bm.verts:
    px = int(np.clip(round(512 - v.co.y / C.PX), 0, 1023))
    py = int(np.clip(round(512 - (v.co.z - zoff) / C.PX), 0, 1023))
    # Solo detrás del pecho (lomo, grupa y cola): el pelo esponjado del pecho conserva su relieve.
    if not cab[py, px] and v.co.z > 0.04 and px < 690:
        cuerpo.append(v)
for _ in range(RELAJAR):
    bmesh.ops.smooth_vert(bm, verts=cuerpo, factor=0.5, use_axis_x=True, use_axis_y=True, use_axis_z=True)
bm.to_mesh(retopo.data); bm.free()
retopo.data.update()
print("relajado: %d vértices del cuerpo, %d pasadas" % (len(cuerpo), RELAJAR))

# Simetría exacta con costura cerrada: cortar al medio, quedarse con la mitad -X y espejarla
# (Mirror con recorte y soldadura en el plano medio).
bm = bmesh.new(); bm.from_mesh(retopo.data)
bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:], plane_co=(0, 0, 0),
                       plane_no=(1, 0, 0), clear_outer=True)
for v in bm.verts:
    if abs(v.co.x) < 1e-4:
        v.co.x = 0.0
bm.to_mesh(retopo.data); bm.free()
md = retopo.modifiers.new("espejo", "MIRROR")
md.use_clip = True; md.use_mirror_merge = True; md.merge_threshold = 1e-4
bpy.context.view_layer.objects.active = retopo
bpy.ops.object.modifier_apply(modifier="espejo")
bm = bmesh.new(); bm.from_mesh(retopo.data)
abiertos = sum(1 for e in bm.edges if e.is_boundary)
quads = sum(1 for f in bm.faces if len(f.verts) == 4)
print("espejada: %d caras (%d cuadriláteros), bordes abiertos %d" % (len(bm.faces), quads, abiertos))
bm.free()
p99, peor, sin_par = simetria_exacta(retopo)
print("emparejamiento de espejo: p99 %.4f, peor %.4f, vértices sin pareja %d" % (p99, peor, sin_par))

# v4: patas traseras más gruesas ("pantalón" de persa). Cada vértice de la pata se empuja
# en horizontal, alejándose del eje de la pata a su altura (no por la normal: las normales
# de esta malla son ruidosas y la superficie se arrugaba). Caída suave hacia la grupa y hacia
# la mano del pie; el lado de adentro crece poco. Después se suaviza la zona. Simétrico.
if PIERNA > 0:
    mt = ndimage.binary_dilation(((mp >> 4) & 1).astype(bool), iterations=2)
    dentro_px = ndimage.distance_transform_edt(mt)
    vs = retopo.data.vertices
    info = []
    for v in vs:
        px = int(np.clip(round(512 - v.co.y / C.PX), 0, 1023))
        py = int(np.clip(round(512 - (v.co.z - zoff) / C.PX), 0, 1023))
        if mt[py, px] and abs(v.co.x) >= 0.04:
            w = min(1.0, dentro_px[py, px] / 30.0)
            w *= float(np.clip((py - 540) / 90.0, 0, 1))
            w *= float(np.clip((880 - py) / 50.0, 0, 1)) * 0.8 + 0.2
            w *= float(np.clip((abs(v.co.x) - 0.04) / 0.05, 0, 1))
            info.append((v.index, py, w))
    # Eje de la pata por franja de altura: centro de |x| e y de sus vértices.
    franjas = {}
    for i, py, w in info:
        franjas.setdefault(py // 20, []).append(i)
    eje = {}
    for k, ids in franjas.items():
        c = np.array([(abs(vs[i].co.x), vs[i].co.y) for i in ids])
        eje[k] = c.mean(axis=0)
    mover = {}
    for i, py, w in info:
        v = vs[i]
        xc, yc = eje[py // 20]
        s_ = 1.0 if v.co.x > 0 else -1.0
        d = np.array([abs(v.co.x) - xc, v.co.y - yc])
        n = np.linalg.norm(d)
        if n < 1e-6:
            continue
        d /= n
        k = 1.0 if d[0] >= -0.2 else 0.35            # adentro (hacia la otra pata), poco
        mover[i] = (d[0] * s_ * PIERNA * w * k, d[1] * PIERNA * w * k * 0.8)
    for i, (dx, dy) in mover.items():
        vs[i].co.x += dx; vs[i].co.y += dy
    retopo.data.update()
    bm = bmesh.new(); bm.from_mesh(retopo.data); bm.verts.ensure_lookup_table()
    zona_s = [bm.verts[i] for i in mover]
    for _ in range(3):
        bmesh.ops.smooth_vert(bm, verts=zona_s, factor=0.5, use_axis_x=True, use_axis_y=True, use_axis_z=True)
    bm.to_mesh(retopo.data); bm.free(); retopo.data.update()
    p99, peor, sin_par = simetria_exacta(retopo)
    print("patas traseras infladas %.3f u en %d vértices (simetría: peor %.5f)" % (PIERNA, len(mover), peor))
for p in retopo.data.polygons:
    p.use_smooth = True
print("final:", len(retopo.data.vertices), "vértices,", len(retopo.data.polygons), "caras")
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_RETOPO)
print("guardado", C.BLEND_RETOPO)
