class_name Nivel
extends Node2D
## Constructor genérico de niveles: arma cualquier nivel desde sus datos (DatosNivel) y le deja lo propio a su guion
## (GuionNivel, nodo hijo «Guion»). Lo que hace por todos los niveles:
## - Piezas sólidas (cada una calza con el borde visible de su arte) y paredes invisibles entre cuartos.
## - Puertas de a pares (sus dos caras se abren y cierran juntas) y el cruce con fundido a negro; la escalera de fondo
##   se sube y se baja escalón por escalón.
## - La cámara queda dentro del cuarto donde está Felipe (nunca muestra otro cuarto).
## - Los sistemas de siempre: pantallas (título, pausa), medidores, Travesuras (agenda, HUD, diálogo, jugo, indicador),
##   sonidos y logros.
## - Al empezar muestra la meta (R4); primeras frases de Felipe por zona (en vez de carteles) y puntos de descanso.
## Avisa con señales (habitacion_cambiada, puerta_cerrada_probada, escalera_bajada...) y el guion las escucha.
## Arquitectura y receta para el nivel 2: siete-vidas/memoria/07-arquitectura.md.

## Piso con profundidad (pedido del creador, 2026-10-19): la pared termina FONDO_PISO px arriba de la línea de apoyo;
## en esa banda se ve el piso detrás de los pies (Gemini, pasada única: de 12 a 16 px).
const FONDO_PISO := 14.0

signal logro_desbloqueado(titulo: String)
signal habitacion_cambiada(nombre: String)
## Terminó el fundido de una puerta (la pantalla ya se ve).
signal fundido_terminado
## Felipe quiso pasar por una puerta cerrada.
signal puerta_cerrada_probada(puerta: Puerta)
## Felipe terminó de bajar la escalera de fondo.
signal escalera_bajada

## Muestra la pantalla de título al empezar (las pruebas la apagan).
@export var mostrar_titulo := true

var datos: DatosNivel
var logros: Array[String] = []
var tiempo := 0.0
var terminado := false
var pantallas: Pantallas
var habitacion := ""
var puertas := {}
## Sistemas reutilizables del nivel: agenda, libreta, HUD, diálogo, jugo e indicador.
var travesuras: Travesuras

## Felipe está en un punto de descanso (para rellenar el bolsillo solo al llegar).
var _en_descanso := false
var _piezas := {}
var _sonidos: Array[AudioStreamPlayer] = []
## Si devuelve true, los logros nuevos esperan (no se muestran) hasta que deje de hacerlo; los que esperan.
var retener_logros: Callable
var logros_retenidos: PackedStringArray = []
var _lecciones_vistas := {}
var _fundido: ColorRect
var _cruzando := false
var _dijo := {}
## Mientras la cámara muestra la meta, Felipe no dice sus lecciones (se pisaban con «La libertad está allá arriba»).
var _mostrando_meta := false

@onready var felipe: Felipe = $Felipe


## Lo propio de este nivel (nodo hijo «Guion» de la escena). Existe desde que se instancia la escena: las pruebas
## ajustan el guion (por ejemplo, guion.batalla_con_jefe = false) antes de agregar el nivel al árbol.
var guion: GuionNivel:
	get:
		return get_node_or_null("Guion") as GuionNivel


## Calcetines del día (van al nido de Su Majestad).
var calcetines: int:
	get:
		return travesuras.recompensas.calcetines if travesuras else 0


