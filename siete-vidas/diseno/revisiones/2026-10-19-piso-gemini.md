# Consulta de piso a Gemini (2026-10-19)

- **Fuente:** gemini.google.com (Gemini Automático), conversación nueva "Guía de Corrección de Pixel Art".
- **Imágenes adjuntas:** `capturas/2026-10-19-creador-piso-3.png`, `capturas/2026-10-19-creador-piso-4.png`, `capturas/2026-10-19-creador-piso-5.png` y `arte/referencias/gemini/muebles-sala.png`.
- **Prompt:** "Eres artista de entornos de pixel art 2D en vista lateral (como Eastward, Stardew Valley o Untitled Goose Game). En estas capturas de mi juego, el piso de madera se ve mal: parece apresurado y montado, con líneas oscuras raras, y los muebles y el gato no parecen pisarlo. ¿Qué está mal, exactamente? ¿Cómo se dibuja bien un piso en un juego de plataformas de vista lateral con un poco de profundidad: cuántos px de piso se ven detrás de los pies, perspectiva de las tablas sí o no, cómo se resuelve la unión con el zócalo y la pared, y cómo se apoyan los muebles con sombra? Dame instrucciones concretas que un programador pueda aplicar con píxeles."

> Nota de quien copió: al primer envío Gemini no escribió texto. Generó una imagen de "antes y después" del piso, guardada en `capturas/2026-10-19-piso-gemini-antes-despues.png` (2708x368, convertida de JPG a PNG). Se repreguntó en la misma conversación: "No quiero una imagen. Respóndeme SOLO CON TEXTO, sin generar imágenes, a la pregunta anterior sobre las capturas: [la misma pregunta]". Abajo va esa respuesta, sin editar, salvo por las etiquetas de cita "JPG" que Gemini pone como botones junto a algunas frases, que se quitaron.

## Respuesta (completa)

Como artista de entornos 2D, entiendo perfectamente el dolor de cabeza: el tile de madera actual tiene líneas horizontales negras muy agresivas y desorganizadas que parecen ruido digital, lo que rompe la ilusión de una superficie plana transitable. Además, al no haber profundidad visible detrás de los personajes y carecer de sombras de contacto, todo da la sensación de estar "pegado" o flotando sobre un fondo gris.

Aquí tienes el diagnóstico exacto y las **instrucciones técnicas y de píxeles** para que un programador o artista lo resuelva de inmediato:

#### 1. ¿Qué está mal exactamente? (Diagnóstico)

* **Las líneas oscuras del piso:** Se usaron trazos negros aleatorios o de un solo píxel muy contrastado en horizontal, simulando tablones vistos desde arriba o con una textura ruidosa que no respeta la iluminación cenital del juego.
* **Falta de "Grounding" (Soporte):** Las patas de los muebles, los objetos y el gato terminan exactamente donde empieza la línea de colisión, sin una transición de sombra o profundidad, haciendo que parezca que flotan.
* **Desconexión con la pared:** La línea de base donde se une la pared con el suelo carece de un zócalo (rodapié) limpio, lo que hace que ambos elementos choquen visualmente de forma extraña.

#### 2. Guía de Píxeles para un Piso de Vista Lateral con Profundidad

##### A. ¿Perspectiva de las tablas sí o no?

* **NO uses perspectiva de tablas (convergencia o líneas diagonales)** en un juego de plataformas de vista lateral pura. Las tablas deben ser horizontales o tener un patrón siso/espiga limpio que se repita lateralmente (tileable). Intentar meter fuga en un plano 2D lateral de plataformas genera distorsión cuando el personaje camina hacia los extremos.

##### B. ¿Cuántos píxeles de piso se ven detrás de los pies?

* **De 12 a 16 píxeles de profundidad** por encima de la línea de colisión de los pies.
* Esto significa que el tile o la franja de piso visible entre la pared (zócalo) y los pies del personaje debe tener esa altura en píxeles. Esto da el "colchón" visual necesario para que el escenario se sienta tridimensional y no una simple línea plana.

##### C. Unión con el zócalo y la pared

* **El Zócalo (Rodapié):** Dibuja una franja horizontal sólida de 2 a 3 píxeles de alto en la base de la pared, con un color ligeramente más claro en su borde superior (como un bisel o brillo de luz) y una línea de sombra de 1 píxel justo donde choca con el piso de madera.
* Esto separa mecánicas y visualmente la pared vertical del plano horizontal transitable.

##### D. Apoyo de muebles y personajes (Sombras de contacto)

Para que los muebles y el gato paren de "flotar" y pisen bien el suelo, el programador debe aplicar dos capas de píxeles en las coordenadas de contacto:

1. **Sombra de contacto cenital:** Una pequeña elipse difuminada u opaca de **2 píxeles de alto por el ancho de la base de cada pata** (o de la pezuña/patas del gato), pintada justo debajo de estas en un tono marrón oscuro semitransparente.
2. **Oclusores de ambiente:** Una línea de sombra de 1 píxel pegada a la base trasera de los muebles grandes (como el sofá o el estante) para indicar que tapan la luz que viene de arriba.
