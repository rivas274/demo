# Prototipo: travesuras
Fecha: 2026-10-18 · Carpeta: siete-vidas/prototipos/travesuras/

## Pregunta
Si el jugador hace travesuras con mañas de gato (tirar, arañar, maullar, intimidar), con la voz de Felipe y una respuesta épica tipo Balatro, sentirá que ser Felipe es divertido por sí solo; lo notaremos en que prueba todas las acciones sin que se lo pidan, las repite y se ríe con las frases.
Suposición más arriesgada: que se sienta bien **sin animaciones nuevas**, solo con efectos de código y la voz.

## Qué se construyó
- **La sala en una pantalla** (640×360), por código y fea a propósito: sofá arañable, control remoto en el brazo del sofá, mesa de comedor (75 cm) con vaso, repisa (1,30 m) con florero, plato de comida en el piso y una puerta de 104 px. Felipe a su escala (0.72, 67 px) con su movimiento y sus hojas copiadas del juego.
- **Acción (E)**: tirar lo más cercano (el vaso y el florero caen, rebotan y se rompen con trozos y sonido; el control cae y se puede patear), arañar el sofá (2 marcas por pulsación, pelusa) y comer (3 porciones). El efecto sale en el cuadro de impacto: cuadro 4 de `zarpazo` y cuadro 3 de `comer` (hallazgo B5). Antes del manotazo, si Felipe está pegado al objeto, da un pasito atrás para que la pata lo alcance.
- **Maullar (Q) e intimidar (R) sin animación propia**: maullar usa el cuadro 1 de `comer` (boca abierta, ojos cerrados), se estira hasta 8 %, salen ondas y notas de la boca y suena un maullido sintetizado. Intimidar usa `quieto` con lomo inclinado, ensanchado hasta 8 %, pelos erizados dibujados por código, temblor de un píxel, tinte rojizo y bufido.
- **Voz de Felipe**: cuadro de diálogo abajo con su retrato (las 9 caras) y 51 frases cortas por evento, sin repetir la última, con texto que se escribe solo y se salta con Enter. Valeria tiene su propio retrato provisional por código (enojada, contenta y neutra).
- **Respuesta épica**: congelado de 0,05 s al pegar la pata y de 0,06 a 0,09 s en la travesura, palabra que salta ("¡GRAVEDAD: 1 · VASO: 0!", "¡CRÍTICO! FLORERO: 0", "¡ZAPPING DEFINITIVO!", "¡GOL!", "¡RIIIP!", "¡MIAU!", "¡FSSSHH! TERROR"), "+N CAOS" con combo, sacudida, destello y sonido con peso. Valeria (unos 200 px) entra al oír ruido y grita "¡FELIPE!". Si Felipe ronronea cerca (S), lo perdona ("¡CARISMA CRÍTICO!") y le deja un snack; si no, lo persigue, se rinde, se va y repone todo. Todo lo que se rompe delante de ella vale el doble ("¡EN SU CARA! x2").
- **Quedó fuera a propósito**: menús, vidas, música, nivel, jefe y guardado.

## Qué pasó
Solo lo que se ve en el video del bot (`pruebas/demo.gd`, 65,8 s, juega con los mismos botones que una persona). Aquí no hay jugadores de verdad: falta la prueba del creador.
- **0–9 s, sofá:** arañó dos veces (3,2 y 3,7 s; las marcas quedan en el respaldo), tiró el control del brazo (6,2 s, "¡ZAPPING DEFINITIVO!") y lo pateó en el piso (8,8 s, "¡GOL!"). Cada golpe sale cuando la pata llega adelante (cuadro 4), no al apretar.
- **11–17 s, primer ciclo completo:** Valeria entró por el ruido acumulado (11,0 s, "¡FELIPE!" grande, sacudida y destello). Felipe ronroneó a su lado y ella lo perdonó en unos 2 s (13,2 s, corazones, "¡CARISMA CRÍTICO! ¡PERDONADO! +20"). Dejó un snack que Felipe se comió (15,4 s, "¡SNACK DE LA VICTORIA!").
- **21–32 s, vaso y florero:** el vaso salió volando justo en el cuadro del manotazo y se rompió en el piso (21,7 s, "¡GRAVEDAD: 1 · VASO: 0!", y Felipe piensa "Arte." o "Yo no lo empujé. Lo liberé."). Valeria llegó, Felipe saltó a la repisa y tiró el florero delante de ella (26,4 s, "¡EN SU CARA! x2", +30). No ronroneó: Valeria lo "persiguió" desde abajo señalándolo (no alcanza la repisa), se rindió a los 3 s y se fue, y el cuarto se repuso.
- **36–50 s, plato, maullar e intimidar:** comió dos veces (36,6 y 37,9 s; "¡ÑAM!" y migas), maulló (39,4 s), intimidó (41,1 s), volvió a maullar y eso trajo a Valeria (43,9 s). La intimidó en su cara (44,9 s, x2) y luego ronroneó para que lo perdonara (47,3 s).
- **53–65 s, repetición:** el vaso repuesto se volvió a tirar y el ciclo tirar → grito → ronroneo → snack se repitió completo. CAOS final: 170 en 35 eventos.
- **Problemas que se ven en el video:**
  - Valeria señala desde el piso cuando Felipe está en la repisa y no hace nada más: la "persecución" casi no se nota.
  - El florero repuesto aparece encima de Felipe si él sigue en la repisa.
  - A veces la frase de Felipe sale tarde, porque espera a que Valeria termine la suya: "Persecución mediocre." aparece cuando ella ya se fue.
  - Intimidar se lee como un gato enojado y erizado, pero con la cara de reojo de siempre.
