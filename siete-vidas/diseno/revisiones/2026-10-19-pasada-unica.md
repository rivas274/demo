# Pasada única de calidad visual del nivel 1 (2026-10-19)

Lo que dijo el creador: «se ve apresurado, montado; el piso se ve mal; ¿por qué el sofá tiene una línea blanca?; el lavamanos quedó desproporcionado». Una sola pasada con plan, 0 créditos. Fuentes: `06-lecciones-arte.md` (26 lecciones, checklist), `2026-10-19-piso-gemini.md` (cómo hacer el piso), `arte/referencias/gemini/pisos.png` (franjas), `2026-10-19-escenarios-gemini.md` (feedback por escenario) y las capturas del creador `capturas/2026-10-19-creador-piso-3/4/5.png`.

## Plan (armado antes de tocar nada)

1. **Piso:** fuera el piso por código (hileras que convergen, líneas oscuras). Franjas de Gemini sin perspectiva: parquet en los cuartos, damero en la cocina, losa en el balcón; que repitan sin costura. Banda detrás de los pies de 20 a **14 px** (`Sala.FONDO_PISO`); zócalo de **3 px** con bisel claro y **1 px de sombra** en la unión; sombras de contacto de **2 px** (por pata y en vivo) y **1 px de oclusión** detrás de los muebles grandes.
2. **Resalte del Indicador:** nunca un rectángulo. Contorno de 1 px por la silueta del arte, crema cálido que late suave, para todo lo interactuable (sofá, puerta entornada, cómoda, ropa y Valeria no daban arte).
3. **Fregadero:** a escala de gato junto al mesón, el microondas y Felipe: un tercio del mesón, embutido en la cubierta, grifo alineado sobre el centro de la cuba (lección 18).
4. **Luz de la sala:** quitar la luz redonda de la lámpara (halo sobre el tapiz, lección 26); su luz cae en el tablero de la mesita y en el piso en escalones. Ventana, polvo, portátil y LED igual. Solo la sala.
5. **Gemini por escenario:** verificar cada punto contra las capturas y aplicar lo correcto (más los patrones nuevos: sombras de contacto, nada cortado en el borde, dirección de luz, grosor de muro, halos), sin mover colisiones.
6. **Checklist:** recapturar los 13 escenarios, recorrer las 26 lecciones con capturas ampliadas y arreglar lo que falle antes de entregar.

## Qué se aplicó

### Piso (lecciones 16, 17 y 22)

- **Franjas de Gemini** (`herramientas/preparar_arte_nivel.py`, `pisos_gemini()`): de `pisos.png` se toma cada franja sin el remate de arriba (que hacía de zócalo), se reduce a 1/4 con promedio (Gemini dibuja cada pixel con ~4 px) y se vuelve a su paleta de 16 colores para que no quede borroso. Salen 44 px de alto, justo lo que va de `PARED_BASE` a `ALTO`.
  - **Repetición sin costura, verificada:** el damero repite exacto cada 128 px de origen y la losa también; el parquet **no** repite exacto, pero casi cada 452 px. La herramienta busca el corte en que la primera y la última columna más se parecen (diferencia media de 0,6 a 0,8 sobre 255) y recorta ese tramo. Resultado: `piso_parquet` 113 × 44, `piso_damero` 128 × 44 (contraste al 80 % para no competir con Felipe ni con el azulejo, R14; sin la hilera sombreada de atrás) y `piso_losa` 128 × 44 (con el canto del balcón abajo).
  - **Se borraron** `piso.png`, `piso_cocina.png`, `piso_balcon.png` y la llave con trapo (`llave_agua.png`, ver fregadero), y su código en la herramienta.
