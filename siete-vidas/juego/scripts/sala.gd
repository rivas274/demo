class_name Sala
extends Node2D
## Primer nivel y demo: "La Gran Fuga", la casa de Valeria como tutorial (diseño en siete-vidas/diseno/nivel-01-gran-fuga.md).
## Cada habitación es un espacio aparte y se pasa de una a otra por puertas (fundido a negro; la cámara queda dentro
## del cuarto). Se sube por la escalera, bloqueada por dos rejas para bebés: se cruzan trepando el librero y se abren
## desde arriba (atajo). Cada mecánica se enseña sin peligro antes de pedirla; la meta (el balcón) se muestra al empezar;
## A.S.P.I. espera en el estudio y se vence ensuciando el piso para distraerla y desenchufándola.
## Todo se arma desde datos; el arte es de Gemini (ArteNivel) y el fondo con parallax está en FondoApartamento.

## Escala del mundo: 1,21 px por cm (Felipe mide unos 55 cm de alto contando la cabeza; Valeria = 3 Felipes).
## Casa antigua del Barrio Viejo: cuartos de 3,5 m (424 px) de alto, todos con el piso a la misma altura.
const TECHO := 24.0
const SUELO := 448.0
const ALTO := SUELO + 30.0
const ANCHO := 6640.0
const MADERA := Color("b0613f")
const MADERA_OSCURA := Color("6e3a26")

## Habitaciones en orden de ruta: [rectángulo, nombre, estilo de pared]. Entre una y otra hay muro.
## Ninguna es más angosta que la pantalla (640 px), para que la cámara quede dentro.
const HABITACIONES := [
	[Rect2(0, TECHO, 1400, SUELO - TECHO), "sala", "tapiz"],
	[Rect2(1560, TECHO, 800, SUELO - TECHO), "recibidor", "tapiz_verde"],
	[Rect2(2520, TECHO, 800, SUELO - TECHO), "cocina", "azulejo"],
	[Rect2(3480, TECHO, 700, SUELO - TECHO), "pasillo", "tapiz_azul"],
	[Rect2(4340, TECHO, 700, SUELO - TECHO), "dormitorio", "rosa"],
	[Rect2(5200, TECHO, 640, SUELO - TECHO), "estudio", "tapiz_mostaza"],
	[Rect2(6000, TECHO, 640, SUELO - TECHO), "balcon", "exterior"],
]
## Orden de la ruta (las reglas de diseño lo usan para comprobar que se enseña antes de pedir).
const RUTA := ["sala", "recibidor", "cocina", "pasillo", "dormitorio", "estudio", "balcon"]
## Ventanas: huecos de la pared por donde se ve la ciudad.
const VENTANAS := [Rect2(260, 140, 180, 145), Rect2(3070, 130, 150, 150), Rect2(3700, 140, 120, 120), Rect2(4620, 110, 150, 120), Rect2(5400, 90, 150, 100)]

## Puertas: [nombre, posición (al pie), puerta a la que lleva]. Van de a pares.
const PUERTAS := [
	["sala>recibidor", Vector2(1350, SUELO), "recibidor<sala"],
	["recibidor<sala", Vector2(1605, SUELO), "sala>recibidor"],
	["recibidor>cocina", Vector2(1810, SUELO), "cocina<recibidor"],
	["cocina<recibidor", Vector2(2570, SUELO), "recibidor>cocina"],
	["recibidor>pasillo", Vector2(2320, SUELO - 288), "pasillo<recibidor"],  # arriba de la escalera
	["pasillo<recibidor", Vector2(3530, SUELO), "recibidor>pasillo"],
	["pasillo>dormitorio", Vector2(3830, SUELO), "dormitorio<pasillo"],
	["dormitorio<pasillo", Vector2(4390, SUELO), "pasillo>dormitorio"],
	["pasillo>estudio", Vector2(4130, SUELO), "estudio<pasillo"],
	["estudio<pasillo", Vector2(5250, SUELO), "pasillo>estudio"],
	["estudio>balcon", Vector2(5800, SUELO), "balcon<estudio"],  # cerrada hasta desenchufar a A.S.P.I.
	["balcon<estudio", Vector2(6040, SUELO), "estudio>balcon"],
]
const PUERTA_BALCON := "estudio>balcon"

