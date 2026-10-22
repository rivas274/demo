# Paso 5 y 6: animación a mano con poses clave (Bezier) y exportación a glTF.
# - Pasa todo a metros (alto total de Felipe = 67 px / 121 px/m).
# - Controles IK de animador para cada pie (pie apoyado clavado en el piso, sin patinar),
#   polos de rodilla y codo; los dedos y la escápula se animan aparte.
# - "caminar": 22 cuadros a 24 fps (0,92 s), secuencia lateral (TI, DI, TD, DD), 8 poses
#   clave por pata: contacto, bajada, apoyo, talón arriba, despegue, recoge (alto), paso y
#   estira. Grupa y hombros suben y bajan por turnos, el lomo ondula, cabeza baja y
#   adelantada, cola a media altura en gancho con la punta retrasada.
# - "quieto": 72 cuadros (3 s): respiración, cola lenta, mirada y una oreja que se mueve.
# - Se hornea a los huesos que deforman (visual keying), se borran los controles y se exporta.
import sys, os, math, json, bpy, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

V = mathutils.Vector
Q = mathutils.Quaternion
FPS = 24
N_CAMINAR = 22
N_QUIETO = 72
DUTY = 0.6            # fracción del ciclo con el pie apoyado
ZANCADA_U = 0.30      # largo del paso en unidades de Meshy (antes de pasar a metros)
ALZA_TRAS_U = 0.065
ALZA_DEL_U = 0.08
FASE = {"thigh.L": 0.0, "upper_arm.L": 0.25, "thigh.R": 0.5, "upper_arm.R": 0.75}

bpy.ops.wm.open_mainfile(filepath=C.BLEND_RIG)
sc = bpy.context.scene
sc.render.fps = FPS
malla = bpy.data.objects["Felipe"]
arm = bpy.data.objects["FelipeRig"]
if "Original" in bpy.data.objects:
    bpy.data.objects.remove(bpy.data.objects["Original"])

# --- A metros: escala aplicada a armadura y malla.
alto_u = max((malla.matrix_world @ v.co).z for v in malla.data.vertices)
K = C.ALTO_M / alto_u
print("alto %.4f u -> %.4f m (K=%.5f)" % (alto_u, C.ALTO_M, K))
# Se separa la malla, se escalan y aplican las dos, y se vuelve a emparentar sin desfase.
bpy.ops.object.select_all(action="DESELECT")
malla.select_set(True)
bpy.context.view_layer.objects.active = malla
bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
for o in (arm, malla):
    o.scale = (K, K, K)
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
malla.parent = arm
malla.matrix_parent_inverse = mathutils.Matrix.Identity(4)
print("malla alto ahora:", max((malla.matrix_world @ v.co).z for v in malla.data.vertices))
ZANCADA = ZANCADA_U * K
ALZA = {"thigh": ALZA_TRAS_U * K, "upper_arm": ALZA_DEL_U * K}

# --- Controles de animador (no deforman).
bpy.context.view_layer.objects.active = arm
arm.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
eb = arm.data.edit_bones
CTL = {}
for lado in ("L", "R"):
    for pata, (ik_hueso, pie, dedo) in {"tras": ("shin", "foot", "r_toe"), "del": ("forearm", "hand", "f_toe")}.items():
        b_pie, b_dedo, b_ik = eb[pie + "." + lado], eb[dedo + "." + lado], eb[ik_hueso + "." + lado]
        bola = b_dedo.head.copy()  # bola del pie: pivote del talón
        c = eb.new("ctl_%s.%s" % (pata, lado))
        c.head = bola; c.tail = bola + V((0, 0, 0.04)); c.roll = 0; c.parent = eb["root"]; c.use_deform = False
        # Objetivo IK = copia del pie (mismo reposo), hijo del control: su cabeza es el talón
        # o la muñeca y su giro es el que copia el pie.
        t = eb.new("ik_%s.%s" % (pata, lado))
        t.head = b_pie.head.copy(); t.tail = b_pie.tail.copy(); t.roll = b_pie.roll; t.parent = c; t.use_deform = False
        codo = b_ik.head.copy()
        p = eb.new("polo_%s.%s" % (pata, lado))
        p.head = codo + V((0, -0.12, 0)); p.tail = p.head + V((0, 0, 0.02)); p.parent = eb["root"]; p.use_deform = False
        CTL[(pata, lado)] = (c.name, t.name, p.name, ik_hueso + "." + lado, pie + "." + lado, dedo + "." + lado)
