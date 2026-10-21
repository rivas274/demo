extends SceneTree
## Prueba del primer nivel (v4, "La Gran Fuga": siete cuartos con puertas, Valeria, escalera con cajas de la mudanza, Agenda y
## balcón) de principio a fin, con los botones de una persona donde importa.
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_nivel.gd

var _fallos: Array[String] = []
var sala: Nivel
## Lo propio del nivel 1 (Valeria, A.S.P.I., la pelea, las cajas...).
var guion: GuionNivel1
var felipe: Felipe
## Valeria nunca se para en una puerta (se revisa en cada cuadro de la prueba).
var _valeria_en_puerta := ""
## De pie, Valeria siempre pisa el piso (G2): aquí queda dónde se paró sobre un mueble, si pasó.
var _valeria_sobre_mueble := ""
## G1: Valeria nunca se dibuja bajo el piso; G3: nunca cambia de lugar más de lo que camina en un cuadro, salvo al
## cruzar una puerta (Valeria.cruces). Aquí queda lo primero que falló.
var _valeria_bajo_el_piso := ""
var _valeria_salto := ""
var _valeria_antes := Vector2.INF
var _valeria_cruces := 0
var _valeria_cuadro := 0
const MEDIR := preload("res://pruebas/medir_pasos.gd")


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var t := sala.travesuras
	await _esperar(30)
	_comprobar(not felipe.tiene_doble_salto and not felipe.tiene_zoomies and not felipe.puede_trepar, "En el nivel 1 no hay doble salto, Zoomies ni trepar")

	# G7: título e introducción tapan todo: HUD, diálogo y palabras no se dibujan encima.
	sala.pantallas.mostrar_titulo()
	await _esperar(2)
	var oculta_en_titulo := not t.hud.visible and not t.dialogo.visible and not t.jugo.visible
	sala.pantallas.modo = Pantallas.Modo.INTRO
	await process_frame
	var oculta_en_intro := not t.hud.visible and not t.dialogo.visible and not t.jugo.visible
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	paused = false
	await _esperar(2)
	_comprobar(oculta_en_titulo and oculta_en_intro and t.hud.visible and t.dialogo.visible, "G7 En el título y la introducción no se ven el HUD, el diálogo ni las palabras; al jugar, sí")
	var capa_pantallas: CanvasLayer = sala.pantallas.get_parent()
	_comprobar(capa_pantallas.layer > t.hud.layer and capa_pantallas.layer > t.dialogo.layer and capa_pantallas.layer > Capas.CAPA_AVISOS and capa_pantallas.layer > Capas.CAPA_JEFE, "G7 Las pantallas (título, intro, pausa) van en la capa de más arriba")
	_comprobar(Capas.CAPA_FUNDIDO > t.dialogo.layer and Capas.CAPA_FUNDIDO > t.hud.layer and Capas.CAPA_FUNDIDO > Capas.CAPA_AVISOS, "G7 El negro de las puertas tapa también el diálogo, los carteles y los logros")

	# B2: el pie apoyado del caminar de Valeria no patina: medido en la hoja, retrocede lo que ella avanza por cuadro
	# (VELOCIDAD / FPS_CAMINAR) con menos de 2 px de diferencia, y las piernas alternan (el pie apoyado cambia).
	var pasos: Array = MEDIR.pie_apoyado(Valeria.RUTA % "caminar", Valeria.CUADROS_CAMINAR, 18, 34, 40.0)
	var peor := 0.0
	for medida: Array in pasos:
		peor = maxf(peor, absf(-float(medida[1]) - Valeria.VELOCIDAD / Valeria.FPS_CAMINAR))
	_comprobar(pasos.size() >= 4 and peor <= 2.0, "B2 El pie apoyado de Valeria se desliza %.1f px por cuadro como mucho (≤ 2; %d pares medidos: %s)" % [peor, pasos.size(), str(pasos)])
	_comprobar(absf(Valeria.VELOCIDAD - Valeria.PASO_CUADRO * Valeria.FPS_CAMINAR) < 0.01, "B2 La velocidad de Valeria sale del paso medido (%.1f px por cuadro × %.0f cuadros/s = %.0f px/s)" % [Valeria.PASO_CUADRO, Valeria.FPS_CAMINAR, Valeria.VELOCIDAD])

	# La meta se muestra al empezar (la cámara pasa por el balcón) y Felipe lo dice.
	sala.pantallas.empezar.emit()
	await _esperar(10)
	var camara_meta: Camera2D = sala.get_node_or_null("Camara de la meta")
	_comprobar(camara_meta != null and camara_meta.is_current() and Nivel1.habitacion_de(camara_meta.position) == "balcon", "Al empezar, la cámara muestra el balcón (la meta)")
	await create_timer(3.0).timeout
	_comprobar(felipe.get_node("Camara").is_current() and sala.fundido_alfa() < 0.01, "Después vuelve a Felipe (con fundidos, sin cortes duros: M4)")
	_comprobar(_dijo("felipe", "libertad"), "Felipe dice que la libertad está allá arriba")

	# Sin avisos de texto ni fila de controles (M2): la primera vez, una línea de Felipe con el botón.
	await _poner_en(Vector2(100, Nivel1.SUELO))
	_comprobar(sala.get_node_or_null("Interfaz/Ayuda") == null and sala.pantallas.aviso == "", "No hay fila de controles ni avisos abajo")
	_comprobar(_dijo("felipe", "{saltar} Los muebles"), "La primera vez, Felipe enseña a saltar con su frase y el botón")
	var lineas := t.dialogo.historial.size()
	await _poner_en(Vector2(130, Nivel1.SUELO))
	await _poner_en(Vector2(100, Nivel1.SUELO))
	_comprobar(_contar("felipe", "{saltar} Los muebles") == 1, "La frase no se repite al volver")
	_comprobar(sala.habitacion == "sala" and guion.valeria.actividad == Valeria.Actividad.SENTADA, "Felipe empieza en la sala; Valeria ve su serie en el sofá")
	# Prueba de luz (LuzCuarto, GuionNivel1.luz_activa): ambiente y luces solo en la sala; la interfaz va en CanvasLayer.
	var luz: LuzCuarto = sala.get_node_or_null("LuzCuarto")
	if guion.luz_activa:
		var ambiente: CanvasModulate = luz.get_node("Ambiente del cuarto") if luz else null
		_comprobar(ambiente != null and ambiente.color == Nivel1.AMBIENTE_CUARTOS["sala"] and t.hud is CanvasLayer and t.dialogo is CanvasLayer and t.jugo is CanvasLayer, "Luz: en la sala hay ambiente de atardecer y el HUD, el diálogo y las palabras van en CanvasLayer (no lo reciben)")
		var sin_sombra := t.indicador.material as CanvasItemMaterial
		_comprobar(sin_sombra != null and sin_sombra.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED, "Luz: el Indicador (en el mundo) no recibe el ambiente ni las luces")

	# Capas (plan de estabilización): sobre el asiento del sofá, junto a Valeria, Felipe va DELANTE de ella; en el piso,
	# detrás con su silueta.
	await _poner_en(Vector2(400, Nivel1.SUELO - 49))
	await _esperar(20)
	var silueta_sofa := guion.valeria.get_node_or_null("SiluetaTapada") as SiluetaTapada
	_comprobar(guion.superficie_de_felipe() == "Asiento del sofá" and Capas.z_efectivo(felipe.sprite) > Capas.z_efectivo(guion.valeria) and not silueta_sofa.dibujando(), "Capas: sobre el asiento del sofá junto a Valeria, Felipe va delante de ella (sin silueta) [%s, z %d, piso %s, y %.0f]" % [guion.superficie_de_felipe(), felipe.z_index, felipe.is_on_floor(), felipe.global_position.y])
	await _poner_en(Vector2(420, Nivel1.SUELO))
	await _esperar(20)
	_comprobar(Capas.z_efectivo(felipe.sprite) > Capas.z_efectivo(guion.valeria) and not silueta_sofa.dibujando(), "Capas: con Valeria sentada en el sofá, Felipe en el piso va delante de ella (decisión del creador)")
	felipe.cambiar_estado(Felipe.Estado.RONRONEANDO, {"objetivo": null})
	await _esperar(3)
	_comprobar(Capas.z_efectivo(felipe.sprite) > Capas.z_efectivo(guion.valeria), "Capas: frotándose (Encantar), Felipe va delante de Valeria aunque esté en el piso")
	await _esperar_que(func() -> bool: return felipe.estado != Felipe.Estado.RONRONEANDO, 300)
	await _esperar(3)
	_comprobar(Capas.z_efectivo(felipe.sprite) > Capas.z_efectivo(guion.valeria), "Capas: al terminar de frotarse, con Valeria sentada, sigue delante de ella")

	# Arañar el sofá delante de Valeria: a los dos arañazos lo deja frente al rascador y el plástico aguanta.
	await _poner_en(Vector2(330, Nivel1.SUELO))
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return guion.valeria.actividad == Valeria.Actividad.REGANANDO, 70)
	_comprobar(guion.valeria.actividad == Valeria.Actividad.REGANANDO and absf(guion.valeria.global_position.y - Nivel1.SUELO) < 0.5, "G2 Al pararse del sofá para regañar, Valeria baja al piso (no queda encima del sofá)")
	await _esperar(50)
	_comprobar(not guion.sofa.esta_roto and absf(felipe.global_position.x - (Nivel1.RASCADOR_X - 46.0)) < 6.0, "Valeria lo pilla arañando el sofá y lo deja frente al rascador")
	_comprobar(_dijo("valeria", "Aquí"), "Valeria: «Ahí no. Aquí. Para eso lo compré.»")
	await _esperar(80)

	# El rascador con público: perdón, snack y Valeria graba 8 s de espaldas al sofá; garras afiladas → sofá CRÍTICO.
	var snacks := felipe.snacks
	await _poner_en(Vector2(Nivel1.RASCADOR_X - 40.0, Nivel1.SUELO))
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return guion.valeria.actividad == Valeria.Actividad.GRABANDO, 240)
	_comprobar(guion.valeria.actividad == Valeria.Actividad.GRABANDO and felipe.snacks == snacks + 1, "Con Valeria mirando, el rascador da un snack y ella saca el celular")
	_comprobar(not guion.valeria.ve(Vector2(300, Nivel1.SUELO - 20)), "Grabando, Valeria le da la espalda al sofá")
	felipe.afilar_garras()
	await _poner_en(Vector2(300, Nivel1.SUELO))
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return guion.sofa.esta_roto, 90)
	_comprobar(guion.sofa.esta_roto and t.agenda.esta_cumplida("sofa"), "Con las garras afiladas, el arañazo rompe el plástico: travesura «sofa»")
	_comprobar("¡PLÁSTICO: 0!" in t.jugo.palabras, "Reacción: «¡PLÁSTICO: 0!»")
	_comprobar(absf(sala.pieza("Asiento del sofá").position.y - (Nivel1.SUELO - 45)) < 0.5, "Sin plástico, la colisión del asiento baja a su arte nuevo")
	await process_frame
	await process_frame
	_comprobar(guion.arte.sofa_dibujado == "sofa_aranado", "G4 Al romper el plástico, el sofá se redibuja sin plástico ni etiqueta (%s)" % guion.arte.sofa_dibujado)
	await _esperar(120)
	await _poner_en(Vector2(370, Nivel1.SUELO - 49))
	await _esperar(30)
	_comprobar(sala.calcetines == 1, "El calcetín sale de entre los cojines y va al nido (%d)" % sala.calcetines)
	await _esperar_que(func() -> bool: return guion.valeria.actividad == Valeria.Actividad.SENTADA, 900)

	# El vaso de la mesa: «¡GRAVEDAD: 1 · VASO: 0!», Valeria regaña; frotarse = perdón (travesura «perdon»).
	await _poner_en(Vector2(880, Nivel1.SUELO - 91))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(70)
	_comprobar("La Gravedad Funciona" in sala.logros and "¡GRAVEDAD: 1 · VASO: 0!" in t.jugo.palabras, "Tirar el vaso da «La Gravedad Funciona» y su palabra")
	Input.action_press("agacharse")
	await _tocar("saltar")
	Input.action_release("agacharse")
	await _esperar_que(func() -> bool: return guion.valeria.actividad == Valeria.Actividad.REGANANDO, 400)
	_comprobar(guion.valeria.actividad == Valeria.Actividad.REGANANDO and guion.valeria.motivo_regano == "rotura", "Valeria se para y lo regaña (corazón roto)")
	await _poner_en(Vector2(guion.valeria.global_position.x + 30.0 * signf(felipe.global_position.x - guion.valeria.global_position.x + 0.1), Nivel1.SUELO), 10)
	_comprobar(felipe.objeto_cercano() == guion.valeria, "Junto a Valeria enojada, el botón de acción es «Encantar»")
	# Plan de estabilización (decisión 1): Valeria va delante de Felipe y, donde lo tapa, se ve su contorno.
	var silueta := guion.valeria.get_node_or_null("SiluetaTapada") as SiluetaTapada
	_comprobar(Capas.z_efectivo(guion.valeria) > Capas.z_efectivo(felipe.sprite) and guion.valeria.clip_children == CanvasItem.CLIP_CHILDREN_AND_DRAW, "Capas: Valeria (humana) se dibuja delante de Felipe y recorta su silueta")
	await process_frame
	_comprobar(silueta != null and silueta.dibujando(), "Capas: junto a Valeria se dibuja la silueta de Felipe (solo donde ella lo tapa)")
	await _tocar("interactuar")
	_comprobar(felipe.estado == Felipe.Estado.RONRONEANDO and felipe.sprite.animation == "ronronear", "Felipe se frota ronroneando")
	await _esperar(80)
	_comprobar(t.agenda.esta_cumplida("perdon") and t.perdones >= 2, "Valeria lo perdona: travesura «perdon» (perdones %d)" % t.perdones)

	# Puertas: con el botón de acción o arriba se pasa a la otra habitación, y la cámara queda dentro.
	await _poner_en(sala.puertas["sala>recibidor"].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	var recibidor := Nivel1.rect_de("recibidor")
	var camara: Camera2D = felipe.get_node("Camara")
	_comprobar(sala.habitacion == "recibidor" and felipe.global_position.distance_to(sala.puertas["recibidor<sala"].global_position) < 4.0, "La puerta lleva de la sala al recibidor")
	if luz:
		_comprobar((luz.get_node("Ambiente del cuarto") as CanvasModulate).color == Nivel1.AMBIENTE_CUARTOS["recibidor"] and not (luz.get_node("Sol de la ventana") as PointLight2D).enabled, "Luz: en el recibidor, el atardecer de su lámpara y las luces de la sala apagadas")
	_comprobar(camara.limit_left == int(recibidor.position.x) and camara.limit_right == int(recibidor.end.x), "La cámara queda dentro del recibidor")
	# G3: Valeria no se teletransporta: camina hasta la puerta de la sala, sale por ella y recién entonces aparece en
	# el recibidor (por la puerta, con la puerta abierta).
	var cruces_antes := guion.valeria.cruces
	_comprobar(guion.valeria.cuarto == "sala", "G3 Valeria sigue en la sala cuando Felipe sale (no aparece de golpe en el recibidor)")
	var vio_puerta_abierta := false
	for i in 900:
		await physics_frame
		_vigilar_valeria()
		if guion.valeria.cuarto == "recibidor" and guion.valeria.visible:
			vio_puerta_abierta = sala.puertas["recibidor<sala"].apertura > 0.99
			break
	_comprobar(guion.valeria.cuarto == "recibidor" and vio_puerta_abierta and guion.valeria.cruces == cruces_antes + 1, "G3 Valeria entra al recibidor por la puerta abierta, una sola vez")
	await _esperar_que(func() -> bool: return _dijo("valeria", "Dieta"), 120)
	_comprobar(_dijo("valeria", "Dieta"), "Valeria pasa al recibidor rumbo a la cocina: «Voy por café. Tú no entras. Dieta.»")
	await _esperar_que(func() -> bool: return guion.valeria.cuarto == "cocina", 900)
	_comprobar(guion.valeria.cuarto == "cocina" and sala.puertas[Nivel1.PUERTA_COCINA].cerrada, "Valeria se encierra en la cocina")

	# La puerta cerrada no deja pasar; maullar del otro lado la abre (R19).
	await _poner_en(sala.puertas[Nivel1.PUERTA_COCINA].global_position)
	await _tocar("interactuar")
	await _esperar(20)
	_comprobar(sala.habitacion == "recibidor", "La puerta de la cocina está cerrada")
	await _tocar("maullar")
	# G2: la puerta se abre con Valeria en el vano (no sola y vacía).
	var abierta_sin_nadie := false
	# Cocina v2: Valeria camina ~600 px desde la estufa hasta la puerta.
	for i in 900:
		await physics_frame
		_vigilar_valeria()
		var p: Puerta = sala.puertas[Nivel1.PUERTA_COCINA]
		if p.apertura > 0.5 and not (guion.valeria.cuarto == "recibidor" and guion.valeria.visible) and guion.valeria.actividad != Valeria.Actividad.FUERA:
			abierta_sin_nadie = true
		if not p.cerrada and _dijo("valeria", "entra"):
			break
	_comprobar(not sala.puertas[Nivel1.PUERTA_COCINA].cerrada and _dijo("valeria", "entra"), "Al maullar, Valeria abre la puerta de la cocina")
	_comprobar(guion.valeria.cuarto == "recibidor" and guion.valeria.visible and absf(guion.valeria.global_position.x - sala.puertas[Nivel1.PUERTA_COCINA].global_position.x) < 2.0, "G2 Valeria se asoma en el vano para decir su frase (no habla desde fuera de cuadro)")
	_comprobar(not abierta_sin_nadie, "G2 La puerta de la cocina no se abre sola, vacía")

	# Las llaves del zapatero: «¡CLINK CRÍTICO!».
	await _poner_en(Vector2(1745, Nivel1.SUELO - 97))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(70)
	_comprobar("¡CLINK CRÍTICO!" in t.jugo.palabras, "Tirar las llaves: «¡CLINK CRÍTICO!»")

	# Caja de arena: descanso; popo táctico (secreta) con censura irónica y Valeria con mascarilla.
	await _poner_en(Vector2(Nivel1.DESCANSOS[0].get_center().x, Nivel1.SUELO - 45))
	await _esperar(10)
	_comprobar(Nivel1.DESCANSOS[0].has_point(felipe.punto_reaparicion), "La caja de arena es punto de descanso")
	Input.action_press("agacharse")
	await _esperar(90)
	Input.action_release("agacharse")
	_comprobar(t.agenda.esta_cumplida("popo") and guion.censura_mostrada, "Agachado en la arena: popo táctico con la pegatina de censura irónica")
	await _esperar_que(func() -> bool: return guion.valeria.cuarto == "recibidor" and guion.valeria.visible and _dijo("valeria", "acabo de limpiar"), 1200)
	_comprobar(guion.valeria.mascarilla and guion.valeria.cuarto == "recibidor", "Valeria sale con mascarilla: «La acabo de limpiar.»")
	_comprobar(t.agenda.texto_recompensa("popo") == "Foto vergonzosa" and _foto_suelta("recibidor") != null, "G6 El popo táctico da una foto vergonzosa (no un camino ya abierto)")
	var fotos_antes := t.recompensas.fotos
	await _poner_en(_foto_suelta("recibidor").global_position + Vector2(0, -2), 60)
	_comprobar(t.recompensas.fotos == fotos_antes + 1, "G6 La foto del popo se recoge y va a la galería")
	await _esperar_que(func() -> bool: return guion.valeria.cuarto == "cocina", 900)
	_comprobar(not sala.puertas[Nivel1.PUERTA_COCINA].cerrada, "Al volver por bolsas, Valeria deja abierta la puerta de la cocina")

	# Cocina: tazón, ratón, caja, pollo en la cara de Valeria y calcetín del refrigerador.
	await _poner_en(sala.puertas[Nivel1.PUERTA_COCINA].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "cocina", "Se entra a la cocina")
	var corazones := felipe.corazones
	felipe.recibir_dano(1, felipe.global_position.x - 10.0)
	await _esperar(90)
	await _poner_en(Vector2(2975, Nivel1.SUELO))
	await _tocar("interactuar")
	await _esperar(40)
	_comprobar(felipe.corazones == corazones and _dijo("felipe", "croquetas"), "El tazón se come (cura) y Felipe se queja de las tres croquetas")
	var raton := _raton_en("cocina", Nivel1.SUELO)
	await _zarpazo_a(raton)
	_comprobar(raton.vida.muerto, "Un zarpazo voltea al ratón de cuerda")
	# Con lugar en el bolsillo (el plato y los descansos ya pudieron llenarlo).
	felipe.snacks = 2
	var snacks_antes := felipe.snacks
	var caja: CajaCarton = sala.get_node("Caja de carton")
	await _zarpazo_a(caja)
	await _esperar(40)
	await _poner_en(caja.global_position + Vector2(10, 0))
	await _esperar(40)
	_comprobar(caja.roto and felipe.snacks > snacks_antes, "La caja de cartón se rompe de un zarpazo y suelta un snack")
	var raton_meson := _raton_en("cocina", Nivel1.SUELO - 109)
	raton_meson.queue_free()
	guion.valeria.mirando = 1.0
	await _poner_en(Nivel1.POLLO + Vector2(30, 0))
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar(t.agenda.esta_cumplida("almuerzo") and "¡EN SU CARA!" in t.jugo.palabras, "Robar el pollo delante de Valeria: «¡EN SU CARA!» (travesura «almuerzo»)")
	_comprobar(_dijo("valeria", "almuerzo"), "Valeria: «Ese era mi almuerzo.»")
	await _poner_en(Nivel1.CALCETIN_REFRIGERADOR + Vector2(0, -1))
	await _esperar(30)
	_comprobar(sala.calcetines == 2, "El calcetín de arriba del refrigerador se recoge (%d)" % sala.calcetines)

	# Las cajas de la mudanza (lección 33): desde el piso no se pasan. Se empuja a Felipe contra la pila 2 s caminando y
	# 2 s saltando: no la atraviesa ni la salta. Desde el librero se pasa por encima.
	var tope := Nivel1.CAJAS.position.x - 19.0
	await _poner_en(Vector2(2225, Nivel1.SUELO))
	Input.action_press("mover_derecha")
	await _esperar(120)
	var x_caminando := felipe.global_position.x
	# Agachado (gateando) tampoco: la pila no deja hueco abajo. (Saltando, la única subida es el librero: el camino.)
	Input.action_press("agacharse")
	await _esperar(120)
	Input.action_release("agacharse")
	Input.action_release("mover_derecha")
	await _esperar(30)
	_comprobar(x_caminando <= tope and felipe.global_position.x <= tope and felipe.global_position.y > Nivel1.SUELO - 2.0, "Empujado contra la pila de cajas desde abajo (caminando y gateando), Felipe no la atraviesa (x %.0f y %.0f; la pila empieza en %.0f)" % [x_caminando, felipe.global_position.x, Nivel1.CAJAS.position.x])
	await _tocar("interactuar")
	await _esperar(40)
	_comprobar(not guion.cajas.tirada_ya and _dijo("felipe", "mudanza"), "Desde afuera la empuja: «Cajas de la mudanza...» (no se mueve)")
	await _poner_en(Vector2(2250, Nivel1.SUELO - 155))
	_comprobar(felipe.is_on_floor() and absf(felipe.global_position.y - (Nivel1.SUELO - 155)) < 1.0, "Se para en la repisa de arriba del librero")
	Input.action_press("mover_derecha")
	Input.action_press("saltar")
	await _esperar(14)
	Input.action_release("saltar")
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.x > Nivel1.CAJAS.end.x and felipe.global_position.y > Nivel1.SUELO - 2.0, 180)
	Input.action_release("mover_derecha")
	_comprobar(felipe.global_position.x > Nivel1.CAJAS.end.x and felipe.global_position.y > Nivel1.SUELO - 2.0, "Desde el librero pasa por encima de las cajas y cae al pie de la escalera (sin doble salto)")

	# La escalera: escalón por escalón, con el pasamanos delante al 70 %.
	await _poner_en(sala.puertas[Nivel1.PUERTA_ESCALERA].global_position, 10)
	await _tocar("interactuar")
	var en_escalera := false
	var siguio_peldanos := true
	var pasamanos_claro := false
	var animo := false
	for i in 200:
		await physics_frame
		if felipe.en_escalera():
			en_escalera = true
			animo = animo or felipe.sprite.animation == "subir_escalera"
			pasamanos_claro = pasamanos_claro or is_equal_approx(sala.get_node("Pasamanos").modulate.a, Nivel1.OPACIDAD_PASAMANOS)
			var dentro := felipe.global_position.y >= Nivel1.PELDANOS[-1].y - 8.0 and felipe.global_position.y <= Nivel1.SUELO + 1.0
			siguio_peldanos = siguio_peldanos and dentro
		if sala.habitacion == "pasillo":
			break
	_comprobar(en_escalera and animo and siguio_peldanos, "Sube escalón por escalón con la animación subir_escalera")
	_comprobar(pasamanos_claro, "Mientras sube, el pasamanos de adelante baja al 70 %")
	await _esperar(30)
	_comprobar(sala.habitacion == "pasillo" and _dijo("valeria", "Audífonos"), "La escalera lleva al pasillo; abajo, Valeria se pone audífonos")

	# Bajar: por el vano vuelve al pie de la escalera (adentro de las cajas), escalón por escalón; desde el peldaño, tirar la caja de arriba es el atajo.
	await _poner_en(sala.puertas["pasillo<recibidor"].global_position, 10)
	await _tocar("interactuar")
	var peldanos_pisados := {}
	var bajo_a_saltos := false
	var siempre_adentro := true
	var alto_anterior := -INF
	var subio := false
	for i in 400:
		await physics_frame
		_vigilar_valeria()
		if sala.habitacion != "recibidor":
			continue
		var pies := felipe.global_position
		siempre_adentro = siempre_adentro and pies.x > Nivel1.CAJAS.end.x
		for j in Nivel1.PELDANOS.size():
			if pies.distance_to(Nivel1.PELDANOS[j]) < 3.0:
				peldanos_pisados[j] = true
		bajo_a_saltos = bajo_a_saltos or felipe.estado == Felipe.Estado.SUBIENDO_ESCALON
		# Baja: cuadro a cuadro la altura de los pies no vuelve a subir más que el saltito de un escalón.
		subio = subio or (alto_anterior != -INF and pies.y < alto_anterior - 24.0)
		alto_anterior = pies.y
		if not sala.cruzando() and felipe.is_on_floor():
			break
	_comprobar(absf(felipe.global_position.x - Nivel1.ESCALERA_PIE.x) < 6.0 and felipe.global_position.y > Nivel1.SUELO - 2.0, "Por el vano baja la escalera hasta el pie")
	_comprobar(peldanos_pisados.size() == Nivel1.PELDANOS.size() and bajo_a_saltos and not subio, "Baja escalón por escalón: pisa los %d peldaños (%d), un saltito por escalón y sin volver a subir" % [Nivel1.PELDANOS.size(), peldanos_pisados.size()])
	_comprobar(siempre_adentro and felipe.is_on_floor() and felipe.estado == Felipe.Estado.SUELO, "Al bajar queda del lado de adentro de las cajas, en el piso y con el control de vuelta")
	_comprobar(_dijo("felipe", "empujables"), "Al bajar con las cajas enteras: «Desde aquí arriba, esas cajas se ven… empujables.»")
	Input.action_press("mover_derecha")
	await _esperar(20)
	Input.action_release("mover_derecha")
	_comprobar(felipe.global_position.x > Nivel1.ESCALERA_PIE.x + 10.0, "Después de bajar se puede caminar")
	await _poner_en(Vector2(Nivel1.ESCALERA_PIE.x, Nivel1.SUELO), 20)
	_comprobar(felipe.objeto_cercano() != guion.cajas, "Adentro, en el piso, las cajas no se ofrecen (manda «Ascender»)")
	# Estudio v3: la caja de los libros mide casi lo que el peldaño (48 px); parado ahí, las cajas de la mudanza (en otro
	# piso) no se ofrecen.
	# (Se mide con un punto: llevar a Felipe al estudio empezaría la pelea.)
	var caja_libros := Nivel1.rect_pieza("Caja de los libros")
	var sobre_la_caja := Node2D.new()
	sala.add_child(sobre_la_caja)
	sobre_la_caja.global_position = Vector2(caja_libros.get_center().x, caja_libros.position.y)
	_comprobar(guion.cajas.adentro(sobre_la_caja) and not guion.cajas.en_el_peldano(sobre_la_caja), "Parado en la caja de los libros del estudio, las cajas de la mudanza no ofrecen «Tirar»")
	sobre_la_caja.queue_free()
	await _poner_en(Nivel1.PELDANO_CAJAS, 20)
	_comprobar(felipe.is_on_floor() and felipe.objeto_cercano() == guion.cajas and tr(guion.cajas.verbo(felipe)) == "Tirar", "Parado en el segundo peldaño (desde arriba), el botón de las cajas es «Tirar»")
	# El mundo reacciona (pilar 5): Valeria tiene los audífonos de la reunión puestos y aun así oye el ¡PUM!.
	var con_audifonos := guion.valeria.audifonos
	await _tocar("interactuar")
	var polvo_salio := false
	var audifono_afuera := false
	var sacudio := false
	for i in 90:
		await physics_frame
		sacudio = sacudio or t.jugo._sacudiendo
		polvo_salio = polvo_salio or guion.cajas.polvo().emitting
		audifono_afuera = audifono_afuera or guion.valeria.audifono_afuera > 0.0
	_comprobar(guion.cajas.tirada_ya and "Atajo de Gato" in sala.logros and is_equal_approx(guion.cajas.rect_solido().size.y, CajasMudanza.ALTO_BASE), "Un manotazo desde el peldaño tira la caja de arriba: quedan dos cajas (atajo, logro)")
	_comprobar(guion.cajas.rect_borde_caja() != Rect2() and "¡PUM! · MUDANZA: 0" in t.jugo.palabras, "La caja de arriba queda abierta en el piso (su borde se pisa), con «¡PUM! · MUDANZA: 0»")
	_comprobar(polvo_salio and guion.cajas.ropa_esparcida(), "Al caer la caja: nube de polvo y la ropa se esparce por el piso")
	_comprobar(sacudio, "Al caer la caja: sacudida corta de cámara")
	_comprobar(con_audifonos and audifono_afuera and _dijo("valeria", "era el gato"), "Valeria, con audífonos, oye el ¡PUM!: se saca uno y reacciona («…Perdón, era el gato.»)")
	await _esperar_que(func() -> bool: return _dijo("felipe", "Mudanza terminada"), 400)
	_comprobar(_dijo("felipe", "Mudanza terminada") and _orden_dicho("era el gato", "Mudanza terminada"), "Después, Felipe sin culpa: «Mudanza terminada. De nada.» (no se pisan)")
	_comprobar(guion.valeria.audifonos, "Valeria se vuelve a poner el audífono (sigue en su reunión)")
	# Vuelta por el atajo: de adentro hacia afuera y otra vez adentro, saltando (sin el librero).
	await _poner_en(Vector2(Nivel1.ESCALERA_PIE.x + 10.0, Nivel1.SUELO), 20)
	Input.action_press("mover_izquierda")
	Input.action_press("saltar")
	await _esperar(16)
	Input.action_release("saltar")
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.x < Nivel1.CAJAS.position.x - 30.0, 240)
	Input.action_release("mover_izquierda")
	_comprobar(felipe.global_position.x < Nivel1.CAJAS.position.x - 30.0, "Con la caja tirada se vuelve de un salto por encima de las dos cajas")
	await _poner_en(Vector2(2140, Nivel1.SUELO), 20)
	Input.action_press("mover_derecha")
	for k in 6:
		Input.action_press("saltar")
		await _esperar(16)
		Input.action_release("saltar")
		await _esperar(20)
	await _esperar_que(func() -> bool: return felipe.is_on_floor() and felipe.global_position.x > Nivel1.CAJAS.end.x, 180)
	Input.action_release("mover_derecha")
	_comprobar(felipe.global_position.x > Nivel1.CAJAS.end.x, "Y de afuera hacia adentro: piso, caja abierta, dos cajas")

	# Pasillo: el ensayo de A.S.P.I. (aspira sin hacer daño), el láser (secreta) y la puerta entornada (arañar).
	await _poner_en(sala.puertas[Nivel1.PUERTA_ESCALERA].global_position, 10)
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return sala.habitacion == "pasillo" and not sala.cruzando(), 300)
	await _poner_en(Vector2(4760, Nivel1.SUELO - 97))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar_que(func() -> bool: return guion.ensayo.paso == EnsayoAspi.Paso.LIMPIA, 600)
	_comprobar(guion.ensayo.paso == EnsayoAspi.Paso.LIMPIA, "Al tirar el vaso de la consola, sale A.S.P.I. del estudio a limpiar")
	corazones = felipe.corazones
	felipe.global_position = guion.ensayo.aspi.global_position + Vector2(150, 0)
	felipe.velocity = Vector2.ZERO
	await _esperar(5)
	var antes := felipe.global_position.x
	await _esperar(15)
	_comprobar(antes - felipe.global_position.x > 10.0 and felipe.corazones == corazones, "Su succión arrastra a Felipe, sin hacer daño (ensayo)")
	_comprobar(_dijo("felipe", "Uñas: modo ancla"), "Felipe enseña a aferrarse: «Mantén {agacharse}. Uñas: modo ancla.»")
	await _esperar_que(func() -> bool: return guion.ensayo.paso == EnsayoAspi.Paso.LISTO, 900)
	_comprobar(guion.ensayo.paso == EnsayoAspi.Paso.LISTO and _dijo("aspi", "registrado"), "Vuelve a su cuarto: «Suciedad eliminada. Gato… registrado.»")
	await _poner_en(Vector2(5190, Nivel1.SUELO))
	await _esperar(6 * 60)
	_comprobar(t.agenda.esta_cumplida("laser"), "Quieto 5 s frente al láser: se apaga de vergüenza (secreta)")
	await _poner_en(Vector2(Nivel1.DESCANSOS[1].get_center().x, Nivel1.SUELO))
	await _esperar(10)
	_comprobar(Nivel1.DESCANSOS[1].has_point(felipe.punto_reaparicion), "El cojín del pasillo es punto de descanso")
	# La puerta del baño (lugar insinuado): frase al acercarse; quieto cerca, la manilla destella y Felipe la mira.
	_comprobar(guion.bano != null and guion.bano.cerrada and not sala.puertas.values().has(guion.bano), "El baño es una puerta cerrada que no es habitación (R7)")
	await _poner_en(Vector2(Nivel1.BANO.x + 80, Nivel1.SUELO))
	await _esperar(20)
	_comprobar(_dijo("felipe", "El trono de porcelana"), "Al acercarse al baño: «El trono de porcelana. Algún día será mío.»")
	await _poner_en(Vector2(Nivel1.BANO.x + 40, Nivel1.SUELO))
	await _esperar(int(2.4 * 60))
	_comprobar(_dijo("felipe", "Esa manija me mira raro") and felipe.mirando < 0.0, "Quieto junto al baño: la manilla destella y Felipe la mira de reojo")
	guion.bano.interactuar(felipe)
	await _esperar(10)
	_comprobar(guion.bano.cerrada and sala.habitacion == "pasillo", "Probar la puerta del baño: tiembla y no cede")
	_comprobar(Nivel1.LUGARES_VISTOS.all(func(l: Array) -> bool: return not "baño" in String(l[0])), "El baño no es un lugar visto (R17): es un lugar oído")
	await _poner_en(sala.puertas[Nivel1.PUERTA_DORMITORIO].global_position + Vector2(-30, 0))
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar(not sala.puertas[Nivel1.PUERTA_DORMITORIO].entornada, "La puerta entornada se abre arañándola")
	await _poner_en(sala.puertas[Nivel1.PUERTA_DORMITORIO].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "dormitorio", "La puerta lleva al dormitorio")

	# Dormitorio: la ropa doblada está apoyada en el colchón (no flota) y se desordena desde la cama; el contorno del
	# Indicador cubre la pila tal como se dibuja.
	var ropa: Interactivo = sala.get_node("Ropa doblada")
	var arte_ropa := ArteNivel.textura("ropa_limpia").get_size()
	var dibujo_ropa := Rect2(Nivel1.ROPA + Vector2(-arte_ropa.x / 2.0, Nivel1.ROPA_HUNDIDA - arte_ropa.y), arte_ropa)
	var contorno_ropa := ropa.rect_indicador()
	_comprobar(absf(contorno_ropa.position.y - dibujo_ropa.position.y) <= 2.0 and absf(contorno_ropa.end.y - dibujo_ropa.end.y) <= 2.0 and absf(contorno_ropa.get_center().x - dibujo_ropa.get_center().x) <= 2.0, "La ropa doblada: el contorno del Indicador calza con la pila dibujada")
	var cama := Nivel1.rect_pieza("Cama")
	_comprobar(dibujo_ropa.end.y >= cama.position.y + 14.0 and dibujo_ropa.end.y <= cama.position.y + 24.0 and absf(dibujo_ropa.get_center().x - (cama.position.x + 125.0)) <= 12.0, "La ropa doblada está en medio de la cama, hundida en el edredón (base %.0f px bajo el colchón, no en el borde de arriba)" % (dibujo_ropa.end.y - cama.position.y))
	# Piso con profundidad: la pared (zócalo, puertas, ventanas) termina entre 12 y 16 px sobre la línea de apoyo (Gemini,
	# pasada única), y las puertas se dibujan con el umbral en esa unión, con el piso delante.
	_comprobar(Nivel1.SUELO - Nivel1.PARED_BASE >= 12.0 and Nivel1.SUELO - Nivel1.PARED_BASE <= 16.0 and Nivel1.ALTO - Nivel1.SUELO >= 16.0, "Piso con profundidad: banda de %.0f px entre el zócalo y la línea de apoyo, y %.0f px delante" % [Nivel1.SUELO - Nivel1.PARED_BASE, Nivel1.ALTO - Nivel1.SUELO])
	var umbrales := true
	for puerta: Puerta in sala.puertas.values():
		var arte_puerta := puerta.arte_indicador()
		if not arte_puerta.is_empty() and absf((arte_puerta["rect"] as Rect2).end.y - Nivel1.PARED_BASE) > 0.5:
			umbrales = false
	_comprobar(umbrales, "Piso con profundidad: cada puerta tiene el umbral en la unión pared-piso (no en la línea de apoyo)")
	for ventana: Rect2 in Nivel1.VENTANAS:
		_comprobar(absf(Nivel1.PARED_BASE - ventana.end.y - 109.0) < 0.5, "Las ventanas recortadas tienen el alféizar a 90 cm de la unión pared-piso")
	# Cocina v2 (lecciones 18, 28 y 31): más ancha que la pantalla; el fregadero embutido del arte del mesón queda bajo la
	# ventana (el grifo dentro del mesón y del vidrio); el ratón del mesón nunca pasa por delante del grifo ni del pollo;
	# el microondas se apoya en el mesón.
	var cocina := Nivel1.rect_de("cocina")
	var meson := Nivel1.rect_pieza("Mesón")
	var patrulla := Rect2(Nivel1.RATONES[1][1] - 31.0, 0, Nivel1.RATONES[1][2] - Nivel1.RATONES[1][1] + 62.0, 1)
	_comprobar(cocina.size.x >= 1300.0, "La cocina mide %.0f px (la cámara se mueve)" % cocina.size.x)
	_comprobar(Nivel1.GRIFO.x > meson.position.x and Nivel1.GRIFO.x < meson.end.x and Nivel1.GRIFO.x > Nivel1.VENTANA_COCINA.position.x and Nivel1.GRIFO.x < Nivel1.VENTANA_COCINA.end.x, "El fregadero y su grifo quedan en el mesón, bajo la ventana")
	_comprobar(Nivel1.GRIFO.x < patrulla.position.x and Nivel1.POLLO.x - 32.0 > patrulla.end.x, "El ratón del mesón no pasa por delante del grifo ni del pollo")
	_comprobar(Nivel1.MICROONDAS_X >= meson.position.x and Nivel1.MICROONDAS_X + 98.0 <= meson.end.x, "El microondas se apoya en el mesón")
	await _poner_en(Nivel1.ROPA)
	await _tocar("interactuar")
	await _esperar(90)
	_comprobar(guion.ropa_firmada and _dijo("felipe", "pelo de rey"), "Desordenar la ropa doblada: queda revuelta y con pelos")
	# El cajón (desde la cama) suelta el calcetín 3; la cortina no se trepa.
	await _poner_en(Vector2(6205, Nivel1.SUELO - 65))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _esperar(60)
	_comprobar(t.agenda.esta_cumplida("cajon"), "Un manotazo al cajón: calcetines volando (travesura «cajon»)")
	await _esperar(60)
	await _poner_en(Vector2(6272, Nivel1.SUELO - 96))
	await _esperar(40)
	_comprobar(sala.calcetines == 3 and "Coleccionista de Calcetines" in sala.logros, "Los 3 calcetines van al nido: «Coleccionista de Calcetines»")
	await _poner_en(Vector2(6355, Nivel1.SUELO))
	Input.action_press("mover_arriba")
	await _esperar(40)
	Input.action_release("mover_arriba")
	_comprobar(felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 40.0, "La cortina no se trepa todavía (lugar visto: Afilar Garras)")

	# Estudio: entrar por la puerta (sin pantalla negra), la puerta del balcón cerrada y el teclado (secreta).
	await _poner_en(sala.puertas["pasillo>estudio"].global_position)
	await _tocar("interactuar")
	var negra := false
	await _esperar_que(func() -> bool: return guion.batalla.fase == BatallaAspi.Fase.ENTRADA, 200)
	while guion.batalla.fase == BatallaAspi.Fase.ENTRADA:
		negra = negra or sala.fundido_alfa() > 0.05
		await physics_frame
	_comprobar(not negra, "Entrar al estudio por la puerta: la presentación se ve (sin fundido a negro, B1)")
	felipe.vida.restante_invulnerable = 999.0
	await _poner_en(sala.puertas[Nivel1.PUERTA_BALCON].global_position)
	# En la pelea la puerta cerrada no se ofrece en la burbuja (M3), pero arriba se prueba igual.
	_comprobar(felipe.objeto_cercano() != sala.puertas[Nivel1.PUERTA_BALCON], "M3 En la pelea, la burbuja no ofrece «Probar» en la puerta cerrada del balcón")
	await _tocar("mover_arriba")
	# La frase puede esperar a que termine la franja de fase (zonas de texto: nunca dos textos en la franja).
	await _esperar_que(func() -> bool: return _dijo("felipe", "aspiradora tiene la llave"), 300)
	_comprobar(sala.habitacion == "estudio" and _dijo("felipe", "aspiradora tiene la llave"), "Con A.S.P.I. encendida, la puerta del balcón no abre")
	await _poner_en(Vector2(Nivel1.TECLADO.get_center().x, Nivel1.SUELO - 98))
	await _esperar(10)
	_comprobar(t.agenda.esta_cumplida("teclado"), "Pisar el teclado: «jjjjjjjjjj» (secreta)")
	var batalla := guion.batalla
	for i in batalla.datos.fases:
		var apagados_antes := batalla.apagados
		for intento in 3:
			if batalla.apagados > apagados_antes or batalla.fase != BatallaAspi.Fase.PELEA:
				break
			await _poner_en(Vector2(6880, Nivel1.SUELO), 20)
			if not batalla.llena:
				batalla.deposito = batalla.datos.capacidad[batalla.apagados] - 1
				batalla.agregar_mancha(guion.aspi.global_position)
				await _esperar_que(func() -> bool: return batalla.llena, 600)
			await _esperar(25)
			# Cae sobre ella desde un poco más arriba que su tapa (por debajo del escritorio, que se atraviesa desde abajo).
			felipe.global_position = guion.aspi.global_position + Vector2(0, -62)
			felipe.velocity = Vector2.ZERO
			await _esperar(20)
			# Si se llenó justo bajo la silla, Felipe cae sobre el asiento (55 px), por encima de la franja donde la pisa
			# (de 54 a 4 px sobre ella), y nunca la apaga: esa era la falla de 1 de cada 4 veces. Baja a través de la
			# silla como lo haría un jugador (agachado + saltar).
			if felipe.is_on_floor() and felipe.global_position.y < guion.aspi.global_position.y - BatallaAspi.ALTO_ARRIBA - 14.0:
				Input.action_press("agacharse")
				await _esperar(6)
				await _tocar("saltar")
				Input.action_release("agacharse")
			await _esperar(60)
	await _esperar(60)
	_comprobar(guion.aspi.vida.muerto and t.agenda.esta_cumplida("desenchufar") and "Desenchufada" in sala.logros, "Apagada tres veces: «Desenchufar a A.S.P.I.» y el logro")
	await _poner_en(sala.puertas[Nivel1.PUERTA_BALCON].global_position)
	await _tocar("interactuar")
	await _esperar(30)
	_comprobar(sala.habitacion == "balcon", "Apagada A.S.P.I., la puerta lleva al balcón")

	# Pausa.
	await _tocar("pausa")
	_comprobar(paused and sala.pantallas.modo == Pantallas.Modo.PAUSA, "Esc pausa el juego")
	await _tocar("pausa")
	_comprobar(not paused, "Esc otra vez continúa")

	# Balcón: sentarse en la baranda, la cámara se abre, salto real → Caer de Pie y el resumen del día.
	await _poner_en(Vector2(Nivel1.SALIDA, Nivel1.SUELO - 89))
	await _esperar(40)
	_comprobar(guion.balcon.sentado_en_baranda and _dijo("felipe", "gato de interior"), "En la baranda se sienta y suspira")
	_comprobar(not _maceta_en(felipe.global_position.x), "M6 Felipe se sienta AL LADO de la maceta de la baranda, no encima (x %.0f)" % felipe.global_position.x)
	Input.action_press("saltar")
	Input.action_press("mover_derecha")
	await _esperar(14)
	Input.action_release("saltar")
	var siempre_a_la_vista := true
	var cartel_antes_de_aterrizar := false
	var aterrizo := false
	for i in 400:
		await physics_frame
		siempre_a_la_vista = siempre_a_la_vista and _se_ve(felipe)
		cartel_antes_de_aterrizar = cartel_antes_de_aterrizar or (not aterrizo and _cartel_de("PODER NUEVO") != null)
		if felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO + 100.0:
			aterrizo = true
			break
	Input.action_release("mover_derecha")
	_comprobar(guion.balcon.salto_final and felipe.tiene_caer_de_pie, "El salto real desde la baranda da Caer de Pie")
	_comprobar(aterrizo and absf(felipe.global_position.y - Nivel1.TOLDO.position.y) < 2.0, "G1 Aterriza en el toldo de la panadería de abajo")
	_comprobar(siempre_a_la_vista, "G1 La cámara lo sigue: Felipe se ve en todo el salto")
	_comprobar(not cartel_antes_de_aterrizar, "G1 El cartel «PODER NUEVO» sale recién después de aterrizar")
	await _esperar_que(func() -> bool: return _cartel_de("PODER NUEVO") != null, 600)
	await _esperar(15)
	var cartel := _cartel_de("PODER NUEVO")
	var pies_en_pantalla := (sala.get_viewport().get_canvas_transform() * felipe.global_position).y
	_comprobar(cartel != null and "Caer de Pie" in sala.logros and _se_ve(felipe), "G1 Tras aterrizar, el cartel «PODER NUEVO · CAER DE PIE» y el logro, con Felipe a la vista")
	_comprobar(cartel != null and not Rect2(cartel.position, cartel.size).intersects(Rect2((sala.get_viewport().get_canvas_transform() * felipe.global_position) + Vector2(-34, -72), Vector2(68, 72))), "G1 El cartel no tapa a Felipe aterrizado")
	await create_timer(4.0).timeout
	var resumen: ResumenDia = null
	for hijo in t.get_children():
		if hijo is ResumenDia:
			resumen = hijo
	_comprobar(sala.terminado and resumen != null and paused, "Sale el resumen del día (en lugar de la pantalla final)")
	_comprobar(t.agenda.cumplidas() == Agenda.NIVEL_1.size(), "La agenda queda completa (%d de %d)" % [t.agenda.cumplidas(), Agenda.NIVEL_1.size()])
	_comprobar(_valeria_en_puerta == "", "Valeria nunca se paró en una puerta %s" % _valeria_en_puerta)
	_comprobar(_valeria_bajo_el_piso == "", "G1 Valeria nunca se dibuja bajo el piso %s" % _valeria_bajo_el_piso)
	_comprobar(_valeria_salto == "", "G3 Valeria nunca salta de lugar más de lo que camina en un cuadro, salvo por una puerta %s" % _valeria_salto)
	_comprobar(_valeria_sobre_mueble == "", "G2 De pie, Valeria siempre pisa el piso %s" % _valeria_sobre_mueble)
	paused = false
	Engine.time_scale = 1.0
	sala.queue_free()
	await process_frame

	# Lección 33, en una casa nueva (empujar a Felipe por todos los cuartos no debe tocar la partida de arriba).
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	await _esperar(30)
	await _barreras()
	await _entrar_por_puerta()
	sala.queue_free()
	await process_frame

	# Pantalla de título al empezar.
	var otra: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	root.add_child(otra)
	await process_frame
	_comprobar(paused and otra.pantallas.modo == Pantallas.Modo.TITULO, "El juego empieza en la pantalla de título")
	paused = false

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## ¿Alguien dijo algo que contiene `texto`?
## ¿La frase con `primero` salió antes que la frase con `despues`?
func _orden_dicho(primero: String, despues: String) -> bool:
	var i := -1
	var j := -1
	var historial: Array = sala.travesuras.dialogo.historial
	for k in historial.size():
		if i < 0 and primero in String(historial[k][1]):
			i = k
		if j < 0 and despues in String(historial[k][1]):
			j = k
	return i >= 0 and j > i


