extends SceneTree
## Prueba de la pelea con A.S.P.I. en el estudio: entrada de 8 pasos con PresentacionJefe (que se ve al entrar por la
## puerta: B1), imaginación solo en la entrada, ensuciar, anticipación de cada ataque, aspirar, depósito lleno, apagarla
## de un salto (tres veces), soplido contra el que acampa (G12), bolas en arco, entrada corta al volver tras perder una
## vida y el final. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []
var sala: Sala
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var aspi: Aspi = sala.aspi
	var batalla: BatallaAspi = sala.batalla
	var arena := Sala.rect_de("estudio")
	await _esperar(30)
	_comprobar(batalla != null and batalla.fase == BatallaAspi.Fase.ESPERANDO and aspi.quieta, "A.S.P.I. duerme en su base hasta que Felipe entra al estudio")

	# Entrada por la puerta: empieza DESPUÉS del fundido (B1) y sigue los 8 pasos de PresentacionJefe.
	felipe._tiempo_invulnerable = 999.0
	await _poner_en(sala.puertas["pasillo>estudio"].global_position)
	Input.action_press("interactuar")
	await _esperar(2)
	Input.action_release("interactuar")
	var textos := {}
	var pasos := []
	var oculta := false
	var gigante_maximo := 0.0
	var negro_maximo := 0.0
	var empezo_en_negro := false
	for i in 900:
		await physics_frame
		if batalla.fase == BatallaAspi.Fase.ENTRADA:
			var negro: float = sala.get_node("Interfaz/Fundido").modulate.a
			negro_maximo = maxf(negro_maximo, negro)
			if batalla.presentacion.t < 0.05:
				empezo_en_negro = empezo_en_negro or negro > 0.01
			textos[batalla.presentacion.texto_en_pantalla] = true
			if not batalla.presentacion.paso_actual in pasos and batalla.presentacion.paso_actual != "":
				pasos.append(batalla.presentacion.paso_actual)
			oculta = oculta or not aspi.visible
			gigante_maximo = maxf(gigante_maximo, batalla.gigante)
		if batalla.fase == BatallaAspi.Fase.PELEA:
			break
	_comprobar(negro_maximo < 0.01 and not empezo_en_negro, "Entrar por la puerta: la presentación empieza con el fundido ya terminado (nada en negro, B1)")
	var orden := []
	for paso: Array in PresentacionJefe.PASOS:
		orden.append(paso[0])
	_comprobar(pasos == orden, "La entrada recorre los 8 pasos en orden (%s)" % ", ".join(pasos))
	_comprobar(textos.has(PresentacionJefe.TEXTO_INICIO), "La entrada muestra «¡BATALLA INICIADA!»")
	_comprobar(textos.has(BatallaAspi.NOMBRE), "La entrada presenta a la jefa por su nombre")
	_comprobar(textos.has(BatallaAspi.RUGIDO), "El rugido: «%s»" % BatallaAspi.RUGIDO)
	_comprobar(batalla.presentacion.t < 5.0, "La entrada dura menos de 5 s (%.1f s)" % batalla.presentacion.t)
	_comprobar(batalla.presentacion.zoom_maximo >= 2.5, "La cámara se acerca como en Broforce (zoom %.1f)" % batalla.presentacion.zoom_maximo)
	_comprobar(oculta and gigante_maximo >= 1.0, "En la imaginación de Felipe, A.S.P.I. se vuelve gigante")
	_comprobar(sala.puertas["estudio<pasillo"].cerrada and _dijo("felipe", "Quién cerró"), "Sin vuelta atrás: la puerta se cierra sola («…¿Quién cerró?»)")
	_comprobar(batalla.fase == BatallaAspi.Fase.PELEA and not paused and aspi.visible, "Tras la entrada sigue el juego con la A.S.P.I. real")
	await _esperar(70)
	_comprobar(batalla.gigante == 0.0 and batalla.transformacion == 0.0, "La imaginación se desvanece: el resto de la pelea se ve el estudio normal")
	_comprobar("Tira" in batalla.presentacion.pista_actual(), "El cartel de la fase 1 trae su pista de una línea")
	_comprobar(batalla.presentacion.vida == 1.0, "La barra de la jefa aparece llena")

	# Los zarpazos rebotan en la carcasa.
	aspi.global_position = Vector2(arena.position.x + 360, Sala.SUELO)
	await _zarpazo_a(aspi)
	_comprobar(aspi.golpes == 0 and not aspi.apagada, "El zarpazo rebota en la carcasa")

	# Embestida anunciada: retrocede, luz roja 0,5 s y recién después carga (y solo entonces hace daño).
	await _poner_en(Vector2(arena.position.x + 200, Sala.SUELO))
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.NINGUNO, 200)
	felipe._tiempo_invulnerable = 0.0
	aspi.global_position = Vector2(arena.position.x + 330, Sala.SUELO)
	batalla._espera_embestida = 0.0
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.AVISO_EMBESTIDA, 120)
	_comprobar(batalla.ataque == BatallaAspi.Ataque.AVISO_EMBESTIDA and aspi.luz_aviso.a > 0.0 and aspi.inofensiva, "Antes de embestir avisa: luz roja que parpadea, inofensiva")
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.EMBESTIDA, 60)
	_comprobar(batalla.ataque == BatallaAspi.Ataque.EMBESTIDA and not aspi.inofensiva, "Después de 0,5 s carga y ahí sí duele")
	felipe._tiempo_invulnerable = 999.0
	await _esperar(60)

	# Ensuciar: una maceta rota deja una mancha y A.S.P.I. va a limpiarla (antes gira el cepillo).
	aspi.global_position = Vector2(arena.position.x + 80, Sala.SUELO)
	var maceta := _maceta()
	await _poner_en(maceta.global_position + Vector2(-16, 0))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return not batalla.manchas.is_empty(), 90)
	_comprobar(batalla.manchas.size() == 1, "La maceta rota deja una mancha en el piso")
	await _poner_en(Vector2(arena.position.x + 60, Sala.SUELO))
	await _esperar_que(func() -> bool: return batalla._aviso_succion > 0.0, 400)
	_comprobar(batalla._aviso_succion > 0.0 and not batalla.limpiando, "Antes de aspirar, el cepillo gira 0,6 s (anticipación)")
	await _esperar_que(func() -> bool: return batalla.limpiando, 100)
	_comprobar(batalla.limpiando and absf(aspi.global_position.x - batalla.manchas[0]) < 8.0, "A.S.P.I. va a limpiar la mancha")

	# Mientras limpia aspira: de pie arrastra, agachado se aferra.
	felipe.global_position = aspi.global_position + Vector2(-150, 0)
	felipe.velocity = Vector2.ZERO
	await _esperar(5)
	var antes := felipe.global_position.x
	await _esperar(15)
	_comprobar(felipe.global_position.x - antes > 15.0, "De pie, la succión arrastra a Felipe (%.0f px)" % (felipe.global_position.x - antes))
	felipe.global_position = aspi.global_position + Vector2(-150, 0)
	Input.action_press("agacharse")
	await _esperar(5)
	antes = felipe.global_position.x
	await _esperar(15)
	Input.action_release("agacharse")
	_comprobar(not batalla.limpiando or absf(felipe.global_position.x - antes) < 3.0, "Agachado se aferra y no lo arrastra")
	await _poner_en(Vector2(arena.position.x + 60, Sala.SUELO))
	await _esperar_que(func() -> bool: return batalla.deposito == 1, 300)
	_comprobar(batalla.deposito == 1 and batalla.presentacion.escudo > 0.0 and "Glup." in sala.travesuras.jugo.palabras, "Limpiar le llena el depósito (barra azul, «+1» y «Glup.»)")
	await _esperar(6 * 60 + 30)
	_comprobar(maceta.visible and not maceta.roto, "Lo roto vuelve a su lugar de a uno (6 s)")

	# Lleno: se detiene inofensiva; si nadie la apaga, lo vacía.
	await _llenar(batalla, aspi)
	_comprobar(batalla.llena and aspi.inofensiva and "encima" in batalla.presentacion.pista_actual(), "Con el depósito lleno se detiene, inofensiva, y la pista dice que le salte encima")
	await _esperar_que(func() -> bool: return not batalla.llena, 400)
	_comprobar(not batalla.llena and batalla.deposito == 0 and batalla.apagados == 0, "Si nadie la apaga a tiempo, vacía el depósito y sigue")

	# Saltarle encima con el depósito lleno la apaga: ¡CLIC!, fase 2, más rápida.
	await _llenar(batalla, aspi)
	await _caerle_encima(aspi)
	_comprobar(batalla.apagados == 1 and not batalla.llena, "Caerle encima le aprieta el botón: fase 2")
	_comprobar("¡CLIC!" in sala.travesuras.jugo.palabras, "Al apagarla: congelado, destello, sacudida y «¡CLIC!»")
	await _esperar(100)
	_comprobar(aspi.velocidad_persecucion > BatallaAspi.VELOCIDAD[0], "En la fase 2 es más rápida")

	# Contra el que acampa (G12): quieto en la repisa, A.S.P.I. lo saca en 4 s o menos, sin daño.
	aspi.global_position = Vector2(arena.position.x + 70, Sala.SUELO)
	var repisa := sala.pieza("Repisa de las macetas")
	var corazones := felipe.corazones
	await _poner_en(Vector2(repisa.position.x + 30, repisa.position.y), 2)
	var cuadros := 0
	var aviso_amarillo := false
	while cuadros < 300 and batalla.soplidos == 0:
		await physics_frame
		cuadros += 1
		aviso_amarillo = aviso_amarillo or (batalla.ataque == BatallaAspi.Ataque.AVISO_SOPLIDO and aspi.vibrando)
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Sala.SUELO - 2.0, 120)
	_comprobar(batalla.soplidos >= 1 and felipe.global_position.y > Sala.SUELO - 2.0 and cuadros <= 240, "Quieto en la repisa, A.S.P.I. lo saca de un soplido en %.1f s (≤ 4 s)" % (cuadros / 60.0))
	_comprobar(aviso_amarillo, "Antes del soplido avisa 0,6 s: vibra con luz amarilla")
	_comprobar(felipe.corazones == corazones, "El soplido no hace daño")
	await _llenar(batalla, aspi)
	await _caerle_encima(aspi)
	_comprobar(batalla.apagados == 2, "Segundo apagado: fase 3 (furia)")

	# Fase 3: tose y escupe bolas de pelo en arco que llegan arriba (al escritorio).
	await _esperar(100)
	aspi.velocidad_patrulla = 0.0
	aspi.global_position = Vector2(arena.position.x + 90, Sala.SUELO)
	await _poner_en(Vector2(arena.position.x + 330, Sala.SUELO - 98), 2)
	felipe._tiempo_invulnerable = 0.0
	corazones = felipe.corazones
	var tosio := false
	var alta := false
	for i in 600:
		await physics_frame
		tosio = tosio or batalla.ataque == BatallaAspi.Ataque.AVISO_BOLA
		for bola in batalla.bolas:
			alta = alta or bola.global_position.y < Sala.SUELO - 110.0
		if felipe.corazones < corazones:
			break
	_comprobar(tosio and alta, "En furia tose y la bola de pelo va en arco hasta arriba")
	_comprobar(felipe.corazones < corazones, "La bola de pelo quita un corazón aunque esté en el escritorio")
	felipe._tiempo_invulnerable = 999.0

	# Perder una vida: reaparece en el cojín, A.S.P.I. conserva la fase y al volver la entrada es corta (1 s).
	var cojin: Rect2 = Sala.DESCANSOS[1]
	felipe.punto_reaparicion = Vector2(cojin.get_center().x, cojin.position.y + 10)
	felipe.global_position = felipe.punto_reaparicion
	await _esperar(30)
	_comprobar(batalla.ausente and batalla.apagados == 2, "Fuera del estudio la pelea espera con la fase guardada")
	sala.puertas["pasillo>estudio"].interactuar(felipe)
	var duro := 0.0
	await _esperar_que(func() -> bool: return batalla.presentacion.presentando, 200)
	while batalla.presentacion.presentando:
		await physics_frame
		duro += 1.0 / 60.0
	_comprobar(duro > 0.5 and duro <= 1.1 and not batalla.ausente, "Al volver, la entrada corta dura %.1f s (≤ 1 s) y sigue la fase 3" % duro)

	# Maullar: gira hacia Felipe ("¿Gato detectado?").
	await _poner_en(Vector2(arena.position.x + 120, Sala.SUELO))
	aspi.global_position = Vector2(arena.position.x + 400, Sala.SUELO)
	batalla._espera_embestida = 99.0
	batalla._espera_bola = 99.0
	await _tocar("maullar")
	await _esperar(30)
	_comprobar("¿Gato detectado?" in sala.travesuras.jugo.palabras, "Al maullar, A.S.P.I. gira hacia Felipe: «¿Gato detectado?»")

	# Tercer apagado: se apaga del todo.
	await _llenar(batalla, aspi)
	await _caerle_encima(aspi)
	await _esperar_que(func() -> bool: return felipe.estado == Felipe.Estado.OCIO, 200)
	_comprobar(felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation == "acicalarse", "Felipe se lame la pata como si nada")
	_comprobar(aspi.apagada and batalla.fase == BatallaAspi.Fase.FIN, "Al tercer apagado, A.S.P.I. se apaga del todo")
	_comprobar(not sala.puertas[Sala.PUERTA_BALCON].cerrada and "Desenchufada" in sala.logros and sala.travesuras.agenda.esta_cumplida("desenchufar"), "Se abre la puerta del balcón (travesura «desenchufar» y logro)")
	_comprobar(Engine.time_scale == 1.0 and not sala.puertas["estudio<pasillo"].cerrada, "Todo vuelve de golpe a la normalidad")
	await _poner_en(Vector2(arena.position.x + 330, Sala.SUELO))
	await _esperar(70)
	_comprobar(batalla.bolas.is_empty() and batalla.presentacion.pista_actual() == "", "No quedan bolas ni pistas")

	# La presentación es reutilizable: sirve igual para otro jefe cualquiera (cada uno solo da sus datos).
	var otro := Node2D.new()
	otro.position = Vector2(arena.position.x + 200, Sala.SUELO)
	sala.add_child(otro)
	var presentacion := PresentacionJefe.new("EL CARTERO", "Timbre del Terror · Nivel 12")
	presentacion.imaginacion = false
	presentacion.texto_rugido = "¡CORRESPONDENCIA!"
	presentacion.pantallas = sala.pantallas
	sala.add_child(presentacion)
	await physics_frame
	var pasos_cartero := []
	presentacion.paso_empezado.connect(func(paso: String) -> void: pasos_cartero.append(paso))
	presentacion.presentar(felipe, otro, Rect2(arena.position.x, 0, 640, Sala.ALTO))
	var vio_nombre := false
	for i in 600:
		await physics_frame
		vio_nombre = vio_nombre or presentacion.texto_en_pantalla == "EL CARTERO"
		if not presentacion.presentando:
			break
	_comprobar(vio_nombre and pasos_cartero.size() == 8 and not presentacion.presentando and not paused, "La misma presentación de 8 pasos sirve para otro jefe (EL CARTERO)")

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _maceta() -> Vaso:
	for hijo in sala.get_children():
		if hijo is Vaso and hijo.tipo == "maceta" and not hijo.roto and hijo.visible:
			return hijo
	return null


