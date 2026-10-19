extends SceneTree
## Capturas de cada cuarto del nivel 1 (dos por cuarto) para revisar el arte contra las colisiones, que nada flote ni
## tape una puerta y que los textos se lean. Necesita pantalla; en la nube, con xvfb-run. Con --debug-collisions se
## ven las colisiones encima del arte:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 [--debug-collisions] --script res://pruebas/capturas_nivel.gd -- <carpeta>

var _carpeta := "user://capturas"

## [nombre, posición de Felipe (al pie)].
const PUNTOS := [
	["1-sala-sofa", Vector2(300, Sala.SUELO)],
	["2-sala-comedor", Vector2(1000, Sala.SUELO)],
	["3-recibidor-entrada", Vector2(1700, Sala.SUELO)],
	["4-recibidor-escalera", Vector2(2318, Sala.SUELO)],
	["5-cocina-entrada", Vector2(3050, Sala.SUELO)],
	["6-cocina-meson", Vector2(3433, Sala.SUELO - 55)],
	["7-pasillo-consola", Vector2(4150, Sala.SUELO)],
	["8-pasillo-estudio", Vector2(4920, Sala.SUELO)],
	["9-dormitorio-cama", Vector2(5530, Sala.SUELO)],
	["10-dormitorio-ropero", Vector2(5980, Sala.SUELO)],
	["11-estudio", Vector2(6600, Sala.SUELO)],
	["12-balcon", Vector2(7450, Sala.SUELO)],
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Sala = load("res://escenas/apartamento.tscn").instantiate()
	sala.mostrar_titulo = false
	sala.batalla_con_jefe = false
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
		await _capturar(punto[0])
	quit()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
