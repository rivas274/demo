class_name Vaso
extends Node2D
## Objeto que Felipe tira de un manotazo con el botón de acción: cae y, según el tipo,
## se rompe (vaso: logro "La Gravedad Funciona") o aturde al enemigo que esté debajo (rollo, maceta).
## Las macetas vuelven a su lugar mientras A.S.P.I. siga encendida, para no quedarse sin munición.
## Escala de gato: vaso, rollo y maceta al doble de su tamaño real.

## Se rompió en el piso (en la pelea deja una mancha que A.S.P.I. va a limpiar).
signal caido(posicion: Vector2)

const LOGRO := "La Gravedad Funciona"
## Segundos que queda aturdido el enemigo al que le cae encima.
const ATURDIR := 3.0
const RADIO_IMPACTO := 44.0

var tipo: String
var roto := false
var _velocidad := Vector2.ZERO
var _cayendo := false
var _piso: float
var _inicio: Vector2


func _init(y_piso: float, tipo_objeto: String = "vaso") -> void:
	_piso = y_piso
	tipo = tipo_objeto
	name = "Vaso" if tipo == "vaso" else tipo.capitalize()


func _ready() -> void:
	_inicio = position
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
		_al_caer()


func _al_caer() -> void:
	caido.emit(global_position)
	var sala := get_parent()
	if sala.has_method("sonar"):
		sala.sonar("vidrio" if tipo != "rollo" else "caja")
	if tipo == "vaso":
		if sala.has_method("desbloquear_logro"):
			sala.desbloquear_logro(LOGRO)
		return
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if enemigo.has_method("aturdir") and absf(enemigo.global_position.x - global_position.x) < RADIO_IMPACTO and absf(enemigo.global_position.y - global_position.y) < 20.0:
			enemigo.aturdir(ATURDIR)
	if tipo == "maceta":
		await get_tree().create_timer(4.0).timeout
		var jefa_encendida := get_tree().get_nodes_in_group("enemigos").any(func(e: Node) -> bool: return e is Aspi and e.necesita_aturdir and not e.apagada)
		if jefa_encendida:
			position = _inicio
			roto = false
			add_to_group(Comida.GRUPO)
			queue_redraw()


func _draw() -> void:
	if not roto and ArteNivel.dibujar(self, tipo, 0.0, 0.0):
		return
	match tipo:
		"rollo":
			draw_rect(Rect2(-6, -10, 12, 10), Color("f3efe8"))
			draw_circle(Vector2(0, -5), 2.0, Color("cfc6bb"))
		"maceta":
			if roto:
				draw_rect(Rect2(-10, -3, 20, 3), Color("6e4a2c"))
				draw_rect(Rect2(-8, -5, 6, 3), Color("b0613f"))
				draw_rect(Rect2(3, -4, 6, 3), Color("b0613f"))
				return
			draw_colored_polygon(PackedVector2Array([Vector2(-8, -14), Vector2(8, -14), Vector2(6, 0), Vector2(-6, 0)]), Color("b0613f"))
			draw_circle(Vector2(-3, -18), 5.0, Color("5f8f5a"))
			draw_circle(Vector2(4, -20), 5.0, Color("6f9f6a"))
		_:
			if roto:
				for trozo: Vector2 in [Vector2(-9, -2), Vector2(-3, -3), Vector2(4, -2), Vector2(9, -1)]:
					draw_colored_polygon(PackedVector2Array([trozo, trozo + Vector2(3, -2), trozo + Vector2(4, 1)]), Color(0.85, 0.93, 1.0, 0.8))
				draw_rect(Rect2(-12, -1, 24, 1), Color(0.6, 0.8, 1.0, 0.6))
				return
			draw_rect(Rect2(-5, -15, 10, 15), Color(0.85, 0.93, 1.0, 0.45))
			draw_rect(Rect2(-4, -9, 8, 8), Color(0.45, 0.7, 0.95, 0.6))
			draw_rect(Rect2(-5, -15, 10, 15), Color(0.9, 0.95, 1.0, 0.9), false, 1.0)
