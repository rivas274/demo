# Acciones nuevas de Felipe con poses clave: arañar (entrada, bucle, salida), pedir
# (entrada, bucle) y saltar (en el lugar; el arco lo hace el código en Godot).
# Referencias: felipe-video2-juega-salta.png (salto y aterrizaje), felipe-video4-juega-con-gato.png
# (sentado con la cola alrededor de las patas) y la tabla "Acciones de Felipe".
# El torso gira en la cadera (torso(..., en_cadera=True)) y las patas en el aire se ponen
# relativas al torso (natural() + desplazamiento): así ninguna pata se estira de más.
import math
import mathutils
import anima_base as B

V = mathutils.Vector


def _torso(f, **kw):
    B.torso(f, en_cadera=True, **kw)


def _en_piso(p):
    p = V(p)
    p.z = B.BOLA[("del", "L")].z
    return p


def _cola_forma(f, estatica, k, retraso=0):
    """Clave de la forma de la cola (estatica [(cabeceo, lado)] por hueso) a una fracción k."""
    for i, h in enumerate(B.COLA):
        B.clave(h, f + i * retraso, rot=B.Q(V((0, 0, 1)), math.radians(estatica[i][0] * k)) @
                B.Q(V((1, 0, 0)), math.radians(estatica[i][1] * k)))


# ------------------------------------------------------------------ arañar
N_AR_ENTRA, N_AR, N_AR_SALE = 12, 16, 12
PARADO = 66.0          # grados que se levanta el torso (de pie en dos patas)
SUBE_PARADO = 0.008    # la cadera sube un poco al estirar las traseras
COLA_PARADO = [(44, 0), (-34, 0), (-22, 0), (0, 0), (22, 0)]


def _mano_en_pared(lado, cabeceo, sube, alto=0.0, separa=0.0):
    """La mano donde la deja el torso levantado, contra una pared vertical delante
    (alto + = más arriba; separa + = se aleja de la pared)."""
    return B.natural("del", lado, sube=sube, cabeceo=cabeceo) + V((0, separa, alto))


def _pose_aranar(f, t):
    """Pose del bucle de arañar en t (0..N_AR). Dos zarpazos por ciclo: la izquierda baja en
    0-6 (fuerte en 3) y la derecha en 8-14 (fuerte en 11)."""
    n = N_AR

    def mano(lado, desfase):
        u = ((t - desfase) % n) / n
        if u < 0.375:      # baja contra el respaldo
            k = u / 0.375
            alto = 0.020 - 0.034 * (k * k * (3 - 2 * k))   # v4: con el hombro anatómico la mano no llega tan abajo
            separa = 0.0
            fuerte = math.sin(math.pi * k)
        else:              # vuelve arriba despegada
            k = (u - 0.375) / 0.625
            alto = -0.014 + 0.034 * (k * k * (3 - 2 * k))
            separa = 0.012 * math.sin(math.pi * k)
            fuerte = 0.0
        pos = _mano_en_pared(lado, PARADO, SUBE_PARADO, alto, separa)
        # Garras abajo en los cuadros fuertes: la mano se dobla y los dedos se cierran.
        B.pata(f, "del", lado, pos=pos, rot=-PARADO + 30 * fuerte, dedo=8 + 35 * fuerte, escapula=-6 + 10 * fuerte)
        return fuerte
    fl = mano("L", 0)
    fr = mano("R", n / 2)
    _torso(f, sube=SUBE_PARADO - 0.003 * (fl + fr), cabeceo=PARADO - 2 * (fl + fr), balanceo=4 * (fl - fr))
    B.lomo(f, arco=-4, giro_lat=3 * (fl - fr))
    B.cabeza(f, cuello=40, cab=22, giro_lat=-2 * (fl - fr))
    B.orejas(f, atras=20)
    for lado in ("L", "R"):
        B.pata(f, "tras", lado, rot=6, dedo=-6)


