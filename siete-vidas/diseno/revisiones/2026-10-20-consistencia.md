# Revisión de consistencia visual: nivel 1 completo + interfaz (2026-10-20)

Rama `claude/split-bill-csubjd` en `ed3ae42` (menú de estambre). Capturas a 640×360 con xvfb-run: 21 de cuartos (`capturas_nivel.gd`), 6 de sistemas (`capturas_sistemas.gd`) y 16 de título, intro, HUD, pausa, los pasos de la presentación del jefe y la pelea (con un script temporal que ya se borró). Las revisé ampliadas ×2 a ×6 y medí la densidad y la paleta de los 140 PNG de `assets/` (largo medio de los tramos del mismo color y número de colores). Hoja de recortes: `hoja-hallazgos.png` (cada recorte va con el ID de la tabla).

## Veredicto

1. **Los cuartos aguantan:** casi todo el arte del mundo es de Gemini, a 1 pixel de arte por pixel del juego (tramos de 1,0 a 1,25 px) y con luz desde la izquierda. Lo que delata el montaje son **4 piezas de código junto al arte**: la ventana del pasillo, el armario bajo la escalera, el marco estirado de las otras 3 ventanas y la planta vectorial del balcón. A eso se suman halos suaves y etiquetas de código.
2. **La interfaz es lo más débil y lo primero que se ve:** toda la letra es la fuente por defecto de Godot, suavizada, y no tiene nada de pixel. Además hay 5 estilos de panel distintos (gris, azul noche, papel, pizarra verde y rectángulo crema con borde rojo). El menú de estambre es la única pieza de interfaz dibujada, y su letrero principal se gira y se rompe.
3. **La presentación del jefe amplía la cámara a 1,15–2,4×** (zoom no entero), así que en el mismo cuadro conviven pixeles de 2 y de 3 px.

**Causas de fondo de que se vea "hecho por IA":**
- **Código y arte mezclados en primer plano:** lo de código se dibuja sin contorno de 1 px, con colores planos o polígonos lisos (lecciones 17 y 32).
- **Interfaz sin dirección de arte:** usa la fuente del sistema, rectángulos `draw_rect` y un estilo distinto en cada pantalla.
- **Escalas no enteras:** cámara del jefe, íconos del HUD a 0,6, letrero girado y, ya conocido, Felipe a 0,72.

## Hallazgos (prioridad y forma de arreglarlo)

Prioridades: **B** = bloqueante (el creador lo ve en 5 s), **G** = grave, **M** = menor. Vía: **código** (escala, recorte, paleta, quitar) o **arte** (encargo a Gemini, `encargo-gemini-consistencia.md`).

