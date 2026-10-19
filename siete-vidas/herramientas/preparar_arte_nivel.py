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
    "comedor": ("muebles-sala", 0, (245, 129), None),  # mesa de 75 cm con dos sillas
    "sofa": ("muebles-sala", 1, (240, 102), None),  # 85 cm de alto
    "aparador": ("muebles-sala", 4, (156, 98), None),  # 81 cm
    "lampara": ("muebles-sala", 3, (34, 160), None),
    "librero": ("muebles-sala", 2, (92, 218), None),  # 1,80 m; sus repisas son plataformas
    # Cocina.
    "alacenas": ("muebles-cocina", 0, (210, 66), None),
    "refrigerador": ("muebles-cocina", 2, (84, 218), None),  # 1,80 m
    "meson": ("muebles-cocina", 3, (204, 109), None),  # 90 cm
    "banco": ("muebles-cocina", 4, (52, 79), None),  # 65 cm
    # Dormitorio.
    "comoda": ("muebles-dormitorio", 0, (84, 97), (0.0, 0.47, 1.0, 1.0)),  # 80 cm, sin el espejo
    "ropero": ("muebles-dormitorio", 1, (104, 185), None),  # 1,53 m
    "cama": ("muebles-dormitorio", 2, (200, 90), None),  # colchón a 55 cm (fila 25 del arte)
    "perchero": ("muebles-dormitorio", 4, (40, 160), None),
    "escalera": ("escalera-fondo", 0, (300, 292), None),  # de fondo: se dibuja en la pared
    # Recibidor y balcón.
    "reja": ("escalera-y-baranda", 1, (64, 91), None),  # una reja para bebés de 75 cm; van dos apiladas
    "baranda": ("escalera-y-baranda", 2, (184, 128), None),
    # Objetos.
    "vaso": ("objetos", 0, (24, 32), None),  # lado menor ≥ 24 (R8)
    "lata": ("objetos", 1, (30, 18), None),
    "plato": ("objetos", 2, (40, 16), None),
    "maceta": ("objetos", 3, (28, 37), None),
    "maceta_grande": ("objetos", 3, (45, 60), None),  # balcón: escalón a la baranda
    "calcetin": ("objetos", 4, (24, 33), None),
    "rollo": ("objetos", 5, (35, 24), None),
    "juguetes": ("objetos", 7, (26, 18), None),
    "caja": ("objetos", 8, (64, 54), None),
    "raton": ("objetos", 9, (62, 54), None),  # escala de gato: la mitad de Felipe
    # Tanda 2.
    "escritorio": ("muebles-extra", 0, (160, 98), None),  # 81 cm, con 30 cm libres debajo
    "caja_arena": ("muebles-extra", 1, (104, 46), None),
    "cojin": ("muebles-extra", 2, (70, 42), None),
    "base_carga": ("muebles-extra", 4, (74, 38), None),
    "repisa": ("muebles-extra", 5, (160, 47), None),
    "puerta_cerrada": ("puertas", 0, (144, 248), None),
    "puerta_abierta": ("puertas", 1, (176, 248), None),
    "puerta_balcon": ("puertas", 2, (176, 212), None),
    "vano": ("puertas", 3, (134, 150), None),
    "cortina": ("detalles", 0, (60, 290), None),
    "bola_pelo": ("detalles", 1, (24, 24), None),
    "aspi_llena": ("detalles", 2, (76, 87), None),  # tapa del depósito abierta
    "mancha": ("detalles", 8, (60, 20), None),
    "retrato": ("cuadros", 0, (84, 100), None),  # retrato oficial de Su Majestad
    "paisaje": ("cuadros", 1, (64, 66), None),
    "reloj": ("cuadros", 2, (46, 48), None),
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
    "reja_v2": ("reja-antifuga", 0, (105, 182), None),  # 1,5 m, en 3/4
    "tazon": ("comida-grande", 0, (48, 35), None),
    "lata_v2": ("comida-grande", 1, (32, 36), None),
    "pollo": ("comida-grande", 2, (64, 50), None),
    "bolsita": ("comida-grande", 3, (28, 32), None),
    "reja_frente": ("reja-antifuga", 0, (48, 182), (0.0, 0.0, 0.69, 1.0)),  # solo la cara de frente, 48 px (decisión del creador)
    "banquito": ("muebles-cocina", 4, (52, 54), None),  # banquito del dormitorio, 45 cm
    # Tanda 3C (nivel 1 v4): sala, recibidor, cocina y ventanas. arriba-extra.png no llegó: baúl, consola,
    # cojín con hueco, retrato familiar, cómoda abierta, ropa, caja de recuerdos, escritorio con pantalla y
    # papeles se dibujan por código o con piezas que ya había.
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
    # A.S.P.I. (escala de gato: más grande que una real); la gigante es imaginación de Felipe.
    "aspi": ("aspi-gemini-1", 0, (76, 47), None),
    "aspi_gigante": ("aspi-gigante", 0, (330, 270), None),
}

