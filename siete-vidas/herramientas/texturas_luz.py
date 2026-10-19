"""Texturas de luz en escalones para la prueba de luz de la sala (LuzCuarto).

Genera en siete-vidas/juego/assets/luz/:
- luz_escalones.png: luz redonda de 4 anillos de tono plano (sin degradado), para la lámpara, el portátil y el LED.
- luz_rayo.png: el rayo de la ventana de la sala, 3 franjas escalonadas inclinadas hacia la derecha (como los rayos
  de FondoApartamento), a escala 1 (un píxel de la textura = un píxel del juego).

Uso: python3 siete-vidas/herramientas/texturas_luz.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

DESTINO = Path(__file__).resolve().parent.parent / "juego" / "assets" / "luz"

# Anillos de la luz redonda: (radio en px de 64, gris).
ANILLOS = [(64, 40), (48, 95), (32, 165), (16, 255)]
# Rayo: el vidrio de la ventana de la sala mide 126 px y el rayo llega al piso 90 px (borde izquierdo) y 140 px
# (borde derecho) más a la derecha, 248 px más abajo. Cada franja entra un 16 % del vidrio por lado.
VIDRIO = 126
BAJA = 248
CORRE_IZQ = 90
CORRE_DER = 140
FRANJAS = [60, 115, 170]


def luz_redonda() -> Image.Image:
    lado = 128
    imagen = Image.new("RGBA", (lado, lado), (0, 0, 0, 255))
    centro = (lado - 1) / 2.0
    for y in range(lado):
        for x in range(lado):
            distancia = ((x - centro) ** 2 + (y - centro) ** 2) ** 0.5
            gris = 0
            for radio, valor in ANILLOS:
                if distancia < radio:
                    gris = valor
            imagen.putpixel((x, y), (gris, gris, gris, 255))
    return imagen


def rayo() -> Image.Image:
    ancho = CORRE_DER + VIDRIO + 8
    imagen = Image.new("RGBA", (ancho, BAJA), (0, 0, 0, 255))
    dibujo = ImageDraw.Draw(imagen)
    for i, valor in enumerate(FRANJAS):
        adentro = VIDRIO * 0.16 * i
        dibujo.polygon([
            (adentro, 0), (VIDRIO - adentro, 0),
            (VIDRIO + CORRE_DER - adentro, BAJA - 1), (CORRE_IZQ + adentro, BAJA - 1),
        ], fill=(valor, valor, valor, 255))
    return imagen


if __name__ == "__main__":
    DESTINO.mkdir(parents=True, exist_ok=True)
    luz_redonda().save(DESTINO / "luz_escalones.png")
    rayo().save(DESTINO / "luz_rayo.png")
    print("Texturas en", DESTINO)
