class_name BatallaAspi
extends PeleaJefe
## Pelea con A.S.P.I. en el estudio de Valeria ("La Bestia del Estudio", depósito lleno). Es el examen del nivel (R12):
## tirar (ensuciar), agacharse (aferrarse a la succión), muebles como escalera (silla → escritorio → repisa) y saltar
## (caerle encima, esquivar bolas). Lo común a todo jefe (esperar en la arena, la entrada de 8 pasos de
## PresentacionJefe, fases, ataques en orden, salir y volver) está en PeleaJefe; sus números y sus ataques, en
## datos/jefes/aspi.tres. Aquí queda lo único de A.S.P.I.:
## - Su momento en la entrada: en la imaginación de Felipe crece hasta ser una bestia gigante en un estudio en llamas.
## - El depósito: todo lo que se rompe en el piso deja una mancha; ella la limpia (ConductaLimpiar) y se le llena el
##   depósito (3 LED en su lomo). Lleno, se detiene, inofensiva, y Felipe le salta encima para apretarle el botón: el
##   momento estrella (RemateAspi: el motor falla, se hincha, silencio, pausa de impacto, destello, estrellas, onda y
##   temblor). Tres apagados la apagan del todo.
## - Nada vuelve a su lugar (revisión del 2026-10-23, `diseno/revisiones/2026-10-23-pelea-aspi-sin-reposicion.md`): lo
##   que cae queda en el piso como desorden hasta el final. Hay 14 manchas en 11 fuentes (objetos y FuenteDesorden) y
##   la suciedad nunca se pierde: al apagarla escupe una montaña de pelusa (MontanaPelusa, `datos.devuelve`) que Felipe
##   esparce; si nadie la apaga a tiempo, vacía el depósito en el piso; si Felipe pierde una vida, todo se conserva.
## Ataques (conductas, siempre anunciados, en 4 tiempos: preparación, peligro, impacto y recuperación): embestida,
## soplido contra el que acampa (fase 2) y bolas de pelo (fase 3). Rojo = peligro; amarillo = oportunidad (v4).
## Las instrucciones van como íconos sobre Felipe la primera vez que sirven (AyudaAspi), no como subtítulos.
## Si Felipe pierde una vida, reaparece en el cojín y al volver conserva la fase (entrada corta de 1 s).

## Lo que ve quien mira la pelea (las pruebas y el dibujo): qué ataque está haciendo y en qué parte.
enum Ataque { NINGUNO, AVISO_EMBESTIDA, EMBESTIDA, AVISO_SOPLIDO, SOPLIDO, AVISO_BOLA }

## Sus datos (nombre, fases, números y conductas).
const DATOS := "res://datos/jefes/aspi.tres"
## La gigante se desvanece en el rugido.
const DESVANECER := 0.8
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
		var capacidad: int = DatosJefe.por_fase(datos.capacidad, vencidas)
		if presentacion:
			presentacion.escudo = float(deposito) / capacidad
		# Medidor en su lomo: 3 LED que se encienden por mancha, reescalados a la capacidad de la fase (2/3/3).
		if apariencia:
			apariencia.leds = mini(3, int(deposito * 3 / maxi(capacidad, 1)))
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
## La pelusa que devuelve (sobrecarga y montañas), el apagón de la fase 3 y el material para lo que se lee a oscuras.
var pelusa: PelusaAspi
var apagon: ApagonEstudio
var reacciones: ReaccionesAspi
var remate: RemateAspi
var ayuda: AyudaAspi
var sin_sombrear := CanvasItemMaterial.new()
## Por qué está vulnerable: "deposito" (lleno) o "charco" (electrocutada en el apagón).
var motivo := ""
## Nota de «Arte gatuno» al terminar (porcentaje de desorden; -1 = todavía no).
var nota := -1
var montanas: Array[MontanaPelusa]:
	get:
		return pelusa.montanas
## Para el dibujo: rayos de la imaginación, segundos de reinicio, papeles que vuelan, cuándo fue el último «¡CLIC!».
var rayo := 0.0
var desvaneciendo := false
var reinicio := 0.0
var papeles: Array[Vector3] = []
var tiempo_clic := -10.0
var centro_gigante := Vector2.ZERO

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
	# El globito tampoco tapa el aviso de oportunidad («¡LLENA! ¡SALTA!»): la frase espera a después del golpe.
	globo.peligro = func() -> bool: return amenaza() or llena
	presentacion.paso_empezado.connect(_al_paso)
	presentacion.empujon.connect(_al_empujon)
	# La imaginación de Felipe tapa TODO el escenario (muebles, puertas, repisa); solo Felipe va delante (B1).
	_imaginacion = _lienzo("Imaginacion", Capas.IMAGINACION, func() -> void: dibujo.imaginacion(_imaginacion))
	_manchas_dibujo = _lienzo("Manchas", Capas.MUEBLES, func() -> void: dibujo.manchas(_manchas_dibujo))
	_encima = _lienzo("Viento y depósito", Capas.EFECTOS, func() -> void: dibujo.encima(_encima))
	# Avisos, chispas y bolas se leen también en el apagón (sin sombrear).
	sin_sombrear.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	_encima.material = sin_sombrear
	pelusa = PelusaAspi.new(self)
	add_child(pelusa)
	apagon = ApagonEstudio.new(nivel, jefe, felipe)
	apagon.charcos = func() -> Array[Vector2]:
		var corto := conducta("cortocircuito") as ConductaCortocircuito
		return corto.charcos() if corto else ([] as Array[Vector2])
	add_child(apagon)
	# El pergamino de un logro no aparece en el apagón: espera a que vuelva la luz (v4, Gemini).
	nivel.retener_logros = func() -> bool: return is_instance_valid(apagon) and apagon.activo and fase == Fase.PELEA
	reacciones = ReaccionesAspi.new(self)
	add_child(reacciones)
	remate = RemateAspi.new(self)
	add_child(remate)
	ayuda = AyudaAspi.new(self)
	add_child(ayuda)
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
	return total + pelusa.pendientes()


