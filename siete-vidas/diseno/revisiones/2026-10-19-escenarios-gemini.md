# Feedback de Gemini por escenario (2026-10-19)

- **Fuente:** gemini.google.com (Gemini Automático), la misma conversación de la consulta de piso ("Guía de Corrección de Pixel Art"), después del encargo de las franjas de piso.
- **Archivos adjuntos:** `capturas/2026-10-19-escenarios-actual.png` (13 escenarios rotulados) y `memoria/06-lecciones-arte.md` (Gemini aceptó el .md como archivo).
- **Prompt:** "Esta es la lista de errores que el creador de mi juego ya encontró a simple vista (por ejemplo: el lavaplatos de la cocina quedó desproporcionado, el piso se ve montado, hay un rectángulo blanco alrededor del sofá y todo parece pegado a la pared). Revisa CADA uno de los 13 escenarios de la imagen como artista de entornos indie de pixel art y dime, escenario por escenario, qué errores de esa misma clase siguen ahí, nombrando el objeto y diciendo qué hacer, con medidas o proporciones si puedes. Después dime qué patrones de error me faltan en la lista para no repetirlos en escenarios futuros. Sé directo y concreto; no me des consejos generales."

> Notas de quien copió:
> - Gemini empezó un informe, lo cortó a mitad de palabra en el escenario 4 ("junto al libr") y volvió a empezar desde el escenario 1 ("Aquí tienes la auditoría técnica..."). Se copia tal cual salió, con los dos borradores. El segundo es el completo.
> - Se quitaron las etiquetas de cita "JPG"/"MD" de la interfaz. Una fórmula salió repetida tres veces por el renderizado matemático de Gemini ("rgba(0,0,0,0.3)rgba(0,0,0, 0.3)rgba(0,0,0,0.3)) de 6×2 px6 \times 2\text{ px}6×2 px"); se dejó una sola vez.
> - Nombra objetos por escenario, así que no se repreguntó. Algunos objetos pueden no existir (el "pollo asado", el gato en la silla de la cocina, la "impresora"); hay que verificarlos contra la captura.

## Respuesta (completa)

Analizando minuciosamente cada uno de los **13 escenarios** en la imagen adjunta contra el documento de errores identificados, aquí tienes el informe directo, técnico y detallado escenario por escenario, seguido de los patrones de error sistémicos que faltan en tu lista.

### Revisión Escenario por Escenario

#### 1. `SALA-SOFA`

