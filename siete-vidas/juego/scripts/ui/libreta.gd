class_name Libreta
extends CanvasLayer
## La Agenda de Su Majestad en una libreta con la letra de Felipe (inclinada, tinta azul), agrupada por cuarto.
## Tab (mando: View/Select) la abre y la cierra; abierta, el juego queda en pausa. Las secretas dicen "???"
## hasta cumplirlas; las cumplidas se tachan con una palomita roja y muestran su recompensa.

signal abierta_cambio(abierta: bool)

const NOMBRES_CUARTOS := {
	"sala": "Sala", "recibidor": "Recibidor", "cocina": "Cocina", "pasillo": "Pasillo",
	"dormitorio": "Dormitorio", "estudio": "Estudio", "balcon": "Balcón",
}
const HOJA := Rect2(92, 20, 456, 322)
const TINTA := Color(0.12, 0.18, 0.48)
const ALTO_RENGLON := 29.0

var agenda: Agenda
var abierta := false
## Si es false, Tab no la abre (por ejemplo, durante el resumen del día).
var habilitada := true
var _hoja: Control
var _letra: FontVariation


func _ready() -> void:
	layer = Capas.CAPA_LIBRETA
	process_mode = Node.PROCESS_MODE_ALWAYS
	_letra = FontVariation.new()
	_letra.base_font = ThemeDB.fallback_font
	# Letra de Felipe: inclinada y un poco gruesa.
	_letra.variation_transform = Transform2D(Vector2(1, 0), Vector2(-0.22, 1), Vector2.ZERO)
	_letra.variation_embolden = 0.3
	_hoja = Control.new()
	_hoja.name = "Hoja"
	_hoja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hoja.size = Vector2(640, 360)
	_hoja.draw.connect(_dibujar)
	_hoja.visible = false
	add_child(_hoja)


func _process(_delta: float) -> void:
	if InputMap.has_action("agenda") and Input.is_action_just_pressed("agenda"):
		alternar()
	if abierta:
		_hoja.queue_redraw()


func alternar() -> void:
	if abierta:
		cerrar()
	else:
		abrir()


## Abre la libreta y pausa el juego. No se abre si el juego ya estaba en pausa por otra cosa (título, pausa, jefe).
func abrir() -> bool:
	if abierta or not habilitada or agenda == null or get_tree().paused:
		return false
	abierta = true
	_hoja.visible = true
	get_tree().paused = true
	_hoja.pivot_offset = Vector2(320, 180)
	_hoja.scale = Vector2(0.9, 0.9)
	_hoja.rotation = -0.04
	var t := create_tween()
	t.tween_property(_hoja, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(_hoja, "rotation", 0.0, 0.12)
	_hoja.queue_redraw()
	abierta_cambio.emit(true)
	return true


func cerrar() -> void:
	if not abierta:
		return
	abierta = false
	_hoja.visible = false
	get_tree().paused = false
	abierta_cambio.emit(false)


func _dibujar() -> void:
	var c := _hoja
	c.draw_rect(Rect2(0, 0, 640, 360), Color(0.05, 0.03, 0.05, 0.6))
	# Hoja de libreta: papel crema, renglones azules, margen rojo y espiral arriba.
	var hoja := HOJA
	c.draw_rect(hoja.grow(3), Color(0.25, 0.18, 0.14))
	c.draw_rect(hoja, Color(0.98, 0.95, 0.85))
	for y in range(int(hoja.position.y) + 58, int(hoja.end.y) - 4, 16):
		c.draw_line(Vector2(hoja.position.x + 2, y), Vector2(hoja.end.x - 2, y), Color(0.55, 0.68, 0.9, 0.45), 1.0)
	var margen := hoja.position.x + 78
	c.draw_line(Vector2(margen, hoja.position.y), Vector2(margen, hoja.end.y), Color(0.9, 0.35, 0.35, 0.7), 1.0)
	for i in 14:
		var x := hoja.position.x + 20 + i * 32
		c.draw_circle(Vector2(x, hoja.position.y + 2), 4.0, Color(0.5, 0.5, 0.55))
		c.draw_circle(Vector2(x, hoja.position.y + 2), 2.0, Color(0.2, 0.15, 0.15))
	c.draw_string(_letra, Vector2(margen + 8, hoja.position.y + 30), "Agenda de Su Majestad", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, TINTA)
	c.draw_string(_letra, Vector2(margen + 10, hoja.position.y + 46), "Cosas por hacer hoy (en orden de importancia: todas)", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TINTA.lightened(0.3))
	# Firma: huellita en la esquina.
	var huella := Vector2(hoja.end.x - 26, hoja.position.y + 28)
	c.draw_circle(huella, 6.0, Color(0.55, 0.3, 0.3, 0.6))
	for k in 4:
		c.draw_circle(huella + Vector2(-7 + k * 4.6, -9 + absf(k - 1.5) * 2.0), 2.4, Color(0.55, 0.3, 0.3, 0.6))
	if agenda == null:
		return
	var y := hoja.position.y + 56
	var cuarto_anterior := ""
	for t: Dictionary in agenda.travesuras:
		var id: String = t["id"]
		var cuarto := String(t.get("cuarto", ""))
		if cuarto != cuarto_anterior:
			cuarto_anterior = cuarto
			c.draw_string(_letra, Vector2(hoja.position.x + 8, y + 15), String(NOMBRES_CUARTOS.get(cuarto, cuarto.capitalize())), HORIZONTAL_ALIGNMENT_LEFT, 66, 11, Color(0.7, 0.25, 0.25))
		_renglon(c, agenda, id, margen + 6, y)
		y += ALTO_RENGLON
	# Pie: cómo se cierra y cuántas van.
	var x_pie := margen + 8
	IconosBotones.dibujar(c, "agenda", Vector2(x_pie, hoja.end.y - 22), 14.0)
	c.draw_string(ThemeDB.fallback_font, Vector2(x_pie + IconosBotones.ancho("agenda", 14.0) + 4, hoja.end.y - 11), "cerrar", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.3, 0.3))
	var cuenta := "%d de %d hechas" % [agenda.cumplidas(), agenda.total()]
	c.draw_string(_letra, Vector2(hoja.end.x - 12 - _letra.get_string_size(cuenta, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x, hoja.end.y - 10), cuenta, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.85, 0.15, 0.15))


