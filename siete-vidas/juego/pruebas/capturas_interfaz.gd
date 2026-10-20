extends SceneTree
## Capturas de toda la interfaz con el kit «Decreto real» (para comparar antes y después): HUD con diálogo, cartel de
## travesura, aviso de logro, libreta, pausa (ficha de Su Majestad), opciones, resumen del día y el sello al elegir.
## Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_interfaz.gd -- <carpeta>

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
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	sala.pantallas.empezar.emit()
	await _segundos(1.0)
	felipe.vida.restante_invulnerable = 999.0
	var t := sala.travesuras
	t.dialogo.limpiar()
	t.dialogo.decir("valeria", "VALERIA_CAJAS_AUDIFONOS_1", 0, true)
	await _segundos(2.5)
	await _capturar("i1-hud-dialogo")
	t.dialogo.limpiar()
	t.hud.cartel(tr("UI_TRAVESURA_CUMPLIDA"), "AGENDA_ROBAR_EL_ALMUERZO_DE", "RECOMPENSA_SNACK_GUARDADO", false, t.altura_cartel())
	await _segundos(0.8)
	await _capturar("i2-cartel")
	await _segundos(3.0)
	sala.desbloquear_logro("LOGRO_ATAJO_DE_GATO")
	await _segundos(0.6)
	await _capturar("i3-logro")
	await _segundos(3.0)
	t.libreta.abrir()
	await _segundos(0.6)
	await _capturar("i4-libreta")
	t.libreta.cerrar()
	await _segundos(0.3)
	felipe.peso = 9.8
	sala.pantallas.modo = Pantallas.Modo.PAUSA
	await _segundos(1.5)
	await _capturar("i5-pausa")
	# El sello al elegir «Opciones», cuadro a cuadro (para el GIF).
	var menu := sala.pantallas.menu_pausa
	menu.enfocar(&"Opciones")
	await _segundos(0.3)
	(menu.get_node("Opciones") as Button).pressed.emit()
	for i in 14:
		await _segundos(0.05)
		await _capturar("s%02d-sello" % i)
	await _segundos(0.6)
	await _capturar("i6-opciones")
	sala.pantallas.opciones.cerrar()
	await _segundos(0.3)
	sala.pantallas.modo = Pantallas.Modo.JUGANDO
	await _segundos(0.3)
	t.mostrar_resumen()
	await _segundos(4.0)
	await _capturar("i7-resumen")
	quit()


func _segundos(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_carpeta.path_join(nombre + ".png"))
