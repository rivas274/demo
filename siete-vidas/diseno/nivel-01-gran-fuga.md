# Nivel 1, "La Gran Fuga" (v4, construido)

Documento vigente del nivel. Fecha: 2026-10-19 · Fase 3 (vertical slice). Sale de la propuesta v4 aprobada por el creador (habilidades apagadas, bolsillo de 5 y nido de calcetines, arañar y maullar, Valeria con 4 poses y caminar, escalera de fondo con reja) y cuenta lo que quedó **construido** en `siete-vidas/juego/` (datos en `scripts/sala.gd`). Plan de arte: `nivel-01-plan-arte.md`. Revisión que se corrigió: `revisiones/2026-10-18-nivel1-gran-fuga.md`.

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
- **Popo táctico (secreta):** agachado 1,2 s sobre la arena: censura irónica (pegatina de pescadito y "CONTENIDO SENSIBLE" sobre una papa). Valeria sale con mascarilla ("¡ACABO DE LIMPIARLA! Voy por bolsas...") y deja la puerta abierta: **recompensa camino** (la puerta de la cocina).
- **Travesura suelta:** las llaves del zapatero (se sube desde el borde de la caja de arena): "¡CLINK CRÍTICO!" y Valeria desde la cocina: "¿Mis llaves? ¿OTRA VEZ?".
- **Escalera:** sección 4. **Hito:** la reja con el cartel "PIPE: NO. Con amor, mamá".

### 2.3 Cocina (opcional, 960 px)
- **Enseña, de a una:** comer (tazón hondo: "Tres croquetas. Esto es un crimen.") → zarpazo (ratón de cuerda en el piso, 90 px después de su frase; queda patas arriba con la llave girando) → la caja de cartón se rompe de un zarpazo y suelta un snack → silla → mesón: un ratón cuida el pollo.
- **Robar el almuerzo de Valeria:** el pollo asado del mesón. Valeria, junto a la puerta, mira hacia el mesón: "¡EN SU CARA!" y "¡ESE ERA MI ALMUERZO! Esto va a mis historias.", y regaña. **Travesura "almuerzo"**, 2 snacks.
- **Calcetín 2 (exploración):** mesón → microondas → refrigerador (escalones de 54 px).
- **Hito:** el refrigerador con imanes y el pollo grande a escala de gato.

### 2.4 Pasillo de arriba (1040 px)
- **Giro:** baúl → consola: Felipe tira el vaso; sale A.S.P.I. del estudio, va a la mancha y la aspira. La succión arrastra a Felipe de pie: "Mantén {agacharse}. Uñas: modo ancla." (agachado se aferra). Aquí no hace daño. Vuelve a su cuarto: "Suciedad eliminada. Gato… registrado." Felipe: "Ese robot cree que me registra. Yo lo registro a él."
- **Ignorar el láser (secreta):** 5 s quieto con el punto rojo cerca: se apaga "de vergüenza" y cae una **foto vergonzosa** del cajón de la consola.
- **Arañar es llave:** la puerta del dormitorio está entornada; se abre arañándola ("Puerta entornada. Invitación aceptada.").
- **Descanso:** cojín, a 2 px del rectángulo sagrado de la puerta del estudio.
- **Lugar visto (R17):** desde el alféizar se ve, por la ventana, el toldo del vecino con una caja de pizza (se vuelve con Caer de Pie).
- **Hito:** el retrato familiar donde Felipe tapa a todos. Bajo la consola se pasa agachado (47 px libres); el baúl se pasa por delante.

### 2.5 Dormitorio (opcional, 720 px)
- **Repasa** subir muebles: banquito → cama → cómoda → repisa → ropero. Una cesta de ropa al pie de la cortina sirve para salir del hueco entre la cómoda y el ropero.
- **Saquear el cajón de calcetines:** manotazo al cajón (desde la cama): calcetines volando y el **calcetín 3** sobre la cómoda ("Inventario.").
- **Travesura suelta:** firmar la ropa doblada de la cama (se acicala encima: "Ahora tiene mi firma.").
- **Lugar visto (R17):** la cortina llega a la repisa alta con la caja de recuerdos de Valeria; no se trepa todavía (Afilar Garras).

