extends SceneTree
## Prueba del primer nivel (tutorial "La Gran Fuga": habitaciones con puertas) de principio a fin.
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

	# La meta se muestra al empezar (la cámara pasa por el balcón).
	sala.pantallas.empezar.emit()
	await _esperar(10)
	var camara_meta: Camera2D = sala.get_node_or_null("Camara de la meta")
	_comprobar(camara_meta != null and camara_meta.is_current() and Sala.habitacion_de(camara_meta.position) == "balcon", "Al empezar, la cámara muestra el balcón (la meta)")
	await create_timer(2.5).timeout
	_comprobar(felipe.get_node("Camara").is_current(), "Después vuelve a Felipe")

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
	_comprobar(sala.habitacion == "sala", "Felipe empieza en la sala")

	# Piezas de juguete: duelen.
	var corazones := felipe.corazones
	await _poner_en(felipe, Vector2(Sala.PELIGROS[0].get_center().x, Sala.SUELO))
	_comprobar(felipe.corazones < corazones, "Pisar las piezas de juguete quita un corazón")
	await _esperar(90)

	# Vaso de la mesa: logro.
	await _poner_en(felipe, Vector2(620, Sala.SUELO - 91))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar("La Gravedad Funciona" in sala.logros, "Tirar el vaso de la mesa da «La Gravedad Funciona»")

	# Ratón de cuerda: un zarpazo.
	var raton: Raton = _raton_en(sala, "sala")
	await _zarpazo_a(felipe, raton)
	_comprobar(raton.apagada, "Un zarpazo apaga al ratón de cuerda")

	# Puertas: con el botón de acción o arriba se pasa a la otra habitación, y la cámara queda dentro.
	await _poner_en(felipe, sala.puertas["sala>recibidor"].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	var recibidor := Sala.rect_de("recibidor")
	var camara: Camera2D = felipe.get_node("Camara")
	_comprobar(sala.habitacion == "recibidor" and felipe.global_position.distance_to(sala.puertas["recibidor<sala"].global_position) < 4.0, "La puerta lleva de la sala al recibidor")
	_comprobar(camara.limit_left == int(recibidor.position.x) and camara.limit_right == int(recibidor.end.x), "La cámara queda dentro del recibidor")
	await _tocar("mover_arriba")
	await _esperar(30)
	_comprobar(sala.habitacion == "sala", "Arriba en una puerta también la cruza (vuelve a la sala)")

	# Caja de arena: punto de descanso.
	await _poner_en(felipe, Vector2(Sala.DESCANSOS[0].get_center().x, Sala.SUELO - 24))
	await _esperar(10)
	_comprobar(Sala.DESCANSOS[0].has_point(felipe.punto_reaparicion), "La caja de arena es punto de descanso")

	# La reja no se cruza desde el piso; desde el librero sí.
	await _poner_en(felipe, Vector2(1965, Sala.SUELO))
	Input.action_press("mover_derecha")
	await _esperar(40)
	Input.action_release("mover_derecha")
	_comprobar(felipe.global_position.x < Sala.REJA.position.x, "Las rejas apiladas cierran el paso a la escalera")
	await _poner_en(felipe, Vector2(1960, Sala.SUELO - 218))
	_comprobar(felipe.is_on_floor() and felipe.global_position.y <= Sala.SUELO - 217.0, "Se para arriba del librero")
	Input.action_press("mover_derecha")
	Input.action_press("saltar")
	await _esperar(12)
	Input.action_release("saltar")
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.x > Sala.REJA.end.x, 120)
	Input.action_release("mover_derecha")
	_comprobar(felipe.global_position.x > Sala.REJA.end.x, "Desde el librero salta la reja")

	# Desde la escalera la reja se abre (atajo); desde el recibidor no.
	var reja: Reja = sala.get_node("Reja")
	await _poner_en(felipe, Vector2(Sala.REJA.position.x - 20, Sala.SUELO))
	reja.interactuar(felipe)
	_comprobar(not reja.abierta_ya, "Desde el recibidor la reja no se abre")
	await _poner_en(felipe, Vector2(Sala.REJA.end.x + 12, Sala.SUELO))
	await _tocar("interactuar")
	_comprobar(reja.abierta_ya and "Atajo de Gato" in sala.logros, "Desde la escalera se abre la reja (logro Atajo de Gato)")

	# Arriba de la escalera, la puerta al pasillo.
	await _poner_en(felipe, sala.puertas["recibidor>pasillo"].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "pasillo", "La escalera lleva al pasillo de arriba")

	# Cojín del pasillo: descanso antes del jefe.
	await _poner_en(felipe, Vector2(Sala.DESCANSOS[1].get_center().x, Sala.SUELO))
	await _esperar(10)
	_comprobar(Sala.DESCANSOS[1].has_point(felipe.punto_reaparicion), "El cojín del pasillo es punto de descanso")

	# Calcetines: arriba del refrigerador, trepando la cortina del dormitorio y arriba del ropero.
	await _poner_en(felipe, Sala.CALCETINES[0] + Vector2(0, -1))
	await _esperar(5)
	_comprobar(sala.calcetines == 1, "El calcetín del refrigerador se recoge")
	var cortina: Rect2 = Sala.TREPABLES[0]
	await _poner_en(felipe, Vector2(cortina.get_center().x, Sala.SUELO))
	felipe.mirando = 1.0
	Input.action_press("mover_arriba")
	var animacion_trepar := false
	for i in 600:
		await physics_frame
		animacion_trepar = animacion_trepar or (felipe.trepando and felipe.sprite.animation == "trepar")
		if sala.calcetines == 2:
			break
	Input.action_release("mover_arriba")
	_comprobar(animacion_trepar, "Trepando usa la animación de trepar")
	_comprobar(sala.calcetines == 2, "Trepando la cortina llega al calcetín de la repisa alta")
	await _poner_en(felipe, Sala.CALCETINES[2] + Vector2(0, -1))
	await _esperar(5)
	_comprobar(sala.calcetines == 3 and "Coleccionista de Calcetines" in sala.logros, "Los 3 calcetines dan «Coleccionista de Calcetines»")

	# La puerta del balcón está cerrada hasta apagar a A.S.P.I.
	await _poner_en(felipe, sala.puertas["pasillo>estudio"].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "estudio" and sala.batalla.fase != BatallaAspi.Fase.ESPERANDO, "Entrar al estudio despierta a A.S.P.I.")
	await _esperar_que(func() -> bool: return sala.batalla.fase == BatallaAspi.Fase.PELEA, 400)
	felipe._tiempo_invulnerable = 999.0
	await _poner_en(felipe, sala.puertas[Sala.PUERTA_BALCON].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "estudio" and "Cerrada" in sala.pantallas.aviso_fijo, "Con A.S.P.I. encendida, la puerta del balcón no abre")

	# Desenchufarla (la pelea completa está en prueba_jefe) abre el balcón.
	for i in Sala.ENCHUFES.size():
		await _poner_en(felipe, Sala.ENCHUFES[i])
		sala.aspi.aturdir(3.0)
		await _tocar("interactuar")
	_comprobar(sala.aspi.apagada and "Desenchufada" in sala.logros, "Con los 3 enchufes A.S.P.I. se apaga (logro Desenchufada)")
	await _poner_en(felipe, sala.puertas[Sala.PUERTA_BALCON].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "balcon", "Apagada A.S.P.I., la puerta lleva al balcón")

	# Pausa.
	await _tocar("pausa")
	_comprobar(paused and sala.pantallas.modo == Pantallas.Modo.PAUSA, "Esc pausa el juego")
	await _tocar("pausa")
	_comprobar(not paused, "Esc otra vez continúa")

	# Balcón: fin de la demo.
	await _poner_en(felipe, Vector2(Sala.SALIDA + 30, Sala.SUELO))
	_comprobar(sala.terminado and felipe.tiene_caer_de_pie, "Llegar al final del balcón da Caer de Pie y termina el nivel")
	await create_timer(2.5).timeout
	_comprobar(sala.pantallas.modo == Pantallas.Modo.FIN and paused, "Aparece la pantalla de Demo completada")
	_comprobar(sala.pantallas.datos_fin.get("calcetines", "") == "3 de 3", "El final cuenta los calcetines (%s)" % sala.pantallas.datos_fin.get("calcetines", ""))
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


func _raton_en(sala: Sala, cuarto: String) -> Raton:
	for hijo in sala.get_children():
		if hijo is Raton and Sala.habitacion_de(hijo.global_position) == cuarto:
			return hijo
	return null


func _zarpazo_a(felipe: Felipe, objetivo: Node2D) -> void:
	felipe._tiempo_invulnerable = 99.0
	await _poner_en(felipe, objetivo.global_position + Vector2(-30, 0))
	felipe.global_position = objetivo.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)
	felipe._tiempo_invulnerable = 0.0


## Lo pone en un lugar y espera a que termine cualquier manotazo anterior (la animación dura 0,67 s).
func _poner_en(felipe: Felipe, posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(45)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await physics_frame
	await physics_frame
	Input.action_release(accion)
	await physics_frame


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