## Arte de Gemini por mueble: nombre -> [imagen en assets/nivel1/ ("" = va dentro de otra imagen), corrimiento en x].
const ARTE_MUEBLES := {
	"Sofá": ["sofa", 0.0], "Mesa": ["comedor", 0.0], "Silla": ["", 0.0], "Silla 2": ["", 0.0], "Banco": ["banco", 0.0],
	"Aparador": ["aparador", 0.0], "Librero": ["librero", 0.0], "Repisa del librero 1": ["", 0.0],
	"Repisa del librero 2": ["", 0.0], "Repisa del librero 3": ["", 0.0], "Mesón": ["meson", 0.0],
	"Refrigerador": ["refrigerador", 0.0], "Consola": ["aparador", 0.0], "Cama": ["cama", 0.0], "Cabecera": ["", 0.0],
	"Cómoda": ["comoda", 0.0], "Ropero": ["ropero", 0.0], "Escritorio": ["aparador", 0.0], "Taburete": ["banco", 0.0],
	"Baranda": ["baranda", -92.0],
}

## [rectángulo, se atraviesa desde abajo, nombre, estilo de dibujo]. Entre paréntesis, la altura real.
const PIEZAS := [
	[Rect2(0, SUELO, ANCHO, 30), false, "Piso", "invisible"],
	[Rect2(0, TECHO - 20, ANCHO, 20), false, "Techo", "invisible"],
	# Sala.
	[Rect2(220, SUELO - 54, 230, 10), true, "Sofá", "arte"],  # asiento a 45 cm
	[Rect2(520, SUELO - 55, 40, 8), true, "Silla", "arte"],  # 45 cm
	[Rect2(570, SUELO - 91, 133, 8), true, "Mesa", "arte"],  # 75 cm
	[Rect2(715, SUELO - 55, 40, 8), true, "Silla 2", "arte"],
	[Rect2(808, SUELO - 79, 52, 8), true, "Banco", "arte"],  # 65 cm, sobre los juguetes
	[Rect2(970, SUELO - 98, 156, 62), false, "Aparador", "arte"],  # 81 cm, con 30 cm libres debajo
	# Recibidor.
	[Rect2(1660, SUELO - 24, 100, 24), false, "Caja de arena", "caja"],  # 20 cm
	[Rect2(1880, SUELO - 55, 92, 6), true, "Repisa del librero 1", "arte"],  # repisas cada 45 cm
	[Rect2(1880, SUELO - 109, 92, 6), true, "Repisa del librero 2", "arte"],
	[Rect2(1880, SUELO - 163, 92, 6), true, "Repisa del librero 3", "arte"],
	[Rect2(1880, SUELO - 218, 92, 8), true, "Librero", "arte"],  # 1,80 m
	[Rect2(2246, SUELO - 288, 114, 8), true, "Descanso de la escalera", "escalon"],
	# Cocina.
	[Rect2(2700, SUELO - 109, 204, 109), false, "Mesón", "arte"],  # 90 cm
	[Rect2(2940, SUELO - 218, 84, 218), false, "Refrigerador", "arte"],  # 1,80 m
	# Pasillo de arriba.
	[Rect2(3640, SUELO - 98, 156, 62), false, "Consola", "arte"],  # 81 cm
	# Dormitorio.
	[Rect2(4490, SUELO - 280, 60, 8), true, "Repisa alta", "repisa"],  # 2,30 m; se llega trepando la cortina
	[Rect2(4580, SUELO - 66, 244, 30), false, "Cama", "arte"],  # colchón a 55 cm, con 30 cm libres debajo
	[Rect2(4580, SUELO - 120, 30, 8), true, "Cabecera", "arte"],  # 1 m
	[Rect2(4848, SUELO - 97, 84, 97), false, "Cómoda", "arte"],  # 80 cm
	[Rect2(4936, SUELO - 185, 104, 185), false, "Ropero", "arte"],  # 1,53 m
	# Estudio de Valeria (la pelea).
	[Rect2(5360, SUELO - 98, 156, 62), false, "Escritorio", "arte"],  # 81 cm
	[Rect2(5556, SUELO - 79, 52, 8), true, "Taburete", "arte"],  # 65 cm
	[Rect2(5620, SUELO - 160, 160, 8), true, "Repisa de las macetas", "repisa"],  # 1,30 m
	[Rect2(5772, SUELO - 250, 60, 8), true, "Repisita del enchufe", "repisa"],  # 2,05 m
	# Balcón.
	[Rect2(6630, SUELO - 94, 10, 94), false, "Baranda", "arte"],  # 78 cm
]
## Escalera del recibidor: escalones que se atraviesan desde abajo.
const ESCALERA_X := 2030.0
const ESCALONES := 9
const ANCHO_ESCALON := 24.0
const SUBIDA_ESCALON := 32.0
## Dos rejas para bebés apiladas (1,5 m) al pie de la escalera.
const REJA := Rect2(1990, SUELO - 182, 40, 182)
## Piezas de juguete en la alfombra: quitan un corazón.
const PELIGROS := [Rect2(760, SUELO - 6, 180, 6)]
## Cortina del dormitorio: se trepa hasta la repisa alta (calcetín secreto).
const TREPABLES := [Rect2(4450, SUELO - 290, 36, 290)]

