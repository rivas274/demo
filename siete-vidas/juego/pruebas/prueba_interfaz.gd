extends SceneTree
## Prueba de las piezas de la interfaz por separado: BarraVida (escucha a Vida), ContadorRecurso, Cartel, MenuUI,
## la pila de pantallas (GestorPantallas y la pausa), Pantallas con su menú, los textos traducibles (tr), los controles
## (Controles: textos sacados del InputMap y remapeo) y el tema (Estilo: ningún nombre pedido falta). Sin ventana:
##   godot --headless --path siete-vidas/juego --script res://pruebas/prueba_interfaz.gd
## Termina con código 0 si todo pasa y 1 si algo falla.

var _fallos: Array[String] = []
var mundo: Node


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	mundo = Node.new()
	mundo.name = "Mundo de prueba"
	root.add_child(mundo)
	await _esperar(2)

	await _probar_barra_vida()
	_probar_contador_y_cartel()
	await _probar_gestor_pantallas()
	await _probar_menu_y_pausa()
	_probar_textos()
	_probar_controles()
	_probar_tema()

	for fallo in _fallos:
		print("FALLA: ", fallo)
	print("Resultado: %d fallos" % _fallos.size())
	quit(1 if _fallos.size() > 0 else 0)


func _probar_barra_vida() -> void:
	var vida := Vida.new(5)
	mundo.add_child(vida)
	var barra: BarraVida = (load("res://escenas/ui/barra_vida.tscn") as PackedScene).instantiate()
	mundo.add_child(barra)
	var vistos: Array[int] = []
	barra.mostrada.connect(func(actual: int, _maximo: int) -> void: vistos.append(actual))
	barra.conectar(vida)
	_comprobar(barra.actual == 5 and barra.maximo == 5 and is_equal_approx(barra.fraccion, 1.0), "BarraVida: al conectarse muestra lo que tiene la Vida (5 de 5)")
	vida.danar(2)
	_comprobar(barra.actual == 3 and vistos[-1] == 3, "BarraVida: reacciona a Vida.cambio (golpe de 2: 3 de 5)")
	vida.llenar()
	_comprobar(barra.actual == 5, "BarraVida: al llenarse la Vida, vuelve a 5")
	var otra := Vida.new(3)
	mundo.add_child(otra)
	barra.conectar(otra)
	vida.danar(1)
	_comprobar(barra.actual == 3 and barra.maximo == 3, "BarraVida: al conectarse a otra Vida deja de escuchar la anterior")
	barra.forma = BarraVida.Forma.BARRA
	barra.forzada = 0.25
	_comprobar(is_equal_approx(barra.fraccion, 0.25), "BarraVida: en la entrada del jefe muestra la fracción forzada")
	barra.queue_free()
	vida.queue_free()
	otra.queue_free()
	await _esperar(1)


func _probar_contador_y_cartel() -> void:
	var contador: ContadorRecurso = (load("res://escenas/ui/contador_recurso.tscn") as PackedScene).instantiate()
	contador.clave = "calcetin"
	mundo.add_child(contador)
	contador.fijar("3", true)
	_comprobar(contador.texto == "3" and contador.tiene and contador.golpe == 1.0, "ContadorRecurso: muestra el valor y salta al cambiar")
	contador.fijar("0", false, false)
	_comprobar(not contador.tiene and contador.golpe == 1.0, "ContadorRecurso: sin golpe al armar la interfaz")
	contador.queue_free()
	var cartel := Cartel.crear("TÍTULO", "nombre", "premio", false, Rect2(0, 100, 640, 96), false)
	var textos: Array[String] = []
	for hijo in cartel.get_children():
		if hijo is Label:
			textos.append((hijo as Label).text)
	_comprobar(textos == ["TÍTULO", "NOMBRE", "RECOMPENSA: PREMIO"], "Cartel: franja con título, nombre y recompensa")
	cartel.free()


