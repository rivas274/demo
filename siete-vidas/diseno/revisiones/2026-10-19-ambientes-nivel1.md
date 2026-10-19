# Revisión de ambientes, nivel 1 "La Gran Fuga" (2026-10-19)

Revisor: artista de entornos (Claude). Insumos: la hoja `capturas/2026-10-19-ambientes-cuartos.png` (commit actual), recapturas a 640×360 y ×2 de los 12 puntos (`pruebas/capturas_nivel.gd`), la crítica de Gemini `2026-10-19-ambientes-gemini.md` (cada punto contrastado con la imagen), las revisiones 1 a 3, la crítica de arte ya aplicada (`nivel-01-gran-fuga.md` §13 y §14), `pilares.md`, `reglas-de-niveles.md`, la tabla de capas (memoria 03) y el código de `fondo_apartamento.gd`, `sala.gd` y `preparar_arte_nivel.py`. Lo ya arreglado (ventanas a 109 px, retratos bajo el HUD, taza en vez del rollo, ropa hundida en el edredón, vano cuadrado, sombras de contacto por primera vez, vaso y macetas retocados) no se repite.

Capturas que respaldan el plan:
- `capturas/2026-10-19-amb-puertas-anchos.png`: cuatro anchos de marco (140, 128, 106 y 122 px) y un vano de 150 px (1,24 m), por donde Valeria no cabe.
- `capturas/2026-10-19-amb-ventanas-tres-estilos.png`: las cinco ventanas a la misma altura, pero con tres marcos distintos (arte con persiana, arte crema y marco de código sin vidrio).
- `capturas/2026-10-19-amb-cocina-balcon.png`: el pollo se cruza con las alacenas, el azulejo va del piso al techo, y la puerta del balcón queda sin fachada y con parquet afuera.
- `capturas/2026-10-19-amb-pasillo-sin-sitio-bano.png`: entre la puerta del dormitorio y el cojín quedan 156 px libres; la puerta del baño necesita 184.

---

## 1. Veredicto

**Mejoró en orden y escala: cada pieza está bien hecha y bien medida. Pero la casa todavía no existe como lugar: son siete escenografías armadas con piezas de tandas distintas, con luz plana, y todo lo que hay en ellas es jugable.**
**Nada está mal por sí solo. Lo que delata a la IA es la suma: cada ventana y cada puerta sigue su propia regla, y no hay ni un objeto que esté ahí solo porque alguien vive en la casa.**
**Se arregla en una pasada, casi todo con código y arte que ya tenemos (0 créditos de SpriteCook), más una hoja de Gemini de 12 piezas para la vida de los cuartos.**

### Las 3 causas de fondo

1. **La casa no tiene un sistema arquitectónico.** Hay tres estilos de ventana: arte con persiana, arte de marco crema y marco de código sin vidrio. Las puertas tienen cuatro anchos de marco (la "entornada" se ve como una abierta más angosta) y el vano de la escalera mide 1,24 m. El zócalo y la cornisa son una franja plana de 14 px. El mismo parquet de 256 px se repite, con la costura a la vista, en la sala, la cocina y hasta en el balcón, y la puerta del balcón flota delante de la ciudad sin muro alrededor. *Por qué delata a la IA:* un desarrollador dibuja una ventana y una puerta y las reusa; aquí cada una viene de un encargo distinto.
2. **La luz no tiene dirección ni caída.** Las sombras de contacto (22 % y 3 px) no se ven en la captura ×4. Los cuadros, el reloj y las repisas no proyectan sombra. Nada oscurece bajo la cornisa. Solo 3 de 5 ventanas echan luz, en un polígono liso. Por eso los muebles parecen pegatinas sobre la pared. Además, el azulejo de la cocina va del piso al techo, compite con todo y empeora la lectura (R14).
3. **Cada cuarto es una fila de muebles con función de juego, sin vida alrededor.** No hay ni un objeto que solo cuente quién vive ahí: falta la taza olvidada, el cable del cargador, las zapatillas tiradas, los pelos de Felipe, los arañazos viejos, las fotos en la nevera, el corcho de Valeria. Tampoco hay movimiento ambiental en 5 de 7 cuartos. Hay repetición de catálogo (seis zapatillas naranjas iguales en el zapatero) y simetría de exposición (el retrato centrado sobre la mesa, centrada entre dos sillas espejadas).

### Cruce con Gemini (qué era cierto)

- **Cierto y entra al plan:** la falta de desgaste y de micro-historias, la simetría del comedor, que zócalos, ventanas y puertas son incoherentes, el trapo y los utensilios de cocina, los zapatos desordenados, las plantas agrupadas y el saco de tierra del balcón, y las marcas de garras.
- **Falso, verificado en la imagen:** el "pavo asado" es el pollo, que se queda porque es la travesura "almuerzo". Ningún gato rasca una silla. La vista 8 tiene el retrato familiar y la 11 no tiene cuadro. La "cama de gato" de la vista 3 es la caja de arena y la de la vista 10 es la cesta de ropa. "Consola y aparador" son la misma pieza. En el pasillo no hay "lámpara de pie ni planta" (la lámpara está en el recibidor). La "mesa de dibujo" es el escritorio. El "recipiente de agua de repuesto" es el vaso, que se tira en la pelea. El gato del balcón no está sobre la baranda.
- **Cierto, pero no se hace:** agrupar las dos sillas de un lado de la mesa (son el escalón medido hacia el vaso), poner un bol de agua junto al tazón (la puerta de la cocina y el lugar de Valeria no dejan sitio; se resuelve con croquetas regadas), poner colillas o latas (no es Valeria), y "mover el escritorio al centro" (es el examen de la pelea, R12).

---

## 2. Plan de corrección

**Cómo usar este plan:** un solo agente lo aplica de arriba abajo. Los pasos van en este orden para no rehacer trabajo. Cada fila dice si se hace con **código**, con **arte existente** (hojas de `arte/referencias/gemini/` que ya están en el repositorio) o si **espera a Gemini** (tanda 3E, sección 3). Lo que espera a Gemini deja su **lugar reservado en los datos** desde la primera pasada (la pieza sin imagen no se dibuja: `ArteNivel.textura` devuelve null). Así, cuando llegue el arte, basta con correr `preparar_arte_nivel.py`. Prioridad: **P1** = la casa es incoherente o hay algo que se cruza; **P2** = vida, luz y profundidad; **P3** = pulido.

