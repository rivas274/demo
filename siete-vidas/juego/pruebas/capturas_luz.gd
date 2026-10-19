extends SceneTree
## Capturas de la sala con y sin la prueba de luz (LuzCuarto), dos vistas: sofá con Valeria y comedor.
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_luz.gd -- <carpeta> [sin_luz]

var _carpeta := "user://capturas_luz"
var _con_luz := true

const PUNTOS := [["sofa", Vector2(300, Sala.SUELO)], ["comedor", Vector2(1000, Sala.SUELO)]]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	if args.size() > 1 and args[1] == "sin_luz":
		_con_luz = false
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.batalla_con_jefe = false
	if "luz_activa" in sala:
		sala.set("luz_activa", _con_luz)
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _esperar(30)
	for punto: Array in PUNTOS:
		sala.travesuras.dialogo.limpiar()
		felipe.global_position = punto[1]
		felipe.velocity = Vector2.ZERO
		await _esperar(50)
		sala.travesuras.dialogo.limpiar()
		await _esperar(2)
		await process_frame
		await process_frame
		var imagen := root.get_texture().get_image()
		imagen.save_png("%s/%s-%s.png" % [_carpeta, punto[0], "luz" if _con_luz else "antes"])
	quit()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame
