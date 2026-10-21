extends SceneTree
## Capturas de cada cuarto del nivel 1 (dos por cuarto) para revisar el arte contra las colisiones, que nada flote ni
## tape una puerta y que los textos se lean. Necesita pantalla; en la nube, con xvfb-run. Con --debug-collisions se
## ven las colisiones encima del arte:
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 [--debug-collisions] --script res://pruebas/capturas_nivel.gd -- <carpeta>

var _carpeta := "user://capturas"

## [nombre, posición de Felipe (al pie)].
const PUNTOS := [
	["1-sala-sofa", Vector2(300, Nivel1.SUELO)],
	["2-sala-comedor", Vector2(1000, Nivel1.SUELO)],
	["3-recibidor-entrada", Vector2(1700, Nivel1.SUELO)],
	["4-recibidor-escalera", Vector2(2200, Nivel1.SUELO)],
	["4b-escalera-adentro", Vector2(2390, Nivel1.SUELO)],
	["5-cocina-entrada", Vector2(3050, Nivel1.SUELO)],
	["6-cocina-estufa", Vector2(3433, Nivel1.SUELO - 55)],
	["6b-cocina-fregadero", Vector2(3640, Nivel1.SUELO - 109)],
	["6c-cocina-refrigerador", Vector2(3900, Nivel1.SUELO - 109)],
	["7-pasillo-consola", Vector2(4530, Nivel1.SUELO)],
	["8-pasillo-estudio", Vector2(5300, Nivel1.SUELO)],
	["9-dormitorio-cama", Vector2(5910, Nivel1.SUELO)],
	["10-dormitorio-ropero", Vector2(6360, Nivel1.SUELO)],
	["11-estudio", Vector2(6980, Nivel1.SUELO)],
	["12-balcon", Vector2(8126, Nivel1.SUELO)],
	["13-pasillo-bano", Vector2(Nivel1.BANO.x, Nivel1.SUELO)],
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_carpeta = args[0]
	DirAccess.make_dir_recursive_absolute(_carpeta)
	_correr.call_deferred()


func _correr() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	var guion: GuionNivel1 = sala.guion
	sala.mostrar_titulo = false
	guion.batalla_con_jefe = false
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
	# La escalera después del atajo: la caja de arriba tirada desde el peldaño, abierta en el piso.
	sala.travesuras.dialogo.limpiar()
	felipe.global_position = Nivel1.PELDANO_CAJAS
	await _esperar(20)
	felipe.mirando = -1.0
	# Valeria en su reunión (audífonos puestos): igual oye el ¡PUM! (segunda pasada, pilar 5).
	guion.valeria.audifonos = true
	guion.cajas.interactuar(felipe)
	await _esperar(12)
	await _capturar("4c-escalera-caja-cayendo")
	await _esperar_que(func() -> bool: return guion.cajas.rect_borde_caja() != Rect2(), 120)
	await _esperar(8)
	await _capturar("4e-escalera-caja-pum")
	await _esperar(40)
	await _capturar("4f-escalera-valeria-reacciona")
	await _esperar(80)
	sala.travesuras.dialogo.limpiar()
	felipe.global_position = Vector2(2400, Nivel1.SUELO)
	await _esperar(40)
	sala.travesuras.dialogo.limpiar()
	await _esperar(2)
	await _capturar("4d-escalera-caja-tirada")
	# Valeria con un audífono afuera (en la sala, para verla de cerca).
	sala.travesuras.dialogo.limpiar()
	felipe.global_position = Vector2(guion.valeria.global_position.x - 90.0, Nivel1.SUELO)
	guion.valeria.audifonos = true
	guion.valeria.sacar_audifono(5.0)
	await _esperar(40)
	sala.travesuras.dialogo.limpiar()
	await _esperar(2)
	await _capturar("4g-valeria-audifono-afuera")
	quit()


func _esperar_que(condicion: Callable, maximo: int) -> void:
	for i in maximo:
		if condicion.call():
			return
		await physics_frame


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