def aranar_entrada():
    a = B.nueva_accion("aranar_entrada")
    n = N_AR_ENTRA
    _torso(0); B.lomo(0); B.cabeza(0); B.orejas(0); B.patas_quietas(0)
    # Se prepara: carga en las traseras y mira arriba.
    _torso(3, sube=-0.006, cabeceo=-3, estira=0.97)
    B.cabeza(3, cuello=-6, cab=-8)
    B.patas_quietas(3)
    # Se levanta: el pecho sube y las manos despegan con los dedos recogidos.
    _torso(6, sube=0.004, cabeceo=34, estira=1.04)
    B.lomo(6, arco=-2)
    B.cabeza(6, cuello=18, cab=8)
    B.orejas(6, atras=10)
    for lado in ("L", "R"):
        B.pata(6, "del", lado, pos=B.natural("del", lado, sube=0.004, cabeceo=34) + V((0, -0.004, 0.012)),
               rot=-40, dedo=-10, escapula=-6)
        B.pata(6, "tras", lado, rot=4, dedo=-4)
    # Se pasa un poco y se asienta contra el respaldo (= cuadro 0 del bucle).
    _torso(9, sube=SUBE_PARADO + 0.003, cabeceo=PARADO + 4, estira=1.05)
    for lado in ("L", "R"):
        B.pata(9, "del", lado, pos=_mano_en_pared(lado, PARADO + 4, SUBE_PARADO + 0.003, 0.02, 0.006),
               rot=-PARADO, dedo=0, escapula=-8)
    _pose_aranar(n, 0)
    for f, k in ((0, 0.0), (6, 0.55)):
        _cola_forma(f, COLA_PARADO, k, retraso=1 if f else 0)
    _cola_forma(n, COLA_PARADO, 1.0)
    B.suavizar(a, ciclo=False)
    B.completar(a, n)
    return a, n


def aranar():
    a = B.nueva_accion("aranar")
    n = N_AR
    for t in range(0, n + 1):
        _pose_aranar(t, t)
    # Cola: sacudidas rápidas de la punta (4 por ciclo) sobre un vaivén de 2 por ciclo.
    B.cola(n, estatica=COLA_PARADO, onda=lambda t: (3 * B.seno(t, n, 2), 5 * B.seno(t, n, 2, 0.1)),
           punta=lambda t, i: (0.0, 6 * max(0, i - 1) * B.seno(t, n, 4)), paso=1)
    B.suavizar(a)
    B.completar(a, n)
    return a, n


def aranar_salida():
    a = B.nueva_accion("aranar_salida")
    n = N_AR_SALE
    _pose_aranar(0, 0)
    # Suelta el respaldo y baja: las manos van adelante y abajo.
    _torso(5, sube=0.004, cabeceo=30, estira=1.03)
    B.lomo(5, arco=0)
    B.cabeza(5, cuello=10, cab=4)
    B.orejas(5, atras=8)
    for lado in ("L", "R"):
        # Se separa del respaldo al bajar (la mano no debe pasar a través de él).
        B.pata(5, "del", lado, pos=B.natural("del", lado, sube=0.004, cabeceo=30) + V((0, 0.03, -0.004)),
               rot=-25, dedo=-5, escapula=6)
        B.pata(5, "tras", lado, rot=3)
    # Apoya las manos y amortigua con el lomo arqueado.
    _torso(9, sube=-0.010, cabeceo=-3, estira=0.95)
    B.lomo(9, arco=5)
    B.cabeza(9, cuello=8, cab=-2)
    B.orejas(9, atras=2)
    for lado in ("L", "R"):
        B.pata(9, "del", lado, rot=0, escapula=-4)
        B.pata(9, "tras", lado)
    _torso(n); B.lomo(n); B.cabeza(n); B.orejas(n); B.patas_quietas(n)
    # Cola: vuelve al reposo con un latigazo que viaja a la punta.
    golpe = B.curva([(0, 0), (4, 0), (8, 16), (12, 0)])
    for f, k in ((0, 1.0), (5, 0.6), (n, 0.0)):
        for i, h in enumerate(B.COLA):
            B.clave(h, f, rot=B.Q(V((0, 0, 1)), math.radians(COLA_PARADO[i][0] * k + golpe(f - i * 2) * B.AMP_COLA[i])))
    B.suavizar(a, ciclo=False)
    B.completar(a, n)
    return a, n


# ------------------------------------------------------------------ pedir
N_PE_ENTRA, N_PE = 18, 36
SENTADO = dict(sube=-0.040, adelante=0.004, cabeceo=10.0)
# Rodea las patas: la base baja al piso y el resto se curva hacia adelante por el lado
# derecho de Felipe (el que queda a la vista en la sala). En reposo los huesos de la cola
# suben 35°, 81°, 86°, 67° y 29° sobre la horizontal: el cabeceo de cada uno los deja
# casi al ras del piso y el giro lateral los curva alrededor del cuerpo.
COLA_SENTADO = [(-50, -8), (-40, -40), (-5, -55), (20, -55), (40, -45)]


