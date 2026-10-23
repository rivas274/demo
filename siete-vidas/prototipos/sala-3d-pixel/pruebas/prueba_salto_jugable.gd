# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Prueba del salto en la sala jugable (con la física de verdad y el botón apretado como una
# persona):
# 1. la altura del salto (v²/2g) es la del juego 2D, unos 0,66 m;
# 2. desde el piso, pegado al sofá, Felipe cae sobre el cojín (45 cm);
# 3. desde el piso, bajo la mesa alta (75 cm), no llega ni quieto ni con carrera: vuelve al piso;
# 4. desde el sofá (cojín y luego el respaldo, 85 cm) sí alcanza la mesa alta;
# 5. S + Espacio baja de la mesa al piso.
# El juego es de un solo plano (2,5D): Felipe nunca sale de z = Z_PLANO.
# Uso: godot --headless --path . --script res://pruebas/prueba_salto_jugable.gd
extends SceneTree

var _fallas := 0


func _init() -> void:
	_correr.call_deferred()


func _ok(cond: bool, texto: String) -> void:
	print(("  OK    " if cond else "  FALLA ") + texto)
	if not cond:
		_fallas += 1


func _esperar(n: int) -> void:
	for i in n:
		await physics_frame


func _saltar(f: CharacterBody3D, pos: Vector3, tecla := "", cuadros_tecla := 40) -> void:
	f.global_position = pos
	f.velocity = Vector3.ZERO
	await _esperar(30)
	f.set("altura_max", f.global_position.y)
	Input.action_press("saltar")
	if tecla != "":
		Input.action_press(tecla)
	for i in 120:
		await physics_frame
		if i == 20:
			Input.action_release("saltar")
		if i == cuadros_tecla and tecla != "":
			Input.action_release(tecla)
	Input.action_release("saltar")
	if tecla != "":
		Input.action_release(tecla)
	await _esperar(30)


func _correr() -> void:
	var escena: Node = load("res://jugable.tscn").instantiate()
	escena.set("con_valeria", false)
	root.add_child(escena)
	await _esperar(20)
	var f: CharacterBody3D = escena.get("gato")
	var v: float = f.get("velocidad_salto")
	var g: float = f.get("gravedad")
	var alto := v * v / (2.0 * g)
	print("Prueba del salto (sala jugable)")
	_ok(absf(alto - 0.66) < 0.02, "altura del salto %.3f m (juego 2D: 80 px = 0,66 m)" % alto)
	var mesa: float = escena.get("MESA_ALTO")
	_ok(alto < mesa, "la mesa alta (%.2f m) queda más alta que el salto" % mesa)

	var zp: float = escena.get("Z_PLANO")
	await _saltar(f, Vector3(0.4, 0.0, zp))
	var y := f.global_position.y
	_ok(y > 0.38 and y < 0.48 and f.is_on_floor(), "desde el piso cae sobre el cojín del sofá (pies a %.3f m)" % y)

	await _saltar(f, Vector3(1.7, 0.0, zp))
	_ok(f.get("altura_max") < mesa - 0.05, "bajo la mesa alta, los pies suben hasta %.3f m (< %.2f)" % [f.get("altura_max"), mesa])
	_ok(f.global_position.y < 0.05, "y vuelve al piso (pies a %.3f m)" % f.global_position.y)

	await _saltar(f, Vector3(2.4, 0.0, zp), "mover_izq", 60)
	_ok(f.global_position.y < 0.05, "con carrera hacia la mesa tampoco sube (pies a %.3f m)" % f.global_position.y)

	await _saltar(f, Vector3(0.9, 0.43, zp))
	var y_resp := f.global_position.y
	await _saltar(f, Vector3(1.0, f.global_position.y, zp), "mover_der", 75)
	y = f.global_position.y
	_ok(y_resp > 0.8 and absf(y - mesa) < 0.03 and f.global_position.x > 1.45, "desde el sofá (cojín, respaldo a %.2f m) sí alcanza la mesa alta (pies a %.3f m, x %.2f)" % [y_resp, y, f.global_position.x])

	Input.action_press("mover_abajo")
	await _esperar(5)
	Input.action_press("saltar")
	await _esperar(5)
	Input.action_release("saltar")
	Input.action_release("mover_abajo")
	await _esperar(60)
	_ok(f.global_position.y < 0.05, "S + Espacio baja de la mesa al piso (pies a %.3f m)" % f.global_position.y)
	_ok(absf(f.global_position.z - zp) < 0.001, "Felipe nunca salió de su plano (z = %.3f)" % f.global_position.z)

	print("RESULTADO: %s (%d fallas)" % ["PASA" if _fallas == 0 else "FALLA", _fallas])
	quit(1 if _fallas > 0 else 0)
