#!/usr/bin/env python3
"""Lámina de revisión del kit de interfaz v2 (A + C).

1. Todas las piezas de siete-vidas/juego/assets/ui/v2/ a x1 y a x4.
2. Las 4 pantallas de direccion-arte-AC-v2.png y el recuadro de texto grande, rearmados SOLO con los PNG del kit
   (más el texto y los retratos, que pone el juego) sobre las capturas base-*.png, al lado de la lámina original,
   con el porcentaje de píxeles iguales.
3. Revisa que con texto grande queden al menos 6 px libres entre el retrato y el texto (y en normal también).

Uso:  python3 siete-vidas/herramientas/interfaz_v2_kit_lamina.py   (rehace antes el kit con interfaz_v2_kit.py)
Sale: siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/kit-v2.png (y -x2.png)
"""
from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw

import interfaz_v2_kit as kit
import interfaz_v2_laminas as k
import interfaz_v2_laminas_layout as L

O = kit.O
SEG = L.SEGURA
NOTA = k.F8
HUECO_MIN = 6   # px libres entre el retrato (con su fondo, sombra y fragmentos) y el texto del diálogo
P: dict = {}
MEDIDAS: list = []


def cargar(nombre) -> Image.Image:
    return Image.open(os.path.join(kit.DESTINO, P[nombre]["archivo"])).convert("RGBA")


def estirar(im: Image.Image, info, ancho) -> Image.Image:
    """Estira una pieza de 3 partes a lo ancho (como NinePatchRect): repite la columna del centro."""
    if ancho is None or ancho == info["ancho"]:
        return im
    izq, der = info["hz"]
    nuevo = im.width + ancho - info["ancho"]
    assert nuevo - izq - der >= 1, (info["archivo"], ancho)
    out = Image.new("RGBA", (nuevo, im.height), (0, 0, 0, 0))
    out.paste(im.crop((0, 0, izq, im.height)), (0, 0))
    out.paste(im.crop((izq, 0, izq + 1, im.height)).resize((nuevo - izq - der, im.height), Image.NEAREST), (izq, 0))
    out.paste(im.crop((im.width - der, 0, im.width, im.height)), (nuevo - der, 0))
    return out


def poner(img, nombre, x, y, ancho=None):
    info = P[nombre]
    im = estirar(cargar(nombre), info, ancho)
    img.alpha_composite(im, (x - info["ancla"][0], y - info["ancla"][1]))


def tira(img, nombre, x, y, ancho):
    """Repite una tira (relleno de barra) a lo ancho."""
    t = cargar(nombre)
    for i in range(0, ancho, t.width):
        img.alpha_composite(t.crop((0, 0, min(t.width, ancho - i), t.height)), (x + i, y))


def fragmentos(img, color, cx, cy, n, semilla, radio):
    t_img = cargar(f"fragmentos-{color}")
    for x, y, t in kit.posiciones_fragmentos(cx, cy, n, semilla, radio):
        i = t - 2
        celda = t_img.crop((i * 6, 0, i * 6 + 6, 6))
        img.alpha_composite(celda, (x, y))


def franja_texto(img, x, y, t, f, alto, color_texto, pieza):
    w = k.ancho(t, f) + 16
    poner(img, pieza, x, y, ancho=w)
    top = f.getbbox("H")[1]
    dy = (alto - L.alto_mayus(f)) // 2 - top - 1
    k.texto(img, (x + 8, y + dy + 1), t, f, color_texto)
    return w