bpy.ops.object.mode_set(mode="POSE")
pbs = arm.pose.bones
for pb in pbs:
    pb.rotation_mode = "QUATERNION"
for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
    ik = pbs[ikb].constraints.new("IK")
    ik.target = arm; ik.subtarget = t
    ik.pole_target = arm; ik.pole_subtarget = p
    ik.chain_count = 2
    cr = pbs[pie].constraints.new("COPY_ROTATION")
    cr.target = arm; cr.subtarget = c
    cr.target = arm; cr.subtarget = t
    cr.target_space = "WORLD"; cr.owner_space = "WORLD"


def error_reposo():
    bpy.context.view_layer.update()
    e = 0.0
    for b in arm.data.bones:
        if b.name.startswith(("ctl_", "ik_", "polo_")):
            continue
        e += (pbs[b.name].matrix.translation - b.matrix_local.translation).length
        e += (pbs[b.name].matrix.col[1].xyz - b.matrix_local.col[1].xyz).length
    return e


# Ángulo de polo que deja la pose de reposo intacta.
for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
    ik = pbs[ikb].constraints["IK"]
    mejor = min(range(-180, 180, 5), key=lambda g: (setattr(ik, "pole_angle", math.radians(g)), error_reposo())[1])
    mejor = min([mejor + d for d in range(-5, 6)], key=lambda g: (setattr(ik, "pole_angle", math.radians(g)), error_reposo())[1])
    ik.pole_angle = math.radians(mejor)
    print("polo", ikb, mejor, "grados")
print("error en reposo con IK: %.5f" % error_reposo())


# --- Ayudas de claves.
def q_mundo(nombre, eje, grados):
    """Giro alrededor de un eje del mundo, expresado en el espacio local de reposo del hueso."""
    r = arm.data.bones[nombre].matrix_local.to_quaternion()
    return r.inverted() @ Q(V(eje), math.radians(grados)) @ r


def giro(nombre, *giros):
    q = Q()
    for eje, g in giros:
        q = q_mundo(nombre, eje, g) @ q
    return q


def clave(nombre, f, rot=None, loc=None, interp="BEZIER"):
    pb = pbs[nombre]
    if rot is not None:
        pb.rotation_quaternion = rot
        pb.keyframe_insert("rotation_quaternion", frame=f)
    if loc is not None:
        pb.location = loc
        pb.keyframe_insert("location", frame=f)
    return pb


def loc_mundo(nombre, desp):
    """Desplazamiento en el mundo -> location local del hueso (para controles y columna)."""
    m = arm.data.bones[nombre].matrix_local.to_3x3()
    return m.inverted() @ V(desp)


def suavizar(accion, ciclo=True):
    for fc in todas_fcurves(accion):
        if ciclo and not any(m.type == "CYCLES" for m in fc.modifiers):
            fc.modifiers.new("CYCLES")
        for k in fc.keyframe_points:
            if k.interpolation != "LINEAR":
                k.interpolation = "BEZIER"
                k.easing = "AUTO"
                k.handle_left_type = k.handle_right_type = "AUTO_CLAMPED"
        fc.update()


def todas_fcurves(accion):
    try:
        return list(accion.fcurves)
    except AttributeError:  # Blender 5: acciones por capas y ranuras
        out = []
        for capa in accion.layers:
            for tira in capa.strips:
                for bolsa in tira.channelbags:
                    out.extend(bolsa.fcurves)
        return out


def lineal(accion, hueso, frames):
    """Marca como lineal el tramo que empieza en cada cuadro dado (pie apoyado)."""
    for fc in todas_fcurves(accion):
        if ('"%s"' % hueso) in fc.data_path and fc.data_path.endswith("location"):
            for k in fc.keyframe_points:
                if any(abs(k.co.x - f) < 1e-3 for f in frames):
                    k.interpolation = "LINEAR"


def nueva_accion(nombre):
    if nombre in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[nombre])
    a = bpy.data.actions.new(nombre)
    a.use_fake_user = True
    if arm.animation_data is None:
        arm.animation_data_create()
    arm.animation_data.action = a
    for pb in pbs:
        pb.rotation_quaternion = Q(); pb.location = (0, 0, 0)
    return a


def ciclo(p):
    return p % 1.0


