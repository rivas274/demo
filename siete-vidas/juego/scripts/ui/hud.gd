class_name Hud
extends CanvasLayer
## Arriba, discreto y sin báscula: la agenda (cuántas van y el ícono de Tab), calcetines del nido, fotos de la
## galería y snacks del bolsillo (x/5). Al centro, los carteles épicos "¡TRAVESURA CUMPLIDA!" y
## "¡TRAVESURA SECRETA!" en cola (como la franja de un jefe, en chico). Nada de puntos.
## Va a la derecha de los corazones y las vidas (Medidores, 6 a 98 px).

## Carteles que se mostraron (para las pruebas): [título, nombre].
var carteles: Array = []
## Segundos entre la travesura y el cartel: primero se ve el gag, después el cartel.
@export var retraso_cartel := 0.5

var agenda: Agenda
var recompensas: Recompensas
## La cola única de anuncios (G5): si está, los carteles esperan su turno y su lugar ahí.
var anuncios: Anuncios
var _barra: Control
var _mostrando := false
var _golpe := {}

const X0 := 104.0
## Alto del cartel y alturas posibles (bajo el diálogo de arriba, al medio, abajo).
const ALTO_CARTEL := 96.0
const Y_CARTEL := 104.0
const ALTURAS_CARTEL := [104.0, 180.0, 252.0]
const FONDO := Color(0.1, 0.07, 0.09, 0.78)
## Versión chica del cartel (cuando no hay hueco para la franja sin tapar el chiste): una tarjeta en una esquina.
const TAM_CHICO := Vector2(260, 54)
const DURACION_CARTEL := 2.45


func _ready() -> void:
	layer = Capas.CAPA_HUD
	process_mode = Node.PROCESS_MODE_ALWAYS
	_barra = Control.new()
	_barra.name = "Barra"
	_barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_barra.size = Vector2(640, 40)
	_barra.draw.connect(_dibujar_barra)
	add_child(_barra)


func _process(delta: float) -> void:
	for clave: String in _golpe.keys():
		_golpe[clave] = maxf(0.0, _golpe[clave] - delta * 3.0)
	_barra.queue_redraw()


## Hace saltar un contador ("calcetin", "snack", "foto" o "agenda").
func golpear(clave: String) -> void:
	_golpe[clave] = 1.0


func _dibujar_barra() -> void:
	if agenda == null:
		return
	var fuente := ThemeDB.fallback_font
	# Libreta: "AGENDA 2/8" y la tecla para abrirla.
	var g: float = _golpe.get("agenda", 0.0)
	var ancho_agenda := 116.0
	_barra.draw_rect(Rect2(X0, 6, ancho_agenda, 22), FONDO)
	_barra.draw_rect(Rect2(X0 + 4, 9, 12, 15), Color(0.97, 0.93, 0.8))
	for k in 3:
		_barra.draw_line(Vector2(X0 + 6, 13 + k * 4), Vector2(X0 + 14 - (k / 2) * 2, 13 + k * 4), Color(0.3, 0.35, 0.7), 1.0)
	_texto(fuente, Vector2(X0 + 20, 21), "AGENDA %d/%d" % [agenda.cumplidas(), agenda.total()], 11 + int(g * 4), Color(1.0, 0.88, 0.45).lerp(Color.WHITE, g))
	IconosBotones.dibujar(_barra, "agenda", Vector2(X0 + ancho_agenda - IconosBotones.ancho("agenda", 12.0) - 3, 11), 12.0)
	# Recompensas: ícono y número.
	var x := X0 + ancho_agenda + 4
	var snacks := recompensas.snacks() if recompensas else 0
	var filas := [
		["calcetin", str(recompensas.calcetines if recompensas else 0), recompensas != null and recompensas.calcetines > 0],
		["foto", str(recompensas.fotos if recompensas else 0), recompensas != null and recompensas.fotos > 0],
		["snack", "%d/%d" % [snacks, Felipe.SNACKS_MAX], snacks > 0],
	]
	for datos: Array in filas:
		var clave: String = datos[0]
		var gc: float = _golpe.get(clave, 0.0)
		var tiene: bool = datos[2]
		var ancho := 52.0 if clave != "snack" else 60.0
		_barra.draw_rect(Rect2(x, 6, ancho, 22), FONDO)
		Recogible.dibujar_icono(_barra, clave, Vector2(x + 13, 17), 0.6 + 0.25 * gc)
		if not tiene:
			_barra.draw_rect(Rect2(x + 1, 7, 24, 20), Color(0.1, 0.07, 0.09, 0.55))
		_texto(fuente, Vector2(x + 27, 21), datos[1], 11 + int(gc * 4), Color(1, 1, 1).lerp(Color(1.0, 0.9, 0.4), gc) if tiene else Color(1, 1, 1, 0.45))
		x += ancho + 4


