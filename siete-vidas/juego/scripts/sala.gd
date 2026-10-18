class_name Sala
extends Node2D
## Primer nivel y demo: "La Gran Fuga", el dúplex de Valeria como tutorial (diseño en siete-vidas/diseno/nivel-01-gran-fuga.md).
## Cada mecánica se enseña sin peligro, se pone a prueba y luego se usa de otra forma; la meta (el balcón) se muestra
## al empezar; la escalera es un atajo que se abre desde arriba; A.S.P.I. es un examen de todo lo aprendido.
## Todo se arma desde datos; el dibujo es provisional y el fondo con parallax está en FondoApartamento.

## Escala del mundo: 1,21 px por cm (Felipe mide unos 55 cm de alto contando la cabeza; Valeria = 3 Felipes).
## Casa antigua del Barrio Viejo: dos pisos de 3,5 m (424 px) con un entrepiso de 24 px.
const ANCHO := 3080.0
const PISO_ALTO := 424.0
const TECHO_BAJO := PISO_ALTO + 24.0
const SUELO := TECHO_BAJO + 424.0
const ALTO := SUELO + 30.0
const TELA := Color("4f6d7a")
const MADERA := Color("b0613f")
const MADERA_OSCURA := Color("6e3a26")
const LOMOS := [Color("c8576b"), Color("6f8f8a"), Color("d9a65b"), Color("5b4d7a")]
const LADRILLO := Color("8f4a3c")

## Habitaciones (para el fondo): [rectángulo, estilo de pared]. Lo que queda fuera es muro o exterior.
const HABITACIONES := [
	[Rect2(0, TECHO_BAJO, 1540, SUELO - TECHO_BAJO), "sala"],
	[Rect2(1540, 0, 346, SUELO), "escalera"],
	[Rect2(1886, TECHO_BAJO, 594, SUELO - TECHO_BAJO), "cocina"],
	[Rect2(1886, 0, 594, PISO_ALTO), "dormitorio"],
	[Rect2(2480, 0, 416, PISO_ALTO), "pasillo"],
]
## Ventanas: huecos de la pared por donde se ve la ciudad.
const VENTANAS := [Rect2(290, 600, 180, 145), Rect2(2205, 540, 90, 150), Rect2(2560, 90, 150, 120)]

