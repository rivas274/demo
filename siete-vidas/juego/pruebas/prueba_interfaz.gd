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
	await _probar_ficha()
	await _probar_opciones()
	_probar_textos()
	_probar_controles()
	await _probar_mandos()
	_probar_tema()
	_probar_kit_v2()
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
	await _probar_huellas()
	await _probar_barra_jefe()


## HUELLAS (salud de 9 huellas, interfaz v2): 18 medias = 9 huellas en sus estados; al perder, destello blanco 60 ms y
## rebote; al curar, se llena de abajo arriba; varias, en cascada de 60 ms; con 3 o menos, laten.
func _probar_huellas() -> void:
	var vida := Vida.new(SaludFelipe.MEDIAS_MAX)
	mundo.add_child(vida)
	var barra: BarraVida = (load("res://escenas/ui/barra_vida.tscn") as PackedScene).instantiate()
	mundo.add_child(barra)
	barra.conectar(vida)
	_comprobar(barra.forma == BarraVida.Forma.HUELLAS and barra.huellas() == 9 and barra.medida() == Vector2(152, 20), "Huellas: 9 huellas en la caja de 152×20 del layout")
	_comprobar(BarraVida.estado_de(0, 13) == BarraVida.Huella.LLENA and BarraVida.estado_de(6, 13) == BarraVida.Huella.MEDIA and BarraVida.estado_de(7, 13) == BarraVida.Huella.VACIA, "Huellas: con 13 medias, 6 llenas, 1 media y el resto vacías")
	for estado in BarraVida.Huella.values():
		_comprobar(barra.textura_huella(estado) != null and barra.textura_huella(estado).get_size() == Vector2(13, 12), "Huellas: la huella «%s» del kit mide 13×12" % BarraVida.NOMBRES_HUELLA[estado])
	vida.danar(4)
	_comprobar(barra.animando.size() == 2 and barra.animando[8][0] == BarraVida.Huella.GOLPE and is_equal_approx(barra.animando[7][1], -BarraVida.CASCADA), "Huellas: dos huellas perdidas hacen el golpe en cascada (60 ms)")
	await _segundos(0.4)
	_comprobar(barra.animando.is_empty(), "Huellas: la animación del golpe termina (240 ms más la cascada)")
	vida.curar(2)
	_comprobar(barra.animando.has(7) and barra.animando[7][0] == BarraVida.Huella.CURANDO, "Huellas: al curar, la huella se llena (estado «curando»)")
	vida.fijar(6)
	_comprobar(barra.latiendo(), "Huellas: con 3 huellas o menos, laten")
	vida.fijar(8)
	_comprobar(not barra.latiendo(), "Huellas: con 4, no laten")
	barra.grande = true
	_comprobar(barra.medida() == Vector2(304, 40) and barra.textura_huella(BarraVida.Huella.LLENA).get_size() == Vector2(26, 24), "Huellas: con texto grande, todo al doble (304×40, huellas de 26×24)")
	barra.queue_free()
	vida.queue_free()
	await _esperar(1)


## Barra del jefe v2: 3 segmentos (I, II y III, la fase activa en su color) y la capa de daño reciente que baja 300 ms
## después.
func _probar_barra_jefe() -> void:
	var vida := Vida.new(3)
	mundo.add_child(vida)
	var barra: BarraVida = (load("res://escenas/ui/barra_jefe.tscn") as PackedScene).instantiate()
	barra.titulo = "A.S.P.I."
	mundo.add_child(barra)
	barra.conectar(vida)
	_comprobar(barra.forma == BarraVida.Forma.BARRA and barra.medida() == Vector2(250, 40) and barra.fase_activa() == 0 and BarraVida.FASES == ["I", "II", "III"], "Barra del jefe: 250×40, fases I, II y III; empieza en la I")
	vida.danar(1)
	await _esperar(2)
	_comprobar(barra.fase_activa() == 1 and is_equal_approx(barra.reciente, 1.0) and is_equal_approx(barra.fraccion, 2.0 / 3.0), "Barra del jefe: al bajar, la capa de daño reciente se queda un momento (fase II activa)")
	await _segundos(BarraVida.ESPERA_RECIENTE + BarraVida.BAJADA + 0.2)
	_comprobar(is_equal_approx(barra.reciente, barra.fraccion), "Barra del jefe: el daño reciente baja después de 300 ms")
	barra.queue_free()
	vida.queue_free()
	await _esperar(1)


