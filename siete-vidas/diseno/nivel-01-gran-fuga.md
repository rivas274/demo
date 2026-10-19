# Nivel 1, "La Gran Fuga" (v4, construido)

Documento vigente del nivel. Fecha: 2026-10-19 · Fase 3 (vertical slice). Sale de la propuesta v4 aprobada por el creador (habilidades apagadas, bolsillo de 5 y nido de calcetines, arañar y maullar, Valeria con 4 poses y caminar, escalera de fondo con reja) y cuenta lo que quedó **construido** en `siete-vidas/juego/` (datos en `scripts/sala.gd`). Plan de arte: `nivel-01-plan-arte.md`. Revisiones que se corrigieron: `revisiones/2026-10-18-nivel1-gran-fuga.md` (sección 9) y `revisiones/2026-10-19-nivel1-v4.md` (sección 11).

## 1. Propósito

- **Qué aprende:** a moverse como un gato pesado que usa los muebles de escalera, y el ciclo del juego: **hacer la travesura → que te pillen → salirte con la tuya** (pilar 3), con la Agenda de Su Majestad como motivo (pilar 2).
- **Qué siente:** arrogancia y travesura, con un mundo que le contesta (pilar 5); al final, el alivio de escapar por el balcón.
- **Fantasía:** la casa es su reino y Valeria su servidumbre; abajo manda Valeria, arriba manda A.S.P.I.
- **Estructura:** la sala presenta el ciclo con Valeria; recibidor y cocina lo desarrollan (maullar, comer, zarpazo, muebles como escalera); arriba gira (lo que Felipe ensucia lo limpia A.S.P.I.); el estudio lo examina; el balcón es el alivio.
- **Habilidades:** se juega **sin doble salto, Zoomies ni trepar** (se ganan después). Todo escalón del camino obligatorio mide 60 px o menos (Felipe salta ~79).
- **Duración:** el bot lo termina en unos 4 min con la agenda completa; una persona, la primera vez, 12 a 18 min.

## 2. Recorrido por habitación (lo construido)

Valeria vive en la planta baja y va donde hay ruido. Empieza sentada en el sofá viendo su serie; cuando Felipe sale al recibidor pasa detrás de él a la cocina ("Voy por un café. Y tú no entras: dieta.") y se encierra. Cuando Felipe sube, se pone audífonos para una reunión: arriba no oye nada.

### 2.1 Sala (inicio, 1280 px)
- **Enseña, de a una:** saltar (los muebles son la escalera) → arañar (sofá y rascador) → tirar (vaso de la mesa) → frotarse con Valeria.
- **Sofá con plástico (arañable, 3 pasadas):** si Valeria mira, a las dos pasadas lo deja frente al rascador ("¡Ahí no, bebito, AQUÍ!") y el plástico aguanta.
- **Rascador (teatro):** con Valeria mirando da perdón y un snack (una vez por visita) y ella saca el celular y graba 8 s **de espaldas al sofá** ("¡Miren! ¡Usa su rascador!"). Usarlo afila las garras 6 s: el siguiente arañazo al sofá es CRÍTICO y rompe el plástico ("¡PLÁSTICO: 0!", "¡El sofá! ¡Lo estoy pagando en 12 cuotas!"): **travesura "sofa"**, sale el calcetín 1 de entre los cojines. Sin público: "¿Para quién actúo?".
- **Vaso:** desde la mesa (silla → mesa), congelado de 0,08 s y "¡GRAVEDAD: 1 · VASO: 0!"; Valeria se para ("¡PIPE!") y regaña 5 s con un corazón roto encima. Junto a ella, el botón de acción es **"Encantar"**: Felipe se frota ronroneando y ella lo perdona ("¿Quién es el bebito más gordito? ¡TÚ!"): **travesura "perdon"**, snack a sus pies.
- **Hitos:** retrato oficial de Su Majestad, ventana al patio de luz con persiana (por el vidrio se ve el balcón de arriba con la luz roja de A.S.P.I.) y el nido de Su Majestad (la cesta se llena a la vista con los calcetines).

### 2.2 Recibidor (1200 px)
- **Enseña, de a una:** agacharse (bajo el zapatero, 40 px libres) → descanso (caja de arena, con lámpara al lado) → maullar (puerta cerrada de la cocina; abajo se ve la sombra de Valeria) → el librero como escalera.
- **Maullar es llave:** junto a la puerta de la cocina, Valeria la abre ("Ya, entra, pero no hay nada para ti.").
- **Popo táctico (secreta):** agachado 1,2 s sobre la arena: censura irónica (pegatina de pescadito y "CONTENIDO SENSIBLE" sobre una papa). Valeria sale con mascarilla ("¡ACABO DE LIMPIARLA! Voy por bolsas...") y del susto se le cae la **foto vergonzosa** que tenía lista para subir (cae flotando junto a la lámpara). Al volver por bolsas deja abierta la puerta de la cocina (efecto, no recompensa: si Felipe ya maulló, la puerta ya estaba abierta y el cartel no promete nada que ya pasó).
- **Travesura suelta:** las llaves del zapatero (se sube desde el borde de la caja de arena): "¡CLINK CRÍTICO!" y Valeria desde la cocina: "¿Mis llaves? ¿OTRA VEZ?".
- **Escalera:** sección 4. **Hito:** la reja con el cartel "PIPE: NO".

### 2.3 Cocina (opcional, 960 px)
- **Enseña, de a una:** comer (tazón hondo: "Tres croquetas. Esto es un crimen.") → zarpazo (ratón de cuerda en el piso, 90 px después de su frase; queda patas arriba con la llave girando) → la caja de cartón se rompe de un zarpazo y suelta un snack → silla → mesón: un ratón patrulla entre el borde y el microondas (cuida la subida) → microondas: el pollo.
- **Robar el almuerzo de Valeria:** el pollo asado, que espera sobre el microondas (fuera de la patrulla del ratón: nunca lo tapa). Valeria, junto a la puerta, mira hacia el mesón: "¡EN SU CARA!" y "¡ESE ERA MI ALMUERZO! Esto va a mis historias.", y regaña. **Travesura "almuerzo"**, 2 snacks.
- **Calcetín 2 (exploración):** mesón → microondas → refrigerador (escalones de 54 px).
- **Hito:** el refrigerador con imanes y el pollo grande a escala de gato.

