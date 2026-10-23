# Consulta a Gemini: rediseñar la pelea contra A.S.P.I. (2026-10-23)

**Copia y pega todo lo que está debajo de la línea en Gemini, junto con las imágenes y el video adjuntos.**

Adjuntos:
- `pelea-aspi.mp4`: video de 41 s de la pelea actual, jugada por el bot.
- `hoja-pelea.png`: 10 cuadros del video, cada 4 s.
- `cuarto-izquierda.png` y `cuarto-derecha.png`: el estudio completo, que es la arena de la pelea.
- `objetos-tirados.png`: cómo quedan las cosas al tirarlas.

Las imágenes están en `siete-vidas/diseno/revisiones/capturas/pelea-aspi/`.

---

Hola. Estoy haciendo un juego de plataformas 2D en pixel art, de vista lateral, a 640×360: **«Felipe: Nueve Vidas, Cero Disculpas»**. Felipe es un gato persa malcriado que se cree aristócrata; el humor es una sátira desde su punto de vista. Pilares: «Siempre te sales con la suya», «Cada maña es llave y travesura» y «Épico en su cabeza» (todo se vive épico, como en Broforce o Balatro, aunque sea algo cotidiano de gato). Sin sangre ni sufrimiento: los enemigos son juguetes y máquinas.

**El jefe del nivel 1 es A.S.P.I., una aspiradora robot.** Su título es «Devoradora de Pelos · Nivel 99». La pelea es en el estudio de Valeria, la dueña, que mide unos 2 pantallas de ancho. Hay dos islas de muebles para subir (silla, escritorio, repisas, una caja y un librero bajo) y la aspiradora anda por el piso.

**Cómo funciona hoy:**
- Felipe **tira cosas al piso** de un manotazo: un vaso, una taza, 2 macetas, una planta, un portarretratos y papeles. Si pisa el teclado, la impresora escupe papeles. Lo que cae deja una **mancha**.
- A.S.P.I. va a limpiar cada mancha con un aviso previo de 0,6 s. Mientras aspira, arrastra a Felipe si está cerca, y él puede agacharse para aguantar.
- Cuando junta 2, 3 y 3 manchas (según la fase), su **depósito se llena** y se queda quieta unos segundos pitando «¡DEPÓSITO LLENO!». Felipe le salta encima, aprieta su botón y la «golpea». Son 3 fases.
- **Ataques:**
  - **embestida**, avisada con una luz roja;
  - **soplido** contra Felipe si se queda arriba de un mueble mucho rato (desde la fase 2): lo bota al piso sin daño;
  - **bolas de pelo en arco** en la fase 3.
  - Si Felipe maúlla, A.S.P.I. gira hacia él.

**El problema que vio el creador:** para que nunca falten manchas, **lo que se rompe vuelve a aparecer en su lugar cada 6 segundos, de uno en uno**. El creador dice que **rompe la inmersión**: las cosas reaparecen por arte de magia. Preferiría algo más como que Felipe las **tumbe**, sin que vuelvan solas. Hay que replantear el recurso «manchas», pero sin perder lo que funciona: el ciclo de ensuciar, que ella limpie, que se llene y que Felipe le salte encima.

**Ideas que ya tenemos (opina y mejóralas):**
- **A. Tumbar y que quede donde cae:** nada desaparece ni vuelve. Las cosas quedan en el piso (tierra, libros abiertos, café derramado, papeles) y se agregan más fuentes de desorden al cuarto: unas 12 a 14 para 8 manchas necesarias. Al final el estudio queda destruido como trofeo.
- **B. A.S.P.I. devuelve la suciedad:** al apagarse en cada fase, su depósito se abre y escupe una montaña de pelusa que Felipe puede volver a esparcir.
- **C. Felipe es la suciedad:** se sacude o se frota y suelta una bola de pelo que cuenta como mancha («Devoradora de Pelos»). Con límite para que no sea repetitivo.

**Preguntas (responde en español, concreto y por puntos):**
1. ¿Cuál de las ideas A, B o C recomiendas, o qué combinación? ¿Por qué, pensando en la inmersión, la diversión y el humor?
2. Propón **2 o 3 ideas propias** para que nunca falte munición sin que nada reaparezca por magia. ¿Cómo lo resuelven otros jefes de juegos 2D? Da ejemplos de juegos concretos.
3. ¿Cómo harías que la pelea **escale en las 3 fases** si los objetos son limitados? ¿Cambia la arena (cosas que caen solas o que la aspiradora tumba al chocar)?
4. ¿Qué **momentos épicos o chistes** agregarías, en el tono de Felipe, para que se sienta más memorable?
5. Mirando el video y las capturas, ¿qué **otros 3 problemas** ves en la pelea (claridad, ritmo, lectura de los ataques, cámara, interfaz)? Ordénalos por importancia.
6. Si puedes, **dibuja una maqueta** del estudio con tu propuesta: dónde están las fuentes de desorden y por dónde se mueve A.S.P.I.

---

Guardar la respuesta de Gemini en `siete-vidas/diseno/revisiones/2026-10-23-gemini-pelea-aspi.md`, y lo que dibuje en `siete-vidas/diseno/revisiones/capturas/pelea-aspi/`. Después, Claude junta la propuesta de Gemini con la suya y la pasa por el diseñador de juego contra los pilares.
