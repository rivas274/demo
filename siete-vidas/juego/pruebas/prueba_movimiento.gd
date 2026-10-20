extends SceneTree
## Prueba automática del movimiento de Felipe. Se ejecuta sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

## Animaciones hechas desde poses editadas, que no tienen las proporciones de Felipe A (ver pendientes).
const PENDIENTES_DE_REHACER := []

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Node = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.peligros_activos = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	# En el nivel 1 el doble salto, los Zoomies y trepar vienen apagados (decisión del creador): aquí se prenden
	# para seguir probándolos; prueba_acciones.gd comprueba que estén apagados por defecto.
	felipe.tiene_doble_salto = true
	felipe.tiene_zoomies = true
	felipe.puede_trepar = true
	# Esta prueba es solo del movimiento: los enemigos se prueban en prueba_mecanicas.gd.
	for enemigo in root.get_tree().get_nodes_in_group("enemigos"):
		enemigo.queue_free()

	await _esperar(30)
	_comprobar(felipe.is_on_floor(), "Felipe empieza apoyado en el piso")
	var alto := _alto_dibujado(felipe)
	_comprobar(alto > 60.0 and alto < 74.0, "Felipe mide unos 67 px, un tercio de Valeria (%.0f px)" % alto)

	var x_inicial := felipe.position.x
	Input.action_press("mover_derecha")
	await _esperar(40)
	Input.action_release("mover_derecha")
	_comprobar(felipe.position.x > x_inicial + 40.0, "Caminar a la derecha lo mueve (%.0f px)" % (felipe.position.x - x_inicial))
	_comprobar(felipe.sprite.animation == "caminar", "Usa la animación de caminar")
	await _probar_patas_sin_patinar(felipe)

	await _esperar(30)
	var y_suelo := felipe.position.y
	Input.action_press("saltar")
	var deformacion := 0.0
	for i in 12:
		await physics_frame
		var escala := felipe.sprite.scale / Felipe.ESCALA_SPRITE
		deformacion = maxf(deformacion, maxf(absf(escala.x - 1.0), absf(escala.y - 1.0)))
	var altura := y_suelo - felipe.position.y
	_comprobar(altura > 30.0, "Saltar lo eleva (%.0f px)" % altura)
	_comprobar(felipe.sprite.animation == "saltar", "Usa la animación de saltar")
	_comprobar(deformacion <= Felipe.DEFORMACION_MAXIMA + 0.001, "Al saltar se deforma como mucho un 8 %% (%.0f %%)" % (deformacion * 100.0))
	Input.action_release("saltar")
	await _esperar(4)
	Input.action_press("saltar")
	await _esperar(2)
	Input.action_release("saltar")
	_comprobar(not felipe.doble_salto_disponible, "El doble salto se gasta en el aire")

	# Reglas del salto acordadas en la ficha de concepto.
	for i in 90:
		await physics_frame
		if felipe.velocity.y > 250.0:
			break
	_comprobar(felipe.sprite.animation == "caer" and felipe.sprite.frame == Felipe.CUADRO_CAYENDO, "Al caer usa la pose de caída")
	_comprobar(_patas_delanteras_abajo(felipe), "Al caer, lo más bajo de Felipe son las patas delanteras")
	for i in 90:
		await physics_frame
		if felipe.is_on_floor():
			break
	await _esperar(1)
	_comprobar(felipe.estado == Felipe.Estado.ATERRIZANDO and felipe.sprite.animation == "caer" and felipe.sprite.frame == Felipe.CUADRO_CONTACTO, "Al tocar el piso usa la pose de contacto")
	_comprobar(_patas_delanteras_abajo(felipe), "Al tocar el piso, las delanteras tocan primero")
	await _esperar(6)
	_comprobar(felipe.sprite.animation == "saltar" and felipe.sprite.frame == Felipe.CUADRO_ATERRIZAJE, "Después baja la parte de atrás y se aplasta")
	await _esperar(12)
	_comprobar(absf(felipe.sprite.rotation) < 0.02, "Después de aterrizar queda derecho")

	await _esperar(60)
	_comprobar(felipe.is_on_floor(), "Vuelve a aterrizar")
	_comprobar(felipe.doble_salto_disponible, "Al aterrizar recupera el doble salto")
	await _probar_ajuste_del_salto(felipe)

	var x_antes := felipe.position.x
	Input.action_press("zoomies")
	await _esperar(8)
	Input.action_release("zoomies")
	_comprobar(felipe.position.x - x_antes > 25.0, "Los Zoomies lo impulsan (%.0f px)" % (felipe.position.x - x_antes))

	await _esperar(20)
	Input.action_press("zarpazo")
	await _esperar(2)
	Input.action_release("zarpazo")
	_comprobar(felipe.sprite.animation == "zarpazo", "El zarpazo reproduce su animación")

	# Botón de acción: solo hace algo si hay un objeto cerca (lejos del sofá arañable).
	await _esperar(40)
	await _poner_en(felipe, Vector2(120, Sala.SUELO))
	await _tocar("interactuar")
	_comprobar(felipe.estado != Felipe.Estado.COMIENDO, "Sin comida cerca, el botón de acción no hace nada")

	# Agacharse y gatear.
	Input.action_press("agacharse")
	await _esperar(2)
	_comprobar(felipe.agachado and felipe.sprite.animation == "agacharse", "S lo agacha, primero con la transición")
	Input.action_press("mover_derecha")
	await _esperar(40)
	_comprobar(absf(felipe.velocity.x) <= felipe.velocidad_gatear + 1.0, "Agachado gatea más lento (%.0f px/s)" % absf(felipe.velocity.x))
	_comprobar(felipe.sprite.animation == "gatear" and felipe.sprite.is_playing(), "Agachado y en movimiento usa la animación de gatear")
	var hueco := Sala.SUELO - _pieza("Zapatero").end.y
	var alto_gateando := 0.0
	for i in felipe.sprite.sprite_frames.get_frame_count("gatear"):
		alto_gateando = maxf(alto_gateando, _alto_visible(felipe.sprite.sprite_frames.get_frame_texture("gatear", i).get_image()) * Felipe.ESCALA_SPRITE)
	_comprobar(alto_gateando <= hueco, "Gateando cabe bajo el zapatero (%.0f px de %.0f libres)" % [alto_gateando, hueco])
	Input.action_release("mover_derecha")
	Input.action_release("agacharse")
	await _esperar(2)
	_comprobar(not felipe.agachado and felipe.sprite.animation == "agacharse", "Al soltar S se para con la transición al revés")
	await _esperar(20)
	_comprobar(felipe.sprite.animation == "quieto", "Después de pararse queda quieto")

	# Debajo del zapatero (33 cm libres) solo se pasa agachado.
	var aparador := _pieza("Zapatero")
	await _poner_en(felipe, Vector2(aparador.position.x - 60, Sala.SUELO))
	Input.action_press("mover_derecha")
	await _esperar(60)
	_comprobar(felipe.position.x < aparador.position.x, "De pie no cabe bajo el zapatero")
	Input.action_press("agacharse")
	for i in 240:
		await physics_frame
		if felipe.position.x > aparador.get_center().x:
			break
	Input.action_release("agacharse")
	await _esperar(4)
	_comprobar(felipe.position.x > aparador.get_center().x and felipe.agachado, "Bajo el zapatero sigue agachado aunque suelte S")
	for i in 240:
		await physics_frame
		if felipe.position.x > aparador.end.x + 30:
			break
	await _esperar(4)
	Input.action_release("mover_derecha")
	_comprobar(felipe.position.x > aparador.end.x and not felipe.agachado, "Al salir del zapatero se para solo")

	# Agachado + saltar sobre un mueble atravesable: baja a través de él.
	var mesa := _pieza("Mesa")
	await _poner_en(felipe, Vector2(mesa.get_center().x, mesa.position.y))
	_comprobar(felipe.is_on_floor() and felipe.position.y <= mesa.position.y + 1.0, "Se para sobre la mesa")
	Input.action_press("agacharse")
	await _esperar(4)
	await _tocar("saltar")
	Input.action_release("agacharse")
	await _esperar(40)
	_comprobar(felipe.position.y > mesa.position.y + 40.0, "Agachado + saltar baja a través de la mesa")

	# Con comida cerca, el botón de acción la come.
	var platos := root.get_tree().get_nodes_in_group(Componentes.INTERACTUABLES).size()
	await _poner_en(felipe, Vector2(2990, Sala.SUELO))
	await _tocar("interactuar")
	_comprobar(felipe.estado == Felipe.Estado.COMIENDO and felipe.sprite.animation == "comer", "Junto a la comida, el botón de acción la come")
	await _esperar(60)
	_comprobar(root.get_tree().get_nodes_in_group(Componentes.INTERACTUABLES).size() == platos - 1, "La comida desaparece al comerla")

	# Ocio: sin tocar nada, se pone a acicalarse, jugar o dar vueltas; cualquier botón lo corta.
	await _poner_en(felipe, Vector2(200, Sala.SUELO))
	felipe.espera_ocio = 1.0
	await _esperar(80)
	_comprobar(felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation in Felipe.OCIO.keys(), "Sin tocar nada se entretiene solo (%s)" % felipe.sprite.animation)
	Input.action_press("mover_derecha")
	await _esperar(3)
	Input.action_release("mover_derecha")
	_comprobar(felipe.estado != Felipe.Estado.OCIO and felipe.sprite.animation == "caminar" and is_equal_approx(felipe.sprite.scale.x, Felipe.ESCALA_SPRITE), "Al tocar un botón deja de entretenerse y vuelve a su tamaño")
	felipe._empezar_ocio("jugar")
	await _esperar(2)
	_comprobar(felipe.get_node_or_null("Estambre") != null, "Al jugar aparece la bola de estambre frente a Felipe")
	Input.action_press("saltar")
	await _esperar(2)
	Input.action_release("saltar")
	await _esperar(2)
	_comprobar(not felipe.get_children().any(func(n: Node) -> bool: return n is Sprite2D and n.texture == Felipe.BOLA_ESTAMBRE), "Al dejar de jugar la bola desaparece")
	await _esperar(60)
	# Proporciones: todas las hojas salen de Felipe A en cuadros de 106 px y se dibujan a la misma escala,
	# así la cabeza mide siempre lo mismo. PENDIENTES_DE_REHACER son las que todavía no cumplen.
	for nombre: String in AnimacionesFelipe.HOJAS:
		if nombre in PENDIENTES_DE_REHACER:
			continue
		var cuadro := felipe.sprite.sprite_frames.get_frame_texture(nombre, 0)
		_comprobar(cuadro.get_width() == 106 and cuadro.get_height() == 106, "La animación %s usa cuadros de 106 px como Felipe A" % nombre)

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


