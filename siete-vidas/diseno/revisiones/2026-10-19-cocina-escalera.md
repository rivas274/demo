# Cocina más grande, cajas de la mudanza y objetos apoyados (pasada única, 2026-10-19)

Pedido del creador (aprobado): cocina más grande con el arte de Gemini de la tanda 3F (`arte/referencias/gemini/cocina-v2.png`), cajas de la mudanza en vez de la reja «PIPE: NO», objetos sobre muebles al doble, apoyados en el centro y con sombra, y barreras que bloquean de verdad. 0 créditos. Fuentes: `memoria/06-lecciones-arte.md` (las 33 lecciones), `memoria/01-decisiones.md` (escalera con cajas, objetos más grandes y apoyados, cocina más grande), `revisiones/2026-10-19-cocina-gemini.md` y las capturas `capturas/2026-10-19-creador-r5-6..9.png`.

## Plan (corto)

1. **Arte:** procesar `cocina-v2.png` con `preparar_arte_nivel.py` (función nueva `cocina_v2()`, recorte al borde opaco): A mesón, B estufa, C alacenas, D pila de cajas (y sus partes: base de 2 cajas y caja de arriba), E caja abierta, F escoba. Escala de gato: cubierta del mesón y de la estufa a 90 cm = **109 px** (manda sobre los 130–140 de Gemini), alacenas 70 cm, cajas de unos 30 cm, escoba 1,1 m.
2. **Cocina de ~1300 px:** correr todo x ≥ 4000 con un script sobre los literales; recomponer de izquierda a derecha según Gemini (electrodomésticos que cortan la línea, mesón continuo, fregadero bajo la ventana), sin perder lo que pide el nivel (tazón, ratón, caja, silla, pollo y su camino, calcetín del refrigerador, maullido en la puerta, Valeria que ve el pollo). Colisiones medidas contra el arte (±2 px).
3. **Escalera:** quitar reja, cartel y `reja_frente.png`; pila sólida de cajas al pie; librero para pasar; tirar la caja de arriba desde el segundo peldaño = atajo (R6); frases nuevas; escoba de Gemini en vez de la de código.
4. **Objetos sobre muebles:** medir en el arte cuánto se ve la cara de arriba de cada mueble y apoyar cada objeto en su medio con sombra de contacto; quitar impresora y regleta; agrandar el libro del banquito.
5. **Barreras:** prueba que empuja a Felipe contra cada muro, mueble sólido, la pila de cajas y las puertas cerradas.
6. Capturas, checklist de lecciones, pruebas y bot, entregables y memoria.

## Aplicado

