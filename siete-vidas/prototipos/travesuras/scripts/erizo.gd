# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Erizo
extends Node2D
## Pelo erizado de "intimidar": púas cortas que salen del contorno de Felipe (lomo, cabeza y cola),
## medido en su cuadro "quieto". Sustituye a una animación propia que todavía no existe.

## Largo máximo de cada púa en px.
@export var largo := 7.0
## Cada cuántos píxeles del contorno sale una púa.
@export var separacion := 3

var _puntos: PackedVector2Array = []
var _normales: PackedVector2Array = []
var _tiempo := 0.0
var _duracion := 0.0


func preparar(textura: Texture2D, escala: float) -> void:
	var imagen := textura.get_image()
	var ancho := imagen.get_width()
	var alto := imagen.get_height()
	var centro := Vector2(ancho, alto) / 2.0
	var cuenta := 0
	for y in range(1, alto - 1):
		for x in range(1, ancho - 1):
			if imagen.get_pixel(x, y).a < 0.5:
				continue
			# Borde: un vecino transparente. La normal apunta hacia afuera (hacia lo transparente).
			var normal := Vector2.ZERO
			for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if imagen.get_pixel(x + d.x, y + d.y).a < 0.5:
					normal += Vector2(d)
			if normal == Vector2.ZERO or normal.y > 0.3:
				continue
			# Solo la mitad de arriba (lomo, cabeza, cola): las patas no se erizan.
			if y > alto * 0.72:
				continue
			cuenta += 1
			if cuenta % separacion != 0:
				continue
			_puntos.append((Vector2(x, y) - centro) * escala)
			_normales.append(normal.normalized())


func erizar(duracion: float, lado: float) -> void:
	_duracion = duracion
	_tiempo = duracion
	scale.x = lado
	queue_redraw()


func _process(delta: float) -> void:
	if _tiempo <= 0.0:
		return
	_tiempo -= delta
	queue_redraw()


func _draw() -> void:
	if _tiempo <= 0.0:
		return
	var avance := 1.0 - _tiempo / _duracion
	# Sube rápido, se mantiene y baja.
	var fuerza := clampf(avance / 0.15, 0.0, 1.0) * clampf(_tiempo / 0.25, 0.0, 1.0)
	for i in _puntos.size():
		var temblor := 0.75 + 0.25 * sin(_tiempo * 40.0 + i)
		var punta := _puntos[i] + _normales[i] * largo * fuerza * temblor
		draw_line(_puntos[i], punta, Color(0.27, 0.22, 0.2), 2.0)
		draw_line(_puntos[i] + _normales[i], punta, Color(0.93, 0.9, 0.85), 1.0)
