# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name SalaProto
extends Node2D
## Un solo cuarto de una pantalla (la sala), feo a propósito y dibujado por código, a escala de gato
## (muebles casi reales a 1,21 px/cm). Une a Felipe, los objetos, Valeria, la voz y la respuesta épica.

const SUELO := 296.0
## Superficies de pie: [x inicial, x final, y]. Mismos números para colisión, dibujo y caída de objetos.
const MESA := Rect2(250, 205, 120, 8)      # mesa de comedor, 75 cm
const REPISA := Rect2(392, 139, 108, 7)    # repisa, 1,30 m
const PUERTA := Rect2(530, 42, 104, 254)   # puerta de 2,10 m y 104 px de ancho

## Caos por travesura (antes del combo).
@export var caos_vaso := 10
@export var caos_florero := 15
@export var caos_control := 8
@export var caos_patada := 4
@export var caos_aranazo := 5
@export var caos_maullido := 3
@export var caos_intimidar := 6
@export var caos_perdon := 20
## Ruido que oye Valeria por travesura.
@export var ruido_rotura := 3.0
@export var ruido_golpe := 2.0
@export var ruido_aranazo := 0.8
@export var ruido_maullido := 1.5
@export var ruido_intimidar := 1.5
## Congelado (hitstop) en segundos: golpe de pata y travesura completa.
@export var congelado_pata := 0.05
@export var congelado_travesura := 0.09

var felipe: FelipeProto
var valeria: Valeria
var vaso: Tirable
var florero: Tirable
var control: Tirable
var sofa: Sofa
var plato: Plato
var snack: Plato
var jugo: Jugo
var dialogo: Dialogo
var sonidos: Sonidos
var frases := Frases.new()
var camara: Camera2D
var puerta_abierta := 0.0
## Registro de lo que pasó (para el bot y la prueba): [segundo, texto].
var registro: Array = []
var tiempo := 0.0

var _ultimo_aranazo_hablado := -99.0
var _ultimo_en_su_cara := -99.0


func _ready() -> void:
	Controles.registrar()
	sonidos = Sonidos.new()
	add_child(sonidos)
	camara = Camera2D.new()
	camara.position = Vector2(320, 180)
	add_child(camara)
	camara.make_current()
	_crear_colisiones()
	sofa = Sofa.new()
	sofa.aranado.connect(_al_aranar)
	add_child(sofa)
	var superficies := [[0.0, 640.0, SUELO], [MESA.position.x, MESA.end.x, MESA.position.y], [REPISA.position.x, REPISA.end.x, REPISA.position.y], [Sofa.ASIENTO.position.x, Sofa.ASIENTO.end.x, Sofa.ASIENTO.position.y], [Sofa.BRAZO_DERECHO.position.x, Sofa.BRAZO_DERECHO.end.x, Sofa.BRAZO_DERECHO.position.y], [Sofa.BRAZO_IZQUIERDO.position.x, Sofa.BRAZO_IZQUIERDO.end.x, Sofa.BRAZO_IZQUIERDO.position.y]]
	vaso = _crear_tirable("vaso", Vector2(340, MESA.position.y), true, superficies)
	florero = _crear_tirable("florero", Vector2(468, REPISA.position.y), true, superficies)
	control = _crear_tirable("control", Vector2(197, Sofa.BRAZO_DERECHO.position.y), false, superficies)
	plato = Plato.new()
	plato.position = Vector2(470, SUELO)
	plato.comido.connect(_al_comer)
	add_child(plato)
	valeria = Valeria.new()
	valeria.grita.connect(_al_gritar)
	valeria.perdona.connect(_al_perdonar)
	valeria.persigue.connect(_al_perseguir)
	valeria.se_va.connect(_al_rendirse)
	valeria.se_fue.connect(_al_irse)
	add_child(valeria)
	felipe = FelipeProto.new()
	felipe.name = "Felipe"
	felipe.position = Vector2(235, SUELO)
	felipe.z_index = 1
	add_child(felipe)
	felipe.impacto.connect(_al_impacto_pata)
	felipe.maullo.connect(_al_maullar)
	felipe.intimido.connect(_al_intimidar)
	felipe.sonido.connect(sonidos.sonar)
	valeria.felipe = felipe
	jugo = Jugo.new()
	jugo.camara = camara
	add_child(jugo)
	dialogo = Dialogo.new()
	dialogo.sonidos = sonidos
	add_child(dialogo)


