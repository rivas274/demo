#!/usr/bin/env python3
"""Láminas de dirección de arte A, B y C, versión 2: el estilo de cada opción aplicado al layout APROBADO.

Usa las piezas dibujadas por código de `interfaz_v2_laminas.py` y las pone en las posiciones y medidas del layout
(`interfaz_v2_layout.py`, sección «Layout y legibilidad multiplataforma» de diseno/interfaz-v2.md):
zona segura de títulos (32, 18)-(608, 342), letra de 11 px de cuerpo o más (Pixel Operator 16 / Bold 16 /
Silkscreen 16; nada de 8 px en lo que se lee), HUD solo con las 9 huellas, barra del jefe con 3 fases, diálogo
siempre arriba, carteles y logros de a uno y pausa con la lista a la izquierda y el contenido a la derecha.

Cada lámina (1280 x 980) junta 4 pantallas reales de 640 x 360 a escala 1 (capturas del juego sin interfaz,
`capturas/interfaz-rediseno/base-*.png`, de `capturas_sin_interfaz.gd`) y una franja con el texto grande (200 %),
la huella, la paleta y las reglas.

Uso:  python3 siete-vidas/herramientas/interfaz_v2_laminas_layout.py
Sale: siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/direccion-arte-{A,B,C}-v2.png (y -x2.png)
"""
from __future__ import annotations

import copy
import os

from PIL import Image, ImageDraw, ImageFont

import interfaz_v2_laminas as k  # piezas dibujadas por código (caja, franja, huella, fondo del retrato...)

CAPTURAS = k.CAPTURAS
SEGURA = (32, 18, 608, 342)

FUENTES = {
    1: {"texto": k.F16, "nombre": k.F16B, "cartel": k.SK16, "linea": 17},
    2: {"texto": k.fuente("PixelOperator.ttf", 32), "nombre": k.fuente("PixelOperator-Bold.ttf", 32),
        "cartel": k.fuente("Silkscreen-Regular.ttf", 32), "linea": 34},
}
NOTA = k.F8  # solo para las notas de la lámina (meta), nunca para la interfaz

# Choque dorado de Felipe / amarillo de oportunidad (lección 50): Felipe pasa a un oro ámbar (más anaranjado) y la
# oportunidad queda en amarillo limón, siempre como borde y texto sobre panel oscuro con su flecha, nunca como bloque.
AJUSTES = {
    "A": {"felipe": "#E8913A", "oportunidad": "#FFE066"},
    "B": {"felipe": "#E0A848", "oportunidad": "#FFE066"},
    "C": {"felipe": "#FF9F2E", "oportunidad": "#F2F05A"},
}


def opcion(letra):
    o = copy.deepcopy(k.OPCIONES[letra])
    o.update(AJUSTES[letra])
    return o


def escribir(img, x, y_mayus, t, f, color, contorno=None):
    """Escribe con la parte de arriba de las mayúsculas en y_mayus (cada letra trae su propio margen arriba)."""
    k.texto(img, (x, y_mayus - f.getbbox("H")[1]), t, f, color, contorno=contorno)


def alto_mayus(f):
    b = f.getbbox("H")
    return b[3] - b[1]


def partir(t, f, w):
    lineas, actual = [], ""
    for p in t.split(" "):
        prueba = (actual + " " + p).strip()
        if k.ancho(prueba, f) <= w:
            actual = prueba
        else:
            lineas.append(actual)
            actual = p
    if actual:
        lineas.append(actual)
    return lineas


def franja_v2(img, o, x, y, t, f, color, alto, color_texto=None):
    """Franja del nombre o título con el texto centrado en alto (usa la franja de cada opción)."""
    am = alto_mayus(f)
    top = f.getbbox("H")[1]
    dy = (alto - am) // 2 - top - 1
    if o["borde"] == "filete":
        dy -= 2
    return k.franja(img, o, x, y, t, f, color, color_texto, alto=alto, dy_texto=dy)


