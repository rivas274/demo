class_name HaceDano
extends Node
## Pieza para lo que lastima a Felipe al tocarlo (hitbox): A.S.P.I., los ratones de cuerda y las bolas de pelo que
## escupe en la pelea (el láser del pasillo no lastima: solo se escapa). Cada cuadro mira si Felipe está dentro de su
## zona (relativa a la entidad) y le quita `dano` MEDIAS huellas (2 = 1 huella; salud de 9 huellas, 2026-10-23); Felipe
## decide el resto (la opción «Golpes», parpadeo, empujón, desmayo). Se apaga sola mientras la entidad está aturdida o
## vencida (se lo dicen con `pausar` y `apagar`); quien manda en la entidad la puede volver inofensiva con `activo = false`.

## Tocó a Felipe y le hizo daño.
signal toco(felipe: Felipe)

## Medias huellas que quita (2 = 1 huella, el golpe normal).
@export var dano := 2
## Zona rectangular, medida desde los pies de la entidad hasta los pies de Felipe: hasta `medio_ancho` px a cada lado,
## hasta `arriba` px más arriba y hasta `abajo` px más abajo.
@export var medio_ancho := 54.0
@export var arriba := 30.0
@export var abajo := 8.0
## Si es mayor que 0, la zona es un círculo de este radio alrededor de la entidad (las bolas de pelo), medido hasta el
## punto de Felipe corrido `desfase_felipe`.
@export var radio := 0.0
@export var desfase_felipe := Vector2.ZERO
## false: no lastima (A.S.P.I. detenida, el ensayo sin daño).
@export var activo := true

var _pausa := 0.0
var _apagado := false
var _felipe: Felipe


func _init() -> void:
	name = "HaceDano"


func _ready() -> void:
	_felipe = get_tree().get_first_node_in_group("felipe") as Felipe


## No lastima durante `segundos` (aturdida).
func pausar(segundos: float) -> void:
	_pausa = segundos


## No vuelve a lastimar (vencida).
func apagar() -> void:
	_apagado = true


func _physics_process(delta: float) -> void:
	_pausa = maxf(0.0, _pausa - delta)
	revisar()


## Mira si toca a Felipe ahora y, si lo toca, le hace daño. Devuelve si lo tocó. Corre sola cada cuadro; quien necesita
## el orden exacto (la pelea mueve cada bola de pelo y mira si tocó antes de ver si llegó al piso) apaga el proceso de
## la pieza y la llama a mano.
func revisar() -> bool:
	var cuerpo := get_parent() as Node2D
	if not activo or _apagado or _pausa > 0.0 or cuerpo == null or cuerpo.is_queued_for_deletion():
		return false
	if _felipe == null or not is_instance_valid(_felipe):
		_felipe = cuerpo.get_tree().get_first_node_in_group("felipe") as Felipe if cuerpo.is_inside_tree() else null
		if _felipe == null:
			return false
	var distancia := _felipe.global_position + desfase_felipe - cuerpo.global_position
	var toca := distancia.length() < radio if radio > 0.0 else absf(distancia.x) < medio_ancho and distancia.y > -arriba and distancia.y < abajo
	if toca:
		_felipe.recibir_dano(dano, cuerpo.global_position.x)
		toco.emit(_felipe)
	return toca
