class_name FuenteDesorden
extends Node2D
## Pieza para lo que suelta cosas de a una (pilar 2: tirar es llave y travesura): las notas del corcho, los libros del
## estante, los apuntes que vuelan al pisar el teclado. Cada vez que Felipe le da un manotazo (o el nivel la activa)
## suelta la siguiente: cae con física simple (PiezaSuelta), queda en el piso con su sombra y avisa con `soltada`.
## Nada vuelve a su lugar: el arte del mueble cambia a su versión con el hueco (`<arte>_<n>`). Cuando se acaba, deja
## de ofrecerse. Sus datos (DatosFuente) dicen qué suelta, desde dónde y cuántas veces.
## La posición del nodo es la base del arte, en su centro (como ArteNivel.dibujar).

## Una cosa llegó al piso. `mancha` es el tipo de mancha que deja ("" = la pieza misma es la mancha).
signal soltada(pieza: PiezaSuelta, mancha: String)

const GRUPO := "fuentes_desorden"

@export var datos: DatosFuente
## Cuántas soltó ya.
var usadas := 0
## Las que van cayendo (cuentan como suciedad en camino).
var en_vuelo := 0
## Línea del piso (y en el mundo) donde terminan.
var piso := 0.0


static func crear(datos_fuente: DatosFuente, base: Vector2, piso_y: float) -> FuenteDesorden:
	var fuente := FuenteDesorden.new()
	fuente.datos = datos_fuente
	fuente.name = "Fuente " + (datos_fuente.arte if datos_fuente.arte != "" else datos_fuente.piezas[0] if not datos_fuente.piezas.is_empty() else "")
	fuente.position = base
	fuente.piso = piso_y
	return fuente


func _ready() -> void:
	add_to_group(GRUPO)
	if datos.ofrecer:
		add_to_group(Componentes.INTERACTUABLES)
	Capas.usar(self, Capas.ARTE_PARED if datos.capa == "pared" else Capas.MUEBLES)


## Cuántas le quedan por soltar.
func restantes() -> int:
	return maxi(0, datos.piezas.size() - usadas)


func disponible(_felipe: Felipe) -> bool:
	return restantes() > 0


func verbo(_felipe: Felipe) -> String:
	return datos.verbo


## Felipe la alcanza en este punto (no en la base del arte).
func punto_para(_desde: Vector2) -> Vector2:
	return global_position + datos.alcance


## Felipe da el manotazo; la siguiente cae cuando la pata llega (cuadro de impacto).
func interactuar(felipe: Felipe) -> void:
	if restantes() <= 0:
		return
	felipe.dar_manotazo(soltar.bind(-felipe.mirando if datos.hacia_felipe else felipe.mirando))


## Suelta la siguiente hacia `hacia` (1 = derecha). Devuelve la pieza (null si ya no queda nada).
func soltar(hacia := 1.0) -> PiezaSuelta:
	if restantes() <= 0:
		return null
	var i := usadas
	usadas += 1
	en_vuelo += 1
	if restantes() == 0:
		remove_from_group(Componentes.INTERACTUABLES)
	var desde: Vector2 = datos.salidas[i] if i < datos.salidas.size() else Vector2.ZERO
	var pieza := PiezaSuelta.crear(datos.piezas[i], global_position + desde, Vector2(datos.velocidad.x * signf(hacia if hacia != 0.0 else 1.0), datos.velocidad.y), piso)
	pieza.gravedad = datos.gravedad
	pieza.vueltas = datos.vueltas * (1.0 if randf() < 0.5 else -1.0)
	pieza.con_sombra = true
	Capas.usar(pieza, Capas.JUEGO)
	pieza.apoyada.connect(_al_apoyarse)
	get_parent().add_child(pieza)
	var nivel := Componentes.nivel(self)
	if nivel:
		nivel.sonar(datos.sonido)
	queue_redraw()
	return pieza


func _al_apoyarse(pieza: PiezaSuelta) -> void:
	en_vuelo = maxi(0, en_vuelo - 1)
	soltada.emit(pieza, datos.mancha)


func _draw() -> void:
	if datos.arte == "" or usadas == 0:
		return
	# Encima del arte de siempre (que dibuja el nivel), su versión con el hueco: misma imagen, mismo lugar.
	ArteNivel.dibujar(self, "%s_%d" % [datos.arte, usadas], 0.0, 0.0)


## Para el contorno del Indicador: la silueta de la que va a caer, en su lugar (la nota, el libro parado).
func arte_indicador() -> Dictionary:
	if restantes() <= 0:
		return {}
	var i := usadas
	var nombre: String = datos.en_su_lugar[i] if i < datos.en_su_lugar.size() and datos.en_su_lugar[i] != "" else datos.piezas[i]
	var desde: Vector2 = datos.salidas[i] if i < datos.salidas.size() else Vector2.ZERO
	var arte := ArteNivel.arte_en(self, nombre, desde.x, desde.y)
	if not arte.is_empty():
		arte["z"] = z_index
	return arte


func rect_indicador() -> Rect2:
	return Rect2(global_position + datos.rect.position, datos.rect.size)
