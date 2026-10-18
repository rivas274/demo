class_name Laser
extends Node2D
## Punto del puntero láser: corre por el piso y siempre se escapa de Felipe. Imposible de atrapar.

const RADIO_HUIDA := 70.0

var limite_izquierdo: float
var limite_derecho: float

var _destino: Vector2
var _azar := RandomNumberGenerator.new()


func _init(izquierda: float, derecha: float) -> void:
	limite_izquierdo = izquierda
	limite_derecho = derecha
	name = "Laser"
	_azar.seed = 3


func _ready() -> void:
	_destino = position


func _process(delta: float) -> void:
	var felipe: Felipe = get_tree().get_first_node_in_group("felipe")
	if felipe and absf(felipe.global_position.x - global_position.x) < RADIO_HUIDA and absf(felipe.global_position.y - global_position.y) < 60.0:
		# Se escapa al otro lado de Felipe, justo fuera de su alcance.
		var lado := -signf(felipe.global_position.x - global_position.x)
		_destino.x = clampf(felipe.global_position.x + lado * _azar.randf_range(110, 170), limite_izquierdo, limite_derecho)
	elif position.distance_to(_destino) < 4.0:
		_destino.x = _azar.randf_range(limite_izquierdo, limite_derecho)
	position.x = move_toward(position.x, _destino.x, 420.0 * delta)
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0, -1), 4.0, Color(1, 0.1, 0.1, 0.25))
	draw_circle(Vector2(0, -1), 2.0, Color("ff2a2a"))
