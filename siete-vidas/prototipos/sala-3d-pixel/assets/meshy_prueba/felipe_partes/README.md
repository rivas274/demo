# Felipe por piezas (2026-10-22): cortes del creador y HoloPart en local

## Qué hay

| Archivo | Qué es |
|---|---|
| `etiquetas.npy` | Pieza de cada cara de `../felipe_meshy.glb`, cargado con trimesh `force="mesh", process=False` (88.912 caras). Los índices corresponden al orden de `piezas.json`. |
| `piezas.json` | Los 15 nombres. Izquierda y derecha son las de Felipe: su izquierda es +X. |
| `superficie/felipe_piezas_superficie.glb` | La superficie original **con la textura de Meshy**, partida en las 15 piezas. Las piezas son superficies abiertas, sin la geometría escondida. |
| `holopart/<pieza>.glb` | Cada pieza completada y cerrada por HoloPart. Unas 10.000 caras, **sin textura**. |
| `despiece_holopart.png`, `despiece_superficie.png` | Arriba, el modelo armado (3/4 y lado). Abajo, el despiece. Cada pieza va en un color. |
| `holopart_piezas.png` | Cada pieza de HoloPart sola, en dos ángulos. |
| `segmentacion_vistas.png`, `segmentacion_control.png` | La segmentación en 8 vistas, y las caras proyectadas sobre las plantillas para comprobar la alineación. |
| `segmentar_v8.py`, `correr_holopart.py`, `despiece_blender.py` | Los scripts (en la PC están en `C:\IA3D`). |

## Segmentación con las marcas del creador (`segmentar_v8.py`)

- Usa `../plantilla_esqueleto/mascaras_perfil.png` y `mascaras_frente.png`, con la misma proyección que `vistas.gd`: centro del AABB y lado = 1,15 × la mayor extensión (2,184) para 1024 px.
- **Cuerpo:** grupa y pecho salen de los dos círculos de `creador_perfil_cuerpo.png`, ajustados por mínimos cuadrados. Cada cara va al círculo más cercano.
- **Patas:** son los contornos grandes de perfil, desde el hombro y la cadera.
  - Delanteras: el lado sale del contorno del frente.
  - Traseras: el lado sale del signo de X.
  - La franja central de la panza queda en el cuerpo.
- **Melena:** el contorno del pecho visto de frente, solo la mitad delantera.
- **Cola:** se parte en 3 tramos con las curvas del dibujo. Los mechones que se salen del contorno también cuentan como cola.
- **Cabeza:** el contorno de perfil, con la papada. Las orejas y los mechones de mejilla tienen que caer en el contorno del frente **y** en el de perfil a la vez.
- Después hay un suavizado por mayoría entre caras vecinas, y las islas chicas pasan a la pieza vecina.

## HoloPart local (RTX 4060, 8 GB)

- `C:\IA3D\HoloPart`, con 50 pasos y semilla 42. Tardó 44 minutos en total y llegó a un máximo de 7,4 GB de VRAM.
- Cambios respecto del repo original:
  - La extracción es con marching cubes de skimage, porque diso no tiene binario para Windows.
  - Mi propio bucle evita un bug de `run_holopart`, que pasa `final_octree_depth` a una función que no lo acepta.
  - Guarda los latentes por pieza.
- No se usaron los demos en línea:
  - El demo de Hunyuan3D-Part en Hugging Face da `RuntimeError` incluso con sus ejemplos.
  - Los demos de HoloPart piden 600 s de GPU, por encima de la cuota gratis.

| Pieza | Resultado |
|---|---|
| cabeza | **Bien**: completa y cerrada. |
| cola_punta, cola_medio | **Bien**: cerradas. |
| cuerpo_grupa | **Bien**: una masa cerrada. |
| oreja_izq | **Bien**: cerrada. |
| melena | **Aceptable**: un cuenco cerrado, con el borde de arriba algo irregular. |
| pata_del_izq/der, pata_tras_izq/der | **Cerradas, pero delgadas**: el pie sale bien, pero la parte del flanco es una cáscara fina, porque el contorno solo cubre la piel de ese lado. Para animar con huesos pueden servir; si las quieres con volumen, hay que darles un "relleno" dentro del cuerpo. |
| cola_base | **Mal**: sale con un faldón ancho donde toca el cuerpo. No está cerrada. |
| oreja_der | **Regular**: trae una aleta delgada en la base. No está cerrada. |
| cuerpo_pecho | **Mal**: quedan fragmentos, porque la melena y las patas delanteras se llevan casi toda su superficie. |
| mechon_izq, mechon_der | **Mal**: basura en decenas de trozos. Son demasiado chicos (unas 600 caras) para HoloPart. |

**Propuesta:**
- Las piezas malas se pueden reemplazar por formas simples. El pecho sería una esfera, como la que dibujó el creador.
- Los mechones y la oreja derecha se pueden tomar de la superficie original con textura (`superficie/`), o reflejar la oreja izquierda.
- La textura de las piezas de HoloPart se transfiere desde `felipe_meshy.glb` por punto más cercano. Las etiquetas por cara sirven para limitar la búsqueda a la misma pieza.

## Actualización: el mejor de 5 semillas (regla del creador: al menos 5 intentos)

Las 5 piezas que salieron mal se repitieron con las semillas 1, 7, 123 y 2026, además de la 42 original. `comparar_intentos.py` puntúa cada intento según:
- si está cerrada;
- en cuántos trozos sale;
- qué fracción de la superficie queda fuera del modelo original;
- qué tan bien cubre la zona original de la pieza.

Después hubo una revisión visual de todos los intentos (`intentos_5_semillas.png`). Los puntajes están en `comparacion_intentos.json`.

| Pieza | Elegida | Antes (semilla 42) | Ahora |
|---|---|---|---|
| cuerpo_pecho | s123 | 5 fragmentos, abierta | 1 pieza cerrada |
| oreja_der | s2026 | aleta, abierta | cerrada |
| mechon_izq | s123 | 104 trozos | 1 lámina cerrada (delgada) |
| mechon_der | s2026 | 52 trozos | 1 pieza cerrada (delgada) |
| cola_base | s123 | faldón, abierta | cerrada, **pero el faldón sigue** |

**El faldón de cola_base sale en las 5 semillas porque está en el modelo de Meshy.** El 30 % de la superficie de esa zona mira hacia abajo: la raíz de la cola se abre como un ala sobre la grupa. Para quitarlo hay que recortarlo a mano, o redibujar la base de la cola más arriba.

**Las 15 piezas de `holopart/` ya están cerradas.** Juntas están en `felipe_partes_holopart.glb`, con el despiece en `despiece_holopart.png`. Las patas siguen siendo cáscaras delgadas por el flanco: eso viene del contorno dibujado, no de la semilla.
