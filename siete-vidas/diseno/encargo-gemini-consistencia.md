# Encargo a Gemini: tanda de consistencia (nivel 1 + interfaz)

Revisión de consistencia del 2026-10-20 (`revision.md`, hallazgos B2, G1, G2, G6, G7, G9 y M1). Una sola tanda, **2 imágenes, 11 piezas**. Antes de generar, el creador le escribe "sí, adelante" en su propio chat.

**Texto común (pegar al inicio de las dos imágenes):**
> Mismo estilo que la tanda 1 del nivel 1: pixel art chibi con sombreado cel, dos tonos planos por color, contorno café oscuro cerrado de 1 px, sin degradados, sin antialias, sin sombra proyectada, paleta cálida del Barrio Viejo (terracota, crema, madera, atardecer), luz desde arriba a la izquierda. Vista lateral recta, de frente, como se ve en la pared en un juego de plataformas. **Fondo blanco puro #FFFFFF liso**; cada pieza separada de las demás por al menos 40 px de blanco; **sin texto, sin letras, sin números, sin líneas de medida**. Nada de la pieza en blanco puro: lo blanco (papel, vidrio pintado, cartón) va en crema #EDE4D6 o más oscuro. **Excepción:** los huecos que se piden "en blanco puro" se vuelven transparentes. Cada pieza ocupa su celda grande y respeta la proporción ancho : alto indicada. Adjuntar como referencias de estilo `siete-vidas/arte/felipe/felipe-A-base.png`, `siete-vidas/arte/referencias/gemini/muebles-sala.png`, más la referencia propia de cada pieza.

---

## Imagen 1: `consistencia-casa.png` (4 piezas del mundo)

| # | Pieza | Forma, vista y proporción (ancho : alto) | Tamaño final en el juego | Referencia |
| --- | --- | --- | --- | --- |
| 1 | **Marco de ventana de la casa, vacío** | Ventana de madera de frente, con **la misma madera, molduras y alféizar que la ventana de la sala**, pero sin persiana: marco ancho de grosor parejo (unos 18 px a escala por lado y 26 arriba), parante en cruz de madera que divide el vidrio en 4 y alféizar que sobresale abajo. Los 4 huecos del vidrio en **blanco puro** (se vuelven transparentes y detrás se ve la vista). Proporción 1,2 : 1 | **186 × 154** (hueco de 150 × 120, alféizar a 109 px del piso). Una sola pieza, sin estirar, en cocina, dormitorio, estudio y pasillo | `ventanas-patio.png` (ventana de la sala) |
| 2 | **Vista del pasillo: toldo con pizza** | Rectángulo **lleno, sin marco**: la pared de un patio de luz al atardecer (crema rosado) y, abajo, el toldo a rayas terracota y crema de un vecino. Encima del toldo, una caja de pizza abierta con la tapa levantada, mancha de grasa y la pizza a la vista. Tonos un poco azulados de lejanía. Proporción 1,25 : 1 | **150 × 120**, detrás del marco 1. La caja de pizza mide al menos 34 × 24 en el juego (se ve desde lejos, pero se lee). El vapor lo pone el código | `ventanas-patio.png` (ventana del pasillo actual) |
| 3 | **Armario bajo la escalera** | Vista lateral del espacio bajo una escalera de madera que sube de izquierda a derecha con 7 peldaños: el frente es un **triángulo rectángulo** (el lado inclinado sigue la escalera y el lado alto queda a la derecha) más un tramo rectangular a la derecha, bajo el descanso. Cerrado con tablas verticales de madera café, una moldura bajo el borde inclinado y un zócalo propio. En el medio, una **puertita con la parte de arriba inclinada como la escalera, entreabierta**, con un pomo dorado; por la abertura se ve oscuro y una caja de cartón. Arriba a la derecha, el **descanso**: una tabla gruesa de canto claro. **No dibujar la escalera**, solo lo que va debajo (la escalera ya existe y va encima). Proporción 2,1 : 1 | **318 × 150**: el triángulo ocupa los primeros 214 px (sube 150 px como la escalera), el tramo recto los 104 restantes y el descanso es una tabla de 108 × 14 arriba a la derecha. La puerta mide unos 50 × 70 | `escalera-dos-capas.png` (para que calce bajo el larguero) |
| 4 | **Teclado de computador** | Teclado mecánico chico, gris carbón, visto de frente y un poco desde arriba, con teclas crema en 4 filas, una barra espaciadora y un cable corto que sale por detrás. Proporción 2,2 : 1 | **52 × 24**, frente al monitor del estudio, apoyado en el medio del escritorio | `arriba-extra.png` (monitor) |

---

> **Imagen 2 reemplazada (2026-10-20):** el creador eligió el menú «Decreto real»; el kit de interfaz salió de
> `kit-interfaz-decreto.png` y `kit-interfaz-decreto-correccion.png` (ver `memoria/03-arte-y-herramientas.md`).

---

**Guardar** en `siete-vidas/arte/referencias/gemini/consistencia-casa.png` y `consistencia-interfaz.png` y subir en un solo commit a `claude/split-bill-csubjd` ("Arte de consistencia: ventanas, armario, teclado y kit de interfaz, generado con Gemini").

**Integrado (2026-10-20, 0 créditos):** `python3 siete-vidas/herramientas/preparar_arte_nivel.py consistencia`. El marco
de ventana va en las 4 ventanas (hueco de 150 × 120), la vista del pasillo detrás del vidrio con el toldo un poco más
oscuro y el teclado en el escritorio; se borró el código que dibujaba marco, parante, alféizar, ventana del pasillo y
teclado. El armario bajo la escalera **no calza** con el larguero de la escalera (su pendiente y su descanso tapan los
peldaños): se probó y sigue el de código.
