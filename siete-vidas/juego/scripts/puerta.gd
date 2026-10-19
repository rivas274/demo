class_name Puerta
extends Node2D
## Puerta entre habitaciones (arte de una sola hoja de la tanda 3A: arregla B2, el poste en el medio). Junto a ella,
## el botón de acción o arriba la cruza: la sala funde a negro y Felipe aparece en la puerta del otro lado. Una puerta
## cerrada no deja pasar (la de la cocina hasta que Valeria la abre; la del balcón hasta apagar a A.S.P.I.); una
## entornada se abre arañándola (la del dormitorio). Señales del escenario: tapete, luz cálida que sale del vano y,
## en la puerta cerrada de la cocina, la sombra de Valeria que se mueve debajo.

signal cruzada(puerta: Puerta)

## Escala de gato: puertas gruesas y legibles (vano de unos 104 px; la imagen se mide en prueba_reglas_nivel).
const ANCHO := 104.0
## Puerta de 2,05 m.
const ALTO_MAXIMO := 248.0
const CERCA := 44.0

var destino: String
var alto := ALTO_MAXIMO
var cerrada := false
## Entornada (abierta un palmo): no se cruza hasta arañarla.
var entornada := false
## Pie de la escalera de fondo: no se dibuja marco (la escalera es del nivel).
var escalera := false
## Arte: "" puerta de madera, "balcon" puerta-ventana, "vano" arco sin hoja.
var estilo := ""
## Alguien se mueve del otro lado (sombra bajo la puerta cerrada).
var sombra_detras := false
var _felipe: Felipe
var _cerca := false
var _tiempo := 0.0
var _abierta_un_rato := 0.0


func _init(nombre_puerta: String, posicion: Vector2, puerta_destino: String, alto_disponible: float) -> void:
	name = nombre_puerta
	position = posicion
	destino = puerta_destino
	alto = minf(ALTO_MAXIMO, alto_disponible)
	z_index = -2


func _ready() -> void:
	add_to_group(Comida.GRUPO)
	_felipe = get_tree().get_first_node_in_group("felipe")


func interactuar(_felipe_que_entra: Felipe) -> void:
	cruzada.emit(self)


## La entornada se ofrece como arañable (otro nodo); la cerrada sigue ofreciéndose (Felipe dice algo al probarla).
func disponible(_felipe_que_pregunta: Felipe) -> bool:
	return not entornada


## Verbo de Felipe para el Indicador: la escalera se "asciende", las puertas se "pasan".
func verbo(_felipe: Felipe) -> String:
	if escalera:
		return "Ascender"
	return "Probar" if cerrada else "Pasar"


## Nombre de la imagen según el estado.
func arte() -> String:
	if estilo == "vano":
		return "vano"
	if estilo == "balcon":
		return "puerta_balcon_v2" if cerrada else "puerta_balcon_abierta"
	if entornada:
		return "puerta_entornada"
	if cerrada and _abierta_un_rato <= 0.0:
		return "puerta_cerrada_v2"
	return "puerta_abierta_v2"


## Se abre un momento (alguien entra o sale) y vuelve a quedar como estaba.
func abrir_un_momento(segundos := 0.6) -> void:
	_abierta_un_rato = segundos
	queue_redraw()


func arte_indicador() -> Dictionary:
	if escalera:
		return {}
	return ArteNivel.arte_en(self, arte(), 0.0, 0.0)


func _physics_process(delta: float) -> void:
	_tiempo += delta
	if _abierta_un_rato > 0.0:
		_abierta_un_rato -= delta
		if _abierta_un_rato <= 0.0:
			queue_redraw()
	if sombra_detras and cerrada:
		queue_redraw()
	if _felipe == null:
		return
	var distancia := _felipe.global_position - global_position
	var cerca := absf(distancia.x) < CERCA and absf(distancia.y) < 6.0
	if cerca != _cerca:
		_cerca = cerca
		queue_redraw()
	if cerca and not entornada and _felipe.is_on_floor() and Input.is_action_just_pressed("mover_arriba"):
		cruzada.emit(self)


func _draw() -> void:
	if escalera:
		return
	var nombre := arte()
	var textura := ArteNivel.textura(nombre)
	var alto_arte := textura.get_size().y if textura else ALTO_MAXIMO
	if not cerrada and not entornada and estilo != "balcon":
		# Luz cálida que sale del vano.
		draw_colored_polygon(PackedVector2Array([Vector2(-40, -alto_arte + 30), Vector2(40, -alto_arte + 30), Vector2(64, 0), Vector2(-64, 0)]), Color(1.0, 0.85, 0.55, 0.10))
	ArteNivel.dibujar(self, nombre, 0.0, 0.0)
	if cerrada and estilo != "balcon":
		# Rendija de luz abajo y, si hay alguien adentro, su sombra que va y viene.
		draw_rect(Rect2(-44, -3, 88, 2), Color(1.0, 0.85, 0.5, 0.8))
		if sombra_detras:
			var x := sin(_tiempo * 1.3) * 30.0
			draw_rect(Rect2(x - 9, -3, 18, 2), Color(0.15, 0.08, 0.06, 0.9))
	if estilo != "vano":
		# Tapete terracota.
		draw_rect(Rect2(-48, -2, 96, 4), Color(0.69, 0.33, 0.24))
		draw_rect(Rect2(-48, -2, 96, 1), Color(0.82, 0.45, 0.32))
