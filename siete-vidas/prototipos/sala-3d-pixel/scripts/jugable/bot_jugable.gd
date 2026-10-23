# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Bot que juega como una persona (aprieta las mismas acciones que el teclado): camina, salta al
# cojín del sofá, araña el respaldo, sube al respaldo y a la mesa alta, tira la taza, baja con
# S + Espacio, tira el vaso de la mesita, empuja la pelota, le pide a Valeria, se come el snack
# y se queda quieto hasta que Felipe se sienta a jugar con la pelota; una tecla lo levanta.
# Uso: godot --path . res://jugable.tscn -- --bot   (con --bot-log imprime posiciones)
extends Node

var juego: Node
var _pasos: Array = []
var _i := -1
var _t := 0.0
var _total := 0.0
var _bloqueo := 0.0
var _antes := Vector3.ZERO
var _log := false


func _ready() -> void:
	_log = "--bot-log" in OS.get_cmdline_user_args()
	_pasos = [
		["esperar", 0.8],
		["ir_x", 0.3],
		["saltar", 0.3],
		["esperar_suelo"],
		["esperar", 0.3],
		["tecla", "accion"],
		["esperar_libre"],
		["esperar", 0.3],
		["saltar", 0.3],
		["esperar_suelo"],
		["esperar", 0.3],
		["ir_x", 1.1],
		["saltar_con", "mover_der", 0.35, 0.55],
		["esperar_suelo"],
		["esperar", 0.3],
		["ir_x", 1.85],
		["tecla", "accion"],
		["esperar_libre"],
		["esperar", 0.4],
		["bajar"],
		["esperar_suelo"],
		["esperar", 0.3],
		["ir_x", -0.95],
		["tecla", "accion"],
		["esperar_libre"],
		["esperar", 0.3],
		["ir_x", -2.2],
		["mantener", "mover_izq", 1.0],
		["esperar", 0.4],
		["esperar_valeria_libre"],
		["ir_valeria"],
		["tecla", "pedir"],
		["esperar_libre"],
		["esperar", 1.5],
		["ir_golosina"],
		["esperar", 0.4],
		["ir_pelota"],
		["esperar", 16.5],
		["tecla", "mover_der"],
		["esperar", 1.5],
		["fin"],
	]
	_siguiente()


func _felipe() -> CharacterBody3D:
	return juego.get("gato")


func _soltar_todo() -> void:
	for a in ["mover_izq", "mover_der", "mover_arriba", "mover_abajo", "saltar", "accion", "pedir"]:
		Input.action_release(a)


func _siguiente() -> void:
	_soltar_todo()
	_i += 1
	_t = 0.0
	_bloqueo = 0.0
	if _i < _pasos.size():
		_antes = _felipe().global_position
		if _log:
			print("[bot %.1f s] paso %d %s  felipe=%s" % [_total, _i, str(_pasos[_i]), str(_felipe().global_position)])


## Camina hasta x (el juego es de un solo plano: solo izquierda y derecha).
func _ir_a(x: float, _z := NAN, tol := 0.05) -> bool:
	var dx := x - _felipe().global_position.x
	_apretar("mover_der", dx > tol)
	_apretar("mover_izq", dx < -tol)
	return absf(dx) <= tol


func _apretar(a: String, si: bool) -> void:
	if si and not Input.is_action_pressed(a):
		Input.action_press(a)
	elif not si and Input.is_action_pressed(a):
		Input.action_release(a)


func _physics_process(delta: float) -> void:
	if _i >= _pasos.size():
		return
	_t += delta
	_total += delta
	var f := _felipe()
	var p: Array = _pasos[_i]
	if _log and int(_total * 60.0) % 60 == 0:
		var ap: AnimationPlayer = f.get("ap")
		var b: Node3D = juego.get("pelota")
		print("    t=%.0f estado=%d clip=%s pos=%s pelota=%s" % [_total, f.get("estado"), ap.current_animation, str(f.global_position.snapped(Vector3.ONE * 0.01)), str(b.global_position.snapped(Vector3.ONE * 0.01))])
	var listo := false
	# Atascado (contra un mueble): se da por llegado.
	if p[0] in ["ir_x", "ir_valeria", "ir_golosina", "ir_pelota"]:
		if (f.global_position - _antes).length() < 0.002 * 1.0:
			_bloqueo += delta
		else:
			_bloqueo = 0.0
		_antes = f.global_position
	match p[0]:
		"esperar":
			listo = _t >= p[1]
		"ir_x":
			listo = _ir_a(p[1]) or _bloqueo > 0.35
		"saltar":
			_apretar("saltar", _t < p[1])
			listo = _t > p[1] + 0.05
		"saltar_con":
			_apretar("saltar", _t < p[2])
			_apretar(p[1], _t < p[3])
			listo = _t > maxf(p[2], p[3]) + 0.05
		"bajar":
			_apretar("mover_abajo", _t < 0.3)
			_apretar("saltar", _t > 0.1 and _t < 0.2)
			listo = _t > 0.35
		"mantener":
			_apretar(p[1], _t < p[2])
			listo = _t > p[2]
		"esperar_suelo":
			listo = _t > 0.2 and f.call("en_suelo_firme")
		"esperar_libre":
			listo = _t > 0.3 and f.get("estado") == 0
		"tecla":
			_apretar(p[1], _t < 0.12)
			listo = _t > 0.15
		"esperar_valeria_libre":
			var v: Node = juego.get("valeria")
			listo = v == null or not v.get("_reaccionando") or _t > 12.0
		"ir_valeria":
			var v: Node3D = juego.get("valeria")
			if v == null:
				listo = true
			else:
				var lado := 1.0 if f.global_position.x > v.global_position.x else -1.0
				listo = _ir_a(v.global_position.x + lado * 0.7, clampf(v.global_position.z, -0.3, 0.4), 0.08) or _bloqueo > 0.5 or _t > 8.0
				if v.call("verbo", f) == "Pedir" and _t > 0.5 and (v.global_position - f.global_position).length() < 0.85:
					listo = true
		"ir_golosina":
			var gs: Array = juego.get("_golosinas")
			if gs.is_empty():
				listo = true
			else:
				var g: Node3D = gs[0]
				listo = _ir_a(g.global_position.x, g.global_position.z, 0.06) or _t > 6.0
		"ir_pelota":
			var b: Node3D = juego.get("pelota")
			var lado := -1.0 if f.global_position.x < b.global_position.x else 1.0
			listo = _ir_a(b.global_position.x + lado * 0.75, b.global_position.z - 0.05, 0.06) or _t > 8.0 or _bloqueo > 0.6
		"fin":
			listo = true
			if _log:
				print("[bot] fin en %.1f s" % _total)
	if listo:
		_siguiente()
