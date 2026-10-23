class_name DatosFuente
extends Resource
## Los datos de una fuente de desorden (FuenteDesorden): algo del mundo que suelta cosas de a una cada vez que Felipe le
## da un manotazo (las notas del corcho, los libros del estante) o cada vez que alguien la activa (los apuntes del
## teclado). Lo que suelta cae, queda en el piso y deja una mancha para A.S.P.I. Nada vuelve a su lugar.
## Una fuente nueva es un archivo .tres en `datos/fuentes/` más una línea en los datos del nivel (dónde va).

## Imagen del mueble o la pared que la lleva ("" = no dibuja nada: el teclado lo dibuja el decorado). Después de
## soltar n cosas se dibuja `<arte>_<n>` (la pizarra sin la nota, el librero con el hueco), recombinada del mismo arte
## con `herramientas/preparar_arte_nivel.py desorden`.
@export var arte := ""
## Capa donde se dibuja: "pared" (Capas.ARTE_PARED) o "mueble" (Capas.MUEBLES).
@export var capa := "mueble"
## Verbo de Felipe en la burbuja del Indicador.
@export var verbo := "VERBO_DESORDENAR"
## Si Felipe la usa con el botón de acción (false: la activa el nivel, como el teclado al pisarlo).
@export var ofrecer := true
## Imagen de cada cosa que suelta, en orden (cuántas hay = cuántas veces se puede usar).
@export var piezas: PackedStringArray = []
## Desde dónde sale cada una: el medio de su base, en su lugar (relativo a la base del arte, en su centro).
@export var salidas: PackedVector2Array = []
## Imagen de cada una en su lugar, antes de caer (el contorno del Indicador sigue su silueta; "" = la de `piezas`):
## el libro parado en el estante, mientras que al caer queda acostado.
@export var en_su_lugar: PackedStringArray = []
## Dónde la alcanza Felipe (relativo a la base del arte): se compara con su alcance de 48 × 40 px.
@export var alcance := Vector2.ZERO
## Rectángulo que declara para las reglas (lado menor ≥ 24) y los anuncios, relativo a la base del arte.
@export var rect := Rect2(-16, -24, 32, 24)
## Mancha que deja en el piso para A.S.P.I.: "" = la pieza misma (el papel, la nota) es la mancha y se la lleva al
## limpiar; otro tipo ("papel") = la pieza queda en el piso como desorden y esa mancha va al lado.
@export var mancha := ""
## Caída: gravedad, velocidad inicial (x hacia donde mira Felipe) y vueltas por segundo (las notas caen planeando).
@export var gravedad := 900.0
@export var velocidad := Vector2(70, -60)
## Sale hacia Felipe (el libro que saca del estante) en vez de hacia donde mira (la nota que despega de un manotazo).
@export var hacia_felipe := false
@export var vueltas := 1.0
## Sonido del nivel al soltar y al llegar al piso.
@export var sonido := "caja"
