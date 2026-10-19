# Nivel 1, "La Gran Fuga": plan de arte y animaciones (para aprobar antes de gastar)

Fecha: 2026-10-19 · Autor: director de arte · Estado: **propuesta; no se ha gastado nada.**
Base: propuesta v4 aprobada (`nivel-01-propuesta-v4.md`, sección 9 y "Decisiones del creador"), revisión del 2026-10-18 (B2, G1, G3, G4, G6, G7, G8, G9, G11, M1), tandas 1 y 2 de Gemini (`nivel-01-gran-fuga.md`) y lo que ya hay en `siete-vidas/juego/assets/nivel1/`.

Reglas que mandan (CLAUDE.md): toda animación de Felipe sale **directamente de Felipe A** con `animate_game_art`; 8 cuadros de 106×106 a una sola escala, 0,72; cabeza en las filas 25 a 70; estirar y aplastar ±8 % como máximo; objetos aparte, por código; escala de gato (1,21 px/cm en alturas, lo que le importa al gato al doble, nada interactuable menor a 24 px **por su lado menor**); humanos de 3 Felipes con proporciones normales.

---

## 1. Animaciones de Felipe (SpriteCook)

Ajustes comunes a todas:

- `animate_game_art` con `asset_id = 14b3c27f-798c-4795-84fe-48ed15508247` (Felipe A), `project_id = 126fcb42-c3f6-40b5-9f75-42715fbdce40`, 8 cuadros, `auto_enhance_prompt = false`.
- El prompt siempre termina con: *"Same cat as the reference: 3/4 view facing right, chibi proportions, big head, tabby cap with white stripe down the forehead, hazel-green half-lidded side-eye, white chest and paws, big fluffy tabby tail. The cat stays in place, feet on the same ground line in every frame, head the same size in every frame, whole body inside the frame. No objects, no furniture, no background, transparent background."*
- Antes de cada llamada: `get_credit_balance` y "sí" del creador a esa ficha.
- Al llegar: comprobar cuadros de 106 px y pasar `comparar_felipe.py` (sección 6).

### 1.1 `subir_escalera` (aprobada, prioridad 1)

- **Para qué:** subir los 7 escalones de la escalera de fondo dando un saltito por escalón (G6). Es un ciclo; el código sube a Felipe unos 21 px por ciclo siguiendo la línea de los peldaños.
- **Modelo:** `pixel-engine-v1.5` (pose poco común; el de por defecto ya falló con gatear). **26 créditos.**
- **Prompt:**
  > "The cat climbs one stair step in place, as a looping cycle. Frames 1-2: the cat crouches slightly and lifts both front paws high, as if placing them on a step one step higher in front of it. Frames 3-4: the front paws are planted up front and higher, the body stretches diagonally upward with the chest raised and the back lower, tail balancing behind. Frames 5-6: the hind legs push and gather up under the belly, the rear lifts to the level of the front paws. Frames 7-8: all four paws together again, the body settles level, ready to repeat. Calm side-eye expression the whole time." + texto común.
- **Riesgo:** que el piso "se mueva" entre cuadros (en los cuadros 3-4 las delanteras quedan más arriba) o que salga de perfil. Si los pies de atrás no quedan en la misma línea en 1 y 8, el ciclo salta. Riesgo medio; conviene el modelo caro.
- **Alternativa gratis:** cuadros de `saltar` (1 agacharse, 3 patas recogidas) y `caer` (5 contacto) encadenados por escalón, con un saltito de código. Se lee como "salta escalones", no como "sube"; sirve de provisional mientras llega.

### 1.2 `aranar` (aprobada)

- **Para qué:** arañar sofá, rascador y la puerta entornada del dormitorio (G11). Las marcas y el mueble van por código.
- **Modelo:** `pixel-engine-v1.5` (de pie en dos patas, pose poco común). **26 créditos.**
- **Prompt:**
  > "The cat scratches a vertical surface that is just in front of it to the right (the surface is NOT drawn). Frames 1-2: the cat rises onto its hind legs, body upright, front paws reaching up to the right with claws out. Frames 3-4: the left front paw drags down while the right paw stays up. Frames 5-6: the right front paw drags down while the left paw goes up again. Frame 7: both paws drag down once more. Frame 8: the cat drops back onto four paws and looks over its shoulder at the viewer with a smug side-eye. Head stays the same size while standing up; the whole cat, ears included, stays inside the frame." + texto común.
