class_name Sala
extends Node2D
## Primer nivel y demo: "La Gran Fuga", el apartamento de Valeria como tutorial.
## Cada mueble enseña un movimiento (avisos en AVISOS); al final A.S.P.I. cuida la puerta del balcón
## y escapar por el balcón da el poder Caer de Pie y termina la demo.
## Todo se arma desde datos; el dibujo es provisional y el fondo con parallax está en FondoApartamento.

## Escala del mundo: 1,21 px por cm (Felipe mide unos 55 cm de alto contando la cabeza; Valeria = 3 Felipes).
## Techo alto de casa antigua del Barrio Viejo: 3,5 m.
const ANCHO := 2700.0
## Hasta aquí llega la pared del apartamento; después está el balcón, al aire libre.
const PARED := 2500.0
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
	[Rect2(2120, 110, 20, SUELO - 110), false, "Pared del pasillo", "pared"],  # se pasa trepando la cortina
	[Rect2(2480, 176, 20, SUELO - 176), false, "Puerta del balcón", "puerta"],  # 2,05 m; se abre al apagar a A.S.P.I.
	[Rect2(2690, 330, 10, SUELO - 330), false, "Baranda", "baranda"],  # 78 cm
]

## Zonas para trepar (cortinas): mantener arriba dentro de ellas.
const TREPABLES := [Rect2(2078, 60, 36, SUELO - 60)]

## Avisos del tutorial: [desde x, hasta x, texto]. {acción} se cambia por la tecla o el botón en uso.
const AVISOS := [
	[0.0, 230.0, "{mover_izquierda} {mover_derecha} caminar  ·  mantén {zoomies} para correr"],
	[230.0, 520.0, "{saltar} para saltar al sofá"],
	[520.0, 690.0, "{interactuar} junto al vaso para tirarlo. Es tradición."],
	[690.0, 860.0, "Mantén {agacharse} para pasar bajo el aparador"],
	[860.0, 1095.0, "{zarpazo} para el zarpazo: el ratón de cuerda cae de uno"],
	[1095.0, 1205.0, "Caja de arena: punto de descanso. Aquí reapareces."],
	[1205.0, 1310.0, "Caja sospechosa: {zarpazo} la rompe"],
	[1310.0, 1440.0, "{saltar} dos veces para el Doble Salto"],
	[1440.0, 1560.0, "{interactuar} junto a la comida para comer: cura un corazón"],
	[1560.0, 1900.0, "Sube por la alacena para pasar el refrigerador"],
	[1900.0, 2142.0, "Mantén {mover_arriba} en la cortina para trepar"],
	[2142.0, 2480.0, "A.S.P.I. no te deja salir: tres {zarpazo} la apagan"],
	[2480.0, 2700.0, "El balcón. La libertad. Salta."],
]
## Calcetines coleccionables (uno más sale de la caja de cartón).
const CALCETINES := [Vector2(775, SUELO), Vector2(1850, 206)]
const CAJA_CARTON := Vector2(1260, SUELO)
const RATON := [Vector2(980, SUELO), 870.0, 1090.0]
const LASER := [Vector2(1500, SUELO), 1330.0, 1550.0]
## Punto de descanso: la caja de arena.
const DESCANSO := Rect2(1100, 380, 100, 50)
## Pasar esta x en el balcón termina la demo.
const SALIDA := 2560.0
const TOTAL_CALCETINES := 3

## Muestra la pantalla de título al empezar (las pruebas la apagan).
@export var mostrar_titulo := true

signal logro_desbloqueado(titulo: String)

## Comida en el apartamento: [posición sobre la superficie, tipo].
const COMIDA := [
	[Vector2(1435, SUELO), "plato"],  # croquetas en el piso de la cocina
	[Vector2(935, 200), "lata"],  # atún escondido en el estante alto
]

## Vaso sobre la mesa (se tira con el botón de acción).
const VASO := Vector2(670, 333)
## A.S.P.I.: [posición inicial, límite izquierdo y derecho de la patrulla].
const ASPI := [Vector2(2300, SUELO), 2160.0, 2460.0]

