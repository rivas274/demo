# Prototipo: sala-3d-pixel
Fecha: 2026-10-21 · Carpeta: siete-vidas/prototipos/sala-3d-pixel/

## Pregunta
Si el juego se hace en **3D renderizado como pixel art** (cámara ortográfica, render chico, luz en escalones y contorno de 1 px), la sala se verá mejor y Valeria se moverá con más vida que con los sprites de pocas poses. Lo notaremos en la comparación lado a lado y en el clip: ¿la sala 3D se ve igual de bien o mejor, y los personajes se ven más vivos?
Suposición más arriesgada: que los personajes 3D se parezcan a Felipe y a Valeria y no se vean como maniquíes en una maqueta.

Pedidos del creador durante el trabajo:
1. No importa que se vea como otro juego (estamos en concepto); hay que buscar que la sala 3D se vea lo mejor posible por sí misma.
2. Un Felipe 3D para comparar.
3. Un Felipe y una Valeria hechos **desde su imagen** con IA de imagen a 3D.
4. Pixel más grande, bordes mejores (exterior e interior, sin antialias) y menos degradados.
5. Plan B sin servicios externos: darle esqueleto y caminata a la Valeria IA.

## Qué se construyó (versión 2; la v3 cambia a Valeria, ver más abajo)
- **Tubería en Godot 4.3 Forward+:**
  - Escena 3D con cámara ortográfica de lado inclinada 18°, dibujada en un `SubViewport` chico y mostrada a 1280×720 con escala entera y filtro nearest.
  - Pixel de render a **×2, ×3 o ×4** (tecla 4). El predeterminado es **×3** (render de 427×240).
  - El encuadre no cambia con el tamaño del pixel: Felipe mide lo mismo que 67 px del juego y Valeria 1,65 m (unos 200 px del juego).
  - La cámara sigue a Valeria moviéndose solo en múltiplos exactos de un pixel de render, así que no hay bordes que bailen.
  - MSAA, FXAA y TAA apagados, y sombras sin suavizado.
- **Bordes nuevos (post-proceso por profundidad y normales):**
  - **Contorno exterior** de 1 pixel de render donde salta la profundidad. Lo dibuja solo el pixel más cercano y su color es el tono del objeto oscurecido y mezclado con un café profundo; nunca negro puro.
  - **Contorno interior**, más claro, donde cambian las normales: brazos sobre el cuerpo, cojines del sofá, patas, cola sobre el lomo y cajones.
  - Umbrales duros, sin medios píxeles. Reemplaza al casco invertido de la versión 1, que solo marcaba la silueta.
- **Menos degradados:** el shader toon corta el sol y el relleno en 2 tonos y la lámpara en 3. Con la sombra ambiente (plana y algo violeta) quedan **3 a 4 tonos por material**. La paleta global de 55 colores quedó opcional (tecla 1, apagada por defecto) porque corría los colores del sprite de Felipe hacia violeta.
- **La sala:** pared con papel a rayas, ventana con persiana y cielo de atardecer (el sol entra y proyecta la persiana en el piso), piso de tablas, sofá, alfombra, mesita con **lámpara encendida** (luz cálida con sombra, en anillos), librero, libros, plantas y un cuadro. Los muebles son de Kenney (CC0) y están recoloreados.
- **Personajes en escena:**
  - **Valeria maniquí** (Quaternius, CC0) con animaciones reales: camina, gira, se sienta en el sofá, se queda, se para y se va, en un bucle de unos 17 s. Con Tab pasa a modo manual (flechas).
  - **Felipe IA** (Hunyuan3D-2, desde Felipe A): camina con rebote y balanceo, salta al sofá junto a Valeria con estirar y aplastar de ±8 %, se queda respirando (±2 %), baja y vuelve.
  - **Valeria IA** (Hunyuan3D-2, desde su pose de pie de Gemini): de pie junto a la ventana, respirando.
  - **Felipe de primitivas** (versión 1) y **Felipe 2D** (su sprite como `Sprite3D` a 0.72), quietos a la derecha para comparar.
- Quedó fuera a propósito: control de Felipe, colisiones, HUD, sonido, esqueleto para los modelos IA y la casa entera.

Para abrirlo: Godot 4.3 → `siete-vidas/prototipos/sala-3d-pixel/project.godot` → F5. Teclas: **1** paleta, **2** bordes, **3** escalones de luz, **4** tamaño de pixel (×2, ×3 o ×4), **Tab** guion o manual, **F1** ayuda. El proyecto ahora usa **Forward+**, que necesita Vulkan; cualquier PC con tarjeta de video de los últimos años lo tiene.

## Qué pasó
Capturas y clips (sin jugadores de verdad; falta que el creador lo mire), en `/tmp/claude-0/-home-user-demo/38ed3265-b77e-553c-bb05-17ea4f4a88e4/scratchpad/proto3d/`:
- `sala-3d-pixel-v2.mp4`: clip de 17 s con pixel ×3 y bordes nuevos.
- `hoja-tamano-pixel.png`: el mismo cuadro con pixel ×2, ×3 y ×4.
- `hoja-felipe-v2.png`: Felipe A 2D, sprite en la sala, primitivas, IA e IA en el sofá (×3), más la escena completa.
- `hoja-valeria-v2.png`: sprite del juego, concepto Gemini, maniquí animado y Valeria IA.
- `sala-3d-pixel-v3.mp4` y `hoja-valeria-v3.png`: Valeria IA con esqueleto automático (ver la sección v3).
- Versión 1 (comparación con la sala actual): `hoja-sala-2d-vs-3d.png`, `hoja-felipe-2d-vs-3d.png` y `sala-3d-pixel.mp4`.

Lo que se ve en el clip:
- **0 a 4 s:** Valeria maniquí entra caminando y Felipe IA entra por la izquierda con rebote y balanceo; Valeria IA respira junto a la ventana.
- **4 a 6 s:** Valeria se sienta. **6 s:** Felipe IA salta al cojín a su lado. **6 a 11 s:** los dos sentados bajo la luz de la lámpara.
- **11 a 17 s:** Felipe baja y vuelve a su sitio; Valeria se para y se va.

## Tamaño del pixel y bordes: por qué ×3
- **×2 (640×360):** es la resolución del juego actual. Los personajes y caras se leen mejor, pero el 3D se nota "3D a baja resolución": muchas diagonales finas y detalles de 1 px.
- **×3 (427×240), el elegido:** se lee como pixel art pintado. Bloques claros, contornos que se notan, la luz de la lámpara en anillos limpios y la persiana todavía legible. La cara de Felipe IA y la de Valeria IA siguen reconocibles: ojos y nariz alcanzan a ser 1 o 2 pixeles.
- **×4 (320×180):** el sprite de Felipe y las caras se rompen (ojos de medio pixel que desaparecen), la persiana se vuelve ruido y el sofá pierde los cojines. Sirve para un juego de estilo más tosco, no para este.
- **Bordes:** el contorno por profundidad y normales es claramente mejor que el casco de la versión 1. Ahora se ven los cojines, las patas de la mesita, los brazos de Valeria sobre el cuerpo y la cola de Felipe sobre el lomo, y no hay medios píxeles. El borde interior queda bien más claro que el exterior. Con modelos IA el contorno marca también el ruido de la malla (orejas y cola con picos); por eso el modelo tiene que estar limpio.

