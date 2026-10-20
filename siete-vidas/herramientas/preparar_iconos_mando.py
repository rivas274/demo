"""Arma los íconos de pixel de los botones de PlayStation (✕ ○ □ △) que le faltan a la hoja de Kenney «Input Prompts
Pixel» (CC0) que usa el juego. Toma el botón redondo vacío de esa hoja (columna 12, fila 0), lo tiñe con el color de cada
botón del paquete «Input Prompts» 1.5 de Kenney (CC0; los originales de 64 px están en
`arte/referencias/kenney-input-prompts/`) y le dibuja el símbolo en pixeles, claro, como las letras de los botones de Kenney. Sin arte de
otros juegos ni logos: son las formas geométricas de los botones, dibujadas de nuevo a 16 px.

Uso: python3 preparar_iconos_mando.py
Escribe siete-vidas/juego/assets/kenney/input-prompts-playstation-pixel.png (4 cuadros de 16 × 16 en fila: cruz,
círculo, cuadrado, triángulo).
"""
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parent.parent
HOJA = RAIZ / "juego" / "assets" / "kenney" / "input-prompts-pixel.png"
ORIGINALES = RAIZ / "arte" / "referencias" / "kenney-input-prompts"
DESTINO = RAIZ / "juego" / "assets" / "kenney" / "input-prompts-playstation-pixel.png"
LADO = 16

# Símbolos de 6 × 6 (1 = pixel del símbolo), centrados en la cara del botón, en claro como las letras de Kenney.
SIMBOLOS = {
    "cross": ["11..11", ".1111.", "..11..", "..11..", ".1111.", "11..11"],
    "circle": [".1111.", "11..11", "1....1", "1....1", "11..11", ".1111."],
    "square": ["111111", "1....1", "1....1", "1....1", "1....1", "111111"],
    "triangle": ["..11..", "..11..", ".1..1.", ".1..1.", "1....1", "111111"],
}
SIMBOLO = (240, 240, 236)
ORDEN = ["cross", "circle", "square", "triangle"]


def main():
    hoja = np.asarray(Image.open(HOJA).convert("RGBA")).astype(float)
    vacio = hoja[0:LADO, 12 * LADO:13 * LADO].copy()
    salida = np.zeros((LADO, LADO * len(ORDEN), 4), np.uint8)
    for i, nombre in enumerate(ORDEN):
        original = Image.open(ORIGINALES / f"playstation_button_color_{nombre}.png").convert("RGBA")
        color = np.array(original.getpixel((14, 32))[:3], float)
        cuadro = vacio.copy()
        # Lo claro del botón (cara y brillo) toma el color del botón, con su luz relativa; el contorno queda.
        luz = cuadro[:, :, :3].mean(axis=2)
        cara = (cuadro[:, :, 3] > 0) & (luz > 150)
        cuadro[cara, :3] = np.clip(color * (luz[cara] / 225.0)[:, None], 0, 255)
        filas = SIMBOLOS[nombre]
        ys, xs = np.where(cara)
        y0 = int(round((ys.min() + ys.max() + 1) / 2 - len(filas) / 2)) - 1
        x0 = int(round((xs.min() + xs.max() + 1) / 2 - len(filas[0]) / 2))
        for y, fila in enumerate(filas):
            for x, c in enumerate(fila):
                if c == "1":
                    cuadro[y0 + y, x0 + x, :3] = SIMBOLO
        salida[:, i * LADO:(i + 1) * LADO] = cuadro.astype(np.uint8)
    Image.fromarray(salida, "RGBA").save(DESTINO)
    print(f"{DESTINO.name}: {len(ORDEN)} cuadros de {LADO} px")


if __name__ == "__main__":
    main()
