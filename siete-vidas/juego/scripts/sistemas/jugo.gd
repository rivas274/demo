class_name Jugo
extends CanvasLayer
## Respuesta épica tipo Balatro y Broforce (pilar 5), sin puntaje: congelar un instante, palabras que saltan
## y rebotan ("¡GRAVEDAD: 1 · VASO: 0!"), sacudida de cámara y destello. Del prototipo de travesuras aprobado.
## No es la presentación de jefe: los jefes usan PresentacionJefe.

## Píxeles de la sacudida más fuerte.
@export var sacudida_maxima := 5.0

var camara: Camera2D
## Lo que las palabras no tapan (Felipe): si una cae encima, sube por sobre su cabeza (M1).
var evitar: Node2D
## La burbuja del Indicador (zona E): si una palabra coincide con ella, la palabra va más arriba.
var indicador: Indicador
## Quienes reaccionan (Valeria): una palabra no les tapa la cara. Cada uno da rect_dibujado() en el mundo.
var testigos: Array[Node2D] = []
## Caja en pantalla de la última palabra (para las pruebas de zonas).
var ultima_caja := Rect2()
var _palabra_actual: Control
## La animación de la palabra: va en tiempo real (la cámara lenta de una derrota no la estira).
var _tween_palabra: Tween
## Palabras que saltaron (para las pruebas).
var palabras: Array[String] = []

var _congelado := 0.0
var _sacudida := 0.0
var _fuerza_sacudida := 0.0
var _sacudiendo := false
## La sacudida actual es solo vertical (un golpe contra el piso).
var _vertical := false
## Temblor de pantalla estándar (v3.1, «la pantalla no tiembla»): amplitud en píxeles ENTEROS de la base 640 × 360
## que decae al cuadrado en `_temblor_dur` s. Va en el offset de la cámara del mundo (después del suavizado), nunca en
## el HUD. Con «Reducir sacudida» (Opciones) se divide por 3 (mínimo 1 px).
var _temblor_px := 0.0
var _temblor_dur := 0.0
var _temblor_t := 0.0
## Para las pruebas: el mayor desplazamiento de cámara (px) del último temblor.
var temblor_maximo := 0.0
var _flash: ColorRect


func _ready() -> void:
	layer = Capas.CAPA_JUGO
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.size = Vector2(640, 360)
	add_child(_flash)


## Congela el juego un instante (golpe con peso). Esta capa, el diálogo y la interfaz siguen.
func congelar(segundos: float) -> void:
	_congelado = maxf(_congelado, segundos)
	Engine.time_scale = 0.03


func congelado() -> bool:
	return _congelado > 0.0


func sacudir(segundos: float, fuerza := 1.0, vertical := false) -> void:
	temblar(roundi(sacudida_maxima * fuerza), segundos, vertical)


## Temblor de `px` píxeles enteros que decae en `segundos` (si ya hay uno más fuerte, gana el más fuerte).
func temblar(px: int, segundos: float, vertical := true) -> void:
	var amplitud := float(px)
	if Opciones.reducir_sacudida:
		amplitud = maxf(1.0, roundf(amplitud / 3.0))
	var queda := _temblor_px * pow(1.0 - clampf(_temblor_t / maxf(_temblor_dur, 0.001), 0.0, 1.0), 2.0)
	if amplitud < queda:
		return
	_temblor_px = amplitud
	_temblor_dur = maxf(segundos, 0.05)
	_temblor_t = 0.0
	_vertical = vertical
	temblor_maximo = 0.0
	_sacudida = _temblor_dur


func destello(fuerza := 0.5, color := Color.WHITE) -> void:
	_flash.color = Color(color, maxf(_flash.color.a, fuerza))


## Palabra que salta sobre un punto del mundo (se pasa a la pantalla con la cámara actual).
## `pegatina`: la palabra va sobre una etiqueta de pergamino del kit, en tinta (se lee sobre cualquier fondo).
func palabra_en_mundo(texto: String, posicion: Vector2, color := Color(1.0, 0.9, 0.3), tamano := 18, retraso := 0.0, pegatina := false) -> void:
	var en_pantalla := posicion
	var vista := get_viewport()
	if vista:
		en_pantalla = vista.get_canvas_transform() * posicion
	palabra(texto, en_pantalla, color, tamano, retraso, pegatina)


