# Rig y animación de un cuadrúpedo hecho con IA (receta estándar en Blender)

## Qué problema resuelve

Animar un animal (gato, perro) generado con IA para que se mueva natural, sin «masa», sin cortes y sin textura estirada. La malla de IA es **una estatua**: una sopa de triángulos sin bucles en las articulaciones. Hay que rehacerla antes de animar.

## Receta paso a paso

Todo se puede correr por script con **Blender como módulo de Python** (`pip install bpy==5.2.3`, sirve también en la nube sin pantalla). Un script por paso, en orden.

### 1. Retopología (malla nueva y limpia)
1. Importa el GLB, aplica transformaciones y centra con el piso en z = 0.
2. **Voxel Remesh** (unos 6 mm en un gato de 55 cm): cierra la malla y une las islas sueltas (había 127) en una sola pieza.
3. **Simetría primero:** busca el plano medio, aplica **Symmetrize** desde la mitad buena y **suelda** (5 mm cerró la costura). El personaje se arma simétrico en reposo; la asimetría la pone la animación.
4. **QuadriFlow** a unos **7.700 cuadriláteros**. Para que quede simétrica, córtala al medio y espéjala con **Mirror** soldado (la simetría de QuadriFlow dejaba una grieta en el centro).
5. **Shrinkwrap** a la original para no perder la forma. Relaja zonas con escalones, sin tocar la cara.
6. **Revisa la cara antes y después:** con poca densidad se aplana (regresión vista en Felipe).

### 2. Textura
Hornea el color desde la malla alta con «Selected to Active» (ver [02-texturas.md](02-texturas.md)).

### 3. Esqueleto con anatomía real
- Parte del **metarig de gato de Rigify** y recórtalo (en Felipe, 34 huesos: raíz, columna de 4, cuello, cabeza, 2 orejas, cola de 5 y por pata cintura + 3 segmentos + dedos).
- **Anatomía de cuadrúpedo digitígrado, dentro del pelo:**
  - **Trasera:** cadera arriba en la grupa → fémur **hacia adelante** y abajo → rodilla → tibia **hacia atrás** → corvejón → metatarso casi vertical → dedos.
  - **Delantera:** escápula arriba, detrás del cuello → hombro en la punta del pecho → húmero **hacia atrás** → codo bajo el pecho → antebrazo casi vertical → muñeca → mano.
- **Las patas empiezan dentro del cuerpo:** la pata visible es solo la punta. Las traseras son más largas y grandes, así que **la grupa queda más alta que los hombros**.
- Para ubicar huesos y cortes, dale al creador **plantillas ortográficas con cuadrícula** (perfil y frente) para que marque a mano dónde van; luego se leen por script.
- Cola de 5 huesos (con 4 se dobla en codo, no en curva).

### 4. Pesos
1. **Automatic Weights** (pesos de calor).
2. **Suavizar** entre vecinos; nada de cortes duros (un corte seco pliega la piel y en el toon parece una sombra rara). El peso de la pata se desvanece en una rampa.
3. **Máximo 4 huesos por vértice**, normalizado (Godot no acepta más).
4. **Cabeza rígida:** toda a su hueso, con un anillo de mezcla solo donde nace el cuello; la cara no se mezcla.
5. **El flanco sigue al fémur** con caída suave hacia la cadera; el hombro sigue a la escápula y al húmero. El muslo no se lleva la grupa.
6. Ninguna pata toma vértices del otro lado ni del centro de la panza.
7. **Pesos espejados** (.L ↔ .R), como Mirror Vertex Groups.
8. El estirar y aplastar del torso no se hereda en patas, cuello ni cola (`inherit_scale = NONE`), o las patas no llegan al piso.
9. Sin Preserve Volume: Godot usa skinning lineal.
10. **Prueba posando** (patas a ±35°, cola, cabeza) antes de animar.

**Trampa de bpy:** al borrar grupos de un vértice, guarda primero los índices. Si borras mientras recorres `v.groups`, la colección se corre y quedan restos (más de 4 huesos, suma mayor que 1).

