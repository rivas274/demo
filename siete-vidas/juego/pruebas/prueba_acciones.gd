extends SceneTree
## Prueba de las acciones nuevas de Felipe y de los sistemas reutilizables del nivel (PARTE A del nivel 1 v4):
## habilidades apagadas, maullar, arañar y manotazo en el cuadro de impacto, comer un snack del bolsillo,
## bolsillo de 5, subir escalones, rascador con y sin testigo, garras afiladas → crítico, Agenda, recompensas,
## libreta, resumen, diálogo sin repetir e Indicador.
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_acciones.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []
var sala: Sala
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.peligros_activos = false
	sala.batalla_con_jefe = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	for enemigo in root.get_tree().get_nodes_in_group("enemigos"):
		enemigo.queue_free()
	# Valeria (la del nivel) se va a la cocina: aquí los testigos son de prueba (su escena tiene prueba_nivel).
	sala.valeria.poner(Sala.VALERIA_COCINA, "cocina", -1.0, Valeria.Actividad.DE_PIE)
	await _esperar(30)

	await _probar_habilidades()
	await _probar_maullar()
	await _probar_aranar()
	await _probar_manotazo()
	await _probar_snacks()
	await _probar_escalera()
	await _probar_rascador()
	await _probar_frotarse()
	await _probar_agenda()
	await _probar_dialogo()
	await _probar_indicador()

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## Doble salto, Zoomies y trepar vienen apagados en el nivel 1 (decisión del creador, 2026-10-19).
func _probar_habilidades() -> void:
	_comprobar(not felipe.tiene_doble_salto and not felipe.tiene_zoomies and not felipe.puede_trepar, "En el nivel 1 el doble salto, los Zoomies y trepar vienen apagados")
	await _poner_en(Vector2(120, Sala.SUELO))
	var y_suelo := felipe.global_position.y
	Input.action_press("saltar")
	await _esperar(8)
	Input.action_release("saltar")
	await _esperar(6)
	Input.action_press("saltar")
	await _esperar(3)
	Input.action_release("saltar")
	var mas_alto := y_suelo
	for i in 80:
		await physics_frame
		mas_alto = minf(mas_alto, felipe.global_position.y)
		if felipe.is_on_floor() and i > 10:
			break
	_comprobar(y_suelo - mas_alto < 95.0, "Sin doble salto, saltar otra vez en el aire no lo sube más (%.0f px)" % (y_suelo - mas_alto))
	await _esperar(20)
	var x_antes := felipe.global_position.x
	await _tocar("zoomies")
	await _esperar(6)
	_comprobar(felipe.estado != Felipe.Estado.ZOOMIES and absf(felipe.global_position.x - x_antes) < 10.0, "Sin Zoomies, tocar Shift no da el impulso")
	# La cortina del dormitorio es un lugar visto: sin Afilar Garras no se trepa.
	await _poner_en(Vector2(6355, Sala.SUELO))
	Input.action_press("mover_arriba")
	await _esperar(30)
	Input.action_release("mover_arriba")
	_comprobar(not felipe.trepando, "Sin Afilar Garras no trepa la cortina")


func _probar_maullar() -> void:
	await _poner_en(Vector2(120, Sala.SUELO))
	var cerca := _oyente(Vector2(220, Sala.SUELO))
	var lejos := _oyente(Vector2(120 + Felipe.RADIO_MAULLIDO + 60, Sala.SUELO))
	var maullidos: Array[int] = []
	var al_maullar := func(_boca: Vector2) -> void: maullidos.append(felipe.sprite.frame)
	felipe.maullo.connect(al_maullar)
	Input.action_press("maullar")
	await _esperar(2)
	Input.action_release("maullar")
	_comprobar(felipe.estado == Felipe.Estado.MAULLANDO and felipe.sprite.animation == "maullar", "Q (B en el mando) maúlla con su animación")
	var antes_de_tiempo := false
	for i in 90:
		await physics_frame
		if felipe.sprite.animation == "maullar" and felipe.sprite.frame < Felipe.CUADRO_MAULLIDO and not maullidos.is_empty():
			antes_de_tiempo = true
		if felipe.estado != Felipe.Estado.MAULLANDO:
			break
	felipe.maullo.disconnect(al_maullar)
	_comprobar(maullidos.size() == 1 and maullidos[0] == Felipe.CUADRO_MAULLIDO and not antes_de_tiempo, "El maullido sale en el cuadro de la boca abierta (%s)" % [maullidos])
	_comprobar(int(cerca.get_meta("oidos")) == 1 and int(lejos.get_meta("oidos")) == 0, "Lo oye quien está cerca (pieza OyeMaullido), no quien está lejos")
	_comprobar(felipe.estado == Felipe.Estado.SUELO, "Después de maullar vuelve a quedar libre")
	_comprobar("¡MIAU!" in sala.travesuras.jugo.palabras, "Al maullar salta la palabra ¡MIAU!")
	cerca.queue_free()
	lejos.queue_free()