func _ready() -> void:
	guion.nivel = self
	datos = guion.datos_del_nivel()
	guion.crear_fondo()
	for pieza_datos: Array in datos.piezas:
		_crear_pieza(pieza_datos[0], pieza_datos[1], pieza_datos[2], pieza_datos[3])
	# Paredes de cada habitación: no se sale de un cuarto si no es por una puerta.
	for cuarto_datos: Array in datos.habitaciones:
		var cuarto: Rect2 = cuarto_datos[0]
		_crear_pieza(Rect2(cuarto.position.x - 20, 0, 20, datos.alto), false, "Pared izquierda de %s" % cuarto_datos[1], "invisible")
		_crear_pieza(Rect2(cuarto.end.x, 0, 20, datos.alto), false, "Pared derecha de %s" % cuarto_datos[1], "invisible")
	felipe.sonido.connect(sonar)
	for i in 5:
		var reproductor := AudioStreamPlayer.new()
		add_child(reproductor)
		_sonidos.append(reproductor)
	# Una sola pila de pantallas (título, pausa, libreta, resumen): decide qué responde a las teclas y la pausa.
	add_child(GestorPantallas.new())
	# Teclas y botones que el jugador cambió (si los guardó).
	Controles.cargar()
	Opciones.cargar()
	# Capas de pantalla de la tabla única (Capas): título, intro y pausa tapan todo (G7).
	$Interfaz.layer = Capas.CAPA_INTERFAZ
	var capa_pantallas := CanvasLayer.new()
	capa_pantallas.name = "Capa de pantallas"
	capa_pantallas.layer = Capas.CAPA_PANTALLAS
	add_child(capa_pantallas)
	pantallas = Pantallas.new()
	pantallas.reiniciar.connect(func() -> void: get_tree().reload_current_scene())
	pantallas.empezar.connect(_mostrar_meta)
	pantallas.modo_cambiado.connect(_al_cambiar_modo)
	capa_pantallas.add_child(pantallas)
	pantallas.conectar_felipe(felipe)
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
	medidores.pantallas = pantallas
	travesuras = Travesuras.new(felipe, datos.agenda)
	add_child(travesuras)
	medidores.dialogo = travesuras.dialogo
	medidores.anuncios = travesuras.anuncios
	pantallas.bolsillo.conectar(felipe, travesuras.recompensas)
	_crear_puertas()
	# Profundidad (capas por rol): Felipe es el JUGADOR y el vigía avisa en qué superficie está.
	Profundidad.superficie_felipe = "piso"
	Profundidad.poner(felipe, Capas.Rol.JUGADOR)
	add_child(VigiaSuperficie.new(self, felipe))
	guion.preparar()
	_fundido = ColorRect.new()
	_fundido.name = "Fundido"
	_fundido.color = Color.BLACK
	_fundido.modulate.a = 0.0
	_fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sigue en pausa (B1: la presentación del jefe pausa el árbol; el fundido nunca se queda a medias).
	_fundido.process_mode = Node.PROCESS_MODE_ALWAYS
	_fundido.set_anchors_preset(Control.PRESET_FULL_RECT)
	# El negro de las puertas tapa también el diálogo, los carteles y los logros (G7).
	var capa_fundido := CanvasLayer.new()
	capa_fundido.name = "Capa del fundido"
	capa_fundido.layer = Capas.CAPA_FUNDIDO
	add_child(capa_fundido)
	capa_fundido.add_child(_fundido)
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	_al_cambiar_modo(pantallas.modo)
	_actualizar_camara()
	guion.al_terminar_de_armar()


func _crear_puertas() -> void:
	for puerta_datos: Array in datos.puertas:
		var puerta := Puerta.new(puerta_datos[0], puerta_datos[1], puerta_datos[2], puerta_datos[1].y - datos.techo)
		# Las dos caras de una puerta se ven igual (el creador, 2026-10-19): mismo estado a cada lado.
		var caras := [puerta_datos[0], puerta_datos[2]]
		puerta.cerrada = caras.any(func(cara: String) -> bool: return cara in datos.puertas_cerradas)
		puerta.entornada = caras.any(func(cara: String) -> bool: return cara in datos.puertas_entornadas)
		puerta.escalera = puerta_datos[0] == datos.puerta_escalera
		puerta.sombra_detras = puerta_datos[0] in datos.puertas_con_sombra_detras
		puerta.estilo = datos.estilo_puerta(puerta_datos[0])
		puerta.cruzada.connect(cruzar)
		add_child(puerta)
		puertas[puerta_datos[0]] = puerta
	# Las dos caras de una misma puerta se abren y se cierran juntas (Valeria abre de un lado, se ve del otro).
	for nombre: String in puertas:
		var puerta: Puerta = puertas[nombre]
		puerta.par = puertas.get(puerta.destino)


