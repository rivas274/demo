# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Jugo
extends CanvasLayer
## Respuesta épica tipo Balatro/Broforce: congelar un instante, palabras que saltan y rebotan,
## sacudida de cámara y destello. (v2: sin contador de CAOS ni combo: el motivo ahora es la Agenda.)

## Píxeles de la sacudida más fuerte.
@export var sacudida_maxima := 6.0

var camara: Camera2D

var _tiempo := 0.0
var _congelado := 0.0
var _sacudida := 0.0
var _fuerza_sacudida := 0.0
var _flash: ColorRect


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.size = Vector2(640, 360)
	add_child(_flash)


func _etiqueta(texto: String, tamano: int, color: Color) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.08))
	etiqueta.add_theme_constant_override("outline_size", 5)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta


## Congela el juego un instante (hitstop). Los efectos de esta capa siguen.
func congelar(segundos: float) -> void:
	_congelado = maxf(_congelado, segundos)
	Engine.time_scale = 0.03


func sacudir(segundos: float, fuerza := 1.0) -> void:
	_sacudida = maxf(_sacudida, segundos)
	_fuerza_sacudida = maxf(_fuerza_sacudida, fuerza)


func destello(fuerza := 0.5, color := Color.WHITE) -> void:
	_flash.color = Color(color, maxf(_flash.color.a, fuerza))


## Palabra que salta, rebota y se va (posición en pantalla = mundo, la cámara está fija).
func palabra(texto: String, posicion: Vector2, color := Color(1.0, 0.9, 0.3), tamano := 22, retraso := 0.0) -> void:
	var etiqueta := _etiqueta(texto, tamano, color)
	etiqueta.add_theme_constant_override("outline_size", 6)
	add_child(etiqueta)
	var medida := etiqueta.get_minimum_size()
	etiqueta.size = medida
	etiqueta.pivot_offset = medida / 2.0
	var x := clampf(posicion.x - medida.x / 2.0, 4.0, 636.0 - medida.x)
	var y := clampf(posicion.y - medida.y / 2.0, 34.0, 290.0 - medida.y)
	etiqueta.position = Vector2(x, y)
	etiqueta.scale = Vector2.ZERO
	etiqueta.rotation = randf_range(-0.12, 0.12)
	var animar := create_tween()
	animar.tween_interval(retraso)
	animar.tween_property(etiqueta, "scale", Vector2.ONE * 1.35, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animar.tween_property(etiqueta, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	animar.tween_interval(0.55)
	animar.tween_property(etiqueta, "position:y", y - 18.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	animar.parallel().tween_property(etiqueta, "modulate:a", 0.0, 0.35)
	animar.tween_callback(etiqueta.queue_free)


func _process(delta: float) -> void:
	# Tiempo real del juego, sin la cámara lenta del congelado.
	var real := delta / maxf(Engine.time_scale, 0.001)
	_tiempo += real
	if _congelado > 0.0:
		_congelado -= real
		if _congelado <= 0.0:
			Engine.time_scale = 1.0
	_flash.color.a = maxf(0.0, _flash.color.a - real * 3.5)
	if camara:
		if _sacudida > 0.0:
			_sacudida -= real
			var fuerza := sacudida_maxima * _fuerza_sacudida * minf(_sacudida * 4.0, 1.0)
			camara.offset = Vector2(roundf(randf_range(-fuerza, fuerza)), roundf(randf_range(-fuerza, fuerza)))
		else:
			_fuerza_sacudida = 0.0
			camara.offset = Vector2.ZERO