### 2.4 Pasillo de arriba (1040 px)
- **Giro:** baúl → consola: Felipe tira el vaso; sale A.S.P.I. del estudio, va a la mancha y la aspira. La succión arrastra a Felipe de pie: "Mantén {agacharse}. Uñas: modo ancla." (agachado se aferra). Aquí no hace daño. Vuelve a su cuarto: "Suciedad eliminada. Gato… registrado." Felipe: "Ese robot cree que me registra. Yo lo registro a él."
- **Ignorar el láser (secreta):** el punto mide 8 px, con halo que late; la primera vez Felipe dice "No. No voy a caer.". 5 s quieto con el punto rojo cerca: se apaga "de vergüenza" y cae una **foto vergonzosa** del cajón de la consola.
- **Arañar es llave:** la puerta del dormitorio está entornada; se abre arañándola ("Puerta entornada. Invitación aceptada.").
- **Descanso:** cojín, a 2 px del rectángulo sagrado de la puerta del estudio.
- **Lugar visto (R17):** por la ventana se ve el toldo del vecino con una caja de pizza **afuera, detrás del vidrio** (con reflejos encima); el alféizar (90 cm, sobre la consola) se pisa pero está vacío y Felipe dice "Esa pizza es mía. Algún día." (se vuelve con Caer de Pie).
- **Hito:** el retrato familiar donde Felipe tapa a todos. Bajo la consola se pasa agachado (47 px libres); el baúl se pasa por delante.

### 2.5 Dormitorio (opcional, 720 px)
- **Repasa** subir muebles: banquito → cama → cómoda → repisa → ropero. La repisa es una repisa de pared entre la cómoda y el ropero (con el paisaje encima); la ventana va sobre la cama, del mismo tamaño que las demás, con la cortina a los lados colgada de una barra y hasta el piso. Una cesta de ropa al pie de la repisa sirve para salir del hueco entre la cómoda y el ropero.
- **Saquear el cajón de calcetines:** manotazo al cajón (desde la cama): calcetines volando y el **calcetín 3** sobre la cómoda ("Inventario.").
- **Travesura suelta:** desordenar la ropa doblada de la cama (la pila de `arriba-extra`, 52 × 48, en el medio del colchón y hundida 9 px en el edredón para que se apoye y no flote; se acicala encima y queda revuelta y con pelos: "Doblada era aburrida. Ahora tiene pelo de rey."). `prueba_nivel` comprueba que se apoya en el colchón, que el contorno del Indicador calza con la pila y que «Desordenar» funciona.
- **Lugar visto (R17):** la repisa alta con la caja de recuerdos de Valeria, sobre el hueco entre la cómoda y el ropero; no se alcanza todavía (Afilar Garras: se trepará la cortina hasta la barra y de ahí se salta a la repisa alta). La cortina es **arte de Gemini** (`dormitorio-cortina-alta.png`, procesada por `preparar_arte_nivel.py` a 45 × 277): dos paños (el derecho en espejo) de una sola barra con un remate en cada punta, 18 px sobre el marco de la ventana; cada paño tapa 9 px de la ventana y la tela baja hasta el piso (lo que sobra del arte no se dibuja). Sin colisión: si se vuelve trepable con Afilar Garras, el rectángulo trepable es la tela de cada paño.

### 2.6 Estudio de Valeria (jefe, 640 px, una pantalla)
- **Examen** (sección 5). **Pisar el teclado (secreta;** teclado dibujado de 52 × 24, con cuatro filas de teclas, delante de la pantalla**):** la pantalla dice "jjjjjjjjjj", **foto vergonzosa 3**, y durante la pelea la impresora (en el piso, bajo el escritorio) escupe un papel cada 4 s que cuenta como mancha.
- **Desenchufar a A.S.P.I.:** recompensa camino (la puerta del balcón) y logro "Desenchufada".

### 2.7 Balcón (alivio, 640 px)
- Sin enemigos ni agenda. Maceta grande → baranda (la maceta del medio de la baranda se quitó: Felipe se queda en un tramo libre, sin meterse en una maceta). Felipe se queda quieto y se acicala (no hay animación de sentarse todavía), la cámara se abre hacia la ciudad (1,5 s) y suspira: "Soy un gato de interior. Mi cardio es mirar por la ventana." El jugador salta (salto real): cámara lenta y la cámara **lo sigue hacia abajo** (se abre 230 px bajo el balcón: fachada, ventanas del piso de abajo y el letrero de la panadería); aterriza **a la vista** sobre el toldo verde de la panadería con el polvo grande del aterrizaje, y recién entonces sale el cartel **"PODER NUEVO · CAER DE PIE"** a una altura que no lo tapa, "No me caí. Aterricé con estilo." y el **resumen del día** tipo Balatro (travesuras, secretas, calcetines, fotos, snacks y perdones).

## 3. Agenda de Su Majestad del nivel

`Agenda.NIVEL_1`, 8 líneas, 3 secretas ("???" hasta cumplirlas). Cada recompensa aparece sobre algo pisable y se recoge al pasar. Sitio y reacción de cada una en `Sala.AGENDA_SITIOS` (R18).

| # | Travesura | Cuarto | | Cómo se cumple | Recompensa |
| --- | --- | --- | --- | --- | --- |
| 1 | Romper algo y que me perdone igual | Sala | visible | Tirar el vaso y frotarse contra Valeria enojada | Snack |
| 2 | Arañar el sofá nuevo (con plástico) | Sala | visible | Garras afiladas en el rascador (con Valeria grabando) y arañar el sofá | Calcetín 1 |
| 3 | Popo táctico en la arena recién limpiada | Recibidor | **secreta** | Agachado 1,2 s sobre la caja de arena | Foto vergonzosa 1 (se le cae a Valeria) |
| 4 | Robar el almuerzo de Valeria | Cocina | visible | Comer el pollo del mesón | 2 snacks |
| 5 | Ignorar el láser | Pasillo | **secreta** | 5 s quieto con el láser cerca | Foto vergonzosa 2 |
| 6 | Saquear el cajón de calcetines | Dormitorio | visible | Manotazo al cajón de la cómoda | Calcetín 3 |
| 7 | Pisar el teclado de Valeria | Estudio | **secreta** | Pararse en el teclado del escritorio | Foto 3 y papeles (manchas) en la pelea |
| 8 | Desenchufar a A.S.P.I. | Estudio | visible | Apagarla tres veces | Camino: balcón |