### 2.6 Estudio de Valeria (jefe, 640 px, una pantalla)
- **Examen** (sección 5). **Pisar el teclado (secreta):** la pantalla dice "jjjjjjjjjj", **foto vergonzosa 2**, y durante la pelea la impresora (en el piso, bajo el escritorio) escupe un papel cada 4 s que cuenta como mancha.
- **Desenchufar a A.S.P.I.:** recompensa camino (la puerta del balcón) y logro "Desenchufada".

### 2.7 Balcón (alivio, 640 px)
- Sin enemigos ni agenda. Maceta grande → baranda. Felipe se sienta, la cámara se abre hacia la ciudad (1,5 s) y suspira: "Soy un gato de interior. Mi cardio es mirar por la ventana." El jugador salta (salto real): cámara lenta, cartel **"PODER NUEVO · CAER DE PIE"**, "No me caí. Aterricé con estilo." y el **resumen del día** tipo Balatro (travesuras, secretas, calcetines, fotos, snacks y perdones) en lugar de la pantalla final de antes.

## 3. Agenda de Su Majestad del nivel

`Agenda.NIVEL_1`, 8 líneas, 3 secretas ("???" hasta cumplirlas). Cada recompensa aparece sobre algo pisable y se recoge al pasar. Sitio y reacción de cada una en `Sala.AGENDA_SITIOS` (R18).

| # | Travesura | Cuarto | | Cómo se cumple | Recompensa |
| --- | --- | --- | --- | --- | --- |
| 1 | Romper algo y que me perdone igual | Sala | visible | Tirar el vaso y frotarse contra Valeria enojada | Snack |
| 2 | Arañar el sofá nuevo (con plástico) | Sala | visible | Garras afiladas en el rascador (con Valeria grabando) y arañar el sofá | Calcetín 1 |
| 3 | Popo táctico en la arena recién limpiada | Recibidor | **secreta** | Agachado 1,2 s sobre la caja de arena | Camino: puerta de la cocina |
| 4 | Robar el almuerzo de Valeria | Cocina | visible | Comer el pollo del mesón | 2 snacks |
| 5 | Ignorar el láser | Pasillo | **secreta** | 5 s quieto con el láser cerca | Foto vergonzosa 1 |
| 6 | Saquear el cajón de calcetines | Dormitorio | visible | Manotazo al cajón de la cómoda | Calcetín 3 |
| 7 | Pisar el teclado de Valeria | Estudio | **secreta** | Pararse en el teclado del escritorio | Foto 2 y papeles (manchas) en la pelea |
| 8 | Desenchufar a A.S.P.I. | Estudio | visible | Apagarla tres veces | Camino: balcón |

El calcetín 2 (refrigerador) es de exploración. Calcetines al nido (cada 10, una ranura de maña: "3/10 para tu próxima ranura"); fotos a la galería (las dos dan "Galería Viral"); snacks al bolsillo de 5 (mantener la acción 0,6 s sin nada cerca come uno).

## 4. La escalera

- **Reja anti-fuga** (decisión del creador): Valeria la atornilló después del video viral. Mide 1,5 m (182 px), se dibuja de 48 px (la cara de frente del arte de Gemini) con colisión fina de 12 px, cartel "PIPE: NO. Con amor, mamá" escrito por código. Desde afuera Felipe la **empuja** ("¿Una reja? ¿En MI escalera? Qué tierno.").
- **El librero es la escalera del gato:** repisas a 48, 103 y 155 px (escalones de 48 a 55). Desde la de arriba se salta la reja y se cae adentro, al pie de la escalera.
- **Subir:** al pie, "Ascender" (acción o arriba): Felipe sube los **7 escalones** con la animación `subir_escalera`, un saltito por escalón por la línea de los peldaños (`Sala.PELDANOS`), camina por el descanso hasta el vano y hay un fundido al pasillo. La escalera va en **dos capas**: peldaños detrás de Felipe y pasamanos con barrotes delante, que baja a **70 %** de opacidad mientras sube.
- **Bajar:** por el vano del pasillo aparece en el descanso y baja escalón por escalón (cuadros de saltar y caer).
- **Atajo (R6):** desde adentro, "Abrir": un manotazo al pestillo la abre para siempre ("El pestillo, por dentro. Aficionada.", logro "Atajo de Gato"), a 348 px de la caja de arena.

## 5. Cómo se anuncia cada interacción (sin carteles)

