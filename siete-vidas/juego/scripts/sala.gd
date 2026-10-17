class_name Sala
extends Node2D
## Sala de prueba armada desde datos: paredes sólidas y muebles que se atraviesan desde abajo.
## Es un "blockout": formas simples para probar el movimiento antes de dibujar el escenario.

const ANCHO := 1280.0
const ALTO := 360.0
const COLOR_FONDO := Color("e8d6c3")
const COLOR_PARED := Color("7f3b30")
const COLOR_MUEBLE := Color("b0613f")

## [rectángulo, se atraviesa desde abajo, nombre]
const PIEZAS := [
	[Rect2(0, 330, 1280, 30), false, "Piso"],
	[Rect2(-20, 0, 20, 360), false, "Pared izquierda"],
	[Rect2(1280, 0, 20, 360), false, "Pared derecha"],
	[Rect2(150, 290, 140, 12), true, "Sofá"],
	[Rect2(380, 250, 110, 10), true, "Mesa"],
	[Rect2(560, 200, 90, 8), true, "Estante bajo"],
	[Rect2(720, 150, 90, 8), true, "Estante alto"],
	[Rect2(900, 110, 160, 10), true, "Repisa de la ventana"],
	[Rect2(1120, 270, 100, 60), false, "Caja de arena"],
]

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	var fondo := ColorRect.new()
	fondo.color = COLOR_FONDO
	fondo.size = Vector2(ANCHO, ALTO)
	fondo.z_index = -10
	add_child(fondo)
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2])
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = 0
	camara.limit_top = 0
	camara.limit_right = int(ANCHO)
	camara.limit_bottom = int(ALTO)


func _crear_pieza(rect: Rect2, atravesable: bool, nombre: String) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.name = nombre
	cuerpo.position = rect.position + rect.size / 2.0
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = rect.size
	forma.shape = caja
	forma.one_way_collision = atravesable
	cuerpo.add_child(forma)
	var dibujo := ColorRect.new()
	dibujo.color = COLOR_MUEBLE if atravesable else COLOR_PARED
	dibujo.size = rect.size
	dibujo.position = -rect.size / 2.0
	cuerpo.add_child(dibujo)
	add_child(cuerpo)