El calcetín 2 (refrigerador) es de exploración. Calcetines al nido (cada 10, una ranura de maña: "3/10 para tu próxima ranura"); fotos a la galería: **las tres secretas dan una foto cada una** y la galería completa (3) da "Galería Viral"; snacks al bolsillo de 5 (mantener la acción 0,6 s sin nada cerca come uno).

## 4. La escalera

- **Reja anti-fuga** (decisión del creador): Valeria la atornilló después del video viral. Mide 1,5 m (182 px), se dibuja de 48 px (la cara de frente del arte de Gemini) con colisión fina de 12 px, cartel "PIPE: NO" escrito por código en dos líneas sobre el cartel de cartón del arte (34 px, centrado en la reja, sin pisar el librero; la firma "Con amor, mamá" se quitó porque a 6 px no se leía). Desde afuera Felipe la **empuja** ("¿Una reja? ¿En MI escalera? Qué tierno.").
- **El librero es la escalera del gato:** repisas a 48, 103 y 155 px (escalones de 48 a 55). Desde la de arriba se salta la reja y se cae adentro, al pie de la escalera.
- **Subir:** al pie, "Ascender" (acción o arriba): Felipe sube los **7 escalones** con la animación `subir_escalera`, un saltito por escalón por la línea de los peldaños (`Sala.PELDANOS`), camina por el descanso hasta el vano y hay un fundido al pasillo. La escalera va en **dos capas**: peldaños detrás de Felipe y pasamanos con barrotes delante, que baja a **70 %** de opacidad mientras sube.
- **Descanso:** un rellano grueso (como un escalón ancho) con el faldón cerrado hasta el piso: tablas y la puertita de un armario bajo la escalera (sin poste suelto).
- **Bajar:** por el vano del pasillo aparece en el descanso y baja escalón por escalón (cuadros de saltar y caer); `prueba_nivel` comprueba que pisa los 7 peldaños sin volver a subir, que termina adentro de la reja, en el piso y con el control de vuelta.
- **Atajo (R6):** desde adentro, "Abrir": un manotazo al pestillo la abre para siempre ("El pestillo, por dentro. Aficionada.", logro "Atajo de Gato"), a 348 px de la caja de arena.

## 5. Cómo se anuncia cada interacción (sin carteles)

- Se quitaron los avisos de texto y la fila de controles de abajo (M2).
- **Indicador:** contorno claro de 1 px en el objeto y burbuja sobre Felipe con el ícono del botón en uso (Kenney) y el verbo: Pasar, Probar (puerta cerrada), Ascender, Degustar, Liberar, Firmar (sofá), Desordenar (ropa), Actuar, Encantar, Abrir, Empujar, Arañar (puerta entornada), Saquear. Un verbo por acción.
- **Primeras frases de Felipe** (`Sala.LECCIONES`, una sola vez por zona, 48 caracteres o menos sin el botón): "{saltar} Los muebles son mi escalera." · "{interactuar} Ese sofá tiene plástico. Por ahora." · "{interactuar} Un rascador. Necesito público." · "{interactuar} Ese vaso está muy cerca del borde. Aún." · "Mantén {agacharse}. Es estrategia, no humildad." · "Mi trono. Aquí vuelvo si algo sale mal." · "{maullar} Servidumbre: abran." · "{saltar} El librero es mi escalera." · "{interactuar} Escalones. Mi única pasión." · "{interactuar} Comida a la vista. Me sacrifico." · "{zarpazo} Un ratón de cuerda. Qué insolencia." · "{interactuar} Puerta entornada. Qué invitación." · "{saltar} Banquito, cama, cómoda. Escalera real." · "{interactuar} El cajón de los calcetines. Botín." · "{saltar} La maceta, la baranda… y la libertad."
- **Señales del escenario:** luz cálida que sale de las puertas abiertas y tapete; rendija de luz y sombra que se mueve bajo la puerta cerrada de la cocina; etiqueta "NUEVO" en sofá y rascador; corazón roto sobre Valeria enojada.

## 6. La pelea con A.S.P.I. ("La Bestia del Estudio")

### Entrada en 8 pasos (4,8 s, `PresentacionJefe`)
La presentación **empieza cuando terminó el fundido de la puerta** (B1); el fundido y su tween siguen en pausa. Los pasos son datos de `PresentacionJefe.PASOS`; A.S.P.I. solo da su nombre, título, rugido y efectos.

| s | Paso | Qué pasa |
| --- | --- | --- |
| 0,0–0,4 | 1. Sin vuelta atrás | La puerta se cierra sola con un portazo y polvo. Subtítulo de la presentación: "FELIPE: …¿Quién cerró?" (el cuadro de diálogo y el Indicador se esconden durante toda la entrada) |
| 0,4–1,2 | 2. La espera | Penumbra; la luz de A.S.P.I. pasa a roja; retumbo que crece; las pelusas del piso tiemblan |
| 1,2–2,2 | 3. Revelar despacio | Golpe de cámara a Felipe con «¡BATALLA INICIADA!»; la cámara sube de las ruedas al sensor mientras crece la imaginación (estudio en llamas y la bestia gigante al fondo, sin colisión), enmarcada con una viñeta oscura con motas de polvo |
| 2,2–2,8 | 4. Nombre y título | Franja: **A.S.P.I.**, "Devoradora de Pelos · Nivel 99" |
| 2,8–3,4 | 5. La barra se llena | Barra de vida que se llena |
| 3,0 | 6. Música | Entra el tema de la pelea (provisional) |
| 3,4–4,0 | 7. Vender el tamaño | Cámara baja; dos empujones que sacuden la pantalla |
| 4,0–4,8 | 8. El rugido | "DETECTANDO SUCIEDAD. DETECTANDO… GATO.", ola de polvo y papeles que vuelan; la imaginación se desvanece y vuelve el control |

