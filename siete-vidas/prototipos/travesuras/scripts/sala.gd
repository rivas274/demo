# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name SalaProto
extends Node2D
## Un solo cuarto de una pantalla (la sala), feo a propósito y dibujado por código, a escala de gato
## (muebles casi reales a 1,21 px/cm). Une a Felipe, los objetos, Valeria, la voz y la respuesta épica.
## v2: sin CAOS ni puntaje. El motivo es la Agenda de Su Majestad (7 travesuras, 3 secretas) y sus
## recompensas útiles: calcetines, snacks, fotos vergonzosas y un camino (la persiana).
## v2b: "Teatro para Valeria": un rascador nuevo y caro junto al sofá. Usarlo delante de ella cuenta
## como perdón; sin público, Felipe se queja. Deja las garras afiladas: el siguiente arañazo al sofá
## es crítico y rompe el plástico de un golpe.

const SUELO := 296.0
## Superficies de pie: [x inicial, x final, y]. Mismos números para colisión, dibujo y caída de objetos.
const MESA := Rect2(250, 205, 120, 8)      # mesa de comedor, 75 cm
const REPISA := Rect2(392, 139, 108, 7)    # repisa, 1,30 m
const PUERTA := Rect2(530, 42, 104, 254)   # puerta de 2,10 m y 104 px de ancho
## v2: ventana con persiana eléctrica sobre el sofá; al subir, su alféizar (1,40 m) es una plataforma.
const VENTANA := Rect2(44, 46, 112, 80)
const ALFEIZAR := Rect2(36, 126, 128, 7)
## Tele en la pared, sobre la mesa.
const TELE := Rect2(272, 62, 90, 56)
## Dónde está el calcetín del alféizar (asoma bajo la persiana).
const CALCETIN_ALFEIZAR_X := 128.0

## Ruido que oye Valeria por travesura.
@export var ruido_rotura := 3.0
@export var ruido_golpe := 2.0
@export var ruido_aranazo := 0.8
@export var ruido_maullido := 1.5
@export var ruido_intimidar := 1.5
## Congelado (hitstop) en segundos: golpe de pata y travesura completa.
@export var congelado_pata := 0.05
@export var congelado_travesura := 0.09
## Congelado al cumplir una travesura de la agenda.
@export var congelado_agenda := 0.12
## Segundos después de completar la agenda antes de mostrar el resumen.
@export var espera_resumen := 1.5
## Ruido que hace el rascador (es "portarse bien": casi no se oye).
@export var ruido_rascador := 0.0

var felipe: FelipeProto
var valeria: Valeria
var vaso: Tirable
var florero: Tirable
var control: Tirable
var sofa: Sofa
var rascador: Rascador
var plato: Plato
var snack: Recogible
var aspiradora: Aspiradora
var jugo: Jugo
var agenda := Agenda.new()
var hud: Hud
var libreta: Libreta
var resumen: Resumen
var persiana_abierta := 0.0
var perdones := 0
var calcetin_alfeizar: Recogible
var _cuerpo_alfeizar: CollisionShape2D
var _superficies: Array = []
var _reponer_pendiente: Array = []
var _espera_resumen := -1.0
var _resumen_automatico_hecho := false
var _motivo_grito := ""
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
var _ultima_palabra_aranazo := -99.0
var _perdon_por_rascador := false
var _ultimo_critico := -99.0
var _dijo_persiana := false


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
	sofa.plastico_roto.connect(_al_romper_plastico)
	sofa.critico.connect(_al_aranar_critico)
	rascador = Rascador.new()
	rascador.aranado.connect(_al_usar_rascador)
	add_child(rascador)
	var superficies := [[0.0, 640.0, SUELO], [MESA.position.x, MESA.end.x, MESA.position.y], [REPISA.position.x, REPISA.end.x, REPISA.position.y], [Sofa.ASIENTO.position.x, Sofa.ASIENTO.end.x, Sofa.ASIENTO.position.y], [Sofa.BRAZO_DERECHO.position.x, Sofa.BRAZO_DERECHO.end.x, Sofa.BRAZO_DERECHO.position.y], [Sofa.BRAZO_IZQUIERDO.position.x, Sofa.BRAZO_IZQUIERDO.end.x, Sofa.BRAZO_IZQUIERDO.position.y]]
	_superficies = superficies
	vaso = _crear_tirable("vaso", Vector2(340, MESA.position.y), true, superficies)
	florero = _crear_tirable("florero", Vector2(468, REPISA.position.y), true, superficies)
	control = _crear_tirable("control", Vector2(197, Sofa.BRAZO_DERECHO.position.y), false, superficies)
	plato = Plato.new()
	plato.position = Vector2(470, SUELO)
	plato.comido.connect(_al_comer)
	add_child(plato)
	aspiradora = Aspiradora.new()
	aspiradora.position = Vector2(312, SUELO)
	aspiradora.escupio.connect(_al_escupir_aspiradora)
	add_child(aspiradora)
	valeria = Valeria.new()
	valeria.grita.connect(_al_gritar)
	valeria.perdona.connect(_al_perdonar)
	valeria.persigue.connect(_al_perseguir)
	valeria.se_va.connect(_al_rendirse)
	valeria.se_fue.connect(_al_irse)
	valeria.se_sento.connect(_al_sentarse)
	add_child(valeria)
	# Valeria va detrás de los objetos: no tapa el florero ni el vaso cuando se para frente a la repisa.
	move_child(valeria, sofa.get_index() + 1)
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
	rascador.felipe = felipe
	jugo = Jugo.new()
	jugo.camara = camara
	add_child(jugo)
	dialogo = Dialogo.new()
	dialogo.sonidos = sonidos
	add_child(dialogo)
	hud = Hud.new()
	hud.preparar(sonidos)
	hud.total_travesuras = agenda.total()
	add_child(hud)
	libreta = Libreta.new()
	libreta.preparar(agenda, sonidos)
	libreta.pidio_terminar.connect(terminar_dia)
	add_child(libreta)
	agenda.cumplida.connect(_al_cumplir)
	agenda.progreso.connect(_al_avanzar)