- **Riesgo:** de pie es más alto: puede salir cortado arriba o con la cabeza más chica para caber. Si la cabeza cambia de tamaño, no entra. Riesgo medio-alto.
- **Alternativa gratis:** `zarpazo` repetido frente al mueble + marcas por código (provisional ya previsto en la propuesta).

### 1.3 `maullar` (aprobada)

- **Para qué:** botón propio; abre la puerta de la cocina vía Valeria, hace reaccionar a humanos y a A.S.P.I.
- **Modelo:** por defecto (gesto de cabeza, sin pose rara). **20 créditos.**
- **Prompt:**
  > "The cat meows loudly in place. Frames 1-2: the cat raises its head slightly, eyes still half-lidded. Frames 3-5: mouth wide open in a long meow, eyes squeezed half shut, ears slightly back, tail swishing from side to side. Frames 6-7: mouth closes slowly. Frame 8: offended side-eye, back to the idle pose. Only the head, mouth and tail move; the body and paws stay planted." + texto común.
- **Riesgo:** bajo. Puede abrir la boca poco (se lee como bostezo) o cambiar a ojos redondos.
- **Alternativa gratis:** retrato 3 de los 9 (boca abierta) en la burbuja + estirar 4 % y sacudida de código sobre `quieto`.

### 1.4 `empujar` (opcional)

- **Para qué:** el chiste de tirar el vaso mirando a la cámara.
- **Modelo:** por defecto. **20 créditos.**
- **Prompt:**
  > "The cat slowly pushes something off a table with one paw while staring straight at the viewer. Frames 1-2: the cat turns its face toward the viewer, deadpan, unblinking half-lidded stare. Frames 3-5: the right front paw extends slowly forward at chest height, the paw tip pushes forward. Frames 6-7: the paw stays out, the cat keeps staring at the viewer without blinking. Frame 8: the paw returns to the ground. The object is NOT drawn." + texto común.
- **Riesgo:** bajo-medio (mirar de frente puede cambiar la cara).
- **Alternativa gratis (recomendada por ahora):** `zarpazo` con el impacto en el cuadro 4 (B5). **Recomiendo no pedirla todavía.**

### 1.5 `entrar_puerta` (opcional)

- **Para qué:** cruzar una puerta de espaldas antes del fundido.
- **Modelo:** `pixel-engine-v1.5` (vista de espaldas). **26 créditos.**
- **Prompt:**
  > "The cat turns around and walks away from the viewer into a doorway. Frames 1-2: the cat turns from 3/4 view to a back view. Frames 3-8: back view, walking away with small steps, fluffy tabby tail held high and swaying, the tabby saddle pattern on the back visible. The cat does not get smaller; it stays in place." + texto común (cambiando "3/4 view facing right" por "starts in 3/4 view").
- **Riesgo:** alto. La espalda no existe en Felipe A: el modelo inventa el lomo, la gorra vista de atrás y la cola; puede salir otro gato.
- **Alternativa gratis (recomendada):** Felipe camina hacia el vano, se oscurece (luz del vano encima) y se achica 6 % (dentro del ±8 %) mientras va el fundido. **Recomiendo no pedirla en este nivel.**

**Total animaciones de Felipe:** aprobadas **72** (26 + 26 + 20); con las dos opcionales **118**. Reserva sugerida: **26** para rehacer una (la más probable de fallar es `aranar`).

---

## 2. Valeria

### 2.1 Ficha visual (para que sea siempre la misma persona)

La biblia solo dice "teletrabaja, sube todo a redes, lo ama de verdad". Propongo (el creador aprueba o corrige):

| Rasgo | Valeria |
| --- | --- |
| Edad | unos 30 años |
| Cuerpo | 1,65 m, contextura normal; **200 px de alto** en el juego (3 Felipes); cabeza de ~26 px (1/7,5 de la altura), proporciones normales, nada Chibi |
| Pelo | castaño oscuro `#4A2E22`, ondulado, en un moño alto desordenado con dos mechones sueltos a los lados de la cara |
| Cara | piel morena clara `#D9A27C` (sombra `#B07B5A`), ojos cafés grandes, cejas expresivas; sin lentes (la expresión se lee mejor) |
| Ropa de casa | sudadera holgada verde azulado `#3E7C7A` (sombra `#2C5A59`) con mangas arremangadas; pantalón de buzo gris carbón `#4B4A55`; calcetines rosados `#E59AA2` y pantuflas crema con orejitas de gato |
| Accesorio | celular con funda amarilla mostaza `#D9A441` (sin logos); en "viendo la serie", un portátil gris sin logo |
| Contorno y sombra | igual que Felipe: contorno café oscuro `#241C1A`, sombras planas en 2 tonos, sin degradados |
| Vista | **3/4 mirando a la derecha**, como Felipe A; se voltea por código |

