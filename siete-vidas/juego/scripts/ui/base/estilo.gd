class_name Estilo
extends RefCounted
## Acceso al tema central de la interfaz (datos/ui/tema.tres): colores, tamaños de letra y medidas con nombre.
## Los nodos Control (Label, Button, Panel...) toman el tema solos (está puesto en project.godot como tema del
## proyecto); lo que se dibuja con código (draw_rect, draw_string) pide aquí sus colores y tamaños por nombre, para
## que ningún color ni tamaño suelto viva en un script de la interfaz.
##
## Cambiar un color de la interfaz = cambiarlo en tema.tres (tipo "Felipe"), en el editor o a mano.

const RUTA_TEMA := "res://datos/ui/tema.tres"
## Tipo del tema donde están los colores, tamaños y medidas con nombre.
const TIPO := &"Felipe"

static var _tema: Theme


static func tema() -> Theme:
	if _tema == null:
		_tema = load(RUTA_TEMA)
	return _tema


## Color con nombre del tema ("rojo", "texto_claro"...). Con `alfa` >= 0 cambia su transparencia.
static func color(nombre: StringName, alfa := -1.0) -> Color:
	var c := tema().get_color(nombre, TIPO)
	if alfa >= 0.0:
		c.a = alfa
	return c


## Tamaño de letra con nombre ("titulo", "aviso"...).
static func letra(nombre: StringName) -> int:
	return tema().get_font_size(nombre, TIPO)


## Medida con nombre (márgenes, altos de barra...).
static func medida(nombre: StringName) -> int:
	return tema().get_constant(nombre, TIPO)


## Fuente pixel del estilo con ese nombre (la misma clave que su tamaño en letra()); sin nombre, la de por defecto
## del tema. Letras (fuentes/, sin suavizado): Pixel Operator 8 a 8 px (chica), Pixel Operator a 16 px (textos) y
## Silkscreen a 16, 24 o 32 px (títulos y carteles). Siempre a su tamaño de diseño o un múltiplo: nítidas a 640×360.
static func fuente(nombre: StringName = &"") -> Font:
	if nombre != &"" and tema().has_font(nombre, TIPO):
		return tema().get_font(nombre, TIPO)
	return tema().default_font if tema().default_font else ThemeDB.fallback_font


## Dibuja un texto con la fuente y el tamaño del estilo `nombre` (atajo de draw_string).
static func escribir(c: CanvasItem, pos: Vector2, texto: String, nombre: StringName, color: Color, alineacion := HORIZONTAL_ALIGNMENT_LEFT, ancho := -1.0) -> void:
	c.draw_string(fuente(nombre), pos.round(), texto, alineacion, ancho, letra(nombre), color)


## Ancho del texto con el estilo `nombre`.
static func ancho(texto: String, nombre: StringName) -> float:
	return fuente(nombre).get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra(nombre)).x


## ¿Existe ese color en el tema? (para las pruebas: ningún nombre pedido falta).
static func tiene_color(nombre: StringName) -> bool:
	return tema().has_color(nombre, TIPO)


## Texto con contorno (el de los contadores y carteles): primero el borde, encima el color.
static func texto_con_contorno(c: CanvasItem, pos: Vector2, texto: String, nombre: StringName, color: Color, contorno: StringName = &"contorno_hud", grosor := -1) -> void:
	var borde := grosor if grosor >= 0 else medida(&"contorno_hud")
	c.draw_string_outline(fuente(nombre), pos.round(), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra(nombre), borde, Estilo.color(contorno))
	c.draw_string(fuente(nombre), pos.round(), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, letra(nombre), color)


## Texto centrado en x (la pantalla, si `centro_x` < 0).
static func texto_centrado(c: CanvasItem, texto: String, y: float, nombre: StringName, color: Color, centro_x := -1.0) -> void:
	var cx := centro_x if centro_x >= 0.0 else c.get_viewport_rect().size.x / 2.0
	escribir(c, Vector2(roundf(cx - ancho(texto, nombre) / 2.0), y), texto, nombre, color)
