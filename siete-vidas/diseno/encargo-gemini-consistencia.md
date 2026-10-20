# Encargo a Gemini: tanda de consistencia (nivel 1 + interfaz)

Revisión de consistencia del 2026-10-20 (`revision.md`, hallazgos B2, G1, G2, G6, G7, G9 y M1). Una sola tanda, **2 imágenes, 11 piezas**. Antes de generar, el creador le escribe "sí, adelante" en su propio chat.

**Texto común (pegar al inicio de las dos imágenes):**
> Mismo estilo que la tanda 1 del nivel 1 y que `menu-estambre.png`: pixel art chibi con sombreado cel, dos tonos planos por color, contorno café oscuro cerrado de 1 px, sin degradados, sin antialias, sin sombra proyectada, paleta cálida del Barrio Viejo (terracota, crema, madera, atardecer), luz desde arriba a la izquierda. Vista lateral recta, de frente, como se ve en la pared en un juego de plataformas. **Fondo blanco puro #FFFFFF liso**; cada pieza separada de las demás por al menos 40 px de blanco; **sin texto, sin letras, sin números, sin líneas de medida**. Nada de la pieza en blanco puro: lo blanco (papel, vidrio pintado, cartón) va en crema #EDE4D6 o más oscuro. **Excepción:** los huecos que se piden "en blanco puro" se vuelven transparentes. Cada pieza ocupa su celda grande y respeta la proporción ancho : alto indicada. Adjuntar como referencias de estilo `siete-vidas/arte/felipe/felipe-A-base.png`, `siete-vidas/arte/referencias/gemini/muebles-sala.png` y `siete-vidas/arte/referencias/gemini/menu-estambre.png`, más la referencia propia de cada pieza.

---

## Imagen 1: `consistencia-casa.png` (4 piezas del mundo)

| # | Pieza | Forma, vista y proporción (ancho : alto) | Tamaño final en el juego | Referencia |
| --- | --- | --- | --- | --- |
| 1 | **Marco de ventana de la casa, vacío** | Ventana de madera de frente, con **la misma madera, molduras y alféizar que la ventana de la sala**, pero sin persiana: marco ancho de grosor parejo (unos 18 px a escala por lado y 26 arriba), parante en cruz de madera que divide el vidrio en 4 y alféizar que sobresale abajo. Los 4 huecos del vidrio en **blanco puro** (se vuelven transparentes y detrás se ve la vista). Proporción 1,2 : 1 | **186 × 154** (hueco de 150 × 120, alféizar a 109 px del piso). Una sola pieza, sin estirar, en cocina, dormitorio, estudio y pasillo | `ventanas-patio.png` (ventana de la sala) |
| 2 | **Vista del pasillo: toldo con pizza** | Rectángulo **lleno, sin marco**: la pared de un patio de luz al atardecer (crema rosado) y, abajo, el toldo a rayas terracota y crema de un vecino. Encima del toldo, una caja de pizza abierta con la tapa levantada, mancha de grasa y la pizza a la vista. Tonos un poco azulados de lejanía. Proporción 1,25 : 1 | **150 × 120**, detrás del marco 1. La caja de pizza mide al menos 34 × 24 en el juego (se ve desde lejos, pero se lee). El vapor lo pone el código | `ventanas-patio.png` (ventana del pasillo actual) |
| 3 | **Armario bajo la escalera** | Vista lateral del espacio bajo una escalera de madera que sube de izquierda a derecha con 7 peldaños: el frente es un **triángulo rectángulo** (el lado inclinado sigue la escalera y el lado alto queda a la derecha) más un tramo rectangular a la derecha, bajo el descanso. Cerrado con tablas verticales de madera café, una moldura bajo el borde inclinado y un zócalo propio. En el medio, una **puertita con la parte de arriba inclinada como la escalera, entreabierta**, con un pomo dorado; por la abertura se ve oscuro y una caja de cartón. Arriba a la derecha, el **descanso**: una tabla gruesa de canto claro. **No dibujar la escalera**, solo lo que va debajo (la escalera ya existe y va encima). Proporción 2,1 : 1 | **318 × 150**: el triángulo ocupa los primeros 214 px (sube 150 px como la escalera), el tramo recto los 104 restantes y el descanso es una tabla de 108 × 14 arriba a la derecha. La puerta mide unos 50 × 70 | `escalera-dos-capas.png` (para que calce bajo el larguero) |
| 4 | **Teclado de computador** | Teclado mecánico chico, gris carbón, visto de frente y un poco desde arriba, con teclas crema en 4 filas, una barra espaciadora y un cable corto que sale por detrás. Proporción 2,2 : 1 | **52 × 24**, frente al monitor del estudio, apoyado en el medio del escritorio | `arriba-extra.png` (monitor) |

---