Por qué estos colores: el verde azulado y el gris contrastan con el papel tapiz crema-terracota de la sala y la cocina (R14), y no se confunden con Felipe (gris-café y blanco). El rosado de los calcetines repite el de su nariz: los une sin decirlo.

**Legal:** si Valeria se parece a alguien real, hace falta su permiso escrito (biblia, revisión legal). Ningún logo en celular, portátil ni ropa.

### 2.2 Poses fijas (Gemini, una sola hoja: la misma persona en las cinco)

Pedirlas **juntas en una imagen** es lo que más ayuda a que Gemini no cambie la cara ni la ropa entre poses. Son 5 (la quinta es la base para caminar):

0. **Base de pie, neutra** (referencia para todo lo demás y para caminar).
1. **Enojada:** de pie, señalando hacia abajo a la derecha con el índice, la otra mano en la cadera, ceño fruncido, boca abierta gritando.
2. **Perdonando:** agachada en cuclillas, acariciando hacia abajo a la derecha con una mano, sonrisa derretida, ojos cerrados de ternura.
3. **Grabando:** de pie, celular en alto con las dos manos apuntando abajo a la derecha, sonrisa enorme, de espaldas a medias al lado izquierdo (no ve el sofá).
4. **Viendo la serie:** sentada (sin sofá: el sofá es otra pieza), piernas recogidas a un lado, portátil sobre las piernas, cara de hipnotizada; altura total ~150 px, con la cadera donde va el asiento del sofá (54 px del piso).

### 2.3 Caminar: ¿Gemini o SpriteCook?

| | Gemini, hoja de 8 cuadros | SpriteCook, `animate_game_art` desde la pose 0 de Gemini (se sube gratis) |
| --- | --- | --- |
| Costo | sin créditos | **20** (por defecto) o 26 (`pixel-engine-v1.5`) |
| Consistencia entre cuadros | baja: cada cuadro sale un poco distinto (cara, ropa, largo de piernas), pies a distinta altura; hay que alinear y retocar a mano | alta: anima la misma imagen; así salieron todas las de Felipe |
| Riesgo | que el ciclo "tiemble" y no sirva; horas de retoque | el tamaño del cuadro no se sabe hasta ver la salida (con Felipe A de 86×94 salió 106); si achica a Valeria, se rehace o se fija **una sola escala para todo su arte**, como con Felipe |

**Recomiendo SpriteCook, modelo por defecto, 20 créditos.** Caminar es un movimiento común; el modelo caro no hace falta.

- **Prompt:** *"The woman walks in place to the right, a relaxed walking cycle of 8 frames: alternating legs, arms swinging gently, slight up-and-down bob, slippers visible. Same woman as the reference: 3/4 view facing right, same hair bun, teal hoodie, charcoal sweatpants, pink socks, cream cat slippers, same face. She stays in place, feet on the same ground line, same size in every frame, transparent background."* `auto_enhance_prompt = false`, `project_id` del juego.
- **Alternativa gratis:** pose 0 desplazada con un balanceo de 2 px por código (se ve barato, sirve de provisional).
- **Regla de escala para Valeria (propuesta):** todas sus poses y su caminar a **una sola escala** que la deje en 200 px; si una pieza sale de otro tamaño, se rehace.

### 2.4 Retrato para diálogos (Gemini)

Mismo estilo que `felipe-retratos.png` (cara y hombros, fondo beige liso, cuadros iguales). Hoja de 3×2: Valeria neutra, enojada, derretida de ternura, grabando con el celular (emocionada); A.S.P.I. normal (luz verde) y en alerta (luz roja). Se reducen a 66×66 px como los de Felipe.

---

## 3. Encargo a Gemini, tanda 3 (piezas del nivel)

Para la sesión "gemini" de la Dell (el creador le escribe **"sí, adelante"** en su propio chat). Guardar en `siete-vidas/arte/referencias/gemini/`, subir en un solo commit a la rama del juego y procesar con `preparar_arte_nivel.py` (sumar las piezas a su tabla `PIEZAS`).

