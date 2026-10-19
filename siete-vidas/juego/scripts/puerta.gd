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
## Puerta del baño (lugar insinuado): siempre cerrada, con la luz fría de un tubo bajo la puerta que titila cada 5 a
## 8 s; al probarla la hoja tiembla 1 px y no cede; su manilla puede dar un destello.
var bano := false
const LUZ_BANO := Color("dfe8e2")
## Dónde brilla la manilla de palanca (desde el pie, al centro de la puerta cerrada de 140 px).
const MANILLA := Vector2(47, -100)
var _temblor := 0.0
var _destello := 0.0
var _felipe: Felipe
var _cerca := false
var _tiempo := 0.0
var _abierta_un_rato := 0.0
## Alguien la está cruzando (Valeria): queda abierta hasta soltar_paso() (G2).
var _sosteniendo := false
## La otra cara de esta misma puerta (en el cuarto de al lado): se abre y se cierra con esta.
var par: Puerta
## Hoja de la puerta: 0 cerrada, 1 abierta. Va hacia su objetivo en DURACION_APERTURA (se ve girar la hoja).
var apertura := 1.0
const DURACION_APERTURA := 0.25


func _init(nombre_puerta: String, posicion: Vector2, puerta_destino: String, alto_disponible: float) -> void:
	name = nombre_puerta
	position = posicion
	destino = puerta_destino
	alto = minf(ALTO_MAXIMO, alto_disponible)
	z_index = Capas.PUERTAS


func _ready() -> void:
	apertura = 0.0 if _objetivo_apertura() == 0.0 else 1.0
	add_to_group(Comida.GRUPO)
	_felipe = get_tree().get_first_node_in_group("felipe")


func interactuar(_felipe_que_entra: Felipe) -> void:
	cruzada.emit(self)


## Cerrada, ¿se ofrece igual para "Probar"? (en la pelea, la del balcón no: M3, la burbuja pisaba a A.S.P.I.).
var ofrecer_cerrada := true


## La entornada se ofrece como arañable (otro nodo); la cerrada sigue ofreciéndose (Felipe dice algo al probarla).
func disponible(_felipe_que_pregunta: Felipe) -> bool:
	return not entornada and (not cerrada or ofrecer_cerrada)


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
	if apertura <= 0.0:
		return "puerta_cerrada_v2"
	return "puerta_abierta_v2"


## Al probarla y no ceder: la hoja tiembla 1 px un momento.
func temblar() -> void:
	_temblor = 0.3


## La manilla da un destello de 1 px (0,2 s).
func destellar() -> void:
	_destello = 0.2


## ¿La rendija del baño está apagada en este momento? (titileo de tubo: un parpadeo corto cada 5 a 8 s).
func _tubo_apagado() -> bool:
	var ciclo := floorf(_tiempo / 6.5)
	var parpadeo := ciclo * 6.5 + 3.0 + fmod(ciclo * 2.37, 3.0) - 1.5
	return absf(_tiempo - parpadeo) < 0.18 and int(_tiempo * 20.0) % 2 == 0


## Se abre un momento (alguien entra o sale) y vuelve a quedar como estaba.
func abrir_un_momento(segundos := 0.6) -> void:
	_abierta_un_rato = segundos
	queue_redraw()


## Alguien va a cruzarla: se abre (la hoja gira en 0,25 s) y queda abierta hasta soltar_paso().
func abrir_para_paso(con_par := true) -> void:
	_sosteniendo = true
	queue_redraw()
	if con_par and par:
		par.abrir_para_paso(false)


## Ya pasó: si la puerta estaba cerrada, vuelve a cerrarse (la hoja gira de vuelta).
func soltar_paso(con_par := true) -> void:
	_sosteniendo = false
	queue_redraw()
	if con_par and par:
		par.soltar_paso(false)


