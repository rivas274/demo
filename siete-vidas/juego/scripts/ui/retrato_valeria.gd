class_name RetratoValeria
extends Control
## Retrato provisional dibujado por código (46 x 46) para cuando falte la hoja de retratos de Valeria y A.S.P.I.
## (assets/personajes/retratos-valeria-aspi.png). Valeria: 0 neutra, 1 enojada, 2 derretida, 3 grabando.
## A.S.P.I.: 0 normal (luz verde), 1 alerta (luz roja).

var personaje := "valeria"
var animo := 0


func _draw() -> void:
	if personaje == "aspi":
		draw_rect(Rect2(0, 0, 46, 46), Color(0.85, 0.8, 0.7))
		draw_rect(Rect2(4, 22, 38, 14), Color(0.2, 0.2, 0.22))
		draw_rect(Rect2(6, 18, 34, 6), Color(0.32, 0.32, 0.35))
		draw_rect(Rect2(28, 28, 6, 3), Color(0.9, 0.2, 0.2) if animo == 1 else Color(0.3, 0.9, 0.4))
		return
	var piel := Color("d9a27c")
	var pelo := Color("4a2e22")
	draw_rect(Rect2(0, 0, 46, 46), Color(0.85, 0.8, 0.7))
	# Moño alto, cara y sudadera verde azulado (ficha visual de Valeria).
	draw_rect(Rect2(16, 1, 14, 8), pelo)
	draw_rect(Rect2(9, 7, 28, 30), pelo)
	draw_rect(Rect2(12, 12, 22, 24), piel)
	draw_rect(Rect2(8, 38, 30, 8), Color("3e7c7a"))
	draw_rect(Rect2(19, 34, 8, 5), piel)
	var negro := Color(0.15, 0.1, 0.1)
	match animo:
		1:
			draw_line(Vector2(14, 18), Vector2(20, 21), negro, 2.0)
			draw_line(Vector2(32, 18), Vector2(26, 21), negro, 2.0)
			draw_rect(Rect2(16, 22, 3, 3), negro)
			draw_rect(Rect2(27, 22, 3, 3), negro)
			draw_rect(Rect2(18, 29, 10, 4), Color(0.5, 0.12, 0.12))
		2:
			draw_arc(Vector2(18, 24), 2.5, PI, TAU, 6, negro, 2.0)
			draw_arc(Vector2(28, 24), 2.5, PI, TAU, 6, negro, 2.0)
			draw_arc(Vector2(23, 29), 4.0, 0.0, PI, 8, Color(0.6, 0.2, 0.2), 2.0)
			draw_rect(Rect2(13, 27, 4, 2), Color(1, 0.55, 0.6))
			draw_rect(Rect2(29, 27, 4, 2), Color(1, 0.55, 0.6))
		3:
			draw_rect(Rect2(16, 22, 3, 3), negro)
			draw_rect(Rect2(27, 22, 3, 3), negro)
			draw_arc(Vector2(23, 29), 4.0, 0.0, PI, 8, Color(0.6, 0.2, 0.2), 2.0)
			# Celular amarillo mostaza en alto.
			draw_rect(Rect2(33, 8, 9, 14), Color("d9a441"))
		_:
			draw_rect(Rect2(16, 22, 3, 3), negro)
			draw_rect(Rect2(27, 22, 3, 3), negro)
			draw_line(Vector2(19, 30), Vector2(27, 30), Color(0.55, 0.2, 0.2), 2.0)
