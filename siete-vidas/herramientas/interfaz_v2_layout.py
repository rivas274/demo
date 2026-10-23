#!/usr/bin/env python3
"""Wireframes de layout de la interfaz v2 (sin arte): cajas grises, etiquetas y medidas en px de la base 640x360.

Cada pantalla sale en dos versiones: texto normal (100 %) y texto grande (200 %, la opción de accesibilidad),
y cada una a 640x360 y ampliada x2. Marca la zona segura de títulos (90 %) y la de acción (95 %), una cuadrícula
de 8 px (más marcada cada 32 px) y las medidas de cada caja. Los textos usan las letras reales del juego a su
tamaño real, en español, para comprobar que caben.

Uso:  python3 siete-vidas/herramientas/interfaz_v2_layout.py
Sale: siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/layout-*.png
Documento: siete-vidas/diseno/interfaz-v2.md («Layout y legibilidad multiplataforma»)
"""
from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFont

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
SALIDA = os.path.join(RAIZ, "diseno", "revisiones", "capturas", "interfaz-rediseno")
FUENTES = os.path.join(RAIZ, "juego", "fuentes")

W, H = 640, 360
# Zona segura de títulos (90 %: 5 % por lado) y de acción (95 %), en px de la base.
SEGURA = (32, 18, 608, 342)
ACCION = (16, 9, 624, 351)
PISO = 300


def fuente(nombre, tam):
    return ImageFont.truetype(os.path.join(FUENTES, nombre), tam)


# Letras del juego. Normal = tamaño de diseño; grande = x2 (200 %, XAG 101).
LETRAS = {
    1: {"texto": fuente("PixelOperator.ttf", 16), "nombre": fuente("PixelOperator-Bold.ttf", 16),
        "cartel": fuente("Silkscreen-Regular.ttf", 16), "linea": 17},
    2: {"texto": fuente("PixelOperator.ttf", 32), "nombre": fuente("PixelOperator-Bold.ttf", 32),
        "cartel": fuente("Silkscreen-Regular.ttf", 32), "linea": 34},
}
NOTA = fuente("PixelOperator8.ttf", 8)   # solo para las notas del wireframe (no es texto del juego)

C = {
    "fondo": (214, 214, 210, 255), "rejilla": (205, 205, 201, 255), "rejilla32": (192, 192, 188, 255),
    "pared": (226, 224, 218, 255), "piso": (188, 186, 180, 255), "escena": (150, 150, 146, 255),
    "escena_txt": (110, 110, 106, 255),
    "ui": (70, 70, 74, 255), "ui2": (100, 100, 106, 255), "ui_borde": (25, 25, 28, 255), "ui_txt": (250, 250, 250, 255),
    "ui_apagado": (175, 175, 180, 255), "acento": (130, 130, 136, 255),
    "segura": (214, 40, 40, 255), "accion": (235, 140, 20, 255), "nota": (25, 80, 200, 255), "nota_fondo": (255, 255, 255, 230),
}


def ancho(t, f):
    return int(f.getlength(t))


def partir(t, f, w):
    """Parte un texto en líneas que caben en w px."""
    palabras = t.split(" ")
    lineas, actual = [], ""
    for p in palabras:
        prueba = (actual + " " + p).strip()
        if ancho(prueba, f) <= w:
            actual = prueba
        else:
            lineas.append(actual)
            actual = p
    if actual:
        lineas.append(actual)
    return lineas


