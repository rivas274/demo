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
## - Nada vuelve a su lugar (revisión del 2026-10-23, `diseno/revisiones/2026-10-23-pelea-aspi-sin-reposicion.md`): lo
##   que cae queda en el piso como desorden hasta el final. Hay 14 manchas en 11 fuentes (objetos y FuenteDesorden) y
##   la suciedad nunca se pierde: al apagarla escupe una montaña de pelusa (MontanaPelusa, `datos.devuelve`) que Felipe
##   esparce; si nadie la apaga a tiempo, vacía el depósito en el piso; si Felipe pierde una vida, todo se conserva.
## Ataques (conductas, siempre anunciados): embestida, soplido contra el que acampa (fase 2) y bolas de pelo (fase 3).
## Si Felipe pierde una vida, reaparece en el cojín y al volver conserva la fase (entrada corta de 1 s).

## Lo que ve quien mira la pelea (las pruebas y el dibujo): qué ataque está haciendo y en qué parte.
enum Ataque { NINGUNO, AVISO_EMBESTIDA, EMBESTIDA, AVISO_SOPLIDO, SOPLIDO, AVISO_BOLA }

## Sus datos (nombre, fases, números y conductas).
const DATOS := "res://datos/jefes/aspi.tres"
## La gigante se desvanece en el rugido.
const DESVANECER := 0.8
## Segundos después del «¡CLIC!» en que escupe la montaña (cuando ya se fue la palabra: una a la vez).
const ESPERA_ESCUPIR := 1.0
## La montaña cae a este lado de A.S.P.I. (hacia el piso libre).
const DISTANCIA_MONTANA := 58.0
## Al apagarla, Felipe rebota hacia arriba.
const REBOTE := -420.0
## Lleno bajo la repisa: sale disparada hacia adelante (nunca queda justo bajo la repisa).
const EMPUJE_LLENA := 80.0
## Margen a cada lado de los muebles bajo los que no se queda llena (medio cuerpo de A.S.P.I. y un poco).
const MARGEN_LLENA := 44.0
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
## x de cada mancha en el piso, qué es ("mancha", "papel", "pelusa" o "nodo": la pieza misma, como la nota o la mota)
## y su nodo (la pieza que se lleva al limpiarla; null si solo es dibujo).
var manchas: Array[float] = []
var tipos_mancha: Array[String] = []
var nodos_mancha: Array[Node2D] = []
var succionando := false
## 0 = estudio normal, 1 = fin del mundo (solo en la entrada).
var transformacion := 0.0
## 0 = A.S.P.I. de tamaño real, 1 = bestia gigante del fondo (solo en la entrada).
var gigante := 0.0
## Lo que se puede tirar en el estudio (queda donde cae), lo que suelta cosas de a una y las montañas de pelusa.
var municion: Array[Objeto] = []
var fuentes: Array[FuenteDesorden] = []
var montanas: Array[MontanaPelusa] = []
## Para el dibujo: rayos de la imaginación, segundos de reinicio, papeles que vuelan, cuándo fue el último «¡CLIC!».
var rayo := 0.0
var desvaneciendo := false
var reinicio := 0.0
var papeles: Array[Vector3] = []
var tiempo_clic := -10.0
var centro_gigante := Vector2.ZERO

var _reloj_llena := 0.0
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


## Lo que se puede tirar en el estudio: cuando cae, queda en el piso y deja una mancha.
func agregar_municion(objeto: Objeto) -> void:
	municion.append(objeto)
	objeto.tirable.caido.connect(func(posicion: Vector2) -> void: agregar_mancha(posicion))


## Lo que suelta cosas de a una (las notas del corcho, los libros del estante, los apuntes del teclado).
func agregar_fuente(fuente: FuenteDesorden) -> void:
	fuentes.append(fuente)
	fuente.soltada.connect(func(pieza: PiezaSuelta, mancha: String) -> void:
		if mancha == "":
			agregar_mancha(pieza.global_position, "nodo", pieza)
		else:
			agregar_mancha(pieza.global_position + Vector2(18.0, 0.0), mancha))


## Algo cayó al piso: si es en el estudio y hay pelea, queda una mancha para limpiar. Con `nodo`, la mancha es esa
## pieza (la nota, la mota de pelusa): al limpiarla, A.S.P.I. se la lleva.
func agregar_mancha(posicion: Vector2, tipo := "mancha", nodo: Node2D = null) -> void:
	if fase in [Fase.ESPERANDO, Fase.FIN] or not arena.grow(4).has_point(posicion - Vector2(0, 1)):
		return
	manchas.append(clampf(posicion.x, jefe.patrulla.limite_izquierdo, jefe.patrulla.limite_derecho))
	tipos_mancha.append(tipo)
	nodos_mancha.append(nodo)
	if tipo == "papel":
		papeles.append(Vector3(posicion.x, 0.0, 0.0))