## Arañar el sofá: las marcas salen en los cuadros de impacto, no al apretar. Con las garras afiladas, crítico.
func _probar_aranar() -> void:
	var sofa: Aranable = sala.get_node("Sofa arañable")
	await _poner_en(Vector2(300, Sala.SUELO))
	_comprobar(felipe.objeto_cercano() == sofa, "Frente al sofá, el botón de acción lo araña")
	await _tocar("interactuar")
	_comprobar(felipe.estado == Felipe.Estado.ARANANDO and felipe.sprite.animation == "aranar", "Arañar usa su animación (de pie en dos patas)")
	var antes_de_tiempo := false
	var primera := -1
	for i in 90:
		await physics_frame
		if felipe.sprite.animation == "aranar" and felipe.sprite.frame < Felipe.CUADROS_IMPACTO_ARANAR[0] and sofa.marcas.size() > 0:
			antes_de_tiempo = true
		if primera < 0 and sofa.marcas.size() > 0:
			primera = felipe.sprite.frame
		if felipe.estado != Felipe.Estado.ARANANDO:
			break
	_comprobar(not antes_de_tiempo and primera == Felipe.CUADROS_IMPACTO_ARANAR[0], "Las marcas salen cuando bajan las garras (cuadro %d)" % primera)
	_comprobar(sofa.aranazos == 2 and not sofa.esta_roto, "Un arañazo son dos pasadas de garra y el plástico aguanta (%d)" % sofa.aranazos)
	# Garras afiladas: duran duracion_garras y el siguiente arañazo es crítico.
	var duracion := felipe.duracion_garras
	felipe.duracion_garras = 0.3
	felipe.afilar_garras()
	await _esperar(30)
	_comprobar(felipe.garras_afiladas == 0.0, "Las garras afiladas se acaban solas")
	felipe.duracion_garras = duracion
	felipe.afilar_garras()
	var criticos: Array[bool] = []
	var al_aranar := func(_o: Node2D, critico: bool) -> void: criticos.append(critico)
	felipe.aranazo.connect(al_aranar)
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return felipe.estado != Felipe.Estado.ARANANDO, 90)
	felipe.aranazo.disconnect(al_aranar)
	_comprobar(criticos.size() == 2 and criticos[0] and not criticos[1], "Con las garras afiladas el primer arañazo es CRÍTICO y gasta el filo (%s)" % [criticos])
	_comprobar(sofa.esta_roto, "El arañazo crítico rompe el plástico de un golpe")
	_comprobar("¡CRÍTICO!" in sala.travesuras.jugo.palabras, "El crítico hace saltar ¡CRÍTICO!")
	var agenda := sala.travesuras.agenda
	_comprobar(agenda.esta_cumplida("sofa"), "Romper el plástico cumple «Arañar el sofá nuevo» de la agenda")
	await _esperar(40)
	var calcetin: Recogible = null
	for hijo in sala.get_children():
		if hijo is Recogible and hijo.tipo == "calcetin":
			calcetin = hijo
	_comprobar(calcetin != null and calcetin.quieto, "El calcetín sale volando y queda sobre algo pisable")
	if calcetin:
		await _poner_en(calcetin.global_position)
		await _esperar(10)
	_comprobar(sala.travesuras.recompensas.calcetines == 1, "Felipe recoge el calcetín al pasar y va al nido (%d)" % sala.travesuras.recompensas.calcetines)
	_comprobar(sala.travesuras.hud.carteles.size() >= 1 and sala.travesuras.hud.carteles[0][0] == "¡TRAVESURA CUMPLIDA!", "Sale el cartel «¡TRAVESURA CUMPLIDA!»")