| # | Qué | Cómo |
| --- | --- | --- |
| 1 | Arte tanda 3F | `cocina_v2()` (al final de `ambientes()`): `meson` 476 × 156 (cubierta en la fila 47, el grifo sobresale), `estufa` 88 × 123, `alacenas` 190 × 80, `cajas_pila` 66 × 135, `cajas_base` 66 × 67, `caja_arriba` 66 × 70, `caja_abierta` 84 × 60, `escoba` 44 × 133. Las piezas viejas `meson`/`alacenas` salen de la lista de la tanda 1 |
| 2 | Cocina de 1340 px | 2800–4140. 173 literales corridos +380 (`sala.gd`, bot, pruebas, planta del primer plano; `ANCHO` 8260). Puerta → tazón, lata, croquetas → ratón (zarpazo) y caja → silla (55) → **estufa con olla** (109) → **mesón largo** (109) con el fregadero embutido y el grifo de cuello de cisne **bajo la ventana** (3682–3832) → microondas (163) con el pollo → refrigerador (216, calcetín). Alacenas sobre la estufa a 1,49 m; reloj a la izquierda. Se borraron el fregadero, el grifo y el paño de código (queda la gota, desde la boca del grifo del arte). Valeria espera frente a la estufa (desde ahí ve el pollo: «¡EN SU CARA!»). Ratón del mesón entre el fregadero y el microondas: nunca pasa delante del grifo ni del pollo (lección 28) |
| 3 | Cajas de la mudanza | `CajasMudanza` (`scripts/entidades/objetos/cajas_mudanza.gd`, borrado `reja.gd`): pila sólida de 64 × 133 al pie (2272–2336). Desde el piso: «Empujar» → «Cajas de la mudanza. Llevan un año «ordenándose».». Librero → por encima de la cesta → pie de la escalera (x 2362). Al bajar con la pila entera: «Desde aquí arriba, esas cajas se ven… empujables.». Segundo peldaño con colisión (2348–2372, 45 px, calza con el arte) → «Tirar»: la caja de arriba cae en arco, media vuelta, y queda abierta con la ropa en el piso; «¡PUM! · MUDANZA: 0», sacudida, logro «Atajo de Gato», Felipe «Mudanza terminada. De nada.» y Valeria (si está abajo sin audífonos) «¡Mis cajas! ¡Estaban ORDENADAS!». Quedan 2 cajas (67 px) y el borde de la caja abierta (33 px): ida y vuelta sin el librero |
| 4 | Escoba | Pieza F en 2590, apoyada fuera del armario bajo el descanso; la de código se borró |
| 5 | Objetos apoyados | `Vaso.hundido` y tercer dato de `Sala.TIRABLES`: mesa 5, consola 4, zapatero 2, escritorio 9 (cubierta vista de 16 px), repisa −6. Sombra 1 px más ancha que la base; posavasos de 1 px bajo cada vaso. Monitor, teclado, pantalla y post-its −9 px; microondas, monitor y libro con sombra (`Sala.APOYADOS`). Libro 42 × 12 en medio del asiento del banquito. Pollo hundido 3 px en la tapa del microondas |
| 6 | Estudio | Impresora (`impresora.png` borrada) y regleta con cables quitadas. Al pisar el teclado en la pelea vuelan los apuntes («¡FIUU!»); la reacción de la Agenda lo dice |
| 7 | Pruebas | `prueba_nivel`: empujes contra la pila (caminando y gateando), librero, bajar, «Tirar» solo desde el peldaño, vuelta y regreso por el atajo; cocina v2 (≥ 1300 px, grifo bajo la ventana, ratón lejos del grifo y del pollo, microondas sobre el mesón); **barreras** en una casa nueva (24 empujes contra muros, muebles sólidos y cajas; puertas cerradas de cocina, balcón y baño). `prueba_reglas_nivel`: R6 con las cajas (no se saltan desde el piso, la base sí), R7 pie detrás de las cajas, B4 colisión de las cajas contra su arte, microondas por su constante. Bot: nueva ruta de la cocina y de la escalera |
| 8 | Capturas | `capturas_nivel.gd`: vistas nuevas 4b (adentro), 4c (caja cayendo), 4d (caja tirada), 6 estufa, 6b fregadero, 6c refrigerador |

## Descartado

- **Mesón a 130–140 px (Gemini):** manda la escala de gato de CLAUDE.md (mesón 90 cm = 109 px).
- **Mueble bajo suelto de la hoja y `cocina-v2-isometrica.png`:** no se usan.
- **Ratón del mesón quitado:** no hizo falta; con el mesón largo patrulla un tramo propio lejos del grifo y del pollo y sigue siendo la llave del zarpazo (R19).
- **Caja que rueda escalones abajo de verdad:** la escalera es de fondo (sin colisión); la caja se vuelca desde la pila hacia afuera en arco y rebota en el piso.

## Checklist de lecciones (capturas ampliadas ×2–×3)

