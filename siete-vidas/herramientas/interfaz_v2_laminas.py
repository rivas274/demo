#!/usr/bin/env python3
"""Láminas de dirección de arte de la interfaz v2 (style tiles A, B y C).

Dibuja por código, en pixel art (sin suavizado, contorno de 1 px), una lámina de 640x360 por opción con:
paleta, tipografía, las 9 huellas de salud (llena, media, vacía, golpe, curando), el HUD en contexto
(huellas, contador y barra del jefe), el diálogo con retrato, el globito de Felipe, el cartel de travesura,
la etiqueta de logro, el menú de pausa y la Ficha de Su Majestad, más la regla de forma y la de movimiento.

Las muestras van sobre recortes de capturas reales del juego (capturas/interfaz-rediseno/actual-*.png).
Los retratos salen de las hojas que ya usa el diálogo (no se generan caras nuevas).

Uso:  python3 siete-vidas/herramientas/interfaz_v2_laminas.py
Sale: siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/direccion-arte-{A,B,C}.png  (y -x2.png)
Documento: siete-vidas/diseno/interfaz-v2.md
"""
from __future__ import annotations

import os
from collections import deque

from PIL import Image, ImageDraw, ImageFont

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
JUEGO = os.path.join(RAIZ, "juego")
CAPTURAS = os.path.join(RAIZ, "diseno", "revisiones", "capturas", "interfaz-rediseno")
FUENTES = os.path.join(JUEGO, "fuentes")


def fuente(nombre: str, tam: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(os.path.join(FUENTES, nombre), tam)


F8 = fuente("PixelOperator8.ttf", 8)          # notas de la lámina y etiquetas chicas
F16 = fuente("PixelOperator.ttf", 16)         # texto de diálogo
F16B = fuente("PixelOperator-Bold.ttf", 16)   # nombres y números
SK8 = fuente("Silkscreen-Regular.ttf", 8)     # etiquetas de fase / menú
SK16 = fuente("Silkscreen-Regular.ttf", 16)   # carteles


def hexa(c: str, a: int = 255) -> tuple:
    c = c.lstrip("#")
    return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16), a)


def mezclar(a: tuple, b: tuple, t: float) -> tuple:
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3)) + (255,)


# ---------------------------------------------------------------------------------------------------------------
# Opciones
# ---------------------------------------------------------------------------------------------------------------
OPCIONES = {
    "A": {
        "titulo": "A · CORTE DIAGONAL",
        "frase": "La más cercana al cuadro elegido: cajas oscuras con cortes en diagonal, líneas claras y fragmentos.",
        "k": 3,              # la diagonal avanza 1 px en x por cada k px en y (k=3 -> unos 18°)
        "fondo": "#241A26", "panel": "#30242C", "linea": "#F4E2BB", "texto": "#FFF0D5", "apagado": "#8A7480",
        "contorno": "#120C12", "sombra": "#0B070B",
        "felipe": "#E8B04A", "valeria": "#D8336B", "aspi": "#E04848", "dano": "#FFF0D5", "maquina": "#4CC9E0",
        "borde": "lineas", "smax": 10,   # líneas claras arriba y abajo
        "esquina": "corte",  # dos esquinas cortadas en diagonal
        "sombra_px": 2,
        "huellas": "fila",
        "corta": "Lo más cercano al cuadro elegido: cortes, líneas y fragmentos.",
        "angulo": "1:3 (18°)",
        "forma": ["Caja oscura + línea clara de 1 px arriba", "y abajo. Contorno 1 px, sombra dura 2 px.",
                  "Esquinas: dos cortadas en diagonal.", "Fragmentos: triángulos de 2-5 px."],
        "mov": ["Entra: barrido 140 ms + rebote 4 px 80 ms.", "Sale: barrido al revés 120 ms.",
                "Golpe: destello 60 ms, grieta, rebote 2 px.", "Cura: se llena hacia arriba 200 ms + brillo.",
                "Cartel: barre 160 ms, squash 110/90 %."],
    },
    "B": {
        "titulo": "B · ORO DE LA CORTE",
        "frase": "Más real y dorada: azul tinta, filete de oro doble, diagonales suaves y esquinas biseladas con gemas.",
        "k": 6,              # unos 9,5°
        "fondo": "#1C1B2C", "panel": "#28263A", "linea": "#D8AC67", "texto": "#F4E2BB", "apagado": "#7C7488",
        "contorno": "#0E0D16", "sombra": "#08070E",
        "felipe": "#F0C04E", "valeria": "#B8325E", "aspi": "#4CC9E0", "dano": "#F4E2BB", "maquina": "#E04848",
        "borde": "filete", "smax": 6,   # filete de oro + línea interior crema
        "esquina": "bisel",  # 4 esquinas biseladas a 45° de 3 px
        "sombra_px": 2,
        "huellas": "dos_filas",
        "corta": "Más real y dorada: filete de oro, bisel y diagonal suave.",
        "angulo": "1:6 (9,5°)",
        "forma": ["Filete de oro 1 px + línea crema a 2 px.", "Esquinas: bisel de 45° de 3 px (las 4).",
                  "Sombra dura 2 px. Sello octogonal.", "Fragmentos: chispas de oro en cruz."],
        "mov": ["Entra: desliza 180 ms + brillo 220 ms.", "Sale: desliza 160 ms, sin rebote.",
                "Golpe: pierde el oro 100 ms, baja 2 px.", "Cura: oro de abajo arriba 240 ms + chispa.",
                "Cartel: barre 200 ms y se asienta 120 ms."],
    },
    "C": {
        "titulo": "C · CÓMIC TRAVIESO",
        "frase": "Más cómic y juguetona: contorno grueso, diagonales fuertes, sombra de color, puntos y estallidos.",
        "k": 2,              # unos 26,5°
        "fondo": "#1A1014", "panel": "#2B1A2E", "linea": "#FFE7B0", "texto": "#FFF6E0", "apagado": "#8C6F86",
        "contorno": "#0A0608", "sombra": "#0A0608",
        "felipe": "#FFC53D", "valeria": "#FF4F9A", "aspi": "#FF5A3C", "dano": "#FFF6E0", "maquina": "#3FD8E8",
        "borde": "grueso", "smax": 14,   # borde claro de 2 px + contorno negro
        "esquina": "recta",  # paralelogramo puro, sin cortes
        "sombra_px": 3,
        "huellas": "rebote",
        "corta": "Más cómic: contorno grueso, sombra de color, puntos y estallidos.",
        "angulo": "1:2 (26,5°)",
        "forma": ["Borde claro 2 px + contorno negro 1 px.", "Sombra dura 3 px DEL COLOR del personaje.",
                  "Paralelogramo puro; trama de puntos.", "Fragmentos: estrellas de 3-7 px."],
        "mov": ["Entra: salta y estira 120>90>100 % 180 ms.", "Texto grande: tiembla 1 px 3 cuadros.",
                "Golpe: la huella salta 3 px y cae vacía.", "Cura: pop 130 % 100 ms.",
                "Cartel: entra girado 6°, golpe + temblor."],
    },
}

