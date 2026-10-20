extends SceneTree
## Prueba de las piezas de la interfaz por separado: BarraVida (escucha a Vida), ContadorRecurso, Cartel, MenuUI, BotonMenu,
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
	await _probar_boton()
	await _probar_opciones()
	_probar_textos()
	_probar_controles()
	_probar_tema()
	_probar_letras()
	_probar_claves()

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
	var hueco := menu.colocar_hueco(menu.get_node("Reiniciar"))
	_comprobar(hueco != null and hueco.global_position.x + hueco.size.x <= (menu.get_node("Reiniciar") as Control).get_global_rect().position.x + 0.5, "MenuUI: el hueco de Felipe se pone al costado del botón elegido")
	_comprobar(abajo != null and abajo.name == &"Opciones" and arriba != null and arriba.name == &"Salir", "MenuUI: se recorre hacia abajo y da la vuelta hacia arriba")
	_comprobar((menu.get_node("Continuar") as Button).text == "MENU_CONTINUAR" and (menu.get_node("Continuar") as Button).auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED, "MenuUI: el texto del botón es una clave que se traduce sola")
	var elegidos: Array[StringName] = []
	menu.elegido.connect(func(opcion: StringName) -> void: elegidos.append(opcion))
	var golpeados: Array[Button] = []
	pantallas.felipe_asomado.golpeo.connect(func(b: Button) -> void: golpeados.append(b))
	(menu.get_node("Continuar") as Button).pressed.emit()
	await _segundos(0.2)
	_comprobar(pantallas.felipe_asomado.visible and pantallas.felipe_asomado.sprite.animation == &"zarpazo" and pantallas.modo == Pantallas.Modo.PAUSA, "Menú de estambre: al elegir, Felipe asoma y da el zarpazo antes de hacer lo elegido")
	await _segundos(1.5)
	_comprobar(golpeados == [menu.get_node("Continuar")] and (menu.get_node("Continuar") as BotonMenu).columpio() > 0.0, "Menú de estambre: el manotazo golpea el letrero elegido (se columpia)")
	_comprobar(elegidos == [&"Continuar"] and pantallas.modo == Pantallas.Modo.JUGANDO and not paused and not menu.visible and not pantallas.felipe_asomado.visible, "Pausa: «Continuar» vuelve al juego")
	pantallas.queue_free()
	await _esperar(1)


## BotonMenu: el golpe al apretar vuelve a escala 1; el vaivén sube con foco y vuelve a 0 sin foco; con «reducir
## movimiento» no se mece ni entra cayendo.
func _probar_boton() -> void:
	var menu := VBoxContainer.new()
	mundo.add_child(menu)
	var boton := BotonMenu.new()
	boton.text = "MENU_CONTINUAR"
	menu.add_child(boton)
	await _esperar(2)
	var d := boton.datos
	_comprobar(d != null and d.escala_apretado == 0.9 and d.vaiven_grados == 6.0, "BotonMenu: sus números salen de datos/ui/boton_menu.tres")
	boton.button_down.emit()
	# Se mira cuadro a cuadro (sin depender del reloj de la máquina): la escala llega a 0,9 y no baja de ahí.
	var minima := 1.0
	var reloj := 0.0
	while reloj < d.tiempo_apretar + 0.15:
		await process_frame
		reloj += get_root().get_process_delta_time()
		minima = minf(minima, boton.scale.x)
	_comprobar(is_equal_approx(minima, d.escala_apretado) and is_equal_approx(boton.scale.x, d.escala_apretado), "BotonMenu: al apretar se encoge a 0,9")
	boton.button_up.emit()
	await _segundos(d.tiempo_soltar + 0.1)
	_comprobar(is_equal_approx(boton.scale.x, 1.0), "BotonMenu: al soltar vuelve a escala 1")
	boton.grab_focus()
	await _segundos(0.1)
	_comprobar(boton.amplitud > 0.0 and boton.amplitud < d.vaiven_grados, "BotonMenu: con foco el vaivén sube de a poco (nunca de golpe)")
	await _segundos(d.vaiven_rampa)
	_comprobar(is_equal_approx(boton.amplitud, d.vaiven_grados) and boton.modulate.r > 1.1, "BotonMenu: con foco se mece hasta 6° y brilla")
	boton.release_focus()
	await _segundos(d.vaiven_rampa + 0.1)
	_comprobar(is_equal_approx(boton.amplitud, 0.0), "BotonMenu: sin foco la amplitud vuelve a 0")
	var golpes: Array[float] = []
	boton.golpeado.connect(func(fuerza: float) -> void: golpes.append(fuerza))
	boton.golpear(1.0)
	await _segundos(0.1)
	_comprobar(golpes == [1.0] and boton.columpio() > 0.0 and absf(boton.rotation) > 0.0, "BotonMenu: golpear() lo columpia y avisa con «golpeado»")
	await _segundos(4.0)
	_comprobar(boton.columpio() == 0.0, "BotonMenu: el columpio del manotazo se apaga solo")
	_comprobar(boton.cuelga() and boton.pivot_offset == (boton.size * boton.punto_cuelgue).round() - Vector2(0, d.largo_hilo), "BotonMenu: cuelga de su hilo (pivote arriba del hilo, sobre la argolla)")
	_comprobar(boton.size == Vector2(87, 39) and boton.theme_type_variation == &"BotonEstambre", "BotonMenu: es el letrero de madera del tema, a su tamaño (no se estira)")
	var motas := boton.get_children().filter(func(n: Node) -> bool: return n is Sprite2D).size()
	_comprobar(motas == 0, "BotonMenu: las motas de pelusa del manotazo se borran solas")
	Opciones.reducir_movimiento = true
	boton.grab_focus()
	await _segundos(d.vaiven_rampa + 0.1)
	var y := boton.position.y
	boton.entrar()
	await _esperar(2)
	_comprobar(boton.rotation == 0.0 and boton.position.y == y, "BotonMenu: con «reducir movimiento» no se mece ni entra cayendo")
	Opciones.reducir_movimiento = false
	boton.entrar()
	await _esperar(1)
	_comprobar(boton.position.y < 0.0, "BotonMenu: la entrada empieza fuera del borde de arriba")
	await _segundos(d.tiempo_entrada + 0.1)
	_comprobar(is_equal_approx(boton.position.y, y), "BotonMenu: y cae hasta su sitio")
	menu.queue_free()
	await _esperar(1)