class Lienzo:
    def __init__(self, titulo, g):
        self.g = g
        self.img = Image.new("RGBA", (W, H), C["fondo"])
        self.d = ImageDraw.Draw(self.img)
        self.d.fontmode = "1"
        self.L = LETRAS[g]
        self.titulo = titulo
        self._escena_base()

    # --- fondo ---------------------------------------------------------------------------------------------------
    def _escena_base(self):
        d = self.d
        d.rectangle([0, 0, W, PISO], fill=C["pared"])
        d.rectangle([0, PISO, W, H], fill=C["piso"])
        for x in range(0, W, 8):
            d.line([(x, 0), (x, H)], fill=C["rejilla32"] if x % 32 == 0 else C["rejilla"])
        for y in range(0, H, 8):
            d.line([(0, y), (W, y)], fill=C["rejilla32"] if y % 32 == 0 else C["rejilla"])
        d.line([(0, PISO), (W, PISO)], fill=C["escena"])

    def escena(self, x, y, w, h, nombre):
        """Algo del mundo (personaje, mueble): contorno gris con su nombre."""
        self.d.rectangle([x, y, x + w - 1, y + h - 1], outline=C["escena"], fill=(205, 203, 197, 255))
        self.d.line([(x, y), (x + w - 1, y + h - 1)], fill=C["escena"])
        self.d.line([(x + w - 1, y), (x, y + h - 1)], fill=C["escena"])
        self.texto((x + 2, y + 2), nombre, NOTA, C["escena_txt"])

    def zonas_seguras(self):
        self._discontinua(ACCION, C["accion"])
        self._discontinua(SEGURA, C["segura"])

    def _discontinua(self, r, color):
        x0, y0, x1, y1 = r
        for x in range(x0, x1, 6):
            self.d.line([(x, y0), (min(x + 3, x1), y0)], fill=color)
            self.d.line([(x, y1), (min(x + 3, x1), y1)], fill=color)
        for y in range(y0, y1, 6):
            self.d.line([(x0, y), (x0, min(y + 3, y1))], fill=color)
            self.d.line([(x1, y), (x1, min(y + 3, y1))], fill=color)

    # --- UI ------------------------------------------------------------------------------------------------------
    def caja(self, x, y, w, h, color=None, medida=True, donde_medida="arriba"):
        self.d.rectangle([x, y, x + w - 1, y + h - 1], fill=color or C["ui"], outline=C["ui_borde"])
        if medida:
            self.medida(x, y, w, h, donde_medida)
        return (x, y, w, h)

    def medida(self, x, y, w, h, donde="arriba"):
        t = f"{w}x{h}"
        tw = ancho(t, NOTA) + 4
        if donde == "arriba":
            px, py = x + w - tw, y - 9
        elif donde == "abajo":
            px, py = x + w - tw, y + h + 1
        else:  # dentro, abajo a la derecha
            px, py = x + w - tw - 1, y + h - 10
        self.chip((px, py), t)

    def chip(self, xy, t, color=None):
        x, y = xy
        self.d.rectangle([x, y, x + ancho(t, NOTA) + 3, y + 8], fill=C["nota_fondo"])
        self.texto((x + 2, y), t, NOTA, color or C["nota"])

    def texto(self, xy, t, f, color):
        self.d.text(xy, t, font=f, fill=color)

    # --- piezas de la interfaz -----------------------------------------------------------------------------------
    def huellas(self, llenas=9):
        """Salud: cara de Felipe + 9 huellas, arriba a la izquierda dentro de la zona segura."""
        g = self.g
        lado = 13 * g
        paso = lado + g
        cara = 16 * g
        w = 4 * g + cara + 4 * g + 9 * paso + 2 * g
        h = max(cara, 12 * g) + 4 * g
        x, y = SEGURA[0], SEGURA[1]
        self.caja(x, y, w, h, medida=False)
        self.chip((x + w + 2, y + h - 9), f"{w}x{h}")
        self.d.rectangle([x + 4 * g, y + 2 * g, x + 4 * g + cara - 1, y + 2 * g + cara - 1], fill=C["ui2"])
        for i in range(9):
            hx = x + 8 * g + cara + i * paso
            hy = y + (h - 12 * g) // 2
            self.d.rectangle([hx, hy, hx + lado - 1, hy + 12 * g - 1],
                             fill=C["ui_txt"] if i < llenas else C["ui2"], outline=C["ui_borde"])
        return (x, y, w, h)

    def alto_hud(self):
        return max(16 * self.g, 12 * self.g) + 4 * self.g

    def dialogo(self, quien, t, abajo=False):
        """Diálogo: retrato a la izquierda que se sale, franja del nombre y caja de 2 líneas (paginado si no cabe)."""
        g, L = self.g, self.L
        x0, x1 = SEGURA[0], SEGURA[2]
        retrato = 52
        pad = 8
        franja_h = 9 * g + 6 if g == 1 else 26
        caja_h = pad * 2 + 2 * L["linea"]
        y_franja = SEGURA[1] + self.alto_hud() + 6
        y_caja = y_franja + franja_h // 2 + 2
        if abajo:
            y_caja = SEGURA[3] - caja_h
            y_franja = y_caja - franja_h // 2 - 2
        bx = x0 + 48
        bw = x1 - bx
        self.caja(bx, y_caja, bw, caja_h, donde_medida="abajo")
        # retrato que se sale por arriba
        ry = y_caja + caja_h - retrato
        self.d.rectangle([x0, ry - 8, x0 + retrato - 1, y_caja + caja_h - 1], fill=C["acento"], outline=C["ui_borde"])
        self.texto((x0 + 4, ry - 6), "retrato", NOTA, C["ui_txt"])
        self.texto((x0 + 4, ry + 2), "52 px", NOTA, C["ui_txt"])
        # franja del nombre
        nombre = quien.upper()
        nw = ancho(nombre, L["nombre"]) + 16
        self.d.rectangle([bx + 10, y_franja, bx + 10 + nw - 1, y_franja + franja_h - 1], fill=C["ui2"], outline=C["ui_borde"])
        self.texto((bx + 18, y_franja + (franja_h - 11 * g) // 2 - 4 * g + 1), nombre, L["nombre"], C["ui_txt"])
        # texto
        tx = bx + 14
        tw = bw - 14 - 20
        lineas = partir(t, L["texto"], tw)
        paginas = (len(lineas) + 1) // 2
        for i, l in enumerate(lineas[:2]):
            self.texto((tx, y_caja + pad - 3 * g + i * L["linea"]), l, L["texto"], C["ui_txt"])
        # flecha / página
        fx, fy = bx + bw - 14, y_caja + caja_h - 12
        self.d.polygon([(fx, fy), (fx + 6, fy + 4), (fx, fy + 8)], fill=C["ui_txt"])
        if paginas > 1:
            self.chip((bx + bw - 60, y_caja + caja_h + 1), f"página 1 de {paginas}", C["segura"])
        return (bx, y_caja, bw, caja_h, lineas)

    def barra_jefe(self, nombre="A.S.P.I."):
        g, L = self.g, self.L
        w = 250
        x = SEGURA[2] - w
        y = SEGURA[1]
        franja_h = 13 if g == 1 else 26
        alto = franja_h + 4 + 10 + 3 + 10 * g
        self.d.rectangle([x, y, x + 25, y + 25], fill=C["acento"], outline=C["ui_borde"])
        self.texto((x + 2, y + 2), "retr.", NOTA, C["ui_txt"])
        nw = ancho(nombre, L["nombre"]) + 14
        self.d.rectangle([x + 28, y, x + 28 + nw - 1, y + franja_h - 1], fill=C["ui2"], outline=C["ui_borde"])
        self.texto((x + 35, y + (franja_h - 11 * g) // 2 - 4 * g + 1), nombre, L["nombre"], C["ui_txt"])
        by = y + franja_h + 4
        self.d.rectangle([x + 28, by, x + w - 1, by + 9], fill=C["ui"], outline=C["ui_borde"])
        iw = w - 32
        self.d.rectangle([x + 30, by + 2, x + 30 + int(iw * 0.68), by + 7], fill=C["ui_apagado"])
        self.d.rectangle([x + 30, by + 2, x + 30 + int(iw * 0.55), by + 7], fill=C["ui_txt"])
        for i, m in enumerate(("I", "II", "III")):
            sx = x + 30 + int(iw * (i + 1) / 3)
            if i < 2:
                self.d.line([(sx, by), (sx, by + 9)], fill=C["ui_borde"], width=2)
            mx = x + 30 + int(iw * (i + 0.5) / 3) - ancho(m, L["cartel"]) // 2
            self.texto((mx, by + 11 - 3 * g), m, L["cartel"], C["ui"] if i != 1 else C["ui_borde"])
        self.medida(x, y, w, alto, "abajo")
        return (x, y, w, alto)

    def cartel(self, titulo, sub=None, y=None):
        g, L = self.g, self.L
        tw = ancho(titulo, L["cartel"]) + 24 * g
        h = 12 * g + 10
        x = (W - tw) // 2
        y = y if y is not None else SEGURA[1] + self.alto_hud() + 6
        self.caja(x, y, tw, h)
        self.texto((x + 12 * g, y + 5 - 3 * g), titulo, L["cartel"], C["ui_txt"])
        if sub:
            sw = ancho(sub, L["texto"]) + 20
            sh = 11 * g + 8
            sx = (W - sw) // 2
            self.caja(sx, y + h + 2, sw, sh, color=C["ui2"], donde_medida="abajo")
            self.texto((sx + 10, y + h + 2 + 4 - 4 * g), sub, L["texto"], C["ui_txt"])
            return (min(x, sx), y, max(tw, sw), h + 2 + sh)
        return (x, y, tw, h)

    def logro(self, t, y=None):
        g, L = self.g, self.L
        icono = 16 * g
        w = 8 + icono + 8 + ancho(t, L["texto"]) + 12
        h = max(icono, 11 * g) + 8
        x = SEGURA[2] - w
        y = y if y is not None else SEGURA[1] + self.alto_hud() + 6
        self.caja(x, y, w, h, donde_medida="abajo")
        self.d.rectangle([x + 8, y + 4, x + 8 + icono - 1, y + 4 + icono - 1], fill=C["acento"])
        self.texto((x + 16 + icono, y + (h - 11 * g) // 2 - 4 * g + 1), t, L["texto"], C["ui_txt"])
        return (x, y, w, h)

    def globito(self, cx, y_base, t):
        g, L = self.g, self.L
        w = ancho(t, L["texto"]) + 16
        h = 11 * g + 8
        x = max(SEGURA[0], min(cx - w // 2, SEGURA[2] - w))
        y = y_base - h - 6
        self.caja(x, y, w, h, donde_medida="arriba")
        self.d.polygon([(cx - 3, y + h - 1), (cx + 3, y + h - 1), (cx, y + h + 5)], fill=C["ui"], outline=C["ui_borde"])
        self.texto((x + 8, y + 4 - 4 * g), t, L["texto"], C["ui_txt"])
        return (x, y, w, h)

    def indicador(self, cx, y_base, boton, verbo):
        g, L = self.g, self.L
        glifo = 16 * g
        w = 6 + glifo + 6 + ancho(verbo, L["texto"]) + 8
        h = glifo + 6
        x = max(SEGURA[0], min(cx - w // 2, SEGURA[2] - w))
        y = y_base - h - 6
        self.caja(x, y, w, h)
        self.d.ellipse([x + 6, y + 3, x + 6 + glifo - 1, y + 3 + glifo - 1], fill=C["ui_txt"])
        self.texto((x + 6 + glifo // 2 - ancho(boton, L["nombre"]) // 2, y + 3 + (glifo - 11 * g) // 2 - 4 * g + 1),
                   boton, L["nombre"], C["ui_borde"])
        self.texto((x + 12 + glifo, y + 3 + (glifo - 11 * g) // 2 - 4 * g + 1), verbo, L["texto"], C["ui_txt"])
        self.d.polygon([(cx - 3, y + h - 1), (cx + 3, y + h - 1), (cx, y + h + 4)], fill=C["ui"], outline=C["ui_borde"])
        return (x, y, w, h)

    # --- salida --------------------------------------------------------------------------------------------------
    def terminar(self, nombre):
        self.zonas_seguras()
        g = self.g
        etiqueta = f"{self.titulo} · texto {'GRANDE (200 %)' if g == 2 else 'normal (100 %)'}"
        self.d.rectangle([0, 0, ancho(etiqueta, NOTA) + 6, 9], fill=(30, 30, 34, 255))
        self.texto((3, 1), etiqueta, NOTA, (255, 255, 255, 255))
        # leyenda de las zonas, abajo a la izquierda (dentro de la franja de acción)
        ley = "rojo: zona segura de títulos 90 % (32 / 18 px) · naranja: acción 95 % (16 / 9 px) · rejilla 8 / 32 px"
        self.d.rectangle([0, H - 9, ancho(ley, NOTA) + 6, H], fill=(30, 30, 34, 255))
        self.texto((3, H - 8), ley, NOTA, (255, 255, 255, 255))
        sufijo = "-grande" if g == 2 else ""
        ruta = os.path.join(SALIDA, f"layout-{nombre}{sufijo}.png")
        self.img.save(ruta)
        self.img.resize((W * 2, H * 2), Image.NEAREST).save(ruta.replace(".png", "-x2.png"))
        return ruta


# -------------------------------------------------------------------------------------------------------------------
# Pantallas
# -------------------------------------------------------------------------------------------------------------------
DIALOGO_VALERIA = ("¿Quién dejó abierta la puerta del balcón? Felipe, si fuiste tú, hoy no hay atún para nadie "
                   "y tampoco hay siesta en mi cama.")
DIALOGO_FELIPE = "Su Majestad no rompió nada. El vaso decidió saltar solo. Arte."


def felipe(l, x=300):
    l.escena(x, PISO - 58, 48, 58, "Felipe")


def exploracion(g):
    l = Lienzo("1 · Exploración: solo la salud", g)
    l.escena(380, PISO - 200, 70, 200, "Valeria")
    l.escena(200, PISO - 45, 150, 45, "sofá")
    felipe(l, 120)
    hx, hy, hw, hh = l.huellas(6)
    l.chip((hx, hy + hh + 11), "salud: 9 huellas, siempre", C["nota"])
    l.chip((330, 30), "nada más fijo: lo demás aparece al cambiar y se va", C["nota"])
    return l.terminar("01-exploracion")


def dialogo_valeria(g):
    l = Lienzo("2 · Diálogo de Valeria (texto largo)", g)
    l.escena(380, PISO - 200, 70, 200, "Valeria")
    l.escena(200, PISO - 45, 150, 45, "sofá")
    felipe(l, 120)
    l.huellas(6)
    bx, by, bw, bh, lineas = l.dialogo("valeria", DIALOGO_VALERIA)
    l.chip((bx, by + bh + 11), f"{len(DIALOGO_VALERIA)} letras -> {len(lineas)} líneas de {('~74' if g == 1 else '~37')} letras",
           C["nota"])
    return l.terminar("02-dialogo-valeria")


def dialogo_felipe(g):
    l = Lienzo("3 · Diálogo de Felipe (abajo: Felipe está arriba)", g)
    l.escena(60, 130, 160, 20, "repisa alta")
    l.escena(120, 130 - 58, 48, 58, "Felipe")
    l.escena(420, PISO - 200, 70, 200, "Valeria")
    l.huellas(6)
    bx, by, bw, bh, lineas = l.dialogo("felipe", DIALOGO_FELIPE, abajo=True)
    l.chip((bx, by - 22), "si la cabeza de Felipe cae en la zona de arriba, el cuadro baja", C["nota"])
    return l.terminar("03-dialogo-felipe")


def pelea(g):
    l = Lienzo("4 · Pelea con jefe: salud, barra, aviso y globito", g)
    l.escena(380, PISO - 30, 76, 30, "A.S.P.I.")
    felipe(l, 180)
    l.huellas(5)
    l.barra_jefe()
    # aviso en el mundo, sobre el jefe (lección 46)
    av = l.globito(418, PISO - 36, "¡LLENA! ¡SALTA!")
    l.chip((av[0], av[1] - 20), "aviso: sobre el jefe, 1 línea", C["nota"])
    gl = l.globito(204, PISO - 62, "¿Eso es todo?")
    l.chip((gl[0], gl[1] - 20), "globito: sobre Felipe", C["nota"])
    l.chip((240, 110), "snacks: solo en la pausa (bolsillo)", C["segura"])
    return l.terminar("04-pelea")


def carteles(g):
    l = Lienzo("5 · Carteles y logros (de a uno, cola única)", g)
    l.escena(380, PISO - 200, 70, 200, "Valeria")
    felipe(l, 200)
    l.huellas(6)
    cx, cy, cw, ch = l.cartel("¡TRAVESURA CUMPLIDA!", "Robar el almuerzo de Valeria")
    l.chip((cx, cy + ch + 11), "cartel: centrado bajo el HUD", C["nota"])
    ly = cy + ch + 26 + (10 if g == 2 else 0)
    lx, lyy, lw, lh = l.logro("Coleccionista de Calcetines", y=ly)
    l.chip((lx, lyy + lh + 11), "logro: a la derecha, entra de lado (espera su turno)", C["nota"])
    fy = lyy + lh + 30
    l.cartel("FASE II · PERSECUCIÓN", y=fy)
    l.chip((SEGURA[0], fy + 14 * g + 12), "fase del jefe: misma franja; corta la frase", C["nota"])
    l.chip((SEGURA[0], SEGURA[3] - 22), "juntos solo para medir: en el juego salen de a uno, bajo el HUD", C["segura"])
    return l.terminar("05-carteles-logros")


def indicador(g):
    l = Lienzo("6 · Indicador de botón sobre un objeto", g)
    l.escena(330, PISO - 60, 90, 60, "mesa")
    l.escena(360, PISO - 60 - 24, 26, 24, "plato")
    felipe(l, 250)
    l.huellas(6)
    ix, iy, iw, ih = l.indicador(373, PISO - 60 - 24, "A", "Degustar")
    l.chip((ix, iy - 20), "ícono del mando en uso + verbo", C["nota"])
    # muestra de íconos por mando: el mismo indicador, con el ícono del mando que se está usando
    y = SEGURA[1] + l.alto_hud() + 30
    for boton, mando in (("A", "Switch"), ("X", "PlayStation"), ("A", "Xbox"), ("E", "Teclado")):
        w = 6 + 16 * l.g + 6 + ancho(mando, l.L["texto"]) + 8
        caja = l.indicador(SEGURA[0] + w // 2, y + 16 * l.g + 6 + 6, boton, mando)
        y = caja[1] + caja[3] + 14
    return l.terminar("06-indicador-boton")


def pausa(g):
    l = Lienzo("7 · Pausa: bolsillo, ficha y opciones", g)
    L = l.L
    x0, y0, x1, y1 = SEGURA
    l.caja(x0, y0, x1 - x0, y1 - y0, color=(60, 60, 64, 255), donde_medida="dentro")
    # columna del menú
    mw = 150 if g == 1 else 246
    l.caja(x0 + 8, y0 + 8, mw, y1 - y0 - 16, color=C["ui"], donde_medida="dentro")
    y = y0 + 16
    for i, op in enumerate(("Continuar", "Bolsillo", "Ficha", "Opciones", "Reiniciar", "Salir")):
        if i == 1:
            l.d.rectangle([x0 + 12, y - 2, x0 + 8 + mw - 5, y + 11 * g + 4], fill=C["ui_apagado"])
        l.texto((x0 + 18, y - 4 * g + 1), op, L["texto"], C["ui_borde"] if i == 1 else C["ui_txt"])
        y += 11 * g + 12
    # contenido
    cx = x0 + 8 + mw + 8
    cw = x1 - 8 - cx
    l.caja(cx, y0 + 8, cw, 26 * g, color=C["ui2"], medida=False)
    l.texto((cx + 8, y0 + 8 + 4 - 3 * g + (3 if g == 2 else 0)), "BOLSILLO", L["cartel"], C["ui_txt"])
    filas = [("Salud", "9 huellas"), ("Snacks", "3 de 5"), ("Calcetines", "4"), ("Fotos", "2 de 6")]
    fh = 11 * g + 14
    yy = y0 + 8 + 26 * g + 8
    for n, v in filas:
        l.caja(cx, yy, cw, fh, color=C["ui"], medida=False)
        l.d.rectangle([cx + 6, yy + 4, cx + 6 + 16 * g - 1, yy + 4 + 16 * g - 1 if g == 2 else yy + fh - 5], fill=C["acento"])
        l.texto((cx + 12 + 16 * g, yy + (fh - 11 * g) // 2 - 4 * g + 1), n, L["texto"], C["ui_txt"])
        l.texto((cx + cw - 10 - ancho(v, L["nombre"]), yy + (fh - 11 * g) // 2 - 4 * g + 1), v, L["nombre"], C["ui_txt"])
        yy += fh + 4
    if g == 1:
        # ficha resumida abajo
        l.caja(cx, yy + 4, cw, y1 - 8 - yy - 4, color=C["ui"], donde_medida="dentro")
        l.d.rectangle([cx + 6, yy + 10, cx + 6 + 52 - 1, yy + 10 + 52 - 1], fill=C["acento"])
        l.texto((cx + 64, yy + 8), "SU MAJESTAD · 8,2 kg", L["nombre"], C["ui_txt"])
        for i, (n, f) in enumerate((("Carisma", "Irresistible."), ("Defensa", "Muy mullido."), ("Ataque", "Con desdén."))):
            l.texto((cx + 64, yy + 26 + i * 17), f"{n}: {f}", L["texto"], C["ui_apagado"])
    else:
        l.chip((cx, y1 - 30), "grande: bolsillo y ficha en pestañas", C["segura"])
    l.chip((x0 + 8, y1 + 1), "panel = zona segura entera (576x324)", C["nota"])
    return l.terminar("07-pausa")


def opciones(g):
    l = Lienzo("8 · Opciones de accesibilidad", g)
    L = l.L
    x0, y0, x1, y1 = SEGURA
    l.caja(x0, y0, x1 - x0, y1 - y0, color=(60, 60, 64, 255), donde_medida="dentro")
    l.texto((x0 + 10, y0 + 6 - 3 * g + (2 if g == 2 else 0)), "ACCESIBILIDAD", L["cartel"], C["ui_txt"])
    filas = [("Tamaño del texto", "Grande" if g == 2 else "Normal"), ("Velocidad del texto", "Normal"),
             ("Avance del diálogo", "Con botón"), ("Sacudida de pantalla", "Reducida"), ("Reducir movimiento", "No"),
             ("Contraste alto", "No"), ("Zona segura", "90 %"), ("Íconos de botones", "Automático")]
    fh = 11 * g + 12
    y = y0 + 12 * g + 16
    disponibles = (y1 - 50 * g - y) // (fh + 3)
    for i, (n, v) in enumerate(filas[:disponibles]):
        l.caja(x0 + 8, y, x1 - x0 - 24, fh, color=C["ui"] if i else C["ui_apagado"], medida=False)
        col = C["ui_borde"] if i == 0 else C["ui_txt"]
        l.texto((x0 + 16, y + (fh - 11 * g) // 2 - 4 * g + 1), n, L["texto"], col)
        vt = f"< {v} >"
        l.texto((x1 - 24 - ancho(vt, L["nombre"]), y + (fh - 11 * g) // 2 - 4 * g + 1), vt, L["nombre"], col)
        y += fh + 3
    # barra de desplazamiento si no caben todas (un solo eje, XAG 101)
    if disponibles < len(filas):
        top = y0 + 12 * g + 16
        l.d.rectangle([x1 - 12, top, x1 - 8, y - 3], fill=C["ui2"])
        l.d.rectangle([x1 - 12, top, x1 - 8, top + (y - top) * disponibles // len(filas)], fill=C["ui_txt"])
        l.chip((x0 + 8, y), f"{len(filas) - disponibles} filas más: desplazar en un solo eje", C["segura"])
    # vista previa del texto
    py = y1 - 50 * g + 6
    l.caja(x0 + 8, py, x1 - x0 - 16, y1 - 8 - py, color=C["ui2"], donde_medida="dentro")
    l.texto((x0 + 16, py + 4 - 3 * g), "Así se verá: ¿Quién dejó abierta la puerta?", L["texto"], C["ui_txt"])
    return l.terminar("08-opciones")


def reglas():
    """Lámina de referencia: escalas, zona segura y letras medidas (cuerpo = del ascendente más alto al
    descendente más bajo, como mide XAG 101)."""
    img = Image.new("RGBA", (W, H), (245, 245, 242, 255))
    d = ImageDraw.Draw(img)
    d.fontmode = "1"
    t8 = NOTA
    t16 = LETRAS[1]["texto"]
    b16 = LETRAS[1]["nombre"]
    d.text((8, 4), "Letras del juego a tamaño real (base 640x360) y si cumplen", font=b16, fill=(20, 20, 20, 255))
    filas = [
        ("Operator 16", fuente("PixelOperator.ttf", 16), 16, "11", "33", "22", "sí"),
        ("Operator Bold 16", fuente("PixelOperator-Bold.ttf", 16), 16, "11", "33", "22", "sí"),
        ("Silkscreen 16", fuente("Silkscreen-Regular.ttf", 16), 18, "10", "30", "20", "sí"),
        ("Operator 8", fuente("PixelOperator8.ttf", 8), 10, "8", "24", "16", "NO en TV"),
        ("Silkscreen 8", fuente("Silkscreen-Regular.ttf", 8), 10, "5", "15", "10", "NO"),
        ("Operator 32 (grande)", fuente("PixelOperator.ttf", 32), 34, "22", "66", "44", "sí"),
    ]
    y = 26
    cab = ["letra", "muestra", "cuerpo", "1080p", "720p", "¿cumple?"]
    xs = [8, 120, 400, 448, 500, 552]
    for x, c in zip(xs, cab):
        d.text((x, y), c, font=t8, fill=(90, 90, 90, 255))
    y += 12
    for nombre, f, alto, cuerpo, tv, mano, ok in filas:
        d.line([(8, y - 2), (632, y - 2)], fill=(215, 215, 210, 255))
        d.text((8, y + 2), nombre, font=t8, fill=(20, 20, 20, 255))
        d.text((120, y), "¿Qué fue? ÁÑ gjpq", font=f, fill=(20, 20, 20, 255))
        for x, v in zip(xs[2:5], (cuerpo, tv, mano)):
            d.text((x, y + 2), v + " px", font=t8, fill=(20, 20, 20, 255))
        d.text((xs[5], y + 2), ok, font=t8, fill=(20, 140, 40, 255) if ok == "sí" else (200, 30, 30, 255))
        y += alto + 6
    y += 6
    lineas = [
        "Cuerpo = del ascendente más alto al descendente más bajo, como mide XAG 101.",
        "Mínimos: consola 1080p 26 px de cuerpo (XAG 101) = 9 px de la base. PC 1080p 18 px = 6 px.",
        "Portátil 720p: mínimo 9 px, recomendado 12 px a 30 cm (Xbox Handheld) = 4,5 / 6 px de la base.",
        "IGDA GASIG: 32 px @1080p (11 px base) y 46 px (15 px base) si el texto se va solo.",
        "Regla del juego: texto esencial con cuerpo de 11 px o más (Pixel Operator 16 / Silkscreen 16).",
        "Escalas enteras: x2 = 1280x720 (Switch portátil), x3 = 1920x1080 (TV, PC, PS4),",
        "x4 = 2560x1440, x6 = 3840x2160 (PS5 4K). Steam Deck 1280x800: x2 con franjas.",
        "Zona segura de títulos 90 %: 32 px a los lados y 18 arriba y abajo (Xbox: 96 / 40 px a 1080p).",
        "Contraste: 4,5:1 texto, 3:1 texto grande e íconos, 7:1 en contraste alto (XAG 102).",
    ]
    for l in lineas:
        d.text((8, y), l, font=t8, fill=(20, 20, 20, 255))
        y += 11
    ruta = os.path.join(SALIDA, "layout-00-reglas.png")
    img.save(ruta)
    img.resize((W * 2, H * 2), Image.NEAREST).save(ruta.replace(".png", "-x2.png"))
    return ruta


def main():
    rutas = [reglas()]
    for g in (1, 2):
        for f in (exploracion, dialogo_valeria, dialogo_felipe, pelea, carteles, indicador, pausa, opciones):
            rutas.append(f(g))
    for r in rutas:
        print(r)


if __name__ == "__main__":
    main()