- Se quitaron los avisos de texto y la fila de controles de abajo (M2).
- **Indicador:** contorno claro de 1 px en el objeto y burbuja sobre Felipe con el ícono del botón en uso (Kenney) y el verbo: Pasar, Probar (puerta cerrada), Ascender, Degustar, Liberar, Firmar, Actuar, Encantar, Abrir, Empujar, Arañar, Saquear.
- **Primeras frases de Felipe** (`Sala.LECCIONES`, una sola vez por zona, 48 caracteres o menos sin el botón): "{saltar} Los muebles son mi escalera." · "{interactuar} Ese sofá tiene plástico. Por ahora." · "{interactuar} Un rascador. Necesito público." · "{interactuar} Ese vaso está muy cerca del borde. Aún." · "Mantén {agacharse}. Es estrategia, no humildad." · "Mi trono. Aquí vuelvo si algo sale mal." · "{maullar} Servidumbre: abran." · "{saltar} El librero es mi escalera." · "{interactuar} Escalones. Mi única pasión." · "{interactuar} Comida a la vista. Me sacrifico." · "{zarpazo} Un ratón de cuerda. Qué insolencia." · "{interactuar} Puerta entornada. Qué invitación." · "{saltar} Banquito, cama, cómoda. Escalera real." · "{interactuar} El cajón de los calcetines. Botín." · "{saltar} La maceta, la baranda… y la libertad."
- **Señales del escenario:** luz cálida que sale de las puertas abiertas y tapete; rendija de luz y sombra que se mueve bajo la puerta cerrada de la cocina; etiqueta "NUEVO" en sofá y rascador; corazón roto sobre Valeria enojada.

## 6. La pelea con A.S.P.I. ("La Bestia del Estudio")

### Entrada en 8 pasos (4,8 s, `PresentacionJefe`)
La presentación **empieza cuando terminó el fundido de la puerta** (B1); el fundido y su tween siguen en pausa. Los pasos son datos de `PresentacionJefe.PASOS`; A.S.P.I. solo da su nombre, título, rugido y efectos.

| s | Paso | Qué pasa |
| --- | --- | --- |
| 0,0–0,4 | 1. Sin vuelta atrás | La puerta se cierra sola con un portazo y polvo. Felipe: "…¿Quién cerró?" |
| 0,4–1,2 | 2. La espera | Penumbra; la luz de A.S.P.I. pasa a roja; retumbo que crece; las pelusas del piso tiemblan |
| 1,2–2,2 | 3. Revelar despacio | Golpe de cámara a Felipe con «¡BATALLA INICIADA!»; la cámara sube de las ruedas al sensor mientras crece la imaginación (estudio en llamas y la bestia gigante al fondo, sin colisión) |
| 2,2–2,8 | 4. Nombre y título | Franja: **A.S.P.I.**, "Devoradora de Pelos · Nivel 99" |
| 2,8–3,4 | 5. La barra se llena | Barra de vida que se llena |
| 3,0 | 6. Música | Entra el tema de la pelea (provisional) |
| 3,4–4,0 | 7. Vender el tamaño | Cámara baja; dos empujones que sacuden la pantalla |
| 4,0–4,8 | 8. El rugido | "DETECTANDO SUCIEDAD. DETECTANDO… GATO.", ola de polvo y papeles que vuelan; la imaginación se desvanece y vuelve el control |

Al volver después de perder una vida (reaparece en el cojín), la entrada corta dura 1 s (portazo y nombre) y la pelea **conserva la fase**.

