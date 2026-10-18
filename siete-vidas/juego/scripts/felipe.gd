class_name Felipe
extends CharacterBody2D
## Controlador de Felipe: movimiento de plataformas con sensación moderna
## (margen de salto, salto recordado, altura variable, doble salto, zoomies, agacharse y gatear)
## y efectos de caricatura (estirar, aplastar y aterrizar con las patas delanteras).

signal aterrizo(fuerza: float)
## Pide un efecto de sonido (la sala lo reproduce).
signal sonido(nombre: String)

enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO, ATERRIZANDO, OCIO, DESMAYADO }

## Felipe mide unos 67 px de alto: Valeria (1,65 m) mide 3 Felipes. Ver la guía del personaje.
const ESCALA_SPRITE := 0.72
## Cuadros de la hoja "saltar" para cada fase (los mismos de la ficha de concepto).
## El cuadro 4 viene inclinado en diagonal y se ve raro: no se usa.
const CUADRO_AGACHADO := 1
const CUADRO_SUBIENDO := 2
const CUADRO_ARRIBA := 3
const CUADRO_ATERRIZAJE := 5
const CUADRO_ASENTARSE := 6
## Cuadros de la hoja "caer": un gato cae con las patas delanteras primero.
const CUADRO_CAYENDO := 3
const CUADRO_CONTACTO := 5
const INCLINACION_DOBLE_SALTO := -0.35
## Estirar y aplastar deforman la cabeza junto con el cuerpo: nunca más de ±8 % para que Felipe
## conserve sus proporciones (regla del creador).
const DEFORMACION_MAXIMA := 0.08
## Alto de la caja de colisión de pie y agachado.
## De pie mide 58 px de las orejas a las patas; agachado, unos 33 px.
## Pasa agachado bajo muebles con 30 cm libres (36 px).
const ALTO_DE_PIE := 58.0
const ALTO_AGACHADO := 32.0
## Capa de los muebles que se atraviesan desde abajo (agachado + saltar baja a través de ellos).
const CAPA_ATRAVESABLE := 2
## Animaciones de ocio: nombre -> vueltas del ciclo antes de volver a quieto.
## Todas salen de Felipe A en cuadros de 106 px y se dibujan con ESCALA_SPRITE, como las demás.
const OCIO := {
	"acicalarse": 3,
	"jugar": 3,
	"vueltas": 2,
}
## Bola de estambre del ocio "jugar": objeto aparte (la animación es solo Felipe) que rueda frente a él.
const BOLA_ESTAMBRE := preload("res://assets/felipe/estambre-bola.png")
const DISTANCIA_ESTAMBRE := 28.0
## Acciones que, presionadas, cuentan como "estar jugando" (cortan el ocio y reinician la espera).
const ACCIONES := ["mover_izquierda", "mover_derecha", "saltar", "zoomies", "zarpazo", "interactuar", "agacharse"]
## Vida: corazones por vida y vidas por partida. Al perder la última, despierta en casa con el Collar de la Vergüenza.
const CORAZONES_MAX := 5
const VIDAS_MAX := 9
## Segundos sin recibir más daño después de un golpe (parpadea).
const TIEMPO_INVULNERABLE := 1.2
## Segundos desmayado antes de reaparecer.
const TIEMPO_DESMAYO := 1.8
## Peso en kilos: no cambia el dibujo de Felipe, solo el indicador de la interfaz.
const PESO_INICIAL := 8.0
const PESO_POR_COMIDA := 0.3
## Alcance del zarpazo frente a Felipe (horizontal, vertical).
const ALCANCE_ZARPAZO := Vector2(56, 40)
## Duración de la transición "agacharse" (4 cuadros a 12 fps), también al pararse.
const DURACION_TRANSICION := 0.33
## Distancia (horizontal, vertical) a la que el botón de acción alcanza un objeto.
const ALCANCE := Vector2(48, 40)

