extends SceneTree
## Partida completa jugada por un bot con los mismos botones que una persona: título, tutorial, cocina, cortina,
## atajo del dormitorio, pelea con A.S.P.I. y balcón. Sirve como prueba de que el nivel se puede terminar
## y para grabar el video del gameplay:
##   godot --headless --path siete-vidas/juego --script res://pruebas/partida.gd
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --write-movie partida.avi --fixed-fps 60 --script res://pruebas/partida.gd
## Termina con código 0 si llega a la pantalla final.

const LIMITE_CUADROS := 60 * 240

var sala: Sala
var felipe: Felipe
var _cuadros := 0
var _pasos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/apartamento.tscn").instantiate()
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	# Título e introducción.
	await _esperar(100)
	await _tocar("ui_accept")
	await _esperar(150)
	await _tocar("ui_accept")
	await _esperar(150)
	_paso("Título e introducción")

	# Sala: sofá, mesa y vaso.
	await _ir_a(220)
	await _subir_a(380, Sala.SUELO - 54, false)
	await _ir_a(470)
	await _subir_a(650, Sala.SUELO - 91, true)
	await _ir_a(655)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(70)
	_paso("Tira el vaso" + (" (logro)" if "La Gravedad Funciona" in sala.logros else ""))
	# Juguetes: banco y salto largo.
	await _ir_a(738)
	await _subir_a(905, Sala.SUELO - 79, true, true)
	await _ir_a(925)
	await _saltar(1.0, false)
	_paso("Salta los juguetes")
	# Aparador: pasar agachado.
	Input.action_press("agacharse")
	await _ir_a(1185)
	Input.action_release("agacharse")
	await _esperar(20)
	_paso("Pasa agachado bajo el aparador")
	# Ratón de cuerda.
	await _cazar_raton(1180, 1395)
	await _subir_a(1450, Sala.SUELO - 24, false)
	await _esperar(50)
	_paso("Caja de arena")

	# Cocina: mesón con ratones y cortina.
	await _ir_a(1915)
	await _subir_a(1990, Sala.SUELO - 109, true)
	await _cazar_raton(1965, 2160)
	await _ir_a(2150)
	await _ir_a(2245)
	Input.action_press("mover_arriba")
	await _hasta(func() -> bool: return felipe.global_position.y <= Sala.PISO_ALTO + 1.0 and felipe.is_on_floor(), 400)
	Input.action_release("mover_arriba")
	_paso("Trepa la cortina (y = %.0f)" % felipe.global_position.y)

	# Dormitorio: por encima de la cama hasta la puerta y el atajo.
	await _subir_a(2150, Sala.PISO_ALTO - 66, false)
	await _ir_a(1985)
	await _saltar(-1.0, false, 1935)
	await _ir_a(1935)
	await _esperar(20)
	felipe.mirando = -1.0
	await _tocar("interactuar")
	await _esperar(40)
	_paso("Abre el atajo" + (" (logro)" if "Atajo de Gato" in sala.logros else ""))
	await _subir_a(2000, Sala.PISO_ALTO - 66, false)
	await _ir_a(2200)
	await _subir_a(2320, Sala.PISO_ALTO - 97, true)
	await _subir_a(2415, Sala.PISO_ALTO - 218, true)
	await _ir_a(2470)
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.PISO_ALTO - 2.0, 120)

	# Pelea con A.S.P.I.
	var batalla := sala.batalla
	Input.action_press("mover_derecha")
	await _hasta(func() -> bool: return batalla.fase != BatallaAspi.Fase.ESPERANDO, 240)
	Input.action_release("mover_derecha")
	await _hasta(func() -> bool: return batalla.fase != BatallaAspi.Fase.ENTRADA, 400)
	_paso("Entrada de la jefa")
	# Se aleja corriendo de la jefa y se aferra agachado mientras aspira.
	await _ir_a(2488, 120)
	Input.action_press("agacharse")
	await _hasta(func() -> bool: return batalla.fase != BatallaAspi.Fase.SUCCION, 1400)
	Input.action_release("agacharse")
	_paso("Aguanta la succión agachado")
	while batalla.fase in [BatallaAspi.Fase.ATURDIR, BatallaAspi.Fase.FURIA] and _cuadros < LIMITE_CUADROS:
		await _ronda_contra_aspi()
	_paso("Apaga a A.S.P.I." if batalla.fase == BatallaAspi.Fase.FIN else "No pudo con A.S.P.I.")
	await _esperar(120)

	# Balcón.
	await _ir_a(Sala.SALIDA + 40, 400)
	await _hasta(func() -> bool: return sala.pantallas.modo == Pantallas.Modo.FIN, 300)
	await _esperar(150)
	var termino := sala.pantallas.modo == Pantallas.Modo.FIN
	_paso("Pantalla final" if termino else "No llegó al final")
	print("Logros: %s · calcetines %d · corazones %d · vidas %d · %.0f s" % [", ".join(sala.logros), sala.calcetines, felipe.corazones, felipe.vidas, _cuadros / 60.0])
	quit(0 if termino else 1)


