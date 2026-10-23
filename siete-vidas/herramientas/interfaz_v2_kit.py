#!/usr/bin/env python3
"""Kit final de piezas de la interfaz v2, estilo «A + C», a la escala real del juego (base 640x360).

Dos clases de piezas:
- Geométricas (marcos, franjas, fondos de retrato, barra del jefe, cartel, logro, pausa, Ficha, aviso, fragmentos):
  se dibujan por código a 1 px real con las MISMAS funciones de la lámina (`interfaz_v2_laminas.py` y la mezcla
  «AC» de `interfaz_v2_laminas_layout.py`), así coinciden con direccion-arte-AC-v2.png.
- Con forma propia (huella, pescadito, orejita y cola del globito, huella del sello): salen de las hojas de IA con
  `interfaz_v2_kit_ia.py` (variantes y puntaje); aquí está la ganadora de cada una retocada a mano píxel a píxel.

Cada pieza se guarda recortada a lo que ocupa (con la sombra adentro) y se anota su «ancla» (dónde cae, dentro del
PNG, la esquina (x, y) que usa el layout) y, si se estira, sus márgenes de 9 partes (calculados: las columnas y filas
del centro son todas iguales).

Uso:  python3 siete-vidas/herramientas/interfaz_v2_kit.py
Sale: siete-vidas/juego/assets/ui/v2/*.png y README.md
"""
from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw

import interfaz_v2_laminas as k
import interfaz_v2_laminas_layout as L

O = L.opcion("AC")
DESTINO = os.path.join(k.JUEGO, "assets", "ui", "v2")
C = lambda n: k.hexa(O[n])  # noqa: E731

# -------------------------------------------------------------------------------------------------------------------
# Paleta del kit: la de A + C y los tonos de luz y sombra que ya usa la lámina (mismas mezclas, fijadas aquí)
# -------------------------------------------------------------------------------------------------------------------
BLANCO = (255, 255, 255)
TONOS = {
    "felipe_luz": k.mezclar(C("felipe"), BLANCO, 0.5),          # luz de la huella y del pescadito
    "felipe_osc": k.mezclar(C("felipe"), C("contorno"), 0.35),   # sombra de la huella; botón apretado
    "felipe_brillo": k.mezclar(C("felipe"), BLANCO, 0.6),        # línea de luz del cartel
    "cura_luz": k.mezclar(k.mezclar(C("felipe"), BLANCO, 0.5), BLANCO, 0.35),
    "cura": k.mezclar(C("felipe"), BLANCO, 0.35),
    "cura_osc": k.mezclar(k.mezclar(C("felipe"), C("contorno"), 0.35), BLANCO, 0.35),
    "vacio": k.mezclar(C("panel"), C("apagado"), 0.35),
    "vacio_luz": k.mezclar(C("panel"), C("apagado"), 0.7),
    "aspi_luz": k.mezclar(C("aspi"), BLANCO, 0.45),             # línea de luz del relleno del jefe
}
BASE = ["fondo", "panel", "linea", "texto", "apagado", "contorno", "sombra", "felipe", "oportunidad", "valeria",
        "aspi", "maquina"]
PALETA = {n: C(n) for n in BASE}
PALETA.update(TONOS)


def hexs(c) -> str:
    return "#%02X%02X%02X" % tuple(c[:3])


