class_name CajasMudanza
extends StaticBody2D
## Cajas de la mudanza al pie de la escalera de fondo (decisión del creador, 2026-10-19; reemplazan la reja «PIPE: NO»):
## tres cajas apiladas con la cesta de ropa encima, sobre el primer escalón. Valeria lleva un año «ordenando». La pila
## es SÓLIDA (alto de la cesta, 1 m): desde el piso no se pasa ni se salta; Felipe solo la empuja. Se pasa trepando
## el librero y bajando del otro lado. Desde la escalera (parado en el segundo peldaño, «desde arriba») un manotazo tira
## la caja de arriba: rueda por el piso y queda abierta con la ropa (caja_abierta), la pila baja a dos cajas y la caja
## abierta es un escalón: el atajo de vuelta (R6), que solo se abre desde adentro.

signal tirada
## Felipe la empujó desde afuera (para su frase).
signal empujada

## Pila entera (cajas_pila, 60 × 124 desde la segunda pasada: cabe entera entre el librero y el poste del pasamanos):
## la colisión va de la fila 2 (el borde de la cesta) al piso.
const ALTO_PILA := 122.0
## Las dos cajas que quedan (cajas_base): 62 px.
const ALTO_BASE := 62.0
## Columnas 0 a 57 de la caja de abajo.
const ANCHO := 58.0
## Dónde queda la caja abierta (centro de su base, a la izquierda de la pila, delante del librero) y el borde de la caja
## (la fila del contorno, a 33 px del piso) que se pisa.
const CAIDA_X := -40.0
const BORDE_CAJA := 33.0
const ANCHO_BORDE_CAJA := 64.0
const SEGUNDOS_CAIDA := 0.75
## Ropa que salta de la caja al golpear el piso (segunda pasada, pilar 5): dos calcetines de arriba-extra (no son el
## calcetín rayado que se colecciona). [imagen, dónde queda (x relativa a la pila), sobre qué (alto de su base: 0 el piso,
## ALTO_BASE encima de las dos cajas), alto del arco, giro final]. Nada cae delante de la puerta de la cocina (lección 2).
const ROPA := [["ropa_1", -86.0, 0.0, 30.0, -0.5], ["ropa_2", 22.0, ALTO_BASE, 34.0, 0.35]]
const SEGUNDOS_ROPA := 0.45

var rect: Rect2
## El peldaño desde donde se tira (pies de Felipe, en el mundo).
var peldano: Vector2
var tirada_ya := false
var _forma: CollisionShape2D
var _borde_caja: StaticBody2D
## Caja de arriba mientras cae: posición relativa, giro y si ya aterrizó.
var _caida := 0.0
var _abierta := false
## Ropa en el aire: 0 al salir de la caja, 1 en el piso.
var _vuelo_ropa := 0.0
var _polvo: CPUParticles2D


func _init(rectangulo: Rect2, peldano_golpe: Vector2) -> void:
	rect = rectangulo
	peldano = peldano_golpe
	name = "Cajas de la mudanza"
	position = Vector2(rect.position.x, rect.end.y)


func _ready() -> void:
	add_to_group(Componentes.INTERACTUABLES)
	Profundidad.poner(self, Capas.Rol.SALTABLE, PackedStringArray([String(name)]))
	_forma = CollisionShape2D.new()
	_forma.shape = RectangleShape2D.new()
	add_child(_forma)
	_poner_alto(ALTO_PILA)
	# Nube de polvo al golpear el piso (delante de las cajas, en la capa del juego: nunca encima de la imaginación).
	_polvo = Particulas.polvo(34, 0.9, Vector2(0, 90), Vector2(40, 110), Vector2(3, 6), Color(0.9, 0.85, 0.76, 0.9), 75.0)
	_polvo.name = "Polvo de la caja"
	Profundidad.poner(_polvo, Capas.Rol.OBJETO_JUEGO)
	_polvo.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_polvo.emission_rect_extents = Vector2(36, 2)
	_polvo.damping_min = 40.0
	_polvo.damping_max = 70.0
	_polvo.position = Vector2(CAIDA_X, -4.0)
	add_child(_polvo)


func _poner_alto(alto: float) -> void:
	(_forma.shape as RectangleShape2D).size = Vector2(ANCHO, alto)
	_forma.position = Vector2(ANCHO / 2.0, -alto / 2.0)


## Rectángulo sólido actual (en el mundo): para las pruebas.
func rect_solido() -> Rect2:
	var alto := ALTO_BASE if tirada_ya else ALTO_PILA
	return Rect2(rect.position.x, rect.end.y - alto, ANCHO, alto)


## ¿Felipe está del lado de la escalera (adentro)?
func adentro(felipe: Node2D) -> bool:
	return felipe.global_position.x >= rect.end.x


## ¿Está parado en el peldaño desde donde se tira la caja de arriba?
## Solo en ESE peldaño (x incluida): antes bastaba la altura y la caja de los libros del estudio (40 cm) ofrecía «Tirar».
func en_el_peldano(felipe: Node2D) -> bool:
	return adentro(felipe) and absf(felipe.global_position.y - peldano.y) < 4.0 and absf(felipe.global_position.x - peldano.x) < 30.0


func interactuar(felipe: Felipe) -> void:
	if tirada_ya:
		return
	if not en_el_peldano(felipe):
		# Desde el recibidor solo la empuja con la pata: no se mueve.
		felipe.dar_manotazo(func() -> void: empujada.emit())
		return
	tirada_ya = true
	remove_from_group(Componentes.INTERACTUABLES)
	felipe.mirando = -1.0
	felipe.sprite.flip_h = true
	# La caja cae cuando la pata llega (cuadro de impacto), no al apretar.
	felipe.dar_manotazo(_tirar)


## Afuera, desde el piso: «Empujar». En el peldaño: «Tirar». Adentro en el piso no se ofrece (manda «Ascender»).
func disponible(felipe: Felipe) -> bool:
	return not tirada_ya and (not adentro(felipe) or en_el_peldano(felipe))


func verbo(felipe: Felipe) -> String:
	return "VERBO_TIRAR" if en_el_peldano(felipe) else "VERBO_EMPUJAR"


## Afuera se alcanza al pie; en el peldaño, a la altura de la caja de arriba (a la par de Felipe).
func punto_para(desde: Vector2) -> Vector2:
	if desde.x >= rect.end.x:
		return Vector2(desde.x, peldano.y)
	return Vector2(rect.position.x, rect.end.y)


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(0, -ALTO_PILA), Vector2(ANCHO, ALTO_PILA))


func arte_indicador() -> Dictionary:
	if tirada_ya:
		return {}
	return ArteNivel.arte_en(self, "cajas_pila", _centro_arte(), 0.0)


func _centro_arte() -> float:
	var t := ArteNivel.textura("cajas_pila")
	return t.get_width() / 2.0 if t else ANCHO / 2.0


func _tirar() -> void:
	_poner_alto(ALTO_BASE)
	var tween := create_tween()
	tween.tween_property(self, "_caida", 1.0, SEGUNDOS_CAIDA).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, SEGUNDOS_CAIDA)
	tween.tween_callback(_aterrizar)
	tirada.emit()


## La caja abierta en el piso: su borde se pisa (escalón al resto de la pila).
func _aterrizar() -> void:
	_abierta = true
	queue_redraw()
	_polvo.restart()
	_polvo.emitting = true
	var tween := create_tween()
	tween.tween_property(self, "_vuelo_ropa", 1.0, SEGUNDOS_ROPA).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_method(func(_v: float) -> void: queue_redraw(), 0.0, 1.0, SEGUNDOS_ROPA)
	_borde_caja = StaticBody2D.new()
	_borde_caja.name = "Borde de la caja abierta"
	_borde_caja.collision_layer = 0
	_borde_caja.set_collision_layer_value(Felipe.CAPA_ATRAVESABLE, true)
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(ANCHO_BORDE_CAJA, 6)
	forma.shape = caja
	forma.one_way_collision = true
	forma.position = Vector2(CAIDA_X, -BORDE_CAJA + 3.0)
	_borde_caja.add_child(forma)
	add_child(_borde_caja)


## Rectángulo del borde de la caja abierta en el mundo (vacío si todavía no cayó).
func rect_borde_caja() -> Rect2:
	if not _abierta:
		return Rect2()
	return Rect2(global_position + Vector2(CAIDA_X - ANCHO_BORDE_CAJA / 2.0, -BORDE_CAJA), Vector2(ANCHO_BORDE_CAJA, 6))


func _draw() -> void:
	var cx := _centro_arte()
	if not tirada_ya:
		ArteNivel.sombra(self, Vector2(cx, 0), ANCHO + 4.0, 0.4)
		ArteNivel.dibujar(self, "cajas_pila", cx, 0.0)
		return
	ArteNivel.sombra(self, Vector2(cx, 0), ANCHO + 4.0, 0.4)
	ArteNivel.dibujar(self, "cajas_base", cx, 0.0)
	if _abierta:
		ArteNivel.sombra(self, Vector2(CAIDA_X, 0), 80.0, 0.45)
		ArteNivel.dibujar(self, "caja_abierta", CAIDA_X, 0.0)
		_dibujar_ropa()
		return
	# La caja de arriba se vuelca hacia afuera: cae en arco, gira media vuelta y rebota en el piso.
	var arriba := ArteNivel.textura("caja_arriba")
	if arriba == null:
		return
	var t := _caida
	var desde := Vector2(cx, -ALTO_BASE - arriba.get_height() / 2.0)
	var hasta := Vector2(CAIDA_X, -arriba.get_height() / 2.0)
	var centro := desde.lerp(hasta, t) + Vector2(0, -sin(t * PI) * 26.0)
	draw_set_transform(centro, -t * PI, Vector2.ONE)
	draw_texture(arriba, -arriba.get_size() / 2.0)
	draw_set_transform(Vector2.ZERO)


## ¿Ya saltó la ropa de la caja y quedó en el piso? (para las pruebas).
func ropa_esparcida() -> bool:
	return _abierta and _vuelo_ropa >= 1.0


## Polvo de la caja (para las pruebas).
func polvo() -> CPUParticles2D:
	return _polvo


## Los calcetines saltan de la boca de la caja en arco y quedan en el piso con su sombra.
func _dibujar_ropa() -> void:
	var boca := Vector2(CAIDA_X, -BORDE_CAJA - 4.0)
	for ropa: Array in ROPA:
		var textura := ArteNivel.textura(ropa[0])
		if textura == null:
			continue
		var t := _vuelo_ropa
		var base := -float(ropa[2])
		var hasta := Vector2(ropa[1], base - textura.get_height() / 2.0 + 2.0)
		var centro := boca.lerp(hasta, t) + Vector2(0, -sin(t * PI) * float(ropa[3]))
		if t >= 1.0:
			ArteNivel.sombra(self, Vector2(ropa[1], base + 1.0), textura.get_width() + 2.0, 0.35)
		draw_set_transform(centro, float(ropa[4]) * t, Vector2.ONE)
		draw_texture(textura, -textura.get_size() / 2.0)
		draw_set_transform(Vector2.ZERO)
