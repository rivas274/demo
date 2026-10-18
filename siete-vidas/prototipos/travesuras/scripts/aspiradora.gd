# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Aspiradora
extends Node2D
## Aspiradora robot (48 x 18 px, más grande que una real: escala de gato), dormida en su base bajo la mesa.
## Si Felipe la intimida cerca, sale huyendo en pánico, choca con todo y escupe el calcetín que se
## había tragado. Después vuelve a su base. La posición es la base del objeto.

signal escupio(punto: Vector2)

enum Estado { DORMIDA, HUYENDO, ESCUPIENDO, VOLVIENDO }

@export var velocidad_huida := 230.0
@export var duracion_huida := 1.6
@export var velocidad_vuelta := 50.0
## Distancia horizontal a la que la alcanza el bufido.
@export var alcance_intimidar := 100.0

var estado := Estado.DORMIDA
var base_x := 0.0
var tiene_calcetin := true
var _tiempo := 0.0
var _lado := 1.0


func _ready() -> void:
	base_x = position.x


func asustar(desde_x: float) -> bool:
	if estado != Estado.DORMIDA and estado != Estado.VOLVIENDO:
		return false
	_lado = signf(position.x - desde_x)
	if _lado == 0.0:
		_lado = 1.0
	estado = Estado.HUYENDO
	_tiempo = 0.0
	return true


func _physics_process(delta: float) -> void:
	_tiempo += delta
	match estado:
		Estado.HUYENDO:
			# Zigzag de pánico: cambia de lado al chocar con las paredes o con las patas del sofá.
			position.x += _lado * velocidad_huida * delta
			if position.x < 232.0 or position.x > 610.0:
				position.x = clampf(position.x, 232.0, 610.0)
				_lado = -_lado
			if _tiempo > duracion_huida:
				estado = Estado.ESCUPIENDO
				_tiempo = 0.0
		Estado.ESCUPIENDO:
			if _tiempo > 0.45:
				if tiene_calcetin:
					tiene_calcetin = false
					escupio.emit(global_position + Vector2(0, -14))
				estado = Estado.VOLVIENDO
				_tiempo = 0.0
		Estado.VOLVIENDO:
			position.x = move_toward(position.x, base_x, velocidad_vuelta * delta)
			if absf(position.x - base_x) < 1.0:
				estado = Estado.DORMIDA
	queue_redraw()


func _draw() -> void:
	var temblor := 0.0
	if estado == Estado.ESCUPIENDO:
		temblor = roundf(sin(_tiempo * 60.0) * 1.5)
	elif estado == Estado.HUYENDO:
		temblor = roundf(sin(_tiempo * 40.0))
	var o := Vector2(temblor, 0)
	# Base de carga (solo cuando está en casa).
	if absf(position.x - base_x) < 2.0:
		draw_rect(Rect2(Vector2(-30, -4), Vector2(60, 4)), Color(0.3, 0.3, 0.33))
	# Cuerpo: disco visto de lado.
	draw_rect(Rect2(o + Vector2(-24, -16), Vector2(48, 14)), Color(0.22, 0.22, 0.26))
	draw_rect(Rect2(o + Vector2(-22, -18), Vector2(44, 4)), Color(0.32, 0.32, 0.38))
	draw_rect(Rect2(o + Vector2(-24, -4), Vector2(48, 2)), Color(0.12, 0.12, 0.14))
	# Ruedas.
	draw_circle(o + Vector2(-14, -2), 3.0, Color(0.1, 0.1, 0.1))
	draw_circle(o + Vector2(14, -2), 3.0, Color(0.1, 0.1, 0.1))
	# Luz: verde dormida, roja en pánico. "Ojos" que miran a Felipe.
	var asustada := estado in [Estado.HUYENDO, Estado.ESCUPIENDO]
	var luz := Color(1.0, 0.25, 0.2) if asustada else Color(0.3, 0.9, 0.4, 0.5 + 0.5 * absf(sin(_tiempo * 1.5)))
	draw_rect(Rect2(o + Vector2(-5, -15), Vector2(10, 4)), luz)
	if asustada:
		# Gotas de sudor y signos de pánico.
		draw_string(ThemeDB.fallback_font, o + Vector2(-6, -24), "!!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.3, 0.25))
		draw_circle(o + Vector2(-_lado * 26, -20 + fmod(_tiempo * 30.0, 8.0)), 2.0, Color(0.6, 0.85, 1.0))
	elif estado == Estado.DORMIDA:
		draw_string(ThemeDB.fallback_font, Vector2(16, -22 - fmod(_tiempo * 6.0, 6.0)), "z", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.6))
