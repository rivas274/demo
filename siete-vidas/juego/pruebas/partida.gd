extends SceneTree
## Partida completa jugada por un bot con los mismos botones que una persona: título, sala, recibidor, cocina,
## librero y reja, escalera, dormitorio, pasillo, pelea con A.S.P.I. y balcón, siempre por las puertas. Sirve como prueba de que el nivel se puede terminar
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
	# Título, introducción y la meta.
	await _esperar(100)
	await _tocar("ui_accept")
	await _esperar(150)
	await _tocar("ui_accept")
	await _esperar(180)
	_paso("Título, introducción y meta")

	# Sala: sofá, mesa y vaso; banco sobre los juguetes; aparador; ratón.
	await _ir_a(200)
	await _subir_a(330, Sala.SUELO - 54, false)
	await _ir_a(440)
	await _subir_a(620, Sala.SUELO - 91, true)
	await _ir_a(615)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(70)
	_paso("Tira el vaso" + (" (logro)" if "La Gravedad Funciona" in sala.logros else ""))
	await _ir_a(698)
	await _subir_a(834, Sala.SUELO - 79, true)
	await _ir_a(852)
	await _saltar(1.0, false, INF, true)
	_paso("Salta los juguetes")
	Input.action_press("agacharse")
	await _ir_a(1145)
	Input.action_release("agacharse")
	await _esperar(20)
	_paso("Pasa agachado bajo el aparador")
	await _cazar_raton(1150, 1400)
	await _entrar("sala>recibidor")

	# Recibidor: caja de arena; la cocina (calcetín) y de vuelta.
	await _subir_a(1710, Sala.SUELO - 24, false)
	await _esperar(30)
	_paso("Caja de arena")
	await _ir_a(1810)
	await _entrar("recibidor>cocina")
	await _ir_a(2660)
	await _subir_a(2720, Sala.SUELO - 109, true)
	await _cazar_raton(2700, 2910)
	await _ir_a(2895)
	await _subir_a(2980, Sala.SUELO - 218, true)
	_paso("Calcetín del refrigerador (%d)" % sala.calcetines)
	await _saltar(-1.0, false, 2860)
	await _ir_a(2680)
	await _ir_a(2570)
	await _entrar("cocina<recibidor")

	# El librero: escalera de gato para saltar las rejas; después la escalera.
	await _ir_a(1862)
	await _subir_a(1900, Sala.SUELO - 55, false)
	await _subir_a(1920, Sala.SUELO - 163, true)
	await _subir_a(1940, Sala.SUELO - 218, false)
	await _ir_a(1962)
	await _saltar(1.0, true, INF, true)
	_paso("Salta la reja desde el librero (x %.0f)" % felipe.global_position.x)
	for intento in 20:
		if felipe.global_position.y <= Sala.SUELO - Sala.SUBIDA_ESCALON * Sala.ESCALONES + 1.0:
			break
		await _saltar(1.0, false)
	await _entrar("recibidor>pasillo")

	# Dormitorio: cortina hasta la repisa alta, cómoda y ropero; vuelta por debajo de la cama.
	await _ir_a(3830)
	await _entrar("pasillo>dormitorio")
	await _ir_a(Sala.TREPABLES[0].get_center().x)
	felipe.mirando = 1.0
	var antes := sala.calcetines
	Input.action_press("mover_arriba")
	await _hasta(func() -> bool: return sala.calcetines > antes, 400)
	Input.action_release("mover_arriba")
	_paso("Trepa la cortina hasta el calcetín (%d)" % sala.calcetines)
	await _ir_a(4570)
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.SUELO - 2.0, 120)
	Input.action_press("agacharse")
	await _ir_a(4838)
	Input.action_release("agacharse")
	await _esperar(15)
	await _subir_a(4890, Sala.SUELO - 97, true)
	await _subir_a(4988, Sala.SUELO - 185, true)
	_paso("Calcetín del ropero (%d)" % sala.calcetines)
	await _ir_a(4880)
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.SUELO - 2.0, 120)
	Input.action_press("agacharse")
	await _ir_a(4570)
	Input.action_release("agacharse")
	await _esperar(15)
	await _ir_a(4390)
	await _entrar("dormitorio<pasillo")

	# Pasillo: el cojín y la puerta del estudio.
	await _ir_a(Sala.DESCANSOS[1].get_center().x)
	await _esperar(30)
	_paso("Descansa en el cojín")
	await _ir_a(4130)
	await _entrar("pasillo>estudio")

	# Pelea: ensuciar el piso para distraerla y desenchufar los tres enchufes.
	var batalla := sala.batalla
	await _hasta(func() -> bool: return batalla.fase == BatallaAspi.Fase.PELEA, 400)
	_paso("Entrada de la jefa")
	for enchufe in [2, 1, 0]:
		await _ronda_contra_aspi(enchufe)
		if batalla.fase == BatallaAspi.Fase.FIN:
			break
	_paso("Apaga a A.S.P.I." if batalla.fase == BatallaAspi.Fase.FIN else "No pudo con A.S.P.I.")
	await _esperar(90)

	# Balcón.
	await _entrar(Sala.PUERTA_BALCON)
	await _ir_a(Sala.SALIDA + 40, 400)
	await _hasta(func() -> bool: return sala.pantallas.modo == Pantallas.Modo.FIN, 300)
	await _esperar(150)
	var termino := sala.pantallas.modo == Pantallas.Modo.FIN
	_paso("Pantalla final" if termino else "No llegó al final")
	print("Logros: %s · calcetines %d · corazones %d · vidas %d · %.0f s" % [", ".join(sala.logros), sala.calcetines, felipe.corazones, felipe.vidas, _cuadros / 60.0])
	quit(0 if termino else 1)


