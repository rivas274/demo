# Nivel 1, "La Gran Fuga" (v4, construido)

Documento vigente del nivel. Fecha: 2026-10-19 · Fase 3 (vertical slice). Sale de la propuesta v4 aprobada por el creador (habilidades apagadas, bolsillo de 5 y nido de calcetines, arañar y maullar, Valeria con 4 poses y caminar, escalera de fondo; desde el 2026-10-19 con cajas de la mudanza en vez de la reja) y cuenta lo que quedó **construido** en `siete-vidas/juego/` (datos en `scripts/sala.gd`). Plan de arte: `nivel-01-plan-arte.md`. Revisiones que se corrigieron: `revisiones/2026-10-18-nivel1-gran-fuga.md` (sección 9) y `revisiones/2026-10-19-nivel1-v4.md` (sección 11).

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
- **Escalera:** sección 4. **Hito:** las cajas de la mudanza con la cesta de ropa al pie de la escalera.

### 2.3 Cocina (opcional, 1340 px desde el 2026-10-19)
- **Enseña, de a una:** comer (tazón hondo: "Tres croquetas. Esto es un crimen.") → zarpazo (ratón de cuerda en el piso, 90 px después de su frase; queda patas arriba con la llave girando) → la caja de cartón se rompe de un zarpazo y suelta un snack → silla → estufa → mesón largo (el fregadero bajo la ventana): un ratón patrulla entre el fregadero y el microondas (cuida la subida) → microondas: el pollo. La cámara se mueve: la cocina mide 1340 px (sección 18).
- **Robar el almuerzo de Valeria:** el pollo asado, que espera sobre el microondas (fuera de la patrulla del ratón: nunca lo tapa). Valeria, frente a la estufa, mira hacia el microondas: "¡EN SU CARA!" y "¡ESE ERA MI ALMUERZO! Esto va a mis historias.", y regaña. **Travesura "almuerzo"**, 2 snacks.
- **Calcetín 2 (exploración):** mesón → microondas → refrigerador (escalones de 54 px).
- **Hito:** el refrigerador con imanes y el pollo grande a escala de gato.

### 2.4 Pasillo de arriba (1240 px; ensanchado 200 px para el baño)
- **Giro:** baúl → consola: Felipe tira el vaso; sale A.S.P.I. del estudio, va a la mancha y la aspira. La succión arrastra a Felipe de pie: "Mantén {agacharse}. Uñas: modo ancla." (agachado se aferra). Aquí no hace daño. Vuelve a su cuarto: "Suciedad eliminada. Gato… registrado." Felipe: "Ese robot cree que me registra. Yo lo registro a él."
- **Ignorar el láser (secreta):** el punto mide 8 px, con halo que late; la primera vez Felipe dice "No. No voy a caer.". 5 s quieto con el punto rojo cerca: se apaga "de vergüenza" y cae una **foto vergonzosa** del cajón de la consola.
- **Arañar es llave:** la puerta del dormitorio está entornada; se abre arañándola ("Puerta entornada. Invitación aceptada.").
- **Descanso:** cojín, a 2 px del rectángulo sagrado de la puerta del estudio.
- **Lugar visto (R17):** por la ventana se ve el toldo del vecino con una caja de pizza **afuera, detrás del vidrio** (con reflejos encima); el alféizar (90 cm, sobre la consola) se pisa pero está vacío y Felipe dice "Esa pizza es mía. Algún día." (se vuelve con Caer de Pie).
- **Lugar insinuado: la puerta del baño** (x 4740, entre la puerta del dormitorio y el láser). Cerrada, con el mismo marco de 140 px que las demás y sin tapete; bajo la puerta, luz fría de tubo (`dfe8e2`) que titila cada 5 a 8 s; un «plic» cada 2,6 s que solo se oye a 300 px o menos (sin charco). A 90 px Felipe dice «El trono de porcelana. Algún día será mío.» (también al «Probar»: la hoja tiembla 1 px y no cede). Si después se queda quieto 2 s a 60 px o menos, la manilla da un destello de 1 px, Felipe la mira de reojo y dice «Esa manija me mira raro.». No es habitación ni va en `PUERTAS` (R7), no es lugar visto (R17: es oído); queda para la maña futura «Abrir puertas», que Felipe aprenderá viendo a otro gato colgarse de una manilla (no está en el juego ni en la tabla de acciones).
- **Hito:** el retrato familiar donde Felipe tapa a todos, sobre el láser y el cojín (el trono con su retrato). Bajo la consola se pasa agachado (47 px libres); el baúl se pasa por delante.

