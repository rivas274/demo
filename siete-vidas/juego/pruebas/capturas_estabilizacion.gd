extends SceneTree
## Capturas del plan de estabilización (2026-10-20) para revisarlas ampliadas: cada lugar donde Felipe y Valeria
## coinciden (decisión 1: Valeria delante y la silueta de Felipe donde ella lo tapa) y Felipe sentado en la baranda
## del balcón (decisión 2: al lado de la maceta, no encima).
## Con «textos» después de la carpeta, en cambio, cada texto en su zona (decisión 3): HUD y diálogo, cartel, logro,
## palabras sobre Felipe, la pegatina del plástico y la de la censura.
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_estabilizacion.gd -- <carpeta> [textos]

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
	if args.size() > 1 and args[1] == "textos":
		_textos.call_deferred()
	elif args.size() > 1 and args[1] == "luces":
		_luces.call_deferred()
	elif args.size() > 1 and args[1] == "rotos":
		_rotos.call_deferred()
	else:
		_correr.call_deferred()


## Las lámparas encendidas (decisión 4): la de la mesita de la sala y la de pie del recibidor.
func _luces() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	(sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _esperar(30)
	for punto: Array in [["l1-sala-lampara", Vector2(330, Nivel1.SUELO)], ["l2-recibidor-lampara", Vector2(1880, Nivel1.SUELO)]]:
		sala.travesuras.dialogo.limpiar()
		felipe.global_position = punto[1]
		felipe.velocity = Vector2.ZERO
		await _esperar(60)
		sala.travesuras.dialogo.limpiar()
		await _esperar(2)
		await _capturar(punto[0])
	quit()


## Lo que queda roto en el piso: el vaso, la taza y una maceta, antes y después de tirarlos.
func _rotos() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	sala.mostrar_titulo = false
	(sala.guion as GuionNivel1).batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	await _esperar(30)
	var vistos := {}
	for nodo in sala.find_children("*", "Objeto", true, false):
		var objeto := nodo as Objeto
		if objeto.tipo in ["vaso", "taza", "maceta"] and not vistos.has(objeto.tipo):
			vistos[objeto.tipo] = true
			sala.travesuras.dialogo.limpiar()
			felipe.global_position = Vector2(objeto.global_position.x - 30.0, objeto.tirable.piso)
			felipe.velocity = Vector2.ZERO
			await _esperar(50)
			sala.travesuras.dialogo.limpiar()
			await _capturar("r-%s-antes" % objeto.tipo)
			felipe.mirando = 1.0
			objeto.tirable.empujar(felipe)
			await _esperar(12)
			await _capturar("r-%s-cayendo" % objeto.tipo)
			await _esperar(90)
			sala.travesuras.dialogo.limpiar()
			sala.travesuras.anuncios.limpiar()
			await _esperar(2)
			await _capturar("r-%s-despues" % objeto.tipo)
	quit()


func _textos() -> void:
	var sala: Nivel = load("res://escenas/nivel_1.tscn").instantiate()
	var guion: GuionNivel1 = sala.guion
	sala.mostrar_titulo = false
	guion.batalla_con_jefe = false
	root.add_child(sala)
	var felipe: Felipe = sala.get_node("Felipe")
	var t := sala.travesuras
	await _esperar(30)
	felipe.global_position = Vector2(560, Nivel1.SUELO)
	await _esperar(40)
	t.dialogo.decir("felipe", "FELIPE_BALCON_1", 0, true)
	await _esperar(90)
	await _capturar("t1-hud-dialogo")
	t.dialogo.limpiar()
	t.hud.cartel("UI_TRAVESURA_CUMPLIDA", "AGENDA_ROBAR_EL_ALMUERZO_DE", false)
	await _esperar(60)
	await _capturar("t2-cartel")
	t.anuncios.limpiar()
	await _esperar(20)
	sala.desbloquear_logro("LOGRO_COLECCIONISTA_DE_CALCETINES")
	await _esperar(30)
	await _capturar("t3-logro")
	t.anuncios.limpiar()
	t.jugo.palabra_en_mundo("PALABRA_CRITICO", felipe.global_position + Vector2(30, -80), Color(1.0, 0.4, 0.3), 22)
	await _esperar(12)
	await _capturar("t4-palabra-critico")
	felipe.global_position = Vector2(Nivel1.SOFA_ARANABLE[0].x - 60.0, Nivel1.SUELO)
	await _esperar(40)
	t.jugo.palabra_en_mundo("PALABRA_PLASTICO_0", Nivel1.SOFA_ARANABLE[0] + Vector2(-80, -110), Color(1.0, 0.6, 0.4), 18, 0.0, true)
	await _esperar(14)
	await _capturar("t5-plastico")
	felipe.global_position = Vector2(Nivel1.DESCANSOS[0].get_center().x, Nivel1.SUELO)
	await _esperar(40)
	guion.call("_censura_ironica")
	await _esperar(10)
	await _capturar("t6-censura")
	quit()


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