## Avisos del tutorial: [rectángulo donde aparece, texto]. Solo la primera vez; {acción} es la tecla o el botón en uso.
const AVISOS := [
	[Rect2(0, TECHO, 250, SUELO - TECHO), "{mover_izquierda} {mover_derecha} caminar · {saltar} saltar"],
	[Rect2(470, TECHO, 200, SUELO - TECHO), "{interactuar} para tirar cosas"],
	[Rect2(945, TECHO, 180, SUELO - TECHO), "Mantén {agacharse} para pasar por debajo"],
	[Rect2(1140, TECHO, 170, SUELO - TECHO), "{zarpazo} zarpazo"],
	[Rect2(1620, TECHO, 150, SUELO - TECHO), "Caja de arena: aquí reapareces"],
	[Rect2(1840, TECHO, 140, SUELO - TECHO), "Trepa el librero: {saltar} dos veces"],
	[Rect2(2040, TECHO, 150, SUELO - TECHO), "De este lado, {interactuar} abre la reja"],
	[Rect2(2600, TECHO, 100, SUELO - TECHO), "{interactuar} para comer"],
	[Rect2(3960, TECHO, 120, SUELO - TECHO), "Cojín: aquí reapareces"],
	[Rect2(4350, TECHO, 140, SUELO - TECHO), "Mantén {mover_arriba} para trepar"],
]
## Calcetines: arriba del refrigerador, en la repisa alta del dormitorio (cortina) y arriba del ropero.
const CALCETINES := [Vector2(2982, SUELO - 218), Vector2(4520, SUELO - 280), Vector2(4988, SUELO - 185)]
const TOTAL_CALCETINES := 3
const CAJA_CARTON := Vector2(3150, SUELO)
## Ratones de cuerda: [posición, límite izquierdo, límite derecho].
const RATONES := [
	[Vector2(1260, SUELO), 1220.0, 1330.0],
	[Vector2(2760, SUELO - 109), 2730.0, 2800.0],
	[Vector2(2860, SUELO - 109), 2820.0, 2895.0],
]
const LASER := [Vector2(3900, SUELO), 3860.0, 3960.0]
## Objetos que se tiran con el botón de acción: [posición, tipo].
const TIRABLES := [
	[Vector2(640, SUELO - 91), "vaso"],
	[Vector2(3720, SUELO - 98), "vaso"],
	[Vector2(5480, SUELO - 98), "rollo"],
	[Vector2(5650, SUELO - 160), "maceta"],
	[Vector2(5700, SUELO - 160), "maceta"],
	[Vector2(5750, SUELO - 160), "maceta"],
]
## Comida: [posición, tipo]. El plato sale de la caja de cartón.
const COMIDA := [[Vector2(2885, SUELO - 109), "lata"]]
## A.S.P.I.: [base de carga, límite izquierdo, límite derecho] dentro del estudio.
const ASPI := [Vector2(5700, SUELO), 5290.0, 5790.0]
## Enchufes de la base de carga: abajo junto al escritorio, sobre el escritorio y en la repisita alta.
const ENCHUFES := [Vector2(5532, SUELO), Vector2(5420, SUELO - 98), Vector2(5802, SUELO - 250)]
## Puntos de descanso: la caja de arena (recibidor) y el cojín (pasillo, junto a la puerta del jefe).
const DESCANSOS := [Rect2(1660, SUELO - 40, 100, 50), Rect2(3990, SUELO - 40, 60, 50)]
## Pasar esta x en el balcón termina la demo.
const SALIDA := 6500.0