## Con modelos propios desde imagen
**Cómo se hizo:**
- `microsoft/TRELLIS.2` respondió, pero todas las veces rechazó el trabajo por **cuota de GPU gratuita agotada** para usuarios sin cuenta ("ZeroGPU quota 0s left"). Lo intenté 3 veces en unos 10 minutos.
- `microsoft/TRELLIS` estaba caído (CONFIG_ERROR).
- Funcionó el respaldo **`tencent/Hunyuan3D-2`**, pero su textura falla en el servidor (NameError). Bajé solo la forma, la reduje a 9.000 a 12.000 caras y le puse color **proyectando la imagen original de frente** sobre los vértices. Cada modelo tomó 1 a 3 minutos y $0.
- Para Valeria, el primer intento salió sin cuerpo (solo cabeza y pantuflas). Con el fondo quitado a mano y 30 pasos salió completa.

**Felipe IA:**
- **¿Se reconoce?** Sí, bastante más que el de primitivas: de frente tiene la cara chata, el gorro con la franja blanca, el pecho blanco esponjado, la nariz rosada y la cola atigrada grande. En el sofá, a ×3, se lee como Felipe.
- **Problemas:**
  - La forma es un bulto: las patas casi no existen y la cola y una oreja salen en pedazos sueltos o con picos.
  - Los costados y la espalda repiten la textura del frente estirada, porque el color va proyectado.
  - Sin esqueleto, al caminar se desliza en bloque con rebote: se lee como un muñeco de peluche que avanza, no como un gato que camina.
  - Siempre muestra la misma cara en 3/4. Al ir a la izquierda se refleja como un espejo, igual que el sprite.
- **Frente al sprite:** el sprite sigue siendo más lindo y más Felipe (pelaje, ojos, pose). El modelo IA gana en luz y volumen (le pega la lámpara y proyecta sombra), pero hoy pierde en forma y en animación.

**Valeria IA:**
- **Es la gran sorpresa:** de frente y a ×3 es claramente Valeria: moño, cara con ojos, sudadera con cordones, pantalón gris y pantuflas de gato. Al lado del maniquí no hay comparación posible: el problema de "Valeria parece un maniquí" desaparece.
- **Pero no se mueve (en la v2):** sin huesos solo puede respirar o deslizarse; la v3 le pone esqueleto por código. Para que camine y se siente como el maniquí hay que **ponerle esqueleto** (autorig: Mixamo pide cuenta de Adobe; Meshy o AccuRIG con cuenta gratis, o a mano en Blender) y pasarle las animaciones de la biblioteca de Quaternius. Eso es justo lo que no probamos y es la siguiente pregunta.
- De perfil es plana (la IA infiere poco volumen de una sola vista): se nota en el giro y al sentarse de lado.

## Qué aprendimos
- **La técnica funciona y la versión 2 se ve mucho más "pixel art"** que la 1: pixel ×3, bordes exterior e interior y 3 a 4 tonos por material. Hace falta **Forward+**, porque el renderizador Compatibility de Godot 4.3 no da la profundidad y las normales que necesita el contorno interior.
- **La luz sigue siendo la mayor ganancia:** dinámica, cálida, con sombras y gratis.
- **El cuello de botella son los personajes:**
  - Con assets libres salen maniquíes.
  - Con IA de imagen a 3D salen **parecidos** (sobre todo Valeria) pero **sin esqueleto** y con malla sucia.
  - Felipe es el más difícil: forma chibi peluda y cola grande.
- **La IA gratis es frágil:** la cuota anónima de GPU se acaba (TRELLIS.2), los espacios se caen (TRELLIS) y fallan a medias (textura de Hunyuan). Para producción hace falta una cuenta: un token gratis de Hugging Face o Meshy.
- **Licencias:** TRELLIS.2 es MIT. Hunyuan3D-2 no lo es (excluye la UE, el Reino Unido y Corea del Sur). Lo usado aquí sirve para juzgar, no para el juego.
- La cámara ortográfica no da paralaje; la profundidad se lee por solapamiento y por la inclinación.

## Si el juego entero fuera así
**Qué cambiaría:**
- **Felipe:** un modelo 3D propio en vez de 22 hojas. Sale de la IA desde Felipe A, pero hay que limpiarlo (cola, orejas, patas), retopologizarlo y ponerle esqueleto de gato. Las animaciones se rehacen en 3D. Se acaba el problema de "que sea el mismo gato" (ya no hay que comparar cada hoja). Recomiendo no pasarlo a 3D mientras el modelo no sea tan bueno como el sprite.
- **Casa:** muebles 3D (kits CC0 recoloreados) en vez de fondos pintados. Las alturas reales y la escala de gato salen solas. La luz de cada habitación es dinámica (si Felipe tira la lámpara, la luz cae con ella) y los objetos que se tiran tienen física de verdad.
- **Barrio:** fachadas y calles modulares (kits CC0). Es donde más rinde el 3D, porque se reutiliza mucho.
- **Humanos y jefes:** Valeria, vecinos y A.S.P.I. desde su imagen Gemini con IA, con autorig y animaciones de biblioteca CC0.

**Cuánto costaría (estimación gruesa):**
- **Tubería:** casi hecha aquí (Forward+, bordes, cámara, pixel ×3). Faltan de 3 a 5 días para pulirla y pasarla al juego.
- **Personajes:** para cada uno, regenerar con TRELLIS.2 (MIT) usando un token gratis o con Meshy (100 créditos al mes en el plan gratis, licencia CC BY), limpiar y ponerle esqueleto. Unos 2 a 4 días por humano. Felipe, de 1 a 2 semanas, por la cola, el pelaje y las animaciones de gato, o un encargo a un artista 3D.
- **Escenarios:** 1 a 3 días por habitación con kits recoloreados.
- **Rehacer el juego en 3D** (movimiento, colisiones, nivel 1 y pruebas): varias semanas.
- **Total:** de 2 a 3 meses antes de volver a donde estamos.

## Valeria IA con esqueleto (versión 3, plan B sin servicios externos)
**Cómo se hizo (`scripts/auto_piel.gd`, todo en Godot, $0):**
- Se toma la malla de Valeria de Hunyuan3D-2 y el esqueleto CC0 de Quaternius en su primera pose de "Idle", que tiene los brazos abajo como la imagen.
- El esqueleto se **reajusta a las proporciones de Valeria**, medidas sobre su imagen: tobillo 6 %, rodilla 23 %, cadera 41 %, hombro 65,5 %, cuello 70 % y cabeza 73,5 % del alto. También se abren o cierran los brazos según su ancho.
- Cada vértice se pega a sus **2 huesos más cercanos** con peso 1/d⁴, sin cruzar de lado: la pierna izquierda no se pega a la derecha.
- Cada cuadro, después de la animación de Quaternius, se reponen los largos de hueso de Valeria.
- Blender no hizo falta. Con sus pesos automáticos saldría mejor, pero no lo probé por tiempo.
- Camina girada 35° hacia la cámara, porque la malla IA es plana de perfil y de frente se ve mucho mejor.
- Con `-- --maniqui` vuelve el maniquí de la v2, para comparar.

**Qué se ve** (`sala-3d-pixel-v3.mp4` y `hoja-valeria-v3.png`):
- **Sí camina, se sienta y se para, y sigue siendo Valeria:** moño, cara, sudadera con cordones, pantalón gris y pantuflas. Ningún paso es grotesco, y a ×3 en movimiento se lee como un personaje, no como un maniquí.
- **Postura encorvada:** las animaciones son de un cuerpo adulto de proporciones normales. Con la cabeza grande de Valeria, la caminata la deja mirando al piso con la cabeza adelantada.
- **Manchas oscuras** en la espalda y detrás de la pierna: el color proyectado de frente no cubre los lados.
- **La pierna de atrás** al caminar se ve plana (pantufla "pegada").
- **Al sentarse** las canillas casi desaparecen dentro del sofá y la pantufla queda suelta delante. Los muslos tienen poco volumen en profundidad.
- Con un modelo de varias vistas (frente, espalda y lados) y los pesos de Blender, la mayoría de esto mejoraría. Igual quedaría por debajo del sprite pintado del juego en cara y expresión.