func _dijo(quien: String, texto: String) -> bool:
	return _contar(quien, texto) > 0


func _contar(quien: String, texto: String) -> int:
	var n := 0
	for linea: Array in sala.travesuras.dialogo.historial:
		if linea[0] == quien and texto in String(linea[1]):
			n += 1
	return n


func _raton_en(cuarto: String, y: float) -> Enemigo:
	for hijo in sala.get_children():
		if (hijo is Enemigo and hijo.datos.nombre == "Raton") and Nivel1.habitacion_de(hijo.global_position) == cuarto and absf(hijo.global_position.y - y) < 4.0:
			return hijo
	return null


func _zarpazo_a(objetivo: Node2D) -> void:
	felipe.vida.restante_invulnerable = 99.0
	await _poner_en(objetivo.global_position + Vector2(-34, 0))
	felipe.global_position = objetivo.global_position + Vector2(-34, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _tocar("zarpazo")
	await _esperar(30)
	felipe.vida.restante_invulnerable = 0.0


## Lo pone en un lugar y espera a que termine cualquier acción anterior (la animación dura 0,67 s).
## Lección 33: toda barrera bloquea DE VERDAD. Empuja a Felipe 1 s caminando contra cada muro de cada cuarto, contra
## cada mueble sólido que llega al piso (desde los dos lados que tengan sitio) y contra la pila de cajas, y prueba las
## puertas cerradas (cocina, balcón, baño): no se atraviesa nada ni se cambia de cuarto.
func _barreras() -> void:
	var solidos: Array[Rect2] = []
	for pieza: Array in Nivel1.PIEZAS:
		if not pieza[1] and pieza[3] != "invisible":
			solidos.append(pieza[0])
	solidos.append(guion.cajas.rect_solido())
	var malos: Array[String] = []
	var probados := 0
	# Muros de cada cuarto.
	for datos: Array in Nivel1.HABITACIONES:
		var cuarto: Rect2 = datos[0]
		for lado: float in [-1.0, 1.0]:
			var borde := cuarto.position.x if lado < 0.0 else cuarto.end.x
			var x := borde - lado * 45.0
			if _ocupado(x, solidos):
				continue
			probados += 1
			await _empujar(Vector2(x, Nivel1.SUELO), lado)
			var dentro := felipe.global_position.x - 19.0 >= cuarto.position.x and felipe.global_position.x + 19.0 <= cuarto.end.x
			if not dentro or Nivel1.habitacion_de(felipe.global_position) != datos[1]:
				malos.append("muro %s de %s (x %.0f)" % ["izquierdo" if lado < 0.0 else "derecho", datos[1], felipe.global_position.x])
	# Muebles sólidos que tocan el piso o dejan un hueco más bajo que Felipe de pie (zapatero, consola).
	for rect: Rect2 in solidos:
		if Nivel1.SUELO - rect.end.y > 50.0:
			continue
		for lado: float in [1.0, -1.0]:
			var x := rect.position.x - 45.0 if lado > 0.0 else rect.end.x + 45.0
			if _ocupado(x, solidos) or Nivel1.habitacion_de(Vector2(x, Nivel1.SUELO)) != Nivel1.habitacion_de(rect.get_center()):
				continue
			probados += 1
			await _empujar(Vector2(x, Nivel1.SUELO), lado)
			var pies := felipe.global_position.x
			var paso := pies + 19.0 > rect.position.x + 2.0 if lado > 0.0 else pies - 19.0 < rect.end.x - 2.0
			if paso and felipe.global_position.y > rect.position.y:
				malos.append("mueble en x %.0f–%.0f (Felipe en x %.0f)" % [rect.position.x, rect.end.x, pies])
	_comprobar(malos.is_empty() and probados >= 20, "Lección 33: Felipe empujado contra cada muro y mueble sólido no lo atraviesa (%d empujes) %s" % [probados, str(malos)])
	# Puertas cerradas: probarlas no lleva a ningún lado.
	var cerradas_ok := true
	for nombre: String in [Nivel1.PUERTA_COCINA, Nivel1.PUERTA_BALCON]:
		var puerta: Puerta = sala.puertas[nombre]
		await _poner_en(puerta.global_position, 10)
		var antes := sala.habitacion
		sala.cruzar(puerta)
		await _esperar(40)
		cerradas_ok = cerradas_ok and puerta.cerrada and sala.habitacion == antes and not sala.cruzando()
	await _poner_en(Nivel1.BANO, 10)
	guion.bano.cruzada.emit(guion.bano)
	await _esperar(30)
	cerradas_ok = cerradas_ok and sala.habitacion == "pasillo"
	_comprobar(cerradas_ok, "Lección 33: las puertas cerradas (cocina, balcón, baño) no dejan pasar")
	await _poner_en(Vector2(100, Nivel1.SUELO), 20)


## Cruzar una puerta (no la escalera): Felipe mira a la cámara, se da vuelta y entra (`entrar_puerta`, a su escala de
## siempre) y recién al terminar empieza el negro; del otro lado vuelve a quieto.
func _entrar_por_puerta() -> void:
	await _poner_en(sala.puertas["sala>recibidor"].global_position, 20)
	await _tocar("interactuar")
	for i in 4:
		await physics_frame
	var animando := felipe.sprite.animation == &"entrar_puerta" and felipe.sprite.is_playing()
	var negro_al_empezar := sala.fundido_alfa()
	var escala_ok := is_equal_approx(felipe.sprite.scale.x, Felipe.ESCALA_SPRITE) and is_equal_approx(absf(felipe.sprite.scale.y), Felipe.ESCALA_SPRITE)
	var cuadro_al_negro := -1
	while sala.cruce_en_curso() and sala.fundido_alfa() < 0.05:
		cuadro_al_negro = felipe.sprite.frame
		await physics_frame
	_comprobar(animando and negro_al_empezar < 0.01 and escala_ok, "Entrar por una puerta: Felipe hace «entrar_puerta» (a escala 0,72) antes del negro")
	_comprobar(cuadro_al_negro >= 6, "Entrar por una puerta: el fundido empieza al final de la animación (cuadro %d)" % cuadro_al_negro)
	await _esperar_que(func() -> bool: return not sala.cruce_en_curso(), 120)
	_comprobar(sala.habitacion == "recibidor" and felipe.sprite.animation != &"entrar_puerta", "Entrar por una puerta: del otro lado ya no sigue de espaldas")


func _ocupado(x: float, solidos: Array[Rect2]) -> bool:
	var cuerpo := Rect2(x - 20.0, Nivel1.SUELO - 52.0, 40.0, 52.0)
	for rect: Rect2 in solidos:
		if rect.intersects(cuerpo):
			return true
	return Nivel1.habitacion_de(Vector2(x, Nivel1.SUELO)) == ""


func _empujar(desde: Vector2, lado: float) -> void:
	await _poner_en(desde, 6)
	var accion := "mover_derecha" if lado > 0.0 else "mover_izquierda"
	Input.action_press(accion)
	await _esperar(60)
	Input.action_release(accion)
	await _esperar(4)


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
		_vigilar_valeria()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
		_vigilar_valeria()
	# Si quedó cruzando una puerta (Felipe entra de espaldas con «entrar_puerta» antes del fundido), se espera a que
	# termine: lo que se mira después es el otro lado.
	while is_instance_valid(sala) and sala.is_inside_tree() and sala.cruce_en_curso():
		await physics_frame
		_vigilar_valeria()


func _vigilar_valeria() -> void:
	if sala == null or not is_instance_valid(sala) or guion.valeria == null:
		return
	var v := guion.valeria
	if v.visible and v.rect_dibujado().end.y > Nivel1.SUELO + 0.5 and _valeria_bajo_el_piso == "":
		_valeria_bajo_el_piso = "(%s, pose %s, x %.0f, abajo %.0f)" % [Valeria.Actividad.keys()[v.actividad], v.pose(), v.global_position.x, v.rect_dibujado().end.y]
	if _valeria_antes != Vector2.INF and v.cruces == _valeria_cruces and _valeria_salto == "":
		var salto := absf(v.global_position.x - _valeria_antes.x)
		var cuadros := maxi(1, Engine.get_physics_frames() - _valeria_cuadro)
		if salto > Valeria.VELOCIDAD / 60.0 * cuadros + 0.5:
			_valeria_salto = "(%.0f px en %d cuadros, x %.0f)" % [salto, cuadros, v.global_position.x]
	_valeria_antes = v.global_position
	_valeria_cuadro = Engine.get_physics_frames()
	_valeria_cruces = v.cruces
	if v.actividad != Valeria.Actividad.SENTADA and v.actividad != Valeria.Actividad.FUERA and absf(v.global_position.y - Nivel1.SUELO) > 0.5:
		_valeria_sobre_mueble = "(%s, x %.0f, y %.0f)" % [Valeria.Actividad.keys()[v.actividad], v.global_position.x, v.global_position.y]
	if v.actividad in [Valeria.Actividad.CAMINANDO, Valeria.Actividad.FUERA, Valeria.Actividad.PUERTA]:
		return
	for datos: Array in Nivel1.PUERTAS:
		if datos[0] != Nivel1.PUERTA_ESCALERA and Nivel1.rect_sagrado(datos[1]).grow(-30).has_point(v.global_position - Vector2(0, 1)):
			_valeria_en_puerta = "(%s, x %.0f)" % [datos[0], v.global_position.x]


## Una foto vergonzosa suelta (sin recoger) en ese cuarto, o null.
func _foto_suelta(cuarto: String) -> Recogible:
	for hijo in sala.get_children():
		if hijo is Recogible and hijo.tipo == "foto" and Nivel1.habitacion_de(hijo.global_position) == cuarto:
			return hijo
	return null


## ¿Hay una maceta de la baranda donde se para Felipe? (la del medio se borró del arte: M6).
func _maceta_en(x: float) -> bool:
	var imagen: Image = ArteNivel.textura("baranda").get_image()
	var columna := int(x - 8276.0)
	# Solo la maceta que se dibuja (columnas 0–94; la de la derecha del arte se quitó) y todo el ancho de Felipe sentado.
	for dx in range(-28, 29):
		var cx := clampi(columna + dx, 0, imagen.get_width() - 1)
		if cx >= 95:
			continue
		for y in range(0, 30):
			if imagen.get_pixel(cx, y).a > 0.5:
				return true
	return false


## ¿Felipe (su cuerpo) está dentro de lo que muestra la cámara?
func _se_ve(quien: Node2D) -> bool:
	var vista := Rect2(Vector2.ZERO, Vector2(640, 360))
	var en_pantalla := sala.get_viewport().get_canvas_transform() * (quien.global_position + Vector2(0, -30))
	return vista.has_point(en_pantalla)


## El cartel del HUD cuyo título es ese (null si no está en pantalla).
func _cartel_de(titulo: String) -> Control:
	for hijo in sala.travesuras.hud.get_children():
		if hijo is Control and String(hijo.name).begins_with("Cartel"):
			for etiqueta in hijo.get_children():
				if etiqueta is Label and etiqueta.text == titulo:
					return hijo
	return null


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
