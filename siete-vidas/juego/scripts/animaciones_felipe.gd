class_name AnimacionesFelipe
extends RefCounted
## Arma el SpriteFrames de Felipe a partir de las hojas de animación (8 cuadros en fila).
## Agregar una animación nueva es agregar una línea a HOJAS.

const CARPETA := "res://assets/felipe/"
const CUADROS := 8

## nombre -> [archivo, fps, en bucle, cuadros de la hoja (opcional, 8 por defecto), [primer, último] cuadro que usa (opcional)]
const HOJAS := {
	"quieto": ["felipe-idle-sheet.png", 8.0, true],
	"caminar": ["felipe-walk-sheet.png", 10.0, true],
	"correr": ["felipe-run-sheet.png", 14.0, true],
	"zarpazo": ["felipe-attack-sheet.png", 16.0, false],
	"comer": ["felipe-eat-sheet.png", 8.0, false],
	"saltar": ["felipe-jump-sheet.png", 0.0, false],
	"ronronear": ["felipe-purr-sheet.png", 8.0, true],
	"desmayo": ["felipe-faint-sheet.png", 8.0, false],
	## Caída desde Felipe A: se usan cuadros sueltos (Felipe.CUADRO_CAYENDO y CUADRO_CONTACTO).
	"caer": ["felipe-caida-sheet.png", 0.0, false],
	## Una sola hoja: 0 a 3 = transición de pie a agachado (al revés para pararse), 4 a 7 = gateo.
	"agacharse": ["felipe-gatear-sheet.png", 12.0, false, 8, [0, 3]],
	"gatear": ["felipe-gatear-sheet.png", 10.0, true, 8, [4, 7]],
	## Ocio (sin tocar nada unos segundos); ver Felipe.OCIO.
	"acicalarse": ["felipe-acicalarse-sheet.png", 8.0, true],
	"jugar": ["felipe-jugar-sheet.png", 10.0, true],
	"vueltas": ["felipe-vueltas-sheet.png", 10.0, true],
	## Trepar (cortinas): se usan los cuadros 3 a 7, de pie en dos patas clavando las uñas.
	"trepar": ["felipe-trepar-sheet.png", 8.0, true, 8, [3, 7]],
}


static func crear() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for nombre: String in HOJAS:
		var datos: Array = HOJAS[nombre]
		var hoja: Texture2D = load(CARPETA + datos[0])
		var cuadros: int = datos[3] if datos.size() > 3 else CUADROS
		var ancho := hoja.get_width() / cuadros
		frames.add_animation(nombre)
		frames.set_animation_speed(nombre, datos[1])
		frames.set_animation_loop(nombre, datos[2])
		var rango: Array = datos[4] if datos.size() > 4 else [0, cuadros - 1]
		for i in range(rango[0], rango[1] + 1):
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			cuadro.region = Rect2(i * ancho, 0, ancho, hoja.get_height())
			frames.add_frame(nombre, cuadro)
	return frames
