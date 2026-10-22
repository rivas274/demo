# Simetría del Felipe de Meshy (el flujo estándar: el personaje se modela y se arma simétrico
# en reposo; la asimetría la pone la animación).
# - ajustar_plano: busca el plano medio real (desplazamiento en X y giro alrededor de Z) que
#   minimiza la distancia entre la malla y su espejo, y lo lleva a X = 0.
# - simetrizar: Symmetrize de Blender (copia una mitad sobre la otra, con sus UV: la textura
#   queda espejada) y soldadura de la costura central.
import math, bpy, bmesh, mathutils
import numpy as np
from scipy.spatial import cKDTree


def error_espejo(pts, x0, yaw_deg):
    """Distancia media entre los puntos y su espejo respecto del plano x = x0 girado yaw."""
    c, s = math.cos(math.radians(yaw_deg)), math.sin(math.radians(yaw_deg))
    q = pts.copy()
    q[:, 0] -= x0
    x = c * q[:, 0] + s * q[:, 1]
    y = -s * q[:, 0] + c * q[:, 1]
    q[:, 0], q[:, 1] = x, y
    arbol = cKDTree(q)
    m = q.copy(); m[:, 0] *= -1
    d, _ = arbol.query(m)
    return float(np.mean(d))


def ajustar_plano(obj, n=12000, semilla=3):
    pts = np.array([v.co[:] for v in obj.data.vertices])
    rng = np.random.default_rng(semilla)
    pts = pts[rng.choice(len(pts), min(n, len(pts)), replace=False)]
    mejor = (error_espejo(pts, 0, 0), 0.0, 0.0)
    for x0 in np.arange(-0.03, 0.0301, 0.003):
        for yaw in np.arange(-4, 4.01, 1.0):
            e = error_espejo(pts, x0, yaw)
            if e < mejor[0]:
                mejor = (e, x0, yaw)
    _, bx, by = mejor
    for x0 in np.arange(bx - 0.003, bx + 0.0031, 0.0005):
        for yaw in np.arange(by - 1, by + 1.01, 0.25):
            e = error_espejo(pts, x0, yaw)
            if e < mejor[0]:
                mejor = (e, x0, yaw)
    e, x0, yaw = mejor
    print("plano medio: x0 = %.4f, giro = %.2f°, error de espejo %.4f (sin ajustar %.4f)"
          % (x0, yaw, e, error_espejo(pts, 0, 0)))
    m = mathutils.Matrix.Rotation(math.radians(yaw), 4, "Z") @ mathutils.Matrix.Translation((-x0, 0, 0))
    obj.data.transform(m)
    obj.data.update()
    return x0, yaw, e


def simetrizar(obj, mitad="NEGATIVE_X", umbral=0.002):
    """mitad: la que se conserva ("NEGATIVE_X" copia -X sobre +X)."""
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.symmetrize(direction=mitad, threshold=umbral)
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    # Soldar la costura: solo los vértices pegados al plano medio.
    bm = bmesh.new(); bm.from_mesh(obj.data)
    centro = [v for v in bm.verts if abs(v.co.x) < umbral * 2]
    antes = len(bm.verts)
    bmesh.ops.remove_doubles(bm, verts=centro, dist=umbral)
    bm.to_mesh(obj.data); bm.free()
    obj.data.update()
    return antes - len(obj.data.vertices)


def medir_costura(obj, ancho=0.01):
    """Aristas de borde (sin cerrar) cerca del plano medio y vértices sobre él."""
    bm = bmesh.new(); bm.from_mesh(obj.data)
    bordes = sum(1 for e in bm.edges if e.is_boundary and all(abs(v.co.x) < ancho for v in e.verts))
    bm.free()
    return bordes


def patas_delanteras(obj, k):
    """Centro (y) de cada mano delantera cerca del piso, en metros (k = metros por unidad)."""
    pts = np.array([v.co[:] for v in obj.data.vertices]) * k
    out = {}
    for s, l in ((1, "L"), (-1, "R")):
        sel = pts[(pts[:, 2] < 0.035) & (pts[:, 1] > -0.25) & (pts[:, 1] < -0.05) & (pts[:, 0] * s > 0.01)]
        out[l] = (float(sel[:, 0].mean() * s), float(sel[:, 1].mean())) if len(sel) else None
    return out
