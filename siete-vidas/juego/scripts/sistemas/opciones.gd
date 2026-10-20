class_name Opciones
extends RefCounted
## Opciones del jugador que no son controles (los controles están en Controles): «reducir movimiento» (apaga el
## vaivén y la entrada animada de los botones; el golpe al apretar se queda porque es respuesta, no adorno) y el
## volumen general. Se guardan en user://opciones.cfg y se cargan al empezar el nivel.

const ARCHIVO := "user://opciones.cfg"
## Pasos del volumen general en la pantalla de opciones (0 a 1).
const PASO_VOLUMEN := 0.1

static var reducir_movimiento := false
## Volumen general (0 a 1), en el bus Master.
static var volumen := 1.0:
	set(valor):
		volumen = clampf(valor, 0.0, 1.0)
		aplicar_volumen()


static func aplicar_volumen() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volumen) if volumen > 0.0 else -80.0)
	AudioServer.set_bus_mute(0, volumen <= 0.0)


static func guardar(ruta := ARCHIVO) -> Error:
	var archivo := ConfigFile.new()
	archivo.set_value("accesibilidad", "reducir_movimiento", reducir_movimiento)
	archivo.set_value("sonido", "volumen", volumen)
	return archivo.save(ruta)


static func cargar(ruta := ARCHIVO) -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return false
	reducir_movimiento = bool(archivo.get_value("accesibilidad", "reducir_movimiento", false))
	volumen = float(archivo.get_value("sonido", "volumen", 1.0))
	return true