func _renglon(c: Control, datos: Agenda, id: String, x0: float, y: float) -> void:
	var hecha := datos.esta_cumplida(id)
	var oculta := datos.es_secreta(id) and not hecha
	var casilla := Rect2(x0, y + 4, 12, 12)
	c.draw_rect(casilla, Color(1, 1, 1, 0.6))
	c.draw_rect(casilla, TINTA, false, 1.5)
	var nombre := datos.nombre_visible(id)
	if datos.meta(id) > 1 and not hecha:
		nombre += "  (%d/%d)" % [datos.avance[id], datos.meta(id)]
	var tamano := 12
	var ancho_max := HOJA.end.x - x0 - 30
	c.draw_string(_letra, Vector2(x0 + 20, y + 15), nombre, HORIZONTAL_ALIGNMENT_LEFT, ancho_max, tamano, Color(0.45, 0.4, 0.4) if oculta else TINTA)
	var segunda := ""
	var color_segunda := TINTA.lightened(0.35)
	if hecha:
		# Palomita roja y tachado.
		c.draw_polyline(PackedVector2Array([casilla.position + Vector2(1, 6), casilla.position + Vector2(5, 11), casilla.position + Vector2(14, -3)]), Color(0.85, 0.15, 0.15), 2.5)
		var ancho := minf(_letra.get_string_size(nombre, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x, ancho_max)
		c.draw_line(Vector2(x0 + 18, y + 10), Vector2(x0 + 22 + ancho, y + 9), Color(0.12, 0.18, 0.48, 0.85), 2.0)
		segunda = "¡HECHO!  Recompensa: " + datos.texto_recompensa(id)
		color_segunda = Color(0.1, 0.5, 0.2)
	elif oculta:
		segunda = "secreta  ·  recompensa: ???"
		color_segunda = Color(0.5, 0.45, 0.45)
	else:
		segunda = "recompensa: " + datos.texto_recompensa(id)
		var nota := String(datos.datos(id).get("nota", ""))
		if nota != "":
			segunda = "(" + nota + ")   " + segunda
	c.draw_string(_letra, Vector2(x0 + 24, y + 27), segunda, HORIZONTAL_ALIGNMENT_LEFT, ancho_max, 9, color_segunda)