func _physics_process(delta: float) -> void:
	tiempo += delta
	var objetivo := 1.0 if valeria.estado != Valeria.Estado.FUERA else 0.0
	puerta_abierta = move_toward(puerta_abierta, objetivo, delta * 4.0)
	queue_redraw()


func _crear_tirable(tipo: String, posicion: Vector2, fragil: bool, superficies: Array) -> Tirable:
	var objeto := Tirable.new()
	objeto.tipo = tipo
	objeto.fragil = fragil
	objeto.position = posicion
	objeto.superficies = superficies
	objeto.golpeado.connect(_al_golpear_objeto)
	objeto.roto.connect(_al_romper)
	objeto.aterrizo.connect(_al_aterrizar_objeto)
	add_child(objeto)
	return objeto


func _crear_colisiones() -> void:
	var cuerpos := [
		[Rect2(-20, SUELO, 680, 80), false],
		[Rect2(-20, 0, 20, 360), false],
		[Rect2(640, 0, 20, 360), false],
		# Sofá: sólido hasta el asiento y los brazos (se sube saltando).
		[Rect2(Sofa.ASIENTO.position.x, Sofa.ASIENTO.position.y, Sofa.ASIENTO.size.x, SUELO - Sofa.ASIENTO.position.y), false],
		[Rect2(Sofa.BRAZO_IZQUIERDO.position, Vector2(Sofa.BRAZO_IZQUIERDO.size.x, SUELO - Sofa.BRAZO_IZQUIERDO.position.y)), false],
		[Rect2(Sofa.BRAZO_DERECHO.position, Vector2(Sofa.BRAZO_DERECHO.size.x, SUELO - Sofa.BRAZO_DERECHO.position.y)), false],
		# Mesa y repisa: se atraviesan desde abajo.
		[MESA, true],
		[REPISA, true],
	]
	for datos: Array in cuerpos:
		var rect: Rect2 = datos[0]
		var cuerpo := StaticBody2D.new()
		var forma := CollisionShape2D.new()
		var caja := RectangleShape2D.new()
		caja.size = rect.size
		forma.shape = caja
		forma.position = rect.get_center()
		forma.one_way_collision = datos[1]
		cuerpo.add_child(forma)
		add_child(cuerpo)


func _anotar(texto: String) -> void:
	registro.append([tiempo, texto])
	print("%6.2f s  %s" % [tiempo, texto])


func _felipe_dice(evento: String, urgente := false) -> void:
	var frase := frases.elegir("felipe", evento)
	if frase.is_empty():
		return
	# Si Valeria está hablando, Felipe espera su turno.
	if dialogo.hablando == "valeria" and not urgente:
		dialogo.decir("felipe", frase[0], frase[1])
	else:
		dialogo.decir("felipe", frase[0], frase[1], true)


func _valeria_dice(evento: String) -> void:
	var frase := frases.elegir("valeria", evento)
	if not frase.is_empty():
		dialogo.decir("valeria", frase[0], frase[1], true)