# =========================== CAMINAR ===========================
a_cam = nueva_accion("caminar")
N = N_CAMINAR
# Poses clave de cada pata: (fase, avance en y [-1 adelante .. +1 atrás] * zancada/2,
# alto [0..1] * alza, giro del control [grados, + = talón arriba], giro de los dedos).
POSES_PATA = [
    (0.00, -1.00, 0.00, 0, 0),     # contacto
    (0.10, -0.667, 0.00, 0, 0),    # bajada (recibe el peso)
    (0.30, 0.00, 0.00, 0, 0),      # apoyo medio
    (0.50, 0.667, 0.00, 22, -22),  # talón arriba, dedos planos
    (0.60, 1.00, 0.00, 48, -48),   # despegue
    (0.70, 0.55, 1.00, 70, -10),   # recoge: la pata doblada, lo más alto
    (0.82, -0.25, 0.85, 25, -5),   # paso: pasa por debajo hacia adelante
    (0.92, -1.08, 0.30, -6, 4),    # estira para apoyar
]
for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
    clave_fase = FASE[("thigh." if pata == "tras" else "upper_arm.") + lado]
    alza = ALZA["thigh" if pata == "tras" else "upper_arm"]
    lineales = []
    # Cuadro de cada pose dentro de [0, N); la primera se repite un ciclo después, así el
    # rango de claves mide justo N y el modificador Cycles repite con el período correcto.
    claves = sorted(((fase + clave_fase) * N % N, fase, av, al, g, gd) for fase, av, al, g, gd in POSES_PATA)
    claves.append((claves[0][0] + N,) + claves[0][1:])
    for f2, fase, av, al, g, gd in claves:
        desp = (0, av * ZANCADA / 2, al * alza)
        clave(c, f2, rot=q_mundo(c, (1, 0, 0), g), loc=loc_mundo(c, desp))
        clave(dedo, f2, rot=q_mundo(dedo, (1, 0, 0), gd))
        if pata == "del":
            # Escápula: acompaña a la mano (adelante cuando la mano va adelante).
            clave("shoulder." + lado, f2, rot=q_mundo("shoulder." + lado, (1, 0, 0), 10 * av))
        if fase < DUTY - 1e-6:
            lineales.append(f2)
    lineal(a_cam, c, lineales)

# Cuerpo: 8 poses clave por ciclo (cada 1/8), con funciones periódicas para cada canal.
def s(p, fase=0.0, veces=1):
    return math.sin(2 * math.pi * veces * (p - fase))

BAJA = 0.014 * K         # cuánto bajan grupa y hombros al recibir el peso
LOMO = 0.38 * K          # largo del lomo, para pasar diferencia de alturas a ángulo
for i in range(9):
    p = i / 8.0
    f = p * N
    # Grupa baja justo después de cada contacto trasero (0 y 0,5); hombros después de los delanteros.
    grupa = -BAJA * (0.5 + 0.5 * math.cos(4 * math.pi * (p - 0.10)))
    hombro = -BAJA * (0.5 + 0.5 * math.cos(4 * math.pi * (p - 0.35)))
    lado_x = 0.008 * K * s(p, 0.15)
    clave("spine", f, loc=loc_mundo("spine", (lado_x, 0, grupa)),
          rot=giro("spine", ((0, 1, 0), 3.0 * s(p, 0.1)), ((0, 0, 1), 2.5 * s(p, 0.05))))
    # Ondulación del lomo: inclinación (hombros vs. grupa) y giro lateral en contrafase.
    dif = (hombro - grupa) / LOMO  # radianes aprox.
    clave("spine.001", f, rot=giro("spine.001", ((1, 0, 0), -math.degrees(dif) * 0.5), ((0, 0, 1), -1.5 * s(p, 0.12))))
    clave("spine.002", f, rot=giro("spine.002", ((1, 0, 0), -math.degrees(dif) * 0.5), ((0, 0, 1), -1.5 * s(p, 0.2)),
                                    ((0, 1, 0), -2.5 * s(p, 0.35))))
    clave("spine.003", f, rot=giro("spine.003", ((1, 0, 0), 2.0)))
    # Cabeza baja y adelantada; se mece poco (los gatos estabilizan la cabeza), con retraso.
    clave("spine.004", f, rot=giro("spine.004", ((1, 0, 0), 22 + 1.2 * s(p, 0.45, 2))))
    clave("spine.006", f, rot=giro("spine.006", ((1, 0, 0), -9 - 1.2 * s(p, 0.5, 2)), ((0, 0, 1), 2.0 * s(p, 0.3))))
    # Cola a media altura en gancho: la base se echa atrás, la punta se curva y se mece con retraso.
    clave("tail.001", f, rot=giro("tail.001", ((1, 0, 0), 2 + 2 * s(p, 0.2, 2)), ((0, 0, 1), 5 * s(p, 0.25))))
    clave("tail.002", f, rot=giro("tail.002", ((1, 0, 0), -22 + 3 * s(p, 0.3, 2)), ((0, 0, 1), 7 * s(p, 0.37))))
    clave("tail.003", f, rot=giro("tail.003", ((1, 0, 0), -8 + 4 * s(p, 0.4, 2)), ((0, 0, 1), 9 * s(p, 0.49))))
    clave("tail.004", f, rot=giro("tail.004", ((1, 0, 0), 36 + 6 * s(p, 0.5, 2)), ((0, 0, 1), 12 * s(p, 0.61))))
    clave("ear.L", f, rot=giro("ear.L", ((1, 0, 0), -4)))
    clave("ear.R", f, rot=giro("ear.R", ((1, 0, 0), -4)))