### Reglas, fases y ataques (no se gana sentado, G12)
- **Ensuciar:** lo que se rompe en el piso deja una mancha (vaso y rollo del escritorio, 2 macetas de la repisa, papeles del teclado). A.S.P.I. va a limpiarla: **anticipación** (el cepillo gira 0,6 s), aspira (de pie arrastra; agachado se aferra; en la fase 3 alcanza 260 px) y suma "+1" y "Glup.". Lo roto vuelve **de a uno cada 6 s**.
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
| Sala | 0–1280 | 1280 | nido 40 · ventana 170–350 · sofá 240–480 (asiento 49, respaldo 102) · rascador 520–620 (69/114/165) · silla 680 (55) · mesa 745–923 (91, vaso en 905) · silla 929 (55) · retrato · puerta 1188 |
| Recibidor | 1440–2640 | 1200 | puerta 1532 · zapatero 1626–1786 (97; 40 libres debajo; llaves) · caja de arena 1832–1936 (45) · lámpara 1942 · puerta de la cocina 2070 · librero 2162–2266 (48/103/155/218) · reja 2284–2296 (182) · escalera 2322–2548 y vano en el descanso (150) |
| Cocina | 2800–3760 | 960 | puerta 2892 · tazón 3010 · Valeria 3080 · ratón 3200–3290 · caja de cartón 3360 · silla 3400 (55) · mesón 3464–3668 (108, pollo 3510, ratón) · microondas 3570 (162) · refrigerador 3674–3758 (216, calcetín 2) |
| Pasillo | 4000–5040 | 1040 | vano de la escalera 4092 · baúl 4190 (54) · consola 4256–4412 (97, vaso; 47 libres) · alféizar 4264–4436 (150) · puerta del dormitorio 4536 · láser 4640–4780 · cojín 4784–4854 · puerta del estudio 4948 |
| Dormitorio | 5200–5920 | 720 | puerta 5292 · banquito 5386 (53) · cama 5444–5644 (65) · cómoda 5650–5734 (96, cajón) · repisa 5740–5810 (145) · cortina y cesta 5745–5807 (cesta 35) · repisa alta 5735–5815 (290, lugar visto) · ropero 5816–5920 (185) |
| Estudio | 6240–6880 | 640 | puerta 6332 · silla 6424 (55) · escritorio 6488–6648 (98; vaso, teclado, pantalla, rollo) · impresora bajo el escritorio · repisa 6636–6696 (151, 2 macetas) · base de carga 6600–6674 · puerta del balcón 6788 |
| Balcón | 7040–7680 | 640 | puerta 7132 · maceta grande 7330 (32) · baranda 7400–7584 (89) · ciudad |

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
| R8 | ✔ Huecos bajo muebles sólidos de 0 o de 36 px o más (zapatero 40, consola 47); lado **menor** ≥ 24 px de todo lo interactuable (comida y recompensas incluidas); puertas medidas en la imagen (vano de 112 y 120 px); ratón a la mitad de Felipe |
| R9 | ✔ Pared distinta por cuarto. 👁 Hito por cuarto: retrato oficial, reja "PIPE: NO", refrigerador con imanes, retrato familiar, cama y cortina, base de carga roja, la ciudad |
| R10 | ✔ 3 calcetines sobre algo pisable; el del refrigerador pide subir |
| R11 | ✔ La única zona fuerte es el estudio; cierra con el balcón |
| R12 | ✔ 5 cosas para tirar en el estudio y una en alto (repisa). Ver sección 6 |
| R13 | ✔ Todos los cuartos menos el balcón tienen con qué jugar. 👁 Su chiste (sección 2) |
| R14 | 👁 El primer plano quedó solo en el balcón; el pasamanos baja a 70 % mientras Felipe sube; diálogo y carteles no tapan a Felipe. ✔ Rectángulo sagrado: ningún mueble, decorado, ratón, descanso ni lugar de Valeria se cruza con una puerta o la escalera (B3, G10) |
| R15 | ✔ `prueba_movimiento` (altura de Felipe); la animación nueva de esta parte (ninguna) no aplica |
| R16 | ✔ `prueba_jefe`: entrada de 8 pasos en menos de 5 s, sin negro al entrar por la puerta, imaginación solo en la entrada, cartel y pista por fase, todo vuelve de golpe al ganar, y la misma presentación sirve para otro jefe |
| R17 | ✔ Dos lugares vistos que no se alcanzan todavía (toldo del vecino: Caer de Pie; caja de recuerdos: Afilar Garras); atajo de la reja. 👁 La historia la cuenta el escenario: reja anti-fuga con cartel, retratos, carpeta de fotos |
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
- **La tanda `arriba-extra.png` de Gemini no llegó:** baúl, retrato familiar, caja de recuerdos, pantalla, teclado, impresora, ropa doblada, calcetines del cajón y papeles se dibujan por código; consola = aparador y cómoda = la de siempre.
- **El caminar de Valeria de Gemini** se usa (alineado por pies y cabeza en la herramienta); no hizo falta el balanceo de código.