## Cruza la puerta con ese nombre (camina hasta ella y aprieta el botón de acción).
func _entrar(nombre: String) -> void:
	var puerta: Puerta = sala.puertas[nombre]
	await _ir_a(puerta.global_position.x)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 90)
	await _ir_a(puerta.global_position.x, 60)
	if OS.get_cmdline_user_args().has("--detalle"):
		print("        puerta %s: estado %d, suelo %s, objeto %s" % [nombre, felipe.estado, felipe.is_on_floor(), felipe.objeto_cercano()])
	await _tocar("interactuar")
	await _esperar(30)
	_paso("Entra a %s" % sala.habitacion)


## Una ronda: ensucia el piso para que A.S.P.I. vaya a limpiar y, mientras limpia, tira del enchufe.
## Enchufe alto: maceta desde la repisa y salto a la repisita. Escritorio: el rollo, tirado desde el mismo escritorio.
## Enchufe de abajo: maceta lejos y carrera hasta la puerta.
func _ronda_contra_aspi(indice: int) -> void:
	var batalla := sala.batalla
	var objetivo: Vector2 = Sala.ENCHUFES[indice]
	for intento in 4:
		if batalla.enchufes[indice].tirado:
			return
		if indice == 1:
			await _ensuciar_con_rollo()
		else:
			# Para el enchufe de abajo, la maceta de más a la derecha: la succión no llega hasta el enchufe.
			await _ensuciar_con_maceta(indice == 0)
		# Ocupada: limpiando o aturdida (si la maceta le cayó encima).
		await _hasta(func() -> bool: return batalla.puede_desenchufar(), 300)
		if OS.get_cmdline_user_args().has("--detalle"):
			print("        %.1f s limpia en %s (felipe x %.0f y %.0f)" % [_cuadros / 60.0, batalla.manchas, felipe.global_position.x, felipe.global_position.y])
		match indice:
			2:
				await _ir_a(5770, 120)
				await _subir_a(objetivo.x, objetivo.y, true)
			0:
				await _bajar()
				if OS.get_cmdline_user_args().has("--detalle"):
					print("        %.1f s bajó (x %.0f y %.0f, estado %d)" % [_cuadros / 60.0, felipe.global_position.x, felipe.global_position.y, felipe.estado])
				await _ir_a(objetivo.x, 400, true)
		await _ir_a(objetivo.x, 60)
		if OS.get_cmdline_user_args().has("--detalle"):
			print("        %.1f s enchufe %d: limpiando %s, manchas %s" % [_cuadros / 60.0, indice, batalla.limpiando, batalla.manchas])
		await _tocar("interactuar")
		await _esperar(20)
		_paso("Ronda contra A.S.P.I.: enchufes %d" % batalla.tirados)


func _ensuciar_con_maceta(lejos: bool) -> void:
	if felipe.global_position.y > Sala.SUELO - 150.0:
		if felipe.global_position.y < Sala.SUELO - 50.0:
			await _bajar()
		await _ir_a(5540, 600, true)
		await _subir_a(5582, Sala.SUELO - 79, false)
		await _subir_a(5636, Sala.SUELO - 160, true)
	if _maceta_mas_cercana(lejos) == null:
		await _hasta(func() -> bool: return _maceta_mas_cercana(lejos) != null, 300)
	var maceta := _maceta_mas_cercana(lejos)
	await _ir_a(maceta.global_position.x - 16.0, 120)
	felipe.mirando = 1.0
	await _tocar("interactuar")


func _ensuciar_con_rollo() -> void:
	if absf(felipe.global_position.y - (Sala.SUELO - 98.0)) > 2.0:
		if felipe.global_position.y < Sala.SUELO - 50.0:
			await _bajar()
		await _ir_a(5540, 400)
		await _subir_a(5470, Sala.SUELO - 98, true)
	await _ir_a(5462, 60)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(30)
	await _ir_a(Sala.ENCHUFES[1].x, 120)


## Baja de la repisa atravesándola (agachado + saltar).
func _bajar() -> void:
	Input.action_press("agacharse")
	await _tocar("saltar")
	Input.action_release("agacharse")
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.SUELO - 2.0, 90)


## La maceta disponible de más a la izquierda (o de más a la derecha si `derecha`).
func _maceta_mas_cercana(derecha := false) -> Vaso:
	var mejor: Vaso = null
	for hijo in sala.get_children():
		if hijo is Vaso and hijo.tipo == "maceta" and not hijo.roto and hijo.global_position.y < Sala.SUELO - 150.0:
			if mejor == null or (hijo.global_position.x > mejor.global_position.x) == derecha:
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
		# Si un mueble lo frena (y no va agachado), lo salta con doble salto.
		if felipe.is_on_floor() and felipe.is_on_wall() and not felipe.agachado and absf(dx) > 20.0:
			await _saltar(signf(dx), true)
			continue
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