func _physics_process(delta: float) -> void:
	_soltar_logros()
	if terminado:
		return
	tiempo += delta
	_actualizar_camara()
	# Puntos de descanso: ahí reaparece Felipe si pierde una vida, y al llegar rellenan el bolsillo hasta 3 snacks.
	var en_descanso := false
	for descanso: Rect2 in datos.descansos:
		if descanso.has_point(felipe.global_position) and felipe.is_on_floor():
			en_descanso = true
			var punto := Vector2(descanso.get_center().x, descanso.position.y + 10)
			if felipe.punto_reaparicion != punto:
				felipe.punto_reaparicion = punto
				sonar("logro")
			if not _en_descanso:
				felipe.recargar_snacks(datos.snacks_en_descanso)
	_en_descanso = en_descanso
	_actualizar_lecciones()
	guion.cada_cuadro(delta)


## La cámara queda dentro de la habitación donde está Felipe (también después de una puerta o de reaparecer).
func _actualizar_camara() -> void:
	var actual := datos.habitacion_de(felipe.global_position)
	if actual == "" or actual == habitacion:
		return
	habitacion = actual
	var cuarto := datos.rect_de(actual)
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = int(cuarto.position.x)
	camara.limit_right = int(cuarto.end.x)
	camara.limit_top = 0
	camara.limit_bottom = int(datos.alto)
	camara.reset_smoothing()
	# El salto de cámara se completa en el cuadro siguiente, ya con los límites nuevos.
	camara.reset_smoothing.call_deferred()
	habitacion_cambiada.emit(actual)


## Cruza una puerta: funde a negro, lleva a Felipe a la puerta del otro lado y vuelve a mostrar.
## La escalera se sube (y se baja) escalón por escalón antes (o después) del fundido.
func cruzar(puerta: Puerta) -> void:
	if _cruzando or terminado:
		return
	if puerta.cerrada:
		puerta_cerrada_probada.emit(puerta)
		return
	if puerta.entornada:
		return
	var otra: Puerta = puertas.get(puerta.destino)
	if otra == null:
		return
	_cruzando = true
	sonar("salto")
	if puerta.escalera:
		await _subir_escalera()
	felipe.set_physics_process(false)
	if not puerta.escalera:
		await _entrar_por_la_puerta()
	await _fundir(1.0, 0.15)
	felipe.global_position = datos.escalera_cima if otra.escalera else otra.global_position
	felipe.velocity = Vector2.ZERO
	var centro := datos.rect_de(datos.habitacion_de(felipe.global_position)).get_center().x
	felipe.mirando = -1.0 if otra.escalera else (1.0 if felipe.global_position.x < centro else -1.0)
	felipe.sprite.flip_h = felipe.mirando < 0.0
	felipe.sprite.play("quieto")
	_actualizar_camara()
	await _fundir(0.0, 0.2)
	if otra.escalera:
		await _bajar_escalera()
		escalera_bajada.emit()
	felipe.set_physics_process(true)
	_cruzando = false
	fundido_terminado.emit()


## Antes del fundido: Felipe mira a la cámara, se da vuelta y entra (animación `entrar_puerta`, desde Felipe A). El
## negro empieza al terminar (con un tope por si la animación no avanza).
func _entrar_por_la_puerta() -> void:
	var sprite := felipe.sprite
	if not sprite.sprite_frames.has_animation(&"entrar_puerta"):
		return
	felipe.velocity = Vector2.ZERO
	# Se llama desde el cuadro de física de Felipe (al tocar la puerta): se espera a que termine ese cuadro, que
	# todavía pone su animación de siempre.
	await get_tree().physics_frame
	sprite.play(&"entrar_puerta")
	var tope := Time.get_ticks_msec() + 1500
	while sprite.animation == &"entrar_puerta" and sprite.is_playing() and Time.get_ticks_msec() < tope:
		await get_tree().process_frame