| ID | Prio | Dónde | Qué pasa (verificado en captura) | Vía | Arreglo |
| --- | --- | --- | --- | --- | --- |
| B1 | B | Toda la interfaz | La letra es `ThemeDB.fallback_font` (no hay ningún .ttf en el proyecto): suavizada y sin pixel, en el HUD, el diálogo, la libreta, el resumen, el logro, «¡PUM!», los carteles del jefe, los letreros de estambre, el título y la pausa | Código | Fuente pixel de licencia libre con á é í ó ú ñ ¿ ¡ (p. ej. *Pixel Operator*, CC0) como `default_font` de `tema.tres`, a tamaños enteros (8, 16) y sin antialias. Acreditarla en `CREDITOS.md`. Retocar los tamaños en `tema.tres` |
| B2 | B | Pasillo, ventana sobre la consola | La pieza de Gemini quedó recoloreada y la parte de arriba (`_dibujar_ventana_pasillo`) es de código: cielo en 6 franjas, techos en rectángulos, sin contorno. La caja de pizza son polígonos y círculos. Es la única ventana de otro estilo | Arte (pieza 1 + pieza 2) | Usar el mismo marco que las otras 3 ventanas y, en el vidrio, la vista nueva del toldo con la pizza. Se borran `_dibujar_ventana_pasillo` y `ventana_pasillo.png`. El vapor puede seguir por código (líneas de 1 px) |
| B3 | B | Presentación del jefe | `presentacion_jefe.gd` interpola `_camara.zoom` entre 1,0, 1,3, 1,5, `ZOOM_FELIPE`, `ZOOM_JEFE` y 1,4: Felipe, la puerta y la silla quedan con pixeles de tamaños mezclados | Código | Solo zooms enteros (1 o 2), con corte seco en el cambio de paso (estilo Broforce) en vez del `lerp`. Encuadrar moviendo la cámara, no ampliando |
| G1 | G | Recibidor, bajo la escalera | El armario, su puerta, la caja, el zócalo y el rellano son `draw_rect`/polígonos planos sin contorno, entre la escalera y la escoba de Gemini. Se nota a la primera ampliación | Arte (pieza 3) | Pieza de Gemini que calce bajo el larguero de `escalera_peldanos.png`. Se borra `_dibujar_armario_escalera` (queda solo la sombra) |
| G2 | G | Cocina, dormitorio y estudio | `ventana_marco.png` se estira en 9 partes desde la ventana de la sala, y en los costados quedan muñones de la persiana (rayas oscuras). El parante en cruz es de código (4 px planos). La barra del estudio lleva remates hechos con `draw_circle` | Arte (pieza 1) | Marco vacío nuevo de Gemini, con parante y alféizar, en una sola pieza de 186 × 154 (hueco de 150 × 120). Fuera `_marco_9` y el parante. Barra del estudio: la `cortina_barra` del dormitorio con sus remates |
| G3 | G | Sala (rascador y sofá) | La etiqueta «NUEVO» es un rectángulo crema de código, con letra suavizada, que flota junto a la etiqueta en blanco de Gemini, sin hilo. La del sofá queda detrás de Felipe | Código | Escribir «NUEVO» con la fuente pixel (B1) **sobre** las etiquetas de Gemini que ya cuelgan, y borrar el rectángulo |
| G4 | G | Balcón, primer plano | `_planta()` dibuja polígonos lisos (vectoriales) en negro morado | Código | Quitarla, o usar `maceta_grande.png` con tinte de silueta (`modulate` oscuro). No hace falta arte |
| G5 | G | Láser, calcetín recogible, pelea | Círculos suaves con alfa (lección 26): el punto del láser con 3 aros, un brillo amarillo de 20 px detrás del calcetín (`recogible.gd:82`) y círculos blancos difusos tipo bokeh en la succión de A.S.P.I. | Código | Escalones de pixel: láser de 3 × 3 con cruz de 1 px y latido de 1 px; brillo del recogible como contorno de 1 px que late (como el `Indicador`); polvo de 2 × 2 a 3 × 3 px opaco |
| G6 | G | Interfaz | Cinco estilos: HUD (paneles gris oscuro, corazones en un panel crema), diálogo (azul noche con borde crema), libreta (papel), resumen (pizarra verde con barras de color planas), logro (rectángulo crema con borde rojo de 1 px), barra del jefe (rectángulos rojos planos). Ninguno dialoga con el estambre ni con la madera | Arte (piezas 5 a 11) + código | Un panel de madera en 9 partes para el HUD, el diálogo, el resumen y la franja de fase. La libreta sigue como papel (es la agenda). Logro como etiqueta colgada, barra del jefe con marco de metal de A.S.P.I. y cinta para los carteles. Colores del tema |
| G7 | G | HUD | Los íconos se dibujan a escala 0,6 (`contador_recurso.gd:53`): el calcetín y la bolsita pierden filas y columnas. La libreta y la foto vergonzosa son de código | Arte (pieza 6) | 4 íconos de 20 × 20 a escala 1, sin el «golpe» que escala (cambiar por un salto de 1–2 px) |
| G8 | G | Pausa | El letrero principal «Continuar» gira al balancearse: el pixel art rotado sale en escalones y con otra densidad | Código | Balanceo sin rotación: desplazar el letrero 1–2 px en x y dibujar el hilo inclinado, o rotar en pasos con el sprite a escala ×1 sin filtro. El texto, con la fuente pixel |
| G9 | G | Título, intro, «Pausa» | Texto suelto, sin logo ni marco, sobre la sala oscurecida. El título no usa el estambre del menú | Arte (pieza 9) + código | Letrero de título (sin texto) colgado del mismo ovillo. «[Enter] Jugar» como letrero de estambre |
| G10 | M | Dormitorio, cortina | El vaivén corre la mitad de abajo de cada paño 1 px y deja un escalón visible a la altura del 55 % | Código | Mover el paño entero, o solo el ruedo (últimos 6 px) |
| M1 | M | Estudio, teclado | `_dibujar_teclado` hace teclas planas sin contorno junto al monitor de Gemini | Arte (pieza 4) | Teclado de Gemini de 52 × 24 |
| M2 | M | Cocina, refrigerador | El imán de la foto de abajo cruza la manija; las polaroids de 12 × 14 no se leen | Código | Correr el imán 8 px; si se quieren leer, polaroids a 18 × 21 (escala de gato) |
| M3 | M | Pasillo, vano | El poste de la escalera que asoma por el vano (`vano_bajada.png`) trae puntos claros de halo del JPEG | Código | Volver a pasarlo por `quitar halo` de `preparar_arte_nivel.py` |
| M4 | M | Pelea | En la imaginación, el HUD queda bajo la franja negra y asoma «9 vidas» cortado. La franja «FASE 1» se monta sobre el HUD | Código | Esconder el HUD mientras dura `presentando`; franja de fase bajo el HUD (y = 44) |
| M5 | M | Paleta | Las piezas de Gemini traen de 500 a 7.000 colores (ruido del JPEG reducido con promedio), junto a piezas limpias: pisos (16), taza (8), Felipe (18), Valeria caminando (22). A 1× casi no se nota; se nota en el retrato de Valeria (8.652 colores, se ve más suave que el de Felipe) | Código | Probar en `preparar_arte_nivel.py` la cuantización a 32 colores por pieza (la misma de `pisos_gemini`), primero con el sofá, el retrato y la mesa. Si se ve mejor, aplicarla a todo |
| M6 | M | Felipe | Escala 0,72: pixeles disparejos frente al arte a 1× | SpriteCook (ya en pendientes) | No entra en esta tanda: se hace con las hojas finales de ~67 px |
| M7 | M | Imaginación del jefe | A.S.P.I. gigante y el fondo a ~3× de densidad, con Felipe a 1× | Ninguna | Lo permite la regla de las imaginaciones (decorado, CLAUDE.md). No se toca |

