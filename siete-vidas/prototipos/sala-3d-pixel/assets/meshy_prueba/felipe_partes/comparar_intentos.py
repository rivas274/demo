"""Compara varios intentos (semillas) de HoloPart por pieza y propone el mejor.

Uso: python comparar_intentos.py <original.glb> <etiquetas.npy> <piezas.json> <salida.json> semilla=archivo.glb [...]

Métricas por pieza e intento:
  cerrada   la malla es cerrada (watertight)
  trozos    componentes conectados (1 es lo ideal)
  fuera     fracción de la superficie que queda fuera del modelo original a más de 1 % de su tamaño
            (faldones y aletas que se salen)
  cobertura distancia media de la zona original de la pieza a la superficie generada, en % del tamaño
            (si la pieza no cubre lo que debía)
Puntaje (menor es mejor): 3*fuera + cobertura + 0.5*(trozos-1) + 1*(no cerrada).
"""
import json
import sys

import numpy as np
import trimesh

orig_ruta, et_ruta, piezas_ruta, salida = sys.argv[1:5]
intentos = dict(a.split("=", 1) for a in sys.argv[5:])

orig = trimesh.load(orig_ruta, force="mesh", process=False)
orig_cerrada = trimesh.Trimesh(orig.vertices, orig.faces)
orig_cerrada.merge_vertices()
et = np.load(et_ruta)
piezas = json.load(open(piezas_ruta, encoding="utf-8"))
tam = orig.extents.max()
# "Dentro del original" con vóxeles rellenos: la prueba por rayos de trimesh se queda sin memoria (88k caras).
ocupado = orig_cerrada.voxelized(tam / 160).fill()
escenas = {s: trimesh.load(r) for s, r in intentos.items()}
rng = np.random.default_rng(0)

resultado = {}
for k, nombre in enumerate(piezas):
    filas = []
    zona = orig.submesh([np.where(et == k)[0]], append=True)
    pts_zona = zona.sample(3000)
    for semilla, esc in escenas.items():
        if nombre not in esc.geometry:
            continue
        g = esc.geometry[nombre]
        trozos = len(g.split(only_watertight=False))
        pts = g.sample(4000)
        cerca, dist, _ = trimesh.proximity.closest_point(orig_cerrada, pts)
        dentro = ocupado.is_filled(pts)
        fuera = float(np.mean((~dentro) & (dist > 0.01 * tam)))
        _, d_cob, _ = trimesh.proximity.closest_point(g, pts_zona)
        cobertura = float(d_cob.mean() / tam * 100)
        puntaje = 3 * fuera * 100 / 10 + cobertura + 0.5 * (trozos - 1) + (0 if g.is_watertight else 1)
        filas.append(dict(semilla=semilla, cerrada=bool(g.is_watertight), trozos=trozos,
                          fuera=round(fuera, 3), cobertura=round(cobertura, 2), puntaje=round(puntaje, 2)))
    if filas:
        filas.sort(key=lambda f: f["puntaje"])
        resultado[nombre] = filas
        print(nombre)
        for f in filas:
            print("   ", f)
json.dump(resultado, open(salida, "w"), indent=1)