### 2.5 Dormitorio (opcional, 720 px)
- **Repasa** subir muebles: banquito → cama → cómoda → repisa → ropero. La repisa es una repisa de pared entre la cómoda y el ropero (con el paisaje encima); la ventana va sobre la cama, del mismo tamaño que las demás, con la cortina a los lados colgada de una barra y hasta el piso. Una cesta de ropa al pie de la repisa sirve para salir del hueco entre la cómoda y el ropero.
- **Saquear el cajón de calcetines:** manotazo al cajón (desde la cama): calcetines volando y el **calcetín 3** sobre la cómoda ("Inventario.").
- **Travesura suelta:** desordenar la ropa doblada de la cama (la pila de `arriba-extra`, 52 × 48, en el medio del colchón y hundida 9 px en el edredón para que se apoye y no flote; se acicala encima y queda revuelta y con pelos: "Doblada era aburrida. Ahora tiene pelo de rey."). `prueba_nivel` comprueba que se apoya en el colchón, que el contorno del Indicador calza con la pila y que «Desordenar» funciona.
- **Lugar visto (R17):** la repisa alta con la caja de recuerdos de Valeria, sobre el hueco entre la cómoda y el ropero; no se alcanza todavía (Afilar Garras: se trepará la cortina hasta la barra y de ahí se salta a la repisa alta). La cortina es **arte de Gemini** (`dormitorio-cortina-alta.png`, procesada por `preparar_arte_nivel.py` a 45 × 277): dos paños (el derecho en espejo) de una sola barra con un remate en cada punta, 18 px sobre el marco de la ventana; cada paño tapa 9 px de la ventana y la tela baja hasta el piso (lo que sobra del arte no se dibuja). Sin colisión: si se vuelve trepable con Afilar Garras, el rectángulo trepable es la tela de cada paño.

### 2.6 Estudio de Valeria (jefe, 936 px desde el 2026-10-21: la cámara lo recorre)
- **Dos islas de juego (estudio v3, pedido del creador del 2026-10-21: «la batalla con A.S.P.I. no se centre en solo un pedazo de la pantalla»).** A la izquierda, la de siempre: silla (55) → escritorio (98; vaso, taza, teclado, laptop) → repisa de las macetas (170, sobre la pizarra). A la derecha, contra la pared y fuera del rectángulo sagrado de la puerta del balcón, **la de Valeria que lee y teletrabaja**: un **librero bajo** lleno de libros (80 cm, 97 px; arte de Gemini `muebles-sala.png` sin sus filas del medio) con su **planta** (lengua de suegra de `librero-gato.png`: se rompe, deja tierra, pedazos y las hojas) y el **portarretratos de Su Majestad** (el retrato dorado de `cuadros.png`, chico: no se rompe); delante, la **caja de la mudanza con los libros que todavía no desempaca** (40 cm, 48 px: el escalón del piso al librero). Entre las dos, a media altura, la **repisa del gato** (1,14 m, 138 px): escritorio → repisa de las macetas → repisa del gato → librero → caja → piso, un camino por arriba de A.S.P.I. Todo se pasa por delante (atravesable desde abajo): A.S.P.I. anda por el piso, delante de los muebles, y persigue a Felipe por el cuarto entero (límites 6870–7706). Lo que cae a la derecha también le llena el depósito. Sin alfombra a la derecha: no hay una cuarta alfombra de Gemini que no esté ya en uso (encargo opcional en `05-estado-actual.md`).
- **Desorden (2026-10-23, `revisiones/2026-10-23-pelea-aspi-sin-reposicion.md`): 14 manchas en 11 fuentes, todo con arte que ya existía.** Izquierda: vaso y taza (escritorio), **2 apuntes** que vuelan al pisar el teclado, **2 notas del corcho** (se despegan desde la punta derecha del escritorio, «Despegar») y 2 macetas (repisa). Centro: **pila de libros** en la repisa del gato. Derecha: **pila de libros de la mudanza** sobre la caja, **2 libros del estante de arriba** del librero bajo (se sacan desde la caja o el librero, «Desordenar»), la planta y el portarretratos. Lo que cae queda en el piso hasta el final, con su sombra; al ganar, el estudio queda destruido como trofeo.
- **Examen** (sección 5). **Pisar el teclado (secreta;** teclado dibujado de 52 × 24, con cuatro filas de teclas, delante de la pantalla**):** la pantalla dice "jjjjjjjjjj", **foto vergonzosa 3**, y durante la pelea vuelan los apuntes del escritorio (uno cada 4 s, **dos en total**), que cuentan como manchas.
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

