# PROTOTIPO: no es código del juego.
# Pregunta: ¿se siente bien controlar a Felipe 3D (con rig) en una sala jugable: caminar, saltar
# a los muebles, arañar, tirar cosas y pedirle a Valeria?
# Fecha: 2026-10-23
# Prueba del salto en la sala jugable (con la física de verdad y el botón apretado como una
# persona):
# 1. la altura del salto (v²/2g) es la del juego 2D, unos 0,66 m;
# 2. desde el piso, pegado al sofá, Felipe cae sobre el cojín (45 cm);
# 3. desde el piso, pegado a la mesa alta (75 cm), no llega: vuelve al piso;
# 4. desde el sofá (cojín y luego el brazo) sí alcanza la mesa alta.
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

	await _saltar(f, Vector3(0.4, 0.0, -0.2))
	var y := f.global_position.y
	_ok(y > 0.35 and y < 0.55 and f.is_on_floor(), "desde el piso cae sobre el cojín del sofá (pies a %.3f m)" % y)

	await _saltar(f, Vector3(1.7, 0.0, -0.44))
	_ok(f.get("altura_max") < mesa - 0.05, "pegado a la mesa alta, los pies suben hasta %.3f m (< %.2f)" % [f.get("altura_max"), mesa])
	_ok(f.global_position.y < 0.05, "y vuelve al piso (pies a %.3f m)" % f.global_position.y)

	await _saltar(f, Vector3(1.7, 0.0, -0.44), "mover_arriba", 60)
	_ok(f.global_position.y < 0.05, "apretando hacia la mesa tampoco sube (pies a %.3f m)" % f.global_position.y)

	await _saltar(f, Vector3(0.85, 0.43, -0.6), "mover_der", 50)
	var y_brazo := f.global_position.y
	await _saltar(f, f.global_position, "mover_der", 50)
	y = f.global_position.y
	_ok(y > 0.7 and f.global_position.x > 1.3, "desde el sofá (cojín, brazo a %.2f m) sí alcanza la mesa alta (pies a %.3f m, x %.2f)" % [y_brazo, y, f.global_position.x])

	print("RESULTADO: %s (%d fallas)" % ["PASA" if _fallas == 0 else "FALLA", _fallas])
	quit(1 if _fallas > 0 else 0)