func _probar_contador_y_cartel() -> void:
	var cartel := Cartel.crear("TÍTULO", "nombre", false, ZonasTexto.cartel(Cartel.medida("TÍTULO", "nombre")))
	_comprobar(cartel.titulo == "TÍTULO" and cartel.nombre == "nombre" and cartel.get_child_count() == 0, "Cartel: franja con título y una sola línea (sin «RECOMPENSA: …»)")
	_comprobar(KitUI.textura("cartel-sello") != null and Estilo.caja(&"v2_cartel_franja") != null and Estilo.caja(&"v2_cartel_linea") != null, "Cartel: usa la franja, el sello y la línea del kit v2")
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
	_comprobar(pantallas.menu_pausa != null and not pantallas.menu_pausa.is_visible_in_tree(), "Pantallas: el menú de pausa existe y no se ve jugando")
	pantallas.modo = Pantallas.Modo.PAUSA
	await _esperar(2)
	var menu := pantallas.menu_pausa
	_comprobar(paused and menu.visible, "Pausa: pausa el juego y muestra el menú")
	_comprobar(menu.enfocado() != null and menu.enfocado().name == &"Continuar", "MenuUI: al mostrarse, el foco va a la primera opción")
	var abajo := menu.enfocado().find_valid_focus_neighbor(SIDE_BOTTOM)
	var arriba := menu.get_node("Continuar").find_valid_focus_neighbor(SIDE_TOP) as Control
	_comprobar(abajo != null and abajo.name == &"Bolsillo" and arriba != null and arriba.name == &"Salir", "MenuUI: se recorre hacia abajo y da la vuelta hacia arriba")
	_comprobar((menu.get_node("Continuar") as Button).text == "MENU_CONTINUAR" and (menu.get_node("Continuar") as Button).auto_translate_mode != Node.AUTO_TRANSLATE_MODE_DISABLED, "MenuUI: el texto del botón es una clave que se traduce sola")
	var elegidos: Array[StringName] = []
	menu.elegido.connect(func(opcion: StringName) -> void: elegidos.append(opcion))
	# Interfaz v2: la pausa trae la lista, el bolsillo y la Ficha (sin pergamino, sin cojín, sin sello).
	_comprobar(pantallas.pausa.visible and pantallas.ficha != null and pantallas.ficha.is_visible_in_tree() and pantallas.bolsillo.is_visible_in_tree(), "Pausa v2: la Ficha de Su Majestad y el bolsillo se ven en la pausa")
	var nombres: Array[String] = []
	for b in menu.get_children():
		nombres.append(String(b.name))
	_comprobar(nombres == ["Continuar", "Bolsillo", "Ficha", "Opciones", "Reiniciar", "Salir"], "Pausa v2: Continuar, Bolsillo, Ficha, Opciones, Reiniciar y Salir %s" % [nombres])
	var continuar := menu.get_node("Continuar") as BotonMenu
	_comprobar(continuar.theme_type_variation == &"BotonMenu" and continuar.size.y == 19.0 and Estilo.tema().get_stylebox(&"focus", &"BotonMenu") is StyleBoxTexture, "Pausa v2: botones del kit (19 px de alto; con foco, el bloque ámbar)")
	_comprobar(ZonasTexto.SEGURA.encloses(Rect2(pantallas.bolsillo.position, pantallas.bolsillo.size)) and ZonasTexto.SEGURA.encloses(Rect2(pantallas.ficha.position, pantallas.ficha.size)) and not Rect2(pantallas.bolsillo.position, pantallas.bolsillo.size).intersects(Rect2(pantallas.ficha.position, pantallas.ficha.size)), "Pausa v2: bolsillo y Ficha dentro de la zona segura, sin montarse")
	menu.get_node("Bolsillo").pressed.emit()
	await _esperar(2)
	_comprobar(pantallas.modo == Pantallas.Modo.PAUSA and pantallas.bolsillo.resalto > 0.0, "Pausa v2: «Bolsillo» lo hace destellar y la pausa sigue")
	continuar.pressed.emit()
	await _esperar(2)
	_comprobar(elegidos == [&"Bolsillo", &"Continuar"] and pantallas.modo == Pantallas.Modo.JUGANDO and not paused and not pantallas.pausa.visible, "Pausa: «Continuar» vuelve al juego")
	pantallas.queue_free()
	await _esperar(1)


