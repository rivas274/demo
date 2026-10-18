# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Plato
extends Node2D
## Plato de comida (croquetas, al doble de su tamaño real) o snack que deja Valeria.
## La comida baja en el cuadro en que la lengua llega (cuadro 3 de "comer"), no al apretar.

signal comido(plato: Plato)

@export var porciones_max := 3
@export var es_snack := false

var porciones := 3
var prioridad := 0.0
var _migas: CPUParticles2D


func _ready() -> void:
	add_to_group("interactuables")
	porciones = 1 if es_snack else porciones_max
	_migas = CPUParticles2D.new()
	_migas.emitting = false
	_migas.one_shot = true
	_migas.amount = 10
	_migas.lifetime = 0.5
	_migas.explosiveness = 1.0
	_migas.direction = Vector2(0, -1)
	_migas.spread = 60.0
	_migas.gravity = Vector2(0, 500)
	_migas.initial_velocity_min = 50.0
	_migas.initial_velocity_max = 110.0
	_migas.scale_amount_min = 2.0
	_migas.scale_amount_max = 3.0
	_migas.color = Color(0.72, 0.45, 0.22) if not es_snack else Color(1.0, 0.6, 0.4)
	_migas.position = Vector2(0, -10)
	add_child(_migas)


func accion_disponible() -> String:
	return "comer" if porciones > 0 else ""


func punto_para(_desde: Vector2) -> Vector2:
	return global_position


func al_impacto(_felipe: Node2D) -> void:
	porciones -= 1
	_migas.restart()
	_migas.emitting = true
	queue_redraw()
	comido.emit(self)
	if es_snack and porciones <= 0:
		var irse := create_tween()
		irse.tween_property(self, "modulate:a", 0.0, 0.2)
		irse.tween_callback(queue_free)


func rellenar() -> void:
	porciones = porciones_max
	queue_redraw()


func _draw() -> void:
	if es_snack:
		# Snack de pescado, 30 x 16 px.
		var cuerpo := PackedVector2Array([Vector2(-14, -8), Vector2(-4, -15), Vector2(8, -13), Vector2(14, -8), Vector2(8, -2), Vector2(-4, -1)])
		draw_colored_polygon(cuerpo, Color(1.0, 0.55, 0.35))
		draw_colored_polygon(PackedVector2Array([Vector2(14, -8), Vector2(20, -15), Vector2(20, -1)]), Color(0.95, 0.45, 0.3))
		draw_circle(Vector2(-8, -9), 1.5, Color(0.1, 0.1, 0.1))
		draw_polyline(cuerpo + PackedVector2Array([cuerpo[0]]), Color(0.6, 0.25, 0.15), 1.0)
		return
	# Plato de 52 px de ancho con montaña de croquetas que baja con cada bocado.
	var comida := float(porciones) / float(porciones_max)
	if comida > 0.0:
		var alto := 4.0 + 10.0 * comida
		draw_colored_polygon(PackedVector2Array([Vector2(-17, -6), Vector2(-10, -6 - alto), Vector2(10, -6 - alto), Vector2(17, -6)]), Color(0.65, 0.38, 0.18))
		for i in int(8 * comida) + 2:
			draw_circle(Vector2(-12 + (i * 7) % 24, -8 - (i * 5) % int(alto)), 2.5, Color(0.78, 0.5, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-26, -9), Vector2(26, -9), Vector2(20, 0), Vector2(-20, 0)]), Color(0.85, 0.3, 0.3))
	draw_line(Vector2(-26, -9), Vector2(26, -9), Color(0.98, 0.6, 0.55), 2.0)
	draw_circle(Vector2(0, -4), 2.5, Color(1, 0.85, 0.8))
