#!/usr/bin/env python3
"""Pone el kit de interfaz v2 (A + C) en el tema del juego (siete-vidas/juego/datos/ui/tema.tres).

Lee la tabla de piezas de siete-vidas/juego/assets/ui/v2/README.md (tamaño del PNG, medida lógica, ancla y cortes) y
escribe en el tema, tipo «Felipe»:

- un estilo `styles/v2_<pieza>` (StyleBoxTexture) por cada pieza que se estira a lo ancho: los cortes son sus
  `texture_margin_left/right` (arriba y abajo 0: el alto es fijo) y la sombra y el contorno quedan como
  `expand_margin_*`, así el juego dibuja la caja con su MEDIDA LÓGICA (la del layout) y el PNG cae solo en su lugar,
  igual que `poner()` en la lámina del kit;
- un ícono `icons/v2_<pieza>` por cada pieza que no se estira (huellas, flechas, sello, íconos, fondos de retrato) y
  por cada cara de assets/ui/v2/caras/ (`v2_cara_<nombre>`);
- los colores de la paleta del kit con nombre (`ui_fondo`, `ui_panel`, ..., `personaje_felipe`...).

Se puede correr las veces que haga falta: borra lo «v2_» que hubiera y lo vuelve a poner.
Uso:  python3 siete-vidas/herramientas/interfaz_v2_tema.py
"""
from __future__ import annotations

import os
import re

from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JUEGO = os.path.join(RAIZ, "juego")
KIT = os.path.join(JUEGO, "assets", "ui", "v2")
TEMA = os.path.join(JUEGO, "datos", "ui", "tema.tres")

# Paleta del kit (README del kit) con el nombre que usa el juego.
COLORES = {
    "ui_fondo": "241A26", "ui_panel": "30242C", "ui_linea": "F4E2BB", "ui_texto": "FFF0D5", "ui_apagado": "8A7480",
    "ui_contorno": "120C12", "ui_sombra": "0B070B", "personaje_felipe": "E8913A", "oportunidad": "FFE066",
    "personaje_valeria": "D8336B", "personaje_aspi": "E04848", "ui_maquina": "4CC9E0", "felipe_luz": "F4C89C",
    "felipe_oscuro": "9D622C", "ui_vacio": "504049", "aspi_luz": "EE9A9A",
}


def piezas():
    """[(nombre, png (w, h), logica (w, h) o None, ancla (x, y), cortes (izq, der) o None)] de la tabla del README."""
    filas = []
    with open(os.path.join(KIT, "README.md"), encoding="utf-8") as f:
        for linea in f:
            m = re.match(r"\| `([a-z0-9-]+)\.png` \| (\d+)x(\d+) \| ([^|]+) \| ([^|]+) \| ([^|]+) \|", linea)
            if not m:
                continue
            nombre = m.group(1)
            png = (int(m.group(2)), int(m.group(3)))
            logica = None
            ml = re.match(r"\s*(\d+)x(\d+)", m.group(4))
            if ml:
                logica = (int(ml.group(1)), int(ml.group(2)))
            ancla = (0, 0)
            ma = re.match(r"\s*\((\d+), (\d+)\)", m.group(5))
            if ma:
                ancla = (int(ma.group(1)), int(ma.group(2)))
            cortes = None
            mc = re.search(r"izq (\d+), der (\d+)", m.group(6))
            if mc:
                cortes = (int(mc.group(1)), int(mc.group(2)))
            filas.append((nombre, png, logica, ancla, cortes))
    return filas


def caras():
    carpeta = os.path.join(KIT, "caras")
    return sorted(f[:-4] for f in os.listdir(carpeta) if f.endswith(".png"))


def id_de(nombre: str) -> str:
    return "v2_" + nombre.replace("-", "_")


def main():
    with open(TEMA, encoding="utf-8") as f:
        texto = f.read()
    # Quita lo v2 anterior (recursos, subrecursos y claves).
    texto = re.sub(r'\[ext_resource type="Texture2D" path="res://assets/ui/v2/[^"]+" id="v2_[^"]+"\]\n', "", texto)
    texto = re.sub(r'\[sub_resource type="StyleBoxTexture" id="v2_[^"]+"\]\n(?:[^\[\n][^\n]*\n)*\n', "", texto)
    texto = re.sub(r"Felipe/(?:styles|icons)/v2_[^\n]+\n", "", texto)
    for nombre in COLORES:
        texto = re.sub(rf"Felipe/colors/{nombre} = [^\n]+\n", "", texto)

    ext, sub, claves = [], [], []
    for nombre, png, logica, ancla, cortes in piezas():
        i = id_de(nombre)
        ext.append(f'[ext_resource type="Texture2D" path="res://assets/ui/v2/{nombre}.png" id="{i}"]')
        if cortes and logica:
            izq, der = cortes
            sub.append("\n".join([
                f'[sub_resource type="StyleBoxTexture" id="{i}_estilo"]',
                f'texture = ExtResource("{i}")',
                f"texture_margin_left = {float(izq)}",
                f"texture_margin_right = {float(der)}",
                f"expand_margin_left = {float(ancla[0])}",
                f"expand_margin_top = {float(ancla[1])}",
                f"expand_margin_right = {float(png[0] - logica[0] - ancla[0])}",
                f"expand_margin_bottom = {float(png[1] - logica[1] - ancla[1])}",
                "",
            ]))
            claves.append(f'Felipe/styles/{i} = SubResource("{i}_estilo")')
        else:
            claves.append(f'Felipe/icons/{i} = ExtResource("{i}")')
    for cara in caras():
        i = "v2_cara_" + cara.replace("-", "_")
        ext.append(f'[ext_resource type="Texture2D" path="res://assets/ui/v2/caras/{cara}.png" id="{i}"]')
        claves.append(f'Felipe/icons/{i} = ExtResource("{i}")')
    for nombre, hexa in COLORES.items():
        r, g, b = (int(hexa[j:j + 2], 16) / 255 for j in (0, 2, 4))
        claves.append(f"Felipe/colors/{nombre} = Color({r:.6g}, {g:.6g}, {b:.6g}, 1)")

    # Recursos externos después del último ext_resource; subrecursos antes de [resource]; claves al final.
    ultimo_ext = [m.end() for m in re.finditer(r"\[ext_resource [^\n]+\n", texto)][-1]
    texto = texto[:ultimo_ext] + "\n".join(ext) + "\n" + texto[ultimo_ext:]
    pos = texto.index("[resource]")
    texto = texto[:pos] + "\n".join(sub) + "\n" + texto[pos:]
    texto = texto.rstrip("\n") + "\n" + "\n".join(claves) + "\n"
    n_ext = len(re.findall(r"\[ext_resource ", texto))
    n_sub = len(re.findall(r"\[sub_resource ", texto))
    texto = re.sub(r"load_steps=\d+", f"load_steps={n_ext + n_sub + 1}", texto, count=1)
    with open(TEMA, "w", encoding="utf-8") as f:
        f.write(texto)
    print(f"{len(ext)} texturas, {len(sub)} estilos, {len(COLORES)} colores en {TEMA}")


if __name__ == "__main__":
    main()