- **Arreglado durante la revisión:** Felipe tapaba el vaso con el pecho antes del manotazo (ahora da un pasito atrás) y Valeria tapaba el florero con la cabeza (ahora se dibuja detrás de los objetos).
- **Capturas:**
  - `capturas/vaso-cuadro-impacto.png`: 12 cuadros seguidos; la pata sube, baja y el vaso sale justo cuando la pata llega.
  - `capturas/maullar.png`
  - `capturas/intimidar.png`
  - `capturas/valeria-perdona.png`
  - `capturas/florero-en-su-cara.png`
- **Video:** `prototipo-travesuras.mp4` (1280×720, con sonido), entregado aparte.

## Qué aprendimos
- **Lo que confirma el bot (técnico, no de sensación):** el ciclo del pilar 3 (hacerla → que te pillen → salirte con la tuya) cabe en un cuarto y se repite solo, porque Valeria repone todo al irse. Poner el efecto en el cuadro de impacto (B5) hace que el vaso se vea empujado por la pata. Con congelado, palabra, sacudida, sonido y frase, cada travesura "provoca algo" (pilar 5).
- **La suposición más arriesgada sigue abierta:** maullar se entiende con el cuadro de boca abierta más ondas y notas. Intimidar se entiende por los pelos y el temblor, pero la cara no cambia. Si eso basta, solo lo puede decir el creador jugando.
- **Sorpresa:** "en su cara" (romper delante de Valeria vale el doble) da una razón para esperarla en vez de escapar, y le da la vuelta al sigilo, como pide el anti-pilar.
- **Siguiente pregunta (otro prototipo):** ¿maullar e intimidar sirven como llave además de travesura (pilar 2)? Aquí solo traen a Valeria y suman caos; no abren nada.

## Veredicto (v1): CAMBIAR — 2026-10-18
El creador: tirar cosas divierte "en un principio sí, pero sin incentivos para hacerlo pierde sentido"; el medidor de CAOS "no tiene sentido" y el puntaje no es útil. La base (acciones, voz, respuesta épica, Valeria) se queda; falta el motivo. Variante a probar (v2): la **Agenda de Su Majestad** (lista de travesuras con nombre, algunas secretas, con recompensa real) en lugar del medidor de CAOS.

## Si seguimos
- **Diseño a cerrar:**
  - Qué hace Valeria cuando no alcanza a Felipe (¿lo baja de la repisa en brazos?).
  - Cuánto ronroneo hace falta según la reputación y el peso (pilar 4).
  - Si el CAOS se queda como número en pantalla o pasa a la reputación.
  - Una sola cola para el diálogo, para que Felipe no conteste tarde.
- **Animaciones que pediría** (para el `director-arte`, desde Felipe A con `animate_game_art`, 20 créditos cada una aprox.; comprobar el saldo antes):
  - **Maullar:** "el gato levanta la cabeza, abre la boca y maúlla fuerte con los ojos cerrados, y vuelve a la pose". Hoy se toma prestado un cuadro de `comer`.
  - **Intimidar:** "el gato arquea el lomo de lado, eriza el pelo y la cola, aplana las orejas y bufa mostrando los colmillos". Hoy es `quieto` con efectos.
  - **Empujar (opcional):** la pata estirada despacio mirando a la cámara para tirar cosas; ya estaba propuesta en la revisión del nivel 1. Hoy sirve `zarpazo` con el impacto en el cuadro 4.