Al volver después de perder una vida (reaparece en el cojín), la entrada corta dura 1 s (portazo y nombre) y la pelea **conserva la fase**.

### Reglas, fases y ataques (no se gana sentado, G12)
- **Ensuciar:** lo que se rompe en el piso deja una mancha (vaso y taza de café del escritorio, 2 macetas de la repisa, papeles del teclado). A.S.P.I. va a limpiarla: **anticipación** (el cepillo gira 0,6 s), aspira (de pie arrastra; agachado se aferra; en la fase 3 alcanza 260 px) y suma "+1" y "Glup.". Lo roto vuelve **de a uno cada 6 s**.
- **Depósito lleno:** 2/3/3 manchas por fase; se detiene inofensiva 4/3,5/3 s pitando «¡DEPÓSITO LLENO!» con la pista "Sáltale encima y aprieta el botón". Si estaba bajo la repisa, sale disparada 80 px. Felipe le cae encima: **congelado de 0,1 s, destello, sacudida, «¡CLIC!», polvo y sonido en capas**.
- **Embestida (todas las fases):** se echa atrás 10 px y su luz roja parpadea 0,5 s; recién entonces carga, y solo cargando hace daño.
- **Soplido contra el que acampa (desde la fase 2):** más de 3 s (2 s en la fase 3) arriba de algo de más de 90 px: va debajo, vibra con luz amarilla 0,6 s y sopla: Felipe sale al piso sin daño y las macetas caen sin romperse.
- **Bolas de pelo en arco (fase 3):** tos mecánica de 0,5 s ("¡COF!") y la bola va hacia donde está Felipe (llega al escritorio y a la repisa).
- **Maullar:** gira hacia Felipe ("¿Gato detectado?").
- **Final:** cámara lenta 0,5 s, «¡APAGADA!», todo vuelve de golpe a la normalidad, se abre la puerta y Felipe se lame la pata ("Limpieza cancelada.").

### Es un examen (R12)
| Mecánica | Se enseña en | En la pelea |
| --- | --- | --- |
| Tirar | Sala (vaso) | Hacer manchas |
| Agacharse | Recibidor (zapatero); aferrarse en el pasillo | Aguantar la succión |
| Muebles como escalera | Recibidor, cocina, dormitorio | Silla → escritorio → repisa |
| Saltar | Sala | Caerle encima; esquivar embestidas y bolas |
| Zarpazo | Cocina | Rebota en la carcasa |
| Maullar | Recibidor | Atraerla (opcional) |

## 7. Mapa del nivel (construido)

Alto de todos los cuartos: 424 px (3,5 m). Piso en y = 448. Muros entre cuartos. Alturas desde el piso. Cada colisión sale de medir la fila opaca de su arte (`prueba_reglas_nivel.gd` la compara a ±2 px).

| Cuarto | x en el mundo | Ancho | Qué hay (x en el mundo · altura) |
| --- | --- | --- | --- |
| Sala | 0–1280 | 1280 | nido 40 · ventana 170–350 (alféizar 109) · sofá 240–480 (asiento 49, respaldo 102) · rascador 520–620 (69/114/165) · silla 680 (55) · mesa 745–923 (91, vaso en 905) · silla 929 (55) · retrato · puerta 1188 |
| Recibidor | 1440–2640 | 1200 | puerta 1532 · zapatero 1626–1786 (97; 40 libres debajo; llaves) · caja de arena 1832–1936 (45) · lámpara 1942 · puerta de la cocina 2070 · librero 2162–2266 (48/103/155/218) · reja 2284–2296 (182) · escalera 2322–2548 y vano cuadrado en el descanso 2497–2637 (150) |
| Cocina | 2800–3760 | 960 | puerta 2892 · ventana 3150–3300 (alféizar 109, cenefa) · tazón 3010 · Valeria 3080 · ratón 3200–3290 · caja de cartón 3360 · silla 3400 (55) · mesón 3464–3668 (108, ratón 3500–3536) · microondas 3570 (162, pollo 3612) · refrigerador 3674–3758 (216, calcetín 2) |
| Pasillo | 4000–5040 | 1040 | vano cuadrado de la escalera 4092 · baúl 4190 (54) · consola 4256–4412 (97, vaso; 47 libres) · ventana 4260–4440 apoyada en la consola, alféizar 4264–4436 (109; la pizza, afuera tras el vidrio, en 4389) · puerta del dormitorio 4536 · láser 4640–4780 · cojín 4784–4854 · puerta del estudio 4948 |
| Dormitorio | 5200–5920 | 720 | puerta 5292 · banquito 5386 (53) · cama 5444–5644 (65) · ventana 5469–5619 sobre la cama (alféizar 109) · cortina 5436–5652 (telas a los lados, barra a 230, hasta el piso) · ropa doblada 5572 (sobre el colchón) · cómoda 5650–5734 (96, cajón) · repisa 5740–5810 (145) con el paisaje encima · cesta 5747–5807 (35) · repisa alta 5735–5815 (290, lugar visto) · ropero 5816–5920 (185) |
| Estudio | 6240–6880 | 640 | puerta 6332 · silla 6424 (55) · ventana 6455–6605 sobre el escritorio (alféizar 109, paños cortos) · escritorio 6488–6648 (98; vaso, teclado, pantalla, taza de café) · impresora bajo el escritorio · repisa 6636–6696 (151, 2 macetas) · base de carga 6600–6674 · puerta del balcón 6788 |
| Balcón | 7040–7680 | 640 | puerta 7132 · maceta grande 7330 (32) · baranda 7400–7584 (89; tramo sin maceta 7470–7520) · ciudad · toldo de la panadería 7380–7680, 196 px bajo el piso (solo existe en el salto final) |

Árbol: sala → recibidor → (cocina) y escalera → pasillo → (dormitorio) y estudio → balcón.

