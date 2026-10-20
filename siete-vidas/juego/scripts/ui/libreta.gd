class_name Libreta
extends CanvasLayer
## La Agenda de Su Majestad en una libreta con la letra de Felipe (inclinada, tinta azul), agrupada por cuarto.
## Tab (mando: View/Select) la abre y la cierra; abierta, el juego queda en pausa. Las secretas dicen "???"
## hasta cumplirlas; las cumplidas se tachan con una palomita roja y muestran su recompensa.

signal abierta_cambio(abierta: bool)

const HOJA := Rect2(92, 20, 456, 322)
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
	_letra.base_font = Estilo.fuente()
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
	# Tab solo la abre con el juego andando, y solo la cierra si está arriba de la pila de pantallas.
	if InputMap.has_action("agenda") and Input.is_action_just_pressed("agenda"):
		var arriba := GestorPantallas.de(self).arriba()
		if arriba == null or arriba == self:
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
	GestorPantallas.de(self).abrir(self)
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
	GestorPantallas.de(self).cerrar(self)
	abierta_cambio.emit(false)


func _dibujar() -> void:
	var c := _hoja
	c.draw_rect(Rect2(0, 0, 640, 360), Estilo.color(&"libreta_velo"))
	# Hoja de libreta: papel crema, renglones azules, margen rojo y espiral arriba.
	var hoja := HOJA
	c.draw_rect(hoja.grow(3), Estilo.color(&"libreta_tapa"))
	c.draw_rect(hoja, Estilo.color(&"libreta_papel"))
	for y in range(int(hoja.position.y) + 58, int(hoja.end.y) - 4, 16):
		c.draw_line(Vector2(hoja.position.x + 2, y), Vector2(hoja.end.x - 2, y), Estilo.color(&"libreta_renglon"), 1.0)
	var margen := hoja.position.x + 78
	c.draw_line(Vector2(margen, hoja.position.y), Vector2(margen, hoja.end.y), Estilo.color(&"libreta_margen"), 1.0)
	for i in 14:
		var x := hoja.position.x + 20 + i * 32
		c.draw_circle(Vector2(x, hoja.position.y + 2), 4.0, Estilo.color(&"libreta_espiral"))
		c.draw_circle(Vector2(x, hoja.position.y + 2), 2.0, Estilo.color(&"libreta_espiral_hueco"))
	c.draw_string(_letra, Vector2(margen + 8, hoja.position.y + 30), tr("LIBRETA_TITULO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Estilo.color(&"libreta_tinta"))
	c.draw_string(_letra, Vector2(margen + 10, hoja.position.y + 46), tr("LIBRETA_SUBTITULO"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Estilo.color(&"libreta_tinta").lightened(0.3))
	# Firma: huellita en la esquina.
	var huella := Vector2(hoja.end.x - 26, hoja.position.y + 28)
	c.draw_circle(huella, 6.0, Estilo.color(&"libreta_huella"))
	for k in 4:
		c.draw_circle(huella + Vector2(-7 + k * 4.6, -9 + absf(k - 1.5) * 2.0), 2.4, Estilo.color(&"libreta_huella"))
	if agenda == null:
		return
	var y := hoja.position.y + 56
	var cuarto_anterior := ""
	for t: Dictionary in agenda.travesuras:
		var id: String = t["id"]
		var cuarto := String(t.get("cuarto", ""))
		if cuarto != cuarto_anterior:
			cuarto_anterior = cuarto
			c.draw_string(_letra, Vector2(hoja.position.x + 8, y + 15), _nombre_cuarto(cuarto), HORIZONTAL_ALIGNMENT_LEFT, 66, 11, Estilo.color(&"libreta_cuarto"))
		_renglon(c, agenda, id, margen + 6, y)
		y += ALTO_RENGLON
	# Pie: cómo se cierra y cuántas van.
	var x_pie := margen + 8
	IconosBotones.dibujar(c, "agenda", Vector2(x_pie, hoja.end.y - 22), 14.0)
	c.draw_string(Estilo.fuente(), Vector2(x_pie + IconosBotones.ancho("agenda", 14.0) + 4, hoja.end.y - 11), tr("LIBRETA_CERRAR"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Estilo.color(&"libreta_pie"))
	var cuenta := tr("LIBRETA_CUENTA") % [agenda.cumplidas(), agenda.total()]
	c.draw_string(_letra, Vector2(hoja.end.x - 12 - _letra.get_string_size(cuenta, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x, hoja.end.y - 10), cuenta, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Estilo.color(&"libreta_rojo"))


func _renglon(c: Control, datos: Agenda, id: String, x0: float, y: float) -> void:
	var hecha := datos.esta_cumplida(id)
	var oculta := datos.es_secreta(id) and not hecha
	var casilla := Rect2(x0, y + 4, 12, 12)
	c.draw_rect(casilla, Estilo.color(&"libreta_casilla"))
	c.draw_rect(casilla, Estilo.color(&"libreta_tinta"), false, 1.5)
	var nombre := datos.nombre_visible(id)
	if datos.meta(id) > 1 and not hecha:
		nombre += "  (%d/%d)" % [datos.avance[id], datos.meta(id)]
	var tamano := 12
	var ancho_max := HOJA.end.x - x0 - 30
	c.draw_string(_letra, Vector2(x0 + 20, y + 15), nombre, HORIZONTAL_ALIGNMENT_LEFT, ancho_max, tamano, Estilo.color(&"libreta_oculta") if oculta else Estilo.color(&"libreta_tinta"))
	var segunda := ""
	var color_segunda := Estilo.color(&"libreta_tinta").lightened(0.35)
	if hecha:
		# Palomita roja y tachado.
		c.draw_polyline(PackedVector2Array([casilla.position + Vector2(1, 6), casilla.position + Vector2(5, 11), casilla.position + Vector2(14, -3)]), Estilo.color(&"libreta_rojo"), 2.5)
		var ancho := minf(_letra.get_string_size(nombre, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x, ancho_max)
		c.draw_line(Vector2(x0 + 18, y + 10), Vector2(x0 + 22 + ancho, y + 9), Estilo.color(&"libreta_tachado"), 2.0)
		segunda = tr("LIBRETA_HECHO") % datos.texto_recompensa(id)
		color_segunda = Estilo.color(&"libreta_hecho")
	elif oculta:
		segunda = tr("LIBRETA_SECRETA")
		color_segunda = Estilo.color(&"libreta_secreta")
	else:
		segunda = tr("LIBRETA_RECOMPENSA") % datos.texto_recompensa(id)
		var nota := String(datos.datos(id).get("nota", ""))
		if nota != "":
			segunda = "(" + nota + ")   " + segunda
	c.draw_string(_letra, Vector2(x0 + 24, y + 27), segunda, HORIZONTAL_ALIGNMENT_LEFT, ancho_max, 9, color_segunda)


## Nombre del cuarto en pantalla (clave CUARTO_<id> en la traducción; si no hay, el id con mayúscula).
func _nombre_cuarto(cuarto: String) -> String:
	var clave := "CUARTO_" + cuarto
	var nombre := tr(clave)
	return nombre if nombre != clave else cuarto.capitalize()
