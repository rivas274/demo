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
    "alacenas": ("muebles-cocina", 0, (210, 66), None),
    "refrigerador": ("muebles-cocina", 2, (84, 218), None),  # 1,80 m
    "meson": ("muebles-cocina", 3, (204, 109), None),  # 90 cm
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
    "reja_frente": ("reja-antifuga", 0, (48, 182), (0.0, 0.0, 0.69, 1.0)),  # solo la cara de frente, 48 px (decisión del creador)
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
    "ventana_pasillo": ("ventanas-patio", 1, (180, 54), None),  # el alféizar es la fila del borde de la repisa
    # arriba-extra (Gemini, la mandó el creador; revisión 3): reemplaza lo que se dibujaba por código.
    "baul": ("arriba-extra", 0, (70, 48), None),  # 40 cm, se pasa por delante (cabe entre la puerta y la consola)
    "cojin": ("arriba-extra", 2, (70, 48), None),  # cojín redondo con hueco: descanso del pasillo
    "retrato_familiar": ("arriba-extra", 3, (100, 80), None),  # Felipe tapa a toda la familia (M8 de la revisión 2)
    "ropa_limpia": ("arriba-extra", 6, (52, 48), None),  # ropa doblada de la cama (interactuable, lado menor ≥ 24)
    "ropa_pelos": ("arriba-extra", 7, (52, 48), None),  # la misma, después de que Felipe se acicala encima
    "caja_recuerdos": ("arriba-extra", 8, (44, 33), None),  # lugar visto: repisa alta del dormitorio
    "monitor": ("arriba-extra", 9, (44, 48), (0.08, 0.0, 0.48, 0.50)),  # del escritorio con monitor e impresora
    "impresora": ("arriba-extra", 9, (44, 34), (0.54, 0.13, 0.94, 0.48)),
    "papel": ("arriba-extra", 10, (30, 16), None),  # papel plano en el piso (mancha de la pelea)
    "papel_arrugado": ("arriba-extra", 11, (16, 20), None),  # papeles que escupe la impresora
    # A.S.P.I. (escala de gato: más grande que una real); la gigante es imaginación de Felipe.
    "aspi": ("aspi-gemini-1", 0, (76, 47), None),
    "aspi_gigante": ("aspi-gigante", 0, (330, 270), None),
}

# Piezas con huecos (entre patas, barrotes, respaldos): el blanco encerrado también es fondo.
HUECOS = {"llaves", "rascador", "zapatero", "reja_frente", "banquito", "aparador", "baranda", "lampara", "escritorio", "repisa", "mesa_v2", "silla_v2", "librero_v2", "escalera_baranda"}

# Piezas con patas que hay que alargar para dejar el hueco de agachado (R8): nombre -> (fracción de la pieza donde
# empiezan las patas, alto de las patas en el juego).
PATAS = {"zapatero": (0.80, 38)}

# Rectángulos a borrar después de escalar (x0, y0, x1, y1 en la imagen final): el pasamanos trae dibujado el contorno
# de la escalera (una línea vertical y la del piso) que en el juego no calza con los peldaños de atrás.
# La baranda trae tres macetas encima: se borra la del medio para que Felipe se siente en la baranda sin meterse en
# ella (M6 de la revisión 2); RELLENOS repone la baranda que tapaba la maceta.
BORRAR = {"escalera_baranda": [(0, 80, 4, 217), (0, 202, 186, 217)], "baranda": [(70, 0, 121, 36)]}

# Rellenos después de escalar: (x0, y0, x1, y1, desde, periodo) repite en ese rectángulo las columnas que van de
# `desde` a `desde + periodo` (un tramo limpio del mismo dibujo).
RELLENOS = {"baranda": [(70, 36, 121, 62, 58, 18)]}

# Parches después de escalar: (x0, y0, x1, y1, dx) copia en ese rectángulo los pixeles que están dx a la izquierda
# en la imagen original. La ventana del pasillo traía la caja de pizza sobre el alféizar (adentro, al alcance):
# se tapa con el marco y el alféizar de al lado, y la caja se dibuja por código afuera, tras el vidrio (G3).
PARCHES = {"ventana_pasillo": [(114, 28, 153, 33, 32), (104, 33, 163, 54, 56)]}

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
    "libro": ("objetos", 6, (28, 8), None),  # libro achatado sobre el banquito (D-3)
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


def ventana_marco():
    """G3: marco de la ventana de la sala para las ventanas de código, en 9 partes: sin el vidrio, la persiana de
    adentro ni el alféizar (se recorta la fila 0 a 137 y las columnas 9 a 171; el centro queda transparente)."""
    v = abrir("ventana_sala")[0:138, 9:171]
    v[26:138, 18:144, 3] = 0
    guardar(v, "ventana_marco")
    print(f"Marco de ventana: {v.shape[1]} x {v.shape[0]} (bordes 18, 18, 26, 8)")


def recoloreos():
    # P-3: la ventana del pasillo deja la madera crema y pasa a la madera de la ventana de la sala (sin tocar el toldo
    # ni la vista de afuera, que están tras el vidrio: columnas 77 a 163, filas de arriba).
    v = abrir("ventana_pasillo")
    rgb = v[:, :, :3].astype(int)
    crema = (v[:, :, 3] > 0) & (rgb.min(axis=2) > 120) & (rgb.max(axis=2) - rgb.min(axis=2) < 75)
    crema[0:42, 77:163] = False
    guardar(recolorear(v, crema, (178, 117, 73), 187.0), "ventana_pasillo")
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
    # C-2: alacenas recortadas a dos módulos (la mitad izquierda del mesón); sobre el microondas no queda nada.
    a = abrir("alacenas")
    guardar(np.concatenate([a[:, :116], a[:, -2:]], axis=1), "alacenas")
    print("Recoloreos: ventana del pasillo, peldaños, zapatero, alacenas")


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


def ambientes():
    for nombre, (hoja, indice, tamano, fraccion) in PIEZAS_AMBIENTE.items():
        imagen, cajas = piezas(hoja)
        escalar(recortar(imagen, cajas[indice], fraccion), tamano).save(DESTINO / f"{nombre}.png")
    puertas_unificadas()
    vano_alto()
    ventana_marco()
    recoloreos()
    telas()
    tanda_3e()
    pisos_gemini()


if __name__ == "__main__":
    main()