## El vaso sale volando cuando la pata llega (cuadro 4 de zarpazo), no al apretar (hallazgo B5).
func _probar_manotazo() -> void:
	var vaso: Objeto = sala.get_node("Vaso")
	await _poner_en(Vector2(vaso.global_position.x - 30, vaso.global_position.y))
	felipe.mirando = 1.0
	var inicio := vaso.global_position
	await _tocar("interactuar")
	_comprobar(felipe.sprite.animation == "zarpazo", "El manotazo usa la animación del zarpazo")
	var antes_de_tiempo := false
	var cuadro_al_moverse := -1
	for i in 60:
		await physics_frame
		var movido := vaso.global_position.distance_to(inicio) > 0.5
		if movido and cuadro_al_moverse < 0:
			cuadro_al_moverse = felipe.sprite.frame
		if felipe.sprite.animation == "zarpazo" and felipe.sprite.frame < Felipe.CUADRO_IMPACTO_ZARPAZO and movido:
			antes_de_tiempo = true
	_comprobar(not antes_de_tiempo and cuadro_al_moverse >= Felipe.CUADRO_IMPACTO_ZARPAZO, "El vaso no se mueve antes del cuadro de impacto (se movió en el cuadro %d)" % cuadro_al_moverse)
	_comprobar(felipe.ultimo_impacto.get("animacion", "") == "zarpazo" and felipe.ultimo_impacto.get("cuadro", -1) == Felipe.CUADRO_IMPACTO_ZARPAZO, "El impacto quedó en el cuadro %d" % Felipe.CUADRO_IMPACTO_ZARPAZO)
	await _esperar(60)
	_comprobar(vaso.tirable.roto and "La Gravedad Funciona" in sala.logros, "El vaso cae, se rompe y da el logro")


## Mantener la acción 0,6 s sin nada cerca come un snack del bolsillo: cura 1 corazón y suma 0,3 kg.
func _probar_snacks() -> void:
	await _poner_en(Vector2(120, Sala.SUELO))
	_comprobar(felipe.objeto_cercano() == null, "Lejos de todo no hay nada que usar")
	felipe.snacks = 3
	felipe.corazones = 3
	var peso := felipe.peso
	Input.action_press("interactuar")
	await _esperar(18)
	_comprobar(felipe.estado == Felipe.Estado.SUELO and felipe.progreso_comer_snack() > 0.3, "Mantener la acción va cargando el snack (%.0f %%)" % (felipe.progreso_comer_snack() * 100.0))
	Input.action_release("interactuar")
	await _esperar(10)
	_comprobar(felipe.snacks == 3 and felipe.estado == Felipe.Estado.SUELO, "Soltar antes de 0,6 s no come")
	Input.action_press("interactuar")
	await _esperar(int(Felipe.TIEMPO_COMER_SNACK * 60.0) + 4)
	_comprobar(felipe.estado == Felipe.Estado.COMIENDO and felipe.sprite.animation == "comer", "Mantener 0,6 s sin nada cerca come un snack")
	_comprobar(felipe.snacks == 3, "El snack se descuenta cuando la boca llega, no antes")
	Input.action_release("interactuar")
	await _esperar_que(func() -> bool: return felipe.estado != Felipe.Estado.COMIENDO, 120)
	_comprobar(felipe.snacks == 2 and felipe.corazones == 4 and is_equal_approx(felipe.peso, peso + Felipe.PESO_POR_COMIDA), "El snack cura 1 corazón y suma 0,3 kg (snacks %d, corazones %d)" % [felipe.snacks, felipe.corazones])
	_comprobar("¡ÑAM!" in sala.travesuras.jugo.palabras, "Comer el snack hace saltar ¡ÑAM!")
	felipe.snacks = 0
	var avisos := [0]
	var al_no_tener := func() -> void: avisos[0] += 1
	felipe.sin_snacks.connect(al_no_tener)
	Input.action_press("interactuar")
	await _esperar(int(Felipe.TIEMPO_COMER_SNACK * 60.0) + 4)
	Input.action_release("interactuar")
	felipe.sin_snacks.disconnect(al_no_tener)
	_comprobar(avisos[0] == 1 and felipe.estado == Felipe.Estado.SUELO, "Con el bolsillo vacío no come y avisa (sin_snacks)")
	# Bolsillo de 5.
	felipe.snacks = 3
	var guardados := [felipe.guardar_snack(), felipe.guardar_snack(), felipe.guardar_snack()]
	_comprobar(guardados == [true, true, false] and felipe.snacks == Felipe.SNACKS_MAX, "El bolsillo guarda 5 snacks como máximo")
	var llenos := [0]
	var al_llenarse := func() -> void: llenos[0] += 1
	var recompensas := sala.travesuras.recompensas
	recompensas.bolsillo_lleno.connect(al_llenarse)
	var entraron := recompensas.dar({"tipo": "snack", "cantidad": 2})
	recompensas.bolsillo_lleno.disconnect(al_llenarse)
	_comprobar(entraron == 0 and llenos[0] == 1, "Un snack con el bolsillo lleno no entra (avisa bolsillo_lleno)")
	felipe.snacks = 2
	_comprobar(recompensas.dar({"tipo": "snack", "cantidad": 2}) == 2 and felipe.snacks == 4, "Las recompensas de snack van al bolsillo")
	await _esperar(10)