## BotonMenu (datos/ui/boton_menu.tres, interfaz v2): el golpe al apretar vuelve a escala 1; sin vaivén (el foco es el
## bloque ámbar del kit); entra barriendo desde la izquierda con rebote; con «reducir movimiento» no entra barriendo.
func _probar_boton() -> void:
	var menu := VBoxContainer.new()
	mundo.add_child(menu)
	var boton := BotonMenu.new()
	boton.text = "MENU_CONTINUAR"
	menu.add_child(boton)
	await _esperar(2)
	var d := boton.datos
	_comprobar(d != null and d.escala_apretado == 0.94 and d.vaiven_grados == 0.0, "BotonMenu: sus números salen de datos/ui/boton_menu.tres (sin vaivén)")
	boton.button_down.emit()
	# Se mira cuadro a cuadro (sin depender del reloj de la máquina): la escala llega a la de apretado y no baja de ahí.
	var minima := 1.0
	var reloj := 0.0
	while reloj < d.tiempo_apretar + 0.15:
		await process_frame
		reloj += get_root().get_process_delta_time()
		minima = minf(minima, boton.scale.x)
	_comprobar(is_equal_approx(minima, d.escala_apretado) and is_equal_approx(boton.scale.x, d.escala_apretado), "BotonMenu: al apretar se encoge")
	boton.button_up.emit()
	await _segundos(d.tiempo_soltar + 0.1)
	_comprobar(is_equal_approx(boton.scale.x, 1.0), "BotonMenu: al soltar vuelve a escala 1")
	boton.grab_focus()
	await _segundos(d.vaiven_rampa + 0.1)
	_comprobar(boton.rotation == 0.0 and boton.theme_type_variation == &"BotonMenu", "BotonMenu: con foco no se mece (el foco es el bloque del kit)")
	Opciones.reducir_movimiento = true
	var x := boton.position.x
	boton.entrar()
	await _esperar(2)
	_comprobar(boton.position.x == x, "BotonMenu: con «reducir movimiento» no entra barriendo")
	Opciones.reducir_movimiento = false
	boton.entrar()
	await _esperar(1)
	_comprobar(boton.position.x < x, "BotonMenu: la entrada empieza a la izquierda de su sitio")
	await _segundos(d.tiempo_entrada + 0.1)
	_comprobar(is_equal_approx(boton.position.x, x), "BotonMenu: y barre hasta su sitio")
	menu.queue_free()
	await _esperar(1)


