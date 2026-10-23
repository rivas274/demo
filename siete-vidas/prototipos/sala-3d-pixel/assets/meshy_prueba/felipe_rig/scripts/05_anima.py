# Paso 5 y 6: animación a mano con poses clave (Bezier) y exportación a glTF.
# - anima_base.py: rig en metros, controles IK de animador, ayudas y cola con overlapping action.
# - anima_locomocion.py: caminar (0,92 s, en el lugar) y quieto (6 s).
# - anima_acciones.py: arañar (entrada, bucle, salida), pedir (entrada, bucle) y saltar
#   (en el lugar, con marcas de despegue y aterrizaje para el arco que hace Godot).
# Escribe felipe_rig.glb y felipe_rig.json (velocidad, duraciones y marcas).
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import felipe_comun as C
import anima_base as B
import anima_locomocion as L
import anima_acciones as A

B.preparar()
acciones = [L.caminar(), L.quieto(), A.aranar_entrada(), A.aranar(), A.aranar_salida(),
            A.pedir_entrada(), A.pedir(), A.saltar(),
            A.sentarse(), A.sentado_mira(), A.sentado_pelota(), A.levantarse()]


def medir_patinaje(accion, n):
    """Mayor corrimiento en el mundo de la bola de un pie apoyado, con el cuerpo avanzando."""
    B.arm.animation_data.action = accion
    vel = L.velocidad()
    peor = 0.0
    for (pata, lado), fase0 in L.FASE.items():
        pts = []
        for f in range(n):
            pf = ((f / n) - fase0) % 1.0
            if pf <= 0.45:
                q = B.posicion(B.CTL[(pata, lado)]["dedo"], f)
                q.y -= vel * pf * n / B.FPS
                pts.append(q)
        peor = max([peor] + [(q - pts[0]).length for q in pts])
    return peor


def medir_alcance(accion, n):
    """Mayor distancia entre el talón o la muñeca y su objetivo IK (pata que no alcanza)."""
    B.arm.animation_data.action = accion
    peor = (0.0, "", 0)
    for f in range(n + 1):
        B.sc.frame_set(f)
        for d in B.CTL.values():
            e = (B.pbs[d["pie"]].head - B.pbs[d["ik"]].head).length
            if e > peor[0]:
                peor = (e, d["pie"], f)
    return peor


patina = medir_patinaje(acciones[0][0], L.N_CAMINAR)
print("patinaje máximo del pie apoyado al caminar: %.2f mm" % (patina * 1000))
for acc, n in acciones:
    e, pie, f = medir_alcance(acc, n)
    print("%-15s %3d cuadros (%.2f s)  IK: peor %.1f mm (%s, cuadro %d)" % (acc.name, n, n / B.FPS, e * 1000, pie, f))

info = {
    "velocidad_caminar_m_s": round(L.velocidad(), 4),
    "zancada_m": round(L.zancada(), 4),
    "alto_m": round(C.ALTO_M, 4),
    "patinaje_max_mm": round(patina * 1000, 2),
    "fps": B.FPS,
    "duracion_s": {acc.name: round(n / B.FPS, 4) for acc, n in acciones},
    "saltar": {"despegue_s": round(A.DESPEGUE / B.FPS, 4), "aterrizaje_s": round(A.ATERRIZA / B.FPS, 4)},
    "aranar": {"zarpazos_s": [round(3 / B.FPS, 4), round((3 + A.N_AR / 2) / B.FPS, 4)]},
}
# Pelota (la mueve Godot): tiempos de contacto de la pata y posición de la punta de la mano
# en ese momento, en coordenadas del modelo glTF a escala 1 (x izquierda, y arriba, z adelante).
acc_p = [x for x, _ in acciones if x.name == "sentado_pelota"][0]
B.arm.animation_data.action = acc_p
contactos = []
for f in A.CONTACTOS_PELOTA:
    p = B.posicion("f_toe.R", f, cola_=True)
    contactos.append({"t_s": round(f / B.FPS, 4), "pie_m": [round(p.x, 4), round(p.z, 4), round(-p.y, 4)]})
info["sentado_pelota"] = {"contactos": contactos, "pata": "delantera derecha"}
print("pelota:", contactos)
B.exportar(acciones)
with open(os.path.join(C.RIG, "felipe_rig.json"), "w") as fh:
    json.dump(info, fh, indent=2, ensure_ascii=False)
print("info", json.dumps(info, ensure_ascii=False))