## [rectángulo, se atraviesa desde abajo, nombre, estilo de dibujo]. Entre paréntesis, la altura real.
const PIEZAS := [
	[Rect2(0, SUELO, ANCHO, 30), false, "Piso", "invisible"],
	[Rect2(-20, 0, 20, ALTO), false, "Pared izquierda", "invisible"],
	[Rect2(ANCHO, 0, 20, ALTO), false, "Pared derecha", "invisible"],
	[Rect2(0, -20, ANCHO, 20), false, "Techo", "invisible"],
	[Rect2(0, 0, 1540, TECHO_BAJO), false, "Muro sobre la sala", "muro"],
	[Rect2(2480, TECHO_BAJO, 600, SUELO - TECHO_BAJO), false, "Muro bajo el balcón", "muro"],
	[Rect2(1886, PISO_ALTO, 334, 24), false, "Entrepiso del dormitorio", "entrepiso"],
	[Rect2(2270, PISO_ALTO, 810, 24), false, "Entrepiso del pasillo", "entrepiso"],
	# Planta baja: sala.
	[Rect2(260, SUELO - 54, 230, 10), true, "Sofá", "sofa"],  # asiento a 45 cm
	[Rect2(560, SUELO - 55, 40, 8), true, "Silla", "silla"],  # 45 cm
	[Rect2(610, SUELO - 91, 133, 8), true, "Mesa", "mesa"],  # 75 cm
	[Rect2(755, SUELO - 55, 40, 8), true, "Silla 2", "silla"],
	[Rect2(880, SUELO - 79, 50, 8), true, "Banco", "mesa"],  # 65 cm, sobre los juguetes
	[Rect2(1010, SUELO - 98, 150, 62), false, "Aparador", "aparador"],  # 81 cm, con 30 cm libres debajo
	[Rect2(1400, SUELO - 24, 100, 24), false, "Caja de arena", "caja"],  # 20 cm
	[Rect2(1560, SUELO - 260, 50, 8), true, "Repisa de la escalera", "repisa"],  # 2,15 m; se alcanza desde la escalera
	# Planta baja: cocina.
	[Rect2(1960, SUELO - 109, 200, 109), false, "Mesón", "meson"],  # 90 cm
	[Rect2(2400, SUELO - 218, 80, 218), false, "Refrigerador", "refri"],  # 1,80 m
	# Planta alta: dormitorio de Valeria.
	[Rect2(1970, PISO_ALTO - 66, 240, 30), false, "Cama", "cama"],  # 55 cm, con 30 cm libres debajo
	[Rect2(1970, PISO_ALTO - 120, 30, 8), true, "Cabecera", "repisa"],  # 1 m
	[Rect2(2280, PISO_ALTO - 97, 80, 97), false, "Cómoda", "comoda"],  # 80 cm
	[Rect2(2380, PISO_ALTO - 218, 70, 218), false, "Ropero", "ropero"],  # 1,80 m
	# Planta alta: pasillo de A.S.P.I. y balcón.
	[Rect2(2530, PISO_ALTO - 55, 40, 8), true, "Silla del pasillo", "silla"],
	[Rect2(2600, PISO_ALTO - 160, 200, 8), true, "Repisa de las macetas", "repisa"],  # 1,30 m
	[Rect2(2880, PISO_ALTO - 248, 16, 248), false, "Puerta del balcón", "puerta"],  # 2,05 m; se abre al apagar a A.S.P.I.
	[Rect2(3070, PISO_ALTO - 94, 10, 94), false, "Baranda", "baranda"],  # 78 cm
]
## Escalera: escalones que se atraviesan desde abajo, de la sala al dormitorio.
const ESCALERA_X := 1550.0
const ESCALONES := 14
const ANCHO_ESCALON := 24.0
## Puerta del dormitorio, arriba de la escalera: se abre desde el dormitorio (atajo de vuelta).
const PUERTA_DORMITORIO := Rect2(1886, PISO_ALTO - 248, 16, 248)
## Piezas de juguete en la alfombra: quitan un corazón.
const PELIGROS := [Rect2(805, SUELO - 6, 180, 6)]
## Zonas para trepar: la cortina de la cocina sube por el hueco del entrepiso hasta el dormitorio.
const TREPABLES := [Rect2(2227, PISO_ALTO - 40, 36, SUELO - PISO_ALTO + 40)]

## Avisos del tutorial: [rectángulo donde aparece, texto]. Solo la primera vez; {acción} es la tecla o el botón en uso.
const AVISOS := [
	[Rect2(0, TECHO_BAJO, 250, 424), "{mover_izquierda} {mover_derecha} caminar · {saltar} saltar"],
	[Rect2(540, TECHO_BAJO, 220, 424), "{interactuar} para tirar cosas"],
	[Rect2(990, TECHO_BAJO, 190, 424), "Mantén {agacharse} para pasar por debajo"],
	[Rect2(1180, TECHO_BAJO, 200, 424), "{zarpazo} zarpazo"],
	[Rect2(1400, TECHO_BAJO, 140, 424), "Caja de arena: aquí reapareces"],
	[Rect2(2180, TECHO_BAJO, 120, 424), "Mantén {mover_arriba} para trepar"],
	[Rect2(1886, 0, 84, PISO_ALTO), "Cojín: aquí reapareces"],
	[Rect2(2480, 0, 140, PISO_ALTO), "A.S.P.I. solo se aturde si le cae algo encima"],
]
## Calcetines: sobre la repisa de la escalera, en el clóset (el láser lleva ahí) y sobre el ropero.
const CALCETINES := [Vector2(1585, SUELO - 260), Vector2(1925, PISO_ALTO), Vector2(2415, PISO_ALTO - 218)]
const CAJA_CARTON := Vector2(2330, SUELO)
## Ratones de cuerda: [posición, límite izquierdo, límite derecho].
const RATONES := [
	[Vector2(1300, SUELO), 1260.0, 1390.0],
	[Vector2(2000, SUELO - 109), 1965.0, 2060.0],
	[Vector2(2110, SUELO - 109), 2065.0, 2155.0],
	[Vector2(2100, PISO_ALTO), 2020.0, 2270.0],
]
const LASER := [Vector2(2100, PISO_ALTO), 1905.0, 2000.0]
## Objetos que se tiran con el botón de acción: [posición, tipo, piso donde caen].
const TIRABLES := [
	[Vector2(680, SUELO - 91), "vaso", SUELO],
	[Vector2(2300, PISO_ALTO - 97), "rollo", PISO_ALTO],
	[Vector2(2640, PISO_ALTO - 160), "maceta", PISO_ALTO],
	[Vector2(2700, PISO_ALTO - 160), "maceta", PISO_ALTO],
	[Vector2(2760, PISO_ALTO - 160), "maceta", PISO_ALTO],
]
## Comida: [posición, tipo]. El plato sale de la caja de cartón.
const COMIDA := [[Vector2(2340, PISO_ALTO - 97), "lata"]]
const ASPI := [Vector2(2700, PISO_ALTO), 2560.0, 2860.0]
## Puntos de descanso: la caja de arena y el cojín del dormitorio (al final del atajo, antes de A.S.P.I.).
const DESCANSOS := [Rect2(1400, SUELO - 40, 100, 50), Rect2(1906, PISO_ALTO - 40, 60, 50)]
## Orden en que se recorren las habitaciones (las reglas de diseño lo usan para comprobar que se enseña antes de probar).
const RUTA := ["sala", "escalera", "cocina", "dormitorio", "pasillo"]
## Pasar esta x en el balcón termina la demo.
const SALIDA := 2930.0
const TOTAL_CALCETINES := 3