### Orden de la pasada

| Paso | Qué | Por qué en este orden |
| --- | --- | --- |
| 0 | Ensanchar el pasillo 200 px (P-1) y correr las 8 pruebas | Corre las coordenadas de todo lo que viene después; si va al final, se reubica dos veces |
| 1 | `preparar_arte_nivel.py`: puertas, vano, ventana del pasillo, moldura, alacenas, escalera, zapatero, cortinas y arañazos (arte existente) | Todo lo que sigue dibuja estas imágenes |
| 2 | `fondo_apartamento.gd`: ventanas estándar, pared de la cocina, zócalo, cornisa, penumbra, piso y rayos de luz | Es la capa de atrás; las sombras y la decoración se calibran contra ella |
| 3 | `sala.gd`: posiciones (cuadros, paisaje, baño), sombras, desgaste, decoración y movimiento | Datos del nivel |
| 4 | El baño: interacción, frases y goteo | Necesita el pasillo ensanchado y la puerta unificada |
| 5 | Pruebas, capturas ×2 de los 12 puntos (más una 13 para el baño), hoja de antes y después, y documentos | Cierre |
| 6 | Cuando llegue la tanda 3E: sumar las piezas a `PIEZAS` y correr la herramienta | Los lugares ya están reservados |

### 2.0 Cambios globales (se hacen una vez y valen en toda la casa)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| G1 | **Un solo marco de puerta: 140 × 248 en todos los estados.** La cerrada (128) y la del balcón (122) se llevan a 140 repitiendo columnas de su propio marco, sin escalar. La entornada (106) se rearma con el marco de la abierta y la hoja de la cerrada corrida, dejando una franja oscura de 12 px del lado de la manilla y 2 px de sombra, para que se lea "entornada" y no "abierta y angosta". | Hoy hay 4 anchos de marco y la entornada no se distingue de la abierta | código (herramienta, arte existente) | `puerta_cerrada_v2`, `puerta_entornada`, `puerta_balcon_v2/_abierta` en `preparar_arte_nivel.py` | P1 |
| G2 | **El vano de la escalera a 140 × 248**, la altura de una puerta, a los dos lados: `vano_cuadrado()` deja de cortar `puerta_abierta_v2` a 150. En el recibidor cabe: el descanso está a 150 px y el techo a 424. `ESCALERA_RECT` sube hasta `SUELO − 398`. En el pasillo, dentro del hueco oscuro, se dibujan el remate del pasamanos y los dos primeros peldaños bajando (`escalera_baranda` recortada, 60 % de valor). | Un vano de 1,24 m en una casa con techo de 3,5 m se lee como una chimenea, y Valeria no cabe | código (arte existente) | `vano.png`, `Sala.ARTE["vano"]`, `ESCALERA_RECT` | P1 |
| G3 | **Una sola ventana de la casa.** Las ventanas de código (cocina, dormitorio y estudio) usan el marco de `ventana_sala` en 9 partes: esquinas y cantos del arte, con los lados estirados repitiendo una columna. Llevan parante en cruz de 4 px en dos tonos con bisel, **vidrio** (tinte 8 % y dos reflejos diagonales de pixel, como la puerta del balcón) y el alféizar actual. La de la sala sigue tal cual. La del pasillo pasa a ese marco (P-3). | Hoy hay tres estilos, y las de código no tienen vidrio: se ve la ciudad por un agujero | código (arte existente) | `FondoApartamento._dibujar_ventana`; recorte del marco en la herramienta (`ventana_marco.png`) | P1 |
| G4 | **Zócalo y cornisa de verdad.** El zócalo mide 18 px: canto claro de 2 px (`c98a5e`), cuerpo de madera, filete oscuro de 1 px y una sombra de 2 px sobre el piso. La cornisa lleva dos tonos con una fila de dentículos cada 6 px. Debajo de la cornisa van **3 franjas de penumbra** (6 px cada una, al 12/8/4 %). Todo es igual en los 6 cuartos interiores; las puertas lo cortan porque se dibujan encima. | La franja plana de 14 px y el techo sin caída de luz son lo más "plantilla" de la casa | código | `moldura.png` (herramienta) y `FondoApartamento._crear_pared` | P1 |
| G5 | **Sombras con peso.** Las de contacto pasan al 45 % (franja de 3 px) y al 28 % (2 px abajo), con el ancho de la base opaca real (las 3 filas de abajo del arte). Bajo cada pata va un bloque de 2 × 2 más oscuro. Los objetos de pared (cuadros, reloj, repisas, alacenas, corcho y caja de recuerdos) proyectan una sombra de 2 px hacia abajo y 1 px del lado contrario a la ventana, al 20 %. | En la captura ×4 las sombras de hoy no se ven; los objetos flotan | código | `Sala._dibujar_sombras_de_contacto` (+ `SOMBRA_PARED` nueva) | P1 |
| G6 | **Luz con dirección, una por cuarto.** Las 5 ventanas echan su rayo (hoy faltan la sala y el pasillo), siempre hacia la derecha: el sol de la tarde entra por el lado oeste de la casa, una sola orientación coherente. El rayo va en **3 franjas escalonadas** (no un polígono liso), con el tono de cada cuarto: ámbar en la sala, crema en la cocina, gris azulado en el pasillo, rosado en el dormitorio y dorado en el estudio. Dentro de cada rayo flotan **5 motas de polvo** de 1 px que suben despacio. | La luz plana no da profundidad; las motas son el movimiento mínimo de cada cuarto | código | `FondoApartamento._dibujar_luz` (capa `LUZ` 5, ya aprobada encima de Felipe) | P2 |
| G7 | **Piso sin costura ni repetición.** Se arregla la columna de costura de `piso.png` (cada 256 px se ve una línea clara). Cada baldosa se dibuja volteada de forma alterna y con un corrimiento distinto por cuarto. La cocina y el balcón cambian de piso (C-4 y B-2). | La repetición exacta y la costura delatan la plantilla | código (herramienta y fondo) | `piso.png`, `FondoApartamento._dibujar_pared` | P2 |
| G8 | **Cuadros a una sola línea.** Todo cuadro tiene el borde de arriba en el dintel de las puertas (`SUELO − 248`) o cuelga de un clavo con hilo de 1 px en dos tonos. Ninguno queda centrado sobre el mueble que tiene debajo. | Hoy los retratos están 54 px más arriba que puertas y ventanas, casi en el HUD, y el de la sala está en el eje exacto de la mesa | código | `Sala.ARTE`: `retrato`, `retrato_familiar`, `reloj`, `paisaje` | P1 |
| G9 | **Desgaste por código, en pixel y con la paleta de Felipe** (gris `7a7470` y crema `e8dccb`, nunca blanco). Van **mechones de pelo** de 3 a 5 px: 6 en el sofá, 5 en el edredón, 4 en el cojín y 3 en cada alfombra. Van **arañazos viejos** con las marcas sueltas de la tanda 3C (sin usar) al 70 %: en el marco de la puerta entornada del dormitorio, en la esquina baja del ropero, en una pata de la mesa del comedor y en el poste de arranque de la escalera, todos a 20–45 px de altura (la altura de Felipe). Va **polvo en lo alto**: una línea de 1 px gris cálido sobre el ropero, el refrigerador, el librero y las alacenas, más una pelusa. | Es la "capa de amor" que pide el creador. Las marcas ya son arte de Gemini: tienen el mismo estilo | código + arte existente (`sala-extra.png`: arañazos) | `Sala._dibujar_desgaste` (nueva, capas `MUEBLES`/`MARCAS`), `PIEZAS["aranazo_1..3"]` | P2 |
| G10 | **Algo se mueve en cada cuarto.** Sala: las motas sobre el sofá y la luz del portátil que late. Recibidor: la rendija (ya está) y la lámpara que parpadea una vez cada 9 s. Cocina: el segundero del reloj (C-8) y el goteo de la llave (C-5). Pasillo: el vapor de la pizza (ya está) y la luz del baño que titila (P-2). Dormitorio: la cortina con brisa (D-4). Estudio: el monitor (ya está). Balcón: las plantas de la baranda que se mecen (B-4). | Lista de revisión: "algo que se mueve en cada cuarto" | código | `Sala._physics_process` (los temporizadores que ya existen) | P2 |
| G11 | **Regla de islas para toda la decoración nueva.** Por cuarto va un foco, una isla secundaria y espacio negativo donde se juega. La decoración nueva va pegada a un mueble (isla), nunca sola en medio de la pared. Ningún decorado nuevo entra en un rectángulo sagrado ni tapa algo jugable. Lo que parece pisable, se pisa (con colisión medida); si no, mide menos de 24 px de alto y va pegado a la pared. | Evita que la vida nueva se vuelva otro catálogo y protege R8/R14 | criterio (lo comprueba `prueba_reglas_nivel`, sagrados y R8) | todas las filas siguientes | P1 |

