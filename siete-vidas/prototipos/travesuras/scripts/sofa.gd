# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Sofa
extends Node2D
## Sofá arañable (45 cm de asiento a 1,21 px/cm). Cada arañazo deja tres rayas que se quedan
## y suelta pelusa. La colisión la pone la sala con los mismos rectángulos.

signal aranado(sofa: Sofa, punto: Vector2)

## Rectángulos en coordenadas de la sala (el nodo está en 0,0).
const RESPALDO := Rect2(20, 193, 190, 50)
const ASIENTO := Rect2(44, 242, 142, 20)
const BASE := Rect2(20, 262, 190, 30)
const BRAZO_IZQUIERDO := Rect2(20, 223, 26, 69)
const BRAZO_DERECHO := Rect2(184, 223, 26, 69)
const MAXIMO_MARCAS := 40

var prioridad := 60.0
var marcas: Array[Vector2] = []
var _pelusa: CPUParticles2D


func _ready() -> void:
	add_to_group("interactuables")
	_pelusa = CPUParticles2D.new()
	_pelusa.emitting = false
	_pelusa.one_shot = true
	_pelusa.amount = 16
	_pelusa.lifetime = 1.1
	_pelusa.explosiveness = 0.9
	_pelusa.direction = Vector2(0, -1)
	_pelusa.spread = 70.0
	_pelusa.gravity = Vector2(0, 60)
	_pelusa.initial_velocity_min = 30.0
	_pelusa.initial_velocity_max = 90.0
	_pelusa.damping_min = 40.0
	_pelusa.damping_max = 60.0
	_pelusa.scale_amount_min = 2.0
	_pelusa.scale_amount_max = 4.0
	_pelusa.color = Color(0.95, 0.88, 0.72)
	add_child(_pelusa)


func accion_disponible() -> String:
	return "arañar"


## El punto del sofá más cercano a Felipe (de pie en el piso araña el brazo; sobre el asiento, el respaldo).
func punto_para(desde: Vector2) -> Vector2:
	return Vector2(clampf(desde.x, 24.0, 206.0), clampf(desde.y, 223.0, 296.0))


func al_impacto(felipe: Node2D) -> void:
	var lado := float(felipe.get("mirando"))
	var pata: Vector2 = felipe.global_position + Vector2(lado * 20.0, -24.0)
	var zona := RESPALDO.merge(BASE).merge(BRAZO_DERECHO)
	var punto := Vector2(clampf(pata.x, zona.position.x + 6, zona.end.x - 6), clampf(pata.y, zona.position.y + 8, zona.end.y - 12))
	punto += Vector2(randf_range(-4, 4), randf_range(-4, 4))
	marcas.append(punto)
	if marcas.size() > MAXIMO_MARCAS:
		marcas.pop_front()
	_pelusa.position = punto
	_pelusa.restart()
	_pelusa.emitting = true
	queue_redraw()
	aranado.emit(self, punto)


func _draw() -> void:
	var tela := Color(0.58, 0.32, 0.3)
	var oscuro := tela.darkened(0.25)
	draw_rect(RESPALDO, oscuro)
	draw_rect(Rect2(RESPALDO.position + Vector2(30, 6), Vector2(62, 40)), tela)
	draw_rect(Rect2(RESPALDO.position + Vector2(98, 6), Vector2(62, 40)), tela)
	draw_rect(BASE, oscuro)
	draw_rect(ASIENTO, tela.lightened(0.08))
	draw_line(Vector2(115, 242), Vector2(115, 262), oscuro, 2.0)
	for brazo: Rect2 in [BRAZO_IZQUIERDO, BRAZO_DERECHO]:
		draw_rect(brazo, tela)
		draw_rect(Rect2(brazo.position, Vector2(brazo.size.x, 6)), tela.lightened(0.15))
	draw_rect(Rect2(28, 292, 8, 4), Color(0.25, 0.17, 0.12))
	draw_rect(Rect2(194, 292, 8, 4), Color(0.25, 0.17, 0.12))
	# Arañazos que se quedan: tres rayas claras con hilos sueltos.
	for marca in marcas:
		for i in 3:
			var x := marca.x - 5.0 + i * 5.0
			draw_line(Vector2(x - 3, marca.y - 9), Vector2(x + 3, marca.y + 9), Color(0.95, 0.85, 0.7), 2.0)
			draw_line(Vector2(x + 3, marca.y + 9), Vector2(x + 4, marca.y + 12), Color(0.95, 0.85, 0.7, 0.7), 1.0)
