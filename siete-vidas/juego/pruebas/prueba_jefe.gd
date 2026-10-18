extends SceneTree
## Prueba de la pelea con A.S.P.I. en el estudio: entrada tipo Broforce con la imaginación de Felipe (solo en la entrada),
## ensuciar para distraerla, aspirar, desenchufar los tres enchufes y el final. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	var aspi: Aspi = sala.aspi
	var batalla: BatallaAspi = sala.batalla
	await _esperar(30)
	_comprobar(batalla != null and batalla.fase == BatallaAspi.Fase.ESPERANDO and aspi.quieta, "A.S.P.I. duerme en su base hasta que Felipe entra al estudio")

	# Entrada: al entrar al estudio, todo se congela y empieza la presentación.
	felipe._tiempo_invulnerable = 999.0
	await _poner_en(felipe, Vector2(5300, Sala.SUELO))
	_comprobar(batalla.fase == BatallaAspi.Fase.ENTRADA and paused, "Entrar al estudio congela el juego y empieza la entrada")
	var textos := {}
	var oculta := false
	var gigante_maximo := 0.0
	for i in 600:
		await physics_frame
		textos[batalla.presentacion.texto_en_pantalla] = true
		oculta = oculta or not aspi.visible
		gigante_maximo = maxf(gigante_maximo, batalla.gigante)
		if batalla.fase != BatallaAspi.Fase.ENTRADA:
			break
	_comprobar(textos.has(PresentacionJefe.TEXTO_INICIO), "La entrada muestra «¡BATALLA INICIADA!»")
	_comprobar(textos.has(BatallaAspi.NOMBRE), "La entrada presenta a la jefa por su nombre")
	_comprobar(batalla.presentacion.t < 5.0, "La entrada dura menos de 5 s (%.1f s)" % batalla.presentacion.t)
	_comprobar(batalla.presentacion.zoom_maximo >= 2.5, "La cámara se acerca como en Broforce (zoom %.1f)" % batalla.presentacion.zoom_maximo)
	_comprobar(oculta and gigante_maximo >= 1.0, "En la imaginación de Felipe, A.S.P.I. se vuelve gigante")
	_comprobar(batalla.fase == BatallaAspi.Fase.PELEA and not paused and aspi.visible, "Tras la entrada sigue el juego con la A.S.P.I. real")
	await _esperar(70)
	_comprobar(batalla.gigante == 0.0 and batalla.transformacion == 0.0, "La imaginación se desvanece: el resto de la pelea se ve el estudio normal")
	_comprobar("desenchúfala" in sala.pantallas.aviso_fijo, "La pista de la fase 1 dice qué hacer")
	_comprobar(batalla.presentacion.vida == 1.0, "La barra de la jefa aparece llena")

	# Los zarpazos rebotan en la carcasa.
	aspi.global_position = Vector2(5600, Sala.SUELO)
	await _zarpazo_a(felipe, aspi)
	_comprobar(aspi.golpes == 0 and not aspi.apagada, "El zarpazo rebota en la carcasa")

	# Sin distraerla, no se puede desenchufar.
	await _poner_en(felipe, Sala.ENCHUFES[0])
	await _tocar("interactuar")
	_comprobar(batalla.tirados == 0, "Sin distraerla, A.S.P.I. no deja desenchufar")

	# Ensuciar: una maceta rota deja una mancha y A.S.P.I. va a limpiarla.
	aspi.global_position = Vector2(5320, Sala.SUELO)
	await _poner_en(felipe, Vector2(5634, Sala.SUELO - 160))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return not batalla.manchas.is_empty(), 90)
	_comprobar(batalla.manchas.size() == 1, "La maceta rota deja una mancha en el piso")
	await _esperar_que(func() -> bool: return batalla.limpiando, 400)
	_comprobar(batalla.limpiando and absf(aspi.global_position.x - batalla.manchas[0]) < 8.0, "A.S.P.I. va a limpiar la mancha")

	# Mientras limpia aspira: de pie arrastra, agachado se aferra.
	await _poner_en(felipe, aspi.global_position + Vector2(-150, 0))
	var antes := felipe.global_position.x
	await _esperar(20)
	_comprobar(felipe.global_position.x - antes > 15.0, "De pie, la succión arrastra a Felipe (%.0f px)" % (felipe.global_position.x - antes))
	felipe.global_position = aspi.global_position + Vector2(-150, 0)
	Input.action_press("agacharse")
	await _esperar(5)
	antes = felipe.global_position.x
	await _esperar(20)
	Input.action_release("agacharse")
	_comprobar(absf(felipe.global_position.x - antes) < 3.0, "Agachado se aferra y no lo arrastra")

	# Mientras limpia, el enchufe de la repisita sale.
	await _poner_en(felipe, Sala.ENCHUFES[2])
	_comprobar(batalla.limpiando, "Sigue limpiando mientras Felipe va al enchufe")
	await _tocar("interactuar")
	_comprobar(batalla.tirados == 1 and not batalla.limpiando, "Distraída, el enchufe sale y A.S.P.I. deja de limpiar (fase 2)")
	_comprobar(aspi.velocidad_persecucion > BatallaAspi.VELOCIDAD[0], "En la fase 2 es más rápida")

	# Aturdida también sirve: segundo enchufe, sobre el escritorio.
	await _poner_en(felipe, Sala.ENCHUFES[1])
	aspi.aturdir(3.0)
	await _tocar("interactuar")
	_comprobar(batalla.tirados == 2, "Aturdida también deja desenchufar (fase 3)")

	# Fase 3: escupe bolas de pelo; pegan si no salta.
	aspi.aturdir(0.0)
	aspi._tiempo_aturdida = 0.0
	aspi.velocidad_patrulla = 0.0
	aspi.velocidad_persecucion = 0.0
	aspi.global_position = Vector2(5700, Sala.SUELO)
	await _poner_en(felipe, Vector2(5580, Sala.SUELO))
	felipe._tiempo_invulnerable = 0.0
	var corazones := felipe.corazones
	await _esperar_que(func() -> bool: return felipe.corazones < corazones, 300)
	_comprobar(felipe.corazones < corazones, "En furia, una bola de pelo quita un corazón")
	felipe._tiempo_invulnerable = 999.0

	# Tercer enchufe, abajo junto al escritorio: se apaga.
	await _poner_en(felipe, Sala.ENCHUFES[0])
	aspi.aturdir(3.0)
	await _tocar("interactuar")
	_comprobar(aspi.apagada and batalla.fase == BatallaAspi.Fase.FIN, "Con los 3 enchufes, A.S.P.I. se apaga")
	_comprobar(not sala.puertas[Sala.PUERTA_BALCON].cerrada and "Desenchufada" in sala.logros, "Se abre la puerta del balcón (logro Desenchufada)")
	await _poner_en(felipe, Vector2(5560, Sala.SUELO))
	await _esperar(70)
	_comprobar(batalla.bolas.is_empty() and sala.pantallas.aviso_fijo == "", "No quedan bolas ni pistas")
	_comprobar(felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation == "acicalarse", "Felipe se lame la pata como si nada")

	# La presentación es reutilizable: sirve igual para otro jefe cualquiera.
	var otro := Node2D.new()
	otro.position = Vector2(5400, Sala.SUELO)
	sala.add_child(otro)
	var presentacion := PresentacionJefe.new("EL CARTERO", "Timbre del Terror · Nivel 12")
	presentacion.imaginacion = false
	presentacion.pantallas = sala.pantallas
	sala.add_child(presentacion)
	await physics_frame
	presentacion.presentar(felipe, otro, Rect2(5200, 0, 640, Sala.ALTO))
	var vio_nombre := false
	for i in 600:
		await physics_frame
		vio_nombre = vio_nombre or presentacion.texto_en_pantalla == "EL CARTERO"
		if not presentacion.presentando:
			break
	_comprobar(vio_nombre and not presentacion.presentando and not paused, "La misma presentación sirve para otro jefe (EL CARTERO)")

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _zarpazo_a(felipe: Felipe, objetivo: Node2D) -> void:
	await _poner_en(felipe, objetivo.global_position + Vector2(-30, 0))
	felipe.global_position = objetivo.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)


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