func _segundos(s: float) -> void:
	await create_timer(s, true).timeout


## Etapa 5: opciones desde la pausa (por la pila de pantallas): remapear con teclado y mando, reducir movimiento y
## volumen general, guardados.
func _probar_opciones() -> void:
	var pantallas := Pantallas.new()
	mundo.add_child(pantallas)
	await _esperar(2)
	pantallas.modo = Pantallas.Modo.PAUSA
	await _esperar(2)
	var gestor := GestorPantallas.de(pantallas)
	_comprobar(pantallas.menu_pausa.has_node("Opciones"), "Opciones: la pausa tiene su letrero «Opciones»")
	pantallas.opciones.abrir()
	await _esperar(2)
	var op := pantallas.opciones
	_comprobar(gestor.arriba() == op and paused and op.visible, "Opciones: se abre encima de la pausa (pila de pantallas) y el juego sigue en pausa")
	_comprobar(op.menu.enfocado() != null, "Opciones: se navega con foco (teclado y mando)")
	_comprobar(op.menu.has_node("zarpazo") and op.menu.get_child_count() == Controles.ACCIONES.size() + 3, "Opciones: una fila por acción, más reducir movimiento, volumen y volver")
	var antes := InputMap.action_get_events("zarpazo").duplicate()
	op.empezar_remapeo("zarpazo")
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_K
	tecla.pressed = true
	op.recibir_tecla(tecla)
	var boton := InputEventJoypadButton.new()
	boton.button_index = JOY_BUTTON_Y
	boton.pressed = true
	op.empezar_remapeo("zarpazo")
	op.recibir_tecla(boton)
	_comprobar(Controles.texto("zarpazo", false) == "K" and Controles.texto("zarpazo", true) == "Y" and op.esperando == "", "Opciones: remapear con el teclado (K) y con el mando (Y)")
	_comprobar(IconosBotones.texto("zarpazo", false) == "K" and "K / Y" in (op.menu.get_node("zarpazo") as Button).text, "Opciones: los íconos y la fila siguen el cambio")
	var cancelar := InputEventKey.new()
	cancelar.physical_keycode = KEY_ESCAPE
	cancelar.pressed = true
	op.empezar_remapeo("zarpazo")
	op.recibir_tecla(cancelar)
	_comprobar(Controles.texto("zarpazo", false) == "K" and op.esperando == "", "Opciones: Esc cancela el remapeo sin cambiar nada")
	InputMap.action_erase_events("zarpazo")
	for e: InputEvent in antes:
		InputMap.action_add_event("zarpazo", e)
	Controles.guardar()
	var reducir := Opciones.reducir_movimiento
	(op.menu.get_node("ReducirMovimiento") as Button).pressed.emit()
	_comprobar(Opciones.reducir_movimiento != reducir, "Opciones: «reducir movimiento» se prende y se apaga")
	(op.menu.get_node("ReducirMovimiento") as Button).pressed.emit()
	Opciones.volumen = 1.0
	(op.menu.get_node("Volumen") as Button).pressed.emit()
	_comprobar(is_equal_approx(Opciones.volumen, 0.9) and AudioServer.get_bus_volume_db(0) < -0.5, "Opciones: el volumen general baja y se aplica al bus de sonido")
	Opciones.volumen = 1.0
	Opciones.guardar()
	(op.menu.get_node("Volver") as Button).pressed.emit()
	await _esperar(2)
	_comprobar(gestor.arriba() == pantallas and paused and not op.visible, "Opciones: «Volver» regresa a la pausa")
	pantallas.modo = Pantallas.Modo.JUGANDO
	pantallas.queue_free()
	await _esperar(2)
	paused = false


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