# -------------------------------------------------------------------------------------------------------------------
# Formas con forma propia: ganadoras de interfaz_v2_kit_ia.py, retocadas a mano (ver la nota de cada una)
# -------------------------------------------------------------------------------------------------------------------
# Huella (relleno 11x10; con contorno 13x12). Gana «gemini-4 huecos» (0,74 de 15): dedos del centro altos y finos,
# dedos de los lados más bajos y almohadilla en trapecio con la muesca abajo. Retoque: se subió una fila (la de
# arriba quedaba vacía), los dedos del centro pasan a 2x3 y la almohadilla se ensancha abajo para leerse a x1.
HUELLA = [
    "...XX.XX...",
    "...XX.XX...",
    "...XX.XX...",
    "XX.......XX",
    "XX..XXX..XX",
    "...XXXXX...",
    "..XXXXXXX..",
    ".XXXXXXXXX.",
    ".XXXXXXXXX.",
    "..XXX.XXX..",
]
# Sello: la huella del rombo. Gana «chatgpt-1 huecos» (0,79 de 18), con el mismo dibujo que la huella de Gemini 4
# (dedos altos al centro, bajos a los lados, almohadilla en trapecio). Retoque: simetría y la fila de arriba; queda
# igual a la huella, así el símbolo es uno solo en toda la interfaz. El rombo es geometría (el de la lámina).
HUELLA_SELLO = HUELLA
# Pescadito de snack (relleno 12x7; con contorno 14x9). Gana «chatgpt-1 centro» (0,85 de 15): el único con ojo.
# Retoque: el ojo va en la cabeza (la IA dejaba 2 manchas oscuras), la cola se abre en dos y la panza se simplifica.
SNACK = [
    "...XXXX...XX",
    ".XXXXXXXX.XX",
    "XXOXXXXXXXX.",
    "XXXXXXXXXX..",
    ".XXXXXXXXXX.",
    "..XXXXXX.XXX",
    "...XXXX...XX",
]
# Orejita del globito (la izquierda; la derecha es su espejo). C contorno, X panel, A ámbar.
# Gana «gemini-2-der centro» (0,84 de 30): oreja oscura con el interior ámbar en una sola mancha. Retoque: escalera
# limpia en los dos lados (1 px por fila) y sin el doble contorno de la fila 3. La base no lleva contorno: se apoya en
# el globito y lo abre.
OREJA = [
    ".....CC....",
    "....CXXC...",
    "....CXXXC..",
    "...CXAAXXC.",
    "...CXAAAXC.",
    "..CXAAAAXXC",
    ".CXXAAAAXXC",
    ".CXXXXXXXXC",
]
# Cola del globito con huellita (sale del borde de abajo del globito y baja hacia Felipe). L luz ámbar.
# Gana «gemini-3 centro» (0,95 de 15): una «S» limpia de 2 px de grueso con la huellita al final. Retoque: sin la tapa
# de arriba (la cola abre el borde del globito) y la huellita con luz arriba.
COLA = [
    "....CXXC",
    "....CXXC",
    "....CXXC",
    "..CCXXC.",
    ".CXXXC..",
    ".CXXC...",
    "CXXC....",
    "CXXC....",
    "CXXC....",
    "CXXXCCCC",
    ".CXXLLLC",
    ".CXXAAAC",
    "..CCCCC.",
]
VARIANTES = {  # cuántas variantes se compararon (interfaz_v2_kit_ia.py) y cuál ganó
    "huella": (15, "gemini-4 huecos", 0.74), "sello": (18, "chatgpt-1 huecos", 0.79),
    "snack": (15, "chatgpt-1 centro", 0.85), "oreja": (30, "gemini-2-der centro", 0.84),
    "cola": (15, "gemini-3 centro", 0.95),
}


def contornear(im: Image.Image) -> Image.Image:
    px = im.load()
    w, h = im.size
    cont = C("contorno")
    marcar = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h and px[xx, yy][3] and px[xx, yy] != cont:
                    marcar.append((x, y))
                    break
    for p in marcar:
        px[p] = cont
    return im


def huella(estado: str, escala: int = 1, forma=HUELLA) -> Image.Image:
    """Las 5 huellas con los mismos colores de la lámina: llena, media, vacia, golpe, curando."""
    w, h = len(forma[0]), len(forma)
    im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    px = im.load()
    for y, fila in enumerate(forma):
        for x, ch in enumerate(fila):
            if ch != "X":
                continue
            arriba = y == 0 or forma[y - 1][x] != "X"
            abajo = y == h - 1 or forma[y + 1][x] != "X"
            lleno = estado in ("llena", "curando", "golpe") or (estado == "media" and x <= 4)
            if estado == "golpe":
                c = C("dano")
            elif estado == "curando":
                c = TONOS["cura_luz"] if arriba else (TONOS["cura_osc"] if abajo else TONOS["cura"])
            elif lleno:
                c = TONOS["felipe_luz"] if arriba else (TONOS["felipe_osc"] if abajo else C("felipe"))
            else:
                c = TONOS["vacio_luz"] if arriba else TONOS["vacio"]
            px[x + 1, y + 1] = c
    contornear(im)
    if escala > 1:
        im = im.resize((im.width * escala, im.height * escala), Image.NEAREST)
    return im


