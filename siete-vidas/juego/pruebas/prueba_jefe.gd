extends SceneTree
## Prueba de la pelea con A.S.P.I. en el estudio: entrada de 8 pasos con PresentacionJefe (que se ve al entrar por la
## puerta: B1), imaginación solo en la entrada, ensuciar, anticipación de cada ataque, aspirar, depósito lleno, apagarla
## de un salto (tres veces), soplido contra el que acampa (G12), bolas en arco, entrada corta al volver tras perder una
## vida y el final. Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []
var sala: Nivel
## Lo propio del nivel 1 (Valeria, A.S.P.I., la pelea, las cajas...).
var guion: GuionNivel1
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var aspi: Enemigo = guion.aspi
	var batalla: BatallaAspi = guion.batalla
	var arena := Nivel1.rect_de("estudio")
	await _esperar(30)
	_comprobar(batalla != null and batalla.fase == BatallaAspi.Fase.ESPERANDO and aspi.patrulla.quieta, "A.S.P.I. duerme en su base hasta que Felipe entra al estudio")
	# Estudio v3 (la pelea en todo el cuarto): A.S.P.I. llega a los dos lados y lo de la isla de la derecha es munición.
	_comprobar(aspi.patrulla.limite_izquierdo - arena.position.x <= 60.0 and arena.end.x - aspi.patrulla.limite_derecho <= 60.0, "A.S.P.I. recorre el estudio entero (%.0f a %.0f de %.0f a %.0f)" % [aspi.patrulla.limite_izquierdo, aspi.patrulla.limite_derecho, arena.position.x, arena.end.x])
	var librero := Nivel1.rect_pieza("Librero bajo")
	var de_la_derecha := batalla.municion.filter(func(o: Objeto) -> bool: return o.position.x > librero.position.x and o.position.x < librero.end.x)
	_comprobar(de_la_derecha.size() == 2 and aspi.patrulla.limite_derecho > librero.end.x, "Lo que está sobre el librero bajo (planta y portarretratos) le llena el depósito en la fase 1 y ella llega a limpiarlo")

	# Entrada por la puerta: empieza DESPUÉS del fundido (B1) y sigue los 8 pasos de PresentacionJefe.
	felipe.vida.restante_invulnerable = 999.0
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
	var subtitulos := {}
	var dialogo_a_la_vista := false
	var indicador_a_la_vista := false
	var vio_imaginacion := false
	var encima: Array[String] = []
	var dos_aspi := false
	var felipe_delante := true
	for i in 900:
		await physics_frame
		if batalla.fase == BatallaAspi.Fase.ENTRADA:
			var negro: float = sala.fundido_alfa()
			negro_maximo = maxf(negro_maximo, negro)
			if batalla.presentacion.t < 0.05:
				empezo_en_negro = empezo_en_negro or negro > 0.01
			textos[batalla.presentacion.texto_en_pantalla] = true
			if not batalla.presentacion.paso_actual in pasos and batalla.presentacion.paso_actual != "":
				pasos.append(batalla.presentacion.paso_actual)
			oculta = oculta or not aspi.visible
			if batalla.presentacion.presentando:
				subtitulos[batalla.presentacion.subtitulo_en_pantalla] = true
				dialogo_a_la_vista = dialogo_a_la_vista or sala.travesuras.dialogo.ocupado()
				indicador_a_la_vista = indicador_a_la_vista or sala.travesuras.indicador.is_visible_in_tree()
			gigante_maximo = maxf(gigante_maximo, batalla.gigante)
			# B1: durante la imaginación nada del escenario se dibuja encima, y nunca se ven dos A.S.P.I.
			if batalla.transformacion > 0.0 or batalla.gigante > 0.0:
				vio_imaginacion = true
				for nombre in _encima_de_la_imaginacion(batalla):
					if not nombre in encima:
						encima.append(nombre)
				if batalla.gigante > 0.0 and aspi.visible:
					dos_aspi = true
				felipe_delante = felipe_delante and Capas.z_efectivo(felipe) > Capas.z_efectivo(batalla.get_node("Imaginacion"))
		if batalla.fase == BatallaAspi.Fase.PELEA:
			break
	_comprobar(vio_imaginacion and encima.is_empty(), "B1 Durante la imaginación nada del escenario (muebles, puertas, repisa) se dibuja encima de ella %s" % str(encima))
	_comprobar(vio_imaginacion and not dos_aspi, "B1 Nunca se ven dos A.S.P.I. a la vez: la real aparece cuando la gigante ya se fue")
	_comprobar(vio_imaginacion and felipe_delante, "B1 Felipe queda delante de su propia imaginación")
	_comprobar(_tabla_ordenada(), "B1 La tabla única de capas (Capas) va de atrás hacia adelante, sin saltos de orden")
	_comprobar(not aspi.visible or batalla.gigante == 0.0, "B1 Al terminar la entrada, la gigante ya no está")
	_comprobar(negro_maximo < 0.01 and not empezo_en_negro, "Entrar por la puerta: la presentación empieza con el fundido ya terminado (nada en negro, B1)")
	var orden := []
	for paso: Array in PresentacionJefe.PASOS:
		orden.append(paso[0])
	_comprobar(pasos == orden, "La entrada recorre los 8 pasos en orden (%s)" % ", ".join(pasos))
	_comprobar(textos.has(PresentacionJefe.TEXTO_INICIO), "La entrada muestra «¡BATALLA INICIADA!»")
	_comprobar(textos.has(tr(batalla.datos.nombre)), "La entrada presenta a la jefa por su nombre")
	_comprobar(textos.has(tr(batalla.datos.rugido)), "El rugido: «%s»" % tr(batalla.datos.rugido))
	_comprobar(batalla.presentacion.t < 5.0, "La entrada dura menos de 5 s (%.1f s)" % batalla.presentacion.t)
	_comprobar(batalla.presentacion.zooms_usados.keys().all(func(z: Variant) -> bool: return z is int) and is_equal_approx(fmod(batalla.presentacion.zoom_maximo, 1.0), 0.0), "B3 La entrada usa solo zooms enteros (%s)" % [batalla.presentacion.zooms_usados.keys()])
	_comprobar(batalla.presentacion.zoom_maximo >= 2.5, "La cámara se acerca como en Broforce (zoom %.1f)" % batalla.presentacion.zoom_maximo)
	_comprobar(oculta and gigante_maximo >= 1.0, "En la imaginación de Felipe, A.S.P.I. se vuelve gigante")
	_comprobar(sala.puertas["estudio<pasillo"].cerrada and subtitulos.has("…¿Quién cerró?"), "Sin vuelta atrás: la puerta se cierra sola («…¿Quién cerró?», como subtítulo de la presentación)")
	_comprobar(not dialogo_a_la_vista and not indicador_a_la_vista, "M4 Durante la presentación no se ven el cuadro de diálogo ni el Indicador")
	_comprobar(sala.travesuras.indicador.visible, "M4 Al terminar la presentación vuelve el Indicador")
	_comprobar(batalla.fase == BatallaAspi.Fase.PELEA and not paused and aspi.visible, "Tras la entrada sigue el juego con la A.S.P.I. real")
	await _esperar(70)
	_comprobar(batalla.gigante == 0.0 and batalla.transformacion == 0.0, "La imaginación se desvanece: el resto de la pelea se ve el estudio normal")
	_comprobar("Tira" in batalla.presentacion.pista_actual(), "El cartel de la fase 1 trae su pista de una línea")
	_comprobar(batalla.presentacion.vida == 1.0, "La barra de la jefa aparece llena")

	# Los zarpazos rebotan en la carcasa.
	aspi.global_position = Vector2(arena.position.x + 360, Nivel1.SUELO)
	await _zarpazo_a(aspi)
	_comprobar((aspi.vida.maximo - aspi.vida.actual) == 0 and not aspi.vida.muerto, "El zarpazo rebota en la carcasa")

	# Embestida anunciada: retrocede, luz roja 0,5 s y recién después carga (y solo entonces hace daño).
	await _poner_en(Vector2(arena.position.x + 200, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.NINGUNO, 200)
	felipe.vida.restante_invulnerable = 0.0
	aspi.global_position = Vector2(arena.position.x + 330, Nivel1.SUELO)
	(batalla.conducta("embestida") as AtaqueEmbestida).reloj_espera = 0.0
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.AVISO_EMBESTIDA, 120)
	_comprobar(batalla.ataque == BatallaAspi.Ataque.AVISO_EMBESTIDA and batalla.apariencia.luz_aviso.a > 0.0 and not aspi.dano.activo, "Antes de embestir avisa: luz roja que parpadea, inofensiva")
	await _esperar_que(func() -> bool: return batalla.ataque == BatallaAspi.Ataque.EMBESTIDA, 60)
	_comprobar(batalla.ataque == BatallaAspi.Ataque.EMBESTIDA and aspi.dano.activo, "Después de 0,5 s carga y ahí sí duele")
	felipe.vida.restante_invulnerable = 999.0
	await _esperar(60)

	# Ensuciar: una maceta rota deja una mancha y A.S.P.I. va a limpiarla (antes gira el cepillo).
	aspi.global_position = Vector2(arena.position.x + 80, Nivel1.SUELO)
	var maceta := _maceta()
	await _poner_en(maceta.global_position + Vector2(-16, 0))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return not batalla.manchas.is_empty(), 90)
	_comprobar(batalla.manchas.size() == 1, "La maceta rota deja una mancha en el piso")
	await _poner_en(Vector2(arena.position.x + 60, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return batalla.limpiar.reloj_aviso > 0.0, 800)
	_comprobar(batalla.limpiar.reloj_aviso > 0.0 and not batalla.limpiando, "Antes de aspirar, el cepillo gira 0,6 s (anticipación)")
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
	await _poner_en(Vector2(arena.position.x + 60, Nivel1.SUELO))
	await _esperar_que(func() -> bool: return batalla.deposito == 1, 300)
	_comprobar(batalla.deposito == 1 and batalla.presentacion.escudo > 0.0 and "+1 · Glup." in sala.travesuras.jugo.palabras, "Limpiar le llena el depósito (barra azul, «+1» y «Glup.»)")
	var pedazos := maceta.get_children().filter(func(n: Node) -> bool: return n is PiezaSuelta).size()
	await _esperar(8 * 60)
	_comprobar(maceta.visible and maceta.tirable.roto and maceta.position.y == Nivel1.SUELO and pedazos > 0 and maceta.get_children().filter(func(n: Node) -> bool: return n is PiezaSuelta).size() == pedazos, "Nada reaparece: 8 s después la maceta sigue rota en el piso, con sus %d pedazos" % pedazos)

	# Lleno: se detiene inofensiva; si nadie la apaga, lo vacía.
	await _llenar(batalla, aspi)
	_comprobar(batalla.llena and batalla.motivo == "deposito" and not aspi.dano.activo and batalla.presentacion.pista_actual() == "", "Con el depósito lleno se detiene, inofensiva, y el aviso nace sobre ella (no en la franja de arriba)")
	var tenia := batalla.deposito
	await _esperar_que(func() -> bool: return not batalla.llena, 400)
	_comprobar(not batalla.llena and batalla.deposito == 0 and batalla.apagados == 0, "Si nadie la apaga a tiempo, vacía el depósito y sigue")
	_comprobar(batalla.montanas.is_empty() and batalla.pelusa.en_camino == tenia and batalla.apariencia.vibrando, "Antes de escupir se sobrecarga 0,6 s (vibra, humo y chispas)")
	await _esperar_que(func() -> bool: return not batalla.montanas.is_empty(), 60)
	_comprobar(batalla.montanas.size() == 1 and batalla.montanas[0].cantidad == tenia and "¡BLORP!" in sala.travesuras.jugo.palabras, "…y lo vacía EN EL PISO: «¡BLORP!» y una montaña de pelusa con lo que tenía (%d)" % tenia)
	await _esperar_que(func() -> bool: return batalla.montanas.is_empty() or batalla.montanas[0].en_piso, 60)
	for vieja in batalla.montanas.duplicate():
		vieja.queue_free()
	await _esperar(2)

	# Saltarle encima con el depósito lleno la apaga: ¡CLIC!, fase 2, más rápida.
	await _llenar(batalla, aspi)
	await _caerle_encima(aspi)
	_comprobar(batalla.apagados == 1 and not batalla.llena, "Caerle encima le aprieta el botón: fase 2")
	_comprobar(batalla.reacciones.golpes == 1 and not batalla.reacciones.ultimo_final, "El piso tiembla: onda de choque, polvo, lo tirado brinca y sacudida vertical")
	_comprobar("¡CLIC!" in sala.travesuras.jugo.palabras, "Al apagarla: congelado, destello, sacudida y «¡CLIC!»")
	await _esperar(130)
	_comprobar(batalla.montanas.size() == 1 and batalla.montanas[0].cantidad == batalla.datos.devuelve[0] and batalla.montanas[0].en_piso, "Al terminar la fase se le abre el depósito y escupe una montaña de pelusa (%d motas)" % batalla.datos.devuelve[0])
	_comprobar(sala.ya_dijo("devolucion"), "Felipe la comenta: «Devolución aceptada.»")
	var dialogo: Dialogo = sala.travesuras.dialogo
	_comprobar(dialogo.globo == batalla.globo and not dialogo.ocupado() and _dijo("felipe", "Devolución aceptada"), "En la pelea, lo que piensa Felipe va en un globito sobre él (no en el cuadro de arriba)")
	var caja_globo := batalla.globo.rect_en_pantalla()
	_comprobar(not batalla.globo.visible_ahora() or (caja_globo.position.y >= ZonasTexto.HUD.end.y and ZonasTexto.PANTALLA.encloses(caja_globo)), "El globito no entra al HUD ni se sale de la pantalla (%s)" % caja_globo)
	# Esparcirla: el manotazo de siempre (burbuja «Esparcir») la deshace en motas que quedan como manchas.
	var montana: MontanaPelusa = batalla.montanas[0]
	var manchas_antes := batalla.manchas.size()
	(batalla.conducta("embestida") as AtaqueEmbestida).reloj_espera = 99.0
	# Cámara: con A.S.P.I. al otro lado del cuarto (fuera de pantalla), se corre hacia ella o marca el borde.
	var x_aspi := aspi.global_position.x
	aspi.global_position.x = arena.end.x - 60.0
	await _poner_en(Vector2(arena.position.x + 60.0, Nivel1.SUELO), 50)
	_comprobar(batalla.camara.corrida > 40.0, "Con A.S.P.I. fuera de pantalla, la cámara se corre hacia ella (%.0f px, sin zoom: pixel art entero)" % batalla.camara.corrida)
	aspi.global_position.x = x_aspi
	await _poner_en(montana.global_position + Vector2(-20, 0))
	felipe.mirando = 1.0
	_comprobar(felipe.manas.objeto_cercano() == montana and tr(montana.verbo(felipe)) == "Esparcir", "Junto a la montaña, la burbuja dice «Esparcir»")
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return batalla.manchas.size() >= manchas_antes + 2 or batalla.deposito > 0, 120)
	_comprobar(montana.esparcida and "¡FUP!" in sala.travesuras.jugo.palabras and batalla.manchas.size() + batalla.deposito >= manchas_antes + 2, "Un manotazo la esparce («¡FUP!») y quedan 2 motas de pelusa que cuentan como manchas")
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	batalla.deposito = 0
	(batalla.conducta("embestida") as AtaqueEmbestida).reloj_espera = 2.0
	_comprobar(aspi.patrulla.velocidad_persecucion > batalla.datos.velocidad[0], "En la fase 2 es más rápida")

	# Contra el que acampa (G12): quieto en la repisa, A.S.P.I. lo saca en 4 s o menos, sin daño.
	aspi.global_position = Vector2(arena.position.x + 70, Nivel1.SUELO)
	var repisa := sala.pieza("Repisa de las macetas")
	var corazones := felipe.corazones
	await _poner_en(Vector2(repisa.position.x + 30, repisa.position.y), 2)
	var cuadros := 0
	var aviso_amarillo := false
	while cuadros < 300 and batalla.soplidos == 0:
		await physics_frame
		cuadros += 1
		aviso_amarillo = aviso_amarillo or (batalla.ataque == BatallaAspi.Ataque.AVISO_SOPLIDO and batalla.apariencia.vibrando)
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 2.0, 120)
	_comprobar(batalla.soplidos >= 1 and felipe.global_position.y > Nivel1.SUELO - 2.0 and cuadros <= 240, "Quieto en la repisa, A.S.P.I. lo saca de un soplido en %.1f s (≤ 4 s)" % (cuadros / 60.0))
	_comprobar(aviso_amarillo, "Antes del soplido avisa 0,6 s: vibra con luz amarilla")
	_comprobar(felipe.corazones == corazones, "El soplido no hace daño")
	# Segundo apagado cayendo a la velocidad máxima (~12 px por cuadro): no atraviesa la franja de su tapa.
	await _llenar(batalla, aspi)
	var caida := await _caerle_encima_rapido(aspi)
	_comprobar(caida >= felipe.caida_maxima - 1.0, "Llega a la tapa cayendo a la velocidad máxima (%.0f px/s)" % caida)
	_comprobar(batalla.apagados == 2, "Segundo apagado: fase 3 (furia), aunque caiga a la velocidad máxima")

	# Fase 3: tose y escupe bolas de pelo en arco que llegan arriba (al escritorio).
	# M8: sin azar ni carreras. Felipe queda en el escritorio, lejos del teclado (pisarlo suelta papeles en lugares al
	# azar) y A.S.P.I. lejos; se espera el ESTADO (tos y bola alta), no un tiempo fijo.
	# Clímax de la fase 3: corre contra el enchufe, cortocircuito y apagón; siempre queda al menos un charco.
	var corto := batalla.conducta("cortocircuito") as ConductaCortocircuito
	await _esperar_que(func() -> bool: return corto.corriendo, 300)
	_comprobar(corto.corriendo and batalla.amenaza(), "Fase 3: A.S.P.I. arranca contra el enchufe (la cámara la mira: amenaza)")
	await _esperar_que(func() -> bool: return corto.hecho, 300)
	await _esperar(60)
	_comprobar(corto.hecho and batalla.apagon.activo and not corto.charcos().is_empty() and "¡BZZZT!" in sala.travesuras.jugo.palabras, "Cortocircuito: «¡BZZZT!», se corta la luz y hay al menos un charco (%d)" % corto.charcos().size())
	var ambiente: CanvasModulate = sala.find_children("*", "CanvasModulate", true, false)[0]
	_comprobar(ambiente.color.v < 0.7, "En el apagón el cuarto queda en penumbra (no negro: %.2f)" % ambiente.color.v)
	# Pasar por un charco la deja en corto: vulnerable como con el depósito lleno.
	await _esperar_que(func() -> bool: return batalla.reinicio <= 0.0 and not batalla.llena, 300)
	var charco: Vector2 = corto.charcos()[0]
	corto.reloj_charco = 0.0
	aspi.global_position = Vector2(charco.x - 80.0, Nivel1.SUELO)
	aspi.patrulla.destino = charco.x + 60.0
	await _esperar_que(func() -> bool: return batalla.llena, 200)
	_comprobar(batalla.llena and batalla.motivo == "charco" and not aspi.dano.activo, "Pasar por un charco la electrocuta: queda en corto, vulnerable")
	await _esperar_que(func() -> bool: return not batalla.llena, 400)
	_comprobar(not batalla.llena and batalla.apagados == 2 and batalla.montanas.size() <= 1, "Si nadie la apaga, se le pasa el corto (no escupe pelusa)")
	await _esperar_que(func() -> bool: return batalla.reinicio <= 0.0 and batalla.ataque == BatallaAspi.Ataque.NINGUNO, 300)
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	for sobra in batalla.montanas.duplicate():
		sobra.queue_free()
	aspi.patrulla.velocidad_patrulla = 0.0
	aspi.global_position = Vector2(arena.position.x + 40, Nivel1.SUELO)
	await _poner_en(Vector2(arena.position.x + 380, Nivel1.SUELO - 98), 2)
	felipe.vida.restante_invulnerable = 0.0
	corazones = felipe.corazones
	var tosio := false
	var alta := false
	for i in 600:
		await physics_frame
		tosio = tosio or batalla.ataque == BatallaAspi.Ataque.AVISO_BOLA
		for bola in batalla.bolas:
			alta = alta or bola.global_position.y < Nivel1.SUELO - 110.0
		if felipe.corazones < corazones:
			break
	_comprobar(tosio and alta, "En furia tose y la bola de pelo va en arco hasta arriba")
	var bola_datos := batalla.conducta("bola") as AtaqueBolaPelo
	_comprobar(bola_datos.objetivo.distance_to(Vector2(arena.position.x + 380, Nivel1.SUELO - 98)) < 4.0, "La bola apunta a la marca del piso (donde estaba Felipe al toser)")
	_comprobar(felipe.corazones < corazones, "La bola de pelo quita un corazón aunque esté en el escritorio")
	felipe.vida.restante_invulnerable = 999.0

	# Perder una vida: reaparece en el cojín, A.S.P.I. conserva la fase y al volver la entrada es corta (1 s).
	var cojin: Rect2 = Nivel1.DESCANSOS[1]
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
	await _poner_en(Vector2(arena.position.x + 120, Nivel1.SUELO))
	aspi.global_position = Vector2(arena.position.x + 400, Nivel1.SUELO)
	(batalla.conducta("embestida") as AtaqueEmbestida).reloj_espera = 99.0
	(batalla.conducta("bola") as AtaqueBolaPelo).reloj_espera = 99.0
	await _tocar("maullar")
	await _esperar(30)
	_comprobar("¿Gato detectado?" in sala.travesuras.jugo.palabras, "Al maullar, A.S.P.I. gira hacia Felipe: «¿Gato detectado?»")

	# Tercer apagado: se apaga del todo.
	await _llenar(batalla, aspi)
	await _caerle_encima(aspi)
	await _esperar_que(func() -> bool: return felipe.estado == Felipe.Estado.OCIO, 200)
	_comprobar(felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation == "jugar", "Felipe celebra jugando con el estambre (alegre y juguetón)")
	_comprobar(aspi.vida.muerto and batalla.fase == BatallaAspi.Fase.FIN, "Al tercer apagado, A.S.P.I. se apaga del todo")
	_comprobar(batalla.reacciones.ultimo_final and batalla.reacciones.despertares >= 3, "El golpe final es el más fuerte; al entrar y al volver de cada fase se despertó (pitido, luz roja, «!» y pausa: %d)" % batalla.reacciones.despertares)
	_comprobar(not sala.puertas[Nivel1.PUERTA_BALCON].cerrada and "Desenchufada" in sala.logros and sala.travesuras.agenda.esta_cumplida("desenchufar"), "Se abre la puerta del balcón (travesura «desenchufar» y logro)")
	_comprobar(Engine.time_scale == 1.0 and not sala.puertas["estudio<pasillo"].cerrada, "Todo vuelve de golpe a la normalidad")
	_comprobar(not batalla.apagon.activo and ambiente.color.v > 0.9, "Al apagarla por última vez vuelve la luz de golpe")
	_comprobar(sala.travesuras.dialogo.globo == null, "Terminada la pelea, Felipe vuelve a hablar en el cuadro de siempre")
	await _esperar_que(func() -> bool: return batalla.nota >= 0, 60 * 15)
	_comprobar(batalla.nota >= 0 and batalla.nota <= 100, "Al final sale la nota de «Arte gatuno» (%d %%: %s)" % [batalla.nota, tr(NotaArteGatuno.rango(batalla.nota))])
	await _poner_en(Vector2(arena.position.x + 330, Nivel1.SUELO))
	await _esperar(70)
	_comprobar(batalla.bolas.is_empty() and batalla.presentacion.pista_actual() in ["", tr(NotaArteGatuno.rango(batalla.nota))], "No quedan bolas ni pistas de pelea (solo la nota de «Arte gatuno»)")

	# La presentación es reutilizable: sirve igual para otro jefe cualquiera (cada uno solo da sus datos).
	var otro := Node2D.new()
	otro.position = Vector2(arena.position.x + 200, Nivel1.SUELO)
	sala.add_child(otro)
	var presentacion := PresentacionJefe.new("EL CARTERO", "Timbre del Terror · Nivel 12")
	presentacion.imaginacion = false
	presentacion.texto_rugido = "¡CORRESPONDENCIA!"
	presentacion.pantallas = sala.pantallas
	sala.add_child(presentacion)
	await physics_frame
	var pasos_cartero := []
	presentacion.paso_empezado.connect(func(paso: String) -> void: pasos_cartero.append(paso))
	presentacion.presentar(felipe, otro, Rect2(arena.position.x, 0, 640, Nivel1.ALTO))
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


