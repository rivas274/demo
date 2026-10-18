class_name Comida
extends Node2D
## Comida que Felipe se come con el botón de acción (E / Y del mando).
## Todo lo que esté en el grupo "interactuables" y tenga interactuar(felipe) responde a ese botón.
## Arte provisional dibujado con código; (0, 0) es el punto donde la comida toca la superficie.

const GRUPO := "interactuables"

## "plato" (croquetas en el piso de la cocina) o "lata" (atún escondido en un estante).
var tipo: String


func _init(tipo_comida: String) -> void:
	tipo = tipo_comida
	name = "Comida (%s)" % tipo


func _ready() -> void:
	add_to_group(GRUPO)


func interactuar(felipe: Felipe) -> void:
	remove_from_group(GRUPO)
	felipe.comer()
	var desaparecer := create_tween()
	desaparecer.tween_interval(0.45)
	desaparecer.tween_property(self, "scale", Vector2(1.2, 0.0), 0.15)
	desaparecer.tween_callback(queue_free)


func _draw() -> void:
	match tipo:
		"plato":
			draw_rect(Rect2(-16, -8, 32, 8), Color("c8576b"))
			draw_rect(Rect2(-12, -12, 24, 4), Color("8f5a3a"))
			for x in [-9, -3, 3, 8]:
				draw_circle(Vector2(x, -12), 2.5, Color("a8703f"))
		"lata":
			draw_rect(Rect2(-9, -12, 18, 12), Color("aab3b8"))
			draw_rect(Rect2(-9, -9, 18, 5), Color("5f8fa8"))
			draw_rect(Rect2(-6, -8, 4, 3), Color("f2d36b"))
