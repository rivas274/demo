class_name Enchufe
extends Node2D
## Enchufe de la base de carga de A.S.P.I. Con el botón de acción Felipe tira del cable, pero solo funciona
## si A.S.P.I. está ocupada (limpiando o aturdida): la pelea lo decide con `permiso`.

signal desenchufado(enchufe: Enchufe)
signal rechazado(enchufe: Enchufe)

var tirado := false
## Devuelve si ahora se puede desenchufar (lo pone la pelea).
var permiso: Callable = func() -> bool: return true


func _init(posicion: Vector2) -> void:
	position = posicion
	name = "Enchufe"
	# En la pared: detrás de los muebles y de la imaginación de Felipe.
	z_index = -15


func _ready() -> void:
	add_to_group(Comida.GRUPO)


func _process(_delta: float) -> void:
	if not tirado:
		queue_redraw()


func interactuar(felipe: Felipe) -> void:
	if tirado:
		return
	felipe.dar_manotazo()
	if not permiso.call():
		rechazado.emit(self)
		return
	tirado = true
	remove_from_group(Comida.GRUPO)
	desenchufado.emit(self)
	queue_redraw()


func _draw() -> void:
	# Toma en la pared (un poco arriba del punto donde se para Felipe) y el cable que baja.
	var toma := Vector2(0, -34)
	draw_rect(Rect2(toma + Vector2(-7, -9), Vector2(14, 18)), Color("f2ece0"))
	draw_rect(Rect2(toma + Vector2(-7, -9), Vector2(14, 18)), Color("8a7f72"), false, 1.0)
	if tirado:
		draw_line(toma + Vector2(10, 12), toma + Vector2(26, 30), Color("2b2b2b"), 2.0)
		draw_rect(Rect2(toma + Vector2(22, 26), Vector2(8, 6)), Color("2b2b2b"))
		return
	draw_rect(Rect2(toma + Vector2(-4, -3), Vector2(8, 6)), Color("2b2b2b"))
	draw_line(toma + Vector2(0, 3), Vector2(0, 0), Color("2b2b2b"), 2.0)
	# Chispa que llama la atención.
	if int(Time.get_ticks_msec() / 400) % 2 == 0:
		draw_circle(toma + Vector2(9, -8), 2.0, Color("ffe066"))
