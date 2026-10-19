# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-19
class_name Chispas
extends Node2D
## Garras afiladas: chispitas que titilan en las patas de adelante de Felipe mientras dura el filo.
## Parpadean más rápido cuando se está por acabar. Hijo de Felipe (posición en sus pies).

var restante := 0.0
var duracion := 1.0
var lado := 1.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	visible = restante > 0.0
	queue_redraw()


func _draw() -> void:
	if restante <= 0.0:
		return
	var final := restante < 1.5
	if final and int(_t * 10.0) % 2 == 0:
		return
	# Tres destellos de 4 puntas alrededor de la pata delantera, y un brillo en las uñas.
	var pata := Vector2(lado * 15.0, -4.0)
	for i in 3:
		var fase := _t * 7.0 + i * 2.1
		var tam := 2.0 + 2.0 * absf(sin(fase))
		var p := pata + Vector2(lado * (-6.0 + i * 7.0), -6.0 - (i % 2) * 9.0 + sin(fase * 0.5) * 2.0)
		var c := Color(1.0, 1.0, 0.75) if i != 1 else Color(0.7, 0.95, 1.0)
		draw_line(p - Vector2(tam, 0), p + Vector2(tam, 0), c, 1.0)
		draw_line(p - Vector2(0, tam), p + Vector2(0, tam), c, 1.0)
	for k in 3:
		var u := pata + Vector2(lado * (2.0 + k * 2.0), 1.0)
		draw_line(u, u + Vector2(lado * 2.0, -2.0), Color(1, 1, 1, 0.95), 1.0)