## 8. Cumplimiento R1–R19 (real)

✔ = lo valida `prueba_reglas_nivel.gd` (o la prueba que se nombra); 👁 = revisado con capturas (`pruebas/capturas_nivel.gd`, con y sin `--debug-collisions`).

| Regla | Cómo la cumple |
| --- | --- |
| R1 | ✔ Cada mecánica exigida (tirar, agacharse, zarpazo, subir muebles, maullar) tiene su frase antes en la ruta; frases del mismo cuarto a 150 px o más. 👁 El giro es arriba: lo que se ensucia lo limpia A.S.P.I. (ensayo del pasillo) |
| R2 | ✔ Los primeros 80 px de cada lección no tienen daño (la sala no tiene nada que haga daño; el ratón de la cocina patrulla después de su frase) |
| R3 | ✔ Frases de 48 caracteres o menos sin contar el botón; `prueba_nivel` comprueba que salen una sola vez |
| R4 | ✔ La meta es el balcón, último cuarto; `prueba_nivel`: la cámara lo muestra al empezar. 👁 Por la ventana de la sala se ve el balcón con la luz roja |
| R5 | ✔ Caja de arena (recibidor, a una puerta de la cocina) y cojín (pasillo, junto a la puerta del jefe); reaparecer es inmediato |
| R6 | ✔ El pestillo de la reja se abre solo desde adentro y queda a 348 px de la caja de arena; se va por el librero y se vuelve por la reja |
| R7 | ✔ Dos pisos unidos por la escalera (7 escalones); librero, mesón, microondas, refrigerador, ropero; puertas que van y vuelven; ningún cuarto de menos de 640 px. ✔ `prueba_escenario`: todo se alcanza sin doble salto ni trepar y **ningún hueco atrapa a Felipe** |
| R8 | ✔ Huecos bajo muebles sólidos de 0 o de 36 px o más (zapatero 40, consola 47); lado **menor** ≥ 24 px de todo lo interactuable (comida y recompensas incluidas), **también lo dibujado por código** (teclado, ropa y cajón: `Sala.DIBUJADOS_INTERACTUABLES`) y el tamaño que declara cada interactuable del nivel armado (G7); puertas medidas en la imagen (vano de 112 y 120 px); ratón a la mitad de Felipe |
| R9 | ✔ Pared distinta por cuarto. 👁 Hito por cuarto: retrato oficial, reja "PIPE: NO", refrigerador con imanes, retrato familiar, cama y cortina, base de carga roja, la ciudad |
| R10 | ✔ 3 calcetines sobre algo pisable; el del refrigerador pide subir |
| R11 | ✔ La única zona fuerte es el estudio; cierra con el balcón |
| R12 | ✔ 5 cosas para tirar en el estudio y una en alto (repisa). Ver sección 6 |
| R13 | ✔ Todos los cuartos menos el balcón tienen con qué jugar. 👁 Su chiste (sección 2) |
| R14 | 👁 El primer plano quedó solo en el balcón; el pasamanos baja a 70 % mientras Felipe sube; diálogo y carteles no tapan a Felipe (tampoco al aterrizar en el balcón: G1); el aviso de logro va por encima del diálogo y fuera de su cuadro (M3); ningún ratón patrulla sobre la comida o lo que se tira (G5). ✔ Rectángulo sagrado: ningún mueble, decorado, ratón, descanso ni lugar de Valeria se cruza con una puerta o la escalera (B3, G10) |
| R15 | ✔ `prueba_movimiento` (altura de Felipe); la animación nueva de esta parte (ninguna) no aplica |
| R16 | ✔ `prueba_jefe`: entrada de 8 pasos en menos de 5 s, sin negro al entrar por la puerta, imaginación solo en la entrada, cartel y pista por fase, todo vuelve de golpe al ganar, y la misma presentación sirve para otro jefe |
| R17 | ✔ Dos lugares vistos que no se alcanzan todavía (toldo del vecino: Caer de Pie, con la caja tras el vidrio y el alféizar vacío, G3; caja de recuerdos: Afilar Garras); atajo de la reja. 👁 La historia la cuenta el escenario: reja anti-fuga con cartel, retratos, carpeta de fotos |
| R18 | ✔ Las 8 travesuras pasan en su cuarto con su reacción, y cada cuarto menos el balcón tiene al menos una |
| R19 | ✔ `Sala.MANAS`: maullar abre la cocina y molesta a Valeria y A.S.P.I.; arañar abre la puerta del dormitorio y destroza el sofá; frotarse saca a Valeria del regaño; el zarpazo voltea al ratón que cuida el camino al refrigerador y rompe la caja |

## 9. Hallazgos de la revisión del 2026-10-18

| # | Estado |
| --- | --- |
| B1 | **Arreglado.** La pelea espera a que termine el fundido; el fundido y su tween corren en pausa. `prueba_jefe` y `prueba_nivel` entran por la puerta y comprueban que nada está en negro |
| B2 | **Arreglado.** Puertas de una sola hoja (tanda 3A); la prueba mide el vano en la imagen |
| B3 | **Arreglado.** Recibidor de 1200 px con 40 px libres a cada lado de cada puerta; prueba de rectángulo sagrado |
| B4 | **Arreglado.** Toda colisión pisable sale de la fila opaca de su arte y se compara a ±2 px (una prueba de sensibilidad corriéndolas 6 px hace fallar 23 de 28) |
| B5 | Arreglado en la PARTE A (efecto en el cuadro de impacto) |
| G1 | **Arreglado.** El ratón se apoya por el cuerpo (la cola cuelga 7 px); al caer queda patas arriba con la llave girando |
| G2, G5 | **Arreglados** (mesón medido; ya no hay cabecera invisible) |
| G3 | **Arreglado.** Mesa y dos sillas separadas y derechas |
| G4 | **Arreglado.** Librero de 3 repisas que coinciden con su colisión |
| G6, G7 | **Arreglados.** Escalera en dos capas con `subir_escalera` y reja anti-fuga de una pieza |
| G8 | **Arreglado.** Tazón, pollo, bolsita; lado menor ≥ 24 medido |
| G9 | **Arreglado.** Indicador con ícono y verbo, y señales del escenario |
| G10 | **Arreglado.** Nada en los rectángulos sagrados (A.S.P.I. pelea con las dos puertas del estudio cerradas) |
| G11 | Arañar y maullar entraron en la PARTE A; aquí, con su uso en el nivel |
| G12 | **Arreglado.** Soplido contra el que acampa, lo roto vuelve de a uno, bolas en arco, succión de 260 px en la fase 3 |
| G13 | **Mejorado:** agenda, Valeria que reacciona, ensayo de A.S.P.I., travesuras sueltas (llaves, ropa) y voz de Felipe en cada cuarto. Falta sonido de casa |
| M1 | **Arreglado.** La herramienta recorta al borde opaco antes y después de escalar |
| M2 | **Arreglado.** Sin fila de controles ni avisos |
| M3 | **Arreglado.** El primer plano salió de las zonas de juego |
| M4 | Ya no aplica (no hay báscula); el reloj de la cocina no choca con el HUD |
| M5 | **Arreglado.** Balcón con baranda, sentarse, cámara que se abre, salto real y resumen |

