class_name AnimacionesFelipe
extends RefCounted
## Arma el SpriteFrames de Felipe a partir de las hojas de animación (8 cuadros en fila).
## Agregar una animación nueva es agregar una línea a HOJAS.

const CARPETA := "res://assets/felipe/"
const CUADROS := 8
## Cuánto adelanta el pie apoyado cada cuadro de la hoja, en px del juego (medido en la hoja con
## prueba_movimiento: caminar ~2,5 px de hoja × 0,72; correr ~5 px × 0,72). Felipe ajusta el ritmo de la animación a su
## velocidad con esto (G9 de la revisión 3): las patas no patinan.
const PASO := {"caminar": 1.8, "correr": 3.6}
## Tope de cuadros por segundo del ciclo (más rápido se ve borroso a 60 Hz). Con el tope, el pie apoyado se desliza
## como mucho v / FPS_MAXIMO − PASO: 1,7 px caminando a 120 px/s y 2,0 px corriendo a 190 px/s.
const FPS_MAXIMO := 34.0

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
	## Maullar (botón propio): la boca se abre del todo en Felipe.CUADRO_MAULLIDO.
	"maullar": ["felipe-maullar-sheet.png", 10.0, false],
	## Arañar de pie en dos patas (sofá, rascador, puerta entornada): las garras bajan en Felipe.CUADROS_IMPACTO_ARANAR.
	"aranar": ["felipe-aranar-sheet.png", 12.0, false],
	## Subir un escalón: un ciclo por escalón; Felipe.subir_escalon() ajusta la velocidad al tiempo del escalón.
	"subir_escalera": ["felipe-subir-escalera-sheet.png", 20.0, false],
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