* **Errores que persisten:**
   * **Marco de depuración (Error #19):** El sofá tiene una caja rectangular blanca marcada a su alrededor. *Solución:* Eliminar la caja de depuración del motor o cambiar la lógica de selección para que use la silueta del sprite (con un resalte de 1 px).
   * **Objetos flotantes en mesa y ventana (Error #4):** La taza y el vaso flotan levemente en el escritorio detrás de Valeria, y las macetas en la ventana parecen pegadas a la madera sin sombra base. *Solución:* Añadir sombra de contacto de 1-2 px de alto debajo de cada maceta y la taza.
   * **Objetos pegados a la pared (Error #16):** El rascador para gatos y la cesta de la izquierda no tienen sombra de piso tras de sí.

#### 2. `SALA-COMEDOR`

* **Errores que persisten:**
   * **Comida diminuta (Error #5):** El vaso/plato con agua sobre la mesa mide apenas 4-6 px. *Solución:* Aumentar el sprite a al menos 16x16 px para que resalte y se lea claramente a 640x360.
   * **Falta de apoyo y sombra (Error #16):** Las 4 patas de la mesa de comedor y las sillas terminan de golpe en la línea del piso sin ningún oclusor o sombra elíptica. *Solución:* Crear una elipse de sombra semitransparente (rgba(0,0,0,0.3)) de 6×2 px en la base de cada pata.
   * **Silla desalineada:** La silla detrás de la mesa se corta visualmente de forma extraña con el tablero.

#### 3. `RECIBIDOR-ENTRADA`

* **Errores que persisten:**
   * **Mueble flotando sobre el zócalo (Error #16):** La consola/organizador de zapatos y la caja de arena están aplastados justo en la línea del zócalo sin banda de piso visible detrás de sus patas. *Solución:* Desplazar los muebles 8 px hacia abajo para mostrar el piso por detrás y poner sombra de contacto.
   * **Lámpara bloqueando interacción (Error #2):** La lámpara de pie a la derecha está pegada a la zona transitable/pared de la puerta contigua.

#### 4. `RECIBIDOR-ESCALERA`

* **Errores que persisten:**
   * **Elemento sin explicar bajo la escalera (Error #15):** La escoba y el espacio debajo de la escalera se ven flotando sobre un hueco oscuro no delimitado. *Solución:* Definir la estructura de soporte de la escalera o un armario cerrado con panel de madera.
   * **Cajas vacías y flotantes (Error #4, #16):** La caja de cartón pequeña junto al librAquí tienes la auditoría técnica detallada de cada uno de los 13 escenarios basándome en la imagen real (`2026-10-19-escenarios-actual.png`) y contrastándolos directamente con las lecciones de arte.

### 🔍 Revisión Escenario por Escenario

#### 1. SALA-SOFÁ

* **Cuadro de depuración blanco / Selección (Error 19):** El sofá tiene un rectángulo plano de depuración alrededor que rompe la estética de pixel art.
   * *Qué hacer:* Eliminar la caja rectangular y hacer que la línea de brillo/interacción siga el contorno o contorno exterior (*outline*) del mueble.
* **Piso montado y sin profundidad (Errores 16 y 17):** Las patas del sofá, la mesita de centro y el gato están sobre una sola línea plana horizontal.
   * *Qué hacer:* Subir el zócalo de la pared hacia arriba entre 12 y 16 px para dejar franja de piso visible detrás de las patas del sofá y agregar sombras de contacto.
* **Gato/Muebles flotando (Error 4):** La luz y los cables de la mesa auxiliar derecha cuelgan o flotan sin un punto claro de apoyo directo en el piso.

#### 2. SALA-COMEDOR

* **Inconsistencia de marcos de puerta (Error 1):** La puerta izquierda abierta es de un color marrón muy oscuro y plano, mientras que la de la derecha es una puerta con paneles detallados e iluminados.
   * *Qué hacer:* Estandarizar marcos e interiores con el mismo set de tiles de madera.
* **Objetos fuera de profundidad:** La mesa de comedor y las sillas no proyectan sombra proyectada ni de contacto en el piso de madera.

#### 3. RECIBIDOR-ENTRADA

* **Alineación de muebles a la pared (Error 16):** El mueble del recibidor (con el gato abajo) está colgado visualmente sobre la base de la pared sin margen de profundidad.
* **Caja de arena pegada al borde (Error 2):** La caja de arena del gato está demasiado cerca de la pared posterior sin espacio visual de separación.

#### 4. RECIBIDOR-ESCALERA

* **Volumen sin sentido bajo la escalera (Error 15):** Debajo de las escaleras hay una puerta/armario con una línea vertical marrón y cajas que no tienen perspectiva coherente con el ángulo del escalón.
   * *Qué hacer:* Rediseñar la estructura inferior para que sea o un mueble cerrado bien definido o un hueco claro con sombra.
* **Marcos y bisagras desalineadas:** La puerta abierta de la izquierda choca visualmente con el estante.

#### 5. COCINA-ENTRADA

* **Escala de ventanas (Error 12):** La ventana con vista al tanque de agua tiene el alféizar demasiado alto o desconectado en comparación con las ventanas de otras habitaciones.
* **Ratoncitos de cuerda flotando:** Los ratones metálicos en el piso parecen parches pegados directamente sobre el azulejo rosado, sin sombra de contacto ni integración.

#### 6. COCINA-MESÓN

* **Desproporción de objetos en el mesón (Error 18):** El pollo asado encima del microondas/mesón es gigante comparado con la cabeza del gato.
   * *Qué hacer:* Ajustar la escala del pollo (reducir a ~20 px de alto) para que no sea más grande que el microondas ni rompa la proporción del gato.
* **Gato en la silla:** El gato sobre la silla parece flotar al lado del mesón, sus patas no se apoyan de forma natural en el asiento.

#### 7. PASILLO-CONSOLA

* **Piso en banda plana (Error 16 y 17):** El espejo/consola central descansa directamente sobre el borde inferior del encuadre sin que se perciba la superficie del piso.
   * *Qué hacer:* Subir la base del mueble mínimo 12 px por encima del borde de la pantalla e incluir zócalo detrás.

#### 8. PASILLO-ESTUDIO

* **Pared plana y vacía / Falta de apoyo:** La alfombrilla o cama rosa del gato está tirada directamente en la línea horizontal de división entre pared y piso sin sombra o perspectiva que indique que es un elemento 3D redondeado.

#### 9. DORMITORIO-CAMA

* **Altura de ventana e iluminación (Error 12):** La ventana es gigante y cubre casi toda la pared vertical, mientras que en otros cuartos las ventanas son más pequeñas y están a otra altura.
* **Ropa flotando / Apoyo en la cama (Error 14):** Las mantas dobladas en la cama están colocadas perfectamente en el borde delantero sin volumen que se hunda en el colchón.

#### 10. DORMITORIO-ROPERO

* **Ropero pegado a la pared (Error 16):** El armario/ropero de la derecha no tiene profundidad de piso detrás ni sombra en la base.
* **Inconsistencia de cuadros:** Los cuadros pequeños colocados sobre la pared flotan demasiado alto en comparación con la altura de los ojos de los personajes.

#### 11. ESTUDIO

* **Cables y electrodomésticos sin soporte (Error 4 y 16):** La aspiradora robot (A.S.P.I.) y la impresora debajo del escritorio se ven como "sprites flotantes" pegados en la textura del piso sin sombras paralelas.
* **Puerta abierta a la nada (Error 1):** El fondo negro dentro de la puerta abierta izquierda no tiene el detalle de marco o grosor de pared que tienen otras puertas.

#### 12. BALCÓN

* **Transición exterior/interior (Error 17):** La losa de piedra gris del balcón no tiene una franja clara de borde o barandilla en el lado inferior, por lo que parece recortada al ras de la pantalla.
* **Macetas y gato flotando:** Las macetas del piso y el gato están alineados al mismo píxel base sin variar la profundidad (parece que caminara sobre un riel).

#### 13. PASILLO-BAÑO

* **Inconsistencia de marcos de puertas (Error 1):** Dos puertas contiguas exactas con el mismo diseño pero la alfombrilla del piso está corrida y sin perspectiva.

### 🛑 Patrones de Error Faltantes en tu Lista Actual

Para evitar que estos problemas se repitan en el arte futuro, te sugiero añadir estos 4 patrones a tu tabla de lecciones:

1. **Ausencia de Sombras de Contacto (Ambient Occlusion):**
   * *El problema:* Los objetos reposan sobre el suelo o superficies sin una elipse/línea de sombra oscura de 2 px debajo.
   * *Regla nueva:* Todo elemento apoyado debe llevar sombra de contacto proyectada directamente en la base.
2. **Corte de Arte al Ras del Marco (Crop al borde de pantalla):**
   * *El problema:* Muebles, pisos y alfombras rozan o se cortan con la barra negra/UI del juego de 0 px.
   * *Regla nueva:* Mantener un margen mínimo de seguridad de 8 a 12 px entre la base de los objetos transitables y la interfaz o borde del marco.
3. **Inconsistencia en la Dirección de la Luz Cenital:**
   * *El problema:* Unos muebles tienen sombras en el lado derecho (como la mesa de comedor) mientras que las ventanas o lámparas iluminan desde la izquierda.
   * *Regla nueva:* La fuente de luz primaria en interiores debe venir siempre desde arriba-izquierda (ángulo a 45°).
4. **Puertas sin Grosor de Pared (Falta de Umbral/Jamba):**
   * *El problema:* Cuando una puerta está abierta, se ve un rectángulo de negro puro dentro, sin mostrar los 4 a 6 px del grosor del muro de la casa.
   * *Regla nueva:* Toda puerta abierta debe mostrar el marco interior biselado para dar volumen al muro de la habitación.