## Ajuste del salto (2026-10-19): la subida no cambia (misma altura), cae con más peso (1,7 × la gravedad), margen
## de 0,12 s al salir de un borde, salto recordado de 0,15 s y más polvo cuanto más fuerte cae (sin pasar del ±8 %).
func _probar_ajuste_del_salto(felipe: Felipe) -> void:
	felipe.tiene_doble_salto = false
	var proporcion := felipe.gravedad_cayendo / felipe.gravedad
	_comprobar(proporcion > 1.6 and proporcion < 1.8, "Cae con más peso que sube (gravedad de caída %.2f × la de subida)" % proporcion)

	# Salto completo en el piso: altura y tiempos de subida y bajada.
	await _poner_en(felipe, Vector2(200, Sala.SUELO))
	var y_suelo := felipe.position.y
	var y_arriba := y_suelo
	var cuadros_subida := 0
	var cuadros_bajada := 0
	var velocidad_maxima := 0.0
	Input.action_press("saltar")
	await physics_frame
	for i in 120:
		await physics_frame
		if felipe.position.y < y_arriba:
			y_arriba = felipe.position.y
			cuadros_subida = i + 1
		velocidad_maxima = maxf(velocidad_maxima, felipe.velocity.y)
		if felipe.is_on_floor():
			cuadros_bajada = i + 1 - cuadros_subida
			break
	Input.action_release("saltar")
	var altura := y_suelo - y_arriba
	_comprobar(altura > 76.0 and altura < 88.0, "La subida no cambió: el salto sigue llegando a unos 80 px (%.0f px)" % altura)
	_comprobar(cuadros_bajada < cuadros_subida, "Baja más rápido de lo que sube (%d cuadros subiendo, %d bajando)" % [cuadros_subida, cuadros_bajada])

	# Margen al salir de un borde: 7 cuadros (0,117 s) después de dejar la mesa todavía salta.
	var mesa := _pieza("Mesa")
	await _poner_en(felipe, Vector2(mesa.end.x - 26.0, mesa.position.y))
	Input.action_press("mover_derecha")
	for i in 60:
		await physics_frame
		if not felipe.is_on_floor():
			break
	# El botón apretado aquí se lee en el cuadro siguiente: 7 cuadros en el aire en total.
	await _esperar(5)
	Input.action_press("saltar")
	await _esperar(2)
	Input.action_release("mover_derecha")
	_comprobar(felipe.velocity.y < -300.0, "Margen de %.2f s: salta 0,117 s después de dejar el borde" % felipe.margen_salto)
	await _esperar(10)
	Input.action_release("saltar")
	await _esperar(60)

	# Salto recordado: apretar 8 cuadros antes de tocar el piso (se lee 7 antes: 0,133 s al saltar) salta al llegar.
	var desde := Vector2(200, Sala.SUELO - 150.0)
	var cuadros_cayendo := 0
	felipe.position = desde
	felipe.velocity = Vector2.ZERO
	for i in 120:
		await physics_frame
		if felipe.is_on_floor():
			cuadros_cayendo = i
			break
	await _esperar(30)
	felipe.position = desde
	felipe.velocity = Vector2.ZERO
	var salto_al_llegar := false
	for i in cuadros_cayendo + 4:
		if i == cuadros_cayendo - 8:
			Input.action_press("saltar")
		await physics_frame
		if i > cuadros_cayendo and felipe.velocity.y < -300.0:
			salto_al_llegar = true
	Input.action_release("saltar")
	_comprobar(salto_al_llegar, "Salto recordado de %.2f s: apretar justo antes de aterrizar cuenta" % felipe.salto_recordado)
	await _esperar(80)

	# Polvo: una caída desde alto (2 m) levanta más que un saltito, y el aplastado sigue en ±8 %.
	var polvo_de := func(altura_caida: float) -> Array:
		felipe.position = Vector2(200, Sala.SUELO - altura_caida)
		felipe.velocity = Vector2.ZERO
		var deformacion := 0.0
		var velocidad := 0.0
		for i in 120:
			await physics_frame
			velocidad = maxf(velocidad, felipe.velocity.y)
			if felipe.is_on_floor():
				break
		for i in 20:
			var escala := felipe.sprite.scale / Felipe.ESCALA_SPRITE
			deformacion = maxf(deformacion, maxf(absf(escala.x - 1.0), absf(escala.y - 1.0)))
			await physics_frame
		var granos := felipe.polvo.amount
		await _esperar(30)
		return [granos, deformacion, velocidad]
	var bajo: Array = await polvo_de.call(30.0)
	var alto: Array = await polvo_de.call(240.0)
	_comprobar(alto[0] > bajo[0] + 10, "Al aterrizar desde alto suelta más polvo (%d granos desde 2 m, %d desde 30 px)" % [alto[0], bajo[0]])
	_comprobar(alto[2] <= felipe.caida_maxima + 0.5, "La caída no pasa del tope (%.0f px/s de %.0f)" % [alto[2], felipe.caida_maxima])
	_comprobar(alto[1] <= Felipe.DEFORMACION_MAXIMA + 0.001, "Al aterrizar desde alto se aplasta como mucho un 8 %% (%.0f %%)" % (alto[1] * 100.0))
	felipe.tiene_doble_salto = true


