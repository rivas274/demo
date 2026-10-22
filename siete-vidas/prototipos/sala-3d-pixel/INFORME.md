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
- **Fuente:** `assets/meshy_prueba/valeria/mixamo/valeria_animada.glb` (malla Meshy + 5 clips de Mixamo). Si no está, junta los FBX de esa carpeta copiando las pistas `mixamorig` al esqueleto del FBX con skin; si no hay nada, usa `valeria_meshy.glb` estático. Para probar cada uno: `--valeria-fbx` y `--valeria-estatica`.
- **Código:** `scripts/valeria_mixamo.gd` (rutina), `scripts/mixamo_carga.gd` (carga, copia de pistas, medidas), `scripts/principal_valeria_mixamo.gd` (la sala sin Felipes).
- **Sin patinar:** la caminata de Mixamo avanza; se ancla la raíz y el nodo avanza a la velocidad medida en la propia animación (1,41 m/s; medida en los pies apoyados da 1,33 m/s).
- **Sentada de verdad:** la cadera del clip Sitting Idle se lleva a 10 cm sobre el cojín (asiento a 0,425 m). Sentarse y levantarse son cortes con mezcla de 0,6 s (no hay clips de transición); entre las demás, 0,25 s.
- **Recoger:** la pelota aparece en el piso donde la mano llega más abajo y desde ese cuadro va pegada a la mano.
- **Estilo:** material toon de la sala con la textura de Meshy como color; los bordes salen del post-proceso de la sala.

**Qué se ve** (`valeria-mixamo.mp4`, 24 s, en la carpeta de capturas): entra caminando, mira el celular, camina al sofá, se sienta sobre el cojín con los pies en la alfombra, se levanta, recoge la pelota y sale. Es Valeria (moño, cara, sudadera, pantuflas) y se mueve como una persona, sin la postura encorvada de la v3. Pendiente: el celular no aparece en la mano (Mixamo no trae objetos) y al agacharse se ve sobre todo la coronilla.
