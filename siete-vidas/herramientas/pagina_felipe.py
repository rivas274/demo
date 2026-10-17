"""Genera la página de Felipe (guía + animaciones en movimiento) como un HTML autocontenido.

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
    {"id": "sc-idle", "nombre": "Quieto", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-idle-sheet.png", "frames": 8, "fps": 8},
    {"id": "sc-walk", "nombre": "Caminar", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-walk-sheet.png", "frames": 8, "fps": 10},
    {"id": "sc-run", "nombre": "Correr / Zoomies", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-run-sheet.png", "frames": 8, "fps": 12},
    {"id": "sc-attack", "nombre": "Zarpazo", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-attack-sheet.png", "frames": 8, "fps": 12},
    {"id": "sc-eat", "nombre": "Comer snack", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-eat-sheet.png", "frames": 8, "fps": 8},
    {"id": "sc-jump", "nombre": "Saltar", "origen": "SpriteCook", "costo": "20 créditos",
     "archivo": "felipe-jump-sheet.png", "frames": 8, "fps": 10},
    {"id": "code-idle", "nombre": "Quieto", "origen": "Código (gratis)", "costo": "0 créditos",
     "archivo": "codigo/felipe-quieto-codigo-sheet.png", "frames": 8, "fps": 6},
    {"id": "code-walk", "nombre": "Caminar", "origen": "Código (gratis)", "costo": "0 créditos",
     "archivo": "codigo/felipe-caminar-codigo-sheet.png", "frames": 8, "fps": 10},
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
    pesos = []
    for nombre, etiqueta in [("flaco", "Flaco"), ("normal", "Normal"), ("gordito", "Gordito"), ("buda", "Modo Buda")]:
        p = ARTE / "pesos" / f"felipe-quieto-{nombre}-sheet.png"
        if nombre == "buda":
            p = ARTE / "felipe-buda-quieto-sheet.png"
        if p.exists():
            w, h = Image.open(p).size
            pesos.append({"nombre": etiqueta, "src": data_uri(p), "frames": 8, "fps": 8, "fw": w // 8, "fh": h})
    base = ARTE / "felipe-A-base.png"
    bw, bh = Image.open(base).size
    html = TEMPLATE.replace("__ANIMS__", json.dumps(anims)).replace("__PESOS__", json.dumps(pesos)).replace("__BASE__", data_uri(base)) \
        .replace("__BW__", str(bw)).replace("__BH__", str(bh))
    Path(sys.argv[1]).write_text(html, encoding="utf-8")


TEMPLATE = Path(__file__).with_name("pagina_felipe.template.html").read_text(encoding="utf-8")

if __name__ == "__main__":
    main()
