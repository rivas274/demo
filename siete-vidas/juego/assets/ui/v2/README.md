# Kit de interfaz v2 («A + C»)

Piezas finales de la interfaz v2, estilo **A + C** (la A, Corte diagonal, con la sombra de color de la C), a la escala
real del juego (base 640×360). **Están programadas** (2026-10-23): `herramientas/interfaz_v2_tema.py` las pone en el tema
(`datos/ui/tema.tres`: `styles/v2_<pieza>` las que se estiran, con sus cortes y la sombra como `expand_margin_*`;
`icons/v2_<pieza>` las demás) y el juego las dibuja con `KitUI` (`scripts/ui/base/kit_ui.gd`). Las caras chicas
(salud, jefe, diálogo y Ficha) están en `caras/` y las hace `herramientas/interfaz_v2_caras.py`.

- Las genera `siete-vidas/herramientas/interfaz_v2_kit.py` (no editar los PNG a mano: se rehacen con el script).
- Dirección y medidas: `siete-vidas/diseno/interfaz-v2.md` (sección «Dirección de arte: ELEGIDA la A con el toque de la C»).
- Lámina de revisión: `siete-vidas/diseno/revisiones/capturas/interfaz-rediseno/kit-v2.png` (y `-x2`), con todas las
  piezas a ×1 y ×4 y las 4 pantallas rearmadas solo con el kit junto a `direccion-arte-AC-v2.png`.
- Todo va en colores exactos de la paleta de abajo, sin suavizado ni alfa a medias (el script lo comprueba).

## Cómo se usan

- **Ancla:** cada PNG está recortado a lo que ocupa, con la sombra adentro. El «ancla» es dónde cae, dentro del PNG, la
  esquina (x, y) que usa el layout. Ejemplo: `dialogo-marco-valeria.png` con ancla (0, 0) y 68x54 es la caja de 64x50
  más 1 px de contorno y 3 px de sombra.
- **Medida lógica:** el ancho y alto con que el layout dibuja la caja (sin sombra). Las piezas que se estiran se
  guardan con un ancho lógico corto (64, 40 o 104); se estiran al ancho que pida el texto.
- **Cortes de 9 partes:** son los márgenes de `NinePatchRect` (o `StyleBoxTexture`) en px del PNG. Las cajas tienen los
  lados en diagonal de arriba abajo, así que **se estiran solo a lo ancho**: el alto es fijo (por eso hay una pieza
  por alto, normal y grande). Para el alto fijo se usa `patch_margin_top` + `patch_margin_bottom` = alto del PNG.
- **Texto grande (200 %):** las cajas se dibujan a su medida grande con líneas de 1 px (no se escalan); las huellas y
  el ícono del logro se duplican (`-grande`).
- **Velo de la pausa:** no es PNG; es un `ColorRect` del color `fondo` al 78 % (alfa 200).
- **Fragmentos:** los fondos de retrato y el cartel llevan triangulitos alrededor; van aparte (`fragmentos-*.png`) para
  que se puedan mover y animar. Con «Reducir movimiento» quedan quietos.
- **Hueco entre el retrato y el texto:** al menos 6 px libres después del retrato, su fondo, su sombra y sus
  fragmentos. Medido en la lámina del kit: 13 px en normal y 12 px con texto grande (el texto empieza a 24 px del
  borde de la caja, `x` 104 en la base). `interfaz_v2_kit_lamina.py` lo mide y corre el texto si alguna vez baja de 6.

## Piezas

