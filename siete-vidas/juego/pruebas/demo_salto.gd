extends SceneTree
## Tramo corto de la sala con una entrada fija (los mismos botones en los mismos cuadros) para comparar cómo se
## siente el salto: saltitos en el piso, al sofá y al respaldo, al rascador, una caída desde lo alto del rascador
## (1,36 m), la silla, la mesa y la bajada. Sirve para grabar el video antes/después de un ajuste del salto:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --write-movie <carpeta>/c.png --fixed-fps 30 --script res://pruebas/demo_salto.gd
## Con "-- --detalle" escribe dónde aterriza en cada salto (para revisar el guion sin ventana):
##   godot --headless --path siete-vidas/juego --fixed-fps 60 --script res://pruebas/demo_salto.gd -- --detalle

## El guion: [segundo, acción, apretar (true) o soltar (false)]. Se cuenta en cuadros de física, así sale igual a
## 30 o 60 cuadros por segundo.
const GUION := [
	# Dos saltitos en el piso: uno corto y uno largo.
	[0.8, "saltar", true], [0.9, "saltar", false],
	[1.6, "saltar", true], [1.95, "saltar", false],
	# Al asiento del sofá y, desde ahí, al respaldo.
	[2.4, "mover_derecha", true],
	[3.1, "saltar", true], [3.33, "saltar", false],
	[3.7, "mover_derecha", false],
	[4.3, "saltar", true], [4.55, "saltar", false],
	# Corriendo del respaldo al rascador.
	[5.4, "zoomies", true], [5.4, "mover_derecha", true],
	[6.05, "saltar", true], [6.3, "saltar", false],
	[6.6, "mover_derecha", false], [6.6, "zoomies", false],
	[7.1, "mover_derecha", true], [7.35, "mover_derecha", false],
	[7.6, "saltar", true], [7.85, "saltar", false],
	# Desde lo alto del rascador (1,36 m), un salto al piso: la caída más alta del tramo (unos 2 m).
	[9.0, "mover_derecha", true],
	[9.05, "saltar", true], [9.3, "saltar", false],
	[10.2, "mover_derecha", false],
	# A la silla y a la mesa.
	[10.8, "mover_derecha", true],
	[10.82, "saltar", true], [11.05, "saltar", false],
	[11.12, "mover_derecha", false],
	[11.9, "mover_derecha", true],
	[11.95, "saltar", true], [12.18, "saltar", false],
	[13.2, "mover_derecha", false],
	# Un saltito sobre la mesa y, corriendo, abajo por encima de la otra silla.
	[13.7, "saltar", true], [13.85, "saltar", false],
	[14.6, "zoomies", true], [14.6, "mover_derecha", true],
	[14.75, "saltar", true], [14.98, "saltar", false],
	[15.8, "mover_derecha", false], [15.8, "zoomies", false],
]
const DURACION := 17.0

var sala: Nivel
var felipe: Felipe


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var fps := float(Engine.physics_ticks_per_second)
	var detalle := OS.get_cmdline_user_args().has("--detalle")
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	felipe.position = Vector2(150, Nivel1.SUELO)
	var siguiente := 0
	var en_suelo := true
	var y_mas_alto := felipe.position.y
	for cuadro in int(DURACION * fps):
		var segundo := cuadro / fps
		while siguiente < GUION.size() and GUION[siguiente][0] <= segundo + 0.0001:
			var paso: Array = GUION[siguiente]
			if paso[2]:
				Input.action_press(paso[1])
			else:
				Input.action_release(paso[1])
			siguiente += 1
		await physics_frame
		if detalle:
			y_mas_alto = minf(y_mas_alto, felipe.position.y)
			if felipe.is_on_floor() and not en_suelo:
				print("%5.2f s  aterriza en (%.0f, %.0f) desde %.0f px más arriba (velocidad %.0f)" % [
					segundo, felipe.position.x, Nivel1.SUELO - felipe.position.y, felipe.position.y - y_mas_alto, felipe._velocidad_al_caer])
				y_mas_alto = felipe.position.y
			elif felipe.is_on_floor():
				y_mas_alto = felipe.position.y
			en_suelo = felipe.is_on_floor()
	quit(0)
