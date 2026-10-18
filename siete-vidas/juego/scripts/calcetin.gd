class_name Calcetin
extends Node2D
## Calcetín coleccionable: Felipe lo recoge al pasar encima. Arte provisional.

signal recogido

var activo := true


func _init() -> void:
	name = "Calcetin"


func _process(_delta: float) -> void:
	if not activo or not visible:
		return
	var felipe: Felipe = get_tree().get_first_node_in_group("felipe")
	if felipe and felipe.global_position.distance_to(global_position) < 26.0:
		activo = false
		recogido.emit()
		queue_free()


func _draw() -> void:
	if ArteNivel.dibujar(self, "calcetin", 0.0, 0.0):
		return
	var color := Color("5b4d7a")
	draw_rect(Rect2(-3, -16, 6, 11), color)
	draw_rect(Rect2(-3, -7, 10, 5), color)
	draw_rect(Rect2(-3, -16, 6, 3), Color("f3efe8"))