func _physics_process(delta: float) -> void:
	tiempo += delta
	var objetivo := 1.0 if valeria.estado != Valeria.Estado.FUERA else 0.0
	puerta_abierta = move_toward(puerta_abierta, objetivo, delta * 4.0)
	_revisar_golpes_a_valeria()
	_reponer_lo_pendiente()
	if agenda.completa() and not _resumen_automatico_hecho and not hud.ocupado() and not _hay_recompensas_sueltas():
		if _espera_resumen < 0.0:
			_espera_resumen = espera_resumen
		_espera_resumen -= delta
		if _espera_resumen <= 0.0:
			_resumen_automatico_hecho = true
			terminar_dia()
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
	# Alféizar: existe solo cuando la persiana sube (el camino que abre una travesura).
	var cuerpo_alfeizar := StaticBody2D.new()
	_cuerpo_alfeizar = CollisionShape2D.new()
	var caja_alfeizar := RectangleShape2D.new()
	caja_alfeizar.size = ALFEIZAR.size
	_cuerpo_alfeizar.shape = caja_alfeizar
	_cuerpo_alfeizar.position = ALFEIZAR.get_center()
	_cuerpo_alfeizar.one_way_collision = true
	_cuerpo_alfeizar.disabled = true
	cuerpo_alfeizar.add_child(_cuerpo_alfeizar)
	add_child(cuerpo_alfeizar)


func _anotar(texto: String) -> void:
	registro.append([tiempo, texto])
	print("%6.2f s  %s" % [tiempo, texto])


func _felipe_dice(evento: String, urgente := false) -> void:
	var frase := frases.elegir("felipe", evento)
	if frase.is_empty():
		return
	# Si Valeria está hablando, Felipe espera su turno (y la frase caduca si tarda mucho).
	if dialogo.hablando == "valeria" and not urgente:
		dialogo.decir("felipe", frase[0], frase[1])
	else:
		dialogo.decir("felipe", frase[0], frase[1], true)


func _valeria_dice(evento: String) -> Array:
	var frase := frases.elegir("valeria", evento)
	if not frase.is_empty():
		dialogo.decir("valeria", frase[0], frase[1], true)
	return frase


## Felipe contesta cuando Valeria está por terminar su frase (si no, su respuesta caducaría en la cola).
func _felipe_responde(evento: String, frase_valeria: Array) -> void:
	var espera := 0.4 + 0.035 * String(frase_valeria[0] if not frase_valeria.is_empty() else "").length()
	get_tree().create_timer(espera).timeout.connect(func() -> void: _felipe_dice(evento))


## Valeria saca el celular y le saca una foto con flash (solo efecto). Frase opcional después.
func _foto_de_valeria(evento := "") -> void:
	valeria.sacar_celular()
	get_tree().create_timer(0.35).timeout.connect(func() -> void:
		jugo.destello(0.3, Color.WHITE)
		sonidos.sonar("pop", 1.8)
		_anotar("Valeria saca una foto con flash"))
	if evento != "":
		# Después de la frase de Felipe (en cola: si él sigue hablando, espera su turno).
		get_tree().create_timer(5.0).timeout.connect(func() -> void:
			var f := frases.elegir("valeria", evento)
			dialogo.decir("valeria", f[0], f[1]))


