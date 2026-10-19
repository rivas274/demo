# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-19
class_name Rascador
extends Node2D
## "Teatro para Valeria": un rascador nuevo y caro junto al sofá (poste con cuerda, base y plataforma,
## unos 75 cm a 1,21 px/cm = 90 px), con la etiqueta del precio colgando. Sin colisión: es decorado
## que se araña con la acción (E) desde el piso, mirándolo. La sala decide si hubo público.

## Felipe lo araña (cada golpe de pata en el cuadro de impacto). "primero" = primer golpe de la pulsación.
signal aranado(rascador: Rascador, punto: Vector2, primero: bool)

## Centro del poste (coordenadas de la sala; el nodo está en 0,0).
const X := 232.0
const SUELO := 296.0
const BASE := Rect2(214, 288, 36, 8)
const POSTE := Rect2(226, 206, 12, 82)
const PLATAFORMA := Rect2(212, 198, 40, 8)
## Parte del sofá "justo al lado del rascador": marcas desde esta x (el brazo derecho).
const ZONA_SOFA_X := 176.0

## Más bajo que el sofá (60): si Felipe mira el rascador, gana el rascador.
var prioridad := 40.0
var felipe: Node2D
## Hilos sueltos que deja cada arañazo en la cuerda.
var hilos: Array[Vector2] = []
var _sacudida := 0.0
var _fibras: CPUParticles2D


func _ready() -> void:
	add_to_group("interactuables")
	_fibras = CPUParticles2D.new()
	_fibras.emitting = false
	_fibras.one_shot = true
	_fibras.amount = 12
	_fibras.lifetime = 0.9
	_fibras.explosiveness = 0.9
	_fibras.direction = Vector2(0, -1)
	_fibras.spread = 80.0
	_fibras.gravity = Vector2(0, 160)
	_fibras.initial_velocity_min = 40.0
	_fibras.initial_velocity_max = 100.0
	_fibras.scale_amount_min = 1.5
	_fibras.scale_amount_max = 3.0
	_fibras.color = Color(0.85, 0.72, 0.45)
	add_child(_fibras)


func accion_disponible() -> String:
	return "afilar"


## Solo desde el piso y mirándolo (pegado al brazo del sofá y mirando al sofá, gana el sofá).
func punto_para(desde: Vector2) -> Vector2:
	var lejos := Vector2(99999, 99999)
	if desde.y < SUELO - 10.0 or felipe == null:
		return lejos
	var dx := X - desde.x
	if absf(dx) >= 2.0 and signf(dx) != float(felipe.get("mirando")):
		return lejos
	return Vector2(X, clampf(desde.y - 24.0, POSTE.position.y, POSTE.end.y))


func al_impacto(quien: Node2D) -> void:
	var lado := float(quien.get("mirando"))
	var punto := Vector2(X - lado * 4.0, clampf(quien.global_position.y - 26.0, POSTE.position.y + 6, POSTE.end.y - 6))
	punto += Vector2(randf_range(-2, 2), randf_range(-5, 5))
	hilos.append(punto)
	if hilos.size() > 24:
		hilos.pop_front()
	_fibras.position = punto
	_fibras.restart()
	_fibras.emitting = true
	_sacudida = 0.25
	aranado.emit(self, punto, int(quien.get("golpe_en_accion")) == 0)


func _process(delta: float) -> void:
	if _sacudida > 0.0:
		_sacudida = maxf(0.0, _sacudida - delta)
		queue_redraw()


func _draw() -> void:
	# Bamboleo de un píxel al arañarlo (entero, sin emborronar).
	var b := Vector2(1 if _sacudida > 0.0 and int(_sacudida * 40.0) % 2 == 0 else 0, 0)
	var felpa := Color(0.82, 0.8, 0.86)
	var cuerda := Color(0.78, 0.64, 0.4)
	# Base y plataforma de felpa (gris lila, se ve nuevo).
	draw_rect(BASE, felpa.darkened(0.15))
	draw_rect(Rect2(BASE.position, Vector2(BASE.size.x, 2)), felpa)
	# Poste con cuerda enrollada.
	draw_rect(Rect2(POSTE.position + b, POSTE.size), cuerda)
	var y := POSTE.position.y + 2.0
	while y < POSTE.end.y:
		draw_line(Vector2(POSTE.position.x, y) + b, Vector2(POSTE.end.x, y + 2.0) + b, cuerda.darkened(0.25), 1.0)
		y += 4.0
	for h in hilos:
		draw_line(h + b, h + b + Vector2(-5, 4), Color(0.95, 0.85, 0.6), 1.0)
		draw_line(h + b, h + b + Vector2(4, 5), Color(0.95, 0.85, 0.6), 1.0)
	draw_rect(Rect2(PLATAFORMA.position + b, PLATAFORMA.size), felpa.darkened(0.1))
	draw_rect(Rect2(PLATAFORMA.position + b, Vector2(PLATAFORMA.size.x, 2)), felpa)
	# Pompón de juguete colgando a la izquierda.
	draw_line(Vector2(216, 206) + b, Vector2(216, 222) + b, Color(0.3, 0.3, 0.3), 1.0)
	draw_circle(Vector2(216, 225) + b, 3.5, Color(0.95, 0.4, 0.5))
	# Etiqueta del precio colgando de la plataforma (todavía no la sacan: es nuevo y caro).
	draw_line(Vector2(248, 206) + b, Vector2(250, 214) + b, Color(0.9, 0.9, 0.9), 1.0)
	var etiqueta := Rect2(Vector2(238, 214) + b, Vector2(36, 13))
	draw_rect(etiqueta, Color(1.0, 0.98, 0.9))
	draw_rect(etiqueta, Color(0.6, 0.15, 0.15), false, 1.0)
	draw_string(ThemeDB.fallback_font, etiqueta.position + Vector2(2, 10), "$89.990", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.1, 0.1))