signal logro_desbloqueado(titulo: String)
signal habitacion_cambiada(nombre: String)


## Nombre de la habitación que contiene el punto, mirando un píxel arriba para que el piso cuente ("" si está fuera).
static func habitacion_de(punto: Vector2) -> String:
	for habitacion: Array in HABITACIONES:
		if (habitacion[0] as Rect2).has_point(punto - Vector2(0, 1)):
			return habitacion[1]
	return ""


## Rectángulo de la habitación con ese nombre.
static func rect_de(nombre: String) -> Rect2:
	for habitacion: Array in HABITACIONES:
		if habitacion[1] == nombre:
			return habitacion[0]
	return Rect2()


## Índice en RUTA de la habitación que contiene el punto (-1 si está fuera).
static func orden_en_ruta(punto: Vector2) -> int:
	return RUTA.find(habitacion_de(punto))


## Muestra la pantalla de título al empezar (las pruebas la apagan).
@export var mostrar_titulo := true
## Entrar al estudio arranca la pelea de jefe (la prueba de mecánicas la apaga para probar a A.S.P.I. sola).
@export var batalla_con_jefe := true
## Las piezas de juguete hacen daño (la prueba de movimiento las apaga).
@export var peligros_activos := true

var logros: Array[String] = []
var calcetines := 0
var tiempo := 0.0
var terminado := false
var pantallas: Pantallas
var batalla: BatallaAspi
var aspi: Aspi
var habitacion := ""
var puertas := {}
var _piezas := {}
var _sonidos: Array[AudioStreamPlayer] = []
var _avisos_vistos := {}
var _fundido: ColorRect
var _cruzando := false

@onready var felipe: Felipe = $Felipe


func _ready() -> void:
	add_child(FondoApartamento.new(ANCHO, ALTO))
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2], pieza[3])
	# Paredes de cada habitación: no se sale de un cuarto si no es por una puerta.
	for datos: Array in HABITACIONES:
		var cuarto: Rect2 = datos[0]
		_crear_pieza(Rect2(cuarto.position.x - 20, 0, 20, ALTO), false, "Pared izquierda de %s" % datos[1], "invisible")
		_crear_pieza(Rect2(cuarto.end.x, 0, 20, ALTO), false, "Pared derecha de %s" % datos[1], "invisible")
	for i in ESCALONES:
		var escalon := Rect2(ESCALERA_X + i * ANCHO_ESCALON, SUELO - SUBIDA_ESCALON * (i + 1), ANCHO_ESCALON, 8)
		_crear_pieza(escalon, true, "Escalón %d" % (i + 1), "escalon")
	var reja := Reja.new(REJA)
	reja.abierta.connect(func() -> void: desbloquear_logro("Atajo de Gato"))
	add_child(reja)
	for datos: Array in PUERTAS:
		var puerta := Puerta.new(datos[0], datos[1], datos[2], datos[1].y - TECHO)
		puerta.cerrada = datos[0] == PUERTA_BALCON
		puerta.cruzada.connect(cruzar)
		add_child(puerta)
		puertas[datos[0]] = puerta
	for comida: Array in COMIDA:
		var objeto := Comida.new(comida[1])
		objeto.position = comida[0]
		add_child(objeto)
	aspi = Aspi.new(ASPI[1], ASPI[2])
	aspi.position = ASPI[0]
	aspi.necesita_aturdir = true
	aspi.apagado.connect(_abrir_balcon)
	add_child(aspi)
	var enchufes: Array[Enchufe] = []
	for posicion: Vector2 in ENCHUFES:
		var enchufe := Enchufe.new(posicion)
		add_child(enchufe)
		enchufes.append(enchufe)
	var tirables: Array[Vaso] = []
	for tirable: Array in TIRABLES:
		var objeto := Vaso.new(SUELO, tirable[1])
		objeto.position = tirable[0]
		add_child(objeto)
		tirables.append(objeto)
	if batalla_con_jefe:
		batalla = BatallaAspi.new(aspi, felipe, self, enchufes)
		add_child(batalla)
		for objeto in tirables:
			objeto.caido.connect(batalla.agregar_mancha)
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
	_fundido = ColorRect.new()
	_fundido.name = "Fundido"
	_fundido.color = Color.BLACK
	_fundido.modulate.a = 0.0
	_fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fundido.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Interfaz.add_child(_fundido)
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	_actualizar_camara()


