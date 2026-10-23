extends SceneTree
## Capturas del nivel 1 sin interfaz (fondos para las maquetas de la interfaz v2). No cambia el juego: carga el
## nivel, esconde las capas de interfaz, el HUD y el indicador, y guarda la sala y la pelea a 640 × 360.
## Uso (necesita pantalla):
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --resolution 640x360 \
##     --script <ruta absoluta a este archivo> -- <carpeta>

var _carpeta := "/tmp"
var sala: Nivel
var felipe: Felipe


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	_correr.call_deferred()


func _sin_ui(nodo: Node) -> void:
	for hijo in nodo.get_children():
		if hijo is CanvasLayer and (hijo as CanvasLayer).layer >= 1:
			(hijo as CanvasLayer).visible = false
		if hijo is CanvasItem and (hijo is Indicador or hijo.name == "Medidores" or hijo.name == "Hud"):
			(hijo as CanvasItem).visible = false
		_sin_ui(hijo)


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	felipe.vida.restante_invulnerable = 99999.0
	await _esperar(40)
	# Sala con Valeria en el sofá: Felipe en el piso, a la izquierda del sofá.
	await _parar(Vector2(200, Nivel1.SUELO), 90)
	_sin_ui(root)
	await _esperar(2)
	_capturar("limpia-sala")
	await _parar(Vector2(520, Nivel1.SUELO), 60)
	_sin_ui(root)
	await _esperar(2)
	_capturar("limpia-sala-2")
	# Pelea: entra al estudio y se salta la entrada.
	var guion: GuionNivel1 = sala.guion
	var batalla: BatallaAspi = guion.batalla
	var aspi: Enemigo = guion.aspi
	await _parar(Vector2(6842, Nivel1.SUELO), 30)
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
	for nombre: String in ["embestida", "bola"]:
		batalla.conducta(nombre).set("reloj_espera", 9999.0)
	(batalla.conducta("embestida") as AtaqueEmbestida).espera = PackedFloat32Array([9999.0])
	(batalla.conducta("bola") as AtaqueBolaPelo).espera = 9999.0
	await _esperar(60)
	felipe.vida.restante_invulnerable = 0.0
	await _parar(Vector2(aspi.global_position.x - 150.0, Nivel1.SUELO), 50)
	_sin_ui(root)
	await _esperar(2)
	_capturar("limpia-pelea")
	await _parar(Vector2(aspi.global_position.x + 160.0, Nivel1.SUELO), 50)
	_sin_ui(root)
	await _esperar(2)
	_capturar("limpia-pelea-2")
	quit()


func _parar(donde: Vector2, cuadros: int) -> void:
	felipe.global_position = donde
	felipe.velocity = Vector2.ZERO
	await _esperar(cuadros)


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
	await process_frame


func _capturar(nombre: String) -> void:
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
