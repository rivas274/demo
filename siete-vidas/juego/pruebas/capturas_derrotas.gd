extends SceneTree
## Cuadros de las derrotas jugosas (ratón de cuerda de la cocina y golpe final de A.S.P.I.) para armar los GIF y
## revisarlas contra memoria/06-lecciones-arte.md. Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --fixed-fps 60 --script res://pruebas/capturas_derrotas.gd -- <carpeta>

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
	await _segundos(1.5)
	# El ratón de la cocina (piso): Felipe a su izquierda, mirándolo, y un zarpazo.
	var raton: Enemigo = null
	for hijo in get_nodes_in_group(Componentes.ENEMIGOS):
		if hijo is Enemigo and hijo.datos.nombre == "Raton" and hijo.global_position.y > Nivel1.SUELO - 5.0:
			raton = hijo
	raton.patrulla.quieta = true
	raton.global_position = Vector2(3250, Nivel1.SUELO)
	felipe.global_position = Vector2(3214, Nivel1.SUELO)
	felipe.mirando = 1.0
	await _segundos(0.8)
	sala.travesuras.dialogo.limpiar()
	Input.action_press("zarpazo")
	await _segundos(0.05)
	Input.action_release("zarpazo")
	for i in 40:
		await _capturar("raton-%02d" % i)
		await _segundos(0.05)
	await _segundos(2.5)
	await _capturar("raton-marca")
	# A.S.P.I.: se entra al estudio, pasa la presentación y se le da el golpe final.
	felipe.vida.restante_invulnerable = 999.0
	felipe.global_position = sala.puertas["pasillo>estudio"].global_position
	await _segundos(0.3)
	Input.action_press("interactuar")
	await _segundos(0.05)
	Input.action_release("interactuar")
	await _segundos(12.0)
	var batalla = sala.guion.batalla
	var jefe: Enemigo = batalla.jefe
	felipe.vida.restante_invulnerable = 0.0
	felipe.global_position = jefe.global_position + Vector2(-50, 0)
	felipe.mirando = 1.0
	await _segundos(0.2)
	jefe.vida.morir()
	for i in 40:
		await _capturar("aspi-%02d" % i)
		await _segundos(0.05)
	await _segundos(1.5)
	await _capturar("aspi-marca")
	quit()


func _segundos(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func _capturar(nombre: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_carpeta.path_join(nombre + ".png"))
