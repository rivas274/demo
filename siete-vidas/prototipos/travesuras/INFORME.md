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