- **`FondoApartamento._crear_piso`:** solo repite la franja de cada cuarto, sin perspectiva, corrida distinto en cada cuarto. Fuera `HILERAS_*`, `ESCALA_FONDO` y `OSCURO_FONDO`.
- **Banda de 14 px** (`Sala.FONDO_PISO` 20 → 14): todo lo de la pared bajó 6 px solo en el dibujo; colisiones iguales. `prueba_nivel` ahora pide 12 a 16 px.
- **Zócalo de 3 px** (`FondoApartamento.ZOCALO`): 1 px de bisel claro y 2 de madera oscura; en el piso, 1 px de sombra en la unión (antes 18 px de zócalo y 2 + 2 de sombra).
- **Sombras:** `Sala.sombra` pasó de una mancha de 5 filas a **2 px** (base entera y la fila de delante 2 px más angosta por lado), para muebles y en vivo (Felipe, Valeria, A.S.P.I., ratones, caja, comida). Bajo cada pata, 2 px más oscuros; detrás de cada mueble de 80 px o más, **1 px de oclusión** en la unión pared-piso.

### Resalte por silueta (lección 19)

- `Indicador` ya no dibuja rectángulos: si el objeto no da su arte, solo sale la burbuja. El contorno es crema cálido (`COLOR_CONTORNO`) y late entre 55 y 100 %.
- Dan su arte: el **sofá** (la imagen que se ve, con o sin plástico), la **puerta entornada** (su puerta), el **cajón** (la cómoda), la **ropa doblada** (limpia o con pelos) y **Valeria** (el cuadro de su hoja, volteado si mira a la izquierda; el shader recorta el cuadro para que no se cuele el vecino).
- **Capa del contorno:** detrás de muebles y personajes (ARTE_PARED), así solo se ve donde hay pared o piso detrás y nunca cruza a Valeria sentada (lo vimos en la primera captura: el contorno del respaldo pasaba por encima de su portátil). La ropa lo lleva en MARCAS (si no, la cama lo tapaba).

### Fregadero (lección 18)

- `Sala.FREGADERO` de 36 × 15 a **62 × 16 px** (un tercio de los 188 px del mesón, unos 50 cm a escala de gato), bien adentro del borde, en la cubierta de azulejos. Borde de acero de 2 px con brillo arriba a la izquierda (la ventana de la cocina), cuba hundida: la pared del fondo iluminada con su sombra de borde, el fondo más oscuro, franja de sombra bajo el borde de delante, desagüe y agua.
- **Grifo de cuello de cisne por código** (`Sala.GRIFO`, la boca sobre el centro de la cuba): la llave con trapo de Gemini traía el trapo pegado al caño y no se podía centrar sobre una cuba de este ancho, así que se borró. Va en su propia capa (MARCAS): el ratón del mesón pasa por detrás y ya no lo tapa (lo vimos en la primera captura). La gota cae de la boca a la cuba.
- **Paño de cocina** cuadrillé doblado sobre el canto del mesón (algo de Valeria, lección 21).
- ¿Cumple la lección 18? Sí: se miró junto al mesón, el microondas, el ratón y Felipe (hoja de detalles); `prueba_nivel` comprueba que mide entre 28 y 40 % del mesón, que está dentro de la cubierta y que el grifo cae en su centro.

### Luz de la sala (lecciones 24 y 26)

- Fuera la luz redonda «Lámpara de la mesita» (`luz_escalones` a escala 1,1 pintaba un círculo en el tapiz). Su luz cae ahora en el **tablero de la mesita** (3 escalones planos bajo la pantalla) y en el **piso** delante (3 franjas planas), sin sombrear. Ventana (luz principal desde la izquierda), polvo, portátil y LED, igual. `luz_escalones.png` se sigue usando (portátil y LED).
- Dirección: la ventana está a la izquierda; las sombras de los cuadros caen a la derecha y los brillos del grifo y del fregadero van a la izquierda.

### Otros arreglos de la revisión

- **Grosor de muro en las puertas abiertas** (lección 25): jamba izquierda de 5 px y dintel de 4 px en dos tonos de sombra, con 1 px de canto (`Puerta._dibujar_grosor_muro`).
- **Farol de la fachada del balcón** (lecciones 23 y 26): quedaba cortado por el borde de arriba de la pantalla (la cámara del balcón es fija) y tenía un halo circular. Se borró con el color del muro (`FAROLES` en la herramienta).
- **Caja de recuerdos del dormitorio** (lección 23): la repisa alta bajó de 2,40 m a **2,26 m** (`SUELO − 274`); la caja quedaba cortada por el borde de arriba. Sigue fuera de alcance (89 px sobre el ropero, el tope es 72) y `prueba_escenario` y R17 lo comprueban.

