class_name Chispas
extends Node2D
## Garras afiladas (rascador): chispitas que titilan en las patas de adelante de Felipe mientras dura el filo.
## Parpadean más rápido cuando se está por acabar. Es hija de Felipe (origen en sus pies). Efecto de código.

## Segundos de filo que quedan (Felipe lo actualiza cada cuadro).
var restante := 0.0
var duracion := 1.0
## 1 = mira a la derecha, -1 = a la izquierda.
var lado := 1.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	visible = restante > 0.0
	if visible:
		queue_redraw()


func _draw() -> void:
	if restante <= 0.0:
		return
	# Último segundo y medio: parpadea para avisar que se acaba.
	if restante < 1.5 and int(_t * 10.0) % 2 == 0:
		return
	# Tres destellos de 4 puntas alrededor de la pata delantera y un brillo en las uñas (píxeles enteros).
	var pata := Vector2(lado * 15.0, -4.0)
	for i in 3:
		var fase := _t * 7.0 + i * 2.1
		var tam := roundf(2.0 + 2.0 * absf(sin(fase)))
		var p := (pata + Vector2(lado * (-6.0 + i * 7.0), -6.0 - (i % 2) * 9.0 + sin(fase * 0.5) * 2.0)).round()
		var color := Color(1.0, 1.0, 0.75) if i != 1 else Color(0.7, 0.95, 1.0)
		draw_line(p - Vector2(tam, 0), p + Vector2(tam, 0), color, 1.0)
		draw_line(p - Vector2(0, tam), p + Vector2(0, tam), color, 1.0)
	for k in 3:
		var u := pata + Vector2(lado * (2.0 + k * 2.0), 1.0)
		draw_line(u, u + Vector2(lado * 2.0, -2.0), Color(1, 1, 1, 0.95), 1.0)