## Una ronda: sube a la repisa, tira una maceta cuando A.S.P.I. pasa por debajo, baja y le da zarpazos;
## en furia salta las bolas de pelo mientras tanto.
func _ronda_contra_aspi() -> void:
	var aspi := sala.batalla.aspi
	if felipe.global_position.y > Sala.PISO_ALTO - 100.0:
		await _ir_a(2505, 600, true)
		await _subir_a(2550, Sala.PISO_ALTO - 55, false)
		await _subir_a(2625, Sala.PISO_ALTO - 160, true)
	_paso("Ronda contra A.S.P.I. (golpes %d)" % aspi.golpes)
	var maceta := _maceta_mas_cercana()
	if maceta == null:
		await _esperar(30)
		return
	await _ir_a(maceta.global_position.x - 16.0)
	felipe.mirando = 1.0
	# La maceta cae unos 60 px adelante en 0,67 s.
	var caida := maceta.global_position.x + 60.0
	await _hasta(func() -> bool: return absf(aspi.global_position.x + aspi.velocity.x * 0.67 - caida) < 14.0 or aspi.apagada, 600)
	await _tocar("interactuar")
	await _hasta(func() -> bool: return aspi.esta_aturdida(), 70)
	if not aspi.esta_aturdida():
		return
	Input.action_press("agacharse")
	await _tocar("saltar")
	Input.action_release("agacharse")
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.PISO_ALTO - 2.0, 90)
	# Golpea mientras le quede aturdimiento; antes de que despierte, corre a la silla.
	while aspi._tiempo_aturdida > 0.5 and not aspi.apagada:
		await _ir_a(aspi.global_position.x - 26.0, 40)
		felipe.mirando = 1.0
		await _tocar("zarpazo")
		await _esperar(18)


func _maceta_mas_cercana() -> Vaso:
	var mejor: Vaso = null
	for hijo in sala.get_children():
		if hijo is Vaso and hijo.tipo == "maceta" and hijo.global_position.y < Sala.PISO_ALTO - 150.0:
			if mejor == null or hijo.global_position.x < mejor.global_position.x:
				mejor = hijo
	return mejor


func _cazar_raton(desde: float, hasta: float) -> void:
	for hijo in sala.get_children():
		if is_instance_valid(hijo) and hijo is Raton and not hijo.apagada and hijo.global_position.x > desde and hijo.global_position.x < hasta \
				and absf(hijo.global_position.y - felipe.global_position.y) < 20.0:
			await _cazar(hijo)
	_paso("Caza ratones entre %d y %d" % [desde, hasta])


## Se acerca y lo golpea apenas lo tiene al alcance del zarpazo, antes de que lo toque.
func _cazar(enemigo: Aspi) -> void:
	for i in 400:
		if not is_instance_valid(enemigo) or enemigo.apagada:
			break
		var dx := enemigo.global_position.x - felipe.global_position.x
		if absf(dx) < 46.0:
			await _golpear(signf(dx))
		else:
			Input.action_press("mover_derecha" if dx > 0.0 else "mover_izquierda")
			Input.action_release("mover_izquierda" if dx > 0.0 else "mover_derecha")
			await _cuadro()
	Input.action_release("mover_derecha")
	Input.action_release("mover_izquierda")


func _golpear(lado: float) -> void:
	Input.action_release("mover_derecha")
	Input.action_release("mover_izquierda")
	felipe.mirando = lado
	await _tocar("zarpazo")
	await _esperar(10)