## Feedback de Gemini, punto por punto

| Escenario | Punto de Gemini | Qué se hizo |
| --- | --- | --- |
| 1 Sala-sofá | Rectángulo blanco del sofá | Aplicado: contorno por silueta. |
| 1 | Piso sin profundidad, patas en una línea | Aplicado: franja de 14 px detrás, sombras de 2 px. |
| 1 | Taza y vaso flotan en un «escritorio detrás de Valeria» | Descartado: no hay escritorio en la sala; la taza está apoyada en la mesita (colisión medida). |
| 1 | Macetas de la ventana sin sombra | Descartado: son parte del arte de la ventana, detrás del vidrio. |
| 1 | Rascador y cesta sin sombra de piso | Aplicado: los dos llevan la sombra nueva y la oclusión del rascador. |
| 1 | Cables y luz de la mesita flotan | Descartado: el cable va del enchufe al cargador en el piso, verificado en la captura. |
| 2 Sala-comedor | Vaso de 4–6 px | Descartado: mide 24 × 32 (R8). |
| 2 | Patas de mesa y sillas sin sombra | Aplicado: 2 px por pata y oclusión de la mesa. |
| 2 | Silla detrás de la mesa cortada | Descartado: las sillas están a los lados, no detrás. |
| 2 | Marcos de puerta distintos | Descartado: un solo marco (lección 1, `prueba_reglas_nivel`); en el comedor se ve una sola puerta. |
| 3 Recibidor-entrada | Zapatero y caja de arena sin piso detrás («bajarlos 8 px») | Aplicado de otra forma: se ve la banda de 14 px detrás de sus patas; los muebles no se movieron (colisión ±2 px). |
| 3 | Lámpara de pie bloquea la puerta | Descartado: no la tapa ni entra en el rectángulo de la puerta (B3 lo mide). |
| 4 Recibidor-escalera | Volumen bajo la escalera sin sentido | Descartado: ya es un armario con tablas, puerta y pomo (§16); verificado en la captura ampliada. |
| 4 | Puerta abierta choca con el estante | Descartado: esa puerta está cerrada y separada del librero. |
| 5 Cocina-entrada | Ventana a otra altura | Descartado: alféizar a 109 px en todas (prueba). |
| 5 | Ratones sin sombra | Aplicado: sombra en vivo de 2 px. |
| 6 Cocina-mesón | Pollo gigante («bajarlo a 20 px») | Descartado: escala de gato, lo que le importa al gato se ve grande (CLAUDE.md). El pollo existe (sobre el microondas). |
| 6 | Gato en la silla flota | Verificado y descartado: la silla existe y Felipe apoya en el asiento. |
| 6 | (Del creador) lavaplatos desproporcionado | Aplicado: fregadero a escala con grifo. |
| 7 Pasillo-consola | Consola sobre el borde de la pantalla | Descartado: hay 30 px de piso bajo la línea de apoyo; ahora además 14 px detrás. |
| 8 Pasillo-estudio | Cojín rosa sin sombra | Aplicado: sombra de 2 px y oclusión. |
| 9 Dormitorio-cama | Ventana gigante | Descartado: misma medida que todas; las cortinas largas la hacen ver más alta. |
| 9 | Mantas en el borde | Descartado: la ropa está en medio de la cama, hundida 22 px (prueba). |
| 10 Dormitorio-ropero | Ropero sin piso ni sombra | Aplicado: banda de piso, sombra y oclusión. |
| 10 | Cuadros demasiado altos | Descartado: el paisaje se apoya en su repisa a 1,20 m. Lo que sí estaba mal arriba: la caja de recuerdos cortada (bajada). |
| 11 Estudio | A.S.P.I. e impresora sin sombra | Aplicado: sombra en vivo de A.S.P.I. y de contacto de la impresora. La impresora existe. |
| 11 | Puerta abierta a la nada | Aplicado: grosor de muro (jamba y dintel). |
| 12 Balcón | Losa recortada al ras | Aplicado: la losa nueva trae su canto abajo. |
| 12 | Macetas y gato en un riel | Descartado: el plano de juego es uno solo (plataformas lateral). |
| 13 Pasillo-baño | Alfombra corrida sin perspectiva | Descartado: es la alfombra del pasillo, que sale por el borde mientras la cámara se mueve (sale claramente). |
| Patrón | Sombras de contacto | Aplicado (lección 22). |
| Patrón | Nada cortado al ras del borde | Aplicado donde la cámara es fija o el borde de arriba es fijo: farol del balcón, caja de recuerdos. En los cuartos más anchos que la pantalla, lo que entra o sale por los costados al moverse la cámara no cuenta. |
| Patrón | Dirección de luz | Aplicado: sala, ventana a la izquierda; brillos del cromo a la izquierda. |
| Patrón | Grosor de muro en puertas | Aplicado (lección 25). |
| Patrón | Halos | Aplicado: lámpara de la sala y farol del balcón (lección 26). |

