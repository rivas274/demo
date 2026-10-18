# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name FelipeProto
extends CharacterBody2D
## Felipe simplificado (copiado de felipe.gd del juego): caminar, correr, saltar y doble salto,
## más las travesuras del prototipo: acción (tirar, arañar, comer), maullar, intimidar y ronronear.
## El efecto de la acción sale en el cuadro de impacto (frame_changed), no al apretar.

## La pata toca algo (cuadro de impacto). La sala lo usa para el golpe chico.
signal impacto(objeto: Node2D, tipo: String)
## Boca abierta del maullido (posición en el mundo).
signal maullo(boca: Vector2)
## Punto máximo del lomo erizado (centro de Felipe).
signal intimido(centro: Vector2)
signal sonido(nombre: String)

enum Estado { SUELO, AIRE, ACCION, MAULLANDO, INTIMIDANDO, RONRONEANDO }

const ESCALA_SPRITE := 0.72
const DEFORMACION_MAXIMA := 0.08
const POSICION_SPRITE := Vector2(0, -36)
## Cuadro de la hoja "zarpazo" en que la pata llega adelante (revisión 2026-10-18, B5).
const CUADRO_IMPACTO_ZARPAZO := 4
## Cuadro de la hoja "comer" en que la lengua llega al plato.
const CUADRO_IMPACTO_COMER := 3
## Pose del maullido: cuadro 1 de "comer" (boca abierta, ojos cerrados). No hay hoja de maullar.
const CUADRO_MAULLIDO := 1
## La boca en ese cuadro, desde los pies, mirando a la derecha (medido en la hoja: 76, 71).
const BOCA := Vector2(17, -23)
## Saltos del juego (cuadros sueltos).
const CUADRO_SUBIENDO := 2
const CUADRO_ARRIBA := 3
const CUADRO_CAYENDO := 3
## Distancia (horizontal, vertical) a la que la acción alcanza algo, como en el juego.
const ALCANCE := Vector2(48, 40)

@export_group("Movimiento")
@export var velocidad_caminar := 120.0
@export var velocidad_correr := 190.0
@export var aceleracion := 1200.0
@export var friccion := 1450.0
@export_group("Salto")
@export var gravedad := 1410.0
@export var gravedad_cayendo := 1940.0
@export var velocidad_salto := -475.0
@export var velocidad_doble_salto := -420.0
@export var caida_maxima := 600.0
@export var corte_salto := 0.45
@export var margen_salto := 0.1
@export var salto_recordado := 0.12
@export_group("Travesuras")
## Duración de la pose de maullido.
@export var duracion_maullido := 0.75
## Duración del lomo erizado.
@export var duracion_intimidar := 1.0
## Arañazos seguidos por cada pulsación sobre el sofá.
@export var aranazos_por_accion := 2
## Distancia a la que Felipe se para antes de tirar algo (si está más cerca, da un pasito atrás
## para que la pata llegue al objeto en el cuadro de impacto en vez de taparlo con el pecho).
@export var distancia_tirar := 34.0

var estado := Estado.SUELO
var mirando := 1.0
var tiene_doble_salto := true
var ronroneando := false
## Último cuadro de impacto aplicado (para la prueba): [animación, cuadro].
var ultimo_impacto: Array = []

var _tiempo_fuera_del_suelo := 0.0
var _tiempo_salto_pedido := 99.0
var _tiempo_desde_salto := 99.0
var _tiempo_pose := 0.0
var _objeto_pendiente: Node2D
var _tipo_pendiente := ""
var _repeticiones := 0
var _pico_avisado := false
var _efecto: Tween

var sprite: AnimatedSprite2D
var cuerpo: CollisionShape2D
var polvo: CPUParticles2D
var erizo: Erizo


func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "Sprite"
	sprite.sprite_frames = AnimacionesProto.crear()
	sprite.scale = Vector2.ONE * ESCALA_SPRITE
	sprite.position = POSICION_SPRITE
	add_child(sprite)
	cuerpo = CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(36, 56)
	cuerpo.shape = caja
	cuerpo.position = Vector2(0, -28)
	add_child(cuerpo)
	polvo = CPUParticles2D.new()
	polvo.emitting = false
	polvo.one_shot = true
	polvo.amount = 10
	polvo.lifetime = 0.4
	polvo.explosiveness = 1.0
	polvo.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	polvo.emission_rect_extents = Vector2(17, 1)
	polvo.direction = Vector2(0, -1)
	polvo.spread = 80.0
	polvo.gravity = Vector2(0, 140)
	polvo.initial_velocity_min = 25.0
	polvo.initial_velocity_max = 65.0
	polvo.scale_amount_min = 2.0
	polvo.scale_amount_max = 3.0
	polvo.color = Color(0.88, 0.84, 0.79, 0.8)
	add_child(polvo)
	erizo = Erizo.new()
	erizo.position = POSICION_SPRITE
	add_child(erizo)
	erizo.preparar(sprite.sprite_frames.get_frame_texture("quieto", 0), ESCALA_SPRITE)
	floor_snap_length = 4.0
	sprite.frame_changed.connect(_al_cambiar_cuadro)
	sprite.animation_finished.connect(_al_terminar_animacion)
	sprite.play("quieto")


func _physics_process(delta: float) -> void:
	var direccion := Input.get_axis("izquierda", "derecha")
	_tiempo_salto_pedido += delta
	_tiempo_desde_salto += delta
	if Input.is_action_just_pressed("saltar"):
		_tiempo_salto_pedido = 0.0
	match estado:
		Estado.ACCION:
			_frenar(delta)
		Estado.MAULLANDO:
			_frenar(delta)
			_actualizar_maullido(delta)
		Estado.INTIMIDANDO:
			_frenar(delta)
			_actualizar_intimidar(delta)
		Estado.RONRONEANDO:
			_frenar(delta)
			if not Input.is_action_pressed("ronronear") or not is_on_floor():
				_dejar_de_ronronear()
		_:
			_mover(direccion, delta)
			_intentar_saltar()
			_intentar_acciones()
	_aplicar_gravedad(delta)
	var estaba_en_suelo := is_on_floor()
	var caida := velocity.y
	move_and_slide()
	if is_on_floor():
		_tiempo_fuera_del_suelo = 0.0
		tiene_doble_salto = true
		if not estaba_en_suelo:
			if estado == Estado.AIRE:
				estado = Estado.SUELO
			if caida > 300.0:
				_soltar_polvo(10)
			_estirar(Vector2(1.0 + DEFORMACION_MAXIMA * 0.8, 1.0 - DEFORMACION_MAXIMA * 0.8), 0.18)
	else:
		_tiempo_fuera_del_suelo += delta
		if estado == Estado.SUELO:
			estado = Estado.AIRE
	_actualizar_animacion(direccion)


func _mover(direccion: float, delta: float) -> void:
	var maxima := velocidad_correr if Input.is_action_pressed("correr") else velocidad_caminar
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
	if velocity.y < 0.0 and Input.is_action_just_released("saltar"):
		velocity.y *= corte_salto


func _intentar_saltar() -> void:
	if _tiempo_salto_pedido > salto_recordado:
		return
	if is_on_floor() or _tiempo_fuera_del_suelo < margen_salto:
		_saltar(velocidad_salto)
		_soltar_polvo(8)
		_estirar(Vector2(0.94, 1.06), 0.2)
	elif tiene_doble_salto:
		tiene_doble_salto = false
		_saltar(velocidad_doble_salto)
		_soltar_polvo(6)


func _saltar(fuerza: float) -> void:
	sonido.emit("salto")
	velocity.y = fuerza
	_tiempo_desde_salto = 0.0
	_tiempo_salto_pedido = 99.0
	_tiempo_fuera_del_suelo = 99.0
	estado = Estado.AIRE


func _intentar_acciones() -> void:
	if not is_on_floor():
		return
	if Input.is_action_just_pressed("accion"):
		var objeto := objeto_cercano()
		if objeto:
			_empezar_accion(objeto)
	elif Input.is_action_just_pressed("maullar"):
		_empezar_maullido()
	elif Input.is_action_just_pressed("intimidar"):
		_empezar_intimidar()
	elif Input.is_action_pressed("ronronear"):
		_empezar_ronroneo()


