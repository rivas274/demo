"""Alarga las patas de felipe_color.glb sin regenerar el modelo.

Las patas del modelo IA son muñones: solo asoman ~0,12 unidades bajo la panza. Estirar
en Y una franja horizontal también estira la panza y el pecho (el cuerpo crece en vez
de las patas), así que se hace por columnas:
- Todo el cuerpo sube `alargue` unidades, rígido (cabeza, cuerpo, cola y colores igual).
- Dentro de las 4 columnas de las patas (alrededor de los 4 grupos de vértices más
  bajos), lo que está bajo `Y_ARRIBA` se estira para llenar ese hueco: las manos se
  quedan en el piso sin deformarse y la caña de la pata se alarga.
- Entre la columna y el resto la mezcla es suave (no queda corte).
Uso: python3 estirar_patas.py [alargue=0.45] [salida]
"""
import os
import sys
import numpy as np
import trimesh

AQUI = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(AQUI, "felipe_color.glb")
alargue = float(sys.argv[1]) if len(sys.argv) > 1 else 0.45  # 0,25 / 0,40 / 0,55 probados: 0,45 da patas de ~28 % sin verse flaco
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(AQUI, "felipe_color_patas.glb")
Y_ARRIBA = -0.70   # hasta aquí llega la pata dentro del cuerpo (muslo y hombro)
R_PATA = 0.15      # radio de la columna de cada pata (entera)
R_MEZCLA = 0.26    # aquí ya no se estira nada
MANOS = 0.05       # alto de la mano, que no se estira


def suave(t):
    t = np.clip(t, 0, 1)
    return 3 * t * t - 2 * t * t * t


m = trimesh.load(SRC, force="mesh", process=False)
V = m.vertices.copy()
suelo = V[:, 1].min()

# Columnas: los 4 grupos de vértices más bajos (izquierda/derecha, delante/detrás).
bajos = V[V[:, 1] < suelo + 0.08]
z_mitad = (bajos[:, 2].min() + bajos[:, 2].max()) / 2
cx = (V[:, 0].min() + V[:, 0].max()) / 2
centros = []
for lado in (-1, 1):
    for frente in (False, True):
        s = bajos[(np.sign(bajos[:, 0] - cx) == lado) & ((bajos[:, 2] > z_mitad) == frente)]
        centros.append(s[:, [0, 2]].mean(axis=0))
centros = np.array(centros)
d = np.min(np.linalg.norm(V[:, None, [0, 2]] - centros[None], axis=2), axis=1)
w = 1 - suave((d - R_PATA) / (R_MEZCLA - R_PATA))

# Pata: de la mano (sin estirar) a Y_ARRIBA, estirada para ganar `alargue`.
y = V[:, 1]
cana0, cana1 = suelo + MANOS, Y_ARRIBA
k = 1 + alargue / (cana1 - cana0)
y_pata = np.where(y <= cana0, y, np.where(y >= cana1, y + alargue, cana0 + (y - cana0) * k))
y_cuerpo = y + alargue
V[:, 1] = w * y_pata + (1 - w) * y_cuerpo

out = trimesh.Trimesh(V, m.faces, vertex_colors=m.visual.vertex_colors, process=False)
out.export(OUT, include_normals=True)
pz = V[(np.abs(V[:, 2] - z_mitad) < 0.06) & (np.abs(V[:, 0] - cx) < 0.15)][:, 1].min() - suelo
cab = V[V[:, 2] > 0.2][:, 1].max() - suelo
print("ok alargue %.2f: patas bajo la panza %.2f de %.2f de alto (%.0f %%)" % (alargue, pz, cab, 100 * pz / cab), OUT)