- **Cajas de la mudanza** (decisión del creador, 2026-10-19; reemplazan la reja «PIPE: NO», que se veía mal y se atravesaba): tres cajas de unos 30 cm con la cesta de ropa encima (pieza D de Gemini, tanda 3F, 66 × 135), al pie de la escalera sobre el primer escalón. Valeria lleva un año «ordenando». La pila es **sólida** (`CajasMudanza`, 64 × 133): desde el piso no se pasa caminando, gateando ni de un salto (el salto llega a 79 px); `prueba_nivel` empuja a Felipe contra ella. Desde afuera solo la empuja: «Cajas de la mudanza. Llevan un año «ordenándose».».
- **El librero es la escalera del gato:** repisas a 48, 103 y 155 px. Desde la de arriba pasa por encima de la cesta y cae al pie de la escalera.
- **Subir:** al pie (x 2362), "Ascender" (acción o arriba): Felipe sube los **7 escalones** con la animación `subir_escalera`, un saltito por escalón por la línea de los peldaños (`Sala.PELDANOS`), camina por el descanso hasta el vano y hay un fundido al pasillo. La escalera va en **dos capas**: peldaños detrás de Felipe y pasamanos con barrotes delante, que baja a **70 %** de opacidad mientras sube.
- **Descanso:** un rellano grueso con el armario bajo la escalera (tablas, puerta entreabierta) y la **escoba de Gemini** (pieza F, 44 × 133) apoyada fuera, bajo el descanso; la escoba de código se quitó (lección 32).
- **Bajar:** por el vano del pasillo aparece en el descanso y baja escalón por escalón; termina adentro de las cajas, en el piso. Si la pila sigue entera: «Desde aquí arriba, esas cajas se ven… empujables.».
- **Atajo (R6), "desde arriba":** parado en el **segundo peldaño** (x 2348–2372, 45 px, una tabla de colisión que calza con el arte), "Tirar": un manotazo vuelca la caja de arriba con la cesta, que cae en arco dando media vuelta y queda **abierta con la ropa en el piso** (pieza E, delante del librero), con «¡PUM! · MUDANZA: 0», sacudida y el logro "Atajo de Gato"; Felipe: «Mudanza terminada. De nada.» y Valeria, si está abajo sin audífonos: «¡Mis cajas! ¡Estaban ORDENADAS!». Quedan dos cajas (67 px, se suben de un salto) y el borde de la caja abierta (33 px) es un escalón: se va y se vuelve sin el librero. Queda a 349 px de la caja de arena.

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

Al volver después de perder una vida (reaparece en el cojín), la entrada corta dura 1 s (portazo y nombre) y la pelea **conserva la fase, las manchas del piso, las montañas de pelusa y el depósito** (si estaba llena, lo vacía en el piso).

### Reglas, fases y ataques (no se gana sentado, G12)
- **Ensuciar (2026-10-23: nada reaparece):** lo que cae al piso deja una mancha y **queda ahí hasta el final** (14 manchas en 11 fuentes, sección 2.6). A.S.P.I. va a limpiarla: **anticipación** (el cepillo gira 0,6 s), aspira (de pie arrastra; agachado se aferra; en la fase 3 alcanza 260 px) y suma "+1" y "Glup.". Se lleva la mancha (tierra, café, el papel, la nota, la pelusa); los pedazos, la planta, los libros y el retrato quedan como desorden.
- **La pelusa vuelve (la munición nunca falta):** al apagarla, se le abre el depósito y **escupe una montaña de pelusa** («¡BLORP!», nube; `DatosJefe.devuelve`: 2 motas tras la fase 1 y 2 tras la fase 2) y Felipe dice «Devolución aceptada.». La montaña se **esparce** con el manotazo de siempre (burbuja «Esparcir», «¡FUP!»): quedan 2 motas que cuentan como manchas. Si nadie la apaga a tiempo, **vacía el depósito en el piso** (montaña con todo lo que tenía, «¡LO VACIÓ EN EL PISO!»). Las manchas que quedan en el piso pasan a la fase siguiente. Cuenta: pide 2/3/3 (8); tirando lo mínimo bastan 4 cosas; hay 14 + 4 de pelusa. La suciedad solo baja al apagarla (devuelve 2 de 2 y 2 de 3), así que nunca se acaba (`prueba_municion`).
- **Depósito lleno:** 2/3/3 manchas por fase; se detiene inofensiva 4/3,5/3 s pitando «¡DEPÓSITO LLENO!» con «¡DEPÓSITO LLENO!» y una flecha sobre ella (v3: ya no en la franja de arriba). Si estaba bajo la repisa, sale disparada 80 px; si estaba bajo la caja de los libros o el librero bajo (Felipe caería en ellos y no en su botón), sale al piso libre de al lado, hacia la puerta del balcón (`Nivel1.ASPI_NO_SE_LLENA_BAJO`). Felipe le cae encima: **congelado de 0,1 s, destello, sacudida, «¡CLIC!», polvo y sonido en capas**.
- **Embestida (todas las fases):** se echa atrás 10 px y su luz roja parpadea 0,5 s; recién entonces carga, y solo cargando hace daño.
- **Soplido contra el que acampa (desde la fase 2):** más de 3 s (2 s en la fase 3) arriba de algo de más de 90 px: va debajo, vibra con luz amarilla 0,6 s y sopla: Felipe sale al piso sin daño (vuela atravesando los muebles bajos, como al bajar agachado: no queda en la caja ni en el librero) y las macetas de la repisa caen y se rompen (A.S.P.I. se ensucia sola). Arriba del librero bajo (97 px) también cuenta como acampar: A.S.P.I. cruza el cuarto hasta él.
- **Bolas de pelo en arco (fase 3):** tos mecánica de 0,5 s ("¡COF!") y la bola va hacia donde está Felipe (llega al escritorio y a la repisa); cada 3,4 s (v3).
- **Cortocircuito y apagón (fase 3, v3, `revisiones/2026-10-23-pelea-aspi-v3.md`):** al empezar la fase corre contra el enchufe de la estación («¡ERROR!», reversa), chispas y «¡BZZZT!», y el cuarto queda en penumbra con su luz roja de emergencia. Los charcos de agua y café brillan; si pasa por uno queda **en corto** (vulnerable como con el depósito lleno). Siempre hay al menos uno (el choque tumba el vaso y la taza o se le sale el agua del tanque). Maullar la lleva al charco. Al apagarla, la luz vuelve de golpe.
- **Lectura (v3):** los avisos nacen sobre ella («¡DEPÓSITO LLENO!», «¡EN CORTO!»), la embestida marca en el piso una línea roja hasta donde va a cargar, Felipe piensa en un globito sobre su cabeza y la cámara se corre hacia ella cuando viene de lejos (flecha en el borde si no se ve).
- **Sobrecarga y nota (v3):** antes del «¡BLORP!», 0,6 s de vibración, humo y chispas. Al final, la nota de «Arte gatuno» (Aficionado, Decorador u O B R A   M A E S T R A); con más del 85 %, Valeria grita «¡¡FELIPE!!» desde abajo y sale el logro «Reestructuración Inmobiliaria».
- **Maullar:** gira hacia Felipe ("¿Gato detectado?").
- **Final:** cámara lenta 0,5 s, «¡APAGADA!», la imaginación vuelve de golpe a la normalidad (el estudio real queda destruido: el trofeo), se abre la puerta, Felipe se lame la pata y mira su obra: «Estudio redecorado. Estilo: Su Majestad.».