## Respuesta épica de una travesura: congelar, palabra que salta, sacudida, destello y sonido con peso.
## (v2: sin "+N CAOS" ni combo.)
func _travesura(evento: String, texto: String, ruido: float, posicion: Vector2, fuerza: float, sonido: String, hablar := true) -> void:
	var en_su_cara := valeria.presente()
	jugo.congelar(lerpf(0.06, congelado_travesura, fuerza))
	jugo.sacudir(0.12 + 0.18 * fuerza, 0.4 + 0.6 * fuerza)
	jugo.destello(0.25 + 0.35 * fuerza)
	if hablar:
		# Si el objeto le cayó encima a Valeria, la palabra es "¡IMPACTO DIRECTO!" (no se pisan).
		jugo.palabra(texto, posicion, Color(1.0, 0.88, 0.3), 16 + int(8 * fuerza))
	sonidos.sonar(sonido)
	sonidos.sonar("peso", 1.0 - 0.15 * fuerza)
	valeria.oir(ruido)
	_anotar(evento + (" (en su cara)" if en_su_cara else ""))
	if not hablar:
		return
	if en_su_cara and tiempo - _ultimo_en_su_cara > 2.0:
		_ultimo_en_su_cara = tiempo
		jugo.palabra("¡EN SU CARA!", Vector2(320, 150), Color(1.0, 0.3, 0.5), 20, 0.2)
		_valeria_dice("en_su_cara")
		_felipe_dice("en_su_cara")
		return
	_felipe_dice(evento)


## --- Agenda ---

func _al_cumplir(t: Dictionary) -> void:
	var secreta: bool = t["secreta"]
	var titulo := "¡TRAVESURA SECRETA!" if secreta else "¡TRAVESURA CUMPLIDA!"
	_anotar("AGENDA: %s -> %s" % [t["nombre"], t["recompensa"]])
	hud.travesuras = agenda.cumplidas()
	hud.golpear("agenda")
	# Abajo si Felipe está arriba, o si lo importante pasa arriba (la persiana que se abre).
	hud.cartel(titulo, t["nombre"], t["recompensa"], secreta, felipe.global_position.y < 200.0 or t["id"] == "tele")
	jugo.congelar(congelado_agenda)
	jugo.destello(0.45, Color(1.0, 0.6, 0.95) if secreta else Color(1.0, 0.95, 0.6))
	jugo.sacudir(0.2, 0.6)
	var frase: Array = t["frase"]
	if dialogo.hablando == "valeria":
		# Si Valeria acaba de reaccionar, Felipe cierra después (no le pisa la frase).
		var espera := 0.4 + 0.035 * dialogo.texto_actual.length()
		get_tree().create_timer(espera).timeout.connect(func() -> void: dialogo.decir("felipe", frase[0], frase[1], true))
	else:
		dialogo.decir("felipe", frase[0], frase[1], true)


func _al_avanzar(t: Dictionary) -> void:
	_anotar("agenda: %s (%d/%d)" % [t["nombre"], agenda.avance[t["id"]], t["meta"]])
	hud.golpear("agenda")
	jugo.palabra("AGENDA: %d/%d" % [agenda.avance[t["id"]], t["meta"]], Vector2(70, 42), Color(1.0, 0.9, 0.5), 12, 0.3)


## Pantalla de fin del día (también con F).
func terminar_dia() -> void:
	if is_instance_valid(resumen):
		return
	libreta.cerrar()
	libreta.bloqueada = true
	var filas := [
		["Travesuras", agenda.cumplidas(), agenda.total()],
		["Secretas", agenda.secretas_cumplidas(), agenda.total_secretas()],
		["Calcetines", hud.calcetines, Hud.TOTAL_CALCETINES],
		["Fotos vergonzosas", hud.fotos, -1],
		["Snacks guardados", hud.snacks, -1],
		["Valeria te perdonó (veces)", perdones, -1],
	]
	var frase := ["Un día flojo. Hasta los reyes descansan.", 3]
	if agenda.completa():
		frase = ["Siete de siete. La casa es mía. Como siempre fue.", 7]
	elif agenda.cumplidas() >= 3:
		frase = ["Nada mal. Mañana termino la lista. O no. Soy el rey.", 4]
	_anotar("RESUMEN: travesuras %d/%d, secretas %d/%d, calcetines %d/3, fotos %d, snacks %d, perdones %d" % [agenda.cumplidas(), agenda.total(), agenda.secretas_cumplidas(), agenda.total_secretas(), hud.calcetines, hud.fotos, hud.snacks, perdones])
	resumen = Resumen.new()
	resumen.mostrar(filas, frase, sonidos)
	dialogo.visible = false
	resumen.cerrado.connect(func() -> void:
		libreta.bloqueada = false
		dialogo.visible = true)
	add_child(resumen)


