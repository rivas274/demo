# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Tirable
extends Node2D
## Algo que Felipe tira de un manotazo: vaso, florero o control remoto (dibujados por código).
## Sale volando en el cuadro de impacto de la pata, cae con física simple, rebota y, si es frágil, se rompe.
## La posición es la base del objeto (donde se apoya).

signal golpeado(objeto: Tirable)
signal roto(objeto: Tirable)
signal aterrizo(objeto: Tirable, fuerza: float)

enum Estado { EN_SITIO, VOLANDO, QUIETO, ROTO }

@export var tipo := "vaso"
@export var fragil := true
## Empujón de la pata (px/s): hacia donde mira Felipe y hacia arriba.
@export var empujon := Vector2(150, -170)
@export var gravedad := 900.0
## Velocidad de caída desde la que un objeto frágil se rompe.
@export var velocidad_rotura := 200.0
@export var rebote := 0.45

var estado := Estado.EN_SITIO
var velocidad := Vector2.ZERO
var giro := 0.0
var prioridad := 0.0
## Superficies donde puede caer: [x inicial, x final, y].
var superficies: Array = []
var origen: Vector2
var _pedazos: Array = []
var _chispas: CPUParticles2D


func _ready() -> void:
	add_to_group("interactuables")
	origen = position
	_chispas = CPUParticles2D.new()
	_chispas.emitting = false
	_chispas.one_shot = true
	_chispas.amount = 28
	_chispas.lifetime = 0.7
	_chispas.explosiveness = 1.0
	_chispas.direction = Vector2(0, -1)
	_chispas.spread = 75.0
	_chispas.gravity = Vector2(0, 600)
	_chispas.initial_velocity_min = 90.0
	_chispas.initial_velocity_max = 220.0
	_chispas.scale_amount_min = 2.0
	_chispas.scale_amount_max = 4.0
	_chispas.color = _color_principal().lightened(0.3)
	_chispas.top_level = true
	add_child(_chispas)


func accion_disponible() -> String:
	return "tirar" if estado in [Estado.EN_SITIO, Estado.QUIETO] else ""


func punto_para(_desde: Vector2) -> Vector2:
	return global_position


## Cuadro de impacto de la pata: sale volando lejos de Felipe.
func al_impacto(felipe: Node2D) -> void:
	var lado := signf(global_position.x - felipe.global_position.x)
	if lado == 0.0:
		lado = float(felipe.get("mirando"))
	if estado == Estado.QUIETO:
		# Ya en el piso: patada que lo hace deslizar y girar.
		velocidad = Vector2(lado * 230.0, -110.0)
	else:
		velocidad = Vector2(lado * empujon.x, empujon.y)
	giro = lado * 9.0
	estado = Estado.VOLANDO
	golpeado.emit(self)


func _physics_process(delta: float) -> void:
	if estado != Estado.VOLANDO:
		return
	var antes := position
	velocidad.y += gravedad * delta
	position += velocidad * delta
	rotation += giro * delta
	if position.x < 12.0 or position.x > 628.0:
		position.x = clampf(position.x, 12.0, 628.0)
		velocidad.x *= -0.5
	if velocidad.y <= 0.0:
		return
	for superficie: Array in superficies:
		if position.x < superficie[0] or position.x > superficie[1]:
			continue
		if antes.y <= superficie[2] and position.y >= superficie[2]:
			position.y = superficie[2]
			_tocar_superficie()
			return


func _tocar_superficie() -> void:
	var fuerza := velocidad.y
	if fragil and fuerza >= velocidad_rotura:
		_romper()
		return
	aterrizo.emit(self, fuerza)
	if fuerza < 70.0:
		estado = Estado.QUIETO
		velocidad = Vector2.ZERO
		giro = 0.0
		# Queda acostado o de pie, nunca torcido.
		rotation = snappedf(rotation, PI)
		return
	velocidad = Vector2(velocidad.x * 0.6, -fuerza * rebote)
	giro *= 0.6


func _romper() -> void:
	estado = Estado.ROTO
	rotation = 0.0
	_chispas.global_position = global_position + Vector2(0, -6)
	_chispas.restart()
	_chispas.emitting = true
	# Pedazos que quedan en el piso.
	_pedazos.clear()
	for i in 6:
		_pedazos.append([Vector2(randf_range(-22, 22), 0), randf_range(3, 7), randf() * TAU])
	queue_redraw()
	roto.emit(self)


