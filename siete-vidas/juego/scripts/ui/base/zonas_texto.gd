class_name ZonasTexto
extends RefCounted
## Zonas FIJAS de la pantalla de 640×360 para todo lo que se lee. Tabla única, como Capas: nadie inventa dónde poner un
## texto; lo pide aquí. prueba_zonas_texto la comprueba. Interfaz v2 (layout aprobado por el creador, 2026-10-23,
## `siete-vidas/diseno/interfaz-v2.md`): todo lo que se lee va dentro de la ZONA SEGURA de títulos (el 90 % del
## centro: de (32, 18) a (608, 342), la de las guías de consola).
##
##   A   Salud              arriba a la izquierda, desde (32, 18): cara de Felipe y 9 huellas, 152×20 (grande 304×40).
##   A2  Jefe               arriba a la derecha, hasta (608, 18): retrato, nombre y barra con fases I-II-III, 250×44.
##                          Solo en la pelea (`jefe_visible`): mientras se ve, B y C empiezan debajo de ella.
##   B   Diálogo            arriba, de y 44 a 103 (grande, de 64 a 163); abajo solo si Felipe está muy arriba.
##   C   Carteles           desde y 44 (`techo`): travesura, fase del jefe, «PODER NUEVO» centrados; el LOGRO, a la
##                          derecha (`logro`). La MISMA franja que el diálogo: uno a la vez por la cola de Anuncios.
##   D   Palabras del mundo sobre Felipe o el objeto, dentro de la zona segura y fuera de A, B y C; 1 a la vez, 0,9 s.
##   E   Avisos de botón    la burbuja del Indicador sobre Felipe; si D coincide con ella, D sube.
##
## Letra: lo que se lee va con 11 px de cuerpo o más (Pixel Operator 16, su negrita o Silkscreen 16; con texto grande,
## 32). Las letras de 8 px quedan solo para marcas del mundo que no hace falta leer (`ESTILOS_DECORATIVOS`).

const PANTALLA := Rect2(0, 0, 640, 360)
## Zona segura de títulos (90 %) y de acción (95 %).
const SEGURA := Rect2(32, 18, 576, 324)
const ACCION := Rect2(16, 9, 608, 342)
## Franja de arriba donde va la salud (y 0–40; grande, 0–60): nada más entra ahí.
const HUD := Rect2(0, 0, 640, 40)
const SALUD := Rect2(32, 18, 152, 20)
const SALUD_GRANDE := Rect2(32, 18, 304, 40)
const JEFE := Rect2(358, 18, 250, 44)
const DIALOGO := Rect2(0, 44, 640, 60)
const CARTELES := Rect2(0, 44, 640, 60)
## Margen de las palabras con el borde de la pantalla.
const BORDE := 2.0
## Tamaño mínimo de letra (estilo del tema) para todo lo que se lee.
const LETRA_MINIMA := 16
## Estilos de 8 px que se permiten: marcas del mundo que no hace falta leer (rótulos de cajas, «REC» del celular) y
## la letra dentro de las teclas dibujadas (es parte del ícono).
const ESTILOS_DECORATIVOS := [&"etiqueta", &"rec", &"tecla"]
## Una palabra del mundo dura esto, en total (entra, rebota y se va).
const DURACION_PALABRA := 0.9
## Estilos que pueden usar los carteles (zona C) y las palabras (zona D): la prueba exige LETRA_MINIMA en todos.
const ESTILOS_C_Y_D := [&"cartel_kit", &"cartel_nombre", &"logro_nombre", &"jefe_cartel",
	&"jefe_pista", &"palabra", &"palabra_grande", &"censura"]

## Se ve la barra del jefe (la pone PresentacionJefe): el diálogo y los carteles bajan para no taparla.
static var jefe_visible := false


## Dónde empiezan el diálogo y los carteles (y): bajo la salud (grande: bajo la salud grande) y, en la pelea, bajo la
## barra del jefe.
static func techo(grande := false) -> float:
	var bajo_salud := SEGURA.position.y + (40.0 if grande else 20.0) + 6.0
	return maxf(bajo_salud, JEFE.end.y + 2.0) if jefe_visible else bajo_salud


## Rectángulo de la salud (normal o grande).
static func salud(grande := false) -> Rect2:
	return SALUD_GRANDE if grande else SALUD


## Lugar de un cartel de ese tamaño: centrado, arriba en la zona C (el ancho, como mucho el de la zona segura).
static func cartel(tamano: Vector2) -> Rect2:
	var t := Vector2(minf(tamano.x, SEGURA.size.x), minf(tamano.y, CARTELES.size.y))
	return Rect2(Vector2(roundf((PANTALLA.size.x - t.x) / 2.0), techo(Opciones.texto_grande)), t)


## Lugar de un logro de ese tamaño: en la zona C, alineado a la derecha de la zona segura.
static func logro(tamano: Vector2) -> Rect2:
	var t := Vector2(minf(tamano.x, SEGURA.size.x), tamano.y)
	return Rect2(Vector2(SEGURA.end.x - t.x, techo(Opciones.texto_grande)), t)


## Zonas que una palabra del mundo no pisa (A, B y C juntas, y la barra del jefe si se ve).
static func prohibidas_palabra() -> Array[Rect2]:
	var zonas: Array[Rect2] = [HUD, DIALOGO, CARTELES]
	if jefe_visible:
		zonas.append(JEFE)
	return zonas


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
	var x := clampf(caja.position.x, SEGURA.position.x, SEGURA.end.x - caja.size.x)
	var y := clampf(caja.position.y, piso, SEGURA.end.y - caja.size.y)
	return Rect2(Vector2(x, y), caja.size)


## ¿La caja respeta la zona C (dentro de la zona segura, desde el techo y sin tocar la salud ni la barra del jefe)?
static func en_zona_c(caja: Rect2) -> bool:
	var zona := Rect2(SEGURA.position.x, techo(Opciones.texto_grande), SEGURA.size.x, 60.0 * (2.0 if Opciones.texto_grande else 1.0))
	return zona.encloses(caja) and not caja.intersects(HUD) and not (jefe_visible and caja.intersects(JEFE))


## ¿La caja de una palabra queda fuera de A, B y C y dentro de la pantalla?
static func palabra_valida(caja: Rect2) -> bool:
	if not SEGURA.encloses(caja):
		return false
	for zona in prohibidas_palabra():
		if caja.intersects(zona):
			return false
	return true