## ¿Está abierta del todo? (para esperar a que termine de abrirse antes de cruzar).
func abierta_del_todo() -> bool:
	return apertura >= 1.0


func _objetivo_apertura() -> float:
	if estilo != "" or entornada or escalera:
		return 0.0 if cerrada else 1.0
	return 1.0 if (not cerrada or _abierta_un_rato > 0.0 or _sosteniendo) else 0.0


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
	var objetivo := _objetivo_apertura()
	if apertura != objetivo:
		# Las puertas de madera giran; el balcón y la entornada cambian de golpe (no tienen hoja que girar).
		apertura = move_toward(apertura, objetivo, delta / DURACION_APERTURA) if estilo == "" and not entornada else objetivo
		queue_redraw()
	if sombra_detras and cerrada:
		queue_redraw()
	if bano or _temblor > 0.0 or _destello > 0.0:
		_temblor = maxf(0.0, _temblor - delta)
		_destello = maxf(0.0, _destello - delta)
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
	if apertura > 0.0 and not entornada and estilo != "balcon":
		# Luz cálida que sale del vano.
		draw_colored_polygon(PackedVector2Array([Vector2(-40, -alto_arte + 30), Vector2(40, -alto_arte + 30), Vector2(64, 0), Vector2(-64, 0)]), Color(1.0, 0.85, 0.55, 0.10))
	var temblor := (1.0 if int(_temblor * 40.0) % 2 == 0 else -1.0) if _temblor > 0.0 else 0.0
	ArteNivel.dibujar(self, nombre, temblor, 0.0)
	if estilo == "vano":
		# Arriba de la escalera de fondo: dentro del hueco se ven el remate del pasamanos y los peldaños que bajan (G2).
		ArteNivel.dibujar(self, "vano_bajada", 0.0, -4.0)
	if _destello > 0.0:
		var brillo := Color("fff3c4")
		draw_rect(Rect2(MANILLA + Vector2(-2, 0), Vector2(5, 1)), brillo)
		draw_rect(Rect2(MANILLA + Vector2(0, -2), Vector2(1, 5)), brillo)
	if apertura > 0.0 and apertura < 1.0 and estilo == "" and not entornada:
		# La hoja gira sobre la bisagra (borde derecho): la cerrada se angosta hacia allá mientras se abre.
		var hoja := ArteNivel.textura("puerta_cerrada_v2")
		if hoja:
			var ancho := hoja.get_width()
			var borde := ancho / 2.0
			draw_set_transform(Vector2(borde, 0), 0.0, Vector2(maxf(1.0 - apertura, 0.08), 1.0))
			draw_texture(hoja, Vector2(-ancho, -hoja.get_height()), Color(1, 1, 1).darkened(apertura * 0.35))
			draw_set_transform(Vector2.ZERO)
	if apertura <= 0.0 and estilo != "balcon":
		# Rendija de luz abajo y, si hay alguien adentro, su sombra que va y viene.
		if bano:
			# Luz fría de tubo: la rendija y un reflejo sobre el piso (el baño no lleva tapete).
			var alfa := 0.25 if _tubo_apagado() else 0.85
			draw_rect(Rect2(-44, -3, 88, 2), Color(LUZ_BANO, alfa))
			draw_rect(Rect2(-40, -1, 80, 3), Color(LUZ_BANO, alfa * 0.3))
		else:
			draw_rect(Rect2(-44, -3, 88, 2), Color(1.0, 0.85, 0.5, 0.8))
		if sombra_detras:
			var x := sin(_tiempo * 1.3) * 30.0
			draw_rect(Rect2(x - 9, -3, 18, 2), Color(0.15, 0.08, 0.06, 0.9))
	if estilo != "vano" and not bano:
		# Tapete terracota.
		draw_rect(Rect2(-48, -2, 96, 4), Color(0.69, 0.33, 0.24))
		draw_rect(Rect2(-48, -2, 96, 1), Color(0.82, 0.45, 0.32))