## Mira el cuadro que se está dibujando y compara dónde está su punto más bajo
## con el centro del cuerpo: debe quedar del lado hacia donde mira Felipe.
## G9 (revisión 3): las patas no patinan. Se mide en la hoja cuánto adelanta el pie apoyado por cuadro (AnimacionesFelipe
## .PASO debe coincidir con la medida, ±0,5 px) y, en el juego, que el ciclo vaya al ritmo de la velocidad: el pie
## apoyado se desliza ≤ 2 px por cuadro caminando y corriendo.
func _probar_patas_sin_patinar(felipe: Felipe) -> void:
	var medir := preload("res://pruebas/medir_pasos.gd")
	# Hoja de pasos largos: se mide en las 4 filas del piso (con 8 filas, la pata que se levanta tapa el calce).
	var hoja_caminar: String = AnimacionesFelipe.HOJAS["caminar"][0]
	_comprobar(hoja_caminar == "felipe-caminar-largo-sheet.png", "Caminar usa la hoja de pasos largos (%s)" % hoja_caminar)
	var medidas: Array = medir.pie_apoyado(AnimacionesFelipe.CARPETA + hoja_caminar, AnimacionesFelipe.CUADROS, 4, 20, 40.0)
	var suma := 0.0
	for m: Array in medidas:
		suma += -float(m[1])
	var paso_hoja := suma / maxf(medidas.size(), 1.0) * Felipe.ESCALA_SPRITE
	_comprobar(medidas.size() >= 5 and absf(paso_hoja - AnimacionesFelipe.PASO["caminar"]) <= 0.2, "G9 El pie apoyado de caminar adelanta %.1f px del juego por cuadro (AnimacionesFelipe.PASO: %.1f)" % [paso_hoja, AnimacionesFelipe.PASO["caminar"]])
	for datos: Array in [["caminar", felipe.velocidad_caminar, false], ["correr", felipe.velocidad_correr, true]]:
		var nombre: String = datos[0]
		_poner_en(felipe, Vector2(300, Sala.SUELO))
		await _esperar(20)
		if datos[2]:
			Input.action_press("zoomies")
		Input.action_press("mover_derecha")
		await _esperar(50)
		var fps := felipe.sprite.speed_scale * felipe.sprite.sprite_frames.get_animation_speed(felipe.sprite.animation)
		var anim := felipe.sprite.animation
		var v := absf(felipe.velocity.x)
		Input.action_release("mover_derecha")
		Input.action_release("zoomies")
		var desliza := v / fps - float(AnimacionesFelipe.PASO[nombre])
		_comprobar(anim == nombre and desliza <= 2.0 and fps <= AnimacionesFelipe.FPS_MAXIMO + 0.01, "G9 Al %s (%.0f px/s) el ciclo va a %.0f cuadros/s: el pie apoyado se desliza %.1f px por cuadro (≤ 2)" % [nombre, v, fps, desliza])
		await _esperar(30)


