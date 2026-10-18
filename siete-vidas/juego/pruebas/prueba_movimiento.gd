extends SceneTree
## Prueba automática del movimiento de Felipe. Se ejecuta sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

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
	await _esperar(12)
	var altura := y_suelo - felipe.position.y
	_comprobar(altura > 30.0, "Saltar lo eleva (%.0f px)" % altura)
	_comprobar(felipe.sprite.animation == "saltar", "Usa la animación de saltar")
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
	var imagen := felipe.sprite.sprite_frames.get_frame_texture("quieto", 0).get_image()
	var arriba := -1
	var abajo := -1
	for y in imagen.get_height():
		for x in imagen.get_width():
			if imagen.get_pixel(x, y).a > 0.5:
				if arriba < 0:
					arriba = y
				abajo = y
				break
	return (abajo - arriba + 1) * Felipe.ESCALA_SPRITE


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	print(("OK    " if condicion else "FALLA ") + descripcion)
	if not condicion:
		_fallos.append(descripcion)
