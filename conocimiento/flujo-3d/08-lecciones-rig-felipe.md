# Lecciones del rig de Felipe (prototipo descartado el 2026-10-23)

Lista completa de lecciones del rig, tal como quedaron en la memoria del proyecto antes de descartar el 3D. El prototipo se borró del repositorio. Para recuperarlo:

```
git checkout 8cc2445 -- siete-vidas/prototipos/sala-3d-pixel
```

- **Primera lección:** para animar un modelo 3D hecho con IA, el método estándar es:
  1. retopología en cuadriláteros (QuadriFlow o Instant Meshes);
  2. hornear la textura en UVs nuevas;
  3. esqueleto estándar (Rigify «Cat»; Mixamo para humanos);
  4. pesos automáticos y suavizados, probados posando;
  5. animación con poses clave mirando video de referencia.
- **Por qué:** la malla de IA es una «estatua» sin bucles en las articulaciones. Cortarla en piezas o moverla con fórmulas no resuelve la causa.
- **Lecciones del rig de Felipe (2026-10-22, prototipo `sala-3d-pixel`, detalle en su `INFORME.md`):**
  - **Pesos sin cortes duros.** Una regla seca entre huesos (por ejemplo, "la pata no toma la panza") pliega la piel y en el toon parece una sombra rara. Lo estándar es desvanecer el peso con una rampa y suavizarlo entre vecinos. Fuente: manual de Blender, *Weight Paint › Smooth* y *Limit Total*.
  - **El muslo y el brazo solo toman la piel de la pata.** La grupa y el flanco siguen a la pelvis y a la escápula. Si no, giran con la pata.
  - **En bpy, al borrar los grupos de un vértice,** primero hay que guardar sus índices. Si se borra mientras se recorre `v.groups`, la colección se corre y quedan restos (más de 4 huesos, suma mayor que 1).
  - **Pies con IK, pivote en la bola del pie y polos** (como el rig «paw» de Rigify). Se animan los controles y se hornea a los huesos: el pie apoyado no patina.
  - **El torso gira en la cadera** al pararse, sentarse o saltar, y las patas en el aire se ponen relativas al torso. Así ninguna pata se estira de más.
  - **Cola viva: overlapping action.** Cada hueso va 2 a 4 cuadros atrás del anterior y con más amplitud hacia la punta. Encima, en el motor, un resorte amortiguado aditivo (spring o jiggle bones) que reacciona a la aceleración. Fuente: Richard Williams, *The Animator's Survival Kit* (overlapping action); jiggle/spring bones de los motores.
  - **Simetría primero:** el personaje se arma simétrico en reposo (Symmetrize de la malla de alta, retopo cortada al medio y espejada con Mirror, pesos espejados con .L y .R) y la asimetría la pone la animación. Una mano 6 cm atrás en la malla de IA hacía que esa pata "se metiera" al caminar. Fuente: flujo estándar de modelado y rigging de personajes (Blender, *Symmetrize* y *Mirror Vertex Groups*).
  - **Manchas de pelaje:** si la textura de IA no tiene el patrón real, limpiarla no lo arregla. Se dibuja el patrón de las fotos en un mapa del cuerpo y se pasa a la textura.
  - **Anatomía dentro del pelo:** las patas de un cuadrúpedo empiezan dentro del cuerpo. La cadera va en la grupa con el fémur hacia adelante, y la escápula detrás del cuello con el húmero hacia atrás. El flanco y el hombro siguen a esos huesos con pesos suaves. El estirar y aplastar del torso no se hereda en patas, cuello ni cola (`inherit_scale` = NONE). Fuente: anatomía de cuadrúpedo digitígrado y rigs de cuadrúpedos (Rigify «paw»).
  - **Engrosar una parte de la malla:** se empuja desde el eje del miembro, no por la normal (con normales ruidosas la superficie se arruga), y se suaviza después.
  - **Contorno toon:** casco invertido de 1 px más el post-proceso de profundidad y normales. Bajar mucho el umbral de profundidad ensucia el escenario. Fuente: técnica estándar de cel shading (inverted hull y bordes por Sobel).
  - **Simetría sí, pero no en la cara de un modelo de IA.** La cara viene expresiva y algo asimétrica, y espejarla la aplana y hunde los ojos. Cuerpo simétrico; cabeza proyectada sobre la original, con más densidad. Los pesos de calor se calculan en la malla base y se transfieren (Data Transfer).
  - **Partes que se aplastan al doblar** (manos, pies): se dejan rígidas en su hueso, con la mezcla arriba de la articulación, y se mide su volumen en cada cuadro.
  - **Contorno:** no subir la sensibilidad del post-proceso global por un personaje, porque ensucia toda la escena a pixel ×3. El casco invertido en mallas con normales ruidosas deja puntos. Antes de dar un ajuste por bueno, comparar contra la versión anterior en el mismo cuadro.
  - **Entregas animadas en MP4** (H.264, yuv420p, faststart), no en GIF: en la app del creador los GIF no se reproducen solos.
  - **Cabeza grande con cámara alta:** la cabeza gira hacia la cámara y sube un poco al caminar (capa en el motor). Es la técnica de los juegos de vista lateral y arregla el "cerebro gigante" mejor que achicarla. Detalle en `conocimiento/flujo-3d/03-rig-y-animacion-cuadrupedo.md`.
  - **Límite de proporciones chibi:** con las patas delanteras cortas, Felipe no puede sentarse erguido con las manos en el piso. Su sentado es bajo.