func _physics_process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	_actualizar_camara()
	# Puntos de descanso: la caja de arena y el cojín.
	for descanso: Rect2 in DESCANSOS:
		if descanso.has_point(felipe.global_position) and felipe.is_on_floor():
			var punto := Vector2(descanso.get_center().x, descanso.position.y + 10)
			if felipe.punto_reaparicion != punto:
				felipe.punto_reaparicion = punto
				sonar("logro")
	# Piezas de juguete: duelen al pisarlas.
	for peligro: Rect2 in PELIGROS if peligros_activos else []:
		if peligro.grow(2).has_point(felipe.global_position) and felipe.is_on_floor():
			felipe.recibir_dano(1, felipe.global_position.x - felipe.mirando * 10.0)
	_actualizar_aviso()
	if felipe.global_position.x > SALIDA and habitacion == "balcon":
		_terminar_demo()


## La cámara queda dentro de la habitación donde está Felipe (también después de una puerta o de reaparecer).
func _actualizar_camara() -> void:
	var actual := habitacion_de(felipe.global_position)
	if actual == "" or actual == habitacion:
		return
	habitacion = actual
	var cuarto := rect_de(actual)
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = int(cuarto.position.x)
	camara.limit_right = int(cuarto.end.x)
	camara.limit_top = 0
	camara.limit_bottom = int(ALTO)
	camara.reset_smoothing()
	# El salto de cámara se completa en el cuadro siguiente, ya con los límites nuevos.
	camara.reset_smoothing.call_deferred()
	habitacion_cambiada.emit(actual)


## Cruza una puerta: funde a negro, lleva a Felipe a la puerta del otro lado y vuelve a mostrar.
func cruzar(puerta: Puerta) -> void:
	if _cruzando or terminado:
		return
	if puerta.cerrada:
		_aviso_breve("Cerrada. A.S.P.I. tiene el control de esta puerta.")
		return
	var otra: Puerta = puertas.get(puerta.destino)
	if otra == null:
		return
	_cruzando = true
	sonar("salto")
	felipe.set_physics_process(false)
	var fundido := create_tween()
	fundido.tween_property(_fundido, "modulate:a", 1.0, 0.15)
	await fundido.finished
	felipe.global_position = otra.global_position
	felipe.velocity = Vector2.ZERO
	felipe.mirando = 1.0 if otra.global_position.x < rect_de(habitacion_de(otra.global_position)).get_center().x else -1.0
	_actualizar_camara()
	felipe.set_physics_process(true)
	var vuelta := create_tween()
	vuelta.tween_property(_fundido, "modulate:a", 0.0, 0.2)
	await vuelta.finished
	_cruzando = false


func _aviso_breve(texto: String) -> void:
	pantallas.aviso_fijo = texto
	await get_tree().create_timer(2.0).timeout
	if pantallas.aviso_fijo == texto:
		pantallas.aviso_fijo = ""


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
	var balcon := rect_de("balcon")
	var camara_meta := Camera2D.new()
	camara_meta.name = "Camara de la meta"
	camara_meta.position = Vector2(balcon.get_center().x, SUELO - 120)
	camara_meta.limit_left = int(balcon.position.x)
	camara_meta.limit_right = int(balcon.end.x)
	camara_meta.limit_top = 0
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
	var puerta: Puerta = puertas.get(PUERTA_BALCON)
	if puerta:
		puerta.cerrada = false
		puerta.queue_redraw()
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
		dibujo.draw.connect(_dibujar_mueble.bind(dibujo, rect.size, estilo, nombre))
		cuerpo.add_child(dibujo)
	add_child(cuerpo)