## Lo interactuable más cercano al alcance. El sofá tiene penalización: si hay algo que tirar, gana tirar.
func objeto_cercano() -> Node2D:
	var mejor: Node2D = null
	var mejor_puntaje := INF
	for objeto: Node2D in get_tree().get_nodes_in_group("interactuables"):
		if objeto.call("accion_disponible") == "":
			continue
		var punto: Vector2 = objeto.call("punto_para", global_position)
		var distancia := punto - global_position
		if absf(distancia.x) > ALCANCE.x or absf(distancia.y) > ALCANCE.y:
			continue
		var puntaje := absf(distancia.x) + absf(distancia.y) * 0.5 + float(objeto.get("prioridad"))
		if puntaje < mejor_puntaje:
			mejor_puntaje = puntaje
			mejor = objeto
	return mejor


func _empezar_accion(objeto: Node2D) -> void:
	var punto: Vector2 = objeto.call("punto_para", global_position)
	if absf(punto.x - global_position.x) > 4.0:
		mirando = signf(punto.x - global_position.x)
	_objeto_pendiente = objeto
	_tipo_pendiente = objeto.call("accion_disponible")
	estado = Estado.ACCION
	velocity.x = 0.0
	sprite.flip_h = mirando < 0.0
	if _tipo_pendiente == "tirar" and absf(punto.x - global_position.x) < distancia_tirar:
		create_tween().tween_property(self, "global_position:x", punto.x - mirando * distancia_tirar, 0.1)
	if _tipo_pendiente == "comer":
		_repeticiones = 0
		_reiniciar("comer")
	else:
		_repeticiones = aranazos_por_accion - 1 if _tipo_pendiente == "arañar" else 0
		_reiniciar("zarpazo")


func _reiniciar(nombre: String) -> void:
	sprite.stop()
	sprite.animation = nombre
	sprite.frame = 0
	sprite.play(nombre)


func _al_cambiar_cuadro() -> void:
	if estado != Estado.ACCION or not is_instance_valid(_objeto_pendiente):
		return
	if sprite.animation == "zarpazo" and sprite.frame == 2:
		sonido.emit("zarpazo")
	var cuadro := CUADRO_IMPACTO_COMER if sprite.animation == "comer" else CUADRO_IMPACTO_ZARPAZO
	if sprite.frame == cuadro:
		ultimo_impacto = [String(sprite.animation), sprite.frame]
		_objeto_pendiente.call("al_impacto", self)
		impacto.emit(_objeto_pendiente, _tipo_pendiente)


func _al_terminar_animacion() -> void:
	if estado != Estado.ACCION:
		return
	if _repeticiones > 0 and is_instance_valid(_objeto_pendiente):
		_repeticiones -= 1
		_reiniciar(sprite.animation)
		return
	_objeto_pendiente = null
	estado = Estado.SUELO if is_on_floor() else Estado.AIRE


## Maullar: pose de boca abierta (cuadro de "comer"), se estira hacia arriba (≤8 %) y salen ondas de la boca.
func _empezar_maullido() -> void:
	estado = Estado.MAULLANDO
	_tiempo_pose = duracion_maullido
	_pico_avisado = false
	velocity.x = 0.0
	_poner_cuadro("quieto", 0)
	_estirar(Vector2(0.95, 1.08), duracion_maullido * 0.8)


func _actualizar_maullido(delta: float) -> void:
	_tiempo_pose -= delta
	var t := duracion_maullido - _tiempo_pose
	if t > 0.08 and not _pico_avisado:
		_pico_avisado = true
		_poner_cuadro("comer", CUADRO_MAULLIDO)
		maullo.emit(global_position + Vector2(BOCA.x * mirando, BOCA.y))
	if _tiempo_pose < 0.12:
		_poner_cuadro("quieto", 0)
	if _tiempo_pose <= 0.0:
		estado = Estado.SUELO


