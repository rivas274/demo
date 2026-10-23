# Base de la animación de Felipe en Blender (bpy): prepara el rig en metros, arma los
# controles de animador (IK de pies y manos con polos), da ayudas para poner poses clave
# en ejes del mundo, la cola con "overlapping action" y el horneado y la exportación.
# Felipe mira hacia -Y, arriba es +Z, su lado izquierdo (.L) es +X.
import os, sys, math, bpy, mathutils
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C

V = mathutils.Vector
Q = mathutils.Quaternion
FPS = 24
COLA = ["tail.001", "tail.002", "tail.003", "tail.004", "tail.005"]
# Amplitud de la onda de la cola por hueso: base casi quieta, punta con el mayor movimiento.
AMP_COLA = [0.25, 0.5, 0.8, 1.15, 1.5]
RETRASO_COLA = 3  # cuadros de retraso de cada hueso respecto del anterior
DEF_MAX = float(os.environ.get("FELIPE_DEF", "0.08"))    # estirar y aplastar: como mucho ±8 %
POLO_M = float(os.environ.get("FELIPE_POLO", "0.25"))  # distancia del polo de rodilla y codo

arm = None
pbs = None
CTL = {}      # (pata, lado) -> dict de nombres: ctl, ik, polo, ikb, pie, dedo
BOLA = {}     # (pata, lado) -> posición de reposo de la bola del pie (mundo)
PIVOTE = None  # cabeza del hueso "spine": pivote del torso
CADERA = None  # punto medio de las caderas: el torso gira ahí al pararse, sentarse o saltar
K = 1.0
sc = None


def preparar():
    """Abre el rig, lo pasa a metros y arma los controles. Deja todo en modo pose."""
    global arm, pbs, K, PIVOTE, CADERA, sc
    bpy.ops.wm.open_mainfile(filepath=C.BLEND_RIG)
    sc = bpy.context.scene
    sc.render.fps = FPS
    malla = bpy.data.objects["Felipe"]
    arm = bpy.data.objects["FelipeRig"]
    if "Original" in bpy.data.objects:
        bpy.data.objects.remove(bpy.data.objects["Original"])
    alto_u = max((malla.matrix_world @ v.co).z for v in malla.data.vertices)
    K = C.ALTO_M / alto_u
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
    print("alto %.4f u -> %.4f m (K=%.5f)" % (alto_u, C.ALTO_M, K))

    bpy.context.view_layer.objects.active = arm
    arm.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    eb = arm.data.edit_bones
    # El estirar y aplastar va en el torso; patas, cuello (y cabeza) y cola no heredan su
    # escala: si no, las patas se encogían y no llegaban al piso, y la cabeza se deformaba.
    for nb in ("pelvis.L", "pelvis.R", "shoulder.L", "shoulder.R", "spine.004", "tail.001"):
        eb[nb].inherit_scale = "NONE"
    PIVOTE = eb["spine"].head.copy()
    CADERA = (eb["thigh.L"].head + eb["thigh.R"].head) / 2
    for lado in ("L", "R"):
        for pata, (ik_hueso, pie, dedo, padre_polo) in {
                "tras": ("shin", "foot", "r_toe", "root"),
                "del": ("forearm", "hand", "f_toe", "spine.003")}.items():
            b_pie, b_dedo, b_ik = eb[pie + "." + lado], eb[dedo + "." + lado], eb[ik_hueso + "." + lado]
            bola = b_dedo.head.copy()
            c = eb.new("ctl_%s.%s" % (pata, lado))
            c.head = bola; c.tail = bola + V((0, 0, 0.015)); c.roll = 0; c.parent = eb["root"]; c.use_deform = False
            t = eb.new("ik_%s.%s" % (pata, lado))
            t.head = b_pie.head.copy(); t.tail = b_pie.tail.copy(); t.roll = b_pie.roll; t.parent = c; t.use_deform = False
            p = eb.new("polo_%s.%s" % (pata, lado))
            # Polo de la rodilla fijo al piso; el del codo va con el pecho (sigue al torso
            # cuando se para en dos patas o se sienta).
            # Polo lejos (POLO_M adelante): con el polo pegado al codo, el plano de la pata
            # giraba cuando la mano pasaba por delante y el codo se metía o se abría.
            p.head = b_ik.head + V((0, -POLO_M, 0)); p.tail = p.head + V((0, 0, 0.01))
            p.parent = eb[padre_polo]; p.use_deform = False
            CTL[(pata, lado)] = {"ctl": c.name, "ik": t.name, "polo": p.name, "ikb": ik_hueso + "." + lado,
                                 "pie": pie + "." + lado, "dedo": dedo + "." + lado}
            BOLA[(pata, lado)] = bola
    bpy.ops.object.mode_set(mode="POSE")
    pbs = arm.pose.bones
    for pb in pbs:
        pb.rotation_mode = "QUATERNION"
    for d in CTL.values():
        ik = pbs[d["ikb"]].constraints.new("IK")
        ik.target = arm; ik.subtarget = d["ik"]
        ik.pole_target = arm; ik.pole_subtarget = d["polo"]
        ik.chain_count = 2
        cr = pbs[d["pie"]].constraints.new("COPY_ROTATION")
        cr.target = arm; cr.subtarget = d["ik"]
        cr.target_space = "WORLD"; cr.owner_space = "WORLD"
    for d in CTL.values():
        ik = pbs[d["ikb"]].constraints["IK"]
        prueba = lambda g: (setattr(ik, "pole_angle", math.radians(g)), error_reposo())[1]
        mejor = min(range(-180, 180, 5), key=prueba)
        mejor = min([mejor + x for x in range(-5, 6)], key=prueba)
        ik.pole_angle = math.radians(mejor)
    print("error en reposo con IK: %.5f" % error_reposo())