| # | ✔/✘ | Dónde se miró |
| --- | --- | --- |
| 1 | ✔ | Mismo marco de puerta en todos los cuartos (hoja) |
| 2 | ✔ | Nada tapa puertas; la caja abierta queda delante del librero, que ya no hace falta (su borde es el escalón) |
| 3 | ✔ | Estufa, mesón, alacenas, silla y cajas, cada uno en su pieza |
| 4 | ✔ | Colisiones a ±2 px (B4: estufa 86 %, mesón 99 %, microondas y refrigerador 100 %, peldaño 100 %, cajas medidas); piezas recortadas al borde opaco |
| 5 | ✔ | Tazón 48 × 35, pollo 64 × 50, cajas ≥ 24 px |
| 6 | ✔ | Las cajas de la mudanza se explican solas (Valeria «ordenando») |
| 7 | ✔ | La escalera sigue con `subir_escalera` |
| 8 | ✔ | Capas de la tabla única (cajas en MUEBLES, gota en MARCAS) |
| 9 | ✔ | Sin cambios en los ciclos de caminar |
| 10 | ✔ | Valeria camina hasta la estufa por la puerta |
| 11 | ✔ | «¡PUM!» y el logro pasan por la cola de anuncios |
| 12 | ✔ | La ventana de la cocina sigue con el alféizar a 109 px |
| 13 | ✔ | Cajas de la mudanza en el recibidor; ollas y estufa en la cocina |
| 14 | ✔ | Objetos en el medio de cada cubierta |
| 15 | ✔ | Armario bajo la escalera con su puerta y la escoba |
| 16 | ✔ | Muebles y cajas con su sombra en el piso |
| 17 | ✔ | Sin superficies de código nuevas |
| 18 | ✔ | Fregadero del arte, a escala del mesón, bajo la ventana |
| 19 | ✔ | Sin rectángulos de depuración |
| 20 | ✔ | Estufa y refrigerador cortan la línea del mesón; nada clonado |
| 21 | ✔ | Gota del grifo, segundero, croquetas, ropa en la caja abierta |
| 22 | ✔ | Sombras de contacto en muebles y objetos |
| 23 | ✔ | Escoba, refrigerador y estufa entran enteros con la cámara en sus límites |
| 24 | ✔ | Luz por la izquierda en las piezas nuevas |
| 25 | ✔ | Sin puertas nuevas |
| 26 | ✔ | Sin halos nuevos |
| 27 | ✔ | El resalte de las cajas sigue su silueta |
| 28 | ✔ | El ratón del mesón no pasa delante del grifo ni del pollo (prueba) |
| 29 | ✔ | Vaso, taza, monitor y libro apoyados con sombra |
| 30 | ✔ | Impresora y regleta quitadas |
| 31 | ✔ | Cocina de 1340 px, la cámara se mueve |
| 32 | ✔ | Escoba de Gemini; fregadero, grifo y paño de código quitados |
| 33 | ✔ | Prueba de barreras: 24 empujes y puertas cerradas, 0 fallos |
| 34 (nueva) | ✔ | El escritorio tenía 16 px de cubierta vista: hundir 1–2 px no alcanzaba; ahora 9 |
| 35 (nueva) | ✔ | Una captura dejó a Felipe dentro del mesón (salió bajo el piso): los puntos de captura van sobre algo libre |

**35 de 35 ✔.** Pregunta guía («¿el creador lo vería en 5 segundos?»): en la hoja solo quedan dos cosas menores a la vista, aceptadas: el poste del pasamanos tapa unos 6 px del costado de la pila (está delante, en la escalera) y las alacenas muestran su costado como el resto del arte de la tanda 3F.

## Resultados

- Pruebas: movimiento, escenario, mecánicas, nivel, reglas_nivel, jefe y acciones en **0 fallos**.
- Bot `partida.gd`: **3 de 3** (agenda 8 de 8, 3 calcetines, 3 fotos, logros completos, ~262 s).
- Entregables (fuera del repositorio): `cocina-escalera-antes-despues.png`, `cocina-escalera-detalles.png`, `nivel1-v4h.mp4`.
- **Felipe:** cambió su tabla de acciones (verbo «Tirar»; la reja salió de «Acción» y «Subir escalera»): memoria 02 y ficha (plantilla y copia local) actualizadas; la ficha en línea queda por publicar (pedido del creador).

## Segunda pasada: 3 puntos (2026-10-20)

Pedido del creador (aprobado, una sola pasada, 0 créditos de SpriteCook): llenar la entrada de la cocina, que el poste del pasamanos no tape la pila de cajas y que el mundo reaccione al tirar la caja de arriba. Hoja antes/después: `tres-puntos-antes-despues.png` (fuera del repositorio).

### Qué se hizo

