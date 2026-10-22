# Caminar y quieto de Felipe, con poses clave (ver anima_base.py para las ayudas).
import math
import anima_base as B

N_CAMINAR = 22        # 0,92 s a 24 fps
N_QUIETO = 144        # 6 s: el quieto con pausas irregulares no debe verse como metrónomo
DUTY = 0.6            # fracción del ciclo con el pie apoyado
ZANCADA_U = 0.30      # largo del paso en unidades de Meshy (se pasa a metros con K)
ALZA_U = {"tras": 0.065, "del": 0.08}
FASE = {("tras", "L"): 0.0, ("del", "L"): 0.25, ("tras", "R"): 0.5, ("del", "R"): 0.75}
# Poses clave de cada pata: (fase, avance [-1 adelante .. +1 atrás] * zancada/2,
# alto [0..1] * alza, giro del pie [+ = talón arriba], giro de los dedos).
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


def zancada():
    return ZANCADA_U * B.K


def velocidad():
    return zancada() / (DUTY * N_CAMINAR / B.FPS)


def caminar():
    a = B.nueva_accion("caminar")
    n = N_CAMINAR
    Z = zancada()
    for (pata, lado), fase0 in FASE.items():
        alza = ALZA_U[pata] * B.K
        claves = sorted(((fase + fase0) * n % n, fase, av, al, g, gd) for fase, av, al, g, gd in POSES_PATA)
        claves.append((claves[0][0] + n,) + claves[0][1:])
        lineales = []
        for f, fase, av, al, g, gd in claves:
            B.pata(f, pata, lado, desp=(0, av * Z / 2, al * alza), rot=g, dedo=gd,
                   escapula=10 * av if pata == "del" else None)
            if fase < DUTY - 1e-6:
                lineales.append(f)
        B.lineal(a, B.CTL[(pata, lado)]["ctl"], lineales)
    baja = 0.014 * B.K
    lomo_largo = 0.38 * B.K
    for i in range(9):
        p = i / 8.0
        f = p * n
        s = lambda fase, veces=1: math.sin(2 * math.pi * (veces * p - fase))
        # La grupa baja justo después de cada contacto trasero; los hombros, de los delanteros.
        grupa = -baja * (0.5 + 0.5 * math.cos(4 * math.pi * (p - 0.10)))
        hombro = -baja * (0.5 + 0.5 * math.cos(4 * math.pi * (p - 0.35)))
        B.torso(f, sube=grupa, lado=0.008 * B.K * s(0.15), balanceo=3.0 * s(0.1), giro_lat=2.5 * s(0.05))
        B.lomo(f, cabeceo=math.degrees((hombro - grupa) / lomo_largo), giro_lat=-1.5 * s(0.15),
               balanceo=-2.5 * s(0.35))
        # Cabeza baja y adelantada; se mece poco y con retraso (los gatos la estabilizan).
        B.cabeza(f, cuello=22 + 1.2 * s(0.45, 2), cab=-9 - 1.2 * s(0.5, 2), giro_lat=2.0 * s(0.3))
        B.orejas(f, atras=4)
    # Cola a media altura en gancho; la onda (lado a lado una vez por ciclo, sube y baja dos
    # veces) viaja de la base a la punta con 3 cuadros de retraso por hueso.
    B.cola(n, estatica=[(2, 0), (-22, 0), (-8, 0), (16, 0), (26, 0)],
           onda=lambda t: (2.5 * B.seno(t, n, 2), 7.0 * B.seno(t, n, 1, 0.25)))
    B.suavizar(a)
    B.completar(a, n)
    return a, n


def quieto():
    a = B.nueva_accion("quieto")
    n = N_QUIETO
    B.patas_quietas(0)
    B.patas_quietas(n)
    resp = lambda f: math.sin(2 * math.pi * 4 * f / n)  # 4 respiraciones en 6 s
    mira = B.curva([(0, 0), (30, 0), (46, 6), (80, 6), (96, -3), (126, -3), (144, 0)])
    for i in range(0, n + 1, 6):
        f = i
        B.torso(f, sube=0.004 * B.K * resp(f))
        B.lomo(f, cabeceo=-0.8 * resp(f))
        B.cabeza(f, cuello=0.8 * math.sin(2 * math.pi * 2 * f / n + 0.6), cab=1.0 * math.sin(2 * math.pi * f / n),
                 giro_lat=mira(f), ladeo=0.4 * mira(f))
    # Orejas: un respingo de la izquierda a los 2 s y otro chico de la derecha a los 4,5 s.
    for f, g in ((0, 0), (44, 0), (47, 22), (50, 4), (54, 16), (60, 0), (n, 0)):
        B.orejas(f, atras=0, izq=g)
    # Cola: nunca congelada; vaivén lento con pausas irregulares y un tic de la punta.
    lado = B.curva([(0, 0), (20, 7), (40, -3), (56, -3), (76, 6), (86, 6), (108, -6), (130, -1), (144, 0)])
    cab = B.curva([(0, 0), (30, 2), (70, -1.5), (110, 2), (144, 0)])

    def tic(t, i):
        if i < 3:
            return 0.0, 0.0
        u = (t - 94) / 3.0
        golpe = math.exp(-u * u) * 18 * (i - 2) / 2 if -6 < t - 94 < 10 else 0.0
        return golpe, golpe * 0.4
    B.cola(n, estatica=[(0, 0)] * 5, onda=lambda t: (cab(t), lado(t)), punta=tic)
    B.suavizar(a)
    B.completar(a, n)
    return a, n