# ---------------------------------------------------------------------------------------------------------------
# Recortes reales y retratos
# ---------------------------------------------------------------------------------------------------------------


def captura(nombre: str) -> Image.Image:
    im = Image.open(os.path.join(CAPTURAS, nombre)).convert("RGBA")
    if im.width == 1280:
        im = im.resize((640, 360), Image.NEAREST)
    return im


def quitar_fondo(im: Image.Image, tolerancia: int = 26) -> Image.Image:
    """Borra el fondo liso de una hoja de retratos inundando desde los bordes."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    base = px[0, 0][:3]
    vistos = set()
    cola = deque()
    for x in range(w):
        cola.append((x, 0)); cola.append((x, h - 1))
    for y in range(h):
        cola.append((0, y)); cola.append((w - 1, y))
    while cola:
        x, y = cola.popleft()
        if (x, y) in vistos or not (0 <= x < w and 0 <= y < h):
            continue
        vistos.add((x, y))
        r, g, b, a = px[x, y]
        if a == 0 or sum(abs(c - d) for c, d in zip((r, g, b), base)) <= tolerancia:
            px[x, y] = (0, 0, 0, 0)
            cola.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return im


def recortar_opaco(im: Image.Image) -> Image.Image:
    caja = im.getbbox()
    return im.crop(caja) if caja else im


def retratos() -> dict:
    hoja_f = Image.open(os.path.join(JUEGO, "assets", "felipe", "felipe-retratos.png")).convert("RGBA")
    hoja_o = Image.open(os.path.join(JUEGO, "assets", "personajes", "retratos-valeria-aspi.png")).convert("RGBA")
    lado_f = hoja_f.width / 3
    lado_o = hoja_o.width // 3

    def cara_f(i):
        x, y = int((i % 3) * lado_f), int((i // 3) * lado_f)
        return recortar_opaco(quitar_fondo(hoja_f.crop((x, y, int(x + lado_f), int(y + lado_f)))))

    def cara_o(i):
        x, y = (i % 3) * lado_o, (i // 3) * lado_o
        return recortar_opaco(quitar_fondo(hoja_o.crop((x + 1, y + 1, x + lado_o - 1, y + lado_o - 1)), 40))

    return {"felipe": cara_f(0), "felipe_presumido": cara_f(7), "felipe_feliz": cara_f(6),
            "valeria": cara_o(0), "aspi": cara_o(4), "aspi_alerta": cara_o(5)}


def achicar(im: Image.Image, alto: int) -> Image.Image:
    """Achica un retrato a `alto` px sin suavizar el borde: caja + alfa de corte duro."""
    ancho = max(1, round(im.width * alto / im.height))
    chico = im.resize((ancho, alto), Image.BOX)
    px = chico.load()
    for y in range(chico.height):
        for x in range(chico.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return chico


def con_contorno(im: Image.Image, color: tuple) -> Image.Image:
    w, h = im.size
    out = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    a = im.split()[3]
    sil = Image.new("RGBA", im.size, color)
    for dx, dy in ((0, 1), (2, 1), (1, 0), (1, 2)):
        out.paste(sil, (dx, dy), a)
    out.alpha_composite(im, (1, 1))
    return out


# ---------------------------------------------------------------------------------------------------------------
# Primitivas pixel art
# ---------------------------------------------------------------------------------------------------------------


def poligono(img: Image.Image, pts, color) -> None:
    ImageDraw.Draw(img).polygon([(int(x), int(y)) for x, y in pts], fill=color)


def texto(img, xy, t, f=F8, color="#FFF0D5", contorno=None, sombra=None):
    d = ImageDraw.Draw(img)
    d.fontmode = "1"
    c = hexa(color) if isinstance(color, str) else color
    x, y = xy
    if contorno:
        co = hexa(contorno) if isinstance(contorno, str) else contorno
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, -1), (-1, 1), (1, 1)):
            d.text((x + dx, y + dy), t, font=f, fill=co)
    if sombra:
        so = hexa(sombra) if isinstance(sombra, str) else sombra
        d.text((x + 1, y + 1), t, font=f, fill=so)
    d.text((x, y), t, font=f, fill=c)


def ancho(t, f=F8) -> int:
    return int(f.getlength(t))


def paralelo(x, y, w, h, k, invertir=False, s=None):
    """Paralelogramo inclinado hacia la derecha (la parte de arriba corre a la derecha)."""
    s = h // k if s is None else s
    if invertir:
        return [(x, y), (x + w - s, y), (x + w, y + h), (x + s, y + h)]
    return [(x + s, y), (x + w, y), (x + w - s, y + h), (x, y + h)]


def encoger(pts, n=1):
    cx = sum(p[0] for p in pts) / len(pts)
    cy = sum(p[1] for p in pts) / len(pts)
    out = []
    for x, y in pts:
        out.append((x + (n if x < cx else -n), y + (n if y < cy else -n)))
    return out


def inclinacion(o, h, k=None) -> int:
    """Cuánto corre la diagonal en una caja de alto h: 1 px cada k px, con un tope para paneles altos."""
    return min(h // (k or o["k"]), o["smax"])


def contorno_caja(o, x, y, w, h, s):
    """Puntos de la caja según la regla de esquinas de la opción (s = corrimiento de la diagonal)."""
    if o["esquina"] == "corte":
        c = 4
        return [(x + s, y), (x + w - c, y), (x + w, y + c), (x + w - s, y + h), (x + c, y + h), (x, y + h - c)]
    if o["esquina"] == "bisel":
        c = 3
        return [(x + s + c, y), (x + w - c, y), (x + w, y + c), (x + w - s, y + h - c), (x + w - s - c, y + h),
                (x + c, y + h), (x, y + h - c), (x + s, y + c)]
    return [(x + s, y), (x + w, y), (x + w - s, y + h), (x, y + h)]


def gema(img, o, cx, cy, color):
    poligono(img, [(cx, cy - 3), (cx + 3, cy), (cx, cy + 3), (cx - 3, cy)], hexa(o["contorno"]))
    poligono(img, [(cx, cy - 2), (cx + 2, cy), (cx, cy + 2), (cx - 2, cy)], hexa(color))
    img.putpixel((cx, cy - 1), mezclar(hexa(color), (255, 255, 255), 0.6))


def caja(img, o, x, y, w, h, color_fondo=None, acento=None, k=None):
    """La caja del lenguaje de cada opción: fondo oscuro, borde claro y esquinas según la regla."""
    s = inclinacion(o, h, k)
    fondo = hexa(color_fondo or o["panel"])
    linea = hexa(o["linea"])
    cont = hexa(o["contorno"])
    sp = o["sombra_px"]
    pts = contorno_caja(o, x, y, w, h, s)
    sombra_c = hexa(acento) if (o["borde"] == "grueso" and acento) else hexa(o["sombra"])
    poligono(img, [(px + sp, py + sp) for px, py in pts], sombra_c)
    poligono(img, pts, cont)
    d = ImageDraw.Draw(img)
    if o["borde"] == "grueso":
        poligono(img, contorno_caja(o, x + 1, y + 1, w - 2, h - 2, s), linea)
        poligono(img, contorno_caja(o, x + 3, y + 3, w - 6, h - 6, max(0, s - 1)), fondo)
    elif o["borde"] == "filete":
        poligono(img, contorno_caja(o, x + 1, y + 1, w - 2, h - 2, s), linea)
        poligono(img, contorno_caja(o, x + 2, y + 2, w - 4, h - 4, s), cont)
        poligono(img, contorno_caja(o, x + 3, y + 3, w - 6, h - 6, s), fondo)
        if h >= 14:
            ym = y + h // 2
            gema(img, o, x + s // 2 + 1, ym, o["felipe"] if not acento else acento)
            gema(img, o, x + w - s // 2 - 2, ym, o["felipe"] if not acento else acento)
    else:
        poligono(img, contorno_caja(o, x + 1, y + 1, w - 2, h - 2, s), fondo)
        d.line([(x + s + 2, y + 2), (x + w - 6, y + 2)], fill=linea)
        d.line([(x + 6, y + h - 3), (x + w - s - 3, y + h - 3)], fill=linea)
    return pts


def franja(img, o, x, y, t, f, color, color_texto=None, alto=13, dy_texto=-4):
    """Franja del nombre o del título: en A, bloque del color; en B, oscura con filete de oro y texto del color;
    en C, cinta con cola de golondrina y sombra de color."""
    w = ancho(t, f) + 16
    k = o["k"]
    cont = hexa(o["contorno"])
    s = alto // k
    if o["borde"] == "filete":
        alto += 4
        y -= 2
        pts = contorno_caja(o, x, y, w, alto, s)
        poligono(img, [(px + 1, py + 1) for px, py in pts], hexa(o["sombra"]))
        poligono(img, pts, cont)
        poligono(img, contorno_caja(o, x + 1, y + 1, w - 2, alto - 2, s), hexa(o["linea"]))
        poligono(img, contorno_caja(o, x + 2, y + 2, w - 4, alto - 4, s), hexa(o["fondo"]))
        claro = mezclar(hexa(color_texto or color), (255, 255, 255), 0.35)
        texto(img, (x + 8, y + dy_texto + 3), t, f, claro)
        return w
    if o["borde"] == "grueso":
        cola = [(x + w - 2, y), (x + w + 8, y), (x + w + 3, y + alto // 2), (x + w + 8, y + alto), (x + w - 2 - s, y + alto)]
        poligono(img, [(px + 2, py + 2) for px, py in cola], hexa(o["valeria"] if color == o["felipe"] else o["felipe"]))
        poligono(img, cola, cont)
        poligono(img, [(x + w - 1, y + 1), (x + w + 5, y + 1), (x + w + 1, y + alto // 2), (x + w + 5, y + alto - 1),
                       (x + w - 1 - s, y + alto - 1)], mezclar(hexa(color), cont, 0.35))
    pts = paralelo(x, y, w, alto, k)
    if o["borde"] == "grueso":
        poligono(img, [(px + 2, py + 2) for px, py in pts], cont)
    poligono(img, [(px - 1, py) for px, py in pts[:1]] + pts[1:2] + [(pts[2][0] + 1, pts[2][1] + 1), (pts[3][0] - 1, pts[3][1] + 1)], cont)
    poligono(img, encoger(pts, 1), hexa(color))
    if o["borde"] == "grueso":
        trama(img, (x, y, x + w, y + alto), mezclar(hexa(color), (255, 255, 255), 0.35), paso=2)
        poligono(img, encoger(paralelo(x + 6, y + 2, w - 12, alto - 4, k), 0), hexa(color))
    texto(img, (x + 8, y + dy_texto + 1), t, f, color_texto or o["contorno"])
    return w


def trama(img, rect, color, paso=3):
    """Trama de puntos (opción C)."""
    x0, y0, x1, y1 = rect
    px = img.load()
    for y in range(y0, y1, paso):
        for x in range(x0 + (y // paso) % 2, x1, paso * 2):
            if 0 <= x < img.width and 0 <= y < img.height and px[x, y][3] > 0:
                px[x, y] = color


def fragmentos(img, o, cx, cy, color, n=6, semilla=1, radio=20):
    import random
    rnd = random.Random(semilla)
    for i in range(n):
        ang = rnd.uniform(0, 6.283)
        import math
        r = rnd.uniform(radio * 0.6, radio)
        x = cx + math.cos(ang) * r
        y = cy + math.sin(ang) * r * 0.7
        t = rnd.randint(2, 5 if o["huellas"] != "rebote" else 4)
        if o["huellas"] == "dos_filas":   # chispas de oro: cruz de 3-5 px
            c = hexa(o["linea"])
            d = ImageDraw.Draw(img)
            d.line([(x - t // 2 - 1, y), (x + t // 2 + 1, y)], fill=c)
            d.line([(x, y - t // 2 - 1), (x, y + t // 2 + 1)], fill=c)
        elif o["huellas"] == "rebote":    # estallido: estrella de 4 puntas
            c = hexa(color)
            d = ImageDraw.Draw(img)
            d.line([(x - t, y), (x + t, y)], fill=hexa(o["contorno"]), width=3)
            d.line([(x, y - t), (x, y + t)], fill=hexa(o["contorno"]), width=3)
            d.line([(x - t + 1, y), (x + t - 1, y)], fill=c)
            d.line([(x, y - t + 1), (x, y + t - 1)], fill=c)
        else:
            poligono(img, [(x, y), (x + t, y + t // 2), (x + 1, y + t)], hexa(color))


# ---------------------------------------------------------------------------------------------------------------
# La huella de salud (aprobada): almohadilla grande y 4 deditos
# ---------------------------------------------------------------------------------------------------------------
HUELLA = [
    "...XX.XX...",
    "..XXX.XXX..",
    "..XXX.XXX..",
    "XX.......XX",
    "XXX.XXX.XXX",
    "XX.XXXXX.XX",
    "..XXXXXXX..",
    ".XXXXXXXXX.",
    ".XXXXXXXXX.",
    "..XXX.XXX..",
]


def huella(o, estado: str, escala: int = 1) -> Image.Image:
    """estado: llena, media, vacia, golpe, curando."""
    w, h = len(HUELLA[0]), len(HUELLA)
    im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    px = im.load()
    base = hexa(o["felipe"])
    luz = mezclar(base, (255, 255, 255), 0.5)
    osc = mezclar(base, hexa(o["contorno"]), 0.35)
    vacio = mezclar(hexa(o["panel"]), hexa(o["apagado"]), 0.35)
    vacio_luz = mezclar(hexa(o["panel"]), hexa(o["apagado"]), 0.7)
    cont = hexa(o["contorno"])
    for y, fila in enumerate(HUELLA):
        for x, ch in enumerate(fila):
            if ch != "X":
                continue
            lleno = estado in ("llena", "curando", "golpe") or (estado == "media" and x <= 4)
            if estado == "golpe":
                c = hexa(o["dano"])
            elif lleno:
                arriba = y == 0 or HUELLA[y - 1][x] != "X"
                abajo = y == h - 1 or HUELLA[y + 1][x] != "X"
                c = luz if arriba else (osc if abajo else base)
                if estado == "curando":
                    c = mezclar(c, (255, 255, 255), 0.35)
            else:
                arriba = y == 0 or HUELLA[y - 1][x] != "X"
                c = vacio_luz if arriba else vacio
            px[x + 1, y + 1] = c
    # contorno de 1 px alrededor de la silueta
    for y in range(h + 2):
        for x in range(w + 2):
            if px[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w + 2 and 0 <= yy < h + 2 and px[xx, yy][3] and px[xx, yy] != cont:
                    px[x, y] = cont
                    break
    if estado == "vacia" or estado == "media":
        # grieta de 1 px en la almohadilla vacía
        pass
    if escala > 1:
        im = im.resize((im.width * escala, im.height * escala), Image.NEAREST)
    return im


def fila_huellas(img, o, x, y, llenas: int, media: bool, cara: Image.Image):
    """HUD de salud: cara chica de Felipe + 9 huellas, en el arreglo de cada opción."""
    estilo = o["huellas"]
    hw = len(HUELLA[0]) + 2
    hh = len(HUELLA) + 2
    if estilo == "dos_filas":
        # B: cara en un rombo biselado y 9 huellas en 2 filas (5 + 4)
        cw = cara.width + 8
        caja(img, o, x, y, cw + 5 * (hw + 1) + 12, 2 * hh + 8, k=o["k"])
        img.alpha_composite(cara, (x + 6, y + (2 * hh + 8 - cara.height) // 2))
        n = 0
        for fila in range(2):
            for i in range(5 if fila == 0 else 4):
                est = "llena" if n < llenas else ("media" if (n == llenas and media) else "vacia")
                img.alpha_composite(huella(o, est), (x + cw + 4 + i * (hw + 1) + fila * (hw // 2), y + 4 + fila * (hh + 1)))
                n += 1
        return
    paso = hw + (1 if estilo == "fila" else 2)
    w = cara.width + 10 + 9 * paso + 8
    hcaja = hh + 8 if estilo == "fila" else hh + 10
    acento = o["felipe"]
    caja(img, o, x, y, w, hcaja, acento=acento)
    img.alpha_composite(cara, (x + 4, y + hcaja - cara.height - 1))
    for i in range(9):
        est = "llena" if i < llenas else ("media" if (i == llenas and media) else "vacia")
        dy = 0
        if estilo == "rebote":
            dy = -1 if i % 2 == 0 else 1
        img.alpha_composite(huella(o, est), (x + cara.width + 8 + i * paso, y + (hcaja - hh) // 2 + dy))


# ---------------------------------------------------------------------------------------------------------------
# Íconos chicos
# ---------------------------------------------------------------------------------------------------------------
SNACK = [
    "....XXXX..X.",
    "..XXXXXXXXX.",
    ".XXOXXXXXXX.",
    "XXXXXXXXX.XX",
    ".XXXXXXXXXX.",
    "..XXXXXXX..X",
    "....XXXX....",
]


def icono(patron, color, cont, ojo=None) -> Image.Image:
    w, h = len(patron[0]), len(patron)
    im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
    px = im.load()
    for y, f in enumerate(patron):
        for x, ch in enumerate(f):
            if ch == "X":
                px[x + 1, y + 1] = color
            elif ch == "O":
                px[x + 1, y + 1] = ojo or cont
    for y in range(h + 2):
        for x in range(w + 2):
            if px[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w + 2 and 0 <= yy < h + 2 and px[xx, yy][3] and px[xx, yy] != cont:
                    px[x, y] = cont
                    break
    return im


def flecha(img, o, x, y, color):
    poligono(img, [(x, y), (x + 5, y + 4), (x, y + 8)], hexa(o["contorno"]))
    poligono(img, [(x, y + 1), (x + 4, y + 4), (x, y + 7)], hexa(color))


# ---------------------------------------------------------------------------------------------------------------
# Componentes
# ---------------------------------------------------------------------------------------------------------------


def fondo_retrato(img, o, x, y, w, h, color, semilla=1):
    """Fondo inclinado del retrato, del color del personaje: A liso con fragmentos; B con filete de oro y rayas;
    C con trama de puntos, estrellas y sombra de color."""
    k = o["k"]
    s = inclinacion(o, h)
    pts = paralelo(x, y, w, h, k, s=s)
    sp = o["sombra_px"]
    sombra = hexa(o["felipe"] if (o["borde"] == "grueso" and color != o["felipe"]) else
                  (o["valeria"] if o["borde"] == "grueso" else o["sombra"]))
    poligono(img, [(px + sp, py + sp) for px, py in pts], sombra)
    poligono(img, pts, hexa(o["contorno"]))
    if o["borde"] == "filete":
        poligono(img, paralelo(x + 1, y + 1, w - 2, h - 2, k, s=s), hexa(o["linea"]))
        poligono(img, paralelo(x + 2, y + 2, w - 4, h - 4, k, s=s), hexa(o["contorno"]))
        poligono(img, paralelo(x + 3, y + 3, w - 6, h - 6, k, s=s), hexa(color))
        oscuro = mezclar(hexa(color), hexa(o["contorno"]), 0.25)
        rayas = Image.new("RGBA", img.size, (0, 0, 0, 0))
        dr = ImageDraw.Draw(rayas)
        for i in range(-h, w + h, 6):   # rayas diagonales finas (terciopelo), recortadas a la forma
            dr.line([(x + i, y + h), (x + i + h // 2, y)], fill=oscuro)
        mascara = Image.new("L", img.size, 0)
        ImageDraw.Draw(mascara).polygon([(int(a), int(b)) for a, b in paralelo(x + 3, y + 3, w - 6, h - 6, k, s=s)], fill=255)
        img.paste(rayas, (0, 0), Image.composite(rayas.split()[3], Image.new("L", img.size, 0), mascara))
        return
    poligono(img, encoger(pts, 1), hexa(color))
    if o["borde"] == "grueso":
        trama(img, (x, y, x + w, y + h), mezclar(hexa(color), (255, 255, 255), 0.35), paso=3)
    fragmentos(img, o, x + 4, y + 2, color, n=5, semilla=semilla, radio=10)


def barra_jefe(img, o, x, y, w, cara, valor=0.55, reciente=0.68):
    """Retrato chico + nombre en franja + barra de 2 capas con 3 segmentos (I, II, III)."""
    col = o["aspi"]
    fondo_retrato(img, o, x, y - 2, 30, 26, col, semilla=9)
    img.alpha_composite(cara, (x + 4, y + 23 - cara.height))
    franja(img, o, x + 26, y - 3, "A.S.P.I.", F16B, col, o["contorno"] if o["borde"] != "filete" else col, alto=14)
    # barra
    bx, by, bw, bh = x + 30, y + 12, w - 32, 10
    caja(img, o, bx, by, bw, bh + 4, color_fondo=o["fondo"], acento=col, k=max(o["k"], 3))
    ix, iw = bx + 5, bw - 12
    d = ImageDraw.Draw(img)
    for capa, frac, color in (("rec", reciente, hexa(o["dano"])), ("real", valor, hexa(col))):
        fw = int(iw * frac)
        d.rectangle([ix, by + 4, ix + fw, by + bh - 1], fill=color)
        if capa == "real":
            d.line([(ix, by + 4), (ix + fw, by + 4)], fill=mezclar(hexa(col), (255, 255, 255), 0.45))
    # 3 segmentos: cortes en diagonal y marcas I II III
    for i, marca in enumerate(("I", "II", "III")):
        sx = ix + int(iw * (i + 1) / 3)
        if i < 2:
            d.line([(sx, by + 3), (sx - 2, by + bh)], fill=hexa(o["contorno"]), width=2)
        mx = ix + int(iw * (i + 0.5) / 3) - ancho(marca, SK8) // 2
        activa = i == 1
        texto(img, (mx, by + bh + 3), marca, SK8, o["aspi"] if activa else o["texto"], contorno=o["contorno"])


def contador(img, o, x, y, n, de):
    ic = icono(SNACK, hexa(o["felipe"]), hexa(o["contorno"]))
    t = f"{n}/{de}"
    w = ic.width + ancho(t, F16B) + ancho("SNACKS", SK8) + 22
    caja(img, o, x, y, w, 18, acento=o["felipe"])
    img.alpha_composite(ic, (x + 7, y + 5))
    texto(img, (x + 9 + ic.width, y + 1), t, F16B, o["texto"])
    texto(img, (x + 12 + ic.width + ancho(t, F16B), y + 6), "SNACKS", SK8, o["texto"])


def dialogo(img, o, x, y, w, quien, cara, lineas, color):
    """Cuadro elegido: retrato grande que sale del marco sobre fondo inclinado con fragmentos, nombre en franja,
    caja oscura con cortes en diagonal y líneas claras, flecha."""
    h = 40
    fondo_retrato(img, o, x, y - 8, 58, h + 10, color, semilla=len(quien))
    cx = x + 50
    caja(img, o, cx, y + 4, w - 50, h - 4, acento=color)
    c2 = con_contorno(cara, hexa(o["contorno"]))
    img.alpha_composite(c2, (x + 4, y + h + 2 - c2.height))
    franja(img, o, cx + 12, y - 6, quien.upper(), F16B, color,
           (o["texto"] if quien == "valeria" else o["contorno"]) if o["borde"] != "filete" else color, alto=13)
    sangria = inclinacion(o, h - 4) + 6
    for i, l in enumerate(lineas):
        texto(img, (cx + sangria - (i * 13) // o["k"] if o["esquina"] == "recta" else cx + sangria, y + 7 + i * 13), l, F16, o["texto"])
    flecha(img, o, x + w - 18 - (6 if o["esquina"] == "recta" else 0), y + h - 12, o["linea"] if o["borde"] != "grueso" else color)


def globito(img, o, x, y, t, cola_x):
    """Globito gatuno con orejitas, cola corta y una huellita: A caja cortada; B octágono dorado; C estallido."""
    w = ancho(t, F16) + 16
    h = 18
    cont = hexa(o["contorno"])
    linea = hexa(o["linea"])
    acento = hexa(o["felipe"])
    poligono(img, [(cola_x - 4, y + h - 2), (cola_x + 5, y + h - 2), (cola_x - 2, y + h + 8)], cont)
    poligono(img, [(cola_x - 2, y + h - 2), (cola_x + 3, y + h - 2), (cola_x - 1, y + h + 5)],
             linea if o["borde"] != "grueso" else acento)
    if o["borde"] == "grueso":
        # estallido: picos alrededor de la caja
        picos = []
        for i in range(0, w + 1, 8):
            picos += [(x + i, y - 1), (x + i + 4, y - 4)]
        picos += [(x + w + 4, y + h // 2)]
        for i in range(w, -1, -8):
            picos += [(x + i, y + h + 1), (x + i - 4, y + h + 4)]
        picos += [(x - 5, y + h // 2)]
        poligono(img, [(a + 3, b + 3) for a, b in picos], hexa(o["valeria"]))
        poligono(img, picos, cont)
        poligono(img, encoger(picos, 2), linea)
        poligono(img, encoger(picos, 4), hexa(o["panel"]))
        texto(img, (x + 8, y + 1), t, F16, o["texto"])
    else:
        caja(img, o, x, y, w, h, acento=o["felipe"])
        texto(img, (x + 8 + inclinacion(o, h) // 2, y + 1), t, F16, o["texto"])
    for ox in (x + 7, x + w - 17):
        poligono(img, [(ox - 1, y + 2), (ox + 4, y - 6), (ox + 10, y + 2)], cont)
        poligono(img, [(ox + 1, y + 1), (ox + 4, y - 4), (ox + 8, y + 1)], acento)
        img.putpixel((ox + 4, y - 2), mezclar(acento, (255, 200, 200), 0.6))
    hu = huella(o, "llena")
    img.alpha_composite(hu, (cola_x - 7, y + h + 6))


def cartel(img, o, x, y, titulo, nombre):
    """Cartel de travesura: franja diagonal grande dorada que entra barriendo, con huella-sello dinámica."""
    k = max(2, o["k"] - 1)
    col = o["felipe"]
    h = 22
    s = inclinacion(o, h, k)
    w = ancho(titulo, SK16) + 48 + s
    pts = paralelo(x, y, w, h, k, s=s)
    sp = o["sombra_px"] + 1
    poligono(img, [(px + sp, py + sp) for px, py in pts], hexa(o["sombra"] if o["borde"] != "grueso" else o["valeria"]))
    poligono(img, pts, hexa(o["contorno"]))
    if o["borde"] == "filete":
        poligono(img, paralelo(x + 1, y + 1, w - 2, h - 2, k, s=s), hexa(o["texto"]))
        poligono(img, paralelo(x + 2, y + 2, w - 4, h - 4, k, s=s), mezclar(hexa(col), hexa(o["contorno"]), 0.4))
        poligono(img, paralelo(x + 3, y + 3, w - 6, h - 6, k, s=s), hexa(col))
        gema(img, o, x + w - s // 2 - 4, y + h // 2, o["valeria"])
    else:
        poligono(img, encoger(pts, 1), hexa(col))
        ImageDraw.Draw(img).line([(x + s + 3, y + 2), (x + w - 4, y + 2)], fill=mezclar(hexa(col), (255, 255, 255), 0.6))
        ImageDraw.Draw(img).line([(x + 3, y + h - 2), (x + w - s - 3, y + h - 2)], fill=mezclar(hexa(col), hexa(o["contorno"]), 0.35))
    if o["borde"] == "grueso":
        trama(img, (x, y, x + 46, y + h), mezclar(hexa(col), (255, 255, 255), 0.45), paso=2)
    # sello de huella dinámico (rombo en A, octágono en B, estrella en C)
    sx, sy = x + 4, y - 4
    sello = [(sx + 14, sy), (sx + 28, sy + 15), (sx + 14, sy + 30), (sx, sy + 15)]
    if o["borde"] == "filete":
        sello = [(sx + 9, sy), (sx + 20, sy), (sx + 28, sy + 9), (sx + 28, sy + 21), (sx + 20, sy + 30),
                 (sx + 9, sy + 30), (sx, sy + 21), (sx, sy + 9)]
    elif o["borde"] == "grueso":
        import math
        sello = []
        for i in range(16):
            r = 17 if i % 2 == 0 else 11
            a = i * math.pi / 8
            sello.append((sx + 14 + math.cos(a) * r, sy + 15 + math.sin(a) * r))
    if o["borde"] == "grueso":
        poligono(img, [(a + 2, b + 2) for a, b in sello], hexa(o["valeria"]))
    poligono(img, sello, hexa(o["contorno"]))
    poligono(img, encoger(sello, 1), hexa(o["linea"]))
    poligono(img, encoger(sello, 2), hexa(o["fondo"]))
    img.alpha_composite(huella(o, "llena"), (sx + 8, sy + 9))
    texto(img, (x + 38, y + 1), titulo, SK16, o["contorno"])
    fragmentos(img, o, x + w - 6, y + 4, col, n=5, semilla=7, radio=12)
    nw = ancho(nombre, F16) + 22
    ny = y + h + 2
    caja(img, o, x + 26, ny, nw, 17, acento=col)
    texto(img, (x + 36 + (inclinacion(o, 17) // 2 if o["esquina"] == "recta" else 0), ny + 1), nombre, F16, o["texto"])


def logro(img, o, x, y, t):
    """Logro: etiqueta diagonal que entra deslizando desde la derecha, con el ícono, y se va."""
    w = ancho(t, F16) + 40
    caja(img, o, x, y, w, 20, acento=o["felipe"])
    # ícono: huella en rombo del color de Felipe
    ic = [(x + 4, y + 10), (x + 15, y - 1), (x + 26, y + 10), (x + 15, y + 21)]
    poligono(img, ic, hexa(o["contorno"]))
    poligono(img, encoger(ic, 1), hexa(o["felipe"]))
    hu = huella(o, "vacia")
    img.alpha_composite(hu, (x + 9, y + 4))
    texto(img, (x + 31, y + 2), t, F16, o["texto"])
    texto(img, (x + w - 30, y - 8), "LOGRO", SK8, o["felipe"], contorno=o["contorno"])


def menu_pausa(img, o, x, y):
    caja(img, o, x, y, 68, 84, color_fondo=o["fondo"], acento=o["felipe"])
    franja(img, o, x + 5, y - 6, "PAUSA", SK8, o["felipe"], o["contorno"] if o["borde"] != "filete" else o["felipe"],
           alto=12, dy_texto=-2)
    k = o["k"]
    for i, op in enumerate(("CONTINUAR", "OPCIONES", "REINICIAR", "SALIR")):
        by = y + 14 + i * 16
        dx = 0
        if i == 0:
            pts = paralelo(x + 3, by - 1, 63, 13, k)
            poligono(img, pts, hexa(o["contorno"]))
            poligono(img, encoger(pts, 1), hexa(o["felipe"]))
            texto(img, (x + 10, by + 2), op, SK8, o["contorno"])
        else:
            texto(img, (x + 12 - dx, by + 2), op, SK8, o["texto"])


def ficha(img, o, x, y, cara):
    w = 82
    caja(img, o, x, y, w, 84, color_fondo=o["fondo"], acento=o["felipe"])
    k = o["k"]
    franja(img, o, x + 4, y - 6, "SU MAJESTAD", SK8, o["felipe"], o["contorno"] if o["borde"] != "filete" else o["felipe"],
           alto=12, dy_texto=-2)
    fondo_retrato(img, o, x + 6, y + 10, 32, 30, o["felipe"], semilla=3)
    img.alpha_composite(cara, (x + 8, y + 41 - cara.height))
    texto(img, (x + 41, y + 14), "8,2", F16B, o["texto"])
    texto(img, (x + 64, y + 22), "kg", F8, o["apagado"])
    for i, (n, v, c) in enumerate((("ATAQUE", 0.7, o["aspi"]), ("DEFENSA", 0.5, o["maquina"]), ("CARISMA", 0.95, o["felipe"]))):
        by = y + 46 + i * 11
        texto(img, (x + 5, by), n, SK8, o["apagado"])
        bx = x + 47
        poligono(img, paralelo(bx, by + 1, 30, 7, 2), hexa(o["contorno"]))
        poligono(img, paralelo(bx + 1, by + 2, int(28 * v), 5, 2), hexa(c))


# ---------------------------------------------------------------------------------------------------------------
# Lámina
# ---------------------------------------------------------------------------------------------------------------


def lamina(letra: str, caras: dict) -> Image.Image:
    o = OPCIONES[letra]
    img = Image.new("RGBA", (640, 360), hexa(o["fondo"]))
    d = ImageDraw.Draw(img)
    # Encabezado
    d.rectangle([0, 0, 639, 13], fill=hexa(o["contorno"]))
    poligono(img, paralelo(2, 1, ancho(o["titulo"], SK8) + 16, 11, 2), hexa(o["felipe"]))
    texto(img, (8, 2), o["titulo"], SK8, o["contorno"])
    texto(img, (ancho(o["titulo"], SK8) + 26, 3), o["corta"], F8, o["texto"])

    cara_hud = con_contorno(achicar(caras["felipe"], 16), hexa(o["contorno"]))
    cara_aspi = con_contorno(achicar(caras["aspi_alerta"] if letra == "C" else caras["aspi"], 12), hexa(o["contorno"]))

    # 1. HUD en contexto (zona A, y 0-26 del juego), sobre la pared real del estudio
    pared = captura("actual-pelea-globito.png").crop((0, 28, 640, 72))
    img.alpha_composite(pared, (0, 15))
    fila_huellas(img, o, 4, 18, 6, True, cara_hud)
    contador(img, o, 262, 22, 5, 5)
    barra_jefe(img, o, 380, 20, 252, cara_aspi)

    # 2. Diálogo de Valeria en contexto (zona B, arriba), sobre la sala real
    sala = captura("actual-hud-dialogo.png").crop((150, 84, 470, 196))
    img.alpha_composite(sala, (0, 61))
    dialogo(img, o, 6, 78, 312, "valeria", caras["valeria"], ["¿Qué fue eso?... (a la cámara)", "Perdón, era el gato."], o["valeria"])

    # 3. Globito de Felipe en la pelea, sobre él
    est = captura("actual-pelea-globito.png").crop((392, 218, 552, 330))
    img.alpha_composite(est, (322, 61))
    globito(img, o, 334, 80, "¡JA! ¿Eso es todo?", 400)

    # 4. Menú de pausa y Ficha de Su Majestad (mini), en el mismo lenguaje (sin pergamino ni cojín)
    d.rectangle([482, 61, 639, 172], fill=hexa(o["fondo"]))
    menu_pausa(img, o, 484, 74)
    ficha(img, o, 555, 74, caras["felipe_ficha"])

    # 5. Cartel de travesura y logro, sobre la sala real
    franja = captura("actual-logro.png").crop((0, 84, 640, 136))
    img.alpha_composite(franja, (0, 174))
    cartel(img, o, 10, 182, "¡TRAVESURA!", "Robar el almuerzo de Valeria")
    logro(img, o, 372, 190, "Coleccionista de Calcetines")

    # 6. Fila de abajo: huellas, paleta, letras, forma y movimiento
    y0 = 228
    d.rectangle([0, y0 - 2, 639, y0 - 1], fill=hexa(o["contorno"]))
    texto(img, (4, y0 + 1), "HUELLA (x2)", SK8, o["felipe"])
    for i, est_h in enumerate(("llena", "media", "vacia", "golpe", "curando")):
        hu = huella(o, est_h, 2)
        cx, cy = 4 + (i % 3) * 38, y0 + 12 + (i // 3) * 38
        img.alpha_composite(hu, (cx, cy))
        texto(img, (cx, cy + 26), est_h.upper().replace("VACIA", "VACÍA"), SK8, o["apagado"])
    hu3 = huella(o, "llena", 3)
    img.alpha_composite(hu3, (121 - hu3.width, y0 + 52))
    texto(img, (4, y0 + 90), "13x12 px, contorno", F8, o["texto"])
    texto(img, (4, y0 + 99), "1 px, luz arriba,", F8, o["texto"])
    texto(img, (4, y0 + 108), "sombra abajo.", F8, o["texto"])
    texto(img, (4, y0 + 120), "HUD: 9 = salud", F8, o["felipe"])

    # Paleta
    px0 = 124
    texto(img, (px0, y0 + 1), "PALETA", SK8, o["felipe"])
    claves = ["fondo", "panel", "linea", "texto", "apagado", "contorno", "felipe", "valeria", "aspi", "maquina"]
    for i, c in enumerate(claves):
        cy = y0 + 12 + i * 12
        d.rectangle([px0, cy, px0 + 9, cy + 9], fill=hexa(o["contorno"]))
        d.rectangle([px0 + 1, cy + 1, px0 + 8, cy + 8], fill=hexa(o[c]))
        texto(img, (px0 + 13, cy + 1), o[c].upper(), F8, o["texto"])

    # Letras
    tx = 192
    texto(img, (tx, y0 + 1), "LETRAS (ya en el juego)", SK8, o["felipe"])
    texto(img, (tx, y0 + 9), "VALERIA", F16B, o["valeria"])
    texto(img, (tx, y0 + 24), "nombre: Operator Bold 16", F8, o["apagado"])
    texto(img, (tx, y0 + 32), "¿Qué fue eso?", F16, o["texto"])
    texto(img, (tx, y0 + 47), "texto: Pixel Operator 16", F8, o["apagado"])
    texto(img, (tx, y0 + 55), "5/5   x9", F16B, o["texto"])
    texto(img, (tx, y0 + 70), "números: Operator Bold 16", F8, o["apagado"])
    texto(img, (tx, y0 + 79), "¡TRAVESURA!", SK16, o["felipe"], contorno=o["contorno"])
    texto(img, (tx, y0 + 98), "carteles: Silkscreen 16 o 24", F8, o["apagado"])
    texto(img, (tx, y0 + 107), "FASE II · SNACKS · PAUSA", SK8, o["texto"])
    texto(img, (tx, y0 + 117), "etiquetas: Silkscreen 8", F8, o["apagado"])

    # Forma y movimiento
    fx = 372
    texto(img, (fx, y0 + 1), "FORMA", SK8, o["felipe"])
    pts = paralelo(fx + 40, y0, 44, 12, o["k"])
    poligono(img, pts, hexa(o["contorno"]))
    poligono(img, encoger(pts, 1), hexa(o["linea"]))
    poligono(img, encoger(pts, 2), hexa(o["panel"]))
    texto(img, (fx + 90, y0 + 2), o["angulo"], F8, o["texto"])
    for i, l in enumerate(o["forma"]):
        texto(img, (fx, y0 + 15 + i * 10), l, F8, o["texto"])
    my = y0 + 17 + len(o["forma"]) * 10
    texto(img, (fx, my), "MOVIMIENTO", SK8, o["felipe"])
    for i, l in enumerate(o["mov"]):
        texto(img, (fx, my + 11 + i * 10), l, F8, o["texto"])
    return img


def main() -> None:
    caras_base = retratos()
    for letra in OPCIONES:
        caras = {
            "felipe": caras_base["felipe"],
            "felipe_presumido": achicar(caras_base["felipe_presumido"], 40),
            "valeria": achicar(caras_base["valeria"], 52),
            "felipe_ficha": con_contorno(achicar(caras_base["felipe_presumido"], 30), (14, 12, 18, 255)),
            "aspi": caras_base["aspi"],
            "aspi_alerta": caras_base["aspi_alerta"],
        }
        img = lamina(letra, caras)
        destino = os.path.join(CAPTURAS, f"direccion-arte-{letra}.png")
        img.save(destino)
        img.resize((1280, 720), Image.NEAREST).save(destino.replace(".png", "-x2.png"))
        print(destino)


if __name__ == "__main__":
    main()
