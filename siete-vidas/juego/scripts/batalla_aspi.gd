class_name BatallaAspi
extends Node2D
## Pelea con A.S.P.I. en el estudio de Valeria ("La Bestia del Estudio", depósito lleno). Es el examen del nivel (R12):
## tirar (ensuciar), agacharse (aferrarse a la succión), muebles como escalera (silla → escritorio → repisa) y saltar
## (caerle encima, esquivar bolas). La entrada son los 8 pasos de PresentacionJefe (la misma para todos los jefes):
## esta pelea solo da sus datos y su "momento" (en la imaginación de Felipe crece hasta ser una bestia gigante en un
## estudio en llamas). Empieza DESPUÉS del fundido de la puerta (arregla B1).
## La pelea: los zarpazos rebotan en la carcasa. Todo lo que se rompe en el piso deja una mancha; ella va a limpiarla
## (anticipación: el cepillo gira 0,6 s) y aspira (de pie arrastra a Felipe; agachado se aferra). Cada mancha le llena
## el depósito; lleno, se detiene pitando, inofensiva, y Felipe le salta encima para apretarle el botón (congelado,
## destello, sacudida, «¡CLIC!» y polvo). Tres apagados la apagan del todo.
## Ataques, siempre anunciados: embestida (retrocede, luz roja 0,5 s), soplido contra el que acampa (desde la fase 2:
## si Felipe pasa más de 3 s arriba de algo de más de 90 px, va debajo, vibra con luz amarilla 0,6 s y lo saca de un
## soplido; las macetas caen sin romperse) y, en la fase 3, bolas de pelo en arco (tos mecánica 0,5 s). Lo que se
## rompe vuelve de a uno cada 6 s: hay que bajar por el rollo, el vaso o los papeles del teclado (G12).
## Si Felipe pierde una vida, reaparece en el cojín y al volver conserva la fase (entrada corta de 1 s).

signal empezada
signal fase_cambiada(fase: Fase)
signal terminada

enum Fase { ESPERANDO, ENTRADA, PELEA, FIN }
enum Ataque { NINGUNO, AVISO_EMBESTIDA, EMBESTIDA, AVISO_SOPLIDO, SOPLIDO, AVISO_BOLA }

const NOMBRE := "A.S.P.I."
const TITULO := "Devoradora de Pelos · Nivel 99"
const RUGIDO := "DETECTANDO SUCIEDAD. DETECTANDO… GATO."
const APAGADOS_TOTALES := 3
## Por fase (0, 1 o 2 apagados): manchas para llenar el depósito, segundos detenida y segundos limpiando cada mancha.
const CAPACIDAD := [2, 3, 3]
const TIEMPO_LLENA := [4.0, 3.5, 3.0]
const TIEMPO_LIMPIEZA := [2.6, 2.2, 1.8]
const VELOCIDAD := [55.0, 70.0, 85.0]
## Más que caminar (120 px/s): de pie no se escapa; hay que agacharse. En furia aspira desde más lejos.
const FUERZA_SUCCION := 150.0
const RADIO_SUCCION := [200.0, 200.0, 260.0]
const AVISO_SUCCION := 0.6
## Embestida: anticipación, carrera y espera entre una y otra.
const AVISO_EMBESTIDA := 0.5
const DURACION_EMBESTIDA := 0.6
const ESPERA_EMBESTIDA := [2.4, 2.0, 1.7]
const DISTANCIA_EMBESTIDA := 170.0
## Contra el que acampa (G12): altura que cuenta como "arriba", segundos que tolera por fase, aviso y soplido.
const ALTURA_ACAMPAR := 90.0
const TIEMPO_ACAMPAR := [INF, 3.0, 2.0]
const AVISO_SOPLIDO := 0.6
const EMPUJE_SOPLIDO := 300.0
const DURACION_SOPLIDO := 0.45
const VELOCIDAD_A_DEBAJO := 190.0
## Bolas de pelo en arco (fase 3).
const ESPERA_BOLAS := 2.2
const AVISO_BOLA := 0.5
const GRAVEDAD_BOLA := 600.0
const VUELO_BOLA := 0.9
## Lo que se rompe vuelve de a uno, cada tanto.
const REPOSICION := 6.0
const DESVANECER := 0.8
## Al reiniciarse tras un apagado se queda quieta e inofensiva un momento: Felipe alcanza a alejarse.
const REINICIO := 1.5
const REBOTE := -420.0
## Lleno bajo la repisa: sale disparada hacia adelante (nunca queda justo bajo la repisa).
const EMPUJE_LLENA := 80.0
## Alto del dibujo de A.S.P.I.: Felipe la apaga si cae sobre esa franja.
const ALTO_ARRIBA := 40.0
const PISTAS := [
	"Tira cosas al piso: limpiar le llena el depósito",
	"Si te aspira, mantén {agacharse}. Y no acampes arriba",
	"¡Bolas de pelo! Salta y no te quedes quieto",
]
const PISTA_LLENA := "Sáltale encima y aprieta el botón"
const CARTELES := ["FASE 1: ¡LLÉNALE EL DEPÓSITO!", "FASE 2: ¡SE REINICIÓ!", "FASE 3: ¡FURIA!"]

