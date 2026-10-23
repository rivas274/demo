extends SceneTree
## Capturas ampliadas ×3 de las capas en el estudio (v5, sistema de profundidad por rol): Felipe saltando delante del
## escritorio con el vaso, Felipe sobre el escritorio junto al vaso, A.S.P.I. bajo la silla, el escritorio y el
## librero bajo, y Felipe sobre el escritorio con A.S.P.I. debajo. Funciona también con la v4 (para el antes).
## Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_capas.gd -- <carpeta>

var _carpeta := "user://capas"
var sala: Nivel
var felipe: Felipe
var aspi: Enemigo


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	aspi = sala.guion.aspi
	felipe.vida.restante_invulnerable = 0.0
	await _esperar(30)
	var vaso: Node2D = null
	for nodo in sala.get_children():
		if nodo is Objeto and (nodo as Objeto).tipo == "vaso":
			vaso = nodo
	var escritorio := Nivel1.rect_pieza("Escritorio")
	var zona := Rect2(vaso.global_position.x - 70, escritorio.position.y - 70, 140, 130)
	# Al entrar al estudio empieza la pelea: se salta la entrada y se apagan los ataques (A.S.P.I. queda quieta).
	var batalla: BatallaAspi = sala.guion.batalla
	await _parar(Vector2(6990, Nivel1.SUELO), 10)
	for i in 120:
		if batalla.fase != PeleaJefe.Fase.ESPERANDO:
			break
		await physics_frame
	batalla.saltar_entrada()
	for i in 300:
		if batalla.fase == PeleaJefe.Fase.PELEA:
			break
		await physics_frame
	for nombre: String in ["embestida", "bola", "soplido"]:
		var conducta := batalla.conducta(nombre)
		if conducta:
			conducta.set("reloj_espera", 99999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([99999.0])
	await _esperar(60)
	# A.S.P.I. lejos para los dos primeros casos.
	await _aspi_en(7600.0)
	# 1. Sobre el escritorio junto al vaso.
	await _parar(Vector2(vaso.global_position.x + 26.0, escritorio.position.y - 2.0), 30)
	_capturar("1-sobre-el-escritorio-junto-al-vaso", zona)
	# 2. Saltando delante del escritorio, a la altura del vaso.
	await _parar(Vector2(vaso.global_position.x + 4.0, Nivel1.SUELO), 20)
	paused = false
	Input.action_press("saltar")
	for i in 40:
		await physics_frame
		if felipe.velocity.y > -40.0 and not felipe.is_on_floor():
			break
	Input.action_release("saltar")
	_capturar("2-saltando-delante-del-escritorio", zona)
	await _esperar(40)
	# 3. A.S.P.I. pasando bajo la silla, el escritorio y el librero bajo (Felipe en el piso, a un lado).
	for caso: Array in [["3a-aspi-bajo-la-silla", "Silla del estudio"], ["3b-aspi-bajo-el-escritorio", "Escritorio"], ["3c-aspi-bajo-el-librero", "Librero bajo"]]:
		var mueble := Nivel1.rect_pieza(caso[1])
		await _parar(Vector2(mueble.end.x + 70.0, Nivel1.SUELO), 10)
		await _aspi_en(mueble.get_center().x)
		_capturar(caso[0], Rect2(mueble.get_center().x - 80, mueble.position.y - 60, 200, Nivel1.SUELO - mueble.position.y + 75))
	# 4. Felipe sobre el escritorio con A.S.P.I. debajo.
	await _aspi_en(escritorio.get_center().x)
	await _parar(Vector2(escritorio.get_center().x, escritorio.position.y - 2.0), 30)
	_capturar("4-felipe-arriba-aspi-debajo", Rect2(escritorio.get_center().x - 80, escritorio.position.y - 70, 160, Nivel1.SUELO - escritorio.position.y + 80))
	quit()


func _aspi_en(x: float) -> void:
	var batalla: BatallaAspi = sala.guion.batalla
	batalla.manchas.clear()
	batalla.tipos_mancha.clear()
	batalla.nodos_mancha.clear()
	aspi.patrulla.quieta = true
	aspi.patrulla.destino = INF
	aspi.global_position = Vector2(x, Nivel1.SUELO)
	await _esperar(4)


func _parar(donde: Vector2, cuadros: int) -> void:
	paused = false
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		paused = false
		await physics_frame
	await process_frame


## Guarda la pantalla (640 × 360) y la zona del mundo ampliada ×3.
func _capturar(nombre: String, zona: Rect2) -> void:
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
	var lienzo := sala.get_viewport().get_canvas_transform()
	var escala := float(imagen.get_width()) / 640.0
	var r := Rect2(lienzo * zona.position, zona.size)
	var rect := Rect2i(Vector2i(r.position * escala), Vector2i(r.size * escala)).intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
	var parte := imagen.get_region(rect)
	parte.resize(parte.get_width() * 3, parte.get_height() * 3, Image.INTERPOLATE_NEAREST)
	parte.save_png("%s/%s-x3.png" % [_carpeta, nombre])
