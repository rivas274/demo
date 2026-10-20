extends SceneTree
## Capturas del plan de estabilización (2026-10-20) para revisarlas ampliadas: cada lugar donde Felipe y Valeria
## coinciden (decisión 1: Valeria delante y la silueta de Felipe donde ella lo tapa) y Felipe sentado en la baranda
## del balcón (decisión 2: al lado de la maceta, no encima).
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_estabilizacion.gd -- <carpeta>

var _carpeta := "user://cruces"

## [nombre, lugar de Valeria, cuarto, actividad, hacia, lugar de Felipe, frotarse].
var _puntos: Array = [
	["1-sala-sofa-piso", Nivel1.VALERIA_SOFA, "sala", Valeria.Actividad.SENTADA, 1.0, Vector2(420, Nivel1.SUELO), false],
	["2-sala-sofa-cojin", Nivel1.VALERIA_SOFA, "sala", Valeria.Actividad.SENTADA, 1.0, Vector2(400, Nivel1.SUELO - 49), false],
	["3-sala-comedor", Vector2(1000, Nivel1.SUELO), "sala", Valeria.Actividad.DE_PIE, -1.0, Vector2(1000, Nivel1.SUELO), false],
	["4-recibidor-puerta", Vector2(1700, Nivel1.SUELO), "recibidor", Valeria.Actividad.DE_PIE, 1.0, Vector2(1712, Nivel1.SUELO), false],
	["5-cocina-estufa-piso", Nivel1.VALERIA_COCINA, "cocina", Valeria.Actividad.DE_PIE, -1.0, Vector2(3505, Nivel1.SUELO), false],
	["6-cocina-estufa-arriba", Nivel1.VALERIA_COCINA, "cocina", Valeria.Actividad.DE_PIE, -1.0, Vector2(3500, Nivel1.SUELO - 109), false],
	["7-cocina-meson", Vector2(3600, Nivel1.SUELO), "cocina", Valeria.Actividad.DE_PIE, 1.0, Vector2(3610, Nivel1.SUELO - 109), false],
	["8-frotarse", Vector2(1000, Nivel1.SUELO), "sala", Valeria.Actividad.DE_PIE, -1.0, Vector2(1010, Nivel1.SUELO), true],
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
	var valeria: Valeria = guion.valeria
	await _esperar(30)
	for punto: Array in _puntos:
		sala.travesuras.dialogo.limpiar()
		valeria.poner(punto[1], punto[2], punto[4], punto[3])
		felipe.global_position = punto[5]
		felipe.velocity = Vector2.ZERO
		await _esperar(50)
		if punto[6]:
			felipe.frotarse(valeria)
			await _esperar(20)
		sala.travesuras.dialogo.limpiar()
		await _esperar(2)
		await _capturar(punto[0])
	# Balcón: sube a la baranda donde la sube el bot y se sienta.
	valeria.poner(Nivel1.VALERIA_SOFA, "sala", 1.0, Valeria.Actividad.SENTADA)
	sala.travesuras.dialogo.limpiar()
	felipe.global_position = Vector2(7890, Nivel1.SUELO)
	await _esperar(30)
	felipe.global_position = Vector2(8095, Nivel1.SUELO - 90)
	felipe.velocity = Vector2.ZERO
	await _esperar(150)
	sala.travesuras.dialogo.limpiar()
	await _esperar(2)
	await _capturar("9-balcon-sentado")
	quit()


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await physics_frame


func _capturar(nombre: String) -> void:
	await process_frame
	await process_frame
	var imagen := root.get_texture().get_image()
	imagen.save_png("%s/%s.png" % [_carpeta, nombre])
