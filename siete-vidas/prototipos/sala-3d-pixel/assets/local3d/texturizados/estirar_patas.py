"""Alarga las patas de felipe_color.glb sin regenerar el modelo.

Estira en Y solo la franja de las patas (del piso a un poco más arriba de la panza)
y funde el estirón hacia arriba en una franja de transición, para que no quede corte.
Todo lo de arriba (cuerpo, cabeza, cola) sube igual, sin deformarse; los colores no
cambian. Uso: python3 estirar_patas.py [estiron=0.6] [salida]
"""
import os
import sys
import numpy as np
import trimesh

AQUI = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(AQUI, "felipe_color.glb")
estiron = float(sys.argv[1]) if len(sys.argv) > 1 else 0.6  # 0,4 y 0,5 se probaron: 0,6 se ve persa grande, no flaco
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(AQUI, "felipe_color_patas.glb")

m = trimesh.load(SRC, force="mesh", process=False)
V = m.vertices.copy()
suelo = V[:, 1].min()
Y_PATAS = -0.76   # hasta aquí se estira entero (la panza está en -0,86; los muslos, en -0,75)
Y_FIN = -0.64     # aquí el estirón ya se apagó


def densidad(y):
    """Factor de estirón en cada altura: 1+e en las patas, 1 arriba, suave entre medio."""
    t = np.clip((y - Y_PATAS) / (Y_FIN - Y_PATAS), 0, 1)
    return 1 + estiron * (1 - (3 * t * t - 2 * t * t * t))


# y nueva = suelo + integral de la densidad desde el piso (sube todo lo de arriba igual).
malla = np.linspace(suelo, V[:, 1].max(), 4000)
acum = np.concatenate([[0], np.cumsum((densidad(malla[1:]) + densidad(malla[:-1])) / 2 * np.diff(malla))])
V[:, 1] = suelo + np.interp(V[:, 1], malla, acum)
out = trimesh.Trimesh(V, m.faces, vertex_colors=m.visual.vertex_colors, process=False)
out.export(OUT, include_normals=True)
print("ok estiron %.2f alto %.3f -> %.3f" % (estiron, np.ptp(m.vertices[:, 1]), np.ptp(V[:, 1])), OUT)