suavizar(a_cam)

# =========================== QUIETO ===========================
a_qui = nueva_accion("quieto")
N = N_QUIETO
for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
    for f in (0, N):
        clave(c, f, rot=Q(), loc=(0, 0, 0))
        clave(dedo, f, rot=Q())
for i in range(13):
    p = i / 12.0
    f = p * N
    resp = s(p, 0.0, 2)  # 2 respiraciones en 3 s
    clave("spine", f, loc=loc_mundo("spine", (0, 0, 0.004 * K * resp)))
    clave("spine.001", f, rot=giro("spine.001", ((1, 0, 0), -0.6 * resp)))
    clave("spine.002", f, rot=giro("spine.002", ((1, 0, 0), -0.8 * resp)))
    clave("spine.004", f, rot=giro("spine.004", ((1, 0, 0), 0.8 * s(p, 0.1, 2))))
    clave("spine.006", f, rot=giro("spine.006", ((0, 0, 1), 5 * s(p, 0.15)), ((1, 0, 0), 1.5 * s(p, 0.4))))
    clave("tail.001", f, rot=giro("tail.001", ((0, 0, 1), 4 * s(p, 0.0))))
    clave("tail.002", f, rot=giro("tail.002", ((0, 0, 1), 6 * s(p, 0.07)), ((1, 0, 0), 2 * s(p, 0.1, 2))))
    clave("tail.003", f, rot=giro("tail.003", ((0, 0, 1), 8 * s(p, 0.14))))
    clave("tail.004", f, rot=giro("tail.004", ((0, 0, 1), 12 * s(p, 0.22)), ((1, 0, 0), 6 * s(p, 0.3, 2))))
# Oreja: un respingo rápido hacia atrás cerca de los 2 s.
for f, g in ((0, 0), (44, 0), (47, -22), (50, -4), (54, -16), (60, 0), (N, 0)):
    clave("ear.L", f, rot=giro("ear.L", ((1, 0, 0), g), ((0, 0, 1), g * 0.5)))
for f in (0, N):
    clave("ear.R", f, rot=Q())
suavizar(a_qui)


# --- Horneado a los huesos que deforman.
def hornear(accion, n):
    arm.animation_data.action = accion
    bpy.ops.object.mode_set(mode="POSE")
    for pb in pbs:
        try:
            pb.select = True
        except AttributeError:
            pb.bone.select = True
    sc.frame_start, sc.frame_end = 0, n
    bpy.ops.nla.bake(frame_start=0, frame_end=n, only_selected=False, visual_keying=True,
                     clear_constraints=False, clear_parents=False, use_current_action=True,
                     clean_curves=False, bake_types={"POSE"}, channel_types={"LOCATION", "ROTATION"})
    hecha = arm.animation_data.action
    hecha.name = accion.name if hecha != accion else hecha.name
    return hecha


# Medir que el pie apoyado no patina (antes de borrar los controles).
def medir_patinaje(accion, n):
    """Mayor corrimiento (en el mundo) de la bola de un pie apoyado, con el cuerpo avanzando."""
    arm.animation_data.action = accion
    peor = 0.0
    for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
        fase0 = FASE[("thigh." if pata == "tras" else "upper_arm.") + lado]
        pts = []
        for f in range(n):
            pf = ((f / n) - fase0) % 1.0
            if 0.0 <= pf <= 0.45:   # apoyo con el pie plano (después sube el talón)
                sc.frame_set(f)
                pos = arm.matrix_world @ pbs[dedo].head
                pts.append(V((pos.x, pos.y - VEL * pf * n / FPS, pos.z)))
        for q in pts:
            peor = max(peor, (q - pts[0]).length)
        if os.environ.get("FELIPE_DEPURAR"):
            print(dedo, ["%.3f,%.3f" % (q.y, q.z) for q in pts])
    return peor