func _maceta() -> Objeto:
	for hijo in sala.get_children():
		if hijo is Objeto and hijo.tipo == "maceta" and not hijo.tirable.roto and hijo.visible:
			return hijo
	return null


## Le deja el depósito a una mancha de llenarse y le pone esa mancha al lado (más rápido que tirar macetas).
func _llenar(batalla: BatallaAspi, aspi: Enemigo) -> void:
	await _poner_en(Vector2(Nivel1.rect_de("estudio").position.x + 60, Nivel1.SUELO), 2)
	batalla.deposito = batalla.datos.capacidad[batalla.apagados] - 1
	batalla.agregar_mancha(aspi.global_position)
	await _esperar_que(func() -> bool: return batalla.llena, 400)


## Felipe cae sobre A.S.P.I. desde un poco más arriba que su tapa.
func _caerle_encima(aspi: Enemigo) -> void:
	await _esperar(20)
	felipe.global_position = aspi.global_position + Vector2(0, -62)
	felipe.velocity = Vector2.ZERO
	await _esperar(60)


## Felipe cae sobre A.S.P.I. desde lo alto ya a la velocidad máxima de caída; devuelve la velocidad de caída del
## último cuadro antes de apagarla.
func _caerle_encima_rapido(aspi: Enemigo) -> float:
	await _esperar(20)
	felipe.global_position = aspi.global_position + Vector2(0, -BatallaAspi.ALTO_ARRIBA - 140.0)
	felipe.velocity = Vector2(0, felipe.caida_maxima)
	var antes := guion.batalla.apagados
	var velocidad := 0.0
	for i in 60:
		velocidad = felipe.velocity.y
		await physics_frame
		if guion.batalla.apagados > antes:
			break
	await _esperar(40)
	return velocidad


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


