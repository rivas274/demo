# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
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
		print("        %.2f s %s en (%.0f, %.0f) mirando %d estado %d" % [sala.tiempo, accion, felipe.global_position.x, felipe.global_position.y, felipe.mirando, felipe.estado])
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
	var trabado := 0
	var antes := felipe.global_position.x
	for i in maximo:
		var dx := x - felipe.global_position.x
		if absf(dx) < 4.0:
			break
		# Si choca con algo (p. ej. el brazo del sofá) y no avanza, se rinde como lo haría una persona.
		trabado = trabado + 1 if absf(felipe.global_position.x - antes) < 0.2 else 0
		antes = felipe.global_position.x
		if trabado > 12 and i > 12:
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
	for i in 14:
		if absf(felipe.global_position.x - x) < 6.0:
			Input.action_release(accion)
		await cuadro()
	Input.action_release("saltar")
	if doble:
		for i in 40:
			if felipe.velocity.y > -60.0:
				break
			if absf(felipe.global_position.x - x) < 6.0:
				Input.action_release(accion)
			await cuadro()
		Input.action_press("saltar")
		for i in 12:
			if absf(felipe.global_position.x - x) < 6.0:
				Input.action_release(accion)
			await cuadro()
		Input.action_release("saltar")
	for i in 120:
		if absf(felipe.global_position.x - x) < 6.0:
			Input.action_release(accion)
		if felipe.is_on_floor() and i > 4:
			break
		await cuadro()
	Input.action_release(accion)
	await esperar(8)


## v2: abre la agenda (Tab), la deja abierta unos segundos y la cierra.
func ver_agenda(s: float) -> void:
	await tocar("agenda")
	await segundos(s)
	await tocar("agenda")
	await esperar(10)


## v2: llega al asiento del sofá (desde el piso, saltando por encima del brazo).
func ir_al_asiento(x: float) -> void:
	if felipe.global_position.y > Sofa.ASIENTO.position.y + 10.0 or felipe.global_position.x > Sofa.BRAZO_DERECHO.end.x:
		await saltar_a(x, true)
	await ir_a(x)


## v2: se acerca a Valeria y ronronea hasta que perdona.
func ronronear_a_valeria() -> void:
	var v := sala.valeria
	if absf(v.position.x - felipe.global_position.x) > 90.0:
		var lado := signf(felipe.global_position.x - v.position.x)
		var destino := clampf(v.position.x + lado * 55.0, 30.0, 600.0)
		if felipe.global_position.y < SalaProto.SUELO - 10.0:
			await saltar_a(destino, false)
		await ir_a(destino)
	Input.action_press("ronronear")
	await hasta(func() -> bool: return v.estado == Valeria.Estado.PERDONANDO, 180)
	await segundos(0.3)
	Input.action_release("ronronear")
	await segundos(0.6)


## v2: recoge las recompensas que quedaron sueltas (salta si están en otra altura).
## No va a las que están más arriba que "altura_minima" (el alféizar se visita a propósito).
func recoger_todo(altura_minima := 150.0) -> void:
	for intento in 6:
		var objetivo: Recogible = null
		for n: Node in sala.get_children():
			if n is Recogible and not n.get("_recogido") and n.position.y >= altura_minima:
				objetivo = n
				break
		if objetivo == null:
			return
		paso("recoger %s en (%.0f, %.0f)" % [objetivo.tipo, objetivo.position.x, objetivo.position.y])
		await hasta(func() -> bool: return not is_instance_valid(objetivo) or objetivo.quieto or objetivo.get("_recogido"), 150)
		if not is_instance_valid(objetivo) or objetivo.get("_recogido"):
			continue
		var dy := objetivo.position.y - felipe.global_position.y
		if absf(dy) > 10.0:
			await saltar_a(objetivo.position.x, dy < -50.0)
		if is_instance_valid(objetivo) and not objetivo.get("_recogido"):
			await ir_a(objetivo.position.x)
		await esperar(12)


func paso(texto: String) -> void:
	if OS.get_cmdline_user_args().has("--detalle"):
		print("  -- paso %s a los %.2f s" % [texto, sala.tiempo])
