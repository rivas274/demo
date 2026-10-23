#!/usr/bin/env python3
"""Kit de interfaz v2 (A + C): piezas con forma propia sacadas de las hojas de IA, con variantes y medida objetiva.

Piezas: huella (13x12), pescadito de snack (12x7 de relleno, 14x9 con contorno), orejita del globito (11x8),
cola del globito con huellita (cabe en 14x14) y la huella del sello en rombo (11x10 de relleno).

Método (el estándar de pasar arte de IA a pixel exacto):
  1. Recorte de cada pieza en cada hoja (5 hojas: ChatGPT 1 y Gemini 1-4).
  2. Silueta: todo lo que no se alcanza desde el borde del recorte pasando por el fondo blanco.
     Relleno: la silueta menos el contorno oscuro que toca el exterior.
  3. Reducción al tamaño del juego por tres métodos: «mayoría» (la clase que más área ocupa en cada celda; el
     vacío gana desde el 50 %), «huecos» (igual, pero el vacío gana desde el 30 %: guarda los huecos entre dedos)
     y «centro» (la muestra del centro de la celda, el vecino más próximo).
  4. Limpieza automática: fuera los píxeles sueltos (0-1 vecinos), se tapan los agujeros de 1 px y el contorno de
     1 px se vuelve a trazar alrededor del relleno. Colores: solo la paleta A + C.
  5. Medida objetiva (0 a 1) y lámina de comparación a x1 sobre el fondo real y a x6.

Uso:  python3 siete-vidas/herramientas/interfaz_v2_kit_ia.py
Sale: diseno/revisiones/capturas/interfaz-rediseno/kit-v2-variantes.png (y la tabla de puntajes en la consola).
La versión final de cada pieza (la ganadora, retocada a mano) está escrita como rejilla en interfaz_v2_kit.py.
"""
from __future__ import annotations

import os

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

import interfaz_v2_laminas as k

RAIZ = k.RAIZ
REF = os.path.join(RAIZ, "arte", "referencias")
HOJAS = {
    "chatgpt-1": os.path.join(REF, "chatgpt", "interfaz-v2", "intento-1.png"),
    "gemini-1": os.path.join(REF, "gemini", "interfaz-v2", "intento-1.png"),
    "gemini-2": os.path.join(REF, "gemini", "interfaz-v2", "intento-2.png"),
    "gemini-3": os.path.join(REF, "gemini", "interfaz-v2", "intento-3.png"),
    "gemini-4": os.path.join(REF, "gemini", "interfaz-v2", "intento-4.png"),
}

# Paleta A + C (la base; los tonos de luz y sombra salen de estos en interfaz_v2_kit.py)
PALETA = {"fondo": "#241A26", "panel": "#30242C", "linea": "#F4E2BB", "texto": "#FFF0D5", "apagado": "#8A7480",
          "contorno": "#120C12", "felipe": "#E8913A", "oportunidad": "#FFE066", "valeria": "#D8336B",
          "aspi": "#E04848", "maquina": "#4CC9E0"}
PAL_RGB = np.array([k.hexa(c)[:3] for c in PALETA.values()], dtype=float)

# Recortes (x0, y0, x1, y1) en cada hoja, con la transformación que deja la pieza en la orientación del juego.
# Huella: la «llena» de cada hoja (en Gemini 2 la llena es negra sin contorno: se usa la de «golpe», blanca con contorno).
RECORTES = {
    "huella": [("chatgpt-1", (1069, 135, 1130, 193), None), ("gemini-1", (628, 269, 703, 342), None),
               ("gemini-2", (256, 289, 318, 347), None), ("gemini-3", (563, 270, 626, 329), None),
               ("gemini-4", (29, 266, 102, 333), None)],
    "snack": [("chatgpt-1", (829, 705, 927, 766), None), ("gemini-1", (632, 851, 684, 881), None),
              ("gemini-2", (622, 715, 685, 753), None), ("gemini-3", (1296, 542, 1368, 584), None),
              ("gemini-4", (618, 730, 690, 770), None)],
    # Orejitas: la izquierda y la derecha de cada hoja (la derecha se refleja para compararlas igual).
    "oreja": [("chatgpt-1", (810, 297, 870, 340), None), ("chatgpt-1", (1147, 305, 1195, 340), "espejo"),
              ("gemini-1", (692, 455, 722, 480), None), ("gemini-1", (815, 455, 845, 480), "espejo"),
              ("gemini-2", (445, 277, 467, 306), None), ("gemini-2", (545, 277, 575, 306), "espejo"),
              ("gemini-3", (35, 622, 70, 657), None), ("gemini-3", (212, 622, 250, 657), "espejo"),
              ("gemini-4", (627, 370, 663, 400), None), ("gemini-4", (862, 369, 905, 400), "espejo")],
    # Cola: sale del borde de abajo del globito y baja hacia Felipe; las que la IA dibujó saliendo de lado se giran.
    "cola": [("chatgpt-1", (1190, 337, 1295, 427), "girar"), ("gemini-1", (876, 468, 994, 511), "girar"),
             ("gemini-2", (518, 348, 601, 386), None), ("gemini-3", (281, 668, 373, 722), "girar"),
             ("gemini-4", (967, 382, 1061, 456), "girar")],
    # Sello: la huella dentro del rombo (el rombo se traza exacto: es geometría).
    "sello": [("chatgpt-1", (1145, 485, 1247, 590), None), ("chatgpt-1", (27, 870, 137, 978), None),
              ("gemini-1", (1051, 495, 1155, 601), None), ("gemini-2", (1029, 365, 1120, 458), None),
              ("gemini-3", (1243, 24, 1385, 168), None), ("gemini-4", (426, 531, 586, 690), None)],
}

# Tamaño del relleno (sin contorno) o de la pieza entera, por pieza
TAM = {"huella": (11, 10), "snack": (12, 7), "oreja": (11, 8), "cola": (14, 14), "sello": (11, 10)}

# Forma aprobada en la lámina (direccion-arte-AC-v2.png), para medir el apego a la lámina
APROBADA = {
    "huella": np.array([[c == "X" for c in f] for f in k.HUELLA]),
    "sello": np.array([[c == "X" for c in f] for f in k.HUELLA]),
    "snack": np.array([[c in "XO" for c in f] for f in k.SNACK]),
}


def _oreja_lamina() -> np.ndarray:
    im = Image.new("L", (12, 9), 0)
    ImageDraw.Draw(im).polygon([(0, 8), (5, 0), (11, 8)], fill=1)
    return np.asarray(im.resize((11, 8), Image.NEAREST)).astype(bool)


APROBADA["oreja"] = _oreja_lamina()


# -------------------------------------------------------------------------------------------------------------------
# Silueta, relleno y clases
# -------------------------------------------------------------------------------------------------------------------
def cargar(hoja, caja, trans):
    a = np.asarray(Image.open(HOJAS[hoja]).convert("RGB").crop(caja)).astype(int)
    if trans == "espejo":
        a = a[:, ::-1]
    elif trans == "girar":     # 90° a la derecha: lo que salía por la izquierda sale por arriba
        a = np.rot90(a, k=-1)
    return a


def separar(a):
    """Devuelve (silueta, relleno, oscuro, acento) como máscaras."""
    mn, mx = a.min(axis=2), a.max(axis=2)
    claro = (mn > 200) & (mx - mn < 45)
    lab, _ = ndimage.label(claro)
    borde = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    fuera = np.isin(lab, list(borde))
    sil = ~fuera
    sil = ndimage.binary_opening(sil, iterations=1) | (sil & ~ndimage.binary_erosion(sil))
    lum = 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]
    oscuro = sil & (lum < 62)
    # el contorno es lo oscuro conectado con el exterior
    toca = oscuro & ndimage.binary_dilation(fuera, iterations=2)
    lab_o, _ = ndimage.label(oscuro, structure=np.ones((3, 3)))
    ids = set(np.unique(lab_o[toca])) - {0}
    contorno = np.isin(lab_o, list(ids))
    relleno = sil & ~contorno
    sat = (mx - mn) / np.maximum(mx, 1)
    acento = sil & (sat > 0.38) & (mx > 120)
    return sil, relleno, oscuro, acento


def quitar_motas(m, minimo):
    lab, n = ndimage.label(m)
    if n == 0:
        return m
    tam = ndimage.sum(m, lab, range(1, n + 1))
    return np.isin(lab, [i + 1 for i, t in enumerate(tam) if t >= minimo])


def caja_de(m):
    ys, xs = np.where(m)
    return ys.min(), ys.max() + 1, xs.min(), xs.max() + 1


def reducir(clases, w, h, metodo):
    """clases: matriz de enteros (0 = vacío). Reduce a w x h por mayoría o por el centro de cada celda."""
    H, W = clases.shape
    out = np.zeros((h, w), dtype=int)
    for j in range(h):
        for i in range(w):
            y0, y1 = int(round(j * H / h)), max(int(round((j + 1) * H / h)), int(round(j * H / h)) + 1)
            x0, x1 = int(round(i * W / w)), max(int(round((i + 1) * W / w)), int(round(i * W / w)) + 1)
            if metodo == "centro":
                out[j, i] = clases[min(H - 1, int((j + 0.5) * H / h)), min(W - 1, int((i + 0.5) * W / w))]
            else:
                celda = clases[y0:y1, x0:x1].ravel()
                cuenta = np.bincount(celda, minlength=4)
                # el vacío gana si ocupa la mitad o más («mayoria») o desde el 30 % («huecos»: guarda los
                # huecos entre dedos y la separación de las piezas finas)
                if cuenta[0] >= celda.size * (0.3 if metodo == "huecos" else 0.5):
                    out[j, i] = 0
                else:
                    cuenta[0] = 0
                    out[j, i] = int(cuenta.argmax())
    return out


def limpiar(m):
    """Fuera píxeles sueltos (0-1 vecinos) y se tapan agujeros de 1 px. Devuelve (máscara, cambios)."""
    m = m.copy()
    cambios = 0
    vec = ndimage.convolve(m.astype(int), np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]]), mode="constant")
    sueltos = m & (vec <= 1)
    cambios += int(sueltos.sum())
    m &= ~sueltos
    vec = ndimage.convolve(m.astype(int), np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]]), mode="constant")
    agujeros = ~m & (vec == 4)
    cambios += int(agujeros.sum())
    m |= agujeros
    return m, cambios


def apego_paleta(a, mascara):
    px = a[mascara].astype(float)
    if len(px) == 0:
        return 0.0
    d = np.sqrt(((px[:, None, :] - PAL_RGB[None, :, :]) ** 2).sum(axis=2)).min(axis=1)
    return float(max(0.0, 1 - d.mean() / 60))


def iou(a, b):
    if a.shape != b.shape:
        b = np.asarray(Image.fromarray(b.astype(np.uint8) * 255).resize((a.shape[1], a.shape[0]), Image.NEAREST)) > 0
    return float((a & b).sum() / max(1, (a | b).sum()))