func _texto(fuente: Font, pos: Vector2, texto: String, tamano: int, color: Color) -> void:
	_barra.draw_string_outline(fuente, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, 4, Color(0.08, 0.04, 0.06))
	_barra.draw_string(fuente, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


## Cartel épico: título grande, nombre de la travesura y la recompensa. Pasa por la cola única de anuncios (G5): sale
## cuando le toca, donde no tapa a Felipe, al diálogo ni a quien reacciona; si no hay hueco, en chico en una esquina.
## `y_cartel` solo se usa sin cola de anuncios (pruebas sueltas del HUD).
func cartel(titulo: String, nombre: String, recompensa: String, secreta: bool, y_cartel := -1.0) -> void:
	carteles.append([titulo, nombre])
	golpear("agenda")
	var datos := [titulo, nombre, recompensa, secreta]
	if anuncios:
		anuncios.anunciar("cartel", titulo, Vector2(640, ALTO_CARTEL), TAM_CHICO,
			func(rect: Rect2, chico: bool) -> float: return _mostrar_cartel(datos, rect, chico),
			_ocultar_cartel, false, retraso_cartel, false, _mover_cartel)
		return
	_mostrando = true
	create_tween().tween_callback(func() -> void:
		_mostrar_cartel(datos, Rect2(0, y_cartel if y_cartel >= 0.0 else Y_CARTEL, 640, ALTO_CARTEL), false)
		create_tween().tween_callback(func() -> void: _mostrando = false).set_delay(DURACION_CARTEL)).set_delay(retraso_cartel)


func ocupado() -> bool:
	return _mostrando or (anuncios != null and anuncios.ocupado())


var _caja_actual: Control
var _animacion: Tween


## Muestra el cartel en ese rectángulo (franja completa o tarjeta chica) y devuelve cuánto dura.
func _mostrar_cartel(datos: Array, rect: Rect2, chico: bool) -> float:
	var secreta: bool = datos[3]
	var color := Color(1.0, 0.45, 0.85) if secreta else Color(1.0, 0.85, 0.25)
	var caja := Control.new()
	caja.name = "Cartel"
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.size = rect.size
	caja.position = rect.position
	caja.pivot_offset = rect.size / 2.0
	add_child(caja)
	_caja_actual = caja
	if chico:
		var fondo := Panel.new()
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.12, 0.05, 0.12, 0.9)
		estilo.border_color = color
		estilo.set_border_width_all(2)
		estilo.set_corner_radius_all(3)
		fondo.add_theme_stylebox_override("panel", estilo)
		fondo.size = rect.size
		fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caja.add_child(fondo)
		caja.add_child(_etiqueta(datos[0], 14, color, Vector2(0, 2), rect.size.x))
		caja.add_child(_etiqueta(String(datos[1]).to_upper(), 9, Color.WHITE, Vector2(6, 22), rect.size.x - 12))
		caja.add_child(_etiqueta("RECOMPENSA: " + String(datos[2]).to_upper(), 9, Color(0.75, 1.0, 0.75), Vector2(6, 35), rect.size.x - 12))
	else:
		var franja := Polygon2D.new()
		franja.polygon = PackedVector2Array([Vector2(0, 12), Vector2(640, 0), Vector2(640, 84), Vector2(0, 96)])
		franja.color = Color(0.12, 0.05, 0.12, 0.88)
		caja.add_child(franja)
		for puntos: PackedVector2Array in [PackedVector2Array([Vector2(0, 12), Vector2(640, 0)]), PackedVector2Array([Vector2(0, 96), Vector2(640, 84)])]:
			var borde := Line2D.new()
			borde.points = puntos
			borde.width = 3.0
			borde.default_color = color
			caja.add_child(borde)
		caja.add_child(_etiqueta(datos[0], 24, color, Vector2(0, 12)))
		caja.add_child(_etiqueta(String(datos[1]).to_upper(), 14, Color.WHITE, Vector2(0, 45)))
		caja.add_child(_etiqueta("RECOMPENSA: " + String(datos[2]).to_upper(), 11, Color(0.6, 1.0, 0.6), Vector2(0, 67)))
	caja.scale = Vector2(1.6, 0.1) if not chico else Vector2(0.6, 0.6)
	caja.modulate.a = 0.0
	_animacion = create_tween()
	_animacion.tween_property(caja, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_animacion.parallel().tween_property(caja, "modulate:a", 1.0, 0.1)
	_animacion.tween_interval(DURACION_CARTEL - 0.43)
	_animacion.tween_property(caja, "position:x", -rect.size.x - 20.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_animacion.tween_callback(caja.queue_free)
	return DURACION_CARTEL


## Se corre a otro lugar (alguien entró a cuadro y el cartel lo tapaba).
func _mover_cartel(rect: Rect2) -> void:
	if is_instance_valid(_caja_actual):
		create_tween().tween_property(_caja_actual, "position:y", rect.position.y, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if rect.size.x < 640.0:
			_caja_actual.position.x = rect.position.x


## Sale rápido (algo urgente pidió la pantalla).
func _ocultar_cartel() -> void:
	if _animacion:
		_animacion.kill()
	if is_instance_valid(_caja_actual):
		var caja := _caja_actual
		var salir := create_tween()
		salir.tween_property(caja, "modulate:a", 0.0, 0.12)
		salir.tween_callback(caja.queue_free)


func _etiqueta(texto: String, tamano: int, color: Color, pos: Vector2, ancho := 640.0) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.position = pos
	etiqueta.size = Vector2(ancho, tamano + 8)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.06))
	etiqueta.add_theme_constant_override("outline_size", 6)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Nunca se sale de su caja (en la tarjeta chica, los nombres largos terminan en «…»).
	etiqueta.clip_text = true
	etiqueta.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return etiqueta
