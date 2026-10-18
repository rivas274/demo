"""Genera los sonidos provisionales de la demo (WAV 22 kHz, mono) con síntesis simple, sin dependencias.

Uso: python3 sonidos_demo.py <carpeta_salida>
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
}

if __name__ == "__main__":
    random.seed(7)
    salida = Path(sys.argv[1])
    salida.mkdir(parents=True, exist_ok=True)
    for nombre, generar in SONIDOS.items():
        guardar(salida / f"{nombre}.wav", generar())
