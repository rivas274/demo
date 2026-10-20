class_name Cartel
extends Control
## Pieza de interfaz: un cartel de anuncio. Dos formas:
## - franja: banda inclinada de todo el ancho con título grande, nombre y recompensa (como la franja de un jefe);
## - tarjeta: cuadro chico con borde (cuando no hay hueco para la franja sin tapar el chiste).
## Entra con un golpe de escala, se queda `duracion` s y sale deslizándose a la izquierda. No sabe de colas ni de
## travesuras: quien lo crea (Hud, a través de Anuncios) decide cuándo y dónde. Colores y letras salen del tema.

const ANCHO_PANTALLA := 640.0
const ENTRADA := 0.18
const SALIDA := 0.25

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
	if chico:
		var fondo := Panel.new()
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Estilo.color(&"cartel_tarjeta")
		estilo.border_color = color
		estilo.set_border_width_all(Estilo.medida(&"borde_panel"))
		estilo.set_corner_radius_all(Estilo.medida(&"radio_panel"))
		fondo.add_theme_stylebox_override("panel", estilo)
		fondo.size = rect.size
		fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caja.add_child(fondo)
		caja.add_child(etiqueta(titulo, &"tarjeta_titulo", color, Vector2(0, 2), rect.size.x))
		caja.add_child(etiqueta(nombre.to_upper(), &"tarjeta_texto", Estilo.color(&"cartel_nombre"), Vector2(6, 22), rect.size.x - 12))
		caja.add_child(etiqueta(linea_recompensa, &"tarjeta_texto", Estilo.color(&"cartel_recompensa_chica"), Vector2(6, 35), rect.size.x - 12))
	else:
		var franja := Polygon2D.new()
		franja.polygon = PackedVector2Array([Vector2(0, 12), Vector2(ANCHO_PANTALLA, 0), Vector2(ANCHO_PANTALLA, 84), Vector2(0, 96)])
		franja.color = Estilo.color(&"cartel_fondo")
		caja.add_child(franja)
		for puntos: PackedVector2Array in [PackedVector2Array([Vector2(0, 12), Vector2(ANCHO_PANTALLA, 0)]), PackedVector2Array([Vector2(0, 96), Vector2(ANCHO_PANTALLA, 84)])]:
			var borde := Line2D.new()
			borde.points = puntos
			borde.width = 3.0
			borde.default_color = color
			caja.add_child(borde)
		caja.add_child(etiqueta(titulo, &"cartel_titulo", color, Vector2(0, 12)))
		caja.add_child(etiqueta(nombre.to_upper(), &"cartel_nombre", Estilo.color(&"cartel_nombre"), Vector2(0, 45)))
		caja.add_child(etiqueta(linea_recompensa, &"cartel_recompensa", Estilo.color(&"cartel_recompensa"), Vector2(0, 67)))
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


## Etiqueta centrada con contorno, que nunca se sale de su caja (los nombres largos terminan en «…»).
static func etiqueta(texto: String, estilo: StringName, color: Color, pos: Vector2, ancho := ANCHO_PANTALLA) -> Label:
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
	e.add_theme_color_override("font_outline_color", Estilo.color(&"cartel_contorno"))
	e.add_theme_constant_override("outline_size", Estilo.medida(&"contorno_cartel"))
	e.mouse_filter = Control.MOUSE_FILTER_IGNORE
	e.clip_text = true
	e.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return e