**Texto común para todas las hojas (copiar al inicio de cada encargo):**
> Mismo estilo que la tanda 1: pixel art chibi cel-shaded del de Felipe A, dos tonos planos por color, contorno café oscuro cerrado de 1 px, sin degradados, sin antialias, sin sombra proyectada en el piso, paleta del Barrio Viejo (terracota, crema, madera, atardecer). Vista lateral recta de juego de plataformas (las puertas, ventanas y cuadros de frente, como se ven en la pared). **Fondo blanco puro #FFFFFF liso**; cada pieza separada de las demás por al menos 40 px de blanco; sin texto, sin letras, sin números, sin líneas de medida. Nada de la pieza en blanco puro: lo que sea blanco (papel, plástico, letreros, el pecho de Felipe) va en crema #EDE4D6 o más oscuro. Cada pieza dibujada grande, ocupando su celda. Respetar las proporciones indicadas (alto : ancho). Adjuntar `siete-vidas/arte/felipe/felipe-A-base.png` y `siete-vidas/arte/referencias/gemini/muebles-sala.png` como referencias de estilo.

**Cómo se evitan los márgenes transparentes y los halos (M1 y lo visto en la tanda 1):**
1. En el encargo: fondo blanco puro, sin sombra en el piso, contorno cerrado y nada blanco dentro de la pieza (la herramienta borra lo que pase de 232 de brillo y se comería un letrero blanco).
2. En `preparar_arte_nivel.py` (código, sin costo): después de quitar fondo y halo, **recortar cada pieza a su borde opaco antes de escalar** y otra vez después (hoy quedan 1 a 3 px transparentes por lado: puerta 2-3 px, comedor 3 px, sofá 3 px); escalar con vecino más cercano; quitar pixeles sueltos de menos de 4 px; guardar el margen de abajo para que `ArteNivel` apoye por la última fila opaca.
3. Los letreros (el cartel "PIPE: NO. Con amor, mamá", las etiquetas "NUEVO") se piden **en blanco** y el texto lo pone el código con la fuente pixel (Gemini escribe mal y no se puede corregir sin regenerar).

### Tanda 3A: lo que bloquea la construcción (pedir primero)

| # | Archivo | Contenido y texto del encargo | Tamaño en el juego | Arregla |
| --- | --- | --- | --- | --- |
| 18 | `puertas-v2.png` | "Puerta interior de madera de un solo vano, de frente: marco ancho de madera (unos 13 px de grosor a escala) alrededor de un hueco oscuro; **la hoja abierta hacia adentro, pegada al lado derecho del marco, dentro del mismo marco**, sin ningún poste ni división en el medio del hueco. La misma puerta **cerrada** con manilla dorada y una rendija de luz cálida abajo. La misma puerta **entornada** (abierta un palmo, una franja oscura vertical). La puerta-ventana del balcón cerrada, con vidrios, del mismo ancho. Un tapete pequeño terracota." Proporción alto : ancho 1,9 : 1. | Puerta: **130×248**, hueco interior de **104 px**. Tapete 104×8 | B2 (poste en el centro, 176 px de ancho) |
| 19 | `comedor-piezas.png` | "Una mesa de comedor de madera sola, de lado, con sus dos patas visibles y nada debajo (proporción alto : ancho 0,6 : 1). Una silla de madera sola, **de perfil lateral perfecto, derecha**, mirando a la derecha, con el asiento a la mitad de la altura del respaldo (proporción alto : ancho 2,7 : 1). Piezas separadas, ninguna se cruza con otra." La segunda silla es la misma volteada por código. | Mesa **150×91** (tablero en la fila de arriba). Silla **40×109**, asiento a 55 px del piso | G3 (sillas torcidas y cruzadas), B4 |
| 20 | `librero-gato.png` | "Librero de madera alto y angosto (proporción alto : ancho 2,4 : 1) con **solo 3 repisas gruesas y planas** a exactamente 1/4, 1/2 y 3/4 de la altura, más el techo del mueble arriba, todas del mismo grosor. Huecos grandes y medio vacíos: en el de abajo una caja de cartón pequeña, en el del medio una planta en maceta y un libro tirado acostado, en el de arriba dos libros parados a un lado. Nada sobresale de las repisas hacia arriba en la mitad derecha (ahí se para el gato)." | **92×218**; repisas a **54, 109, 163** y tope a 218 px del piso | G4 (repisas que no calzan) |
| 21 | `escalera-dos-capas.png` | "La misma escalera de madera antigua, vista de lado, que sube de izquierda a derecha con **7 peldaños iguales**, dibujada **dos veces una al lado de la otra, en el mismo tamaño y la misma posición**: A) solo los peldaños y el larguero, en tonos apagados (va detrás del gato); B) solo el pasamanos torneado con **pocos barrotes delgados y muy separados** (va delante del gato), con el resto transparente." | Cada capa **210×150** (contrahuella de 21 px) | G6 |
| 22 | `reja-antifuga.png` | "Reja alta para mascotas de metal blanco crema (#EDE4D6), de una sola pieza, vista en 3/4 para que se vea su ancho, barrotes verticales, marco grueso, un **pestillo grande** rojo a media altura y un **cartel de cartón en blanco** colgado con cinta en la parte de arriba (sin letras). Proporción alto : ancho 3,8 : 1." | **48×182**; pestillo ≥ 24×24; cartel ~40×28 (texto por código) | G7 |
| 23 | `comida-grande.png` | "Tazón hondo de cerámica azul con un montón de croquetas que sobresale (ancho 1,5 : alto 1). Lata de atún abierta con la tapa doblada hacia arriba y la cola de un pescado asomando (cuadrada). Pollo asado entero dorado en una fuente (ancho 1,6 : alto 1). Bolsita de premios para gato cerrada, con un pescadito dibujado, sin letras (cuadrada)." | Tazón **48×32**, lata **32×32**, pollo **64×40**, bolsita **24×24** | G8 (plato 40×16, lata 30×18) |

