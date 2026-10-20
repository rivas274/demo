class_name Recogible
extends Node2D
## Recompensa que sale de una travesura y Felipe recoge al pasar por encima: calcetín, snack o foto vergonzosa.
## Sale disparada (la foto cae flotando), se apoya en lo primero que pisa (piso o mueble, por física) y brilla
## hasta que la recogen. La posición es la base del objeto. Todo mide 24 px o más (escala de gato).
## Al recogerla se avisa con `recogido`; quien la creó la entrega a Recompensas.

signal recogido(objeto: Recogible)

## Capas que la detienen: piso y muebles (1) y muebles que se atraviesan desde abajo (Felipe.CAPA_ATRAVESABLE).
const CAPAS_SUELO := 1 | 2

@export var tipo := "calcetin"
@export var gravedad := 900.0
## Distancia (horizontal, vertical) a la que Felipe la recoge.
@export var alcance := Vector2(26, 46)

## Contorno que late: el ícono multiplicado por un tinte fuerte (queda casi crema, como el resalte del Indicador).
const BRILLO := Color(6.0, 5.5, 3.6, 0.9)

var velocidad := Vector2.ZERO
var quieto := false
var _vida := 0.0
var _recogido := false


func _init(tipo_recompensa := "calcetin", impulso := Vector2.ZERO) -> void:
	tipo = tipo_recompensa
	velocidad = impulso
	name = "Recogible (%s)" % tipo


func _physics_process(delta: float) -> void:
	_vida += delta
	queue_redraw()
	if _recogido:
		return
	if not quieto:
		_caer(delta)
	var felipe := get_tree().get_first_node_in_group("felipe") as Node2D
	if felipe and _vida > 0.35:
		var d := felipe.global_position - global_position
		if absf(d.x) < alcance.x and d.y > -alcance.y * 0.3 and d.y < alcance.y:
			recoger()


func _caer(delta: float) -> void:
	if tipo == "foto":
		# Papel: cae despacio y se mece.
		velocidad.y = minf(velocidad.y + gravedad * 0.25 * delta, 70.0)
		velocidad.x = lerpf(velocidad.x, sin(_vida * 5.0) * 60.0, delta * 3.0)
		rotation = sin(_vida * 5.0) * 0.35
	else:
		velocidad.y += gravedad * delta
		rotation += velocidad.x * 0.02 * delta
	var paso := velocidad * delta
	if velocidad.y > 0.0 and is_inside_tree():
		var consulta := PhysicsRayQueryParameters2D.create(global_position, global_position + paso + Vector2(0, 1), CAPAS_SUELO)
		var choque := get_world_2d().direct_space_state.intersect_ray(consulta)
		if not choque.is_empty() and (choque["normal"] as Vector2).y < -0.5:
			global_position = choque["position"]
			quieto = true
			velocidad = Vector2.ZERO
			rotation = 0.0
			return
	global_position += paso


