# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
class_name Controles
extends RefCounted
## Teclas y botones del prototipo, registrados por código (así project.godot queda corto).

## accion -> [teclas (physical keycode), botones de mando, eje del mando o null]
const MAPA := {
	"izquierda": [[KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [JOY_AXIS_LEFT_X, -1.0]],
	"derecha": [[KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [JOY_AXIS_LEFT_X, 1.0]],
	"saltar": [[KEY_SPACE, KEY_W, KEY_UP], [JOY_BUTTON_A], null],
	"correr": [[KEY_SHIFT], [JOY_BUTTON_RIGHT_SHOULDER], null],
	"accion": [[KEY_E], [JOY_BUTTON_Y], null],
	"maullar": [[KEY_Q], [JOY_BUTTON_X], null],
	"intimidar": [[KEY_R], [JOY_BUTTON_B], null],
	"ronronear": [[KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], [JOY_AXIS_LEFT_Y, 1.0]],
	"saltar_dialogo": [[KEY_ENTER, KEY_TAB], [JOY_BUTTON_LEFT_SHOULDER], null],
}


static func registrar() -> void:
	for accion: String in MAPA:
		if InputMap.has_action(accion):
			continue
		InputMap.add_action(accion, 0.4)
		var datos: Array = MAPA[accion]
		for tecla: int in datos[0]:
			var evento := InputEventKey.new()
			evento.physical_keycode = tecla
			InputMap.action_add_event(accion, evento)
		for boton: int in datos[1]:
			var evento := InputEventJoypadButton.new()
			evento.button_index = boton
			InputMap.action_add_event(accion, evento)
		if datos[2] != null:
			var eje := InputEventJoypadMotion.new()
			eje.axis = datos[2][0]
			eje.axis_value = datos[2][1]
			InputMap.action_add_event(accion, eje)