## --- Recompensas ---

func _soltar(tipo: String, desde: Vector2, impulso: Vector2) -> Recogible:
	var r := Recogible.new()
	r.tipo = tipo
	r.position = desde
	r.velocidad = impulso
	r.superficies = _superficies
	r.felipe = felipe
	r.recogido.connect(_al_recoger)
	add_child(r)
	return r


func _al_recoger(r: Recogible) -> void:
	sonidos.sonar("pop", 1.3)
	sonidos.sonar("perdon", 1.6)
	match r.tipo:
		"calcetin":
			hud.calcetines += 1
			hud.golpear("calcetin")
			jugo.palabra("¡CALCETÍN %d/%d!" % [hud.calcetines, Hud.TOTAL_CALCETINES], r.global_position + Vector2(0, -60), Color(1.0, 0.95, 0.95), 15)
			_anotar("recoge calcetín (%d/3)" % hud.calcetines)
			_felipe_dice("recoger_calcetin")
		"snack":
			hud.snacks += 1
			hud.golpear("snack")
			jugo.palabra("¡SNACK GUARDADO!", r.global_position + Vector2(0, -60), Color(0.6, 1.0, 0.6), 14)
			_anotar("guarda un snack (%d)" % hud.snacks)
			_felipe_dice("recoger_snack")
		"foto":
			hud.fotos += 1
			hud.golpear("foto")
			jugo.palabra("¡FOTO VERGONZOSA!", r.global_position + Vector2(0, -60), Color(1.0, 0.6, 0.85), 15)
			_anotar("recoge la foto vergonzosa" + (" del rascador" if r.variante == 1 else ""))
			_felipe_dice("recoger_foto_rascador" if r.variante == 1 else "recoger_foto", true)