- **Valores que funcionaron (perillas):**
  - Congelado: 0,05 s al pegar la pata y de 0,06 a 0,09 s en la travesura; 0,1 s en el perdón.
  - Caos por travesura: vaso 10, florero 15, control 8, patada 4, arañazo 5, maullido 3, intimidar 6 y perdón 20. Vale x2 delante de Valeria. Combo: ventana de 3 s, hasta x5.
  - Valeria: viene con 3 de ruido acumulado (una rotura sola basta) y perdona con 0,9 s de ronroneo a menos de 110 px. Da 5 s para el encanto antes de perseguir, y persigue 3 s.
  - Felipe: tira el objeto parado a 34 px; da 2 arañazos por pulsación; maullar dura 0,75 s e intimidar 1,0 s, ambos con deformación de hasta 8 %.
  - Texto: 55 letras por segundo; cada frase espera 1,3 s más 0,035 s por letra.

## v2: Agenda de Su Majestad
Fecha: 2026-10-18 · Misma carpeta, 0 créditos.

### Pregunta
Si cada travesura es un objetivo con nombre y una recompensa útil (la Agenda de Su Majestad, como la lista de Untitled Goose Game), el jugador va a buscar y planear travesuras en vez de romper al azar. Lo vamos a notar en que busca las secretas, intenta completar la lista y se detiene a leer la agenda.
Suposición más arriesgada: que una lista con recompensas dé ganas de seguir en un cuarto chico.

### Qué se construyó
- **Fuera el CAOS:** no quedan medidor, "+N CAOS", combos ni números de puntaje (la prueba lo revisa en todas las etiquetas de la pantalla). Se queda lo épico: congelado, palabras que saltan ("¡CRÍTICO! FLORERO: 0", "¡ZAPPING DEFINITIVO!", "¡IMPACTO DIRECTO!"), sacudida, destello, sonido y la voz de Felipe.
- **La Agenda (Tab o Select):** una libreta con letra inclinada de Felipe, casillas, tachado, "¡HECHO!" y la recompensa de cada renglón. Mientras está abierta, el juego queda en pausa. Tiene 6 travesuras, 4 visibles y 2 secretas que se ven como "???" hasta cumplirlas (en la v2b pasó a 7, ver abajo):

  | Travesura | Recompensa |
  | --- | --- |
  | Derribar el florero heredado de la abuela | Foto vergonzosa (Valeria en pijama de unicornio; estaba escondida en el florero) |
  | Arañar el sofá nuevo (todavía tiene el plástico) | Calcetín (con 6 arañazos se rompe el plástico y sale de entre los cojines) |
  | Tirar el control mientras Valeria ve su serie | Camino: el control cae, la persiana sube y el alféizar pasa a ser una plataforma con un calcetín |
  | Que Valeria me perdone 2 veces | Un snack por cada perdón, que se guarda |
  | ??? Tirarle algo encima a Valeria | Snack de emergencia (se le cae del bolsillo) |
  | ??? Intimidar a la aspiradora | Calcetín (huye en pánico y lo escupe) |
- **Cosas nuevas en el cuarto, todas a escala de gato:** una ventana con persiana sobre el sofá (alféizar de 128 px a 1,40 m), una tele en la pared, una aspiradora robot de 48 × 18 px bajo la mesa, el plástico con su etiqueta "NUEVO" en el sofá, y recompensas que se recogen al pasar (calcetín de 24 × 26, snack de 32 × 16 y foto de 30 × 26).
- **Valeria cambió un poco:** cuando perdona queda de buenas y se sienta a ver su serie 12 s (sentada, con cabritas). Si le tiran el control, se para y regaña. Si le cae algo encima, se sobresalta ("¡AAAY!").
- **Pistas en el cuarto:** la etiqueta "NUEVO", la punta de un calcetín que asoma bajo la persiana y la aspiradora que ronca ("z") bajo la mesa.
- **Respuesta al cumplir:** congelado, destello, el cartel "¡TRAVESURA CUMPLIDA!" (dorado) o "¡TRAVESURA SECRETA!" (rosado) con el nombre y la recompensa, y una frase de Felipe ("Spoiler: se cortó la serie."). El cartel sale medio segundo después de la travesura para que primero se vea el gag. Si Felipe está arriba, o si lo que importa pasa arriba (la persiana), el cartel va más abajo.
- **Íconos arriba a la izquierda:** AGENDA n/6, calcetines n/3, snacks y fotos. Saltan al sumar.
- **Resumen del día, tipo Balatro:** sale con la agenda completa (cuando no queda nada por recoger) o con F. Las filas aparecen una a una con números que suben contando: Travesuras, Secretas, Calcetines, Fotos vergonzosas, Snacks guardados y las veces que Valeria te perdonó. Al final, una frase de Felipe ("Seis de seis. La casa es mía. Como siempre fue.").
- **Fallos de la v1 arreglados:**
  - Una frase que espera en la cola se descarta a los 2 s, así que Felipe ya no contesta cuando Valeria se fue.
  - Si Felipe está donde va un objeto (el florero en la repisa), Valeria espera a que se mueva para reponerlo.
  - Los dos arañazos de una pulsación ya no pisan sus palabras.