## Respuesta épica de una travesura: congelar, palabra que salta, +CAOS con combo, sacudida, destello y sonido con peso.
func _travesura(evento: String, texto: String, puntos: int, ruido: float, posicion: Vector2, fuerza: float, sonido: String) -> void:
	var en_su_cara := valeria.presente()
	var sumados := jugo.sumar_caos(puntos * (2 if en_su_cara else 1))
	jugo.congelar(lerpf(0.06, congelado_travesura, fuerza))
	jugo.sacudir(0.12 + 0.18 * fuerza, 0.4 + 0.6 * fuerza)
	jugo.destello(0.25 + 0.35 * fuerza)
	# La palabra va en "posicion" y el +CAOS justo encima (nunca sobre Felipe).
	jugo.palabra(texto, posicion, Color(1.0, 0.88, 0.3), 16 + int(8 * fuerza))
	jugo.palabra("+%d CAOS" % sumados, posicion + Vector2(0, -26), Color(1.0, 0.5, 0.35), 13, 0.12)
	sonidos.sonar(sonido)
	sonidos.sonar("peso", 1.0 - 0.15 * fuerza)
	valeria.oir(ruido)
	_anotar("%s (+%d caos, total %d)" % [evento, sumados, jugo.caos])
	if en_su_cara and tiempo - _ultimo_en_su_cara > 2.0:
		_ultimo_en_su_cara = tiempo
		jugo.palabra("¡EN SU CARA! x2", Vector2(320, 80), Color(1.0, 0.3, 0.5), 22, 0.2)
		_valeria_dice("en_su_cara")
		_felipe_dice("en_su_cara")
		return
	_felipe_dice(evento)


## Golpe de la pata en su cuadro de impacto: un congelado corto y una sacudida chica (antes del vuelo).
func _al_impacto_pata(objeto: Node2D, tipo: String) -> void:
	if tipo == "tirar":
		jugo.congelar(congelado_pata)
		jugo.sacudir(0.1, 0.3)
		sonidos.sonar("golpe_pata")
		_anotar("pata toca %s en cuadro %d" % [objeto.get("tipo"), felipe.sprite.frame])


func _al_golpear_objeto(objeto: Tirable) -> void:
	if objeto.tipo == "control" and objeto.position.y >= SUELO - 1.0:
		_travesura("patear", "¡GOL!", caos_patada, 1.0, objeto.position + Vector2(0, -44), 0.3, "golpe")


func _al_romper(objeto: Tirable) -> void:
	if objeto.tipo == "vaso":
		_travesura("tirar_vaso", "¡GRAVEDAD: 1 · VASO: 0!", caos_vaso, ruido_rotura, objeto.position + Vector2(0, -44), 1.0, "rotura")
	else:
		_travesura("tirar_florero", "¡CRÍTICO! FLORERO: 0", caos_florero, ruido_rotura, objeto.position + Vector2(0, -44), 1.0, "rotura")


func _al_aterrizar_objeto(objeto: Tirable, fuerza: float) -> void:
	sonidos.sonar("golpe", 1.4 - minf(fuerza / 600.0, 0.5))
	if objeto.tipo == "control" and fuerza > 150.0 and objeto.get_meta("primera_caida", true):
		objeto.set_meta("primera_caida", false)
		_travesura("tirar_control", "¡ZAPPING DEFINITIVO!", caos_control, ruido_golpe, objeto.position + Vector2(0, -44), 0.7, "golpe")


func _al_aranar(_sofa: Sofa, punto: Vector2) -> void:
	sonidos.sonar("arañar", randf_range(0.9, 1.15))
	var hablar := tiempo - _ultimo_aranazo_hablado > 1.5
	if hablar:
		_ultimo_aranazo_hablado = tiempo
	var en_su_cara := valeria.presente()
	var sumados := jugo.sumar_caos(caos_aranazo * (2 if en_su_cara else 1))
	jugo.congelar(0.06)
	jugo.sacudir(0.1, 0.35)
	var arriba := Vector2(punto.x, minf(punto.y, felipe.global_position.y - 70.0))
	jugo.palabra(["¡RIIIP!", "¡FIRMA DE AUTOR!", "¡RASS!"].pick_random() if hablar else "¡RIIIP!", arriba + Vector2(0, -12), Color(1.0, 0.92, 0.75), 16)
	jugo.palabra("+%d CAOS" % sumados, arriba + Vector2(0, -34), Color(1.0, 0.5, 0.35), 12, 0.1)
	valeria.oir(ruido_aranazo)
	_anotar("arañar (+%d caos, total %d)" % [sumados, jugo.caos])
	if hablar:
		_felipe_dice("arañar")