## Veredicto final: DESCARTAR (por ahora), guardando lo aprendido
Esta es la tercera vuelta sobre la misma idea (v1 CAMBIAR, v2 CAMBIAR, v3). La regla dice que tres CAMBIAR obligan a considerar DESCARTAR, y la evidencia lo apoya.

**El híbrido (casa y humanos en 3D, Felipe en sprite):**
- **La casa en 3D sí se ve bien por sí misma:** luz dinámica cálida, bordes limpios, pixel ×3 y escala real gratis.
- **Los humanos 3D salen reconocibles pero toscos:** encorvados, con lados manchados, y al sentarse pierden las piernas.
- **Felipe en sprite convive técnicamente, pero choca en estilo:** un dibujo pintado con contorno propio al lado de volúmenes toon. Felipe en 3D desde imagen todavía es un bulto.
- **El costo de llegar a la calidad del arte 2D actual:** regenerar con varias vistas (con cuenta), pesos en Blender, limpiar mallas, rehacer el movimiento y el nivel en 3D. Son 2 a 3 meses en plena Fase 3, que busca calidad final en el nivel 1.

Por eso recomiendo **no cambiar el juego a 3D ahora**. Si el creador lo aprueba, se borra la carpeta y queda solo la decisión.

**Qué guardar para el juego 2D:**
1. **La luz es lo que más enamoró.** Se puede lograr en 2D con `PointLight2D` y mapas de normales en los muebles, cortando la luz en 3 escalones como el shader toon. Vale un prototipo chico propio.
2. **El contorno interior más claro** que el exterior es una regla de estilo útil para el arte 2D.
3. **La IA de imagen a 3D sirve como referencia:** girar a Valeria o a Felipe para dibujar vistas nuevas (espalda, perfil) para el `director-arte`.
4. Si más adelante se reabre el 3D, empezar por la pregunta que quedó: Valeria **multivista** con pesos de Blender y animaciones hechas para su cuerpo.

## Si se reabre el 3D
- Diseño a cerrar: híbrido (humanos y casa en 3D, Felipe 2D) o todo 3D; la herramienta de IA y su licencia (TRELLIS.2 MIT con token o Meshy CC BY); el autorig.
- Arte que pediría (para el `director-arte`, con costo): una vista de espalda y otra de perfil de Valeria y de Felipe A, para que la IA no invente los lados. La IA mejora mucho con varias vistas: Hunyuan3D-2 acepta frente, espalda, izquierda y derecha.
- Valores que funcionaron:
  - Pixel ×3 (render de 427×240 a 1280×720) y cámara ortográfica de 2,975 m de alto inclinada 18°, ajustada a 1 pixel de render.
  - Bordes: umbral de profundidad 0,12 m, umbral de normal 0,45, exterior a 0,08 lineal mezclado 60 % con el café `#29140f`, interior a 0,42 lineal.
  - Luz: sol y relleno en 2 tonos, lámpara en 3 (cortes 0,12 y 0,55); ambiente violeta (0,26, 0,22, 0,34); lámpara de energía 1,8 y alcance 1,7 m.
  - Modelos IA reducidos a 9.000 a 12.000 caras, con el color proyectado de frente y el borde de la máscara erosionado 2 px para que no queden halos blancos.
- Otra pregunta para después: ¿aporta el paralaje de una cámara en perspectiva lo suficiente para justificar perder el ajuste exacto a pixel?

## Valeria de Meshy con animaciones de Mixamo (2026-10-22)
**Cómo se abre (un solo comando, desde esta carpeta):** `godot --path . -- --valeria-mixamo` (o la escena `valeria_mixamo.tscn`). No hace falta abrir el editor antes: si Godot no importó los archivos, los lee directo con `GLTFDocument`/`FBXDocument`.
- **Fuente:** los FBX de Mixamo de `assets/meshy_prueba/valeria/mixamo/`: la malla y el esqueleto salen de `valeria_walking.fbx` (con skin) y las pistas `mixamorig` de los demás se copian a ese esqueleto. Si no hay FBX usa `valeria_animada.glb`, y si no hay nada, `valeria_meshy.glb` estático. Para probar cada uno: `--valeria-glb` y `--valeria-estatica`.
- **Código:** `scripts/valeria_mixamo.gd` (rutina), `scripts/mixamo_carga.gd` (carga, copia de pistas, medidas), `scripts/principal_valeria_mixamo.gd` (la sala sin Felipes).
- **Sin patinar:** la caminata de Mixamo avanza; se ancla la raíz y el nodo avanza a la velocidad medida en la propia animación (1,41 m/s; medida en los pies apoyados da 1,33 m/s).
- **Sentada de verdad:** la cadera del clip Sitting Idle se lleva a 10 cm sobre el cojín (asiento a 0,425 m). Sentarse y levantarse son cortes con mezcla de 0,6 s (no hay clips de transición); entre las demás, 0,25 s.
- **Recoger:** la pelota aparece en el piso donde la mano llega más abajo y desde ese cuadro va pegada a la mano.
- **Estilo:** material toon de la sala con la textura de Meshy como color; los bordes salen del post-proceso de la sala.

**Qué se ve** (`valeria-mixamo.mp4`, 24 s, en la carpeta de capturas): entra caminando, mira el celular, camina al sofá, se sienta sobre el cojín con los pies en la alfombra, se levanta, recoge la pelota y sale. Es Valeria (moño, cara, sudadera, pantuflas) y se mueve como una persona, sin la postura encorvada de la v3. Pendiente: el celular no aparece en la mano (Mixamo no trae objetos) y al agacharse se ve sobre todo la coronilla.

**Brazos "con los codos al revés" (corregido el mismo día):** el creador vio los brazos amorfos en la primera versión del clip.
- **Causa:** el GLB `valeria_animada.glb`. Al juntar los clips en Blender (`juntar_mixamo.py`), las acciones de los FBX sin skin se pasaron al esqueleto del FBX con skin. En Blender una acción guarda la pose **relativa al reposo** de cada hueso, y el reposo de los FBX sin skin no es el mismo que el del FBX con skin (cambian sobre todo los brazos). Por eso en idle, texting, sitting_idle y picking_up los codos van hacia adentro, delante de la panza, y los antebrazos salen hacia afuera. Walking está bien porque venía en el mismo archivo que la malla. Los cuadros de Blender (`valeria_animaciones_cuadros.png`) ya muestran el error.
- **No era** el auto-rig de Mixamo (los codos y muñecas caen en su lugar y con los FBX directos los brazos cuelgan bien), ni nuestra copia de pistas (el GLB tal cual y la rutina se ven iguales).
- **Arreglo:** la rutina ahora usa primero los FBX directos. Sus curvas son poses locales absolutas y se copian bien al esqueleto del FBX con skin. Diagnóstico con `pruebas/valeria_brazos.gd` (frente y perfil de idle, walking y texting: GLB tal cual, GLB con la copia de la rutina, FBX de caminar y FBX con pistas copiadas). Resultado en `valeria-brazos-antes-despues.png` y `valeria-mixamo-v2.mp4`.
- **Para arreglar el GLB** (lo necesita el juego en Three.js): bajar de Mixamo cada animación **con skin** (todas comparten reposo), o, en `juntar_mixamo.py`, convertir cada acción al reposo del esqueleto con skin antes de juntarla.

## Pendiente: animación de «acecho» (de `felipe-video2-juega-salta.png`, 2026-10-22)
Felipe agazapado: cuerpo pegado al piso o la cama, cabeza baja y adelantada, grupa un poco alta y cola barriendo de lado a lado. Anotada para más adelante; no está hecha. Las otras notas de ese video (salto con impulso de las traseras, aterrizaje con las delanteras y el lomo arqueado, cola que se sacude atenta) ya están en la v8 (`scripts/felipe_meshy.gd`, `scripts/felipe_v8.gd`).