var logros: Array[String] = []
var calcetines := 0
var tiempo := 0.0
var terminado := false
var pantallas: Pantallas
var _piezas := {}
var _sonidos: Array[AudioStreamPlayer] = []
var _avisado_descanso := false

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	add_child(FondoApartamento.new(PARED, SUELO, ANCHO))
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
	aspi.apagado.connect(_abrir_balcon)
	add_child(aspi)
	var raton := Raton.new(RATON[1], RATON[2])
	raton.position = RATON[0]
	add_child(raton)
	var caja := CajaCarton.new()
	caja.position = CAJA_CARTON
	caja.rota.connect(_romper_caja)
	add_child(caja)
	var laser := Laser.new(LASER[1], LASER[2])
	laser.position = LASER[0]
	add_child(laser)
	for posicion: Vector2 in CALCETINES:
		_poner_calcetin(posicion)
	for zona: Rect2 in TREPABLES:
		var cortina := Node2D.new()
		cortina.name = "Cortina"
		cortina.z_index = -1
		cortina.draw.connect(_dibujar_cortina.bind(cortina, zona))
		add_child(cortina)
	felipe.zonas_trepables.assign(TREPABLES)
	felipe.sonido.connect(sonar)
	for i in 4:
		var reproductor := AudioStreamPlayer.new()
		add_child(reproductor)
		_sonidos.append(reproductor)
	pantallas = Pantallas.new()
	pantallas.reiniciar.connect(func() -> void: get_tree().reload_current_scene())
	$Interfaz.add_child(pantallas)
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
	medidores.pantallas = pantallas
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = 0
	camara.limit_top = 0
	camara.limit_right = int(ANCHO)
	camara.limit_bottom = int(ALTO)


func _crear_pieza(rect: Rect2, atravesable: bool, nombre: String, estilo: String) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.name = nombre
	_piezas[nombre] = cuerpo
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
		"pared":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("d8c4ad"))
			c.draw_rect(Rect2(-6, 0, tamano.x + 12, 8), MADERA_OSCURA)
		"puerta":
			c.draw_rect(Rect2(-4, -4, tamano.x + 8, tamano.y + 4), MADERA_OSCURA)
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("8fb3c4"))
			c.draw_rect(Rect2(2, 20, tamano.x - 4, tamano.y - 40), Color(0.85, 0.93, 1.0, 0.6))
		"baranda":
			c.draw_rect(Rect2(-190, 0, 200, 6), Color("2b2421"))
			var barrote := -184.0
			while barrote < 10.0:
				c.draw_rect(Rect2(barrote, 6, 3, tamano.y - 6), Color("2b2421"))
				barrote += 14.0
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
	sonar("logro")



func _physics_process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	# Punto de descanso: la caja de arena.
	if DESCANSO.has_point(felipe.global_position) and felipe.is_on_floor():
		felipe.punto_reaparicion = Vector2(DESCANSO.get_center().x, DESCANSO.position.y + 20)
		if not _avisado_descanso:
			_avisado_descanso = true
			sonar("logro")
	# Aviso del tutorial según dónde está Felipe.
	pantallas.aviso = ""
	for aviso: Array in AVISOS:
		if felipe.global_position.x >= aviso[0] and felipe.global_position.x < aviso[1]:
			pantallas.aviso = aviso[2]
			break
	if felipe.global_position.x > SALIDA:
		_terminar_demo()


func sonar(nombre: String) -> void:
	var ruta := "res://assets/sonidos/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	for reproductor in _sonidos:
		if not reproductor.playing:
			reproductor.stream = load(ruta)
			reproductor.play()
			return


func _poner_calcetin(posicion: Vector2) -> void:
	var calcetin := Calcetin.new()
	calcetin.position = posicion
	calcetin.recogido.connect(_recoger_calcetin)
	add_child(calcetin)


func _recoger_calcetin() -> void:
	calcetines += 1
	sonar("calcetin")
	if calcetines == TOTAL_CALCETINES:
		desbloquear_logro("Coleccionista de Calcetines")


func _romper_caja() -> void:
	sonar("caja")
	_poner_calcetin(CAJA_CARTON)


func _abrir_balcon() -> void:
	var puerta: Node = _piezas.get("Puerta del balcón")
	if puerta:
		puerta.queue_free()
		_piezas.erase("Puerta del balcón")
	desbloquear_logro("Desenchufada")


func _terminar_demo() -> void:
	terminado = true
	felipe.tiene_caer_de_pie = true
	desbloquear_logro("Caer de Pie")
	var segundos := int(tiempo)
	var datos := {
		"tiempo": "%d:%02d" % [segundos / 60, segundos % 60],
		"calcetines": "%d de %d" % [calcetines, TOTAL_CALCETINES],
		"logros": ", ".join(logros),
		"vidas": "%d" % (Felipe.VIDAS_MAX - felipe.vidas + (Felipe.VIDAS_MAX if felipe.tiene_collar else 0)),
	}
	get_tree().create_timer(2.0).timeout.connect(pantallas.mostrar_fin.bind(datos))


func _dibujar_cortina(c: Node2D, zona: Rect2) -> void:
	c.draw_rect(Rect2(zona.position.x - 6, zona.position.y - 6, zona.size.x + 12, 5), MADERA_OSCURA)
	var pliegue := 0.0
	while pliegue < zona.size.x:
		c.draw_rect(Rect2(zona.position.x + pliegue, zona.position.y, 6, zona.size.y - 4), Color("c46a5a") if int(pliegue / 6.0) % 2 == 0 else Color("a8564a"))
		pliegue += 6.0
