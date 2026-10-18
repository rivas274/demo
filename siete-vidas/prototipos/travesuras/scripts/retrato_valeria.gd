# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name RetratoValeria
extends Control
## Retrato provisional de Valeria dibujado por código (46 x 46). Ánimo: 0 enojada, 1 derretida, 2 cansada.

var animo := 0


func _draw() -> void:
	var piel := Color(0.93, 0.76, 0.62)
	var pelo := Color(0.28, 0.16, 0.1)
	draw_rect(Rect2(0, 0, 46, 46), Color(0.55, 0.75, 0.8) if animo == 1 else (Color(0.85, 0.45, 0.4) if animo == 0 else Color(0.6, 0.6, 0.65)))
	draw_rect(Rect2(6, 6, 34, 40), pelo)
	draw_rect(Rect2(10, 12, 26, 30), piel)
	draw_rect(Rect2(8, 4, 30, 10), pelo)
	draw_rect(Rect2(17, 40, 12, 6), piel)
	var negro := Color(0.15, 0.1, 0.1)
	match animo:
		0:
			draw_line(Vector2(13, 19), Vector2(20, 22), negro, 2.0)
			draw_line(Vector2(33, 19), Vector2(26, 22), negro, 2.0)
			draw_rect(Rect2(15, 24, 4, 4), negro)
			draw_rect(Rect2(27, 24, 4, 4), negro)
			draw_rect(Rect2(17, 33, 12, 5), Color(0.5, 0.12, 0.12))
		1:
			draw_arc(Vector2(17, 26), 3.0, PI, TAU, 6, negro, 2.0)
			draw_arc(Vector2(29, 26), 3.0, PI, TAU, 6, negro, 2.0)
			draw_arc(Vector2(23, 32), 5.0, 0.0, PI, 8, Color(0.6, 0.2, 0.2), 2.0)
			draw_rect(Rect2(12, 29, 4, 2), Color(1, 0.55, 0.6))
			draw_rect(Rect2(30, 29, 4, 2), Color(1, 0.55, 0.6))
		_:
			draw_line(Vector2(14, 25), Vector2(20, 25), negro, 2.0)
			draw_line(Vector2(26, 25), Vector2(32, 25), negro, 2.0)
			draw_line(Vector2(19, 35), Vector2(27, 35), Color(0.55, 0.2, 0.2), 2.0)
