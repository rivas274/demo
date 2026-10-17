class_name Felipe
extends CharacterBody2D
## Controlador de Felipe: movimiento de plataformas con sensación moderna
## (margen de salto, salto recordado, altura variable, doble salto, zoomies)
## y efectos de caricatura (estirar, aplastar y aterrizar con las patas delanteras).

signal aterrizo(fuerza: float)

enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO }

const ESCALA_SPRITE := 0.5

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
var _efecto: Tween

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	sprite.sprite_frames = AnimacionesFelipe.crear()
	sprite.scale = Vector2.ONE * ESCALA_SPRITE
	sprite.animation_finished.connect(_al_terminar_animacion)
	sprite.play("quieto")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("mover_izquierda", "mover_derecha")
	_tiempo_salto_pedido += delta
	_espera_zoomies = maxf(0.0, _espera_zoomies - delta)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0

	match estado:
		Estado.ZOOMIES:
			_actualizar_zoomies(delta)
		Estado.ZARPAZO, Estado.COMIENDO:
			_frenar(delta)
			_aplicar_gravedad(delta)
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
		_estirar(Vector2(0.8, 1.25), 0.18)
	elif tiene_doble_salto:
		tiene_doble_salto = false
		_saltar(velocidad_doble_salto)
		_inclinar(-0.35, 0.35)


func _saltar(fuerza: float) -> void:
	velocity.y = fuerza
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
		if estado == Estado.SUELO:
			estado = Estado.AIRE


## Un gato aterriza primero con las patas delanteras: llega inclinado con la nariz
## hacia abajo, se endereza sobre ellas y después se aplasta.
func _aterrizar() -> void:
	var fuerza := clampf(_velocidad_al_caer / caida_maxima, 0.0, 1.0)
	if estado == Estado.AIRE:
		estado = Estado.SUELO
	aterrizo.emit(fuerza)
	if _efecto:
		_efecto.kill()
	_efecto = create_tween()
	_efecto.tween_property(sprite, "rotation", 0.0, 0.08).from(0.3 * mirando * fuerza)
	var base := Vector2.ONE * ESCALA_SPRITE
	_efecto.tween_property(sprite, "scale", base * Vector2(1.0 + 0.3 * fuerza, 1.0 - 0.3 * fuerza), 0.05)
	_efecto.tween_property(sprite, "scale", base, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _actualizar_animacion(direccion: float) -> void:
	sprite.flip_h = mirando < 0.0
	if estado in [Estado.ZARPAZO, Estado.COMIENDO]:
		return
	if estado == Estado.ZOOMIES:
		_reproducir("correr")
	elif not is_on_floor():
		sprite.animation = "saltar"
		# Cuadro según la fase: subir, pausa arriba, caer buscando el suelo.
		sprite.frame = 2 if velocity.y < -60.0 else (3 if velocity.y < 60.0 else 2)
		if velocity.y > 60.0 and not (_efecto and _efecto.is_running()):
			sprite.rotation = lerpf(sprite.rotation, 0.3 * mirando, 0.15)
	elif absf(velocity.x) > velocidad_caminar + 5.0:
		_reproducir("correr")
	elif direccion != 0.0:
		_reproducir("caminar")
	else:
		_reproducir("quieto")


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
