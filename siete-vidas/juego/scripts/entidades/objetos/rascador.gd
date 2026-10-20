class_name Rascador
extends Node2D
## "Teatro para Valeria" (prototipo de travesuras aprobado, propuesta v4 §2.1): un rascador nuevo y caro.
## Felipe lo araña con el botón de acción. Cada vez que lo usa:
## - las garras quedan afiladas 6 s (Felipe.duracion_garras): el siguiente arañazo al sofá es CRÍTICO;
## - con público (un testigo que lo está mirando): perdón al instante + un snack al bolsillo, una vez por visita;
##   si repite en la misma visita, no hay premio ("el bis no se cobra");
## - sin público: Felipe se queja ("¿Para quién actúo?") y no hay premio.
## El que avisa qué frase decir y qué jugo mostrar es quien escucha la señal `funcion` (Travesuras).
##
## Interfaz "testigo" (la PARTE B la cumple con Valeria): un nodo en el grupo GRUPO_TESTIGOS con
##   ve(punto: Vector2) -> bool       ¿está mirando ese punto ahora?
##   visita: int                       (opcional) sube cada vez que vuelve a entrar al cuarto
##   perdonar(felipe, motivo: String)  (opcional) lo perdona ("rascador")
## La posición del rascador es su base, al centro. Sin colisión (sus plataformas, si las tiene, son del nivel).

## Terminó una función: con o sin público, si hubo premio (perdón + snack) y quién miraba.
signal funcion(rascador: Rascador, con_publico: bool, premio: bool, testigo: Node)

const GRUPO_TESTIGOS := "testigos"
## Del arte de la tanda 3C (100 × 165; sus plataformas son piezas del nivel).
const ANCHO := 60.0
const ALTO := 160.0

## Verbo de Felipe en el Indicador.
@export var verbo_indicador := "Actuar"
@export var frase_primera_vez := ""

## Funciones que hizo (con y sin público) y premios cobrados.
var funciones := 0
var premios := 0
## Hilos sueltos que deja cada arañazo en la cuerda (coordenadas locales).
var hilos: Array[Vector2] = []
var _funcion_pendiente := false
## testigo (id) -> visita en la que ya cobró el premio.
var _visita_premiada := {}
var _sacudida := 0.0
var _fibras: CPUParticles2D


func _init(nombre := "Rascador") -> void:
	name = nombre


func _ready() -> void:
	add_to_group(Componentes.INTERACTUABLES)
	_fibras = Particulas.polvo(12, 0.9, Vector2(0, 160), Vector2(40, 100), Vector2(1.5, 3.0), Color(0.85, 0.72, 0.45), 80.0, 0.9)
	add_child(_fibras)


func punto_para(desde: Vector2) -> Vector2:
	return Vector2(global_position.x, clampf(desde.y, global_position.y - ALTO, global_position.y))


func interactuar(felipe: Felipe) -> void:
	_funcion_pendiente = true
	felipe.aranar(self)


func verbo(_felipe: Felipe) -> String:
	return verbo_indicador


func primera_frase() -> String:
	return frase_primera_vez


func arte_indicador() -> Dictionary:
	return ArteNivel.arte_en(self, "rascador", 0.0, 0.0)


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(-ANCHO / 2.0, -ALTO), Vector2(ANCHO, ALTO))


## El primer testigo que está mirando el rascador, o null.
func testigo_que_mira() -> Node:
	for testigo in get_tree().get_nodes_in_group(GRUPO_TESTIGOS):
		if testigo.has_method("ve") and bool(testigo.call("ve", global_position)):
			return testigo
	return null


## Lo llama Felipe en cada cuadro de impacto de "aranar". Afila las garras; la función se evalúa una vez por uso.
## Nunca es crítico (el crítico es para el sofá).
func al_aranar(felipe: Felipe) -> bool:
	felipe.afilar_garras()
	var punto := Vector2(-felipe.mirando * 4.0, clampf(to_local(felipe.global_position).y - 30.0, -ALTO + 8.0, -8.0)) + Vector2(randf_range(-2, 2), randf_range(-5, 5))
	hilos.append(punto.round())
	if hilos.size() > 24:
		hilos.pop_front()
	_fibras.position = punto
	_fibras.restart()
	_fibras.emitting = true
	_sacudida = 0.25
	queue_redraw()
	if _funcion_pendiente:
		_funcion_pendiente = false
		_evaluar_funcion(felipe)
	return false


func _evaluar_funcion(felipe: Felipe) -> void:
	funciones += 1
	var testigo := testigo_que_mira()
	if testigo == null:
		funcion.emit(self, false, false, null)
		return
	var visita: int = int(testigo.get("visita")) if "visita" in testigo else 0
	var clave := testigo.get_instance_id()
	var premio: bool = _visita_premiada.get(clave, -1) != visita
	if premio:
		_visita_premiada[clave] = visita
		premios += 1
		felipe.guardar_snack()
		if testigo.has_method("perdonar"):
			testigo.call("perdonar", felipe, "rascador")
	funcion.emit(self, true, premio, testigo)


func _process(delta: float) -> void:
	if _sacudida > 0.0:
		_sacudida = maxf(0.0, _sacudida - delta)
		queue_redraw()


func _draw() -> void:
	# Bamboleo de un píxel al arañarlo (entero, sin emborronar).
	var b := Vector2(1 if _sacudida > 0.0 and int(_sacudida * 40.0) % 2 == 0 else 0, 0)
	if not ArteNivel.dibujar(self, "rascador", b.x, 0.0):
		_dibujar_provisional(b)
	for h in hilos:
		draw_line(h + b, h + b + Vector2(-5, 4), Color(0.95, 0.85, 0.6), 1.0)
		draw_line(h + b, h + b + Vector2(4, 5), Color(0.95, 0.85, 0.6), 1.0)


## Arte provisional (como en el prototipo): poste con cuerda, base y plataforma de felpa, etiqueta "NUEVO".
func _dibujar_provisional(b: Vector2) -> void:
	var felpa := Color(0.82, 0.8, 0.86)
	var cuerda := Color(0.78, 0.64, 0.4)
	draw_rect(Rect2(-18, -8, 36, 8), felpa.darkened(0.15))
	var poste := Rect2(Vector2(-6, -ALTO + 8) + b, Vector2(12, ALTO - 16))
	draw_rect(poste, cuerda)
	var y := poste.position.y + 2.0
	while y < poste.end.y:
		draw_line(Vector2(poste.position.x, y), Vector2(poste.end.x, y + 2.0), cuerda.darkened(0.25), 1.0)
		y += 4.0
	draw_rect(Rect2(Vector2(-20, -ALTO) + b, Vector2(40, 8)), felpa.darkened(0.1))
	draw_rect(Rect2(Vector2(-20, -ALTO) + b, Vector2(40, 2)), felpa)
	var etiqueta := Rect2(Vector2(6, -ALTO + 16) + b, Vector2(30, 12))
	draw_rect(etiqueta, Color(1.0, 0.98, 0.9))
	draw_rect(etiqueta, Color(0.6, 0.15, 0.15), false, 1.0)
	draw_string(ThemeDB.fallback_font, etiqueta.position + Vector2(2, 9), "NUEVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.1, 0.1))