func _al_comer(objeto: Plato) -> void:
	sonidos.sonar("comer")
	jugo.sacudir(0.06, 0.2)
	if objeto.es_snack:
		jugo.palabra("¡SNACK DE LA VICTORIA!", Vector2(objeto.position.x, felipe.global_position.y - 84), Color(0.6, 1.0, 0.6), 16)
		_anotar("come el snack")
		_felipe_dice("snack")
		return
	jugo.palabra("¡ÑAM!", Vector2(objeto.position.x, felipe.global_position.y - 84), Color(0.9, 1.0, 0.7), 16)
	_anotar("come del plato (quedan %d)" % objeto.porciones)
	_felipe_dice("comer" if objeto.porciones > 0 else "plato_vacio")


func _al_maullar(boca: Vector2) -> void:
	var ondas := Ondas.new()
	ondas.position = boca
	ondas.lado = felipe.mirando
	ondas.z_index = 2
	add_child(ondas)
	sonidos.sonar("maullido", randf_range(0.95, 1.08))
	_travesura("maullar", "¡MIAU!", caos_maullido, ruido_maullido, felipe.global_position + Vector2(felipe.mirando * 24.0, -86), 0.35, "pop")


func _al_intimidar(centro: Vector2) -> void:
	sonidos.sonar("bufido")
	jugo.destello(0.25, Color(1.0, 0.3, 0.2))
	_travesura("intimidar", "¡FSSSHH! TERROR", caos_intimidar, ruido_intimidar, centro + Vector2(0, -58), 0.6, "golpe")


func _al_gritar(_v: Valeria) -> void:
	sonidos.sonar("felipe_grito")
	jugo.congelar(0.08)
	jugo.sacudir(0.3, 1.0)
	jugo.destello(0.3, Color(1.0, 0.6, 0.5))
	jugo.palabra("¡FELIPE!", valeria.position + Vector2(0, -225), Color(1.0, 0.35, 0.3), 28)
	_anotar("Valeria llega y grita")
	_valeria_dice("llega_florero" if florero.estado == Tirable.Estado.ROTO and randf() < 0.6 else "llega")
	_felipe_dice("llega_valeria")


