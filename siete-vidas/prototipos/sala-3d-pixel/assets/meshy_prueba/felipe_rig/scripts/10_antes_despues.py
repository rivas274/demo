# Hojas de antes y después del Felipe simétrico (v3) frente al asimétrico (v2):
#  - felipe-simetrico-antes-despues.png: frente, espalda y arriba, con el alambre de la retopo;
#  - felipe-rig-lomo-antes-despues.png: espalda, perfil y 3/4 (manchas del lomo y cola);
#  - felipe-rig-patas-antes-despues.png: la caminata de perfil y de frente en 4 cuadros.
# Uso: python3 10_antes_despues.py <textura_antes.blend> <anim_antes.blend> <carpeta de salida> <png de la textura de antes>
import sys, os, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

tex_antes, anim_antes, sal, png_antes = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]


def textura_de(blend):
    """Los .blend de antes apuntan al mismo archivo de textura: se les da la suya."""
    if blend in (tex_antes, anim_antes):
        img = bpy.data.images["felipe_rig_color"]
        img.filepath = png_antes
        img.reload()
T = 330


def hoja(nombre, columnas, filas):
    img = Image.new("RGB", (170 + T * len(columnas), 30 + T * len(filas)), (240, 240, 240))
    d = ImageDraw.Draw(img)
    for j, c in enumerate(columnas):
        d.text((170 + j * T + 8, 7), c, fill=(20, 20, 20), font=R.letra(15))
    for i, (et, rutas) in enumerate(filas):
        d.text((8, 30 + i * T + T // 2 - 10), et, fill=(20, 20, 20), font=R.letra(16))
        for j, r in enumerate(rutas):
            img.paste(Image.open(r).convert("RGB").resize((T, T)), (170 + j * T, 30 + i * T))
    img.save(os.path.join(sal, nombre))
    print("hoja", nombre)


def malla_textura(blend, pref, vistas, alambre=()):
    bpy.ops.wm.open_mainfile(filepath=blend)
    textura_de(blend)
    r = bpy.data.objects["Retopo"]
    R.escena(T, 12)
    R.luz()
    rutas = []
    for k, (d, c, tam) in enumerate(vistas):
        R.camara(d, centro=c, tam=tam)
        R.mostrar_solo([r])
        p = os.path.join(C.TRABAJO, "ad_%s_%d.png" % (pref, k))
        R.render(p)
        rutas.append(p)
    if alambre:
        mat = r.data.materials[0]
        r.data.materials[0] = R.material_liso()
        w = R.alambre_de(r, grosor=0.0026)
        for k, (d, c, tam) in enumerate(alambre):
            R.camara(d, centro=c, tam=tam)
            R.mostrar_solo([r, w])
            p = os.path.join(C.TRABAJO, "ad_%s_w%d.png" % (pref, k))
            R.render(p)
            rutas.append(p)
        r.data.materials[0] = mat
    return rutas


CUERPO = (0, 0, 0.81)
SIM = [((0, -1, 0.05), CUERPO, 2.0), ((0, 1, 0.3), CUERPO, 2.0), ((0, 0.35, 1), CUERPO, 2.0)]
ALAMBRE = [((0, -1, 0.05), CUERPO, 2.0), ((0, 0.35, 1), CUERPO, 2.0)]
filas = []
for et, blend, pref in (("antes\n(Meshy tal cual)", tex_antes, "a"), ("después\n(simétrico)", C.BLEND_TEXTURA, "d")):
    filas.append((et, malla_textura(blend, "sim" + pref, SIM, ALAMBRE)))
hoja("felipe-simetrico-antes-despues.png", ["frente", "espalda", "arriba", "alambre: frente", "alambre: arriba"], filas)

LOMO = [((0, 1, 0.45), CUERPO, 2.0), ((-1, 0, 0.1), CUERPO, 2.0), ((-0.75, 0.6, 0.5), CUERPO, 2.0),
        ((0, 0.35, 1), (0, 0.15, 0.5), 1.3), ((-0.55, 0.85, 0.05), (0, 0.42, 0.45), 0.85)]
ANTES, DESPUES = os.environ.get("FELIPE_ANTES", "antes (v2)"), os.environ.get("FELIPE_DESPUES", "después (v3)")
filas = []
for et, blend, pref in ((ANTES, tex_antes, "a"), (DESPUES, C.BLEND_TEXTURA, "d")):
    filas.append((et, malla_textura(blend, "lomo" + pref, LOMO)))
hoja("felipe-rig-lomo-antes-despues.png", ["espalda", "perfil", "3/4 de atrás", "lomo de cerca, desde arriba",
                                           "unión cola, grupa y pata"], filas)


def patas(blend, pref):
    bpy.ops.wm.open_mainfile(filepath=blend)
    textura_de(blend)
    arm = bpy.data.objects["FelipeRig"]
    m = bpy.data.objects["Felipe"]
    acc = bpy.data.actions["caminar"]
    arm.animation_data.action = acc
    try:
        if acc.slots:
            arm.animation_data.action_slot = acc.slots[0]
    except AttributeError:
        pass
    for t in arm.animation_data.nla_tracks:
        t.mute = True
    R.escena(T, 10)
    R.luz()
    n = int(acc.frame_range[1])
    filas = []
    for vista, d in (("perfil", (-1, 0, 0.12)), ("frente", (0, -1, 0.12))):
        rutas = []
        for k in range(4):
            f = n * k / 4
            bpy.context.scene.frame_set(int(f), subframe=f - int(f))
            R.camara(d, centro=(0, -0.04, 0.12), tam=0.36)
            R.mostrar_solo([m])
            p = os.path.join(C.TRABAJO, "ad_pat_%s_%s_%d.png" % (pref, vista, k))
            R.render(p)
            rutas.append(p)
        filas.append((vista, rutas))
    return filas


filas = []
for et, blend, pref in ((ANTES, anim_antes, "a"), (DESPUES, C.BLEND_ANIM, "d")):
    for vista, rutas in patas(blend, pref):
        filas.append(("%s\n%s" % (et, vista), rutas))
hoja("felipe-rig-patas-antes-despues.png", ["cuadro 1/4 del ciclo", "2/4", "3/4", "4/4"], filas)