### Tanda 3B: Valeria (después de que el creador apruebe su ficha)

| # | Archivo | Contenido y texto del encargo | Tamaño en el juego |
| --- | --- | --- | --- |
| 24 | `valeria-poses.png` | "La misma mujer en 5 poses, una al lado de la otra, misma cara, mismo pelo, misma ropa, mismo tamaño, **proporciones humanas normales (no chibi)**, vista 3/4 mirando a la derecha, de cuerpo entero con los pies sobre la misma línea: [ficha de 2.1 completa] Poses: 0) de pie neutra, brazos relajados; 1) enojada señalando hacia abajo a la derecha, otra mano en la cadera, gritando; 2) en cuclillas acariciando hacia abajo a la derecha, sonrisa derretida, ojos cerrados; 3) de pie grabando con el celular en alto con las dos manos hacia abajo a la derecha, sonrisa enorme; 4) sentada sin mueble (como sobre un sofá invisible), piernas recogidas a un lado, portátil gris sobre las piernas, cara hipnotizada. Adjuntar Felipe A al lado, en escala: ella mide 3 veces lo que mide él." | Pose de pie **200 px** de alto; sentada ~150; en cuclillas ~110 |
| 25 | `retratos-valeria-aspi.png` | "Hoja de retratos 3×2, cuadros iguales, cara y hombros, fondo beige liso #E8D9C4, mismo estilo que `felipe-retratos.png` (adjuntar): Valeria neutra, enojada, derretida de ternura, grabando emocionada con el celular; A.S.P.I. (la de `aspi-gemini-1.png`) con luz verde y con luz roja de alerta." | 66×66 cada uno |

### Tanda 3C: piezas de cada cuarto (pueden esperar a que el nivel funcione con lo provisional)

