# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Recogible
extends Node2D
## Recompensa que Felipe recoge al pasar por encima: calcetín, snack o foto vergonzosa.
## Sale disparada (o cae flotando, la foto), se apoya en una superficie y brilla hasta que la recoge.
## La posición es la base del objeto. Todo mide al menos 24 px (escala de gato).

signal recogido(objeto: Recogible)

@export var tipo := "calcetin"
@export var gravedad := 900.0
## Distancia (horizontal, vertical) a la que Felipe lo recoge.
@export var alcance := Vector2(26, 46)

var velocidad := Vector2.ZERO
var superficies: Array = []
var felipe: Node2D
var quieto := false
## Foto: 0 = Valeria en pijama de unicornio (florero); 1 = Valeria arañando el rascador (rascador).
var variante := 0
var _vida := 0.0
var _recogido := false


func _physics_process(delta: float) -> void:
	_vida += delta
	queue_redraw()
	if _recogido:
		return
	if not quieto:
		var antes := position
		if tipo == "foto":
			# Papel: cae despacio y se mece.
			velocidad.y = minf(velocidad.y + gravedad * 0.25 * delta, 70.0)
			velocidad.x = lerpf(velocidad.x, sin(_vida * 5.0) * 60.0, delta * 3.0)
			rotation = sin(_vida * 5.0) * 0.35
		else:
			velocidad.y += gravedad * delta
			rotation += velocidad.x * 0.02 * delta
		position += velocidad * delta
		position.x = clampf(position.x, 16.0, 624.0)
		if velocidad.y > 0.0:
			for s: Array in superficies:
				if position.x >= s[0] and position.x <= s[1] and antes.y <= s[2] and position.y >= s[2]:
					position.y = s[2]
					quieto = true
					velocidad = Vector2.ZERO
					rotation = 0.0
					break
	if felipe and _vida > 0.35:
		var d := felipe.global_position - global_position
		if absf(d.x) < alcance.x and d.y > -alcance.y * 0.3 and d.y < alcance.y:
			_recoger()


func _recoger() -> void:
	_recogido = true
	recogido.emit(self)
	var irse := create_tween()
	irse.tween_property(self, "position:y", position.y - 30.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	irse.parallel().tween_property(self, "scale", Vector2.ONE * 1.4, 0.25)
	irse.tween_property(self, "modulate:a", 0.0, 0.15)
	irse.tween_callback(queue_free)


func _draw() -> void:
	# Brillo para que se lea como "esto se recoge".
	if not _recogido:
		var brillo := 0.35 + 0.25 * sin(_vida * 6.0)
		draw_circle(Vector2(0, -12), 18.0, Color(1.0, 0.95, 0.6, brillo * 0.35))
	Recogible.dibujar_icono(self, "foto_rascador" if tipo == "foto" and variante == 1 else tipo, Vector2(0, -12), 1.0)


## Dibuja el ícono centrado en "centro" (lo usa también el HUD, a otra escala).
static func dibujar_icono(lienzo: CanvasItem, que: String, centro: Vector2, escala: float) -> void:
	var e := escala
	match que:
		"calcetin":
			# Calcetín a rayas, 24 x 26 px.
			var blanco := Color(0.95, 0.95, 0.92)
			var raya := Color(0.85, 0.25, 0.3)
			lienzo.draw_rect(Rect2(centro + Vector2(-10, -14) * e, Vector2(16, 26) * e), Color(0.3, 0.2, 0.2))
			lienzo.draw_rect(Rect2(centro + Vector2(-10, 2) * e, Vector2(25, 10) * e), Color(0.3, 0.2, 0.2))
			lienzo.draw_rect(Rect2(centro + Vector2(-9, -13) * e, Vector2(14, 24) * e), blanco)
			lienzo.draw_rect(Rect2(centro + Vector2(-9, 3) * e, Vector2(23, 8) * e), blanco)
			for i in 3:
				lienzo.draw_rect(Rect2(centro + Vector2(-9, -11 + i * 5) * e, Vector2(14, 2) * e), raya)
			lienzo.draw_rect(Rect2(centro + Vector2(9, 3) * e, Vector2(5, 8) * e), raya)
		"snack":
			# Snack de pescado, 32 x 16 px.
			var c := centro
			var cuerpo := PackedVector2Array([c + Vector2(-14, 0) * e, c + Vector2(-4, -7) * e, c + Vector2(8, -5) * e, c + Vector2(14, 0) * e, c + Vector2(8, 6) * e, c + Vector2(-4, 7) * e])
			lienzo.draw_colored_polygon(cuerpo, Color(1.0, 0.55, 0.35))
			lienzo.draw_colored_polygon(PackedVector2Array([c + Vector2(13, 0) * e, c + Vector2(19, -7) * e, c + Vector2(19, 7) * e]), Color(0.95, 0.45, 0.3))
			lienzo.draw_circle(c + Vector2(-8, -1) * e, 1.6 * e, Color(0.1, 0.1, 0.1))
		"foto":
			# Foto de Valeria en pijama de unicornio, 30 x 26 px.
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.98, 0.97, 0.93))
			lienzo.draw_rect(Rect2(centro + Vector2(-12, -10) * e, Vector2(24, 17) * e), Color(0.6, 0.75, 0.95))
			# Pijama rosado, cara y cuerno.
			lienzo.draw_rect(Rect2(centro + Vector2(-6, -2) * e, Vector2(12, 9) * e), Color(0.98, 0.6, 0.8))
			lienzo.draw_circle(centro + Vector2(0, -5) * e, 4.0 * e, Color(0.93, 0.76, 0.62))
			lienzo.draw_colored_polygon(PackedVector2Array([centro + Vector2(-2, -8) * e, centro + Vector2(2, -8) * e, centro + Vector2(0, -14) * e]), Color(1.0, 0.85, 0.3))
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.4, 0.35, 0.3), false, 1.0)
		"foto_rascador":
			# Foto de Valeria de rodillas arañando el rascador "para enseñarle", 30 x 26 px.
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.98, 0.97, 0.93))
			lienzo.draw_rect(Rect2(centro + Vector2(-12, -10) * e, Vector2(24, 17) * e), Color(0.9, 0.85, 0.7))
			lienzo.draw_rect(Rect2(centro + Vector2(4, -10) * e, Vector2(4, 17) * e), Color(0.78, 0.64, 0.4))
			lienzo.draw_rect(Rect2(centro + Vector2(-8, -1) * e, Vector2(10, 8) * e), Color(0.35, 0.55, 0.62))
			lienzo.draw_circle(centro + Vector2(-4, -5) * e, 4.0 * e, Color(0.93, 0.76, 0.62))
			lienzo.draw_line(centro + Vector2(0, -2) * e, centro + Vector2(4, -4) * e, Color(0.93, 0.76, 0.62), 2.0 * e)
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.4, 0.35, 0.3), false, 1.0)
