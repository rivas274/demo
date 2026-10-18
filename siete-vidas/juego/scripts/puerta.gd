class_name Puerta
extends Node2D
## Puerta entre habitaciones. Junto a ella, el botón de acción o arriba la cruza: la sala funde a negro y Felipe
## aparece en la puerta del otro lado. Una puerta cerrada no deja pasar (la del balcón, hasta apagar a A.S.P.I.).

signal cruzada(puerta: Puerta)

## Escala de gato: puertas gruesas y legibles.
const ANCHO := 104.0
## Puerta de 2,05 m; si el techo queda más cerca (arriba de la escalera), es un vano más bajo.
const ALTO_MAXIMO := 248.0
const CERCA := 44.0

var destino: String
var alto := ALTO_MAXIMO
var cerrada := false
## Pie de la escalera de fondo: no se dibuja marco, solo la flecha (la sala anima la subida).
var escalera := false
## Arte: "" puerta de madera, "balcon" puerta-ventana, "vano" arco sin hoja.
var estilo := ""
var _felipe: Felipe
var _cerca := false


func _init(nombre_puerta: String, posicion: Vector2, puerta_destino: String, alto_disponible: float) -> void:
	name = nombre_puerta
	position = posicion
	destino = puerta_destino
	alto = minf(ALTO_MAXIMO, alto_disponible)
	z_index = -2


func _ready() -> void:
	add_to_group(Comida.GRUPO)
	_felipe = get_tree().get_first_node_in_group("felipe")


func interactuar(_felipe_que_entra: Felipe) -> void:
	cruzada.emit(self)


func _physics_process(_delta: float) -> void:
	if _felipe == null:
		return
	var distancia := _felipe.global_position - global_position
	var cerca := absf(distancia.x) < CERCA and absf(distancia.y) < 6.0
	if cerca != _cerca:
		_cerca = cerca
		queue_redraw()
	if cerca and _felipe.is_on_floor() and Input.is_action_just_pressed("mover_arriba"):
		cruzada.emit(self)


func _draw() -> void:
	if escalera:
		if _cerca:
			_flecha(-90.0)
		return
	var arte := "vano" if estilo == "vano" else ("puerta_balcon" if estilo == "balcon" and cerrada else ("puerta_cerrada" if cerrada else "puerta_abierta"))
	ArteNivel.dibujar(self, arte, 0.0, 0.0)
	if _cerca:
		_flecha(-ArteNivel.textura("puerta_abierta").get_size().y - 14.0 if estilo != "vano" else -ArteNivel.textura("vano").get_size().y - 14.0)


## Flecha que invita a entrar.
func _flecha(y: float) -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-8, y + 6), Vector2(8, y + 6), Vector2(0, y - 6)]), Color("ffe066"))