### 2.1 Sala (foco: Valeria en el sofá bajo el rayo de la ventana)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| S-1 | **Galería asimétrica:** el retrato oficial se corre a x ≈ 700 (sobre la silla izquierda y la punta de la mesa), con el borde de arriba en el dintel. A su derecha van dos marcos chicos a distinta altura (foto de Felipe panza arriba y la huella de Felipe en yeso) | Rompe el eje retrato–mesa–sillas; cuenta "ama a Felipe" | código ya; los marcos chicos esperan a **Gemini 4** | `Sala.ARTE["retrato"]`, `marco_foto`, `marco_huella` | P2 |
| S-2 | **Rincón de Valeria:** una mesita lateral pisable de 45 cm (55 px), pegada al brazo izquierdo del sofá (x 190–236), con lámpara de mesa apagada, una taza olvidada con otro dibujo que la del estudio (para no confundir con un tirable) y el cargador enredado | Isla secundaria; "teletrabaja y vive en el sofá". Si parece mueble, se pisa: colisión medida de su fila opaca (±2 px) | **Gemini 3** (lugar y colisión reservados) | `mesita_sala`, `Sala.COLISIONES` | P2 |
| S-3 | **Alfombra** de lado, terracota con flecos, de 300 px, bajo el sofá y hasta el rascador, con pelos (G9) | Ancla la isla y quita el "mueble pegado al parquet" | **Gemini 1** | `alfombra_sala` (capa pared, después del piso y antes de las sombras) | P2 |
| S-4 | **Cable del portátil:** cable de 1 px en dos tonos del sofá al enchufe del zócalo (enchufe de 6 × 8 px en el zócalo) | Cuenta en un detalle que Valeria teletrabaja | código | `Sala._dibujar_desgaste` | P3 |

### 2.2 Recibidor (foco: la reja "PIPE: NO" y la escalera)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| R-1 | **Perchero de pared** sobre el zapatero (x 1650–1720, de 140 a 250 px): la chaqueta verde azulado de Valeria, la bufanda, el bolso y el paraguas colgado | Un recibidor sin abrigos no es entrada de casa. Va sobre el zapatero: no tapa el paso agachado | **Gemini 5** | `perchero` (capa pared) | P2 |
| R-2 | **Zapatillas de Valeria tiradas**, una volteada, en el hueco zapatero–caja de arena (1790–1824), de menos de 16 px de alto | Desorden con intención; sin colisión, bajas, no parecen escalón | **Gemini 6** | `zapatillas` (capa mueble) | P2 |
| R-3 | **El video viral enmarcado** sobre la caja de arena: un teléfono con Felipe en el rascador y corazones, sin letras, con el borde arriba en el dintel | Es el origen de la reja (R17) y "sube todo a redes" | **Gemini 7** | `marco_viral` | P2 |
| R-4 | **Peldaños de madera apagada**, no gris piedra: tinte hacia `8a6a55` al 60 % de valor (siguen detrás de Felipe y contrastan con él) | Toda la casa es de madera; el gris parece otra casa | código (herramienta) | `escalera_peldanos` | P2 |
| R-5 | **El zapatero sin clones:** 2 de los 6 pares se recolorean (verde azulado y crema) y 1 se voltea | Seis zapatillas idénticas son una firma de IA | código (herramienta) | `zapatero.png` | P3 |
| R-6 | **El zócalo sigue a la escalera** en escalones de pixel bajo el larguero, hasta el faldón | En una casa real, el zócalo sube con la escalera | código | `Sala._dibujar_descanso` / zócalo G4 | P3 |

