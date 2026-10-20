class_name BatallaAspi
extends PeleaJefe
## Pelea con A.S.P.I. en el estudio de Valeria ("La Bestia del Estudio", depósito lleno). Es el examen del nivel (R12):
## tirar (ensuciar), agacharse (aferrarse a la succión), muebles como escalera (silla → escritorio → repisa) y saltar
## (caerle encima, esquivar bolas). Lo común a todo jefe (esperar en la arena, la entrada de 8 pasos de
## PresentacionJefe, fases, ataques en orden, salir y volver) está en PeleaJefe; sus números y sus ataques, en
## datos/jefes/aspi.tres. Aquí queda lo único de A.S.P.I.:
## - Su momento en la entrada: en la imaginación de Felipe crece hasta ser una bestia gigante en un estudio en llamas.
## - El depósito: todo lo que se rompe en el piso deja una mancha; ella la limpia (ConductaLimpiar) y se le llena el
##   depósito. Lleno, se detiene pitando, inofensiva, y Felipe le salta encima para apretarle el botón (congelado,
##   destello, sacudida, «¡CLIC!» y polvo). Tres apagados la apagan del todo.
## - Lo roto vuelve de a uno cada 6 s: hay que bajar por la taza, el vaso o los papeles del teclado (G12).
## Ataques (conductas, siempre anunciados): embestida, soplido contra el que acampa (fase 2) y bolas de pelo (fase 3).
## Si Felipe pierde una vida, reaparece en el cojín y al volver conserva la fase (entrada corta de 1 s).

## Lo que ve quien mira la pelea (las pruebas y el dibujo): qué ataque está haciendo y en qué parte.
enum Ataque { NINGUNO, AVISO_EMBESTIDA, EMBESTIDA, AVISO_SOPLIDO, SOPLIDO, AVISO_BOLA }

## Sus datos (nombre, fases, números y conductas).
const DATOS := "res://datos/jefes/aspi.tres"
## Lo que se rompe vuelve de a uno, cada tanto; la gigante se desvanece en el rugido.
const REPOSICION := 6.0
const DESVANECER := 0.8
## Al apagarla, Felipe rebota hacia arriba.
const REBOTE := -420.0
## Lleno bajo la repisa: sale disparada hacia adelante (nunca queda justo bajo la repisa).
const EMPUJE_LLENA := 80.0
## Alto del dibujo de A.S.P.I.: Felipe la apaga si cae sobre esa franja.
const ALTO_ARRIBA := 40.0
## Mientras se ve el «¡CLIC!» no hay otro rótulo sobre A.S.P.I. (M3).
const DURA_CLIC := 1.3

## El dibujo de A.S.P.I. (luz de aviso, vibración y tapa del depósito) y el de la pelea.
var apariencia: AparienciaAspi
var dibujo: DibujoBatallaAspi
## Lo que tragó: se ve como la franja azul bajo la barra (escudo de la presentación).
var deposito := 0:
	set(valor):
		deposito = valor
		if presentacion:
			presentacion.escudo = float(deposito) / DatosJefe.por_fase(datos.capacidad, vencidas)
var llena := false
## x de cada mancha en el piso (y qué es: "mancha" o "papel").
var manchas: Array[float] = []
var tipos_mancha: Array[String] = []
var succionando := false
## 0 = estudio normal, 1 = fin del mundo (solo en la entrada).
var transformacion := 0.0
## 0 = A.S.P.I. de tamaño real, 1 = bestia gigante del fondo (solo en la entrada).
var gigante := 0.0
## Lo que se puede tirar en el estudio (vuelve de a uno).
var municion: Array[Objeto] = []
## Para el dibujo: rayos de la imaginación, segundos de reinicio, papeles que vuelan, cuándo fue el último «¡CLIC!».
var rayo := 0.0
var desvaneciendo := false
var reinicio := 0.0
var papeles: Array[Vector3] = []
var tiempo_clic := -10.0
var centro_gigante := Vector2.ZERO

var _reloj_llena := 0.0
var _por_reponer: Array[Objeto] = []
var _reloj_reponer := 0.0
var _encima: Node2D
var _imaginacion: Node2D
var _manchas_dibujo: Node2D
var _polvo: CPUParticles2D

## A.S.P.I. (el jefe de esta pelea).
var aspi: Enemigo:
	get:
		return jefe
