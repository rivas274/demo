extends SceneTree
## Cuadros de las animaciones nuevas de Felipe en el juego (derrape de los Zoomies, sentarse y entrar por una
## puerta), para armar GIF y revisarlas a su escala. Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_animaciones.gd -- <carpeta>

var _carpeta := "user://capturas"
var sala: Nivel
var felipe: Felipe


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
	await _segundos(1.0)
	sala.travesuras.dialogo.limpiar()
	# Entrar por una puerta (la de la sala al recibidor).
	felipe.global_position = sala.puertas["sala>recibidor"].global_position
	await _segundos(0.6)
	sala.travesuras.dialogo.limpiar()
	Input.action_press("interactuar")
	await _segundos(0.05)
	Input.action_release("interactuar")
	for i in 16:
		await _capturar("puerta-%02d" % i)
		await _segundos(0.05)
	# Sentarse (ocio), en el recibidor.
	await _segundos(1.0)
	felipe.global_position = Vector2(1700, Nivel1.SUELO)
	await _segundos(0.6)
	felipe._empezar_ocio("sentarse")
	for i in 24:
		await _capturar("sentarse-%02d" % i)
		await _segundos(0.08)
	# Derrape de los Zoomies.
	felipe.tiene_zoomies = true
	felipe.global_position = Vector2(1600, Nivel1.SUELO)
	felipe.mirando = 1.0
	await _segundos(0.6)
	Input.action_press("zoomies")
	await _segundos(0.05)
	Input.action_release("zoomies")
	for i in 20:
		await _capturar("derrape-%02d" % i)
		await _segundos(0.03)
	quit()


func _segundos(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	var imagen := root.get_texture().get_image()
	imagen.save_png(_carpeta.path_join(nombre + ".png"))
	# Felipe en grande (×3) para el GIF.
	var camara := root.get_viewport().get_camera_2d()
	if camara:
		var en_pantalla := root.get_viewport().get_canvas_transform() * felipe.global_position
		var r := Rect2i(Vector2i(en_pantalla) - Vector2i(60, 90), Vector2i(120, 110)).intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
		var cerca := imagen.get_region(r)
		cerca.resize(cerca.get_width() * 3, cerca.get_height() * 3, Image.INTERPOLATE_NEAREST)
		cerca.save_png(_carpeta.path_join(nombre + "-cerca.png"))