## Palabra que salta, rebota y se va (posición en pantalla). Zona D de ZonasTexto (plan de estabilización 2026-10-20):
## una sola a la vez (la nueva reemplaza a la que se veía), 0,9 s en total, Silkscreen de 16 o 24 px con contorno
## oscuro de 1 px, fuera del HUD, del diálogo y de los carteles, dentro de la pantalla, sin tapar a Felipe y más
## arriba que la burbuja del Indicador si coinciden.
func palabra(texto: String, posicion: Vector2, color := Color(1.0, 0.9, 0.3), tamano := 18, retraso := 0.0, pegatina := false) -> void:
	# Llega como clave (PALABRA_...) o texto suelto: se muestra traducido.
	texto = tr(texto)
	palabras.append(texto)
	if retraso > 0.0:
		get_tree().create_timer(retraso, true, false, true).timeout.connect(func() -> void: _saltar(texto, posicion, color, tamano, pegatina))
	else:
		_saltar(texto, posicion, color, tamano, pegatina)


func _saltar(texto: String, posicion: Vector2, color: Color, tamano: int, pegatina: bool) -> void:
	if is_instance_valid(_palabra_actual):
		_palabra_actual.queue_free()
	var etiqueta := Label.new()
	etiqueta.name = "Palabra"
	etiqueta.text = texto
	# Letra pixel de títulos (Silkscreen) a su tamaño de diseño: 16 px, o 24 px para las palabras grandes (B1).
	var estilo := &"palabra_grande" if tamano >= 20 else &"palabra"
	etiqueta.add_theme_font_override("font", Estilo.fuente(estilo))
	etiqueta.add_theme_font_size_override("font_size", Estilo.letra(estilo))
	etiqueta.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	etiqueta.add_theme_color_override("font_color", color)
	# Contorno oscuro de 1 px (outline_size 2 = 1 px a cada lado): se lee sobre cualquier pared, sin sombra borrosa.
	etiqueta.add_theme_color_override("font_outline_color", Estilo.color(&"contorno_palabra"))
	etiqueta.add_theme_constant_override("outline_size", 2)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Con pegatina, la palabra va dentro de un panel oscuro de la interfaz v2 (6 px de margen), en letra clara.
	var nodo: Control = etiqueta
	if pegatina:
		var panel := Panel.new()
		panel.add_theme_stylebox_override("panel", Estilo.caja(&"panel"))
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		etiqueta.add_theme_color_override("font_color", Estilo.color(&"ui_texto"))
		etiqueta.add_theme_constant_override("outline_size", 0)
		etiqueta.position = Vector2(6, 4)
		panel.add_child(etiqueta)
		nodo = panel
	nodo.name = "Palabra"
	add_child(nodo)
	_palabra_actual = nodo
	# Se mide ya en el árbol (con su letra): fuera del árbol la medida sale chica y la caja no la contiene.
	var medida := etiqueta.get_minimum_size()
	etiqueta.size = medida
	if pegatina:
		medida += Vector2(12, 8)
		nodo.size = medida
	nodo.pivot_offset = medida / 2.0
	var caja := ZonasTexto.colocar_palabra(Rect2(posicion - medida / 2.0, medida), _evitar_en_pantalla())
	nodo.position = caja.position
	ultima_caja = caja
	# Salta en escalones enteros (2× un instante y después 1×) y rebota unos px, sin girar: la letra pixel no se
	# deforma (B1 de la revisión de consistencia). Rebota hacia abajo para no subir a la zona C.
	var abajo := nodo.position.y
	# El golpe al doble solo si el doble también respeta las zonas (si no, entra a 1×).
	if ZonasTexto.palabra_valida(caja.grow_individual(medida.x / 2.0, medida.y / 2.0, medida.x / 2.0, medida.y / 2.0)):
		nodo.scale = Vector2.ONE * 2.0
	# El tween es de la palabra: si otra la reemplaza, se va con ella.
	var animar := nodo.create_tween()
	_tween_palabra = animar
	animar.tween_interval(0.05)
	animar.tween_callback(func() -> void: nodo.scale = Vector2.ONE)
	animar.tween_property(nodo, "position:y", abajo + 4.0, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animar.tween_property(nodo, "position:y", abajo, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	animar.tween_interval(ZonasTexto.DURACION_PALABRA - 0.6)
	animar.tween_property(nodo, "modulate:a", 0.0, 0.2)
	animar.tween_callback(nodo.queue_free)


## Lo que una palabra no tapa, en pantalla: Felipe y la burbuja del Indicador (zona E).
func _evitar_en_pantalla() -> Array[Rect2]:
	var zonas: Array[Rect2] = []
	var vista := get_viewport()
	if vista == null:
		return zonas
	var lienzo := vista.get_canvas_transform()
	if indicador and is_instance_valid(indicador):
		var burbuja: Rect2 = indicador.rect_burbuja()
		if burbuja.has_area():
			zonas.append(Rect2(lienzo * burbuja.position, burbuja.size * lienzo.get_scale()).grow(2.0))
	for testigo in testigos:
		if is_instance_valid(testigo) and testigo.is_visible_in_tree() and testigo.has_method("rect_dibujado"):
			var r: Rect2 = testigo.call("rect_dibujado")
			# Solo la parte de arriba (cabeza y manos): es donde está el chiste de su reacción.
			r.size.y = minf(r.size.y, 90.0)
			zonas.append(Rect2(lienzo * r.position, r.size * lienzo.get_scale()))
	if evitar and is_instance_valid(evitar) and evitar.is_inside_tree():
		var pies := lienzo * evitar.global_position
		zonas.append(Rect2(pies + Vector2(-38, -74), Vector2(76, 76)))
	return zonas


func _process(delta: float) -> void:
	# Tiempo real, sin la cámara lenta del congelado. Tope de 1/20 s: el cuadro en que empieza un congelado todavía
	# trae el delta sin escalar y, dividido por la escala nueva, se comía de golpe la sacudida (v3.1).
	var real := minf(delta / maxf(Engine.time_scale, 0.001), 0.05)
	if _tween_palabra and _tween_palabra.is_valid():
		_tween_palabra.set_speed_scale(1.0 / maxf(Engine.time_scale, 0.001))
	if _congelado > 0.0:
		_congelado -= real
		if _congelado <= 0.0:
			_congelado = 0.0
			Engine.time_scale = 1.0
	_flash.color.a = maxf(0.0, _flash.color.a - real * 3.5)
	if camara == null or not is_instance_valid(camara):
		return
	if _temblor_t < _temblor_dur and _temblor_px > 0.0:
		# Primero se dibuja la amplitud de este instante (el primer cuadro, entera) y después corre el reloj.
		var k := 1.0 - clampf(_temblor_t / _temblor_dur, 0.0, 1.0)
		_temblor_t += real
		_sacudiendo = true
		var amplitud := maxf(1.0, roundf(_temblor_px * k * k)) if k > 0.0 else 0.0
		# Arriba y abajo alternando (un golpe contra el piso); en el temblor libre, también algo de lado.
		var signo := 1.0 if Engine.get_process_frames() % 2 == 0 else -1.0
		# Vertical: solo toca el alto del offset (el adelanto de cámara de Zoomies, en x, se respeta).
		if _vertical:
			camara.offset.y = amplitud * signo
		else:
			camara.offset = Vector2(roundf(randf_range(-amplitud, amplitud)), amplitud * signo)
		temblor_maximo = maxf(temblor_maximo, absf(amplitud))
		if _temblor_t >= _temblor_dur:
			_temblor_px = 0.0
	elif _sacudiendo:
		# Solo se devuelve la cámara una vez, para no pelear con otras sacudidas (PresentacionJefe).
		_sacudiendo = false
		_fuerza_sacudida = 0.0
		if _vertical:
			camara.offset.y = 0.0
		else:
			camara.offset = Vector2.ZERO
		_vertical = false


func _exit_tree() -> void:
	if _congelado > 0.0:
		Engine.time_scale = 1.0
