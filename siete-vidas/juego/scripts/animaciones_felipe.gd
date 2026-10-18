class_name AnimacionesFelipe
extends RefCounted
## Arma el SpriteFrames de Felipe a partir de las hojas de animación (8 cuadros en fila).
## Agregar una animación nueva es agregar una línea a HOJAS.

const CARPETA := "res://assets/felipe/"
const CUADROS := 8

## nombre -> [archivo, fps, en bucle, cuadros (opcional, 8 por defecto)]
const HOJAS := {
	"quieto": ["felipe-idle-sheet.png", 8.0, true],
	"caminar": ["felipe-walk-sheet.png", 10.0, true],
	"correr": ["felipe-run-sheet.png", 14.0, true],
	"zarpazo": ["felipe-attack-sheet.png", 16.0, false],
	"comer": ["felipe-eat-sheet.png", 8.0, false],
	"saltar": ["felipe-jump-sheet.png", 0.0, false],
	"ronronear": ["felipe-purr-sheet.png", 8.0, true],
	"desmayo": ["felipe-faint-sheet.png", 8.0, false],
	## Poses propias de la caída: 0 = cayendo con las delanteras estiradas, 1 = contacto con las delanteras.
	"caer": ["felipe-caida-sheet.png", 0.0, false, 2],
	## Gateo agachado: cuadros de 256×256 (más grandes que los demás); se dibuja con Felipe.ESCALA_AGACHADO.
	"gatear": ["felipe-gatear-sheet.png", 10.0, true],
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
		for i in cuadros:
			var cuadro := AtlasTexture.new()
			cuadro.atlas = hoja
			cuadro.region = Rect2(i * ancho, 0, ancho, hoja.get_height())
			frames.add_frame(nombre, cuadro)
	return frames