func _al_perdonar(_v: Valeria) -> void:
	sonidos.sonar("ronroneo_off")
	sonidos.sonar("perdon")
	var sumados := jugo.sumar_caos(caos_perdon)
	jugo.congelar(0.1)
	jugo.destello(0.4, Color(1.0, 0.75, 0.85))
	jugo.sacudir(0.15, 0.4)
	jugo.palabra("¡CARISMA CRÍTICO!", felipe.global_position + Vector2(0, -112), Color(1.0, 0.55, 0.75), 22)
	jugo.palabra("¡PERDONADO! +%d" % sumados, felipe.global_position + Vector2(0, -84), Color(1.0, 0.9, 0.5), 14, 0.15)
	_anotar("Valeria perdona (+%d caos, total %d)" % [sumados, jugo.caos])
	_valeria_dice("perdona")
	_felipe_dice("perdonado")
	if not is_instance_valid(snack):
		snack = Plato.new()
		snack.es_snack = true
		snack.prioridad = -10.0
		var x := clampf(felipe.global_position.x + felipe.mirando * 44.0, 60.0, 520.0)
		# Que no caiga encima del plato.
		if absf(x - plato.position.x) < 44.0:
			x = plato.position.x - 50.0 if felipe.global_position.x < plato.position.x else minf(plato.position.x + 50.0, 520.0)
		snack.position = Vector2(x, SUELO)
		snack.comido.connect(_al_comer)
		add_child(snack)
		# Cae de la mano de Valeria.
		snack.position.y = SUELO - 90.0
		create_tween().tween_property(snack, "position:y", SUELO, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _al_perseguir(_v: Valeria) -> void:
	_anotar("Valeria persigue")
	_valeria_dice("persigue")
	_felipe_dice("persecucion")


func _al_rendirse(_v: Valeria) -> void:
	_anotar("Valeria se rinde")
	_valeria_dice("se_va")


func _al_irse(_v: Valeria) -> void:
	_anotar("Valeria se fue y repuso todo")
	var repuso := false
	for objeto: Tirable in [vaso, florero, control]:
		if objeto.necesita_reponer():
			objeto.reponer()
			objeto.set_meta("primera_caida", true)
			repuso = true
	if plato.porciones < plato.porciones_max:
		plato.rellenar()
		repuso = true
	if repuso:
		_felipe_dice("se_fue")


func _draw() -> void:
	# Pared, zócalo y piso.
	draw_rect(Rect2(0, 0, 640, SUELO), Color(0.86, 0.8, 0.68))
	for i in 9:
		draw_rect(Rect2(i * 72 + 20, 0, 3, SUELO), Color(0.82, 0.76, 0.64))
	draw_rect(Rect2(0, SUELO - 8, 640, 8), Color(0.62, 0.5, 0.4))
	draw_rect(Rect2(0, SUELO, 640, 64), Color(0.55, 0.38, 0.26))
	for i in 8:
		draw_line(Vector2(i * 84 + 30, SUELO), Vector2(i * 84 + 30, 360), Color(0.48, 0.32, 0.22), 1.0)
	draw_line(Vector2(0, SUELO), Vector2(640, SUELO), Color(0.4, 0.27, 0.18), 2.0)
	# Cuadro torcido en la pared (de Felipe, claro).
	draw_rect(Rect2(86, 70, 70, 54), Color(0.4, 0.28, 0.2))
	draw_rect(Rect2(92, 76, 58, 42), Color(0.95, 0.85, 0.55))
	draw_circle(Vector2(121, 100), 12.0, Color(0.5, 0.45, 0.42))
	draw_string(ThemeDB.fallback_font, Vector2(95, 140), "SU MAJESTAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.28, 0.2))
	# Mesa de comedor (75 cm).
	var madera := Color(0.45, 0.28, 0.16)
	draw_rect(MESA, madera)
	draw_rect(Rect2(MESA.position.x + 6, MESA.end.y, 8, SUELO - MESA.end.y), madera.darkened(0.15))
	draw_rect(Rect2(MESA.end.x - 14, MESA.end.y, 8, SUELO - MESA.end.y), madera.darkened(0.15))
	draw_rect(Rect2(MESA.position.x, MESA.end.y, MESA.size.x, 6), madera.darkened(0.3))
	# Repisa (1,30 m) con ménsulas.
	draw_rect(REPISA, madera.lightened(0.1))
	for x: float in [REPISA.position.x + 14, REPISA.end.x - 20]:
		draw_colored_polygon(PackedVector2Array([Vector2(x, REPISA.end.y), Vector2(x + 6, REPISA.end.y), Vector2(x + 6, REPISA.end.y + 22)]), madera.darkened(0.2))
	# Puerta de 104 px: marco ancho; se abre cuando entra Valeria.
	draw_rect(PUERTA.grow(6), Color(0.95, 0.93, 0.88))
	draw_rect(PUERTA, Color(0.18, 0.14, 0.12))
	var ancho_hoja := PUERTA.size.x * (1.0 - 0.75 * puerta_abierta)
	draw_rect(Rect2(PUERTA.position, Vector2(ancho_hoja, PUERTA.size.y)), Color(0.66, 0.46, 0.3))
	draw_rect(Rect2(PUERTA.position + Vector2(10, 16), Vector2(ancho_hoja - 20, 90)), Color(0.6, 0.41, 0.27))
	draw_rect(Rect2(PUERTA.position + Vector2(10, 124), Vector2(ancho_hoja - 20, 110)), Color(0.6, 0.41, 0.27))
	if puerta_abierta < 0.5:
		draw_circle(Vector2(PUERTA.position.x + ancho_hoja - 12, 170), 4.0, Color(0.85, 0.75, 0.3))