signal logro_desbloqueado(titulo: String)

## Índice en RUTA de la habitación que contiene el punto, mirando un píxel arriba para que el piso cuente (-1 si está fuera).
static func orden_en_ruta(punto: Vector2) -> int:
	for habitacion: Array in HABITACIONES:
		if (habitacion[0] as Rect2).has_point(punto - Vector2(0, 1)):
			return RUTA.find(habitacion[1])
	return -1


## Muestra la pantalla de título al empezar (las pruebas la apagan).
@export var mostrar_titulo := true
## Cruzarse con A.S.P.I. arranca la pelea de jefe (la prueba de mecánicas la apaga para probar a A.S.P.I. sola).
@export var batalla_con_jefe := true
## Las piezas de juguete hacen daño (la prueba de movimiento las apaga).
@export var peligros_activos := true

var logros: Array[String] = []
var calcetines := 0
var tiempo := 0.0
var terminado := false
var pantallas: Pantallas
var batalla: BatallaAspi
var _piezas := {}
var _sonidos: Array[AudioStreamPlayer] = []
var _avisos_vistos := {}
var _tiempo_peligro := 0.0

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	add_child(FondoApartamento.new(ANCHO, ALTO))
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2], pieza[3])
	for i in ESCALONES:
		var escalon := Rect2(ESCALERA_X + i * ANCHO_ESCALON, SUELO - 32.0 * (i + 1), ANCHO_ESCALON, 8)
		_crear_pieza(escalon, true, "Escalón %d" % (i + 1), "escalon")
	var puerta := PuertaDormitorio.new(PUERTA_DORMITORIO)
	puerta.abierta.connect(func() -> void: desbloquear_logro("Atajo de Gato"))
	add_child(puerta)
	for comida: Array in COMIDA:
		var objeto := Comida.new(comida[1])
		objeto.position = comida[0]
		add_child(objeto)
	for tirable: Array in TIRABLES:
		var objeto := Vaso.new(tirable[2], tirable[1])
		objeto.position = tirable[0]
		add_child(objeto)
	var aspi := Aspi.new(ASPI[1], ASPI[2])
	aspi.position = ASPI[0]
	aspi.necesita_aturdir = true
	aspi.apagado.connect(_abrir_balcon)
	add_child(aspi)
	if batalla_con_jefe:
		batalla = BatallaAspi.new(aspi, felipe, self)
		add_child(batalla)
	for datos: Array in RATONES:
		var raton := Raton.new(datos[1], datos[2])
		raton.position = datos[0]
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
	var decorado := Node2D.new()
	decorado.name = "Decorado"
	decorado.z_index = -1
	decorado.draw.connect(_dibujar_decorado.bind(decorado))
	add_child(decorado)
	var ropa := Node2D.new()
	ropa.name = "Ropa del closet"
	ropa.z_index = 5
	ropa.draw.connect(_dibujar_ropa.bind(ropa))
	add_child(ropa)
	felipe.zonas_trepables.assign(TREPABLES)
	felipe.sonido.connect(sonar)
	for i in 4:
		var reproductor := AudioStreamPlayer.new()
		add_child(reproductor)
		_sonidos.append(reproductor)
	pantallas = Pantallas.new()
	pantallas.reiniciar.connect(func() -> void: get_tree().reload_current_scene())
	pantallas.empezar.connect(_mostrar_meta)
	$Interfaz.add_child(pantallas)
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
	medidores.pantallas = pantallas
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = 0
	camara.limit_top = 0
	camara.limit_right = int(ANCHO)
	camara.limit_bottom = int(ALTO)