## API de la escalera: un ciclo de "subir_escalera" por escalón, con saltito, hasta el último peldaño.
func _probar_escalera() -> void:
	await _poner_en(Vector2(120, Sala.SUELO))
	var peldanos: Array[Vector2] = []
	for i in 3:
		peldanos.append(Vector2(120 + 20 * (i + 1), Sala.SUELO - 21 * (i + 1)))
	var subidos: Array[int] = []
	var terminadas := [0]
	var al_subir := func(n: int) -> void: subidos.append(n)
	var al_terminar := func() -> void: terminadas[0] += 1
	felipe.escalon_subido.connect(al_subir)
	felipe.escalera_terminada.connect(al_terminar)
	var posicion_al_terminar := [Vector2.ZERO]
	var guardar := func() -> void: posicion_al_terminar[0] = felipe.global_position
	felipe.escalera_terminada.connect(guardar)
	felipe.subir_escalera(peldanos)
	_comprobar(felipe.en_escalera() and felipe.sprite.animation == "subir_escalera" and felipe.sprite.is_playing(), "subir_escalera() usa la animación de subir")
	var cuadros_primer_escalon := {}
	var mas_alto_que_la_linea := false
	for i in 120:
		await physics_frame
		if subidos.is_empty() and felipe.sprite.animation == "subir_escalera":
			cuadros_primer_escalon[felipe.sprite.frame] = true
			# Por encima de la recta entre el piso y el primer peldaño: el saltito.
			var en_linea := Sala.SUELO - 21.0 * clampf((felipe.global_position.x - 120.0) / 20.0, 0.0, 1.0)
			if felipe.global_position.y < en_linea - 3.0:
				mas_alto_que_la_linea = true
		if terminadas[0] > 0:
			break
	felipe.escalon_subido.disconnect(al_subir)
	felipe.escalera_terminada.disconnect(al_terminar)
	felipe.escalera_terminada.disconnect(guardar)
	_comprobar(subidos == [1, 2, 3] and terminadas[0] == 1, "Sube escalón por escalón y avisa al terminar (%s)" % [subidos])
	_comprobar(cuadros_primer_escalon.size() >= 6, "Cada escalón es un ciclo de la animación (%d cuadros vistos)" % cuadros_primer_escalon.size())
	_comprobar(mas_alto_que_la_linea, "Da un saltito por escalón")
	_comprobar(posicion_al_terminar[0].distance_to(peldanos[-1]) < 1.0, "Termina en el último peldaño")
	_comprobar(not felipe.en_escalera() and felipe.sprite.speed_scale == 1.0, "Al terminar vuelve a moverse normal")
	# Bajar un escalón: mismos saltitos con los cuadros de saltar y caer.
	await _poner_en(Vector2(120, Sala.SUELO))
	felipe.global_position = Vector2(120, Sala.SUELO - 21)
	felipe.subir_escalon(Vector2(140, Sala.SUELO))
	await _esperar(9)
	_comprobar(felipe.sprite.animation in ["saltar", "caer"], "Bajando usa los cuadros de saltar y caer")
	await _esperar(20)
	_comprobar(not felipe.en_escalera(), "Termina de bajar")