**Lo que se pidió revisar y está bien:**
- **Retrato provisional de Valeria:** no se ve, porque carga la hoja de Gemini; el respaldo de `RetratoValeria` solo existe si falta el PNG.
- **Baranda del balcón:** es de Gemini; el vaivén de las macetas no deja corte visible.
- **Grifo:** es de Gemini, viene dentro de `meson.png`; por código solo va la gota de 1 × 2.
- **Escoba:** de Gemini.
- **Cortina del dormitorio:** de Gemini; solo falla el corte del vaivén (G10).
- **Valeria:** las poses de Gemini y el caminar de SpriteCook son la misma persona; el caminar tiene la paleta más plana, pero a 1× no se nota.

## Inventario de consistencia

Origen: **Ge** = Gemini, **SC** = SpriteCook, **Cód** = dibujado por código, **Ke** = Kenney. «Encaja» resume si comparte densidad, contorno de 1 px, paleta, luz y escala de gato.

### Mundo

| Elemento | Origen | Encaja | Nota |
| --- | --- | --- | --- |
| Paredes (tapiz, rosa, azulejo) y pisos (parquet, damero, losa) | Ge | Sí | Pisos cuantizados a 16 colores |
| Puertas (5 estados), vano, puerta del balcón | Ge (+ grosor de muro por código) | Sí | Un solo marco. La jamba de código tiene 2 tonos y no se nota |
| Zócalo, cornisa y sombras de 2 px | Cód | Sí | Son finos y se leen como sombra |
| Ventana de la sala (persiana) | Ge | Sí | Es la referencia del estilo de las ventanas |
| Ventanas de cocina, dormitorio y estudio (marco) | Ge estirado + Cód | **No** | G2 |
| Ventana del pasillo | Ge recoloreado + Cód | **No** | B2 |
| Vista por las ventanas (cielo, ciudad lejana y cercana) | Ge | Sí | Cables de 1 px algo pálidos, aceptable |
| Rayos de luz y polvo | Cód | Sí | Franjas planas con 3,5 % de alfa, polvo de 1 px |
| Cortina del dormitorio | Ge | Casi | G10 |
| Paños del estudio y visillo de la cocina | Ge | Sí | La barra del estudio es de código (G2) |
| Sofá (plástico y arañado), mesita, lámpara, rascador, cesta, alfombras, cuadros, retrato, marcos, perchero, zapatero, caja de arena, aparador | Ge | Sí | |
| Etiqueta «NUEVO» | Cód | **No** | G3 |
| Cable de la lámpara y cargador | Cód (línea de 1 px) | Sí | Se lee como cable |
| Mesa, sillas, librero, cajas, banquito, croquetas, repisa de la cocina | Ge | Sí | |
| Escalera (peldaños y pasamanos) y escoba | Ge | Sí | |
| Armario bajo la escalera y rellano | Cód | **No** | G1 |
| Mesón (con fregadero y grifo), estufa, alacenas, refrigerador, microondas, pollo, imanes, tazón, lata | Ge | Sí | M2 |
| Gota del grifo | Cód 1 × 2 | Sí | |
| Consola, baúl, cojín, retrato familiar | Ge | Sí | |
| Cama, cómoda, ropero, repisas, caja de recuerdos, ropa | Ge | Sí | |
| Escritorio, monitor, vaso, taza, A.S.P.I., base de carga | Ge | Sí | |
| Pantalla del monitor (serie de Valeria) | Cód | Sí | Es contenido de pantalla y se lee como tal |
| Teclado | Cód | No | M1 |
| Balcón: fachada, baranda, macetas | Ge | Sí | |
| Planta de primer plano del balcón | Cód vectorial | **No** | G4 |
| Ratones, caja, bolas de pelo, manchas, arañazos | Ge | Sí | |
| Láser | Cód (círculos suaves) | **No** | G5 |
| Brillo del recogible | Cód (círculo suave) | **No** | G5 |
| Felipe (todas las hojas) | SC | Casi | Escala 0,72 (M6) |
| Valeria (poses y caminar) | Ge + SC | Sí | |
| A.S.P.I. gigante e imaginación | Ge | Sí (imaginación) | M7 |
| Polvo y succión de la pelea | Cód (círculos difusos) | **No** | G5 |

