extends SceneTree
## Prueba automática de las mecánicas: vida, desmayo, comer, peso, A.S.P.I., vaso, logros e interfaz.
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	var aspi: Enemigo = sala.get_node("ASPI")
	# Los ratones de cuerda tienen su propia prueba (prueba_nivel); aquí estorbarían.
	for hijo in sala.get_children():
		if (hijo is Enemigo and hijo.datos.nombre == "Raton"):
			hijo.queue_free()
	await _esperar(30)

	# Interfaz.
	var medidores := sala.get_node("Interfaz/Medidores") as Medidores
	_comprobar(medidores != null and medidores.felipe == felipe, "La interfaz muestra los medidores de Felipe")
	_comprobar(felipe.corazones == Felipe.CORAZONES_MAX and felipe.vidas == Felipe.VIDAS_MAX, "Empieza con 5 corazones y 9 vidas")

	# Daño e invulnerabilidad.
	felipe.recibir_dano(1, felipe.global_position.x + 10.0)
	_comprobar(felipe.corazones == 4, "Un golpe quita un corazón")
	felipe.recibir_dano(1, felipe.global_position.x + 10.0)
	_comprobar(felipe.corazones == 4, "Justo después de un golpe es invulnerable")
	await _esperar(90)

	# Comer cura y suma peso.
	var peso_antes := felipe.peso
	await _poner_en(felipe, Vector2(2990, Sala.SUELO))
	await _tocar("interactuar")
	# Cura cuando la boca llega a la comida (cuadro de impacto de "comer").
	await _esperar(30)
	_comprobar(felipe.corazones == 5, "Comer cura un corazón")
	_comprobar(is_equal_approx(felipe.peso, peso_antes + Felipe.PESO_POR_COMIDA), "Comer sube el peso (%.1f kg)" % felipe.peso)
	await _esperar(60)

	_comprobar(Medidores.nivel_de_peso(8.0) == "Atlético" and Medidores.nivel_de_peso(10.0) == "Modo Invierno" and Medidores.nivel_de_peso(12.0) == "Modo Buda", "El peso le pone un humor a Felipe según los kilos")

	# Desmayo y reaparición.
	for i in Felipe.CORAZONES_MAX:
		felipe.recibir_dano(1, felipe.global_position.x)
		await _esperar(80)
	_comprobar(felipe.estado == Felipe.Estado.DESMAYADO and felipe.sprite.animation == "desmayo", "Sin corazones se desmaya")
	_comprobar(felipe.vidas == Felipe.VIDAS_MAX - 1, "Desmayarse cuesta una vida")
	await _esperar(130)
	_comprobar(felipe.estado != Felipe.Estado.DESMAYADO and felipe.corazones == Felipe.CORAZONES_MAX, "Reaparece con los corazones llenos")
	_comprobar(felipe.global_position.distance_to(felipe.punto_reaparicion) < 4.0, "Reaparece en el punto de descanso")
	felipe.vidas = 1
	felipe.corazones = 1
	await _esperar(90)
	felipe.recibir_dano(1, felipe.global_position.x)
	await _esperar(130)
	_comprobar(felipe.vidas == Felipe.VIDAS_MAX and felipe.tiene_collar, "Al perder la última vida despierta con el Collar de la Vergüenza")

	# A.S.P.I.: persigue y hace daño al tocar.
	await _esperar(90)
	aspi.global_position = Vector2(7140, Sala.SUELO)
	await _poner_en(felipe, Vector2(7020, Sala.SUELO))
	var corazones_antes := felipe.corazones
	for i in 180:
		await physics_frame
		if felipe.corazones < corazones_antes:
			break
	_comprobar(aspi.patrulla.persiguiendo or felipe.corazones < corazones_antes, "A.S.P.I. persigue a Felipe cuando lo ve")
	_comprobar(felipe.corazones < corazones_antes, "A.S.P.I. quita un corazón al tocarlo")

	# Tres zarpazos la apagan (Felipe invulnerable para que el contacto no lo empuje entre golpe y golpe).
	await _esperar(90)
	felipe.vida.restante_invulnerable = 99.0
	felipe.global_position = aspi.global_position + Vector2(-30, 0)
	felipe.mirando = 1.0
	felipe.estado = Felipe.Estado.SUELO
	await _esperar(2)
	await _tocar("zarpazo")
	await _esperar(30)
	_comprobar((aspi.vida.maximo - aspi.vida.actual) == 0, "Sin aturdir, el zarpazo rebota en A.S.P.I.")
	for i in aspi.vida.maximo:
		aspi.recibe_golpes.aturdir(3.0)
		felipe.global_position = aspi.global_position + Vector2(-30, 0)
		felipe.mirando = 1.0
		felipe.velocity = Vector2.ZERO
		felipe.estado = Felipe.Estado.SUELO
		await _esperar(2)
		await _tocar("zarpazo")
		await _esperar(30)
	_comprobar(aspi.vida.muerto, "Tres zarpazos con A.S.P.I. aturdida la apagan (%d golpes)" % (aspi.vida.maximo - aspi.vida.actual))
	felipe.vida.restante_invulnerable = 0.0

	# Vaso: tirarlo da el logro.
	await _esperar(90)
	var vaso: Objeto = sala.get_node("Vaso")
	await _poner_en(felipe, Vector2(vaso.position.x - 30, vaso.position.y))
	felipe.mirando = 1.0
	await _tocar("interactuar")
	_comprobar(felipe.sprite.animation == "zarpazo", "Tirar el vaso con el botón de acción usa la animación del zarpazo")
	await _esperar(90)
	_comprobar(vaso.tirable.roto, "El vaso cae y se rompe")
	_comprobar("La Gravedad Funciona" in sala.logros, "Tirar el vaso da el logro La Gravedad Funciona")

	for fallo in _fallos:
		printerr("FALLO: " + fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _poner_en(felipe: Felipe, posicion: Vector2) -> void:
	felipe.global_position = posicion
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
