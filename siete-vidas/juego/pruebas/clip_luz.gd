extends SceneTree
## Clip de la prueba de luz: Felipe camina por la sala al atardecer, pasa por el rayo de la ventana y la lámpara.
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --write-movie <carpeta>/c.png --fixed-fps 30 --script res://pruebas/clip_luz.gd

## [acción, segundos].
const GUION := [["", 1.0], ["mover_izquierda", 1.6], ["", 0.8], ["mover_derecha", 4.5], ["", 0.6], ["mover_izquierda", 2.6], ["", 0.9]]


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	var guion: GuionNivel1 = sala.guion
	sala.mostrar_titulo = false
	guion.batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	felipe.global_position = Vector2(560, Nivel1.SUELO)
	for paso: Array in GUION:
		if paso[0] != "":
			Input.action_press(paso[0])
		for i in int(paso[1] * 30.0):
			await process_frame
		if paso[0] != "":
			Input.action_release(paso[0])
	quit()
