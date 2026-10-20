extends SceneTree
## Capturas de los sistemas del nivel a 640×360 (Indicador, diálogo con retratos, libreta, carteles, maullido y
## resumen del día), para revisar que se lean bien. Necesita pantalla; en la nube, con xvfb-run:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_sistemas.gd -- <carpeta>

var _carpeta := "user://capturas"
var sala: Nivel
## Lo propio del nivel 1 (Valeria, A.S.P.I., la pelea, las cajas...).
var guion: GuionNivel1
var felipe: Felipe


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	sala.mostrar_titulo = false
	guion.peligros_activos = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	var t := sala.travesuras
	await _esperar(40)
	# 1. Junto al sofá: contorno, burbuja "Firmar" y la primera línea de Felipe con el ícono del botón.
	await _poner_en(Vector2(300, Nivel1.SUELO))
	await _esperar(40)
	await _capturar("1-indicador-sofa-y-dialogo")
	# 2. En la mesa, junto al vaso: contorno con la forma del dibujo y "Liberar".
	t.dialogo.limpiar()
	var vaso: Objeto = sala.get_node("Vaso")
	await _poner_en(vaso.global_position + Vector2(-30, 0))
	felipe.mirando = 1.0
	await _esperar(10)
	await _capturar("2-indicador-vaso")
	# 3. Valeria habla (retrato de la hoja de Gemini) y sale un cartel de travesura cumplida.
	t.cumplir("perdon")
	t.decir_valeria("perdona", true)
	await _esperar(50)
	await _capturar("3-cartel-y-valeria")
	# 4. Maullido: cuadro de boca abierta y ¡MIAU!
	t.dialogo.limpiar()
	await _poner_en(Vector2(120, Nivel1.SUELO))
	await _esperar(150)
	Input.action_press("maullar")
	await _esperar(2)
	Input.action_release("maullar")
	await _esperar(26)
	await _capturar("4-maullar")
	# 5. Libreta con dos cumplidas (una secreta revelada).
	await _esperar(60)
	t.cumplir("laser")
	await _esperar(5)
	t.libreta.abrir()
	await _cuadros(10)
	await _capturar("5-libreta")
	t.libreta.cerrar()
	await _esperar(10)
	# 6. Resumen del día.
	var resumen := t.mostrar_resumen()
	for i in 260:
		await process_frame
	await _capturar("6-resumen")
	resumen.cerrar()
	quit()


func _poner_en(posicion: Vector2) -> void:
	felipe.global_position = posicion
	felipe.velocity = Vector2.ZERO
	await _esperar(20)


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _cuadros(cuadros: int) -> void:
	for i in cuadros:
		await process_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
