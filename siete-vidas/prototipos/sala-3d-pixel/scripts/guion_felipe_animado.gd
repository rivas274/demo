# PROTOTIPO: no es código del juego.
# Guion del video de Felipe 3D animado (unos 14 s, en bucle): quieto, camina a la
# derecha, salta al cojín del sofá, se queda, baja de un salto mirando a la izquierda
# y camina de vuelta. Mueve el nodo de Felipe y elige su animación.
extends Node

const VELOCIDAD := 0.29  # m/s, a juego con el paso (caminar ×1,6)
const RITMO_PASO := 1.6

var felipe: Node3D
var x_inicio := -0.6
var x_antes_sofa := 0.55
var cojin := Vector3(0.82, 0.43, -0.55)
var z_piso := 0.3
var x_bajada := 0.40
var x_final := -0.75
var duracion := 14.2
var _t := 0.0
var _tramos: Array = []


func _ready() -> void:
	var t := 0.0
	_tramos = []
	for tramo in [
			["quieto", 0.8, Vector3(x_inicio, 0, z_piso), Vector3(x_inicio, 0, z_piso), true],
			["caminar", (x_antes_sofa - x_inicio) / VELOCIDAD, Vector3(x_inicio, 0, z_piso), Vector3(x_antes_sofa, 0, z_piso), true],
			["saltar", 1.2, Vector3(x_antes_sofa, 0, z_piso), cojin, true],
			["quieto", 1.5, cojin, cojin, true],
			["saltar", 1.2, cojin, Vector3(x_bajada, 0, z_piso), false],
			["caminar", (x_bajada - x_final) / VELOCIDAD, Vector3(x_bajada, 0, z_piso), Vector3(x_final, 0, z_piso), false],
			["quieto", 2.0, Vector3(x_final, 0, z_piso), Vector3(x_final, 0, z_piso), false]]:
		_tramos.append([t] + tramo)
		t += tramo[1]
	duracion = t
	felipe.position = Vector3(x_inicio, 0, z_piso)


func _process(delta: float) -> void:
	_t = fmod(_t + delta, duracion)
	for i in range(_tramos.size() - 1, -1, -1):
		var tr: Array = _tramos[i]
		if _t < tr[0]:
			continue
		var local: float = _t - tr[0]
		var k := clampf(local / tr[2], 0.0, 1.0)
		var desde: Vector3 = tr[3]
		var hasta: Vector3 = tr[4]
		felipe.set("mira_derecha", tr[5])
		match tr[1]:
			"quieto":
				felipe.call("reproducir", "quieto")
				felipe.position = hasta
			"caminar":
				felipe.call("reproducir", "caminar", RITMO_PASO)
				felipe.position = desde.lerp(hasta, k)
			"saltar":
				var ap: AnimationPlayer = felipe.get("ap")
				if ap.current_animation != "saltar":
					ap.play("saltar", 0.08)
					ap.speed_scale = 1.0
				var arco: Vector2 = felipe.call("arco_salto", local)
				var p := desde.lerp(hasta, arco.x)
				p.y += arco.y * 0.18
				felipe.position = p
		break