| # | Punto | Cómo |
| --- | --- | --- |
| 1 | Entrada de la cocina vacía (media pantalla de pared con solo el reloj) | Isla de pared con arte de Gemini que ya estaba en el repo (`segunda_pasada_cocina()` en `preparar_arte_nivel.py`): repisa con ménsulas de `muebles-extra` (`repisa_cocina` 120 × 35) con la tabla a 1,24 m sobre el rincón del gato; encima, la maceta con flores de Valeria y la **reserva de croquetas** al doble (`croquetas_reserva` 38 × 44, de `comida-grande`): Valeria la guarda en alto, lejos de Felipe, que la mira desde el tazón. El reloj queda arriba a la derecha (grupo en triángulo, no en fila). Objetos apoyados en el medio de la tabla con sombra; la repisa da sombra en la pared. Decorado sin colisión (no se alcanza sin doble salto). El piso y la mitad derecha de la pared quedan libres (espacio negativo donde se juega); nada tapa la puerta, el tazón ni la lata |
| 2 | El poste del pasamanos tapaba el costado de la pila | Medido con máscaras de pixeles: entre el librero (hasta 2266; no se puede correr, lo limita el rectángulo de la puerta de la cocina, B3) y el poste (desde 2325) quedan 59 px y la pila medía 66: en ninguna x entraba sin cruzarse con uno de los dos. Se reescaló la pila a 0,32 (60 × 124, cajas de ~27 cm) y va en 2262, con 2 px de aire a cada lado. Colisión 58 × 122 (base 62). Sigue bloqueando (R6: 122 px, el salto llega a ~80), se pasa desde el librero y el atajo funciona (prueba de ida y vuelta) |
| 3 | Al tirar la caja casi nadie reaccionaba | Al caer: congelado, «¡PUM! · MUDANZA: 0», sacudida corta (0,15 s), **nube de polvo** (`CajasMudanza`, en la capa del juego, nunca encima de la imaginación del jefe) y **dos calcetines** (`ropa_1`, `ropa_2`, de `arriba-extra`; distintos del calcetín rayado que se colecciona) que saltan en arco: uno al piso junto a la caja abierta y otro sobre las dos cajas (nada delante de la puerta). **Valeria lo oye aunque tenga audífonos**, desde donde esté: se saca uno 3 s (`Valeria.sacar_audifono`) y dice con su retrato «¡¿Qué fue ESO?! …Perdón, era el gato. ¡FELIPE, MIS CAJAS!» (de la reunión); sin audífonos, «¡Mis cajas! ¡Estaban ORDENADAS!». Cuando cierra su frase, Felipe sin culpa: «Mudanza terminada. De nada.» (espera a que se cierre: no se pisan ni caducan en la cola). El logro «Atajo de Gato» va por la cola de anuncios y sale al costado, sin tapar el diálogo ni el golpe |

### Pruebas

- `prueba_nivel`: con los audífonos puestos (la ruta normal), tirar la caja da polvo, ropa esparcida, sacudida, el audífono afuera, la frase de Valeria, y después la de Felipe; Valeria sigue con audífonos al terminar. Posiciones de las cajas por sus constantes (no cambiaron números en las pruebas).
- `prueba_reglas_nivel`: B4 de las cajas (colisión contra el arte nuevo, ±2 px), R6 y B3 en 0 fallos.
- `capturas_nivel.gd`: vistas nuevas 4e (el golpe), 4f (la reacción) y 4g (Valeria con un audífono afuera).

### Checklist de lecciones (capturas ×2–×5)

