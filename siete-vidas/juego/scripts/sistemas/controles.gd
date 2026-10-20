class_name Controles
extends RefCounted
## Los controles del juego en un solo lugar. Las acciones viven en el InputMap (project.godot, sección [input]); aquí
## se lee de ahí qué tecla o qué botón tiene cada una, así que si el jugador las cambia (remapear), los textos y los
## íconos de los avisos cambian solos. También recuerda si lo último que se tocó fue el teclado o el mando.
##
## - texto(accion, mando): "Espacio", "A", "←"... (para avisos y respaldo de los íconos).
## - evento(accion, mando): el primer evento del InputMap para ese dispositivo (para elegir el ícono).
## - remapear(accion, evento) + guardar(): cambia la tecla o el botón y lo deja en user://controles.cfg;
##   cargar() lo vuelve a aplicar al empezar.

## Acciones que el jugador puede cambiar (las de la interfaz, ui_*, son de Godot y no se tocan).
const ACCIONES := [
	"mover_izquierda", "mover_derecha", "mover_arriba", "agacharse", "saltar", "zoomies", "zarpazo", "interactuar",
	"maullar", "agenda", "pausa", "saltar_dialogo",
]
const ARCHIVO := "user://controles.cfg"
## Nombre corto de los botones del mando (Xbox) por índice de JoyButton.
const BOTONES := {
	JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_BACK: "View",
	JOY_BUTTON_START: "Menu", JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "↑", JOY_BUTTON_DPAD_DOWN: "↓", JOY_BUTTON_DPAD_LEFT: "←", JOY_BUTTON_DPAD_RIGHT: "→",
}
## Teclas con nombre propio en pantalla (clave de traducción TECLA_<nombre de Godot>). Las demás muestran su letra.
const TECLAS_CON_NOMBRE := ["Space", "Escape", "Enter", "Tab", "Shift", "Left", "Right", "Up", "Down"]

## Último dispositivo usado (lo cambia registrar_evento).
static var usa_mando := false


## Llamar desde _input de algún nodo: cambia a textos e íconos de mando o de teclado según lo último que se tocó.
static func registrar_evento(evento: InputEvent) -> void:
	if evento is InputEventJoypadButton or (evento is InputEventJoypadMotion and absf((evento as InputEventJoypadMotion).axis_value) > 0.5):
		usa_mando = true
	elif evento is InputEventKey:
		usa_mando = false


## Primer evento de la acción para el teclado o el mando (null si no tiene).
static func evento(accion: String, mando: Variant = null) -> InputEvent:
	var de_mando: bool = usa_mando if mando == null else bool(mando)
	if not InputMap.has_action(accion):
		return null
	for e: InputEvent in InputMap.action_get_events(accion):
		if de_mando and (e is InputEventJoypadButton or e is InputEventJoypadMotion):
			return e
		if not de_mando and e is InputEventKey:
			return e
	return null


## Texto corto de la tecla o el botón que tiene la acción ahora.
static func texto(accion: String, mando: Variant = null) -> String:
	var e := evento(accion, mando)
	if e is InputEventKey:
		return nombre_tecla(e as InputEventKey)
	if e is InputEventJoypadButton:
		return String(BOTONES.get((e as InputEventJoypadButton).button_index, str((e as InputEventJoypadButton).button_index)))
	if e is InputEventJoypadMotion:
		var m := e as InputEventJoypadMotion
		if m.axis == JOY_AXIS_LEFT_X:
			return "←" if m.axis_value < 0.0 else "→"
		return "↑" if m.axis_value < 0.0 else "↓"
	return accion


static func nombre_tecla(e: InputEventKey) -> String:
	var codigo := e.physical_keycode if e.physical_keycode != KEY_NONE else e.keycode
	var nombre := OS.get_keycode_string(codigo)
	if nombre in TECLAS_CON_NOMBRE:
		return TranslationServer.translate("TECLA_" + nombre)
	return nombre


## Cambia la tecla (o el botón, según el evento) de una acción; el del otro dispositivo queda como estaba.
static func remapear(accion: String, nuevo: InputEvent) -> void:
	var de_mando := nuevo is InputEventJoypadButton or nuevo is InputEventJoypadMotion
	var viejo := evento(accion, de_mando)
	if viejo:
		InputMap.action_erase_event(accion, viejo)
	InputMap.action_add_event(accion, nuevo)


## Guarda las teclas y botones de todas las acciones cambiables.
static func guardar(ruta := ARCHIVO) -> Error:
	var archivo := ConfigFile.new()
	for accion: String in ACCIONES:
		if InputMap.has_action(accion):
			archivo.set_value("controles", accion, InputMap.action_get_events(accion))
	return archivo.save(ruta)


## Aplica lo guardado (si hay). Devuelve true si cargó algo.
static func cargar(ruta := ARCHIVO) -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return false
	for accion: String in ACCIONES:
		var eventos: Variant = archivo.get_value("controles", accion, null)
		if eventos is Array and InputMap.has_action(accion):
			InputMap.action_erase_events(accion)
			for e: Variant in eventos:
				if e is InputEvent:
					InputMap.action_add_event(accion, e)
	return true


## "{saltar} para saltar" -> "[Espacio] para saltar" (o el botón del mando en uso).
static func etiquetar(texto_con_acciones: String, mando: Variant = null) -> String:
	for accion: String in ACCIONES:
		texto_con_acciones = texto_con_acciones.replace("{%s}" % accion, "[%s]" % texto(accion, mando))
	return texto_con_acciones
