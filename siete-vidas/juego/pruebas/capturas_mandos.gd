extends SceneTree
## Íconos de los botones con cada tipo de mando (teclado, Xbox, PlayStation y Switch) en el diálogo y la libreta.
## Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_mandos.gd -- <carpeta>

var _carpeta := "user://capturas"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	await create_timer(1.5).timeout
	var detector := DetectorMando.de(self)
	for tipo: StringName in [DetectorMando.TECLADO, DetectorMando.XBOX, DetectorMando.PLAYSTATION, DetectorMando.SWITCH]:
		detector.cambiar(tipo, 0)
		sala.travesuras.dialogo.limpiar()
		sala.travesuras.dialogo.decir("felipe", "%s: {saltar} saltar · {zarpazo} zarpazo · {interactuar} acción · {maullar} maullar · {zoomies} zoomies" % tipo, 0, true)
		await create_timer(2.5).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(_carpeta.path_join("mando-%s.png" % tipo))
	quit()