def snack() -> Image.Image:
    w, h = len(SNACK[0]), len(SNACK)
    im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    px = im.load()
    for y, fila in enumerate(SNACK):
        for x, ch in enumerate(fila):
            if ch == ".":
                continue
            arriba = y == 0 or SNACK[y - 1][x] == "."
            abajo = y == h - 1 or SNACK[y + 1][x] == "."
            px[x + 1, y + 1] = C("contorno") if ch == "O" else (
                TONOS["felipe_luz"] if arriba else (TONOS["felipe_osc"] if abajo else C("felipe")))
    return contornear(im)


def de_rejilla(rejilla, espejo=False) -> Image.Image:
    colores = {"C": C("contorno"), "X": C("panel"), "A": C("felipe"), "L": TONOS["felipe_luz"]}
    w, h = len(rejilla[0]), len(rejilla)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, fila in enumerate(rejilla):
        for x, ch in enumerate(fila[::-1] if espejo else fila):
            if ch in colores:
                im.putpixel((x, y), colores[ch])
    return im


# -------------------------------------------------------------------------------------------------------------------
# Registro de piezas
# -------------------------------------------------------------------------------------------------------------------
PIEZAS: dict = {}   # nombre -> info


def margenes(im: Image.Image):
    """Márgenes de 9 partes: el tramo de columnas (y de filas) iguales a la del centro, que se puede estirar.
    Devuelve (izq, der, arriba, abajo); arriba/abajo = None si ninguna fila se repite (alto fijo)."""
    a = np.asarray(im)
    w, h = im.width, im.height

    def tramo(n, igual):
        c = n // 2
        i0, i1 = c, c
        while i0 - 1 >= 0 and igual(i0 - 1, c):
            i0 -= 1
        while i1 + 1 < n and igual(i1 + 1, c):
            i1 += 1
        return i0, i1

    x0, x1 = tramo(w, lambda i, c: np.array_equal(a[:, i], a[:, c]))
    y0, y1 = tramo(h, lambda i, c: np.array_equal(a[i], a[c]))
    hz = (x0, w - 1 - x1) if x1 - x0 >= 2 else None
    # a lo alto solo si el tramo igual es de verdad (la mitad del alto o más): en las cajas con lados en diagonal,
    # unas pocas filas iguales seguidas son casualidad de la escalera y estirarlas la deforma
    vt = (y0, h - 1 - y1) if y1 - y0 + 1 >= h // 2 else None
    return hz, vt


def pieza(nombre, dibujar, origen, nota, ancho_logico=None, alto_logico=None, estira=True, recorte=None):
    """dibujar(img, x, y) dibuja la pieza con el ancla en (x, y) sobre un lienzo transparente.
    recorte: (x0, y0, x1, y1) relativo al ancla, para piezas que van encima de otra con el mismo tamaño."""
    lienzo = Image.new("RGBA", (900, 500), (0, 0, 0, 0))
    ax, ay = 40, 40
    dibujar(lienzo, ax, ay)
    caja = lienzo.getbbox() if recorte is None else (ax + recorte[0], ay + recorte[1], ax + recorte[2], ay + recorte[3])
    im = lienzo.crop(caja)
    info = {"archivo": f"{nombre}.png", "ancla": (ax - caja[0], ay - caja[1]), "tam": im.size, "origen": origen,
            "nota": nota, "ancho": ancho_logico, "alto": alto_logico, "hz": None, "vt": None}
    if estira:
        info["hz"], info["vt"] = margenes(im)
    PIEZAS[nombre] = info
    im.save(os.path.join(DESTINO, info["archivo"]))
    return im


def imagen(nombre, im, origen, nota):
    PIEZAS[nombre] = {"archivo": f"{nombre}.png", "ancla": (0, 0), "tam": im.size, "origen": origen, "nota": nota,
                      "ancho": None, "alto": None, "hz": None, "vt": None}
    im.save(os.path.join(DESTINO, f"{nombre}.png"))


# -------------------------------------------------------------------------------------------------------------------
# Piezas geométricas (mismo dibujo que la lámina)
# -------------------------------------------------------------------------------------------------------------------
CODIGO = "código (interfaz_v2_kit.py, mismas funciones que la lámina)"
COLORES = {"felipe": "felipe", "valeria": "valeria", "aspi": "aspi"}
W0 = 64  # ancho lógico con que se guardan las piezas que se estiran a lo ancho