var fase := Fase.ESPERANDO
var aspi: Aspi
var felipe: Felipe
var sala: Sala
var apagados := 0
var deposito := 0
var llena := false
## x de cada mancha en el piso (y qué es: "mancha" o "papel").
var manchas: Array[float] = []
var tipos_mancha: Array[String] = []
var limpiando := false
var succionando := false
var ataque := Ataque.NINGUNO
## Segundos que lleva Felipe arriba de algo (para el soplido).
var acampando := 0.0
## 0 = estudio normal, 1 = fin del mundo (solo en la entrada).
var transformacion := 0.0
## 0 = A.S.P.I. de tamaño real, 1 = bestia gigante del fondo (solo en la entrada).
var gigante := 0.0
var bolas: Array[Node2D] = []
## Entrada de 8 pasos, carteles y barra de vida (componente reutilizable para cualquier jefe).
var presentacion: PresentacionJefe
## El estudio: ahí se pelea.
var arena: Rect2
## Felipe salió del estudio (perdió una vida): A.S.P.I. espera en su base y al volver hay entrada corta.
var ausente := false
## Soplidos dados (para pruebas y el resumen).
var soplidos := 0

var _reloj := 0.0
var _reloj_ataque := 0.0
var _espera_embestida := 0.0
var _espera_bola := 0.0
var _aviso_succion := 0.0
var _reinicio := 0.0
var _rayo := 0.0
var _desvaneciendo := false
var _volviendo := false
var _centro_gigante := Vector2.ZERO
var _encima: Node2D
var _imaginacion: Node2D
var _manchas_dibujo: Node2D
var _municion: Array[Vaso] = []
var _por_reponer: Array[Vaso] = []
var _reloj_reponer := 0.0
var _destino_embestida := 0.0
var _hacia_soplido := 1.0
var _polvo: CPUParticles2D
var _papeles: Array[Vector3] = []
## Cuándo fue el último «¡CLIC!» (s): mientras se ve, no hay otro rótulo sobre A.S.P.I. (M3).
var _tiempo_clic := -10.0
const DURA_CLIC := 1.3


func _init(jefa: Aspi, gato: Felipe, nivel: Sala) -> void:
	aspi = jefa
	felipe = gato
	sala = nivel
	name = "Batalla"
	arena = Sala.rect_de("estudio")
	_centro_gigante = Vector2(arena.get_center().x, Sala.SUELO - 160)
	# La batalla en sí no dibuja nada: cada parte va en su capa de la tabla única (Capas, B1 de la revisión 3).
	z_index = Capas.JUEGO
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	aspi.apagado.connect(_terminar)
	aspi.oyo_maullido.connect(_al_oir_maullido)
	aspi.quieta = true
	aspi.invulnerable = true
	# Sin jefa no hay pelea (algunas pruebas la quitan).
	aspi.tree_exiting.connect(queue_free)
	presentacion = PresentacionJefe.new(NOMBRE, TITULO)
	presentacion.texto_rugido = RUGIDO
	presentacion.alto_jefe = Aspi.ALTO + 20.0
	presentacion.encuadre_momento = _centro_gigante + Vector2(0, 40)
	presentacion.terminada.connect(_al_terminar_presentacion)
	presentacion.paso_empezado.connect(_al_paso)
	presentacion.empujon.connect(_al_empujon)
	add_child(presentacion)
	# La imaginación de Felipe tapa TODO el escenario (muebles, puertas, repisa); solo Felipe va delante (B1).
	_imaginacion = Node2D.new()
	_imaginacion.name = "Imaginacion"
	Capas.usar(_imaginacion, Capas.IMAGINACION)
	_imaginacion.draw.connect(_dibujar_imaginacion)
	add_child(_imaginacion)
	_manchas_dibujo = Node2D.new()
	_manchas_dibujo.name = "Manchas"
	Capas.usar(_manchas_dibujo, Capas.MUEBLES)
	_manchas_dibujo.draw.connect(_dibujar_manchas)
	add_child(_manchas_dibujo)
	_encima = Node2D.new()
	_encima.name = "Viento y depósito"
	Capas.usar(_encima, Capas.EFECTOS)
	_encima.draw.connect(_dibujar_encima)
	add_child(_encima)
	_polvo = CPUParticles2D.new()
	_polvo.name = "Polvo"
	Capas.usar(_polvo, Capas.EFECTOS)
	_polvo.emitting = false
	_polvo.one_shot = true
	_polvo.amount = 24
	_polvo.lifetime = 0.7
	_polvo.explosiveness = 1.0
	_polvo.direction = Vector2(0, -1)
	_polvo.spread = 90.0
	_polvo.gravity = Vector2(0, 220)
	_polvo.initial_velocity_min = 50.0
	_polvo.initial_velocity_max = 140.0
	_polvo.scale_amount_min = 2.0
	_polvo.scale_amount_max = 4.0
	_polvo.color = Color(0.86, 0.82, 0.75)
	add_child(_polvo)


## Lo que se puede tirar en el estudio: vuelve de a uno cuando se rompe (o cuando un soplido lo tira).
func agregar_municion(objeto: Vaso) -> void:
	_municion.append(objeto)
	objeto.caido.connect(func(posicion: Vector2) -> void:
		agregar_mancha(posicion)
		_por_reponer.append(objeto))
	objeto.tirado.connect(func(o: Vaso) -> void: _por_reponer.append(o))