func _abrir_persiana() -> void:
	if persiana_abierta > 0.0:
		return
	_anotar("la persiana sube: alféizar abierto")
	sonidos.sonar("zarpazo", 0.5)
	create_tween().tween_property(self, "persiana_abierta", 1.0, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_cuerpo_alfeizar.set_deferred("disabled", false)
	_superficies.append([ALFEIZAR.position.x, ALFEIZAR.end.x, ALFEIZAR.position.y])
	calcetin_alfeizar = _soltar("calcetin", Vector2(CALCETIN_ALFEIZAR_X, ALFEIZAR.position.y), Vector2.ZERO)
	calcetin_alfeizar.quieto = true
	jugo.palabra("¡LA PERSIANA!", VENTANA.get_center() + Vector2(0, 10), Color(0.6, 0.9, 1.0), 16, 0.6)


## --- Eventos ---

## Golpe de la pata en su cuadro de impacto: un congelado corto y una sacudida chica (antes del vuelo).
func _al_impacto_pata(objeto: Node2D, tipo: String) -> void:
	if tipo == "tirar":
		jugo.congelar(congelado_pata)
		jugo.sacudir(0.1, 0.3)
		sonidos.sonar("golpe_pata")
		_anotar("pata toca %s en cuadro %d" % [objeto.get("tipo"), felipe.sprite.frame])


func _al_golpear_objeto(objeto: Tirable) -> void:
	objeto.set_meta("golpeo_valeria", false)
	if objeto.tipo == "control" and objeto.position.y >= SUELO - 1.0:
		_travesura("patear", "¡GOL!", 1.0, objeto.position + Vector2(0, -44), 0.3, "golpe")


func _al_romper(objeto: Tirable) -> void:
	var hablar: bool = not objeto.get_meta("golpeo_valeria", false)
	if objeto.tipo == "vaso":
		_travesura("tirar_vaso", "¡GRAVEDAD: 1 · VASO: 0!", ruido_rotura, objeto.position + Vector2(0, -44), 1.0, "rotura", hablar)
	else:
		_travesura("tirar_florero", "¡CRÍTICO! FLORERO: 0", ruido_rotura, objeto.position + Vector2(0, -44), 1.0, "rotura", hablar)
		if not agenda.esta_cumplida("florero"):
			# La foto estaba escondida en el florero: sale volando y cae flotando.
			_soltar("foto", objeto.position + Vector2(0, -30), Vector2(-felipe.mirando * 30.0, -160.0))
		agenda.avanzar("florero")


func _al_aterrizar_objeto(objeto: Tirable, fuerza: float) -> void:
	sonidos.sonar("golpe", 1.4 - minf(fuerza / 600.0, 0.5))
	if objeto.tipo == "control" and fuerza > 150.0 and objeto.get_meta("primera_caida", true):
		objeto.set_meta("primera_caida", false)
		if valeria.viendo_tele():
			# El control cae con la tele encendida: aprieta "ABRIR" y la persiana sube.
			_travesura("tirar_control", "¡ZAPPING DEFINITIVO!", ruido_golpe, objeto.position + Vector2(0, -44), 0.8, "golpe", false)
			_motivo_grito = "interrumpida"
			valeria.interrumpir()
			_abrir_persiana()
			agenda.avanzar("tele")
		else:
			_travesura("tirar_control", "¡ZAPPING DEFINITIVO!", ruido_golpe, objeto.position + Vector2(0, -44), 0.7, "golpe")


## Algo que vuela le cae encima a Valeria.
func _revisar_golpes_a_valeria() -> void:
	var cuerpo := valeria.cuerpo()
	if cuerpo.size == Vector2.ZERO:
		return
	for objeto: Tirable in [vaso, florero, control]:
		if objeto.estado != Tirable.Estado.VOLANDO or objeto.get_meta("golpeo_valeria", false):
			continue
		if not cuerpo.has_point(objeto.position + Vector2(0, -12)):
			continue
		objeto.set_meta("golpeo_valeria", true)
		_anotar("¡%s le cae encima a Valeria!" % objeto.tipo)
		jugo.congelar(0.12)
		jugo.sacudir(0.3, 1.0)
		jugo.destello(0.4, Color(0.6, 0.85, 1.0))
		jugo.palabra("¡IMPACTO DIRECTO!", Vector2(valeria.position.x + 20.0, SUELO - 56.0), Color(0.5, 0.85, 1.0), 22)
		sonidos.sonar("felipe_grito", 1.3)
		jugo.palabra("¡AAAY!", Vector2(valeria.position.x + 58.0, valeria.position.y - 150.0), Color(1.0, 0.35, 0.3), 20, 0.1)
		var estaba := valeria.presente()
		_motivo_grito = "golpeada"
		valeria.golpeada()
		if estaba:
			_valeria_dice("golpeada")
		objeto.chocar_con_valeria(SUELO)
		if not agenda.esta_cumplida("encima"):
			# Del susto se le cae el snack de emergencia del bolsillo.
			_soltar("snack", valeria.position + Vector2(0, -100), Vector2(-valeria.mirando * 70.0, -140.0))
		agenda.avanzar("encima")


func _al_aranar(_sofa: Sofa, punto: Vector2) -> void:
	sonidos.sonar("arañar", randf_range(0.9, 1.15))
	var hablar := tiempo - _ultimo_aranazo_hablado > 1.5
	if hablar:
		_ultimo_aranazo_hablado = tiempo
	jugo.congelar(0.06)
	jugo.sacudir(0.1, 0.35)
	# Una palabra por pulsación (los dos arañazos seguidos ya no se pisan las palabras).
	if tiempo - _ultima_palabra_aranazo > 0.8 and tiempo - _ultimo_critico > 1.0:
		_ultima_palabra_aranazo = tiempo
		var arriba := Vector2(punto.x, minf(punto.y, felipe.global_position.y - 70.0))
		jugo.palabra(["¡RIIIP!", "¡FIRMA DE AUTOR!", "¡RASS!"].pick_random() if hablar else "¡RIIIP!", arriba + Vector2(0, -12), Color(1.0, 0.92, 0.75), 16)
	valeria.oir(ruido_aranazo)
	_anotar("arañar" + (" (junto al rascador)" if punto.x >= Rascador.ZONA_SOFA_X else ""))
	# Secreta: arañar el sofá justo al lado del rascador nuevo, con Valeria mirando hacia el rascador.
	if punto.x >= Rascador.ZONA_SOFA_X and valeria.ve_x(Rascador.X) and not agenda.esta_cumplida("junto_rascador"):
		_cumplir_junto_rascador()
		return
	if hablar and sofa.con_plastico and not sofa.ultimo_critico:
		_felipe_dice("arañar")


func _cumplir_junto_rascador() -> void:
	_anotar("¡araña el sofá al lado del rascador delante de Valeria!")
	jugo.palabra("¡A DIEZ CENTÍMETROS!", Vector2(rascador.X - 20.0, 150), Color(1.0, 0.45, 0.6), 18, 0.1)
	_valeria_dice("junto_rascador")
	_foto_de_valeria("historias")
	# La foto estaba escondida detrás del rascador: sale volando con el portazo de indignación.
	var foto := _soltar("foto", Vector2(rascador.X + 6.0, Rascador.PLATAFORMA.position.y - 4.0), Vector2(40.0, -150.0))
	foto.variante = 1
	agenda.avanzar("junto_rascador")


## Arañazo con las garras afiladas: ¡CRÍTICO! (y el plástico se rompe de un golpe).
func _al_aranar_critico(_sofa: Sofa, punto: Vector2) -> void:
	_anotar("¡arañazo CRÍTICO con las garras afiladas!")
	_ultimo_critico = tiempo
	jugo.congelar(0.12)
	jugo.sacudir(0.25, 0.9)
	jugo.destello(0.35, Color(0.8, 0.95, 1.0))
	sonidos.sonar("rotura", 1.3)
	jugo.palabra("¡CRÍTICO!", Vector2(punto.x, minf(punto.y, felipe.global_position.y - 70.0) - 14.0), Color(0.6, 0.95, 1.0), 26)


## Rascador: cada golpe suelta fibras; el primero de la pulsación decide si hubo público.
func _al_usar_rascador(_r: Rascador, punto: Vector2, primero: bool) -> void:
	sonidos.sonar("arañar", randf_range(1.1, 1.3))
	jugo.sacudir(0.06, 0.2)
	valeria.oir(ruido_rascador)
	if not primero:
		return
	felipe.afilar_garras()
	var publico := valeria.ve_x(Rascador.X)
	# Con público, la palabra del filo sale después de la ovación (para no pisarse).
	jugo.palabra("¡GARRAS AFILADAS!", Vector2(punto.x + 20.0, felipe.global_position.y - 92.0), Color(0.7, 0.95, 1.0), 13, 1.1 if publico else 0.25)
	if publico:
		_perdon_por_rascador = true
		if valeria.perdonar_por_rascador():
			_anotar("usa el rascador CON público")
			return
		_perdon_por_rascador = false
		_anotar("usa el rascador con público (bis, sin premio)")
		jugo.palabra("¡RASS!", punto + Vector2(0, -20), Color(1.0, 0.92, 0.75), 14)
		var frase := _valeria_dice("rascador_bis")
		_felipe_responde("rascador_bis", frase)
		return
	_anotar("usa el rascador SIN público")
	jugo.palabra("¡RASS!", punto + Vector2(0, -20), Color(1.0, 0.92, 0.75), 14)
	_felipe_dice("rascador_solo", true)


func _al_romper_plastico(_sofa: Sofa) -> void:
	_anotar("el plástico del sofá se rompe")
	jugo.palabra("¡PLÁSTICO: 0!", Vector2(115, 170), Color(0.8, 0.95, 1.0), 18)
	sonidos.sonar("rotura", 1.6)
	# Entre los cojines estaba un calcetín perdido.
	_soltar("calcetin", Vector2(115, Sofa.ASIENTO.position.y - 4), Vector2(-felipe.mirando * 50.0, -230.0))
	agenda.avanzar("sofa")


func _al_comer(objeto: Plato) -> void:
	sonidos.sonar("comer")
	jugo.sacudir(0.06, 0.2)
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
	_travesura("maullar", "¡MIAU!", ruido_maullido, felipe.global_position + Vector2(felipe.mirando * 24.0, -86), 0.35, "pop")


func _al_intimidar(centro: Vector2) -> void:
	sonidos.sonar("bufido")
	jugo.destello(0.25, Color(1.0, 0.3, 0.2))
	var cerca := absf(aspiradora.position.x - felipe.global_position.x) <= aspiradora.alcance_intimidar and felipe.global_position.y > SUELO - 30.0
	if cerca and aspiradora.asustar(felipe.global_position.x):
		_travesura("intimidar", "¡FSSSHH! TERROR", ruido_intimidar, centro + Vector2(0, -58), 0.6, "golpe", false)
		jugo.palabra("¡PÁNICO ELECTRODOMÉSTICO!", Vector2(aspiradora.position.x + 90.0, SUELO - 24.0), Color(1.0, 0.45, 0.3), 15, 0.15)
		return
	_travesura("intimidar", "¡FSSSHH! TERROR", ruido_intimidar, centro + Vector2(0, -58), 0.6, "golpe")


func _al_escupir_aspiradora(punto: Vector2) -> void:
	_anotar("la aspiradora escupe un calcetín")
	sonidos.sonar("pop", 0.7)
	jugo.palabra("¡PTUH!", punto + Vector2(0, -30), Color(1.0, 0.95, 0.95), 16)
	var lado := signf(felipe.global_position.x - punto.x)
	_soltar("calcetin", punto, Vector2(lado * 60.0, -200.0))
	agenda.avanzar("aspiradora")


func _al_gritar(_v: Valeria) -> void:
	sonidos.sonar("felipe_grito")
	jugo.congelar(0.08)
	jugo.sacudir(0.3, 1.0)
	jugo.destello(0.3, Color(1.0, 0.6, 0.5))
	jugo.palabra("¡FELIPE!", Vector2(valeria.position.x, 96), Color(1.0, 0.35, 0.3), 28)
	_anotar("Valeria llega y grita" + (" (%s)" % _motivo_grito if _motivo_grito != "" else ""))
	if _motivo_grito == "interrumpida":
		_valeria_dice("interrumpida")
	elif _motivo_grito == "golpeada":
		_valeria_dice("golpeada")
	else:
		_valeria_dice("llega_florero" if florero.estado == Tirable.Estado.ROTO and randf() < 0.6 else "llega")
		_felipe_dice("llega_valeria")
	_motivo_grito = ""


func _al_perdonar(_v: Valeria) -> void:
	sonidos.sonar("ronroneo_off")
	sonidos.sonar("perdon")
	perdones += 1
	jugo.congelar(0.1)
	jugo.destello(0.4, Color(1.0, 0.75, 0.85))
	jugo.sacudir(0.15, 0.4)
	var teatro := _perdon_por_rascador
	_perdon_por_rascador = false
	if teatro:
		# "Teatro para Valeria": respuesta épica propia, frase de ella y luego la de Felipe.
		jugo.congelar(0.14)
		jugo.sacudir(0.25, 0.7)
		jugo.palabra("¡OVACIÓN!", Vector2(rascador.X + 60.0, 160), Color(1.0, 0.55, 0.75), 26)
		jugo.palabra("¡PERDONADO SIN RONRONEAR!", felipe.global_position + Vector2(10, -84), Color(1.0, 0.9, 0.5), 13, 0.2)
		_anotar("Valeria perdona por el rascador (%d)" % perdones)
		var frase := _valeria_dice("rascador")
		# Si este perdón cumple la agenda, Felipe contesta con la frase de la travesura.
		if agenda.esta_cumplida("perdon") or agenda.avance["perdon"] + 1 < 2:
			_felipe_responde("rascador_publico", frase)
	else:
		jugo.palabra("¡CARISMA CRÍTICO!", felipe.global_position + Vector2(0, -112), Color(1.0, 0.55, 0.75), 22)
		jugo.palabra("¡PERDONADO!", felipe.global_position + Vector2(0, -84), Color(1.0, 0.9, 0.5), 14, 0.15)
		_anotar("Valeria perdona (%d)" % perdones)
		var frase := _valeria_dice("perdona")
		if agenda.esta_cumplida("perdon") or agenda.avance["perdon"] + 1 < 2:
			_felipe_responde("perdonado", frase)
	_foto_de_valeria()
	# Snack que cae de la mano de Valeria, junto a Felipe (no encima del plato).
	var x := clampf(felipe.global_position.x + felipe.mirando * 30.0, 60.0, 520.0)
	if absf(x - plato.position.x) < 40.0:
		x = plato.position.x - 46.0 if felipe.global_position.x < plato.position.x else minf(plato.position.x + 46.0, 520.0)
	snack = _soltar("snack", Vector2(x, SUELO - 90.0), Vector2(0, -40))
	agenda.avanzar("perdon")


func _al_sentarse(_v: Valeria) -> void:
	_anotar("Valeria se sienta a ver su serie")
	if control.necesita_reponer():
		_reponer(control)
	if persiana_abierta > 0.0 and not _dijo_persiana:
		_dijo_persiana = true
		_valeria_dice("persiana")
	else:
		_valeria_dice("tele")
		_felipe_dice("tele")


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
			_reponer(objeto)
			repuso = true
	if plato.porciones < plato.porciones_max:
		plato.rellenar()
		repuso = true
	if repuso:
		_felipe_dice("se_fue")


## Repone un objeto; si Felipe está parado donde va (p. ej. en la repisa), espera a que se mueva
## (arreglo de la v1: el florero aparecía encima de Felipe).
func _reponer(objeto: Tirable) -> void:
	var d := felipe.global_position - objeto.origen
	if absf(d.x) < 44.0 and absf(d.y) < 50.0:
		if not _reponer_pendiente.has(objeto):
			_reponer_pendiente.append(objeto)
		return
	objeto.reponer()
	objeto.set_meta("primera_caida", true)
	objeto.set_meta("golpeo_valeria", false)


func _reponer_lo_pendiente() -> void:
	for objeto: Tirable in _reponer_pendiente.duplicate():
		var d := felipe.global_position - objeto.origen
		if absf(d.x) >= 44.0 or absf(d.y) >= 50.0:
			_reponer_pendiente.erase(objeto)
			objeto.reponer()
			objeto.set_meta("primera_caida", true)
			objeto.set_meta("golpeo_valeria", false)


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
	# Cuadro en la pared (de Felipe, claro).
	draw_rect(Rect2(404, 22, 58, 46), Color(0.4, 0.28, 0.2))
	draw_rect(Rect2(409, 27, 48, 36), Color(0.95, 0.85, 0.55))
	draw_circle(Vector2(433, 46), 10.0, Color(0.5, 0.45, 0.42))
	draw_string(ThemeDB.fallback_font, Vector2(404, 78), "SU MAJESTAD", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.4, 0.28, 0.2))
	_dibujar_ventana()
	_dibujar_tele()
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