## Checklist de las 26 lecciones (capturas recapturadas y ampliadas ×2 y ×3)

| # | Lección | Resultado |
| --- | --- | --- |
| 1 | Un solo marco de puerta | ✔ |
| 2 | Nada tapa una puerta ni una interacción | ✔ (la lámpara del recibidor queda fuera del rectángulo de la puerta) |
| 3 | Muebles derechos y en su pieza | ✔ |
| 4 | Colisión ±2 px, sin margen transparente | ✔ (nada con colisión cambió; la repisa alta y su caja bajaron juntas) |
| 5 | Comida grande | ✔ |
| 6 | Barreras con sentido | ✔ |
| 7 | Cada desplazamiento con su animación | ✔ (sin cambios) |
| 8 | Una sola tabla de capas | ✔ (contorno en ARTE_PARED, grifo en MARCAS, luz de la lámpara en ARTE_PARED; memoria 03) |
| 9 | Pies que no patinan | ✔ (sin cambios; video) |
| 10 | Transiciones de pose | ✔ (sin cambios) |
| 11 | Una sola cola de anuncios | ✔ |
| 12 | Ventanas iguales | ✔ (prueba) |
| 13 | Cada objeto en su cuarto | ✔ (el paño de cocina es de la cocina) |
| 14 | Cosas apoyadas en el centro | ✔ |
| 15 | Todo volumen se explica | ✔ |
| 16 | El piso es un plano | ✔ (14 px detrás de los pies) |
| 17 | Superficies grandes con arte de verdad | ✔ (franjas de Gemini) |
| 18 | Lo agregado tiene sentido y escala | ✔ (fregadero) |
| 19 | Nada de rectángulos de depuración | ✔ (silueta) |
| 20 | Nada clonado ni en fila | ✔ (el parquet se corre distinto en cada cuarto) |
| 21 | Algo vive en cada cuarto | ✔ (gota, paño) |
| 22 | Sombra de contacto y oclusión | ✔ |
| 23 | Nada cortado en el borde | ✔ (farol y caja de recuerdos arreglados) |
| 24 | Una dirección de luz | ✔ |
| 25 | Grosor de muro en las aberturas | ✔ |
| 26 | Sin halos circulares | ✔ (lámpara y farol) |

**26 de 26 ✔.** Dos errores nuevos vistos en la pasada (se sumaron a `06-lecciones-arte.md` como 27 y 28): el resalte dibujado encima de todo cruzaba a Valeria, y el grifo nuevo quedaba tapado por el ratón que patrulla el mesón.

## Pruebas y entregables

- `prueba_movimiento`, `prueba_escenario`, `prueba_mecanicas`, `prueba_nivel`, `prueba_reglas_nivel`, `prueba_jefe` y `prueba_acciones`: 0 fallos. Bot `partida.gd`: 3 de 3 con la agenda 8 de 8.
- Fuera del repositorio: hoja `pasada-unica-antes-despues.png` (13 escenarios), `pasada-unica-detalles.png` (sofá, fregadero y piso ×3) y el video `nivel1-v4g.mp4`.
- **No se tocó a Felipe** (ni su arte ni su colisión): no aplica la regla de los tres lugares.
