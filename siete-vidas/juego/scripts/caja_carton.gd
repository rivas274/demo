class_name CajaCarton
extends StaticBody2D
## Caja de cartón (40 cm, 48 px): se rompe de un zarpazo y puede guardar algo adentro (un calcetín).
## Está en el grupo "enemigos" solo para recibir zarpazos. Arte provisional.

signal rota

const LADO := 48.0

var roto := false


func _init() -> void:
	name = "Caja de carton"


func _ready() -> void:
	add_to_group("enemigos")
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(LADO, LADO)
	forma.shape = caja
	forma.position = Vector2(0, -LADO / 2.0)
	add_child(forma)


func recibir_zarpazo(_felipe: Felipe) -> void:
	if roto:
		return
	roto = true
	remove_from_group("enemigos")
	for hijo in get_children():
		if hijo is CollisionShape2D:
			hijo.set_deferred("disabled", true)
	rota.emit()
	queue_redraw()


func _draw() -> void:
	var carton := Color("c49a6c")
	if roto:
		for trozo: Rect2 in [Rect2(-26, -8, 18, 8), Rect2(-4, -6, 14, 6), Rect2(12, -9, 16, 9)]:
			draw_rect(trozo, carton)
		return
	draw_rect(Rect2(-LADO / 2.0, -LADO, LADO, LADO), carton)
	draw_rect(Rect2(-LADO / 2.0, -LADO, LADO, 6), carton.darkened(0.15))
	draw_rect(Rect2(-3, -LADO, 6, LADO), Color("d9c7a0"))