## Vacía el depósito en el piso: se sobrecarga y escupe una montaña de pelusa con `motas` manchas (PelusaAspi).
func escupir_pelusa(motas: int) -> void:
	pelusa.escupir(motas)


## Chispas eléctricas (amarillas y celestes), que se ven también en el apagón.
func chispas(donde: Vector2, cantidad := 16) -> void:
	for color: Color in [Color(1.0, 0.92, 0.4), Color(0.6, 0.9, 1.0)]:
		var chispa := Particulas.polvo(cantidad, 0.45, Vector2(0, 260), Vector2(80, 200), Vector2(1, 2), color, 160.0)
		chispa.material = sin_sombrear
		Capas.usar(chispa, Capas.EFECTOS)
		chispa.global_position = donde
		add_child(chispa)
		chispa.restart()
		chispa.emitting = true
		chispa.finished.connect(chispa.queue_free)


## Sonido de un momento de la pelea (DatosJefe.sonidos: el motor, la reversa, el atragantamiento, el cortocircuito...).
## Si el sonido final no está todavía, suena el provisional que diga el dato (o nada).
func sonar_evento(evento: String, tono := 1.0) -> void:
	var nombre: String = datos.sonidos.get(evento, "")
	if nombre != "":
		nivel.sonar(nombre, tono)


## Para la cámara (CamaraPelea): avisa una embestida, tose una bola o corre contra el enchufe.
func amenaza() -> bool:
	var corto := conducta("cortocircuito") as ConductaCortocircuito
	return ataque in [Ataque.AVISO_EMBESTIDA, Ataque.EMBESTIDA, Ataque.AVISO_BOLA] or not bolas.is_empty() or (corto != null and corto.corriendo)


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
		soltar_polvo(jefe.global_position + Vector2(0, -20))
		presentacion.destello(0.45)
	jefe.visible = gigante <= 0.0
	if habia_gigante and jefe.visible and fase != Fase.ESPERANDO:
		soltar_polvo(jefe.global_position + Vector2(0, -20))
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


func soltar_polvo(donde: Vector2) -> void:
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
			soltar_polvo(puerta.global_position if puerta else felipe.global_position)
			# La frase la muestra la presentación como subtítulo (el diálogo se esconde durante la entrada, M4).
		"espera":
			apariencia.luz_aviso = Estilo.color(&"peligro")
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
	apariencia.inflado = 0.0
	jefe.patrulla.quieta = true
	jefe.dano.activo = false
	jefe.global_position = Nivel1.ASPI[0]
	(conducta("bola") as AtaqueBolaPelo).quitar_todas()


func _al_cambiar_fase() -> void:
	# Fase 3 (dos apagadas): el ojo queda enojado.
	apariencia.furia = vencidas >= 2
	deposito = 0
	apariencia.inflado = 0.0
	llena = false
	terminar_ataque()
	reinicio = datos.reinicio if vencidas > 0 else 0.0
	jefe.patrulla.quieta = reinicio > 0.0
	jefe.dano.activo = false
	if reinicio <= 0.0:
		# Al entrar: se despierta (pitido, luz roja, «!» y pausa) antes de moverse.
		reacciones.despertar()
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
			# Vuelve de la fase: se despierta (pitido, luz roja, «!» y pausa) antes de moverse.
			reacciones.despertar()
		return
	if reacciones.despertando > 0.0:
		return
	if llena:
		remate.actualizar(delta)
		return
	if reacciones.mareada > 0.0:
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
	# El motor sube de tono con cada mancha (gancho de sonido).
	sonar_evento("motor", 1.0 + deposito * datos.tono_por_mancha)
	if deposito >= DatosJefe.por_fase(datos.capacidad, vencidas):
		_llenar()
	else:
		nivel.travesuras.jugo.palabra_en_mundo("PALABRA_1_GLUP", jefe.global_position + Vector2(0, -60), Color(0.5, 0.85, 1.0), 14)


## Depósito lleno: queda vulnerable (RemateAspi: la anticipación y el golpe).
func _llenar() -> void:
	quedar_vulnerable("deposito")


## Queda quieta, inofensiva y vulnerable: con el depósito lleno o electrocutada por un charco (RemateAspi).
func quedar_vulnerable(por: String) -> void:
	remate.quedar_vulnerable(por)


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
	# Celebra jugando (alegre y juguetón): la animación de jugar con el estambre.
	felipe.acicalarse("jugar")
	terminada.emit()
	# Mira su obra: el estudio destruido, con orgullo (después de su frase de la derrota, sin cortarla).
	# Espera a que se callen las frases de la derrota y de la Agenda (medio segundo seguido sin cuadro de diálogo).
	var libre := 0
	for i in 720:
		libre = 0 if nivel.travesuras.dialogo.ocupado() else libre + 1
		if libre >= 30 and i > 60:
			break
		await get_tree().physics_frame
	# Mira su obra con orgullo según la nota de «Arte gatuno» (opcional: se ve, no obliga).
	var por_ciento := NotaArteGatuno.porcentaje(self)
	if Nivel1.habitacion_de(felipe.global_position) == "estudio":
		nivel.travesuras.decir_felipe(NotaArteGatuno.frase(por_ciento), true)
	nota = NotaArteGatuno.mostrar(self)
