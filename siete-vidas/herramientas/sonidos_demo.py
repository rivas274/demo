"""Genera los sonidos provisionales de la demo (WAV 22 kHz, mono) con síntesis simple, sin dependencias.

Uso: python3 sonidos_demo.py <carpeta_salida> [nombre ...]
Se reemplazarán por sonidos finales (jsfxr o grabados) más adelante.
"""
import math
import random
import struct
import sys
import wave
from pathlib import Path

TASA = 22050


def tono(f0, f1, dur, forma="cuadrada", vol=0.35, ruido=0.0):
    n = int(TASA * dur)
    fase = 0.0
    muestras = []
    for i in range(n):
        t = i / n
        f = f0 + (f1 - f0) * t
        fase += 2 * math.pi * f / TASA
        if forma == "cuadrada":
            v = 1.0 if math.sin(fase) >= 0 else -1.0
        elif forma == "triangulo":
            v = 2 / math.pi * math.asin(math.sin(fase))
        else:
            v = math.sin(fase)
        v = v * (1 - ruido) + (random.uniform(-1, 1) * ruido)
        envolvente = min(1.0, i / (TASA * 0.005)) * (1 - t) ** 1.5
        muestras.append(v * vol * envolvente)
    return muestras


def guardar(ruta, muestras):
    with wave.open(str(ruta), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(TASA)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, m)) * 32767)) for m in muestras))


SONIDOS = {
    "salto": lambda: tono(220, 520, 0.14, "cuadrada", 0.25),
    "zarpazo": lambda: tono(900, 200, 0.09, "triangulo", 0.35, ruido=0.5),
    "golpe": lambda: tono(180, 60, 0.22, "cuadrada", 0.35, ruido=0.3),
    "comer": lambda: tono(500, 700, 0.06, "triangulo", 0.3) + tono(600, 900, 0.08, "triangulo", 0.3),
    "vidrio": lambda: tono(2400, 1800, 0.25, "seno", 0.25, ruido=0.7),
    "logro": lambda: tono(523, 523, 0.09, "triangulo", 0.3) + tono(659, 659, 0.09, "triangulo", 0.3) + tono(784, 784, 0.2, "triangulo", 0.3),
    "calcetin": lambda: tono(880, 1320, 0.12, "triangulo", 0.3),
    "caja": lambda: tono(160, 90, 0.18, "cuadrada", 0.3, ruido=0.6),
    "batalla": lambda: tono(147, 147, 0.1, "cuadrada", 0.4, ruido=0.2) + tono(147, 147, 0.1, "cuadrada", 0.4, ruido=0.2)
    + tono(110, 55, 0.7, "cuadrada", 0.45, ruido=0.4),
    "succion": lambda: tono(90, 600, 1.4, "seno", 0.3, ruido=0.85),
    "puf": lambda: tono(500, 70, 0.35, "seno", 0.35, ruido=0.6),
    # Nivel 1 v4: acciones de gato y reacciones.
    "maullido": lambda: tono(520, 780, 0.12, "triangulo", 0.3) + tono(780, 420, 0.3, "triangulo", 0.3),
    "aranar": lambda: tono(1400, 900, 0.07, "seno", 0.2, ruido=0.9) + tono(1300, 800, 0.07, "seno", 0.2, ruido=0.9),
    "ronroneo": lambda: tono(55, 60, 0.45, "cuadrada", 0.18, ruido=0.4) + tono(60, 55, 0.45, "cuadrada", 0.18, ruido=0.4),
    "goteo": lambda: tono(1900, 1100, 0.05, "seno", 0.28) + tono(1100, 700, 0.06, "seno", 0.12),  # «plic» de la llave y del baño
    "resorte": lambda: tono(300, 900, 0.08, "seno", 0.3) + tono(900, 250, 0.18, "seno", 0.3),
    # Pelea con A.S.P.I. v3 (2026-10-23): ganchos de sonido provisionales (los finales, en el encargo de 05).
    "motor": lambda: tono(70, 90, 0.5, "cuadrada", 0.18, ruido=0.5),
    # El motor falla con el depósito lleno (v4): dos tosidos que caen de tono, con un silencio entre medio.
    "falla": lambda: tono(110, 60, 0.09, "cuadrada", 0.22, ruido=0.6) + [0.0] * 1500 + tono(90, 40, 0.14, "cuadrada", 0.22, ruido=0.7),  # sube de tono con cada mancha (pitch en el juego)
    "reversa": lambda: tono(1000, 1000, 0.12, "cuadrada", 0.2) + [0.0] * 1800 + tono(1000, 1000, 0.12, "cuadrada", 0.2),
    "atragantar": lambda: tono(180, 90, 0.2, "cuadrada", 0.3, ruido=0.5) + tono(220, 60, 0.35, "cuadrada", 0.3, ruido=0.6),
    "pitido": lambda: tono(1400, 1400, 0.08, "cuadrada", 0.22) + tono(1900, 1900, 0.12, "cuadrada", 0.22),  # se despierta
    "cortocircuito": lambda: tono(2600, 300, 0.12, "cuadrada", 0.3, ruido=0.9) + tono(1800, 200, 0.18, "cuadrada", 0.3, ruido=0.9)
    + tono(120, 40, 0.4, "cuadrada", 0.35, ruido=0.5),
}

if __name__ == "__main__":
    random.seed(7)
    salida = Path(sys.argv[1])
    salida.mkdir(parents=True, exist_ok=True)
    # Con nombres después de la carpeta, solo esos (los demás no se tocan).
    pedidos = sys.argv[2:] or list(SONIDOS)
    for nombre in pedidos:
        guardar(salida / f"{nombre}.wav", SONIDOS[nombre]())