@export_group("Movimiento")
@export var velocidad_caminar := 120.0
@export var velocidad_correr := 190.0
@export var aceleracion := 1200.0
@export var friccion := 1450.0
@export var velocidad_gatear := 55.0
@export var velocidad_trepar := 140.0
@export_group("Salto")
@export var gravedad := 1410.0
@export var gravedad_cayendo := 1940.0
@export var velocidad_salto := -475.0
@export var velocidad_doble_salto := -420.0
@export var caida_maxima := 600.0
@export var corte_salto := 0.45
@export var margen_salto := 0.1
@export var salto_recordado := 0.12
@export_group("Zoomies")
@export var velocidad_zoomies := 380.0
@export var duracion_zoomies := 0.18
@export var espera_zoomies := 0.45
@export_group("Ocio")
## Segundos quieto y sin tocar nada antes de ponerse a acicalarse, jugar o dar vueltas.
@export var espera_ocio := 8.0

var estado := Estado.SUELO
var mirando := 1.0
var tiene_doble_salto := true
var agachado := false
var corazones := CORAZONES_MAX
var vidas := VIDAS_MAX
var peso := PESO_INICIAL
var tiene_collar := false
## Poder que gana al escapar por el balcón (fin del tutorial).
var tiene_caer_de_pie := false
## Zonas donde puede trepar (cortinas), en coordenadas del mundo. Las pone la sala.
var zonas_trepables: Array[Rect2] = []
var trepando := false
var _tiempo_sin_trepar := 0.0
var punto_reaparicion: Vector2
## Arrastre de afuera en px/s (la succión de A.S.P.I.); agachado se aferra con las uñas y no lo mueve.
var empuje := Vector2.ZERO

var _tiempo_fuera_del_suelo := 0.0
var _tiempo_salto_pedido := 99.0
var _tiempo_zoomies := 0.0
var _espera_zoomies := 0.0
var _velocidad_al_caer := 0.0
var _tiempo_desde_salto := 99.0
var _tiempo_aterrizando := 0.0
var _tiempo_estela := 0.0
var _tiempo_bajando := 0.0
var _tiempo_sin_tocar := 0.0
var _tiempo_levantandose := 0.0
var _tiempo_ocio := 0.0
var _tiempo_invulnerable := 0.0
var _tiempo_desmayado := 0.0
var _estambre: Sprite2D
var _efecto: Tween
var _posicion_sprite: Vector2

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var polvo: CPUParticles2D = $Polvo
@onready var cuerpo: CollisionShape2D = $Cuerpo


func _ready() -> void:
	sprite.sprite_frames = AnimacionesFelipe.crear()
	sprite.scale = Vector2.ONE * ESCALA_SPRITE
	_posicion_sprite = sprite.position
	cuerpo.shape = cuerpo.shape.duplicate()
	set_collision_mask_value(CAPA_ATRAVESABLE, true)
	# Felipe va en su propia capa (3): los enemigos no chocan con él; el daño se calcula por distancia.
	collision_layer = 0
	set_collision_layer_value(3, true)
	sprite.animation_finished.connect(_al_terminar_animacion)
	add_to_group("felipe")
	punto_reaparicion = global_position
	sprite.play("quieto")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("mover_izquierda", "mover_derecha")
	_tiempo_salto_pedido += delta
	_tiempo_desde_salto += delta
	_espera_zoomies = maxf(0.0, _espera_zoomies - delta)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0
	_actualizar_bajada(delta)
	_actualizar_invulnerable(delta)
	if _actualizar_trepar(direccion):
		return
	_actualizar_ocio(delta)
	_actualizar_agachado()

	match estado:
		Estado.ZOOMIES:
			_actualizar_zoomies(delta)
		Estado.ZARPAZO, Estado.COMIENDO, Estado.OCIO:
			_frenar(delta)
			_aplicar_gravedad(delta)
		Estado.DESMAYADO:
			_frenar(delta)
			_aplicar_gravedad(delta)
			_tiempo_desmayado -= delta
			if _tiempo_desmayado <= 0.0:
				_reaparecer()
		Estado.ATERRIZANDO:
			_mover(direccion, delta)
			_aplicar_gravedad(delta)
			_intentar_saltar()
			if estado == Estado.ATERRIZANDO:
				_intentar_acciones(direccion)
			_tiempo_aterrizando -= delta
			if _tiempo_aterrizando <= 0.0 and estado == Estado.ATERRIZANDO:
				estado = Estado.SUELO
		_:
			_mover(direccion, delta)
			_aplicar_gravedad(delta)
			_intentar_saltar()
			_intentar_acciones(direccion)

	var estaba_en_suelo := is_on_floor()
	_velocidad_al_caer = velocity.y
	var arrastre := Vector2.ZERO if agachado or estado == Estado.DESMAYADO else empuje
	velocity += arrastre
	move_and_slide()
	velocity -= arrastre
	_actualizar_suelo(estaba_en_suelo, delta)
	_actualizar_animacion(direccion)
	_actualizar_estela(delta)