Notas de `felipe-video3-sentado-olfatea.png`: al caminar o explorar la cola va a media altura con la punta en gancho (la punta se mece más que la base), y así quedó en la v8. Pendiente para cuando haya animación de sentarse: sentado, la cola estirada en el piso y solo la punta se mueve.

## Felipe con rig hecho en Blender (2026-10-22)
**Por qué:** las versiones anteriores fallaban por la misma causa. La malla de IA es «una estatua»: una sopa de triángulos sin bucles en las articulaciones. Con pesos por distancia (v6) se deformaba como masa, y con piezas rígidas (v7 y v8) se veían cortes. Esta vez se siguió la receta de un artista: retopología, textura horneada, esqueleto, pesos de calor y animación con poses clave.

**Cómo se abre:** `godot --path . -- --felipe-rig`. Desde la segunda vuelta, Felipe hace una rutina: camina, salta al sofá, araña, baja, camina y pide (ver más abajo). El código está en `scripts/felipe_rig.gd`; en `principal.gd` solo se agregó un `if`.

**Cómo se hizo** (Blender 5.2.3 como módulo de Python, `pip install bpy==5.2.3`; scripts en `assets/meshy_prueba/felipe_rig/scripts/`, se corren en orden):
1. **`01_retopo.py`:** importa el GLB, aplica las transformaciones y lo centra con el piso en z = 0. Hace un remallado por vóxeles de 6 mm, que cierra la malla y une las 127 islas sueltas en una sola pieza. Después, **QuadriFlow** con simetría en X da **7.754 cuadriláteros** (todas las caras), y se pega a la original con Shrinkwrap.
2. **`02_textura.py`:** UV nuevas con Smart UV Project y margen. Hornea en Cycles, en modo **Selected to Active**, solo el color difuso desde la original: 2048 px, extrusión de 1,2 cm y rayo de 4 cm. Ningún texel quedó sin dato.
3. **`03_rig.py`:** esqueleto desde el **metarig de gato de Rigify**, recortado a 34 huesos: raíz, columna de 4 (grupa a pecho), cuello, cabeza, 2 orejas, cola de 5 y, por pata, escápula o pelvis, 3 segmentos y dedos. Los huesos van en las marcas del creador (`plantilla_esqueleto/creador_*.png`) con el mapeo de `vistas.gd`. El ancho de las patas traseras se midió en la malla.
   - Pesos con **Automatic Weights (calor)**: funcionó en todos los vértices. Luego se suavizan los grupos.
   - Reglas por script: la cabeza va entera a su hueso, con un anillo de mezcla de 30 px solo abajo y atrás, donde nace el cuello; la cara, la boca y el mentón no se mezclan. Las orejas salen de la máscara del creador. Ninguna pata toma vértices del otro lado ni del centro de la panza. Máximo 4 huesos por vértice, normalizado.
   - Sin Preserve Volume, porque Godot usa skinning lineal.
4. **`04_poses.py`:** prueba de poses. Patas a ±35° (hombro o cadera y codo o rodilla), cola a 30° hacia atrás y al lado, y cabeza a 20° abajo y al lado.
5. **`05_anima.py`** (con `anima_base.py`, `anima_locomocion.py` y `anima_acciones.py`): todo pasa a metros (alto total de 0,554 m). Se arman controles IK de animador: control del pie con pivote en la bola, objetivo IK que es copia del pie y polos de rodilla y codo, con el ángulo buscado para que el reposo no cambie. Las claves son Bezier con facilidad de entrada y salida y modificador Cycles. Se hornea a los huesos que deforman, se borran los controles y se exporta `felipe_rig.glb` con 2 animaciones.
   - **caminar:** 22 cuadros a 24 fps (0,92 s), en secuencia lateral (trasera izquierda, delantera izquierda, trasera derecha, delantera derecha).
     - **8 poses clave por pata:** contacto, bajada, apoyo medio, talón arriba, despegue, recoge (lo más alto), paso y estira.
     - La escápula acompaña a la mano.
     - La grupa y los hombros bajan por turnos al recibir el peso. El lomo ondula: giro lateral, balanceo e inclinación.
     - La cabeza va baja y adelantada y se mece poco, con retraso.
     - La cola va a media altura en gancho, con la punta retrasada.
     - Va «en el lugar»: **0,187 m/s** a escala 1 (0,243 m/s con la escala 1,3 de la sala), anotado en `felipe_rig.json`. Medido en Blender, **el pie apoyado se corre 0,02 mm**.
   - **quieto:** 6 s (era de 3 s). Respira, la cola se mece lento con pausas y un tic de la punta, la cabeza mira y una oreja da un respingo.
6. **`06_ciclo.py`** y **`07_hojas.py`:** hojas de revisión. **`pruebas/felipe_rig_cuadros.gd`:** cuadros de cerca en Godot (perfil y 3/4).

**Entregables** (en la carpeta de capturas `proto3d/`): `felipe-rig-retopo.png`, `felipe-rig-textura.png`, `felipe-rig-poses.png`, `felipe-rig-ciclo.png`, `felipe-rig-anima.gif` (de cerca, en Godot y con material toon) y `felipe-rig-anima.mp4` (en la sala, pixel ×3, 23 s).

**Qué se ve:**
- **Ya no hay masa ni cortes.** La malla tiene anillos parejos y se dobla como un cuerpo: patas, cuello y cola giran sin estirar la textura y sin picos. La cabeza gira entera, con la cara intacta.
- **La textura horneada se ve igual que la original:** cara, ojos, gorra atigrada, manchas y anillos de la cola. Se pierde el relieve fino del pelo del pecho, que venía de las 89.000 caras y del mapa de normales; la malla nueva lo deja más liso.
- **Camina como un gato chico y pesado:** pasos cortos con la pata que se dobla y empuja, la grupa y los hombros que suben y bajan por turnos, la cabeza baja y la cola en gancho que se mece. De perfil y en 3/4 se lee bien a ×3.

**Límites:**
- Las patas son muñones cortos, así que el paso es chico (10 cm a escala 1).
- Con la delantera a 35° se arruga un poco el pelo esponjado del pecho. La caminata usa ángulos menores.
- La retopología es una malla pareja de QuadriFlow, no una topología dibujada a mano con bucles pensados en cada articulación. Funciona porque es densa (7.754 caras) y regular. Un modelador la mejoraría en codos y rodillas.
- La animación está hecha por script con poses clave, sin ojo humano cuadro a cuadro. Falta que el creador la mire y pida ajustes de carácter (más o menos peso, actitud).
- Al darse vuelta en la sala gira en el lugar sobre una pose quieta; no hay animación de giro.

**Para seguir:** si el creador lo aprueba, el mismo rig sirve para acecho, sentarse, saltar y caer. Bastan más acciones en `05_anima.py` con los mismos controles, sin rehacer la malla ni los pesos.

### Segunda vuelta: sombra de la pata trasera, cola más viva y 3 acciones nuevas (2026-10-22)
El creador vio el rig: «está aceptable… es lo mejor que tenemos». Se siguió con el mismo rig y los mismos scripts.

**1. La sombra rara de la pata trasera: causa de fondo**
- **Descartado:**
  - Normales invertidas o partidas: la malla tiene 0 aristas sin cerrar, 0 caras con el sentido cruzado y 0 pliegues en reposo.
  - Algo oscuro horneado: en Godot la mancha es igual sin textura.
  - Sombra proyectada: también es igual con las sombras apagadas (`pruebas/felipe_rig_sombra.gd`).
