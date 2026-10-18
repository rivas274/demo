"""Genera la ficha de Felipe (guía del personaje: acciones, animaciones aprobadas, rasgos y proporciones) como un HTML autocontenido.

Uso: python3 pagina_felipe.py <salida.html>
Lee los sprites de siete-vidas/arte/felipe/.
"""
import base64
import json
import sys
from pathlib import Path

from PIL import Image

ARTE = Path(__file__).resolve().parent.parent / "arte" / "felipe"

ANIMS = [
    {"id": "sc-idle", "nombre": "Quieto", "godot": "quieto", "archivo": "felipe-idle-sheet.png", "frames": 8, "fps": 8},
    {"id": "sc-walk", "nombre": "Caminar", "godot": "caminar", "archivo": "felipe-walk-sheet.png", "frames": 8, "fps": 10},
    {"id": "sc-run", "nombre": "Correr / Zoomies", "godot": "correr", "archivo": "felipe-run-sheet.png", "frames": 8, "fps": 12},
    {"id": "sc-jump", "nombre": "Saltar", "godot": "saltar", "archivo": "felipe-jump-sheet.png", "frames": 8, "fps": 10},
    {"id": "sc-gatear", "nombre": "Gatear", "godot": "gatear", "rehacer": True, "archivo": "felipe-gatear-sheet.png", "frames": 8, "fps": 10,
     "escala": 0.4 / 0.72},
    {"id": "sc-attack", "nombre": "Zarpazo", "godot": "zarpazo", "archivo": "felipe-attack-sheet.png", "frames": 8, "fps": 12},
    {"id": "sc-eat", "nombre": "Comer", "godot": "comer", "archivo": "felipe-eat-sheet.png", "frames": 8, "fps": 8},
    {"id": "sc-purr", "nombre": "Ronronear", "godot": "ronronear", "archivo": "felipe-purr-sheet.png", "frames": 8, "fps": 8},
    {"id": "sc-faint", "nombre": "Desmayo", "godot": "desmayo", "archivo": "felipe-faint-sheet.png", "frames": 8, "fps": 8},
    # Ocio: desde Felipe A, mismos cuadros de 106 px.
    {"id": "sc-acicalarse", "nombre": "Ocio: acicalarse", "godot": "acicalarse", "archivo": "felipe-acicalarse-sheet.png",
     "frames": 8, "fps": 8},
    {"id": "sc-jugar", "nombre": "Ocio: jugar con estambre", "godot": "jugar", "archivo": "felipe-jugar-sheet.png",
     "frames": 8, "fps": 10},
    {"id": "sc-vueltas", "nombre": "Ocio: perseguirse la cola", "godot": "vueltas", "archivo": "felipe-vueltas-sheet.png",
     "frames": 8, "fps": 10},
]


def data_uri(path):
    return "data:image/png;base64," + base64.b64encode(path.read_bytes()).decode()


def main():
    anims = []
    for a in ANIMS:
        p = ARTE / a["archivo"]
        if not p.exists():
            continue
        w, h = Image.open(p).size
        anims.append({**a, "src": data_uri(p), "fw": w // a["frames"], "fh": h})
    base = ARTE / "felipe-A-base.png"
    bw, bh = Image.open(base).size
    extras = {}
    for clave, archivo in [("cono", "felipe-cono.png"), ("retratos", "felipe-retratos.png"), ("caida", "felipe-caida-sheet.png")]:
        p = ARTE / archivo
        if p.exists():
            w, h = Image.open(p).size
            extras[clave] = {"src": data_uri(p), "w": w, "h": h}
    html = TEMPLATE.replace("__EXTRAS__", json.dumps(extras)).replace("__ANIMS__", json.dumps(anims)).replace("__BASE__", data_uri(base)) \
        .replace("__BW__", str(bw)).replace("__BH__", str(bh))
    Path(sys.argv[1]).write_text(html, encoding="utf-8")


TEMPLATE = Path(__file__).with_name("pagina_felipe.template.html").read_text(encoding="utf-8")

if __name__ == "__main__":
    main()
