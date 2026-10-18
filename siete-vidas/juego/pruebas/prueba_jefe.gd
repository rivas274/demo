extends SceneTree
## Prueba de la pelea con A.S.P.I. (entrada tipo Broforce, imaginación gigante y tres fases). Sin ventana:
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
	var aspi: Aspi = sala.get_node("ASPI")
	var batalla: BatallaAspi = sala.batalla
	await _esperar(30)
	_comprobar(batalla != null and batalla.fase == BatallaAspi.Fase.ESPERANDO, "La pelea espera a que Felipe se cruce con A.S.P.I.")

	# Entrada: al cruzarse, todo se congela y empieza la presentación.
	aspi.velocidad_patrulla = 0.0
	aspi.vision = 0.0
	aspi.global_position = Vector2(2780, Sala.PISO_ALTO)
	await _poner_en(felipe, Vector2(2660, Sala.PISO_ALTO))
	_comprobar(batalla.fase == BatallaAspi.Fase.ENTRADA and paused, "Cruzarse con A.S.P.I. congela el juego y empieza la entrada")
	var textos := {}
	var oculta := false
	var gigante_maximo := 0.0
	for i in 600:
		await physics_frame
		textos[batalla.texto_en_pantalla] = true
		oculta = oculta or not aspi.visible
		gigante_maximo = maxf(gigante_maximo, batalla.gigante)
		if batalla.fase != BatallaAspi.Fase.ENTRADA:
			break
	_comprobar(textos.has("¡BATALLA INICIADA!"), "La entrada muestra «¡BATALLA INICIADA!»")
	_comprobar(textos.has(BatallaAspi.NOMBRE), "La entrada presenta a la jefa por su nombre")
	_comprobar(batalla.zoom_maximo >= 2.5, "La cámara se acerca como en Broforce (zoom %.1f)" % batalla.zoom_maximo)
	_comprobar(oculta and gigante_maximo >= 1.0, "En la imaginación de Felipe, A.S.P.I. se vuelve gigante")
	_comprobar(batalla.fase == BatallaAspi.Fase.SUCCION and not paused, "Tras la entrada sigue el juego en la fase 1")
	_comprobar(aspi.visible and felipe.get_node("Camara").is_current(), "Vuelven la A.S.P.I. real y la cámara de Felipe")
	_comprobar(batalla.transformacion >= 1.0, "El pasillo se vuelve el fin del mundo")
	_comprobar("agacharse" in sala.pantallas.aviso_fijo, "La pista de la fase 1 dice que hay que agacharse")

	# Fase 1, succión: con escudo, de pie lo arrastra y agachado se aferra.
	felipe._tiempo_invulnerable = 999.0
	aspi.aturdir(2.0)
	await _zarpazo_a(felipe, aspi)
	_comprobar(aspi.golpes == 0, "Con escudo, el zarpazo rebota aunque esté aturdida")
	aspi._tiempo_aturdida = 0.0
	await _poner_en(felipe, aspi.global_position + Vector2(-130, 0))
	await _esperar_que(func() -> bool: return batalla.succionando, 400)
	var antes := felipe.global_position.x
	await _esperar(40)
	_comprobar(felipe.global_position.x - antes > 20.0, "De pie, la succión arrastra a Felipe (%.0f px)" % (felipe.global_position.x - antes))
	felipe.global_position = aspi.global_position + Vector2(-130, 0)
	Input.action_press("agacharse")
	await _esperar(5)
	antes = felipe.global_position.x
	await _esperar(30)
	_comprobar(not batalla.succionando or absf(felipe.global_position.x - antes) < 3.0, "Agachado se aferra y no lo arrastra")
	await _esperar_que(func() -> bool: return batalla.fase != BatallaAspi.Fase.SUCCION, 1200)
	Input.action_release("agacharse")
	_comprobar(batalla.fase == BatallaAspi.Fase.ATURDIR and batalla.succiones == BatallaAspi.SUCCIONES, "Aguantar %d succiones rompe el escudo (fase 2)" % BatallaAspi.SUCCIONES)
	_comprobar("maceta" in sala.pantallas.aviso_fijo, "La pista de la fase 2 habla de la maceta")

	# Fase 2: una maceta la aturde y los zarpazos le hacen daño.
	aspi.global_position = Vector2(2705, Sala.PISO_ALTO)
	await _poner_en(felipe, Vector2(2625, Sala.PISO_ALTO - 160))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar(aspi.esta_aturdida(), "Una maceta la aturde")
	await _zarpazo_a(felipe, aspi)
	_comprobar(aspi.golpes == 1, "Aturdida, el zarpazo le hace daño")
	aspi.aturdir(3.0)
	await _zarpazo_a(felipe, aspi)
	_comprobar(batalla.fase == BatallaAspi.Fase.FURIA, "Con %d golpes entra en furia (fase 3)" % BatallaAspi.GOLPES_FASE_ATURDIR)
	_comprobar(aspi.velocidad_patrulla > 40.0, "En furia es más rápida")

	# Fase 3: escupe bolas de pelo por el piso; pegan si no salta.
	aspi.velocidad_patrulla = 0.0
	aspi.velocidad_persecucion = 0.0
	aspi._tiempo_aturdida = 0.0
	await _poner_en(felipe, aspi.global_position + Vector2(-110, 0))
	felipe._tiempo_invulnerable = 0.0
	var corazones := felipe.corazones
	await _esperar_que(func() -> bool: return felipe.corazones < corazones, 300)
	_comprobar(felipe.corazones < corazones, "Una bola de pelo quita un corazón")
	felipe._tiempo_invulnerable = 0.0
	felipe.corazones = Felipe.CORAZONES_MAX
	await _poner_en(felipe, aspi.global_position + Vector2(-110, 0))
	felipe._tiempo_invulnerable = 0.0
	await _esperar_que(func() -> bool: return batalla.bolas.size() > 0 and absf(batalla.bolas[0].global_position.x - felipe.global_position.x) < 40.0, 300)
	Input.action_press("saltar")
	await _esperar(12)
	Input.action_release("saltar")
	await _esperar(40)
	_comprobar(felipe.corazones == Felipe.CORAZONES_MAX, "Saltando, la bola de pelo pasa por debajo")

	# Final: aturdida y con dos zarpazos más se apaga; todo vuelve a ser un pasillo.
	for i in BatallaAspi.GOLPES_TOTALES - BatallaAspi.GOLPES_FASE_ATURDIR:
		aspi.aturdir(3.0)
		await _zarpazo_a(felipe, aspi)
	_comprobar(aspi.apagada and batalla.fase == BatallaAspi.Fase.FIN, "Con %d golpes en total se apaga" % BatallaAspi.GOLPES_TOTALES)
	_comprobar(batalla.transformacion == 0.0 and sala.pantallas.aviso_fijo == "", "El fin del mundo desaparece de golpe")
	await _esperar(70)
	_comprobar(batalla.gigante == 0.0 and batalla.bolas.is_empty(), "La bestia imaginaria se desinfla y no quedan bolas")
	_comprobar(felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation == "acicalarse", "Felipe se lame la pata como si nada")
	_comprobar(sala.get_node_or_null("Puerta del balcón") == null and "Desenchufada" in sala.logros, "Se abre el balcón (logro Desenchufada)")

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _zarpazo_a(felipe: Felipe, objetivo: Node2D) -> void:
	var invulnerable := felipe._tiempo_invulnerable
	felipe._tiempo_invulnerable = 99.0
	await _poner_en(felipe, objetivo.global_position + Vector2(-30, 0))
	felipe.global_position = objetivo.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)
	felipe._tiempo_invulnerable = invulnerable


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
