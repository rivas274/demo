class_name Jugo
extends CanvasLayer
## Respuesta épica tipo Balatro y Broforce (pilar 5), sin puntaje: congelar un instante, palabras que saltan
## y rebotan ("¡GRAVEDAD: 1 · VASO: 0!"), sacudida de cámara y destello. Del prototipo de travesuras aprobado.
## No es la presentación de jefe: los jefes usan PresentacionJefe.

## Píxeles de la sacudida más fuerte.
@export var sacudida_maxima := 5.0

var camara: Camera2D
## Palabras que saltaron (para las pruebas).
var palabras: Array[String] = []

var _congelado := 0.0
var _sacudida := 0.0
var _fuerza_sacudida := 0.0
var _sacudiendo := false
var _flash: ColorRect


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.size = Vector2(640, 360)
	add_child(_flash)


## Congela el juego un instante (golpe con peso). Esta capa, el diálogo y la interfaz siguen.
func congelar(segundos: float) -> void:
	_congelado = maxf(_congelado, segundos)
	Engine.time_scale = 0.03


func congelado() -> bool:
	return _congelado > 0.0


func sacudir(segundos: float, fuerza := 1.0) -> void:
	_sacudida = maxf(_sacudida, segundos)
	_fuerza_sacudida = maxf(_fuerza_sacudida, fuerza)


func destello(fuerza := 0.5, color := Color.WHITE) -> void:
	_flash.color = Color(color, maxf(_flash.color.a, fuerza))


## Palabra que salta sobre un punto del mundo (se pasa a la pantalla con la cámara actual).
func palabra_en_mundo(texto: String, posicion: Vector2, color := Color(1.0, 0.9, 0.3), tamano := 18, retraso := 0.0) -> void:
	var en_pantalla := posicion
	var vista := get_viewport()
	if vista:
		en_pantalla = vista.get_canvas_transform() * posicion
	palabra(texto, en_pantalla, color, tamano, retraso)


## Palabra que salta, rebota y se va (posición en pantalla).
func palabra(texto: String, posicion: Vector2, color := Color(1.0, 0.9, 0.3), tamano := 18, retraso := 0.0) -> void:
	palabras.append(texto)
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.08))
	etiqueta.add_theme_constant_override("outline_size", 6)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)
	var medida := etiqueta.get_minimum_size()
	etiqueta.size = medida
	etiqueta.pivot_offset = medida / 2.0
	# Dentro de la pantalla, debajo del HUD y encima del cuadro de diálogo.
	var x := clampf(posicion.x - medida.x / 2.0, 4.0, 636.0 - medida.x)
	var y := clampf(posicion.y - medida.y / 2.0, 34.0, 292.0 - medida.y)
	etiqueta.position = Vector2(x, y).round()
	etiqueta.scale = Vector2.ZERO
	etiqueta.rotation = randf_range(-0.12, 0.12)
	var animar := create_tween()
	animar.tween_interval(retraso)
	animar.tween_property(etiqueta, "scale", Vector2.ONE * 1.35, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animar.tween_property(etiqueta, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	animar.tween_interval(0.55)
	animar.tween_property(etiqueta, "position:y", etiqueta.position.y - 18.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	animar.parallel().tween_property(etiqueta, "modulate:a", 0.0, 0.35)
	animar.tween_callback(etiqueta.queue_free)


func _process(delta: float) -> void:
	# Tiempo real, sin la cámara lenta del congelado.
	var real := delta / maxf(Engine.time_scale, 0.001)
	if _congelado > 0.0:
		_congelado -= real
		if _congelado <= 0.0:
			_congelado = 0.0
			Engine.time_scale = 1.0
	_flash.color.a = maxf(0.0, _flash.color.a - real * 3.5)
	if camara == null or not is_instance_valid(camara):
		return
	if _sacudida > 0.0:
		_sacudida -= real
		_sacudiendo = true
		var fuerza := sacudida_maxima * _fuerza_sacudida * minf(_sacudida * 4.0, 1.0)
		camara.offset = Vector2(roundf(randf_range(-fuerza, fuerza)), roundf(randf_range(-fuerza, fuerza)))
	elif _sacudiendo:
		# Solo se devuelve la cámara una vez, para no pelear con otras sacudidas (PresentacionJefe).
		_sacudiendo = false
		_fuerza_sacudida = 0.0
		camara.offset = Vector2.ZERO


func _exit_tree() -> void:
	if _congelado > 0.0:
		Engine.time_scale = 1.0