### Es un examen (R12)
| Mecánica | Se enseña en | En la pelea |
| --- | --- | --- |
| Tirar | Sala (vaso) | Hacer manchas |
| Agacharse | Recibidor (zapatero); aferrarse en el pasillo | Aguantar la succión |
| Muebles como escalera | Recibidor, cocina, dormitorio | Silla → escritorio → repisa a la izquierda; caja → librero bajo a la derecha; repisa del gato entre las dos |
| Saltar | Sala | Caerle encima; esquivar embestidas y bolas |
| Zarpazo | Cocina | Rebota en la carcasa |
| Maullar | Recibidor | Atraerla (opcional) |

## 7. Mapa del nivel (construido)

Alto de todos los cuartos: 424 px (3,5 m). Piso en y = 448. Muros entre cuartos. Alturas desde el piso. Cada colisión sale de medir la fila opaca de su arte (`prueba_reglas_nivel.gd` la compara a ±2 px).

| Cuarto | x en el mundo | Ancho | Qué hay (x en el mundo · altura) |
| --- | --- | --- | --- |
| Sala | 0–1280 | 1280 | nido 40 · ventana 170–350 (alféizar 109) · sofá 240–480 (asiento 49, respaldo 102) · rascador 520–620 (69/114/165) · silla 680 (55) · mesa 745–923 (91, vaso en 905) · silla 929 (55) · retrato · puerta 1188 |
| Recibidor | 1440–2640 | 1200 | puerta 1532 · zapatero 1626–1786 (97; 40 libres debajo; llaves) · caja de arena 1832–1936 (45) · lámpara 1942 · puerta de la cocina 2070 · librero 2162–2266 (48/103/155/218) · **cajas de la mudanza 2262–2320 (arte 60 × 124, entre el librero y el poste del pasamanos con 2 px de aire a cada lado; colisión 122 con la cesta; 62 tiradas; caja abierta en el piso 2180–2264, borde a 33)** · peldaño 2 2348–2372 (45, desde ahí se tira) · pie de la escalera 2362 · escalera 2322–2548 con el armario bajo la escalera (puerta entreabierta; escoba de Gemini en 2590) y vano cuadrado en el descanso 2497–2637 (150) |
| Cocina | 2800–4140 | 1340 | puerta 2892 · reloj 3210 · repisa de pared 3060–3180 (tabla a 1,24 m: maceta y reserva de croquetas, decorado sin colisión) · tazón 3010 y lata · ratón 3200–3290 · caja de cartón 3360 · Valeria 3500 (frente a la estufa) · silla 3400 (55) · estufa con olla 3462–3550 (109) · alacenas 3458–3648 (a 1,49 m) · mesón largo 3556–4032 (109; fregadero embutido 3706–3808 con el grifo de Gemini en 3799) · ventana 3682–3832 sobre el fregadero (alféizar 109, cenefa) · ratón del mesón 3846–3890 · microondas 3926–4024 (163, pollo 3975) · refrigerador 4046–4130 (216, calcetín 2) |
| Pasillo | 4380–5620 | 1240 | vano de la escalera 4472 (140 × 248) · baúl 4570 (54) · alfombra 4750–5010 · consola 4636–4792 (97, vaso; 47 libres) · ventana 4640–4820 apoyada en la consola, alféizar 4644–4816 (109; la pizza, afuera tras el vidrio, en 4769) · puerta del dormitorio 4916 · **puerta del baño 5120** (cerrada; rectángulo sagrado 5028–5212) · láser 5220–5360 · retrato familiar 5280–5380 · cojín 5364–5434 · puerta del estudio 5528 |
| Dormitorio | 5780–6500 | 720 | puerta 5872 · banquito 5966 (53) · cama 6024–6224 (65) · ventana 6049–6199 sobre la cama (alféizar 109) · cortina 6016–6232 (telas a los lados, barra a 230, hasta el piso) · ropa doblada 6148 (en medio de la cama, hundida en el edredón) · cómoda 6230–6314 (96, cajón) · repisa 6320–6390 (145) con el paisaje encima · cesta 6327–6387 (35) · repisa alta 6315–6395 (290, lugar visto) · ropero 6396–6500 (185) |
| Estudio | 6820–7756 | 936 | puerta 6912 · silla 7004 (55) · ventana 7035–7185 sobre el escritorio (alféizar 109, paños cortos) · escritorio 7068–7228 (98; vaso, teclado, laptop, taza de café) · A.S.P.I. en su base 7200 · estación de carga 7240–7322 · pizarra 7236–7356 · repisa de las macetas 7266–7326 (170, 2 macetas) · **caja de los libros 7364–7446 (48)** · **repisa del gato 7372–7432 (138)** · **librero bajo 7452–7565 (97; planta en 7480, portarretratos en 7536)** · puerta del balcón 7664 |
| Balcón | 7916–8556 | 640 | puerta 8008 · maceta grande 8206 (32) · baranda 8276–8460 (89; Felipe se sienta en 8364–8446) · ciudad · toldo de la panadería 8256–8556, 196 px bajo el piso (solo existe en el salto final) |

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
| R6 | ✔ La caja de arriba de la mudanza se tira solo desde el segundo peldaño (adentro) y queda a 349 px de la caja de arena; se va por el librero y se vuelve por las cajas |
| R7 | ✔ Dos pisos unidos por la escalera (7 escalones); librero, mesón, microondas, refrigerador, ropero; puertas que van y vuelven; ningún cuarto de menos de 640 px. La puerta del baño no es habitación (no está en `PUERTAS`): R7 sigue valiendo. ✔ `prueba_escenario`: todo se alcanza sin doble salto ni trepar y **ningún hueco atrapa a Felipe** |
| R8 | ✔ Huecos bajo muebles sólidos de 0 o de 36 px o más (zapatero 40, consola 47); lado **menor** ≥ 24 px de todo lo interactuable (comida y recompensas incluidas), **también lo dibujado por código** (teclado, ropa y cajón: `Sala.DIBUJADOS_INTERACTUABLES`) y el tamaño que declara cada interactuable del nivel armado (G7); puertas medidas en la imagen (vano de 112 y 120 px); ratón a la mitad de Felipe |
| R9 | ✔ Pared distinta por cuarto. 👁 Hito por cuarto: retrato oficial, cajas de la mudanza, refrigerador con imanes, retrato familiar, cama y cortina, base de carga roja, la ciudad |
| R10 | ✔ 3 calcetines sobre algo pisable; el del refrigerador pide subir |
| R11 | ✔ La única zona fuerte es el estudio; cierra con el balcón |
| R12 | ✔ 7 cosas para tirar en el estudio, en las dos islas, y dos en alto (repisa). Ver sección 6 |
| R13 | ✔ Todos los cuartos menos el balcón tienen con qué jugar. 👁 Su chiste (sección 2) |
| R14 | 👁 El primer plano quedó solo en el balcón; el pasamanos baja a 70 % mientras Felipe sube; diálogo y carteles no tapan a Felipe (tampoco al aterrizar en el balcón: G1); el aviso de logro va por encima del diálogo y fuera de su cuadro (M3); ningún ratón patrulla sobre la comida o lo que se tira (G5). ✔ Rectángulo sagrado: ningún mueble, decorado, ratón, descanso ni lugar de Valeria se cruza con una puerta o la escalera (B3, G10) |
| R15 | ✔ `prueba_movimiento` (altura de Felipe); la animación nueva de esta parte (ninguna) no aplica |
| R16 | ✔ `prueba_jefe`: entrada de 8 pasos en menos de 5 s, sin negro al entrar por la puerta, imaginación solo en la entrada, cartel y pista por fase, todo vuelve de golpe al ganar, y la misma presentación sirve para otro jefe |
| R17 | ✔ Dos lugares vistos que no se alcanzan todavía (toldo del vecino: Caer de Pie, con la caja tras el vidrio y el alféizar vacío, G3; caja de recuerdos: Afilar Garras); el baño es un lugar **insinuado** (oído, no visto), para «Abrir puertas»; atajo de la reja. 👁 La historia la cuenta el escenario: reja anti-fuga con cartel, retratos, carpeta de fotos |
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
| G12 | **Arreglado.** Soplido contra el que acampa, bolas en arco, succión de 260 px en la fase 3. (Lo roto que volvía de a uno se cambió el 2026-10-23 por la montaña de pelusa: nada reaparece.) |
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