### Qué pasó
Solo lo que se ve en el video del bot (`pruebas/demo.gd`, 74 s con sonido, los mismos botones que una persona). Los segundos son de juego y no cuentan los ratos con la agenda abierta. Aquí no hay jugadores de verdad: falta la prueba del creador.
- **Al empezar:** el bot abre la agenda (3 s). Se lee completa en una pantalla, con las dos secretas como "???".
- **0–8 s, sofá:** tres pulsaciones de arañar (6 arañazos) rompen el plástico a los 6,1 s ("¡PLÁSTICO: 0!" y cartel). El calcetín salta de los cojines y lo recoge a los 7,4 s (calcetines 1/3).
- **9–21 s, la cadena con Valeria:**
  - El ruido de arañar la trae (9,6 s). Felipe ronronea, ella lo perdona (11,3 s, "AGENDA: 1/2") y el snack queda guardado.
  - De buenas, se sienta a ver su serie (14,9 s, la tele se enciende). Felipe sube al asiento y tira el control del brazo (17,5 s): "¡ZAPPING DEFINITIVO!", ella se para ("¡FELIPE! ¡MI SERIE!"), la persiana sube y se cumple la travesura.
  - Ronronea otra vez y llega el segundo perdón (19,7 s), que cumple "perdóname 2 veces".
  - Una travesura dejó lista la siguiente: la del control solo se puede hacer después de un perdón.
- **22–33 s, el camino y la primera secreta:**
  - Felipe salta del asiento al alféizar y agarra el calcetín (23,9 s, 2/3). El bot vuelve a abrir la agenda: 3 tachadas con su recompensa en verde.
  - Baja, le bufa a la aspiradora (≈29 s): "¡PÁNICO ELECTRODOMÉSTICO!", huye chocando, escupe el calcetín ("¡PTUH!", 30,0 s) y sale "¡TRAVESURA SECRETA!". Calcetines 3/3.
- **39–44 s, florero:** Valeria termina su serie y se va (39,4 s). Felipe tira el florero desde la repisa (40,4 s, "¡CRÍTICO! FLORERO: 0" y cartel), la foto cae flotando y la recoge a los 43,9 s ("Valeria en pijama de unicornio. Esto vale oro.").
- **47–56 s, segunda secreta:** desde la mesa maúlla 3 veces hasta que Valeria entra (52,7 s). Con ella al lado, el manotazo le revienta el vaso encima (53,2 s): "¡IMPACTO DIRECTO!", "¡AAAY!" y "¡TRAVESURA SECRETA!". Se le cae el snack de emergencia (snacks 3).
- **58 s, resumen:** Travesuras 6/6 · Secretas 2/2 · Calcetines 3/3 · Fotos 1 · Snacks 3 · Valeria te perdonó 2 veces, con la frase final.
- **Problemas que se ven en el video:**
  - Dos carteles seguidos (control y segundo perdón) tapan la mitad de arriba unos 4 s. El bot espera a que terminen; un jugador podría perderse lo que pasa arriba.
  - En una toma anterior, el florero le cayó encima a Valeria mientras ella salía, así que la secreta se cumplió por casualidad y el resumen salió con recompensas todavía en el piso. Se arregló: el resumen espera a que no quede nada suelto. La casualidad en sí es buena señal (las secretas pueden salir solas), pero también significa que una secreta se puede cumplir sin entenderla.
  - Valeria no reacciona a lo que pasa mientras sale (el florero puede romperse delante de ella sin un grito).
  - El calcetín del alféizar se puede agarrar con la cabeza en medio del salto, sin pararse en el alféizar.
  - Los snacks se juntan pero todavía no sirven para nada (solo se cuentan).
  - Sentada en el sofá, Valeria queda pegada a Felipe cuando él está en el asiento; se lee, pero está apretado.