func _physics_process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	# Puntos de descanso: la caja de arena y el cojín.
	for descanso: Rect2 in DESCANSOS:
		if descanso.has_point(felipe.global_position) and felipe.is_on_floor():
			var punto := Vector2(descanso.get_center().x, descanso.position.y + 10)
			if felipe.punto_reaparicion != punto:
				felipe.punto_reaparicion = punto
				sonar("logro")
	# Piezas de juguete: duelen al pisarlas.
	_tiempo_peligro = maxf(0.0, _tiempo_peligro - delta)
	for peligro: Rect2 in PELIGROS if peligros_activos else []:
		if peligro.grow(2).has_point(felipe.global_position) and felipe.is_on_floor():
			felipe.recibir_dano(1, felipe.global_position.x - felipe.mirando * 10.0)
	_actualizar_aviso()
	if felipe.global_position.x > SALIDA and felipe.global_position.y < TECHO_BAJO:
		_terminar_demo()


## Cada aviso se muestra solo la primera vez que Felipe entra en su zona.
func _actualizar_aviso() -> void:
	pantallas.aviso = ""
	for i in AVISOS.size():
		var zona: Rect2 = AVISOS[i][0].grow_individual(0, 0, 0, 4)
		var dentro := zona.has_point(felipe.global_position)
		if dentro and not _avisos_vistos.get(i, false):
			pantallas.aviso = AVISOS[i][1]
			_avisos_vistos[-1 - i] = true
		elif not dentro and _avisos_vistos.get(-1 - i, false):
			_avisos_vistos[i] = true


## Al empezar, la cámara muestra un momento el balcón abierto: la meta.
func _mostrar_meta() -> void:
	var camara_meta := Camera2D.new()
	camara_meta.name = "Camara de la meta"
	camara_meta.position = Vector2(SALIDA, PISO_ALTO - 120)
	camara_meta.limit_left = 0
	camara_meta.limit_top = 0
	camara_meta.limit_right = int(ANCHO)
	camara_meta.limit_bottom = int(ALTO)
	add_child(camara_meta)
	camara_meta.make_current()
	pantallas.aviso_fijo = "La libertad está allá arriba."
	await get_tree().create_timer(2.2).timeout
	pantallas.aviso_fijo = ""
	felipe.get_node("Camara").make_current()
	camara_meta.queue_free()


func sonar(nombre: String) -> void:
	var ruta := "res://assets/sonidos/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	for reproductor in _sonidos:
		if not reproductor.playing:
			reproductor.stream = load(ruta)
			reproductor.play()
			return


func desbloquear_logro(titulo: String) -> void:
	if titulo in logros:
		return
	logros.append(titulo)
	logro_desbloqueado.emit(titulo)
	sonar("logro")


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
	var plato := Comida.new("plato")
	plato.position = CAJA_CARTON
	add_child(plato)


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


## Piso sobre el que está apoyado un mueble (planta alta o baja).
static func piso_bajo(y: float) -> float:
	return PISO_ALTO if y < PISO_ALTO else SUELO


