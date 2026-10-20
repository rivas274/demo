extends SceneTree
## Tira de cuadros de los Zoomies con su receta de jugo (anticipación, líneas, cámara adelantada, derrape con polvo,
## pelos y marca) en la casa del nivel 1, prendiendo los Zoomies solo para la captura (en el nivel 1 están apagados).
## Necesita pantalla; en la nube, con xvfb-run:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_zoomies.gd -- <carpeta> [x]

var _carpeta := "user://capturas"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var args := OS.get_cmdline_user_args()
	var x := float(args[1]) if args.size() > 1 else 560.0
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	(sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _esperar(30)
	felipe.tiene_zoomies = true
	felipe.global_position = Vector2(x, Nivel1.SUELO)
	felipe.velocity = Vector2.ZERO
	felipe.mirando = 1.0
	await _esperar(60)
	sala.travesuras.dialogo.limpiar()
	Input.action_press("zoomies")
	for i in 16:
		await _esperar(3)
		if i == 0:
			Input.action_release("zoomies")
		await RenderingServer.frame_post_draw
		var imagen := root.get_texture().get_image()
		imagen.save_png(_carpeta.path_join("zoomies_%02d.png" % i))
		# Recorte ×3 alrededor de Felipe (para ver el polvo, las líneas y la marca).
		var en_pantalla := (root.get_canvas_transform() * felipe.global_position).round()
		var caja := Rect2i(Vector2i(en_pantalla) - Vector2i(80, 70), Vector2i(160, 80))
		caja = caja.intersection(Rect2i(Vector2i.ZERO, imagen.get_size()))
		var cerca := imagen.get_region(caja)
		cerca.resize(cerca.get_width() * 3, cerca.get_height() * 3, Image.INTERPOLATE_NEAREST)
		cerca.save_png(_carpeta.path_join("zoomies_cerca_%02d.png" % i))
	quit()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