## Ficha de Su Majestad: las estadísticas salen del peso (más kilos, más todo), cada barra escucha la señal de la
## ficha, las frases son claves que caben en una línea y el peso solo se ve aquí.
func _probar_ficha() -> void:
	var datos: DatosFicha = load("res://datos/ui/ficha.tres")
	for e in [&"defensa", &"carisma", &"ataque", &"peso"]:
		_comprobar(datos.valor(e, 12.0) > datos.valor(e, 8.0), "DatosFicha: más kilos, más %s" % e)
	_comprobar(is_equal_approx(datos.valor(&"defensa", 9.5), 0.55) and is_equal_approx(datos.valor(&"defensa", 8.75), 0.45), "DatosFicha: la tabla se lee por filas e interpola entre ellas")
	_comprobar(datos.frase(&"ataque", 8.0) == "FICHA_ATAQUE_1" and datos.frase(&"ataque", 13.0) == "FICHA_ATAQUE_3", "DatosFicha: tres frases por estadística, según cuánto tenga")
	_comprobar(DatosFicha.texto_kilos(9.8) == "9,8 kg", "DatosFicha: los kilos se leen con coma («9,8 kg»)")
	var ficha: FichaSuMajestad = (load("res://escenas/ui/ficha_su_majestad.tscn") as PackedScene).instantiate()
	mundo.add_child(ficha)
	await _esperar(2)
	var felipe: Felipe = (load("res://escenas/entidades/felipe.tscn") as PackedScene).instantiate()
	mundo.add_child(felipe)
	await _esperar(1)
	ficha.conectar(felipe)
	felipe.peso = 11.6
	await _segundos(0.6)
	var barras := ficha.lista_barras()
	var defensa := barras[1]
	_comprobar(barras.size() == 5 and barras[0].estadistica == &"carisma" and defensa.estadistica == &"defensa" and is_equal_approx(defensa.valor, datos.valor(&"defensa", 11.6)) and is_equal_approx(defensa.mostrado, defensa.valor), "FichaSuMajestad: Felipe.peso_cambiado llega a cada barra (escuchan la señal de la ficha)")
	_comprobar(ficha.kilos == 11.6 and defensa.frase == datos.frase(&"defensa", 11.6), "FichaSuMajestad: muestra los kilos y la frase que toca")
	var velocidad := barras[4]
	_comprobar(not velocidad.con_barra and velocidad.frase == datos.frase_velocidad and tr(velocidad.frase) == "Un rey no corre: lo esperan", "Ficha: la velocidad es solo un chiste fijo («Un rey no corre: lo esperan»)")
	for barra in barras:
		var claves: Array = datos.frases.get(barra.estadistica, [datos.frase_velocidad])
		for clave: String in claves:
			_comprobar(tr(clave) != clave and Estilo.ancho(tr(clave), &"ficha_frase") <= barra.ancho_frase(), "Ficha: «%s» cabe en una línea (%.0f de %.0f px)" % [tr(clave), Estilo.ancho(tr(clave), &"ficha_frase"), barra.ancho_frase()])
	felipe.peso = 8.0
	_comprobar(ficha.kilos == 8.0, "FichaSuMajestad: escucha cada cambio de peso")
	var hud_sin_peso := true
	for ruta in ["res://scripts/ui/hud.gd", "res://scripts/ui/medidores.gd"]:
		var codigo := FileAccess.get_file_as_string(ruta)
		if codigo.contains(".peso") or codigo.contains("PESO"):
			hud_sin_peso = false
	_comprobar(hud_sin_peso, "El peso no se ve en el HUD (solo en la ficha de la pausa)")
	ficha.queue_free()
	felipe.queue_free()
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
	_comprobar(op.menu.has_node("zarpazo") and op.menu.get_child_count() == Controles.ACCIONES.size() + 7 and op.menu.has_node("Vibracion") and op.menu.has_node("ReducirSacudida"), "Opciones: una fila por acción, más golpes, texto grande, reducir movimiento, reducir sacudida, volumen, vibración y volver")
	_comprobar(op.menu.get_child(0).name == &"Golpes" and op.menu.get_child(1).name == &"TextoGrande" and op.menu.get_child(op.menu.get_child_count() - 1).name == &"Volver", "Opciones: la accesibilidad va primero y «Volver» al final")
	# «Golpes» (salud de 9 huellas): normal → suaves → ninguno → normal, guardado.
	Opciones.golpes = Opciones.Golpes.NORMAL
	var golpes := op.menu.get_node("Golpes") as Button
	golpes.pressed.emit()
	_comprobar(Opciones.golpes == Opciones.Golpes.SUAVES and "suaves" in golpes.text and SaludFelipe.medias_del_golpe(2) == 1, "Opciones: «Golpes» pasa a suaves (½ huella por golpe)")
	golpes.pressed.emit()
	_comprobar(Opciones.golpes == Opciones.Golpes.NINGUNO and SaludFelipe.medias_del_golpe(2) == 0, "Opciones: «Golpes» pasa a ninguno (no quita)")
	var archivo := ConfigFile.new()
	archivo.load(Opciones.ARCHIVO)
	_comprobar(int(archivo.get_value("accesibilidad", "golpes", -1)) == Opciones.Golpes.NINGUNO, "Opciones: «Golpes» se guarda")
	golpes.pressed.emit()
	_comprobar(Opciones.golpes == Opciones.Golpes.NORMAL and SaludFelipe.medias_del_golpe(2) == 2, "Opciones: y vuelve a normal (1 huella)")
	(op.menu.get_node("TextoGrande") as Button).pressed.emit()
	_comprobar(Opciones.texto_grande, "Opciones: «Texto grande» se prende")
	(op.menu.get_node("TextoGrande") as Button).pressed.emit()
	_comprobar(not Opciones.texto_grande, "Opciones: y se apaga")
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
	_comprobar(TranslationServer.translate("PAUSA_TITULO") == "PAUSA" and TranslationServer.translate("BOLSILLO_DE") % ["3", "5"] == "3 de 5", "tr: títulos y textos con números")
	_comprobar(PanelBolsillo.texto_huellas(13) == "6 y media" and PanelBolsillo.texto_huellas(18) == "9", "tr: la salud se lee «6 y media» o «9»")
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


