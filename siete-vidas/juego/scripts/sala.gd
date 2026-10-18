class_name Sala
extends Node2D
## Sala armada desde datos: piezas sólidas y muebles que se atraviesan desde abajo.
## El dibujo es provisional (prueba de concepto); el fondo con parallax está en FondoApartamento.

## Escala del mundo: 1,21 px por cm (Felipe mide unos 55 cm de alto contando la cabeza; Valeria = 3 Felipes).
## Techo alto de casa antigua del Barrio Viejo: 3,5 m.
const ANCHO := 1920.0
const SUELO := 424.0
const ALTO := SUELO + 30.0
const TELA := Color("4f6d7a")
const MADERA := Color("b0613f")
const MADERA_OSCURA := Color("6e3a26")
const LOMOS := [Color("c8576b"), Color("6f8f8a"), Color("d9a65b"), Color("5b4d7a")]

## [rectángulo, se atraviesa desde abajo, nombre, estilo de dibujo]. Entre paréntesis, la altura real del mueble.
const PIEZAS := [
	[Rect2(0, SUELO, ANCHO, 30), false, "Piso", "invisible"],
	[Rect2(-20, 0, 20, ALTO), false, "Pared izquierda", "invisible"],
	[Rect2(ANCHO, 0, 20, ALTO), false, "Pared derecha", "invisible"],
	[Rect2(0, -20, ANCHO, 20), false, "Techo", "invisible"],
	[Rect2(260, 370, 230, 10), true, "Sofá", "sofa"],  # asiento a 45 cm
	[Rect2(550, 333, 133, 8), true, "Mesa", "mesa"],  # 75 cm
	[Rect2(700, SUELO - 98, 150, 62), false, "Aparador", "aparador"],  # 81 cm, con 30 cm libres debajo: se pasa agachado
	[Rect2(730, 255, 110, 8), true, "Estante bajo", "repisa"],  # 1,40 m
	[Rect2(880, 200, 110, 8), true, "Estante alto", "repisa"],  # 1,85 m
	[Rect2(1040, 303, 220, 8), true, "Repisa de la ventana", "repisa"],  # 1 m
	[Rect2(1100, 400, 100, 24), false, "Caja de arena", "caja"],  # 20 cm
	[Rect2(1180, 90, 100, 8), true, "Repisa alta", "repisa"],  # 2,75 m
	[Rect2(1320, 206, 110, 10), true, "Librero", "librero"],  # 1,80 m
	[Rect2(1480, 345, 50, 8), true, "Banco", "mesa"],  # 65 cm
	[Rect2(1460, 240, 70, 8), true, "Repisa de la lámpara", "repisa"],  # 1,52 m
	[Rect2(1560, 164, 220, 10), true, "Alacena", "alacena"],  # 2,15 m
	[Rect2(1560, 315, 220, 109), false, "Mesón", "meson"],  # 90 cm
	[Rect2(1800, 206, 100, 218), false, "Refrigerador", "refri"],  # 1,80 m
]

signal logro_desbloqueado(titulo: String)

## Comida en el apartamento: [posición sobre la superficie, tipo].
const COMIDA := [
	[Vector2(1435, SUELO), "plato"],  # croquetas en el piso de la cocina
	[Vector2(935, 200), "lata"],  # atún escondido en el estante alto
]

## Vaso sobre la mesa (se tira con el botón de acción).
const VASO := Vector2(670, 333)
## A.S.P.I.: [posición inicial, límite izquierdo y derecho de la patrulla].
const ASPI := [Vector2(1000, SUELO), 900.0, 1090.0]

var logros: Array[String] = []

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	add_child(FondoApartamento.new(ANCHO, SUELO))
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2], pieza[3])
	for comida: Array in COMIDA:
		var objeto := Comida.new(comida[1])
		objeto.position = comida[0]
		add_child(objeto)
	var vaso := Vaso.new(SUELO)
	vaso.position = VASO
	add_child(vaso)
	var aspi := Aspi.new(ASPI[1], ASPI[2])
	aspi.position = ASPI[0]
	add_child(aspi)
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
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
	if atravesable:
		cuerpo.collision_layer = 0
		cuerpo.set_collision_layer_value(Felipe.CAPA_ATRAVESABLE, true)
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
			c.draw_rect(Rect2(0, -48, tamano.x, 54), TELA.darkened(0.2))
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
			c.draw_rect(Rect2(0, 0, tamano.x, 85), MADERA)
			var puerta := 6.0
			while puerta < tamano.x - 10:
				c.draw_rect(Rect2(puerta, 14, 66, 70), MADERA.lightened(0.1))
				c.draw_rect(Rect2(puerta + 56, 44, 4, 10), MADERA_OSCURA)
				puerta += 74
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA_OSCURA)
		"aparador":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			c.draw_rect(Rect2(-3, 0, tamano.x + 6, 6), MADERA_OSCURA)
			for cajon: float in [8.0, tamano.x / 2 + 4]:
				c.draw_rect(Rect2(cajon, 14, tamano.x / 2 - 12, tamano.y - 22), MADERA.lightened(0.1))
				c.draw_rect(Rect2(cajon + tamano.x / 4 - 10, 28, 8, 3), MADERA_OSCURA)
			for pata: float in [6.0, tamano.x - 12.0]:
				c.draw_rect(Rect2(pata, tamano.y, 6, hasta_suelo - tamano.y), MADERA_OSCURA)
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


func desbloquear_logro(titulo: String) -> void:
	if titulo in logros:
		return
	logros.append(titulo)
	logro_desbloqueado.emit(titulo)
