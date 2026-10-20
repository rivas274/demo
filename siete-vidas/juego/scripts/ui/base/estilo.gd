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


## Fuente de la interfaz (la del tema; si no hay, la de Godot).
static func fuente() -> Font:
	return tema().default_font if tema().default_font else ThemeDB.fallback_font


## ¿Existe ese color en el tema? (para las pruebas: ningún nombre pedido falta).
static func tiene_color(nombre: StringName) -> bool:
	return tema().has_color(nombre, TIPO)


## Texto con contorno (el de los contadores y carteles): primero el borde, encima el color.
static func texto_con_contorno(c: CanvasItem, pos: Vector2, texto: String, tamano: int, color: Color, contorno: StringName = &"contorno_hud", grosor := -1) -> void:
	var borde := grosor if grosor >= 0 else medida(&"contorno_hud")
	c.draw_string_outline(fuente(), pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, borde, Estilo.color(contorno))
	c.draw_string(fuente(), pos, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


## Texto centrado en x (la pantalla, si `centro_x` < 0).
static func texto_centrado(c: CanvasItem, texto: String, y: float, tamano: int, color: Color, centro_x := -1.0) -> void:
	var cx := centro_x if centro_x >= 0.0 else c.get_viewport_rect().size.x / 2.0
	var ancho := fuente().get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x
	c.draw_string(fuente(), Vector2(cx - ancho / 2.0, y), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)
