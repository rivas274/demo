class_name Cartel
extends Control
## Pieza de interfaz: un cartel de anuncio, con el kit «Decreto real» (la misma familia que la pausa): la cinta de
## terciopelo con el título grande y, colgando debajo, un pergamino con una línea (el nombre de la travesura).
## Entra con un golpe de escala, se queda `duracion` s y sale deslizándose a la izquierda. No sabe de colas ni de
## travesuras: quien lo crea (Hud, a través de Anuncios) decide cuándo y dónde. Colores y letras salen del tema.

const ANCHO_PANTALLA := 640.0
const ENTRADA := 0.18
const SALIDA := 0.25
## Franja: la cinta del título (9 partes, a su alto de pixel) y el pergamino de abajo.
const ANCHO_CINTA := 432.0
const ALTO_CINTA := 42.0
const ANCHO_PAPEL := 360.0

## Animación de entrada, espera y salida (para cortarla con ocultar()).
var animacion: Tween


## Arma el cartel en `rect` (la zona C de ZonasTexto: 640 × 60 arriba). `secreta` lo pinta de rosa en vez de dorado.
## Título grande en la cinta y UNA línea corta debajo (plan de estabilización 2026-10-20: la línea «RECOMPENSA: …»
## se quitó; la recompensa se ve volar al HUD y está en la libreta).
static func crear(titulo: String, nombre: String, secreta: bool, rect: Rect2) -> Cartel:
	var caja := Cartel.new()
	caja.name = "Cartel"
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.size = rect.size
	caja.position = rect.position
	caja.pivot_offset = rect.size / 2.0
	var color := Estilo.color(&"cartel_secreto") if secreta else Estilo.color(&"cartel_dorado")
	var x_papel := roundf((rect.size.x - ANCHO_PAPEL) / 2.0)
	caja.add_child(panel(&"panel", Rect2(x_papel, ALTO_CINTA - 10.0, ANCHO_PAPEL, rect.size.y - ALTO_CINTA + 10.0)))
	var x_cinta := roundf((rect.size.x - ANCHO_CINTA) / 2.0)
	caja.add_child(panel(&"cinta", Rect2(x_cinta, 0, ANCHO_CINTA, ALTO_CINTA)))
	caja.add_child(etiqueta(titulo, &"cartel_titulo", color, Vector2(x_cinta + 32, 5), ANCHO_CINTA - 64))
	caja.add_child(etiqueta(nombre.to_upper(), &"cartel_nombre", Estilo.color(&"tinta_decreto"), Vector2(x_papel + 10, ALTO_CINTA - 1.0), ANCHO_PAPEL - 20, false))
	caja.scale = Vector2(1.6, 0.1)
	caja.modulate.a = 0.0
	return caja


## Entra, espera y sale (ya dentro del árbol). Se borra solo al terminar.
func animar(duracion: float) -> void:
	animacion = create_tween()
	animacion.tween_property(self, "scale", Vector2.ONE, ENTRADA).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacion.parallel().tween_property(self, "modulate:a", 1.0, 0.1)
	animacion.tween_interval(duracion - ENTRADA - SALIDA)
	animacion.tween_property(self, "position:x", -size.x - 20.0, SALIDA).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	animacion.tween_callback(queue_free)


## Sale rápido (algo urgente pidió la pantalla).
func ocultar() -> void:
	if animacion:
		animacion.kill()
	var salir := create_tween()
	salir.tween_property(self, "modulate:a", 0.0, 0.12)
	salir.tween_callback(queue_free)


## Un panel del kit (pergamino o cinta, del tema) en ese rectángulo.
static func panel(nombre: StringName, rect: Rect2) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", Estilo.caja(nombre))
	p.position = rect.position
	p.size = rect.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return p


## Etiqueta centrada (con contorno sobre la cinta; sin él, tinta sobre el pergamino), que nunca se sale de su caja (los
## nombres largos terminan en «…»).
static func etiqueta(texto: String, estilo: StringName, color: Color, pos: Vector2, ancho := ANCHO_PANTALLA, contorno := true) -> Label:
	var tamano := Estilo.letra(estilo)
	var e := Label.new()
	e.text = texto
	e.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	e.position = pos
	e.size = Vector2(ancho, tamano + 8)
	e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	e.add_theme_font_override("font", Estilo.fuente(estilo))
	e.add_theme_font_size_override("font_size", tamano)
	e.add_theme_color_override("font_color", color)
	if contorno:
		e.add_theme_color_override("font_outline_color", Estilo.color(&"cartel_contorno"))
		e.add_theme_constant_override("outline_size", Estilo.medida(&"contorno_cartel"))
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.clip_text = true
	e.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return e
