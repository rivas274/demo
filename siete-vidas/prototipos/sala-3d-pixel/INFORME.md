# Prototipo: sala-3d-pixel
Fecha: 2026-10-21 · Carpeta: siete-vidas/prototipos/sala-3d-pixel/

## Pregunta
Si el juego se hace en **3D renderizado como pixel art** (cámara ortográfica, 640×360, luz en escalones y contorno de 1 px), la sala se verá mejor y Valeria se moverá con más vida que con los sprites de pocas poses. Lo notaremos en la comparación lado a lado y en el clip: ¿la sala 3D se ve igual de bien o mejor, y Valeria se ve más viva?
Suposición más arriesgada: que con assets libres (CC0) el resultado tenga personalidad propia y no parezca un maniquí en una maqueta.

Aclaración del creador durante el trabajo: no importa que se vea como otro juego (estamos en concepto); hay que buscar que la sala 3D se vea lo mejor posible por sí misma. Además pidió un **Felipe 3D** para comparar con el sprite.

## Qué se construyó
- **La técnica en Godot 4.3 (renderizador Compatibility):** escena 3D con cámara ortográfica de lado inclinada 18°, dibujada en un `SubViewport` de 640×360 y mostrada con escala entera y filtro nearest. Shader toon propio: cada luz se corta en 3 tonos (sombra, medio y lleno), sin degradados, y la sombra es un tono plano algo violeta (luz cálida, sombra fría). Contorno oscuro de 1 px con **casco invertido** que se agranda en píxeles de pantalla. Sobre la imagen, una paleta limitada de 55 colores (tecla 1). La cámara sigue a Valeria y solo se mueve en múltiplos exactos de un píxel, así que el fondo no tiembla.
- **La sala:** pared con papel a rayas, ventana con persiana y cielo de atardecer (el sol entra por el hueco y proyecta la persiana en el piso), piso de tablas, sofá, alfombra, mesita con **lámpara encendida** (luz cálida con sombra, en anillos escalonados), librero, libros, plantas y un cuadro. Los muebles son de Kenney (CC0), recoloreados con colores de la sala del juego.
- **Valeria 3D:** maniquí CC0 de Quaternius con animaciones reales: caminar, quieta, sentarse, sentada y pararse. Está recoloreada por hueso (sudadera verde azulado, pantalón gris oscuro, piel, zapatillas), con pelo y moño de esferas y ojos de 2 px. Sigue un guion en bucle de unos 17 s: entra, gira, se sienta en el sofá, se queda, se para y se va. Con Tab pasa a modo manual (flechas).
- **Felipe 3D (pedido extra):** en OpenGameArt no había un gato 3D libre con proporciones de persa chibi; los que hay son delgados o realistas. Lo armé con primitivas a su escala (58 px de las orejas a las patas, 67 px con la cola y la cabeza al 56 %), con la paleta de la guía: lomo atigrado con rayas, pecho, panza y patas crema, gorro con franja blanca, cachetes de persa, nariz rosada y ojos verde avellana a media asta. Está animado por código: patas alternadas, respiración, cola que se mece y salto al sofá con estirar y aplastar de ±8 %. Camina, salta al sofá junto a Valeria, se queda y baja. Para que se lea en 3/4 se gira 40° hacia la cámara.
- **Felipe 2D:** su sprite del juego como `Sprite3D` (escala 0.72, 67 px), caminando a la derecha de la sala para comparar.
- Quedó fuera a propósito: control de Felipe, colisiones, HUD, sonido y la casa entera.

Para abrirlo: Godot 4.3 → `siete-vidas/prototipos/sala-3d-pixel/project.godot` → F5. Teclas: **1** activa o quita la paleta, **2** el contorno, **3** los escalones de luz; **Tab** cambia entre guion y modo manual, **F1** muestra la ayuda.

## Qué pasó
Capturas del bot de cámara (sin jugadores de verdad; falta que el creador lo mire):
- Hoja de la sala, la actual contra la 3D: `/tmp/claude-0/-home-user-demo/38ed3265-b77e-553c-bb05-17ea4f4a88e4/scratchpad/proto3d/hoja-sala-2d-vs-3d.png`
- Hoja de Felipe, 2D contra 3D a ×3, más la escena: `/tmp/claude-0/-home-user-demo/38ed3265-b77e-553c-bb05-17ea4f4a88e4/scratchpad/proto3d/hoja-felipe-2d-vs-3d.png`
- Clip de 18 s: `/tmp/claude-0/-home-user-demo/38ed3265-b77e-553c-bb05-17ea4f4a88e4/scratchpad/proto3d/sala-3d-pixel.mp4`
- Paleta activa contra paleta apagada: `/tmp/claude-0/-home-user-demo/38ed3265-b77e-553c-bb05-17ea4f4a88e4/scratchpad/proto3d/pal_vs.png`