## Dibuja el mueble provisional. (0, 0) es la esquina de arriba a la izquierda de la parte donde se para Felipe.
func _dibujar_mueble(c: Node2D, tamano: Vector2, estilo: String) -> void:
	var y := (c.get_parent() as Node2D).position.y
	var hasta_suelo := piso_bajo(y) - y
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
		"silla":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			c.draw_rect(Rect2(0, -50, 6, 50), MADERA_OSCURA)
			c.draw_rect(Rect2(2, tamano.y, 4, hasta_suelo - tamano.y), MADERA_OSCURA)
			c.draw_rect(Rect2(tamano.x - 6, tamano.y, 4, hasta_suelo - tamano.y), MADERA_OSCURA)
		"repisa", "escalon":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			if estilo == "escalon":
				c.draw_rect(Rect2(0, tamano.y, tamano.x, 24), MADERA_OSCURA)
			else:
				for x: float in [4.0, tamano.x - 16.0]:
					c.draw_colored_polygon(PackedVector2Array([Vector2(x, tamano.y), Vector2(x + 12, tamano.y), Vector2(x, tamano.y + 14)]), MADERA_OSCURA)
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
			# Alacenas altas.
			c.draw_rect(Rect2(0, -230, tamano.x, 80), MADERA)
			var puerta := 6.0
			while puerta < tamano.x - 10:
				c.draw_rect(Rect2(puerta, -222, 58, 64), MADERA.lightened(0.1))
				puerta += 66
		"refri":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("e9eef0"))
			c.draw_rect(Rect2(0, 70, tamano.x, 3), Color("aab3b8"))
			c.draw_rect(Rect2(tamano.x - 14, 30, 5, 30), Color("aab3b8"))
			c.draw_rect(Rect2(tamano.x - 14, 90, 5, 40), Color("aab3b8"))
			c.draw_rect(Rect2(14, 100, 20, 26), Color("f2d36b"))
		"cama":
			c.draw_rect(Rect2(0, -6, tamano.x, 12), Color("f3efe8"))
			c.draw_rect(Rect2(0, 6, tamano.x, tamano.y - 6), Color("8f6aa8"))
			c.draw_rect(Rect2(tamano.x - 50, -14, 40, 12), Color("f3efe8"))
			for pata: float in [4.0, tamano.x - 10.0]:
				c.draw_rect(Rect2(pata, tamano.y, 6, hasta_suelo - tamano.y), MADERA_OSCURA)
		"comoda":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			for fila in 3:
				c.draw_rect(Rect2(5, 8 + fila * 29, tamano.x - 10, 24), MADERA.lightened(0.1))
				c.draw_rect(Rect2(tamano.x / 2 - 4, 18 + fila * 29, 8, 3), MADERA_OSCURA)
		"ropero":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA_OSCURA)
			c.draw_rect(Rect2(4, 6, tamano.x / 2 - 6, tamano.y - 12), MADERA)
			c.draw_rect(Rect2(tamano.x / 2 + 2, 6, tamano.x / 2 - 6, tamano.y - 12), MADERA)
		"entrepiso":
			c.draw_rect(Rect2(0, 0, tamano.x, 6), Color("9a5b3c"))
			c.draw_rect(Rect2(0, 6, tamano.x, tamano.y - 6), Color("5a3a2c"))
		"muro":
			c.draw_rect(Rect2(Vector2.ZERO, tamano), LADRILLO.darkened(0.35))
			var fila_l := 0.0
			while fila_l < tamano.y:
				var desfase := 0.0 if int(fila_l / 14.0) % 2 == 0 else 14.0
				var col := -desfase
				while col < tamano.x:
					c.draw_rect(Rect2(maxf(col + 1, 0), fila_l + 1, minf(26, tamano.x - col - 1), 12), LADRILLO.darkened(0.15))
					col += 28.0
				fila_l += 14.0
		"puerta":
			c.draw_rect(Rect2(-4, -4, tamano.x + 8, tamano.y + 4), MADERA_OSCURA)
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("8fb3c4"))
			c.draw_rect(Rect2(2, 20, tamano.x - 4, tamano.y - 40), Color(0.85, 0.93, 1.0, 0.6))
		"baranda":
			c.draw_rect(Rect2(-180, 0, 190, 6), Color("2b2421"))
			var barrote := -174.0
			while barrote < 10.0:
				c.draw_rect(Rect2(barrote, 6, 3, tamano.y - 6), Color("2b2421"))
				barrote += 14.0
		"caja":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("5f8fa8"))
			c.draw_rect(Rect2(4, 0, tamano.x - 8, 6), Color("d9c7a0"))
		_:
			c.draw_rect(Rect2(Vector2.ZERO, tamano), MADERA)


