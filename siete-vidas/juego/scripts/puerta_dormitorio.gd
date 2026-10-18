class_name PuertaDormitorio
extends StaticBody2D
## Puerta del dormitorio, arriba de la escalera. Cerrada al empezar: Felipe sube por la cocina y la abre
## desde dentro con el botón de acción. Queda un atajo por la escalera hasta la caja de arena.

signal abierta

var rect: Rect2
var abierta_ya := false


func _init(rectangulo: Rect2) -> void:
	rect = rectangulo
	name = "Puerta del dormitorio"
	# El punto de interacción está al pie de la puerta, del lado del dormitorio.
	position = Vector2(rect.end.x, rect.end.y)


func _ready() -> void:
	add_to_group(Comida.GRUPO)
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = rect.size
	forma.shape = caja
	forma.position = rect.get_center() - position
	add_child(forma)


func interactuar(felipe: Felipe) -> void:
	# Solo se abre desde el dormitorio (desde la escalera, Felipe empuja contra la puerta).
	if abierta_ya or felipe.global_position.x < rect.end.x:
		return
	abierta_ya = true
	remove_from_group(Comida.GRUPO)
	felipe.dar_manotazo()
	for hijo in get_children():
		if hijo is CollisionShape2D:
			hijo.set_deferred("disabled", true)
	abierta.emit()
	queue_redraw()


func _draw() -> void:
	var local := Rect2(rect.position - position, rect.size)
	draw_rect(local.grow(3), Color("6e3a26"), false, 3.0)
	if abierta_ya:
		draw_rect(Rect2(local.position.x - 40, local.position.y, 40, local.size.y), Color("b0613f").darkened(0.2))
		return
	draw_rect(local, Color("b0613f"))
	draw_circle(local.position + Vector2(local.size.x - 4, local.size.y * 0.55), 2.0, Color("f2d36b"))
