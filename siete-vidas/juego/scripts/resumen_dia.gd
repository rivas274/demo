class_name ResumenDia
extends CanvasLayer
## Resumen del día al terminar un nivel, tipo Balatro: las filas aparecen una a una y sus números suben contando
## con un golpe; al final, una frase de Felipe con su retrato. Pausa el juego; Enter (o A, o Tab) cierra.

signal cerrado

const RETRATOS := preload("res://assets/felipe/felipe-retratos.png")
const LADO_RETRATO := 200.0 / 3.0

@export var pausa_entre_filas := 0.5
@export var duracion_conteo := 0.5

## Filas: [texto, valor, total (-1 si no tiene), nota chica opcional].
var filas: Array = []
var frase: Array = ["", 0]
var terminado := false
var _mostradas := 0
var _valores: Array[float] = []
var _golpes: Array[float] = []
var _tiempo := 0.0
var _lienzo: Control
var _frase_visible := 0.0


## Filas a partir de la agenda y las recompensas (más los perdones de Valeria, que cuenta el nivel).
static func filas_de(agenda: Agenda, recompensas: Recompensas, perdones := 0) -> Array:
	return [
		["Travesuras de la agenda", agenda.cumplidas(), agenda.total(), ""],
		["Secretas", agenda.secretas_cumplidas(), agenda.total_secretas(), ""],
		["Calcetines al nido", recompensas.calcetines, -1, recompensas.texto_ranura()],
		["Fotos vergonzosas", recompensas.fotos, -1, "a la galería"],
		["Snacks en el bolsillo", recompensas.snacks(), Felipe.SNACKS_MAX, ""],
		["Valeria te perdonó", perdones, -1, "veces"],
	]


func mostrar(datos: Array, frase_final: Array) -> void:
	filas = datos
	frase = frase_final
	_valores.clear()
	_golpes.clear()
	for f in filas:
		_valores.append(0.0)
		_golpes.append(0.0)


func _ready() -> void:
	name = "ResumenDia"
	layer = Capas.CAPA_RESUMEN
	process_mode = Node.PROCESS_MODE_ALWAYS
	_lienzo = Control.new()
	_lienzo.size = Vector2(640, 360)
	_lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lienzo.draw.connect(_dibujar)
	add_child(_lienzo)
	get_tree().paused = true


func _process(delta: float) -> void:
	delta = delta / maxf(Engine.time_scale, 0.001)
	_tiempo += delta
	var objetivo := mini(int(_tiempo / pausa_entre_filas), filas.size())
	if objetivo > _mostradas:
		_mostradas = objetivo
		_golpes[_mostradas - 1] = 1.0
	for i in _mostradas:
		var meta := float(filas[i][1])
		if _valores[i] < meta:
			var antes := int(_valores[i])
			_valores[i] = minf(meta, _valores[i] + maxf(meta, 1.0) / duracion_conteo * delta)
			if int(_valores[i]) != antes:
				_golpes[i] = 1.0
		_golpes[i] = maxf(0.0, _golpes[i] - delta * 4.0)
	if _tiempo > filas.size() * pausa_entre_filas + duracion_conteo + 0.3:
		_frase_visible = minf(1.0, _frase_visible + delta * 3.0)
		terminado = true
	_lienzo.queue_redraw()
	if terminado and (_apretado("saltar_dialogo") or _apretado("agenda") or _apretado("ui_accept")):
		cerrar()


func _apretado(accion: String) -> bool:
	return InputMap.has_action(accion) and Input.is_action_just_pressed(accion)


func cerrar() -> void:
	get_tree().paused = false
	cerrado.emit()
	queue_free()


func _dibujar() -> void:
	var c := _lienzo
	var fuente := ThemeDB.fallback_font
	var entrada := minf(_tiempo * 4.0, 1.0)
	c.draw_rect(Rect2(0, 0, 640, 360), Color(0.03, 0.06, 0.05, 0.82 * entrada))
	# Paño verde con borde dorado.
	var panel := Rect2(110, 14, 420, 334)
	c.draw_rect(panel.grow(3), Color(0.85, 0.65, 0.25))
	c.draw_rect(panel, Color(0.12, 0.3, 0.24))
	_texto(c, fuente, Vector2(320, 42), "FIN DEL DÍA", 22, Color(1.0, 0.85, 0.3), true)
	_texto(c, fuente, Vector2(320, 57), "Informe de Su Majestad", 10, Color(0.8, 0.95, 0.85), true)
	var y := 66.0
	for i in _mostradas:
		var fila: Array = filas[i]
		var g := _golpes[i]
		var caja := Rect2(126, y, 388, 30)
		c.draw_rect(caja, Color(0.07, 0.18, 0.14))
		c.draw_rect(Rect2(caja.position, Vector2(5, caja.size.y)), Color(1.0, 0.45, 0.35) if i % 2 == 0 else Color(0.35, 0.65, 1.0))
		_texto(c, fuente, Vector2(138, y + 15), String(fila[0]), 13, Color(0.95, 0.95, 0.9), false)
		var nota := String(fila[3]) if fila.size() > 3 else ""
		if nota != "":
			_texto(c, fuente, Vector2(138, y + 26), nota, 9, Color(0.7, 0.85, 0.75), false)
		var numero := str(int(_valores[i]))
		if int(fila[2]) >= 0:
			numero += "/%d" % fila[2]
		var completo := int(fila[2]) >= 0 and int(_valores[i]) >= int(fila[2])
		var tam := 17 + int(8.0 * g)
		var ancho := fuente.get_string_size(numero, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		_texto(c, fuente, Vector2(504 - ancho, y + 21 - 3.0 * g), numero, tam, Color(1.0, 0.85, 0.3) if completo else Color.WHITE, false)
		y += 34.0
	if _frase_visible > 0.0:
		var a := _frase_visible
		var caja := Rect2(126, 274, 388, 50)
		c.draw_rect(caja, Color(0.13, 0.09, 0.12, 0.95 * a))
		c.draw_rect(caja, Color(0.95, 0.85, 0.6, a), false, 2.0)
		var animo := int(frase[1])
		var cara := Rect2(animo % 3 * LADO_RETRATO, animo / 3 * LADO_RETRATO, LADO_RETRATO, LADO_RETRATO)
		c.draw_texture_rect_region(RETRATOS, Rect2(130, 278, 42, 42), cara, Color(1, 1, 1, a))
		c.draw_string(fuente, Vector2(180, 290), "FELIPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.8, 0.4, a))
		c.draw_multiline_string(fuente, Vector2(180, 305), String(frase[0]), HORIZONTAL_ALIGNMENT_LEFT, 326, 13, 2, Color(1, 0.97, 0.92, a))
		if terminado and fmod(_tiempo, 1.0) < 0.7:
			IconosBotones.dibujar(c, "saltar_dialogo", Vector2(268, 330), 12.0)
			_texto(c, fuente, Vector2(286, 340), "seguir", 9, Color(1, 1, 1, 0.75), false)


func _texto(c: Control, fuente: Font, pos: Vector2, texto: String, tamano: int, color: Color, centrado: bool) -> void:
	var p := pos
	if centrado:
		p.x -= fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x / 2.0
	c.draw_string_outline(fuente, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, 4, Color(0.03, 0.05, 0.04))
	c.draw_string(fuente, p, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)
