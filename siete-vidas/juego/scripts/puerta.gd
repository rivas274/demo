class_name Puerta
extends Node2D
## Puerta entre habitaciones. Junto a ella, el botón de acción o arriba la cruza: la sala funde a negro y Felipe
## aparece en la puerta del otro lado. Una puerta cerrada no deja pasar (la del balcón, hasta apagar a A.S.P.I.).

signal cruzada(puerta: Puerta)

const ANCHO := 64.0
## Puerta de 2,05 m; si el techo queda más cerca (arriba de la escalera), es un vano más bajo.
const ALTO_MAXIMO := 248.0
const CERCA := 30.0

var destino: String
var alto := ALTO_MAXIMO
var cerrada := false
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
	var marco := Color("6e3a26")
	draw_rect(Rect2(-ANCHO / 2.0 - 6.0, -alto - 6.0, ANCHO + 12.0, alto + 6.0), marco)
	draw_rect(Rect2(-ANCHO / 2.0, -alto, ANCHO, alto), Color("2a1d1a"))
	if cerrada:
		draw_rect(Rect2(-ANCHO / 2.0 + 2.0, -alto + 2.0, ANCHO - 4.0, alto - 2.0), Color("b0613f"))
		draw_rect(Rect2(-ANCHO / 2.0 + 8.0, -alto + 12.0, ANCHO - 16.0, alto * 0.4), Color("c47a55"))
		draw_circle(Vector2(ANCHO / 2.0 - 10.0, -alto * 0.45), 3.0, Color("f2d36b"))
	else:
		# Luz que sale del otro cuarto.
		draw_rect(Rect2(-ANCHO / 2.0 + 6.0, -alto + 6.0, ANCHO - 12.0, alto - 6.0), Color(1.0, 0.85, 0.6, 0.12))
	if _cerca:
		# Flecha que invita a entrar.
		var y := -alto - 18.0
		draw_colored_polygon(PackedVector2Array([Vector2(-8, y + 6), Vector2(8, y + 6), Vector2(0, y - 6)]), Color("ffe066"))