## Apagados: las fases que Felipe ya le ganó.
var apagados: int:
	get:
		return vencidas
	set(valor):
		vencidas = valor
var limpiar: ConductaLimpiar:
	get:
		return conducta("limpiar") as ConductaLimpiar
var limpiando: bool:
	get:
		return limpiar.limpiando
var bolas: Array[Node2D]:
	get:
		return (conducta("bola") as AtaqueBolaPelo).bolas
var soplidos: int:
	get:
		return (conducta("soplido") as AtaqueSoplido).soplidos
var ataque: Ataque:
	get:
		if activa is AtaqueEmbestida:
			return Ataque.EMBESTIDA if (activa as AtaqueEmbestida).cargando else Ataque.AVISO_EMBESTIDA
		if activa is AtaqueSoplido:
			return Ataque.SOPLIDO if (activa as AtaqueSoplido).soplando else Ataque.AVISO_SOPLIDO
		if activa is AtaqueBolaPelo:
			return Ataque.AVISO_BOLA
		return Ataque.NINGUNO


func _init(jefa: Enemigo, gato: Felipe, de_nivel: Nivel) -> void:
	super(load(DATOS) as DatosJefe, jefa, gato, de_nivel, de_nivel.datos.rect_de("estudio"))
	name = "Batalla"
	apariencia = jefa.apariencia as AparienciaAspi
	dibujo = DibujoBatallaAspi.new(self)
	centro_gigante = Vector2(arena.get_center().x, de_nivel.datos.suelo - 160)


func _ready() -> void:
	jefe.vida.murio.connect(_terminar)
	jefe.oido.oyo.connect(_al_oir_maullido)
	jefe.patrulla.quieta = true
	jefe.vida.invulnerable = true
	super()
	presentacion.encuadre_momento = centro_gigante + Vector2(0, 40)
	presentacion.paso_empezado.connect(_al_paso)
	presentacion.empujon.connect(_al_empujon)
	# La imaginación de Felipe tapa TODO el escenario (muebles, puertas, repisa); solo Felipe va delante (B1).
	_imaginacion = _lienzo("Imaginacion", Capas.IMAGINACION, func() -> void: dibujo.imaginacion(_imaginacion))
	_manchas_dibujo = _lienzo("Manchas", Capas.MUEBLES, func() -> void: dibujo.manchas(_manchas_dibujo))
	_encima = _lienzo("Viento y depósito", Capas.EFECTOS, func() -> void: dibujo.encima(_encima))
	_polvo = Particulas.polvo(24, 0.7, Vector2(0, 220), Vector2(50, 140), Vector2(2, 4), Color(0.86, 0.82, 0.75))
	_polvo.name = "Polvo"
	Capas.usar(_polvo, Capas.EFECTOS)
	add_child(_polvo)


func _lienzo(nombre: String, capa: int, al_dibujar: Callable) -> Node2D:
	var lienzo := Node2D.new()
	lienzo.name = nombre
	Capas.usar(lienzo, capa)
	lienzo.draw.connect(al_dibujar)
	add_child(lienzo)
	return lienzo


## Lo que se puede tirar en el estudio: vuelve de a uno cuando se rompe (o cuando un soplido lo tira).
func agregar_municion(objeto: Objeto) -> void:
	municion.append(objeto)
	objeto.tirable.caido.connect(func(posicion: Vector2) -> void:
		agregar_mancha(posicion)
		_por_reponer.append(objeto))
	objeto.tirable.tirado.connect(func(_o: Node2D) -> void: _por_reponer.append(objeto))


## Algo se rompió en el piso: si es en el estudio y hay pelea, queda una mancha para limpiar.
func agregar_mancha(posicion: Vector2, tipo := "mancha") -> void:
	if fase in [Fase.ESPERANDO, Fase.FIN] or not arena.grow(4).has_point(posicion - Vector2(0, 1)):
		return
	manchas.append(clampf(posicion.x, jefe.patrulla.limite_izquierdo, jefe.patrulla.limite_derecho))
	tipos_mancha.append(tipo)
	if tipo == "papel":
		papeles.append(Vector3(posicion.x, 0.0, 0.0))