func _mover(direccion: float, delta: float) -> void:
	var maxima := velocidad_correr if Input.is_action_pressed("zoomies") else velocidad_caminar
	if agachado:
		maxima = velocidad_gatear
	if direccion != 0.0:
		mirando = signf(direccion)
		velocity.x = move_toward(velocity.x, direccion * maxima, aceleracion * delta)
	else:
		_frenar(delta)


func _frenar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friccion * delta)


func _aplicar_gravedad(delta: float) -> void:
	if is_on_floor():
		return
	var g := gravedad_cayendo if velocity.y > 0.0 else gravedad
	velocity.y = minf(velocity.y + g * delta, caida_maxima)
	# Altura variable: soltar el botón corta la subida.
	if velocity.y < 0.0 and Input.is_action_just_released("saltar"):
		velocity.y *= corte_salto


func _intentar_saltar() -> void:
	if _tiempo_salto_pedido > salto_recordado:
		return
	if agachado:
		_tiempo_salto_pedido = 99.0
		if _sobre_mueble_atravesable():
			_bajar_por_mueble()
			return
		if not _cabe_de_pie():
			return
		_poner_agachado(false)
	if is_on_floor() or _tiempo_fuera_del_suelo < margen_salto:
		_saltar(velocidad_salto)
		_soltar_polvo(10)
		# Despegue: se ve agachado un instante y sale estirado (sin retrasar el salto).
		_estirar(Vector2(0.94, 1.06), 0.2)
	elif tiene_doble_salto:
		tiene_doble_salto = false
		_saltar(velocidad_doble_salto)
		_soltar_polvo(8)
		_inclinar(INCLINACION_DOBLE_SALTO, 0.28)


func _saltar(fuerza: float) -> void:
	sonido.emit("salto")
	velocity.y = fuerza
	_tiempo_desde_salto = 0.0
	sprite.rotation = 0.0
	_tiempo_salto_pedido = 99.0
	_tiempo_fuera_del_suelo = 99.0
	estado = Estado.AIRE


func _intentar_acciones(direccion: float) -> void:
	if agachado:
		return
	if Input.is_action_just_pressed("zoomies") and _espera_zoomies == 0.0:
		estado = Estado.ZOOMIES
		_tiempo_zoomies = duracion_zoomies
		_espera_zoomies = espera_zoomies
		if direccion != 0.0:
			mirando = signf(direccion)
		velocity = Vector2(mirando * velocidad_zoomies, 0.0)
		_estirar(Vector2(1.06, 0.95), duracion_zoomies)
	elif Input.is_action_just_pressed("zarpazo"):
		estado = Estado.ZARPAZO
		sprite.play("zarpazo")
		sonido.emit("zarpazo")
		_golpear()
	elif Input.is_action_just_pressed("interactuar") and is_on_floor():
		var objeto := objeto_cercano()
		if objeto:
			objeto.call("interactuar", self)


## El objeto interactuable más cercano al alcance, o null si no hay ninguno (el botón no hace nada).
func objeto_cercano() -> Node2D:
	var mejor: Node2D = null
	for objeto: Node2D in get_tree().get_nodes_in_group(Comida.GRUPO):
		var distancia := objeto.global_position - global_position
		if absf(distancia.x) <= ALCANCE.x and absf(distancia.y) <= ALCANCE.y:
			if mejor == null or absf(distancia.x) < absf(mejor.global_position.x - global_position.x):
				mejor = objeto
	return mejor


## Comer cura un corazón y suma peso.
func comer() -> void:
	estado = Estado.COMIENDO
	velocity.x = 0.0
	sprite.play("comer")
	corazones = mini(corazones + 1, CORAZONES_MAX)
	peso += PESO_POR_COMIDA
	sonido.emit("comer")


## Tirar algo de un manotazo (por ejemplo, el vaso de la mesa): usa la animación del zarpazo.
func dar_manotazo() -> void:
	estado = Estado.ZARPAZO
	velocity.x = 0.0
	sprite.play("zarpazo")