## 15. Ambientes (2026-10-19, `revisiones/2026-10-19-ambientes-nivel1.md`)

Plan de 47 cambios aplicado en una pasada, con 0 créditos (código, arte existente y la tanda 3E de Gemini, que llegó a tiempo y se integró en la misma pasada). Estado de cada cambio en la sección «Aplicado» del plan; hoja antes y después de los 12 cuartos (más el 13, el baño).

- **Sistema de la casa:** un solo marco de puerta de 140 × 248 en los cinco estados (la entornada es la hoja cerrada apoyada con 12 px oscuros del lado de la manilla), el vano de la escalera a la altura de una puerta (con el pasamanos y dos peldaños bajando dentro del hueco del pasillo), una sola ventana (el marco de la de la sala en 9 partes, con vidrio, reflejos y parante en cruz), zócalo de 18 px y cornisa con dentículos y penumbra, cuadros con el borde de arriba en el dintel.
- **Luz y peso:** rayos hacia la derecha en las 5 ventanas (tres franjas con el tono de cada cuarto y 5 motas de polvo que suben), sombras de contacto al 45/28 % con la base opaca real y un bloque bajo cada pata, sombra de 2 px de todo lo colgado.
- **Pisos:** sin costura, cada baldosa volteada de forma alterna y con otro corrimiento por cuarto; terracota en la cocina y losa de piedra en el balcón (tanda 3E). La cocina tiene azulejo solo hasta 1,5 m con listel y pintura crema arriba.
- **Vida (G9, G11):** pelos de Felipe (sofá, edredón, cojín, alfombras), arañazos viejos (puerta entornada, ropero, pata de la mesa, poste de la escalera), polvo arriba de los muebles altos, cables y enchufes, croquetas y la lata de atún, libro en el banquito, post-its en el monitor; tanda 3E: alfombras, mesita de Valeria (la única colisión nueva: tablero a 58 px, medido), galería asimétrica de la sala, perchero, zapatillas, video viral, llave con trapo, polaroids en la nevera, corcho, fachada del balcón y la isla de jardinería.
- **Movimiento (G10):** motas en cada rayo, luz del cargador en la sala, lámpara del recibidor que parpadea cada 9 s, segundero y goteo en la cocina, vapor de la pizza y luz del baño en el pasillo, cortina con brisa, monitor del estudio y plantas de la baranda que se mecen.
- **No se tocó:** Felipe, las colisiones medidas (el ensanche solo corre coordenadas), la ruta, los escalones de la pelea y las sillas espejadas del comedor.