- **Causa: los pesos plegaban la piel entre el muslo y la panza al caminar.** Había tres fallas en `03_rig.py`:
  1. **Cortes duros.** "Las patas no toman la panza" era un corte seco en x = 0,07: un vértice iba entero a la columna y el de al lado entero a la pata. Ahora el peso de la pata se desvanece de 0,12 a 0,02 y hay 3 pasadas de suavizado entre vecinos fuera de la cabeza.
  2. **El muslo (y el brazo) se llevaban la grupa (y el flanco):** 70–80 % del peso del lado del cuerpo, incluso sobre la cadera. Ahora su peso baja suave entre la rodilla y la cadera (el codo y el hombro), y lo que sobra pasa a la pelvis (la escápula).
  3. **Un error de bpy:** al borrar los grupos de cada vértice mientras se recorría `v.groups`, la colección se corría y quedaban restos de los pesos de calor (más de 4 huesos, suma mayor que 1). Por eso el exportador avisaba "más de 4 influencias". Ahora hay como máximo 4 y suman 1.
- **Resultado** (`felipe-rig-sombra-antes-despues.png`): en el alambre desaparecen las caras plegadas entre las patas traseras y la panza, y en Blender se suavizan las franjas oscuras bajo el vientre. En el toon de Godot el cambio es chico. La zona lila grande que queda sobre la grupa es su sombra propia (el corte de luz del toon en 0,12), no un defecto.

**2. La cola más viva** (overlapping action / follow-through, el método estándar):
- **5 huesos** (antes 4): el tramo de arriba, largo y con el gancho, va en dos. Así se dobla en curva y no en codo.
- **En Blender:** una onda que viaja de la base a la punta, 3 cuadros de retraso por hueso, amplitud ×0,25 en la base hasta ×1,5 en la punta y giros en ejes locales.
- **Por acción:**
  - **caminar:** vaivén con retraso.
  - **quieto:** 6 s con pausas irregulares y un tic de la punta a los 4 s; nunca está congelada.
  - **arañar:** sacudidas rápidas de la punta.
  - **pedir:** la punta curvada se mueve lento.
  - **saltar:** abajo y atrás al despegar, arriba en el aire y latigazo al aterrizar.
- **En Godot** (`felipe_rig.gd`): un resorte amortiguado por hueso como capa aditiva sobre el clip.
  - La punta es más lenta: 2,6 a 1,5 Hz, amortiguación 0,32 y tope de ±25°.
  - Reacciona a la aceleración del nodo: al arrancar se atrasa, al frenar sigue de largo y rebota, al despegar baja y al aterrizar da un latigazo. También reacciona a los giros.

**3. Acciones nuevas** (poses clave en `anima_acciones.py`):
- **Base común:**
  - El torso gira en la cadera, y las manos y patas en el aire se ponen relativas al torso (dónde quedarían + un desplazamiento).
  - `05_anima.py` mide en cada acción cuánto le falta a cada pata para llegar a su objetivo IK: 0 a 5 mm, y 10 mm en el aire al saltar.
- **arañar** (2,3 s con dos bucles):
  - `aranar_entrada` (0,5 s): se carga, se para en dos patas y se asienta contra el respaldo.
  - `aranar` (0,67 s, bucle): las manos bajan alternadas, con 2 zarpazos por ciclo (garras abajo en los cuadros 3 y 11). El cuerpo se mece con cada zarpazo, las orejas van atrás y la punta de la cola se sacude.
  - `aranar_salida` (0,5 s): se separa del respaldo, apoya las manos y amortigua con el lomo arqueado.
- **pedir** (2,25 s con un bucle):
  - `pedir_entrada` (0,75 s): se sienta y la cola rodea las patas por el lado derecho.
  - `pedir` (1,5 s, bucle): mira arriba con la cabeza ladeada y la pata derecha sube y toca el aire dos veces.
  - Para levantarse, Godot pasa `pedir_entrada` al revés.
  - **No abre la boca:** el rig no tiene mandíbula y no la inventé.
- **saltar** (1,42 s, en el lugar):
  - Anticipación (se agacha y mueve la grupa).
  - Impulso: las traseras empujan y el cuerpo se estira (+7 %).
  - Aire: las patas recogidas y el lomo redondo.
  - Caída: las delanteras adelante.
  - Aterrizaje: delanteras primero (la segunda un cuadro después), luego la grupa, y el lomo se arquea y amortigua (−7 %).
  - Marcas en `felipe_rig.json`: despegue 0,5 s y aterrizaje 1,0 s. El arco parabólico lo hace Godot entre las dos (`arco_salto`).

**4. Rutina en la sala** (`--felipe-rig`, unos 24 s en bucle, mezclas de 0,2 s): camina, gira, salta al cojín del sofá, araña el respaldo (entrada, 3 bucles y salida), baja de un salto, camina hasta donde estaría Valeria, se sienta y pide 2 veces, se levanta y vuelve a empezar.

**Entregables** (en `proto3d/`):
- `felipe-rig-sombra-antes-despues.png`;
- `felipe-rig-acciones.gif`: de cerca en Godot con el toon, de perfil y en 3/4, con caminar, la cola de cerca caminando y en quieto, saltar, arañar y pedir;
- `felipe-rig-acciones.mp4`: la rutina en la sala, pixel ×3;
- `felipe-rig-acciones-cuadros.png`: 6 cuadros clave de cada acción, de perfil y en 3/4, en Blender.

**Límites honestos:**
- **Sentarse:** Felipe chibi no puede sentarse erguido con las manos en el piso. Sus patas delanteras son cortas y casi rectas: cada 25° de pecho levantado suben los hombros unos 8 cm. Por eso pedir es un sentado bajo, "bollo", con 10° de pecho y la grupa 5 cm abajo. Se lee como sentado en 3/4; de perfil parece echado con la cabeza arriba.
- **La pata que pide** sube unos 9 cm. Se ve bien en 3/4 y poco de perfil.
- **Arañar en la sala** se ve en 3/4 de espaldas, porque el respaldo queda detrás del cojín.
- **El salto en la sala** es corto (cojín a 43 cm) y se ve chico a ×3.

