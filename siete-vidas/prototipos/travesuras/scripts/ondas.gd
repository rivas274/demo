# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Ondas
extends Node2D
## Efecto del maullido: arcos que salen de la boca hacia donde mira y notas que suben. Se borra solo.

@export var duracion := 1.0
var lado := 1.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= duracion:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var color := Color(1.0, 0.95, 0.7)
	for i in 3:
		var u := _t / duracion * 1.4 - i * 0.18
		if u <= 0.0 or u >= 1.0:
			continue
		var radio := 6.0 + u * 44.0
		var desde := -0.8 if lado > 0 else PI - 0.8
		draw_arc(Vector2.ZERO, radio, desde, desde + 1.6, 12, Color(0.35, 0.2, 0.1, (1.0 - u) * 0.8), 5.0)
		draw_arc(Vector2.ZERO, radio, desde, desde + 1.6, 12, Color(color, 1.0 - u), 3.0)
	for i in 2:
		var u := clampf(_t / duracion * 1.2 - i * 0.25, 0.0, 1.0)
		if u <= 0.0 or u >= 1.0:
			continue
		var p := Vector2(lado * (14 + i * 12 + u * 16), -6 - u * 34 + sin(u * 12.0 + i) * 3.0)
		var c := Color(1.0, 0.85, 0.35, 1.0 - u)
		var borde := Color(0.35, 0.2, 0.1, c.a)
		draw_circle(p, 5.0, borde)
		draw_circle(p, 4.0, c)
		draw_line(p + Vector2(3.5, 0), p + Vector2(3.5, -14), c, 2.0)
		draw_line(p + Vector2(3.5, -14), p + Vector2(9, -10), c, 2.0)