### Interfaz

| Elemento | Origen | Encaja | Nota |
| --- | --- | --- | --- |
| Letra de toda la interfaz | Fuente por defecto de Godot | **No** | B1 |
| Corazones | Cód (círculos + triángulo) | Casi | Se leen nítidos a 1×; con el panel nuevo, bien |
| Paneles del HUD y contadores | Cód `draw_rect` | **No** | G6 |
| Íconos del HUD | Ge a 0,6 + Cód | **No** | G7 |
| Íconos de teclas | Ke | Sí | Pixel 16 px, nítidos |
| Indicador (burbuja y contorno por silueta) | Cód | Sí | La burbuja hereda B1 |
| Diálogo: panel | Cód | **No** | G6 |
| Diálogo: retratos de Felipe y Valeria | SC / Ge | Casi | Valeria más suave (M5) |
| Libreta (agenda) | Cód (papel con renglones) | Casi | Coherente consigo misma; arreglada con B1 |
| Resumen del día | Cód (pizarra verde) | **No** | G6: pasarlo al panel de madera o a papel |
| Logro (notificación) | Cód | **No** | G6 |
| «¡TRAVESURA CUMPLIDA!» y franjas de fase | Cód (franja oscura) | Casi | B1. Con la cinta (pieza 11) quedaría de la casa |
| Menú de pausa de estambre (letreros, hilo, ovillo, pelusa) | Ge | Sí, salvo el giro | G8 |
| Título, intro y «Pausa» | Solo texto | **No** | G9 |
| Presentación del jefe (franjas, «¡BATALLA INICIADA!», nombre) | Cód | Casi | B1 y B3. La franja roja inclinada es plana pero funciona como gráfica de cómic |
| Barra de vida del jefe | Cód | **No** | G6 |
| Burbuja de A.S.P.I. («DETECTANDO…») | Cód (rectángulo con borde rojo) | Casi | B1 |

## Orden de una sola pasada

1. **Código sin arte**, en este orden: B1 (fuente; arrastra a casi toda la interfaz), B3, G3, G4, G5, G8, G10, M2, M3 y M4. Después probar M5 en 3 piezas.
2. **Encargo a Gemini en una tanda** (2 imágenes, 11 piezas).
3. **Integración con `preparar_arte_nivel.py`:**
   - Marco nuevo en las 4 ventanas (B2 y G2): se borran `_marco_9`, el parante y `_dibujar_ventana_pasillo`.
   - Armario (G1).
   - Teclado (M1).
   - Kit de interfaz (G6, G7 y G9).
4. **Recapturar y cerrar:** los 13 escenarios, las 7 pantallas de interfaz y la entrada del jefe cuadro a cuadro. Recorrer las 36 lecciones.

## Lo que NO se toca

- **Colisiones, alturas y la escala de gato.** Ninguna pieza nueva cambia la colisión: el armario va bajo la escalera, que no tiene colisión; las ventanas son decorado con el alféizar a 109 px, comprobado en `prueba_reglas_nivel`.
- **Felipe:** ni sus hojas ni su escala. La regla de los tres lugares no aplica.
- **La imaginación del jefe** (M7) y el estilo general de la entrada tipo Broforce (`PresentacionJefe`).
- **La libreta como papel:** es la agenda de Felipe y tiene sentido que se vea distinta.
