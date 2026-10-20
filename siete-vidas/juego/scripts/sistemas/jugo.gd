class_name Jugo
extends CanvasLayer
## Respuesta épica tipo Balatro y Broforce (pilar 5), sin puntaje: congelar un instante, palabras que saltan
## y rebotan ("¡GRAVEDAD: 1 · VASO: 0!"), sacudida de cámara y destello. Del prototipo de travesuras aprobado.
## No es la presentación de jefe: los jefes usan PresentacionJefe.

## Píxeles de la sacudida más fuerte.
@export var sacudida_maxima := 5.0

var camara: Camera2D
## Lo que las palabras no tapan (Felipe): si una cae encima, sube por sobre su cabeza (M1).
var evitar: Node2D
## Palabras que saltaron (para las pruebas).
var palabras: Array[String] = []

var _congelado := 0.0
var _sacudida := 0.0
var _fuerza_sacudida := 0.0
var _sacudiendo := false
var _flash: ColorRect


func _ready() -> void:
	layer = Capas.CAPA_JUGO
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
	# Llega como clave (PALABRA_...) o texto suelto: se muestra traducido.
	texto = tr(texto)
	palabras.append(texto)
	var etiqueta := Label.new()
	etiqueta.text = texto
	# Letra pixel de títulos (Silkscreen) a su tamaño de diseño: 16 px, o 24 px para las palabras grandes (B1).
	var estilo := &"palabra_grande" if tamano >= 20 else &"palabra"
	etiqueta.add_theme_font_override("font", Estilo.fuente(estilo))
	etiqueta.add_theme_font_size_override("font_size", Estilo.letra(estilo))
	etiqueta.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	etiqueta.add_theme_color_override("font_color", color)
	# Contorno grueso y sombra: se lee sobre cualquier pared o fondo (M1: el celeste se perdía en la pared beige).
	etiqueta.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.07))
	etiqueta.add_theme_constant_override("outline_size", 6)
	etiqueta.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	etiqueta.add_theme_constant_override("shadow_offset_x", 2)
	etiqueta.add_theme_constant_override("shadow_offset_y", 2)
	etiqueta.add_theme_constant_override("shadow_outline_size", 6)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(etiqueta)
	var medida := etiqueta.get_minimum_size()
	etiqueta.size = medida
	etiqueta.pivot_offset = medida / 2.0
	# Dentro de la pantalla y debajo del HUD.
	var x := clampf(posicion.x - medida.x / 2.0, 4.0, 636.0 - medida.x)
	var y := clampf(posicion.y - medida.y / 2.0, 34.0, 352.0 - medida.y)
	# Nunca encima de Felipe: si lo tapa, sube por sobre su cabeza.
	if evitar and is_instance_valid(evitar) and evitar.is_inside_tree() and get_viewport():
		var pies := get_viewport().get_canvas_transform() * evitar.global_position
		var felipe_ocupa := Rect2(pies + Vector2(-38, -74), Vector2(76, 76))
		if Rect2(Vector2(x, y), medida).intersects(felipe_ocupa):
			y = maxf(34.0, felipe_ocupa.position.y - medida.y - 4.0)
	etiqueta.position = Vector2(x, y).round()
	# Salta en escalones enteros (2× un instante y después 1×) y rebota unos px, sin girar: la letra pixel no se
	# deforma (B1 de la revisión de consistencia).
	etiqueta.visible = false
	var abajo := etiqueta.position.y
	var animar := create_tween()
	animar.tween_interval(retraso)
	animar.tween_callback(func() -> void:
		etiqueta.visible = true
		etiqueta.scale = Vector2.ONE * 2.0)
	animar.tween_interval(0.06)
	animar.tween_callback(func() -> void: etiqueta.scale = Vector2.ONE)
	animar.tween_property(etiqueta, "position:y", abajo - 6.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animar.tween_property(etiqueta, "position:y", abajo, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	animar.tween_interval(0.5)
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