func _probar_gestor_pantallas() -> void:
	var gestor := GestorPantallas.new()
	mundo.add_child(gestor)
	_comprobar(GestorPantallas.de(mundo) == gestor, "GestorPantallas: hay uno solo por árbol")
	var libreta := Control.new()
	var pausa := Control.new()
	mundo.add_child(libreta)
	mundo.add_child(pausa)
	gestor.abrir(libreta)
	_comprobar(paused and gestor.arriba() == libreta, "GestorPantallas: abrir una pantalla pausa el juego")
	gestor.abrir(pausa)
	_comprobar(gestor.es_la_de_arriba(pausa) and not gestor.es_la_de_arriba(libreta), "GestorPantallas: la última abierta queda arriba (solo ella responde)")
	gestor.cerrar(pausa)
	_comprobar(paused and gestor.arriba() == libreta, "GestorPantallas: cerrar la pausa con la libreta abierta no despausa")
	libreta.queue_free()
	await _esperar(1)
	_comprobar(not paused and gestor.arriba() == null, "GestorPantallas: una pantalla que se borra sale de la pila y el juego sigue")
	var sin_pausa := Control.new()
	mundo.add_child(sin_pausa)
	gestor.abrir(sin_pausa, false)
	_comprobar(not paused, "GestorPantallas: una pantalla que no pausa no detiene el juego")
	gestor.cerrar(sin_pausa)
	paused = true
	gestor.abrir(pausa)
	gestor.cerrar(pausa)
	paused = false
	pausa.queue_free()
	sin_pausa.queue_free()
	await _esperar(1)


func _probar_menu_y_pausa() -> void:
	var pantallas := Pantallas.new()
	mundo.add_child(pantallas)
	await _esperar(2)
	_comprobar(pantallas.menu_pausa != null and not pantallas.menu_pausa.visible, "Pantallas: el menú de pausa existe y no se ve jugando")
	pantallas.modo = Pantallas.Modo.PAUSA
	await _esperar(2)
	var menu := pantallas.menu_pausa
	_comprobar(paused and menu.visible, "Pausa: pausa el juego y muestra el menú")
	_comprobar(menu.enfocado() != null and menu.enfocado().name == &"Continuar", "MenuUI: al mostrarse, el foco va a la primera opción")
	var abajo := menu.enfocado().find_valid_focus_neighbor(SIDE_BOTTOM)
	var arriba := menu.get_node("Continuar").find_valid_focus_neighbor(SIDE_TOP) as Control
	_comprobar(abajo != null and abajo.name == &"Reiniciar" and arriba != null and arriba.name == &"Salir", "MenuUI: se recorre hacia abajo y da la vuelta hacia arriba")
	_comprobar((menu.get_node("Continuar") as Button).text == "MENU_CONTINUAR" and (menu.get_node("Continuar") as Button).auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED, "MenuUI: el texto del botón es una clave que se traduce sola")
	var elegidos: Array[StringName] = []
	menu.elegido.connect(func(opcion: StringName) -> void: elegidos.append(opcion))
	(menu.get_node("Continuar") as Button).pressed.emit()
	await _esperar(1)
	_comprobar(elegidos == [&"Continuar"] and pantallas.modo == Pantallas.Modo.JUGANDO and not paused and not menu.visible, "Pausa: «Continuar» vuelve al juego")
	pantallas.queue_free()
	await _esperar(1)


func _probar_textos() -> void:
	_comprobar(TranslationServer.translate("UI_TRAVESURA_CUMPLIDA") == "¡TRAVESURA CUMPLIDA!", "tr: la clave UI_TRAVESURA_CUMPLIDA da el texto en español")
	_comprobar(TranslationServer.translate("PAUSA_TITULO") == "Pausa" and TranslationServer.translate("UI_VIDAS") % 9 == "9 vidas", "tr: títulos y textos con números")
	_comprobar(TranslationServer.translate("CLAVE_QUE_NO_EXISTE") == "CLAVE_QUE_NO_EXISTE", "tr: una clave sin traducción se ve tal cual (fácil de notar)")
	# Toda clave del archivo tiene su texto en español.
	var archivo := FileAccess.open("res://traducciones/textos.csv", FileAccess.READ)
	var vacias: Array[String] = []
	archivo.get_csv_line()
	while not archivo.eof_reached():
		var fila := archivo.get_csv_line()
		if fila.size() >= 2 and fila[0] != "" and fila[1] == "":
			vacias.append(fila[0])
	_comprobar(vacias.is_empty(), "tr: todas las claves tienen texto en español %s" % [vacias])


