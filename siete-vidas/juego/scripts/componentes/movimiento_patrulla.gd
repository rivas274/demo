class_name MovimientoPatrulla
extends Node
## Pieza de movimiento para enemigos de piso (CharacterBody2D): va y viene entre dos límites y, si ve a Felipe cerca y a
## su altura, lo persigue. La usan A.S.P.I. y el ratón de cuerda: solo cambian sus números (velocidades y visión). Mueve
## a su padre; no sabe nada de vida ni de daño (la entidad le avisa con `retroceder`, `detener`, `apagar` y `huir`).
## Quien manda en la entidad puede dejarla `quieta` o mandarla a un `destino` (A.S.P.I. va a limpiar una mancha).

@export var velocidad_patrulla := 40.0
@export var velocidad_persecucion := 80.0
## Distancia a la que ve a Felipe (solo si está más o menos a su altura); 0 = nunca persigue.
@export var vision := 170.0
@export var limite_izquierdo := -INF
@export var limite_derecho := INF
@export var gravedad := 980.0

## Se queda quieta (por ejemplo, mientras aspira).
var quieta := false
## Si no es INF, va hasta esa x sin perseguir a nadie (por ejemplo, a limpiar una mancha).
var destino := INF
var persiguiendo := false
## Hacia dónde va (1 derecha, -1 izquierda).
var direccion := 1.0
## Segundos que quedan del empujón de un zarpazo (mientras tanto no camina por su cuenta).
var retroceso := 0.0

var _detenida := 0.0
var _apagada := false
var _huyendo := 0.0
var _felipe: Felipe


func _init() -> void:
	name = "MovimientoPatrulla"


func _ready() -> void:
	_felipe = get_tree().get_first_node_in_group("felipe") as Felipe


## Un golpe la empuja: sale hacia `hacia` a `velocidad` px/s y no camina por su cuenta durante `segundos`.
func retroceder(hacia: float, velocidad: float, segundos: float) -> void:
	retroceso = segundos
	(get_parent() as CharacterBody2D).velocity.x = hacia * velocidad


## Aturdida: frena y no se mueve durante `segundos`.
func detener(segundos: float) -> void:
	_detenida = segundos


func esta_detenida() -> bool:
	return _detenida > 0.0


## Vencida: frena y no vuelve a moverse.
func apagar() -> void:
	_apagada = true


## Asustada (maña futura «Intimidar»): corre alejándose de `desde_x` durante `segundos`.
func huir(desde_x: float, segundos: float) -> void:
	_huyendo = segundos
	var cuerpo := get_parent() as Node2D
	direccion = 1.0 if cuerpo.global_position.x >= desde_x else -1.0


func _physics_process(delta: float) -> void:
	var cuerpo := get_parent() as CharacterBody2D
	cuerpo.velocity.y += gravedad * delta
	retroceso = maxf(0.0, retroceso - delta)
	_detenida = maxf(0.0, _detenida - delta)
	_huyendo = maxf(0.0, _huyendo - delta)
	if _apagada or _detenida > 0.0:
		cuerpo.velocity.x = move_toward(cuerpo.velocity.x, 0.0, 400.0 * delta)
		cuerpo.move_and_slide()
		return
	var felipe := _felipe if _felipe != null and is_instance_valid(_felipe) else null
	var distancia := felipe.global_position - cuerpo.global_position if felipe else Vector2.INF
	# Agachado (por ejemplo, debajo de la cama), Felipe se esconde: no lo ve.
	persiguiendo = _huyendo <= 0.0 and absf(distancia.x) < vision and absf(distancia.y) < 30.0 and felipe.estado != Felipe.Estado.DESMAYADO and not felipe.agachado
	if persiguiendo:
		direccion = signf(distancia.x) if distancia.x != 0.0 else direccion
	elif _huyendo > 0.0:
		pass
	elif cuerpo.global_position.x <= limite_izquierdo:
		direccion = 1.0
	elif cuerpo.global_position.x >= limite_derecho:
		direccion = -1.0
	if destino != INF:
		var falta := destino - cuerpo.global_position.x
		direccion = signf(falta) if absf(falta) > 1.0 else direccion
		cuerpo.velocity.x = 0.0 if absf(falta) < 4.0 else signf(falta) * velocidad_persecucion
	elif quieta:
		cuerpo.velocity.x = 0.0
	elif retroceso <= 0.0:
		cuerpo.velocity.x = direccion * (velocidad_persecucion if persiguiendo or _huyendo > 0.0 else velocidad_patrulla)
	cuerpo.move_and_slide()
	if cuerpo.is_on_wall():
		direccion = -direccion