func _actualizar_zoomies(delta: float) -> void:
	_tiempo_zoomies -= delta
	velocity.y = 0.0
	if _tiempo_zoomies <= 0.0:
		estado = Estado.SUELO if is_on_floor() else Estado.AIRE
		velocity.x = mirando * velocidad_correr


func _actualizar_suelo(estaba_en_suelo: bool, delta: float) -> void:
	if is_on_floor():
		_tiempo_fuera_del_suelo = 0.0
		tiene_doble_salto = true
		if not estaba_en_suelo:
			_aterrizar()
	else:
		_tiempo_fuera_del_suelo += delta
		if estado in [Estado.SUELO, Estado.ATERRIZANDO]:
			estado = Estado.AIRE


## Un gato aterriza primero con las patas delanteras: llega inclinado con la nariz
## hacia abajo, se endereza sobre ellas y después se aplasta.
func _aterrizar() -> void:
	var fuerza := clampf(_velocidad_al_caer / caida_maxima, 0.0, 1.0)
	aterrizo.emit(fuerza)
	if estado == Estado.AIRE:
		estado = Estado.ATERRIZANDO
		_tiempo_aterrizando = 0.24
	if fuerza > 0.25:
		_soltar_polvo(int(8 + 8 * fuerza))
	if _efecto:
		_efecto.kill()
	# Las patas delanteras tocan primero: el cuerpo gira sobre ellas hasta enderezarse
	# y después se aplasta con un rebote.
	_efecto = create_tween()
	_efecto.tween_property(sprite, "rotation", 0.0, 0.08).from(sprite.rotation)
	var base := _escala_base()
	_efecto.tween_property(sprite, "scale", base * Vector2(1.0 + DEFORMACION_MAXIMA * fuerza, 1.0 - DEFORMACION_MAXIMA * fuerza), 0.05)
	_efecto.tween_property(sprite, "scale", base, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _actualizar_animacion(direccion: float) -> void:
	sprite.flip_h = mirando < 0.0
	if estado in [Estado.ZARPAZO, Estado.COMIENDO, Estado.OCIO, Estado.DESMAYADO]:
		return
	if estado == Estado.ZOOMIES:
		_reproducir("correr")
	elif estado == Estado.ATERRIZANDO:
		# Primero tocan las delanteras, después baja la parte de atrás y se aplasta.
		if _tiempo_aterrizando > 0.16:
			_poner_cuadro("caer", CUADRO_CONTACTO)
		elif _tiempo_aterrizando > 0.08:
			_poner_cuadro("saltar", CUADRO_ATERRIZAJE)
		else:
			_poner_cuadro("saltar", CUADRO_ASENTARSE)
	elif not is_on_floor():
		_animar_aire()
	elif agachado:
		# Primero termina de agacharse; después gatea, o se queda pegado al piso en el primer cuadro.
		if sprite.animation == "agacharse" and sprite.is_playing():
			pass
		elif direccion != 0.0:
			_reproducir("gatear")
		else:
			_poner_cuadro("gatear", 0)
	elif _tiempo_levantandose > 0.0:
		# Se está parando: la transición de agacharse al revés.
		_tiempo_levantandose -= get_physics_process_delta_time()
	elif absf(velocity.x) > velocidad_caminar + 5.0:
		_reproducir("correr")
	elif direccion != 0.0:
		_reproducir("caminar")
	else:
		_reproducir("quieto")


## Fases del salto: despegue agachado, subida estirada, pausa arriba con las patas
## recogidas y caída en picada con las patas delanteras estiradas hacia el suelo
## (la pose "caer" ya viene inclinada, así que no se rota el sprite).
func _animar_aire() -> void:
	if _tiempo_desde_salto < 0.06:
		_poner_cuadro("saltar", CUADRO_AGACHADO)
	elif velocity.y < -85.0:
		_poner_cuadro("saltar", CUADRO_SUBIENDO)
	elif velocity.y < 85.0:
		_poner_cuadro("saltar", CUADRO_ARRIBA)
	else:
		_poner_cuadro("caer", CUADRO_CAYENDO)
		# La caída manda sobre cualquier giro anterior (por ejemplo, el del doble salto).
		if _efecto and _efecto.is_running():
			_efecto.kill()
			sprite.scale = Vector2.ONE * ESCALA_SPRITE
		sprite.rotation = lerpf(sprite.rotation, 0.0, 0.3)


func _poner_cuadro(animacion: String, cuadro: int) -> void:
	sprite.stop()
	sprite.animation = animacion
	sprite.frame = cuadro


func _soltar_polvo(cantidad: int) -> void:
	polvo.amount = maxi(cantidad, 1)
	polvo.restart()
	polvo.emitting = true


## Estela de imágenes fantasma mientras está en el aire o haciendo Zoomies.
func _actualizar_estela(delta: float) -> void:
	if is_on_floor() and estado != Estado.ZOOMIES:
		return
	_tiempo_estela += delta
	if _tiempo_estela < 0.035:
		return
	_tiempo_estela = 0.0
	var fantasma := Sprite2D.new()
	fantasma.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	fantasma.global_position = sprite.global_position
	fantasma.global_rotation = sprite.global_rotation
	fantasma.scale = sprite.scale
	fantasma.flip_h = sprite.flip_h
	fantasma.modulate.a = 0.28
	fantasma.z_index = -1
	get_parent().add_child(fantasma)
	var desvanecer := fantasma.create_tween()
	desvanecer.tween_property(fantasma, "modulate:a", 0.0, 0.22)
	desvanecer.tween_callback(fantasma.queue_free)


func _reproducir(nombre: String) -> void:
	if sprite.animation != nombre or not sprite.is_playing():
		sprite.play(nombre)


func _al_terminar_animacion() -> void:
	if estado in [Estado.ZARPAZO, Estado.COMIENDO]:
		estado = Estado.SUELO if is_on_floor() else Estado.AIRE


func _estirar(forma: Vector2, duracion: float) -> void:
	if _efecto:
		_efecto.kill()
	var base := _escala_base()
	_efecto = create_tween()
	forma = forma.clamp(Vector2.ONE * (1.0 - DEFORMACION_MAXIMA), Vector2.ONE * (1.0 + DEFORMACION_MAXIMA))
	_efecto.tween_property(sprite, "scale", base * forma, duracion * 0.3)
	_efecto.tween_property(sprite, "scale", base, duracion * 0.7)


func _inclinar(angulo: float, duracion: float) -> void:
	if _efecto:
		_efecto.kill()
	_efecto = create_tween()
	_efecto.tween_property(sprite, "rotation", angulo * mirando, duracion * 0.5)
	_efecto.tween_property(sprite, "rotation", 0.0, duracion * 0.5)


## Agacharse: solo en el piso. Bajo un mueble no se puede parar aunque se suelte el botón.
func _actualizar_agachado() -> void:
	var quiere := Input.is_action_pressed("agacharse") and is_on_floor() and estado in [Estado.SUELO, Estado.ATERRIZANDO]
	if quiere and not agachado:
		_poner_agachado(true)
	elif agachado and not quiere and _cabe_de_pie():
		_poner_agachado(false)


func _poner_agachado(valor: bool) -> void:
	agachado = valor
	var caja := cuerpo.shape as RectangleShape2D
	var alto := ALTO_AGACHADO if valor else ALTO_DE_PIE
	caja.size.y = alto
	cuerpo.position.y = -alto / 2.0
	if _efecto:
		_efecto.kill()
	sprite.rotation = 0.0
	sprite.scale = _escala_base()
	# Transición dibujada (cuadros 0 a 2 de la hoja de gatear): al bajar hacia adelante, al pararse al revés.
	if valor:
		sprite.play("agacharse")
	elif is_on_floor():
		sprite.play_backwards("agacharse")
		_tiempo_levantandose = DURACION_TRANSICION


func _escala_base() -> Vector2:
	return Vector2.ONE * ESCALA_SPRITE


## ¿Hay espacio arriba para pararse? (Los muebles que se atraviesan desde abajo no estorban.)
func _cabe_de_pie() -> bool:
	return not test_move(global_transform, Vector2(0, -(ALTO_DE_PIE - ALTO_AGACHADO)))


func _sobre_mueble_atravesable() -> bool:
	for i in get_slide_collision_count():
		var choque := get_slide_collision(i)
		var objeto := choque.get_collider() as CollisionObject2D
		if choque.get_normal().y < -0.5 and objeto and objeto.get_collision_layer_value(CAPA_ATRAVESABLE):
			return true
	return false


## Agachado + saltar sobre una repisa: deja de chocar con los muebles atravesables un instante y cae.
func _bajar_por_mueble() -> void:
	set_collision_mask_value(CAPA_ATRAVESABLE, false)
	_tiempo_bajando = 0.25
	_poner_agachado(false)
	position.y += 2.0


func _actualizar_bajada(delta: float) -> void:
	if _tiempo_bajando <= 0.0:
		return
	_tiempo_bajando -= delta
	if _tiempo_bajando <= 0.0:
		set_collision_mask_value(CAPA_ATRAVESABLE, true)


## Ocio: tras unos segundos quieto y sin tocar nada, elige al azar acicalarse, jugar con estambre
## o dar vueltas persiguiéndose la cola. Cualquier acción lo corta y vuelve a contar desde cero.
func _actualizar_ocio(delta: float) -> void:
	var tocando := ACCIONES.any(func(accion: String) -> bool: return Input.is_action_pressed(accion))
	if estado == Estado.OCIO:
		_tiempo_ocio -= delta
		_rodar_estambre()
		if tocando or _tiempo_ocio <= 0.0 or not is_on_floor():
			_terminar_ocio()
		return
	if tocando or estado != Estado.SUELO or agachado or not is_on_floor() or absf(velocity.x) > 1.0:
		_tiempo_sin_tocar = 0.0
		return
	_tiempo_sin_tocar += delta
	if _tiempo_sin_tocar >= espera_ocio:
		_empezar_ocio(OCIO.keys().pick_random())


func _empezar_ocio(nombre: String) -> void:
	estado = Estado.OCIO
	if _efecto:
		_efecto.kill()
	sprite.rotation = 0.0
	sprite.scale = _escala_base()
	sprite.position = _posicion_sprite
	sprite.play(nombre)
	if nombre == "jugar":
		_estambre = Sprite2D.new()
		_estambre.name = "Estambre"
		_estambre.texture = BOLA_ESTAMBRE
		_estambre.scale = Vector2.ONE * ESCALA_SPRITE
		add_child(_estambre)
		_rodar_estambre()
	var frames := sprite.sprite_frames
	_tiempo_ocio = frames.get_frame_count(nombre) / frames.get_animation_speed(nombre) * OCIO[nombre]


## Se lame la pata como si nada (al final de la pelea con A.S.P.I.).
func acicalarse() -> void:
	if is_on_floor() and estado == Estado.SUELO:
		_empezar_ocio("acicalarse")


func _terminar_ocio() -> void:
	estado = Estado.SUELO if is_on_floor() else Estado.AIRE
	_tiempo_sin_tocar = 0.0
	sprite.scale = _escala_base()
	sprite.position = _posicion_sprite
	sprite.play("quieto")
	if _estambre:
		remove_child(_estambre)
		_estambre.queue_free()
		_estambre = null


## El estambre va y viene frente a Felipe al ritmo de los golpes de la pata, girando al rodar.
func _rodar_estambre() -> void:
	if not _estambre:
		return
	var vaiven := sin(Time.get_ticks_msec() * 0.006) * 6.0
	_estambre.position = Vector2(mirando * (DISTANCIA_ESTAMBRE + vaiven), -BOLA_ESTAMBRE.get_height() * 0.3)
	_estambre.rotation = vaiven / 7.0


## El zarpazo golpea a los enemigos que estén justo enfrente.
func _golpear() -> void:
	for enemigo: Node2D in get_tree().get_nodes_in_group("enemigos"):
		var distancia := enemigo.global_position - global_position
		var enfrente := signf(distancia.x) == mirando or absf(distancia.x) < 8.0
		if enfrente and absf(distancia.x) <= ALCANCE_ZARPAZO.x and absf(distancia.y) <= ALCANCE_ZARPAZO.y:
			enemigo.call("recibir_zarpazo", self)


## Daño: quita corazones, empuja lejos de quien golpea y deja un rato invulnerable (parpadea).
## Sin corazones, se desmaya y pierde una vida.
func recibir_dano(cantidad: int, desde_x: float) -> void:
	if _tiempo_invulnerable > 0.0 or estado == Estado.DESMAYADO:
		return
	if estado == Estado.OCIO:
		_terminar_ocio()
	if agachado:
		_poner_agachado(false)
	corazones = maxi(corazones - cantidad, 0)
	trepando = false
	sonido.emit("golpe")
	if corazones == 0:
		_desmayarse()
		return
	_tiempo_invulnerable = TIEMPO_INVULNERABLE
	var lado := signf(global_position.x - desde_x)
	velocity = Vector2((lado if lado != 0.0 else -mirando) * 220.0, -220.0)
	estado = Estado.AIRE


func _actualizar_invulnerable(delta: float) -> void:
	if _tiempo_invulnerable <= 0.0:
		return
	_tiempo_invulnerable -= delta
	sprite.modulate.a = 0.35 if int(_tiempo_invulnerable * 12.0) % 2 == 0 else 1.0
	if _tiempo_invulnerable <= 0.0:
		sprite.modulate.a = 1.0


func _desmayarse() -> void:
	estado = Estado.DESMAYADO
	_tiempo_desmayado = TIEMPO_DESMAYO
	vidas -= 1
	velocity.x = 0.0
	sprite.modulate.a = 1.0
	sprite.play("desmayo")
	# Una de sus nueve vidas sube como gatito fantasma.
	var fantasma := Sprite2D.new()
	fantasma.texture = sprite.sprite_frames.get_frame_texture("quieto", 0)
	fantasma.scale = Vector2.ONE * ESCALA_SPRITE * 0.6
	fantasma.global_position = sprite.global_position
	fantasma.modulate = Color(1, 1, 1, 0.7)
	fantasma.z_index = 10
	get_parent().add_child(fantasma)
	var subir := fantasma.create_tween().set_parallel()
	subir.tween_property(fantasma, "global_position:y", fantasma.global_position.y - 70.0, 1.4)
	subir.tween_property(fantasma, "modulate:a", 0.0, 1.4)
	subir.chain().tween_callback(fantasma.queue_free)


## Reaparece en el último punto de descanso. Sin vidas, vuelven las nueve pero con el Collar de la Vergüenza.
func _reaparecer() -> void:
	if vidas <= 0:
		vidas = VIDAS_MAX
		tiene_collar = true
	corazones = CORAZONES_MAX
	global_position = punto_reaparicion
	velocity = Vector2.ZERO
	estado = Estado.SUELO
	sprite.play("quieto")
	_tiempo_invulnerable = TIEMPO_INVULNERABLE



## Trepar: dentro de una zona trepable (cortina), mantener arriba sube y abajo baja; saltar se suelta.
## Al llegar arriba da un saltito para pasar al otro lado. Devuelve true si este cuadro estuvo trepando.
## Animación "trepar" desde Felipe A (quieto en la cortina, se queda en su primer cuadro).
func _actualizar_trepar(direccion: float) -> bool:
	_tiempo_sin_trepar = maxf(0.0, _tiempo_sin_trepar - get_physics_process_delta_time())
	var zona := _zona_trepable()
	if zona == Rect2() or agachado or estado in [Estado.DESMAYADO, Estado.OCIO, Estado.ZARPAZO, Estado.COMIENDO]:
		trepando = false
		return false
	if not trepando:
		if _tiempo_sin_trepar > 0.0 or not Input.is_action_pressed("mover_arriba"):
			return false
		trepando = true
	if Input.is_action_just_pressed("saltar"):
		trepando = false
		_saltar(velocidad_salto)
		return false
	var vertical := Input.get_axis("mover_arriba", "agacharse")
	if direccion != 0.0:
		mirando = signf(direccion)
	# Colgado de la cortina se mantiene centrado en ella (así pasa limpio por huecos angostos).
	velocity = Vector2((zona.get_center().x - global_position.x) * 8.0, vertical * velocidad_trepar)
	estado = Estado.AIRE
	tiene_doble_salto = true
	move_and_slide()
	if global_position.y - 20.0 < zona.position.y + 4.0:
		# Llegó arriba: se pasa hacia el lado al que mira y se suelta un momento de la cortina.
		trepando = false
		_tiempo_sin_trepar = 0.5
		move_and_collide(Vector2(mirando * 40.0, 0.0))
		velocity = Vector2(mirando * 60.0, -120.0)
	elif is_on_floor() and vertical > 0.0:
		trepando = false
	sprite.flip_h = mirando < 0.0
	if vertical != 0.0:
		_reproducir("trepar")
	else:
		_poner_cuadro("trepar", 0)
	return true


func _zona_trepable() -> Rect2:
	for zona in zonas_trepables:
		if zona.grow_individual(12, 0, 12, 0).has_point(global_position + Vector2(0, -20)):
			return zona
	return Rect2()
