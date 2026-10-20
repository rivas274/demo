class_name Opciones
extends RefCounted
## Opciones del jugador que no son controles: por ahora, «reducir movimiento» (apaga el vaivén y la entrada animada
## de los botones; el golpe al apretar se queda porque es respuesta, no adorno). Se guardan en user://opciones.cfg y
## se cargan al empezar el nivel.

const ARCHIVO := "user://opciones.cfg"

static var reducir_movimiento := false


static func guardar(ruta := ARCHIVO) -> Error:
	var archivo := ConfigFile.new()
	archivo.set_value("accesibilidad", "reducir_movimiento", reducir_movimiento)
	return archivo.save(ruta)


static func cargar(ruta := ARCHIVO) -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return false
	reducir_movimiento = bool(archivo.get_value("accesibilidad", "reducir_movimiento", false))
	return true