### 2.3 Cocina (foco: el pollo sobre el microondas y el refrigerador)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| C-1 | **Azulejo solo hasta 1,5 m** (182 px) con un listel de remate de 4 px. Arriba, pintura lisa crema cálida (el mosaico `pared_rosa` reteñido). El azulejo baja un 15 % de contraste. La cocina sigue con un estilo de pared propio (R9) | El damero del piso al techo es el fondo más ruidoso de la casa y compite con el reloj, la ventana y los ratones (R14) | código | `FondoApartamento._crear_pared` (estilo "azulejo" en dos tramos) | P1 |
| C-2 | **Alacenas recortadas** al lado más 2 módulos (≤ 111 px, de 3461 a 3572) sobre la mitad izquierda del mesón. Sobre el microondas no queda nada | Hoy el pollo (3580–3644, arriba en `SUELO − 213`) se cruza 31 px con las alacenas; además rompe la fila simétrica | código (herramienta) | `alacenas.png` (recorte) | P1 |
| C-3 | **La cenefa ondulada pasa a visillo:** cortina corta de `detalles.png`, recoloreada crema con franja terracota, colgada de la barra estándar y tapando el tercio de abajo del vidrio | La cenefa de círculos parece un toldo de calle, y la ventana del pasillo ya tiene un toldo de verdad afuera | arte existente + código | `detalles.png` → `visillo_cocina` | P2 |
| C-4 | **Piso de baldosa de terracota** solo en la cocina | Las cocinas del Barrio Viejo no tienen parquet; da identidad (R9) | **Gemini 2** (hasta que llegue, el parquet) | `piso_cocina` | P2 |
| C-5 | **Llave del lavaplatos** en la pared, sobre el borde izquierdo del mesón (3466–3490, fuera de la patrulla del ratón 3500–3536), con una gota cada 3 s y su "plic". Un **trapo** cuelga del tirador del cajón del mesón | Hoy es una cocina sin agua ni uso. El goteo anticipa el del baño | **Gemini 8**; gota y sonido por código (`sonidos_demo.py`: `goteo.wav`) | `llave_agua`, `trapo` | P2 |
| C-6 | **Refrigerador con historia:** 3 polaroids de Felipe (dormido, en una caja, de reojo) entre los imanes de hoy, sin repetir ninguno | R17: "fotos de Felipe en la nevera" | **Gemini 9** | `polaroid_1..3` (capa mueble, junto a los imanes) | P2 |
| C-7 | **Croquetas regadas** (5 de 2 px) junto al tazón y la lata de atún abierta, recortada de `comida-grande.png` (sin usar), al otro lado | Un gato que come aquí todos los días deja rastro | código + arte existente | `lata.png` (herramienta), `Sala._dibujar_desgaste` | P3 |
| C-8 | **Segundero del reloj** que avanza (1 px, cada segundo) | Movimiento del cuarto | código | `reloj` | P3 |

### 2.4 Pasillo de arriba (foco: el retrato familiar sobre el trono, y la puerta del baño como intriga)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| P-1 | **Ensanchar el pasillo 200 px** (4000–5240): **toda x ≥ 4630** del mundo suma 200 (láser, cojín, puerta del estudio, dormitorio, estudio, balcón y `ANCHO` 7680 → 7880). Es un script de una pasada sobre los literales: 71 en `sala.gd`, 20 en `partida.gd`, 6 en `prueba_nivel.gd`, 5 en `capturas_nivel.gd`, 3 en `fondo_apartamento.gd` (contando la planta de 9760), 2 en `prueba_mecanicas.gd`, 1 en `prueba_acciones.gd` y 1 en `valeria.gd`. Hay que revisar a mano cualquier número de 4600 a 4630 | Entre el rectángulo sagrado del dormitorio (hasta 4628) y el cojín (4784) quedan 156 px, y una puerta necesita 184 (B3). El cojín no se mueve porque es el descanso junto al jefe (R5). Ver `capturas/2026-10-19-amb-pasillo-sin-sitio-bano.png` | código | `sala.gd` y pruebas | P1 |
| P-2 | **Puerta del baño** (detalle en 2.4.1), al centro en x = 4740 (marco de 4670 a 4810 y rectángulo sagrado de 4648 a 4832) | Decisión del creador: lugar que se insinúa | código (arte existente: la cerrada de G1) | `Sala.BANO` (nuevo), no va en `PUERTAS` | P1 |
| P-3 | **La ventana del pasillo al marco estándar:** la madera crema (marco, panel y alféizar del arte, más `VENTANA_PASILLO_ARRIBA`) se recolorea a los tonos de G3. No se mueven `VIDRIO_PASILLO`, `PIZZA` ni la colisión del alféizar | Es la única ventana de marco claro; parece un cuadro o un mueble | código (herramienta + `_dibujar_ventana_pasillo`) | `ventana_pasillo.png` | P1 |
| P-4 | **El retrato familiar a x ≈ 4900** (de 4900 a 5000, ya corrido), con el borde arriba en el dintel, sobre el láser y el cojín: el trono con su retrato | Hoy quedaría sobre la puerta del baño; además baja de la barra del HUD (G8) | código | `Sala.ARTE["retrato_familiar"]` | P1 |
| P-5 | **Alfombra de pasillo** larga, del baúl a la puerta del baño, en tonos apagados. Termina antes del láser, para que el punto rojo se lea sobre la madera | Ancla el pasillo y le da profundidad | **Gemini 1** | `alfombra_pasillo` | P2 |
| P-6 | **Arañazos viejos** en el marco de la puerta entornada del dormitorio, a la altura de Felipe | Anuncia sin texto que esa puerta se araña (R19) | arte existente (G9) | `aranazo_2` | P2 |

#### 2.4.1 La puerta del baño (decisión del creador, con su ajuste)