Lo que se ve:
- **0 a 4 s:** Valeria entra caminando. La caminata se lee fluida y con peso: brazos, cadera y pasos de verdad, algo que hoy no tenemos con sprites. La cámara la sigue sin que el fondo tiemble.
- **4 a 6 s:** Valeria gira de frente y se sienta en el sofá con un movimiento continuo; Felipe 3D llega caminando. **6 s:** Felipe salta al cojín junto a ella. **6 a 11 s:** los dos quedan sentados; la luz de la lámpara les pega en escalones.
- **11 a 17 s:** Felipe baja, Valeria se para y se va.
- **La luz:** es lo mejor del prototipo. La lámpara pinta anillos cálidos en la pared, la pantalla de la lámpara proyecta su sombra y el sol pasa por la persiana hasta el piso. Todo eso sale solo, sin dibujar ni un rayo.
- **Valeria no se ve como Valeria:** el maniquí es un huevo sin cara, de hombros anchos y cuerpo neutro. Con dos ojos de 2 px parece un muñeco de madera o un maniquí de tienda, no una persona. En la sala 2D, en cambio, tiene cara, expresión, pelo con volumen y capucha.
- **Felipe 3D se reconoce como "un gato chibi atigrado" pero no del todo como Felipe:** le faltan el pelaje esponjado del persa, la cara chata y la mirada de reojo con carácter. Al lado del sprite se ve más simple y más juguete. El sprite 2D convive técnicamente (escala correcta, se ordena bien en profundidad), pero estilísticamente choca: un dibujo detallado con contorno propio frente a volúmenes planos.
- **La paleta** calma los amarillos quemados de la luz, pero **mueve los colores del sprite de Felipe** hacia violeta. Si se usa, el sprite tiene que quedar fuera de la cuantización o la paleta se ajusta a él.
- **Comparada con la sala actual:** la 2D tiene mucho más detalle de ilustración (papel mural con dibujo, madera con veta, objetos con historia, el cuadro de Felipe). La 3D tiene más profundidad, luz y movimiento, pero objetos más genéricos ("muebles de Kenney"). **Sí, se ve como otro juego**: más "diorama low-poly" que "pixel art pintado".

## Qué aprendimos
- **La técnica funciona en Godot 4.3 Compatibility** con contorno de casco invertido. Hay que trabajar sin buffer de profundidad (Compatibility no lo da en 4.3) y sin Vulkan en la sesión. El contorno por casco no marca los bordes interiores, solo la silueta; para eso haría falta Forward+, con post-proceso de profundidad y normales.
- **La cámara ortográfica no da paralaje:** la profundidad se lee por solapamiento y por la inclinación, no al moverse. Si se quiere paralaje, la cámara tiene que ser en perspectiva con FOV estrecho, y entonces el ajuste a píxeles es más difícil.
- **La luz es la gran ganancia:** escalones cálidos, sombras proyectadas y sol por la persiana, gratis y dinámicos (por ejemplo, si Felipe tira la lámpara, la luz se mueve con ella).
- **La animación también gana:** con una sola biblioteca CC0 Valeria camina, se sienta y se para sin pedir arte nuevo, y cualquier animación de esa biblioteca (más de 40) sirve para otro humano.
- **El cuello de botella es el personaje, no la técnica:** sin un modelo de Valeria hecho a medida (cara, pelo, ropa y proporciones), los humanos 3D se ven genéricos. Con assets libres no se llega a la calidad de personaje que ya tiene el arte 2D.
- Felipe 3D con primitivas sirve para probar el movimiento, pero el personaje del juego depende de su pelaje y su cara de reojo. Eso pide un modelo esculpido con textura pintada.

## Felipe en 3D
- **¿Se reconoce?** A medias. Se lee como un gato chibi atigrado de cola grande, con los colores de Felipe, y el salto al sofá se siente natural. Pero no tiene la cara chata, los cachetes esponjados ni la mirada de reojo que hacen a Felipe. A 67 px, la cara son 3 o 4 píxeles de ojo y nariz.
- **Qué se gana:** cualquier movimiento sin pedir hojas (girar, saltar a cualquier altura, sentarse junto a alguien), consistencia total entre animaciones (siempre es el mismo modelo, que hoy es la regla más cara del proyecto) y que recibe la luz de la escena como los demás.
- **Qué se pierde:** el dibujo. El sprite tiene pelaje, volumen pintado y expresión. El 3D toon hecho con primitivas parece un juguete. Para igualarlo hace falta un modelo esculpido con textura pintada a mano y un rig con cola y orejas, trabajo de artista 3D.
- **Recomendación:** si el juego se pasara a 3D, Felipe también tendría que ser 3D, porque el sprite no convive en estilo. Pero no con primitivas: con un modelo hecho a medida. No lo cambiaría ahora.