## Intimidar: lomo arqueado (estirar hacia arriba y ancho ≤8 %, inclinado hacia atrás), pelo erizado y temblor.
func _empezar_intimidar() -> void:
	estado = Estado.INTIMIDANDO
	_tiempo_pose = duracion_intimidar
	_pico_avisado = false
	velocity.x = 0.0
	_poner_cuadro("quieto", 0)
	if _efecto:
		_efecto.kill()
	var base := Vector2.ONE * ESCALA_SPRITE
	_efecto = create_tween()
	_efecto.tween_property(sprite, "scale", base * _limitar(Vector2(1.05, 1.08)), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_efecto.tween_interval(duracion_intimidar - 0.3)
	_efecto.tween_property(sprite, "scale", base, 0.18)
	erizo.erizar(duracion_intimidar, mirando)


func _actualizar_intimidar(delta: float) -> void:
	_tiempo_pose -= delta
	var t := duracion_intimidar - _tiempo_pose
	# Temblor de píxel entero (sin emborronar) y el lomo inclinado hacia atrás.
	var temblando := _tiempo_pose > 0.2
	sprite.position = POSICION_SPRITE + (Vector2(randi_range(-1, 1), 0) if temblando else Vector2.ZERO)
	sprite.skew = -0.1 * mirando if temblando else 0.0
	sprite.modulate = Color(1, 0.86, 0.82) if temblando and int(t * 16.0) % 2 == 0 else Color.WHITE
	if t > 0.12 and not _pico_avisado:
		_pico_avisado = true
		intimido.emit(global_position + Vector2(0, -30))
	if _tiempo_pose <= 0.0:
		sprite.position = POSICION_SPRITE
		sprite.skew = 0.0
		sprite.modulate = Color.WHITE
		estado = Estado.SUELO


func _empezar_ronroneo() -> void:
	estado = Estado.RONRONEANDO
	ronroneando = true
	velocity.x = 0.0
	sprite.play("ronronear")
	sonido.emit("ronroneo_on")


func _dejar_de_ronronear() -> void:
	ronroneando = false
	estado = Estado.SUELO if is_on_floor() else Estado.AIRE
	sonido.emit("ronroneo_off")


func _actualizar_animacion(direccion: float) -> void:
	sprite.flip_h = mirando < 0.0
	if estado in [Estado.ACCION, Estado.MAULLANDO, Estado.INTIMIDANDO, Estado.RONRONEANDO]:
		return
	if not is_on_floor():
		if velocity.y < -85.0:
			_poner_cuadro("saltar", CUADRO_SUBIENDO)
		elif velocity.y < 85.0:
			_poner_cuadro("saltar", CUADRO_ARRIBA)
		else:
			_poner_cuadro("caer", CUADRO_CAYENDO)
	elif absf(velocity.x) > velocidad_caminar + 5.0:
		_reproducir("correr")
	elif direccion != 0.0:
		_reproducir("caminar")
	else:
		_reproducir("quieto")


func _poner_cuadro(animacion: String, cuadro: int) -> void:
	if sprite.animation == animacion and sprite.frame == cuadro and not sprite.is_playing():
		return
	sprite.stop()
	sprite.animation = animacion
	sprite.frame = cuadro


func _reproducir(nombre: String) -> void:
	if sprite.animation != nombre or not sprite.is_playing():
		sprite.play(nombre)


func _soltar_polvo(cantidad: int) -> void:
	polvo.amount = maxi(cantidad, 1)
	polvo.restart()
	polvo.emitting = true


func _limitar(forma: Vector2) -> Vector2:
	return forma.clamp(Vector2.ONE * (1.0 - DEFORMACION_MAXIMA), Vector2.ONE * (1.0 + DEFORMACION_MAXIMA))


func _estirar(forma: Vector2, duracion: float) -> void:
	if _efecto:
		_efecto.kill()
	var base := Vector2.ONE * ESCALA_SPRITE
	_efecto = create_tween()
	_efecto.tween_property(sprite, "scale", base * _limitar(forma), duracion * 0.3)
	_efecto.tween_property(sprite, "scale", base, duracion * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
