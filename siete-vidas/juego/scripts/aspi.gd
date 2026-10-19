class_name Aspi
extends CharacterBody2D
## A.S.P.I., la aspiradora robot de Valeria: patrulla el piso, persigue a Felipe si lo ve cerca
## y le quita un corazón al tocarlo. Tres zarpazos la apagan. Arte provisional dibujado con código.
## Escala de gato: más grande que una aspiradora real (72 × 26 px de cuerpo).

const ANCHO := 72.0
const ALTO := 26.0
const GOLPES_PARA_APAGAR := 3

## Avisa cuando la apagan (en la demo, abre la puerta del balcón).
signal apagado
## Oyó maullar a Felipe (en la pelea gira hacia él: "¿Gato detectado?").
signal oyo_maullido(felipe: Felipe)

@export var velocidad_patrulla := 40.0
@export var velocidad_persecucion := 80.0
## Distancia a la que ve a Felipe (solo si está más o menos a su altura).
@export var vision := 170.0

## Tamaño y resistencia (el ratón de cuerda hereda de A.S.P.I. y los cambia).
var ancho := ANCHO
var alto := ALTO
var golpes_para_apagar := GOLPES_PARA_APAGAR
var limite_izquierdo: float
var limite_derecho: float
## La jefa solo recibe zarpazos mientras está aturdida (algo le cayó encima).
var necesita_aturdir := false
## En la primera fase de la pelea tiene escudo: todo zarpazo rebota.
var invulnerable := false
## No hace daño al tocarla (por ejemplo, detenida con el depósito lleno).
var inofensiva := false
## Imagen que se dibuja (con el depósito lleno, "aspi_llena": la tapa abierta).
var arte := "aspi"
## Se queda quieta (por ejemplo, mientras aspira).
var quieta := false
## Si no es INF, va hasta esa x sin perseguir a nadie (por ejemplo, a limpiar una mancha).
var destino := INF
var golpes := 0
var apagada := false
var persiguiendo := false
## Anticipación de un ataque: luz que parpadea (roja: embestida; amarilla: soplido) y vibración.
var luz_aviso := Color(0, 0, 0, 0)
var vibrando := false

var _direccion := 1.0
var _tiempo_golpe := 0.0
var _felipe: Felipe
var _tiempo_aturdida := 0.0


func _init(izquierda: float, derecha: float) -> void:
	limite_izquierdo = izquierda
	limite_derecho = derecha
	name = "ASPI"


func _ready() -> void:
	add_to_group("enemigos")
	add_to_group(Felipe.GRUPO_OYENTES)
	# Choca con el piso y los muebles sólidos, pero no con Felipe (el daño se calcula por distancia).
	collision_layer = 0
	set_collision_layer_value(4, true)
	collision_mask = 1
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = Vector2(ancho, alto)
	forma.shape = caja
	forma.position = Vector2(0, -alto / 2.0)
	add_child(forma)
	_felipe = get_tree().get_first_node_in_group("felipe")


func _physics_process(delta: float) -> void:
	velocity.y += 980.0 * delta
	_tiempo_golpe = maxf(0.0, _tiempo_golpe - delta)
	_tiempo_aturdida = maxf(0.0, _tiempo_aturdida - delta)
	if apagada or _tiempo_aturdida > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
		move_and_slide()
		return
	var distancia := _felipe.global_position - global_position if _felipe else Vector2.INF
	# Agachado (por ejemplo, debajo de la cama), Felipe se esconde: no lo ve.
	persiguiendo = absf(distancia.x) < vision and absf(distancia.y) < 30.0 and _felipe.estado != Felipe.Estado.DESMAYADO and not _felipe.agachado
	if persiguiendo:
		_direccion = signf(distancia.x) if distancia.x != 0.0 else _direccion
	elif global_position.x <= limite_izquierdo:
		_direccion = 1.0
	elif global_position.x >= limite_derecho:
		_direccion = -1.0
	if destino != INF:
		var falta := destino - global_position.x
		_direccion = signf(falta) if absf(falta) > 1.0 else _direccion
		velocity.x = 0.0 if absf(falta) < 4.0 else signf(falta) * velocidad_persecucion
	elif quieta:
		velocity.x = 0.0
	elif _tiempo_golpe <= 0.0:
		velocity.x = _direccion * (velocidad_persecucion if persiguiendo else velocidad_patrulla)
	move_and_slide()
	if is_on_wall():
		_direccion = -_direccion
	if _felipe and not inofensiva and absf(distancia.x) < (ancho / 2.0 + 18.0) and distancia.y > -30.0 and distancia.y < 8.0:
		_felipe.recibir_dano(1, global_position.x)
	queue_redraw()


func oir_maullido(felipe: Felipe) -> void:
	oyo_maullido.emit(felipe)


func aturdir(segundos: float) -> void:
	if apagada:
		return
	_tiempo_aturdida = segundos
	queue_redraw()


func esta_aturdida() -> bool:
	return _tiempo_aturdida > 0.0


func recibir_zarpazo(felipe: Felipe) -> void:
	if apagada:
		return
	if invulnerable or (necesita_aturdir and _tiempo_aturdida <= 0.0):
		# Sin aturdir, el zarpazo rebota en la carcasa.
		_tiempo_golpe = 0.15
		velocity.x = felipe.mirando * 60.0
		return
	golpes += 1
	_tiempo_golpe = 0.3
	velocity.x = felipe.mirando * 160.0
	if golpes >= golpes_para_apagar:
		apagada = true
		apagado.emit()
	queue_redraw()


func _draw() -> void:
	# El ratón de cuerda hereda de A.S.P.I. pero tiene su propio dibujo.
	var temblor := Vector2(1 if vibrando and Time.get_ticks_msec() % 80 < 40 else 0, 0)
	draw_set_transform(temblor)
	if not ArteNivel.dibujar(self, arte, 0.0, 1.0, false, Color(0.6, 0.6, 0.62) if apagada else Color.WHITE):
		var cuerpo := Color("3a3d44") if not apagada else Color("6a6d72")
		draw_rect(Rect2(-ancho / 2.0 + 3.0, -alto, ancho - 6.0, alto), cuerpo)
		draw_circle(Vector2(-ANCHO / 2.0 + 4.0, -ALTO / 2.0), ALTO / 2.0, cuerpo)
		draw_circle(Vector2(ANCHO / 2.0 - 4.0, -ALTO / 2.0), ALTO / 2.0, cuerpo)
	# Luz de estado: verde patrullando, roja persiguiendo, apagada sin luz.
	var luz := Color("e0483b") if persiguiendo else Color("5fd18a")
	if apagada:
		luz = Color("2a2a2a")
	elif luz_aviso.a > 0.0:
		luz = luz_aviso if Time.get_ticks_msec() % 160 < 80 else Color(1, 1, 1)
		draw_circle(Vector2(_direccion * 18.0, -40.0), 7.0, Color(luz_aviso, 0.35))
	draw_circle(Vector2(_direccion * 18.0, -40.0), 3.0, luz)
	draw_set_transform(Vector2.ZERO)
	if _tiempo_aturdida > 0.0:
		for i in 3:
			var angulo := Time.get_ticks_msec() * 0.006 + i * TAU / 3.0
			draw_circle(Vector2(cos(angulo) * 22.0, -54.0 + sin(angulo) * 4.0), 3.0, Color("f2d36b"))
	if _tiempo_golpe > 0.0:
		draw_rect(Rect2(-38.0, -47.0, 76.0, 48.0), Color(1, 1, 1, 0.5))
