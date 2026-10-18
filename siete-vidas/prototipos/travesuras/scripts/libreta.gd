# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Libreta
extends CanvasLayer
## La Agenda de Su Majestad en una libreta con la letra de Felipe (inclinada, tinta azul).
## Tab (mando: Select/Back) la abre y la cierra; con ella abierta el juego queda en pausa.
## F (mando: Start) termina el día y pide el resumen.

signal pidio_terminar

var agenda: Agenda
var abierta := false
var bloqueada := false
var _hoja: Control
var _letra: FontVariation
var _tiempo := 0.0
var _sonidos: Sonidos


func preparar(datos: Agenda, sonidos: Sonidos) -> void:
	agenda = datos
	_sonidos = sonidos


func _ready() -> void:
	layer = 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	_letra = FontVariation.new()
	_letra.base_font = ThemeDB.fallback_font
	# Letra de Felipe: inclinada y un poco gruesa.
	_letra.variation_transform = Transform2D(Vector2(1, 0), Vector2(-0.22, 1), Vector2.ZERO)
	_letra.variation_embolden = 0.3
	_hoja = Control.new()
	_hoja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hoja.size = Vector2(640, 360)
	_hoja.draw.connect(_dibujar)
	_hoja.visible = false
	add_child(_hoja)


func _process(delta: float) -> void:
	_tiempo += delta
	if bloqueada:
		return
	if Input.is_action_just_pressed("agenda"):
		alternar()
	elif Input.is_action_just_pressed("terminar"):
		cerrar()
		pidio_terminar.emit()
	if abierta:
		_hoja.queue_redraw()


func alternar() -> void:
	if abierta:
		cerrar()
	else:
		abrir()


func abrir() -> void:
	abierta = true
	_hoja.visible = true
	get_tree().paused = true
	if _sonidos:
		_sonidos.sonar("pop", 0.8)
	_hoja.pivot_offset = Vector2(320, 180)
	_hoja.scale = Vector2(0.9, 0.9)
	_hoja.rotation = -0.04
	var t := create_tween()
	t.tween_property(_hoja, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_hoja, "rotation", 0.0, 0.12)
	_hoja.queue_redraw()


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	_hoja.visible = false
	get_tree().paused = false
	if _sonidos:
		_sonidos.sonar("pop", 0.6)


## Lo que dice el renglón: "???" si es secreta y no se ha cumplido.
func nombre_visible(t: Dictionary) -> String:
	if t["secreta"] and not agenda.esta_cumplida(t["id"]):
		return "???"
	return String(t["nombre"])


func _dibujar() -> void:
	var c := _hoja
	# Fondo oscurecido.
	c.draw_rect(Rect2(0, 0, 640, 360), Color(0.05, 0.03, 0.05, 0.6))
	# Hoja de libreta: papel crema, renglones azules, margen rojo y espiral arriba.
	var hoja := Rect2(118, 26, 404, 314)
	c.draw_rect(hoja.grow(3), Color(0.25, 0.18, 0.14))
	c.draw_rect(hoja, Color(0.98, 0.95, 0.85))
	for y in range(int(hoja.position.y) + 52, int(hoja.end.y) - 4, 16):
		c.draw_line(Vector2(hoja.position.x + 2, y), Vector2(hoja.end.x - 2, y), Color(0.55, 0.68, 0.9, 0.5), 1.0)
	c.draw_line(Vector2(hoja.position.x + 40, hoja.position.y), Vector2(hoja.position.x + 40, hoja.end.y), Color(0.9, 0.35, 0.35, 0.7), 1.0)
	for i in 12:
		var x := hoja.position.x + 22 + i * 32
		c.draw_circle(Vector2(x, hoja.position.y + 2), 4.0, Color(0.5, 0.5, 0.55))
		c.draw_circle(Vector2(x, hoja.position.y + 2), 2.0, Color(0.2, 0.15, 0.15))
	var tinta := Color(0.12, 0.18, 0.48)
	var x0 := hoja.position.x + 48
	c.draw_string(_letra, Vector2(x0, hoja.position.y + 30), "Agenda de Su Majestad", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, tinta)
	c.draw_string(_letra, Vector2(x0 + 2, hoja.position.y + 46), "Cosas por hacer hoy (en orden de importancia: todas)", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, tinta.lightened(0.3))
	# Firma: huellita en la esquina.
	var huella := Vector2(hoja.end.x - 30, hoja.position.y + 26)
	c.draw_circle(huella, 6.0, Color(0.55, 0.3, 0.3, 0.6))
	for k in 4:
		c.draw_circle(huella + Vector2(-7 + k * 4.6, -9 + absf(k - 1.5) * 2.0), 2.4, Color(0.55, 0.3, 0.3, 0.6))
	if agenda == null:
		return
	var y := hoja.position.y + 62
	for t: Dictionary in Agenda.TRAVESURAS:
		var id: String = t["id"]
		var hecha := agenda.esta_cumplida(id)
		var oculta: bool = t["secreta"] and not hecha
		# Casilla.
		var casilla := Rect2(x0, y + 4, 12, 12)
		c.draw_rect(casilla, Color(1, 1, 1, 0.6))
		c.draw_rect(casilla, tinta, false, 1.5)
		var nombre := nombre_visible(t)
		if int(t["meta"]) > 1 and not hecha:
			nombre += "  (%d/%d)" % [agenda.avance[id], t["meta"]]
		var tamano := 13
		var color := tinta if not oculta else Color(0.45, 0.4, 0.4)
		c.draw_string(_letra, Vector2(x0 + 20, y + 15), nombre, HORIZONTAL_ALIGNMENT_LEFT, 330, tamano, color)
		var segunda := ""
		var color_segunda := tinta.lightened(0.35)
		if hecha:
			# Palomita roja y tachado.
			c.draw_polyline(PackedVector2Array([casilla.position + Vector2(1, 6), casilla.position + Vector2(5, 11), casilla.position + Vector2(14, -3)]), Color(0.85, 0.15, 0.15), 2.5)
			var ancho := minf(_letra.get_string_size(nombre, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x, 330.0)
			c.draw_line(Vector2(x0 + 18, y + 10), Vector2(x0 + 22 + ancho, y + 9), Color(0.12, 0.18, 0.48, 0.85), 2.0)
			segunda = "¡HECHO!  Recompensa: " + String(t["recompensa"])
			color_segunda = Color(0.1, 0.5, 0.2)
		elif oculta:
			segunda = "secreta  ·  recompensa: ???"
			color_segunda = Color(0.5, 0.45, 0.45)
		else:
			segunda = "recompensa: " + String(t["recompensa"])
			if String(t["nota"]) != "":
				segunda = "(" + String(t["nota"]) + ")   " + segunda
		c.draw_string(_letra, Vector2(x0 + 24, y + 29), segunda, HORIZONTAL_ALIGNMENT_LEFT, 330, 10, color_segunda)
		y += 38.0
	# Pie.
	var pie := "Tab: cerrar        F: terminar el día"
	c.draw_string(ThemeDB.fallback_font, Vector2(x0, hoja.end.y - 10), pie, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.3, 0.3))
	c.draw_string(_letra, Vector2(hoja.end.x - 118, hoja.end.y - 10), "%d de %d hechas" % [agenda.cumplidas(), agenda.total()], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.15, 0.15))