## Si un ratón se acerca a su altura, lo golpea primero.
func _raton_cerca() -> Raton:
	for hijo in sala.get_children():
		if is_instance_valid(hijo) and hijo is Raton and not hijo.apagada and felipe.is_on_floor() and not felipe.agachado:
			var d: Vector2 = hijo.global_position - felipe.global_position
			if absf(d.x) < 50.0 and absf(d.y) < 14.0:
				return hijo
	return null


## Camina hasta x, saltando lo que lo frena (y salta las bolas de pelo de A.S.P.I.).
func _ir_a(x: float, limite := 600, correr := false) -> void:
	if correr:
		Input.action_press("zoomies")
	for i in limite:
		var dx := x - felipe.global_position.x
		if absf(dx) < 5.0:
			break
		var raton := _raton_cerca()
		if raton:
			await _golpear(signf(raton.global_position.x - felipe.global_position.x))
			continue
		var derecha := dx > 0.0
		Input.action_press("mover_derecha" if derecha else "mover_izquierda")
		Input.action_release("mover_izquierda" if derecha else "mover_derecha")
		_esquivar_bolas()
		await _cuadro()
	Input.action_release("mover_derecha")
	Input.action_release("mover_izquierda")
	Input.action_release("zoomies")


## Salta (doble si hace falta) hacia x hasta quedar parado en la altura y.
func _subir_a(x: float, y: float, doble: bool, correr := false) -> void:
	for intento in 4:
		if absf(felipe.global_position.y - y) < 3.0 and felipe.is_on_floor():
			break
		var lado := signf(x - felipe.global_position.x)
		await _saltar(lado, doble, x, correr)
		print("        salto %d hacia (%.0f, %.0f): quedó en (%.0f, %.0f)" % [intento + 1, x, y, felipe.global_position.x, felipe.global_position.y])
	await _ir_a(x, 90)


func _saltar(lado: float, doble: bool, x_objetivo := INF, correr := false) -> void:
	var accion := "mover_derecha" if lado > 0.0 else "mover_izquierda"
	if lado != 0.0:
		Input.action_press(accion)
	Input.action_press("saltar")
	await _esperar(3)
	if correr:
		# Ya en el aire: mantener Shift corre sin disparar los zoomies.
		Input.action_press("zoomies")
	await _esperar(11)
	Input.action_release("saltar")
	if doble:
		await _hasta(func() -> bool: return felipe.velocity.y > -40.0, 40)
		Input.action_press("saltar")
		await _esperar(14)
		Input.action_release("saltar")
	for i in 120:
		if x_objetivo != INF and absf(felipe.global_position.x - x_objetivo) < 6.0:
			Input.action_release(accion)
			Input.action_release("zoomies")
		if felipe.is_on_floor() and i > 4:
			break
		await _cuadro()
	Input.action_release(accion)
	Input.action_release("zoomies")


func _esquivar_bolas() -> void:
	if sala.batalla == null:
		return
	for bola in sala.batalla.bolas:
		var dx := bola.global_position.x - felipe.global_position.x
		if absf(dx) < 46.0 and signf(float(bola.get_meta("velocidad"))) == -signf(dx) and felipe.is_on_floor():
			Input.action_press("saltar")
			return
	Input.action_release("saltar")


func _hasta(condicion: Callable, limite: int) -> void:
	for i in limite:
		if condicion.call():
			return
		_esquivar_bolas()
		await _cuadro()
	Input.action_release("saltar")


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await _cuadro()
	await _cuadro()
	Input.action_release(accion)
	await _cuadro()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await _cuadro()


var _corazones_antes := 5


func _cuadro() -> void:
	_cuadros += 1
	if felipe.corazones < _corazones_antes and OS.get_cmdline_user_args().has("--detalle"):
		var aspi := sala.batalla.aspi if sala.batalla else null
		print("        ¡golpe! %.1f s en (%.0f, %.0f) agachado=%s fase=%s aspi=%s" % [_cuadros / 60.0, felipe.global_position.x, felipe.global_position.y, felipe.agachado, sala.batalla.fase if sala.batalla else -1, aspi.global_position if aspi else Vector2.ZERO])
	_corazones_antes = felipe.corazones
	if _cuadros > LIMITE_CUADROS:
		print("Se acabó el tiempo")
		quit(1)
	await physics_frame


func _paso(texto: String) -> void:
	_pasos.append(texto)
	print("%5.1f s  %s  (x %.0f, y %.0f, corazones %d)" % [_cuadros / 60.0, texto, felipe.global_position.x, felipe.global_position.y, felipe.corazones])
