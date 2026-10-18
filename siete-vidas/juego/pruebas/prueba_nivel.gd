extends SceneTree
## Prueba del primer nivel (tutorial "La Gran Fuga") de principio a fin.
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

	# Avisos del tutorial con la tecla del dispositivo.
	await _poner_en(felipe, Vector2(300, Sala.SUELO))
	_comprobar("{saltar}" in sala.pantallas.aviso, "Junto al sofá el aviso enseña a saltar")
	_comprobar(sala.pantallas.etiquetar(sala.pantallas.aviso).begins_with("[Espacio]"), "El aviso muestra la tecla: %s" % sala.pantallas.etiquetar(sala.pantallas.aviso))
	sala.pantallas.usa_mando = true
	_comprobar(sala.pantallas.etiquetar("{saltar}") == "[A]", "Con mando muestra el botón del mando")
	sala.pantallas.usa_mando = false

	# Ratón de cuerda: un zarpazo.
	var raton: Raton = sala.get_node("Raton")
	await _zarpazo_a(felipe, raton)
	_comprobar(raton.apagada, "Un zarpazo apaga al ratón de cuerda")

	# Caja de cartón: se rompe y suelta un calcetín.
	var caja: CajaCarton = sala.get_node("Caja de carton")
	await _zarpazo_a(felipe, caja)
	_comprobar(caja.roto, "El zarpazo rompe la caja de cartón")
	await _poner_en(felipe, Sala.CAJA_CARTON + Vector2(0, -2))
	await _esperar(5)
	_comprobar(sala.calcetines == 1, "El calcetín de la caja se recoge al pasar")

	# Punto de descanso.
	await _poner_en(felipe, Vector2(1150, 390))
	await _esperar(10)
	_comprobar(felipe.punto_reaparicion.x > 1100 and felipe.punto_reaparicion.x < 1200, "La caja de arena es el punto de descanso")

	# Puntero láser: imposible de atrapar.
	var laser: Laser = sala.get_node("Laser")
	await _poner_en(felipe, Vector2(laser.global_position.x + 20, Sala.SUELO))
	await _esperar(40)
	_comprobar(absf(laser.global_position.x - felipe.global_position.x) > 60.0, "El láser se escapa de Felipe")

	# Trepar la cortina y pasar la pared.
	var cortina: Rect2 = Sala.TREPABLES[0]
	await _poner_en(felipe, Vector2(cortina.get_center().x, Sala.SUELO))
	Input.action_press("mover_arriba")
	var trepo := false
	for i in 300:
		await physics_frame
		trepo = trepo or felipe.trepando
		if felipe.global_position.y < 110:
			break
	Input.action_release("mover_arriba")
	_comprobar(trepo, "Con arriba en la cortina, Felipe trepa")
	_comprobar(felipe.global_position.y < 110, "Trepando llega arriba de la pared del pasillo (y = %.0f)" % felipe.global_position.y)

	# A.S.P.I. jefa: al apagarla se abre la puerta del balcón.
	for enemigo in root.get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Aspi:
			enemigo.recibir_zarpazo(felipe)
			enemigo.recibir_zarpazo(felipe)
			enemigo.recibir_zarpazo(felipe)
	await _esperar(5)
	_comprobar(sala.get_node_or_null("Puerta del balcón") == null, "Apagar a A.S.P.I. abre la puerta del balcón")
	_comprobar("Desenchufada" in sala.logros, "Apagar a A.S.P.I. da el logro Desenchufada")

	# Pausa.
	await _tocar("pausa")
	_comprobar(paused and sala.pantallas.modo == Pantallas.Modo.PAUSA, "Esc pausa el juego")
	Input.action_press("pausa")
	await process_frame
	await process_frame
	Input.action_release("pausa")
	await process_frame
	_comprobar(not paused, "Esc otra vez continúa")

	# Balcón: fin de la demo.
	await _poner_en(felipe, Vector2(Sala.SALIDA + 30, Sala.SUELO))
	_comprobar(sala.terminado and felipe.tiene_caer_de_pie, "Llegar al balcón da Caer de Pie y termina el nivel")
	await create_timer(2.5).timeout
	_comprobar(sala.pantallas.modo == Pantallas.Modo.FIN and paused, "Aparece la pantalla de Demo completada")
	_comprobar(sala.pantallas.datos_fin.get("calcetines", "") == "1 de 3", "El final cuenta los calcetines (%s)" % sala.pantallas.datos_fin.get("calcetines", ""))
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
	await _tocar("zarpazo")
	await _esperar(30)
	felipe._tiempo_invulnerable = 0.0


func _poner_en(felipe: Felipe, posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await process_frame
	await process_frame
	Input.action_release(accion)
	await process_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