# Piezas con huecos (entre patas, barrotes, respaldos): el blanco encerrado también es fondo.
HUECOS = {"llaves", "rascador", "zapatero", "reja_frente", "banquito", "comedor", "aparador", "banco", "baranda", "librero", "perchero", "reja", "lampara", "escritorio", "repisa", "escalera", "puerta_balcon", "mesa_v2", "silla_v2", "librero_v2", "escalera_baranda", "reja_v2"}

# Piezas con patas que hay que alargar para dejar el hueco de agachado (R8): nombre -> (fracción de la pieza donde
# empiezan las patas, alto de las patas en el juego).
PATAS = {"zapatero": (0.80, 38)}

# Rectángulos a borrar después de escalar (x0, y0, x1, y1 en la imagen final): el pasamanos trae dibujado el contorno
# de la escalera (una línea vertical y la del piso) que en el juego no calza con los peldaños de atrás.
BORRAR = {"escalera_baranda": [(0, 80, 4, 217), (0, 202, 186, 217)]}

# Valeria (tanda 3B): poses y caminar, a una sola escala (de pie mide 200 px, 3 Felipes).
VALERIA_POSES = ("valeria-poses", ["neutra", "enojada", "perdonando", "grabando", "serie"])
VALERIA_CAMINAR = ("valeria-caminar", 8)
VALERIA_ALTO = 200

# Texturas que se repiten: nombre -> (hoja, índice, tamaño del mosaico, suavizado).
# El suavizado (0 a 1) acerca cada pixel al color promedio: las paredes no deben competir con Felipe (regla R14).
MOSAICOS = {
    "pared_tapiz": ("paredes", 0, (64, 64), 0.7),
    "pared_azulejo": ("paredes", 1, (48, 48), 0.6),
    "pared_rosa": ("paredes", 2, (64, 64), 0.3),
    "moldura": ("paredes", 3, (192, 14), 0.0),
    "piso": ("paredes", 4, (256, 30), 0.0),
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
    """Poses de Valeria (valeria_<pose>.png) y su caminar (valeria_caminar.png, 8 cuadros iguales) a una sola escala.
    El caminar de Gemini no trae los pies ni el cuerpo en el mismo lugar: cada cuadro se alinea por la línea de los
    pies y por el centro de la cabeza, para que no tiemble."""
    PERSONAJES.mkdir(parents=True, exist_ok=True)
    hoja, nombres = VALERIA_POSES
    imagen, cajas = piezas(hoja)
    escala = VALERIA_ALTO / recortar_opaco(imagen.crop(cajas[0])).height
    for indice, nombre in enumerate(nombres):
        pose = sin_huecos(recortar_opaco(imagen.crop(cajas[indice])))
        tam = (round(pose.width * escala), round(pose.height * escala))
        escalar(pose, tam).save(PERSONAJES / f"valeria_{nombre}.png")
    hoja, cantidad = VALERIA_CAMINAR
    imagen, cajas = piezas(hoja)
    cuadros = []
    for caja in cajas[:cantidad]:
        cuadro = sin_huecos(recortar_opaco(imagen.crop(caja)))
        cuadros.append(escalar(cuadro, (round(cuadro.width * escala), round(cuadro.height * escala))))
    # Centro de la cabeza: promedio de x de los pixeles opacos del 25 % de arriba.
    centros = []
    for c in cuadros:
        a = np.asarray(c)[:, :, 3] > 0
        ys, xs = np.nonzero(a[: max(1, c.height // 4)])
        centros.append(xs.mean())
    izquierda = max(centros)
    derecha = max(c.width - centro for c, centro in zip(cuadros, centros))
    ancho = int(np.ceil(izquierda + derecha)) + 2
    alto = max(c.height for c in cuadros)
    salida = Image.new("RGBA", (ancho * cantidad, alto), (0, 0, 0, 0))
    for i, (c, centro) in enumerate(zip(cuadros, centros)):
        salida.paste(c, (i * ancho + int(round(ancho / 2 - centro)), alto - c.height))
    salida.save(PERSONAJES / "valeria_caminar.png")
    print(f"Valeria: escala {escala:.4f}, caminar de {cantidad} cuadros de {ancho} x {alto}")


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
        final.save(DESTINO / f"{nombre}.png")
    for nombre, (hoja, indice, tamano, suavizado) in MOSAICOS.items():
        if hoja not in hojas:
            hojas[hoja] = piezas(hoja)
        imagen, cajas = hojas[hoja]
        x0, y0, x1, y1 = cajas[indice]
        # Un margen adentro para no arrastrar el borde de la muestra.
        recorte = imagen.crop((x0 + 6, y0 + 6, x1 - 6, y1 - 6)).resize(tamano, Image.NEAREST)
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
    print(f"{len(PIEZAS) + len(MOSAICOS) + len(FONDOS)} imágenes en {DESTINO}")
    preparar_valeria()


if __name__ == "__main__":
    main()
