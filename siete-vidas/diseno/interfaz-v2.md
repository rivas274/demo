# Interfaz v2: layout primero, después el arte

Actualizado: 2026-10-23. **Estado:** primero se decide la **estructura** (dónde va todo y cómo se lee en cada pantalla) y después el arte. Pedido del creador: «rediseña la UI; no importa el arte, sino dónde va todo y cómo iría».

- El layout en wireframes, sin arte, está en la sección «Layout y legibilidad multiplataforma», que viene enseguida. **Lo aprueba el creador.**
- Las láminas de estilo A, B y C (sección «Dirección de arte: opciones») quedan **en pausa**. Se retoman cuando se apruebe el layout, y entonces se ajustan a él: por ejemplo, el contador de snacks sale del HUD y las etiquetas de 8 px pasan a 16 px.
- No se toca el juego.

## Layout y legibilidad multiplataforma

**Datos nuevos del creador (2026-10-23):**

- El juego puede salir en **Switch** (portátil y TV), **PC** y **PlayStation**. Todo el texto debe leerse en esas pantallas.
- **Los snacks salen de la pantalla principal:** se ven solo en la pausa, en el bolsillo.

Se aplica el pilar de no reinventar la rueda: los números salen de las guías públicas de la industria (fuentes al final de la sección). Nintendo y Sony no publican sus guías (están detrás del portal de desarrolladores, con acuerdo de confidencialidad). Por eso se usan las de Xbox, que son públicas y las más estrictas, más las de accesibilidad. Al registrarse en Nintendo y PlayStation hay que contrastarlas con sus requisitos de certificación (Lotcheck y TRC).

### Lo que dicen los estándares

| Tema | Estándar | Fuente |
| --- | --- | --- |
| Zona segura | **Títulos: el 90 % interior** de la pantalla (menús, HUD, texto, todo lo importante). **Acción: el 95 %.** A 1080p, la zona de títulos queda a 96 px de los lados y 40 px de arriba y abajo. Los 32 px laterales y los 8 px de arriba y abajo pueden tener avisos del sistema | Xbox GDK, «Screen safe areas» |
| Zona segura (TV clásica) | Acción al 90 % y títulos al 80 % (SMPTE RP 13 y RP 8). La norma de 16:9 (SMPTE RP 2046-2) deja solo el 90 % | Autodesk, «Safe display regions»; nesdev |
| Letra mínima, consola | **26 px de cuerpo a 1080p** (52 px a 4K). PC: 18 px a 1080p. El cuerpo se mide del ascendente más alto al descendente más bajo. Hay que poder **agrandarla hasta 200 %**, y los íconos de botón crecen con el texto | Xbox Accessibility Guideline 101 |
| Letra mínima, portátil | Leíble **a 30 cm** (12 pulgadas): a **720p, mínimo 9 px y recomendado 12 px**; a 1080p, mínimo 14 y recomendado 18 | Xbox, guías de compatibilidad portátil |
| Letra mínima, accesibilidad | 28 px a 1080p como **piso**, no como meta (guía de 10 pies de Amazon) | Game Accessibility Guidelines |
| Letra mínima, IGDA | **32 px a 1080p**, y **46 px** para el texto que se va solo, como los subtítulos | IGDA GA-SIG, «Text size» |
| Distancia | Sofá: «10 pies» (unos 3 m) frente a la TV. Portátil: 30 cm | Amazon Fire TV; Xbox portátil |
| Contraste | **4,5:1** para texto normal, **3:1** para texto grande e íconos, **7:1** en el modo de contraste alto | Xbox Accessibility Guideline 102 |
| Ritmo del texto | Que el jugador avance el texto **a su ritmo** | Game Accessibility Guidelines (básica) |
| Espaciado | ≤ 80 letras por línea; interlineado ≥ 1,5× en bloques de más de 2 líneas; desplazamiento en un solo eje | Xbox Accessibility Guideline 101 |

### Escalado del pixel art

La base es 640×360 y se escala **solo por enteros**, con el vecino más cercano:

| Pantalla | Salida | Escala | 1 px de la base mide |
| --- | --- | --- | --- |
| Switch portátil (6,2", 237 ppp) | 1280×720 | ×2 | 0,21 mm |
| Switch OLED portátil (7", 210 ppp) | 1280×720 | ×2 | 0,24 mm |
| Switch 2 portátil (7,9", 1080p, unos 279 ppp) | 1920×1080 | ×3 | 0,27 mm |
| Switch en TV, PS4 y PC a 1080p | 1920×1080 | ×3 | 1,4 mm (TV de 40") a 1,9 mm (TV de 55") |
| PC a 1440p | 2560×1440 | ×4 | — |
| PS5 y PC a 4K | 3840×2160 | ×6 | — |
| Steam Deck | 1280×800 | ×2, con franjas de 40 px | — |

Una pantalla que no es múltiplo usa el mayor entero que cabe, más franjas.

**Qué significa en la base:**

- 26 px a 1080p son 26 / 3 ≈ **9 px de cuerpo** en la base.
- El recomendado del portátil (12 px a 720p) son 6 px en la base.
- Los 32 px de IGDA son ≈ 11 px.
- **Manda la TV**, porque es la pantalla más exigente.

### ¿Cumplen nuestras letras? (medidas en la base, cuerpo de «Hdgjpqy»)

| Letra (uso hoy) | Cuerpo en la base | 1080p (×3) | 720p (×2) | Veredicto |
| --- | --- | --- | --- | --- |
| Pixel Operator 16 (texto) | 11 px | 33 px | 22 px | **Cumple** consola (26), GAG (28) e IGDA (32) |
| Pixel Operator Bold 16 (nombres, números) | 11 px | 33 px | 22 px | **Cumple** |
| Silkscreen 16 (carteles; solo mayúsculas) | 10 px | 30 px | 20 px | **Cumple** consola y GAG; queda justo bajo IGDA 32 |
| Silkscreen 24 y 32 | 15 y 20 px | 45 y 60 px | — | **Cumple** |
| Pixel Operator 8 (hoy: nombre del diálogo, indicador, barra del jefe, ficha, libreta, resumen) | 8 px | 24 px | 16 px | **No cumple en TV** (24 < 26). Sí en portátil |
| Silkscreen 8 (las láminas A, B y C) | 5 px (mayúsculas) | 15 px | 10 px | **No cumple** en TV, y en portátil queda bajo el recomendado |

En tamaño físico, con Pixel Operator 16 (11 px de cuerpo):

| Pantalla y distancia | Alto del cuerpo | Ángulo |
| --- | --- | --- |
| Switch OLED a 30 cm | 2,7 mm | unos 30′ |
| Switch original a 30 cm | 2,4 mm | unos 27′ |
| TV de 55" a 2,5 m | 21 mm | unos 29′ |
| TV de 40" a 3 m | 15 mm | unos 17′ |

El mínimo de Xbox (26 px) en la TV de 40" a 3 m da unos 14′, así que vamos sobre él. Pixel Operator 8 en esa TV da unos 12′: **bajo el mínimo**.

Lámina con las letras a tamaño real: `revisiones/capturas/interfaz-rediseno/layout-00-reglas.png` (y `-x2`).

### Reglas del juego, en números (base 640×360)

1. **Zona segura de títulos (90 %):** el rectángulo de **(32, 18) a (608, 342)**, de 576×324. Todo lo que se lee y todo el HUD va dentro.
   - La zona de acción (95 %) va de (16, 9) a (624, 351): ahí solo cosas del mundo.
   - Opción «Zona segura» de 80 % a 100 % (por omisión, 90 %).
2. **Letra mínima: 11 px de cuerpo en la base** para todo texto que hay que leer (Pixel Operator 16, Pixel Operator Bold 16 o Silkscreen 16). El piso absoluto es 9 px.
   - **Se dejan de usar Pixel Operator 8 y Silkscreen 8** para texto que se lee.
   - Solo podrían quedar en algo decorativo que no hace falta leer, como una marca en un objeto del mundo (lo mismo exceptúa la guía portátil de Xbox).
3. **Texto grande (200 %):** Pixel Operator 32 y Bold 32 (22 px de cuerpo) y Silkscreen 32. Los íconos de botón y las huellas también se duplican (XAG 101).
   - Solo hay 2 pasos, porque las letras pixel solo se ven nítidas en múltiplos de su tamaño de diseño.
4. **Íconos:**
   - ícono de botón: 16×16 en normal y 32×32 en grande;
   - huella: 13×12, y 26×24 en grande;
   - nada con lo que se interactúa mide menos de 16 px en el HUD.
5. **Contraste:**
   - texto ≥ 4,5:1 contra su panel; texto grande e íconos ≥ 3:1;
   - modo «Contraste alto» con todo ≥ 7:1 (XAG 102);
   - todo texto va sobre un panel opaco (≥ 85 %) o con contorno de 1 px más panel en contraste alto, nunca suelto sobre el decorado.
6. **Diálogo:**
   - 2 líneas por página, ≤ 74 letras por línea en normal (≤ 80, XAG) y unas 37 en grande;
   - si no cabe, **se pagina** («página 1 de 2» y la flecha);
   - interlineado de 17 px en normal y 34 px en grande.
7. **Ritmo del texto:**
   - Velocidad de aparición: Lenta 30, Normal 55 (la de hoy), Rápida 110 letras/s, o Al instante.
   - «Avance del diálogo», por omisión **con botón** en las conversaciones (GAG: a su ritmo).
   - En automático, cada frase queda **1,5 s + 1 s por cada 15 letras**. Hoy son 1,3 s + 0,035 s por letra (unas 28 letras/s): demasiado rápido para leer en la TV (IGDA pide letra más grande si el texto se va solo).
   - Los globitos de la pelea son automáticos con la misma regla y se pueden pasar.
8. **Íconos de botón por mando:**
   - el ícono sale del último dispositivo usado (`DetectorMando` e Input Helper), con la opción manual «Íconos de botones» (Automático, Switch, PlayStation, Xbox o Teclado);
   - nunca se escribe «A» o «X» en el texto: siempre va el ícono;
   - en Switch, **confirmar es A, a la derecha**, y volver es B; en PlayStation, confirmar es ✕;
   - los íconos de Kenney (CC0) ya están en el juego.
9. **Sacudida y movimiento:** «Sacudida de pantalla» en Sí, Reducida (la mitad) o No, más «Reducir movimiento» (ya existen; se mueven a Accesibilidad).

### Zonas de texto nuevas (propuesta para `ZonasTexto`; solo en este documento, no en el código)

Todas dentro de la zona segura de títulos. Medidas en px de la base (normal / grande):

| Zona | Lugar | Qué va | Medidas |
| --- | --- | --- | --- |
| **A. HUD** | Arriba a la izquierda, desde (32, 18) | **Solo la salud:** cara de Felipe y 9 huellas | 152×20 / 304×40 |
| **A2. Jefe** | Arriba a la derecha, hasta (608, 18) | Barra del jefe (retrato, nombre, 3 fases), **solo en la pelea** | 250×40 / 250×63 |
| **B. Diálogo** | Arriba: de y 44 a 103 (grande: de 64 a 163). Abajo, si Felipe está arriba: de y 283 a 342 (grande: de 243 a 342) | Caja de 528 px de ancho (de x 80 a 608), retrato de 52 px a la izquierda desde x 32 y franja del nombre de 15 / 26 px | 528×50 / 528×84 |
| **C. Carteles** | Centrados bajo el HUD: desde y 44 (grande: 64) | Travesura (título y una línea), fase del jefe, «PODER NUEVO». **Logro: alineado a la derecha** en la misma franja. De a uno, por la cola | alto 22 + 19 / 34 + 30 |
| **D. Palabras del mundo** | Sobre Felipe o el objeto, dentro de la zona segura y fuera de A–C | «¡CRÍTICO!», «+1 snack» | Silkscreen 16 / 32 |
| **E. Indicador de botón** | Sobre el objeto o Felipe, dentro de la zona segura | Ícono del mando más verbo | unos 91×22 / 162×38 |
| **F. Globito y avisos del jefe** | Sobre el personaje, dentro de la zona segura y fuera de A y A2 | Globito de Felipe, «¡LLENA! ¡SALTA!» | 1 línea, 19 / 30 de alto |

**Letra mínima por tipo de texto:**

| Tipo | Normal | Grande |
| --- | --- | --- |
| Diálogo y globito | Pixel Operator 16 (cuerpo 11) | Pixel Operator 32 |
| Nombre del hablante | Pixel Operator Bold 16 (hoy Pixel Operator 8: **sube**) | Bold 32 |
| Cartel | Silkscreen 16 o 24 | Silkscreen 32 o 48 |
| Etiqueta (fases I-II-III, menú, valores) | Pixel Operator Bold 16 o Silkscreen 16 (**nada de 8**) | 32 |
| Palabra del mundo | Silkscreen 16 o 24 con contorno de 1 px | 32 o 48 |
| Botón | Ícono de 16×16 y verbo en Pixel Operator 16 | Ícono de 32×32 y Pixel Operator 32 |

### Inventario: qué hay hoy en pantalla y qué se decide

Regla: **HUD mínimo.**

- En exploración, solo la salud.
- Lo demás aparece **cuando cambia** y se va.
- La barra del jefe, solo en la pelea.
- Lo que se lleva, en el menú.

| Elemento (pieza de hoy) | Hoy | Decisión | Dónde |
| --- | --- | --- | --- |
| Corazones (`Medidores` / `BarraVida`) | Siempre | **Siempre**, como 9 huellas | A |
| Contador de vidas (9 vidas) | Pausa y al perder una | **Se va**: las 9 huellas son las vidas | — |
| Collar de la Vergüenza | HUD y pausa | Al ponérselo (palabra o cartel) y en la pausa | D o C, y menú |
| Agenda (`Hud`, x/8) | Entra 2 s al cambiar | **Menú** (Libreta). El cartel de travesura ya avisa al cumplir | C y menú |
| Calcetines y fotos (`Hud`) | Entran 2 s al cambiar | Palabra «+1» sobre Felipe al recoger; el resto en el **bolsillo** | D y menú |
| Snacks (`Hud.snacks_fijos` en la pelea) | Fijos en la pelea | **Solo en la pausa (bolsillo)**, decisión del creador. Al recoger o comer: palabra sobre Felipe | D y menú |
| Barra del jefe (`PresentacionJefe`) | Pelea | **Solo en la pelea** | A2 |
| Presentación del jefe (entrada Broforce) | Al empezar la pelea | Igual, pantalla completa, con los textos dentro de la zona segura | — |
| Carteles de fase del jefe | Zona C | Al cambiar de fase | C |
| Avisos del jefe («¡LLENA! ¡SALTA!») | Sobre el jefe | Cuando hay oportunidad | F |
| Diálogo con retrato (`Dialogo`) | Arriba | En las conversaciones | B |
| Globito de Felipe (`GloboDialogo`) | En la pelea | En la pelea, en una ventana segura | F |
| Cartel de travesura, secreta y «PODER NUEVO» (`Anuncios` / `Cartel`) | Zona C | Al ocurrir, de a uno | C |
| Logro (`Medidores._dibujar_aviso`) | Zona C | Al ocurrir, a la derecha, de a uno | C |
| Palabras del mundo (`Jugo.palabra`) | Sobre el objeto | Igual, de a una, 0,9 s | D |
| Indicador de botón (`Indicador`) | Sobre Felipe | Cerca de algo usable | E |
| Íconos de ayuda (`AyudaAspi`) | Sobre Felipe | Solo la primera vez | E |
| Flecha de borde (`CamaraPelea`) | Borde de la pantalla | En el **borde de la zona segura** (hoy está en el de la pantalla) | Borde |
| Avisos del tutorial (`Pantallas`) | Tecla y texto | Como el indicador (ícono más verbo) | E |
| Pausa (`MenuUI`, Decreto real) | Menú | Menú: Continuar, Bolsillo, Ficha, Opciones, Reiniciar, Salir | Menú |
| Bolsillo (`PanelBolsillo`) | Pausa | Menú: salud, snacks, calcetines, fotos y collar | Menú |
| Ficha de Su Majestad | Pausa | Menú; en texto grande va en su propia pestaña | Menú |
| Libreta (Agenda, Tab) | Pantalla propia | Menú (Tab sigue de atajo) | Menú |
| Opciones (`PantallaOpciones`) | Pausa | Menú, más una pestaña **Accesibilidad** | Menú |
| Resumen del día | Al terminar el nivel | Pantalla completa, dentro de la zona segura y con letra ≥ 16 (hoy usa 8 en notas) | — |
| Título, introducción y final | Pantallas | Dentro de la zona segura | — |

**Para el diseñador:** la Ficha y el bolsillo comparten la pantalla en normal. En grande van en pestañas.

### Wireframes

Están en `revisiones/capturas/interfaz-rediseno/`. Cada uno viene en normal y en grande (`-grande`), y cada versión a 640×360 y ampliada (`-x2`). Muestran:

- la zona segura de títulos (rojo) y la de acción (naranja);
- la rejilla de 8 y 32 px;
- las medidas de cada caja;
- el texto real en español, con las letras del juego a su tamaño.

| Archivo | Pantalla | Qué comprueba |
| --- | --- | --- |
| `layout-00-reglas.png` | Letras a tamaño real | Qué letra cumple y cuál no |
| `layout-01-exploracion.png` | Exploración | Solo la salud, arriba a la izquierda |
| `layout-02-dialogo-valeria.png` | Diálogo de Valeria con texto largo (123 letras) | Normal: 2 líneas. Grande: 4 líneas, **paginado en 2** |
| `layout-03-dialogo-felipe.png` | Diálogo de Felipe abajo (Felipe en una repisa alta) | La caja baja si Felipe está arriba |
| `layout-04-pelea.png` | Pelea | Salud, barra del jefe, aviso sobre el jefe y globito sobre Felipe; sin snacks |
| `layout-05-carteles-logros.png` | Cartel de travesura, logro y fase | Se muestran juntos solo para medir: en el juego salen de a uno |
| `layout-06-indicador-boton.png` | Indicador sobre un plato, y los íconos de Switch, PlayStation, Xbox y teclado | Ícono más verbo, dentro de la zona segura |
| `layout-07-pausa.png` | Pausa con el bolsillo y la Ficha | Normal: los dos juntos. Grande: pestañas |
| `layout-08-opciones.png` | Accesibilidad | Tamaño y velocidad del texto, avance, sacudida, reducir movimiento, contraste alto, zona segura e íconos. En grande, 4 filas más con desplazamiento en un solo eje, y una vista previa del texto |

**Lo que muestran los wireframes:**

- **Todo cabe** en normal y en grande dentro de la zona segura, incluidos el español largo («¡TRAVESURA CUMPLIDA!», «FASE II · PERSECUCIÓN», «Coleccionista de Calcetines») y una frase de 123 letras.
- **En texto grande, el diálogo de arriba baja hasta y 163** (45 % del alto). Tapa la cabeza de un humano de pie, pero su cara ya está en el retrato, como en Celeste. Si molesta, la alternativa es poner el diálogo grande abajo, pero ahí tapa a Felipe. Recomiendo dejarlo arriba.
- **En texto grande, la barra del jefe y la salud** suman 304 + 250 px, con 54 px libres entre ellas.

### Referencias: HUD mínimo en juegos 2D de consola

Son observaciones de juego. Conviene verificarlas con capturas antes de citarlas afuera.

| Juego | Qué muestra | Qué no | Qué tomamos |
| --- | --- | --- | --- |
| Celeste | Casi nada fijo. Las fresas se cuentan al recogerlas y se van; el pelo de Madeline dice si le queda el impulso | No hay HUD de vida | Lo que cambia aparece y se va; la información en el personaje |
| Hollow Knight | Arriba a la izquierda: vasija de alma, máscaras de vida y geo | Los jefes no tienen barra de vida (solo el nombre al entrar) | La salud arriba a la izquierda, chica y gráfica (máscaras, para nosotros huellas) |
| Dead Cells | Vida, armas y habilidades abajo; barra del jefe arriba | — | La barra del jefe arriba |
| Ori and the Blind Forest | Vida y energía en celdas | Sin números | La salud como unidades contables, no como barra |
| Cuphead | Abajo a la izquierda: tarjeta de vida y cartas del súper | **Sin barra del jefe** (el avance se ve al morir) | La salud mínima y legible. Nosotros sí mostramos la barra del jefe (las fases ayudan) |
| Shovel Knight | Franja fija arriba, de borde a borde: oro, objeto, magia, vida y vida del jefe | — | La vida del jefe frente a la propia, arriba |
| Pizza Tower | Una «tele» con la cara de Peppino que reacciona, y el puntaje | Sin vida | La cara de Felipe en el HUD que reacciona al golpe y al curar |

### Fuentes

- Xbox, «Screen safe areas» (zona segura de títulos al 90 % y de acción al 95 %; 1720×1000 a 1080p): https://devdocs.xbox.com/build/core-features/graphics/overviews/screen-areas
- Xbox Accessibility Guideline 101, «Text display» (26 px a 1080p en consola, 18 px en PC, texto al 200 %, cómo se mide): https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-101-text-display
- Xbox Accessibility Guideline 102, «Contrast» (4,5:1, 3:1 y 7:1): https://devdocs.xbox.com/build/game-principles/accessibility/xag-deep-dives/xag-102-contrast
- Xbox, guías de compatibilidad portátil (leíble a 12 pulgadas: 9 y 12 px a 720p, 14 y 18 px a 1080p): https://devdocs.xbox.com/build/gdk-and-engines/handheld/handheld-guidelines-and-testcases
- Game Accessibility Guidelines, «Use an easily readable default font size» (28 px a 1080p como piso): https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/
- Game Accessibility Guidelines, «Allow the font size to be adjusted»: https://gameaccessibilityguidelines.com/allow-the-font-size-to-be-adjusted/
- Game Accessibility Guidelines, lista básica («Allow players to progress through text prompts at their own pace», «Provide high contrast between text/UI and background»): https://gameaccessibilityguidelines.com/basic/
- IGDA GA-SIG, «Text size» (32 px a 1080p; 46 px para el texto que se va solo): https://igda-gasig.org/?p=1387
- Amazon Fire TV, «Design and user experience guidelines» (UI de 10 pies): https://developer.amazon.com/docs/fire-tv/design-and-user-experience-guidelines.html
- Autodesk, «Safe display regions for TV production» (SMPTE 80 % y 90 %): https://help.autodesk.com/cloudhelp/ENU/MayaCRE-Rendering/files/GUID-13D613FF-994F-480A-AF0E-DFE06418A351.htm
- Pantallas de Switch: 6,2" a 720p (unos 237 ppp, ComputerBase): https://www.computerbase.de/2016-10/nintendo-switch-touch-display-6.2-zoll-720p/; Switch OLED, 7" a 720p (unos 210 ppp): https://dimensions.com/element/nintendo-switch-oled
- Disposición de botones de Switch (A a la derecha confirma): https://www.nintendolife.com/news/2021/03/talking_point_the_problem_with_the_x_button

## Por qué

El creador dijo que la interfaz del juego 2D (corazones, barra del jefe, contador, diálogos y carteles) «no le cuadra» y la quiere **fresca**. Se consultó a dos IA:

- **ChatGPT:** `revisiones/2026-10-23-chatgpt-interfaz.md` y su lámina `revisiones/capturas/interfaz-rediseno/chatgpt-interfaz-lamina.png`. Propuso 2 variantes: «Clásico cálido» y «Moderno expresivo».
- **Gemini:** `revisiones/2026-10-23-gemini-interfaz.md` y sus maquetas `gemini-interfaz-1-pergamino.png` y `gemini-interfaz-2-moderna.png`, en la misma carpeta.

Se compararon con la interfaz actual (`actual-*.png`, en la misma carpeta).

**El creador eligió el diálogo de la variante 2 de ChatGPT** (`elegido-dialogo-moderno.png`): retrato grande que se sale del marco, sobre un fondo inclinado del color del personaje, con fragmentos; nombre en una franja diagonal del mismo color; caja oscura con cortes en diagonal y líneas claras arriba y abajo, y una flecha para avanzar.

**Su crítica:** «La propuesta de dirección de arte es buena, pero ni el mismo la aplicó». Las maquetas de ChatGPT no cumplen su propia sección 3: vuelven a poner corazones, globitos genéricos y una mezcla de estilos. Esta versión la aplica entera y con un solo lenguaje.

## Decisiones cerradas por el creador (2026-10-23)

1. **Un solo lenguaje dinámico en toda la interfaz, sin pergamino.** Es el lenguaje del cuadro elegido: diagonales, fondo oscuro con borde claro, color por personaje, fragmentos y energía. Se usa en el HUD, el diálogo, el globito, los carteles de travesura y de logro, el **menú de pausa** y la **Ficha de Su Majestad**. Sus palabras: «hay que ajustar el arte para que sea más dinámico; siento que el pergamino no encaja».
2. **La salud son huellas** («que la vida sea la huella está lindo»). La huella es la estrella del HUD: almohadilla grande y 4 deditos, en pixel art limpio. Tiene 5 estados (llena, media, vacía, golpe y curando) y su animación al perder y al curar.
3. **Las 9 vidas SON la salud:** 9 huellas que se gastan con los golpes. **No hay medallón con número** ni reintentos aparte en el HUD.
4. **Assets finales con Gemini y ChatGPT** desde la PC del creador, con los encargos de abajo. El creador elige A, B o C antes de generar.
5. **Multiplataforma** (Switch portátil y TV, PC y PlayStation): el texto se lee en todas. Reglas en «Layout y legibilidad multiplataforma».
6. **Los snacks salen de la pantalla principal:** solo en la pausa (bolsillo).

### Ojo: la decisión 3 cambia el diseño de juego

Así funciona hoy:

- Felipe tiene **5 corazones**: es su pieza `Vida`, con `maximo = 5` en `escenas/entidades/felipe.tscn`.
- Aparte tiene **9 vidas como reintentos** (`Felipe.VIDAS_MAX`). Al quedarse sin corazones, `EstadoDesmayado` le quita una vida, sale el gatito fantasma y reaparece en el último punto de descanso. Sin vidas, vuelven las 9, pero con el Collar de la Vergüenza.
- Las vidas se ven en la pausa (`PanelBolsillo`).

Con «9 huellas = salud», ese sistema doble desaparece. **Antes de implementar hay que revisarlo con el diseñador** (agente de diseño o `/revision-diseno`):

- **Cuánto quita cada golpe:** ¿1 huella siempre? ¿Los jefes quitan 2? ¿La embestida de A.S.P.I. quita más que una bola de pelo?
- **Curación:** hoy los snacks curan y engordan (pilar 4). ¿Un snack devuelve 1 huella? ¿Puede devolver media?
- **Qué pasa al llegar a 0:** hoy es el desmayo, el gatito fantasma y el Collar de la Vergüenza. ¿Se queda igual, pero al acabarse las 9 huellas? ¿Qué pasa con el pilar 3 («Siempre te sales con la suya») y el anti-pilar «no castiga»?
- **Media huella:** solo existe si hay golpes o curas de medio punto. `Vida` cuenta en enteros: haría falta `maximo = 18` (2 puntos por huella). Si no hay medios, el estado «media» no se usa.
- **Textos y pruebas:** el desmayo y `FIN_VIDAS` de `textos.csv` cambian, al igual que el bolsillo de la pausa y las pruebas que cuentan corazones.

Hasta que eso se decida, el arte trae los 5 estados de la huella, y el HUD de las láminas muestra 6 huellas y media de 9.

## Dirección de arte: opciones (EN PAUSA hasta aprobar el layout)

Hay una lámina por opción, a 640×360 y ampliada ×2: `revisiones/capturas/interfaz-rediseno/direccion-arte-{A,B,C}.png` y `-x2.png`.

- **A · Corte diagonal:** es la más cercana al cuadro elegido. Usa cajas ciruela oscuro con dos esquinas cortadas en diagonal, líneas crema de 1 px arriba y abajo, bloques sólidos del color de cada personaje y fragmentos triangulares.
- **B · Oro de la corte:** es la más «real» y dorada. Usa azul tinta con filete de oro y línea crema, diagonales suaves, esquinas biseladas con gemas, nombres en oro sobre oscuro y el fondo del retrato con rayas de terciopelo.
- **C · Cómic travieso:** es la más juguetona. Usa contorno negro con borde claro de 2 px, diagonales fuertes, una sombra dura del color del personaje, trama de puntos, estallidos y estrellas, y cintas con cola de golondrina.

Cada lámina trae:

- el HUD en contexto (huellas, contador de snacks y barra de A.S.P.I.);
- el diálogo de Valeria sobre la sala real;
- el globito de Felipe sobre él, en el estudio real;
- el menú de pausa y la Ficha en miniatura;
- el cartel de travesura y el logro;
- la huella en sus 5 estados;
- la paleta en hex, las letras con sus tamaños y la regla de forma y de movimiento.

Las dibuja `siete-vidas/herramientas/interfaz_v2_laminas.py`, que dibuja por código: es una referencia de dirección, no el arte final.

### En qué se diferencian

| | A · Corte diagonal | B · Oro de la corte | C · Cómic travieso |
| --- | --- | --- | --- |
| Ángulo de la diagonal | 1:3 (unos 18°); tope de 10 px en paneles altos | 1:6 (unos 9,5°); tope de 6 px | 1:2 (unos 26,5°); tope de 14 px |
| Borde | Contorno oscuro de 1 px y líneas claras de 1 px arriba y abajo, a 2 px | Contorno de 1 px, filete de oro de 1 px, línea oscura y fondo | Contorno negro de 1 px y borde claro de 2 px |
| Esquinas | 2 cortadas en diagonal (4 px) | Las 4 biseladas a 45° (3 px), con gemas en las puntas | Paralelogramo puro |
| Sombra | Dura, de 2 px, oscura | Dura, de 2 px, oscura | Dura, de 3 px, **del color** del personaje |
| Franja del nombre | Bloque del color, con el texto oscuro | Oscura con filete de oro, con el texto en el color claro del personaje | Cinta del color con trama de puntos y cola de golondrina |
| Fondo del retrato | Color liso y triángulos | Color con rayas de terciopelo y filete | Color con trama de puntos y estrellas |
| Huellas en el HUD | 1 fila de 9, con la cara chica de Felipe | 2 filas (5 + 4), más compactas | 1 fila de 9 que «rebota» (±1 px alterno) |
| Globito | Caja cortada con orejitas | Caja biselada de oro con orejitas | Estallido de picos con orejitas |
| Sello del cartel | Rombo | Octágono | Estrella de 8 puntas |
| Movimiento | Barrido de 140 ms y rebote de 4 px | Deslizamiento de 180 ms y un brillo que recorre el filete | Estirar 120 % → 90 % → 100 % y temblor del texto grande |

### Paleta de cada opción (hex)

| Uso | A | B | C |
| --- | --- | --- | --- |
| Fondo de los paneles grandes | #241A26 | #1C1B2C | #1A1014 |
| Panel (cajas) | #30242C | #28263A | #2B1A2E |
| Línea o borde claro | #F4E2BB | #D8AC67 (oro) | #FFE7B0 |
| Texto | #FFF0D5 | #F4E2BB | #FFF6E0 |
| Apagado (etiquetas, vacío) | #8A7480 | #7C7488 | #8C6F86 |
| Contorno | #120C12 | #0E0D16 | #0A0608 |
| **Felipe** (dorado, rey) | #E8B04A | #F0C04E | #FFC53D |
| **Valeria** (magenta) | #D8336B | #B8325E | #FF4F9A |
| **A.S.P.I.** | #E04848 (rojo) | #4CC9E0 (cian máquina) | #FF5A3C (rojo) |
| Segundo color de A.S.P.I. | #4CC9E0 | #E04848 | #3FD8E8 |

La paleta sale de la sección 3.7 de ChatGPT: carbón ciruela #30242C, crema pergamino #F4E2BB, marfil #FFF0D5, oro real #D8AC67 y coral. Se oscureció y se le sumaron los colores por personaje del cuadro elegido.

**Un color, un significado (lección 50):** en el juego, el rojo es peligro y el amarillo #FFE066 (`oportunidad`) es la oportunidad.

- El **dorado de Felipe** tiene que distinguirse del amarillo de oportunidad. Por eso va más ocre o anaranjado, y la oportunidad sigue con su borde y su texto de acción («¡LLENA! ¡SALTA!»).
- **A.S.P.I. en rojo** (A y C) coincide con el peligro. Tiene sentido, porque ella es la amenaza.
- **A.S.P.I. en cian** (B) la separa de los avisos de peligro. A cambio, choca con el azul de la «defensa» de la Ficha.

### Lo común a las tres

- **Letras:** son las que ya trae el juego, sin sumar ninguna (todas pixel y libres).
  - Nombres y números: **Pixel Operator Bold 16**.
  - Texto del diálogo y del globito: **Pixel Operator 16**.
  - Carteles: **Silkscreen 16** (o 24 en el título de una travesura grande).
  - Etiquetas cortas, como «FASE II», «SNACKS» y los botones del menú: **Silkscreen 8**.
  - Todo se dibuja a su tamaño de diseño o a un múltiplo, sin suavizado.
  - Se cumple la lección 38: 16 px o más en carteles y palabras, y una sola línea por cartel.
  - ChatGPT sugería Press Start 2P, y Gemini, Silver o VT323. No hacen falta: Pixel Operator y Silkscreen ya cubren la ñ, las tildes, ¿ y ¡ (lo revisa `prueba_zonas_texto`).
- **Zonas de texto sin cambios** (`ZonasTexto`):
  - HUD en y 0–26;
  - diálogo arriba, en y 30–80;
  - carteles en y 30–90, de a uno;
  - el globito, sobre Felipe.

  El cuadro elegido estaba abajo, pero aquí va en la zona B, como hoy.
- **Medidas a 640×360** (todas las opciones):

  | Pieza | Medida |
  | --- | --- |
  | Huella | 13×12 px con su contorno |
  | Fila de 9 huellas con la cara | unos 150×20 px |
  | Diálogo | unos 600×40 px de caja, con el retrato de 52 px de alto saliendo 8 px por arriba |
  | Franja del nombre | 13 px de alto |
  | Barra del jefe | 250×26 px |
  | Contador | 18 px de alto |
  | Globito | 18 px de alto |
  | Cartel | 22 px de franja más una línea de 17 px |
  | Logro | 20 px de alto |

- **Huella:** almohadilla grande y 4 deditos, contorno de 1 px, luz arriba y sombra abajo. Sus estados:

  | Estado | Cómo se ve | Animación |
  | --- | --- | --- |
  | Llena | Color de Felipe | — |
  | Media | Mitad izquierda llena | — |
  | Vacía | Panel apagado | — |
  | Golpe | Blanca | Al perder: destello de 60 ms, se agrieta o pierde el color, rebota 2–3 px y queda vacía (140–240 ms) |
  | Curando | Más clara | Al curar: se llena de abajo arriba en 200–240 ms, con un brillo |

  Así lo piden ChatGPT 4.1–4.2 y el coordinador. Con varias huellas, la cascada lleva un intervalo de 60 ms.
- **Barra del jefe:**
  - retrato chico sobre fondo inclinado y nombre en franja;
  - 3 segmentos con cortes diagonales y las marcas I, II y III, con la fase activa en su color;
  - **2 capas:** el valor real y el «daño reciente» claro, que baja 300 ms después.

  En el cambio de fase, el segmento pulsa y el marco tiembla una vez. En un golpe chico no se sacude (ChatGPT 4.3).
- **Contador:** ícono más número más qué cuenta («SNACKS»).
- **Carteles:**
  - **Travesura:** franja diagonal grande del color de Felipe que entra barriendo, con sello de huella, título en Silkscreen 16 y el nombre en una segunda franja oscura de 16 px. Se inspira en Persona 5, Hades y Pizza Tower.
  - **Logro:** etiqueta diagonal que entra deslizando desde un costado, con el ícono, y se va.
  - Ninguno tapa la acción: los dos van en la zona C, de a uno, y esperan al diálogo.
- **Pausa y Ficha:** el mismo lenguaje.
  - Panel oscuro, franja «PAUSA» del color de Felipe y el botón con foco como bloque diagonal dorado.
  - La Ficha lleva su retrato sobre el fondo inclinado dorado, «SU MAJESTAD» en franja y barras de estadística con puntas en diagonal.
  - **Sin pergamino ni cojín.**
- **Accesibilidad:** con «Reducir movimiento» no hay rebotes, temblores ni fragmentos que vuelan, solo fundidos cortos. Las fases no se distinguen solo por color: también llevan los números romanos.

### Cómo cumple la dirección de ChatGPT (sección 3) y el cuadro elegido

| Punto de ChatGPT | Cómo queda |
| --- | --- |
| Vida: 9 vidas con estilo gatuno, huellas | 9 huellas = salud, con la cara chica de Felipe. Sin corazones (su maqueta los volvía a poner) |
| Jefe: marco elegante y 3 fases | Barra en el mismo lenguaje, con retrato, franja, 3 segmentos I-II-III y 2 capas |
| Diálogo: retrato grande y expresiones | Retrato de 52 px que se sale del marco. Usa las 9 caras de Felipe y las 4 de Valeria que ya existen, sin caras nuevas |
| Globito con forma de gato | Orejitas, cola corta y huellita en la cola. Una línea. Sin retrato |
| Carteles: pergamino con sello real | **Se cambió por decisión del creador:** franja diagonal dinámica con sello de huella estilizado. Se queda la idea del sello; se va el pergamino |
| Paleta hex | Su paleta base, oscurecida, con color por personaje (tabla de arriba) |
| Tipografía | Letras pixel libres del juego, con mínimos de 8 px en etiquetas y 16 px en texto y carteles (su tabla de tamaños) |
| Jugo (sección 4) | Duraciones en cada lámina y en la tabla de la huella. El globito salta 3–5 px; el cartel golpea y vibra; el diálogo sube 8–12 px y sale en 120–180 ms |
| Riesgo «dos direcciones de arte» | Se evita con **un solo lenguaje** en toda la interfaz, incluidos la pausa y los carteles |

De Gemini se toma:

- el número grande y legible;
- el fondo temático detrás del retrato;
- el nombre en el color del personaje (Felipe dorado, Valeria magenta);
- la barra del jefe con 3 segmentos claros.

Se deja fuera su pergamino o «Edicto Real» (decisión del creador) y la corona dentro del retrato: el retrato es el de siempre.

## Qué cambiará en el juego (cuando se elija; no ahora)

Solo como mapa, sin plan detallado:

- **El tema** (`datos/ui/tema.tres`, vía `Estilo`): colores nuevos por nombre (`ui_fondo`, `ui_panel`, `ui_linea`, `ui_texto`, `ui_apagado`, `ui_contorno`, `personaje_felipe`, `personaje_valeria`, `personaje_aspi`) y estilos de 9 partes nuevos.
- **`BarraVida`:** la forma `CORAZONES` pasa a `HUELLAS` (9, en una o dos filas), y la `BARRA` del jefe suma la capa de daño reciente y los segmentos.
- **El cuadro de diálogo** (`cuadro_dialogo.tscn` y `Dialogo`): el fondo del retrato y la franja del nombre según el personaje.
- **`GloboDialogo`**, **`ContadorRecurso`**, **`Cartel`**, el aviso de logro de `Medidores`, **`MenuUI` y `BotonMenu`** (datos de botón nuevos) y **`FichaSuMajestad`**.
- **El kit «Decreto real»** (`assets/ui/decreto/`) deja de usarse en la interfaz. Por la regla de la memoria, lo descartado se borra cuando la pieza nueva lo reemplace.

Las memorias que hay que tocar al implementar son:

- `02-guia-felipe.md`: la vida y las acciones;
- `03-arte-y-herramientas.md`: los assets;
- `07-arquitectura.md`: la interfaz y las zonas;
- `05-estado-actual.md`.

## Encargos para Gemini y ChatGPT (uno por opción; se pega el de la opción elegida)

**Cómo usarlos:**

- Se pega el texto común más el de la opción elegida.
- Se adjuntan las referencias:
  - `direccion-arte-<letra>-x2.png`, que manda en forma y color;
  - `elegido-dialogo-moderno.png`;
  - `actual-hud-dialogo.png`, para el estilo del mundo.
- **Mínimo 5 intentos** por imagen (regla del proyecto): otras semillas o un chat nuevo. Se comparan con la lámina y se elige el mejor. El plan gratis de ChatGPT tiene un tope de imágenes y adjuntos por día, así que conviene repartir las piezas entre los dos y entre días.
- Después, Claude recorta las piezas, las lleva a la escala del juego, las ajusta a la paleta exacta y arma los 9 parches.

### Texto común (va al principio de cualquiera de los tres)

```
Hoja de piezas sueltas de interfaz (UI) para un videojuego 2D en pixel art, resolución base 640x360.
Reglas:
- Fondo blanco puro #FFFFFF, liso. Nada blanco puro dentro de las piezas.
- Cada pieza separada de las demás por al menos 40 px de blanco. Ninguna pieza toca otra.
- SIN TEXTO, sin letras ni números: el juego escribe todo encima.
- Pixel art nítido: píxeles cuadrados, sin suavizado, sin desenfoque, sin degradados suaves, sin brillo difuso.
  Dibuja cada píxel del juego como un bloque exacto de 4x4 píxeles de la imagen.
- Contorno oscuro de 1 píxel del juego alrededor de cada pieza.
- Vista de frente, plana. Luz desde arriba a la izquierda.
- Usa solo los colores de la paleta indicada.
- Sin personajes: el juego pone sus propios retratos.
- Las piezas que se estiran (marcos en 9 partes) deben tener el centro liso y los bordes iguales a lo largo,
  para poder cortarlas en 9 partes.
Piezas (proporciones a escala del juego, en píxeles del juego):
1. Marco del cuadro de diálogo, para cortar en 9 partes: caja ancha de 300x40, con los lados izquierdo y derecho en diagonal.
2. Franja del nombre: 64x13, en diagonal, en 3 colores (dorado, magenta y el color de A.S.P.I.).
3. Fondo del retrato: 58x50, inclinado, en los mismos 3 colores, con sus fragmentos alrededor.
4. Huella de gato de 13x12 (almohadilla grande y 4 deditos) en 5 estados, en fila: llena, media (mitad izquierda llena),
   vacía, golpe (blanca) y curando (más clara, con un brillo).
5. Barra del jefe: marco de 220x14 dividido en 3 segmentos iguales por cortes diagonales, vacío por dentro.
   Aparte: una tira de relleno de 4 px de alto del color del jefe y otra crema (daño reciente).
   Aparte: el marco chico del retrato del jefe, de 30x26, inclinado.
6. Globito de pensamiento de gato: caja de 120x18 para cortar en 9 partes, con 2 orejitas de gato arriba, y aparte
   su cola corta, que termina en una huellita.
7. Cartel de travesura: franja diagonal grande de 220x22 color dorado y, aparte, el sello: una huella dentro de
   su forma (ver la opción).
8. Etiqueta de logro: 220x20, en diagonal, con un ícono de huella en un rombo a la izquierda.
9. Menú de pausa: panel de 68x84 para 9 partes; botón de 64x13 en 3 estados (normal, resaltado y apretado);
   franja de título de 60x12.
10. Ficha: panel de 82x84 para 9 partes y barra de estadística de 30x7 con puntas en diagonal (marco vacío y
    relleno en 3 colores).
11. Contador: marco de 80x18 para 9 partes e ícono de snack (pescadito de croqueta) de 12x7.
12. Fragmentos sueltos de 2 a 7 px en los 3 colores de personaje.
```

### Opción A · Corte diagonal

```
Estilo: moderno y expresivo, como un cuadro de diálogo de juego de acción indie. Cajas oscuras con
dos esquinas cortadas en diagonal (arriba a la izquierda y abajo a la derecha), una línea clara de 1 px
arriba y otra abajo, a 2 px del borde. Diagonales de 1 px de corrimiento por cada 3 px de alto (unos 18 grados).
Sombra dura de 2 px abajo a la derecha, oscura. Fragmentos: triángulos chicos del color del personaje.
Franjas de nombre: bloque sólido del color del personaje. Sello del cartel: rombo oscuro con la huella dorada.
Paleta: fondo #241A26, panel #30242C, línea #F4E2BB, texto #FFF0D5, apagado #8A7480, contorno #120C12,
Felipe dorado #E8B04A, Valeria magenta #D8336B, A.S.P.I. rojo #E04848, segundo color #4CC9E0.
```

### Opción B · Oro de la corte

```
Estilo: realeza elegante, pero dinámico (nada de pergamino ni madera). Cajas azul tinta con un filete de oro
de 1 px, una línea oscura de 1 px y el fondo; las 4 esquinas biseladas a 45 grados (3 px), con una gema en
rombo en el centro de cada punta. Diagonales suaves: 1 px de corrimiento por cada 6 px de alto (unos 9,5 grados).
Sombra dura de 2 px. Franjas de nombre oscuras con filete de oro. Fondo del retrato del color del personaje con
rayas diagonales finas, como terciopelo, y filete de oro. Fragmentos: chispas de oro en cruz.
Sello del cartel: octágono oscuro con filete de oro y la huella dorada.
Paleta: fondo #1C1B2C, panel #28263A, oro #D8AC67, texto #F4E2BB, apagado #7C7488, contorno #0E0D16,
Felipe dorado #F0C04E, Valeria magenta #B8325E, A.S.P.I. cian máquina #4CC9E0, segundo color #E04848.
```

### Opción C · Cómic travieso

```
Estilo: cómic juguetón con mucha energía (Pizza Tower, Persona 5), pero legible. Cajas oscuras con borde claro
de 2 px y contorno negro de 1 px; paralelogramos puros con diagonales fuertes: 1 px de corrimiento por cada 2 px
de alto (unos 26,5 grados). Sombra dura de 3 px DEL COLOR del personaje (no gris). Trama de puntos en los
bloques de color. Franjas de nombre como cinta con cola de golondrina. Globito con borde de picos (estallido).
Fragmentos: estrellas de 4 puntas y estallidos. Sello del cartel: estrella de 8 puntas con la huella.
Paleta: fondo #1A1014, panel #2B1A2E, borde claro #FFE7B0, texto #FFF6E0, apagado #8C6F86, contorno #0A0608,
Felipe dorado #FFC53D, Valeria magenta #FF4F9A, A.S.P.I. rojo #FF5A3C, segundo color #3FD8E8.
```

Las imágenes se guardan en `siete-vidas/arte/referencias/gemini/interfaz-v2/` o `.../chatgpt/interfaz-v2/`, con el número de intento en el nombre.
