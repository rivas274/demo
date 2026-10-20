class_name ZonasTexto
extends RefCounted
## Zonas FIJAS de la pantalla de 640×360 para todo lo que se lee (plan de estabilización 2026-10-20, decisión 3).
## Tabla única, como Capas: nadie inventa dónde poner un texto; lo pide aquí. prueba_zonas_texto la comprueba.
##
##   A  HUD                 y 0–26    corazones, agenda, contadores y barra del jefe (a la derecha). Nada más entra.
##   B  Diálogo             y 30–80   cuadro de diálogo con retrato.
##   C  Carteles            y 30–90   logros, «¡TRAVESURA CUMPLIDA!», fases del jefe, «¡DEPÓSITO LLENO!», «PODER NUEVO».
##                                    La MISMA franja que el diálogo: uno a la vez por la cola de Anuncios, y si hay
##                                    diálogo, espera su turno (la fase del jefe, urgente, corta la frase).
##   D  Palabras del mundo  sobre Felipe o el objeto, fuera de A, B y C y dentro de la pantalla; 1 a la vez, 0,9 s.
##   E  Avisos de botón     la burbuja del Indicador sobre Felipe; si D coincide con ella, D sube.
##
## Letra: todo lo de C y D se escribe con un estilo de 16 px o más (Pixel Operator 16 o Silkscreen 16/24: 9 a 15 px de
## alto de mayúscula). Los estilos de 8 px (Pixel Operator 8, Silkscreen 8) quedan para el HUD y la libreta.

const PANTALLA := Rect2(0, 0, 640, 360)
const HUD := Rect2(0, 0, 640, 27)
const DIALOGO := Rect2(0, 30, 640, 51)
const CARTELES := Rect2(0, 30, 640, 61)
## Margen de las palabras con el borde de la pantalla.
const BORDE := 2.0
## Tamaño mínimo de letra (estilo del tema) para carteles y palabras.
const LETRA_MINIMA := 16
## Una palabra del mundo dura esto, en total (entra, rebota y se va).
const DURACION_PALABRA := 0.9
## Estilos que pueden usar los carteles (zona C) y las palabras (zona D): la prueba exige LETRA_MINIMA en todos.
const ESTILOS_C_Y_D := [&"cartel_titulo", &"cartel_nombre", &"logro_nombre", &"jefe_cartel",
	&"jefe_pista", &"palabra", &"palabra_grande", &"censura"]


## Lugar de un cartel de ese tamaño: centrado, arriba en la zona C (la altura se recorta a la de la zona).
static func cartel(tamano: Vector2) -> Rect2:
	var t := Vector2(minf(tamano.x, CARTELES.size.x), minf(tamano.y, CARTELES.size.y))
	return Rect2(Vector2(roundf((PANTALLA.size.x - t.x) / 2.0), CARTELES.position.y), t)


## Zonas que una palabra del mundo no pisa (A, B y C juntas: de y 0 a 90 en todo el ancho).
static func prohibidas_palabra() -> Array[Rect2]:
	return [HUD, DIALOGO, CARTELES]


## Recoloca la caja de una palabra: dentro de la pantalla y fuera de A, B y C, sin pisar nada de `evitar` (Felipe, la
## burbuja del Indicador, la cara de Valeria). Prueba el lugar pedido y, si choca, arriba, a los lados y abajo de lo
## que pisa; se queda con el lugar libre más cercano al pedido (si no hay ninguno, el pedido, dentro de la pantalla).
static func colocar_palabra(caja: Rect2, evitar: Array[Rect2] = []) -> Rect2:
	var piso := CARTELES.end.y + BORDE
	var pedido := _dentro(caja, piso)
	var candidatos: Array[Rect2] = [pedido]
	for zona in evitar:
		for p: Vector2 in [Vector2(pedido.position.x, zona.position.y - caja.size.y - 2.0),
				Vector2(zona.position.x - caja.size.x - 2.0, pedido.position.y),
				Vector2(zona.end.x + 2.0, pedido.position.y),
				Vector2(pedido.position.x, zona.end.y + 2.0)]:
			candidatos.append(_dentro(Rect2(p, caja.size), piso))
	var mejor := pedido
	var distancia := INF
	for c in candidatos:
		var libre := true
		for zona in evitar:
			if c.intersects(zona):
				libre = false
				break
		if libre and c.position.distance_to(pedido.position) < distancia:
			distancia = c.position.distance_to(pedido.position)
			mejor = c
	return Rect2(mejor.position.round(), mejor.size)


static func _dentro(caja: Rect2, piso: float) -> Rect2:
	var x := clampf(caja.position.x, BORDE, PANTALLA.size.x - BORDE - caja.size.x)
	var y := clampf(caja.position.y, piso, PANTALLA.size.y - BORDE - caja.size.y)
	return Rect2(Vector2(x, y), caja.size)


## ¿La caja respeta la zona C (dentro de ella y de la pantalla, sin tocar el HUD)?
static func en_zona_c(caja: Rect2) -> bool:
	return CARTELES.encloses(caja) and not caja.intersects(HUD)


## ¿La caja de una palabra queda fuera de A, B y C y dentro de la pantalla?
static func palabra_valida(caja: Rect2) -> bool:
	if not PANTALLA.encloses(caja):
		return false
	for zona in prohibidas_palabra():
		if caja.intersects(zona):
			return false
	return true