### 5. Animación con poses clave (a mano, mirando video real)
- **Graba o busca video del animal real** y toma notas por acción (cómo pisa, dónde va la cola).
- **Controles de animador:** IK en cada pie con **pivote en la bola del pie** y polos en rodilla y codo. Se animan los controles y se hornea a los huesos: el pie apoyado no patina.
- **Ciclo de caminar** (Richard Williams, *The Animator's Survival Kit*):
  - **0,67 s** por ciclo; **apoyo del 60 %** del ciclo.
  - Secuencia lateral: trasera izq., delantera izq., trasera der., delantera der.
  - 9 poses por pata con **breakdowns**: contacto, bajada, apoyo medio, talón arriba, despegue, recoge, paso, adelanta, estira. Vuelo en arco Bezier; apoyo lineal.
  - Grupa y hombros bajan por turnos al recibir el peso; la columna se tuerce.
  - **Cabeza estabilizada:** compensa el cabeceo del cuerpo y mira adelante.
  - Mide el patinaje del pie apoyado (en Felipe, 2,3 mm, menos de medio pixel).
- **Cola con overlapping action / follow-through:** cada hueso 2 a 4 cuadros atrás del anterior y más amplitud hacia la punta. Nunca congelada en quieto.
- **Acciones:** el torso gira en la cadera y las patas en el aire se ponen relativas al torso, así ninguna se estira de más. Anticipación antes de saltar, aterrizaje con las delanteras primero.
- Entrada, bucle y salida separados para acciones largas (arañar, pedir).

### 6. Exportar
- Hornea a los huesos que deforman, borra los controles y exporta **GLB** con las animaciones con nombre. Guarda en un JSON la velocidad del ciclo y las marcas (despegue, aterrizaje).
- En Godot: el nodo avanza a la velocidad medida; el arco del salto lo hace Godot entre las marcas; encima, un **resorte amortiguado** por hueso de la cola como capa aditiva que reacciona a la aceleración (jiggle o spring bones).

## Límites conocidos con proporciones chibi
- Patas delanteras cortas: el gato no puede sentarse erguido con las manos en el piso; su sentado es bajo.
- Engrosar una parte: empuja desde el eje del miembro, no por la normal (con normales ruidosas la piel se arruga), y suaviza.
- QuadriFlow da una malla pareja, no bucles pensados por articulación: funciona si es densa; un modelador la mejoraría.
- **Cabeza grande vista desde una cámara alta:** si la caminata lleva la cabeza baja, la cámara ve sobre todo la coronilla ("cerebro gigante"). La técnica estándar de los juegos de vista lateral es que la cabeza gire hacia la cámara (~30°, con suavizado) y suba un poco al caminar, como capa en el motor. Ayuda mucho más que achicar la cabeza. Retoques de forma mínimos (cráneo 8 % más chico y hocico 3 mm afuera) completan el arreglo sin cambiar la expresión.
- **La mirada a cámara es un gesto, no una regla:** de espaldas o dándose vuelta la cabeza sigue al cuerpo; al caminar, un giro sutil (~12°); en quieto, miradas ocasionales de 1 a 2 s. Mirar siempre a la cámara se ve raro.
- **Objetos que el personaje toca** (una pelota): no van en el modelo. Exporta los tiempos de contacto y la posición del pie en ese momento, y que el motor mueva el objeto.
- **No simetrizar la cara de un modelo de IA:** el cuerpo sí, pero la cara se proyecta sobre la original con más densidad. Espejarla la aplana y hunde los ojos.

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Se deforma como masa | Pesos por distancia sobre la malla de IA | Retopología + pesos de calor suavizados |
| Sombra rara entre muslo y panza | Corte duro de pesos | Rampa + suavizado entre vecinos |
| Una pata «se mete» al caminar | La malla de IA tenía una mano 6 cm atrás | Symmetrize antes de todo |
| Patas que no llegan al piso al saltar | Heredan la escala del torso | `inherit_scale = NONE` |
| Caminata «de juguete» | Ciclo lento, sin breakdowns ni desfases | 0,67 s, 60 % de apoyo, breakdowns, cabeza estabilizada |
| La mano se aplastó al animar | Regresión no revisada | Comparar cada versión con la anterior |

## Fuente o ejemplo

- Scripts en orden: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_rig/scripts/` (`01_retopo.py`, `02_textura.py`, `03_rig.py`, `04_poses.py`, `05_anima.py`, `anima_locomocion.py`, `anima_acciones.py`, `simetria.py`).
- Plantillas para marcar huesos: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/plantilla_esqueleto/`.
- Uso en Godot (resorte de la cola): `siete-vidas/prototipos/sala-3d-pixel/scripts/felipe_rig.gd`.
- Detalle de las versiones v1 a v6: `siete-vidas/prototipos/sala-3d-pixel/INFORME.md` («Felipe con rig hecho en Blender»); lecciones: `siete-vidas/memoria/01-decisiones.md` («Pilar de trabajo»).

## Cola gruesa como tubo articulado (lecciones de Felipe v7, 2026-10-23)
- **Problema:** una cola pegada a la malla del cuerpo, con pesos de calor, se deforma feo al sentarse o agacharse. La grupa se mueve con la cola y los anillos se pliegan.
- **Receta estándar:** malla de tubo aparte con anillos regulares, base metida en la grupa, a lo sumo 2 huesos por anillo con mezcla suave en cada junta y UV continuo a lo largo. La grupa no lleva peso de cola.
- **Línea central desde la cola vieja:** usa el eje medio (`skimage.morphology.skeletonize`) de su silueta de perfil y el camino más corto entre la base y la punta. Los extremos del esqueleto se doblan hacia las esquinas: recórtalos y suaviza.
  - El radio sacado de la distancia al borde mide de menos cuando el eje no queda centrado. Compáralo por área con la silueta vieja.
- **Pliegues:** si el radio de curvatura es menor que el grosor, el lado de adentro se pliega. Suaviza la línea hasta que el radio supere el grosor y achica solo el lado de adentro.
  - Mídelo con el paso entre anillos del lado de adentro, dividido por el paso del centro. Si es negativo, los anillos se cruzan.
- **Cantidad de huesos:** con una cola tan gruesa como el largo de sus huesos, 5 huesos no alcanzan para enrollarla (cada junta dobla más de 40° y se pliega). Usa 8 o más y reparte la curva. Para apoyarla en el piso y rodear las patas, usa spline IK horneado a los huesos, con el camino tomado de la envolvente del cuerpo desplazada en el radio del tubo.
- **Tapar el agujero** de la cola vieja: rellenar, subdividir, relajar con el borde fijo e inflar un poco. Un relleno plano se ve como una faceta.
- **Blender (bmesh):** `subdivide_edges` y agregar capas invalidan las referencias de Python a los vértices. Marca lo que necesites en capas `int` creadas antes de operar.

