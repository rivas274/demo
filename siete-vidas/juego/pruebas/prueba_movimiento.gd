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
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")

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
	_comprobar(not felipe.tiene_doble_salto, "El doble salto se gasta en el aire")

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
	_comprobar(felipe.tiene_doble_salto, "Al aterrizar recupera el doble salto")

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

	# Botón de acción: solo hace algo si hay un objeto cerca.
	await _esperar(40)
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
	var hueco := Sala.SUELO - _pieza("Aparador").end.y
	var alto_gateando := 0.0
	for i in felipe.sprite.sprite_frames.get_frame_count("gatear"):
		alto_gateando = maxf(alto_gateando, _alto_visible(felipe.sprite.sprite_frames.get_frame_texture("gatear", i).get_image()) * Felipe.ESCALA_SPRITE)
	_comprobar(alto_gateando <= hueco, "Gateando cabe bajo el aparador (%.0f px de %.0f libres)" % [alto_gateando, hueco])
	Input.action_release("mover_derecha")
	Input.action_release("agacharse")
	await _esperar(2)
	_comprobar(not felipe.agachado and felipe.sprite.animation == "agacharse", "Al soltar S se para con la transición al revés")
	await _esperar(20)
	_comprobar(felipe.sprite.animation == "quieto", "Después de pararse queda quieto")

	# Debajo del aparador (30 cm libres) solo se pasa agachado.
	var aparador := _pieza("Aparador")
	await _poner_en(felipe, Vector2(aparador.position.x - 60, Sala.SUELO))
	Input.action_press("mover_derecha")
	await _esperar(60)
	_comprobar(felipe.position.x < aparador.position.x, "De pie no cabe bajo el aparador")
	Input.action_press("agacharse")
	for i in 240:
		await physics_frame
		if felipe.position.x > aparador.get_center().x:
			break
	Input.action_release("agacharse")
	await _esperar(4)
	_comprobar(felipe.position.x > aparador.get_center().x and felipe.agachado, "Bajo el aparador sigue agachado aunque suelte S")
	for i in 240:
		await physics_frame
		if felipe.position.x > aparador.end.x + 30:
			break
	await _esperar(4)
	Input.action_release("mover_derecha")
	_comprobar(felipe.position.x > aparador.end.x and not felipe.agachado, "Al salir del aparador se para solo")

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
	var platos := root.get_tree().get_nodes_in_group(Comida.GRUPO).size()
	await _poner_en(felipe, Vector2(1400, Sala.SUELO))
	await _tocar("interactuar")
	_comprobar(felipe.estado == Felipe.Estado.COMIENDO and felipe.sprite.animation == "comer", "Junto a la comida, el botón de acción la come")
	await _esperar(60)
	_comprobar(root.get_tree().get_nodes_in_group(Comida.GRUPO).size() == platos - 1, "La comida desaparece al comerla")

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


## Mira el cuadro que se está dibujando y compara dónde está su punto más bajo
## con el centro del cuerpo: debe quedar del lado hacia donde mira Felipe.
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