def error_reposo():
    bpy.context.view_layer.update()
    e = 0.0
    for b in arm.data.bones:
        if b.name.startswith(("ctl_", "ik_", "polo_")):
            continue
        e += (pbs[b.name].matrix.translation - b.matrix_local.translation).length
        e += (pbs[b.name].matrix.col[1].xyz - b.matrix_local.col[1].xyz).length
    return e


# ------------------------------------------------------------------ ayudas de claves
def q_mundo(nombre, eje, grados):
    """Giro alrededor de un eje del mundo, en el espacio local de reposo del hueso."""
    r = arm.data.bones[nombre].matrix_local.to_quaternion()
    return r.inverted() @ Q(V(eje), math.radians(grados)) @ r


def giro(nombre, *giros):
    q = Q()
    for eje, g in giros:
        q = q_mundo(nombre, eje, g) @ q
    return q


def loc_mundo(nombre, desp):
    m = arm.data.bones[nombre].matrix_local.to_3x3()
    return m.inverted() @ V(desp)


def clave(nombre, f, rot=None, loc=None, esc=None):
    pb = pbs[nombre]
    if rot is not None:
        pb.rotation_quaternion = rot
        pb.keyframe_insert("rotation_quaternion", frame=f)
    if loc is not None:
        pb.location = loc
        pb.keyframe_insert("location", frame=f)
    if esc is not None:
        pb.scale = esc
        pb.keyframe_insert("scale", frame=f)


def rotar_x(p, pivote, grados):
    """Gira un punto alrededor del eje X del mundo que pasa por el pivote."""
    return pivote + Q(V((1, 0, 0)), math.radians(grados)) @ (V(p) - pivote)


def _comp_cadera(cabeceo):
    """Traslación que deja la cadera en su lugar cuando el torso cabecea (el hueso spine gira
    en su cabeza, que está detrás de la cadera)."""
    return CADERA - rotar_x(CADERA, PIVOTE, -cabeceo)


def natural(pata_, lado, sube=0.0, adelante=0.0, cabeceo=0.0, en_cadera=True):
    """Dónde quedaría la bola del pie si la pata siguiera al torso sin moverse."""
    p = rotar_x(BOLA[(pata_, lado)], PIVOTE, -cabeceo) + V((0, -adelante, sube))
    return p + (_comp_cadera(cabeceo) if en_cadera else V())


def torso(f, sube=0.0, adelante=0.0, lado=0.0, cabeceo=0.0, balanceo=0.0, giro_lat=0.0, estira=1.0,
          en_cadera=False):
    """Hueso "spine" (todo el cuerpo). cabeceo + = el frente sube; estira = largo (±8 %),
    con el volumen conservado en los otros ejes. en_cadera: gira en la cadera (pararse,
    sentarse, saltar), no en la cabeza del hueso."""
    estira = min(1 + DEF_MAX, max(1 - DEF_MAX, estira))
    ancho = 1.0 / math.sqrt(estira)
    d = V((lado, -adelante, sube)) + (_comp_cadera(cabeceo) if en_cadera else V())
    clave("spine", f, loc=loc_mundo("spine", d),
          rot=giro("spine", ((1, 0, 0), -cabeceo), ((0, 1, 0), balanceo), ((0, 0, 1), giro_lat)),
          esc=(ancho, estira, ancho))


def lomo(f, arco=0.0, giro_lat=0.0, balanceo=0.0, cabeceo=0.0):
    """Lomo: arco + = se arquea hacia arriba (el pecho vuelve a quedar nivelado);
    cabeceo + = el pecho sube respecto de la grupa."""
    clave("spine.001", f, rot=giro("spine.001", ((1, 0, 0), -arco - cabeceo * 0.5), ((0, 0, 1), giro_lat)))
    clave("spine.002", f, rot=giro("spine.002", ((1, 0, 0), 2 * arco - cabeceo * 0.5), ((0, 0, 1), giro_lat),
                                    ((0, 1, 0), balanceo)))
    clave("spine.003", f, rot=giro("spine.003", ((1, 0, 0), -arco)))


