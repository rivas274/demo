# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name AnimacionesProto
extends RefCounted
## Copia simplificada de AnimacionesFelipe del juego: solo las hojas que usa el prototipo.

const CARPETA := "res://assets/felipe/"

const HOJAS := {
	"quieto": ["felipe-idle-sheet.png", 8.0, true],
	"caminar": ["felipe-walk-sheet.png", 10.0, true],
	"correr": ["felipe-run-sheet.png", 14.0, true],
	"zarpazo": ["felipe-attack-sheet.png", 16.0, false],
	"comer": ["felipe-eat-sheet.png", 8.0, false],
	"saltar": ["felipe-jump-sheet.png", 0.0, false],
	"caer": ["felipe-caida-sheet.png", 0.0, false],
	"ronronear": ["felipe-purr-sheet.png", 8.0, true],
}


static func crear() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for nombre: String in HOJAS:
		var datos: Array = HOJAS[nombre]
		var hoja: Texture2D = load(CARPETA + datos[0])
		var ancho := hoja.get_width() / 8
		frames.add_animation(nombre)
		frames.set_animation_speed(nombre, datos[1])
		frames.set_animation_loop(nombre, datos[2])
		for i in 8:
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			cuadro.region = Rect2(i * ancho, 0, ancho, hoja.get_height())
			frames.add_frame(nombre, cuadro)
	return frames