## Dibuja el mueble. (0, 0) es la esquina de arriba a la izquierda de la parte donde se para Felipe.
## Los muebles con arte de Gemini se apoyan en el piso; los demás (repisas, escalones, caja de arena) son dibujo.
func _dibujar_mueble(c: Node2D, tamano: Vector2, estilo: String, nombre: String) -> void:
	var hasta_suelo := SUELO - (c.get_parent() as Node2D).position.y
	match estilo:
		"arte":
			var arte: Array = ARTE_MUEBLES[nombre]
			if arte[0] != "":
				ArteNivel.dibujar(c, arte[0], tamano.x / 2.0 + arte[1], hasta_suelo)
		"repisa", "escalon":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), MADERA)
			if estilo == "escalon":
				c.draw_rect(Rect2(0, tamano.y, tamano.x, 24), MADERA_OSCURA)
			else:
				for x: float in [4.0, tamano.x - 16.0]:
					c.draw_colored_polygon(PackedVector2Array([Vector2(x, tamano.y), Vector2(x + 12, tamano.y), Vector2(x, tamano.y + 14)]), MADERA_OSCURA)
		"caja":
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("5f8fa8"))
			c.draw_rect(Rect2(4, 0, tamano.x - 8, 6), Color("d9c7a0"))


## Decorado sin colisión: juguetes, escalera, lámpara (hito del descanso), alacenas, cojín, perchero y base de carga.
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
	var cima := Vector2(ESCALERA_X + ESCALONES * ANCHO_ESCALON, SUELO - SUBIDA_ESCALON * ESCALONES)
	c.draw_colored_polygon(PackedVector2Array([pie, cima + Vector2(0, 8), cima + Vector2(0, 40), pie + Vector2(40, 0)]), MADERA_OSCURA.darkened(0.2))
	c.draw_line(pie + Vector2(0, -60), cima + Vector2(0, -60), MADERA_OSCURA, 4)
	for i in range(0, ESCALONES, 2):
		var x := ESCALERA_X + i * ANCHO_ESCALON + ANCHO_ESCALON / 2
		var y := SUELO - SUBIDA_ESCALON * (i + 1)
		c.draw_line(Vector2(x, y), Vector2(x, y - 44), MADERA_OSCURA, 2)
	ArteNivel.dibujar(c, "lampara", 1790.0, SUELO)
	c.draw_circle(Vector2(1790, SUELO - 140), 30.0, Color(1.0, 0.9, 0.5, 0.15))
	# Alacenas sobre el mesón (a 1,50 m, Felipe no llega).
	ArteNivel.dibujar(c, "alacenas", 2802.0, SUELO - 182.0)
	ArteNivel.dibujar(c, "perchero", 3590.0, SUELO)
	# Cojín del pasillo: segundo punto de descanso.
	var cojin: Rect2 = DESCANSOS[1]
	c.draw_rect(Rect2(cojin.position.x + 4, SUELO - 10, cojin.size.x - 8, 10), Color("c8576b"))
	c.draw_rect(Rect2(cojin.position.x + 8, SUELO - 13, cojin.size.x - 16, 4), Color("e07a85"))
	# Base de carga de A.S.P.I.
	var base: Vector2 = ASPI[0]
	c.draw_rect(Rect2(base.x - 30, SUELO - 22, 60, 22), Color("4a4d55"))
	c.draw_rect(Rect2(base.x - 24, SUELO - 18, 48, 4), Color("5fd18a"))


func _dibujar_cortina(c: Node2D, zona: Rect2) -> void:
	c.draw_rect(Rect2(zona.position.x - 6, zona.position.y, zona.size.x + 12, 5), MADERA_OSCURA)
	var pliegue := 0.0
	while pliegue < zona.size.x:
		c.draw_rect(Rect2(zona.position.x + pliegue, zona.position.y + 4, 6, zona.size.y - 8), Color("c46a5a") if int(pliegue / 6.0) % 2 == 0 else Color("a8564a"))
		pliegue += 6.0