def cabeza(f, cuello=0.0, cab=0.0, giro_lat=0.0, ladeo=0.0, cuello_giro=0.0):
    """cuello/cab + = baja (mira al piso); giro_lat + = mira a su izquierda; ladeo = inclina."""
    clave("spine.004", f, rot=giro("spine.004", ((1, 0, 0), cuello), ((0, 0, 1), cuello_giro)))
    clave("spine.006", f, rot=giro("spine.006", ((1, 0, 0), cab), ((0, 0, 1), giro_lat), ((0, 1, 0), ladeo)))


def orejas(f, atras=0.0, izq=None):
    """atras + = orejas hacia atrás (esfuerzo, molestia)."""
    for lado, extra in (("L", izq or 0.0), ("R", 0.0)):
        g = atras + extra
        s = 1 if lado == "L" else -1
        clave("ear." + lado, f, rot=giro("ear." + lado, ((1, 0, 0), -g), ((0, 1, 0), s * g * 0.4)))


def pata(f, pata_, lado, desp=(0, 0, 0), rot=0.0, dedo=0.0, pos=None, escapula=None):
    """Control de una pata: desp = desplazamiento en el mundo desde la bola en reposo (o pos
    absoluta); rot = giro del pie en X (+ = talón arriba); dedo = giro de los dedos."""
    d = CTL[(pata_, lado)]
    p = V(pos) if pos is not None else BOLA[(pata_, lado)] + V(desp)
    clave(d["ctl"], f, rot=q_mundo(d["ctl"], (1, 0, 0), rot), loc=loc_mundo(d["ctl"], p - BOLA[(pata_, lado)]))
    clave(d["dedo"], f, rot=q_mundo(d["dedo"], (1, 0, 0), dedo))
    if pata_ == "del" and escapula is not None:
        clave("shoulder." + lado, f, rot=q_mundo("shoulder." + lado, (1, 0, 0), escapula))


def patas_quietas(f):
    for (p_, l) in CTL:
        pata(f, p_, l, escapula=0.0 if p_ == "del" else None)


def cola(n, estatica, onda, paso=2, ciclo=True, punta=None, retraso=RETRASO_COLA, amp=AMP_COLA):
    """Cola con "overlapping action": cada hueso repite la onda del anterior con `retraso`
    cuadros de atraso y más amplitud hacia la punta.
    estatica: [(cabeceo, lado)] por hueso (la forma de base, p. ej. el gancho);
    onda(t) -> (cabeceo, lado) en grados para el hueso de la base, t en cuadros;
    punta(t, i) -> (cabeceo, lado) extra por hueso (tics de la punta), opcional.
    cabeceo + = hacia adelante (sobre el lomo); lado + = hacia la izquierda de Felipe."""
    frames = list(range(0, n, paso)) + [n]
    for f in frames:
        for i, h in enumerate(COLA):
            t = f - i * retraso
            if ciclo:
                t %= n
            else:
                t = max(0, t)
            p, l = onda(t)
            pe, le = estatica[i]
            pp, pl = punta(t, i) if punta else (0.0, 0.0)
            # Ejes locales (el rol deja el Z local = +X del mundo): Z local = adelante/atrás,
            # X local = de lado. Así el vaivén lateral funciona aunque la cola esté inclinada.
            cab = math.radians(pe + amp[i] * p + pp)
            lat = math.radians(le + amp[i] * l + pl)
            clave(h, f, rot=Q(V((0, 0, 1)), cab) @ Q(V((1, 0, 0)), lat))


def curva(puntos):
    """Curva suave por puntos [(t, valor)] (smoothstep entre puntos; fuera, el extremo)."""
    def f(t):
        if t <= puntos[0][0]:
            return puntos[0][1]
        for (t0, v0), (t1, v1) in zip(puntos, puntos[1:]):
            if t <= t1:
                u = (t - t0) / max(1e-6, t1 - t0)
                return v0 + (v1 - v0) * u * u * (3 - 2 * u)
        return puntos[-1][1]
    return f


def seno(t, n, veces=1, fase=0.0):
    return math.sin(2 * math.pi * (veces * t / n - fase))


# ------------------------------------------------------------------ acciones
def todas_fcurves(accion):
    try:
        return list(accion.fcurves)
    except AttributeError:
        out = []
        for capa in accion.layers:
            for tira in capa.strips:
                for bolsa in tira.channelbags:
                    out.extend(bolsa.fcurves)
        return out