def sin_fragmentos(f):
    def envuelto(*a, **kw):
        guardado = k.fragmentos
        k.fragmentos = lambda *x, **y: None
        try:
            return f(*a, **kw)
        finally:
            k.fragmentos = guardado
    return envuelto


fondo_retrato = sin_fragmentos(k.fondo_retrato)


def franja(img, x, y, w, alto, color):
    """La franja del nombre o del título de la A (k.franja sin el texto): bloque del color con contorno."""
    pts = k.paralelo(x, y, w, alto, O["k"])
    k.poligono(img, [(pts[0][0] - 1, pts[0][1])] + pts[1:2] + [(pts[2][0] + 1, pts[2][1] + 1),
                                                               (pts[3][0] - 1, pts[3][1] + 1)], C("contorno"))
    k.poligono(img, k.encoger(pts, 1), C(color))


def barra_paralelo(img, x, y, w, h, color, contorno=True, kk=None, s=None):
    pts = k.paralelo(x, y, w, h, kk or O["k"], s=s)
    if contorno:
        k.poligono(img, pts, C("contorno"))
        k.poligono(img, k.encoger(pts, 1), color)
    else:
        k.poligono(img, pts, color)


def fragmento(t: int, color) -> Image.Image:
    im = Image.new("RGBA", (t + 1, t + 1), (0, 0, 0, 0))
    k.poligono(im, [(0, 0), (t, t // 2), (1, t)], color)
    return im


def posiciones_fragmentos(cx, cy, n, semilla, radio):
    """Las mismas posiciones y tamaños que k.fragmentos (opción A): [(x, y, t)]."""
    import math
    import random
    rnd = random.Random(semilla)
    out = []
    for _ in range(n):
        ang = rnd.uniform(0, 6.283)
        r = rnd.uniform(radio * 0.6, radio)
        x = cx + math.cos(ang) * r
        y = cy + math.sin(ang) * r * 0.7
        t = rnd.randint(2, 5)
        out.append((int(x), int(y), t))
    return out


def construir():
    os.makedirs(DESTINO, exist_ok=True)
    for f in os.listdir(DESTINO):
        if f.endswith(".png"):
            os.remove(os.path.join(DESTINO, f))
    PIEZAS.clear()

    # --- Diálogo: marco (3 sombras de color) en normal (alto 50) y grande (alto 84), flecha
    for p, col in COLORES.items():
        for sufijo, alto in (("", 50), ("-grande", 84)):
            pieza(f"dialogo-marco-{p}{sufijo}", lambda im, x, y, a=alto, c=col: k.caja(im, O, x, y, W0, a, acento=O[c]),
                  CODIGO, f"Caja del diálogo; sombra dura de 3 px de {p}.", W0, alto)
    pieza("dialogo-flecha", lambda im, x, y: k.flecha(im, O, x, y, O["linea"]), CODIGO,
          "Flecha de «sigue» abajo a la derecha de la caja.", estira=False)
    # --- Franjas del nombre (15 normal, 26 grande) y la del jefe (14)
    for p, col in COLORES.items():
        for sufijo, alto in (("", 15), ("-grande", 26)):
            pieza(f"nombre-franja-{p}{sufijo}", lambda im, x, y, a=alto, c=col: franja(im, x, y, 40, a, c), CODIGO,
                  f"Franja del nombre en bloque de {p} (el texto va encima).", 40, alto)
    # --- Fondos de retrato (diálogo normal 58x58 y grande 58x60), sin fragmentos (van aparte)
    for p, col in COLORES.items():
        for sufijo, alto in (("", 58), ("-grande", 60)):
            pieza(f"retrato-fondo-{p}{sufijo}", lambda im, x, y, a=alto, c=col: fondo_retrato(im, O, x, y, 58, a, O[c]),
                  CODIGO, f"Fondo inclinado del retrato de {p}; sombra oscura de 3 px.", 58, alto, estira=False)
    # --- Fragmentos: tiras de 4 triángulos (t = 2, 3, 4, 5) en celdas de 6x6
    for p, col in COLORES.items():
        tira = Image.new("RGBA", (24, 6), (0, 0, 0, 0))
        for i, t in enumerate((2, 3, 4, 5)):
            tira.alpha_composite(fragmento(t, C(col)), (i * 6, 0))
        imagen(f"fragmentos-{p}", tira, CODIGO, "Tira de 4 fragmentos (2, 3, 4 y 5 px) en celdas de 6x6.")

    # --- Barra del jefe
    pieza("jefe-retrato-marco", lambda im, x, y: fondo_retrato(im, O, x, y, 30, 26, O["aspi"]), CODIGO,
          "Marco chico e inclinado del retrato del jefe.", 30, 26, estira=False)
    bx_rel, bw, bh = 0, 220, 10
    pieza("jefe-barra-marco", lambda im, x, y: k.caja(im, O, x, y, bw, bh + 4, color_fondo=O["fondo"], acento=O["aspi"],
                                                      k=3), CODIGO, "Marco de la barra, vacío; sombra roja de 3 px.",
          bw, bh + 4)

    def cortes(im, x, y):
        d = ImageDraw.Draw(im)
        ix, iw = x + 5, bw - 12
        for i in range(2):
            sx = ix + int(iw * (i + 1) / 3)
            d.line([(sx, y + 3), (sx - 2, y + bh)], fill=C("contorno"), width=2)
    pieza("jefe-barra-cortes", cortes, CODIGO, "Los 2 cortes en diagonal que parten la barra en 3 fases; va encima "
          "de los rellenos, en el mismo lugar y del mismo tamaño que el marco.", estira=False,
          recorte=(0, 0, bw + 4, bh + 8))
    rel = Image.new("RGBA", (4, 6), C("aspi"))
    ImageDraw.Draw(rel).line([(0, 0), (3, 0)], fill=TONOS["aspi_luz"])
    imagen("jefe-barra-relleno", rel, CODIGO, "Tira de vida (se repite a lo ancho): 6 px de alto con la luz arriba.")
    imagen("jefe-barra-dano", Image.new("RGBA", (4, 6), C("dano")), CODIGO,
           "Tira de «daño reciente» crema (se repite a lo ancho); baja 300 ms después.")
    pieza("jefe-nombre-franja", lambda im, x, y: franja(im, x, y, 40, 14, "aspi"), CODIGO,
          "Franja del nombre del jefe (14 px).", 40, 14)

    # --- HUD de salud
    pieza("hud-caja", lambda im, x, y: k.caja(im, O, x, y, 152, 20, acento=O["felipe"], k=4), CODIGO,
          "Caja de la salud (cara + 9 huellas), 152x20.", 152, 20)
    pieza("hud-caja-grande", lambda im, x, y: k.caja(im, O, x, y, 304, 40, acento=O["felipe"], k=4), CODIGO,
          "Caja de la salud con texto grande, 304x40.", 304, 40)
    for est in ("llena", "media", "vacia", "golpe", "curando"):
        imagen(f"huella-{est}", huella(est), "IA: " + IA["huella"], f"Huella de salud, estado «{est}».")
        imagen(f"huella-{est}-grande", huella(est, 2), "IA: " + IA["huella"], f"Huella «{est}» a x2 (texto grande).")

    # --- Cartel de travesura
    def cartel_franja(im, x, y, w=W0 + 40):
        h, kk = 22, 2
        s = k.inclinacion(O, h, kk)
        pts = k.paralelo(x, y, w, h, kk, s=s)
        sp = O["sombra_px"] + 1
        k.poligono(im, [(a + sp, b + sp) for a, b in pts], C("sombra"))
        k.poligono(im, pts, C("contorno"))
        k.poligono(im, k.encoger(pts, 1), C("felipe"))
        ImageDraw.Draw(im).line([(x + s + 3, y + 2), (x + w - 4, y + 2)], fill=TONOS["felipe_brillo"])
    pieza("cartel-franja", cartel_franja, CODIGO, "Franja diagonal del cartel; sombra OSCURA de 4 px (el magenta es "
          "de Valeria).", W0 + 40, 22)

    def sello(im, x, y):
        rombo = [(x + 14, y), (x + 28, y + 15), (x + 14, y + 30), (x, y + 15)]
        k.poligono(im, rombo, C("contorno"))
        k.poligono(im, k.encoger(rombo, 1), C("linea"))
        k.poligono(im, k.encoger(rombo, 2), C("fondo"))
        im.alpha_composite(huella("llena", forma=HUELLA_SELLO), (x + 8, y + 9))
    pieza("cartel-sello", sello, "IA (la huella): " + IA["sello"] + "; el rombo, código",
          "Sello en rombo con la huella.", estira=False)
    pieza("cartel-linea", lambda im, x, y: k.caja(im, O, x, y, W0, 19, acento=O["felipe"]), CODIGO,
          "Segunda línea del cartel (nombre de la travesura).", W0, 19)

    # --- Logro (normal: alto 24, ícono rombo r=10; grande: alto 40, r=18)
    for sufijo, g in (("", 1), ("-grande", 2)):
        icono = 16 * g
        pieza(f"logro-etiqueta{sufijo}", lambda im, x, y, hh=icono + 8: k.caja(im, O, x, y, W0 + 40, hh,
                                                                               acento=O["felipe"]),
              CODIGO, "Etiqueta del logro (entra de lado).", W0 + 40, icono + 8)

        def icono_logro(im, x, y, g=g):
            r = 8 * g + 2
            rombo = [(x, y + r), (x + r, y), (x + 2 * r, y + r), (x + r, y + 2 * r)]
            k.poligono(im, rombo, C("contorno"))
            k.poligono(im, k.encoger(rombo, 1), C("felipe"))
            hu = huella("vacia", g)
            im.alpha_composite(hu, (x + r - hu.width // 2, y + r - hu.height // 2))
        pieza(f"logro-icono{sufijo}", icono_logro, "código + huella del kit", "Rombo ámbar con la huella vacía.",
              estira=False)

    # --- Aviso de oportunidad (limón, solo borde y texto) y su flecha
    o2 = dict(O, linea=O["oportunidad"])
    pieza("aviso-marco", lambda im, x, y: k.caja(im, o2, x, y, W0, 20, color_fondo=O["fondo"], acento=O["oportunidad"]),
          CODIGO, "Panel oscuro con borde y sombra limón (nunca un bloque amarillo).", W0, 20)

    def flecha_aviso(im, x, y):
        cx = x + 5
        k.poligono(im, [(cx - 5, y), (cx + 5, y), (cx, y + 6)], C("contorno"))
        k.poligono(im, [(cx - 3, y), (cx + 3, y), (cx, y + 4)], C("oportunidad"))
    pieza("aviso-flecha", flecha_aviso, CODIGO, "Flecha limón hacia abajo (apunta a lo que hay que hacer).",
          estira=False)

    # --- Globito de Felipe
    pieza("globito-caja", lambda im, x, y: k.caja(im, O, x, y, W0, 18, acento=O["felipe"]), CODIGO,
          "Caja del globito (una línea); sombra ámbar de 3 px.", W0, 18)
    imagen("globito-oreja-izq", de_rejilla(OREJA), "IA: " + IA["oreja"], "Orejita izquierda (la base abre el borde).")
    imagen("globito-oreja-der", de_rejilla(OREJA, espejo=True), "IA: " + IA["oreja"], "Orejita derecha (espejo).")
    imagen("globito-cola", de_rejilla(COLA), "IA: " + IA["cola"], "Cola corta con huellita; sale por abajo.")

    # --- Pausa
    pieza("pausa-panel", lambda im, x, y: k.caja(im, O, x, y, 576, 324, color_fondo=O["fondo"], acento=O["felipe"],
                                                 k=12), CODIGO, "Panel de la pausa (toda la zona segura).", 576, 324)
    pieza("titulo-franja", lambda im, x, y: franja(im, x, y, 40, 18, "felipe"), CODIGO,
          "Franja de título («PAUSA», «BOLSILLO»), 18 px.", 40, 18)
    s19 = k.inclinacion(O, 19)
    for est, fill, cont in (("normal", C("fondo"), False), ("resaltado", C("felipe"), True),
                            ("apretado", TONOS["felipe_osc"], True)):
        pieza(f"boton-{est}", lambda im, x, y, f=fill, c=cont: barra_paralelo(im, x, y, W0, 19, f, c, s=s19), CODIGO,
              {"normal": "Botón sin foco: del color del panel (en la lámina solo se ve su texto).",
               "resaltado": "Botón con foco: bloque diagonal ámbar, texto oscuro.",
               "apretado": "Botón apretado: ámbar oscuro."}[est], W0, 19)
    pieza("bolsillo-fila", lambda im, x, y: k.caja(im, O, x, y, W0, 22, acento=O["felipe"], k=4), CODIGO,
          "Fila del bolsillo (ícono, nombre y valor).", W0, 22)
    imagen("icono-snack", snack(), "IA: " + IA["snack"], "Pescadito de snack (12x7 de relleno).")
    cont = C("contorno")
    imagen("icono-calcetin", k.icono(L.ICONOS["calcetin"], C("valeria"), cont), CODIGO, "Calcetín del bolsillo.")
    imagen("icono-foto", k.icono(L.ICONOS["foto"], C("texto"), cont, ojo=C("panel")), CODIGO, "Foto del bolsillo.")
    # --- Ficha
    pieza("ficha-panel", lambda im, x, y: k.caja(im, O, x, y, 394, 166, acento=O["felipe"], k=12), CODIGO,
          "Panel de la Ficha de Su Majestad (en la pausa).", 394, 166)
    pieza("ficha-retrato-fondo", lambda im, x, y: fondo_retrato(im, O, x, y, 56, 52, O["felipe"]), CODIGO,
          "Fondo inclinado del retrato de la Ficha.", 56, 52, estira=False)
    pieza("ficha-barra-marco", lambda im, x, y: k.poligono(im, k.paralelo(x, y, 60, 9, 2), C("contorno")), CODIGO,
          "Marco de la barra de estadística (puntas en diagonal).", 60, 9)
    for p, col in (("felipe", "felipe"), ("maquina", "maquina"), ("aspi", "aspi")):
        pieza(f"ficha-barra-relleno-{p}", lambda im, x, y, c=col: k.poligono(im, k.paralelo(x, y, 30, 7, 2), C(c)),
              CODIGO, "Relleno de la barra de estadística (va a 1 px adentro del marco).", 30, 7)
    revisar_paleta()
    escribir_readme()
    return PIEZAS


IA = {
    "huella": "Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado)",
    "sello": "ChatGPT, hoja chatgpt/interfaz-v2/intento-1.png (generado con ChatGPT y retocado)",
    "snack": "ChatGPT, hoja chatgpt/interfaz-v2/intento-1.png (generado con ChatGPT y retocado)",
    "oreja": "Gemini, hoja gemini/interfaz-v2/intento-2.png (generado con Gemini y retocado)",
    "cola": "Gemini, hoja gemini/interfaz-v2/intento-3.png (generado con Gemini y retocado)",
}


def revisar_paleta():
    """Todo píxel visible del kit es un color exacto de la paleta (sin suavizado ni alfa a medias)."""
    validos = {tuple(c[:3]) for c in PALETA.values()}
    for info in PIEZAS.values():
        im = Image.open(os.path.join(DESTINO, info["archivo"])).convert("RGBA")
        for _, (r, g, b, a) in im.getcolors(1 << 20):
            if a == 0:
                continue
            assert a == 255, f"{info['archivo']}: alfa a medias {a}"
            assert (r, g, b) in validos, f"{info['archivo']}: color fuera de la paleta {hexs((r, g, b))}"


# -------------------------------------------------------------------------------------------------------------------
# README
# -------------------------------------------------------------------------------------------------------------------
def escribir_readme():
    filas = []
    for n, i in PIEZAS.items():
        w, h = i["tam"]
        if i["hz"] and i["vt"]:
            corte = f"9 partes: izq {i['hz'][0]}, der {i['hz'][1]}, arriba {i['vt'][0]}, abajo {i['vt'][1]}"
        elif i["hz"]:
            corte = f"3 partes a lo ancho (alto fijo): izq {i['hz'][0]}, der {i['hz'][1]}"
        else:
            corte = "no se estira"
        logico = f"{i['ancho']}x{i['alto']}" if i["ancho"] else "—"
        ancla = f"({i['ancla'][0]}, {i['ancla'][1]})" if i["ancla"] != (0, 0) else "—"
        filas.append(f"| `{i['archivo']}` | {w}x{h} | {logico} | {ancla} | {corte} | {i['origen']} | {i['nota']} |")
    paleta = "\n".join(f"| {n} | `{hexs(c)}` |" for n, c in PALETA.items())
    variantes = "\n".join(f"| {p} | {n} | {g} | {s:.2f} |" for p, (n, g, s) in VARIANTES.items())
    texto = f"""# Kit de interfaz v2 («A + C»)

Piezas finales de la interfaz v2, estilo **A + C** (la A, Corte diagonal, con la sombra de color de la C), a la escala
real del juego (base 640×360). Todavía **no están programadas** en el juego: son el material para hacerlo.

- Las genera `siete-vidas/herramientas/interfaz_v2_kit.py` (no editar los PNG a mano: se rehacen con el script).
- Dirección y medidas: `siete-vidas/diseno/interfaz-v2.md` (sección «Dirección de arte: ELEGIDA la A con el toque de la C»).
- Lámina de revisión: `siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/kit-v2.png` (y `-x2`), con todas las
  piezas a ×1 y ×4 y las 4 pantallas rearmadas solo con el kit junto a `direccion-arte-AC-v2.png`.
- Todo va en colores exactos de la paleta de abajo, sin suavizado ni alfa a medias (el script lo comprueba).

## Cómo se usan

- **Ancla:** cada PNG está recortado a lo que ocupa, con la sombra adentro. El «ancla» es dónde cae, dentro del PNG, la
  esquina (x, y) que usa el layout. Ejemplo: `dialogo-marco-valeria.png` con ancla (0, 0) y 68x54 es la caja de 64x50
  más 1 px de contorno y 3 px de sombra.
- **Medida lógica:** el ancho y alto con que el layout dibuja la caja (sin sombra). Las piezas que se estiran se
  guardan con un ancho lógico corto (64, 40 o 104); se estiran al ancho que pida el texto.
- **Cortes de 9 partes:** son los márgenes de `NinePatchRect` (o `StyleBoxTexture`) en px del PNG. Las cajas tienen los
  lados en diagonal de arriba abajo, así que **se estiran solo a lo ancho**: el alto es fijo (por eso hay una pieza
  por alto, normal y grande). Para el alto fijo se usa `patch_margin_top` + `patch_margin_bottom` = alto del PNG.
- **Texto grande (200 %):** las cajas se dibujan a su medida grande con líneas de 1 px (no se escalan); las huellas y
  el ícono del logro se duplican (`-grande`).
- **Velo de la pausa:** no es PNG; es un `ColorRect` del color `fondo` al 78 % (alfa 200).
- **Fragmentos:** los fondos de retrato y el cartel llevan triangulitos alrededor; van aparte (`fragmentos-*.png`) para
  que se puedan mover y animar. Con «Reducir movimiento» quedan quietos.
- **Hueco entre el retrato y el texto:** al menos 6 px libres después del retrato, su fondo, su sombra y sus
  fragmentos. Medido en la lámina del kit: 13 px en normal y 12 px con texto grande (el texto empieza a 24 px del
  borde de la caja, `x` 104 en la base). `interfaz_v2_kit_lamina.py` lo mide y corre el texto si alguna vez baja de 6.

## Piezas

| Archivo | PNG | Medida lógica | Ancla | Corte | Origen | Uso |
| --- | --- | --- | --- | --- | --- | --- |
{chr(10).join(filas)}

## Piezas sacadas de las hojas de IA

Método: recorte de cada pieza en las 5 hojas (ChatGPT 1 y Gemini 1 a 4), silueta y relleno, reducción al tamaño del
juego por 3 métodos («mayoría», «huecos» y «centro»), paleta exacta y limpieza (sin píxeles sueltos, contorno de 1 px).
Cada variante se mide de 0 a 1 (apego a la paleta, limpieza, partes que se leen a ×1, simetría o apego a la forma de la
lámina) y se revisa en `kit-v2-variantes.png`. La ganadora se retocó a mano píxel a píxel (la rejilla final y lo que
se cambió están en `interfaz_v2_kit.py`).

| Pieza | Variantes | Ganadora | Puntaje |
| --- | --- | --- | --- |
{variantes}

**Créditos:** huella y huella del sello, generadas con Gemini y ChatGPT y retocadas; pescadito, generado con ChatGPT y
retocado; orejita y cola del globito, generadas con Gemini y retocadas (hojas en `siete-vidas/arte/referencias/`).
Todo lo demás, dibujado por código.

## Paleta del kit

| Nombre | Color |
| --- | --- |
{paleta}
"""
    with open(os.path.join(DESTINO, "README.md"), "w", encoding="utf-8") as f:
        f.write(texto)


if __name__ == "__main__":
    piezas = construir()
    for n, i in piezas.items():
        print(f"{i['archivo']:36s} {i['tam'][0]:4d}x{i['tam'][1]:<4d} ancla {i['ancla']} hz {i['hz']} vt {i['vt']}")
    print(len(piezas), "piezas en", DESTINO)
