class_name Aranable
extends Node2D
## Algo que Felipe araña con el botón de acción (sofá con plástico, puerta entornada): Felipe se para en dos
## patas (animación "aranar") y en cada cuadro de impacto quedan marcas y sale pelusa. Con las garras afiladas
## (rascador) el arañazo es CRÍTICO y lo rompe de un golpe (el plástico del sofá, la puerta se abre).
## No dibuja el mueble (eso es del nivel): solo las marcas que quedan. La posición es la base, al centro.

## Cada arañazo (dos por vez: cuadros 3 y 5 de "aranar"). `critico`: con las garras afiladas.
signal aranado(objeto: Aranable, critico: bool)
## Se rompió: el plástico del sofá cedió o la puerta entornada se abrió.
signal roto(objeto: Aranable)

## Ancho y alto de la zona arañable (la mitad izquierda y derecha de la posición; hacia arriba).
@export var ancho := 120.0
@export var alto := 60.0
## Arañazos que aguanta antes de romperse (0 = nunca se rompe, se puede arañar siempre).
@export var aranazos_para_romper := 3
## Verbo de Felipe en el Indicador ("Firmar" el sofá, "Arañar" la puerta).
@export var verbo_indicador := "Firmar"
## Línea de Felipe la primera vez que se acerca ({interactuar} es el ícono del botón); "" para ninguna.
@export var frase_primera_vez := ""

var aranazos := 0
var esta_roto := false
## Marcas que quedan (en coordenadas locales).
var marcas: Array[Vector2] = []
var _pelusa: CPUParticles2D
var _temblor := 0.0


func _init(nombre := "Arañable", ancho_zona := 120.0, alto_zona := 60.0) -> void:
	name = nombre
	ancho = ancho_zona
	alto = alto_zona


func _ready() -> void:
	add_to_group(Componentes.INTERACTUABLES)
	z_index = Capas.MARCAS
	_pelusa = CPUParticles2D.new()
	_pelusa.emitting = false
	_pelusa.one_shot = true
	_pelusa.amount = 10
	_pelusa.lifetime = 0.8
	_pelusa.explosiveness = 0.9
	_pelusa.direction = Vector2(0, -1)
	_pelusa.spread = 70.0
	_pelusa.gravity = Vector2(0, 150)
	_pelusa.initial_velocity_min = 30.0
	_pelusa.initial_velocity_max = 80.0
	_pelusa.scale_amount_min = 1.0
	_pelusa.scale_amount_max = 2.0
	_pelusa.color = Color(0.95, 0.92, 0.85)
	add_child(_pelusa)


## Si se rompe y ya no se puede arañar más, deja de ofrecerse al botón de acción.
func disponible(_felipe: Felipe) -> bool:
	return aranazos_para_romper == 0 or not esta_roto


## Dónde lo alcanza Felipe: el punto de la zona más cercano a él, a su altura.
func punto_para(desde: Vector2) -> Vector2:
	var x := clampf(desde.x, global_position.x - ancho / 2.0, global_position.x + ancho / 2.0)
	var y := clampf(desde.y, global_position.y - alto, global_position.y)
	return Vector2(x, y)


func interactuar(felipe: Felipe) -> void:
	felipe.aranar(self)


func verbo(_felipe: Felipe) -> String:
	return verbo_indicador


func primera_frase() -> String:
	return frase_primera_vez


## Arte del mueble para el contorno del Indicador (lo pone el nivel, que es quien lo dibuja): devuelve lo mismo que
## arte_indicador(). Sin él no hay contorno, solo la burbuja.
var arte := Callable()


func arte_indicador() -> Dictionary:
	return arte.call() if arte.is_valid() else {}


func rect_indicador() -> Rect2:
	return Rect2(global_position + Vector2(-ancho / 2.0, -alto), Vector2(ancho, alto))


## Lo llama Felipe en cada cuadro de impacto de "aranar". Devuelve si fue crítico.
func al_aranar(felipe: Felipe) -> bool:
	var critico := felipe.gastar_garras()
	var lado := felipe.mirando
	var punto := to_local(felipe.global_position) + Vector2(lado * 16.0, -34.0 + randf_range(-6, 6))
	punto.x = clampf(punto.x, -ancho / 2.0 + 4.0, ancho / 2.0 - 4.0)
	punto.y = clampf(punto.y, -alto + 6.0, -4.0)
	for i in (3 if critico else 1):
		marcas.append(punto + Vector2(i * 5.0 * lado, i * 3.0))
	if marcas.size() > 40:
		marcas = marcas.slice(marcas.size() - 40)
	_pelusa.position = punto
	_pelusa.amount = 20 if critico else 10
	_pelusa.restart()
	_pelusa.emitting = true
	_temblor = 0.2
	aranazos += 1
	aranado.emit(self, critico)
	if not esta_roto and aranazos_para_romper > 0 and (critico or aranazos >= aranazos_para_romper):
		esta_roto = true
		roto.emit(self)
	queue_redraw()
	return critico


func _process(delta: float) -> void:
	if _temblor > 0.0:
		_temblor = maxf(0.0, _temblor - delta)
		queue_redraw()


func _draw() -> void:
	# Marcas de uñas: tres rayas claras con sombra, en píxeles enteros.
	for m in marcas:
		var p := m.round()
		for k in 3:
			var a := p + Vector2(k * 3 - 3, 0)
			draw_line(a + Vector2(1, 1), a + Vector2(2, 9), Color(0.25, 0.15, 0.12, 0.6), 1.0)
			draw_line(a, a + Vector2(1, 8), Color(1.0, 0.97, 0.9, 0.95), 1.0)