func _probar_controles() -> void:
	_comprobar(Controles.texto("saltar", false) == "Espacio" and Controles.texto("saltar", true) == "A", "Controles: Saltar es Espacio / A (leído del InputMap)")
	_comprobar(Controles.texto("maullar", false) == "Q" and Controles.texto("maullar", true) == "B" and Controles.texto("mover_izquierda", true) == "←", "Controles: Maullar Q / B, izquierda ← en el mando")
	_comprobar(Controles.etiquetar("{agacharse} para pasar") == "[S] para pasar" or Controles.usa_mando, "Controles: los avisos cambian {acción} por la tecla")
	var antes := InputMap.action_get_events("zarpazo").duplicate()
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_K
	Controles.remapear("zarpazo", tecla)
	_comprobar(Controles.texto("zarpazo", false) == "K" and Controles.texto("zarpazo", true) == "X", "Controles: remapear cambia la tecla y deja el botón del mando")
	_comprobar(IconosBotones.texto("zarpazo", false) == "K" and IconosBotones.textura("zarpazo", false) == null, "Controles: los íconos siguen al remapeo (K no tiene ícono: se dibuja la tecla)")
	var ruta := "user://controles_prueba.cfg"
	Controles.guardar(ruta)
	InputMap.action_erase_events("zarpazo")
	for e: InputEvent in antes:
		InputMap.action_add_event("zarpazo", e)
	_comprobar(Controles.texto("zarpazo", false) == "J", "Controles: vuelve a J")
	Controles.cargar(ruta)
	_comprobar(Controles.texto("zarpazo", false) == "K", "Controles: guardar y cargar recuerda el remapeo")
	InputMap.action_erase_events("zarpazo")
	for e: InputEvent in antes:
		InputMap.action_add_event("zarpazo", e)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ruta))


## Todo color, letra y medida que pide un script de la interfaz existe en el tema.
func _probar_tema() -> void:
	var faltan: Array[String] = []
	var expresion := RegEx.create_from_string("Estilo\\.(color|letra|medida)\\(&\"([a-z_]+)\"")
	for ruta in _scripts("res://scripts"):
		var texto := FileAccess.get_file_as_string(ruta)
		for m in expresion.search_all(texto):
			var tema := Estilo.tema()
			var hay: bool = tema.has_color(m.get_string(2), Estilo.TIPO) if m.get_string(1) == "color" else (
				tema.has_font_size(m.get_string(2), Estilo.TIPO) if m.get_string(1) == "letra" else tema.has_constant(m.get_string(2), Estilo.TIPO))
			if not hay:
				faltan.append(m.get_string(2))
	_comprobar(faltan.is_empty(), "Tema: todo nombre que piden los scripts existe en tema.tres %s" % [faltan])
	_comprobar(ProjectSettings.get_setting("gui/theme/custom") == Estilo.RUTA_TEMA, "Tema: es el tema del proyecto (los Control lo toman solos)")
	var sueltos: Array[String] = []
	for ruta in _scripts("res://scripts/ui"):
		if ruta.ends_with("retrato_valeria.gd"):
			continue
		if "Color(" in FileAccess.get_file_as_string(ruta):
			sueltos.append(ruta.get_file())
	_comprobar(sueltos.is_empty(), "Tema: ningún script de la interfaz tiene colores sueltos %s" % [sueltos])


func _scripts(carpeta: String) -> Array[String]:
	var lista: Array[String] = []
	for archivo in DirAccess.get_files_at(carpeta):
		if archivo.ends_with(".gd"):
			lista.append(carpeta.path_join(archivo))
	for sub in DirAccess.get_directories_at(carpeta):
		lista.append_array(_scripts(carpeta.path_join(sub)))
	return lista


func _esperar(cuadros: int) -> void:
	for i in cuadros:
		await process_frame


func _comprobar(condicion: bool, descripcion: String) -> void:
	if condicion:
		print("ok  ", descripcion)
	else:
		print("MAL ", descripcion)
		_fallos.append(descripcion)
