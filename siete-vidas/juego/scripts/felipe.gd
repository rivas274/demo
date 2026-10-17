class_name Felipe
extends CharacterBody2D
## Controlador de Felipe: movimiento de plataformas con sensación moderna
## (margen de salto, salto recordado, altura variable, doble salto, zoomies)
## y efectos de caricatura (estirar, aplastar y aterrizar con las patas delanteras).

signal aterrizo(fuerza: float)

enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO, ATERRIZANDO }

const ESCALA_SPRITE := 0.5
## Cuadros de la hoja "saltar" para cada fase (los mismos de la ficha de concepto).
## El cuadro 4 viene inclinado en diagonal y se ve raro: no se usa.
const CUADRO_AGACHADO := 1
const CUADRO_SUBIENDO := 2
const CUADRO_ARRIBA := 3
const CUADRO_ATERRIZAJE := 5
const CUADRO_ASENTARSE := 6
## Cuadros de la hoja "caer": un gato cae con las patas delanteras primero.
const CUADRO_CAYENDO := 0
const CUADRO_CONTACTO := 1
const INCLINACION_DOBLE_SALTO := -0.35

@export_group("Movimiento")
@export var velocidad_caminar := 95.0
@export var velocidad_correr := 150.0
@export var aceleracion := 900.0
@export var friccion := 1100.0
@export_group("Salto")
@export var gravedad := 980.0
@export var gravedad_cayendo := 1350.0
@export var velocidad_salto := -330.0
@export var velocidad_doble_salto := -290.0
@export var caida_maxima := 420.0
@export var corte_salto := 0.45
@export var margen_salto := 0.1
@export var salto_recordado := 0.12
@export_group("Zoomies")
@export var velocidad_zoomies := 300.0
@export var duracion_zoomies := 0.18
@export var espera_zoomies := 0.45

var estado := Estado.SUELO
var mirando := 1.0
var tiene_doble_salto := true

var _tiempo_fuera_del_suelo := 0.0
var _tiempo_salto_pedido := 99.0
var _tiempo_zoomies := 0.0
var _espera_zoomies := 0.0
var _velocidad_al_caer := 0.0
var _tiempo_desde_salto := 99.0
var _tiempo_aterrizando := 0.0
var _tiempo_estela := 0.0
var _efecto: Tween

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var polvo: CPUParticles2D = $Polvo


func _ready() -> void:
	sprite.sprite_frames = AnimacionesFelipe.crear()
	sprite.scale = Vector2.ONE * ESCALA_SPRITE
	sprite.animation_finished.connect(_al_terminar_animacion)
	sprite.play("quieto")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("mover_izquierda", "mover_derecha")
	_tiempo_salto_pedido += delta
	_tiempo_desde_salto += delta
	_espera_zoomies = maxf(0.0, _espera_zoomies - delta)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0

	match estado:
		Estado.ZOOMIES:
			_actualizar_zoomies(delta)
		Estado.ZARPAZO, Estado.COMIENDO:
			_frenar(delta)
			_aplicar_gravedad(delta)
		Estado.ATERRIZANDO:
			_mover(direccion, delta)
			_aplicar_gravedad(delta)
			_intentar_saltar()
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
	move_and_slide()
	_actualizar_suelo(estaba_en_suelo, delta)
	_actualizar_animacion(direccion)
	_actualizar_estela(delta)


func _mover(direccion: float, delta: float) -> void:
	var maxima := velocidad_correr if Input.is_action_pressed("zoomies") else velocidad_caminar
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
	if is_on_floor() or _tiempo_fuera_del_suelo < margen_salto:
		_saltar(velocidad_salto)
		_soltar_polvo(10)
		# Despegue: se ve agachado un instante y sale estirado (sin retrasar el salto).
		_estirar(Vector2(0.8, 1.25), 0.2)
	elif tiene_doble_salto:
		tiene_doble_salto = false
		_saltar(velocidad_doble_salto)
		_soltar_polvo(8)
		_inclinar(INCLINACION_DOBLE_SALTO, 0.28)


func _saltar(fuerza: float) -> void:
	velocity.y = fuerza
	_tiempo_desde_salto = 0.0
	sprite.rotation = 0.0
	_tiempo_salto_pedido = 99.0
	_tiempo_fuera_del_suelo = 99.0
	estado = Estado.AIRE


func _intentar_acciones(direccion: float) -> void:
	if Input.is_action_just_pressed("zoomies") and _espera_zoomies == 0.0:
		estado = Estado.ZOOMIES
		_tiempo_zoomies = duracion_zoomies
		_espera_zoomies = espera_zoomies
		if direccion != 0.0:
			mirando = signf(direccion)
		velocity = Vector2(mirando * velocidad_zoomies, 0.0)
		_estirar(Vector2(1.3, 0.8), duracion_zoomies)
	elif Input.is_action_just_pressed("zarpazo"):
		estado = Estado.ZARPAZO
		sprite.play("zarpazo")
	elif Input.is_action_just_pressed("comer_snack") and is_on_floor():
		estado = Estado.COMIENDO
		sprite.play("comer")


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
	var base := Vector2.ONE * ESCALA_SPRITE
	_efecto.tween_property(sprite, "scale", base * Vector2(1.0 + 0.3 * fuerza, 1.0 - 0.3 * fuerza), 0.05)
	_efecto.tween_property(sprite, "scale", base, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _actualizar_animacion(direccion: float) -> void:
	sprite.flip_h = mirando < 0.0
	if estado in [Estado.ZARPAZO, Estado.COMIENDO]:
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
	elif velocity.y < -60.0:
		_poner_cuadro("saltar", CUADRO_SUBIENDO)
	elif velocity.y < 60.0:
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
	var base := Vector2.ONE * ESCALA_SPRITE
	_efecto = create_tween()
	_efecto.tween_property(sprite, "scale", base * forma, duracion * 0.3)
	_efecto.tween_property(sprite, "scale", base, duracion * 0.7)


func _inclinar(angulo: float, duracion: float) -> void:
	if _efecto:
		_efecto.kill()
	_efecto = create_tween()
	_efecto.tween_property(sprite, "rotation", angulo * mirando, duracion * 0.5)
	_efecto.tween_property(sprite, "rotation", 0.0, duracion * 0.5)
