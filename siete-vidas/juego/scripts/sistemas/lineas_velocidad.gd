class_name LineasVelocidad
extends Node2D
## Líneas de velocidad de pixel (1 px de alto, sin suavizar) detrás de quien corre; se apagan y se borran solas.
## Las crea RecetaJugo.correr().

var _lineas: Array[Rect2] = []
var _color: Color


func _init(datos: DatosJugo, direccion: float, alto: float) -> void:
	name = "Lineas de velocidad"
	z_index = Capas.TRAS_FELIPE
	_color = datos.lineas_color
	for i in datos.lineas_cantidad:
		var largo := roundf(randf_range(datos.lineas_largo.x, datos.lineas_largo.y))
		var y := roundf(-alto * randf_range(0.15, 0.85))
		# Detrás del cuerpo: empiezan a 14 px del centro, hacia el lado contrario de la carrera.
		var x := -direccion * (14.0 + randf_range(0.0, 8.0))
		_lineas.append(Rect2(x if direccion < 0.0 else x - largo, y, largo, 1.0))
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, datos.lineas_vida)
	t.tween_callback(queue_free)


func _draw() -> void:
	for linea in _lineas:
		draw_rect(linea, _color)
