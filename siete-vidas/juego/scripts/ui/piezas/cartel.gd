class_name Cartel
extends Control
## Pieza de interfaz: un cartel de anuncio, con el kit «Decreto real» (la misma familia que la pausa). Dos formas:
## - franja: la cinta de terciopelo con el título grande y, colgando debajo, un pergamino con el nombre y la
##   recompensa (como la franja de un jefe, en chico);
## - tarjeta: un pergamino chico (cuando no hay hueco para la franja sin tapar el chiste).
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


## Arma el cartel en `rect`. `secreta` lo pinta de rosa en vez de dorado.
static func crear(titulo: String, nombre: String, recompensa: String, secreta: bool, rect: Rect2, chico: bool) -> Cartel:
	var caja := Cartel.new()
	caja.name = "Cartel"
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.size = rect.size
	caja.position = rect.position
	caja.pivot_offset = rect.size / 2.0
	var color := Estilo.color(&"cartel_secreto") if secreta else Estilo.color(&"cartel_dorado")
	var linea_recompensa := TranslationServer.translate("UI_RECOMPENSA") % recompensa.to_upper()
	var tinta := Estilo.color(&"tinta_decreto")
	if chico:
		caja.add_child(panel(&"panel", Rect2(Vector2.ZERO, rect.size)))
		caja.add_child(etiqueta(titulo, &"tarjeta_titulo", Estilo.color(&"lacre") if not secreta else color, Vector2(0, 3), rect.size.x, false))
		caja.add_child(etiqueta(nombre.to_upper(), &"tarjeta_texto", tinta, Vector2(8, 22), rect.size.x - 16, false))
		caja.add_child(etiqueta(linea_recompensa, &"tarjeta_texto", Estilo.color(&"tinta_decreto_suave"), Vector2(8, 34), rect.size.x - 16, false))
	else:
		var x_papel := roundf((ANCHO_PANTALLA - ANCHO_PAPEL) / 2.0)
		caja.add_child(panel(&"panel", Rect2(x_papel, 34, ANCHO_PAPEL, 60)))
		var x_cinta := roundf((ANCHO_PANTALLA - ANCHO_CINTA) / 2.0)
		caja.add_child(panel(&"cinta", Rect2(x_cinta, 0, ANCHO_CINTA, ALTO_CINTA)))
		caja.add_child(etiqueta(titulo, &"cartel_titulo", color, Vector2(x_cinta + 32, 5), ANCHO_CINTA - 64))
		caja.add_child(etiqueta(nombre.to_upper(), &"cartel_nombre", tinta, Vector2(x_papel + 10, 48), ANCHO_PAPEL - 20, false))
		caja.add_child(etiqueta(linea_recompensa, &"cartel_recompensa", Estilo.color(&"lacre"), Vector2(x_papel + 10, 68), ANCHO_PAPEL - 20, false))
	caja.scale = Vector2(1.6, 0.1) if not chico else Vector2(0.6, 0.6)
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


## Se corre a otro lugar (alguien entró a cuadro y el cartel lo tapaba).
func mover_a(rect: Rect2) -> void:
	create_tween().tween_property(self, "position:y", rect.position.y, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if rect.size.x < ANCHO_PANTALLA:
		position.x = rect.position.x


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