## Ventana con persiana eléctrica. Cerrada, la persiana tapa también el alféizar y asoma la punta de un
## calcetín por abajo (la pista). Abierta: cielo, alféizar de madera y el calcetín.
func _dibujar_ventana() -> void:
	var marco := Color(0.95, 0.93, 0.88)
	draw_rect(VENTANA.grow(6), marco)
	draw_rect(VENTANA, Color(0.55, 0.78, 0.95))
	# Afuera: nube y techo vecino.
	draw_circle(VENTANA.position + Vector2(30, 24), 9.0, Color(1, 1, 1, 0.9))
	draw_circle(VENTANA.position + Vector2(42, 22), 11.0, Color(1, 1, 1, 0.9))
	draw_rect(Rect2(VENTANA.position + Vector2(0, 56), Vector2(VENTANA.size.x, 24)), Color(0.62, 0.36, 0.3))
	draw_line(VENTANA.position + Vector2(VENTANA.size.x / 2.0, 0), VENTANA.position + Vector2(VENTANA.size.x / 2.0, VENTANA.size.y), marco, 3.0)
	# Alféizar (solo si la persiana subió).
	if persiana_abierta > 0.0:
		draw_rect(ALFEIZAR, Color(0.55, 0.36, 0.22))
		draw_rect(Rect2(ALFEIZAR.position + Vector2(4, ALFEIZAR.size.y), Vector2(ALFEIZAR.size.x - 8, 4)), Color(0.4, 0.26, 0.16))
	# Persiana: tablillas que suben enrolladas.
	var alto := (ALFEIZAR.end.y + 2.0 - VENTANA.position.y) * (1.0 - persiana_abierta)
	var persiana := Rect2(VENTANA.position.x - 8, VENTANA.position.y - 6, VENTANA.size.x + 16, alto + 6)
	if alto > 0.5:
		draw_rect(persiana, Color(0.82, 0.8, 0.74))
		var y := persiana.position.y + 6.0
		while y < persiana.end.y:
			draw_line(Vector2(persiana.position.x, y), Vector2(persiana.end.x, y), Color(0.66, 0.64, 0.58), 1.0)
			y += 6.0
		draw_rect(persiana, Color(0.5, 0.48, 0.44), false, 1.0)
		if persiana_abierta == 0.0:
			# La punta del calcetín asoma bajo la persiana.
			var p := Vector2(CALCETIN_ALFEIZAR_X - 6, persiana.end.y)
			draw_rect(Rect2(p, Vector2(14, 6)), Color(0.95, 0.95, 0.92))
			draw_rect(Rect2(p + Vector2(0, 2), Vector2(14, 2)), Color(0.85, 0.25, 0.3))
	# Caja enrollada arriba.
	draw_rect(Rect2(VENTANA.position.x - 10, VENTANA.position.y - 12, VENTANA.size.x + 20, 8), Color(0.75, 0.73, 0.68))