- **Qué es:** la misma puerta **cerrada** de G1 (marco de 140, manilla de palanca dorada), en la capa `PUERTAS`. **No** es habitación ni va en `PUERTAS` ni en `HABITACIONES`: así R7 ("desde el inicio se llega a todas") y los pares de puertas siguen valiendo. Su rectángulo sagrado se suma a la lista que comprueba `prueba_reglas_nivel` (nada se le cruza: alfombra, retrato, láser y cojín quedan fuera).
- **Luz bajo la puerta:** la rendija de la cerrada, pero **fría** (`dfe8e2`, nunca blanca), con un titileo de tubo cada 5 a 8 s. Es distinta de la rendija cálida de la cocina: es otro tipo de cuarto. Sin sombra que se mueva: no hay nadie adentro.
- **Goteo:** un "plic" cada 2,6 s que solo se oye a 300 px o menos (`goteo.wav`, el mismo de la cocina con otro tono). **No** se pone charco en el piso, porque A.S.P.I. y el jugador lo leerían como mancha (R14).
- **La frase:** al acercarse por primera vez (a 90 px), o al usar **"Probar"** (el verbo de puerta cerrada que ya existe; la hoja tiembla 1 px y no cede), Felipe dice **"El trono de porcelana. Algún día será mío."** (42 caracteres, una vez, R3).
- **La pista sin explicar (ajuste del creador):** la puerta **no** se abre con doble salto. Felipe podría abrirla, pero no lo sabe. Más adelante verá a otro gato colgarse de una manilla, y ahí se desbloquea la acción "Abrir puertas". Aquí solo se insinúa: si Felipe se queda quieto 2 s a 60 px o menos después de la primera frase, la **manilla de palanca da un destello de 1 px** (0,2 s), Felipe gira la cabeza de reojo (su expresión por defecto; no hace falta animación nueva) y dice **"Esa manija me mira raro."** (24 caracteres, una vez). No hay verbo, rótulo ni cartel que explique la maña.
- **Reglas:** R6 no cambia (el atajo sigue siendo la reja). R7 se cumple (el baño no es un cuarto de este nivel). R17: **no** se registra en `LUGARES_VISTOS`, porque está a ras de piso y es un lugar oído, no visto; se documenta en `nivel-01-gran-fuga.md` §2.4 como "lugar insinuado" para la maña "Abrir puertas". R14: no tapa nada (la alfombra termina antes y el retrato está a 90 px). R1: las frases del baño quedan a 204 px de la de la puerta entornada.
- **Memoria (al aplicar):** la decisión del baño y la maña futura "Abrir puertas" (se aprende viendo a otro gato colgarse de una manilla) van en `01-decisiones.md` y `04-pendientes.md`. **No** entra en la tabla "Acciones de Felipe" ni en la ficha hasta que exista en el juego (ahí solo va lo que está en uso).

### 2.5 Dormitorio (foco: la cama bajo la ventana con cortina)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| D-1 | **El paisaje apoyado en la repisa:** la base va en la fila opaca de arriba de la repisa (hoy flota 10 px encima), con una sombra de 2 px | Apoyo y peso. Va en la capa de pared, detrás de Felipe cuando él se para en la repisa | código | `Sala.ARTE["paisaje"]` | P1 |
| D-2 | **Alfombra a los pies de la cama** (corta, rosa viejo, con pelos) | Isla de la cama; rompe el parquet | **Gemini 1** | `alfombra_dormitorio` | P2 |
| D-3 | **Libro abierto boca abajo** en la parte de atrás del banquito (menos de 8 px de alto, no estorba el escalón) | "Libro a medio leer": micro-historia sin texto | arte existente (`objetos.png`: libro, recortado y achatado) | `libro` | P3 |
| D-4 | **La cortina con brisa:** el ruedo de cada paño se corre 1 px de forma alterna cada 0,5 s, con fase distinta en cada paño | Movimiento del cuarto | código | `Sala._dibujar_cortina` | P2 |

### 2.6 Estudio (foco: el escritorio con el monitor; no se mueve nada de la pelea)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| E-1 | **Los paños verdes de código pasan a las cortinas cortas de `detalles.png`**, recoloreadas oliva (`TELA_ESTUDIO`), en la barra estándar | Son lo último dibujado "plano" junto al arte de Gemini | arte existente + código | `detalles.png` → `panos_estudio` | P2 |
| E-2 | **Corcho de Valeria** sobre la repisa de macetas (6626–6694, de 200 a 255 px): polaroids de Felipe, post-its sin letras y un hilo rojo | "Sube todo a redes": es su tablero de contenido. Queda fuera del rectángulo de la puerta del balcón | **Gemini 10** | `corcho` (capa pared, sombra G5) | P2 |
| E-3 | **Enchufe en el zócalo y cable** de la base de carga, más una regleta bajo el escritorio con 3 cables (1 px, dos tonos) | Prepara sin texto la travesura "Desenchufar" | código | `Sala._dibujar_desgaste` | P2 |
| E-4 | **3 post-its** (4 × 4 px, dos tonos, amarillo y rosado) en el borde del monitor | Detalle de quien trabaja aquí | código | dibujo del monitor | P3 |

### 2.7 Balcón (foco: la ciudad y la baranda; alivio)

| # | Cambio | Por qué | Cómo | Archivo o pieza | Prio |
| --- | --- | --- | --- | --- | --- |
| B-1 | **El tramo de fachada del edificio de Valeria** alrededor de la puerta-ventana (7040–7230, del piso al borde de arriba): estuco terracota con cornisa, un farol de pared y la losa del balcón asomando | Hoy la puerta flota delante de la ciudad: la casa no existe por fuera | **Gemini 11**; mientras tanto, código con el ladrillo de M5 | `fachada_balcon` (capa `FACHADA` −19) | P1 |
| B-2 | **Losa de terraza** en vez de parquet | Parquet al aire libre es un error de casa | **Gemini 2**; mientras tanto, código (`piso.png` reteñido gris cálido piedra) | `piso_balcon` | P1 |
| B-3 | **Isla de jardinería** junto a la maceta grande (7240–7320, fuera del rectángulo de la puerta): regadera de lata, saco de tierra medio vacío y la maceta rota de `detalles.png` | Cuenta que Valeria cuida plantas (y que alguien rompió una) | **Gemini 12** + arte existente | `regadera`, `saco_tierra`, `maceta_rota` | P2 |
| B-4 | **Plantas de la baranda que se mecen** (1 px, desfasadas) | Movimiento del alivio final | código | baranda | P3 |