| # | Archivo | Contenido y texto del encargo | Tamaño en el juego |
| --- | --- | --- | --- |
| 26 | `sala-extra.png` | "Rascador para gatos de 3 niveles (plataformas acolchadas planas a 1/3, 2/3 y arriba, poste de cuerda, proporción 3 : 1) con una etiqueta colgante en blanco. El sofá de `muebles-sala.png` **igual, mismo tamaño y forma**, dos veces: A) envuelto en plástico transparente brillante con una etiqueta en blanco; B) sin plástico, con el costado arañado y pelusas. Marcas de arañazo sueltas (3 tamaños). Cesta de mimbre para gato, tres veces: vacía, con 3 calcetines, llena de calcetines." | Rascador **60×175** (plataformas a 54/109/163); sofá **240×102** (igual al actual); cesta **60×36**; marcas 24–40 px |
| 27 | `recibidor-cocina-extra.png` | "Zapatero de madera bajo sobre patas altas, hueco libre debajo de 1/3 de su altura, con zapatos dentro (ancho 1,6 : alto 1). Un llavero con 3 llaves y un pompón. Microondas blanco crema. Una docena de imanes de refrigerador sueltos (frutas, pescaditos, una foto de gato). Ratón de cuerda gris **volcado patas arriba**, con la llave de cuerda arriba. Caja de cartón rota en tres pedazos." | Zapatero **160×98** (36 libres debajo); llaves **24×24**; microondas **60×54**; imanes 8–12 px (decorado); ratón volcado del tamaño de `raton.png`, con el cuerpo tocando el borde de abajo; pedazos de caja 24–32 px |
| 28 | `arriba-extra.png` | "Baúl de madera con herrajes. Consola angosta con un cajón entreabierto. Cojín redondo rosado con un hueco hundido con forma de gato redondo. Retrato familiar en marco: una mujer y unos abuelos genéricos, tapados casi enteros por un gato persa gris y blanco enorme en primer plano. La cómoda de `muebles-dormitorio.png` igual pero con el cajón de arriba abierto. Calcetines sueltos de 3 colores. Pila de ropa doblada, dos veces: limpia y llena de pelos grises. Caja de recuerdos con tapa. Escritorio de madera de dos cajones con pantalla encendida (pantalla vacía azul) e impresora encima. Hojas de papel arrugadas en el piso (planas, de lado)." | Baúl **60×54**; consola **156×98**; cojín **60×20**; retrato 60×48; cómoda **84×97** (igual a la actual); calcetines **24×24**; ropa **48×24**; caja 40×30; escritorio **156×98**; papeles 32×12 (marca de piso, como las manchas) |
| 29 | `ventanas-patio.png` | "Ventana de la sala de frente con persiana de madera a medio subir; por el vidrio se ve un patio de luz al atardecer y, arriba, un balcón con una luz roja pequeña (proporción 1 : 1). Alféizar de ventana del pasillo; por el vidrio se ve, abajo, el toldo a rayas de un vecino con una caja de pizza encima, sin letras." | Ventana sala **180×180**; ventana pasillo **140×120** (decorado; la caja de pizza es la foto, ≥24 px) |

Íconos de botones (G9): **no se piden a Gemini**, salen de Kenney (sección 4).

**Pregunta para el creador sobre la escalera:** el pasamanos va delante de Felipe y R14 dice que el primer plano no lo tapa. Propongo barrotes delgados (3 px) con huecos de 14 px o más y que la capa delantera baje a 70 % de opacidad mientras Felipe sube. ¿De acuerdo?

**Nota sobre la reja:** en el mapa la colisión mide 12 px de ancho; el dibujo en 3/4 propuesto mide 48 px para que no sea un palito. La colisión puede seguir en 12 px.

---

## 4. Kenney (CC0, gratis)

| Paquete | Enlace | Para qué |
| --- | --- | --- |
| Impact Sounds | https://kenney.nl/assets/impact-sounds | vaso, maceta, llaves ("¡CLINK CRÍTICO!"), caja, golpes de la pelea |
| Interface Sounds | https://kenney.nl/assets/interface-sounds | Agenda (abrir, tachar una línea), carteles, notificaciones de logro |
| UI Audio | https://kenney.nl/assets/ui-audio | clics de menús y pausa |
| Digital Audio | https://kenney.nl/assets/digital-audio | pitidos de A.S.P.I. ("¡DEPÓSITO LLENO!", apagado) |
| RPG Audio | https://kenney.nl/assets/rpg-audio | tela y ropa (arañar, ropa doblada), pasos suaves, cajón |
| Input Prompts Pixel | https://kenney.nl/assets/input-prompts-pixel | íconos de teclado y mando en pixel art para el `Indicador` y las líneas de Felipe (G9) |
| Particle Pack / Smoke Particles | https://kenney.nl/assets/particle-pack · https://kenney.nl/assets/smoke-particles | polvo, pelusa, destellos, humo de la ola de polvo. **Son de alta resolución:** reducir con vecino más cercano y pocos colores, o hacer las partículas por código con cuadritos (más coherente con el pixel art) |
| Kenney Fonts | https://kenney.nl/assets/kenney-fonts | fuente pixel (Kenney Pixel o Kenney Mini) para carteles, letreros "PIPE: NO" y "NUEVO" |

