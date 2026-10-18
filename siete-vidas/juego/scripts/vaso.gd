class_name Vaso
extends Node2D
## Vaso de agua sobre un mueble. Con el botón de acción, Felipe lo tira de un manotazo: cae, se rompe
## y da el logro "La Gravedad Funciona". Medidas reales: 12 cm de alto (15 px). Arte provisional.

const LOGRO := "La Gravedad Funciona"

var roto := false
var _velocidad := Vector2.ZERO
var _cayendo := false
var _piso: float


func _init(y_piso: float) -> void:
	_piso = y_piso
	name = "Vaso"


func _ready() -> void:
	add_to_group(Comida.GRUPO)


func interactuar(felipe: Felipe) -> void:
	remove_from_group(Comida.GRUPO)
	felipe.dar_manotazo()
	_velocidad = Vector2(felipe.mirando * 90.0, -90.0)
	_cayendo = true


func _physics_process(delta: float) -> void:
	if not _cayendo:
		return
	_velocidad.y += 900.0 * delta
	position += _velocidad * delta
	rotation += _velocidad.x * 0.04 * delta
	if position.y >= _piso:
		position.y = _piso
		rotation = 0.0
		_cayendo = false
		roto = true
		queue_redraw()
		var sala := get_parent()
		if sala.has_method("desbloquear_logro"):
			sala.desbloquear_logro(LOGRO)


func _draw() -> void:
	if roto:
		for trozo: Vector2 in [Vector2(-9, -2), Vector2(-3, -3), Vector2(4, -2), Vector2(9, -1)]:
			draw_colored_polygon(PackedVector2Array([trozo, trozo + Vector2(3, -2), trozo + Vector2(4, 1)]), Color(0.85, 0.93, 1.0, 0.8))
		draw_rect(Rect2(-12, -1, 24, 1), Color(0.6, 0.8, 1.0, 0.6))
		return
	draw_rect(Rect2(-5, -15, 10, 15), Color(0.85, 0.93, 1.0, 0.45))
	draw_rect(Rect2(-4, -9, 8, 8), Color(0.45, 0.7, 0.95, 0.6))
	draw_rect(Rect2(-5, -15, 10, 15), Color(0.9, 0.95, 1.0, 0.9), false, 1.0)