## Si el juego entero fuera así
**Qué cambiaría:**
- **Felipe:** modelo 3D propio en lugar de las 22 hojas, con rig de gato (cola, orejas, columna). Las animaciones (caminar, correr, saltar, trepar, arañar, comer, etc.) se rehacen en 3D. Se acaba el problema de "que sea el mismo gato" y se pierde el trabajo hecho con SpriteCook.
- **Casa:** cada habitación se arma con muebles 3D en vez de fondos pintados. Las alturas reales y la escala de gato se respetan solas, porque todo está en metros. La luz por habitación (lámpara, sol, refrigerador abierto) sale gratis. Los objetos que se tiran tendrían física de verdad.
- **Barrio:** calles y fachadas modulares (hay kits CC0 de Kenney y Quaternius). Es lo que más rinde en 3D, porque se reutiliza mucho.
- **Humanos y jefes:** Valeria, vecinos y A.S.P.I. con modelo propio. Las animaciones humanas salen de bibliotecas CC0.

**Cuánto costaría (estimación gruesa):**
- **Tubería** (shader, contorno, cámara y paleta, llevados a Forward+ para tener contorno interior): de 1 a 2 semanas, que ya están medio hechas aquí.
- **Personajes con modelo propio** (Felipe, Valeria, 2 o 3 humanos, A.S.P.I.): es lo caro. Necesita un artista 3D o encargos: unas 1 a 2 semanas por personaje con rig y texturas pintadas, y Felipe más, por la cola y el pelaje. SpriteCook y Gemini no hacen modelos 3D animables, así que es dinero o tiempo fuera de las herramientas actuales.
- **Escenarios:** por habitación, 1 a 3 días con kits CC0 y recolor; más si se modelan muebles propios para tener la personalidad de la sala actual.
- **Rehacer el juego:** el movimiento de Felipe, las colisiones, el nivel 1 y las pruebas pasan de 2D a 3D. Es casi empezar la Fase 3 de nuevo: varias semanas.
- **Total:** de 2 a 4 meses de trabajo extra antes de volver a donde estamos, con un riesgo grande en el arte de personajes.

## Veredicto: CAMBIAR
La técnica sí da algo que el 2D actual no tiene: **luz viva, profundidad y humanos que se mueven de verdad**. Pero así como está, **no se ve mejor que la sala actual; se ve distinta y más genérica**: Valeria parece un maniquí, los muebles parecen de kit y Felipe 2D choca con el resto. Pasar todo el juego a 3D cuesta meses y depende de modelos de personaje hechos a medida, que hoy no podemos producir con nuestras herramientas.

Variante a probar (siguiente prototipo, una sola pregunta): **¿un híbrido mantiene el arte 2D y gana la animación de Valeria?** Valeria 3D con toon y contorno, renderizada a una hoja de sprites (o en vivo) **sobre la sala 2D actual**, con una cara pintada como textura. Si ni así se ve como Valeria, la recomendación sería DESCARTAR el 3D y pedir más poses 2D de Valeria al `director-arte`.

## Si seguimos
- Diseño a cerrar: si el 3D sería solo para humanos (híbrido) o para todo el juego; y el renderizador (Forward+ para contorno interior y post-proceso, o seguir en Compatibility).
- Arte que pediría (para el `director-arte`, con costo): un modelo de Valeria a medida (cara pintada, moño, sudadera con capucha), con rig compatible con la Universal Animation Library de Quaternius.
- Valores que funcionaron: 121 px por metro (Valeria 200 px, Felipe 67 px), cámara ortográfica de 2,975 m de alto inclinada 18°, cámara ajustada a 1/121 m, luz en 3 escalones (cortes 0,12 y 0,55, medio 0,55), ambiente violeta (0,36, 0,31, 0,44), lámpara de energía 1,8 y alcance 1,7 m, contorno de 1 px `#210c0a`, papel a rayas cada 0,16 m.
- Otra pregunta para después: ¿aporta el paralaje de una cámara en perspectiva lo suficiente para justificar perder el ajuste exacto a píxeles?
