# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# El sofá como cosa que se araña: desde el cojín (pegado al respaldo) o desde el piso (pegado
# al frente). Solo dice si Felipe está en posición y dónde va el indicador; las marcas las pone
# Felipe donde llegan sus garras.
extends Node3D

@export var x_min := -0.35
@export var x_max := 1.15
@export var alto_cojin := 0.43
## Frente del sofá y del respaldo (z).
@export var z_frente := -0.37
@export var z_respaldo := -0.96


func _ready() -> void:
	add_to_group("interactuable")


func verbo(f: Node3D) -> String:
	var p := f.global_position
	if p.x < x_min or p.x > x_max:
		return ""
	var medio_z := 0.15 + 0.12
	if absf(p.y - alto_cojin) < 0.12 and p.z < z_respaldo + medio_z + 0.1:
		return "Arañar"
	if p.y < 0.08 and p.z < z_frente + medio_z:
		return "Arañar"
	return ""


func punto_para(f: Node3D) -> Vector3:
	var p := f.global_position
	if p.y > 0.2:
		return Vector3(p.x, 0.92, z_respaldo)
	return Vector3(p.x, alto_cojin + 0.12, z_frente)


func punto() -> Vector3:
	return global_position