- **Licencia:** CC0 (dominio público), uso comercial permitido, no exige atribución. Igual se acredita: archivo `siete-vidas/juego/assets/CREDITOS.md` con paquete, autor (Kenney, kenney.nl), enlace y licencia, y una línea en los créditos del juego ("Sonidos e íconos: Kenney.nl, CC0").
- Nunca personajes ni fondos de Kenney (se rompería el estilo).

---

## 5. Resumen de costos

| Partida | Servicio | Créditos |
| --- | --- | --- |
| `subir_escalera` | SpriteCook `pixel-engine-v1.5` | 26 (aprobada) |
| `aranar` | SpriteCook `pixel-engine-v1.5` | 26 (aprobada) |
| `maullar` | SpriteCook por defecto | 20 (aprobada) |
| Valeria caminar (desde su pose 0 subida) | SpriteCook por defecto | 20 (aprobada: Valeria camina) |
| `empujar` | SpriteCook por defecto | 20 (opcional, no recomendada aún) |
| `entrar_puerta` | SpriteCook `pixel-engine-v1.5` | 26 (opcional, no recomendada) |
| Reserva para rehacer una animación | SpriteCook | 26 (solo si falla una) |
| Tandas 3A, 3B y 3C (12 hojas) | Gemini, sesión del creador | sin créditos de SpriteCook |
| Kenney | descarga | 0 |

**Saldo:** 336 (2026-10-18, confirmar con `get_credit_balance`).
- Lo aprobado (3 animaciones + caminar de Valeria): **92** → quedan **244**.
- Con reserva usada: 118 → quedan **218**.
- Con las dos opcionales y la reserva: 164 → quedan **172**.

---

## 6. Orden recomendado y cómo se valida

### Orden

1. **Código provisional ya** (sin costo): recorte de la puerta actual, recorte al borde opaco en `preparar_arte_nivel.py`, prueba arte contra colisión. Así nada espera al arte.
2. **Tanda 3A de Gemini** (puertas, comedor, librero, escalera, reja, comida): son las colisiones del nivel; sin ellas no se pueden medir los saltos.
3. **`subir_escalera`** (26): es la única animación sin provisional aceptable y la pide la escalera.
4. **Ficha de Valeria aprobada → tanda 3B** (poses y retratos) → **caminar de Valeria** (20) desde su pose 0.
5. **`maullar`** (20) y **`aranar`** (26): tienen provisional (`zarpazo`, retrato), así que no bloquean.
6. **Tanda 3C** y Kenney, mientras se construyen los cuartos.
7. Opcionales solo si el creador las pide después de jugar.

Una llamada a la vez: si la primera de `pixel-engine-v1.5` sale mal, se corrige el prompt antes de gastar en la siguiente.

### Validación

- **Cada animación de Felipe:** cuadros de 106×106 (si no, se rehace); `python3 siete-vidas/herramientas/comparar_felipe.py <scratchpad>/comparar.png`; revisar misma vista 3/4, cabeza del mismo tamaño (filas 25-70), gorra con franja, ojos de reojo, pecho blanco, cola peluda, pies sobre el mismo piso. Veredicto **ENTRA / NO ENTRA**; la imagen se muestra al creador aunque no entre. Si entra: los tres lugares (memoria con tabla Acciones de Felipe y assets/créditos en 03, ficha regenerada y publicada, juego con prueba).
- **Valeria:** hoja con sus 5 poses y un cuadro del caminar junto a Felipe A, a escala del juego (200 px contra 67 px). Misma cara, pelo y ropa en todas; si una pose cambia de persona, esa se rehace.
- **Piezas de Gemini:** hoja de contacto de cada tanda (cada pieza a su tamaño de juego, con Felipe A al lado y la línea de colisión dibujada), más capturas del cuarto con `--debug-collisions`. Comprobar: borde opaco a 0 px del borde de la imagen, sin halo blanco, colisión contra fila opaca a ±2 px, lado menor ≥ 24 px en lo interactuable, ninguna pieza dentro del rectángulo de una puerta.
- **Al creador se le muestra:** la ficha de cada encargo antes de gastar, la comparación de cada animación, la hoja de Valeria junto a Felipe y la hoja de contacto de cada tanda. Al cerrar, se anotan créditos y assets en `03-arte-y-herramientas.md`.