func _process(delta: float) -> void:
	_rayo = maxf(0.0, _rayo - delta * 4.0)
	if fase == Fase.ENTRADA and not _desvaneciendo:
		gigante = ease(presentacion.momento, 0.4)
		transformacion = presentacion.momento
		if presentacion.momento > 0.0 and fmod(presentacion.t, 0.9) < delta:
			_rayo = 1.0
	# Nunca dos A.S.P.I. a la vez (B1): la real se esconde mientras exista la gigante y vuelve justo cuando la
	# gigante, ya encogida hasta su tamaño y su lugar, desaparece (con un «¡puf!» de polvo).
	var habia_gigante := not aspi.visible
	if not habia_gigante and gigante > 0.0:
		# Nace la bestia: «¡puf!» y destello, para que el cambio de la aspiradora a la gigante no sea un corte seco.
		_polvo.global_position = aspi.global_position + Vector2(0, -20)
		_polvo.restart()
		_polvo.emitting = true
		presentacion.destello(0.45)
	aspi.visible = gigante <= 0.0
	if habia_gigante and aspi.visible and fase != Fase.ESPERANDO:
		_polvo.global_position = aspi.global_position + Vector2(0, -20)
		_polvo.restart()
		_polvo.emitting = true
	# Felipe queda delante de su propia imaginación; el escenario, detrás.
	felipe.z_index = Capas.FELIPE_IMAGINANDO if (gigante > 0.0 or transformacion > 0.0) else Capas.JUEGO
	presentacion.vida = 1.0 - float(apagados) / APAGADOS_TOTALES if fase == Fase.PELEA else -1.0
	presentacion.escudo = float(deposito) / CAPACIDAD[mini(apagados, 2)] if fase == Fase.PELEA else 0.0
	if not _papeles.is_empty():
		for i in _papeles.size():
			_papeles[i].y += delta
		_papeles = _papeles.filter(func(p: Vector3) -> bool: return p.y < 1.2)
	_imaginacion.queue_redraw()
	_encima.queue_redraw()
	_manchas_dibujo.queue_redraw()


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	match fase:
		Fase.ESPERANDO:
			# Al entrar al estudio (ya terminado el fundido de la puerta), A.S.P.I. despierta.
			if _felipe_en_arena() and felipe.is_on_floor() and not sala.cruzando():
				empezar()
		Fase.PELEA:
			if not _felipe_en_arena():
				_salir()
			elif ausente:
				if felipe.is_on_floor() and not sala.cruzando() and not presentacion.presentando:
					_volver()
			else:
				_actualizar_pelea(delta)
	_mover_bolas(delta)
	_reponer(delta)


func _felipe_en_arena() -> bool:
	return arena.grow_individual(-30, 0, -30, 0).has_point(felipe.global_position - Vector2(0, 1))


## Arranca la entrada: congela el juego y toma la cámara.
func empezar() -> void:
	if fase != Fase.ESPERANDO:
		return
	fase = Fase.ENTRADA
	aspi.necesita_aturdir = true
	aspi.invulnerable = true
	aspi.quieta = true
	aspi.inofensiva = true
	felipe.empuje = Vector2.ZERO
	presentacion.divisiones = APAGADOS_TOTALES
	presentacion.pantallas = sala.pantallas
	presentacion.frase_sin_vuelta = ["Felipe", Frases.FELIPE["quien_cerro"][0][0]]
	presentacion.presentar(felipe, aspi, Rect2(arena.position.x, 0, arena.size.x, Sala.ALTO))
	# En la pelea las puertas cerradas del estudio no se ofrecen: "Probar" pisaba a A.S.P.I. llena (M3) y, junto a la
	# puerta de entrada, mantener la acción probaba la puerta en vez de comer un snack del bolsillo.
	for nombre: String in [Sala.PUERTA_BALCON, "estudio<pasillo"]:
		var puerta: Puerta = sala.puertas.get(nombre)
		if puerta:
			puerta.ofrecer_cerrada = false
	empezada.emit()


## Para pruebas y depuración: termina la entrada de golpe.
func saltar_entrada() -> void:
	presentacion.saltar()


## Algo se rompió en el piso: si es en el estudio y hay pelea, queda una mancha para limpiar.
func agregar_mancha(posicion: Vector2, tipo := "mancha") -> void:
	if fase in [Fase.ESPERANDO, Fase.FIN] or not arena.grow(4).has_point(posicion - Vector2(0, 1)):
		return
	manchas.append(clampf(posicion.x, aspi.limite_izquierdo, aspi.limite_derecho))
	tipos_mancha.append(tipo)
	if tipo == "papel":
		_papeles.append(Vector3(posicion.x, 0.0, 0.0))


func _al_paso(paso: String) -> void:
	var puerta: Puerta = sala.puertas.get("estudio<pasillo")
	match paso:
		"sin_vuelta_atras":
			# La puerta se cierra sola con un portazo.
			if puerta:
				# Portazo: se cierra de golpe (con el juego congelado la hoja no alcanzaría a girar).
				puerta.cerrada = true
				puerta.apertura = 0.0
				puerta.queue_redraw()
			sala.sonar("golpe")
			_polvo.global_position = puerta.global_position if puerta else felipe.global_position
			_polvo.restart()
			_polvo.emitting = true
			# La frase la muestra la presentación como subtítulo (el diálogo se esconde durante la entrada, M4).
		"espera":
			aspi.luz_aviso = Color("e0483b")
		"musica":
			sala.sonar("batalla")
		"rugido":
			aspi.luz_aviso = Color(0, 0, 0, 0)
			_desvaneciendo = true
			for i in 10:
				_papeles.append(Vector3(arena.position.x + 200 + i * 24.0, 0.0, randf()))
			var vuelta := create_tween().set_parallel()
			vuelta.tween_property(self, "gigante", 0.0, DESVANECER)
			vuelta.tween_property(self, "transformacion", 0.0, DESVANECER)
			sala.sonar("succion")


