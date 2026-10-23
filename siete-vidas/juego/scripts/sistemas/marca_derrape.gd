class_name MarcaDerrape
extends Node2D
## Marca breve que deja un derrape en el piso: una raya de 1 px del largo del derrape y otra más corta debajo (las
## patas de atrás), que se apagan y se borran.
## La crea RecetaJugo.marca().

var _largo := 0.0
var _direccion := 1.0
var _color: Color


func _init(datos: DatosJugo, direccion: float) -> void:
	name = "Marca de derrape"
	# Va en el piso como los arañazos (Capas.MARCAS).
	Profundidad.poner(self, Capas.Rol.MARCA)
	_largo = roundf(datos.derrape)
	_direccion = direccion
	_color = datos.color_marca
	var t := create_tween()
	t.tween_interval(datos.marca_derrape * 0.5)
	t.tween_property(self, "modulate:a", 0.0, datos.marca_derrape * 0.5)
	t.tween_callback(queue_free)


## Donde patinan las patas de atrás: detrás del centro del cuerpo. Así la marca queda a la vista detrás de Felipe
## cuando termina de patinar.
const PATAS_ATRAS := 14.0


func _draw() -> void:
	var x := -PATAS_ATRAS if _direccion > 0.0 else PATAS_ATRAS - _largo
	draw_rect(Rect2(x, -1.0, _largo, 1.0), _color)
	var corto := roundf(_largo * 0.6)
	draw_rect(Rect2(x + (_largo - corto if _direccion > 0.0 else 0.0), 0.0, corto, 1.0), _color)
