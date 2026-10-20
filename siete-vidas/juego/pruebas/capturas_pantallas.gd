extends SceneTree
## Capturas de las pantallas y de la presentación del jefe (título, intro, pausa, entrada de A.S.P.I. paso a paso y
## la pelea con su barra), para revisar la letra, el zoom de cámara y que nada se corte. Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_pantallas.gd -- <carpeta>

var _carpeta := "user://capturas"
var sala: Nivel


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _segundos(1.0)
	await _capturar("p1-titulo")
	sala.pantallas.modo = Pantallas.Modo.INTRO
	await _segundos(0.5)
	await _capturar("p2-intro")
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	sala.pantallas.empezar.emit()
	await _segundos(1.5)
	await _capturar("p3-juego-hud")
	sala.pantallas.modo = Pantallas.Modo.PAUSA
	await _segundos(1.5)
	await _capturar("p4-pausa")
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	await _segundos(0.5)
	# Entrada del jefe: por la puerta del estudio, cuadro a cuadro cada 0,4 s.
	felipe.vida.restante_invulnerable = 999.0
	sala.travesuras.dialogo.limpiar()
	felipe.global_position = sala.puertas["pasillo>estudio"].global_position
	await _segundos(0.3)
	Input.action_press("interactuar")
	await _segundos(0.05)
	Input.action_release("interactuar")
	for i in 22:
		await _segundos(0.4)
		await _capturar("j%02d-entrada" % i)
	await _segundos(1.0)
	await _capturar("j99-pelea")
	quit()


func _segundos(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_carpeta.path_join(nombre + ".png"))
