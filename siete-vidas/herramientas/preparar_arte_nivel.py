"""Prepara el arte de Gemini del nivel 1 para el juego: quita el fondo blanco, separa cada pieza de las hojas
y la lleva a su tamaño en el juego (escala de gato: alturas de muebles casi reales, 1,21 px por cm; lo que le
importa al gato, más grande; ver CLAUDE.md), sin suavizar los pixeles.

Cada pieza se recorta a su borde opaco antes y después de escalar (hallazgo M1: sin margen transparente, así
los muebles se apoyan exacto en su colisión) y se le quitan los pixeles sueltos de menos de 4 px.
Valeria (poses y caminar) se lleva a una sola escala (de pie, 200 px) y su caminar se alinea por los pies y la
cabeza (preparar_valeria()).

Uso: python3 preparar_arte_nivel.py
Lee siete-vidas/arte/referencias/gemini/ y escribe siete-vidas/juego/assets/nivel1/ y assets/personajes/.
Necesita numpy y scipy (pip install numpy scipy).
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

RAIZ = Path(__file__).resolve().parent.parent
ORIGEN = RAIZ / "arte" / "referencias" / "gemini"
DESTINO = RAIZ / "juego" / "assets" / "nivel1"
PERSONAJES = RAIZ / "juego" / "assets" / "personajes"

# nombre -> (hoja, índice de la pieza en la hoja, (ancho, alto) en el juego, recorte opcional en fracciones de la pieza)
# El índice sigue el orden de piezas() (filas de arriba abajo, luego de izquierda a derecha).
PIEZAS = {
    # Sala.
    "aparador": ("muebles-sala", 4, (156, 98), None),  # 81 cm
    "lampara": ("muebles-sala", 3, (34, 160), None),
    # Cocina.
    "refrigerador": ("muebles-cocina", 2, (84, 218), None),  # 1,80 m
    # Dormitorio.
    "comoda": ("muebles-dormitorio", 0, (84, 97), (0.0, 0.47, 1.0, 1.0)),  # 80 cm, sin el espejo
    "ropero": ("muebles-dormitorio", 1, (104, 185), None),  # 1,53 m
    "cama": ("muebles-dormitorio", 2, (200, 90), None),  # colchón a 55 cm (fila 25 del arte)
    # Recibidor y balcón.
    "baranda": ("escalera-y-baranda", 2, (184, 128), None),
    # Objetos.
    "vaso": ("objetos", 0, (24, 32), None),  # lado menor ≥ 24 (R8)
    "maceta": ("objetos", 3, (28, 37), None),
    "maceta_grande": ("objetos", 3, (45, 60), None),  # balcón: escalón a la baranda
    "calcetin": ("objetos", 4, (24, 33), None),
    "caja": ("objetos", 8, (64, 54), None),
    "raton": ("objetos", 9, (62, 54), None),  # escala de gato: la mitad de Felipe
    # Tanda 2.
    "escritorio": ("muebles-extra", 0, (160, 98), None),  # 81 cm, con 30 cm libres debajo
    "caja_arena": ("muebles-extra", 1, (104, 46), None),
    "base_carga": ("muebles-extra", 4, (74, 38), None),
    "repisa": ("muebles-extra", 5, (160, 47), None),
    "bola_pelo": ("detalles", 1, (24, 24), None),
    "mancha": ("detalles", 8, (60, 20), None),
    "retrato": ("cuadros", 0, (84, 100), None),  # retrato oficial de Su Majestad
    "paisaje": ("cuadros", 1, (64, 66), None),
    "reloj": ("cuadros", 2, (41, 43), None),  # 10 % más chico que antes: competía con la ventana (crítica de Gemini)
    # Tanda 3A (nivel 1 v4): piezas rehechas que calzan con las colisiones.
    "puerta_abierta_v2": ("puertas-v2", 0, (140, 248), None),
    "puerta_cerrada_v2": ("puertas-v2", 1, (128, 248), None),
    "puerta_entornada": ("puertas-v2", 2, (106, 248), None),
    "puerta_balcon_v2": ("puertas-v2", 3, (122, 248), None),
    "puerta_balcon_abierta": ("puertas-v2", 5, (156, 248), None),
    "mesa_v2": ("comedor-piezas", 0, (178, 91), None),  # 75 cm, tablero en la fila de arriba
    "silla_v2": ("comedor-piezas", 1, (59, 109), None),  # de perfil, derecha
    "librero_v2": ("librero-gato", 0, (104, 218), None),  # 1,80 m, 3 repisas
    "escalera_peldanos": ("escalera-dos-capas", 19, (226, 150), None),  # detrás de Felipe; ancho igual al del pasamanos (peldaños de 25 px)
    "escalera_baranda": ("escalera-dos-capas", 18, (186, 217), None),  # delante de Felipe
    "tazon": ("comida-grande", 0, (48, 35), None),
    "pollo": ("comida-grande", 2, (64, 50), None),
    "bolsita": ("comida-grande", 3, (28, 32), None),
    "banquito": ("muebles-cocina", 4, (52, 54), None),  # banquito del dormitorio, 45 cm
    # Tanda 3C (nivel 1 v4): sala, recibidor, cocina y ventanas.
    "rascador": ("sala-extra", 0, (100, 165), None),  # plataformas medidas en el arte (Sala.PIEZAS)
    "sofa_plastico": ("sala-extra", 1, (240, 102), None),
    "sofa_aranado": ("sala-extra", 2, (240, 98), None),
    "cesta_vacia": ("sala-extra", 8, (60, 35), None),
    "cesta_3": ("sala-extra", 9, (60, 35), None),
    "cesta_llena": ("sala-extra", 10, (60, 42), None),
    "zapatero": ("recibidor-cocina-extra", 0, (160, 98), None),  # 36 px libres debajo (patas estiradas)
    "llaves": ("recibidor-cocina-extra", 1, (32, 31), None),  # se tiran: lado menor ≥ 24 (R8)
    "microondas": ("recibidor-cocina-extra", 2, (98, 54), None),  # escala de gato: escalón de 54 px
    "iman_manzana": ("recibidor-cocina-extra", 3, (11, 12), None),
    "iman_naranja": ("recibidor-cocina-extra", 4, (11, 12), None),
    "iman_foto": ("recibidor-cocina-extra", 7, (12, 13), None),
    "iman_pez": ("recibidor-cocina-extra", 9, (14, 11), None),
    "raton_volcado": ("recibidor-cocina-extra", 11, (60, 39), None),
    "caja_rota": ("recibidor-cocina-extra", 12, (70, 38), None),
    "ventana_sala": ("ventanas-patio", 0, (180, 151), (0.0, 0.24, 1.0, 1.0)),
    "balcon_mini": ("ventanas-patio", 0, (54, 36), (0.30, 0.0, 0.645, 0.205)),
    # arriba-extra (Gemini, la mandó el creador; revisión 3): reemplaza lo que se dibujaba por código.
    "baul": ("arriba-extra", 0, (70, 48), None),  # 40 cm, se pasa por delante (cabe entre la puerta y la consola)
    "cojin": ("arriba-extra", 2, (70, 48), None),  # cojín redondo con hueco: descanso del pasillo
    "retrato_familiar": ("arriba-extra", 3, (100, 80), None),  # Felipe tapa a toda la familia (M8 de la revisión 2)
    "ropa_limpia": ("arriba-extra", 6, (52, 48), None),  # ropa doblada de la cama (interactuable, lado menor ≥ 24)
    "ropa_pelos": ("arriba-extra", 7, (52, 48), None),  # la misma, después de que Felipe se acicala encima
    "caja_recuerdos": ("arriba-extra", 8, (44, 33), None),  # lugar visto: repisa alta del dormitorio
    "monitor": ("arriba-extra", 9, (44, 48), (0.08, 0.0, 0.48, 0.50)),  # del escritorio con monitor e impresora
    "papel": ("arriba-extra", 10, (30, 16), None),  # papel plano en el piso (mancha de la pelea)
    "papel_arrugado": ("arriba-extra", 11, (16, 20), None),  # papeles que escupe la impresora
    # A.S.P.I. (escala de gato: más grande que una real); la gigante es imaginación de Felipe.
    "aspi": ("aspi-gemini-1", 0, (76, 47), None),
    "aspi_gigante": ("aspi-gigante", 0, (330, 270), None),
}

# Piezas con huecos (entre patas, barrotes, respaldos): el blanco encerrado también es fondo.
HUECOS = {"llaves", "rascador", "zapatero", "banquito", "aparador", "baranda", "lampara", "escritorio", "repisa", "mesa_v2", "silla_v2", "librero_v2", "escalera_baranda"}

# Piezas con patas que hay que alargar para dejar el hueco de agachado (R8): nombre -> (fracción de la pieza donde
# empiezan las patas, alto de las patas en el juego).
PATAS = {"zapatero": (0.80, 38)}

# Rectángulos a borrar después de escalar (x0, y0, x1, y1 en la imagen final): el pasamanos trae dibujado el contorno
# de la escalera (una línea vertical y la del piso) que en el juego no calza con los peldaños de atrás.
# La baranda trae tres macetas encima: se borran la del medio y la de la derecha para que Felipe se siente al lado de
# la única que queda, no encima (M6 de la revisión 2 y plan de estabilización 2026-10-20); RELLENOS y PARCHES reponen
# la baranda que tapaban.
BORRAR = {"escalera_baranda": [(0, 80, 4, 217), (0, 202, 186, 217)], "baranda": [(70, 0, 121, 36), (118, 0, 184, 36)]}

# Rellenos después de escalar: (x0, y0, x1, y1, desde, periodo) repite en ese rectángulo las columnas que van de
# `desde` a `desde + periodo` (un tramo limpio del mismo dibujo).
RELLENOS = {"baranda": [(70, 36, 121, 62, 58, 18)]}

# Parches después de escalar: (x0, y0, x1, y1, dx) copia en ese rectángulo los pixeles que están dx a la izquierda
# en la imagen original.
PARCHES = {"baranda": [(118, 36, 178, 75, 52)]}

# Valeria (tanda 3B): poses a una sola escala (de pie mide 200 px, 3 Felipes). Su caminar es de SpriteCook
# (revisión 3, B2: las piernas sí alternan), 8 cuadros de 224 × 224 ya a escala 1:1.
VALERIA_POSES = ("valeria-poses", ["neutra", "enojada", "perdonando", "grabando", "serie"])
VALERIA_CAMINAR_SPRITECOOK = RAIZ / "arte" / "valeria" / "valeria-caminar-spritecook.png"
VALERIA_CUADROS = 8
VALERIA_ALTO = 200

# Cortina del dormitorio (dormitorio-cortina-alta, crítica de Gemini): un paño con barra y dos remates. Se corta el
# remate de la derecha (x ≥ 390 del original) para usarlo como paño izquierdo y, en espejo, como el derecho; la barra
# del medio se estira desde una columna de la misma barra (cortina_barra). Alto en el juego = el de la cortina por
# código que reemplaza: de la barra (SUELO - 278) al piso.
CORTINA = ("dormitorio-cortina-alta", (44, 28, 390, 2179), 277)

# Texturas que se repiten: nombre -> (hoja, índice, tamaño del mosaico, suavizado).
# El suavizado (0 a 1) acerca cada pixel al color promedio: las paredes no deben competir con Felipe (regla R14).
MOSAICOS = {
    "pared_tapiz": ("paredes", 0, (64, 64), 0.7),
    "pared_azulejo": ("paredes", 1, (48, 48), 0.6),
    "pared_rosa": ("paredes", 2, (64, 64), 0.3),
}

# Fondos completos: nombre -> (archivo, tamaño, recorte en fracciones, quitar el blanco).
FONDOS = {
    "cielo": ("fondo-cielo", (820, 458), None, False),
    "ciudad_lejana": ("fondo-ciudad-lejana", (1286, 240), None, True),
    "ciudad_cercana": ("fondo-ciudad-cercana", (1500, 280), None, True),
    "fin_del_mundo": ("fin-del-mundo", (416, 424), (0.14, 0.0, 0.86, 1.0), False),
}


def sin_fondo(imagen):
    """Vuelve transparente el blanco que toca el borde (el fondo), no el blanco de adentro."""
    a = np.asarray(imagen.convert("RGB")).astype(int)
    blanco = a.min(axis=2) > 232
    etiquetas, _ = ndimage.label(blanco)
    borde = set(np.unique(np.concatenate([etiquetas[0], etiquetas[-1], etiquetas[:, 0], etiquetas[:, -1]]))) - {0}
    fondo = np.isin(etiquetas, list(borde))
    # Halo claro del JPEG alrededor del contorno: los pixeles claros pegados al fondo también son fondo.
    claro = a.min(axis=2) > 200
    for _ in range(3):
        vecino = ndimage.binary_dilation(fondo) & claro & ~fondo
        if not vecino.any():
            break
        fondo = fondo | vecino
    rgba = np.dstack([a.astype(np.uint8), np.where(fondo, 0, 255).astype(np.uint8)])
    return Image.fromarray(rgba, "RGBA"), ~fondo


def piezas(nombre):
    imagen, objeto = sin_fondo(Image.open(ORIGEN / f"{nombre}.png"))
    unidas, _ = ndimage.label(ndimage.binary_dilation(objeto, iterations=6))
    cajas = []
    for s in ndimage.find_objects(unidas):
        if (s[0].stop - s[0].start) * (s[1].stop - s[1].start) > 2500:
            cajas.append((s[1].start, s[0].start, s[1].stop, s[0].stop))
    cajas.sort(key=lambda c: (c[1] // 120, c[0]))
    return imagen, cajas


def sin_huecos(imagen):
    """Vuelve transparente el blanco encerrado dentro de la pieza (huecos entre patas o barrotes)."""
    a = np.asarray(imagen).copy()
    blanco = (a[:, :, :3].min(axis=2) > 236) & (a[:, :, 3] > 0)
    etiquetas, cantidad = ndimage.label(blanco)
    tamanos = ndimage.sum(blanco, etiquetas, range(1, cantidad + 1))
    for i, tamano in enumerate(tamanos, start=1):
        if tamano >= 12:
            a[etiquetas == i, 3] = 0
    return Image.fromarray(a, "RGBA")


def recortar_opaco(imagen):
    """Recorta la imagen al rectángulo de sus pixeles opacos (sin margen transparente)."""
    caja = imagen.getchannel("A").point(lambda v: 255 if v > 0 else 0).getbbox()
    return imagen.crop(caja) if caja else imagen


def sin_sueltos(imagen, minimo=4):
    """Quita los grupos de pixeles opacos de menos de `minimo` pixeles (restos del fondo)."""
    a = np.asarray(imagen).copy()
    opaco = a[:, :, 3] > 0
    etiquetas, cantidad = ndimage.label(opaco)
    if cantidad:
        tamanos = ndimage.sum(opaco, etiquetas, range(1, cantidad + 1))
        for i, tamano in enumerate(tamanos, start=1):
            if tamano < minimo:
                a[etiquetas == i, 3] = 0
    return Image.fromarray(a, "RGBA")


def escalar(imagen, tamano):
    """Recorta al borde opaco, escala sin suavizar y vuelve a recortar (M1)."""
    imagen = recortar_opaco(imagen)
    return recortar_opaco(sin_sueltos(imagen.resize(tamano, Image.NEAREST)))


def con_patas(imagen, tamano, fraccion, alto_patas):
    """Escala el cuerpo y las patas por separado: las patas quedan de `alto_patas` (hueco para pasar agachado)."""
    imagen = recortar_opaco(imagen)
    corte = int(imagen.height * fraccion)
    cuerpo = imagen.crop((0, 0, imagen.width, corte)).resize((tamano[0], tamano[1] - alto_patas), Image.NEAREST)
    patas = imagen.crop((0, corte, imagen.width, imagen.height)).resize((tamano[0], alto_patas), Image.NEAREST)
    salida = Image.new("RGBA", tamano, (0, 0, 0, 0))
    salida.paste(cuerpo, (0, 0))
    salida.paste(patas, (0, tamano[1] - alto_patas))
    return recortar_opaco(sin_sueltos(salida))


def preparar_valeria():
    """Poses de Valeria (valeria_<pose>.png) a una sola escala y su caminar (valeria_caminar.png)."""
    PERSONAJES.mkdir(parents=True, exist_ok=True)
    hoja, nombres = VALERIA_POSES
    imagen, cajas = piezas(hoja)
    escala = VALERIA_ALTO / recortar_opaco(imagen.crop(cajas[0])).height
    for indice, nombre in enumerate(nombres):
        pose = sin_huecos(recortar_opaco(imagen.crop(cajas[indice])))
        tam = (round(pose.width * escala), round(pose.height * escala))
        escalar(pose, tam).save(PERSONAJES / f"valeria_{nombre}.png")
    preparar_valeria_caminar()


def pie_apoyado(cuadros):
    """Cuánto retrocede el pie apoyado de un cuadro al siguiente (px, negativo = hacia atrás), en los pares donde los
    dos pies se ven separados en las filas del piso. Devuelve [(cuadro, desplazamiento)]."""
    medidas = []
    for i, a in enumerate(cuadros):
        c = cuadros[(i + 1) % len(cuadros)]
        alto = a.shape[0]
        banda = slice(alto - 18, alto)
        etiquetas, _ = ndimage.label(a[banda, :, 3] > 40)
        mejores = []
        for s in ndimage.find_objects(etiquetas):
            x0, x1 = s[1].start, s[1].stop
            # Pies juntos (una sola mancha ancha) no sirven para medir; tiene que tocar el piso.
            if x1 - x0 < 6 or x1 - x0 > 34 or not (a[alto - 3:alto, x0:x1, 3] > 40).any():
                continue
            error, dx = min((np.abs(a[banda, x0:x1, 3] - c[banda, x0 + d:x1 + d, 3]).mean(), d)
                            for d in range(-20, 9) if 0 <= x0 + d and x1 + d <= a.shape[1])
            mejores.append((error, dx))
        if mejores:
            error, dx = min(mejores)
            if error < 30 and dx < 0:
                medidas.append((i, dx))
    return medidas


def preparar_valeria_caminar():
    """Caminar de SpriteCook: cada cuadro se alinea por los pies (su fila más baja va al piso), se mantiene la x (el
    avance del pie apoyado es la medida) y se recorta a una ventana común centrada en la cabeza."""
    imagen = np.asarray(Image.open(VALERIA_CAMINAR_SPRITECOOK).convert("RGBA"))
    ancho = imagen.shape[1] // VALERIA_CUADROS
    cuadros = []
    for i in range(VALERIA_CUADROS):
        f = imagen[:, i * ancho:(i + 1) * ancho].copy()
        filas = np.nonzero(f[:, :, 3].max(axis=1) > 40)[0]
        baja = f.shape[0] - 1 - filas.max()
        g = np.zeros_like(f)
        g[baja:] = f[:f.shape[0] - baja]
        g[:, :, 3] = np.where(g[:, :, 3] > 40, 255, 0)
        cuadros.append(g)
    opaco = np.any([c[:, :, 3] > 0 for c in cuadros], axis=0)
    ys, xs = np.nonzero(opaco)
    cabeza = np.mean([np.nonzero(c[ys.min():ys.min() + 40, :, 3] > 0)[1].mean() for c in cuadros])
    medio = int(round(max(cabeza - xs.min(), xs.max() + 1 - cabeza))) + 2
    x0, x1, y0 = int(round(cabeza)) - medio, int(round(cabeza)) + medio, ys.min()
    salida = Image.new("RGBA", ((x1 - x0) * VALERIA_CUADROS, cuadros[0].shape[0] - y0), (0, 0, 0, 0))
    for i, c in enumerate(cuadros):
        salida.paste(Image.fromarray(c[y0:, x0:x1].astype(np.uint8), "RGBA"), (i * (x1 - x0), 0))
    salida.save(PERSONAJES / "valeria_caminar.png")
    medidas = pie_apoyado(cuadros)
    promedio = -np.mean([d for _, d in medidas])
    print(f"Valeria: caminar de {VALERIA_CUADROS} cuadros de {x1 - x0} x {salida.height}; pie apoyado {promedio:.2f} px por "
          f"cuadro (pares {[i for i, _ in medidas]}: {[d for _, d in medidas]})")


def vaso_en_pixeles(imagen):
    """Vaso de agua (crítica de Gemini: se veía de vector, con degradados suaves y reflejos que no son de pixel).
    Deja el contorno oscuro y el dibujo de Gemini, pero el agua (desde la fila 11) pasa a un azul más hondo en dos
    tonos planos, la superficie es una fila clara de 1 px y los reflejos son duros: una columna blanca en la pared
    izquierda y un brillo de 2 x 2 arriba a la derecha."""
    a = np.asarray(imagen).copy()
    interior = (a[:, :, 3] > 0) & (a[:, :, :3].max(axis=2) > 100)
    agua_clara, agua_honda, superficie, blanco = (138, 192, 218), (104, 160, 196), (206, 242, 250), (246, 252, 255)
    for y in range(11, a.shape[0]):
        for x in np.where(interior[y])[0][2:-2]:
            a[y, x, :3] = agua_honda if a[y, x, :3].sum() < 520 else agua_clara
    for x in np.where(interior[11])[0][1:-1]:
        a[11, x, :3] = superficie
    for y in range(13, 26):
        fila = np.where(interior[y])[0]
        if len(fila) > 4:
            a[y, fila[0] + 2, :3] = blanco
    for y, x in [(13, 18), (13, 19), (14, 18), (14, 19), (16, 19)]:
        if interior[y, x]:
            a[y, x, :3] = blanco
    return Image.fromarray(a, "RGBA")


def maceta_contrastada(imagen):
    """Maceta de la repisa del estudio (crítica de Gemini): la terracota se perdía contra la pared mostaza. Oscurece
    solo la maceta (pixeles rojizos de la mitad de abajo), no las flores ni las hojas."""
    a = np.asarray(imagen).copy().astype(int)
    alto = a.shape[0]
    rojizo = (a[:, :, 0] > a[:, :, 1] + 30) & (a[:, :, 3] > 0)
    rojizo[: int(alto * 0.45)] = False
    a[rojizo, :3] = (a[rojizo, :3] * np.array([0.78, 0.72, 0.72])).astype(int)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def luz_de_borde(nombre, desde=((0, -1), (1, -1)), color=(255, 168, 92)):
    """Luz de borde (rim light) de una pieza: una franja de 2 px por DENTRO del contorno, del lado de la luz (`desde`),
    solo sobre el metal (pixeles oscuros del cuerpo principal: no el humo ni las chispas sueltas). Se guarda aparte
    (<nombre>_luz.png) y se dibuja encima con la misma transformación. Para la A.S.P.I. gigante (crítica de Gemini): su
    silueta oscura se fundía con el fondo; la luz viene del incendio de arriba (`desde`: direcciones hacia la luz)."""
    a = np.asarray(Image.open(DESTINO / f"{nombre}.png"))
    opaco = a[:, :, 3] > 0
    etiquetas, _ = ndimage.label(opaco)
    tamanos = ndimage.sum(opaco, etiquetas, range(1, etiquetas.max() + 1))
    cuerpo = etiquetas == (int(np.argmax(tamanos)) + 1)

    def lleno_hacia_la_luz(pasos, direccion):
        dx, dy = direccion[0] * pasos, direccion[1] * pasos
        movido = np.zeros_like(cuerpo)
        alto, ancho = cuerpo.shape
        movido[max(0, -dy):alto - max(0, dy), max(0, -dx):ancho - max(0, dx)] = \
            cuerpo[max(0, dy):alto + min(0, dy) or None, max(0, dx):ancho + min(0, dx) or None]
        return movido

    # Metal gris: ni el contorno casi negro ni el humo claro.
    brillo = a[:, :, :3].max(axis=2)
    metal = (brillo > 60) & (brillo < 170)
    franja = np.zeros_like(cuerpo)
    for direccion in desde:
        franja |= cuerpo & metal & ~lleno_hacia_la_luz(9, direccion)
    salida = np.zeros_like(a)
    salida[franja, :3] = color
    salida[franja, 3] = 210
    Image.fromarray(salida, "RGBA").save(DESTINO / f"{nombre}_luz.png")


def taza_de_cafe():
    """Taza de café de Valeria en el escritorio (reemplaza al rollo de papel higiénico, que no tenía sentido en un
    estudio; el creador, 2026-10-19). Se tira igual y deja una mancha. Escala de gato: el doble de una real (30 × 26,
    lado menor ≥ 24, R8), con el contorno oscuro y la luz de arriba a la izquierda del resto del arte."""
    contorno, loza, sombra, luz = (43, 23, 18), (241, 230, 210), (206, 186, 160), (255, 250, 238)
    franja, franja_osc, cafe, crema = (192, 96, 63), (150, 70, 45), (74, 42, 26), (140, 92, 58)
    ancho, alto = 30, 26
    a = np.zeros((alto, ancho, 4), np.uint8)

    def pintar(x0, y0, x1, y1, color):
        a[y0:y1, x0:x1, :3] = color
        a[y0:y1, x0:x1, 3] = 255

    # Asa (a la derecha): un aro de 3 px de grosor.
    pintar(19, 7, 28, 20, contorno)
    pintar(20, 8, 27, 19, loza)
    pintar(20, 8, 27, 9, luz)
    pintar(23, 11, 25, 16, (0, 0, 0))
    a[11:16, 23:25, 3] = 0
    pintar(22, 10, 26, 11, contorno)
    pintar(22, 16, 26, 17, contorno)
    pintar(22, 11, 23, 16, contorno)
    pintar(25, 11, 26, 16, contorno)
    # Cuerpo: un poco más angosto abajo, con contorno.
    for y in range(3, 26):
        recorte = 1 if y >= 23 else 0
        pintar(0 + recorte, y, 22 - recorte, y + 1, contorno)
    for y in range(4, 25):
        recorte = 1 if y >= 22 else 0
        pintar(1 + recorte, y, 21 - recorte, y + 1, loza)
    # Sombra a la derecha y brillo a la izquierda.
    pintar(16, 6, 21, 22, sombra)
    pintar(3, 7, 5, 20, luz)
    # Franja terracota (la de la casa) con su sombra.
    pintar(1, 13, 21, 17, franja)
    pintar(16, 13, 21, 17, franja_osc)
    # Borde de arriba y café adentro (se ve desde arriba en 3/4).
    pintar(0, 1, 22, 3, contorno)
    pintar(1, 2, 21, 6, contorno)
    pintar(2, 2, 20, 5, cafe)
    pintar(4, 3, 11, 4, crema)
    pintar(1, 6, 21, 7, luz)
    # Base: sombra dura bajo la taza.
    pintar(2, 25, 20, 26, contorno)
    Image.fromarray(a, "RGBA").save(DESTINO / "taza.png")
    print(f"Taza de café: {ancho} x {alto}")


def baranda_con_brillo(imagen):
    """Baranda del balcón (crítica de Gemini): brillo cálido del atardecer en el borde de arriba del pasamanos de hierro
    (fila 39, la de la colisión), para que se lea en primer plano frente a la ciudad. Solo el hierro gris, no las
    macetas."""
    a = np.asarray(imagen).copy().astype(int)
    fila = 39
    hierro = (a[fila, :, 3] > 0) & (a[fila, :, 0] - a[fila, :, 2] < 30)
    a[fila, hierro, :3] = (238, 182, 130)
    # Medio tono debajo (fila 41), más tenue.
    hierro_abajo = (a[fila + 2, :, 3] > 0) & (a[fila + 2, :, 0] - a[fila + 2, :, 2] < 40)
    a[fila + 2, hierro_abajo, :3] = (a[fila + 2, hierro_abajo, :3] * 0.6 + np.array([238, 182, 130]) * 0.4).astype(int)
    return Image.fromarray(a.astype(np.uint8), "RGBA")


def preparar_cortina():
    archivo, caja, alto = CORTINA
    imagen, _ = sin_fondo(Image.open(ORIGEN / f"{archivo}.png"))
    recorte = sin_huecos(recortar_opaco(imagen.crop(caja)))
    ancho = round(recorte.width * alto / recorte.height)
    final = escalar(recorte, (ancho, alto))
    # Restos claros del blanco entre las argollas (la tela y la barra no tienen ningún color tan claro).
    a = np.asarray(final).copy()
    a[a[:, :, :3].min(axis=2) > 180, 3] = 0
    final = Image.fromarray(a, "RGBA")
    final.save(DESTINO / "cortina.png")
    # Barra: la penúltima columna del paño, solo las filas de la barra (opacas arriba, antes de la tela).
    a = np.asarray(final)
    columna = a[:, final.width - 2:final.width - 1].copy()
    filas = np.where(columna[:, 0, 3] > 0)[0]
    fin = filas[0]
    while fin + 1 < len(columna) and columna[fin + 1, 0, 3] > 0:
        fin += 1
    Image.fromarray(columna[filas[0]:fin + 1], "RGBA").save(DESTINO / "cortina_barra.png")
    print(f"Cortina: {final.width} x {final.height}; barra de {fin + 1 - filas[0]} px desde la fila {filas[0]}")


def recortar(imagen, caja, fraccion):
    if fraccion:
        x0, y0, x1, y1 = caja
        w, h = x1 - x0, y1 - y0
        caja = (int(x0 + w * fraccion[0]), int(y0 + h * fraccion[1]), int(x0 + w * fraccion[2]), int(y0 + h * fraccion[3]))
    return imagen.crop(caja)


def main():
    DESTINO.mkdir(parents=True, exist_ok=True)
    hojas = {}
    for nombre, (hoja, indice, tamano, fraccion) in PIEZAS.items():
        if hoja not in hojas:
            hojas[hoja] = piezas(hoja)
        imagen, cajas = hojas[hoja]
        recorte = recortar(imagen, cajas[indice], fraccion)
        if nombre in HUECOS:
            recorte = sin_huecos(recorte)
        if nombre in PATAS:
            final = con_patas(recorte, tamano, *PATAS[nombre])
        else:
            final = escalar(recorte, tamano)
        if nombre in BORRAR:
            a = np.asarray(final).copy()
            for x0, y0, x1, y1 in BORRAR[nombre]:
                a[y0:y1, x0:x1, 3] = 0
            final = recortar_opaco(Image.fromarray(a, "RGBA"))
        if nombre in RELLENOS:
            original = np.asarray(final).copy()
            a = original.copy()
            for x0, y0, x1, y1, desde, periodo in RELLENOS[nombre]:
                for x in range(x0, x1):
                    a[y0:y1, x] = original[y0:y1, desde + (x - desde) % periodo]
            final = Image.fromarray(a, "RGBA")
        if nombre == "vaso":
            final = vaso_en_pixeles(final)
        if nombre == "baranda":
            final = baranda_con_brillo(final)
        if nombre == "maceta":
            final = maceta_contrastada(final)
        if nombre in PARCHES:
            original = np.asarray(final).copy()
            a = original.copy()
            for x0, y0, x1, y1, dx in PARCHES[nombre]:
                a[y0:y1, x0:x1] = original[y0:y1, x0 - dx:x1 - dx]
            final = Image.fromarray(a, "RGBA")
        if nombre == "baranda":
            # Sin la maceta de la derecha, arriba quedan filas vacías: se recorta al borde opaco (M1).
            final = final.crop((0, final.getbbox()[1], final.width, final.height))
        final.save(DESTINO / f"{nombre}.png")
    for nombre, (hoja, indice, tamano, suavizado) in MOSAICOS.items():
        if hoja not in hojas:
            hojas[hoja] = piezas(hoja)
        imagen, cajas = hojas[hoja]
        x0, y0, x1, y1 = cajas[indice]
        # Un margen adentro para no arrastrar el borde de la muestra.
        recorte = imagen.crop((x0 + 6, y0 + 6, x1 - 6, y1 - 6)).resize(tamano, Image.NEAREST)
        # Un mosaico de pared o piso es opaco entero: el quitado del halo del JPEG dejaba pixeles claros transparentes
        # en los bordes, y por esas costuras se veía la ciudad de atrás (líneas punteadas en la cocina; autocrítica).
        a = np.asarray(recorte).copy()
        a[:, :, 3] = 255
        recorte = Image.fromarray(a, "RGBA")
        if suavizado:
            a = np.asarray(recorte).astype(float)
            promedio = a[:, :, :3].reshape(-1, 3).mean(axis=0)
            a[:, :, :3] = a[:, :, :3] * (1 - suavizado) + promedio * suavizado
            recorte = Image.fromarray(a.astype(np.uint8), "RGBA")
        recorte.save(DESTINO / f"{nombre}.png")
    for nombre, (archivo, tamano, fraccion, quitar_blanco) in FONDOS.items():
        imagen = Image.open(ORIGEN / f"{archivo}.png")
        if quitar_blanco:
            imagen = sin_fondo(imagen)[0]
            # El cielo que queda atrapado entre cables y techos también es fondo.
            a = np.asarray(imagen).copy()
            cielo = a[:, :, :3].min(axis=2) > 232
            cielo[int(a.shape[0] * 0.6):] = False
            a[cielo, 3] = 0
            imagen = Image.fromarray(a, "RGBA")
        else:
            imagen = imagen.convert("RGBA")
        if fraccion:
            imagen = recortar(imagen, (0, 0, imagen.width, imagen.height), fraccion)
        imagen.resize(tamano, Image.NEAREST).save(DESTINO / f"{nombre}.png")
    preparar_cortina()
    luz_de_borde("aspi_gigante")
    taza_de_cafe()
    ambientes()
    print(f"{len(list(DESTINO.glob('*.png')))} imágenes en {DESTINO}")
    preparar_valeria()


# --- Plan de ambientes del nivel 1 (diseno/revisiones/2026-10-19-ambientes-nivel1.md) -------------------------------

# Arte existente que se empieza a usar: (hoja, índice, tamaño, recorte en fracciones).
PIEZAS_AMBIENTE = {
    "aranazo_1": ("sala-extra", 4, (14, 16), None),  # marcas sueltas de la tanda 3C (G9)
    "aranazo_2": ("sala-extra", 5, (16, 14), None),
    "aranazo_3": ("sala-extra", 7, (5, 12), None),
    "lata": ("comida-grande", 1, (24, 27), None),  # lata de atún abierta junto al tazón (C-7)
    "libro": ("objetos", 6, (42, 12), None),  # libro sobre el banquito (D-3), al doble de su tamaño real (lección 29)
    "maceta_rota": ("detalles", 8, (32, 11), None),  # isla de jardinería del balcón (B-3)
}

# Tanda 3E (vida-casa.png): cajas explícitas en la hoja (Gemini escribió números junto a las piezas y algunas quedan
# pegadas: el recorte automático las une). nombre -> (caja x0, y0, x1, y1, tamaño en el juego).
HOJA_3E = "vida-casa"
PIEZAS_3E = {
    "alfombra_sala": ((33, 30, 525, 150), (300, 10)),
    "alfombra_pasillo": ((33, 163, 515, 265), (260, 8)),
    "alfombra_dormitorio": ((33, 278, 310, 380), (120, 8)),
    "mesita_sala": ((366, 282, 560, 495), (88, 96)),  # lámpara, taza y cargador; tablero a 45 cm medido abajo
    "marco_foto": ((597, 293, 797, 442), (44, 33)),
    "marco_huella": ((815, 293, 965, 442), (30, 30)),
    "perchero": ((35, 468, 312, 705), (118, 101)),
    "zapatillas": ((352, 530, 552, 665), (24, 16)),
    "marco_viral": ((597, 472, 762, 695), (44, 59)),
    "polaroid_1": ((35, 728, 118, 830), (12, 14)),
    "polaroid_2": ((132, 725, 222, 828), (12, 14)),
    "polaroid_3": ((232, 728, 325, 832), (12, 14)),
    "corcho": ((32, 858, 322, 1065), (64, 46)),
    "regadera": ((740, 758, 955, 898), (30, 22)),
    "saco_tierra": ((788, 920, 962, 1068), (26, 22)),
}
# Números de Gemini que quedan dentro de una caja: se pintan de blanco antes de recortar.
NUMEROS_3E = [(796, 930, 838, 964), (362, 282, 384, 310)]
# Franjas de piso de Gemini (pisos.png, pasada única 2026-10-19): nombre -> (filas de origen y0..y1 sin el remate de
# arriba, período horizontal en px de origen). Gemini dibuja cada pixel con ~4 px: se reduce a 1/4 y salen 44 px de
# alto, lo que va de la unión pared-piso (Sala.PARED_BASE) al borde de abajo (Sala.ALTO). Sin perspectiva. El último
# número es el contraste (1 = el de Gemini): el damero baja para no competir con Felipe ni con el azulejo (R14).
FRANJAS_PISO = {
    "piso_parquet": ((127, 303), 452, 1.0),  # el parquet casi repite cada 452 px: se busca el corte que mejor case
    "piso_damero": ((447, 623), 512, 0.8),  # damero de 64 px que repite exacto cada 128; sin la hilera sombreada de atrás
    "piso_losa": ((728, 904), 512, 1.0),  # losas de 128 px con el canto del balcón abajo
}


def recolorear(a, mascara, color, referencia):
    """Lleva los pixeles de la máscara a `color` conservando su luz relativa a `referencia` (luminancia)."""
    luz = a[:, :, :3].astype(float) @ np.array([0.299, 0.587, 0.114])
    nuevo = np.clip(np.outer(luz[mascara] / referencia, np.array(color, float)), 0, 255)
    a[mascara, :3] = nuevo.astype(np.uint8)
    return a


def guardar(a, nombre):
    Image.fromarray(a.astype(np.uint8), "RGBA").save(DESTINO / f"{nombre}.png")


def abrir(nombre):
    return np.asarray(Image.open(DESTINO / f"{nombre}.png").convert("RGBA")).copy()


def ensanchar(a, columnas, ancho):
    """Repite columnas de la propia imagen (sin escalar) hasta llegar a `ancho`: reparte lo que falta entre ellas."""
    falta = ancho - a.shape[1]
    partes, previo = [], 0
    for i, x in enumerate(sorted(columnas)):
        n = falta // len(columnas) + (1 if i < falta % len(columnas) else 0)
        partes += [a[:, previo:x], np.repeat(a[:, x:x + 1], n, axis=1)]
        previo = x
    partes.append(a[:, previo:])
    return np.concatenate(partes, axis=1)


def puertas_unificadas():
    """G1: un solo marco de puerta de 140 x 248 en todos los estados."""
    abierta = abrir("puerta_abierta_v2")
    cerrada_original = abrir("puerta_cerrada_v2")
    # Cerrada (128): se ensancha el panel repitiendo su columna central.
    guardar(ensanchar(cerrada_original, [64], 140), "puerta_cerrada_v2")
    # Puerta-ventana cerrada (122): se ensancha cada hoja por su columna del medio (el parante central no cambia).
    guardar(ensanchar(abrir("puerta_balcon_v2"), [35, 83], 140), "puerta_balcon_v2")
    # Puerta-ventana abierta (156): se quitan 16 columnas del vano oscuro.
    b = abrir("puerta_balcon_abierta")
    guardar(np.concatenate([b[:, :86], b[:, 102:]], axis=1), "puerta_balcon_abierta")
    # Entornada: el marco de la abierta con la hoja cerrada (la de 128, sin ensanchar) apoyada en la bisagra de la
    # izquierda; del lado de la manilla queda una franja oscura de 12 px y 2 px de sombra sobre el canto de la hoja.
    e = abierta.copy()
    oscuro = abierta[18:245, 50:51]
    e[18:245, 14:126] = np.repeat(oscuro, 112, axis=1)
    hoja = cerrada_original[17:241, 14:114]
    e[17:241, 14:114] = hoja
    e[17:241, 112:114, :3] = (e[17:241, 112:114, :3] * 0.55).astype(np.uint8)
    guardar(e, "puerta_entornada")
    print("Puertas: 140 x 248 en los cinco estados")


def vano_alto():
    """G2: el vano de la escalera a la altura de una puerta (140 x 248), sin hoja. En el pasillo, dentro del hueco
    oscuro, se ven el remate del pasamanos y los dos primeros peldaños bajando (vano_bajada, al 60 % de valor)."""
    puerta = abrir("puerta_abierta_v2")
    for x in range(40, 126):
        puerta[18:245, x] = puerta[18:245, 50]
    guardar(puerta, "vano")
    peldanos = abrir("escalera_peldanos")
    baranda = abrir("escalera_baranda")
    lienzo = np.zeros((70, 110, 4), np.uint8)

    def pegar(pieza, x, y):
        alto, ancho = pieza.shape[:2]
        sub = lienzo[y:y + alto, x:x + ancho]
        m = pieza[:, :, 3] > 0
        sub[m] = pieza[m]

    # Peldaños de arriba (esquina de arriba a la izquierda de la hoja) y el poste con el primer tramo del pasamanos.
    pegar(peldanos[0:44, 0:70], 30, 26)
    pegar(baranda[0:60, 0:46], 0, 10)
    lienzo[:, :, :3] = (lienzo[:, :, :3] * 0.6).astype(np.uint8)
    guardar(lienzo, "vano_bajada")
    print("Vano: 140 x 248, con la bajada de la escalera")


def recoloreos():
    # R-4: peldaños de madera apagada, no gris piedra.
    p = abrir("escalera_peldanos")
    rgb = p[:, :, :3].astype(int)
    gris = (p[:, :, 3] > 0) & (rgb.max(axis=2) > 70)
    guardar(recolorear(p, gris, (0x8a, 0x6a, 0x55), 190.0), "escalera_peldanos")
    # R-5: zapatero sin clones: un par verde azulado, otro crema y uno volteado.
    z = abrir("zapatero")
    rgb = z[:, :, :3].astype(int)
    naranja = (z[:, :, 3] > 0) & (rgb[:, :, 0] > 170) & (rgb[:, :, 2] < 120)
    arriba_izq = naranja.copy(); arriba_izq[:, :72] = False; arriba_izq[:, 88:] = False; arriba_izq[28:] = False
    abajo = naranja.copy(); abajo[:36] = False; abajo[50:] = False; abajo[:, :89] = False; abajo[:, 100:] = False
    recolorear(z, arriba_izq, (64, 128, 128), 150.0)
    recolorear(z, abajo, (226, 210, 180), 150.0)
    z[17:28, 88:116] = z[17:28, 88:116][:, ::-1]
    guardar(z, "zapatero")
    print("Recoloreos: peldaños, zapatero")


def telas():
    """C-3 y E-1: las cortinas cortas de detalles.png. Visillo de la cocina (crema con franja terracota, el tercio de
    abajo del vidrio) y paños del estudio (oliva, de la barra al alféizar)."""
    imagen, cajas = piezas("detalles")
    corta = recortar_opaco(imagen.crop(cajas[7]))
    arriba = corta.crop((0, 0, corta.width, int(corta.height * 0.42)))
    visillo = np.asarray(escalar(arriba, (154, 44))).copy()
    rgb = visillo[:, :, :3].astype(int)
    tela = (visillo[:, :, 3] > 0) & (rgb[:, :, 0] > rgb[:, :, 2] + 40) & (rgb.max(axis=2) > 110)
    recolorear(visillo, tela, (236, 222, 196), 120.0)
    franja = tela.copy(); franja[:-9] = False; franja[-5:] = False
    recolorear(visillo, franja, (192, 96, 63), 200.0)
    guardar(visillo, "visillo_cocina")
    pano = np.asarray(escalar(recortar_opaco(imagen.crop(cajas[6])), (34, 150))).copy()
    rgb = pano[:, :, :3].astype(int)
    tela = (pano[:, :, 3] > 0) & (rgb[:, :, 0] > rgb[:, :, 2] + 40) & (rgb.max(axis=2) > 110)
    recolorear(pano, tela, (0x6f, 0x7a, 0x4a), 120.0)
    guardar(pano, "panos_estudio")
    print("Telas: visillo de la cocina y paños del estudio")


# Farol de la fachada y su halo (x0, y0, x1, y1 en el arte ya escalado): se borran.
FAROLES = [(44, 47, 236, 153), (44, 153, 66, 185)]


def tanda_3e():
    """Piezas de la tanda 3E (vida de la casa) y la fachada del balcón rehecha (vida-casa-fachada.png)."""
    original = Image.open(ORIGEN / f"{HOJA_3E}.png").convert("RGB")
    a = np.asarray(original).copy()
    for x0, y0, x1, y1 in NUMEROS_3E:
        a[y0:y1, x0:x1] = 255
    imagen, _ = sin_fondo(Image.fromarray(a))
    for nombre, (caja, tamano) in PIEZAS_3E.items():
        recorte = sin_huecos(imagen.crop(caja))
        final = np.asarray(escalar(recorte, tamano)).copy()
        guardar(final, nombre)
    # Fachada: el hueco de Gemini es más angosto que la puerta. Se recorta hasta el piso (abajo del hueco), se quitan
    # 80 filas de muro liso bajo la cornisa, se ensancha el hueco repitiendo una columna a la derecha del farol y se
    # escala para que el hueco mida 136 x 244 (la puerta-ventana de 140 x 248 lo tapa por delante).
    f, objeto = sin_fondo(Image.open(ORIGEN / "vida-casa-fachada.png"))
    f = np.asarray(sin_huecos(f.crop((207, 21, 788, 985)))).copy()
    f = np.concatenate([f[:100], f[180:]], axis=0)
    f = ensanchar(f, [368], f.shape[1] + 77)
    escala = 244 / (985 - 470)
    tam = (round(f.shape[1] * escala), round(f.shape[0] * escala))
    final = np.asarray(Image.fromarray(f, "RGBA").resize(tam, Image.NEAREST)).copy()
    # Pasada única: el farol de Gemini quedaba cortado por el borde de arriba de la pantalla (lección 23) y con un halo
    # circular (lección 26). Se borra con el color del muro (la mediana de la franja de al lado).
    muro = np.median(final[60:150, 230:280].reshape(-1, 4), axis=0).astype(np.uint8)
    for x0, y0, x1, y1 in FAROLES:
        final[y0:y1, x0:x1] = muro
    guardar(final, "fachada_balcon")
    hueco = np.nonzero(final[-3, :, 3] == 0)[0]
    hueco = hueco[(hueco > 40) & (hueco < final.shape[1] - 40)]
    print(f"Tanda 3E: {len(PIEZAS_3E) + 1} piezas; fachada {tam[0]} x {tam[1]}, hueco de x {hueco.min()} a {hueco.max()}")


def pisos_gemini():
    """Pasada única: mosaicos de piso desde las franjas de Gemini (parquet, damero, losa), sin perspectiva y sin
    costura. Se busca el comienzo x0 en que la columna x0 y la x0 + período más se parecen (el corte cae en una junta
    o en tabla lisa), se reduce a 1/4 con promedio y se vuelve a la paleta de la franja (16 colores) para que no quede
    borroso."""
    original = np.asarray(Image.open(ORIGEN / "pisos.png").convert("RGB")).astype(int)
    for nombre, ((y0, y1), periodo, contraste) in FRANJAS_PISO.items():
        banda = original[y0:y1]
        banda = banda.mean(axis=(0, 1)) + (banda - banda.mean(axis=(0, 1))) * contraste
        ancho = banda.shape[1]
        costos = [np.abs(banda[:, x] - banda[:, x + periodo]).mean() for x in range(0, ancho - periodo)]
        x0 = int(np.argmin(costos))
        recorte = Image.fromarray(banda[:, x0:x0 + periodo].astype(np.uint8), "RGB")
        chico = recorte.resize((periodo // 4, (y1 - y0) // 4), Image.BOX)
        paleta = recorte.quantize(16, method=Image.Quantize.MEDIANCUT)
        final = chico.quantize(palette=paleta, dither=Image.Dither.NONE).convert("RGBA")
        final.save(DESTINO / f"{nombre}.png")
        print(f"{nombre}: {final.size[0]} x {final.size[1]} (corte en x {x0}, costura {costos[x0]:.1f})")
    for viejo in ("piso", "piso_cocina", "piso_balcon"):
        for ruta in (DESTINO / f"{viejo}.png", DESTINO / f"{viejo}.png.import"):
            if ruta.exists():
                ruta.unlink()


def cocina_v2():
    """Tanda 3F de Gemini (`cocina-v2.png`, 2026-10-19): cocina más grande y cajas de mudanza. Cada pieza se escala
    por su medida real a 1,21 px por cm (escala de gato: alturas de muebles casi reales) y se recorta a su borde opaco:
    A mesón largo con fregadero embutido y grifo de cuello de cisne (cubierta a 90 cm = 109 px; el grifo sobresale),
    B estufa con horno y olla (cubierta a 109), C alacenas (70 cm), D pila de 3 cajas de mudanza con la cesta de ropa
    (cajas de unos 30 cm; también por separado la base de 2 cajas y la caja de arriba con la cesta, que se cae), E caja
    abierta con ropa (la de arriba, ya en el piso) y F escoba (1,1 m: cabe bajo el descanso). El mueble bajo suelto de
    la hoja no se usa."""
    imagen, cajas = piezas("cocina-v2")

    def pieza(indice, escala):
        recorte = recortar_opaco(imagen.crop(cajas[indice]))
        tam = (round(recorte.width * escala), round(recorte.height * escala))
        return recortar_opaco(sin_sueltos(recorte.resize(tam, Image.NEAREST)))

    # A: la cubierta está en la fila 93 de la pieza (el grifo va encima); de ahí al piso, 90 cm.
    meson = recortar_opaco(imagen.crop(cajas[0]))
    meson = pieza(0, 109.0 / (meson.height - 93))
    meson.save(DESTINO / "meson.png")
    # B: la cubierta de la estufa en la fila 40 (la olla asoma encima).
    estufa = recortar_opaco(imagen.crop(cajas[1]))
    pieza(1, 109.0 / (estufa.height - 40)).save(DESTINO / "estufa.png")
    alacenas = recortar_opaco(imagen.crop(cajas[2]))
    pieza(2, 80.0 / alacenas.height).save(DESTINO / "alacenas.png")
    # D: tres cajas de 33 px y la cesta encima; la caja de arriba (con la cesta) termina en la fila 194 de la pieza.
    # Segunda pasada (2026-10-20): 0,32 en vez de 0,351 (60 x 124 en vez de 66 x 135). Entre el librero (2162–2266) y
    # el poste del pasamanos (desde 2325) quedan 59 px: así la pila entra entera con 2 px de aire a cada lado y el
    # poste ya no le tapa el costado. Sigue sin saltarse desde el piso (1 m con la cesta).
    escala_cajas = 0.32
    pila = pieza(3, escala_cajas)
    pila.save(DESTINO / "cajas_pila.png")
    corte = round(194 * escala_cajas)
    a = np.asarray(pila)
    guardar(a[corte:], "cajas_base")
    guardar(a[:corte + 2], "caja_arriba")
    pieza(6, 0.3).save(DESTINO / "caja_abierta.png")
    escoba = recortar_opaco(imagen.crop(cajas[4]))
    pieza(4, 133.0 / escoba.height).save(DESTINO / "escoba.png")
    for nombre in ["meson", "estufa", "alacenas", "cajas_pila", "cajas_base", "caja_arriba", "caja_abierta", "escoba"]:
        tam = Image.open(DESTINO / f"{nombre}.png").size
        print(f"Cocina v2: {nombre} {tam[0]} x {tam[1]}")


def segunda_pasada_cocina():
    """Segunda pasada de la cocina y la escalera (2026-10-20, 0 créditos, solo arte de Gemini que ya estaba en el repo):
    - Isla de la entrada de la cocina: repisa de pared con ménsulas (muebles-extra, pieza 5) a 120 px de ancho y la
      bolsa grande de croquetas (comida-grande, pieza 3) a 38 x 44, al doble de su tamaño real (escala de gato): la
      reserva que Valeria guarda en alto, lejos de Felipe. La maceta con flores es la de objetos.png (ya preparada).
    - Ropa que se esparce al caer la caja de la mudanza: los calcetines sueltos de arriba-extra (pieza 5), separados
      uno por uno (ropa_1 café, ropa_2 blanco); no son el calcetín rayado que se colecciona."""
    imagen, cajas = piezas("muebles-extra")
    escalar(sin_huecos(imagen.crop(cajas[5])), (120, 35)).save(DESTINO / "repisa_cocina.png")
    imagen, cajas = piezas("comida-grande")
    escalar(imagen.crop(cajas[3]), (38, 44)).save(DESTINO / "croquetas_reserva.png")
    imagen, cajas = piezas("arriba-extra")
    grupo = recortar_opaco(imagen.crop(cajas[5]))
    a = np.asarray(grupo)
    etiquetas, _ = ndimage.label(a[:, :, 3] > 0)
    calcetines = [s for s in ndimage.find_objects(etiquetas) if (s[0].stop - s[0].start) * (s[1].stop - s[1].start) > 400]
    calcetines.sort(key=lambda s: s[1].start)
    for nombre, s in zip(["ropa_1", "ropa_2"], calcetines[:2]):
        # Solo el calcetín (su grupo de pixeles), sin la punta del vecino que cae en su rectángulo.
        solo = a[s].copy()
        propio = np.bincount(etiquetas[s][etiquetas[s] > 0]).argmax()
        solo[etiquetas[s] != propio, 3] = 0
        recorte = Image.fromarray(solo, "RGBA")
        escala = 22.0 / recorte.height
        tam = (round(recorte.width * escala), 22)
        recortar_opaco(sin_sueltos(recorte.resize(tam, Image.NEAREST))).save(DESTINO / f"{nombre}.png")
    for nombre in ["repisa_cocina", "croquetas_reserva", "ropa_1", "ropa_2"]:
        tam = Image.open(DESTINO / f"{nombre}.png").size
        print(f"Segunda pasada: {nombre} {tam[0]} x {tam[1]}")


def ambientes():
    for nombre, (hoja, indice, tamano, fraccion) in PIEZAS_AMBIENTE.items():
        imagen, cajas = piezas(hoja)
        escalar(recortar(imagen, cajas[indice], fraccion), tamano).save(DESTINO / f"{nombre}.png")
    puertas_unificadas()
    vano_alto()
    recoloreos()
    telas()
    tanda_3e()
    pisos_gemini()
    cocina_v2()
    segunda_pasada_cocina()
    consistencia()




# --- Consistencia (2026-10-20): consistencia-casa.png y correccion-estilo.png --------------------------------------

# nombre -> (hoja, índice, tamaño en el juego, recorte en fracciones o None).
PIEZAS_CONSISTENCIA = {
    "ventana_casa": ("consistencia-casa", 0, (215, 170), None),  # G2: el mismo marco en las 4 ventanas (hueco de 150 × 120)
    "vista_pasillo": ("consistencia-casa", 1, (150, 120), (0.012, 0.17, 0.988, 0.988)),  # B2: 1,25 : 1 sin cortar el toldo
    # El armario bajo la escalera (pieza 2) no calza con el larguero de la escalera: se probó y no se usa (sigue el de
    # código, ArteNivel1._dibujar_armario_escalera).
    "teclado": ("consistencia-casa", 3, (52, 24), None),
    "monitor": ("correccion-estilo", 0, (44, 48), None),
    "microondas": ("correccion-estilo", 1, (98, 54), None),
    "vaso": ("correccion-estilo", 2, (24, 32), None),
    "pollo": ("correccion-estilo", 3, (64, 50), None),  # de 1,6 : 1 a 1,28 : 1 (más alto, se lee como pollo)
}
# El toldo del pasillo, un poco más oscuro (B2): sus rayas terracota y crema bajan este factor de luz.
OSCURECER_TOLDO = 0.85
# La caja de pizza parecía flotar contra los ladrillos (lección 4): se recorta por su contorno, se achica y se apoya
# con la base sobre el toldo (fila BASE_PIZZA de la vista). Detrás se repone la pared y el toldo en espejo.
ESCALA_PIZZA = 0.85
BASE_PIZZA = 97
CORRIMIENTO_FONDO = 52


def pizza_en_el_toldo(imagen):
    """Baja la caja de pizza de la vista del pasillo para que se apoye en el toldo; devuelve la imagen, su caja
    (x0, y0, x1, y1) y la máscara de la caja."""
    a = np.asarray(imagen.convert("RGBA")).copy()
    lum = a[:, :, :3].astype(int) @ np.array([0.299, 0.587, 0.114])
    zona = np.zeros(lum.shape, bool)
    zona[0:98, 57:150] = True
    contorno = ndimage.binary_closing((lum < 100) & zona, structure=np.ones((3, 3)), iterations=2)
    lleno = ndimage.binary_fill_holes(contorno)
    etiquetas, cantidad = ndimage.label(lleno)
    tamanos = ndimage.sum(lleno, etiquetas, range(1, cantidad + 1))
    caja = etiquetas == (int(np.argmax(tamanos)) + 1)
    ys, xs = np.where(caja)
    recorte = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()
    recorte[~caja[ys.min():ys.max() + 1, xs.min():xs.max() + 1], 3] = 0
    # Fondo: la misma vista corrida a la izquierda, donde no hay caja.
    fondo = a.copy()
    # Lo que tapaba la caja se repone en espejo desde el borde izquierdo de la caja (ladrillos y rayas del toldo
    # siguen sin cortes); lo que no alcanza, desde CORRIMIENTO_FONDO px a la izquierda.
    yy, xx = np.where(ndimage.binary_dilation(caja, iterations=3))
    borde = int(xs.min()) - 3
    origen = 2 * borde - xx - 1
    espejo = origen >= 0
    fondo[yy[espejo], xx[espejo]] = a[yy[espejo], origen[espejo]]
    resto = ~espejo
    fondo[yy[resto], xx[resto]] = fondo[yy[resto], np.maximum(xx[resto] - CORRIMIENTO_FONDO, 0)]
    chica = Image.fromarray(recorte, "RGBA")
    chica = chica.resize((round(chica.width * ESCALA_PIZZA), round(chica.height * ESCALA_PIZZA)), Image.NEAREST)
    x0 = int((xs.min() + xs.max()) / 2 - chica.width / 2)
    y0 = BASE_PIZZA - chica.height
    salida = Image.fromarray(fondo, "RGBA")
    salida.alpha_composite(chica, (x0, y0))
    mascara = np.zeros(lum.shape, bool)
    alfa = np.asarray(chica)[:, :, 3] > 0
    alto, ancho = alfa.shape
    mascara[y0:y0 + alto, x0:x0 + ancho] = alfa[:max(0, min(alto, lum.shape[0] - y0)), :max(0, min(ancho, lum.shape[1] - x0))]
    return salida, (x0, y0, x0 + chica.width, y0 + chica.height), mascara


def sin_blanco_puro(nombre):
    """Tiñe de crema (#EDE4D6) el blanco casi puro que quedó en una pieza ya guardada."""
    a = abrir(nombre)
    blanco = (a[:, :, :3].min(axis=2) >= 245) & (a[:, :, 3] > 0)
    a[blanco, 0], a[blanco, 1], a[blanco, 2] = (237, 228, 214)
    guardar(a, nombre)
    return int(blanco.sum())


def consistencia():
    for nombre, (hoja, indice, tamano, fraccion) in PIEZAS_CONSISTENCIA.items():
        imagen, cajas = piezas(hoja)
        recorte = recortar(imagen, cajas[indice], fraccion)
        if nombre == "ventana_casa":
            recorte = sin_huecos(recorte)
        if nombre == "vista_pasillo":
            # Lleno: un rectángulo opaco entero (detrás del vidrio), sin recortar al borde opaco.
            a = np.asarray(recorte.convert("RGBA")).copy()
            a[:, :, 3] = 255
            final = Image.fromarray(a, "RGBA").resize(tamano, Image.NEAREST)
            final, caja, mascara = pizza_en_el_toldo(final)
            a = np.asarray(final).copy().astype(float)
            toldo = np.zeros(a.shape[:2], bool)
            toldo[int(tamano[1] * 0.52):, :] = True
            a[toldo & ~mascara, :3] *= OSCURECER_TOLDO
            final = Image.fromarray(a.astype(np.uint8), "RGBA")
            print(f"Vista del pasillo: caja de pizza en {caja} (Nivel1.PIZZA)")
        else:
            final = escalar(recorte, tamano)
        final.save(DESTINO / f"{nombre}.png")
    for nombre in list(PIEZAS_CONSISTENCIA) + ["aranazo_2", "balcon_mini"]:
        cambiados = sin_blanco_puro(nombre)
        print(f"Consistencia: {nombre} {Image.open(DESTINO / f'{nombre}.png').size} ({cambiados} px de blanco teñidos)")


# Derrotas jugosas (Gemini, 2026-10-20, `derrotas.png`): [nombre, caja en la hoja (x0, y0, x1, y1)]. Todo a UNA escala,
# la del ratón (la carcasa partida mide lo que el ratón entero, 64 px). La sombra ovalada bajo el resorte con alma y
# las nubes de pelusa no se usan (la nube son partículas, `DatosDerrota.color_nube`).
DERROTAS = [
    ["derrota_carcasa", (46, 100, 567, 330)],
    ["derrota_resorte", (599, 77, 742, 295)],
    ["derrota_resorte_alma", (791, 71, 940, 295)],
    ["derrota_llave_1", (46, 390, 218, 550)],
    ["derrota_llave_2", (250, 385, 404, 550)],
    ["derrota_llave_3", (471, 385, 509, 550)],
    ["derrota_llave_4", (250, 582, 410, 748)],
    ["derrota_llave_5", (46, 582, 224, 748)],
    ["derrota_tornillo", (611, 582, 678, 672)],
    ["derrota_engranaje", (832, 396, 946, 510)],
    ["derrota_pelusa", (40, 809, 585, 1016)],
]
ESCALA_DERROTAS = 64.0 / 521.0


def derrotas():
    imagen, objeto = sin_fondo(Image.open(ORIGEN / "derrotas.png"))
    for nombre, caja in DERROTAS:
        recorte = recortar_opaco(sin_huecos(imagen.crop(caja)))
        tamano = (max(1, round(recorte.width * ESCALA_DERROTAS)), max(1, round(recorte.height * ESCALA_DERROTAS)))
        final = escalar(recorte, tamano)
        final.save(DESTINO / f"{nombre}.png")
        cambiados = sin_blanco_puro(nombre)
        print(f"Derrotas: {nombre} {Image.open(DESTINO / f'{nombre}.png').size} ({cambiados} px de blanco teñidos)")


# Lo que queda al romperse (decisión del creador, 2026-10-21: «se rompió», no «se evaporó»): pedazos recortados del
# MISMO arte del objeto (misma escala y paleta), cada uno con su contorno de 1 px. [nombre, origen, polígono en pixeles
# del origen]. La planta tirada es la planta de la maceta, sin la maceta. El charco y la tierra los dibuja el juego.
ROTOS = [
    # El fondo curvo del vaso: el pedazo grande (las esquirlas son de vaso_esquirlas()).
    ["roto_vaso_1", "vaso", [(2, 24), (21, 24), (21, 31), (2, 31)]],
    ["roto_taza_1", "taza", [(1, 3), (12, 3), (10, 13), (2, 12)]],
    ["roto_taza_2", "taza", [(9, 10), (20, 9), (19, 20), (11, 19)]],
    ["roto_taza_3", "taza", [(20, 6), (29, 6), (29, 18), (21, 18)]],
    ["roto_maceta_1", "maceta", [(1, 18), (13, 18), (11, 27), (3, 26)]],
    ["roto_maceta_2", "maceta", [(13, 19), (26, 18), (23, 30), (15, 29)]],
    ["roto_maceta_3", "maceta", [(5, 28), (15, 30), (13, 36), (7, 36)]],
]
CONTORNO_ROTO = (43, 29, 26, 255)


def rotos():
    from PIL import ImageDraw
    for nombre, origen, poligono in ROTOS:
        base = Image.open(DESTINO / f"{origen}.png").convert("RGBA")
        mascara = Image.new("L", base.size, 0)
        ImageDraw.Draw(mascara).polygon(poligono, fill=255)
        a = np.asarray(base).copy()
        m = (np.asarray(mascara) > 0) & (a[:, :, 3] > 0)
        a[~m] = 0
        # Contorno de 1 px: el borde de adentro de la pieza (lo cortado también lleva línea, como el resto del arte).
        borde = m & ~ndimage.binary_erosion(m)
        a[borde] = CONTORNO_ROTO
        pieza = recortar_opaco(Image.fromarray(a, "RGBA"))
        pieza.save(DESTINO / f"{nombre}.png")
        print(f"Rotos: {nombre} {pieza.size}")
    vaso_esquirlas()
    maceta = Image.open(DESTINO / "maceta.png").convert("RGBA")
    # La planta (filas 0 a 17 del arte, sin la maceta), entera: queda caída sobre su tierra en el piso. Acostada de lado
    # no se leía (probado 2026-10-21).
    planta = recortar_opaco(maceta.crop((0, 0, maceta.width, 18)))
    planta.save(DESTINO / "planta_tirada.png")
    print(f"Rotos: planta_tirada {planta.size}")


# Recipientes vacíos (decisión del creador, 2026-10-21: «parece que se comió el plato»). Al comer solo desaparece la
# comida: el tazón queda vacío con dos croquetas sueltas y la bandeja del pollo, con los huesitos. Se arman con el MISMO
# arte (filas del recipiente) y lo que falta se dibuja a pixel con la paleta de la pieza y su contorno de 1 px.
CONTORNO_COMIDA = (43, 29, 26, 255)
HUESO = (237, 228, 214, 255)
HUESO_SOMBRA = (196, 178, 156, 255)


def vacios():
    # Tazón: desde el borde (fila 12) hacia abajo; lo que era croqueta dentro del borde pasa a ser el fondo azul oscuro
    # del tazón, con 2 croquetas sueltas.
    a = np.asarray(Image.open(DESTINO / "tazon.png").convert("RGBA")).copy().astype(int)
    alto = a.shape[0]
    azul = (a[:, :, 2] > a[:, :, 0] + 20) & (a[:, :, 3] > 0)
    oscuro = a[azul][np.argmin(a[azul][:, :3].sum(axis=1))]
    medio = a[azul][np.argsort(a[azul][:, :3].sum(axis=1))[len(a[azul]) // 3]]
    fondo = medio[:3]
    croqueta = a[4:7, 21:24].copy()
    v = np.zeros_like(a)
    v[12:] = a[12:]
    cafe = (v[:, :, 0] > v[:, :, 2] + 30) & (v[:, :, 3] > 0)
    v[cafe, :3] = fondo
    v[cafe, 3] = 255
    # El borde de arriba del tazón con su contorno.
    fila = np.where(v[12, :, 3] > 0)[0]
    v[12, fila] = CONTORNO_COMIDA
    for x, y in [(18, 14), (27, 15)]:
        v[y:y + 3, x:x + 3] = croqueta
    Image.fromarray(v.astype(np.uint8), "RGBA").save(DESTINO / "tazon_vacio.png")
    print("Vacíos: tazon_vacio", Image.open(DESTINO / "tazon_vacio.png").size)
    # Bandeja del pollo: la bandeja (desde la fila 31) y el esqueleto del pollo encima, a pixel.
    a = np.asarray(Image.open(DESTINO / "pollo.png").convert("RGBA")).copy()
    v = np.zeros_like(a)
    v[31:] = a[31:]
    def punto(x, y, color):
        v[y, x] = color
    def trazo(puntos):
        for x, y in puntos:
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                if v[y + dy, x + dx, 3] == 0 or tuple(v[y + dy, x + dx]) == CONTORNO_COMIDA:
                    v[y + dy, x + dx] = CONTORNO_COMIDA
        for x, y in puntos:
            v[y, x] = HUESO
    # La carcasa vista de lado: una cúpula de costillas de 27 × 10 apoyada en la bandeja (fila 31), crema con su
    # contorno, y entre costilla y costilla el hueco en sombra (no un peine flotando).
    import math
    cx, base = 31, 30
    cupula = []
    for dx in range(-13, 14):
        arriba = base - round(9 * math.sqrt(max(0.0, 1 - (dx / 13.5) ** 2)))
        for y in range(arriba, base + 1):
            cupula.append((cx + dx, y))
    trazo(cupula)
    # Huecos entre costillas: columnas oscuras de contorno cada 3 px, desde 2 px bajo el borde de la cúpula; la costilla
    # de al lado lleva su sombra. Así se lee «costillas», no «pan».
    for dx in range(-10, 11, 3):
        tope = base - round(9 * math.sqrt(max(0.0, 1 - (dx / 13.5) ** 2))) + 2
        for y in range(tope, base + 1):
            v[y, cx + dx] = CONTORNO_COMIDA
            v[y, cx + dx + 1] = HUESO_SOMBRA
    # El hueso del muslo, acostado sobre la bandeja a la derecha, con su nudo.
    trazo([(x, 29) for x in range(47, 56)])
    trazo([(56, 28), (57, 28), (56, 29), (57, 29), (56, 30), (57, 30)])
    trazo([(46, 28), (46, 30)])
    Image.fromarray(v, "RGBA").save(DESTINO / "pollo_huesos.png")
    print("Vacíos: pollo_huesos", Image.open(DESTINO / "pollo_huesos.png").size)


# Esquirlas del vaso (2026-10-21: los recortes rectos parecían vasitos en miniatura): triángulos y trapecios irregulares
# de 3 a 6 px, en el celeste del vaso, con un brillo claro de 1 px y su contorno. [nombre, polígono en una grilla de 8].
ESQUIRLAS = [
    ["roto_vaso_2", [(0, 7), (4, 0), (7, 7)]],
    ["roto_vaso_3", [(0, 3), (8, 0), (6, 6), (1, 6)]],
    ["roto_vaso_4", [(0, 5), (3, 0), (6, 2), (5, 6)]],
    ["roto_vaso_5", [(0, 6), (7, 0), (5, 6)]],
]


def vaso_esquirlas():
    from PIL import ImageDraw
    vaso = np.asarray(Image.open(DESTINO / "vaso.png").convert("RGBA")).astype(int)
    opaco = vaso[:, :, 3] > 0
    celeste = vaso[14, 6].tolist()
    brillo = vaso[4, 4].tolist() if vaso[4, 4, 3] > 0 else [230, 244, 250, 255]
    for nombre, poligono in ESQUIRLAS:
        ancho = max(x for x, _ in poligono) + 3
        alto = max(y for _, y in poligono) + 3
        mascara = Image.new("L", (ancho, alto), 0)
        ImageDraw.Draw(mascara).polygon([(x + 1, y + 1) for x, y in poligono], fill=255, outline=255)
        m = np.asarray(mascara) > 0
        a = np.zeros((alto, ancho, 4), int)
        a[m] = celeste
        borde = m & ~ndimage.binary_erosion(m)
        a[borde] = CONTORNO_ROTO
        # Brillo de 1 px: el primer pixel de adentro de la fila de más arriba.
        adentro = m & ~borde
        ys, xs = np.where(adentro)
        if len(ys):
            k = np.argmin(ys * 10 + xs)
            a[ys[k], xs[k]] = brillo
        Image.fromarray(a.astype(np.uint8), "RGBA").save(DESTINO / f"{nombre}.png")
        print(f"Esquirlas: {nombre} {ancho}x{alto}")


# Vista del pasillo con la paloma (decisión del creador, 2026-10-21; encargo diseno/encargo-gemini-vista-paloma.md).
# `vista-paloma.png`: a la izquierda la vista sin pizza (ladrillo y toldo), a la derecha la paloma en 3 poses (quieta,
# picoteando, inflada). La vista se ajusta al vidrio (150 × 120) recortando, sin deformar; el borde casi blanco del
# toldo pasa a crema; la paloma va a ~1/4 del alto de la vista, a la densidad de pixel de la vista.
VISTA_PALOMA = (28, 172, 662, 718)
PALOMAS = [("paloma_quieta", (694, 90, 944, 365)), ("paloma_picotea", (676, 490, 972, 662)), ("paloma_inflada", (690, 735, 966, 1015))]
ALTO_PALOMA = 30
## Fila de la vista (ya a 150 × 120) donde empieza el toldo (la barra de arriba).
TOLDO_PALOMA_Y = 33


def vista_paloma():
    hoja, _ = sin_fondo(Image.open(ORIGEN / "vista-paloma.png"))
    vista = Image.open(ORIGEN / "vista-paloma.png").convert("RGBA").crop(VISTA_PALOMA)
    # 150 × 120 = 1,25 : 1; la vista mide ~1,16 : 1, así que se escala por el ancho y se recorta arriba (ladrillo).
    escala = 150 / vista.width
    vista = vista.resize((150, round(vista.height * escala)), Image.NEAREST)
    sobra = vista.height - 120
    vista = vista.crop((0, sobra, 150, sobra + 120))
    a = np.asarray(vista).copy().astype(int)
    a[:, :, 3] = 255
    casi_blanco = a[:, :, :3].min(axis=2) >= 225
    a[casi_blanco, :3] = (237, 228, 214)
    # El toldo un poco más oscuro que el ladrillo (como la vista anterior, B2): se lee como algo de afuera.
    a[TOLDO_PALOMA_Y:, :, :3] = (a[TOLDO_PALOMA_Y:, :, :3] * OSCURECER_TOLDO).astype(int)
    Image.fromarray(a.astype(np.uint8), "RGBA").save(DESTINO / "vista_pasillo.png")
    print("Vista paloma: vista_pasillo", vista.size, f"recortados {sobra} px arriba, {int(casi_blanco.sum())} px crema")
    # La paloma: la misma escala para las 3 poses (la de la quieta da el alto).
    quieta = recortar_opaco(hoja.crop(PALOMAS[0][1]))
    k = ALTO_PALOMA / quieta.height
    for nombre, caja in PALOMAS:
        pose = recortar_opaco(hoja.crop(caja))
        pose = recortar_opaco(sin_sueltos(pose.resize((max(1, round(pose.width * k)), max(1, round(pose.height * k))), Image.NEAREST)))
        pose.save(DESTINO / f"{nombre}.png")
        cambiados = sin_blanco_puro(nombre)
        print("Vista paloma:", nombre, pose.size, cambiados)


if __name__ == "__main__":
    import sys
    if sys.argv[1:] == ["consistencia"]:
        consistencia()
    elif sys.argv[1:] == ["derrotas"]:
        derrotas()
    elif sys.argv[1:] == ["rotos"]:
        rotos()
    elif sys.argv[1:] == ["vacios"]:
        vacios()
    elif sys.argv[1:] == ["paloma"]:
        vista_paloma()
    else:
        main()
