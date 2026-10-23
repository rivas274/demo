#!/usr/bin/env python3
"""Hoja de revisión de la interfaz v2 EN EL JUEGO: capturas reales al lado de la lámina aprobada.

Arriba, cada pantalla de la lámina (direccion-arte-AC-v2.png, la que rearma kit-v2.png) junto a la captura del juego
que le corresponde; abajo, el resto de las capturas (golpe, pocas huellas, desmayo, opciones, libreta, resumen...).

Uso:  python3 siete-vidas/herramientas/interfaz_v2_juego_hoja.py <carpeta de capturas_interfaz_v2.gd>
Sale: siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/juego-v2.png
"""
from __future__ import annotations

import os
import sys

from PIL import Image, ImageDraw

import interfaz_v2_laminas as k

O = {"fondo": "#241A26", "texto": "#FFF0D5", "felipe": "#E8913A", "oportunidad": "#FFE066", "apagado": "#8A7480"}
# Pantalla de la lámina (recorte en direccion-arte-AC-v2.png) → captura del juego.
PARES = [
    ("1 · Exploración y diálogo", (0, 24, 640, 360), "01-exploracion-dialogo.png"),
    ("2 · Pelea: salud, jefe, aviso y globito", (640, 24, 640, 360), "15-pelea-aviso-oportunidad.png"),
    ("3 · Cartel de travesura", (0, 388, 640, 360), "03-cartel.png"),
    ("4 · Pausa: lista, bolsillo y Ficha", (640, 388, 640, 360), "06-pausa.png"),
    ("Texto grande (200 %)", (0, 752, 640, 236), "08-texto-grande.png"),
]
OTRAS = [
    ("Felipe habla (sombra ámbar)", "01b-dialogo-felipe.png"),
    ("Golpe: la huella destella y la cara hace una mueca", "02-golpe-huella.png"),
    ("Logro a la derecha (zona C)", "04-logro.png"),
    ("Pocas huellas: laten y «empate técnico»", "05-pocas-huellas.png"),
    ("Desmayo: 9 gatitos fantasma", "09-desmayo-fantasmas.png"),
    ("Se miran y vuelven", "09b-desmayo-se-miran.png"),
    ("«Siesta táctica.» con todo lleno", "10-siesta-tactica.png"),
    ("Pelea: barra del jefe y globito", "13-pelea-barra-globito.png"),
    ("Daño reciente en la barra del jefe", "14-pelea-dano-reciente.png"),
    ("Texto grande: logro", "08b-texto-grande-logro.png"),
    ("Opciones: accesibilidad primero", "07-opciones.png"),
    ("Libreta (letra de 16)", "11-libreta.png"),
    ("Resumen del día (siestas tácticas)", "12-resumen.png"),
]


def main():
    carpeta = sys.argv[1]
    lamina = Image.open(os.path.join(k.CAPTURAS, "direccion-arte-AC-v2.png")).convert("RGBA")
    ancho = 8 + 640 + 8 + 640 + 8
    alto = 40 + sum(h + 22 for _, (_, _, _, h), _ in PARES) + ((len(OTRAS) + 1) // 2) * (360 + 22) + 30
    hoja = Image.new("RGBA", (ancho, alto), k.hexa(O["fondo"]))
    d = ImageDraw.Draw(hoja)
    k.texto(hoja, (8, 8), "INTERFAZ V2 · A + C · EN EL JUEGO", k.SK16, O["felipe"])
    k.texto(hoja, (8, 24), "Izquierda: la lámina aprobada (kit-v2.png).  Derecha: captura real del juego a 640x360, sin "
            "retoques.", k.F16, O["texto"])
    y = 48
    for nombre, (x0, y0, w, h), archivo in PARES:
        k.texto(hoja, (8, y), f"{nombre} · lámina", k.F8, O["apagado"])
        k.texto(hoja, (656, y), f"{nombre} · juego", k.F8, O["oportunidad"])
        hoja.alpha_composite(lamina.crop((x0, y0, x0 + w, y0 + h)), (8, y + 12))
        ruta = os.path.join(carpeta, archivo)
        if os.path.exists(ruta):
            cap = Image.open(ruta).convert("RGBA").resize((640, 360), Image.NEAREST).crop((0, 0, w, h))
            hoja.alpha_composite(cap, (656, y + 12))
        d.rectangle([8, y + 12, 8 + w - 1, y + 12 + h - 1], outline=k.hexa("#120C12"))
        y += h + 22
    k.texto(hoja, (8, y), "MÁS CAPTURAS DEL JUEGO", k.SK16, O["felipe"])
    y += 22
    for i, (nombre, archivo) in enumerate(OTRAS):
        x = 8 + (i % 2) * 648
        yy = y + (i // 2) * (360 + 22)
        k.texto(hoja, (x, yy), nombre, k.F8, O["texto"])
        ruta = os.path.join(carpeta, archivo)
        if os.path.exists(ruta):
            hoja.alpha_composite(Image.open(ruta).convert("RGBA").resize((640, 360), Image.NEAREST), (x, yy + 12))
    salida = os.path.join(k.CAPTURAS, "juego-v2.png")
    hoja.save(salida)
    print(salida, hoja.size)


if __name__ == "__main__":
    main()