### Caminata v2: más rápida y fluida (2026-10-22)
El creador: «las demás acciones se ven bien», pero la caminata «parece un juguete». Se rehízo solo `caminar`, con el método estándar de ciclo de cuadrúpedo (Richard Williams, *The Animator's Survival Kit*; los videos del Felipe real).

- **Ritmo:** ciclo de **0,67 s** (16 cuadros; antes 0,92 s) y paso un poco más largo (0,34 u, 11,7 cm a escala 1). Avanza a **0,29 m/s** (0,38 m/s con la escala 1,3 de la sala; antes 0,19 m/s). El apoyo dura el 60 % del ciclo, así que la pata en el aire va más rápido.
- **El pie apoyado sigue sin patinar:** se corre 2,3 mm, menos de medio pixel a ×3.
  - La delantera, casi recta en reposo, alcanza el paso más largo con la escápula (±20°) y con el paso centrado 1,2 cm más atrás, como un gato real.
- **Arcos y breakdowns:** 9 poses por pata: contacto, bajada, apoyo medio, talón arriba, despegue, recoge, paso, adelanta y estira. El vuelo hace un arco Bezier con facilidad de entrada y salida; el apoyo va lineal.
- **Peso y desfases**, con claves en los 16 cuadros:
  - La grupa baja después de cada apoyo trasero y los hombros después de cada delantero, desfasados.
  - La cadera se corre hacia la trasera que apoya y cae del lado de la que vuela; el pecho rola con su propio desfase (la columna se tuerce).
- **Cabeza estabilizada:** compensa el cabeceo del pecho, el balanceo y el giro del cuerpo. Mira adelante, con un cabeceo mínimo y atrasado.
- **Cola:** la misma capa, con 2 cuadros de retraso por hueso (antes 3) para el ritmo más rápido, y el resorte de Godot encima.
- **Mezclas desde y hacia caminar:** 0,2 s, como el resto. Arañar, pedir y saltar no se tocaron.
- **Entregables:**
  - `felipe-rig-camina-v2.gif`: arriba la caminata anterior y abajo la nueva, de perfil y en 3/4, sobre el piso con rayas (`pruebas/felipe_rig_camina_comparar.gd`);
  - `felipe-rig-acciones-v2.mp4`: la rutina completa en la sala.

### v3: modelo simétrico, pata delantera y lomo del Felipe real (2026-10-22)
El creador vio la v2: «mete mucho una de las patas delanteras; se ve mal pintado el lomo». Su idea: hacer el modelo simétrico, que es el flujo estándar (se modela y se arma simétrico en reposo, y la asimetría la pone la animación).

**Causa de la pata:** la malla de Meshy traía la mano delantera izquierda **6 cm más atrás** que la derecha (y −0,13 contra −0,19 m), bajo el pecho. El esqueleto es simétrico y el recorrido igual, así que esa pata terminaba metida bajo la melena.

**Qué se hizo** (en `01_retopo.py` y `simetria.py`; las variantes en `01a_simetria_variantes.py`):
1. **Simetría de la malla de alta:** se busca el plano medio (estaba centrado: desplazamiento 0, giro 0°) y se aplica **Symmetrize**.
   - 6 variantes: mitad −X o +X, con soldadura de 0,5, 2 o 5 mm. Elegida: **la mitad −X (derecha de Felipe), con 5 mm**.
   - Esa mitad tiene la mano en su lugar y es el lado donde el creador marcó el esqueleto. La soldadura de 5 mm cierra la costura: quedan 7 bordes abiertos, contra 298 a 524 con las otras.
   - Además se suelda toda la malla de alta: venía en 83 pedazos con grietas, y por ellas el horneado pintaba una línea blanca en el lomo.
2. **Retopo simétrica:** QuadriFlow, luego se corta al medio y se espeja con Mirror soldado.
   - QuadriFlow con su opción de simetría dejaba una grieta abierta a lo largo del plano medio.
   - Resultado: 7.359 caras, con 1 borde abierto y todos los vértices con su pareja exacta.
   - El lomo y la grupa se relajan 6 pasadas (sin tocar la cara ni el pecho), porque la malla traía escalones en el borde de las manchas viejas.
3. **Textura:** se hornea desde la malla de alta simétrica y se repinta con `02b_lomo.py`.
4. **Pesos espejados**, como Mirror Vertex Groups: los 3.544 vértices de la derecha copian los pesos de su pareja, con .L y .R intercambiados.
5. **Todas las animaciones** se rehicieron sobre el rig nuevo con los mismos scripts.

**Pata delantera** (`anima_locomocion.py`):
- La mano se apoya 1,8 cm más afuera y en el vuelo va 4 cm más afuera, bajo el hombro.
- La pata de Felipe va inclinada hacia adentro (hombro a 9,8 cm del centro, mano a 4,9). Al doblarse, el codo se metía bajo la melena y la pata cruzaba hacia el centro.
- Probé 5 anchos de apoyo (0 a 2,4 cm) y 5 de vuelo (0 a 4 cm), y también 5 distancias de polo, que casi no cambiaron nada. Medí el patinaje, el alcance IK y la inclinación del antebrazo, y miré renders de frente.
- **Elegidos 1,8 y 4 cm:** el pie no patina (0,02 mm), el IK alcanza siempre (0 mm) y las dos delanteras barren el mismo rango simétrico.

**Lomo y cola**, con el patrón de las fotos del creador (`felipe-lomo-arriba-1/2.jpg`, `felipe-lomo-costado.jpg`, `felipe-video6-camina-*.png`):
- La gorra no se toca y la nuca queda blanca.
- **Un par de manchas a media espalda**, separadas por una franja blanca sobre la columna, y una banda blanca atravesada.
- **Un par de manchas sobre la cadera** que bajan por el muslo.
- La base de la cola es blanca, y el resto café oscuro casi liso, más claro al centro.
- Las manchas son pardo oscuro con rayas finas de la columna hacia abajo y bordes suaves. Se dibujan en un mapa del cuerpo (largo × ángulo) y se evalúan en cada texel, así no hay escalones en las costuras UV, y el padding se rellena.
- **Por qué no limpiar la mancha de Meshy:** limpiarla con cierre y apertura daba siempre un solo bloque (la "montura" gris de Meshy, que no es el patrón real). Por eso se dibujan las manchas del patrón.
- Probé 7 variantes de tamaño, franja y forma, medidas por número de manchas, huecos, redondez, simetría y área. **Elegida `g_medianas`:** 4 manchas, 0 huecos, simetría 0,97 y un tamaño cercano a las fotos sin cerrar la banda blanca.

**Caminata con el video 6:**
- La cola va **alta, en arco hacia adelante sobre la grupa**; antes iba a media altura en gancho.
- Las patas se levantan un poco menos (paso tranquilo y pesado).
- Arañar, pedir y saltar no cambian, salvo que las manchas y la cola nuevas se ven en todas.

**Entregables** (en `proto3d/`):
- `felipe-simetrico-antes-despues.png`: frente, espalda, arriba y alambre;
- `felipe-rig-lomo-antes-despues.png`;
- `felipe-rig-patas-antes-despues.png`: perfil y frente, 4 cuadros del ciclo;
- `felipe-rig-camina-v3.gif`: v2 arriba y v3 abajo;
- `felipe-rig-acciones-v3.mp4`;
- `felipe-rig-acciones-cuadros.png`.

**Límites:**
- La pata delantera sigue inclinada hacia adentro en reposo: es la anatomía chibi de Meshy. Ya no se cruza, pero de frente se ve "patizamba".
- La cara venía casi simétrica y quedó espejada de la mitad derecha.
- El pelo esponjado del pecho conserva el relieve de Meshy.

### v4: una sola montura, patas traseras gruesas, anatomía de gato y contorno (2026-10-23)
El creador vio la v3 (simetría, pata y caminata, bien) y pidió varios cambios.

**1. Una sola mancha tipo montura** (`02b_lomo.py`):
- Va desde detrás de los hombros hasta la grupa, llega a la base de la cola y baja por los costados.
- Es pardo oscuro atigrado con rayas finas y simétrica. La gorra y la cara siguen igual.
- El borde tiene mechones: puntas agudas en dos frecuencias, como pelo, no un recorte geométrico.
- **7 variantes** de tamaño, mechones y forma. Elegida **`b_montura_grande`**: la más legible a ×3, cubre la grupa y no deja franja blanca. Las de mechones largos se ven como sierra y las chicas dejan el anca blanca.

**2. Unión de la cola, la grupa y la pata:**
- **El anillo blanco tenía dos causas:**
  - el anillo blanco que la v3 pintaba a propósito;
  - un óvalo que no se pintaba: la base de la cola quedaba fuera de la zona del cuerpo y también de la zona de la cola, y ahí se fundía con la textura vieja de Meshy.
- **Arreglo:** la cola nace del color de la montura y la montura cubre la parte de atrás de la grupa, bajo la raíz de la cola.
- En la malla no había pliegue ni hueco en esa unión: la grieta central ya se había soldado en la v3.

**3. Patas traseras gruesas** (`01_retopo.py`, `PIERNA`):
- Cada vértice del muslo y la canilla se empuja en horizontal, alejándose del eje de la pata a su altura.
- La caída es suave hacia la grupa y hacia el pie, el lado de adentro crece poco y la zona se suaviza después. Es simétrico.
- **Inflar por la normal no sirvió:** las normales de esta malla son ruidosas y la superficie se arrugaba desde 0,06.
- **5 grosores** (0 a 0,09 u). Elegido **0,07 u** (unos 2,4 cm): se ve el "pantalón" de persa desde atrás y las patas no se tocan.

**A. Grupa más alta que los hombros** (`anima_locomocion.py`): al caminar y en quieto, la cadera sube 1,2 cm y el frente baja 4°. Las traseras van más estiradas y se ven más largas.

**B. Anatomía de cuadrúpedo digitígrado dentro del pelo** (`03_rig.py`; ver `felipe-v4-esqueleto.png`):
- **Trasera:** cadera arriba en la grupa → fémur hacia adelante y abajo hasta la rodilla → tibia hacia atrás hasta el corvejón → metatarso casi vertical → dedos.
- **Delantera:** escápula arriba, detrás del cuello → hombro en la punta del pecho → húmero hacia atrás hasta el codo, bajo el pecho → antebrazo casi vertical hasta la muñeca → mano y dedos.
- **Proporciones** (Felipe frente a un gato real):
  - fémur : tibia : metatarso = 1 : 0,92 : 0,33 (real 1 : 1,09 : 0,59);
  - escápula : húmero : radio = 1,15 : 1 : 1,10 (real 0,70 : 1 : 0,95).
  - El pie y la mano son cortos, y la escápula queda algo larga porque baja desde el centro del lomo hasta el hombro. Es la anatomía escalada a un cuerpo chibi.
- **Pesos:** la piel del flanco y del anca sigue al fémur con caída suave desde la cadera hasta la rodilla; la del hombro sigue a la escápula y al húmero.
- **Caminata:** la cadera y el hombro barren, la rodilla y el codo se doblan, y la escápula se desliza con cada paso. El pie no patina (0,02 mm).
- **El estirar y aplastar** ya no se hereda en patas, cuello ni cola (`inherit_scale`). Antes encogía las patas, que no llegaban al piso: hasta 18 mm al saltar. Ahora llegan siempre, salvo una mano al pedir (7 mm).
- Arañar baja un poco menos la mano, porque con el hombro nuevo no alcanzaba.

**Contorno de dibujo** (`felipe_rig.gd`; ver `felipe-v4-contorno-opciones.png`):
- **Casco invertido** de 1 px de render (café `#2b140e`), como segunda pasada del material toon.
- **Umbrales del post-proceso de la sala** bajados a 4 cm de profundidad y 0,30 de normales en el modo `--felipe-rig`, para que salga la línea entre la pata y el cuerpo.
- **Líneas de pliegue** pintadas en la textura, en el borde de las patas que marcó el creador, donde la pata entra al cuerpo.
- **5 combinaciones** probadas. Elegida: **casco 1 px + bordes 0,04/0,30 + pliegues**. Con casco de 2 px y bordes de 0,03 la sala se llena de manchas oscuras.
- **Límite:** la línea de pliegue se ve de cerca y en Blender, pero a ×3 en la sala casi no se nota. Lo que más ayuda allí es el casco.

**Entregables** (en `proto3d/`):
- `felipe-v4-antes-despues.png`: espalda, perfil, 3/4 de atrás, lomo y la unión de la cola y la pata;
- `felipe-v4-esqueleto.png`: huesos dentro de la malla, de perfil y de frente, con el esquema de un gato real y la tabla de largos;
- `felipe-v4-esqueleto-ciclo.png`: 8 cuadros del ciclo con los huesos;
- `felipe-v4-contorno-opciones.png`;
- `felipe-rig-camina-v4.gif`: v3 arriba y v4 abajo;
- `felipe-rig-acciones-v4.mp4`.

### v5: cara de Meshy, mano sin aplastar y sala limpia (2026-10-23)
El creador: la v4 «es la que mejor se mueve», pero con 3 problemas. Se buscó la causa de cada uno comparando con la versión en que estaba bien.

**1. La cara chata, con los ojos hundidos:**
- **Causa:** el Symmetrize de la v3. La cara de Meshy no es simétrica: los ojos van algo girados en 3/4. Espejar la mitad derecha achicó y hundió los ojos y aplanó el perfil. La v2, que no estaba simetrizada, tenía los ojos bien. La retopo de unas 7.400 caras además suavizaba el relieve.
- **Arreglo** (`01_retopo.py`, `FELIPE_CABEZA`): el cuerpo sigue simétrico, pero la cabeza no. Sus vértices se subdividen y se proyectan sobre la cabeza **original** de Meshy, con mezcla en el cuello. La textura se hornea desde la Meshy original.
- **5 variantes**, medidas por la distancia a la superficie de Meshy y mirándolas:

  | Variante | Distancia media a Meshy |
  |---|---|
  | simétrica (v4) | 2,3 mm |
  | proyectada | 2,1 mm |
  | proyectada + 1 subdivisión | 1,1 mm |
  | 16 mil caras | 1,4 mm |
  | **proyectada + 2 subdivisiones (elegida)** | **0,7 mm** |

  La elegida tiene 42 mil caras, casi todas en la cabeza.
- La cabeza ya iba entera en su hueso y no hereda el estirar y aplastar.
- Los pesos de calor fallan en una malla tan densa. Ahora se calculan en la malla base y se transfieren con Data Transfer.

**2. La mano delantera se aplastaba:**
- **Medido:** el volumen de la mano bajaba hasta 14 % en el vuelo de la v4. Ningún hueso tiene escala en sus curvas y nada hereda el estirar y aplastar.
- **Causa:** al doblar la muñeca a 75°, la piel de la mano se repartía entre el antebrazo y la mano, y la mezcla lineal la plegaba. Además, en el vuelo la mano subía dentro del pelo del pecho.
- **Arreglo:**
  - la bola de la mano queda rígida en su hueso (`03_rig.py`);
  - en la caminata, la muñeca se dobla al 70 %, los dedos de la mano no se pliegan y la mano sube y va hacia atrás menos en el vuelo (`anima_locomocion.py`);
  - probé 5 combinaciones.
- **Resultado:** el volumen se mantiene entre 1,00 y 1,01 del reposo en todo el ciclo. El pie sigue sin patinar.

**3. La sala más sucia en pixel ×3:**
- **Causa:** los umbrales de bordes de la v4 (0,04 m / 0,30), que dibujaban puntos y rayas sobre el pelo. Además, el casco invertido de 1 px asomaba sus caras traseras como puntos oscuros en el pecho y la cara.
- **Arreglo:** el post-proceso vuelve a los valores de siempre (0,12 m / 0,45). Quité el casco (`contorno_px` = 0) y las líneas de pliegue pintadas. Los dos siguen disponibles como opciones (`--contorno=`, `--bordes=`, `FELIPE_PLIEGUE`).
- En `felipe-v5-sala-comparacion.png`, la v5 se ve tan limpia como la v3.

**Se conserva de la v4:** la anatomía, la postura, la montura, las patas gruesas y todas las acciones.

**Entregables** (en `proto3d/`):
- `felipe-v5-cara.png`;
- `felipe-v5-mano.png`;
- `felipe-v5-sala-comparacion.png`;
- `felipe-rig-camina-v5.mp4`: v4 arriba y v5 abajo;
- `felipe-rig-acciones-v5.mp4`.

Desde ahora todo lo animado se entrega en MP4 (H.264, yuv420p, faststart).

**Límite:** el GLB pesa 4,1 MB por la cabeza densa. Si hiciera falta, se puede bajar a una subdivisión (1,1 mm de distancia, 14 mil caras).

### v6: textura con el tono de la gorra, boca, ojos y cabeza que muestra la cara (2026-10-23)
El creador: «me encanta la animación de la habitación… creo que lo logramos». Pidió retoques de textura y después, sobre la cabeza: «se ve un poco chata en los ojos», «muy rara; parece un cerebro gigante», «hacer más pequeña la parte de arriba o sacar un poquito más el hocico». **El rig, los pesos y las animaciones no cambiaron.**

**Textura** (`02b_lomo.py`):
- **Montura más chica** (5 variantes; elegida `v6b_media_baja`): sobre el lomo, sin cubrir el anca ni tanto los costados.
- **Tono y rayas de la gorra:** se muestrea el color claro y el oscuro de la gorra en la textura de Meshy. Las rayas son finas y bajan de la columna hacia los costados. Antes la mancha se oscurecía al 66 % y no combinaba con la cabeza.
- **Cola** con el mismo tono y anillos atigrados a lo largo, algo más oscura hacia la punta. Ya no es un bloque liso.
- **Boca:** la "Y" invertida y el contorno de la nariz se engruesan 2 texels y se oscurecen, sin cambiar la forma. Probé 0, 2, 3 y 4. Con 2 se lee 1 px oscuro a ×3.
- **Ojos** (opción a, la menos invasiva): un brillo chico y una sombra leve bajo el párpado superior y hacia afuera. Probé 4 intensidades y elegí la 2: es reversible y no toca la geometría.

**Cabeza:**
- **Causa:** la caminata lleva la cabeza baja y la cámara de la sala está alta. Al alejarse en 3/4 se ve sobre todo la coronilla: un casco gris enorme con el ojo en el borde (la captura del creador).
- **Capa en Godot** (`felipe_rig.gd`): la cabeza gira hacia la cámara, como máximo 30°, con suavizado, y el cuello sube 12° al caminar. También se puede probar la escala de la cabeza (`--giro=`, `--alza=`, `--escala-cabeza=`).
- **Forma** (`01_retopo.py`, `CRANEO` y `HOCICO_MM`): edición proporcional suave y simétrica sobre la cabeza de Meshy. El cráneo (arriba y atrás de los ojos) se acerca a un pivote y las orejas bajan con su base. El hocico (nariz, boca y cachetes) se adelanta.
  - La misma deformación se aplica a la malla de alta antes de hornear. Sin eso, los rayos salían por dentro y quedaban parches negros.
- **Combinaciones probadas** (13, en `felipe-v6-cabeza-opciones.png`):
  - giro y alza: 0/0, 20/8, 30/12 y 35/16;
  - escala de la cabeza: 0,9;
  - solo cráneo, solo hocico y los dos;
  - cráneo 5, 8 y 12 % con giro;
  - cráneo + hocico + giro.
- **Elegida: cráneo 8 %, hocico 3 mm, giro 30° y alza 12°, escala 1,0.**
  - Lo que más arregla es el giro: en el cuadro de la captura se ven el ojo, la V blanca y la nariz.
  - Con cráneo al 12 % se aplastan los párpados.
  - La escala 0,9 casi no cambia nada, y la cabeza grande es parte del estilo chibi.

**Dos errores encontrados y corregidos en el camino:**
- La muestra de la gorra salía vacía con el cráneo más chico: una franja fija de la plantilla y un percentil con `<`. El color salía NaN y la textura quedaba negra.
- Los parches negros del horneado, por no deformar también la malla de alta.

**Entregables** (en `proto3d/`):
- `felipe-v6-textura.png`: espalda, perfil, 3/4, cara, boca de cerca y a ×3, v5 contra v6;
- `felipe-v6-cabeza-opciones.png`;
- `felipe-rig-acciones-v6.mp4`.

### v6.1 (v6b): la mirada a cámara como gesto, no permanente (2026-10-23)
El creador: «cuando se voltea de espaldas, se ve raro que mire la cámara; se ve raro que siempre esté mirando la cámara». Solo cambia la capa de cabeza de `felipe_rig.gd`:
- **De espaldas** (de 100° a 130° lejos de la cámara, con fundido) **o mientras se da vuelta:** la cabeza sigue al cuerpo, sin giro.
- **Caminando:** el giro hacia la cámara es sutil, 12° como máximo (antes 30°), solo para no ver la coronilla. El cuello sigue 12° más alto.
- **Quieto:** una mirada ocasional a la cámara de 1 a 2 s, cada 4 a 8 s al azar (semilla fija), de hasta 35°, y vuelve.
- **Pidiendo:** mira a la persona (hacia la cámara, 25° como máximo).
- Todo con suavizado. Entregables: `felipe-v6b-mirada.png` (v6 contra v6b) y `felipe-rig-acciones-v6b.mp4`.

### Quieto largo: sentarse, mirar y jugar con la pelota (2026-10-23, cierre de la etapa de animación)
El creador: con Felipe «ya estamos bien; seguir insistiendo podría entorpecer». Esta es la última tarea de animación: si el jugador no toca nada un rato, Felipe se sienta, mira al jugador y juega con una pelota. **Las otras animaciones no cambiaron** (mismas medidas al exportar).

**Animaciones nuevas** (`anima_acciones.py`, poses clave como las demás, en el mismo GLB):
- **`sentarse`** (0,83 s): de quieto a sentado. Usa la base de `pedir_entrada`, con la cabeza al frente.
- **`sentado_mira`** (3 s, bucle): sentado, respira, una oreja da un respingo y la cola barre el piso lento. Godot gira la cabeza hacia el jugador (25° como máximo, con suavizado).
- **`sentado_pelota`** (2 s, bucle): la pata delantera derecha da 2 manotazos a una pelota en el piso, con las garras abajo en el contacto. La cabeza baja y sigue la pelota, y la punta de la cola se sacude.
- **`levantarse`** (0,83 s): de sentado a quieto. Son las mismas claves de `sentarse`, invertidas.

**La pelota no va en el modelo.** `felipe_rig.json` → `sentado_pelota.contactos` trae, por cada contacto, `t_s` (segundos dentro del bucle) y `pie_m`: la punta de la pata en coordenadas del modelo glTF a escala 1 (x izquierda, y arriba, z adelante). Godot la convierte con la escala y la transformación del nodo.

**Prueba en Godot** (`pruebas/felipe_rig_pelota.gd`): quieto → sentarse → mira → pelota (3 bucles) → mira → levantarse. La pelota es una esfera roja con el toon. En cada contacto sale rodando adelante y al costado, gira según lo que avanza y vuelve sola al lugar del siguiente manotazo. Entregable: `felipe-rig-sentado-pelota.mp4`.

### v6c: la zona bajo la cola, blanca y limpia (2026-10-23, solo textura)
El creador: «tiene como el ano negro… difuminado». **Causa:** en la v4 se agregó una rampa de 45 px con el color de la montura bajo la raíz de la cola, para tapar un anillo blanco. De atrás se veía como una mancha oscura y borrosa entre las nalgas.
- **Arreglo** (`02b_lomo.py`): se quitó esa rampa. La grupa queda blanca y nítida, como en la vista de atrás de la v2/v3 que el creador marcó como buena.
- **Efecto lateral y su arreglo:** sin la rampa apareció un óvalo blanco en la cara de abajo de la raíz de la cola. Esos texels caen sobre la grupa en el mapa de perfil y se pintaban como cuerpo. Ahora se reclasifican en 3D: si la vecindad de un texel (5 cm) es en su mayoría cola, pasa a ser cola. Se repite hasta que deja de crecer (6 pasos). Los anillos de la cola y el lomo no cambian.
- **Otras zonas revisadas:** pecho, axilas, entre las patas y panza. No había otras manchas borrosas.
- **Sin cambios** en malla, rig ni animaciones: `felipe_rig.glb` se reexportó con la textura nueva, y `felipe_rig.json` quedó idéntico.
- **Entregable:** `felipe-v6c-bajo-cola.png`, con la meta del creador, antes y después desde atrás, atrás y abajo, 3/4 desde abajo y desde abajo, con la cola levantada 40°. También trae la sala a ×3 y las otras zonas revisadas.

