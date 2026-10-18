# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
extends SceneTree
## Ayudas para el bot y la prueba: pulsan los mismos botones que una persona.

var sala: SalaProto
var felipe: FelipeProto
var cuadros := 0
var limite_cuadros := 60 * 150


func cargar() -> void:
	sala = load("res://principal.tscn").instantiate()
	root.add_child(sala)
	await process_frame
	felipe = sala.felipe


func cuadro() -> void:
	cuadros += 1
	if cuadros > limite_cuadros:
		print("Se acabó el tiempo")
		quit(1)
	await physics_frame


func esperar(n: int) -> void:
	for i in n:
		await cuadro()


func segundos(s: float) -> void:
	await esperar(int(s * 60.0))


func tocar(accion: String) -> void:
	if OS.get_cmdline_user_args().has("--detalle"):
		print("        %s en (%.0f, %.0f) mirando %d estado %d" % [accion, felipe.global_position.x, felipe.global_position.y, felipe.mirando, felipe.estado])
	Input.action_press(accion)
	await cuadro()
	await cuadro()
	Input.action_release(accion)
	await cuadro()


func mantener(accion: String, s: float) -> void:
	Input.action_press(accion)
	await segundos(s)
	Input.action_release(accion)


func hasta(condicion: Callable, maximo: int) -> bool:
	for i in maximo:
		if condicion.call():
			return true
		await cuadro()
	return false


func ir_a(x: float, maximo := 400) -> void:
	for i in maximo:
		var dx := x - felipe.global_position.x
		if absf(dx) < 4.0:
			break
		var derecha := dx > 0.0
		Input.action_press("derecha" if derecha else "izquierda")
		Input.action_release("izquierda" if derecha else "derecha")
		await cuadro()
	Input.action_release("derecha")
	Input.action_release("izquierda")
	await hasta(func() -> bool: return absf(felipe.velocity.x) < 1.0, 30)


func mirar(lado: float) -> void:
	var accion := "derecha" if lado > 0.0 else "izquierda"
	Input.action_press(accion)
	await cuadro()
	Input.action_release(accion)
	await esperar(6)


## Salta (doble si hace falta) hacia x y espera a quedar parado.
func saltar_a(x: float, doble: bool) -> void:
	var accion := "derecha" if x > felipe.global_position.x else "izquierda"
	Input.action_press(accion)
	Input.action_press("saltar")
	await esperar(14)
	Input.action_release("saltar")
	if doble:
		await hasta(func() -> bool: return felipe.velocity.y > -60.0, 40)
		Input.action_press("saltar")
		await esperar(12)
		Input.action_release("saltar")
	for i in 120:
		if absf(felipe.global_position.x - x) < 6.0:
			Input.action_release(accion)
		if felipe.is_on_floor() and i > 4:
			break
		await cuadro()
	Input.action_release(accion)
	await esperar(8)