## 16. Piso con profundidad, armario bajo la escalera y fregadero (el creador, 2026-10-19)

El creador vio que todo parecía pegado a la pared o flotando: la línea de apoyo (`Sala.SUELO`) coincidía con el borde de arriba de la franja del piso, así que el piso era una tira decorativa. Arreglado en una pasada con 0 créditos, moviendo solo el dibujo (las colisiones no se tocaron).

- **El piso es un plano visto un poco desde arriba** (como Eastward, Stardew Valley o Untitled Goose Game): la pared termina en `Sala.PARED_BASE`, **14 px** (`FONDO_PISO`, desde la pasada única §17) sobre la línea de apoyo, y bajo `SUELO` quedan **30 px** de piso hasta el borde de la pantalla (44 px de piso en total). Los pies de Felipe, Valeria, A.S.P.I. y las patas de los muebles quedan dentro del piso, delante del zócalo.
- **Piso:** reemplazado en la pasada única (§17) por las franjas de Gemini sin perspectiva.
- **Lo de la pared sube con la pared (`FONDO_PISO`):** zócalo, cornisa, ventanas recortadas y la de la sala (alféizar a 109 px de `PARED_BASE`), cuadros (en el dintel, `PARED_BASE − 248`), perchero, alacenas, corcho, enchufes, la fachada del balcón y **las puertas**: se dibujan con el umbral en la unión pared-piso, con el piso delante, el tapete tendido en el piso como trapecio, la rendija y la luz derramándose hacia delante. El nodo de cada puerta sigue en `SUELO` (Felipe y Valeria la cruzan igual). **Excepción:** la ventana del pasillo queda en el plano de juego porque su alféizar se pisa desde la consola.
- **Repisas de pared** (dormitorio, macetas del estudio, repisa alta): se ve su tabla desde arriba, `FONDO_PISO` de hondo, más clara que el canto y más oscura junto a la pared, con un listón en la pared; el paisaje se apoya al fondo de la repisa y la caja de recuerdos en medio.
- **Sombras de contacto** (`Sala.sombra`, 2 px desde la pasada única, §17): bajo cada mueble (con un bloque bajo cada pata), el nido, el armario, y en vivo bajo Felipe (cae en la superficie que tiene debajo; en el aire se achica y se aclara), Valeria (de pie o caminando), A.S.P.I., los ratones, la caja y la comida.
- **Islas adelantadas** (sin colisión, la base unos px bajo `SUELO`): zapatillas (+8), lata de atún (+6), regadera (+8), saco de tierra (+4) y maceta rota (+11). Las alfombras se tienden en el piso como trapecio (de 12 px detrás de la línea de apoyo a 6 px delante).
- **Armario bajo la escalera** (`Sala._dibujar_armario_escalera`): el faldón con una puertita no se entendía. Ahora tablas verticales cierran el hueco triangular bajo el larguero (medido columna por columna en el arte de los peldaños) y el de bajo el descanso, con su zócalo y una moldura que sigue los peldaños; una puerta con la parte de arriba inclinada como la escalera, entreabierta, con su pomo, una caja adentro y la escoba que asoma con las cerdas en el piso. El zócalo que subía bajo el larguero (R-6) se quitó: lo tapa el armario.
- **Fregadero:** rehecho a escala en la pasada única (§17).
- **Ropa doblada:** en medio de la cama (x 5768), hundida en el edredón (`ROPA_HUNDIDA` 22 px bajo el borde de arriba del colchón), con la tela que se hunde alrededor.
- **Pruebas:** `prueba_nivel` comprueba la banda de piso (12–16 px detrás desde §17, ≥ 16 delante), el umbral de cada puerta en la unión pared-piso, el alféizar de las ventanas recortadas, el fregadero (§17) y la ropa en medio de la cama y hundida (14 a 24 px). Las comprobaciones de arte contra colisión (B4, ±2 px) siguen igual: ningún mueble con colisión cambió de lugar.