func recoger() -> void:
	if _recogido:
		return
	_recogido = true
	recogido.emit(self)
	var irse := create_tween()
	irse.tween_property(self, "position:y", position.y - 30.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	irse.parallel().tween_property(self, "scale", Vector2.ONE * 1.4, 0.25)
	irse.tween_property(self, "modulate:a", 0.0, 0.15)
	irse.tween_callback(queue_free)


func _draw() -> void:
	# Se lee como "esto se recoge": un contorno de 1 px que late (escalones de pixel, sin halo suave: G5 y lección 26).
	var centro := Vector2(0, -Recogible.tamano_icono(tipo).y / 2.0)
	if not _recogido and sin(_vida * 6.0) > -0.2:
		for lado: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			Recogible.dibujar_icono(self, tipo, centro + lado, 1.0, BRILLO)
	# Se apoya por su borde de abajo (ningún margen transparente: M1).
	Recogible.dibujar_icono(self, tipo, centro, 1.0)


## Tamaño del dibujo de cada recompensa (lado menor ≥ 24 px, R8): calcetín y bolsita de premios de Gemini.
static func tamano_icono(que: String) -> Vector2:
	match que:
		"calcetin":
			var arte := ArteNivel.textura("calcetin")
			return arte.get_size() if arte else Vector2(25, 26)
		"snack":
			var bolsa := ArteNivel.textura("bolsita")
			return bolsa.get_size() if bolsa else Vector2(28, 32)
	return Vector2(30, 26)


## Dibuja el ícono centrado en `centro` (lo usan también el HUD y el resumen, a otra escala).
## Con `tinte`, la silueta pintada de ese color (el contorno que late).
static func dibujar_icono(lienzo: CanvasItem, que: String, centro: Vector2, escala: float, tinte := Color.WHITE) -> void:
	var e := escala
	var silueta := tinte != Color.WHITE
	match que:
		"calcetin":
			var arte := ArteNivel.textura("calcetin")
			if arte:
				var tam := arte.get_size() * e
				lienzo.draw_texture_rect(arte, Rect2((centro - tam / 2.0).round(), tam), false, tinte)
				return
			if silueta:
				return
			var blanco := Color(0.95, 0.95, 0.92)
			var raya := Color(0.85, 0.25, 0.3)
			lienzo.draw_rect(Rect2(centro + Vector2(-10, -14) * e, Vector2(16, 26) * e), Color(0.3, 0.2, 0.2))
			lienzo.draw_rect(Rect2(centro + Vector2(-10, 2) * e, Vector2(25, 10) * e), Color(0.3, 0.2, 0.2))
			lienzo.draw_rect(Rect2(centro + Vector2(-9, -13) * e, Vector2(14, 24) * e), blanco)
			lienzo.draw_rect(Rect2(centro + Vector2(-9, 3) * e, Vector2(23, 8) * e), blanco)
			for i in 3:
				lienzo.draw_rect(Rect2(centro + Vector2(-9, -11 + i * 5) * e, Vector2(14, 2) * e), raya)
		"snack":
			# Bolsita de premios (Gemini, tanda 3A); si falta, un pescado dibujado.
			var bolsa := ArteNivel.textura("bolsita")
			if bolsa:
				var tam_bolsa := bolsa.get_size() * e
				lienzo.draw_texture_rect(bolsa, Rect2((centro - tam_bolsa / 2.0).round(), tam_bolsa), false, tinte)
				return
			if silueta:
				return
			var c := centro
			var cuerpo := PackedVector2Array([c + Vector2(-14, 0) * e, c + Vector2(-4, -7) * e, c + Vector2(8, -5) * e, c + Vector2(14, 0) * e, c + Vector2(8, 6) * e, c + Vector2(-4, 7) * e])
			lienzo.draw_colored_polygon(cuerpo, Color(1.0, 0.55, 0.35))
			lienzo.draw_colored_polygon(PackedVector2Array([c + Vector2(13, 0) * e, c + Vector2(19, -7) * e, c + Vector2(19, 7) * e]), Color(0.95, 0.45, 0.3))
			lienzo.draw_circle(c + Vector2(-8, -1) * e, 1.6 * e, Color(0.1, 0.1, 0.1))
		"foto":
			# Foto vergonzosa de Valeria (pijama de unicornio), 30 x 26 px.
			if silueta:
				lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), tinte)
				return
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.98, 0.97, 0.93))
			lienzo.draw_rect(Rect2(centro + Vector2(-12, -10) * e, Vector2(24, 17) * e), Color(0.6, 0.75, 0.95))
			lienzo.draw_rect(Rect2(centro + Vector2(-6, -2) * e, Vector2(12, 9) * e), Color(0.98, 0.6, 0.8))
			lienzo.draw_circle(centro + Vector2(0, -5) * e, 4.0 * e, Color("d9a27c"))
			lienzo.draw_colored_polygon(PackedVector2Array([centro + Vector2(-2, -8) * e, centro + Vector2(2, -8) * e, centro + Vector2(0, -14) * e]), Color(1.0, 0.85, 0.3))
			lienzo.draw_rect(Rect2(centro + Vector2(-15, -13) * e, Vector2(30, 26) * e), Color(0.4, 0.35, 0.3), false, 1.0)
