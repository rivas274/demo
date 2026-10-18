class_name Felipe
extends CharacterBody2D
## Controlador de Felipe: movimiento de plataformas con sensación moderna
## (margen de salto, salto recordado, altura variable, doble salto, zoomies, agacharse y gatear)
## y efectos de caricatura (estirar, aplastar y aterrizar con las patas delanteras).

signal aterrizo(fuerza: float)

enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO, ATERRIZANDO, OCIO }

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
const CUADRO_CAYENDO := 0
const CUADRO_CONTACTO := 1
const INCLINACION_DOBLE_SALTO := -0.35
## Alto de la caja de colisión de pie y agachado: agachado cabe bajo muebles de 30 cm (36 px).
const ALTO_DE_PIE := 52.0
const ALTO_AGACHADO := 28.0
## Animación "gatear" (cuadros de 256 px con el gato apoyado abajo): a esta escala mide unos 36 px de alto
## y cabe bajo un mueble de 30 cm. POSICION_AGACHADO deja las patas sobre el piso.
const ESCALA_AGACHADO := 0.4
const POSICION_AGACHADO := Vector2(0, -51)
## Capa de los muebles que se atraviesan desde abajo (agachado + saltar baja a través de ellos).
const CAPA_ATRAVESABLE := 2
## Animaciones de ocio: nombre -> [escala, posición del sprite, vueltas del ciclo antes de volver a quieto].
## Las hojas vienen de resoluciones distintas: la escala iguala el tamaño de la cabeza con Felipe de pie
## y la posición deja las patas sobre el piso.
const OCIO := {
	"acicalarse": [0.9, Vector2(0, -41), 3],
	"jugar": [0.6, Vector2(0, -55), 3],
	"vueltas": [0.72, Vector2(0, -38), 2],
}
## Bola de estambre del ocio "jugar": objeto aparte (la animación es solo Felipe) que rueda frente a él.
const BOLA_ESTAMBRE := preload("res://assets/felipe/estambre-bola.png")
const DISTANCIA_ESTAMBRE := 34.0
## Acciones que, presionadas, cuentan como "estar jugando" (cortan el ocio y reinician la espera).
const ACCIONES := ["mover_izquierda", "mover_derecha", "saltar", "zoomies", "zarpazo", "interactuar", "agacharse"]
## Distancia (horizontal, vertical) a la que el botón de acción alcanza un objeto.
const ALCANCE := Vector2(48, 40)

@export_group("Movimiento")
@export var velocidad_caminar := 120.0
@export var velocidad_correr := 190.0
@export var aceleracion := 1200.0
@export var friccion := 1450.0
@export var velocidad_gatear := 55.0
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
var _tiempo_ocio := 0.0
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
	sprite.animation_finished.connect(_al_terminar_animacion)
	sprite.play("quieto")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("mover_izquierda", "mover_derecha")
	_tiempo_salto_pedido += delta
	_tiempo_desde_salto += delta
	_espera_zoomies = maxf(0.0, _espera_zoomies - delta)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0
	_actualizar_bajada(delta)
	_actualizar_ocio(delta)
	_actualizar_agachado()

	match estado:
		Estado.ZOOMIES:
			_actualizar_zoomies(delta)
		Estado.ZARPAZO, Estado.COMIENDO, Estado.OCIO:
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
	if agachado:
		return
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


func comer() -> void:
	estado = Estado.COMIENDO
	velocity.x = 0.0
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
	var base := _escala_base()
	_efecto.tween_property(sprite, "scale", base * Vector2(1.0 + 0.3 * fuerza, 1.0 - 0.3 * fuerza), 0.05)
	_efecto.tween_property(sprite, "scale", base, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _actualizar_animacion(direccion: float) -> void:
	sprite.flip_h = mirando < 0.0
	if estado in [Estado.ZARPAZO, Estado.COMIENDO, Estado.OCIO]:
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
		# Gatea; quieto, se queda pegado al piso en el primer cuadro.
		if direccion != 0.0:
			_reproducir("gatear")
		else:
			_poner_cuadro("gatear", 0)
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
	sprite.position = POSICION_AGACHADO if valor else _posicion_sprite
	if valor:
		sprite.play("gatear")
		sprite.stop()
	# Transición rápida: un aplastón al bajar y un estirón al pararse.
	sprite.scale = _escala_base() * (Vector2(1.12, 0.85) if valor else Vector2(0.9, 1.1))
	_efecto = create_tween()
	_efecto.tween_property(sprite, "scale", _escala_base(), 0.1)


func _escala_base() -> Vector2:
	return Vector2.ONE * (ESCALA_AGACHADO if agachado else ESCALA_SPRITE)


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
	var datos: Array = OCIO[nombre]
	estado = Estado.OCIO
	if _efecto:
		_efecto.kill()
	sprite.rotation = 0.0
	sprite.scale = Vector2.ONE * datos[0]
	sprite.position = datos[1]
	sprite.play(nombre)
	if nombre == "jugar":
		_estambre = Sprite2D.new()
		_estambre.name = "Estambre"
		_estambre.texture = BOLA_ESTAMBRE
		_estambre.scale = Vector2.ONE * 0.6
		add_child(_estambre)
		_rodar_estambre()
	var frames := sprite.sprite_frames
	_tiempo_ocio = frames.get_frame_count(nombre) / frames.get_animation_speed(nombre) * datos[2]


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