def nueva_accion(nombre):
    if nombre in bpy.data.actions:
        bpy.data.actions.remove(bpy.data.actions[nombre])
    a = bpy.data.actions.new(nombre)
    a.use_fake_user = True
    if arm.animation_data is None:
        arm.animation_data_create()
    arm.animation_data.action = a
    for pb in pbs:
        pb.rotation_quaternion = Q(); pb.location = (0, 0, 0); pb.scale = (1, 1, 1)
    return a


def suavizar(accion, ciclo=True):
    """Bezier con facilidad de entrada y salida (manijas automáticas acotadas)."""
    for fc in todas_fcurves(accion):
        if ciclo and not any(m.type == "CYCLES" for m in fc.modifiers):
            fc.modifiers.new("CYCLES")
        for k in fc.keyframe_points:
            if k.interpolation != "LINEAR":
                k.interpolation = "BEZIER"
                k.easing = "AUTO"
                k.handle_left_type = k.handle_right_type = "AUTO_CLAMPED"
        fc.update()


def lineal(accion, hueso, frames):
    for fc in todas_fcurves(accion):
        if ('"%s"' % hueso) in fc.data_path and fc.data_path.endswith("location"):
            for k in fc.keyframe_points:
                if any(abs(k.co.x - f) < 1e-3 for f in frames):
                    k.interpolation = "LINEAR"


def completar(accion, n):
    """Todo hueso animado en alguna acción debe tener clave en todas (si no, en Godot
    conserva la pose de la acción anterior): se agregan claves de reposo al inicio y al final."""
    tocados = set()
    for fc in todas_fcurves(accion):
        if fc.data_path.startswith('pose.bones["'):
            tocados.add(fc.data_path.split('"')[1])
    for pb in pbs:
        if pb.name in tocados or pb.name == "root":
            continue
        pb.rotation_quaternion = Q(); pb.location = (0, 0, 0); pb.scale = (1, 1, 1)
        for f in (0, n):
            pb.keyframe_insert("rotation_quaternion", frame=f)
            pb.keyframe_insert("location", frame=f)
            pb.keyframe_insert("scale", frame=f)


def hornear(accion, n):
    arm.animation_data.action = accion
    try:
        if accion.slots and arm.animation_data.action_slot is None:
            arm.animation_data.action_slot = accion.slots[0]
    except AttributeError:
        pass
    bpy.ops.object.mode_set(mode="POSE")
    for pb in pbs:
        try:
            pb.select = True
        except AttributeError:
            pb.bone.select = True
    sc.frame_start, sc.frame_end = 0, n
    bpy.ops.nla.bake(frame_start=0, frame_end=n, only_selected=False, visual_keying=True,
                     clear_constraints=False, clear_parents=False, use_current_action=True,
                     clean_curves=False, bake_types={"POSE"},
                     channel_types={"LOCATION", "ROTATION", "SCALE"})
    return arm.animation_data.action


def posicion(hueso, f, cola_=False):
    sc.frame_set(int(f), subframe=f - int(f))
    pb = pbs[hueso]
    return arm.matrix_world @ (pb.tail if cola_ else pb.head)


def exportar(acciones):
    """Hornea, borra controles y exporta el GLB con las acciones dadas [(accion, n)]."""
    horneadas = [(hornear(a, n), a.name) for a, n in acciones]
    bpy.ops.object.mode_set(mode="POSE")
    for pb in pbs:
        for cn in list(pb.constraints):
            pb.constraints.remove(cn)
    bpy.ops.object.mode_set(mode="EDIT")
    for b in list(arm.data.edit_bones):
        if b.name.startswith(("ctl_", "ik_", "polo_")):
            arm.data.edit_bones.remove(b)
    bpy.ops.object.mode_set(mode="OBJECT")
    for acc, nombre in horneadas:
        for fc in todas_fcurves(acc):
            if any(('"%s' % x) in fc.data_path for x in ("ctl_", "ik_", "polo_")):
                try:
                    acc.fcurves.remove(fc)
                except AttributeError:
                    for capa in acc.layers:
                        for tira in capa.strips:
                            for bolsa in tira.channelbags:
                                if fc in list(bolsa.fcurves):
                                    bolsa.fcurves.remove(fc)
        acc.name = nombre
        acc.use_fake_user = True
    vivas = {acc for acc, _ in horneadas}
    for acc in list(bpy.data.actions):
        if acc not in vivas:
            bpy.data.actions.remove(acc)
    arm.animation_data.action = None
    for acc, _ in horneadas:
        tr = arm.animation_data.nla_tracks.new()
        tr.name = acc.name
        tr.strips.new(acc.name, 0, acc)
        tr.mute = True
    bpy.ops.wm.save_as_mainfile(filepath=C.BLEND_ANIM)
    malla = bpy.data.objects["Felipe"]
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
