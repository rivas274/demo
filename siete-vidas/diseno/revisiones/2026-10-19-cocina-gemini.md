# Consulta de cocina a Gemini, tanda 3F (2026-10-19)

- **Fuente:** gemini.google.com (Gemini Automático), conversación nueva.
- **Imágenes adjuntas, en este orden:** `capturas/2026-10-19-creador-r5-8.png` (cocina, "captura 1"), `capturas/2026-10-19-creador-r5-9.png` (escalera), `arte/referencias/gemini/muebles-cocina.png`, `arte/referencias/gemini/muebles-sala.png` y `arte/felipe/felipe-A-base.png`.
- **Prompt:** "En mi juego de pixel art en vista lateral, la cocina se ve chica y el fregadero diminuto y flotando (captura 1). Busca en tu conocimiento cómo resuelven las cocinas los juegos indie de pixel art en vista lateral (Eastward, Stardew Valley, Unpacking, A Short Hike, Spiritfarer, Celeste) y dame una composición concreta para una cocina de unos 1300 px de ancho a escala de un gato de 67 px: qué muebles van, en qué orden de izquierda a derecha, qué alturas, y cómo se dibuja un fregadero embutido en vista lateral para que no parezca una bandeja. Después dime cómo hacer que los objetos pequeños sobre muebles (vaso, taza, monitor) se vean apoyados y no flotando."

> Nota de quien copió: al primer envío (con la frase "Responde solo con texto, sin generar imágenes." agregada al final) Gemini contestó solo "Solo soy una IA basada en texto, por lo que no puedo ayudarte con eso." Se reenvió en la misma conversación el prompt de arriba, sin esa frase y precedido de "Mira las imágenes que te adjunté arriba (la primera es la cocina de mi juego, la segunda la escalera, y las otras son referencias de estilo).". Esta es esa respuesta, sin editar. Solo se quitaron las etiquetas de cita "PNG" de la interfaz y se separaron en líneas propias dos viñetas que salieron pegadas.

## Respuesta (completa)

Analizando tu captura (1) y el gato de 67 px de alto, el problema principal actual es un desajuste de proporciones, perspectiva y sombreado:

1. **Escala y perspectiva:** El fregadero está dibujado con un borde metálico completo en vista 3/4 isométrica plana flotando sobre la encimera, mientras que el mueble está en vista lateral 2D pura. Además, la encimera actual (de unos 300-400 px) es demasiado pequeña para el gato de 67 px.
2. **Cómo lo resuelven juegos como *Eastward*, *Unpacking* o *Spiritfarer*:**
   * **Continuidad horizontal:** No dibujan un mueble aislado, sino un tramo continuo de encimera (*countertop*) que abarca de pared a pared o gran parte de la habitación.
   * **Profundidad simulada en vista lateral (3/4 Side-View):** La mesada tiene un bisel superior inclinado (3 a 5 px) donde se "hunden" o apoyan las cosas.
   * **Integración visual:** Los electrodomésticos grandes (heladera, cocina/horno) marcan los límites de altura verticales, rompiendo la monotonía de la mesada.

### 1. Composición de cocina ( Ancho: ~1300 px | Gato: 67 px)

Tomando como referencia humana un personaje estándar de ~100-110 px para esta escala (donde el gato le llega a la rodilla/muslo):

#### Proporciones de Altura Recomendadas:

* **Suelo a encimera:** **130 - 140 px** (el gato mide casi la mitad de la altura de la mesada).
* **Grosor del zócalo/borde superior de mesada:** **8 - 12 px**.
* **Hueco entre mesada y muebles altos:** **100 - 120 px**.
* **Muebles aéreos / Alacenas superiores:** **110 - 130 px de alto**, pegados al techo o dejando 30 px arriba.
* **Heladera / Refrigerador:** **210 - 240 px de alto**.

#### Distribución de Izquierda a Derecha (~1300 px):

Para llenar 1300 px sin que se vea vacía ni apretada, utiliza la regla de **3 zonas funcionales**:

| Posición (X) | Ancho | Elemento | Detalle visual y altura |
| --- | --- | --- | --- |
| **0 - 180 px** | ~180 px | **Heladera Vintage/Moderna** | **230 px de alto**. Sobresale en vertical cortando la línea horizontal. |
| **180 - 220 px** | ~40 px | **Espacio / Papelera o Bote de Basura** | Bote pequeño de 50 px de alto para respiración visual. |
| **220 - 620 px** | ~400 px | **Tramo 1: Mesada con Fregadero** | Mueble de 135 px de alto. Encima va el fregadero embutido + escurridor. |
| **620 - 780 px** | ~160 px | **Cocina / Horno integrado** | Mueble bajo con vitrocerámica/hornallas y puerta de horno de cristal negro. campana extractora arriba (120 px de alto). |
| **780 - 1100 px** | ~320 px | **Tramo 2: Mesada de Preparación** | Microondas, tabla de cortar o tostadora sobre la superficie. |
| **1100 - 1300 px** | ~200 px | **Comedor de Gato / Despensa** | Estantería abierta baja o repisas flotantes con platos de comida del gato. |

> **Muebles Aéreos (Pared Superior):**
> Coloca alacenas continuas desde los **220 px hasta los 1100 px** (longitud total de 880 px), dejando libre únicamente la zona de la campana extractora o la heladera.

### 2. Cómo dibujar un Fregadero Embutido en vista lateral

Para evitar el efecto "bandeja flotante" que ocurre en tu primera captura:

1. **Elimina el borde inferior exterior:** Un fregadero embutido no sobresale hacia afuera sobre la madera del mueble; el borde de madera debe cubrir el frente.
2. **Corta la madera de la encimera:**
   * Dibuja la moldura frontal de la mesada continua.
   * En la zona del fregadero, la línea del borde superior de la mesada debe "hundirse".
3. **Perspectiva de la pileta (3 a 4 px de profundidad visual):**
   * **Borde Trasero:** Una línea metálica clara (1-2 px) paralela a la pared.
   * **Pared Posterior Interna (Sombra):** 3 a 5 píxeles verticales teñidos de un tono gris/metálico **muy oscuro**.
   * **Fondo de la pileta:** Un tono metálico medio con la rejilla del desagüe (2x2 px).
   * **Borde Frontal:** No dibujes línea superior. El límite inferior de la pileta se esconde *detrás* del borde de la encimera.
4. **La Canilla / Grifo:**
   * Sale desde la **pared tras el fregadero** o desde el borde metálico posterior, **nunca flotando en medio del hueco**.
   * Dibuja la base colindante a la pared y la curva del tubo cayendo sobre la pileta.

### 3. Cómo hacer que los objetos pequeños se vean apoyados (no flotando)

El error común en vista lateral 2D / 3/4 es colocar los objetos sobre la línea límite del mueble sin interacción de luz/sombra ni oclusión.

#### A. Sombras de Contacto (Ambient Occlusion)

* **Sombra arrojada (1-2 px):** Todo objeto sobre un mueble (vaso, taza, monitor, microondas) DEBE tener una línea de sombra oscura (1 px de alto, tono marrón/gris oscuro según la madera) justo en la base donde toca la madera.
* **Ancho de la sombra:** La sombra de contacto debe ser 2 o 3 píxeles más ancha que la base del objeto en la dirección opuesta a la luz.

#### B. Oclusión y Solapamiento (Overlap)

* **Punto de apoyo:** El borde inferior del objeto no debe rasar con el borde superior del mueble. Debe bajar **1 o 2 píxeles por debajo de la línea posterior de la mesada**, simulando que está apoyado sobre la superficie plana y no en el filo traslapado.
* **Biseles y tapetes:** Si pones un objeto pequeño como un vaso o un monitor, pon debajo un posavasos, tapete o mantel individual de 1 px de grosor. Esto "ancla" visualmente el sprite al plano.

#### C. Consistencia de la Fuente de Luz

* Define de dónde viene la luz principal (ejemplo: ventana a la izquierda o lámpara superior).
* La parte inferior izquierda o derecha de cada pequeña taza/tostadora debe alinearse en tono con la sombra proyectada sobre la tabla del mueble.
