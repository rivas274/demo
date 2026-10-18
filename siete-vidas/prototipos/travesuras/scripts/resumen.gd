# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Resumen
extends CanvasLayer
## Pantalla de fin del día, tipo Balatro: las filas aparecen una a una y sus números suben contando
## con un golpe y un "blip"; al final, una frase de Felipe con su retrato. Enter o Tab: seguir jugando.

signal cerrado

const RETRATOS := preload("res://assets/felipe/felipe-retratos.png")
const LADO_RETRATO := 200.0 / 3.0

@export var pausa_entre_filas := 0.55
@export var duracion_conteo := 0.5

## [texto, valor, total (o -1)]
var filas: Array = []
var frase: Array = ["", 0]
var terminado := false
var _mostradas := 0
var _valores: Array[float] = []
var _golpes: Array[float] = []
var _tiempo := 0.0
var _lienzo: Control
var _sonidos: Sonidos
var _frase_visible := 0.0


func mostrar(datos: Array, frase_final: Array, sonidos: Sonidos) -> void:
	filas = datos
	frase = frase_final
	_sonidos = sonidos
	for f in filas:
		_valores.append(0.0)
		_golpes.append(0.0)


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_lienzo = Control.new()
	_lienzo.size = Vector2(640, 360)
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lienzo.draw.connect(_dibujar)
	add_child(_lienzo)
	get_tree().paused = true


func _process(delta: float) -> void:
	# Tiempo real: el congelado no debe frenar el conteo.
	delta = delta / maxf(Engine.time_scale, 0.001)
	_tiempo += delta
	var objetivo := mini(int(_tiempo / pausa_entre_filas), filas.size())
	if objetivo > _mostradas:
		_mostradas = objetivo
		_golpes[_mostradas - 1] = 1.0
		if _sonidos:
			_sonidos.sonar("golpe", 1.2)
	for i in _mostradas:
		var meta := float(filas[i][1])
		if _valores[i] < meta:
			var antes := int(_valores[i])
			_valores[i] = minf(meta, _valores[i] + maxf(meta, 1.0) / duracion_conteo * delta)
			if int(_valores[i]) != antes:
				_golpes[i] = 1.0
				if _sonidos:
					_sonidos.sonar("salto", 1.0 + 0.12 * int(_valores[i]))
		_golpes[i] = maxf(0.0, _golpes[i] - delta * 4.0)
	var fin_filas := filas.size() * pausa_entre_filas + duracion_conteo + 0.3
	if _tiempo > fin_filas:
		if _frase_visible == 0.0 and _sonidos:
			_sonidos.sonar("perdon")
		_frase_visible = minf(1.0, _frase_visible + delta * 3.0)
		terminado = true
	_lienzo.queue_redraw()
	if terminado and (Input.is_action_just_pressed("saltar_dialogo") or Input.is_action_just_pressed("agenda")):
		get_tree().paused = false
		cerrado.emit()
		queue_free()


func _dibujar() -> void:
	var c := _lienzo
	var fuente := ThemeDB.fallback_font
	var entrada := minf(_tiempo * 4.0, 1.0)
	c.draw_rect(Rect2(0, 0, 640, 360), Color(0.03, 0.06, 0.05, 0.82 * entrada))
	# Paño verde con borde dorado.
	var panel := Rect2(120, 18, 400, 326)
	c.draw_rect(panel.grow(3), Color(0.85, 0.65, 0.25))
	c.draw_rect(panel, Color(0.12, 0.3, 0.24))
	_texto(c, fuente, Vector2(320, 48), "FIN DEL DÍA", 24, Color(1.0, 0.85, 0.3), true)
	_texto(c, fuente, Vector2(320, 64), "Informe de Su Majestad", 11, Color(0.8, 0.95, 0.85), true)
	var y := 82.0
	for i in _mostradas:
		var fila: Array = filas[i]
		var g := _golpes[i]
		var caja := Rect2(138, y, 364, 28)
		c.draw_rect(caja, Color(0.07, 0.18, 0.14))
		c.draw_rect(Rect2(caja.position, Vector2(5, caja.size.y)), Color(1.0, 0.45, 0.35) if i % 2 == 0 else Color(0.35, 0.65, 1.0))
		_texto(c, fuente, Vector2(150, y + 19), String(fila[0]), 14, Color(0.95, 0.95, 0.9), false)
		var numero := str(int(_valores[i]))
		if int(fila[2]) >= 0:
			numero += "/%d" % fila[2]
		var completo := int(fila[2]) >= 0 and int(_valores[i]) >= int(fila[2])
		var color := Color(1.0, 0.85, 0.3) if completo else Color(1, 1, 1)
		var tam := 18 + int(8.0 * g)
		var ancho := fuente.get_string_size(numero, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		_texto(c, fuente, Vector2(492 - ancho, y + 21 - 3.0 * g), numero, tam, color, false)
		y += 32.0
	if _frase_visible > 0.0:
		var a := _frase_visible
		var caja := Rect2(138, 286, 364, 48)
		c.draw_rect(caja, Color(0.13, 0.09, 0.12, 0.95 * a))
		c.draw_rect(caja, Color(0.95, 0.85, 0.6, a), false, 2.0)
		var cara := Rect2(int(frase[1]) % 3 * LADO_RETRATO, int(frase[1]) / 3 * LADO_RETRATO, LADO_RETRATO, LADO_RETRATO)
		c.draw_texture_rect_region(RETRATOS, Rect2(142, 290, 40, 40), cara, Color(1, 1, 1, a))
		c.draw_string(fuente, Vector2(190, 302), "FELIPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.4, a))
		c.draw_multiline_string(fuente, Vector2(190, 317), String(frase[0]), HORIZONTAL_ALIGNMENT_LEFT, 306, 13, 2, Color(1, 0.97, 0.92, a))
		if terminado and fmod(_tiempo, 1.0) < 0.7:
			_texto(c, fuente, Vector2(320, 356), "Enter: seguir jugando", 9, Color(1, 1, 1, 0.7), true)


func _texto(c: Control, fuente: Font, pos: Vector2, texto: String, tamano: int, color: Color, centrado: bool) -> void:
	var p := pos
	if centrado:
		p.x -= fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x / 2.0
	c.draw_string_outline(fuente, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, 4, Color(0.03, 0.05, 0.04))
	c.draw_string(fuente, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)
