class_name Opciones
extends RefCounted
## Opciones del jugador que no son controles (los controles están en Controles): «reducir movimiento» (apaga el
## vaivén y la entrada animada de los botones, los rebotes de la interfaz y los fragmentos que vuelan; el golpe al
## apretar se queda porque es respuesta, no adorno), el volumen general, la vibración del mando y, en accesibilidad,
## «Golpes» (cuánto quita un golpe: no bloquea logros) y «Texto grande» (200 %: la salud, el diálogo y los logros al
## doble). Se guardan en user://opciones.cfg y se cargan al empezar el nivel.

## «Golpes» (salud de 9 huellas, accesibilidad): NORMAL quita 1 huella, SUAVES ½ huella y NINGUNO nada (el golpe
## empuja y suena igual). Sin juicio y sin bloquear logros, como el modo asistido de Celeste.
enum Golpes { NORMAL, SUAVES, NINGUNO }

const ARCHIVO := "user://opciones.cfg"
## Pasos del volumen general en la pantalla de opciones (0 a 1).
const PASO_VOLUMEN := 0.1

static var reducir_movimiento := false
## «Reducir sacudida» (accesibilidad, v3.1): los temblores de pantalla se dividen por 3 (mínimo 1 px).
static var reducir_sacudida := false
## Vibración leve del mando en golpes, derrotas y aterrizajes fuertes (DetectorMando.vibrar).
static var vibracion := true
static var golpes := Golpes.NORMAL
## Texto grande (200 %): la salud, el diálogo y los logros con letra de 32 y piezas grandes del kit.
static var texto_grande := false
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
	archivo.set_value("accesibilidad", "reducir_sacudida", reducir_sacudida)
	archivo.set_value("accesibilidad", "golpes", golpes)
	archivo.set_value("accesibilidad", "texto_grande", texto_grande)
	archivo.set_value("sonido", "volumen", volumen)
	archivo.set_value("mando", "vibracion", vibracion)
	return archivo.save(ruta)


static func cargar(ruta := ARCHIVO) -> bool:
	var archivo := ConfigFile.new()
	if archivo.load(ruta) != OK:
		return false
	reducir_movimiento = bool(archivo.get_value("accesibilidad", "reducir_movimiento", false))
	reducir_sacudida = bool(archivo.get_value("accesibilidad", "reducir_sacudida", false))
	golpes = clampi(int(archivo.get_value("accesibilidad", "golpes", Golpes.NORMAL)), Golpes.NORMAL, Golpes.NINGUNO) as Golpes
	texto_grande = bool(archivo.get_value("accesibilidad", "texto_grande", false))
	volumen = float(archivo.get_value("sonido", "volumen", 1.0))
	vibracion = bool(archivo.get_value("mando", "vibracion", true))
	return true