# -------------------------------------------------------------------------------------------------------------------
# Piezas en el layout (mismas coordenadas que interfaz_v2_laminas_layout.py)
# -------------------------------------------------------------------------------------------------------------------
def huellas(img, ox, oy, cara, llenas=6, media=True, g=1):
    w, h = 152 * g, 20 * g
    x, y = ox + SEG[0], oy + SEG[1]
    poner(img, "hud-caja" + ("-grande" if g == 2 else ""), x, y)
    img.alpha_composite(cara, (x + 4 * g, y + (h - cara.height) // 2))
    for i in range(9):
        est = "llena" if i < llenas else ("media" if (i == llenas and media) else "vacia")
        hu = cargar(f"huella-{est}" + ("-grande" if g == 2 else ""))
        img.alpha_composite(hu, (x + 8 * g + 16 * g + i * 14 * g - g, y + (h - hu.height) // 2))


def barra_jefe(img, ox, oy, cara, valor=0.55, reciente=0.68, fase=1):
    x, y = ox + SEG[2] - 250, oy + SEG[1]
    poner(img, "jefe-retrato-marco", x, y)
    fragmentos(img, "aspi", x + 4, y + 2, 5, 9, 10)
    img.alpha_composite(cara, (x + 4, y + 25 - cara.height))
    f = L.FUENTES[1]
    franja_texto(img, x + 30, y, "A.S.P.I.", f["nombre"], 14, O["contorno"], "jefe-nombre-franja")
    bx, by, bw, bh = x + 30, y + 17, 220, 10
    poner(img, "jefe-barra-marco", bx, by)
    ix, iw = bx + 5, bw - 12
    tira(img, "jefe-barra-dano", ix, by + 4, int(iw * reciente) + 1)
    tira(img, "jefe-barra-relleno", ix, by + 4, int(iw * valor) + 1)
    poner(img, "jefe-barra-cortes", bx, by)
    for i, m in enumerate(("I", "II", "III")):
        mx = ix + int(iw * (i + 0.5) / 3) - k.ancho(m, f["cartel"]) // 2
        L.escribir(img, mx, by + bh + 6, m, f["cartel"], O["aspi"] if i == fase else O["texto"], contorno=O["contorno"])


def dialogo(img, ox, oy, quien, cara, t, g=1, sangria_extra=0):
    f = L.FUENTES[g]
    suf = "-grande" if g == 2 else ""
    y_franja = SEG[1] + 20 * g + 6
    franja_h = 15 if g == 1 else 26
    y_caja = y_franja + franja_h // 2 + 2
    caja_h = 16 + 2 * f["linea"]
    bx, bw = 80, 528
    poner(img, f"dialogo-marco-{quien}{suf}", ox + bx, oy + y_caja, ancho=bw)
    # retrato (fondo, fragmentos y cara) en su propia capa, para medir el hueco con el texto
    capa = Image.new("RGBA", img.size, (0, 0, 0, 0))
    alto_fondo = min(60, caja_h + 8)
    fx, fy = ox + SEG[0], oy + y_caja + caja_h - alto_fondo
    poner(capa, f"retrato-fondo-{quien}{suf}", fx, fy)
    fragmentos(capa, quien, fx + 4, fy + 2, 5, len(quien), 10)
    c2 = k.con_contorno(cara, k.hexa(O["contorno"]))
    capa.alpha_composite(c2, (ox + SEG[0] + 3, oy + y_caja + caja_h - c2.height))
    img.alpha_composite(capa)
    franja_texto(img, ox + bx + 22, oy + y_franja, quien.upper(), f["nombre"], franja_h,
                 O["texto"] if quien == "valeria" else O["contorno"], f"nombre-franja-{quien}{suf}")
    sangria = k.inclinacion(O, caja_h) + 14 + sangria_extra
    lineas = L.partir(t, f["texto"], bw - sangria - 24)
    capa_t = Image.new("RGBA", img.size, (0, 0, 0, 0))
    for i, linea in enumerate(lineas[:2]):
        L.escribir(capa_t, ox + bx + sangria, oy + y_caja + (9 if g == 1 else 13) + i * f["linea"], linea,
                   f["texto"], O["texto"])
    hueco = medir_hueco(capa, capa_t)
    img.alpha_composite(capa_t)
    poner(img, "dialogo-flecha", ox + bx + bw - 16, oy + y_caja + caja_h - 12)
    return hueco


def medir_hueco(capa_retrato, capa_texto) -> int:
    """Px libres entre lo más a la derecha del retrato y lo más a la izquierda del texto, en las filas del texto."""
    rt = np.asarray(capa_retrato)[..., 3] > 0
    tx = np.asarray(capa_texto)[..., 3] > 0
    filas = np.where(tx.any(axis=1))[0]
    izq_texto = np.where(tx[filas].any(axis=0))[0].min()
    der_ret = max((np.where(rt[y])[0].max() for y in filas if rt[y].any()), default=-1)
    return int(izq_texto - der_ret - 1)


def cartel(img, ox, oy, titulo, sub):
    f = L.FUENTES[1]
    h, s = 22, k.inclinacion(O, 22, 2)
    w = k.ancho(titulo, f["cartel"]) + 48 + s
    x, y = ox + (640 - w) // 2, oy + SEG[1] + 26
    poner(img, "cartel-franja", x, y, ancho=w)
    poner(img, "cartel-sello", x - 6, y - 4)
    L.escribir(img, x + 30, y + (h - L.alto_mayus(f["cartel"])) // 2, titulo, f["cartel"], O["contorno"])
    fragmentos(img, "felipe", x + w - 6, y + 4, 5, 7, 12)
    sw = k.ancho(sub, f["texto"]) + 28
    sy2, sx2 = y + h + 2, ox + (640 - sw) // 2
    poner(img, "cartel-linea", sx2, sy2, ancho=sw)
    L.escribir(img, sx2 + 14, sy2 + 5, sub, f["texto"], O["texto"])


def logro(img, x_der, y, t, g=1):
    f = L.FUENTES[g]
    suf = "-grande" if g == 2 else ""
    icono = 16 * g
    h = icono + 8
    w = 12 + icono + 10 + k.ancho(t, f["texto"]) + 18
    x = x_der - w
    poner(img, f"logro-etiqueta{suf}", x, y, ancho=w)
    cx, cy, r = x + 10 + icono // 2, y + h // 2, icono // 2 + 2
    poner(img, f"logro-icono{suf}", cx - r, cy - r)
    L.escribir(img, x + 14 + icono + 8, y + (h - L.alto_mayus(f["texto"])) // 2, t, f["texto"], O["texto"])


def aviso(img, cx, y_base, t):
    f = L.FUENTES[1]
    w, h = k.ancho(t, f["cartel"]) + 20, 20
    x, y = cx - w // 2, y_base - h - 8
    poner(img, "aviso-marco", x, y, ancho=w)
    L.escribir(img, x + 10 + k.inclinacion(O, h) // 2, y + (h - L.alto_mayus(f["cartel"])) // 2, t, f["cartel"],
               O["oportunidad"])
    poner(img, "aviso-flecha", cx - 5, y + h + 1)


def globito(img, x, y, t, cola_x):
    w, h = k.ancho(t, k.F16) + 16, 18
    poner(img, "globito-caja", x, y, ancho=w)
    poner(img, "globito-cola", cola_x - 5, y + h)            # abre el borde de abajo y baja hacia Felipe
    poner(img, "globito-oreja-izq", x + 6, y - 7)            # la base de la oreja abre el borde de arriba
    poner(img, "globito-oreja-der", x + w - 18, y - 7)
    k.texto(img, (x + 8 + k.inclinacion(O, h) // 2, y + 1), t, k.F16, O["texto"])


def pausa(img, ox, oy, cara_ficha):
    f = L.FUENTES[1]
    img.alpha_composite(Image.new("RGBA", (640, 360), k.hexa(O["fondo"], 200)), (ox, oy))   # velo (ColorRect)
    x0, y0 = ox + SEG[0], oy + SEG[1]
    poner(img, "pausa-panel", x0, y0)
    lx = x0 + 14
    franja_texto(img, lx, y0 + 10, "PAUSA", f["cartel"], 18, O["contorno"], "titulo-franja")
    y = y0 + 40
    for i, op in enumerate(("Continuar", "Bolsillo", "Ficha", "Opciones", "Reiniciar", "Salir")):
        poner(img, "boton-resaltado" if i == 1 else "boton-normal", lx - 2, y - 4, ancho=142)
        L.escribir(img, lx + 10, y + 1, op, f["nombre"] if i == 1 else f["texto"], O["contorno"] if i == 1 else O["texto"])
        y += 24
    cx, cw = x0 + 168, 576 - 168 - 14
    franja_texto(img, cx, y0 + 10, "BOLSILLO", f["cartel"], 18, O["contorno"], "titulo-franja")
    filas = [("Salud", "6 y media de 9", "huella-llena"), ("Snacks", "3 de 5", "icono-snack"),
             ("Calcetines", "4", "icono-calcetin"), ("Fotos", "2 de 6", "icono-foto")]
    y = y0 + 38
    for n, v, ic in filas:
        poner(img, "bolsillo-fila", cx, y, ancho=cw)
        im = cargar(ic)
        img.alpha_composite(im, (cx + 12, y + (22 - im.height) // 2))
        L.escribir(img, cx + 34, y + 7, n, f["texto"], O["texto"])
        L.escribir(img, cx + cw - 16 - k.ancho(v, f["nombre"]), y + 7, v, f["nombre"], O["texto"])
        y += 26
    fy = y + 6
    poner(img, "ficha-panel", cx, fy)
    poner(img, "ficha-retrato-fondo", cx + 8, fy + 8)
    fragmentos(img, "felipe", cx + 12, fy + 10, 5, 3, 10)
    cara = k.con_contorno(cara_ficha, k.hexa(O["contorno"]))
    img.alpha_composite(cara, (cx + 12, fy + 60 - cara.height))
    L.escribir(img, cx + 74, fy + 10, "SU MAJESTAD · 8,2 kg", f["nombre"], O["felipe"])
    for i, (n, fr, p, v) in enumerate((("Carisma", "Irresistible.", "felipe", 0.95),
                                       ("Defensa", "Muy mullido.", "maquina", 0.6),
                                       ("Ataque", "Con desdén.", "aspi", 0.7))):
        yy = fy + 28 + i * 17
        L.escribir(img, cx + 74, yy, n, f["texto"], O["apagado"])
        bx = cx + 140
        poner(img, "ficha-barra-marco", bx, yy)
        poner(img, f"ficha-barra-relleno-{p}", bx + 1, yy + 1, ancho=int(58 * v))
        L.escribir(img, bx + 68, yy, fr, f["texto"], O["texto"])


# -------------------------------------------------------------------------------------------------------------------
# Pantallas rearmadas
# -------------------------------------------------------------------------------------------------------------------
def marcar(img, px, py, nombre):
    """Las mismas marcas que la lámina original (borde, nombre y zona segura punteada)."""
    d = ImageDraw.Draw(img)
    d.rectangle([px, py, px + 639, py + 359], outline=k.hexa(O["contorno"]))
    k.texto(img, (px + 3, py + 351), nombre, NOTA, O["texto"], contorno=O["contorno"])
    for xx in range(px + 32, px + 608, 8):
        img.putpixel((xx, py + 18), (255, 80, 80, 255))
        img.putpixel((xx, py + 342), (255, 80, 80, 255))
    for yy in range(py + 18, py + 342, 8):
        img.putpixel((px + 32, yy), (255, 80, 80, 255))
        img.putpixel((px + 608, yy), (255, 80, 80, 255))


def pantallas(caras):
    """Devuelve las 4 pantallas y el recuadro grande rearmados con el kit, con la misma posición que en la lámina."""
    hoja = Image.new("RGBA", (1280, 990), k.hexa(O["fondo"]))
    cara_hud = k.con_contorno(k.achicar(caras["felipe"], 14), k.hexa(O["contorno"]))
    cara_aspi = k.con_contorno(k.achicar(caras["aspi"], 12), k.hexa(O["contorno"]))
    pos = [(0, 24), (640, 24), (0, 388), (640, 388)]
    ox, oy = pos[0]
    hoja.alpha_composite(L.base("base-sala.png"), (ox, oy))
    huellas(hoja, ox, oy, cara_hud)
    MEDIDAS.append(("Diálogo normal (Valeria)", dialogo(hoja, ox, oy, "valeria", caras["valeria"], L.TEXTO_VALERIA)))
    ox, oy = pos[1]
    hoja.alpha_composite(L.base("base-pelea-2.png"), (ox, oy))
    huellas(hoja, ox, oy, cara_hud, llenas=4, media=False)
    barra_jefe(hoja, ox, oy, cara_aspi)
    aviso(hoja, ox + 210, oy + 292, "¡LLENA! ¡SALTA!")
    globito(hoja, ox + 262, oy + 222, "¿Eso es todo?", ox + 318)
    ox, oy = pos[2]
    hoja.alpha_composite(L.base("base-sala-2.png"), (ox, oy))
    huellas(hoja, ox, oy, cara_hud)
    cartel(hoja, ox, oy, "¡TRAVESURA CUMPLIDA!", "Robar el almuerzo de Valeria")
    ox, oy = pos[3]
    hoja.alpha_composite(L.base("base-sala-2.png"), (ox, oy))
    pausa(hoja, ox, oy, caras["ficha"])
    for p, n in zip(pos, ("1 · Exploración + diálogo (arriba)", "2 · Pelea: salud, jefe, aviso, globito",
                          "3 · Cartel de travesura (de a uno)", "4 · Pausa")):
        marcar(hoja, *p, n)
    # Texto grande: el hueco retrato-texto tiene que ser de 6 px o más; si no, se corre el texto
    y0 = 752
    grande = Image.new("RGBA", hoja.size, (0, 0, 0, 0))
    grande.alpha_composite(L.base("base-sala.png").crop((0, 0, 640, 236)), (0, y0))
    huellas(grande, 0, y0, k.con_contorno(k.achicar(caras["felipe"], 28), k.hexa(O["contorno"])), g=2)
    prueba = grande.copy()
    hueco = dialogo(prueba, 0, y0, "felipe", caras["felipe_dialogo"], L.TEXTO_FELIPE_GRANDE, g=2)
    extra = max(0, HUECO_MIN - hueco)
    hueco = dialogo(grande, 0, y0, "felipe", caras["felipe_dialogo"], L.TEXTO_FELIPE_GRANDE, g=2, sangria_extra=extra)
    MEDIDAS.append(("Diálogo grande (Felipe)", hueco))
    logro(grande, 608, y0 + 172, "Coleccionista de Calcetines", g=2)
    ImageDraw.Draw(grande).rectangle([0, y0, 639, y0 + 235], outline=k.hexa(O["contorno"]))
    k.texto(grande, (3, y0 + 226), "TEXTO GRANDE (200 %): mismo layout, diálogo arriba; logro (de a uno) a la derecha",
            NOTA, O["texto"], contorno=O["contorno"])
    hoja.alpha_composite(grande)
    return hoja, pos, extra


# -------------------------------------------------------------------------------------------------------------------
# Lámina
# -------------------------------------------------------------------------------------------------------------------
ANCHO = 1300


def cuadros(w, h, lado=4):
    """Fondo de cuadros grises (transparencia), para que se vean también las piezas oscuras."""
    im = Image.new("RGBA", (w, h), (92, 86, 96, 255))
    d = ImageDraw.Draw(im)
    for yy in range(0, h, lado):
        for xx in range((yy // lado) % 2 * lado, w, lado * 2):
            d.rectangle([xx, yy, xx + lado - 1, yy + lado - 1], fill=(120, 112, 124, 255))
    return im


def fluir(img, items, x0, y0, escala, ancho_max, recorte_max=None):
    """Pone piezas en filas con su nombre debajo, sobre cuadros. Devuelve la y final."""
    x, y, alto_fila = x0, y0, 0
    for nombre in items:
        im = cargar(nombre)
        etiqueta = nombre
        if recorte_max and nombre != "jefe-barra-cortes" and (im.width > recorte_max or im.height > recorte_max + 12):
            im = im.crop((0, 0, min(im.width, recorte_max), min(im.height, recorte_max + 12)))
            etiqueta += " (esquina)"
        im = im.resize((im.width * escala, im.height * escala), Image.NEAREST)
        w = max(im.width, k.ancho(etiqueta, NOTA)) + 10
        if x + w > ancho_max:
            x, y, alto_fila = x0, y + alto_fila + 16, 0
        img.alpha_composite(cuadros(im.width, im.height, 2 * escala), (x, y))
        img.alpha_composite(im, (x, y))
        k.texto(img, (x, y + im.height + 3), etiqueta, NOTA, O["apagado"])
        x += w
        alto_fila = max(alto_fila, im.height)
    return y + alto_fila + 18


def titulo(img, y, t, sub=""):
    L.escribir(img, 8, y, t, k.SK16, O["felipe"])
    if sub:
        k.texto(img, (k.ancho(t, k.SK16) + 20, y - 3), sub, k.F16, O["texto"])
    return y + 18


def lamina():
    global P
    P = kit.construir()
    base_caras = k.retratos()
    caras = {"felipe": base_caras["felipe"], "valeria": k.achicar(base_caras["valeria"], 52),
             "felipe_dialogo": k.achicar(base_caras["felipe_presumido"], 52),
             "ficha": k.achicar(base_caras["felipe_presumido"], 48), "aspi": base_caras["aspi"]}
    rearmada, pos, extra = pantallas(caras)
    original = Image.open(os.path.join(k.CAPTURAS, "direccion-arte-AC-v2.png")).convert("RGBA")

    img = Image.new("RGBA", (ANCHO, 6000), k.hexa(O["fondo"]))
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, ANCHO, 21], fill=k.hexa(O["contorno"]))
    t = "KIT DE INTERFAZ V2 · A + C"
    k.poligono(img, k.paralelo(4, 2, k.ancho(t, k.SK16) + 24, 18, 2), k.hexa(O["felipe"]))
    L.escribir(img, 14, 6, t, k.SK16, O["contorno"])
    k.texto(img, (k.ancho(t, k.SK16) + 40, 4), f"{len(P)} piezas en juego/assets/ui/v2/ · base 640x360 · paleta exacta, "
            "sin suavizado", k.F16, O["texto"])
    grandes = ["pausa-panel", "ficha-panel", "hud-caja-grande"]
    chicas = [n for n in P if n not in grandes]
    y = titulo(img, 32, "PIEZAS A X1", "todas, a su tamaño real")
    y = fluir(img, chicas, 8, y + 4, 1, ANCHO - 8)
    x = 8
    for n in grandes:
        im = cargar(n)
        img.alpha_composite(cuadros(im.width, im.height), (x, y))
        img.alpha_composite(im, (x, y))
        k.texto(img, (x, y + im.height + 3), n, NOTA, O["apagado"])
        x += im.width + 12
    y += max(cargar(n).height for n in grandes) + 22
    y = titulo(img, y, "PIEZAS A X4", "las grandes, solo su esquina de arriba a la izquierda (lo que se estira es la columna del centro)")
    y = fluir(img, [n for n in P if not n.endswith("-grande") or n.startswith("huella")], 8, y + 4, 4, ANCHO - 8,
              recorte_max=40)

    y = titulo(img, y + 6, "PANTALLAS", "izquierda: direccion-arte-AC-v2.png · derecha: rearmada SOLO con el kit "
               "(más texto y retratos del juego)")
    y += 4
    zonas = [(p, 640, 360) for p in pos] + [((0, 752), 640, 236)]
    nombres = ["1 · Exploración + diálogo", "2 · Pelea", "3 · Cartel", "4 · Pausa", "Texto grande (200 %)"]
    for (px, py), w, h in zonas:
        a = original.crop((px, py, px + w, py + h))
        b = rearmada.crop((px, py, px + w, py + h))
        igual = (np.asarray(a) == np.asarray(b)).all(axis=2).mean() * 100
        img.alpha_composite(a, (8, y + 14))
        img.alpha_composite(b, (8 + 640 + 4, y + 14))
        n = nombres.pop(0)
        k.texto(img, (8, y + 2), f"{n} · lámina", NOTA, O["texto"])
        k.texto(img, (652, y + 2), f"{n} · con el kit · {igual:.1f} % de píxeles iguales a la lámina", NOTA,
                O["oportunidad"])
        MEDIDAS.append((f"Iguales a la lámina · {n}", round(igual, 1)))
        y += h + 20
    notas = [f"{n}: {v}" + (" px libres entre retrato y texto" if "Diálogo" in n else " %") for n, v in MEDIDAS]
    notas.append(f"Texto grande: el texto se corrió {extra} px para dejar {HUECO_MIN} px o más después del retrato."
                 if extra else f"Texto grande: ya quedaban {HUECO_MIN} px o más después del retrato.")
    notas.append("Lo distinto es lo que cambió a propósito: huella, sello, pescadito, orejitas y cola (de la IA, "
                 "retocadas) y el botón sin foco.")
    for i, nt in enumerate(notas):
        k.texto(img, (8, y + i * 11), nt, NOTA, O["texto"])
    y += len(notas) * 11 + 6
    img = img.crop((0, 0, ANCHO, y))
    ruta = os.path.join(k.CAPTURAS, "kit-v2.png")
    img.save(ruta)
    img.resize((img.width * 2, img.height * 2), Image.NEAREST).save(ruta.replace(".png", "-x2.png"))
    for n, v in MEDIDAS:
        print(f"{n}: {v}")
    print(ruta)


if __name__ == "__main__":
    lamina()