**Cuenta:** 11 cambios globales, más 4 en la sala, 6 en el recibidor, 8 en la cocina, 6 en el pasillo (incluida la puerta del baño), 4 en el dormitorio, 4 en el estudio y 4 en el balcón: **47 cambios**. **32 se hacen ya**, con código o arte existente; **15 esperan a Gemini** (con lugar reservado: S-1 en parte, S-2, S-3, R-1, R-2, R-3, C-4, C-5, C-6, P-5, D-2, E-2, B-1, B-2 y B-3 en parte; B-1 y B-2 llevan un reemplazo de código mientras tanto). **SpriteCook: 0 créditos.** Ninguna pieza es de Felipe ni es animación.

---

## 3. Encargo a Gemini: tanda 3E, una sola hoja de 12 piezas ("vida de la casa")

Va en `encargo-gemini-tanda-3e.md` al aplicar. Se guarda en `arte/referencias/gemini/vida-casa.png`, sube en un commit ("Arte del nivel 1, tanda 3E, generado con Gemini") y se procesa con `preparar_arte_nivel.py` (sumando las piezas a `PIEZAS`).

**Texto común (el de `nivel-01-plan-arte.md` §3, sin cambios):**
> Mismo estilo que la tanda 1: pixel art chibi cel-shaded del de Felipe A, dos tonos planos por color, contorno café oscuro cerrado de 1 px, sin degradados, sin antialias, sin sombra proyectada en el piso, paleta del Barrio Viejo (terracota, crema, madera, atardecer). Vista lateral recta de juego de plataformas (las puertas, ventanas y cuadros de frente, como se ven en la pared). **Fondo blanco puro #FFFFFF liso**; cada pieza separada de las demás por al menos 40 px de blanco; sin texto, sin letras, sin números, sin líneas de medida. Nada de la pieza en blanco puro: lo que sea blanco (papel, plástico, letreros, el pecho de Felipe) va en crema #EDE4D6 o más oscuro. Cada pieza dibujada grande, ocupando su celda. Respetar las proporciones indicadas (alto : ancho). Adjuntar `siete-vidas/arte/felipe/felipe-A-base.png` y `siete-vidas/arte/referencias/gemini/muebles-sala.png` como referencias de estilo.

**Agregado para esta hoja:** "Son objetos de una casa vivida, con desgaste: bordes gastados, una mancha, una arruga. Nada nuevo ni de catálogo. Adjunto también `cuadros.png` y `detalles.png` para el grosor del contorno."

| # | Pieza | Texto para Gemini | Tamaño en el juego |
| --- | --- | --- | --- |
| 1 | Alfombras (3) | "Tres alfombras vistas de lado, casi planas, como una franja gruesa sobre el piso: A) larga terracota con dibujo persa y flecos en las puntas; B) de pasillo, larga y angosta, beige con franjas azul apagado; C) corta rosa viejo. Las tres un poco gastadas en el centro." | A 300×10, B 260×8, C 120×8 |
| 2 | Pisos (2) | "Dos franjas de piso repetibles de lado a lado, vistas de frente y un poco desde arriba, como el parquet adjunto: A) baldosa de terracota con juntas crema; B) losa de terraza de piedra gris cálida con juntas." | 256×30 cada una |
| 3 | Mesita de la sala | "Mesita lateral de madera baja (alto : ancho 1,4 : 1) con una lámpara de mesa apagada de pantalla crema, una taza de café a medio tomar con una cuchara y un cargador de cable enredado colgando del borde." | 46×55 (tablero arriba) |
| 4 | Marcos chicos (2) | "Dos marcos de madera chicos: A) foto de un gato persa gris y blanco durmiendo panza arriba (alto : ancho 1,2 : 1); B) huella de gato hundida en yeso crema dentro de un marco cuadrado." | 36×44 y 30×30 |
| 5 | Perchero | "Perchero de pared de madera con tres ganchos: una chaqueta verde azulado, una bufanda terracota y un bolso cruzado café; un paraguas cerrado colgando del último gancho." (1 : 0,65) | 70×110 |
| 6 | Zapatillas | "Un par de zapatillas de casa de mujer, crema con suela terracota, tiradas: una de lado y otra volteada." | 34×16 |
| 7 | Video viral enmarcado | "Marco de madera con un teléfono celular vertical adentro; en la pantalla, un gato persa gris y blanco sobre un rascador y muchos corazones rojos alrededor; sin letras ni números." (1,4 : 1) | 44×60 |
| 8 | Llave y trapo | "Llave de agua de cocina antigua de bronce con una gota colgando. Un trapo de cocina a cuadros terracota y crema doblado sobre un tirador, colgando." | 24×30 y 22×34 |
| 9 | Polaroids | "Tres fotos instantáneas chicas con marco crema: un gato persa gris y blanco dormido, el mismo dentro de una caja de cartón y el mismo mirando de reojo." | 12×14 cada una |
| 10 | Corcho | "Tablero de corcho con marco de madera; clavadas con chinches: tres fotos instantáneas del mismo gato persa, cuatro notas adhesivas amarillas y rosadas sin letras y un hilo rojo que une dos fotos." (0,75 : 1) | 70×52 |
| 11 | Fachada del balcón | "Tramo del muro exterior de un edificio antiguo, de frente: estuco terracota gastado con una cornisa de molduras arriba, un farol de pared de hierro encendido y el canto de una losa de balcón abajo; en el medio, un hueco rectangular vacío (blanco) del tamaño de una puerta doble, donde va la puerta." (alto : ancho 1,9 : 1) | 190×360 (hueco de 140×248) |
| 12 | Jardinería | "Regadera de lata gris con abolladuras. Saco de tierra para macetas medio vacío, doblado arriba, con tierra derramada." | 30×26 y 28×30 |