## Rascador: con público, perdón + snack una vez por visita; sin público, queja; siempre afila las garras.
func _probar_rascador() -> void:
	var rascador := Rascador.new()
	rascador.position = Vector2(1010, Sala.SUELO)
	sala.add_child(rascador)
	sala.travesuras.conectar_rascador(rascador)
	var funciones: Array = []
	rascador.funcion.connect(func(_r: Rascador, publico: bool, premio: bool, _t: Node) -> void: funciones.append([publico, premio]))
	await _poner_en(Vector2(1040, Sala.SUELO))
	felipe.snacks = 2
	_comprobar(felipe.objeto_cercano() == rascador, "Junto al rascador, el botón de acción lo usa (verbo «%s»)" % rascador.verbo(felipe))
	await _usar_rascador()
	_comprobar(funciones.size() == 1 and funciones[0] == [false, false], "Sin público: función sin premio (%s)" % [funciones])
	_comprobar(felipe.snacks == 2 and felipe.garras_afiladas > 0.0, "Sin público no hay snack, pero las garras quedan afiladas")
	_comprobar(_dijo("felipe", Frases.FELIPE["rascador_solo"]), "Sin público Felipe se queja («¿Para quién actúo?»)")
	var testigo := _testigo()
	sala.add_child(testigo)
	testigo.global_position = Vector2(1100, Sala.SUELO)
	await _usar_rascador()
	_comprobar(funciones.size() == 2 and funciones[1] == [true, true], "Con un testigo mirando: perdón y premio")
	_comprobar(felipe.snacks == 3 and int(testigo.get("perdones")) == 1, "El premio es un snack al bolsillo y el testigo lo perdona")
	_comprobar(sala.travesuras.perdones == 1 and "¡OVACIÓN!" in sala.travesuras.jugo.palabras, "El perdón cuenta para el resumen y sale ¡OVACIÓN!")
	await _usar_rascador()
	_comprobar(funciones[2] == [true, false] and felipe.snacks == 3, "Otra vez en la misma visita: sin premio (el bis no se cobra)")
	testigo.set("visita", 1)
	await _usar_rascador()
	_comprobar(funciones[3] == [true, true] and felipe.snacks == 4, "En la visita siguiente vuelve a haber premio")
	testigo.set("mirando", false)
	await _usar_rascador()
	_comprobar(funciones[4] == [false, false], "Si el testigo no mira, no hay público")
	testigo.queue_free()
	rascador.queue_free()
	await _esperar(5)


func _usar_rascador() -> void:
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return felipe.estado != Felipe.Estado.ARANANDO, 120)
	await _esperar(4)