## 17. Pasada única de calidad visual (el creador, 2026-10-19, `revisiones/2026-10-19-pasada-unica.md`)

El creador: «se ve apresurado, montado; el piso se ve mal; ¿por qué el sofá tiene una línea blanca?; el lavamanos quedó desproporcionado». Plan único y 0 créditos; colisiones sin cambios salvo la repisa alta (lugar visto).

- **Piso de Gemini sin perspectiva:** `piso_parquet` (cuartos), `piso_damero` (cocina, contraste al 80 %) y `piso_losa` (balcón, con su canto), 44 px de alto, sin costura (`preparar_arte_nivel.pisos_gemini`). Banda detrás de los pies de **14 px**, zócalo de **3 px** (bisel claro y madera) con **1 px de sombra** en la unión.
- **Sombras de 2 px** bajo muebles, patas y en vivo; **1 px de oclusión** en la unión pared-piso detrás de los muebles de 80 px o más.
- **Resalte por silueta:** el Indicador nunca dibuja un rectángulo; contorno crema cálido de 1 px que late, detrás de muebles y personajes. Sofá, puerta entornada, cómoda, ropa y Valeria dan su arte.
- **Fregadero a escala:** 62 × 16 px (un tercio del mesón) embutido en la cubierta, grifo de cuello de cisne por código con la boca sobre el centro (`Sala.GRIFO`, capa MARCAS: el ratón pasa por detrás) y paño de cocina en el canto. Se borró la llave con trapo.
- **Luz de la sala:** la lámpara ya no es una luz redonda (halo en el tapiz); su luz cae en el tablero de la mesita y en el piso en escalones.
- **Además:** grosor de muro en las puertas abiertas (jamba y dintel en dos tonos), farol del balcón borrado (cortado por el borde y con halo) y repisa alta del dormitorio a 2,26 m (`SUELO − 274`; la caja de recuerdos quedaba cortada; sigue fuera de alcance).
- **Cumplimiento de reglas:** R1–R19 sin cambios (`prueba_reglas_nivel` en 0 fallos); R17: la repisa alta sigue sin alcanzarse (89 px sobre el ropero, tope 72).