| Archivo | PNG | Medida lógica | Ancla | Corte | Origen | Uso |
| --- | --- | --- | --- | --- | --- | --- |
| `dialogo-marco-felipe.png` | 68x54 | 64x50 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de felipe. |
| `dialogo-marco-felipe-grande.png` | 68x88 | 64x84 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de felipe. |
| `dialogo-marco-valeria.png` | 68x54 | 64x50 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de valeria. |
| `dialogo-marco-valeria-grande.png` | 68x88 | 64x84 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de valeria. |
| `dialogo-marco-aspi.png` | 68x54 | 64x50 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de aspi. |
| `dialogo-marco-aspi-grande.png` | 68x88 | 64x84 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del diálogo; sombra dura de 3 px de aspi. |
| `dialogo-flecha.png` | 6x9 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Flecha de «sigue» abajo a la derecha de la caja. |
| `nombre-franja-felipe.png` | 42x17 | 40x15 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 7, der 6 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de felipe (el texto va encima). |
| `nombre-franja-felipe-grande.png` | 42x28 | 40x26 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 10, der 9 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de felipe (el texto va encima). |
| `nombre-franja-valeria.png` | 42x17 | 40x15 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 7, der 6 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de valeria (el texto va encima). |
| `nombre-franja-valeria-grande.png` | 42x28 | 40x26 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 10, der 9 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de valeria (el texto va encima). |
| `nombre-franja-aspi.png` | 42x17 | 40x15 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 7, der 6 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de aspi (el texto va encima). |
| `nombre-franja-aspi-grande.png` | 42x28 | 40x26 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 10, der 9 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre en bloque de aspi (el texto va encima). |
| `retrato-fondo-felipe.png` | 62x62 | 58x58 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de felipe; sombra oscura de 3 px. |
| `retrato-fondo-felipe-grande.png` | 62x64 | 58x60 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de felipe; sombra oscura de 3 px. |
| `retrato-fondo-valeria.png` | 62x62 | 58x58 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de valeria; sombra oscura de 3 px. |
| `retrato-fondo-valeria-grande.png` | 62x64 | 58x60 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de valeria; sombra oscura de 3 px. |
| `retrato-fondo-aspi.png` | 62x62 | 58x58 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de aspi; sombra oscura de 3 px. |
| `retrato-fondo-aspi-grande.png` | 62x64 | 58x60 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de aspi; sombra oscura de 3 px. |
| `fragmentos-felipe.png` | 24x6 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Tira de 4 fragmentos (2, 3, 4 y 5 px) en celdas de 6x6. |
| `fragmentos-valeria.png` | 24x6 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Tira de 4 fragmentos (2, 3, 4 y 5 px) en celdas de 6x6. |
| `fragmentos-aspi.png` | 24x6 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Tira de 4 fragmentos (2, 3, 4 y 5 px) en celdas de 6x6. |
| `jefe-retrato-marco.png` | 34x30 | 30x26 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Marco chico e inclinado del retrato del jefe. |
| `jefe-barra-marco.png` | 224x18 | 220x14 | — | 3 partes a lo ancho (alto fijo): izq 7, der 10 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Marco de la barra, vacío; sombra roja de 3 px. |
| `jefe-barra-cortes.png` | 224x18 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Los 2 cortes en diagonal que parten la barra en 3 fases; va encima de los rellenos, en el mismo lugar y del mismo tamaño que el marco. |
| `jefe-barra-relleno.png` | 4x6 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Tira de vida (se repite a lo ancho): 6 px de alto con la luz arriba. |
| `jefe-barra-dano.png` | 4x6 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Tira de «daño reciente» crema (se repite a lo ancho); baja 300 ms después. |
| `jefe-nombre-franja.png` | 42x16 | 40x14 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 6, der 5 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja del nombre del jefe (14 px). |
| `hud-caja.png` | 156x24 | 152x20 | — | 3 partes a lo ancho (alto fijo): izq 7, der 11 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja de la salud (cara + 9 huellas), 152x20. |
| `hud-caja-grande.png` | 308x44 | 304x40 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja de la salud con texto grande, 304x40. |
| `huella-llena.png` | 13x12 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella de salud, estado «llena». |
| `huella-llena-grande.png` | 26x24 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella «llena» a x2 (texto grande). |
| `huella-media.png` | 13x12 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella de salud, estado «media». |
| `huella-media-grande.png` | 26x24 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella «media» a x2 (texto grande). |
| `huella-vacia.png` | 13x12 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella de salud, estado «vacia». |
| `huella-vacia-grande.png` | 26x24 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella «vacia» a x2 (texto grande). |
| `huella-golpe.png` | 13x12 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella de salud, estado «golpe». |
| `huella-golpe-grande.png` | 26x24 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella «golpe» a x2 (texto grande). |
| `huella-curando.png` | 13x12 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella de salud, estado «curando». |
| `huella-curando-grande.png` | 26x24 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-4.png (generado con Gemini y retocado) | Huella «curando» a x2 (texto grande). |
| `cartel-franja.png` | 109x27 | 104x22 | — | 3 partes a lo ancho (alto fijo): izq 13, der 15 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja diagonal del cartel; sombra OSCURA de 4 px (el magenta es de Valeria). |
| `cartel-sello.png` | 29x31 | — | — | no se estira | IA (la huella): ChatGPT, hoja chatgpt/interfaz-v2/intento-1.png (generado con ChatGPT y retocado); el rombo, código | Sello en rombo con la huella. |
| `cartel-linea.png` | 68x23 | 64x19 | — | 3 partes a lo ancho (alto fijo): izq 8, der 12 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Segunda línea del cartel (nombre de la travesura). |
| `logro-etiqueta.png` | 108x28 | 104x24 | — | 3 partes a lo ancho (alto fijo): izq 10, der 14 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Etiqueta del logro (entra de lado). |
| `logro-icono.png` | 21x21 | — | — | no se estira | código + huella del kit | Rombo ámbar con la huella vacía. |
| `logro-etiqueta-grande.png` | 108x44 | 104x40 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Etiqueta del logro (entra de lado). |
| `logro-icono-grande.png` | 37x37 | — | — | no se estira | código + huella del kit | Rombo ámbar con la huella vacía. |
| `aviso-marco.png` | 68x24 | 64x20 | — | 3 partes a lo ancho (alto fijo): izq 8, der 12 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Panel oscuro con borde y sombra limón (nunca un bloque amarillo). |
| `aviso-flecha.png` | 11x7 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Flecha limón hacia abajo (apunta a lo que hay que hacer). |
| `globito-caja.png` | 68x22 | 64x18 | — | 3 partes a lo ancho (alto fijo): izq 8, der 12 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Caja del globito (una línea); sombra ámbar de 3 px. |
| `globito-oreja-izq.png` | 11x8 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-2.png (generado con Gemini y retocado) | Orejita izquierda (la base abre el borde). |
| `globito-oreja-der.png` | 11x8 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-2.png (generado con Gemini y retocado) | Orejita derecha (espejo). |
| `globito-cola.png` | 8x13 | — | — | no se estira | IA: Gemini, hoja gemini/interfaz-v2/intento-3.png (generado con Gemini y retocado) | Cola corta con huellita; sale por abajo. |
| `pausa-panel.png` | 580x328 | 576x324 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Panel de la pausa (toda la zona segura). |
| `titulo-franja.png` | 42x20 | 40x18 | (1, 0) | 3 partes a lo ancho (alto fijo): izq 8, der 7 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Franja de título («PAUSA», «BOLSILLO»), 18 px. |
| `boton-normal.png` | 65x20 | 64x19 | — | 3 partes a lo ancho (alto fijo): izq 6, der 6 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Botón sin foco: del color del panel (en la lámina solo se ve su texto). |
| `boton-resaltado.png` | 65x20 | 64x19 | — | 3 partes a lo ancho (alto fijo): izq 7, der 7 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Botón con foco: bloque diagonal ámbar, texto oscuro. |
| `boton-apretado.png` | 65x20 | 64x19 | — | 3 partes a lo ancho (alto fijo): izq 7, der 7 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Botón apretado: ámbar oscuro. |
| `bolsillo-fila.png` | 68x26 | 64x22 | — | 3 partes a lo ancho (alto fijo): izq 7, der 11 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fila del bolsillo (ícono, nombre y valor). |
| `icono-snack.png` | 14x9 | — | — | no se estira | IA: ChatGPT, hoja chatgpt/interfaz-v2/intento-1.png (generado con ChatGPT y retocado) | Pescadito de snack (12x7 de relleno). |
| `icono-calcetin.png` | 9x10 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Calcetín del bolsillo. |
| `icono-foto.png` | 11x9 | — | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Foto del bolsillo. |
| `ficha-panel.png` | 398x170 | 394x166 | — | 3 partes a lo ancho (alto fijo): izq 12, der 16 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Panel de la Ficha de Su Majestad (en la pausa). |
| `ficha-retrato-fondo.png` | 60x56 | 56x52 | — | no se estira | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Fondo inclinado del retrato de la Ficha. |
| `ficha-barra-marco.png` | 61x10 | 60x9 | — | 3 partes a lo ancho (alto fijo): izq 4, der 4 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Marco de la barra de estadística (puntas en diagonal). |
| `ficha-barra-relleno-felipe.png` | 31x8 | 30x7 | — | 3 partes a lo ancho (alto fijo): izq 3, der 3 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Relleno de la barra de estadística (va a 1 px adentro del marco). |
| `ficha-barra-relleno-maquina.png` | 31x8 | 30x7 | — | 3 partes a lo ancho (alto fijo): izq 3, der 3 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Relleno de la barra de estadística (va a 1 px adentro del marco). |
| `ficha-barra-relleno-aspi.png` | 31x8 | 30x7 | — | 3 partes a lo ancho (alto fijo): izq 3, der 3 | código (interfaz_v2_kit.py, mismas funciones que la lámina) | Relleno de la barra de estadística (va a 1 px adentro del marco). |