## A.S.P.I. limpió la mancha `i`: si era una pieza, se la traga (se achica hacia ella y desaparece).
func quitar_mancha(i: int) -> void:
	var nodo: Node2D = nodos_mancha[i]
	manchas.remove_at(i)
	tipos_mancha.remove_at(i)
	nodos_mancha.remove_at(i)
	if is_instance_valid(nodo):
		var tragar := nodo.create_tween().set_parallel()
		tragar.tween_property(nodo, "global_position", jefe.global_position + Vector2(0, -6), 0.25)
		tragar.tween_property(nodo, "scale", Vector2(0.2, 0.2), 0.25)
		tragar.chain().tween_callback(nodo.queue_free)


## Toda la suciedad que todavía existe: lo que falta por caer (objetos y fuentes), lo que está en el piso, lo que tiene
## en el depósito y lo que guardan las montañas. Solo baja al apagarla (devuelve menos de lo que tragó): nunca falta.
func suciedad_total() -> int:
	var total := manchas.size() + deposito
	for objeto in municion:
		if is_instance_valid(objeto) and not objeto.tirable.roto:
			total += 1
	for fuente in fuentes:
		if is_instance_valid(fuente):
			total += fuente.restantes() + fuente.en_vuelo
	for montana in montanas:
		if is_instance_valid(montana):
			total += montana.pendientes()
	return total


## Vacía el depósito en el piso: se le abre la tapa y escupe una montaña de pelusa con `motas` manchas («¡BLORP!» y
## nube). La montaña cae hacia el lado con más piso libre.
func escupir_pelusa(motas: int) -> MontanaPelusa:
	if motas <= 0:
		return null
	var montana := MontanaPelusa.crear(motas, nivel.datos.suelo)
	montanas.append(montana)
	montana.mota_en_piso.connect(func(mota: PiezaSuelta) -> void: agregar_mancha(mota.global_position, "nodo", mota))
	montana.tree_exiting.connect(func() -> void: montanas.erase(montana))
	nivel.add_child(montana)
	var x := jefe.global_position.x
	var hacia := 1.0 if x < arena.get_center().x else -1.0
	var destino := clampf(x + hacia * DISTANCIA_MONTANA, jefe.patrulla.limite_izquierdo, jefe.patrulla.limite_derecho)
	montana.escupir(jefe.global_position + Vector2(0, -ALTO_ARRIBA), destino)
	apariencia.abrir_tapa()
	var tapa := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tapa.tween_interval(0.6)
	tapa.tween_callback(func() -> void:
		if not llena:
			apariencia.cerrar_tapa())
	_soltar_polvo(jefe.global_position + Vector2(0, -24))
	nivel.travesuras.jugo.palabra_en_mundo("PALABRA_BLORP", jefe.global_position + Vector2(0, -66), Color(0.86, 0.84, 0.8), 18)
	nivel.travesuras.jugo.sacudir(0.12, 0.5)
	nivel.sonar("succion")
	# Felipe lo comenta (la primera vez con su frase de siempre).
	if nivel.ya_dijo("devolucion"):
		nivel.travesuras.decir_felipe("devolucion_otra")
	else:
		nivel.decir("devolucion")
	return montana


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


## Felipe perdió una vida: todo lo del piso, las montañas y el depósito se conservan (nada se pierde). Si estaba llena,
## lo vacía en el piso antes de volver a su base.
func _al_salir_felipe() -> void:
	limpiar.limpiando = false
	if llena:
		llena = false
		escupir_pelusa(deposito)
		deposito = 0
	apariencia.cerrar_tapa()
	jefe.patrulla.quieta = true
	jefe.dano.activo = false
	jefe.global_position = Nivel1.ASPI[0]
	(conducta("bola") as AtaqueBolaPelo).quitar_todas()


func _al_cambiar_fase() -> void:
	# Fase 3 (dos apagadas): el ojo queda enojado.
	apariencia.furia = vencidas >= 2
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