**Si la hoja sale mal, se pide de nuevo solo lo que falló, con el mismo texto común.** Nada de esta hoja es de Felipe: no se pasa por `comparar_felipe.py`. Las fotos de Felipe dentro de los marcos (4, 7, 9 y 10) son decorado y deben parecerse a Felipe A en color y pelaje; si no, se rehacen.

---

## 4. Lo que NO se toca, y por qué

- **Felipe:** escala 0,72, 67 px, hojas y colisión de 58/32. Nada de este plan lo cambia, y no hay animación nueva (en el baño gira con su reojo por defecto).
- **Colisiones medidas (±2 px):** sofá (49/102), rascador (69/114/165), sillas (55), mesa (91), zapatero (97, con 40 libres), caja de arena (45), librero (48/103/155/218), reja (12 de colisión), peldaños, mesón (108), microondas (162), refrigerador (216), baúl (54), consola (97, con 47 libres), alféizar del pasillo (109), cama (65), cómoda (96), repisa (145), ropero (185), escritorio (98), repisa del estudio (151) y baranda (89). El ensanche del pasillo solo **corre** coordenadas; no cambia ninguna medida. La única colisión nueva es la mesita de la sala (S-2), medida de su fila opaca.
- **La ruta y los escalones de 60 px o menos:** las sillas del comedor siguen espejadas y en su lugar (son el escalón hacia el vaso). El escritorio, la repisa y las 5 cosas que se tiran en el estudio no se mueven (R12). Tampoco el cojín junto a la puerta del jefe (R5) ni el pestillo de la reja a 348 px de la arena (R6).
- **Lugares vistos (R17):** el vidrio, la pizza y el alféizar vacío del pasillo, y la caja de recuerdos en la repisa alta. La ventana del pasillo solo cambia de color.
- **Rectángulos sagrados (B3/G10):** ningún decorado nuevo entra en ellos. La puerta del baño suma el suyo, y la prueba lo comprueba.
- **Tabla de capas (`Capas`):** cuadros, corcho, perchero, enchufe y sombras de pared van en `ARTE_PARED` (−3); alfombras y pisos, en la pared, después del piso y antes de las sombras de contacto; mesita, zapatillas, regadera y saco, en `MUEBLES` (−1); pelos y arañazos, en `MUEBLES`/`MARCAS` según si van sobre un mueble o en el piso; rayos y motas, en `LUZ` (5, ya aprobada encima de Felipe); fachada del balcón, en `FACHADA` (−19). **Adentro no hay primer plano nuevo** (M3).
- **Reglas:** R3 (frases de 48 caracteres o menos y una sola vez), R8 (nada interactuable de menos de 24 px; lo nuevo es decorado, salvo la mesita), R9 (cada cuarto sigue con su pared: la cocina cambia de forma, no de estilo) y R14 (el azulejo baja de contraste y el láser queda sobre la madera).
- **La paleta:** nada en blanco puro. La luz fría del baño es `dfe8e2` y los pelos son crema `e8dccb`.
- **Lo que pidió Gemini y se rechaza:** ver "Cruce con Gemini" (sillas, pollo, escritorio, bol de agua y colillas).

## 5. Cómo se verifica (paso 5)

1. Las 8 pruebas del juego (`prueba_movimiento`, `_escenario`, `_mecanicas`, `_nivel`, `_reglas_nivel`, `_jefe`, `_acciones` y `partida.gd`), primero después del paso 0 y otra vez al final.
2. `capturas_nivel.gd`, con y sin `--debug-collisions`, sumando el punto "13-pasillo-bano" (Felipe en x = 4740), y una hoja de antes y después con las 13 vistas. Esa hoja se le muestra al creador y se manda a Gemini con la misma pregunta de `2026-10-19-ambientes-gemini.md`.
3. Al aplicar, hay que actualizar `nivel-01-gran-fuga.md` (§2.4 baño, §7 mapa con el pasillo de 1240 px, §8 R7/R17 y una sección 15 "Ambientes"), `memoria/03` (piezas nuevas y arte existente que se empieza a usar: arañazos, cortinas cortas, libro, lata y maceta rota), `01-decisiones.md` y `04-pendientes.md` (baño y "Abrir puertas") y `05-estado-actual.md`.

## Aplicado (2026-10-19)

Una sola pasada, en orden. **47 hechos, 0 en espera, 0 descartados.** La tanda 3E de Gemini (`arte/referencias/gemini/vida-casa.png` y `vida-casa-fachada.png`, commit 4da2e07) llegó durante la pasada y, por pedido del coordinador, se integró en la misma pasada con cajas explícitas en `preparar_arte_nivel.py` (`PIEZAS_3E`; los números que escribió Gemini se pintan de blanco o quedan fuera de la caja). SpriteCook: 0 créditos. Felipe no se tocó. Todas las pruebas en 0 fallos y el bot 8 de 8. Hoja antes y después con las 13 vistas (fuera del repositorio, en el scratchpad de la sesión: `ambientes-antes-despues.png`) y video del bot `nivel1-v4e.mp4`.