func _process(delta: float) -> void:
	rayo = maxf(0.0, rayo - delta * 4.0)
	if fase == Fase.ENTRADA and not desvaneciendo:
		gigante = ease(presentacion.momento, 0.4)
		transformacion = presentacion.momento
		if presentacion.momento > 0.0 and fmod(presentacion.t, 0.9) < delta:
			rayo = 1.0
	# Nunca dos A.S.P.I. a la vez (B1): la real se esconde mientras exista la gigante y vuelve justo cuando la gigante,
	# ya encogida hasta su tamaño y su lugar, desaparece (con un «¡puf!» de polvo).
	var habia_gigante := not jefe.visible
	if not habia_gigante and gigante > 0.0:
		# Nace la bestia: «¡puf!» y destello, para que el cambio de la aspiradora a la gigante no sea un corte seco.
		_soltar_polvo(jefe.global_position + Vector2(0, -20))
		presentacion.destello(0.45)
	jefe.visible = gigante <= 0.0
	if habia_gigante and jefe.visible and fase != Fase.ESPERANDO:
		_soltar_polvo(jefe.global_position + Vector2(0, -20))
	# Felipe queda delante de su propia imaginación; el escenario, detrás.
	# Solo toca la capa de Felipe mientras imagina (y para devolverla): el resto del tiempo la decide el nivel (delante
	# o detrás de Valeria según dónde está parado).
	if gigante > 0.0 or transformacion > 0.0:
		felipe.z_index = Capas.FELIPE_IMAGINANDO
	elif felipe.z_index == Capas.FELIPE_IMAGINANDO:
		felipe.z_index = Capas.JUEGO
	if not papeles.is_empty():
		for i in papeles.size():
			papeles[i].y += delta
		papeles = papeles.filter(func(p: Vector3) -> bool: return p.y < 1.2)
	_imaginacion.queue_redraw()
	_encima.queue_redraw()
	_manchas_dibujo.queue_redraw()


func _soltar_polvo(donde: Vector2) -> void:
	_polvo.global_position = donde
	_polvo.restart()
	_polvo.emitting = true


func _al_empezar() -> void:
	jefe.recibe_golpes.solo_aturdido = true
	jefe.vida.invulnerable = true
	jefe.patrulla.quieta = true
	jefe.dano.activo = false
	felipe.empuje = Vector2.ZERO
	presentacion.frase_sin_vuelta = ["Felipe", Frases.FELIPE["quien_cerro"][0][0]]
	# En la pelea las puertas cerradas del estudio no se ofrecen: "Probar" pisaba a A.S.P.I. llena (M3) y, junto a la
	# puerta de entrada, mantener la acción probaba la puerta en vez de comer un snack del bolsillo.
	for nombre: String in [Nivel1.PUERTA_BALCON, "estudio<pasillo"]:
		var puerta: Puerta = nivel.puertas.get(nombre)
		if puerta:
			puerta.ofrecer_cerrada = false


func _al_paso(paso: String) -> void:
	var puerta: Puerta = nivel.puertas.get("estudio<pasillo")
	match paso:
		"sin_vuelta_atras":
			# Portazo: se cierra de golpe (con el juego congelado la hoja no alcanzaría a girar).
			if puerta:
				puerta.cerrada = true
				puerta.apertura = 0.0
				puerta.queue_redraw()
			nivel.sonar("golpe")
			_soltar_polvo(puerta.global_position if puerta else felipe.global_position)
			# La frase la muestra la presentación como subtítulo (el diálogo se esconde durante la entrada, M4).
		"espera":
			apariencia.luz_aviso = Color("e0483b")
		"musica":
			nivel.sonar("batalla")
		"rugido":
			apariencia.luz_aviso = Color(0, 0, 0, 0)
			desvaneciendo = true
			for i in 10:
				papeles.append(Vector3(arena.position.x + 200 + i * 24.0, 0.0, randf()))
			var vuelta := create_tween().set_parallel()
			vuelta.tween_property(self, "gigante", 0.0, DESVANECER)
			vuelta.tween_property(self, "transformacion", 0.0, DESVANECER)
			nivel.sonar("succion")


