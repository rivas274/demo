# Ayudas de render (Cycles en CPU, sin GPU) para revisar cada paso del rig de Felipe.
import math, bpy, mathutils

VISTAS = {
    # nombre: (dirección desde la que mira la cámara, hacia el modelo)
    "perfil": mathutils.Vector((1, 0, 0)),     # desde +X: Felipe mira a la izquierda... ver abajo
    "perfil_d": mathutils.Vector((-1, 0, 0)),  # desde -X: Felipe mira a la derecha (como las plantillas)
    "frente": mathutils.Vector((0, -1, 0)),
    "tres_cuartos": mathutils.Vector((-0.75, -1, 0.35)),
    "atras": mathutils.Vector((0, 1, 0.2)),
    "arriba": mathutils.Vector((0, 0, 1)),
}


def escena(res=512, muestras=12):
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = muestras
    sc.cycles.use_denoising = False
    sc.render.resolution_x = res
    sc.render.resolution_y = res
    sc.render.film_transparent = False
    sc.view_settings.view_transform = "Standard"
    if sc.world is None:
        sc.world = bpy.data.worlds.new("Mundo")
    sc.world.use_nodes = True
    bg = sc.world.node_tree.nodes.get("Background")
    bg.inputs[0].default_value = (0.75, 0.75, 0.75, 1)
    bg.inputs[1].default_value = 0.9
    return sc


def luz():
    if "Sol" in bpy.data.objects:
        return
    d = bpy.data.lights.new("Sol", "SUN")
    d.energy = 2.5
    o = bpy.data.objects.new("Sol", d)
    o.rotation_euler = (math.radians(50), math.radians(10), math.radians(-35))
    bpy.context.collection.objects.link(o)


def camara(vista, centro=(0, 0, 0.8), tam=2.3, dist=6.0):
    if "Cam" in bpy.data.objects:
        cam = bpy.data.objects["Cam"]
    else:
        cd = bpy.data.cameras.new("Cam")
        cam = bpy.data.objects.new("Cam", cd)
        bpy.context.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = tam
    d = VISTAS[vista] if isinstance(vista, str) else mathutils.Vector(vista)
    d = d.normalized()
    c = mathutils.Vector(centro)
    cam.location = c + d * dist
    arriba = mathutils.Vector((0, 1, 0)) if abs(d.z) > 0.99 else mathutils.Vector((0, 0, 1))
    m = mathutils.Matrix.Identity(3)
    z = d
    x = arriba.cross(z).normalized()
    y = z.cross(x)
    m.col[0] = x; m.col[1] = y; m.col[2] = z
    cam.rotation_euler = m.to_euler()
    cam.data.clip_end = 50
    bpy.context.scene.camera = cam
    return cam


def material_alambre(nombre="Alambre", color=(0.9, 0.9, 0.88), linea=(0.05, 0.05, 0.08), grosor=0.003):
    if nombre in bpy.data.materials:
        return bpy.data.materials[nombre]
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    mix = nt.nodes.new("ShaderNodeMixShader")
    a = nt.nodes.new("ShaderNodeBsdfDiffuse"); a.inputs[0].default_value = (*color, 1)
    b = nt.nodes.new("ShaderNodeEmission"); b.inputs[0].default_value = (*linea, 1)
    w = nt.nodes.new("ShaderNodeWireframe"); w.use_pixel_size = False
    w.inputs[0].default_value = grosor
    nt.links.new(w.outputs[0], mix.inputs[0])
    nt.links.new(a.outputs[0], mix.inputs[1])
    nt.links.new(b.outputs[0], mix.inputs[2])
    nt.links.new(mix.outputs[0], out.inputs[0])
    return m


def alambre_de(obj, grosor=0.0035, color=(0.08, 0.08, 0.12)):
    """Copia de la malla convertida en alambre real (aristas de los cuadriláteros, no triángulos)."""
    w = obj.copy(); w.data = obj.data.copy(); w.name = obj.name + "_alambre"
    bpy.context.collection.objects.link(w)
    w.modifiers.clear()
    for m in list(obj.modifiers):
        if m.type == "ARMATURE":
            a = w.modifiers.new(m.name, "ARMATURE"); a.object = m.object
    md = w.modifiers.new("alambre", "WIREFRAME")
    md.thickness = grosor
    md.use_replace = True
    md.use_even_offset = False
    mt = bpy.data.materials.new("linea")
    mt.use_nodes = True
    bs = mt.node_tree.nodes.get("Principled BSDF")
    bs.inputs["Base Color"].default_value = (*color, 1)
    w.data.materials.clear(); w.data.materials.append(mt)
    w.parent = obj.parent
    w.matrix_world = obj.matrix_world
    return w


def material_liso(nombre="Liso", color=(0.85, 0.85, 0.82)):
    if nombre in bpy.data.materials:
        return bpy.data.materials[nombre]
    m = bpy.data.materials.new(nombre)
    m.use_nodes = True
    m.node_tree.nodes.get("Principled BSDF").inputs["Base Color"].default_value = (*color, 1)
    return m


def render(ruta):
    bpy.context.scene.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def mostrar_solo(objs):
    for o in bpy.data.objects:
        if o.type in ("MESH", "ARMATURE"):
            o.hide_render = o not in objs