## Mandos (DetectorMando + Input Helper): el tipo de mando cambia los íconos y los textos; en Switch se confirma con el
## botón de la derecha; conectar y desconectar no rompe nada y con el teclado vuelven las teclas.
func _probar_mandos() -> void:
	var detector := DetectorMando.de(self)
	var ayudante := root.get_node_or_null("InputHelper")
	_comprobar(detector != null and ayudante != null, "Mandos: los autoloads «Mandos» (DetectorMando) e «InputHelper» (addon MIT) están")
	if detector == null:
		return
	var avisos: Array[StringName] = []
	detector.mando_cambiado.connect(func(t: StringName) -> void: avisos.append(t))
	var nombres := {"Xbox Wireless Controller": DetectorMando.XBOX, "PS5 Controller": DetectorMando.PLAYSTATION, "Nintendo Switch Pro Controller": DetectorMando.SWITCH, "Steam Deck": DetectorMando.STEAM_DECK, "USB Gamepad": DetectorMando.GENERICO}
	var bien := true
	for nombre: String in nombres:
		bien = bien and detector.tipo_de_nombre(nombre) == nombres[nombre]
	_comprobar(bien, "Mandos: reconoce Xbox, PlayStation, Switch, Steam Deck y genérico por el nombre")
	# Cada tipo, como lo avisa Input Helper.
	var esperado := {
		DetectorMando.XBOX: ["A", "res://assets/kenney/input-prompts-pixel.png", Vector2(4, 0)],
		DetectorMando.PLAYSTATION: ["Cruz", "res://assets/kenney/input-prompts-playstation-pixel.png", Vector2(0, 0)],
		DetectorMando.SWITCH: ["B", "res://assets/kenney/input-prompts-pixel.png", Vector2(14, 0)],
	}
	for tipo: StringName in esperado:
		var dispositivo: String = {DetectorMando.XBOX: "xbox", DetectorMando.PLAYSTATION: "playstation", DetectorMando.SWITCH: "switch"}[tipo]
		ayudante.device_changed.emit(dispositivo, 0)
		var icono := IconosBotones.textura("saltar") as AtlasTexture
		var datos: Array = esperado[tipo]
		_comprobar(detector.tipo == tipo and Controles.usa_mando and Controles.texto("saltar") == datos[0] and icono != null and icono.atlas.resource_path == datos[1] and icono.region.position == datos[2] * IconosBotones.LADO, "Mandos: con %s, «Saltar» es «%s» con su ícono" % [tipo, datos[0]])
	ayudante.device_changed.emit("switch", 0)
	var acepta := InputMap.action_get_events("ui_accept").filter(func(e: InputEvent) -> bool: return e is InputEventJoypadButton).map(func(e: InputEventJoypadButton) -> int: return e.button_index)
	_comprobar(acepta == [JOY_BUTTON_B], "Mandos: en Switch se confirma con el botón de la derecha (diseño de Nintendo)")
	ayudante.device_changed.emit("xbox", 0)
	acepta = InputMap.action_get_events("ui_accept").filter(func(e: InputEvent) -> bool: return e is InputEventJoypadButton).map(func(e: InputEventJoypadButton) -> int: return e.button_index)
	_comprobar(acepta == [JOY_BUTTON_A], "Mandos: en los demás, con el de abajo (estándar de Godot)")
	# Eventos de verdad: una tecla vuelve al teclado; un botón, al mando.
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_SPACE
	tecla.pressed = true
	Controles.registrar_evento(tecla)
	var icono_tecla := IconosBotones.textura("saltar") as AtlasTexture
	_comprobar(detector.tipo == DetectorMando.TECLADO and not Controles.usa_mando and Controles.texto("saltar") == "Espacio" and icono_tecla != null and icono_tecla.region.position == Vector2(17, 4) * IconosBotones.LADO, "Mandos: con el teclado vuelven las teclas y sus íconos")
	var boton := InputEventJoypadButton.new()
	boton.button_index = JOY_BUTTON_A
	boton.pressed = true
	Controles.registrar_evento(boton)
	_comprobar(detector.usa_mando() and Controles.usa_mando, "Mandos: un botón del mando cambia a íconos de mando")
	# Conectar y desconectar en caliente.
	detector.al_conectar(3, true)
	detector.cambiar(DetectorMando.PLAYSTATION, 3)
	detector.al_conectar(3, false)
	_comprobar(detector.tipo == DetectorMando.TECLADO and not Controles.usa_mando and IconosBotones.textura("saltar") != null and not detector.conectados.has(3), "Mandos: si se desconecta el mando en uso, vuelve el teclado sin romper nada")
	detector.vibrar(0.5, 0.5, 0.1)
	_comprobar(avisos.size() >= 5 and avisos[-1] == DetectorMando.TECLADO, "Mandos: DetectorMando avisa cada cambio con «mando_cambiado»")
	var antes := Opciones.vibracion
	Opciones.vibracion = false
	Opciones.guardar("user://opciones_prueba.cfg")
	Opciones.vibracion = true
	Opciones.cargar("user://opciones_prueba.cfg")
	_comprobar(not Opciones.vibracion, "Opciones: la vibración del mando se apaga y se guarda")
	Opciones.vibracion = antes
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://opciones_prueba.cfg"))
	await process_frame


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
		if "Color(" in FileAccess.get_file_as_string(ruta):
			sueltos.append(ruta.get_file())
	_comprobar(sueltos.is_empty(), "Tema: ningún script de la interfaz tiene colores sueltos %s" % [sueltos])


