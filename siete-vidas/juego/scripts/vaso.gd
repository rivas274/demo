class_name Vaso
extends Node2D
## Objeto que Felipe tira de un manotazo con el botón de acción: cae y, según el tipo,
## se rompe (vaso: logro "La Gravedad Funciona") o aturde al enemigo que esté debajo (taza de café, maceta).
## Las llaves no se rompen: caen con un "¡CLINK CRÍTICO!". En la pelea, lo que se rompe vuelve a su lugar de a uno
## (reponer(), lo decide BatallaAspi); un soplido de A.S.P.I. las tira sin romperlas (caer_sin_romper()).
## Escala de gato: vaso, taza, maceta y llaves al doble de su tamaño real (lado menor ≥ 24 px, R8).

## Se rompió en el piso (en la pelea deja una mancha que A.S.P.I. va a limpiar).
signal caido(posicion: Vector2)
## Se cayó sin romperse (soplido): no deja mancha.
signal tirado(objeto: Vaso)

const LOGRO := "La Gravedad Funciona"
## Segundos que queda aturdido el enemigo al que le cae encima.
const ATURDIR := 3.0
const RADIO_IMPACTO := 44.0

var tipo: String
## Cuánto se hunde el dibujo bajo su posición (la línea de atrás del mueble) hasta el medio de la cara de arriba que se
## ve en el arte, con su sombra de contacto (lección 29). Negativo: sube (la repisa dibujada, con su tabla vista desde
## arriba). La posición (alcance, caída) no cambia.
var hundido := 0.0
var roto := false
var _velocidad := Vector2.ZERO
var _cayendo := false
var _piso: float
var _inicio: Vector2
var _sin_romper := false


func _init(y_piso: float, tipo_objeto: String = "vaso") -> void:
	_piso = y_piso
	tipo = tipo_objeto
	name = "Vaso" if tipo == "vaso" else tipo.capitalize()


## Vuelve a su lugar, entero (las macetas de la pelea, de a una).
func reponer() -> void:
	position = _inicio
	rotation = 0.0
	roto = false
	_cayendo = false
	visible = true
	if not is_in_group(Comida.GRUPO):
		add_to_group(Comida.GRUPO)
	queue_redraw()


## Un soplido lo tira sin romperlo: cae al piso y desaparece hasta que lo repongan.
func caer_sin_romper(hacia := 1.0) -> void:
	if _cayendo or roto:
		return
	remove_from_group(Comida.GRUPO)
	_velocidad = Vector2(hacia * 120.0, -140.0)
	_cayendo = true
	position.y += hundido
	queue_redraw()
	_sin_romper = true


func _ready() -> void:
	_inicio = position
	add_to_group(Comida.GRUPO)


## Felipe da el manotazo; el vaso sale volando cuando la pata llega (cuadro de impacto, hallazgo B5).
func interactuar(felipe: Felipe) -> void:
	felipe.dar_manotazo(salir_volando.bind(felipe))


## Lo empuja la pata: sale hacia donde mira Felipe y cae.
func salir_volando(felipe: Felipe) -> void:
	if _cayendo or roto:
		return
	remove_from_group(Comida.GRUPO)
	_velocidad = Vector2(felipe.mirando * 90.0, -90.0)
	_cayendo = true
	position.y += hundido
	queue_redraw()


func verbo(_felipe: Felipe) -> String:
	return "Liberar"


## Rectángulo del dibujo (para medir el lado menor en las pruebas y el contorno).
func rect_dibujo() -> Rect2:
	var t := ArteNivel.textura(tipo)
	var tam := t.get_size() if t else Vector2(24, 24)
	return Rect2(global_position + Vector2(-tam.x / 2.0, -tam.y), tam)


## Para el contorno del Indicador: la imagen y dónde se dibuja.
func arte_indicador() -> Dictionary:
	return ArteNivel.arte_en(self, tipo, 0.0, hundido)


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
	var sala := get_parent()
	if _sin_romper:
		_sin_romper = false
		visible = false
		tirado.emit(self)
		if sala.has_method("sonar"):
			sala.sonar("caja")
		return
	caido.emit(global_position)
	if sala.has_method("sonar"):
		sala.sonar("caja" if tipo == "llaves" else "vidrio")
	if tipo == "vaso":
		if sala.has_method("desbloquear_logro"):
			sala.desbloquear_logro(LOGRO)
		return
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if enemigo.has_method("aturdir") and absf(enemigo.global_position.x - global_position.x) < RADIO_IMPACTO and absf(enemigo.global_position.y - global_position.y) < 20.0:
			enemigo.aturdir(ATURDIR)


func _draw() -> void:
	if not roto and not _cayendo:
		var t := ArteNivel.textura(tipo)
		if t:
			# Sombra de contacto (Gemini, tanda 3F): 1 px más ancha que la base a cada lado; el vaso, además, sobre un
			# posavasos de 1 px.
			var ancho := t.get_width() * 0.8 + 2.0
			if tipo == "vaso":
				draw_rect(Rect2(-ancho / 2.0 - 1.0, hundido - 1.0, ancho + 2.0, 1.0), Color("8a4a3a"))
			Sala.sombra(self, Vector2(0, hundido), ancho + 2.0, 0.5)
			ArteNivel.dibujar(self, tipo, 0.0, hundido - (1.0 if tipo == "vaso" else 0.0))
			return
	if (not roto or tipo == "llaves") and ArteNivel.dibujar(self, tipo, 0.0, 0.0):
		return
	match tipo:
		"taza":
			# Rota: el charco de café y los trozos de loza (en la pelea, además, la mancha que A.S.P.I. limpia).
			draw_rect(Rect2(-15, -2, 30, 2), Color("4a2a1a"))
			draw_rect(Rect2(-11, -3, 20, 1), Color("6b3e22"))
			for trozo: Rect2 in [Rect2(-12, -6, 6, 4), Rect2(-2, -5, 5, 3), Rect2(6, -7, 7, 5)]:
				draw_rect(trozo.grow(1), Color("2b1712"))
				draw_rect(trozo, Color("f1e6d2"))
				draw_rect(Rect2(trozo.position, Vector2(trozo.size.x, 1)), Color("c0603f"))
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
