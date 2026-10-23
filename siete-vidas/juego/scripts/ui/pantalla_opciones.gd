class_name PantallaOpciones
extends Control
## Pantalla de opciones (se abre desde la pausa): primero la accesibilidad («Golpes»: normal, suaves o ninguno; «Texto
## grande»; «reducir movimiento» y «reducir sacudida»), el volumen, la vibración del mando y después la tecla o el
## botón de cada acción. Va en la pila de pantallas (GestorPantallas): encima de la pausa y la tapa; al cerrarse
## vuelve a la pausa. Aspecto de la interfaz v2 (el panel de la pausa y los botones del kit); la lista se desplaza en
## un solo eje y sigue al foco.
##
## Remapear: elegir una acción y apretar la tecla o el botón nuevo (Esc cancela). Se guarda solo (Controles.guardar)
## y los textos e íconos de toda la interfaz siguen el cambio.

## Se cerró (volver a la pausa).
signal cerrada

const ESCENA := "res://escenas/ui/pantalla_opciones.tscn"

## Acción que espera su tecla nueva ("" si no).
var esperando := ""
var menu: MenuUI
var _botones := {}


static func crear() -> PantallaOpciones:
	return (load(ESCENA) as PackedScene).instantiate()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Tapa toda la pantalla (Pantallas, su padre, no tiene tamaño propio: dibuja con el de la vista).
	size = get_viewport_rect().size
	(get_node("Fondo") as ColorRect).color = Estilo.color(&"ui_fondo")
	menu = get_node("%Menu")
	var muestra: Button = menu.get_node("Volver")
	for accion: String in Controles.ACCIONES:
		var boton := muestra.duplicate() as Button
		boton.name = accion
		boton.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		menu.add_child(boton)
		# Las acciones van después de las opciones y antes de «Volver».
		menu.move_child(boton, menu.get_child_count() - 2)
		_botones[accion] = boton
	menu.preparar()
	menu.elegido.connect(_al_elegir)
	_actualizar_textos()
	visibility_changed.connect(func() -> void:
		if visible:
			menu.enfocar())


## Abre la pantalla encima de lo que haya (la pausa).
func abrir() -> void:
	visible = true
	GestorPantallas.de(self).abrir(self)
	_actualizar_textos()
	menu.enfocar()


func cerrar() -> void:
	esperando = ""
	visible = false
	GestorPantallas.de(self).cerrar(self)
	cerrada.emit()


func _al_elegir(opcion: StringName) -> void:
	match opcion:
		&"Volver":
			cerrar()
		&"Golpes":
			# Normal → suaves → ninguno → normal (no bloquea logros).
			Opciones.golpes = ((Opciones.golpes + 1) % Opciones.Golpes.size()) as Opciones.Golpes
			Opciones.guardar()
		&"TextoGrande":
			Opciones.texto_grande = not Opciones.texto_grande
			Opciones.guardar()
		&"ReducirMovimiento":
			Opciones.reducir_movimiento = not Opciones.reducir_movimiento
			Opciones.guardar()
		&"ReducirSacudida":
			Opciones.reducir_sacudida = not Opciones.reducir_sacudida
			Opciones.guardar()
		&"Vibracion":
			Opciones.vibracion = not Opciones.vibracion
			Opciones.guardar()
		&"Volumen":
			# Cada vez que se elige, baja un paso; de 0 vuelve al máximo (izquierda y derecha también lo cambian).
			Opciones.volumen = 1.0 if Opciones.volumen <= 0.0 else snappedf(Opciones.volumen - Opciones.PASO_VOLUMEN, 0.01)
			Opciones.guardar()
		_:
			empezar_remapeo(String(opcion))
	_actualizar_textos()


func empezar_remapeo(accion: String) -> void:
	if not Controles.ACCIONES.has(accion):
		return
	esperando = accion
	_actualizar_textos()


## Mientras espera una tecla, la primera tecla o botón del mando que se apriete es la nueva (Esc cancela).
func _input(evento: InputEvent) -> void:
	if not visible or not GestorPantallas.de(self).es_la_de_arriba(self):
		return
	if esperando == "":
		if evento.is_action_pressed("ui_cancel"):
			cerrar()
			get_viewport().set_input_as_handled()
		elif menu.enfocado() and menu.enfocado().name == &"Volumen" and (evento.is_action_pressed("ui_left") or evento.is_action_pressed("ui_right")):
			Opciones.volumen += Opciones.PASO_VOLUMEN * (1.0 if evento.is_action_pressed("ui_right") else -1.0)
			Opciones.guardar()
			_actualizar_textos()
			get_viewport().set_input_as_handled()
		return
	recibir_tecla(evento)


## Usa este evento como la tecla nueva de la acción que espera (si es una tecla o un botón del mando apretados).
func recibir_tecla(evento: InputEvent) -> bool:
	if esperando == "":
		return false
	var tecla := evento is InputEventKey and (evento as InputEventKey).pressed and not (evento as InputEventKey).echo
	var boton := evento is InputEventJoypadButton and (evento as InputEventJoypadButton).pressed
	if not (tecla or boton):
		return false
	if tecla and (evento as InputEventKey).physical_keycode == KEY_ESCAPE:
		esperando = ""
	else:
		Controles.remapear(esperando, evento)
		Controles.guardar()
		esperando = ""
	if is_inside_tree():
		get_viewport().set_input_as_handled()
	_actualizar_textos()
	return true


func _actualizar_textos() -> void:
	if menu == null:
		return
	for accion: String in _botones:
		var boton: Button = _botones[accion]
		var tecla := tr("OPCIONES_PULSA") if esperando == accion else "%s / %s" % [Controles.texto(accion, false), Controles.texto(accion, true)]
		boton.text = "%s: %s" % [tr("ACCION_" + accion.to_upper()), tecla]
	var golpes: String = ["OPCIONES_GOLPES_NORMAL", "OPCIONES_GOLPES_SUAVES", "OPCIONES_GOLPES_NINGUNO"][Opciones.golpes]
	(menu.get_node("Golpes") as Button).text = tr("OPCIONES_GOLPES") % tr(golpes)
	(menu.get_node("TextoGrande") as Button).text = tr("OPCIONES_TEXTO_GRANDE") % (tr("OPCIONES_SI") if Opciones.texto_grande else tr("OPCIONES_NO"))
	(menu.get_node("ReducirMovimiento") as Button).text = tr("OPCIONES_REDUCIR") % (tr("OPCIONES_SI") if Opciones.reducir_movimiento else tr("OPCIONES_NO"))
	(menu.get_node("ReducirSacudida") as Button).text = tr("OPCIONES_REDUCIR_SACUDIDA") % (tr("OPCIONES_SI") if Opciones.reducir_sacudida else tr("OPCIONES_NO"))
	(menu.get_node("Volumen") as Button).text = tr("OPCIONES_VOLUMEN") % roundi(Opciones.volumen * 100.0)
	(menu.get_node("Vibracion") as Button).text = tr("OPCIONES_VIBRACION") % (tr("OPCIONES_SI") if Opciones.vibracion else tr("OPCIONES_NO"))
