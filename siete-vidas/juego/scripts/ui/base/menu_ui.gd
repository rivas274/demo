class_name MenuUI
extends VBoxContainer
## Menú base: una columna de botones (BotonMenu, o cualquier Button) que se recorre con el teclado (flechas, W/S) o
## el mando (cruceta, palanca) y se elige con Enter o A. Al mostrarse toma el foco en el primer botón; el foco da la
## vuelta de abajo hacia arriba. Avisa con `elegido(nombre del botón)`: el menú no sabe qué hace cada opción.
## Se arma en el editor (escenas/ui/menu_pausa.tscn); el texto de cada botón es una clave de traducción. Con
## `animar_entrada`, los botones (BotonMenu) caen desde arriba uno tras otro al mostrarse.

## Hueco donde la pantalla de menú pone a Felipe asomado por un costado (nodo hijo `HuecoFelipe`, fuera del
## acomodo de la columna: top_level). colocar_hueco(boton) lo lleva al costado de ese botón.
var hueco_felipe: Control
## Lado por el que asoma Felipe: -1 izquierda, 1 derecha.
@export var lado_felipe := -1

## Al mostrarse, los botones caen desde arriba, escalonados (no con Opciones.reducir_movimiento).
@export var animar_entrada := true

signal elegido(opcion: StringName)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	preparar()
	visibility_changed.connect(_al_mostrarse)
	hueco_felipe = get_node_or_null("HuecoFelipe")
	# Menú de estambre: los letreros cuelgan en cadena (cada hilo mide lo que separa un letrero del de arriba) y la
	# columna cuelga de un ovillo.
	var primero := _primero_colgado()
	if primero:
		add_theme_constant_override(&"separation", int(primero.datos.largo_hilo))
	sort_children.connect(queue_redraw)


## Conecta cada botón (avisa `elegido` con su nombre) y arma el foco que da la vuelta. Llamarla de nuevo si se
## agregan botones por código (por ejemplo, una fila por acción en las opciones).
func preparar() -> void:
	var botones := _botones()
	for i in botones.size():
		var boton := botones[i]
		boton.focus_mode = Control.FOCUS_ALL
		if not boton.has_meta(&"menu_conectado"):
			boton.set_meta(&"menu_conectado", true)
			boton.pressed.connect(func() -> void: elegido.emit(boton.name))
		# El foco da la vuelta (de la última a la primera y al revés).
		boton.focus_neighbor_top = boton.get_path_to(botones[(i - 1 + botones.size()) % botones.size()])
		boton.focus_neighbor_bottom = boton.get_path_to(botones[(i + 1) % botones.size()])


func _primero_colgado() -> BotonMenu:
	for boton in _botones():
		if boton is BotonMenu and (boton as BotonMenu).cuelga():
			return boton
	return null


## El ovillo arriba de la columna, donde termina el hilo del primer letrero.
func _draw() -> void:
	var primero := _primero_colgado()
	if primero == null or primero.datos.ovillo == null:
		return
	var ovillo := primero.datos.ovillo
	var x := primero.position.x + roundf(primero.size.x * primero.punto_cuelgue.x)
	# La columna empieza arriba (alignment BEGIN): el primer letrero está en y = 0 aunque esté cayendo.
	var abajo := -primero.datos.largo_hilo + 4.0
	draw_texture(ovillo, Vector2(roundf(x - ovillo.get_width() * 0.35), roundf(abajo - ovillo.get_height())))


func _botones() -> Array[Button]:
	var lista: Array[Button] = []
	for hijo in get_children():
		if hijo is Button:
			lista.append(hijo)
	return lista


func _al_mostrarse() -> void:
	if is_visible_in_tree():
		enfocar()
		if animar_entrada:
			_entrar.call_deferred()


## Entrada escalonada: espera a que el contenedor acomode los botones y los deja caer uno tras otro.
func _entrar() -> void:
	# El contenedor acomoda a sus hijos al final del cuadro: recién después se sabe dónde va cada botón.
	await get_tree().process_frame
	var i := 0
	for boton in _botones():
		if boton is BotonMenu:
			var b := boton as BotonMenu
			b.entrar(i * b.datos.escalon_entrada)
			i += 1


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


## Lleva el hueco de Felipe al costado del botón (a su altura, pegado por fuera) y lo devuelve; la pantalla pone
## ahí a Felipe y, cuando su pata llega (cuadro de impacto del zarpazo), llama boton.golpear().
func colocar_hueco(boton: Button) -> Control:
	if hueco_felipe == null:
		return null
	var r := boton.get_global_rect()
	var x := r.position.x - hueco_felipe.size.x if lado_felipe < 0 else r.end.x
	hueco_felipe.global_position = Vector2(x, r.position.y + (r.size.y - hueco_felipe.size.y) / 2.0).round()
	return hueco_felipe
