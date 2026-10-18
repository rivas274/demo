# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Dialogo
extends CanvasLayer
## Cuadro de diálogo abajo con retrato: Felipe (sus 9 caras) o Valeria (retrato provisional por código).
## Frases de 1 o 2 líneas, se escriben letra a letra, se cierran solas y se pueden saltar (Enter/Tab o LB).

signal dicho(quien: String, texto: String)

const RETRATOS := preload("res://assets/felipe/felipe-retratos.png")
const LADO_RETRATO := 200.0 / 3.0

## Letras por segundo.
@export var velocidad_texto := 55.0
## Segundos que queda la frase completa antes de cerrarse sola (más un poco por letra).
@export var espera_base := 1.3
@export var espera_por_letra := 0.035

var hablando := ""
var texto_actual := ""
var _cola: Array = []
var _caja: Panel
var _nombre: Label
var _texto: Label
var _retrato_felipe: TextureRect
var _retrato_valeria: RetratoValeria
var _visibles := 0.0
var _espera := 0.0
var _ultimo_sonido := 0
var sonidos: Sonidos


func _ready() -> void:
	layer = 4
	_caja = Panel.new()
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.13, 0.09, 0.12, 0.94)
	estilo.border_color = Color(0.95, 0.85, 0.6)
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(3)
	_caja.add_theme_stylebox_override("panel", estilo)
	_caja.position = Vector2(8, 302)
	_caja.size = Vector2(624, 54)
	add_child(_caja)
	var marco := ColorRect.new()
	marco.color = Color(0.85, 0.75, 0.6)
	marco.position = Vector2(4, 3)
	marco.size = Vector2(48, 48)
	_caja.add_child(marco)
	_retrato_felipe = TextureRect.new()
	_retrato_felipe.position = Vector2(5, 4)
	_retrato_felipe.size = Vector2(46, 46)
	_retrato_felipe.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_retrato_felipe.stretch_mode = TextureRect.STRETCH_SCALE
	_caja.add_child(_retrato_felipe)
	_retrato_valeria = RetratoValeria.new()
	_retrato_valeria.position = Vector2(5, 4)
	_retrato_valeria.size = Vector2(46, 46)
	_caja.add_child(_retrato_valeria)
	_nombre = Label.new()
	_nombre.position = Vector2(60, 1)
	_nombre.add_theme_font_size_override("font_size", 11)
	_nombre.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4))
	_caja.add_child(_nombre)
	_texto = Label.new()
	_texto.position = Vector2(60, 15)
	_texto.size = Vector2(556, 36)
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_texto.add_theme_font_size_override("font_size", 14)
	_texto.add_theme_color_override("font_color", Color(1, 0.97, 0.92))
	_texto.add_theme_constant_override("line_spacing", -2)
	_caja.add_child(_texto)
	var aviso := Label.new()
	aviso.text = "Enter"
	aviso.position = Vector2(588, 38)
	aviso.add_theme_font_size_override("font_size", 8)
	aviso.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	_caja.add_child(aviso)
	_caja.visible = false


## Pone una frase. Felipe interrumpe su propia frase; Valeria espera en cola si Felipe está hablando, y al revés.
func decir(quien: String, texto: String, retrato: int, urgente := false) -> void:
	if urgente or not _caja.visible or hablando == quien:
		_mostrar(quien, texto, retrato)
	else:
		_cola.append([quien, texto, retrato])
		if _cola.size() > 2:
			_cola.pop_front()


func ocupado() -> bool:
	return _caja.visible


func _mostrar(quien: String, texto: String, retrato: int) -> void:
	hablando = quien
	texto_actual = texto
	_caja.visible = true
	_texto.text = texto
	_texto.visible_characters = 0
	_visibles = 0.0
	_ultimo_sonido = 0
	_espera = espera_base + espera_por_letra * texto.length()
	var es_felipe := quien == "felipe"
	_nombre.text = "FELIPE" if es_felipe else "VALERIA"
	_retrato_felipe.visible = es_felipe
	_retrato_valeria.visible = not es_felipe
	if es_felipe:
		var cara := AtlasTexture.new()
		cara.atlas = RETRATOS
		cara.region = Rect2((retrato % 3) * LADO_RETRATO, (retrato / 3) * LADO_RETRATO, LADO_RETRATO, LADO_RETRATO)
		_retrato_felipe.texture = cara
	else:
		_retrato_valeria.animo = retrato
		_retrato_valeria.queue_redraw()
	# Pequeño golpe al aparecer.
	_caja.pivot_offset = Vector2(30, 27)
	_caja.scale = Vector2(1.0, 0.7)
	create_tween().tween_property(_caja, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dicho.emit(quien, texto)


func saltar() -> void:
	if not _caja.visible:
		return
	if _texto.visible_characters < texto_actual.length():
		_texto.visible_characters = -1
		_visibles = texto_actual.length()
	else:
		_cerrar()


func _cerrar() -> void:
	_caja.visible = false
	hablando = ""
	if not _cola.is_empty():
		var siguiente: Array = _cola.pop_front()
		_mostrar(siguiente[0], siguiente[1], siguiente[2])


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("saltar_dialogo"):
		saltar()
	if not _caja.visible:
		return
	if _visibles < texto_actual.length():
		_visibles += velocidad_texto * delta
		var nuevas := mini(int(_visibles), texto_actual.length())
		if nuevas != _texto.visible_characters:
			_texto.visible_characters = nuevas
			if sonidos and nuevas - _ultimo_sonido >= 3:
				_ultimo_sonido = nuevas
				sonidos.sonar("texto", 0.8 if hablando == "felipe" else 1.3)
		if nuevas >= texto_actual.length():
			_ultimo_sonido = 0
		return
	_espera -= delta
	if _espera <= 0.0:
		_cerrar()