## Vender el tamaño: cada empujón la acerca a Felipe y sacude la pantalla.
func _al_empujon(_numero: int) -> void:
	var hacia := signf(felipe.global_position.x - jefe.global_position.x)
	var paso := create_tween()
	paso.tween_property(jefe, "position:x", jefe.position.x + hacia * 14.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	nivel.sonar("golpe")


func _al_empezar_pelea() -> void:
	gigante = 0.0
	transformacion = 0.0


func _al_salir_felipe() -> void:
	manchas.clear()
	tipos_mancha.clear()
	limpiar.limpiando = false
	llena = false
	deposito = 0
	apariencia.cerrar_tapa()
	jefe.patrulla.quieta = true
	jefe.dano.activo = false
	jefe.global_position = Nivel1.ASPI[0]
	(conducta("bola") as AtaqueBolaPelo).quitar_todas()


func _al_cambiar_fase() -> void:
	_reloj_llena = 0.0
	deposito = 0
	llena = false
	terminar_ataque()
	reinicio = datos.reinicio if vencidas > 0 else 0.0
	jefe.patrulla.quieta = reinicio > 0.0
	jefe.dano.activo = false
	var velocidad: float = DatosJefe.por_fase(datos.velocidad, vencidas)
	jefe.patrulla.velocidad_patrulla = velocidad * 0.7
	jefe.patrulla.velocidad_persecucion = velocidad


func _actualizar_pelea(delta: float) -> void:
	if ataque != Ataque.SOPLIDO:
		felipe.empuje = Vector2.ZERO
	succionando = false
	avanzar_relojes(delta)
	if reinicio > 0.0:
		reinicio -= delta
		if reinicio <= 0.0:
			jefe.patrulla.quieta = false
		return
	if llena:
		_actualizar_llena(delta)
		return
	if jefe.recibe_golpes.esta_aturdido():
		terminar_ataque()
		limpiar.limpiando = false
		jefe.patrulla.destino = INF
		return
	vigilar(delta)
	correr_conductas(delta)


func _cada_cuadro(delta: float) -> void:
	(conducta("bola") as AtaqueBolaPelo).mover(delta)
	_reponer(delta)


## Corta el ataque en curso y la deja en reposo: sin luz de aviso, sin vibrar, inofensiva y a su velocidad.
func terminar_ataque() -> void:
	super()
	apariencia.luz_aviso = Color(0, 0, 0, 0)
	apariencia.vibrando = false
	jefe.patrulla.quieta = false
	jefe.dano.activo = false
	jefe.patrulla.destino = INF
	jefe.patrulla.velocidad_persecucion = DatosJefe.por_fase(datos.velocidad, vencidas)


## Lo roto (o tirado) vuelve de a uno, cada REPOSICION segundos, mientras dure la pelea.
func _reponer(delta: float) -> void:
	if _por_reponer.is_empty() or fase == Fase.FIN:
		_reloj_reponer = 0.0
		return
	_reloj_reponer += delta
	if _reloj_reponer >= REPOSICION:
		_reloj_reponer = 0.0
		var objeto: Objeto = _por_reponer.pop_front()
		if is_instance_valid(objeto):
			objeto.tirable.reponer()


## Limpió una mancha: el depósito sube; lleno, queda vulnerable. Un solo rótulo a la vez sobre ella (M3): si con esto
## se llena, solo «¡LLENO!».
func llenar_deposito() -> void:
	deposito += 1
	if deposito >= DatosJefe.por_fase(datos.capacidad, vencidas):
		_llenar()
	else:
		nivel.travesuras.jugo.palabra_en_mundo("PALABRA_1_GLUP", jefe.global_position + Vector2(0, -60), Color(0.5, 0.85, 1.0), 14)


## Depósito lleno: se detiene pitando, inofensiva, y espera a que se lo vacíen... o a que Felipe la apague.
func _llenar() -> void:
	llena = true
	_reloj_llena = 0.0
	terminar_ataque()
	jefe.patrulla.destino = INF
	jefe.patrulla.quieta = true
	jefe.dano.activo = false
	apariencia.abrir_tapa()
	nivel.sonar("logro")
	presentacion.cartel("JEFE_DEPOSITO_LLENO", 1.6, datos.pista_vulnerable)
	# Nunca queda justo bajo la repisa: sale disparada unos 80 px hacia adelante.
	var repisa := nivel.pieza("Repisa de las macetas")
	var patrulla := jefe.patrulla
	if repisa and absf(jefe.global_position.x - (repisa.position.x + 30.0)) < 70.0:
		var hacia := 1.0 if jefe.global_position.x + EMPUJE_LLENA < patrulla.limite_derecho else -1.0
		var sale := create_tween()
		sale.tween_property(jefe, "position:x", clampf(jefe.position.x + hacia * EMPUJE_LLENA, patrulla.limite_izquierdo, patrulla.limite_derecho), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _actualizar_llena(delta: float) -> void:
	_reloj_llena += delta
	# Felipe cae sobre ella: le aprieta el botón de apagado con las patas.
	var distancia := felipe.global_position - jefe.global_position
	if felipe.velocity.y > 0.0 and absf(distancia.x) < jefe.datos.ancho / 2.0 + 4.0 and distancia.y > -ALTO_ARRIBA - 14.0 and distancia.y < -ALTO_ARRIBA + 18.0:
		felipe.velocity.y = REBOTE
		_apagar()
		return
	if _reloj_llena >= DatosJefe.por_fase(datos.tiempo_vulnerable, vencidas):
		# Nadie la apagó: vacía el depósito y sigue.
		deposito = 0
		llena = false
		jefe.patrulla.quieta = false
		apariencia.cerrar_tapa()
		presentacion.cartel("JEFE_LO_VACIO", 1.2, DatosJefe.por_fase(datos.pistas, vencidas))


## ¡CLIC!: congelado, destello, sacudida, polvo y sonido en capas.
func _apagar() -> void:
	vencidas += 1
	apariencia.cerrar_tapa()
	nivel.travesuras.jugo.congelar(0.1)
	presentacion.destello(0.7)
	presentacion.sacudir(0.2)
	nivel.travesuras.jugo.palabra_en_mundo("PALABRA_CLIC", jefe.global_position + Vector2(0, -70), Color(1.0, 0.95, 0.5), 22)
	tiempo_clic = Time.get_ticks_msec() / 1000.0
	_soltar_polvo(jefe.global_position + Vector2(0, -20))
	nivel.sonar("golpe")
	nivel.sonar("caja")
	manchas.clear()
	tipos_mancha.clear()
	limpiar.limpiando = false
	if vencidas >= datos.fases:
		jefe.vida.morir()
		return
	cambiar_fase()


## Maullar: gira hacia Felipe ("¿Gato detectado?") y se le puede llevar a una mancha o debajo de un salto.
func _al_oir_maullido(_felipe_que_maulla: Felipe) -> void:
	if fase != Fase.PELEA or llena or activa != null or ausente:
		return
	nivel.travesuras.jugo.palabra_en_mundo("PALABRA_GATO_DETECTADO", jefe.global_position + Vector2(0, -64), Color(1.0, 0.6, 0.6), 11)
	jefe.patrulla.destino = felipe.global_position.x


## Al tercer apagado se apaga del todo: su derrota (destello, rebote, pelusa, cámara lenta), «¡APAGADA!», todo vuelve a la normalidad y Felipe se lame
## la pata. La puerta del balcón se abre (camino de la Agenda).
func _terminar() -> void:
	presentacion.saltar()
	fase = Fase.FIN
	terminar_ataque()
	succionando = false
	limpiar.limpiando = false
	llena = false
	manchas.clear()
	tipos_mancha.clear()
	jefe.patrulla.destino = INF
	jefe.dano.activo = false
	jefe.patrulla.quieta = true
	felipe.empuje = Vector2.ZERO
	var puerta: Puerta = nivel.puertas.get("estudio<pasillo")
	if puerta:
		puerta.cerrada = false
		puerta.ofrecer_cerrada = true
		puerta.queue_redraw()
	# La cámara lenta, el destello por silueta, el rebote contra la pared y la montaña de pelusa son de su derrota
	# (ReaccionDerrota con datos/derrotas/aspi.tres); aquí, el cartel tipo Broforce y el sonido.
	presentacion.destello(1.0)
	presentacion.cartel("JEFE_APAGADA", 1.6)
	nivel.sonar("puf")
	await get_tree().create_timer(0.5, true, false, true).timeout
	nivel.travesuras.cumplir("desenchufar")
	await get_tree().create_timer(0.6, false).timeout
	# Se lame la pata como si nada, apenas toca el piso.
	for i in 180:
		if felipe.is_on_floor() and felipe.estado == Felipe.Estado.SUELO:
			break
		await get_tree().physics_frame
	felipe.acicalarse()
	terminada.emit()
