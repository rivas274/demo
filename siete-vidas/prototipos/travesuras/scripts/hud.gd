# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Hud
extends CanvasLayer
## Arriba a la izquierda: la agenda (cuántas van y la tecla) y las recompensas como íconos chicos
## (calcetines 2/3, snacks, fotos). Al centro: el cartel épico "¡TRAVESURA CUMPLIDA!" en cola.
## Nada de puntos.

const TOTAL_CALCETINES := 3

var calcetines := 0
var snacks := 0
var fotos := 0
var travesuras := 0
var total_travesuras := 7
## Carteles que se mostraron (para la prueba): [titulo, nombre].
var carteles: Array = []
## Segundos entre la travesura y el cartel.
@export var retraso_cartel := 0.5

var _barra: Control
var _cola: Array = []
var _mostrando := false
var _golpe := {}
var _sonidos: Sonidos


func preparar(sonidos: Sonidos) -> void:
	_sonidos = sonidos


func _ready() -> void:
	layer = 6
	process_mode = Node.PROCESS_MODE_ALWAYS
	_barra = Control.new()
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
	var fuente := ThemeDB.fallback_font
	var fondo := Color(0.1, 0.07, 0.09, 0.78)
	# Libreta: "AGENDA 2/7 [Tab]".
	var g: float = _golpe.get("agenda", 0.0)
	_barra.draw_rect(Rect2(4, 4, 112, 22), fondo)
	_barra.draw_rect(Rect2(8, 8, 12, 15), Color(0.97, 0.93, 0.8))
	_barra.draw_line(Vector2(10, 12), Vector2(18, 12), Color(0.3, 0.35, 0.7), 1.0)
	_barra.draw_line(Vector2(10, 16), Vector2(18, 16), Color(0.3, 0.35, 0.7), 1.0)
	_barra.draw_line(Vector2(10, 20), Vector2(16, 20), Color(0.3, 0.35, 0.7), 1.0)
	_texto(fuente, Vector2(25, 20), "AGENDA %d/%d" % [travesuras, total_travesuras], 12 + int(g * 4), Color(1.0, 0.88, 0.45).lerp(Color.WHITE, g))
	_texto(fuente, Vector2(120, 20), "Tab", 9, Color(1, 1, 1, 0.6))
	# Recompensas: íconos con su número.
	var x := 146.0
	for datos: Array in [["calcetin", "%d/%d" % [calcetines, TOTAL_CALCETINES], calcetines], ["snack", str(snacks), snacks], ["foto", str(fotos), fotos]]:
		var clave: String = datos[0]
		var gc: float = _golpe.get(clave, 0.0)
		var tiene: bool = int(datos[2]) > 0
		_barra.draw_rect(Rect2(x, 4, 58, 22), fondo)
		var escala := 0.62 + 0.25 * gc
		Recogible.dibujar_icono(_barra, clave, Vector2(x + 13, 15), escala)
		if not tiene:
			_barra.draw_rect(Rect2(x + 1, 5, 24, 20), Color(0.1, 0.07, 0.09, 0.55))
		_texto(fuente, Vector2(x + 28, 20), datos[1], 12 + int(gc * 4), Color(1, 1, 1).lerp(Color(1.0, 0.9, 0.4), gc) if tiene else Color(1, 1, 1, 0.45))
		x += 62.0


func _texto(fuente: Font, pos: Vector2, texto: String, tamano: int, color: Color) -> void:
	_barra.draw_string_outline(fuente, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, 4, Color(0.08, 0.04, 0.06))
	_barra.draw_string(fuente, pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


## Cartel épico en cola: título grande, nombre de la travesura y la recompensa.
## "abajo": si Felipe está arriba (repisa, alféizar), el cartel va más abajo para no taparlo.
func cartel(titulo: String, nombre: String, recompensa: String, secreta: bool, abajo := false) -> void:
	carteles.append([titulo, nombre])
	_cola.append([titulo, nombre, recompensa, secreta, abajo])
	if not _mostrando:
		# Medio segundo de espera: primero se ve el gag (el vaso en la cara), después el cartel.
		_mostrando = true
		create_tween().tween_callback(_siguiente_cartel).set_delay(retraso_cartel)


func ocupado() -> bool:
	return _mostrando


func _siguiente_cartel() -> void:
	if _cola.is_empty():
		_mostrando = false
		return
	_mostrando = true
	var datos: Array = _cola.pop_front()
	var secreta: bool = datos[3]
	var color := Color(1.0, 0.45, 0.85) if secreta else Color(1.0, 0.85, 0.25)
	var caja := Control.new()
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.size = Vector2(640, 96)
	caja.position = Vector2(0, 168 if datos[4] else 52)
	caja.pivot_offset = Vector2(320, 48)
	add_child(caja)
	# Franja de fondo inclinada (como la presentación de un jefe, en chico).
	var franja := Polygon2D.new()
	franja.polygon = PackedVector2Array([Vector2(0, 12), Vector2(640, 0), Vector2(640, 84), Vector2(0, 96)])
	franja.color = Color(0.12, 0.05, 0.12, 0.88)
	caja.add_child(franja)
	var borde := Line2D.new()
	borde.points = PackedVector2Array([Vector2(0, 12), Vector2(640, 0)])
	borde.width = 3.0
	borde.default_color = color
	caja.add_child(borde)
	var borde2 := Line2D.new()
	borde2.points = PackedVector2Array([Vector2(0, 96), Vector2(640, 84)])
	borde2.width = 3.0
	borde2.default_color = color
	caja.add_child(borde2)
	caja.add_child(_etiqueta(datos[0], 26, color, Vector2(0, 12)))
	caja.add_child(_etiqueta(String(datos[1]).to_upper(), 15, Color.WHITE, Vector2(0, 46)))
	caja.add_child(_etiqueta("RECOMPENSA: " + String(datos[2]).to_upper(), 12, Color(0.6, 1.0, 0.6), Vector2(0, 68)))
	if _sonidos:
		_sonidos.sonar("perdon", 1.25 if secreta else 1.0)
	caja.scale = Vector2(1.6, 0.1)
	caja.modulate.a = 0.0
	var animar := create_tween()
	animar.tween_property(caja, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animar.parallel().tween_property(caja, "modulate:a", 1.0, 0.1)
	animar.tween_interval(2.0)
	animar.tween_property(caja, "position:x", -660.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	animar.tween_callback(caja.queue_free)
	animar.tween_callback(_siguiente_cartel)


func _etiqueta(texto: String, tamano: int, color: Color, pos: Vector2) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.position = pos
	etiqueta.size = Vector2(640, tamano + 8)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0.08, 0.03, 0.06))
	etiqueta.add_theme_constant_override("outline_size", 6)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return etiqueta