## Nodos del nivel que se dibujan con un z igual o mayor que la imaginación, fuera de la imaginación misma, Felipe y los
## efectos de la batalla (viento, papeles, polvo, bolas).
func _encima_de_la_imaginacion(batalla: BatallaAspi) -> Array[String]:
	var lista: Array[String] = []
	# El z con que se dibuja DE VERDAD la imaginación (no el de la tabla): así la prueba falla si alguien la baja.
	var z_imaginacion := Capas.z_efectivo(batalla.get_node("Imaginacion"))
	var pendientes: Array[Node] = [sala]
	while not pendientes.is_empty():
		var nodo: Node = pendientes.pop_back()
		if nodo is CanvasLayer:
			continue
		for hijo in nodo.get_children():
			pendientes.append(hijo)
		if not nodo is CanvasItem or nodo == sala:
			continue
		var item := nodo as CanvasItem
		if not item.is_visible_in_tree() or Capas.z_efectivo(item) < z_imaginacion:
			continue
		if item == felipe or felipe.is_ancestor_of(item) or batalla.is_ancestor_of(item):
			continue
		lista.append(String(item.name))
	return lista


func _tabla_ordenada() -> bool:
	for tabla: Array in [Capas.MUNDO, Capas.PANTALLA]:
		for i in range(1, tabla.size()):
			if int(tabla[i][1]) < int(tabla[i - 1][1]):
				return false
	return true


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
