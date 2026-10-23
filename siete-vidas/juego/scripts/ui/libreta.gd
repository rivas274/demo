class_name Libreta
extends CanvasLayer
## La Agenda de Su Majestad en la hoja de la libreta, con la letra de Felipe, en dos columnas (letra de 16 px).
## Tab (mando: View/Select) la abre y la cierra; abierta, el juego queda en pausa. Las secretas dicen "???"
## hasta cumplirlas; las cumplidas se tachan con una palomita roja y muestran su recompensa.

signal abierta_cambio(abierta: bool)

## La hoja, dentro de la zona segura; dos columnas de renglones de 40 px (nombre y recompensa).
const HOJA := Rect2(92, 22, 456, 316)
const ALTO_RENGLON := 40.0
const COLUMNAS := 2
const ANCHO_COLUMNA := 214.0

var agenda: Agenda
var abierta := false
## Si es false, Tab no la abre (por ejemplo, durante el resumen del día).
var habilitada := true
var _hoja: Control


func _ready() -> void:
	layer = Capas.CAPA_LIBRETA
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	# La hoja de la libreta (dibujo de Felipe, no un panel de la interfaz): papel con contorno oscuro, renglones suaves,
	# margen rojo y la foto vergonzosa del unicornio prendida en la esquina. Letra de 16 px (layout v2: nada de 8).
	var hoja := HOJA
	c.draw_rect(hoja.grow(5), Estilo.color(&"ui_contorno"))
	c.draw_rect(hoja.grow(4), Estilo.color(&"libreta_papel"))
	for y in range(int(hoja.position.y) + 58, int(hoja.end.y) - 4, 20):
		c.draw_line(Vector2(hoja.position.x + 4, y), Vector2(hoja.end.x - 4, y), Estilo.color(&"libreta_renglon"), 1.0)
	c.draw_line(Vector2(hoja.position.x + 8, hoja.position.y + 4), Vector2(hoja.position.x + 8, hoja.end.y - 4), Estilo.color(&"libreta_margen"), 1.0)
	Estilo.escribir(c, Vector2(hoja.position.x + 18, hoja.position.y + 22), tr("LIBRETA_TITULO"), &"libreta_titulo", Estilo.color(&"libreta_tinta"))
	Estilo.escribir(c, Vector2(hoja.position.x + 18, hoja.position.y + 40), tr("LIBRETA_SUBTITULO"), &"libreta_subtitulo", Estilo.color(&"libreta_tinta").lightened(0.3))
	var foto := Estilo.icono(&"foto_unicornio")
	c.draw_texture(foto, Vector2(hoja.end.x - foto.get_width() + 14, hoja.position.y - 12))
	if agenda == null:
		return
	# Dos columnas de renglones (nombre y, debajo, la recompensa o «???»).
	var por_columna := ceili(agenda.travesuras.size() / float(COLUMNAS))
	for i in agenda.travesuras.size():
		var t: Dictionary = agenda.travesuras[i]
		var x := hoja.position.x + 18.0 + (i / por_columna) * ANCHO_COLUMNA
		var y := hoja.position.y + 54.0 + (i % por_columna) * ALTO_RENGLON
		_renglon(c, agenda, String(t["id"]), x, y)
	# Pie: cómo se cierra y cuántas van.
	var x_pie := hoja.position.x + 18
	IconosBotones.dibujar(c, "agenda", Vector2(x_pie, hoja.end.y - 20), 14.0)
	Estilo.escribir(c, Vector2(x_pie + IconosBotones.ancho("agenda", 14.0) + 4, hoja.end.y - 8), tr("LIBRETA_CERRAR"), &"libreta_pie", Estilo.color(&"libreta_pie"))
	var cuenta := tr("LIBRETA_CUENTA") % [agenda.cumplidas(), agenda.total()]
	Estilo.escribir(c, Vector2(hoja.end.x - 12 - Estilo.ancho(cuenta, &"libreta_cuenta"), hoja.end.y - 8), cuenta, &"libreta_cuenta", Estilo.color(&"libreta_rojo"))


func _renglon(c: Control, datos: Agenda, id: String, x0: float, y: float) -> void:
	var hecha := datos.esta_cumplida(id)
	var oculta := datos.es_secreta(id) and not hecha
	var casilla := Rect2(x0, y + 4, 12, 12)
	c.draw_rect(casilla, Estilo.color(&"libreta_casilla"))
	c.draw_rect(casilla, Estilo.color(&"libreta_tinta"), false, 1.5)
	var nombre := datos.nombre_visible(id)
	if datos.meta(id) > 1 and not hecha:
		nombre += "  (%d/%d)" % [datos.avance[id], datos.meta(id)]
	var ancho_max := ANCHO_COLUMNA - 30.0
	nombre = Estilo.recortar(nombre, &"libreta_renglon", ancho_max)
	Estilo.escribir(c, Vector2(x0 + 18, y + 15), nombre, &"libreta_renglon", Estilo.color(&"libreta_oculta") if oculta else Estilo.color(&"libreta_tinta"))
	var segunda := ""
	var color_segunda := Estilo.color(&"libreta_tinta").lightened(0.35)
	if hecha:
		# Palomita roja y tachado.
		c.draw_polyline(PackedVector2Array([casilla.position + Vector2(1, 6), casilla.position + Vector2(5, 11), casilla.position + Vector2(14, -3)]), Estilo.color(&"libreta_rojo"), 2.5)
		var ancho := Estilo.ancho(nombre, &"libreta_renglon")
		c.draw_line(Vector2(x0 + 16, y + 11), Vector2(x0 + 20 + ancho, y + 10), Estilo.color(&"libreta_tachado"), 2.0)
		segunda = tr("LIBRETA_HECHO") % datos.texto_recompensa(id)
		color_segunda = Estilo.color(&"libreta_hecho")
	elif oculta:
		segunda = tr("LIBRETA_SECRETA")
		color_segunda = Estilo.color(&"libreta_secreta")
	else:
		segunda = tr("LIBRETA_RECOMPENSA") % datos.texto_recompensa(id)
	Estilo.escribir(c, Vector2(x0 + 22, y + 32), Estilo.recortar(segunda, &"libreta_detalle", ancho_max - 4.0), &"libreta_detalle", color_segunda)
