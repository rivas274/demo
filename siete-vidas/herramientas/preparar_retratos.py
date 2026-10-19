"""Recorta la hoja de retratos de Valeria y A.S.P.I. que entregó Gemini y la deja lista para el juego.

Entrada: siete-vidas/arte/referencias/gemini/retratos-valeria-aspi.png (JPEG con fondo blanco, 3 x 3 cuadros
con fondo beige; se usan las dos primeras filas).
Salida: siete-vidas/juego/assets/personajes/retratos-valeria-aspi.png, 3 x 2 cuadros de 66 x 66 px:
  fila 1: Valeria neutra, enojada, derretida de ternura
  fila 2: Valeria grabando con el celular, A.S.P.I. normal (luz verde), A.S.P.I. en alerta (luz roja)
Mismo tamaño de cuadro que felipe-retratos.png (200 / 3 px). Uso: python3 siete-vidas/herramientas/preparar_retratos.py
"""
from pathlib import Path

import numpy as np
from PIL import Image

RAIZ = Path(__file__).resolve().parents[1]
ENTRADA = RAIZ / "arte/referencias/gemini/retratos-valeria-aspi.png"
SALIDA = RAIZ / "juego/assets/personajes/retratos-valeria-aspi.png"
LADO = 66


def tramos(perfil: np.ndarray, umbral: float = 0.2) -> list[tuple[int, int]]:
    """Tramos seguidos donde el perfil (fracción de pixeles no blancos) supera el umbral."""
    resultado, inicio = [], None
    for i, valor in enumerate(perfil):
        if valor > umbral and inicio is None:
            inicio = i
        elif valor <= umbral and inicio is not None:
            resultado.append((inicio, i))
            inicio = None
    if inicio is not None:
        resultado.append((inicio, len(perfil)))
    return resultado


def main() -> None:
    imagen = Image.open(ENTRADA).convert("RGB")
    datos = np.asarray(imagen).astype(int)
    no_blanco = np.abs(datos - 255).sum(axis=2) > 30
    columnas = tramos(no_blanco.mean(axis=0))
    filas = tramos(no_blanco.mean(axis=1))[:2]
    hoja = Image.new("RGB", (LADO * 3, LADO * 2))
    for f, (y0, y1) in enumerate(filas):
        for c, (x0, x1) in enumerate(columnas):
            lado = min(x1 - x0, y1 - y0)
            cx, cy = (x0 + x1) // 2, (y0 + y1) // 2
            cuadro = imagen.crop((cx - lado // 2, cy - lado // 2, cx - lado // 2 + lado, cy - lado // 2 + lado))
            hoja.paste(cuadro.resize((LADO, LADO), Image.BOX), (c * LADO, f * LADO))
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    hoja.save(SALIDA)
    print(f"{SALIDA} ({hoja.width}x{hoja.height})")


if __name__ == "__main__":
    main()
