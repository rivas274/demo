# Caminar y quieto de Felipe, con poses clave (ver anima_base.py para las ayudas).
import math
import anima_base as B

N_CAMINAR = 16        # 0,67 s a 24 fps (v2: antes 22 = 0,92 s, se veía lento, "de juguete")
N_QUIETO = 144        # 6 s: el quieto con pausas irregulares no debe verse como metrónomo
DUTY = 0.6            # fracción del ciclo con el pie apoyado (las patas en el aire van más rápido)
ZANCADA_U = 0.34      # largo del paso en unidades de Meshy (se pasa a metros con K)
ALZA_U = {"tras": 0.06, "del": 0.075}   # levanta poco pero con decisión (video 6)
# v4: postura del Felipe real (felipe-lomo-costado.jpg, video 6): la grupa más alta que los
# hombros, el lomo baja suave hacia adelante y las traseras van más estiradas (más largas).
POSTURA_SUBE = 0.012   # m que sube la cadera
POSTURA_CAB = -4.0     # grados: el frente baja
MANO_X = float(__import__("os").environ.get("FELIPE_MANO_X", "0.018"))  # m hacia afuera (elegido entre 0 y 0,024)
VUELO_X = float(__import__("os").environ.get("FELIPE_VUELO_X", "0.04"))  # m más afuera en el vuelo (elegido entre 0 y 0,04)
# Secuencia lateral de gato: trasera izq., delantera izq., trasera der., delantera der.
FASE = {("tras", "L"): 0.0, ("del", "L"): 0.25, ("tras", "R"): 0.5, ("del", "R"): 0.75}
# Poses de cada pata (claves y breakdowns): (fase, avance [-1 adelante .. +1 atrás] * zancada/2,
# alto [0..1] * alza, giro del pie [+ = talón arriba], giro de los dedos). El apoyo (0 a 0,6)
# va lineal (el pie no patina); el vuelo hace un arco con facilidad de entrada y salida.
POSES_PATA = [
    (0.00, -1.00, 0.00, 0, 0),     # contacto
    (0.08, -0.733, 0.00, 0, 0),    # bajada (recibe el peso)
    (0.30, 0.00, 0.00, 0, 0),      # apoyo medio
    (0.48, 0.60, 0.00, 18, -18),   # talón arriba, dedos planos
    (0.60, 1.00, 0.00, 50, -50),   # despegue (empuja atrás)
    (0.68, 0.80, 0.75, 75, -20),   # recoge: sube rápido y se dobla
    (0.77, 0.10, 1.00, 45, -8),    # paso: lo más alto, pasa por debajo
    (0.86, -0.75, 0.70, 10, 0),    # adelanta
    (0.94, -1.08, 0.22, -8, 6),    # estira para apoyar (breakdown antes del contacto)
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
            # La delantera, casi recta en reposo, alcanza con la escápula (como un gato real) y
            # con el paso centrado un poco más atrás.
            centro = 0.012 if pata == "del" else 0.0
            # La mano delantera se apoya un poco más afuera: la pata de Felipe va inclinada hacia
            # adentro (hombro a 0,098 m del centro, mano a 0,049) y, al doblarse, el codo se
            # metía bajo la melena y se abría al levantarla.
            # En el vuelo, la mano va además un poco más afuera (bajo el hombro): así el antebrazo
            # no queda inclinado hacia el centro cuando la pata se dobla.
            vuelo = VUELO_X * math.sin(math.pi * min(1.0, max(0.0, (fase - DUTY) / (1 - DUTY))))
            afuera = (MANO_X + vuelo if pata == "del" else 0.0) * (1 if lado == "L" else -1)
            B.pata(f, pata, lado, desp=(afuera, av * Z / 2 + centro, al * alza), rot=g, dedo=gd,
                   escapula=20 * av if pata == "del" else None)
            if fase < DUTY - 1e-6:
                lineales.append(f)
        B.lineal(a, B.CTL[(pata, lado)]["ctl"], lineales)
    baja = 0.012 * B.K
    lomo_largo = 0.38 * B.K
    for f in range(n + 1):
        p = f / n
        s = lambda fase, veces=1: math.sin(2 * math.pi * (veces * p - fase))
        c = lambda fase, veces=1: math.cos(2 * math.pi * (veces * p - fase))
        # Peso: la grupa baja un poco después de cada contacto trasero (0 y 0,5) y los hombros
        # después de los delanteros (0,25 y 0,75): suben y bajan desfasados, 2 veces por ciclo.
        grupa = -baja * (0.5 + 0.5 * c(0.10, 2))
        hombro = -baja * (0.5 + 0.5 * c(0.35 * 2, 2))
        # Balanceo hacia la pata que apoya: la cadera se corre sobre la trasera apoyada y cae
        # del lado de la que vuela; el pecho lo hace con el desfase de las delanteras.
        lado = 0.007 * B.K * s(0.0)
        rol_grupa = -3.0 * s(0.0)
        rol_pecho = -2.5 * s(0.25)
        giro = 2.0 * s(0.05)
        pecho_cab = math.degrees((hombro - grupa) / lomo_largo)
        B.torso(f, sube=POSTURA_SUBE + grupa, lado=lado, cabeceo=POSTURA_CAB, balanceo=rol_grupa, giro_lat=giro)
        # Torsión: el pecho gira y rola distinto de la grupa.
        B.lomo(f, cabeceo=pecho_cab, giro_lat=-2.0 * s(0.15), balanceo=rol_pecho - rol_grupa)
        # Cabeza estabilizada: mira adelante y compensa el cabeceo, el balanceo y el giro del
        # cuerpo; solo un cabeceo mínimo y atrasado.
        B.cabeza(f, cuello=20 + POSTURA_CAB + pecho_cab + 0.6 * s(0.55, 2), cab=-8 - 0.4 * s(0.65, 2),
                 giro_lat=-giro + 1.5 * s(0.4), ladeo=-rol_pecho * 0.9)
        B.orejas(f, atras=4)
    # Cola alta, en arco hacia adelante sobre la grupa, con la punta suelta (video 6). La onda
    # (de lado una vez por ciclo, sube y baja dos veces) viaja de la base a la punta con 2
    # cuadros de retraso por hueso.
    B.cola(n, estatica=[(14, 0), (8, 0), (14, 0), (22, 0), (18, 0)],
           onda=lambda t: (3.0 * B.seno(t, n, 2, 0.1), 8.0 * B.seno(t, n, 1, 0.25)), paso=1, retraso=2)
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
        B.torso(f, sube=POSTURA_SUBE + 0.004 * B.K * resp(f), cabeceo=POSTURA_CAB)
        B.lomo(f, cabeceo=-0.8 * resp(f))
        B.cabeza(f, cuello=POSTURA_CAB + 0.8 * math.sin(2 * math.pi * 2 * f / n + 0.6), cab=1.0 * math.sin(2 * math.pi * f / n),
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