## Corta el ataque en curso y la deja en reposo: sin luz de aviso, sin vibrar, inofensiva y a su velocidad.
func terminar_ataque() -> void:
	super()
	apariencia.luz_aviso = Color(0, 0, 0, 0)
	apariencia.vibrando = false
	jefe.patrulla.quieta = false
	jefe.dano.activo = false
	jefe.patrulla.destino = INF
	jefe.patrulla.velocidad_persecucion = DatosJefe.por_fase(datos.velocidad, vencidas)


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
	# Nunca queda justo bajo la repisa ni bajo la isla del librero (estudio v3: desde arriba Felipe caería en la caja o
	# en el librero, no en su botón): sale disparada hacia adelante, al piso libre más cercano.
	var x := jefe.global_position.x
	var libre := _piso_libre(x)
	if absf(libre - x) > 0.5:
		var sale := create_tween()
		sale.tween_property(jefe, "position:x", jefe.position.x + (libre - x), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## La x libre más cercana para quedarse llena: fuera de lo que tapa su botón desde arriba (Nivel1.ASPI_NO_SE_LLENA_BAJO,
## con medio cuerpo de margen) y dentro de su patrulla. La repisa conserva su regla de siempre (80 px hacia adelante).
func _piso_libre(x: float) -> float:
	var patrulla := jefe.patrulla
	var zonas: Array[Vector2] = []
	for nombre: String in Nivel1.ASPI_NO_SE_LLENA_BAJO:
		var pieza := Nivel1.rect_pieza(nombre)
		if pieza.has_area():
			zonas.append(Vector2(pieza.position.x - MARGEN_LLENA, pieza.end.x + MARGEN_LLENA))
	var repisa := nivel.pieza("Repisa de las macetas")
	if repisa and absf(x - (repisa.position.x + 30.0)) < 70.0:
		var hacia := 1.0 if x + EMPUJE_LLENA < patrulla.limite_derecho else -1.0
		x = clampf(x + hacia * EMPUJE_LLENA, patrulla.limite_izquierdo, patrulla.limite_derecho)
	# Las zonas se tocan (la caja va delante del librero): se sale por la derecha, hacia la puerta del balcón (piso
	# libre); si no cabe en su patrulla, por la izquierda.
	for zona in zonas:
		if x > zona.x and x < zona.y:
			var desde := zona.x
			var hasta := zona.y
			for otra in zonas:
				if otra.x <= hasta and otra.y >= desde:
					desde = minf(desde, otra.x)
					hasta = maxf(hasta, otra.y)
			x = hasta if hasta <= patrulla.limite_derecho else desde
			break
	return x


func _actualizar_llena(delta: float) -> void:
	_reloj_llena += delta
	# Felipe cae sobre ella: le aprieta el botón de apagado con las patas.
	# El botón está arriba del dibujo, que va `profundidad` px más abajo que los pies (más cerca de la cámara).
	var distancia := felipe.global_position - jefe.global_position - Vector2(0, jefe.datos.profundidad)
	if felipe.velocity.y > 0.0 and absf(distancia.x) < jefe.datos.ancho / 2.0 + 4.0 and distancia.y > -ALTO_ARRIBA - 14.0 and distancia.y < -ALTO_ARRIBA + 18.0:
		felipe.velocity.y = REBOTE
		_apagar()
		return
	if _reloj_llena >= DatosJefe.por_fase(datos.tiempo_vulnerable, vencidas):
		# Nadie la apagó: vacía el depósito EN EL PISO (montaña de pelusa con todo lo que tenía) y sigue.
		var tenia := deposito
		deposito = 0
		llena = false
		jefe.patrulla.quieta = false
		escupir_pelusa(tenia)
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
	# Lo que quedó en el piso sigue ahí (la fase siguiente lo limpia).
	limpiar.limpiando = false
	if vencidas >= datos.fases:
		jefe.vida.morir()
		return
	var motas: int = DatosJefe.por_fase(datos.devuelve, vencidas - 1) if not datos.devuelve.is_empty() else 0
	cambiar_fase()
	# Se le abre el depósito y escupe la pelusa: lo que limpió vuelve al piso (cuando ya se fue el «¡CLIC!»).
	var escupe := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	escupe.tween_interval(ESPERA_ESCUPIR)
	escupe.tween_callback(func() -> void:
		if fase == Fase.PELEA:
			escupir_pelusa(motas))


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
	# El estudio queda como quedó: lo del piso sigue ahí (el trofeo de Felipe).
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
	# Mira su obra: el estudio destruido, con orgullo (después de su frase de la derrota, sin cortarla).
	# Espera a que se callen las frases de la derrota y de la Agenda (medio segundo seguido sin cuadro de diálogo).
	var libre := 0
	for i in 720:
		libre = 0 if nivel.travesuras.dialogo.ocupado() else libre + 1
		if libre >= 30 and i > 60:
			break
		await get_tree().physics_frame
	if Nivel1.habitacion_de(felipe.global_position) == "estudio":
		nivel.travesuras.decir_felipe("estudio_destruido", true)
