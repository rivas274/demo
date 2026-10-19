class_name OidoPuerta
extends Node2D
## Oído del otro lado de una puerta cerrada: Valeria está en la cocina (lejos en el mundo), pero oye a Felipe maullar
## junto a la puerta. Está en el grupo de los que oyen maullidos (Felipe.GRUPO_OYENTES) y avisa con `oido`.

signal oido(felipe: Felipe)


func _init() -> void:
	name = "Oido de la puerta"


func _ready() -> void:
	add_to_group(Felipe.GRUPO_OYENTES)


func oir_maullido(felipe: Felipe) -> void:
	if absf(felipe.global_position.x - global_position.x) < 140.0:
		oido.emit(felipe)