- **Capturas:**
  - `capturas/v2-agenda.png`
  - `capturas/v2-persiana-se-abre.png`
  - `capturas/v2-alfeizar-calcetin.png`
  - `capturas/v2-vaso-encima-de-valeria.png`
  - `capturas/v2-resumen.png`
- **Video:** `prototipo-travesuras-v2.mp4` (1280×720, con sonido), entregado aparte.
- **Pruebas:** `prueba_agenda.gd` (36 comprobaciones) y `prueba_impacto.gd` (13 de la v1) pasan.

### Qué aprendimos
Pendiente de la prueba del creador. Lo único que confirma el bot es técnico:
- La agenda completa cabe en el cuarto chico, en unos 60 s de juego.
- Las travesuras se pueden encadenar: perdón → serie → control → persiana → calcetín.
- Las recompensas aparecen donde se ven.

Si eso hace que alguien *planee*, lo tiene que decir alguien jugando.

### Agregado en la v2b (2026-10-19): el rascador y los diálogos de Valeria
Misma pregunta y misma carpeta, 0 créditos. Fue una decisión del creador: "Teatro para Valeria".
- **Rascador nuevo y caro** junto al brazo derecho del sofá, dibujado por código: poste con cuerda, base, plataforma y pompón, de unos 75 cm (90 px), con la etiqueta "$89.990" colgando. No tiene colisión. Se araña con E desde el piso, mirándolo, con la misma animación `zarpazo` y el efecto en el cuadro 4: hilos en la cuerda, fibras y un bamboleo de un píxel.
  - **Con público** (Valeria en la sala y mirando hacia el rascador, también sentada viendo la tele): perdón al instante, que cuenta para "perdóname 2 veces" y da su snack. Ella dice "¡Mira, sí lo usa! ¡Valió cada centavo!", sale "¡OVACIÓN!" y "¡PERDONADO SIN RONRONEAR!", y saca el celular con flash. Vale una vez por visita: el bis no se cobra.
  - **Sin público:** Felipe se queja ("¿Para quién actúo?", "Sin público no hay función.", "Arte desperdiciado. Nadie miró.") y no hay premio.
  - **Garras afiladas:** al usarlo, con o sin público, quedan 6 s de filo, con chispitas en la pata delantera que parpadean al final. El siguiente arañazo al sofá es "¡CRÍTICO!" (congelado, destello y sacudida) y rompe el plástico de un golpe.
- **Tercera secreta:** "Arañar el sofá justo al lado del rascador nuevo". Se cumple arañando el brazo del sofá pegado al rascador **mientras Valeria mira hacia él**. Se juntaron las dos condiciones que propuso el creador porque el brazo derecho es justo donde araña cualquiera que llega desde el piso: sin Valeria, la secreta saldría siempre en el primer arañazo. Recompensa: **otra foto vergonzosa** (Valeria de rodillas arañando el rascador "para enseñarle"), que estaba detrás del rascador. Valeria grita "¡Pipe! ¡El rascador está AHÍ! ¡A diez centímetros!" y después "Esto va directo a mis historias." con el flash. Felipe: "El rascador es para mirarlo. El sofá, para arañarlo." La agenda pasa a 7 (4 visibles y 3 secretas), y el HUD, la libreta y el resumen cuentan sobre 7 ("Siete de siete...").
- **Diálogos de Valeria pulidos**, con la voz de la biblia: le dice "Pipe", le habla como a un bebé, teletrabaja y sube todo a redes. El chiste es el contraste: él se cree un dios y ella lo trata de bebito gordito, y el enojo se le pasa al pensar en sus seguidores. Algunas frases: "¡PIPE! Estoy en una reunión...", "Felipe Ron con Pasas Primero. Nombre completo. Estás en problemas.", "¡El florero de mi abuela! Sobrevivió a dos mudanzas, Pipe. DOS.", "Ya, ya. Te perdono porque tengo que subirte a mis historias.", "¡NO! ¡Justo cuando se iban a besar!", "¿Quién subió la...? Pipe, ¿desde cuándo tienes pulgares?". Cuando perdona saca el celular con flash; es solo efecto y frase, sin mecánica.
- **Arreglos de diálogo que salieron al revisar el video:**
  - La frase de Felipe al cumplir una travesura le borraba la reacción a Valeria. Ahora él espera a que ella termine.
  - "¡GARRAS AFILADAS!" se pisaba con la ovación; ahora sale después.
  - El "¡RIIIP!" del segundo arañazo tapaba el "¡CRÍTICO!".
  - La frase de la persiana se cortaba. Ahora Valeria la dice al sentarse.
  - El último renglón de la agenda (7) chocaba con el pie de la libreta.
- **Qué se ve en el video del bot** (`prototipo-travesuras-v2b.mp4`, 95 s con sonido; segundos de juego):
  - **1,8 s:** el rascador sin público. Felipe dice "Arte desperdiciado. Nadie miró." y le quedan las chispitas.
  - **4,9 s:** con las garras afiladas, sube al sofá. El primer arañazo es "¡CRÍTICO!" y el plástico se rompe de un golpe; antes hacían falta 3 pulsaciones.
  - **12–15 s:** maúlla y llega Valeria ("¡PIPE! Estoy en una reunión..."). Ronronea, ella lo perdona con flash y se sienta a ver la tele.
  - **21 s:** tira el control ("¡NO! ¡Justo cuando se iban a besar!"). Felipe baja al rascador y, con ella regañándolo, lo araña. Llega el perdón 2 al instante (23,8 s): "¡Mira, sí lo usa!", "¡OVACIÓN!" y el cartel. Valeria vuelve a la tele y dice la frase de la persiana.
  - **28,6 s:** con ella viendo la tele, araña el brazo del sofá pegado al rascador. Con el filo que le quedaba sale otro "¡CRÍTICO!", junto con "¡A DIEZ CENTÍMETROS!" y "¡TRAVESURA SECRETA!". Viene la frase de Felipe y luego "Esto va directo a mis historias." con el flash. La foto cae sobre la mesa.
  - **Después:** sigue como antes con el alféizar, la aspiradora, el florero ("¡El florero de mi abuela!..."), la persecución, el vaso encima ("Acabo de lavarme el pelo. ACABO.") y el resumen: 7/7 · 3/3 · calcetines 3/3 · fotos 2 · snacks 3 · 2 perdones.
- **Problemas que todavía se ven:**
  - El cartel del perdón 2 tapa la cabeza de Valeria con el celular. El flash alcanza a verse porque el cartel sale medio segundo después.
  - El rascador queda apretado entre el sofá y la mesa, y la etiqueta del precio se monta sobre la pata de la mesa.
  - Al empezar, Felipe aparece encima del rascador.
  - Que el perdón valga una vez por visita es una decisión mía para que no se puedan juntar snacks sin fin. Hay que confirmarla.
- **Capturas:**
  - `capturas/v2b-rascador-sin-publico.png`
  - `capturas/v2b-rascador-ovacion.png`
  - `capturas/v2b-secreta-junto-al-rascador.png`
  - `capturas/v2-agenda.png` y `capturas/v2-resumen.png`, actualizadas a 7.
- **Pruebas:** pasan `prueba_agenda.gd` (54 comprobaciones, entre ellas la queja sin público, el CRÍTICO tras afilar, el perdón con público, que el bis no da premio y la secreta nueva) y `prueba_impacto.gd` (13).
- **Para mirar al jugar:**
  - ¿El rascador hace que esperes a Valeria a propósito, como "en su cara" pero al revés?
  - ¿La queja sin público da risa?
  - ¿Te dan ganas de afilar antes de ir al sofá?

### Veredicto (v2): PENDIENTE
Lo decide el creador jugando (F5). Qué mirar: las preguntas de "Qué mirar en la v2" del README.

**Siguientes preguntas (para otros prototipos, no para este):** ¿para qué sirven los snacks y los calcetines (llave, ronroneo más fuerte, cosmética)? ¿Una agenda por habitación o una por día?

## Veredicto (v2 + v2b): SEGUIR — 2026-10-19
El creador: "me gusta, mejoró"; pidió pulir los diálogos de Valeria (hecho en v2b) y pasar al nivel 1. La Agenda, el rascador como teatro para Valeria y su voz entran al diseño del nivel 1 (`siete-vidas/diseno/nivel-01-propuesta-v4.md`).
