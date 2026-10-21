extends SceneTree
## Cuadros de A.S.P.I. de lado (2026-10-21) para un GIF: andando (rueda, cepillo, rebote, LED), enojada persiguiendo y
## apagada con las espirales. Necesita pantalla:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_aspi.gd -- <carpeta>

var _carpeta := "user://aspi"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	(sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _cuadros(30, "")
	var aspi: Enemigo = (sala.guion as GuionNivel1).aspi
	# El cuarto completo en dos vistas (la cámara lo recorre) y A.S.P.I. en su base.
	felipe.global_position = Vector2(6960, Nivel1.SUELO)
	await _cuadros(60, "")
	await _cuadros(2, "e-cuarto-izquierda")
	felipe.global_position = Vector2(7600, Nivel1.SUELO)
	await _cuadros(60, "")
	await _cuadros(2, "e-cuarto-derecha")
	aspi.global_position = Nivel1.ASPI[0]
	aspi.patrulla.vision = 0.0
	aspi.patrulla.quieta = true
	felipe.global_position = Vector2(7000, Nivel1.SUELO)
	await _cuadros(40, "")
	await _cuadros(2, "d-en-la-base")
	aspi.patrulla.quieta = false
	felipe.global_position = Vector2(7380, Nivel1.SUELO)
	felipe.vida.restante_invulnerable = 999.0
	aspi.global_position = Vector2(7450, Nivel1.SUELO)
	aspi.patrulla.vision = 0.0
	await _cuadros(40, "")
	await _cuadros(36, "a-anda")
	aspi.patrulla.vision = 400.0
	felipe.global_position = Vector2(7620, Nivel1.SUELO)
	await _cuadros(36, "b-enojada")
	aspi.vida.morir()
	await _cuadros(60, "")
	await _cuadros(24, "c-apagada")
	quit()


func _cuadros(n: int, prefijo: String) -> void:
	for i in n:
		await physics_frame
		if prefijo != "" and i % 2 == 0:
			await process_frame
			root.get_texture().get_image().save_png("%s/%s-%03d.png" % [_carpeta, prefijo, i])
