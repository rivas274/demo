class_name Sala
extends Node2D
## Sala armada desde datos: piezas sólidas y muebles que se atraviesan desde abajo.
## El dibujo es provisional (prueba de concepto); el fondo con parallax está en FondoApartamento.

const ANCHO := 1920.0
const ALTO := 540.0
const SUELO := 510.0
const TELA := Color("4f6d7a")
const MADERA := Color("b0613f")
const MADERA_OSCURA := Color("6e3a26")
const LOMOS := [Color("c8576b"), Color("6f8f8a"), Color("d9a65b"), Color("5b4d7a")]

## [rectángulo, se atraviesa desde abajo, nombre, estilo de dibujo]
const PIEZAS := [
	[Rect2(0, SUELO, ANCHO, 30), false, "Piso", "invisible"],
	[Rect2(-20, 0, 20, ALTO), false, "Pared izquierda", "invisible"],
	[Rect2(ANCHO, 0, 20, ALTO), false, "Pared derecha", "invisible"],
	[Rect2(0, -20, ANCHO, 20), false, "Techo", "invisible"],
	[Rect2(150, 470, 140, 10), true, "Sofá", "sofa"],
	[Rect2(380, 430, 110, 8), true, "Mesa", "mesa"],
	[Rect2(560, 380, 90, 8), true, "Estante bajo", "repisa"],
	[Rect2(720, 330, 90, 8), true, "Estante alto", "repisa"],
	[Rect2(870, 290, 180, 8), true, "Repisa de la ventana", "repisa"],
	[Rect2(1000, 480, 80, 30), false, "Caja de arena", "caja"],
	[Rect2(1110, 250, 90, 10), true, "Librero", "librero"],
	[Rect2(1250, 200, 80, 8), true, "Repisa de la lámpara", "repisa"],
	[Rect2(1320, 465, 40, 8), true, "Banco", "mesa"],
	[Rect2(1380, 150, 300, 10), true, "Alacena", "alacena"],
	[Rect2(1400, 430, 280, 80), false, "Mesón", "meson"],
	[Rect2(1740, 300, 100, 210), false, "Refrigerador", "refri"],
]

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	add_child(FondoApartamento.new(ANCHO, SUELO))
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2], pieza[3])
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = 0
	camara.limit_top = 0
	camara.limit_right = int(ANCHO)
	camara.limit_bottom = int(ALTO)


func _crear_pieza(rect: Rect2, atravesable: bool, nombre: String, estilo: String) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.name = nombre
	cuerpo.position = rect.position
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = rect.size
	forma.shape = caja
	forma.position = rect.size / 2.0
	forma.one_way_collision = atravesable
	cuerpo.add_child(forma)
	if estilo != "invisible":
		var dibujo := Node2D.new()
		dibujo.z_index = -1
		dibujo.draw.connect(_dibujar_mueble.bind(dibujo, rect.size, estilo))
		cuerpo.add_child(dibujo)
	add_child(cuerpo)


## Dibuja el mueble provisional. (0, 0) es la esquina de arriba a la izquierda de la parte donde se para Felipe.
func _dibujar_mueble(c: Node2D, tamano: Vector2, estilo: String) -> void:
	var hasta_suelo := SUELO - (c.get_parent() as Node2D).position.y
	match estilo:
		"sofa":
			c.draw_rect(Rect2(0, -34, tamano.x, 40), TELA.darkened(0.2))
			c.draw_rect(Rect2(0, 0, tamano.x, hasta_suelo - 6), TELA)
			c.draw_rect(Rect2(tamano.x / 2 - 1, 0, 2, 14), TELA.darkened(0.3))
			c.draw_rect(Rect2(-10, -10, 14, hasta_suelo + 4), TELA.darkened(0.1))
			c.draw_rect(Rect2(tamano.x - 4, -10, 14, hasta_suelo + 4), TELA.darkened(0.1))
		"mesa":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			c.draw_rect(Rect2(6, tamano.y, 6, hasta_suelo - tamano.y), MADERA_OSCURA)
			c.draw_rect(Rect2(tamano.x - 12, tamano.y, 6, hasta_suelo - tamano.y), MADERA_OSCURA)
		"repisa":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			for x: float in [10.0, tamano.x - 22.0]:
				c.draw_colored_polygon(PackedVector2Array([Vector2(x, tamano.y), Vector2(x + 12, tamano.y), Vector2(x, tamano.y + 14)]), MADERA_OSCURA)
		"librero":
			c.draw_rect(Rect2(0, 0, tamano.x, hasta_suelo), MADERA_OSCURA)
			var fila := 14.0
			while fila < hasta_suelo - 10:
				c.draw_rect(Rect2(6, fila, tamano.x - 12, 40), MADERA.darkened(0.35))
				var x := 8.0
				var i := 0
				while x < tamano.x - 14:
					c.draw_rect(Rect2(x, fila + 12 + (i % 3) * 3, 7, 28 - (i % 3) * 3), LOMOS[i % LOMOS.size()])
					x += 9
					i += 1
				fila += 52
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
		"alacena":
			c.draw_rect(Rect2(0, 0, tamano.x, 90), MADERA)
			var puerta := 6.0
			while puerta < tamano.x - 10:
				c.draw_rect(Rect2(puerta, 14, 66, 70), MADERA.lightened(0.1))
				c.draw_rect(Rect2(puerta + 56, 44, 4, 10), MADERA_OSCURA)
				puerta += 74
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA_OSCURA)
		"meson":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("d8cbb8"))
			c.draw_rect(Rect2(-4, 0, tamano.x + 8, 8), Color("8a8f96"))
			var cajon := 8.0
			while cajon < tamano.x - 10:
				c.draw_rect(Rect2(cajon, 16, 60, 56), Color("c4b6a2"))
				cajon += 68
		"refri":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("e9eef0"))
			c.draw_rect(Rect2(0, 70, tamano.x, 3), Color("aab3b8"))
			c.draw_rect(Rect2(tamano.x - 14, 30, 5, 30), Color("aab3b8"))
			c.draw_rect(Rect2(tamano.x - 14, 90, 5, 40), Color("aab3b8"))
			c.draw_rect(Rect2(20, 100, 24, 30), Color("f2d36b"))
		"caja":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("5f8fa8"))
			c.draw_rect(Rect2(4, 0, tamano.x - 8, 6), Color("d9c7a0"))
		_:
			c.draw_rect(Rect2(Vector2.ZERO, tamano), MADERA)