func _probar_agenda() -> void:
	var agenda := Agenda.new()
	_comprobar(agenda.total() == 8 and agenda.total_secretas() == 3, "La agenda del nivel 1 tiene 8 travesuras, 3 secretas")
	_comprobar(agenda.cuartos() == ["sala", "recibidor", "cocina", "pasillo", "dormitorio", "estudio"], "Agrupada por cuarto, en el orden de la ruta")
	_comprobar(agenda.nombre_visible("popo") == "???" and agenda.texto_recompensa("popo") == "???", "Las secretas dicen «???» hasta cumplirlas")
	var cumplidas: Array = []
	agenda.cumplida.connect(func(t: Dictionary) -> void: cumplidas.append(t["id"]))
	_comprobar(agenda.avanzar("popo") and cumplidas == ["popo"], "avanzar() cumple la travesura y avisa")
	_comprobar(agenda.nombre_visible("popo") == "Popo táctico en la arena recién limpiada", "Al cumplirla, la secreta se revela")
	_comprobar(not agenda.avanzar("popo") and cumplidas.size() == 1, "Una travesura se cumple una sola vez")
	var doble := Agenda.new([{"id": "dos", "nombre": "Dos veces", "cuarto": "sala", "secreta": false, "meta": 2, "recompensa": {"tipo": "foto", "cantidad": 1, "texto": "Foto"}}])
	var progresos := [0]
	doble.progreso.connect(func(_t: Dictionary) -> void: progresos[0] += 1)
	_comprobar(not doble.avanzar("dos") and progresos[0] == 1 and doble.avanzar("dos") and doble.completa(), "Las de varias veces avanzan y se cumplen al llegar a la meta")
	# Recompensas: nido (cada 10 calcetines una ranura), galería y caminos.
	var recompensas := Recompensas.new(felipe)
	var ranuras := [0]
	recompensas.ranura_ganada.connect(func(_n: int) -> void: ranuras[0] += 1)
	recompensas.dar({"tipo": "calcetin", "cantidad": 12})
	_comprobar(recompensas.ranuras() == 1 and ranuras[0] == 1 and recompensas.texto_ranura() == "2/10 para tu próxima ranura", "Cada 10 calcetines del nido, una ranura de maña (%s)" % recompensas.texto_ranura())
	var caminos: Array = []
	recompensas.camino_abierto.connect(func(id: String) -> void: caminos.append(id))
	recompensas.dar({"tipo": "camino", "id": "balcon"})
	recompensas.dar({"tipo": "foto", "cantidad": 1})
	_comprobar(caminos == ["balcon"] and recompensas.fotos == 1, "Los caminos se avisan y las fotos van a la galería")
	# A través del nivel: travesura secreta sin lugar → recompensa directa y cartel secreto.
	var travesuras := sala.travesuras
	var fotos_antes := travesuras.recompensas.fotos
	_comprobar(travesuras.cumplir("laser"), "El nivel cumple una travesura con cumplir(id)")
	_comprobar(travesuras.recompensas.fotos == fotos_antes + 1, "Sin lugar para soltarla, la recompensa se entrega directo")
	_comprobar(travesuras.hud.carteles[-1] == ["¡TRAVESURA SECRETA!", "Ignorar el láser"], "Las secretas sacan «¡TRAVESURA SECRETA!»")
	# Libreta: Tab la abre y pausa; otra vez la cierra.
	await _esperar(5)
	await _tocar_en_pausa("agenda")
	_comprobar(travesuras.libreta.abierta and paused, "Tab abre la libreta y pausa el juego")
	await _tocar_en_pausa("agenda")
	_comprobar(not travesuras.libreta.abierta and not paused, "Tab otra vez la cierra")
	# Resumen del día tipo Balatro.
	var resumen := travesuras.mostrar_resumen()
	await process_frame
	_comprobar(paused and resumen.filas.size() == 6 and int(resumen.filas[0][1]) == travesuras.agenda.cumplidas(), "El resumen del día cuenta travesuras, secretas, calcetines, fotos, snacks y perdones")
	resumen.cerrar()
	await process_frame
	_comprobar(not paused, "Al cerrar el resumen sigue el juego")