## Valeria lo vuelve a poner en su lugar.
func reponer() -> void:
	estado = Estado.EN_SITIO
	position = origen
	rotation = 0.0
	velocidad = Vector2.ZERO
	queue_redraw()


func necesita_reponer() -> bool:
	return position != origen or estado == Estado.ROTO


func _color_principal() -> Color:
	match tipo:
		"vaso":
			return Color(0.62, 0.84, 0.95)
		"florero":
			return Color(0.25, 0.42, 0.78)
	return Color(0.15, 0.15, 0.17)


func _draw() -> void:
	if estado == Estado.ROTO:
		for pedazo: Array in _pedazos:
			var p: Vector2 = pedazo[0]
			var t: float = pedazo[1]
			var puntos := PackedVector2Array([p + Vector2(-t, 0), p + Vector2(t, 0), p + Vector2(t * 0.3, -t).rotated(pedazo[2] * 0.2)])
			draw_colored_polygon(puntos, _color_principal())
		if tipo == "vaso":
			draw_rect(Rect2(-26, -2, 52, 3), Color(0.55, 0.75, 0.95, 0.6))
		return
	match tipo:
		"vaso":
			# Vaso al doble de su tamaño real (escala de gato): 24 x 30 px, con agua.
			var vidrio := PackedVector2Array([Vector2(-12, -30), Vector2(12, -30), Vector2(9, 0), Vector2(-9, 0)])
			draw_colored_polygon(vidrio, Color(0.75, 0.9, 1.0, 0.55))
			draw_colored_polygon(PackedVector2Array([Vector2(-11, -18), Vector2(11, -18), Vector2(9, 0), Vector2(-9, 0)]), Color(0.35, 0.65, 0.95, 0.75))
			draw_polyline(PackedVector2Array([Vector2(-12, -30), Vector2(-9, 0), Vector2(9, 0), Vector2(12, -30)]), Color(0.9, 0.97, 1.0), 2.0)
			draw_line(Vector2(-7, -26), Vector2(-5, -6), Color(1, 1, 1, 0.8), 2.0)
		"florero":
			# Florero 26 x 34 px con flores hasta 50 px.
			for i in 3:
				var tallo_x := -6.0 + i * 6.0
				var tope := Vector2(tallo_x * 1.8, -46.0 + absf(i - 1) * 6.0)
				draw_line(Vector2(tallo_x, -32), tope, Color(0.25, 0.55, 0.25), 2.0)
				draw_circle(tope, 5.0, [Color(0.95, 0.35, 0.4), Color(1.0, 0.85, 0.3), Color(0.95, 0.5, 0.8)][i])
				draw_circle(tope, 2.0, Color(1, 0.95, 0.7))
			var cuerpo := PackedVector2Array([Vector2(-6, -34), Vector2(6, -34), Vector2(7, -28), Vector2(13, -16), Vector2(11, 0), Vector2(-11, 0), Vector2(-13, -16), Vector2(-7, -28)])
			draw_colored_polygon(cuerpo, _color_principal())
			draw_polyline(cuerpo + PackedVector2Array([cuerpo[0]]), Color(0.12, 0.2, 0.4), 1.0)
			draw_line(Vector2(-12, -14), Vector2(12, -14), Color(0.95, 0.95, 1.0), 2.0)
			draw_line(Vector2(-11, -9), Vector2(11, -9), Color(0.95, 0.95, 1.0), 1.0)
		"control":
			# Control remoto 34 x 12 px, acostado.
			draw_rect(Rect2(-17, -12, 34, 12), _color_principal())
			draw_rect(Rect2(-17, -12, 34, 12), Color(0.4, 0.4, 0.45), false, 1.0)
			draw_rect(Rect2(-13, -9, 5, 5), Color(0.9, 0.2, 0.2))
			for i in 3:
				draw_rect(Rect2(-5 + i * 6, -9, 4, 3), Color(0.7, 0.7, 0.75))
				draw_rect(Rect2(-5 + i * 6, -5, 4, 3), Color(0.5, 0.7, 0.9))
