class_name MenuUI
extends VBoxContainer
## Menú base: una columna de botones (BotonMenu, o cualquier Button) que se recorre con el teclado (flechas, W/S) o
## el mando (cruceta, palanca) y se elige con Enter o A. Al mostrarse toma el foco en el primer botón; el foco da la
## vuelta de abajo hacia arriba. Avisa con `elegido(nombre del botón)`: el menú no sabe qué hace cada opción.
## Se arma en el editor (escenas/ui/menu_pausa.tscn); el texto de cada botón es una clave de traducción.

signal elegido(opcion: StringName)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var botones := _botones()
	for i in botones.size():
		var boton := botones[i]
		boton.focus_mode = Control.FOCUS_ALL
		boton.pressed.connect(func() -> void: elegido.emit(boton.name))
		# El foco da la vuelta (de la última a la primera y al revés).
		boton.focus_neighbor_top = boton.get_path_to(botones[(i - 1 + botones.size()) % botones.size()])
		boton.focus_neighbor_bottom = boton.get_path_to(botones[(i + 1) % botones.size()])
	visibility_changed.connect(_al_mostrarse)


func _botones() -> Array[Button]:
	var lista: Array[Button] = []
	for hijo in get_children():
		if hijo is Button:
			lista.append(hijo)
	return lista


func _al_mostrarse() -> void:
	if is_visible_in_tree():
		enfocar()


## Pone el foco en la primera opción (o en la que se pida).
func enfocar(opcion: StringName = &"") -> void:
	var botones := _botones()
	if botones.is_empty():
		return
	var boton := botones[0]
	if opcion != &"" and has_node(NodePath(opcion)):
		boton = get_node(NodePath(opcion))
	boton.grab_focus.call_deferred()


## El botón que tiene el foco ahora (o null).
func enfocado() -> Button:
	for boton in _botones():
		if boton.has_focus():
			return boton
	return null