> **En espera (2026-10-20):** la imagen 2 se pide después de que el creador elija el menú nuevo (`encargo-gemini-menu-ideas.md`), para que todo el kit de interfaz siga esa dirección. Por ahora se pide solo la imagen 1.

## Imagen 2: `consistencia-interfaz.png` (7 piezas de interfaz)

Interfaz "hecha en la casa": madera y estambre como el menú de pausa. El texto lo pone el juego con la fuente pixel. Todo lo que se usa en 9 partes lleva **borde de grosor parejo y centro liso** (sin dibujos en el medio).

| # | Pieza | Forma, vista y proporción (ancho : alto) | Tamaño final en el juego | Referencia |
| --- | --- | --- | --- | --- |
| 5 | **Panel de madera oscura (9 partes)** | Tabla de madera café oscura, de frente, con un borde de madera más clara de grosor parejo (4 px a escala) y esquinas apenas redondeadas, con un clavito en cada esquina. Centro liso, de un solo tono oscuro para que se lea el texto crema encima. Proporción 4 : 1 | Se estira: diálogo de 620 × 56, contadores del HUD de 50 × 24, resumen de 420 × 300 y franja de fase. Bordes de **6 px** en el juego | `menu-estambre.png` (letrero) |
| 6 | **4 íconos del HUD**, en fila | a) libreta de espiral con renglones y una huella de gato en la tapa; b) calcetín a rayas rojo y crema; c) foto polaroid con una mujer en pijama de unicornio; d) bolsita de premios con un pescadito dibujado. Cada uno en un **cuadrado** de igual tamaño, con el contorno grueso y claro para que se lea chico | **20 × 20** cada uno, a escala 1 (sin reducir en el juego) | `comida-grande.png` (bolsita), `arriba-extra.png` (calcetín) |
| 7 | **Marco del retrato** | Marco cuadrado de madera, como un cuadro pequeño colgado, con el borde de 4 px a escala y el **hueco central en blanco puro** (transparente). Proporción 1 : 1 | **66 × 66** exterior, hueco de 58 × 58 (el retrato va detrás) | `cuadros.png` (marcos) |
| 8 | **Etiqueta de logro** | Etiqueta de cartón crema colgada de un trocito de estambre terracota con una argolla, con un borde de cartón más oscuro y una esquina doblada. Lisa por dentro (el texto va encima). Proporción 4 : 1 | **200 × 44** (notificación de logro, arriba a la derecha) | `menu-estambre.png` |
| 9 | **Letrero de título** | El letrero principal del menú en grande: tabla de madera clara con borde oscuro, colgada de **dos** hilos de estambre, con una coronita dorada en la esquina de arriba a la derecha y un rasguño de garra en la esquina de abajo a la izquierda. Liso por dentro. Proporción 3 : 1 | **270 × 90**, debajo del ovillo del menú | `menu-estambre.png` (letrero principal) |
| 10 | **Marco de la barra del jefe** | Barra horizontal de metal gris oscuro como la carcasa de A.S.P.I., con remaches, un sensor rojo pequeño en el extremo izquierdo y el **interior en blanco puro** (transparente; ahí va la vida roja por código). Proporción 10 : 1 | **250 × 26**, interior de 232 × 10 | `aspi-gemini-1.png` |
| 11 | **Cinta de cartel** | Cinta de tela terracota, recta y horizontal, con los extremos cortados en V y un pliegue en cada punta. Lisa en el medio. Proporción 8 : 1 | **400 × 44** (para «¡TRAVESURA CUMPLIDA!», «FASE 1» y «¡BATALLA INICIADA!»; el código la inclina como hoy, en pasos de 1 px) | `menu-estambre.png` |

---

**Guardar** en `siete-vidas/arte/referencias/gemini/consistencia-casa.png` y `consistencia-interfaz.png` y subir en un solo commit a `claude/split-bill-csubjd` ("Arte de consistencia: ventanas, armario, teclado y kit de interfaz, generado con Gemini").

**Al integrar (sesión del juego, 0 créditos):**
- **Herramientas:**
  - Las piezas 1 a 4 se procesan con `preparar_arte_nivel.py`: se quita el blanco encerrado en los huecos, se recorta cada pieza a su borde opaco y se escala sin suavizar al tamaño final.
  - Las piezas 5 a 11 se procesan con `preparar_menu_estambre.py`: se divide por el pixel del dibujo para que cada pixel quede en un pixel del juego.
- **Hay que medir:**
  - el hueco del marco (150 × 120);
  - que el armario calce con el larguero de `escalera_peldanos` usando las máscaras de pixeles (lección 36);
  - que los bordes del panel 9 partes queden parejos.
- **Se borra el código que queda sin uso:** `_marco_9` y el parante, `_dibujar_ventana_pasillo`, `_dibujar_armario_escalera`, `_dibujar_teclado`, los `draw_rect` de los paneles y el ícono de código de la foto.