## B1: letras pixel de licencia libre, sin suavizado, con tildes, eñe y signos de apertura, a su tamaño de diseño.
func _probar_letras() -> void:
	var estilos := [&"texto", &"nota", &"titulo", &"dialogo_texto", &"cartel_titulo", &"palabra", &"jefe_nombre", &"libreta_renglon"]
	var bien := true
	var detalle := []
	for estilo: StringName in estilos:
		var fuente := Estilo.fuente(estilo) as FontFile
		var tamano := Estilo.letra(estilo)
		var base := 8 if fuente != null and fuente.resource_path.ends_with("PixelOperator8.ttf") else 16 if fuente != null and fuente.resource_path.ends_with("PixelOperator.ttf") else 8
		var ok := fuente != null and fuente.antialiasing == TextServer.FONT_ANTIALIASING_NONE and tamano % base == 0
		for letra in "áéíóúñüÁÉÍÓÚÑ¿¡":
			ok = ok and fuente != null and fuente.has_char(letra.unicode_at(0))
		if not ok:
			detalle.append(estilo)
		bien = bien and ok
	_comprobar(bien, "Letra: pixel, sin suavizado, con á é í ó ú ñ ü ¿ ¡ y a un múltiplo de su tamaño de diseño %s" % [detalle])
	_comprobar(Estilo.fuente() != ThemeDB.fallback_font and Estilo.tema().default_font != null, "Letra: el tema trae su letra (ya no la de Godot)")
	_comprobar(Estilo.recortar("A.S.P.I. — Devoradora de Pelos · Nivel 3", &"jefe_barra", 120.0).ends_with("…") and Estilo.ancho(Estilo.recortar("A.S.P.I. — Devoradora de Pelos · Nivel 3", &"jefe_barra", 120.0), &"jefe_barra") <= 120.0, "Letra: un texto que no cabe se recorta con «…»")


## Etapa 4: todo texto del juego es una clave de traducciones/textos.csv, y ninguna clave usada en el código o en los
## datos falta (tr(clave) != clave). Frases de Felipe y Valeria, agenda, primeras frases, palabras, logros, verbos,
## carteles y datos del jefe.
func _probar_claves() -> void:
	var prefijos := "(FELIPE|VALERIA|AGENDA|RECOMPENSA|LECCION|PALABRA|LOGRO|JEFE|CARTEL|VERBO|PRIMERA|ENSAYO|N1|UI|MENU|PAUSA|FIN|TITULO|INTRO|LIBRETA|RESUMEN|NOMBRE|CUARTO|TECLA)_[A-Z0-9_]+"
	var expresion := RegEx.create_from_string("\"(" + prefijos + ")\"")
	var faltan: Array[String] = []
	var usadas := 0
	var archivos := _scripts("res://scripts")
	for carpeta in ["res://datos/jefes", "res://datos/objetos", "res://datos/enemigos"]:
		for archivo in DirAccess.get_files_at(carpeta):
			if archivo.ends_with(".tres"):
				archivos.append(carpeta.path_join(archivo))
	for ruta in archivos:
		# La tabla de capas nombra sus capas en mayúsculas (FELIPE_IMAGINANDO): no son textos.
		if ruta.ends_with("capas.gd"):
			continue
		for m in expresion.search_all(FileAccess.get_file_as_string(ruta)):
			usadas += 1
			if TranslationServer.translate(m.get_string(1)) == m.get_string(1):
				faltan.append("%s (%s)" % [m.get_string(1), ruta.get_file()])
	_comprobar(usadas > 200 and faltan.is_empty(), "Claves: las %d claves del código y los datos tienen su texto %s" % [usadas, faltan])
	var sueltas: Array[String] = []
	for tabla: Dictionary in [Frases.FELIPE, Frases.VALERIA]:
		for evento: String in tabla:
			for frase: Array in tabla[evento]:
				if not RegEx.create_from_string("^" + prefijos + "$").search(String(frase[0])):
					sueltas.append(String(frase[0]))
	for t: Dictionary in Agenda.NIVEL_1:
		for texto: String in [String(t["nombre"]), String(t["frase"][0]), String((t["recompensa"] as Dictionary)["texto"])]:
			if not RegEx.create_from_string("^" + prefijos + "$").search(texto):
				sueltas.append(texto)
	for leccion: Array in Nivel1.LECCIONES:
		if not RegEx.create_from_string("^" + prefijos + "$").search(String(leccion[1])):
			sueltas.append(String(leccion[1]))
	_comprobar(sueltas.is_empty(), "Claves: las frases de Felipe y Valeria, la agenda y las primeras frases van por clave %s" % [sueltas])


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