func _patas_delanteras_abajo(felipe: Felipe) -> bool:
	var imagen := felipe.sprite.sprite_frames.get_frame_texture(felipe.sprite.animation, felipe.sprite.frame).get_image()
	var suma_x := 0.0
	var opacos := 0
	var fila_mas_baja := -1
	for y in imagen.get_height():
		for x in imagen.get_width():
			if imagen.get_pixel(x, y).a > 0.5:
				suma_x += x
				opacos += 1
				fila_mas_baja = y
	var suma_abajo := 0.0
	var abajo := 0
	for y in range(maxi(0, fila_mas_baja - 2), fila_mas_baja + 1):
		for x in imagen.get_width():
			if imagen.get_pixel(x, y).a > 0.5:
				suma_abajo += x
				abajo += 1
	var lado := (suma_abajo / abajo) - (suma_x / opacos)
	if felipe.sprite.flip_h:
		lado = -lado
	return lado > 3.0


## Alto en pantalla de Felipe en la pose de referencia (primer cuadro de "quieto", con la cola abajo).
func _alto_dibujado(felipe: Felipe) -> float:
	return _alto_visible(felipe.sprite.sprite_frames.get_frame_texture("quieto", 0).get_image()) * Felipe.ESCALA_SPRITE


## Filas de la imagen con pixeles visibles (opacidad mayor a 0,5).
func _alto_visible(imagen: Image) -> float:
	var arriba := -1
	var abajo := -1
	for y in imagen.get_height():
		for x in imagen.get_width():
			if imagen.get_pixel(x, y).a > 0.5:
				if arriba < 0:
					arriba = y
				abajo = y
				break
	return abajo - arriba + 1


func _pieza(nombre: String) -> Rect2:
	for pieza: Array in Sala.PIEZAS:
		if pieza[2] == nombre:
			return pieza[0]
	return Rect2()


func _poner_en(felipe: Felipe, posicion: Vector2) -> void:
	felipe.position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await _esperar(2)
	Input.action_release(accion)


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
