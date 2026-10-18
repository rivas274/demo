class_name Medidores
extends Control
## Interfaz con estilo de red social: corazones ("me gusta") de vida, vidas restantes, peso en kilos
## y notificaciones de logros. Arte provisional dibujado con código.

const ROJO := Color("e0483b")
const VACIO := Color(0.25, 0.18, 0.18, 0.55)
const TEXTO := Color("2b2421")
const FONDO := Color(1, 0.98, 0.95, 0.85)

var felipe: Felipe
var _notificacion := ""
var _tiempo_notificacion := 0.0


func _ready() -> void:
	name = "Medidores"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func mostrar_logro(titulo: String) -> void:
	_notificacion = titulo
	_tiempo_notificacion = 3.5


func _process(delta: float) -> void:
	_tiempo_notificacion = maxf(0.0, _tiempo_notificacion - delta)
	queue_redraw()


func _draw() -> void:
	if not felipe:
		return
	var fuente := ThemeDB.fallback_font
	draw_rect(Rect2(6, 6, 200, 34), FONDO)
	for i in Felipe.CORAZONES_MAX:
		_corazon(Vector2(16 + i * 16, 16), ROJO if i < felipe.corazones else VACIO)
	draw_string(fuente, Vector2(12, 36), "%d vidas" % felipe.vidas, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXTO)
	draw_string(fuente, Vector2(64, 36), ("Báscula: %.1f kg" % felipe.peso).replace(".", ","), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, TEXTO)
	if felipe.tiene_collar:
		draw_string(fuente, Vector2(100, 20), "Collar de la Vergüenza", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, ROJO)
	if _tiempo_notificacion > 0.0:
		var caja := Rect2(get_viewport_rect().size.x - 216, 8, 208, 34)
		draw_rect(caja, FONDO)
		draw_rect(caja, ROJO, false, 1.0)
		draw_string(fuente, caja.position + Vector2(8, 13), "Nuevo logro desbloqueado", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("6f625b"))
		draw_string(fuente, caja.position + Vector2(8, 27), _notificacion, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, TEXTO)


func _corazon(centro: Vector2, color: Color) -> void:
	draw_circle(centro + Vector2(-3, -2), 3.5, color)
	draw_circle(centro + Vector2(3, -2), 3.5, color)
	draw_colored_polygon(PackedVector2Array([centro + Vector2(-6.5, -1), centro + Vector2(6.5, -1), centro + Vector2(0, 7)]), color)