## 10. Diferencias con la propuesta v4 (y por qué)

- **Un solo ratón cuida el pollo** (no dos): con el microondas sobre el mesón no caben dos patrullas sin tapar la comida; el segundo ratón enseña el zarpazo en el piso.
- **La cama no se pasa agachado:** su arte deja 11 px bajo el marco (no 36); es sólida hasta el piso (R8 permite hueco 0). Agacharse se practica en el zapatero y la consola.
- **El librero tiene sus repisas a 48, 103 y 155 px** (el arte de Gemini), no a 54, 109 y 163. La reja se salta desde la de 155.
- **Microondas de 98 × 54** (escala de gato) para que el escalón al refrigerador sea de 54 px.
- **Dormitorio y cocina más angostos** (720 y 960 px) para no dejar huecos sin salida detrás del ropero y del refrigerador.
- **`arriba-extra.png` llegó en la revisión 3:** baúl (40 cm, 70 × 48), cojín redondo, retrato familiar, ropa doblada limpia y con pelos, caja de recuerdos, monitor e impresora (recortados del escritorio con monitor) y papeles son arte; el teclado y los calcetines que vuelan siguen por código; consola = aparador y cómoda = la de siempre.
- **Cortina de Gemini** (`dormitorio-cortina-alta.png`, 2026-10-19): reemplazó a la de código. La herramienta le corta el remate derecho para usarla como paño izquierdo y, en espejo, como el derecho; el tramo de barra del medio se estira desde una columna de la misma barra. Desde el 2026-10-19 la ventana del dormitorio va sobre la cama (sección 14) y la cortina cuelga a sus lados. `dormitorio-cortina.png` (la ancha) no se usa.
- **Retoques de arte en la herramienta** (`preparar_arte_nivel.py`, sin pedir arte nuevo): a la ventana del pasillo se le tapó la caja de pizza que traía sobre el alféizar (PARCHES) y a la baranda se le quitó la maceta del medio (BORRAR + RELLENOS).
- **El caminar de Valeria es de SpriteCook** (revisión 3): el de Gemini no alternaba las piernas y se borró. Camina a 110 px/s (9,2 px de pie apoyado por cuadro × 12 cuadros/s, medido en la hoja).
- **Valeria cruza las puertas a la vista** (revisión 3): cuando Felipe sale al recibidor, ella camina hasta la puerta de la sala y entra al recibidor por la puerta unos 7 s después; maullar a la cocina hace que se asome en el vano. Por eso la cocina se abre ~2 s después del maullido, no al instante.

## 11. Hallazgos de la revisión 2 (2026-10-19, `revisiones/2026-10-19-nivel1-v4.md`)

| # | Estado |
| --- | --- |
| G1 | **Arreglado.** Al saltar, cámara lenta y la cámara baja con Felipe (se abre 230 px bajo el balcón); aterriza a la vista en el toldo de la panadería con el polvo grande y recién ahí sale el cartel, a una altura que no lo tapa. `prueba_nivel` comprueba que se ve en todo el salto, que aterriza en el toldo y que el cartel sale después y sin taparlo |
| G2 | **Arreglado.** De pie (regañando, caminando, grabando), Valeria siempre tiene los pies en el piso; al pararse del sofá baja delante de él. `prueba_nivel` lo vigila en cada cuadro |
| G3 | **Arreglado.** La caja de pizza está afuera, sobre el toldo, detrás del vidrio con reflejos; el alféizar quedó vacío (la herramienta tapa la caja del arte) y Felipe dice "Esa pizza es mía. Algún día.". `prueba_reglas_nivel` comprueba que la caja está dentro del vidrio y por encima del alféizar |
| G4 | **Arreglado.** Cortina a los lados de una ventana nueva entre la cómoda y el ropero (la repisa es su alféizar); desde el 2026-10-19 es el arte de Gemini (`dormitorio-cortina-alta.png`) |
| G5 | **Arreglado.** El pollo pasó al microondas y el ratón patrulla entre el borde del mesón y el microondas (3500–3536). `prueba_reglas_nivel`: ningún ratón tapa la comida ni lo que se tira, con su dibujo completo |
| G6 | **Arreglado.** El popo táctico da una foto vergonzosa (se le cae a Valeria); las tres secretas dan fotos y la galería completa da "Galería Viral". Valeria igual deja la cocina abierta al volver (efecto, no premio) |
| G7 | **Arreglado (código).** Teclado de 52 × 24 con teclas y ropa de 52 × 26 con volumen; la prueba R8 mide lo dibujado por código y el tamaño que declara cada interactuable del nivel armado. El arte de Gemini (tanda `arriba-extra`) sigue pendiente |
| G8 | **Pendiente, no es error:** el creador decidió no pedir todavía la animación `entrar_puerta`; las puertas siguen con fundido |
| G9 | **Pendiente, no es error:** intimidar queda para el Barrio Viejo (decisión del creador) |
| M1 | **Arreglado.** Rellano grueso con faldón cerrado y puertita de armario; sin poste |
| M2 | **Arreglado.** "PIPE: NO" en dos líneas sobre el cartel del arte, centrado en la reja; la firma ilegible se quitó |
| M3 | **Arreglado.** El aviso de logro va en una capa sobre el diálogo y, si el diálogo está arriba, sale justo debajo de él (`prueba_acciones`) |
| M4 | **Arreglado** en `PresentacionJefe` (para todos los jefes): esconde el diálogo y el Indicador mientras presenta, la frase de "sin vuelta atrás" sale como subtítulo y los discos rosados se cambiaron por una viñeta oscura con motas (`prueba_jefe`) |
| M5 | **Arreglado.** Punto de 8 px con halo que late y centro brillante; frase "No. No voy a caer." la primera vez |
| M6 | **Arreglado.** Se quitó la maceta del medio de la baranda (herramienta de arte); Felipe se queda quieto y se acicala mientras no haya animación de sentarse (opcional, SpriteCook) |
| M7 | **Arreglado.** Sofá "Firmar", ropa "Desordenar", puerta entornada "Arañar" (`prueba_acciones`) |
| M8 | **Espera** el retrato familiar nuevo de Gemini |
| Sospecha: bajar la escalera | **Funciona.** `prueba_nivel` baja desde el vano: pisa los 7 peldaños sin volver a subir, termina adentro de la reja, en el piso, y puede caminar |