def _ajustar_sentado():
    """Baja la grupa lo justo para que las manos lleguen al piso con el pecho levantado:
    las patas delanteras de Felipe son cortas y casi rectas en reposo."""
    sobra = B.natural("del", "L", sube=0.0, adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"]).z \
        - B.BOLA[("del", "L")].z
    SENTADO["sube"] = -sobra - 0.002
    print("sentado: la grupa baja %.1f mm" % (-SENTADO["sube"] * 1000))


def _manos_sentado(f, salvo=None):
    for lado in ("L", "R"):
        if lado != salvo:
            B.pata(f, "del", lado, pos=_en_piso(B.natural("del", lado, **SENTADO) + V((0, -0.004, 0))),
                   escapula=4)


def _sentado(f, ladeo=12.0, extra_cab=0.0, balanceo=0.0):
    _torso(f, sube=SENTADO["sube"], adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"] + extra_cab,
           balanceo=balanceo)
    B.lomo(f, arco=2, cabeceo=4)
    # Mira hacia arriba, a la persona, con la cabeza ladeada.
    B.cabeza(f, cuello=-10, cab=-12, ladeo=ladeo, giro_lat=-8)
    B.orejas(f, atras=-4)
    for lado in ("L", "R"):
        # Corvejón y talón al piso.
        B.pata(f, "tras", lado, desp=(0, 0.004, 0), rot=-60, dedo=40)


def pedir_entrada():
    _ajustar_sentado()
    a = B.nueva_accion("pedir_entrada")
    n = N_PE_ENTRA
    _torso(0); B.lomo(0); B.cabeza(0); B.orejas(0); B.patas_quietas(0)
    _torso(6, sube=-0.014, adelante=0.002, cabeceo=5)
    B.cabeza(6, cuello=4, cab=-4)
    for lado in ("L", "R"):
        B.pata(6, "tras", lado, desp=(0, 0.002, 0), rot=-22, dedo=14)
        B.pata(6, "del", lado, escapula=0)
    # Se pasa un poco al bajar la grupa y se acomoda.
    _torso(12, sube=SENTADO["sube"] - 0.006, adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"] + 3)
    B.cabeza(12, cuello=-6, cab=-10, ladeo=6)
    for lado in ("L", "R"):
        B.pata(12, "tras", lado, desp=(0, 0.004, 0), rot=-60, dedo=40)
    _manos_sentado(12)
    _sentado(n)
    _manos_sentado(n)
    for f, k in ((0, 0.0), (6, 0.25), (12, 0.8)):
        _cola_forma(f, COLA_SENTADO, k, retraso=1 if f else 0)
    _cola_forma(n, COLA_SENTADO, 1.0)
    B.suavizar(a, ciclo=False)
    B.completar(a, n)
    return a, n


def pedir():
    a = B.nueva_accion("pedir")
    n = N_PE
    # Pata delantera derecha: sube, toca el aire dos veces y vuelve a apoyar.
    # (cuadro, desp desde donde la deja el torso sentado, giro, dedos)
    toques = [(0, None, 0, 0), (5, (0, -0.014, 0.040), -30, 10), (9, (0, -0.036, 0.085), -66, -20),
              (12, (0, -0.046, 0.064), -42, 16), (15, (0, -0.036, 0.088), -68, -20), (18, (0, -0.048, 0.064), -42, 16),
              (22, (0, -0.034, 0.082), -60, -16), (28, (0, -0.006, 0.022), -14, 6), (31, None, 0, 0), (n, None, 0, 0)]
    for f, d, r, dd in toques:
        base = B.natural("del", "R", **SENTADO)
        pos = _en_piso(base + V((0, -0.004, 0))) if d is None else base + V(d)
        B.pata(f, "del", "R", pos=pos, rot=r, dedo=dd, escapula=-10 if d and d[2] > 0.03 else 4)
    for f in (0, n):
        _manos_sentado(f, salvo="R")
    lado_cab = B.curva([(0, 12), (9, 16), (22, 18), (31, 12), (36, 12)])
    arriba = B.curva([(0, 0), (6, 1), (28, 1), (32, 0), (36, 0)])
    for f in range(0, n + 1, 3):
        # Se inclina hacia la pata que queda apoyada y se estira un poco al pedir.
        _sentado(f, ladeo=lado_cab(f), extra_cab=3 * arriba(f), balanceo=-4 * arriba(f))
    # Cola: la punta curvada se mueve lento de lado a lado.
    B.cola(n, estatica=COLA_SENTADO, onda=lambda t: (0.0, 0.0),
           punta=lambda t, i: (3 * B.seno(t, n, 1, 0.2) if i >= 3 else 0.0, 7 * max(0, i - 2) * B.seno(t, n, 1)))
    B.suavizar(a)
    B.completar(a, n)
    return a, n


# ------------------------------------------------------------------ saltar
N_SALTO = 34
DESPEGUE = 12     # cuadro en que las traseras dejan el piso
ATERRIZA = 24     # cuadro en que tocan las delanteras


def saltar():
    a = B.nueva_accion("saltar")
    n = N_SALTO
    # torso: (cuadro, sube, cabeceo, estira, arco, lado, giro)
    cuerpo = [(0, 0, 0, 1.0, 0, 0, 0), (4, -0.012, -3, 0.97, 0, 0, 0),
              (6, -0.022, -5, 0.95, 0, 0.007, 5), (8, -0.026, -5, 0.95, 0, -0.007, -5),   # anticipación: mueve la grupa
              (10, -0.028, -6, 0.94, 0, 0.005, 3), (11, -0.030, -7, 0.93, 0, 0, 0),
              (DESPEGUE, 0.004, 12, 1.07, -4, 0, 0),    # impulso: las traseras empujan, el cuerpo se estira
              (14, 0.012, 8, 1.05, -2, 0, 0), (18, 0.012, 0, 1.0, 6, 0, 0),   # aire: recogido, lomo redondo
              (22, 0.006, -10, 1.03, 0, 0, 0),           # caída: delanteras adelante
              (ATERRIZA, 0.0, -12, 1.0, 0, 0, 0),        # tocan las delanteras
              (27, -0.022, -3, 0.93, 10, 0, 0),          # baja la grupa, el lomo se arquea y amortigua
              (30, -0.008, 0, 0.98, 4, 0, 0), (n, 0, 0, 1.0, 0, 0, 0)]
    sube = B.curva([(c[0], c[1]) for c in cuerpo])
    cabe = B.curva([(c[0], c[2]) for c in cuerpo])
    for f, su, cab, est, arco, lado, gl in cuerpo:
        _torso(f, sube=su, cabeceo=cab, estira=est, lado=lado, giro_lat=gl)
        B.lomo(f, arco=arco)
    for f, cu, ca in [(0, 0, 0), (6, -4, -6), (11, -6, -8), (DESPEGUE, -2, -6), (18, 4, 0), (22, 8, 2),
                      (ATERRIZA, 12, 0), (27, 10, 4), (n, 0, 0)]:
        B.cabeza(f, cuello=cu, cab=ca)
    for f, g in ((0, 0), (8, -6), (DESPEGUE, 8), (18, 14), (ATERRIZA, 4), (28, 0), (n, 0)):
        B.orejas(f, atras=g)
    # Patas: (cuadro, None = apoyada en su lugar | desp desde donde la deja el torso, giro, dedos)
    tras = [(0, None, 0, 0), (11, None, 0, 0), (DESPEGUE, None, 58, -40),
            (14, (0, 0.024, 0.016), 44, -10), (18, (0, -0.006, 0.026), 28, -4), (22, (0, -0.008, 0.018), 10, 0),
            (ATERRIZA, (0, -0.004, 0.012), 4, 0), (27, None, 0, 0), (n, None, 0, 0)]
    dela = [(0, None, 0, 0, 0), (11, None, 0, 0, 4), (DESPEGUE, (0, -0.010, 0.012), 32, -10, -10),
            (15, (0, 0.004, 0.034), 62, 20, -14), (19, (0, -0.012, 0.020), 30, 4, -6),
            (22, (0, -0.020, -0.004), -10, -6, 4), (ATERRIZA, None, 0, 0, 8), (27, None, 0, 0, 4),
            (n, None, 0, 0, 0)]
    for lado, des in (("L", 0), ("R", 1)):
        for f, d, r, dd in tras:
            pos = None if d is None else B.natural("tras", lado, sube=sube(f), cabeceo=cabe(f)) + V(d)
            B.pata(f, "tras", lado, pos=pos, rot=r, dedo=dd)
        for f, d, r, dd, esc in dela:
            # La segunda mano llega un cuadro después (no toca el piso como un bloque).
            f2 = f + des if ATERRIZA <= f < n else f
            pos = None if d is None else B.natural("del", lado, sube=sube(f2), cabeceo=cabe(f2)) + V(d)
            B.pata(f2, "del", lado, pos=pos, rot=r, dedo=dd, escapula=esc)
    # Cola: en la anticipación se agita; al despegar va abajo y atrás, en el aire sube como
    # balance y al aterrizar da un latigazo. La onda viaja de la base a la punta.
    cab = B.curva([(0, 0), (8, -8), (11, -22), (DESPEGUE + 2, -30), (18, 18), (22, 24), (ATERRIZA + 1, 8),
                   (27, -24), (30, 14), (32, -4), (n, 0)])
    lado = B.curva([(0, 0), (5, 8), (7, -8), (9, 8), (11, 0), (n, 0)])
    B.cola(n, estatica=[(0, 0)] * 5, onda=lambda t: (cab(t), lado(t)), ciclo=False, paso=1)
    B.suavizar(a, ciclo=False)
    B.completar(a, n)
    return a, n


# ------------------------------------------------------------------ quieto largo: sentado
# Si el jugador no toca nada un rato: se sienta, mira al jugador y juega con una pelota.
# La pelota NO va en el modelo: felipe_rig.json trae los cuadros de contacto de la pata y la
# posición del pie en ese momento; Godot mueve una pelota aparte.
N_SENTARSE, N_SENT_MIRA, N_SENT_PELOTA = 20, 72, 48
CONTACTOS_PELOTA = [14, 32]   # cuadros en que la pata derecha toca la pelota (en el piso)


def _sentarse_claves(f_de):
    """Claves de quieto -> sentado; f_de(t) mapea el tiempo (para levantarse se invierte)."""
    n = N_SENTARSE
    _torso(f_de(0)); B.lomo(f_de(0)); B.cabeza(f_de(0)); B.orejas(f_de(0)); B.patas_quietas(f_de(0))
    _torso(f_de(7), sube=-0.014, adelante=0.002, cabeceo=5)
    B.cabeza(f_de(7), cuello=4, cab=-2)
    for lado in ("L", "R"):
        B.pata(f_de(7), "tras", lado, desp=(0, 0.002, 0), rot=-22, dedo=14)
        B.pata(f_de(7), "del", lado, escapula=0)
    _torso(f_de(13), sube=SENTADO["sube"] - 0.006, adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"] + 3)
    B.cabeza(f_de(13), cuello=-2, cab=-4, ladeo=3)
    for lado in ("L", "R"):
        B.pata(f_de(13), "tras", lado, desp=(0, 0.004, 0), rot=-60, dedo=40)
    _manos_sentado(f_de(13))
    _sentado_quieto(f_de(n))
    for f, k in ((0, 0.0), (7, 0.25), (13, 0.8), (n, 1.0)):
        _cola_forma(f_de(f), COLA_SENTADO, k)


def _sentado_quieto(f, cuello=-4.0, cab=-4.0, giro=0.0, ladeo=4.0):
    """Sentado, mirando al frente (la capa de Godot gira la cabeza hacia el jugador)."""
    _torso(f, sube=SENTADO["sube"], adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"])
    B.lomo(f, arco=2, cabeceo=4)
    B.cabeza(f, cuello=cuello, cab=cab, giro_lat=giro, ladeo=ladeo)
    B.orejas(f, atras=0)
    for lado in ("L", "R"):
        B.pata(f, "tras", lado, desp=(0, 0.004, 0), rot=-60, dedo=40)
    _manos_sentado(f)


def sentarse():
    _ajustar_sentado()
    a = B.nueva_accion("sentarse")
    _sentarse_claves(lambda t: t)
    B.suavizar(a, ciclo=False)
    B.completar(a, N_SENTARSE)
    return a, N_SENTARSE


def levantarse():
    a = B.nueva_accion("levantarse")
    n = N_SENTARSE
    _sentarse_claves(lambda t: n - t)
    B.suavizar(a, ciclo=False)
    B.completar(a, n)
    return a, n


def sentado_mira():
    """Bucle de 3 s: sentado, mira al jugador con desdén (párpados de reojo, cabeza algo ladeada;
    el giro hacia la cámara lo pone Godot), respira y la cola barre el piso lento."""
    a = B.nueva_accion("sentado_mira")
    n = N_SENT_MIRA
    resp = lambda f: math.sin(2 * math.pi * 2 * f / n)
    lade = B.curva([(0, 4), (20, 7), (40, 7), (56, 3), (72, 4)])
    for f in range(0, n + 1, 6):
        _sentado_quieto(f, cuello=-4 + 0.6 * resp(f), cab=-6, ladeo=lade(f))
        _torso(f, sube=SENTADO["sube"] + 0.002 * resp(f), adelante=SENTADO["adelante"], cabeceo=SENTADO["cabeceo"])
    for f, g in ((0, 0), (30, 0), (33, 16), (37, 2), (n, 0)):
        B.orejas(f, atras=0, izq=g)
    # Cola: barre de lado a lado por el piso, lento, con la punta retrasada.
    B.cola(n, estatica=COLA_SENTADO, onda=lambda t: (0.0, 9 * B.seno(t, n, 1)),
           punta=lambda t, i: (4 * B.seno(t, n, 2, 0.3) if i >= 3 else 0.0, 0.0), retraso=4)
    B.suavizar(a)
    B.completar(a, n)
    return a, n


def sentado_pelota():
    """Bucle de 2 s: desde sentado, la pata delantera derecha da 2 manotazos a una pelota en el
    piso, delante y algo a su derecha (garras abajo en el contacto); la cabeza la sigue."""
    a = B.nueva_accion("sentado_pelota")
    n = N_SENT_PELOTA
    base = B.natural("del", "R", **SENTADO)
    piso = lambda p: _en_piso(p)
    # (cuadro, desp desde la mano en reposo, giro de la mano, dedos)
    golpes = [(0, None, 0, 0), (5, (0, -0.010, 0.045), -35, -10), (10, (-0.006, -0.040, 0.070), -60, -20),
              (CONTACTOS_PELOTA[0], (-0.010, -0.062, 0.0), 12, 28), (18, (-0.008, -0.045, 0.030), -25, 0),
              (23, None, 0, 0), (27, (0.004, -0.020, 0.050), -45, -14),
              (CONTACTOS_PELOTA[1], (0.012, -0.068, 0.0), 14, 30), (36, (0.010, -0.050, 0.030), -25, 0),
              (42, None, 0, 0), (n, None, 0, 0)]
    for f, d, r, dd in golpes:
        if d is None:
            pos = piso(base + V((0, -0.004, 0)))
        elif d[2] == 0.0:
            pos = piso(base + V(d))      # contacto: la mano en el piso
        else:
            pos = base + V(d)
        B.pata(f, "del", "R", pos=pos, rot=r, dedo=dd, escapula=-12 if d and d[2] > 0.03 else 4)
    for f in (0, n):
        _manos_sentado(f, salvo="R")
        for lado in ("L", "R"):
            B.pata(f, "tras", lado, desp=(0, 0.004, 0), rot=-60, dedo=40)
    # La cabeza baja a mirar la pelota y la sigue (va y vuelve tras cada golpe).
    sigue = B.curva([(0, 0), (12, 2), (16, -8), (22, -3), (30, 4), (34, 9), (40, 3), (48, 0)])
    baja = B.curva([(0, 12), (10, 14), (15, 18), (24, 12), (33, 18), (42, 13), (48, 12)])
    for f in range(0, n + 1, 3):
        golpe = 1.0 if any(abs(f - c) <= 3 for c in CONTACTOS_PELOTA) else 0.0
        _torso(f, sube=SENTADO["sube"], adelante=SENTADO["adelante"] + 0.004 * golpe,
               cabeceo=SENTADO["cabeceo"] - 2 * golpe, balanceo=-4)
        B.lomo(f, arco=2, cabeceo=4)
        B.cabeza(f, cuello=baja(f) * 0.5, cab=baja(f), giro_lat=sigue(f), ladeo=5)
        B.orejas(f, atras=-6)
    # Cola: alerta, la punta se sacude rápido.
    B.cola(n, estatica=COLA_SENTADO, onda=lambda t: (0.0, 4 * B.seno(t, n, 2)),
           punta=lambda t, i: (0.0, 6 * max(0, i - 2) * B.seno(t, n, 4)))
    B.suavizar(a)
    B.completar(a, n)
    return a, n
