class_name CajaCarton
extends StaticBody2D
## Caja de cartón (40 cm a escala de gato): se rompe de un zarpazo y suelta un snack. Escena con sus piezas
## (escenas/entidades/caja_carton.tscn): Vida (1 golpe), RecibeGolpes (el zarpazo), SueltaRecompensa (el snack) y
## SombraContacto. Este nodo solo es el cuerpo sólido y el dibujo; al romperse deja de ser sólida y queda en trozos.

signal rota

const LADO := 60.0
const ESCENA := "res://escenas/entidades/caja_carton.tscn"

var roto := false
var vida: Vida


## Fábrica: la caja con sus piezas, lista para poner en el nivel.
static func crear() -> CajaCarton:
	return load(ESCENA).instantiate()


## Tamaño de la colisión: el del arte (la colisión calza con el dibujo, hallazgo B4).
func tamano() -> Vector2:
	var t := ArteNivel.textura("caja")
	return t.get_size() if t else Vector2(LADO, LADO)


func _ready() -> void:
	Profundidad.poner(self, Capas.Rol.OBJETO_JUEGO)
	vida = Componentes.de(self, Vida) as Vida
	vida.murio.connect(_al_romperse)
	add_to_group(Componentes.ENEMIGOS)
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = tamano()
	forma.shape = caja
	forma.position = Vector2(0, -caja.size.y / 2.0)
	add_child(forma)


func _al_romperse() -> void:
	roto = true
	remove_from_group(Componentes.ENEMIGOS)
	for hijo in get_children():
		if hijo is CollisionShape2D:
			hijo.set_deferred("disabled", true)
	rota.emit()
	queue_redraw()


func _draw() -> void:
	var carton := Color("c49a6c")
	if roto and ArteNivel.dibujar(self, "caja_rota", 0.0, 0.0):
		return
	if roto:
		for trozo: Rect2 in [Rect2(-26, -8, 18, 8), Rect2(-4, -6, 14, 6), Rect2(12, -9, 16, 9)]:
			draw_rect(trozo, carton)
		return
	if ArteNivel.dibujar(self, "caja", 0.0, 0.0):
		return
	draw_rect(Rect2(-LADO / 2.0, -LADO, LADO, LADO), carton)
	draw_rect(Rect2(-LADO / 2.0, -LADO, LADO, 6), carton.darkened(0.15))
	draw_rect(Rect2(-3, -LADO, 6, LADO), Color("d9c7a0"))