## Opacidad del negro de las puertas (0 a 1).
func fundido_alfa() -> float:
	return _fundido.modulate.a


## Título, introducción, pausa o final: la interfaz del juego (HUD, diálogo, palabras, avisos) no se ve (G7).
func _al_cambiar_modo(modo: Pantallas.Modo) -> void:
	var jugando := modo == Pantallas.Modo.JUGANDO
	if travesuras:
		travesuras.mostrar_interfaz(jugando)


## ¿Está cruzando una puerta ahora (sin contar el fundido de la meta)?
func cruce_en_curso() -> bool:
	return _cruzando


## ¿Hay un fundido de puerta en curso? (la pelea espera a que termine: arregla B1).
func cruzando() -> bool:
	return _cruzando or _fundido.modulate.a > 0.01


func _fundir(alfa: float, segundos: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fundido, "modulate:a", alfa, segundos)
	await tween.finished


## Sube los escalones (animación subir_escalera, un saltito por escalón) y camina al vano del descanso.
func _subir_escalera() -> void:
	felipe.subir_escalera(datos.peldanos.duplicate())
	await felipe.escalera_terminada
	felipe.set_physics_process(false)
	await _caminar_a(datos.escalera_cima, 0.55)


## Al volver de arriba: aparece en el descanso, camina al último escalón y baja escalón por escalón.
func _bajar_escalera() -> void:
	await _caminar_a(datos.peldanos[-1], 0.5)
	felipe.set_physics_process(true)
	var peldanos: Array[Vector2] = []
	for i in range(datos.peldanos.size() - 2, -1, -1):
		peldanos.append(datos.peldanos[i])
	peldanos.append(datos.escalera_pie)
	felipe.subir_escalera(peldanos)
	await felipe.escalera_terminada


## Camina por el descanso (sin piso de colisión: la escalera es de fondo).
func _caminar_a(destino: Vector2, segundos: float) -> void:
	felipe.mirando = signf(destino.x - felipe.global_position.x) if absf(destino.x - felipe.global_position.x) > 1.0 else felipe.mirando
	felipe.sprite.flip_h = felipe.mirando < 0.0
	felipe.sprite.play("caminar")
	var paso := create_tween()
	paso.tween_property(felipe, "global_position", destino, segundos)
	await paso.finished
	felipe.sprite.play("quieto")


## Primeras frases de Felipe, una sola vez por zona (en lugar de los avisos de abajo).
func _actualizar_lecciones() -> void:
	for i in datos.lecciones.size():
		if _lecciones_vistas.has(i):
			continue
		var zona: Rect2 = datos.lecciones[i][0]
		if zona.grow_individual(0, 0, 0, 4).has_point(felipe.global_position) and not _cruzando and not _mostrando_meta:
			_lecciones_vistas[i] = true
			travesuras.dialogo.decir("felipe", datos.lecciones[i][1], datos.lecciones[i][2])


## Al empezar, la cámara muestra un momento la meta (R4). Felipe lo dice y arranca. Sin cortes duros (M4): del negro de
## la introducción se abre a la meta, y de la meta se funde al primer cuarto.
func _mostrar_meta() -> void:
	_mostrando_meta = true
	_fundido.modulate.a = 1.0
	var meta := datos.rect_de(datos.cuarto_meta)
	var camara_meta := Camera2D.new()
	camara_meta.name = "Camara de la meta"
	camara_meta.position = Vector2(meta.get_center().x, datos.suelo - 120)
	camara_meta.limit_left = int(meta.position.x)
	camara_meta.limit_right = int(meta.end.x)
	camara_meta.limit_top = 0
	camara_meta.limit_bottom = int(datos.alto)
	add_child(camara_meta)
	camara_meta.make_current()
	await _fundir(0.0, 0.4)
	travesuras.jugo.palabra(datos.rotulo_meta, Vector2(320, 150), Color(1.0, 0.85, 0.45), 14)
	decir("meta", true)
	await get_tree().create_timer(1.6).timeout
	await _fundir(1.0, 0.3)
	felipe.get_node("Camara").make_current()
	camara_meta.queue_free()
	await _fundir(0.0, 0.35)
	_mostrando_meta = false
	decir("inicio")