| # | ✔/✘ | Dónde se miró |
| --- | --- | --- |
| 1 | ✔ | Sin puertas nuevas |
| 2 | ✔ | La isla no tapa la puerta ni el tazón; la ropa no cae delante de la puerta (primera prueba la dejaba en 2134, dentro del rectángulo de la puerta: se corrió) |
| 3 | ✔ | Repisa, maceta y bolsa, cada una en su pieza |
| 4 | ✔ | Cajas: colisión a ±2 px del arte nuevo; piezas recortadas al borde opaco |
| 5 | ✔ | Bolsa de croquetas 38 × 44 (al doble) |
| 6 | ✔ | La pila sigue explicándose sola |
| 7 | ✔ | Sin desplazamientos nuevos |
| 8 | ✔ | Polvo en la capa JUEGO (con EFECTOS quedaba encima de la imaginación de A.S.P.I.: `prueba_jefe` lo pilló) |
| 9 | ✔ | Sin ciclos nuevos |
| 10 | ✔ | Valeria no cambia de pose: solo el audífono |
| 11 | ✔ | Diálogo arriba, logro al costado y «¡PUM!» en el mundo: no se montan; Valeria y Felipe hablan uno después del otro |
| 12 | ✔ | Sin ventanas nuevas |
| 13 | ✔ | Plantas y croquetas en la cocina; ropa en la caja de la mudanza |
| 14 | ✔ | Maceta y bolsa en el medio de la tabla |
| 15 | ✔ | La repisa se sostiene con sus ménsulas |
| 16 | ✔ | Calcetines con su sombra en el piso y sobre las cajas |
| 17 | ✔ | Sin superficies de código |
| 18 | ✔ | Repisa a escala de la pared y del tazón |
| 19 | ✔ | Sin rectángulos de depuración |
| 20 | ✔ | Isla asimétrica (maceta, bolsa, reloj más alto); los dos calcetines son distintos |
| 21 | ✔ | La cocina cuenta algo: la reserva escondida de Felipe |
| 22 | ✔ | Sombra de contacto en los objetos de la repisa y en la ropa |
| 23 | ✔ | La isla entra entera en pantalla |
| 24 | ✔ | Piezas de Gemini con la luz por la izquierda |
| 25 | ✔ | Sin aberturas nuevas |
| 26 | ✔ | Sin halos |
| 27 | ✔ | Resalte de la pila sigue su silueta |
| 28 | ✔ | Nada patrulla delante de la isla (el ratón va por el piso, 75 px más abajo) |
| 29 | ✔ | Objetos de la repisa apoyados, con sombra, al doble |
| 30 | ✔ | Pocos objetos: dos en la repisa |
| 31 | ✔ | Sin cambios de ancho |
| 32 | ✔ | Nada dibujado por código junto al arte (el audífono ya era de código; solo se corre) |
| 33 | ✔ | Prueba de barreras y empujes contra la pila en 0 fallos |
| 34 | ✔ | La tabla de la repisa de pared casi no muestra cara de arriba: objetos hundidos 2 px |
| 35 | ✔ | Puntos de captura en lugares libres |
| 36 (nueva) | ✔ | El poste de primer plano tapaba la pila: el hueco se midió con máscaras antes de mover nada |

**36 de 36 ✔.** Lo que se aceptó: la pila es un 8 % más chica que antes (cajas de ~27 cm en vez de 30); el audífono afuera se ve chico (lo cuenta el retrato y la frase).

### Encargo opcional a Gemini (si el creador quiere más historia en la entrada)

No hace falta para cerrar este punto, pero no hay en el repo una pizarrita ni un calendario. Texto sugerido: «Pixel art, misma paleta y contorno que `cocina-v2.png`, fondo blanco, piezas separadas y numeradas, vista frontal, luz desde la izquierda: 1) pizarrita de cocina con marco de madera y la nota a tiza "comprar croquetas!!" y un dibujo de un gato, 2) calendario de pared con un día marcado "VET Felipe" en rojo, 3) ganchos de pared con un delantal y una bolsa de tela». Tamaños en el juego: pizarrita ~50 × 40, calendario ~36 × 48, ganchos ~70 × 60.

### Resultados

- Pruebas: movimiento, escenario, mecánicas, nivel, reglas_nivel, jefe y acciones en **0 fallos**. Una corrida de `prueba_nivel` (de cuatro) falló en la pelea de A.S.P.I. (apagarla tres veces); las otras tres pasaron: es la inestabilidad conocida de esa parte, no de las cajas.
- Bot `partida.gd`: **3 de 3** (agenda 8 de 8, ~263 s).
- **Felipe no cambió:** no aplica la regla de los tres lugares (ni ficha ni tabla de acciones).

