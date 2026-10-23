class_name Laser
extends Node2D
## Punto del puntero láser: corre por el piso y siempre se escapa de Felipe. Imposible de atrapar.

const RADIO_HUIDA := 70.0

var limite_izquierdo: float
var limite_derecho: float

var _destino: Vector2
## Apagado "de vergüenza" (Felipe lo ignoró 5 s).
var apagado := false
var _azar := RandomNumberGenerator.new()


func _init(izquierda: float, derecha: float) -> void:
	limite_izquierdo = izquierda
	limite_derecho = derecha
	name = "Laser"
	_azar.seed = 3


func _ready() -> void:
	_destino = position
	Profundidad.poner(self, Capas.Rol.OBJETO_JUEGO)


func apagar() -> void:
	apagado = true
	queue_redraw()


func _process(delta: float) -> void:
	if apagado:
		return
	var felipe: Felipe = get_tree().get_first_node_in_group("felipe")
	if felipe and absf(felipe.global_position.x - global_position.x) < RADIO_HUIDA and absf(felipe.global_position.y - global_position.y) < 60.0:
		# Se escapa al otro lado de Felipe, justo fuera de su alcance.
		var lado := -signf(felipe.global_position.x - global_position.x)
		_destino.x = clampf(felipe.global_position.x + lado * _azar.randf_range(110, 170), limite_izquierdo, limite_derecho)
	elif position.distance_to(_destino) < 4.0:
		_destino.x = _azar.randf_range(limite_izquierdo, limite_derecho)
	position.x = move_toward(position.x, _destino.x, 420.0 * delta)
	queue_redraw()


## Punto de 8 px con halo que late y centro brillante (M5: para ignorarlo, primero hay que notarlo).
const RADIO_PUNTO := 4.0


func _draw() -> void:
	if apagado:
		return
	# Punto de pixel: 3 × 3 rojo con una cruz de 1 px y un latido de 1 px (sin aros suaves: G5 y lección 26).
	var latido := sin(Time.get_ticks_msec() / 1000.0 * 8.0) > 0.0
	var centro := Vector2(-1, -4)
	var largo := 3.0 if latido else 2.0
	draw_rect(Rect2(centro + Vector2(1, -largo), Vector2(1, largo * 2.0 + 3.0)), Color(1, 0.25, 0.25, 0.7))
	draw_rect(Rect2(centro + Vector2(-largo, 1), Vector2(largo * 2.0 + 3.0, 1)), Color(1, 0.25, 0.25, 0.7))
	draw_rect(Rect2(centro, Vector2(3, 3)), Color("ff2a2a"))
	draw_rect(Rect2(centro + Vector2(1, 1), Vector2(1, 1)), Color(1, 0.85, 0.85))