## Piezas sacadas de las hojas de IA

Método: recorte de cada pieza en las 5 hojas (ChatGPT 1 y Gemini 1 a 4), silueta y relleno, reducción al tamaño del
juego por 3 métodos («mayoría», «huecos» y «centro»), paleta exacta y limpieza (sin píxeles sueltos, contorno de 1 px).
Cada variante se mide de 0 a 1 (apego a la paleta, limpieza, partes que se leen a ×1, simetría o apego a la forma de la
lámina) y se revisa en `kit-v2-variantes.png`. La ganadora se retocó a mano píxel a píxel (la rejilla final y lo que
se cambió están en `interfaz_v2_kit.py`).

| Pieza | Variantes | Ganadora | Puntaje |
| --- | --- | --- | --- |
| huella | 15 | gemini-4 huecos | 0.74 |
| sello | 18 | chatgpt-1 huecos | 0.79 |
| snack | 15 | chatgpt-1 centro | 0.85 |
| oreja | 30 | gemini-2-der centro | 0.84 |
| cola | 15 | gemini-3 centro | 0.95 |

**Créditos:** huella y huella del sello, generadas con Gemini y ChatGPT y retocadas; pescadito, generado con ChatGPT y
retocado; orejita y cola del globito, generadas con Gemini y retocadas (hojas en `siete-vidas/arte/referencias/`).
Todo lo demás, dibujado por código.

## Paleta del kit

| Nombre | Color |
| --- | --- |
| fondo | `#241A26` |
| panel | `#30242C` |
| linea | `#F4E2BB` |
| texto | `#FFF0D5` |
| apagado | `#8A7480` |
| contorno | `#120C12` |
| sombra | `#0B070B` |
| felipe | `#E8913A` |
| oportunidad | `#FFE066` |
| valeria | `#D8336B` |
| aspi | `#E04848` |
| maquina | `#4CC9E0` |
| felipe_luz | `#F4C89C` |
| felipe_osc | `#9D622C` |
| felipe_brillo | `#F6D3B0` |
| cura_luz | `#F8DBBF` |
| cura | `#F0B87F` |
| cura_osc | `#BF9976` |
| vacio | `#504049` |
| vacio_luz | `#6F5C67` |
| aspi_luz | `#EE9A9A` |