func sonar(nombre: String, tono := 1.0) -> void:
	var ruta := "res://assets/sonidos/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	for reproductor in _sonidos:
		if not reproductor.playing:
			reproductor.stream = load(ruta)
			reproductor.pitch_scale = tono
			reproductor.play()
			return


## Silencio de golpe (v4: contraste justo antes del golpe estrella): corta los sonidos que estén sonando.
func callar() -> void:
	for reproductor in _sonidos:
		reproductor.stop()


func desbloquear_logro(titulo: String) -> void:
	titulo = tr(titulo)
	if titulo in logros:
		return
	logros.append(titulo)
	# Mientras algo pide la pantalla limpia (el apagón de A.S.P.I., v4) el pergamino del logro espera su turno.
	if retener_logros.is_valid() and retener_logros.call():
		logros_retenidos.append(titulo)
		return
	logro_desbloqueado.emit(titulo)
	sonar("logro")


## Muestra los logros que esperaban, cuando ya nada los retiene.
func _soltar_logros() -> void:
	if logros_retenidos.is_empty() or (retener_logros.is_valid() and retener_logros.call()):
		return
	var pendientes := logros_retenidos
	logros_retenidos = []
	for titulo in pendientes:
		logro_desbloqueado.emit(titulo)
	sonar("logro")


## Felipe dice una frase de Frases.FELIPE (cada evento con `una_vez` sale solo la primera vez).
func decir(evento: String, urgente := false, una_vez := true) -> void:
	if una_vez and _dijo.has(evento):
		return
	_dijo[evento] = true
	travesuras.decir_felipe(evento, urgente)


## ¿Felipe ya dijo la frase de ese evento?
func ya_dijo(evento: String) -> bool:
	return _dijo.has(evento)


## Espera (en cuadros de física) a que se cumpla algo, como mucho `segundos`.
func esperar_que(condicion: Callable, segundos: float) -> void:
	var t := 0.0
	while t < segundos and not condicion.call() and is_inside_tree():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


## Espera a que se cierre la frase en pantalla (hasta `maximo` s): la respuesta va después, no se pisa ni caduca en la cola.
func esperar_dialogo(maximo: float) -> void:
	var espera := 0.0
	await get_tree().process_frame
	while travesuras.dialogo.ocupado() and espera < maximo:
		await get_tree().process_frame
		espera += get_process_delta_time()


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
	if estilo in ["repisa", "lugar_visto"]:
		var dibujo := Node2D.new()
		dibujo.name = "Dibujo"
		Profundidad.poner(dibujo, Capas.Rol.SALTABLE, PackedStringArray([nombre]))
		var adorno: String = datos.adornos_de_piezas.get(nombre, "")
		dibujo.draw.connect(func() -> void: ArteNivel.dibujar_repisa(dibujo, rect.size, FONDO_PISO, adorno))
		cuerpo.add_child(dibujo)
	add_child(cuerpo)


## La pieza (mueble) cuya cubierta sostiene `punto` (la base de un objeto), o "piso": para la profundidad de lo apoyado.
func superficie_en(punto: Vector2) -> String:
	for nombre: String in _piezas:
		var cuerpo: StaticBody2D = _piezas[nombre]
		var forma := cuerpo.get_child(0) as CollisionShape2D
		if forma == null or not forma.shape is RectangleShape2D:
			continue
		var tam := (forma.shape as RectangleShape2D).size
		var arriba := cuerpo.global_position
		if punto.x >= arriba.x - 2.0 and punto.x <= arriba.x + tam.x + 2.0 and absf(punto.y - arriba.y) <= 14.0:
			return nombre
	return "piso"


## Cuerpo sólido de una pieza (para las pruebas y el guion): su rectángulo actual en el mundo.
func pieza(nombre: String) -> StaticBody2D:
	return _piezas.get(nombre)
