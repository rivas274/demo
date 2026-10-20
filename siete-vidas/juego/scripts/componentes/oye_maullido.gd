class_name OyeMaullido
extends Node2D
## Pieza para quien oye maullar a Felipe (maña «Maullar», pilar 2: es llave y travesura). La llevan Valeria (mira a
## Felipe, abre la puerta), A.S.P.I. (gira hacia él: «¿Gato detectado?») y la puerta de la cocina (Valeria la oye desde
## adentro). Felipe, al maullar, avisa a todas las de su grupo que estén dentro de RADIO_MAULLIDO; la pieza solo emite
## `oyo` y quien la lleva decide qué hacer. Una maña nueva de sonido puede usar la misma pieza.

signal oyo(felipe: Felipe)

## Si es mayor que 0, solo oye cuando Felipe está a menos de esta distancia horizontal (la puerta de la cocina: 140 px).
@export var alcance_x := 0.0


func _init() -> void:
	name = "OyeMaullido"


func _ready() -> void:
	add_to_group(Felipe.GRUPO_OYENTES)


## Lo llama Felipe en el cuadro del maullido.
func oir_maullido(felipe: Felipe) -> void:
	if alcance_x > 0.0 and absf(felipe.global_position.x - global_position.x) >= alcance_x:
		return
	oyo.emit(felipe)