## Decorado sin colisión: piezas de juguete, lámpara de pie (hito del descanso) y macetas del balcón.
func _dibujar_decorado(c: Node2D) -> void:
	var colores := [Color("e0483b"), Color("5fa8d3"), Color("f2d36b"), Color("5fd18a")]
	for peligro: Rect2 in PELIGROS:
		c.draw_rect(Rect2(peligro.position.x - 10, SUELO - 2, peligro.size.x + 20, 4), Color("c8576b", 0.5))
		var x := peligro.position.x
		var i := 0
		while x < peligro.end.x:
			c.draw_rect(Rect2(x, SUELO - 5 - (i % 2) * 2, 8, 5 + (i % 2) * 2), colores[i % colores.size()])
			x += 13.0
			i += 1
	# Zanca y pasamanos de la escalera: los escalones se leen como una sola pieza.
	var pie := Vector2(ESCALERA_X, SUELO)
	var cima := Vector2(ESCALERA_X + ESCALONES * ANCHO_ESCALON, SUELO - 32.0 * ESCALONES)
	c.draw_colored_polygon(PackedVector2Array([pie, cima + Vector2(0, 8), cima + Vector2(0, 40), pie + Vector2(40, 0)]), MADERA_OSCURA.darkened(0.2))
	c.draw_line(pie + Vector2(0, -60), cima + Vector2(0, -60), MADERA_OSCURA, 4)
	for i in range(0, ESCALONES, 2):
		var x := ESCALERA_X + i * ANCHO_ESCALON + ANCHO_ESCALON / 2
		var y := SUELO - 32.0 * (i + 1)
		c.draw_line(Vector2(x, y), Vector2(x, y - 60 + 16), MADERA_OSCURA, 2)
	# Cojín del dormitorio: segundo punto de descanso.
	var cojin: Rect2 = DESCANSOS[1]
	c.draw_rect(Rect2(cojin.position.x + 4, PISO_ALTO - 10, cojin.size.x - 8, 10), Color("c8576b"))
	c.draw_rect(Rect2(cojin.position.x + 8, PISO_ALTO - 13, cojin.size.x - 16, 4), Color("e07a85"))
	# Lámpara de pie encendida junto a la caja de arena.
	c.draw_rect(Rect2(1512, SUELO - 160, 4, 160), MADERA_OSCURA)
	c.draw_colored_polygon(PackedVector2Array([Vector2(1498, SUELO - 160), Vector2(1530, SUELO - 160), Vector2(1524, SUELO - 185), Vector2(1504, SUELO - 185)]), Color("f2d36b"))
	c.draw_circle(Vector2(1514, SUELO - 150), 40.0, Color(1, 0.85, 0.5, 0.12))
	# Macetas en la baranda del balcón.
	for x: float in [2930.0, 2990.0, 3040.0]:
		c.draw_rect(Rect2(x - 8, PISO_ALTO - 16, 16, 16), Color("b0613f"))
		c.draw_circle(Vector2(x, PISO_ALTO - 22), 9.0, Color("5f8f5a"))


## Ropa colgada del clóset, delante de Felipe: esconde el calcetín secreto.
func _dibujar_ropa(c: Node2D) -> void:
	c.draw_rect(Rect2(1902, PISO_ALTO - 200, 60, 4), MADERA_OSCURA)
	var colores := [Color("c46a5a"), Color("5f8fa8"), Color("d9a65b")]
	for i in 3:
		c.draw_rect(Rect2(1906 + i * 18, PISO_ALTO - 196, 16, 150 - i * 20), Color(colores[i], 0.92))


func _dibujar_cortina(c: Node2D, zona: Rect2) -> void:
	c.draw_rect(Rect2(zona.position.x - 6, zona.position.y, zona.size.x + 12, 5), MADERA_OSCURA)
	var pliegue := 0.0
	while pliegue < zona.size.x:
		c.draw_rect(Rect2(zona.position.x + pliegue, zona.position.y + 4, 6, zona.size.y - 8), Color("c46a5a") if int(pliegue / 6.0) % 2 == 0 else Color("a8564a"))
		pliegue += 6.0