## Vender el tamaño: cada empujón la acerca a Felipe y sacude la pantalla.
func _al_empujon(_numero: int) -> void:
	var hacia := signf(felipe.global_position.x - aspi.global_position.x)
	var paso := create_tween()
	paso.tween_property(aspi, "position:x", aspi.position.x + hacia * 14.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sala.sonar("golpe")


func _al_terminar_presentacion() -> void:
	aspi.visible = true
	if fase == Fase.PELEA and _volviendo:
		_volviendo = false
		ausente = false
		aspi.quieta = false
		return
	if fase != Fase.ENTRADA:
		return
	fase = Fase.PELEA
	gigante = 0.0
	transformacion = 0.0
	aspi.quieta = false
	aspi.vision = arena.size.x
	_cambiar_fase()


## Felipe salió del estudio (perdió una vida y reapareció en el cojín): todo queda en pausa, con la fase guardada.
func _salir() -> void:
	if ausente:
		return
	ausente = true
	_terminar_ataque()
	felipe.empuje = Vector2.ZERO
	manchas.clear()
	tipos_mancha.clear()
	limpiando = false
	llena = false
	deposito = 0
	aspi.cerrar_tapa()
	aspi.quieta = true
	aspi.inofensiva = true
	aspi.global_position = Sala.ASPI[0]
	for bola in bolas.duplicate():
		_quitar_bola(bola)


## Vuelve a la pelea: entrada corta (portazo y nombre, 1 s) y sigue en la fase a la que llegó.
func _volver() -> void:
	_volviendo = true
	presentacion.presentar_corta(felipe, aspi, Rect2(arena.position.x, 0, arena.size.x, Sala.ALTO))


func _cambiar_fase() -> void:
	_reloj = 0.0
	deposito = 0
	llena = false
	acampando = 0.0
	_terminar_ataque()
	_espera_embestida = ESPERA_EMBESTIDA[apagados]
	_espera_bola = ESPERA_BOLAS
	_reinicio = REINICIO if apagados > 0 else 0.0
	aspi.quieta = _reinicio > 0.0
	aspi.inofensiva = true
	aspi.velocidad_patrulla = VELOCIDAD[apagados] * 0.7
	aspi.velocidad_persecucion = VELOCIDAD[apagados]
	presentacion.cartel(CARTELES[apagados], 2.4, PISTAS[apagados])
	presentacion.destello(0.4)
	presentacion.sacudir(0.25)
	fase_cambiada.emit(fase)


func _actualizar_pelea(delta: float) -> void:
	if ataque != Ataque.SOPLIDO:
		felipe.empuje = Vector2.ZERO
	succionando = false
	_espera_embestida = maxf(0.0, _espera_embestida - delta)
	if _reinicio > 0.0:
		_reinicio -= delta
		if _reinicio <= 0.0:
			aspi.quieta = false
		return
	if llena:
		_actualizar_llena(delta)
		return
	if aspi.esta_aturdida():
		_terminar_ataque()
		limpiando = false
		aspi.destino = INF
		return
	_contar_acampada(delta)
	if ataque != Ataque.NINGUNO:
		_actualizar_ataque(delta)
		return
	# En furia, la tos cuenta siempre (también si Felipe acampa arriba): la bola en arco es justo lo que llega al
	# escritorio y a la repisa (M8 de la revisión 3: antes el reloj se detenía mientras acampaba y la bola salía o no
	# según dónde lo dejara caer el soplido).
	if apagados >= 2:
		_espera_bola -= delta
		if _espera_bola <= 0.0 and manchas.is_empty():
			_empezar_ataque(Ataque.AVISO_BOLA)
			return
	# Contra el que acampa: va debajo y, a su tiempo, sopla.
	if apagados >= 1 and acampando > 1.0:
		aspi.destino = felipe.global_position.x
		aspi.velocidad_persecucion = VELOCIDAD_A_DEBAJO
		if acampando >= TIEMPO_ACAMPAR[apagados] and absf(aspi.global_position.x - felipe.global_position.x) < 16.0:
			_empezar_ataque(Ataque.AVISO_SOPLIDO)
		return
	aspi.velocidad_persecucion = VELOCIDAD[apagados]
	if not manchas.is_empty():
		_limpiar(delta)
		return
	limpiando = false
	_aviso_succion = 0.0
	aspi.destino = INF
	var distancia := felipe.global_position - aspi.global_position
	if _espera_embestida <= 0.0 and felipe.is_on_floor() and absf(distancia.y) < 30.0 and absf(distancia.x) < DISTANCIA_EMBESTIDA:
		_empezar_ataque(Ataque.AVISO_EMBESTIDA)
		return


func _contar_acampada(delta: float) -> void:
	if felipe.is_on_floor() and Sala.SUELO - felipe.global_position.y > ALTURA_ACAMPAR:
		acampando += delta
	elif felipe.is_on_floor() or felipe.global_position.y > Sala.SUELO - ALTURA_ACAMPAR:
		acampando = 0.0


## Va a la mancha, gira el cepillo 0,6 s (anticipación) y aspira hasta limpiarla.
func _limpiar(delta: float) -> void:
	var mancha := manchas[0]
	aspi.destino = mancha
	if absf(aspi.global_position.x - mancha) >= 6.0:
		return
	if not limpiando:
		_aviso_succion += delta
		aspi.vibrando = true
		if _aviso_succion < AVISO_SUCCION:
			return
		aspi.vibrando = false
		limpiando = true
		_reloj = 0.0
		sala.sonar("succion")
	_reloj += delta
	succionando = true
	_aspirar()
	if _reloj >= TIEMPO_LIMPIEZA[apagados]:
		manchas.pop_front()
		tipos_mancha.pop_front()
		limpiando = false
		_aviso_succion = 0.0
		_reloj = 0.0
		deposito += 1
		# Un solo rótulo a la vez sobre A.S.P.I. (M3): si con esto se llena, solo «¡LLENO!».
		if deposito >= CAPACIDAD[apagados]:
			_llenar()
		else:
			sala.travesuras.jugo.palabra_en_mundo("+1 · Glup.", aspi.global_position + Vector2(0, -60), Color(0.5, 0.85, 1.0), 14)


func _empezar_ataque(cual: Ataque) -> void:
	ataque = cual
	_reloj_ataque = 0.0
	match cual:
		Ataque.AVISO_EMBESTIDA:
			# Se echa atrás 10 px, luz roja que parpadea y un chirrido.
			aspi.quieta = true
			aspi.destino = INF
			aspi.luz_aviso = Color("e0483b")
			var hacia := signf(felipe.global_position.x - aspi.global_position.x)
			var atras := create_tween()
			atras.tween_property(aspi, "position:x", aspi.position.x - hacia * 10.0, 0.15)
			_destino_embestida = clampf(felipe.global_position.x + hacia * 70.0, aspi.limite_izquierdo, aspi.limite_derecho)
			sala.sonar("zarpazo")
		Ataque.AVISO_SOPLIDO:
			aspi.quieta = true
			aspi.destino = INF
			aspi.vibrando = true
			aspi.luz_aviso = Color("ffd23f")
			sala.sonar("succion")
			sala.travesuras.jugo.palabra_en_mundo("¡FUUU!", aspi.global_position + Vector2(0, -60), Color(1.0, 0.9, 0.4), 14)
		Ataque.AVISO_BOLA:
			aspi.quieta = true
			aspi.destino = INF
			aspi.vibrando = true
			sala.travesuras.jugo.palabra_en_mundo("¡COF!", aspi.global_position + Vector2(0, -58), Color(0.9, 0.9, 0.9), 13)


func _actualizar_ataque(delta: float) -> void:
	_reloj_ataque += delta
	match ataque:
		Ataque.AVISO_EMBESTIDA:
			if _reloj_ataque >= AVISO_EMBESTIDA:
				ataque = Ataque.EMBESTIDA
				_reloj_ataque = 0.0
				aspi.quieta = false
				aspi.inofensiva = false
				aspi.velocidad_persecucion = VELOCIDAD[apagados] * 3.0
				aspi.destino = _destino_embestida
		Ataque.EMBESTIDA:
			if _reloj_ataque >= DURACION_EMBESTIDA or absf(aspi.global_position.x - _destino_embestida) < 6.0:
				_terminar_ataque()
				_espera_embestida = ESPERA_EMBESTIDA[apagados]
		Ataque.AVISO_SOPLIDO:
			if _reloj_ataque >= AVISO_SOPLIDO:
				_soplar()
		Ataque.SOPLIDO:
			if _reloj_ataque >= DURACION_SOPLIDO:
				felipe.empuje = Vector2.ZERO
				_terminar_ataque()
		Ataque.AVISO_BOLA:
			if _reloj_ataque >= AVISO_BOLA:
				_terminar_ataque()
				_escupir_bola()
				_espera_bola = ESPERA_BOLAS


func _terminar_ataque() -> void:
	ataque = Ataque.NINGUNO
	_reloj_ataque = 0.0
	aspi.luz_aviso = Color(0, 0, 0, 0)
	aspi.vibrando = false
	aspi.quieta = false
	aspi.inofensiva = true
	aspi.destino = INF
	aspi.velocidad_persecucion = VELOCIDAD[mini(apagados, 2)]


## Sopla hacia arriba: Felipe sale empujado al piso (sin daño) y las macetas caen sin romperse.
func _soplar() -> void:
	ataque = Ataque.SOPLIDO
	_reloj_ataque = 0.0
	soplidos += 1
	aspi.vibrando = false
	acampando = 0.0
	# Desde la repisa sale hacia la puerta del balcón; desde el escritorio, hacia la silla: siempre a algo bajo.
	var repisa := sala.pieza("Repisa de las macetas")
	_hacia_soplido = 1.0 if repisa and felipe.global_position.x >= repisa.position.x - 4.0 else -1.0
	felipe.velocity = Vector2(_hacia_soplido * EMPUJE_SOPLIDO, -300.0)
	felipe.empuje = Vector2(_hacia_soplido * EMPUJE_SOPLIDO * 0.6, 0.0)
	presentacion.sacudir(0.2)
	sala.travesuras.jugo.palabra_en_mundo("¡FIUUU!", felipe.global_position + Vector2(0, -80), Color(0.8, 0.95, 1.0), 16)
	for objeto in _municion:
		if objeto.tipo == "maceta" and not objeto.roto and objeto.visible:
			objeto.caer_sin_romper(_hacia_soplido)


## Lo roto (o tirado) vuelve de a uno, cada REPOSICION segundos, mientras dure la pelea.
func _reponer(delta: float) -> void:
	if _por_reponer.is_empty() or fase == Fase.FIN:
		_reloj_reponer = 0.0
		return
	_reloj_reponer += delta
	if _reloj_reponer >= REPOSICION:
		_reloj_reponer = 0.0
		var objeto: Vaso = _por_reponer.pop_front()
		if is_instance_valid(objeto):
			objeto.reponer()


## Depósito lleno: se detiene pitando, inofensiva, y espera a que se lo vacíen... o a que Felipe la apague.
func _llenar() -> void:
	llena = true
	_reloj = 0.0
	_terminar_ataque()
	aspi.destino = INF
	aspi.quieta = true
	aspi.inofensiva = true
	aspi.abrir_tapa()
	sala.sonar("logro")
	presentacion.cartel("¡DEPÓSITO LLENO!", 1.6, PISTA_LLENA)
	# Nunca queda justo bajo la repisa: sale disparada unos 80 px hacia adelante.
	var repisa := sala.pieza("Repisa de las macetas")
	if repisa and absf(aspi.global_position.x - (repisa.position.x + 30.0)) < 70.0:
		var hacia := 1.0 if aspi.global_position.x + EMPUJE_LLENA < aspi.limite_derecho else -1.0
		var sale := create_tween()
		sale.tween_property(aspi, "position:x", clampf(aspi.position.x + hacia * EMPUJE_LLENA, aspi.limite_izquierdo, aspi.limite_derecho), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _actualizar_llena(delta: float) -> void:
	_reloj += delta
	# Felipe cae sobre ella: le aprieta el botón de apagado con las patas.
	var distancia := felipe.global_position - aspi.global_position
	if felipe.velocity.y > 0.0 and absf(distancia.x) < Aspi.ANCHO / 2.0 + 4.0 and distancia.y > -ALTO_ARRIBA - 14.0 and distancia.y < -ALTO_ARRIBA + 18.0:
		felipe.velocity.y = REBOTE
		_apagar()
		return
	if _reloj >= TIEMPO_LLENA[apagados]:
		# Nadie la apagó: vacía el depósito y sigue.
		deposito = 0
		llena = false
		aspi.quieta = false
		aspi.cerrar_tapa()
		presentacion.cartel("¡LO VACIÓ!", 1.2, PISTAS[apagados])


## ¡CLIC!: congelado, destello, sacudida, polvo y sonido en capas.
func _apagar() -> void:
	apagados += 1
	aspi.cerrar_tapa()
	sala.travesuras.jugo.congelar(0.1)
	presentacion.destello(0.7)
	presentacion.sacudir(0.2)
	sala.travesuras.jugo.palabra_en_mundo("¡CLIC!", aspi.global_position + Vector2(0, -70), Color(1.0, 0.95, 0.5), 22)
	_tiempo_clic = Time.get_ticks_msec() / 1000.0
	_polvo.global_position = aspi.global_position + Vector2(0, -20)
	_polvo.restart()
	_polvo.emitting = true
	sala.sonar("golpe")
	sala.sonar("caja")
	manchas.clear()
	tipos_mancha.clear()
	limpiando = false
	if apagados >= APAGADOS_TOTALES:
		aspi.apagada = true
		aspi.apagado.emit()
		return
	_cambiar_fase()


## Mientras limpia aspira: de pie, Felipe se desliza hacia ella; agachado se aferra.
func _aspirar() -> void:
	var distancia := aspi.global_position.x - felipe.global_position.x
	var radio: float = RADIO_SUCCION[mini(apagados, 2)]
	if absf(distancia) < radio and absf(distancia) > 6.0 and absf(felipe.global_position.y - aspi.global_position.y) < 40.0:
		felipe.empuje = Vector2(signf(distancia) * FUERZA_SUCCION, 0.0)


## Maullar: gira hacia Felipe ("¿Gato detectado?") y se le puede llevar a una mancha o debajo de un salto.
func _al_oir_maullido(_felipe_que_maulla: Felipe) -> void:
	if fase != Fase.PELEA or llena or ataque != Ataque.NINGUNO or ausente:
		return
	sala.travesuras.jugo.palabra_en_mundo("¿Gato detectado?", aspi.global_position + Vector2(0, -64), Color(1.0, 0.6, 0.6), 11)
	aspi.destino = felipe.global_position.x


## Bola de pelo en arco hacia donde está Felipe (llega a la repisa y al escritorio).
func _escupir_bola() -> void:
	var bola := Node2D.new()
	bola.name = "Bola de pelo"
	Capas.usar(bola, Capas.EFECTOS)
	var desde := aspi.global_position + Vector2(0, -30)
	var hasta := felipe.global_position + Vector2(0, -20)
	var velocidad := Vector2((hasta.x - desde.x) / VUELO_BOLA, (hasta.y - desde.y) / VUELO_BOLA - 0.5 * GRAVEDAD_BOLA * VUELO_BOLA)
	bola.set_meta("velocidad", velocidad)
	bola.global_position = desde
	bola.draw.connect(_dibujar_bola.bind(bola))
	add_child(bola)
	bolas.append(bola)
	sala.sonar("caja")


func _mover_bolas(delta: float) -> void:
	for bola: Node2D in bolas.duplicate():
		var velocidad: Vector2 = bola.get_meta("velocidad")
		velocidad.y += GRAVEDAD_BOLA * delta
		bola.set_meta("velocidad", velocidad)
		bola.global_position += velocidad * delta
		bola.rotation += velocidad.x * delta * 0.05
		bola.queue_redraw()
		var distancia := (felipe.global_position + Vector2(0, -24)) - bola.global_position
		if distancia.length() < 22.0:
			felipe.recibir_dano(1, bola.global_position.x)
			_quitar_bola(bola)
		elif bola.global_position.y > Sala.SUELO - 6.0 or not arena.grow(20).has_point(bola.global_position) or fase == Fase.FIN:
			_quitar_bola(bola)


func _quitar_bola(bola: Node2D) -> void:
	bolas.erase(bola)
	bola.queue_free()


## Al tercer apagado se apaga del todo: cámara lenta, «¡APAGADA!», todo vuelve de golpe a la normalidad y Felipe se
## lame la pata. La puerta del balcón se abre (camino de la Agenda).
func _terminar() -> void:
	presentacion.saltar()
	fase = Fase.FIN
	_terminar_ataque()
	succionando = false
	limpiando = false
	llena = false
	manchas.clear()
	tipos_mancha.clear()
	aspi.destino = INF
	aspi.inofensiva = true
	aspi.quieta = true
	felipe.empuje = Vector2.ZERO
	var puerta: Puerta = sala.puertas.get("estudio<pasillo")
	if puerta:
		puerta.cerrada = false
		puerta.ofrecer_cerrada = true
		puerta.queue_redraw()
	Engine.time_scale = 0.3
	presentacion.destello(1.0)
	presentacion.cartel("¡APAGADA!", 1.6)
	sala.sonar("puf")
	await get_tree().create_timer(0.5 * 0.3, true, false, false).timeout
	Engine.time_scale = 1.0
	sala.travesuras.cumplir("desenchufar")
	await get_tree().create_timer(0.6, false).timeout
	# Se lame la pata como si nada, apenas toca el piso.
	for i in 180:
		if felipe.is_on_floor() and felipe.estado == Felipe.Estado.SUELO:
			break
		await get_tree().physics_frame
	felipe.acicalarse()
	terminada.emit()


func _dibujar_bola(bola: Node2D) -> void:
	# Escala de gato: bolas de pelo grandes y legibles (el dibujo gira con el nodo).
	var arte := ArteNivel.textura("bola_pelo")
	bola.draw_texture(arte, -arte.get_size() / 2.0)


## La imaginación de Felipe en la entrada: el estudio en llamas y la bestia gigante, POR ENCIMA de todo el escenario
## (capa Capas.IMAGINACION; B1). El estudio real se desvanece con `transformacion` y vuelve al final del rugido.
## La gigante nace de la A.S.P.I. real (mismo lugar y ancho) y al final se encoge hasta ella.
func _dibujar_imaginacion() -> void:
	var c := _imaginacion
	var tiempo := Time.get_ticks_msec() / 1000.0
	if transformacion > 0.0:
		var a := transformacion
		c.draw_texture_rect(ArteNivel.textura("fin_del_mundo"), arena, false, Color(1, 1, 1, a))
		if _rayo > 0.0:
			c.draw_rect(arena, Color(1, 0.9, 0.9, 0.18 * _rayo * a))
	if gigante > 0.0:
		var arte := ArteNivel.textura("aspi_gigante")
		var tam := arte.get_size()
		var k := ease(gigante, 0.6)
		var escala := lerpf(Aspi.ANCHO / tam.x, 1.0, k)
		# Desde (y hacia) donde está la A.S.P.I. real ahora: los empujones la movieron.
		var origen := aspi.global_position + Vector2(0, -tam.y * escala / 2.0)
		var centro := origen.lerp(_centro_gigante + Vector2(0, sin(tiempo * 2.0) * 5.0), k)
		if fase == Fase.ENTRADA and gigante < 1.0 and not _desvaneciendo:
			# Temblor de sueño mientras crece.
			centro += Vector2(sin(tiempo * 40.0), cos(tiempo * 33.0)) * 2.0
		var mira := 1.0 if felipe.global_position.x >= centro.x else -1.0
		c.draw_set_transform(centro, sin(tiempo * 1.3) * 0.03 * k, Vector2(escala * mira, escala))
		c.draw_texture(arte, -tam / 2.0)
		c.draw_set_transform(Vector2.ZERO)


## Las manchas en el piso (tierra de maceta, agua, papel) que A.S.P.I. va a limpiar, y la pelusa que tiembla en la espera.
func _dibujar_manchas() -> void:
	var c := _manchas_dibujo
	for i in manchas.size():
		if tipos_mancha[i] == "papel":
			ArteNivel.dibujar(c, "papel", manchas[i], Sala.SUELO + 1.0)
		else:
			ArteNivel.dibujar(c, "mancha", manchas[i], Sala.SUELO + 2.0)
	if fase == Fase.ENTRADA and presentacion.paso_actual in ["espera", "revelar", "nombre", "barra", "musica", "tamano"]:
		var t := Time.get_ticks_msec() / 1000.0
		for i in 12:
			var x := arena.position.x + 60.0 + i * 46.0
			c.draw_circle(Vector2(x + sin(t * 30.0 + i) * 1.5, Sala.SUELO - 3), 3.0, Color(0.88, 0.85, 0.8, 0.9))


## Delante de todo: el viento de la succión, el cepillo que gira, papeles que vuelan y el aviso del depósito lleno.
func _dibujar_encima() -> void:
	var c := _encima
	var tiempo := Time.get_ticks_msec() / 1000.0
	for p in _papeles:
		var x := p.x + p.y * 160.0
		var y := Sala.SUELO - 40.0 - sin(p.y * 3.0 + p.z * 6.0) * 60.0 - p.y * 40.0
		c.draw_set_transform(Vector2(x, y), p.y * 6.0 + p.z)
		ArteNivel.dibujar(c, "papel_arrugado", 0.0, 10.0)
		c.draw_set_transform(Vector2.ZERO)
	if _reinicio > 0.0 and fase == Fase.PELEA:
		# Barra de reinicio sobre la carcasa (no es un rótulo: no pisa al «¡CLIC!»); el texto sale cuando el «¡CLIC!» ya se fue.
		var barra := Rect2(aspi.global_position + Vector2(-18, -ALTO_ARRIBA - 12), Vector2(36, 4))
		c.draw_rect(barra.grow(1), Color(0.05, 0.1, 0.15, 0.9))
		c.draw_rect(Rect2(barra.position, Vector2(barra.size.x * (1.0 - _reinicio / REINICIO), barra.size.y)), Color("9fd8ff"))
		if tiempo - _tiempo_clic > DURA_CLIC:
			var punto := aspi.global_position + Vector2(-34, -ALTO_ARRIBA - 22)
			c.draw_string_outline(ThemeDB.fallback_font, punto, "REINICIANDO" + ".".repeat(int(tiempo * 3.0) % 4), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 4, Color(0.05, 0.1, 0.15))
			c.draw_string(ThemeDB.fallback_font, punto, "REINICIANDO" + ".".repeat(int(tiempo * 3.0) % 4), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("9fd8ff"))
	if _aviso_succion > 0.0 and not limpiando:
		# Anticipación de la succión: el cepillo gira y se ven líneas de aire.
		for i in 6:
			var angulo := tiempo * 18.0 + i * TAU / 6.0
			var centro := aspi.global_position + Vector2(0, -6)
			c.draw_line(centro, centro + Vector2(cos(angulo), sin(angulo) * 0.4) * 14.0, Color(0.9, 0.95, 1.0, 0.8), 1.0)
	if llena:
		# Por encima de la tapa abierta (que sube unos 32 px).
		var arriba := aspi.global_position + Vector2(0, -ALTO_ARRIBA - 52)
		if int(tiempo * 4.0) % 2 == 0:
			c.draw_circle(aspi.global_position + Vector2(0, -ALTO_ARRIBA - 4), 5.0, Color("e0483b"))
		var fuente := ThemeDB.fallback_font
		var texto := "¡LLENO!"
		var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		c.draw_rect(Rect2(arriba.x - ancho / 2.0 - 6, arriba.y - 13, ancho + 12, 18), Color(0.1, 0.05, 0.07, 0.85))
		c.draw_string(fuente, Vector2(arriba.x - ancho / 2.0, arriba.y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("ffe066"))
		# Flecha hacia abajo: hay que caerle encima.
		c.draw_colored_polygon(PackedVector2Array([arriba + Vector2(-6, 8), arriba + Vector2(6, 8), arriba + Vector2(0, 16)]), Color("ffe066"))
	if ataque == Ataque.SOPLIDO or ataque == Ataque.AVISO_SOPLIDO:
		for i in 8:
			var avance := fmod(tiempo * 2.0 + i * 0.13, 1.0)
			var x := aspi.global_position.x - 20.0 + i * 5.0
			c.draw_line(Vector2(x, aspi.global_position.y - 40.0 - avance * 120.0), Vector2(x, aspi.global_position.y - 52.0 - avance * 120.0), Color(1, 1, 0.8, 0.6 * (1.0 - avance)), 1.5)
	if not succionando:
		return
	var x_jefa := aspi.global_position.x
	var radio: float = RADIO_SUCCION[mini(apagados, 2)]
	for i in 16:
		var lado := -1.0 if i % 2 == 0 else 1.0
		var avance := fmod(tiempo * 1.4 + i * 0.37, 1.0)
		var x := x_jefa + lado * (1.0 - avance) * radio
		var y := Sala.SUELO - 6.0 - fmod(i * 23.0, 70.0)
		if arena.has_point(Vector2(x, y)):
			c.draw_line(Vector2(x, y), Vector2(x + lado * 18.0, y), Color(Color("dff3ff"), 0.7 * avance), 1.5)