## 12. Hallazgos de la revisión 3 (2026-10-19, `revisiones/2026-10-19-nivel1-v4-revision3.md`)

Todo por código y con el arte que mandó el creador (`arriba-extra.png`, caminar de Valeria de SpriteCook); 0 créditos en esta tanda. Detalle y autocrítica en la sección "Arreglos" del informe.

| # | Estado |
| --- | --- |
| B1 | **Arreglado.** Tabla única de capas (`Capas`); la imaginación va en la capa 25, por encima de todo el escenario, y Felipe delante (26). La A.S.P.I. real se esconde mientras existe la gigante, que nace y muere en su lugar con un «¡puf!». `prueba_jefe` revisa cada cuadro de la entrada |
| B2 | **Arreglado.** Caminar de SpriteCook; el cuadro sale de la distancia caminada; pie apoyado ≤ 1,2 px de desliz por cuadro (`prueba_nivel` mide la hoja) |
| G1 | **Arreglado.** Fundido cruzado de 0,2 s entre poses, decidido al dibujar (la pose anterior queda donde estaba: nunca se dibuja bajo el piso); antes de echar a andar desde otra pose, cambia en su lugar. `prueba_nivel` vigila cada cuadro |
| G2 | **Arreglado.** Puertas con hoja que gira (0,25 s); Valeria la abre, se desvanece en el vano y la puerta se cierra detrás; la otra cara de la puerta se abre recién cuando ella aparece. Al maullar, se asoma en el vano para decir su frase |
| G3 | **Arreglado.** Camina hasta la puerta de la sala y entra al recibidor por la puerta; nunca cambia de lugar más de lo que camina, salvo al cruzar (`prueba_nivel`) |
| G4 | **Arreglado.** El sofá se redibuja sin plástico ni etiqueta y vuelan jirones (`prueba_nivel`) |
| G5, M3 | **Arreglado.** Una sola cola de anuncios (`Anuncios`): uno a la vez, ubicado al mostrarse sin tapar a Felipe, al diálogo, a Valeria, a A.S.P.I. ni el chiste marcado; espera la reacción de Valeria y, si no hay hueco, sale en chico en una esquina; se corre si alguien entra a cuadro. En la pelea no se ofrece «Probar» en la puerta del balcón y sobre A.S.P.I. hay un rótulo a la vez |
| G6 | **Arreglado.** Mascarilla sobre nariz y boca, con pliegues y elástico, que sigue la cara en cada cuadro y al girar |
| G7 | **Arreglado.** Pantallas en la capa 40 y la interfaz se esconde fuera del juego; el fundido de las puertas (capa 12) tapa diálogo, carteles y logros (`prueba_nivel`) |
| G8 | **Arreglado (código).** A.S.P.I. llena es la misma imagen con la tapa que se levanta en 0,25 s, un saltito y el depósito con pelusas; se borró `aspi_llena.png` |
| G9 | **Arreglado (código).** El ciclo va al ritmo de la velocidad (tope 34 cuadros/s): desliz ≤ 2 px por cuadro (`prueba_movimiento`). Opcional: un `caminar` nuevo desde Felipe A con pasos largos |
| M1 | **Arreglado.** Palabras con contorno grueso y sombra, que suben si caerían sobre Felipe; la del vaso va sobre la mesa; el rugido con caja oscura |
| M2 | **Arreglado.** Las recompensas pegadas a Felipe salen a su lado en arco corto; los snacks del pollo caen en el mesón |
| M4 | **Arreglado.** Introducción → balcón → sala con fundidos; cartel «EL BALCÓN · ARRIBA, AL FONDO»; las lecciones esperan a que termine |
| M5 | **Arreglado (código).** Ladrillo, ventanas con marco, cortina y alféizar; el letrero va en el faldón del toldo (Felipe aterriza arriba y no lo tapa) |
| M6 | **Arreglado.** Respira, mira alrededor cada tanto y gira con transición (no antes de 0,4 s ni con Felipe a menos de 12 px) |
| M7 | **Arreglado (código).** Ventana con 68 px de vidrio; caja de pizza de 34 × 24, abierta, con grasa y vapor |
| M8 | **Arreglado.** Causa raíz: en furia la tos dejaba de contar mientras Felipe acampaba y la prueba dependía de dónde lo dejaba el soplido y de papeles al azar del teclado. Ahora la tos cuenta siempre (la bola es justo lo que llega arriba) y la prueba espera el estado. 5 de 5 seguidas |

## 13. Crítica de arte de Gemini (2026-10-19, `revisiones/2026-10-19-critica-gemini.md`)