## Interfaz v2 («A + C»): toda pieza del kit que pide el código existe en el tema; los colores con nombre de la
## paleta; nada de letra de 8 px en lo que se lee (layout: 11 px de cuerpo o más; las de 8, solo en marcas del mundo);
## el kit viejo «Decreto real» ya no existe.
func _probar_kit_v2() -> void:
	var faltan: Array[String] = []
	var piezas := RegEx.create_from_string("KitUI\\.(pieza|icono|textura|franja_texto|icono_desde_abajo)\\([^\"\\n]*\"([a-z0-9-]+)\"")
	var usadas := 0
	for ruta in _scripts("res://scripts"):
		for m in piezas.search_all(FileAccess.get_file_as_string(ruta)):
			var nombre := m.get_string(2)
			var id := StringName("v2_" + nombre.replace("-", "_"))
			usadas += 1
			# Los nombres armados con «%s» o con sufijo se prueban con sus variantes (felipe, valeria, aspi; -grande).
			if not (Estilo.tema().has_stylebox(id, Estilo.TIPO) or Estilo.tema().has_icon(id, Estilo.TIPO)):
				var hay := false
				for sufijo in ["-felipe", "-valeria", "-aspi", "-grande", "-felipe-0", "-llena", "felipe", "llena"]:
					var otro := StringName("v2_" + (nombre + sufijo).replace("-", "_"))
					hay = hay or Estilo.tema().has_stylebox(otro, Estilo.TIPO) or Estilo.tema().has_icon(otro, Estilo.TIPO)
				if not hay:
					faltan.append(nombre)
	_comprobar(usadas > 30 and faltan.is_empty(), "Kit v2: las %d piezas que pide el código están en el tema %s" % [usadas, faltan])
	var caja := Estilo.caja(&"v2_dialogo_marco_valeria") as StyleBoxTexture
	_comprobar(caja != null and caja.texture.get_size() == Vector2(68, 54) and caja.expand_margin_right == 4.0 and caja.expand_margin_bottom == 4.0 and caja.texture_margin_left == 12.0, "Kit v2: la caja del diálogo se dibuja con su medida lógica (la sombra y el contorno, afuera) y sus cortes del README")
	var paleta := {&"ui_fondo": "241a26", &"ui_panel": "30242c", &"ui_linea": "f4e2bb", &"ui_texto": "fff0d5", &"personaje_felipe": "e8913a", &"personaje_valeria": "d8336b", &"personaje_aspi": "e04848", &"oportunidad": "ffe066"}
	var mal: Array[String] = []
	for nombre: StringName in paleta:
		if not Estilo.tiene_color(nombre) or Estilo.color(nombre).to_html(false) != paleta[nombre]:
			mal.append(String(nombre))
	_comprobar(mal.is_empty(), "Kit v2: la paleta A + C con nombre en el tema (Felipe en oro ámbar, oportunidad en limón) %s" % [mal])
	var chicas: Array[String] = []
	for estilo in Estilo.tema().get_font_size_list(Estilo.TIPO):
		if Estilo.letra(estilo) < ZonasTexto.LETRA_MINIMA and not ZonasTexto.ESTILOS_DECORATIVOS.has(estilo):
			chicas.append(String(estilo))
	_comprobar(chicas.is_empty(), "Letra mínima: nada de 8 px en lo que se lee (11 px de cuerpo o más) %s" % [chicas])
	_comprobar(not DirAccess.dir_exists_absolute("res://assets/ui/decreto") and not ResourceLoader.exists("res://escenas/ui/sello_huella.tscn") and not ResourceLoader.exists("res://escenas/ui/boton_pergamino.tscn"), "Kit viejo: «Decreto real» se borró (lo descartado no se guarda)")
	var codigo := ""
	for ruta in ["res://scripts/ui/hud.gd", "res://scripts/ui/medidores.gd"]:
		for linea in FileAccess.get_file_as_string(ruta).split("\n"):
			if not linea.strip_edges().begins_with("#"):
				codigo += linea + "\n"
	_comprobar(not codigo.contains("snack") and not codigo.contains("ContadorRecurso") and not codigo.contains("vidas"), "HUD mínimo: el HUD no tiene contador de snacks ni de vidas")


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