# -------------------------------------------------------------------------------------------------------------------
# Variantes por pieza: devuelven una rejilla de letras (X relleno, A acento, O detalle oscuro, . vacío) sin contorno
# para huella, snack y sello; con el contorno (C) para oreja y cola.
# -------------------------------------------------------------------------------------------------------------------
def variante(pieza, a, metodo):
    sil, relleno, oscuro, acento = separar(a)
    w, h = TAM[pieza]
    if pieza in ("huella", "sello"):
        if pieza == "sello":
            # la huella es el acento (ámbar) del centro del rombo; el borde ámbar del rombo (ChatGPT) queda fuera
            H, W = acento.shape
            lab, n = ndimage.label(acento)
            centro = np.zeros_like(acento)
            for i in range(1, n + 1):
                cy, cx = ndimage.center_of_mass(lab == i)
                ys, xs = np.where(lab == i)
                if abs(cy - H / 2) < H * 0.22 and abs(cx - W / 2) < W * 0.22 and np.ptp(xs) < W * 0.5:
                    centro |= lab == i
            relleno = centro
        relleno = quitar_motas(relleno, max(4, relleno.sum() // 60))
        y0, y1, x0, x1 = caja_de(relleno)
        m = reducir(relleno[y0:y1, x0:x1].astype(int), w, h, metodo) > 0
        fuente = (relleno, (y0, y1, x0, x1))
        m, cambios = limpiar(m)
        rejilla = np.where(m, "X", ".")
        return rejilla, m, cambios, fuente
    if pieza == "snack":
        sil = quitar_motas(sil, sil.sum() // 20)
        y0, y1, x0, x1 = caja_de(sil)
        cl = np.where(sil, np.where(oscuro & ~ndimage.binary_dilation(~sil, iterations=3), 2, 1), 0)
        r = reducir(cl[y0:y1, x0:x1], w, h, metodo)
        m, cambios = limpiar(r > 0)
        r = np.where(m, np.maximum(r, 1), 0)
        # el detalle oscuro solo vale adentro (no en el borde del relleno) y como mucho 2 px (el ojo)
        borde = m & ~ndimage.binary_erosion(m)
        r[(r == 2) & borde] = 1
        if (r == 2).sum() > 2:
            ys, xs = np.where(r == 2)
            for yy, xx in list(zip(ys, xs))[2:]:
                r[yy, xx] = 1
        rejilla = np.select([r == 2, r == 1], ["O", "X"], ".")
        return rejilla, m, cambios, (sil, (y0, y1, x0, x1))
    # oreja y cola: la silueta entera al tamaño total; el borde es contorno, adentro acento (A) o cuerpo (X)
    sil = quitar_motas(sil, sil.sum() // 15)
    y0, y1, x0, x1 = caja_de(sil)
    if pieza == "cola":   # mantener la proporción dentro de 14x14
        hh, ww = y1 - y0, x1 - x0
        esc = 14 / max(hh, ww)
        w, h = max(6, round(ww * esc)), max(6, round(hh * esc))
    cl = np.where(sil, np.where(acento, 2, 1), 0)
    r = reducir(cl[y0:y1, x0:x1], w, h, metodo)
    m, cambios = limpiar(r > 0)
    r = np.where(m, np.maximum(r, 1), 0)
    borde = m & ~ndimage.binary_erosion(m, border_value=0)
    if pieza == "oreja":
        # la base de la oreja se apoya en el globito: abajo solo llevan contorno las dos puntas
        borde[-1, :] = False
        xs = np.where(m[-1])[0]
        if len(xs):
            borde[-1, xs.min()] = borde[-1, xs.max()] = True
    rejilla = np.select([borde, r == 2, r == 1], ["C", "A", "X"], ".")
    return rejilla, m, cambios, (sil, (y0, y1, x0, x1))


def medir(pieza, a, rejilla, m, cambios, fuente):
    """Puntaje de 0 a 1 y sus partes."""
    sil_f, (y0, y1, x0, x1) = fuente
    pal = apego_paleta(a[y0:y1, x0:x1], sil_f[y0:y1, x0:x1])
    limpieza = max(0.0, 1 - cambios / 6)
    p = {"paleta": pal, "limpieza": limpieza}
    if pieza in ("huella", "sello"):
        n = ndimage.label(m)[1]
        p["partes"] = 1.0 if n == 5 else (0.5 if n in (4, 6) else 0.0)        # se leen almohadilla y 4 dedos
        p["simetria"] = float((m == m[:, ::-1]).mean())
        p["lamina"] = iou(m, APROBADA["huella"])
        total = 0.30 * p["lamina"] + 0.25 * p["partes"] + 0.15 * p["simetria"] + 0.15 * pal + 0.15 * limpieza
    elif pieza == "snack":
        p["partes"] = 1.0 if ndimage.label(m)[1] == 1 else 0.0
        p["ojo"] = 1.0 if (rejilla == "O").any() else 0.0
        p["lamina"] = iou(m, APROBADA["snack"])
        total = 0.30 * p["lamina"] + 0.15 * p["partes"] + 0.15 * p["ojo"] + 0.2 * pal + 0.2 * limpieza
    elif pieza == "oreja":
        acento = rejilla == "A"
        p["acento"] = min(1.0, acento.sum() / 8)                               # se ve el color de adentro
        # el acento es una mancha sólida (sin cuerpo metido adentro, ni cerrado ni abierto abajo): a x1 un anillo
        # o una «V» se ve como ruido. Se mide cuánto del acento «cerrado» (closing 3x3) es acento de verdad.
        cerrado = ndimage.binary_closing(np.pad(acento, 2), structure=np.ones((3, 3)))[2:-2, 2:-2] | acento
        p["solido"] = float(acento.sum() / max(1, cerrado.sum())) if ndimage.label(acento)[1] == 1 else 0.0
        p["lamina"] = iou(m, APROBADA["oreja"])
        total = 0.25 * p["lamina"] + 0.15 * p["acento"] + 0.2 * p["solido"] + 0.2 * pal + 0.2 * limpieza
    else:  # cola
        n_a = (rejilla == "A").sum()
        p["huellita"] = min(1.0, n_a / 6)                                       # la huellita se ve
        p["partes"] = 1.0 if ndimage.label(m)[1] == 1 else 0.0
        vec = ndimage.convolve(m.astype(int), np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]]), mode="constant")
        p["grosor"] = float(1 - ((vec <= 1) & m).sum() / max(1, m.sum()))      # sin hilos de 1 px
        total = 0.25 * p["huellita"] + 0.2 * p["partes"] + 0.15 * p["grosor"] + 0.2 * pal + 0.2 * limpieza
    p["total"] = total
    return p


# -------------------------------------------------------------------------------------------------------------------
# Dibujo de una rejilla con la paleta (igual que el kit final)
# -------------------------------------------------------------------------------------------------------------------
def pintar(pieza, rejilla):
    c = lambda n: k.hexa(PALETA[n])
    felipe = c("felipe")
    luz = k.mezclar(felipe, (255, 255, 255), 0.5)
    osc = k.mezclar(felipe, c("contorno"), 0.35)
    h, w = rejilla.shape
    if pieza in ("huella", "sello", "snack"):
        im = Image.new("RGBA", (w + 2, h + 2), (0, 0, 0, 0))
        px = im.load()
        for y in range(h):
            for x in range(w):
                ch = rejilla[y, x]
                if ch == ".":
                    continue
                arriba = y == 0 or rejilla[y - 1, x] == "."
                abajo = y == h - 1 or rejilla[y + 1, x] == "."
                px[x + 1, y + 1] = c("contorno") if ch == "O" else (luz if arriba else (osc if abajo else felipe))
        _contorno(im, c("contorno"))
        return im
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y in range(h):
        for x in range(w):
            ch = rejilla[y, x]
            if ch == "C":
                px[x, y] = c("contorno")
            elif ch == "A":
                px[x, y] = felipe
            elif ch == "X":
                px[x, y] = c("panel")
    return im


def _contorno(im, cont):
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            if px[x, y][3]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h and px[xx, yy][3] and px[xx, yy] != cont:
                    px[x, y] = cont
                    break


# -------------------------------------------------------------------------------------------------------------------
def todas():
    """Todas las variantes: {pieza: [(nombre, rejilla, puntaje, imagen)]}."""
    res = {}
    for pieza, lista in RECORTES.items():
        res[pieza] = []
        for hoja, caja, trans in lista:
            a = cargar(hoja, caja, trans)
            lado = "" if pieza != "oreja" else ("-der" if trans == "espejo" else "-izq")
            if pieza == "sello":
                lado = "-logro" if caja[0] < 200 and hoja == "chatgpt-1" else ""
            for metodo in ("mayoria", "huecos", "centro"):
                rej, m, cambios, fuente = variante(pieza, a, metodo)
                p = medir(pieza, a, rej, m, cambios, fuente)
                res[pieza].append((f"{hoja}{lado} {metodo}", rej, p, pintar(pieza, rej), a))
    return res


def lamina_variantes(res, ruta):
    fondo_real = Image.open(os.path.join(k.CAPTURAS, "base-pelea-2.png")).convert("RGBA").crop((240, 150, 400, 260))
    filas = [(p, v) for p in res for v in res[p]]
    W, H_fila = 1280, 96
    img = Image.new("RGBA", (W, 6000), k.hexa("#241A26"))
    y = 6
    k.texto(img, (8, y), "KIT v2 · VARIANTES DE LAS PIEZAS CON FORMA PROPIA (x1 sobre el juego y x6) · gana el puntaje más alto",
            k.F8, "#FFF0D5")
    y += 18
    for pieza, vs in res.items():
        mejor = max(range(len(vs)), key=lambda i: vs[i][2]["total"])
        k.texto(img, (8, y), f"{pieza.upper()}  ({len(vs)} variantes)", k.SK16, "#E8913A")
        y += 20
        x = 8
        for i, (nombre, rej, p, im, a) in enumerate(vs):
            ancho_celda = max(122, im.width * 6 + 12)
            if x + ancho_celda > W:
                x = 8
                y += H_fila + 30
            # fuente reducida (referencia), x1 sobre fondo real, x6
            ref = Image.fromarray(a.astype(np.uint8)).convert("RGBA")
            ref.thumbnail((40, 40))
            img.alpha_composite(ref, (x, y))
            cel = fondo_real.crop((0, 0, 30, 30)).copy()
            cel.alpha_composite(im, ((30 - im.width) // 2, (30 - im.height) // 2))
            img.alpha_composite(cel, (x, y + 44))
            grande = im.resize((im.width * 6, im.height * 6), Image.NEAREST)
            img.alpha_composite(grande, (x + 44, y))
            color = "#FFE066" if i == mejor else "#FFF0D5"
            k.texto(img, (x, y + H_fila - 12), f"{nombre}", k.F8, color)
            k.texto(img, (x, y + H_fila - 3), f"{p['total']:.2f}" + ("  GANA" if i == mejor else ""), k.F8, color)
            if i == mejor:
                ImageDraw.Draw(img).rectangle([x - 3, y - 3, x + ancho_celda - 8, y + H_fila + 8], outline=k.hexa("#FFE066"))
            x += ancho_celda + 6
        y += H_fila + 30
    img = img.crop((0, 0, W, y + 4))
    img.save(ruta)
    img.resize((img.width * 2, img.height * 2), Image.NEAREST).save(ruta.replace(".png", "-x2.png"))
    return ruta


def main():
    res = todas()
    for pieza, vs in res.items():
        print(f"\n== {pieza} ({len(vs)} variantes)")
        orden = sorted(vs, key=lambda v: -v[2]["total"])
        for nombre, rej, p, im, a in orden:
            partes = " ".join(f"{kk}={vv:.2f}" for kk, vv in p.items() if kk != "total")
            print(f"  {p['total']:.3f}  {nombre:28s} {partes}")
        nombre, rej, *_ = orden[0]
        print("  ganadora:", nombre)
        for fila in rej:
            print("   ", "".join(fila))
    ruta = lamina_variantes(res, os.path.join(k.CAPTURAS, "kit-v2-variantes.png"))
    print("\n" + ruta)


if __name__ == "__main__":
    main()