## Le deja el depósito a una mancha de llenarse y le pone esa mancha al lado (más rápido que tirar macetas).
func _llenar(batalla: BatallaAspi, aspi: Aspi) -> void:
	await _poner_en(Vector2(Sala.rect_de("estudio").position.x + 60, Sala.SUELO), 2)
	batalla.deposito = BatallaAspi.CAPACIDAD[batalla.apagados] - 1
	batalla.agregar_mancha(aspi.global_position)
	await _esperar_que(func() -> bool: return batalla.llena, 400)


## Felipe cae sobre A.S.P.I. desde un poco más arriba que su tapa.
func _caerle_encima(aspi: Aspi) -> void:
	await _esperar(20)
	felipe.global_position = aspi.global_position + Vector2(0, -62)
	felipe.velocity = Vector2.ZERO
	await _esperar(60)


func _zarpazo_a(objetivo: Node2D) -> void:
	await _poner_en(objetivo.global_position + Vector2(-30, 0))
	felipe.global_position = objetivo.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)


func _dijo(quien: String, texto: String) -> bool:
	for linea: Array in sala.travesuras.dialogo.historial:
		if linea[0] == quien and texto in String(linea[1]):
			return true
	return false


## Lo pone en un lugar y espera a que termine cualquier manotazo anterior (la animación dura 0,67 s).
func _poner_en(posicion: Vector2, cuadros := 45) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


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