| # | Estado | Nota |
| --- | --- | --- |
| Paso 0 / P-1 | hecho | 103 literales corridos (toda x ≥ 4630 + 200; `ANCHO` 7880); a mano: el ancho del pasillo (1240), la planta del primer plano (9960) y el bot del láser (de 4600 a 4810, fuera de los 60 px de la manija). El bot vuelve caminando antes de agacharse bajo la consola |
| G1 | hecho | Cerrada y puerta-ventana ensanchadas por columnas de su propio panel; la abierta del balcón pierde 16 columnas del vano oscuro; la entornada es el marco de la abierta con la hoja cerrada apoyada, 12 px oscuros y 2 px de sombra. `prueba_reglas_nivel` mide 140 × 248 en los seis |
| G2 | hecho | `vano_alto()`: 140 × 248; `ESCALERA_RECT` sube a `SUELO − 398`; `vano_bajada.png` (poste y dos peldaños al 60 %) dentro del hueco del pasillo |
| G3 | hecho | `ventana_marco.png` (162 × 138, bordes 18/18/26/8) en 9 partes, parante en cruz con bisel, vidrio al 8 % y dos reflejos. El marco trae el cabezal de la persiana de la sala (se lee como la misma ventana) |
| G4 | hecho | Zócalo de 18 px, cornisa de 14 con dentículos cada 6 px y 3 franjas de penumbra, por código en `FondoApartamento._molduras` (ya no se usa `moldura.png`). La cornisa casi no entra en cámara: el techo queda arriba del cuadro |
| G5 | hecho | Sombras de contacto 45/28 % con la base opaca real y bloque bajo cada pata (`Sala._base_opaca`); `SOMBRA_PARED` para 11 piezas colgadas (silueta +1, +2 al 20 %) |
| G6 | hecho | 5 rayos hacia la derecha en 3 franjas, tono por cuarto (`TONO_LUZ`), 5 motas por rayo |
| G7 | hecho | Costura del piso arreglada en la herramienta; baldosas volteadas de forma alterna y corrimiento distinto por cuarto |
| G8 | hecho | `Sala.DINTEL`; retrato, retrato familiar, reloj, marcos y video viral al dintel o con desfase a propósito; el paisaje se apoya en la repisa (D-1) |
| G9 | hecho | `Sala._dibujar_ambiente`: pelos, arañazos de la tanda 3C (`aranazo_1..3`, al 70 %; el del poste va en el nodo del pasamanos para quedar encima), polvo y pelusa |
| G10 | hecho | En la sala, en vez de la luz del portátil (Valeria es otro nodo), late la luz del cargador al final del cable (S-4) |
| G11 | hecho | Ningún decorado nuevo entra en un rectángulo sagrado (la prueba suma el del baño); lo único pisable nuevo es la mesita, medida |
| S-1 | hecho | Retrato a x 660 al dintel; marco con Felipe panza arriba y la huella, a otra altura (3E) |
| S-2 | hecho | Mesita de 88 × 96 con lámpara, taza y cargador (3E); colisión «Mesita» a 58 px (48 cm) de la columna 6 a la 76, medida por la prueba |
| S-3 | hecho | Alfombra terracota de 300 × 10 en la franja del piso (3E) |
| S-4 | hecho | Enchufe en el zócalo y cable con caída hasta el cargador de la mesita |
| R-1 | hecho | Perchero de 118 × 101 sobre el zapatero, de 140 a 241 px (3E; más ancho que lo pedido porque Gemini lo dibujó apaisado) |
| R-2 | hecho | Zapatillas de 24 × 16 en el hueco zapatero–caja de arena (3E) |
| R-3 | hecho | Video viral de 44 × 59 sobre la caja de arena, al dintel (3E) |
| R-4 | hecho | Peldaños recoloreados a madera `8a6a55` |
| R-5 | hecho | Un par verde azulado, uno crema y uno volteado |
| R-6 | hecho | Escalones de zócalo bajo el borde del larguero (medido en el arte), hasta el faldón |
| C-1 | hecho | Azulejo hasta 182 px con contraste al 85 % y listel; arriba, `pared_rosa` llevada a pintura crema `e9d6b4` |
| C-2 | hecho | Alacenas a 2 módulos (118 px, de 3461 a 3579): nada sobre el microondas ni el pollo |
| C-3 | hecho | `visillo_cocina.png` (cortina corta de `detalles.png`, crema con franja terracota) sobre el tercio de abajo del vidrio |
| C-4 | hecho | `piso_cocina.png` (3E) |
| C-5 | hecho | Gemini dibujó la llave y el trapo juntos (el trapo cuelga de la llave, no del cajón): una sola pieza `llave_agua` de 30 × 38; la gota dibujada se borra y cae por código cada 3 s con `goteo.wav` |
| C-6 | hecho | 3 polaroids entre los imanes (3E) |
| C-7 | hecho | 5 croquetas y `lata.png` (de `comida-grande.png`) |
| C-8 | hecho | Segundero rojo que avanza cada segundo |
| P-2 | hecho | Ver 2.4.1: `Sala.BANO` (4740), `Puerta.bano` (luz fría que titila, sin tapete, temblor y destello de la manilla), frases en `Frases.FELIPE` («bano», «bano_manija»), goteo a 0,8 de tono a 300 px o menos. Comprobado en `prueba_nivel` (5 comprobaciones) y `prueba_reglas_nivel` (rectángulo sagrado) |
| P-3 | hecho | La madera crema de `ventana_pasillo.png` pasa a la de la ventana de la sala (el toldo y la vista no se tocan) |
| P-4 | hecho | Retrato familiar de 4900 a 5000, al dintel |
| P-5 | hecho | Alfombra de pasillo de 4370 a 4630 (3E) |
| P-6 | hecho | `aranazo_1` en el marco de la puerta entornada |
| D-1 | hecho | Paisaje con la base en la repisa |
| D-2 | hecho | Alfombra rosa vieja a los pies de la cama (3E) |
| D-3 | hecho | `libro.png` (de `objetos.png`, 28 × 8) atrás del banquito |
| D-4 | hecho | La mitad de abajo de cada paño se corre 1 px cada 0,5 s (el ruedo queda tras la cama, por eso se mueve la mitad) |
| E-1 | hecho | `panos_estudio.png` (cortina corta de `detalles.png` en oliva) a los dos lados |
| E-2 | hecho | Corcho de 64 × 46 (no 70 × 52) de 6831 a 6895: entre el paño y la puerta del balcón (3E) |
| E-3 | hecho | Enchufe, cable de la base de carga y regleta con 3 cables |
| E-4 | hecho | 3 post-its en el borde del monitor |
| B-1 | hecho | `vida-casa-fachada.png`: hueco ensanchado repitiendo una columna a la derecha del farol, 80 filas de muro liso menos y escala para un hueco de 133 × 242 detrás de la puerta-ventana (`Sala.FACHADA_BALCON`, capa `FACHADA`). No hizo falta el reemplazo de ladrillo |
| B-2 | hecho | `piso_balcon.png` (3E) |
| B-3 | hecho | Regadera, saco de tierra (3E) y maceta rota de `detalles.png`, de 7434 a 7526 |
| B-4 | hecho | Las dos macetas de la baranda se mecen 1 px con fases distintas |