## 18. Cocina más grande, cajas de la mudanza y objetos apoyados (el creador, 2026-10-19, `revisiones/2026-10-19-cocina-escalera.md`)

Pasada única con el arte de Gemini de la tanda 3F (`arte/referencias/gemini/cocina-v2.png`, procesado con `preparar_arte_nivel.cocina_v2()`), 0 créditos.

- **Cocina de 1340 px** (la cámara se mueve; todo x ≥ 4000 corrió 380 px con un script sobre los literales: 173 en `sala.gd`, el bot y las pruebas; `ANCHO` 8260). Composición de Gemini adaptada a la escala de gato (mesón a 90 cm = 109 px, no los 130–140 que sugería): puerta → rincón del gato (tazón, lata, croquetas) → ratón y caja → silla → **estufa con olla** → **mesón largo con el fregadero embutido** bajo la ventana (grifo de cuello de cisne del arte; la gota sigue) → microondas con el pollo → refrigerador. Alacenas nuevas sobre la estufa. Se quitaron el fregadero y el paño de código.
- **Escalera:** reja, cartel y `reja_frente.png` borrados; cajas de la mudanza sólidas y atajo "desde arriba" (sección 4).
- **Objetos sobre muebles** (lección 29): cada tirable lleva cuánto se hunde (`Sala.TIRABLES`, tercer dato; `Vaso.hundido`) hasta el medio de la cara de arriba que se ve en el arte, con sombra de contacto 1 px más ancha que su base: mesa 5, consola 4, zapatero 2, escritorio 9 (su cubierta se ve de 16 px), repisa dibujada −6 (al medio de su tabla). El vaso lleva posavasos de 1 px. Monitor, teclado y pantalla bajaron 9 px; libro del banquito al doble (42 × 12) en medio del asiento; microondas y monitor con sombra (`Sala.APOYADOS`). **Se quitaron la impresora y la regleta con sus cables** del estudio (en la pelea, al pisar el teclado vuelan los apuntes: «¡FIUU!»).
- **Barreras:** `prueba_nivel` empuja a Felipe contra cada muro de cada cuarto, cada mueble sólido que llega al piso y la pila de cajas (24 empujes), y prueba las puertas cerradas (cocina, balcón, baño): nada se atraviesa.
- **Cumplimiento:** R1–R19 en 0 fallos; R6 con la caja de la mudanza; R8 con la colisión de las cajas medida contra su arte.

## 19. Segunda pasada: 3 puntos (el creador, 2026-10-20, `revisiones/2026-10-19-cocina-escalera.md`, «Segunda pasada»)

0 créditos, solo arte de Gemini que ya estaba en el repositorio (`preparar_arte_nivel.segunda_pasada_cocina()`).

- **Entrada de la cocina:** isla de pared sobre el rincón del gato: repisa con ménsulas (`repisa_cocina`, 120 × 35) con la tabla a 1,24 m, la maceta con flores de Valeria y la **reserva de croquetas** al doble (`croquetas_reserva`, 38 × 44), guardada en alto, lejos de Felipe; el reloj arriba a la derecha. Decorado de pared (sin colisión, no se alcanza en el nivel 1); objetos apoyados en la tabla con sombra. El piso y la mitad derecha de la pared quedan libres.
- **Pila de cajas:** entre el librero (hasta 2266, no se puede correr: lo limita el rectángulo de la puerta de la cocina) y el poste del pasamanos (desde 2325) quedan 59 px; la pila de 66 no cabía. Se escaló a 0,32 (60 × 124, cajas de unos 27 cm) y va en 2262: se ve entera, con 2 px de aire a cada lado. Sigue sin saltarse desde el piso (122 px), se pasa desde el librero y la caja tirada deja 62 px (atajo de ida y vuelta).
- **El mundo reacciona al tirar la caja (pilar 5):** congelado, «¡PUM! · MUDANZA: 0», sacudida corta, **nube de polvo** y **dos calcetines** (`ropa_1`, `ropa_2`, de `arriba-extra`, no el calcetín rayado que se colecciona) que saltan de la caja: uno queda en el piso y otro sobre las dos cajas (nada cae delante de la puerta). **Valeria oye el golpe aunque tenga audífonos**, desde donde esté: se saca uno (`Valeria.sacar_audifono`, 3 s) y dice con su retrato «¡¿Qué fue ESO?! …Perdón, era el gato. ¡FELIPE, MIS CAJAS!» (sin audífonos, la de antes). Cuando termina, Felipe: «Mudanza terminada. De nada.». Las dos frases van por la cola del diálogo (no se pisan) y el logro por la cola de anuncios, sin tapar el diálogo.