## Tele en la pared: apagada, gris; encendida (Valeria viendo su serie), colores que cambian.
func _dibujar_tele() -> void:
	draw_rect(TELE.grow(3), Color(0.1, 0.1, 0.12))
	if valeria.viendo_tele():
		var colores := [Color(0.9, 0.4, 0.5), Color(0.4, 0.7, 0.95), Color(0.95, 0.85, 0.4), Color(0.5, 0.85, 0.55)]
		var k := int(tiempo * 2.0)
		draw_rect(TELE, colores[k % 4].darkened(0.2))
		# Dos siluetas besándose: es una teleserie.
		draw_circle(TELE.position + Vector2(36, 26), 9.0, colores[(k + 1) % 4].darkened(0.5))
		draw_circle(TELE.position + Vector2(54, 26), 9.0, colores[(k + 2) % 4].darkened(0.5))
		draw_rect(Rect2(TELE.position + Vector2(24, 36), Vector2(42, 20)), colores[(k + 3) % 4].darkened(0.5))
	else:
		draw_rect(TELE, Color(0.2, 0.22, 0.25))
		draw_line(TELE.position + Vector2(8, 8), TELE.position + Vector2(28, 28), Color(1, 1, 1, 0.12), 3.0)
	draw_rect(Rect2(TELE.position + Vector2(TELE.size.x / 2.0 - 4, TELE.size.y + 3), Vector2(8, 6)), Color(0.1, 0.1, 0.12))


## El resumen automático espera a que Felipe recoja lo que quedó en el piso.
func _hay_recompensas_sueltas() -> bool:
	for n in get_children():
		if n is Recogible and not n.get("_recogido"):
			return true
	return false
