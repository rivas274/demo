class_name Reja
extends StaticBody2D
## Reja anti-fuga para mascotas (decisión del creador, 2026-10-19): Valeria la atornilló entre el librero y la
## escalera después del video viral. Mide 1,5 m (182 px), se dibuja de 48 px con colisión fina (12 px), lleva el
## cartel "PIPE: NO" (texto por código, centrado en la reja sin pisar el librero, M2) y el pestillo del lado de adentro ("a prueba de Pipe").
## Desde el recibidor Felipe solo la empuja ("Qué tierno."); se pasa trepando el librero y saltándola. Desde la
## escalera, un manotazo al pestillo la abre para siempre: es el atajo de vuelta (R6).

signal abierta
## Felipe la empujó desde afuera (para su frase).
signal empujada

const ANCHO_DIBUJO := 48.0
## Cartel de cartón sobre el que trae el arte (28 × 30, al centro de la reja de 48 px): no se monta sobre el
## librero (M2).
const CARTEL := Rect2(-17, -162, 34, 33)

var rect: Rect2
var abierta_ya := false
var _apertura := 0.0


func _init(rectangulo: Rect2) -> void:
	rect = rectangulo
	name = "Reja"
	position = Vector2(rect.get_center().x, rect.end.y)


func _ready() -> void:
	add_to_group(Comida.GRUPO)
	z_index = -1
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = rect.size
	forma.shape = caja
	forma.position = rect.get_center() - position
	add_child(forma)


## ¿Felipe está del lado de la escalera (adentro)?
func adentro(felipe: Node2D) -> bool:
	return felipe.global_position.x >= rect.end.x


func interactuar(felipe: Felipe) -> void:
	if abierta_ya:
		return
	if not adentro(felipe):
		# Desde el recibidor solo la empuja con la pata.
		felipe.dar_manotazo(func() -> void: empujada.emit())
		return
	abierta_ya = true
	remove_from_group(Comida.GRUPO)
	# El pestillo se abre cuando la pata llega (cuadro de impacto), no al apretar.
	felipe.dar_manotazo(_abrir)


func _abrir() -> void:
	for hijo in get_children():
		if hijo is CollisionShape2D:
			hijo.set_deferred("disabled", true)
	var giro := create_tween()
	giro.tween_property(self, "_apertura", 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	giro.parallel().tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, 0.35)
	abierta.emit()


func disponible(_felipe: Felipe) -> bool:
	return not abierta_ya


func verbo(felipe: Felipe) -> String:
	return "Abrir" if adentro(felipe) else "Empujar"


## Felipe la alcanza al pie, del lado donde está.
func punto_para(desde: Vector2) -> Vector2:
	return Vector2(rect.end.x if desde.x >= rect.end.x else rect.position.x, rect.end.y)


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(-ANCHO_DIBUJO / 2.0, -rect.size.y), Vector2(ANCHO_DIBUJO, rect.size.y))


func arte_indicador() -> Dictionary:
	if abierta_ya:
		return {}
	return ArteNivel.arte_en(self, "reja_frente", 0.0, 0.0)


func _draw() -> void:
	if abierta_ya:
		# Abierta: girada contra el librero (se ve angosta, de canto).
		var arte := ArteNivel.textura("reja_frente")
		if arte:
			var ancho := lerpf(ANCHO_DIBUJO, 14.0, _apertura)
			draw_texture_rect(arte, Rect2(-ANCHO_DIBUJO / 2.0, -arte.get_height(), ancho, arte.get_height()), false, Color(0.92, 0.9, 0.88))
		return
	if not ArteNivel.dibujar(self, "reja_frente", 0.0, 0.0):
		draw_rect(Rect2(-ANCHO_DIBUJO / 2.0, -rect.size.y, ANCHO_DIBUJO, rect.size.y), Color(0.93, 0.9, 0.84), false, 3.0)
	# Cartel de cartón de Valeria, pegado con cinta (el texto lo pone el código: Gemini escribe mal).
	var fuente := ThemeDB.fallback_font
	draw_rect(CARTEL.grow(1), Color(0.35, 0.22, 0.15))
	draw_rect(CARTEL, Color(0.86, 0.74, 0.55))
	# Cinta adhesiva en las esquinas de arriba, sin salirse del cartel.
	draw_rect(Rect2(CARTEL.position + Vector2(1, -1), Vector2(7, 3)), Color(0.95, 0.93, 0.8, 0.9))
	draw_rect(Rect2(Vector2(CARTEL.end.x - 8, CARTEL.position.y - 1), Vector2(7, 3)), Color(0.95, 0.93, 0.8, 0.9))
	# "PIPE: NO" en dos líneas legibles (la firma de 6 px no se leía y se quitó: el chiste está en "PIPE: NO", M2).
	for linea: Array in [["PIPE:", 11, 13], ["NO", 14, 28]]:
		var ancho_linea := fuente.get_string_size(linea[0], HORIZONTAL_ALIGNMENT_LEFT, -1, linea[1]).x
		draw_string(fuente, Vector2(-ancho_linea / 2.0, CARTEL.position.y + linea[2]), linea[0], HORIZONTAL_ALIGNMENT_LEFT, -1, linea[1], Color(0.7, 0.08, 0.1))