# -------------------------------------------------------------------------------------------------------------------
# Piezas en el layout aprobado (coordenadas de la pantalla; ox, oy = dónde está la pantalla en la lámina)
# -------------------------------------------------------------------------------------------------------------------


def huellas(img, o, ox, oy, cara, llenas=6, media=True, g=1):
    """Zona A: cara de Felipe + 9 huellas en 152 x 20 (304 x 40 en grande), desde (32, 18)."""
    w, h = 152 * g, 20 * g
    x, y = ox + SEGURA[0], oy + SEGURA[1]
    k.caja(img, o, x, y, w, h, acento=o["felipe"], k=max(o["k"], 4))
    img.alpha_composite(cara, (x + 4 * g, y + (h - cara.height) // 2))
    for i in range(9):
        est = "llena" if i < llenas else ("media" if (i == llenas and media) else "vacia")
        hu = k.huella(o, est, g)
        dy = (-g if i % 2 == 0 else g) if o["huellas"] == "rebote" else 0
        img.alpha_composite(hu, (x + 8 * g + 16 * g + i * 14 * g - g, y + (h - hu.height) // 2 + dy))


def barra_jefe(img, o, ox, oy, cara, valor=0.55, reciente=0.68, fase=1):
    """Zona A2: 250 x 40 a la derecha, desde (358, 18): retrato, nombre en franja, barra de 2 capas y fases I-II-III."""
    x, y = ox + SEGURA[2] - 250, oy + SEGURA[1]
    col = o["aspi"]
    k.fondo_retrato(img, o, x, y, 30, 26, col, semilla=9)
    img.alpha_composite(cara, (x + 4, y + 25 - cara.height))
    f = FUENTES[1]
    franja_v2(img, o, x + 30, y, "A.S.P.I.", f["nombre"], col, 14,
              o["contorno"] if o["borde"] != "filete" else col)
    bx, by, bw, bh = x + 30, y + 17, 220, 10
    k.caja(img, o, bx, by, bw, bh + 4, color_fondo=o["fondo"], acento=col, k=max(o["k"], 3))
    ix, iw = bx + 5, bw - 12
    d = ImageDraw.Draw(img)
    d.rectangle([ix, by + 4, ix + int(iw * reciente), by + bh - 1], fill=k.hexa(o["dano"]))
    d.rectangle([ix, by + 4, ix + int(iw * valor), by + bh - 1], fill=k.hexa(col))
    d.line([(ix, by + 4), (ix + int(iw * valor), by + 4)], fill=k.mezclar(k.hexa(col), (255, 255, 255), 0.45))
    for i, m in enumerate(("I", "II", "III")):
        sx = ix + int(iw * (i + 1) / 3)
        if i < 2:
            d.line([(sx, by + 3), (sx - 2, by + bh)], fill=k.hexa(o["contorno"]), width=2)
        mx = ix + int(iw * (i + 0.5) / 3) - k.ancho(m, f["cartel"]) // 2
        escribir(img, mx, by + bh + 6, m, f["cartel"], col if i == fase else o["texto"], contorno=o["contorno"])


def dialogo(img, o, ox, oy, quien, cara, t, color, g=1):
    """Zona B (siempre arriba): caja de 528 px desde x 80, franja del nombre y retrato de 52 px desde x 32."""
    f = FUENTES[g]
    y_franja = SEGURA[1] + 20 * g + 6
    franja_h = 15 if g == 1 else 26
    y_caja = y_franja + franja_h // 2 + 2
    caja_h = 16 + 2 * f["linea"]
    bx, bw = 80, 528
    k.caja(img, o, ox + bx, oy + y_caja, bw, caja_h, acento=color)
    alto_fondo = min(60, caja_h + 8)
    k.fondo_retrato(img, o, ox + SEGURA[0], oy + y_caja + caja_h - alto_fondo, 58, alto_fondo, color, semilla=len(quien))
    c2 = k.con_contorno(cara, k.hexa(o["contorno"]))
    img.alpha_composite(c2, (ox + SEGURA[0] + 3, oy + y_caja + caja_h - c2.height))
    franja_v2(img, o, ox + bx + 22, oy + y_franja, quien.upper(), f["nombre"], color, franja_h,
              (o["texto"] if quien == "valeria" else o["contorno"]) if o["borde"] != "filete" else color)
    sangria = k.inclinacion(o, caja_h) + 14
    lineas = partir(t, f["texto"], bw - sangria - 24)
    for i, l in enumerate(lineas[:2]):
        corre = (i * f["linea"]) // max(o["k"], 1) if o["esquina"] == "recta" else 0
        # el texto empieza bajo la franja del nombre (que monta 1/2 sobre la caja)
        escribir(img, ox + bx + sangria - corre, oy + y_caja + (9 if g == 1 else 13) + i * f["linea"], l,
                 f["texto"], o["texto"])
    k.flecha(img, o, ox + bx + bw - 16 - (k.inclinacion(o, caja_h) // 2 if o["esquina"] == "recta" else 0),
             oy + y_caja + caja_h - 12, o["linea"] if o["borde"] != "grueso" else color)
    return len(lineas)


def cartel(img, o, ox, oy, titulo, sub):
    """Zona C: travesura centrada bajo el HUD (y 44): franja diagonal de 22 px + línea de 19 px."""
    f = FUENTES[1]
    kk = max(2, o["k"] - 1)
    col = o["felipe"]
    h = 22
    s = k.inclinacion(o, h, kk)
    w = k.ancho(titulo, f["cartel"]) + 48 + s
    x = ox + (640 - w) // 2
    y = oy + SEGURA[1] + 26
    pts = k.paralelo(x, y, w, h, kk, s=s)
    sp = o["sombra_px"] + 1
    k.poligono(img, [(a + sp, b + sp) for a, b in pts], k.hexa(o["sombra"] if o["borde"] != "grueso" else o["valeria"]))
    k.poligono(img, pts, k.hexa(o["contorno"]))
    if o["borde"] == "filete":
        k.poligono(img, k.paralelo(x + 1, y + 1, w - 2, h - 2, kk, s=s), k.hexa(o["texto"]))
        k.poligono(img, k.paralelo(x + 2, y + 2, w - 4, h - 4, kk, s=s), k.mezclar(k.hexa(col), k.hexa(o["contorno"]), 0.4))
        k.poligono(img, k.paralelo(x + 3, y + 3, w - 6, h - 6, kk, s=s), k.hexa(col))
    else:
        k.poligono(img, k.encoger(pts, 1), k.hexa(col))
        ImageDraw.Draw(img).line([(x + s + 3, y + 2), (x + w - 4, y + 2)], fill=k.mezclar(k.hexa(col), (255, 255, 255), 0.6))
    if o["borde"] == "grueso":
        k.trama(img, (x, y, x + 46, y + h), k.mezclar(k.hexa(col), (255, 255, 255), 0.45), paso=2)
    # sello de huella (rombo A, octágono B, estrella C)
    sx, sy = x - 6, y - 4
    if o["borde"] == "filete":
        sello = [(sx + 9, sy), (sx + 20, sy), (sx + 28, sy + 9), (sx + 28, sy + 21), (sx + 20, sy + 30),
                 (sx + 9, sy + 30), (sx, sy + 21), (sx, sy + 9)]
    elif o["borde"] == "grueso":
        import math
        sello = [(sx + 14 + math.cos(i * math.pi / 8) * (17 if i % 2 == 0 else 11),
                  sy + 15 + math.sin(i * math.pi / 8) * (17 if i % 2 == 0 else 11)) for i in range(16)]
        k.poligono(img, [(a + 2, b + 2) for a, b in sello], k.hexa(o["valeria"]))
    else:
        sello = [(sx + 14, sy), (sx + 28, sy + 15), (sx + 14, sy + 30), (sx, sy + 15)]
    k.poligono(img, sello, k.hexa(o["contorno"]))
    k.poligono(img, k.encoger(sello, 1), k.hexa(o["linea"]))
    k.poligono(img, k.encoger(sello, 2), k.hexa(o["fondo"]))
    img.alpha_composite(k.huella(o, "llena"), (sx + 8, sy + 9))
    escribir(img, x + 30, y + (h - alto_mayus(f["cartel"])) // 2, titulo, f["cartel"], o["contorno"])
    k.fragmentos(img, o, x + w - 6, y + 4, col, n=5, semilla=7, radio=12)
    sw = k.ancho(sub, f["texto"]) + 28
    sy2 = y + h + 2
    sx2 = ox + (640 - sw) // 2
    k.caja(img, o, sx2, sy2, sw, 19, acento=col)
    escribir(img, sx2 + 14 + (k.inclinacion(o, 19) // 2 if o["esquina"] == "recta" else 0), sy2 + 5, sub, f["texto"], o["texto"])


def logro(img, o, x_der, y, t, g=1):
    """Zona C, a la derecha: etiqueta diagonal con ícono (entra de lado; de a uno con los carteles)."""
    f = FUENTES[g]
    icono = 16 * g
    h = icono + 8
    w = 12 + icono + 10 + k.ancho(t, f["texto"]) + 18
    x = x_der - w
    k.caja(img, o, x, y, w, h, acento=o["felipe"])
    cx, cy = x + 10 + icono // 2, y + h // 2
    r = icono // 2 + 2
    rombo = [(cx - r, cy), (cx, cy - r), (cx + r, cy), (cx, cy + r)]
    k.poligono(img, rombo, k.hexa(o["contorno"]))
    k.poligono(img, k.encoger(rombo, 1), k.hexa(o["felipe"]))
    hu = k.huella(o, "vacia", g)
    img.alpha_composite(hu, (cx - hu.width // 2, cy - hu.height // 2))
    escribir(img, x + 14 + icono + 8, y + (h - alto_mayus(f["texto"])) // 2, t, f["texto"], o["texto"])


def aviso_oportunidad(img, o, cx, y_base, t):
    """Aviso de oportunidad sobre el jefe: panel oscuro con borde y texto amarillo limón y flecha hacia abajo.
    Nunca un bloque dorado: así no se confunde con lo de Felipe."""
    f = FUENTES[1]
    w = k.ancho(t, f["cartel"]) + 20
    h = 20
    x, y = cx - w // 2, y_base - h - 8
    o2 = dict(o, linea=o["oportunidad"])
    k.caja(img, o2, x, y, w, h, color_fondo=o["fondo"], acento=o["oportunidad"])
    escribir(img, x + 10 + k.inclinacion(o, h) // 2, y + (h - alto_mayus(f["cartel"])) // 2, t, f["cartel"], o["oportunidad"])
    c = k.hexa(o["oportunidad"])
    k.poligono(img, [(cx - 5, y + h + 1), (cx + 5, y + h + 1), (cx, y + h + 7)], k.hexa(o["contorno"]))
    k.poligono(img, [(cx - 3, y + h + 1), (cx + 3, y + h + 1), (cx, y + h + 5)], c)


ICONOS = {
    "calcetin": ["..XXX..", "..XXX..", "..XXX..", "..XXX..", "..XXXX.", ".XXXXXX", "XXXXXX.", "XXXX..."],
    "foto": ["XXXXXXXXX", "XOOOOOOOX", "XOOXOOOOX", "XOXXXOOOX", "XXXXXXXOX", "XOOOOOOOX", "XXXXXXXXX"],
}


def pausa(img, o, ox, oy, caras):
    """Pausa: panel en toda la zona segura; lista a la izquierda (150 px) y contenido a la derecha."""
    f = FUENTES[1]
    velo = Image.new("RGBA", (640, 360), k.hexa(o["fondo"], 200))
    img.alpha_composite(velo, (ox, oy))
    x0, y0 = ox + SEGURA[0], oy + SEGURA[1]
    k.caja(img, o, x0, y0, 576, 324, color_fondo=o["fondo"], acento=o["felipe"], k=12)
    # lista
    lx = x0 + 14
    franja_v2(img, o, lx, y0 + 10, "PAUSA", f["cartel"], o["felipe"], 18,
              o["contorno"] if o["borde"] != "filete" else o["felipe"])
    y = y0 + 40
    for i, op in enumerate(("Continuar", "Bolsillo", "Ficha", "Opciones", "Reiniciar", "Salir")):
        if i == 1:
            pts = k.paralelo(lx - 2, y - 4, 142, 19, o["k"], s=k.inclinacion(o, 19))
            k.poligono(img, pts, k.hexa(o["contorno"]))
            k.poligono(img, k.encoger(pts, 1), k.hexa(o["felipe"]))
            escribir(img, lx + 10, y + 1, op, f["nombre"], o["contorno"])
        else:
            escribir(img, lx + 10, y + 1, op, f["texto"], o["texto"])
        y += 24
    # contenido: bolsillo
    cx = x0 + 168
    cw = 576 - 168 - 14
    franja_v2(img, o, cx, y0 + 10, "BOLSILLO", f["cartel"], o["felipe"], 18,
              o["contorno"] if o["borde"] != "filete" else o["felipe"])
    cont = k.hexa(o["contorno"])
    filas = [("Salud", "6 y media de 9", k.huella(o, "llena")),
             ("Snacks", "3 de 5", k.icono(k.SNACK, k.hexa(o["felipe"]), cont)),
             ("Calcetines", "4", k.icono(ICONOS["calcetin"], k.hexa(o["valeria"]), cont)),
             ("Fotos", "2 de 6", k.icono(ICONOS["foto"], k.hexa(o["texto"]), cont, ojo=k.hexa(o["panel"])))]
    y = y0 + 38
    for n, v, ic in filas:
        k.caja(img, o, cx, y, cw, 22, acento=o["felipe"], k=max(o["k"], 4))
        img.alpha_composite(ic, (cx + 12, y + (22 - ic.height) // 2))
        escribir(img, cx + 34, y + 7, n, f["texto"], o["texto"])
        escribir(img, cx + cw - 16 - k.ancho(v, f["nombre"]), y + 7, v, f["nombre"], o["texto"])
        y += 26
    # ficha
    fy = y + 6
    k.caja(img, o, cx, fy, cw, oy + SEGURA[3] - 10 - fy, acento=o["felipe"], k=12)
    k.fondo_retrato(img, o, cx + 8, fy + 8, 56, 52, o["felipe"], semilla=3)
    cara = k.con_contorno(caras["ficha"], cont)
    img.alpha_composite(cara, (cx + 12, fy + 60 - cara.height))
    escribir(img, cx + 74, fy + 10, "SU MAJESTAD · 8,2 kg", f["nombre"], o["felipe"])
    for i, (n, fr, c, v) in enumerate((("Carisma", "Irresistible.", o["felipe"], 0.95),
                                        ("Defensa", "Muy mullido.", o["maquina"], 0.6),
                                        ("Ataque", "Con desdén.", o["aspi"], 0.7))):
        yy = fy + 28 + i * 17
        escribir(img, cx + 74, yy, n, f["texto"], o["apagado"])
        bx = cx + 140
        k.poligono(img, k.paralelo(bx, yy, 60, 9, 2), cont)
        k.poligono(img, k.paralelo(bx + 1, yy + 1, int(58 * v), 7, 2), k.hexa(c))
        escribir(img, bx + 68, yy, fr, f["texto"], o["texto"])


# -------------------------------------------------------------------------------------------------------------------
# Lámina
# -------------------------------------------------------------------------------------------------------------------
TEXTO_VALERIA = "¿Quién dejó abierta la puerta del balcón? Felipe, si fuiste tú, hoy no hay atún para nadie."
TEXTO_FELIPE_GRANDE = "Su Majestad no rompió nada. El vaso decidió saltar solo."


def base(nombre):
    return Image.open(os.path.join(CAPTURAS, nombre)).convert("RGBA")


def lamina(letra, caras):
    o = opcion(letra)
    W, H = 1280, 990
    img = Image.new("RGBA", (W, H), k.hexa(o["fondo"]))
    d = ImageDraw.Draw(img)
    # encabezado
    d.rectangle([0, 0, W, 21], fill=k.hexa(o["contorno"]))
    titulo = o["titulo"] + "  ·  v2 sobre el layout aprobado"
    k.poligono(img, k.paralelo(4, 2, k.ancho(titulo, k.SK16) + 24, 18, 2), k.hexa(o["felipe"]))
    escribir(img, 14, 6, titulo, k.SK16, o["contorno"])
    k.texto(img, (k.ancho(titulo, k.SK16) + 40, 4), o["corta"], k.F16, o["texto"])

    cara_hud = k.con_contorno(k.achicar(caras["felipe"], 14), k.hexa(o["contorno"]))
    cara_aspi = k.con_contorno(k.achicar(caras["aspi_alerta"] if letra == "C" else caras["aspi"], 12), k.hexa(o["contorno"]))

    pantallas = [(0, 24), (640, 24), (0, 388), (640, 388)]
    # 1. Exploración con diálogo de Valeria (arriba)
    ox, oy = pantallas[0]
    img.alpha_composite(base("base-sala.png"), (ox, oy))
    huellas(img, o, ox, oy, cara_hud)
    dialogo(img, o, ox, oy, "valeria", caras["valeria"], TEXTO_VALERIA, o["valeria"])
    # 2. Pelea: salud, barra del jefe, aviso de oportunidad sobre el jefe y globito sobre Felipe
    ox, oy = pantallas[1]
    img.alpha_composite(base("base-pelea-2.png"), (ox, oy))
    huellas(img, o, ox, oy, cara_hud, llenas=4, media=False)
    barra_jefe(img, o, ox, oy, cara_aspi)
    aviso_oportunidad(img, o, ox + 210, oy + 292, "¡LLENA! ¡SALTA!")
    k.globito(img, o, ox + 262, oy + 222, "¿Eso es todo?", ox + 318)
    # 3. Cartel de travesura (de a uno, bajo el HUD)
    ox, oy = pantallas[2]
    img.alpha_composite(base("base-sala-2.png"), (ox, oy))
    huellas(img, o, ox, oy, cara_hud)
    cartel(img, o, ox, oy, "¡TRAVESURA CUMPLIDA!", "Robar el almuerzo de Valeria")
    # 4. Pausa
    ox, oy = pantallas[3]
    img.alpha_composite(base("base-sala-2.png"), (ox, oy))
    pausa(img, o, ox, oy, caras)
    # marcos y nombres de las pantallas
    for i, ((px, py), nombre) in enumerate(zip(pantallas, ("1 · Exploración + diálogo (arriba)",
                                                           "2 · Pelea: salud, jefe, aviso, globito",
                                                           "3 · Cartel de travesura (de a uno)", "4 · Pausa"))):
        d.rectangle([px, py, px + 639, py + 359], outline=k.hexa(o["contorno"]))
        k.texto(img, (px + 3, py + 351), nombre, NOTA, o["texto"], contorno=o["contorno"])
        # zona segura (punteada, tenue)
        for xx in range(px + 32, px + 608, 8):
            img.putpixel((xx, py + 18), (255, 80, 80, 255))
            img.putpixel((xx, py + 342), (255, 80, 80, 255))
        for yy in range(py + 18, py + 342, 8):
            img.putpixel((px + 32, yy), (255, 80, 80, 255))
            img.putpixel((px + 608, yy), (255, 80, 80, 255))

    # 5. Franja de abajo: texto grande x2 (recuadro de 640 x 230 con fondo real), huella, paleta y reglas
    y0 = 752
    recorte = base("base-sala.png").crop((0, 0, 640, 236))
    img.alpha_composite(recorte, (0, y0))
    d.rectangle([0, y0, 639, y0 + 235], outline=k.hexa(o["contorno"]))
    huellas(img, o, 0, y0, k.con_contorno(k.achicar(caras["felipe"], 28), k.hexa(o["contorno"])), g=2)
    n = dialogo(img, o, 0, y0, "felipe", caras["felipe_dialogo"], TEXTO_FELIPE_GRANDE, o["felipe"], g=2)
    logro(img, o, 608, y0 + 172, "Coleccionista de Calcetines", g=2)
    k.texto(img, (3, y0 + 226), "TEXTO GRANDE (200 %): mismo layout, diálogo arriba; logro (de a uno) a la derecha",
            NOTA, o["texto"], contorno=o["contorno"])

    rx = 656
    escribir(img, rx, y0 + 4, "HUELLA (x2)", k.SK16, o["felipe"])
    for i, est in enumerate(("llena", "media", "vacia", "golpe", "curando")):
        hu = k.huella(o, est, 2)
        img.alpha_composite(hu, (rx + i * 44, y0 + 20))
        k.texto(img, (rx + i * 44, y0 + 46), est, NOTA, o["apagado"])
    escribir(img, rx + 232, y0 + 4, "PALETA", k.SK16, o["felipe"])
    claves = [("fondo", "fondo"), ("panel", "panel"), ("linea", "borde"), ("texto", "texto"), ("felipe", "Felipe"),
              ("oportunidad", "oportunidad"), ("valeria", "Valeria"), ("aspi", "A.S.P.I."), ("maquina", "2.º A.S.P.I."),
              ("apagado", "apagado")]
    for i, (c, nom) in enumerate(claves):
        cx = rx + 232 + (i % 2) * 190
        cy = y0 + 22 + (i // 2) * 16
        d.rectangle([cx, cy, cx + 13, cy + 13], fill=k.hexa(o["contorno"]))
        d.rectangle([cx + 1, cy + 1, cx + 12, cy + 12], fill=k.hexa(o[c]))
        k.texto(img, (cx + 18, cy - 1), f"{nom} {o[c].upper()}", k.F16, o["texto"])
    reglas = [
        f"Forma: diagonal {o['angulo']}; " + o["forma"][0].lower(),
        o["forma"][1], o["forma"][2],
        "Mov.: " + o["mov"][0], o["mov"][2], o["mov"][3],
        "Letras: Pixel Operator 16 / Bold 16 y Silkscreen 16 (11 px de cuerpo);",
        "grande: 32. Nada de 8 px en lo que se lee.",
        "Felipe en oro ámbar; oportunidad en amarillo limón, solo como borde",
        "y texto sobre panel oscuro con flecha (nunca un bloque).",
    ]
    for i, l in enumerate(reglas):
        k.texto(img, (rx, y0 + 108 + i * 12), l, NOTA, o["texto"])
    return img


def main():
    base_caras = k.retratos()
    caras = {
        "felipe": base_caras["felipe"],
        "valeria": k.achicar(base_caras["valeria"], 52),
        "felipe_dialogo": k.achicar(base_caras["felipe_presumido"], 52),
        "ficha": k.achicar(base_caras["felipe_presumido"], 48),
        "aspi": base_caras["aspi"],
        "aspi_alerta": base_caras["aspi_alerta"],
    }
    for letra in ("A", "B", "C"):
        img = lamina(letra, caras)
        ruta = os.path.join(CAPTURAS, f"direccion-arte-{letra}-v2.png")
        img.save(ruta)
        img.resize((img.width * 2, img.height * 2), Image.NEAREST).save(ruta.replace(".png", "-x2.png"))
        print(ruta)


if __name__ == "__main__":
    main()