Cada punto se comprobó contra capturas reales (`pruebas/capturas_nivel.gd`) antes de aplicarlo; Gemini se equivocó en varios (el sofá no es verde, la "alfombra azul" es la caja de arena, la "ratonera" es el vano de la escalera). 0 créditos: todo por código y en `preparar_arte_nivel.py`. Detalle punto por punto en la sección "Qué se aplicó" de la crítica; hoja antes/después de los 8 cuartos y video `nivel1-v4d.mp4`.

- **Cortina:** arte de Gemini (sección 2.5).
- **Sala:** Valeria sentada 9 px más abajo (`Valeria.FILA_CADERA` 139): los muslos sobre el cojín, que se hunde, y los pies en el piso; sombras de contacto duras bajo cada mueble que pisa el piso (rascador, sofá, sillas, librero, refrigerador, ropero…); el retrato oficial bajó 16 px (lo tapaba la barra del HUD).
- **Recibidor y escalera:** charco de luz cálida bajo la lámpara; reja anti-fuga con tinte crema / gris cálido; el vano tenía un borde interior en sombra (hoy es un hueco cuadrado con marco de puerta, sección 14).
- **Cocina:** reloj 10 % más chico (41 × 43) y más lejos de la ventana; el azulejo de la pared es opaco entero (por las costuras se veía la ciudad: líneas punteadas).
- **Pasillo:** el vaso está 17 px más adentro de la consola (4378); retrato familiar 14 px más abajo.
- **Dormitorio:** la ropa doblada se hunde 3 px en el edredón (se veía flotando); el paisaje bajó 14 px.
- **Estudio:** el monitor muestra la serie de Valeria (noche en franjas, lámpara, dos siluetas y un corazón; brillo que titila y reflejo duro); LED de A.S.P.I. con halo y brillo; macetas de la repisa más oscuras contra la pared mostaza; vaso con agua en dos tonos planos y reflejos de pixel.
- **Balcón:** brillo cálido en el borde de arriba de la baranda.
- **Rótulos de interacción:** placa con marco de madera, contorno, esquinas recortadas, clavitos y sombra dura; la misma letra e interior que el diálogo y la libreta; el ícono de Kenney se mantiene.
- **Jefe:** luz de borde cálida en la A.S.P.I. gigante (`aspi_gigante_luz.png`); el «DETECTANDO… GATO.» va en una cartela semitransparente con marco rojo; el primer plano no la tapa (capa 25, ya comprobado en `prueba_jefe`).

## 14. Ventanas, objetos y puertas (el creador, 2026-10-19)

El creador: "Las ventanas están raras. En el estudio está muy alta. ¿Por qué hay papel higiénico en el estudio? La ventana del cuarto se ve pequeña y rara. La ropa debería estar más abajo." y "¿Por qué hay puertas redondas si todas son cuadradas?". 0 créditos: todo por código y en `preparar_arte_nivel.py`. Hoja antes/después de los cinco cuartos y de las dos caras de cada puerta: `ventanas-antes-despues.png` (fuera del repositorio).

- **Ventanas con una sola medida** (`Sala.ALFEIZAR`, `VENTANA_COCINA`, `VENTANA_DORMITORIO`, `VENTANA_ESTUDIO`): alféizar a 90 cm (109 px del piso), vidrio de unos 150 × 120 px y arriba a 1,90 m; nada bajo la barra del HUD ni pegado al techo. Las recortadas llevan marco, alféizar que sobresale con su sombra y su tela (`FondoApartamento._dibujar_ventana`).

| Ventana | Antes | Ahora |
| --- | --- | --- |
| Sala (arte con persiana) | alféizar a 150 px, arriba bajo el HUD | alféizar a 109 px, justo sobre el respaldo del sofá; mismo arte (180 × 151) |
| Cocina | 140 × 120, alféizar a 198 px, sin alféizar dibujado, barra sin tela | 150 × 120, alféizar a 109 px, cenefa de cocina |
| Pasillo (arte con la pizza) | alféizar a 150 px (1,24 m), 94 px de alto, la parte de arriba se veía como una caja aparte | apoyada en la consola, alféizar a 109 px, 132 px de alto; la parte de arriba sigue las columnas del arte (una sola ventana); vidrio 86 × 106 y la pizza 41 px más abajo, siempre afuera tras el vidrio (G3) |
| Dormitorio | 56 × 108 en el hueco entre la cómoda y el ropero (se veía chica) | 150 × 120 sobre la cama, cortina de Gemini a los lados desde una barra 18 px sobre el marco, hasta el piso; el paisaje pasó sobre la repisa |
| Estudio | 140 × 100 con el alféizar a 258 px (arriba quedaba bajo el HUD) | 150 × 120 sobre el escritorio (el monitor delante del vidrio), alféizar a 109 px, dos paños cortos verde oliva |

- **Taza de café en vez del rollo de papel higiénico** (estudio): un rollo heredado del prototipo no tenía sentido en un estudio. La taza de Valeria (`taza.png`, 30 × 26, dibujada en `preparar_arte_nivel.py`: loza crema con la franja terracota de la casa, café adentro y contorno oscuro) se tira igual, aturde a A.S.P.I. si le cae encima y, rota, deja trozos de loza y un charco de café: en la pelea es una mancha como antes. Se borró `rollo.png`. Revisados los demás cuartos: no hay otros objetos fuera de lugar (el vaso de la mesa y de la consola, las llaves del zapatero, las macetas y el vaso del estudio tienen sentido donde están).
- **Ropa doblada:** en el medio de la cama (5572) y hundida 9 px en el edredón: el arte está en 3/4 y termina en la punta de la esquina de adelante; apoyada en el borde del colchón se veía flotando.
- **Puertas iguales a los dos lados:** el vano de la escalera era un arco (en el descanso y en el pasillo); ahora es un hueco cuadrado con el mismo marco de madera de las puertas (`vano.png`, 140 × 150, sale de `puerta_abierta_v2` sin la hoja). Además cada par empieza en el mismo estado: la cocina cerrada a los dos lados, la del dormitorio entornada a los dos lados y la del balcón cerrada a los dos lados (se abren juntas). `Sala.estilo_puerta()`; `prueba_reglas_nivel` comprueba en cada par el mismo marco, el mismo estado y el mismo ancho, y que ningún hueco sea un arco.