func _probar_dialogo() -> void:
	var dialogo := sala.travesuras.dialogo
	dialogo.limpiar()
	await _esperar(2)
	_comprobar(dialogo.decir("felipe", "Prueba uno."), "El diálogo muestra una frase")
	_comprobar(not dialogo.decir("felipe", "Prueba uno."), "No repite la misma frase seguida")
	_comprobar(dialogo.decir("valeria", "Prueba dos.", Dialogo.VALERIA_ENOJADA) and dialogo.texto_actual == "Prueba uno.", "Mientras habla alguien, la frase siguiente espera en la cola única")
	dialogo.saltar()
	dialogo.saltar()
	_comprobar(dialogo.hablando == "valeria" and dialogo.texto_actual == "Prueba dos.", "Saltar pasa a la frase de la cola (Valeria, con su retrato)")
	_comprobar(dialogo._retrato.visible and dialogo._retrato.texture != null, "Valeria usa su retrato de la hoja de Gemini")
	var caducidad := dialogo.caducidad_cola
	dialogo.caducidad_cola = 0.1
	dialogo.decir("felipe", "Frase vieja.")
	await _esperar(20)
	dialogo.saltar()
	dialogo.saltar()
	_comprobar(not dialogo.ocupado(), "Una frase que esperó demasiado en la cola se descarta")
	dialogo.caducidad_cola = caducidad
	var largas: Array[String] = []
	for tabla: Dictionary in [Frases.FELIPE, Frases.VALERIA]:
		for evento: String in tabla:
			for frase: Array in tabla[evento]:
				if Dialogo.lineas_de(String(frase[0])) > Dialogo.MAX_LINEAS:
					largas.append(String(frase[0]))
	for t: Dictionary in Agenda.NIVEL_1:
		if Dialogo.lineas_de(String(t["frase"][0])) > Dialogo.MAX_LINEAS:
			largas.append(String(t["frase"][0]))
	_comprobar(largas.is_empty(), "Todas las frases caben en 1 o 2 líneas %s" % [largas])
	var frases := Frases.new()
	var repetida := false
	var anterior := ""
	for i in 40:
		var texto := String(frases.elegir("felipe", "maullar")[0])
		repetida = repetida or texto == anterior
		anterior = texto
	_comprobar(not repetida, "Frases.elegir no repite la misma frase seguida")
	# M3: el aviso de logro va por encima del diálogo (capa más alta) y nunca debajo de su cuadro.
	var medidores := sala.get_node("Interfaz/Medidores") as Medidores
	dialogo.limpiar()
	sala.travesuras.anuncios.limpiar()
	await _esperar(2)
	sala.felipe.global_position = Vector2(120, Sala.SUELO)
	dialogo.decir("felipe", "Una frase arriba.", 0, true)
	sala.desbloquear_logro("Logro de prueba")
	# El logro sale cuando le toca en la cola única de anuncios (G5 de la revisión 3).
	for i in 400:
		if medidores.mostrando_logro():
			break
		await process_frame
	var cuadro := dialogo.rect_en_pantalla()
	_comprobar(medidores.mostrando_logro() and cuadro.has_area() and not medidores.rect_logro().intersects(cuadro), "M3 Con el diálogo en pantalla, el aviso de logro sale fuera de su cuadro")
	_comprobar(Medidores.CAPA_AVISO > dialogo.layer, "M3 El aviso de logro va en una capa por encima del diálogo")
	dialogo.limpiar()


## Frotarse contra alguien enojado (Valeria): un ciclo de "ronronear" y después perdonar(felipe, "frotarse").
func _probar_frotarse() -> void:
	var testigo := _testigo()
	sala.add_child(testigo)
	testigo.global_position = Vector2(160, Sala.SUELO)
	await _poner_en(Vector2(130, Sala.SUELO))
	var terminados: Array[Node2D] = []
	felipe.ronroneo_terminado.connect(func(o: Node2D) -> void: terminados.append(o))
	felipe.frotarse(testigo)
	_comprobar(felipe.estado == Felipe.Estado.RONRONEANDO and felipe.sprite.animation == "ronronear" and felipe.mirando > 0.0, "Frotarse: ronronea mirando a quien se frota")
	await _esperar(30)
	_comprobar(int(testigo.get("perdones")) == 0, "El perdón no llega antes de terminar el ronroneo")
	await _esperar(40)
	_comprobar(int(testigo.get("perdones")) == 1 and terminados.size() == 1 and felipe.estado == Felipe.Estado.SUELO, "Al terminar (1 s), lo perdonan y Felipe queda libre")
	testigo.queue_free()


