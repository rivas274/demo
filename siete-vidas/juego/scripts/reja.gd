class_name Reja
extends StaticBody2D
## Dos rejas para bebés apiladas al pie de la escalera (1,5 m): Felipe no las salta desde el piso. Las cruza
## trepando el librero y, desde el lado de la escalera, las abre con el botón de acción (atajo de vuelta).

signal abierta

var rect: Rect2
var abierta_ya := false


func _init(rectangulo: Rect2) -> void:
	rect = rectangulo
	name = "Reja"
	# El punto de interacción está al pie, del lado de la escalera.
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
	# Solo se abre desde la escalera (desde el recibidor, Felipe empuja contra la reja).
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
	var centro := rect.get_center().x - position.x
	if abierta_ya:
		# Plegadas contra la pared.
		ArteNivel.dibujar(self, "reja", centro - 40.0, 0.0)
		return
	ArteNivel.dibujar(self, "reja", centro, 0.0)
	ArteNivel.dibujar(self, "reja", centro, -rect.size.y / 2.0)
