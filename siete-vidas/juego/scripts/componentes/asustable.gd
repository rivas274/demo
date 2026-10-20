class_name Asustable
extends Node
## Pieza para lo que se asusta (maña futura «Intimidar», pilar 2: espanta al perro que bloquea el patio y hace que el
## gato rival suelte su comida). Todavía ninguna maña la usa: queda lista para que, cuando exista, funcione con todo lo
## que lleve esta pieza. Quien asusta llama `asustar(quien)`; la entidad decide la reacción (el ratón y A.S.P.I. huyen
## con MovimientoPatrulla.huir).

const GRUPO := "asustables"

signal asustado(quien: Node2D)

## Segundos que dura el susto.
@export var segundos := 2.0
## Si es false, no se deja asustar (un jefe en plena pelea).
@export var activo := true


func _init() -> void:
	name = "Asustable"


func _ready() -> void:
	add_to_group(GRUPO)


## Asusta a quien lleva la pieza. Devuelve si se asustó.
func asustar(quien: Node2D) -> bool:
	if not activo:
		return false
	asustado.emit(quien)
	return true
