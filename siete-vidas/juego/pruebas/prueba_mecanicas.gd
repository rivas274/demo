extends SceneTree
## Prueba automática de las mecánicas: vida, desmayo, comer, peso, A.S.P.I., vaso, logros e interfaz.
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd

var _fallos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	var guion: GuionNivel1 = sala.guion
	sala.mostrar_titulo = false
	guion.batalla_con_jefe = false
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
	await _probar_huellas(sala, felipe, medidores)

	# A.S.P.I.: persigue y hace daño al tocar.
	await _esperar(90)
	aspi.global_position = Vector2(7140, Nivel1.SUELO)
	await _poner_en(felipe, Vector2(7020, Nivel1.SUELO))
	var medias_antes := felipe.medias
	for i in 180:
		await physics_frame
		if felipe.medias < medias_antes:
			break
	_comprobar(aspi.patrulla.persiguiendo or felipe.medias < medias_antes, "A.S.P.I. persigue a Felipe cuando lo ve")
	_comprobar(medias_antes - felipe.medias == 2, "A.S.P.I. quita una huella (2 medias) al tocarlo")

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


## Salud de 9 huellas (decisión del creador del 2026-10-23, siete-vidas/diseno/salud-9-huellas.md): medias por
## dentro, la opción «Golpes», curar, pocas huellas, desmayo sin perder nada, el Collar al tercero y el descanso.
func _probar_huellas(sala: Nivel, felipe: Felipe, medidores: Medidores) -> void:
	var dialogo := sala.travesuras.dialogo
	_comprobar(felipe.medias == 18 and Felipe.HUELLAS_MAX == 9 and is_equal_approx(felipe.salud.huellas(), 9.0), "Empieza con 9 huellas (18 medias por dentro)")
	_comprobar(not ("vidas" in felipe) and medidores.huellas.forma == BarraVida.Forma.HUELLAS and medidores.huellas.huellas() == 9, "No hay vidas aparte: el HUD muestra 9 huellas")
	# Daño: 1 huella por golpe e invulnerable 1,2 s.
	felipe.recibir_dano(2, felipe.global_position.x + 10.0)
	_comprobar(felipe.medias == 16, "Un golpe quita 1 huella (2 medias)")
	_comprobar(is_equal_approx(felipe.vida.restante_invulnerable, Felipe.TIEMPO_INVULNERABLE) and Felipe.TIEMPO_INVULNERABLE == 1.2, "Después del golpe, 1,2 s invulnerable")
	felipe.recibir_dano(2, felipe.global_position.x + 10.0)
	_comprobar(felipe.medias == 16, "Justo después de un golpe es invulnerable")
	_comprobar(medidores.huellas.animando.has(8) and medidores.huellas.animando[8][0] == BarraVida.Huella.GOLPE, "La huella que se pierde hace la animación de golpe")
	await _esperar(90)
	# Opción «Golpes» (accesibilidad): Suaves = ½ huella (se ve el estado «media»); Ninguno = empuja pero no quita.
	Opciones.golpes = Opciones.Golpes.SUAVES
	felipe.recibir_dano(2, felipe.global_position.x + 10.0)
	_comprobar(felipe.medias == 15 and BarraVida.estado_de(7, felipe.medias) == BarraVida.Huella.MEDIA, "Golpes «suaves»: quita media huella y la huella queda en «media»")
	await _esperar(90)
	Opciones.golpes = Opciones.Golpes.NINGUNO
	felipe.recibir_dano(2, felipe.global_position.x + 10.0)
	_comprobar(felipe.medias == 15 and absf(felipe.velocity.x) > 100.0 and felipe.vida.restante_invulnerable > 0.0, "Golpes «ninguno»: el golpe empuja, pero no quita")
	Opciones.golpes = Opciones.Golpes.NORMAL
	await _esperar(90)
	# Curar: comer cura 1 huella y suma peso.
	var peso_antes := felipe.peso
	await _poner_en(felipe, Vector2(2990, Nivel1.SUELO))
	await _tocar("interactuar")
	# Cura cuando la boca llega a la comida (cuadro de impacto de "comer").
	await _esperar(30)
	_comprobar(felipe.medias == 17, "Comer cura 1 huella (de 7 y media a 8 y media)")
	_comprobar(is_equal_approx(felipe.peso, peso_antes + Felipe.PESO_POR_COMIDA), "Comer sube el peso (%.1f kg)" % felipe.peso)
	await _esperar(60)
	var ficha: DatosFicha = load("res://datos/ui/ficha.tres")
	_comprobar(tr(ficha.humor(8.0)) == "Atlético" and tr(ficha.humor(10.0)) == "Modo Invierno" and tr(ficha.humor(12.0)) == "Modo Buda", "El peso le pone un humor a Felipe según los kilos (DatosFicha)")
	# Pocas huellas: con 3 o menos laten y Felipe lo dice una vez.
	dialogo.limpiar()
	felipe.medias = 8
	await _esperar(2)
	felipe.recibir_dano(2, felipe.global_position.x)
	await _esperar(4)
	_comprobar(medidores.huellas.latiendo() and _dijo(dialogo, "Esto es un empate técnico."), "Con 3 huellas o menos, las que quedan laten y Felipe dice «Esto es un empate técnico.»")
	await _esperar(90)
	# Desmayo: los 9 gatitos fantasma, reaparece lleno y sin perder nada, «Siesta táctica.».
	dialogo.limpiar()
	var snacks := felipe.snacks
	var peso := felipe.peso
	var calcetines := sala.travesuras.recompensas.calcetines
	felipe.medias = 2
	await _esperar(2)
	felipe.recibir_dano(2, felipe.global_position.x)
	await _esperar(20)
	var fantasmas := 0
	for hijo in felipe.get_parent().get_children():
		if hijo is Sprite2D and String(hijo.name).begins_with("Fantasma"):
			fantasmas += 1
	_comprobar(felipe.estado == Felipe.Estado.DESMAYADO and felipe.sprite.animation == "desmayo" and felipe.salud.desmayos == 1, "Sin huellas se desmaya")
	_comprobar(fantasmas == 9, "Las 9 huellas suben como 9 gatitos fantasma (%d)" % fantasmas)
	await _esperar(130)
	_comprobar(felipe.estado != Felipe.Estado.DESMAYADO and felipe.medias == 18, "Reaparece con las 9 huellas llenas")
	_comprobar(felipe.global_position.distance_to(felipe.punto_reaparicion) < 4.0, "Reaparece en el punto de descanso")
	_comprobar(felipe.snacks == snacks and is_equal_approx(felipe.peso, peso) and sala.travesuras.recompensas.calcetines == calcetines and not felipe.tiene_collar, "Desmayarse no quita nada (ni snacks, ni peso, ni calcetines; sin collar)")
	_comprobar(_dijo(dialogo, "Siesta táctica."), "Al volver dice «Siesta táctica.»")
	# El Collar de la Vergüenza llega al tercer desmayo del nivel.
	for i in 2:
		await _esperar(90)
		felipe.medias = 2
		await _esperar(2)
		felipe.recibir_dano(2, felipe.global_position.x)
		await _esperar(130)
	_comprobar(felipe.salud.desmayos == 3 and felipe.tiene_collar and felipe.medias == 18, "Al tercer desmayo del nivel llega el Collar de la Vergüenza")
	# El descanso llena todas las huellas.
	await _esperar(90)
	felipe.medias = 6
	await _poner_en(felipe, Vector2(Nivel1.DESCANSOS[1].get_center().x, Nivel1.SUELO))
	await _esperar(10)
	_comprobar(felipe.medias == 18, "Llegar a un descanso llena las 9 huellas")


func _dijo(dialogo: Dialogo, texto: String) -> bool:
	for frase: Array in dialogo.historial:
		if frase[0] == "felipe" and frase[1] == texto:
			return true
	return false


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
