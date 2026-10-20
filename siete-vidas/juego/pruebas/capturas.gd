extends SceneTree
## Toma capturas del juego en momentos clave (necesita pantalla; en la nube usar xvfb-run):
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas.gd -- <carpeta>

var _carpeta := "user://capturas"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Node = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	await _esperar(30)
	await _capturar("1-quieto")
	Input.action_press("mover_derecha")
	await _esperar(25)
	await _capturar("2-caminando")
	Input.action_press("saltar")
	await _esperar(14)
	await _capturar("3-saltando")
	Input.action_release("saltar")
	await _esperar(3)
	Input.action_press("saltar")
	await _esperar(10)
	Input.action_release("saltar")
	await _capturar("4-doble-salto")
	await _esperar(16)
	await _capturar("5-cayendo")
	Input.action_release("mover_derecha")
	await _esperar(60)
	Input.action_press("zarpazo")
	await _esperar(5)
	Input.action_release("zarpazo")
	await _capturar("6-zarpazo")
	quit()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