VEL = ZANCADA / (DUTY * N_CAMINAR / FPS)
print("velocidad de avance: %.4f m/s" % VEL)
pat = medir_patinaje(a_cam, N_CAMINAR)
print("patinaje máximo del pie apoyado: %.2f mm" % (pat * 1000))
# Distancia de la cadera/hombro a la bola del pie: que el IK alcance (sin estirar de más).
arm.animation_data.action = a_cam
falta = 0.0
for f in range(N_CAMINAR + 1):
    sc.frame_set(f)
    for (pata, lado), (c, t, p, ikb, pie, dedo) in CTL.items():
        falta = max(falta, (pbs[pie].head - pbs[t].head).length)
print("distancia máxima IK (talón/muñeca a su objetivo): %.2f mm" % (falta * 1000))

b_cam = hornear(a_cam, N_CAMINAR)
b_qui = hornear(a_qui, N_QUIETO)

# Borrar controles y restricciones; dejar solo canales de los huesos que exporta Godot.
bpy.ops.object.mode_set(mode="POSE")
for pb in pbs:
    for cn in list(pb.constraints):
        pb.constraints.remove(cn)
for acc in (b_cam, b_qui):
    for fc in todas_fcurves(acc):
        if any(('"%s' % x) in fc.data_path for x in ("ctl_", "ik_", "polo_")):
            fc.mute = True
bpy.ops.object.mode_set(mode="EDIT")
for b in list(arm.data.edit_bones):
    if b.name.startswith(("ctl_", "ik_", "polo_")):
        arm.data.edit_bones.remove(b)
bpy.ops.object.mode_set(mode="OBJECT")
for acc in (b_cam, b_qui):
    quitar = [fc for fc in todas_fcurves(acc) if fc.mute]
    for fc in quitar:
        try:
            acc.fcurves.remove(fc)
        except AttributeError:
            for capa in acc.layers:
                for tira in capa.strips:
                    for bolsa in tira.channelbags:
                        if fc in list(bolsa.fcurves):
                            bolsa.fcurves.remove(fc)
for acc in list(bpy.data.actions):
    if acc not in (b_cam, b_qui):
        bpy.data.actions.remove(acc)
b_cam.name, b_qui.name = "caminar", "quieto"
for acc in (b_cam, b_qui):
    acc.use_fake_user = True
arm.animation_data.action = b_qui
# Cada acción en su pista NLA (así el exportador las saca por separado).
for acc in (b_cam, b_qui):
    tr = arm.animation_data.nla_tracks.new()
    tr.name = acc.name
    st = tr.strips.new(acc.name, 0, acc)
    tr.mute = True
arm.animation_data.action = None
bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_ANIM)

info = {
    "velocidad_caminar_m_s": round(VEL, 4),
    "ciclo_caminar_s": round(N_CAMINAR / FPS, 4),
    "zancada_m": round(ZANCADA, 4),
    "ciclo_quieto_s": round(N_QUIETO / FPS, 4),
    "alto_m": round(C.ALTO_M, 4),
    "patinaje_max_mm": round(pat * 1000, 2),
}
with open(os.path.join(C.RIG, "felipe_rig.json"), "w") as fh:
    json.dump(info, fh, indent=2, ensure_ascii=False)
print("info", info)

# --- Exportar.
bpy.ops.object.select_all(action="DESELECT")
for o in bpy.data.objects:
    o.select_set(o in (arm, malla))
bpy.ops.export_scene.gltf(
    filepath=C.GLB_SALIDA, export_format="GLB", use_selection=True,
    export_animations=True, export_animation_mode="ACTIONS", export_skins=True,
    export_all_influences=False, export_def_bones=False, export_yup=True,
    export_apply=False, export_image_format="AUTO", export_force_sampling=True,
    export_frame_range=False, export_anim_single_armature=True, export_reset_pose_bones=True)
print("exportado", C.GLB_SALIDA, os.path.getsize(C.GLB_SALIDA) // 1024, "KB")
