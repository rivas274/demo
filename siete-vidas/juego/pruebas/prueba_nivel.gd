extends SceneTree
## Prueba del primer nivel (tutorial "La Gran Fuga", dúplex de dos pisos) de principio a fin.
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_nivel.gd

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _esperar(30)

	# Avisos: con la tecla del dispositivo, y solo la primera vez.
	await _poner_en(felipe, Vector2(100, Sala.SUELO))
	_comprobar("{saltar}" in sala.pantallas.aviso, "Al empezar, el aviso enseña a caminar y saltar")
	_comprobar("[Espacio]" in sala.pantallas.etiquetar(sala.pantallas.aviso), "El aviso muestra la tecla: %s" % sala.pantallas.etiquetar(sala.pantallas.aviso))
	sala.pantallas.usa_mando = true
	_comprobar(sala.pantallas.etiquetar("{saltar}") == "[A]", "Con mando muestra el botón del mando")
	sala.pantallas.usa_mando = false
	await _poner_en(felipe, Vector2(400, Sala.SUELO))
	await _poner_en(felipe, Vector2(100, Sala.SUELO))
	_comprobar(sala.pantallas.aviso == "", "El aviso no se repite al volver")

	# Piezas de juguete: duelen.
	var corazones := felipe.corazones
	await _poner_en(felipe, Vector2(Sala.PELIGROS[0].get_center().x, Sala.SUELO))
	_comprobar(felipe.corazones < corazones, "Pisar las piezas de juguete quita un corazón")
	await _esperar(90)

	# Ratón de cuerda: un zarpazo.
	var raton: Raton = sala.get_node("Raton")
	await _zarpazo_a(felipe, raton)
	_comprobar(raton.apagada, "Un zarpazo apaga al ratón de cuerda")

	# Calcetín de la repisa de la escalera.
	await _poner_en(felipe, Sala.CALCETINES[0] + Vector2(0, -1))
	await _esperar(5)
	_comprobar(sala.calcetines == 1, "El calcetín de la repisa se recoge")

	# Punto de descanso.
	await _poner_en(felipe, Vector2(1450, Sala.SUELO - 24))
	await _esperar(10)
	_comprobar(felipe.punto_reaparicion.x > 1400 and felipe.punto_reaparicion.x < 1500, "La caja de arena es el punto de descanso")

	# Caja de cartón: se rompe y suelta comida.
	var caja: CajaCarton = sala.get_node("Caja de carton")
	await _zarpazo_a(felipe, caja)
	_comprobar(caja.roto, "El zarpazo rompe la caja de cartón")
	_comprobar(sala.get_children().any(func(n: Node) -> bool: return n is Comida and n.tipo == "plato"), "Dentro de la caja había un plato de comida")

	# Trepar la cortina de la cocina hasta el dormitorio por el hueco del entrepiso.
	var cortina: Rect2 = Sala.TREPABLES[0]
	await _poner_en(felipe, Vector2(cortina.get_center().x, Sala.SUELO))
	felipe.mirando = 1.0
	Input.action_press("mover_arriba")
	var animacion_trepar := false
	for i in 600:
		await physics_frame
		animacion_trepar = animacion_trepar or (felipe.trepando and felipe.sprite.animation == "trepar")
		if felipe.global_position.y <= Sala.PISO_ALTO + 1.0 and felipe.is_on_floor():
			break
	Input.action_release("mover_arriba")
	_comprobar(animacion_trepar, "Trepando usa la animación de trepar")
	_comprobar(felipe.global_position.y <= Sala.PISO_ALTO + 1.0, "Trepando la cortina llega al dormitorio (y = %.0f)" % felipe.global_position.y)

	# Láser y calcetín secreto del clóset.
	var laser: Laser = sala.get_node("Laser")
	_comprobar(laser.limite_izquierdo < Sala.CALCETINES[1].x + 40.0, "El láser ronda el clóset del calcetín secreto")

	# Puerta del dormitorio: atajo que solo se abre desde dentro.
	var puerta: PuertaDormitorio = sala.get_node("Puerta del dormitorio")
	await _poner_en(felipe, Vector2(Sala.PUERTA_DORMITORIO.position.x - 20, Sala.PISO_ALTO))
	puerta.interactuar(felipe)
	_comprobar(not puerta.abierta_ya, "Desde la escalera la puerta del dormitorio no se abre")
	await _poner_en(felipe, Vector2(Sala.PUERTA_DORMITORIO.end.x + 24, Sala.PISO_ALTO))
	await _tocar("interactuar")
	_comprobar(puerta.abierta_ya and "Atajo de Gato" in sala.logros, "Desde el dormitorio se abre el atajo (logro Atajo de Gato)")
	_comprobar(Sala.DESCANSOS[1].has_point(felipe.punto_reaparicion), "El cojín junto al atajo es punto de descanso")

	# A.S.P.I.: no ve a Felipe agachado; una maceta encima la aturde; aturdida, tres zarpazos.
	var aspi: Aspi
	for enemigo in root.get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Aspi and not enemigo is Raton:
			aspi = enemigo
	aspi.global_position = Vector2(2860, Sala.PISO_ALTO)
	await _poner_en(felipe, Vector2(2650, Sala.PISO_ALTO))
	Input.action_press("agacharse")
	await _esperar(10)
	aspi.global_position = Vector2(2760, Sala.PISO_ALTO)
	await _esperar(5)
	_comprobar(felipe.agachado and not aspi.persiguiendo, "Agachado, A.S.P.I. no ve a Felipe")
	Input.action_release("agacharse")
	await _esperar(10)
	aspi.velocidad_patrulla = 0.0
	aspi.vision = 0.0
	aspi.global_position = Vector2(2705, Sala.PISO_ALTO)
	felipe._tiempo_invulnerable = 99.0
	await _poner_en(felipe, Vector2(2625, Sala.PISO_ALTO - 160))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar(aspi.esta_aturdida(), "Una maceta que le cae encima aturde a A.S.P.I.")
	for i in Aspi.GOLPES_PARA_APAGAR:
		aspi.aturdir(3.0)
		await _zarpazo_a(felipe, aspi)
	_comprobar(aspi.apagada, "Aturdida, tres zarpazos la apagan")
	_comprobar(sala.get_node_or_null("Puerta del balcón") == null and "Desenchufada" in sala.logros, "Apagarla abre la puerta del balcón (logro Desenchufada)")

	# Pausa.
	await _tocar("pausa")
	_comprobar(paused and sala.pantallas.modo == Pantallas.Modo.PAUSA, "Esc pausa el juego")
	await _tocar("pausa")
	_comprobar(not paused, "Esc otra vez continúa")

	# Balcón: fin de la demo.
	await _poner_en(felipe, Vector2(Sala.SALIDA + 30, Sala.PISO_ALTO))
	_comprobar(sala.terminado and felipe.tiene_caer_de_pie, "Llegar al balcón da Caer de Pie y termina el nivel")
	await create_timer(2.5).timeout
	_comprobar(sala.pantallas.modo == Pantallas.Modo.FIN and paused, "Aparece la pantalla de Demo completada")
	_comprobar(sala.pantallas.datos_fin.get("calcetines", "") == "%d de 3" % sala.calcetines, "El final cuenta los calcetines (%s)" % sala.pantallas.datos_fin.get("calcetines", ""))
	paused = false
	sala.queue_free()
	await process_frame

	# Pantalla de título al empezar.
	var otra: Sala = load("res://escenas/apartamento.tscn").instantiate()
	root.add_child(otra)
	await process_frame
	_comprobar(paused and otra.pantallas.modo == Pantallas.Modo.TITULO, "El juego empieza en la pantalla de título")
	paused = false

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _zarpazo_a(felipe: Felipe, objetivo: Node2D) -> void:
	felipe._tiempo_invulnerable = 99.0
	await _poner_en(felipe, objetivo.global_position + Vector2(-30, 0))
	felipe.global_position = objetivo.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)
	felipe._tiempo_invulnerable = 0.0


func _poner_en(felipe: Felipe, posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await physics_frame
	await physics_frame
	Input.action_release(accion)
	await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