## Indicador: contorno y burbuja con el ícono y el verbo cuando hay algo cerca; nada cuando está lejos.
func _probar_indicador() -> void:
	var indicador := sala.travesuras.indicador
	_comprobar(IconosBotones.textura("interactuar", false) != null and IconosBotones.textura("interactuar", true) != null, "Los íconos de teclado y mando salen del paquete de Kenney")
	_comprobar(IconosBotones.texto("maullar", false) == "Q" and IconosBotones.texto("maullar", true) == "B", "Maullar: Q en el teclado, B en el mando")
	await _poner_en(Vector2(300, Sala.SUELO))
	await _esperar(3)
	_comprobar(indicador.objeto == sala.get_node("Sofa arañable") or indicador.objeto == null, "Frente al sofá roto ya no se ofrece si no se puede arañar más")
	var puerta: Puerta = sala.puertas["sala>recibidor"]
	await _poner_en(puerta.global_position + Vector2(-20, 0))
	await _esperar(3)
	_comprobar(indicador.objeto == puerta and indicador.verbo == "Pasar", "Junto a una puerta aparece la burbuja «Pasar» (%s)" % indicador.verbo)
	await _poner_en(Vector2(120, Sala.SUELO))
	await _esperar(3)
	_comprobar(indicador.objeto == null and indicador.verbo == "", "Lejos de todo, el indicador se va")
	# M7: un verbo por acción (sofá «Firmar», ropa «Desordenar», puerta entornada «Arañar»).
	var verbos := {}
	for nombre: String in ["Sofa arañable", "Ropa doblada", "Puerta entornada"]:
		var cosa := sala.get_node(nombre)
		verbos[String(cosa.call("verbo", felipe))] = nombre
	_comprobar(verbos.size() == 3 and verbos.has("Firmar") and verbos.has("Desordenar") and verbos.has("Arañar"), "M7 Sofá, ropa y puerta entornada tienen verbos distintos (%s)" % ", ".join(verbos.keys()))
	# M5: el punto del láser mide 8 px o más.
	_comprobar(Laser.RADIO_PUNTO * 2.0 >= 8.0, "M5 El punto del láser mide %.0f px (con halo que late)" % (Laser.RADIO_PUNTO * 2.0))
	var vaso2: Objeto = null
	for hijo in sala.get_children():
		if hijo is Objeto and not hijo.tirable.roto and hijo.tipo == "vaso":
			vaso2 = hijo
	if vaso2:
		await _poner_en(vaso2.global_position + Vector2(-30, 0))
		await _esperar(3)
		_comprobar(indicador.objeto == vaso2.tirable and indicador.verbo == "Liberar", "Junto a un vaso: «Liberar» con contorno del dibujo")
	felipe.snacks = 2
	await _poner_en(Vector2(120, Sala.SUELO))
	Input.action_press("interactuar")
	await _esperar(12)
	_comprobar(indicador.verbo == "Degustar snack", "Manteniendo la acción sin nada cerca, la burbuja carga «Degustar snack»")
	Input.action_release("interactuar")
	await _esperar(5)


## Oyente de prueba del maullido: una pieza OyeMaullido suelta que cuenta lo que oye (meta «oidos»).
func _oyente(posicion: Vector2) -> Node2D:
	var oyente := OyeMaullido.new()
	oyente.set_meta("oidos", 0)
	oyente.oyo.connect(func(_f: Felipe) -> void: oyente.set_meta("oidos", int(oyente.get_meta("oidos")) + 1))
	sala.add_child(oyente)
	oyente.global_position = posicion
	return oyente


## Testigo falso para el rascador (la interfaz que cumplirá Valeria en la PARTE B).
func _testigo() -> Node2D:
	var script := GDScript.new()
	script.source_code = "extends Node2D\nvar visita := 0\nvar perdones := 0\nvar mirando := true\nfunc ve(_punto: Vector2) -> bool:\n\treturn mirando\nfunc perdonar(_felipe: Node, _motivo: String) -> void:\n\tperdones += 1\n"
	script.reload()
	var testigo := Node2D.new()
	testigo.set_script(script)
	testigo.add_to_group(Rascador.GRUPO_TESTIGOS)
	return testigo


func _dijo(quien: String, lista: Array) -> bool:
	var textos := lista.map(func(f: Array) -> String: return String(f[0]))
	for linea: Array in sala.travesuras.dialogo.historial:
		if linea[0] == quien and textos.has(linea[1]):
			return true
	return false


func _poner_en(posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await _esperar(2)
	Input.action_release(accion)


## En pausa no corre la física: se espera por cuadros de proceso.
func _tocar_en_pausa(accion: String) -> void:
	Input.action_press(accion)
	await process_frame
	await process_frame
	Input.action_release(accion)
	await process_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
