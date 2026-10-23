# Hojas del esqueleto anatómico (v4): huesos dentro de la malla transparente de perfil y de
# frente, junto a un esquema de un gato real con sus proporciones; y 8 cuadros del ciclo de
# caminar de perfil con los huesos visibles.
# Uso: python3 11_esqueleto.py <hoja esqueleto.png> <hoja ciclo.png>
import sys, os, math, bpy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C, felipe_render as R
from PIL import Image, ImageDraw

sal_esq, sal_ciclo = sys.argv[1], sys.argv[2]
bpy.ops.wm.open_mainfile(filepath=C.BLEND_ANIM)
arm = bpy.data.objects["FelipeRig"]
m = bpy.data.objects["Felipe"]
for t in arm.animation_data.nla_tracks:
    t.mute = True
arm.animation_data.action = None
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION"
    pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0); pb.scale = (1, 1, 1)
R.material_translucido(m, 0.28)
hs = [h for h in R.huesos_visibles(arm, radio=0.004) if not h.name.endswith("root")]
R.escena(520, 16)
R.luz()
T = 520
rutas = []
for k, (d, c, tam) in enumerate((((-1, 0, 0.0), (0, 0.0, 0.27), 0.75), ((0, -1, 0.0), (0, 0, 0.27), 0.62))):
    R.camara(d, centro=c, tam=tam)
    R.mostrar_solo([m] + hs)
    p = os.path.join(C.TRABAJO, "esq_%d.png" % k)
    R.render(p)
    rutas.append(p)

# Largos de los huesos de las patas (m) y proporción respecto del fémur / del húmero.
L = {b.name: b.length for b in arm.data.bones}
tras = [("fémur (thigh)", L["thigh.L"]), ("tibia (shin)", L["shin.L"]), ("metatarso (foot)", L["foot.L"])]
dela = [("escápula (shoulder)", L["shoulder.L"]), ("húmero (upper_arm)", L["upper_arm.L"]),
        ("radio y cúbito (forearm)", L["forearm.L"]), ("metacarpo (hand)", L["hand.L"])]
# Gato real (medidas típicas de un gato doméstico adulto, cm).
REAL_T = [("fémur", 11.0), ("tibia", 12.0), ("metatarso", 6.5)]
REAL_D = [("escápula", 7.0), ("húmero", 10.0), ("radio", 9.5), ("metacarpo", 3.0)]

# Esquema del gato real de perfil (mira a la derecha), dibujado con sus proporciones y
# ángulos de pie típicos.
E = Image.new("RGB", (T, T), (250, 248, 242))
d = ImageDraw.Draw(E)
s = 9.5
def cadena(origen, partes, color):
    x, y = origen
    pts = [(x, y)]
    for largo, ang in partes:
        x += largo * s * math.cos(math.radians(ang)); y += largo * s * math.sin(math.radians(ang))
        pts.append((x, y))
    d.line(pts, fill=color, width=6)
    for p in pts:
        d.ellipse((p[0] - 6, p[1] - 6, p[0] + 6, p[1] + 6), fill=(250, 248, 242), outline=color, width=3)
    return pts
col = (120, 70, 40)
d.line([(70, 190), (170, 175), (300, 172), (395, 185)], fill=(90, 90, 90), width=8)       # columna
d.ellipse((380, 120, 470, 200), outline=(90, 90, 90), width=5)                             # cráneo
d.line([(70, 190), (30, 120), (10, 70)], fill=(90, 90, 90), width=5)                       # cola
r = cadena((95, 200), [(11, 58), (12, 118), (6.5, 82), (3, 10)], col)                          # cadera, fémur, tibia, metatarso, dedos
f_ = cadena((350, 165), [(7, 62), (10, 100), (9.5, 88), (3, 20)], col)                          # escápula, húmero, radio, mano
for txt, p_ in (("cadera", r[0]), ("rodilla", r[1]), ("corvejón", r[2]), ("escápula", f_[0]),
                ("hombro", f_[1]), ("codo", f_[2]), ("muñeca", f_[3])):
    d.text((p_[0] + 10, p_[1] - 8), txt, fill=(30, 30, 30), font=R.letra(15))
d.text((10, 8), "Esquema: gato real (proporciones)", fill=(30, 30, 30), font=R.letra(18))

H = Image.new("RGB", (T * 3, T + 250), (240, 240, 240))
dr = ImageDraw.Draw(H)
for j, (r, t) in enumerate(((rutas[0], "Felipe: huesos de perfil"), (rutas[1], "Felipe: huesos de frente"))):
    H.paste(Image.open(r).convert("RGB"), (T * j, 30))
    dr.text((T * j + 8, 6), t, fill=(20, 20, 20), font=R.letra(18))
H.paste(E, (T * 2, 30))
y = T + 40
f = R.letra(16)
dr.text((10, y), "Trasera (Felipe, cm / proporción con el fémur  —  gato real):", fill=(20, 20, 20), font=f)
for i, ((n, l), (nr, lr)) in enumerate(zip(tras, REAL_T)):
    dr.text((20, y + 24 + 22 * i), "%s: %.1f cm (%.2f)  —  %s %.1f cm (%.2f)" % (n, l * 100, l / tras[0][1], nr, lr, lr / REAL_T[0][1]),
            fill=(20, 20, 20), font=f)
dr.text((T * 1.5, y), "Delantera (Felipe / proporción con el húmero  —  gato real):", fill=(20, 20, 20), font=f)
for i, ((n, l), (nr, lr)) in enumerate(zip(dela, REAL_D)):
    dr.text((T * 1.5 + 10, y + 24 + 22 * i), "%s: %.1f cm (%.2f)  —  %s %.1f cm (%.2f)" % (n, l * 100, l / dela[1][1], nr, lr, lr / REAL_D[1][1]),
            fill=(20, 20, 20), font=f)
H.save(sal_esq)
print("hoja", sal_esq)
for n, l in tras + dela:
    print("%-26s %.1f cm" % (n, l * 100))

# Ciclo de caminar de perfil con huesos (8 cuadros).
acc = bpy.data.actions["caminar"]
arm.animation_data.action = acc
try:
    if acc.slots:
        arm.animation_data.action_slot = acc.slots[0]
except AttributeError:
    pass
n = int(acc.frame_range[1])
R.escena(330, 12)
cic = Image.new("RGB", (330 * 4, 352 * 2), (240, 240, 240))
dc = ImageDraw.Draw(cic)
for i in range(8):
    fr = n * i / 8
    bpy.context.scene.frame_set(int(fr), subframe=fr - int(fr))
    R.camara((-1, 0, 0.0), centro=(0, 0.0, 0.27), tam=0.75)
    R.mostrar_solo([m] + hs)
    p = os.path.join(C.TRABAJO, "esqc_%d.png" % i)
    R.render(p)
    x, yy = 330 * (i % 4), 352 * (i // 4)
    cic.paste(Image.open(p).convert("RGB"), (x, yy + 22))
    dc.text((x + 6, yy + 3), "caminar %d/8 (cuadro %.1f)" % (i + 1, fr), fill=(20, 20, 20), font=R.letra(14))
cic.save(sal_ciclo)
print("hoja", sal_ciclo)
