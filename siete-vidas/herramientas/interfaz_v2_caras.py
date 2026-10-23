#!/usr/bin/env python3
"""Caras de la interfaz v2 (A + C) a su tamaño de pixel, para el juego.

Las mismas que usan la lámina del kit (interfaz_v2_kit_lamina.py): se recortan de las hojas de retratos del juego, se
achican sin suavizar el borde (caja + alfa de corte duro) y llevan el contorno de 1 px del kit. Así el juego no
achica retratos de 66 px en tiempo real (se verían borrosos o con dientes).

Uso:  python3 siete-vidas/herramientas/interfaz_v2_caras.py
Sale: siete-vidas/juego/assets/ui/v2/caras/
  hud-felipe.png (14 px de alto) y hud-felipe-grande.png (28): la cara de la caja de salud, y hud-felipe-golpe
  (orejas planas) para la mueca al recibir un golpe;
  jefe-aspi.png (12): la cara del retrato de la barra del jefe;
  dialogo-<quien>-<n>.png (52): un retrato por ánimo (Felipe 0-8, Valeria 0-3, A.S.P.I. 0-1);
  ficha-felipe.png (48): la cara de la Ficha de Su Majestad (presumido).
"""
from __future__ import annotations

import os

from PIL import Image

import interfaz_v2_kit as kit
import interfaz_v2_laminas as k

DESTINO = os.path.join(k.JUEGO, "assets", "ui", "v2", "caras")


def hojas():
    hoja_f = Image.open(os.path.join(k.JUEGO, "assets", "felipe", "felipe-retratos.png")).convert("RGBA")
    hoja_o = Image.open(os.path.join(k.JUEGO, "assets", "personajes", "retratos-valeria-aspi.png")).convert("RGBA")
    lado_f = hoja_f.width / 3
    lado_o = hoja_o.width // 3

    def cara_f(i):
        x, y = int((i % 3) * lado_f), int((i // 3) * lado_f)
        return k.recortar_opaco(k.quitar_fondo(hoja_f.crop((x, y, int(x + lado_f), int(y + lado_f)))))

    def cara_o(i):
        x, y = (i % 3) * lado_o, (i // 3) * lado_o
        return k.recortar_opaco(k.quitar_fondo(hoja_o.crop((x + 1, y + 1, x + lado_o - 1, y + lado_o - 1)), 40))

    return cara_f, cara_o


def main():
    os.makedirs(DESTINO, exist_ok=True)
    contorno = k.hexa(kit.O["contorno"])
    cara_f, cara_o = hojas()

    def guardar(nombre, im, alto, borde=True):
        chica = k.achicar(im, alto)
        if borde:
            chica = k.con_contorno(chica, contorno)
        chica.save(os.path.join(DESTINO, nombre + ".png"))
        print(nombre, chica.size)

    guardar("hud-felipe", cara_f(0), 14)
    guardar("hud-felipe-grande", cara_f(0), 28)
    # Mueca al recibir un golpe (orejas planas), como la cara de Peppino en Pizza Tower.
    guardar("hud-felipe-golpe", cara_f(1), 14)
    guardar("hud-felipe-golpe-grande", cara_f(1), 28)
    guardar("jefe-aspi", cara_o(4), 12)
    guardar("ficha-felipe", cara_f(7), 48)
    for i in range(9):
        guardar(f"dialogo-felipe-{i}", cara_f(i), 52)
    for i in range(4):
        guardar(f"dialogo-valeria-{i}", cara_o(i), 52)
    for i in range(2):
        guardar(f"dialogo-aspi-{i}", cara_o(4 + i), 52)


if __name__ == "__main__":
    main()
