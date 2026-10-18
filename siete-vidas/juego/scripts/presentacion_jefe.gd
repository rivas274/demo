class_name PresentacionJefe
extends Node2D
## Presentación de jefe reutilizable (estilo Broforce) y su interfaz durante la pelea. Sirve para cualquier jefe:
## cada pelea da el nombre, el título y los colores, llama a presentar() y, si quiere, usa `momento` (0 a 1)
## para su propio efecto (A.S.P.I. crece hasta volverse gigante).
## Entrada, con el juego congelado: acercamiento a Felipe, «¡BATALLA INICIADA!», barrido al jefe, momento del jefe
## (con nube de pensamiento si es imaginación de Felipe) y su nombre en una franja. Después: carteles de fase,
## barra de vida con escudo, destellos y sacudidas.

signal momento_empezado
signal terminada

## Línea de tiempo de la entrada, en segundos (menos de 5 s: regla R16).
const ACERCAMIENTO := 0.35
const CARTEL := 1.45
const GIRO := 1.75
const MOMENTO := 2.65
const NOMBRE := 4.0
const FIN := 4.5
const ZOOM_FELIPE := 2.6
const ZOOM_JEFE := 3.0
const TEXTO_INICIO := "¡BATALLA INICIADA!"

## Datos del jefe.
var nombre := ""
var titulo := ""
var lema_felipe := "FELIPE · 8 kg de furia"
var color_inicio := Color("c81e2a")
var color_nombre := Color("15101a")
## Encuadre al final del momento del jefe (INF: sobre el jefe) y su zoom.
var encuadre_momento := Vector2.INF
var zoom_momento := 1.15
## El momento es imaginación de Felipe: se enmarca con una nube de pensamiento.
var imaginacion := true
## Pantallas del nivel: al terminar, el juego sigue solo si no se abrió la pausa.
var pantallas: Pantallas

## Estado que leen la pelea y las pruebas.
var presentando := false
var t := 0.0
var momento := 0.0
var texto_en_pantalla := ""
var zoom_maximo := 1.0
## Barra de vida del jefe (0 a 1; negativa la oculta), escudo (0 a 1) y marcas entre golpes.
var vida := -1.0
var escudo := 0.0
var divisiones := 0

var _felipe: Felipe
var _jefe: Node2D
var _camara: Camera2D
var _interfaz: Node2D
var _flash := 0.0
var _sacudida := 0.0
var _barras := 0.0
var _cartel := 0.0
var _texto_cartel := ""
var _momento_avisado := false
var _azar := RandomNumberGenerator.new()


func _init(nombre_jefe: String, titulo_jefe: String) -> void:
	nombre = nombre_jefe
	titulo = titulo_jefe
	name = "Presentacion de %s" % nombre_jefe
	process_mode = Node.PROCESS_MODE_ALWAYS
	_azar.seed = 7


func _ready() -> void:
	_camara = Camera2D.new()
	_camara.name = "Camara del jefe"
	add_child(_camara)
	var capa := CanvasLayer.new()
	capa.layer = 30
	add_child(capa)
	_interfaz = Node2D.new()
	_interfaz.name = "Interfaz del jefe"
	_interfaz.draw.connect(_dibujar)
	capa.add_child(_interfaz)


## Empieza la entrada: congela el juego y toma la cámara. `limites` son los bordes del nivel para la cámara.
func presentar(felipe: Felipe, jefe: Node2D, limites: Rect2) -> void:
	_felipe = felipe
	_jefe = jefe
	presentando = true
	t = 0.0
	momento = 0.0
	_momento_avisado = false
	_camara.limit_left = int(limites.position.x)
	_camara.limit_top = int(limites.position.y)
	_camara.limit_right = int(limites.end.x)
	_camara.limit_bottom = int(limites.end.y)
	_camara.global_position = _en_felipe()
	_camara.zoom = Vector2.ONE
	_camara.make_current()
	_flash = 1.0
	get_tree().paused = true


## Termina la entrada de golpe (para pruebas y depuración).
func saltar() -> void:
	if presentando:
		_terminar()


func cartel(texto: String, segundos := 1.4) -> void:
	_texto_cartel = texto
	_cartel = segundos


func destello(fuerza := 0.5) -> void:
	_flash = maxf(_flash, fuerza)


func sacudir(segundos := 0.25) -> void:
	_sacudida = maxf(_sacudida, segundos)


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta * 3.0)
	_sacudida = maxf(0.0, _sacudida - delta)
	_cartel = maxf(0.0, _cartel - delta)
	if presentando:
		_avanzar(delta)
	_interfaz.queue_redraw()


func _avanzar(delta: float) -> void:
	t += delta
	var en_jefe := _jefe.global_position + Vector2(0, -20)
	texto_en_pantalla = ""
	if t < ACERCAMIENTO:
		# Golpe de cámara a la cara de Felipe.
		var k := ease(t / ACERCAMIENTO, 0.3)
		_camara.zoom = Vector2.ONE * lerpf(1.0, ZOOM_FELIPE, k)
		_camara.global_position = _en_felipe()
		_barras = k
		_sacudida = 0.2
	elif t < CARTEL:
		texto_en_pantalla = TEXTO_INICIO
		_camara.zoom = Vector2.ONE * ZOOM_FELIPE
		_barras = 1.0
		if t - delta < ACERCAMIENTO:
			sacudir(0.35)
			destello(0.6)
	elif t < GIRO:
		# Barrido rápido hasta el jefe.
		var k := ease((t - CARTEL) / (GIRO - CARTEL), -2.0)
		_camara.global_position = _en_felipe().lerp(en_jefe, k)
		_camara.zoom = Vector2.ONE * lerpf(ZOOM_FELIPE, ZOOM_JEFE, k)
	elif t < MOMENTO:
		# El momento propio del jefe; la cámara se abre hacia su encuadre.
		if not _momento_avisado:
			_momento_avisado = true
			momento_empezado.emit()
		momento = (t - GIRO) / (MOMENTO - GIRO)
		var destino := en_jefe if encuadre_momento == Vector2.INF else encuadre_momento
		_camara.zoom = Vector2.ONE * lerpf(ZOOM_JEFE, zoom_momento, ease(momento, 0.5))
		_camara.global_position = en_jefe.lerp(destino, ease(momento, 0.5))
		_sacudida = 0.1
	elif t < NOMBRE:
		texto_en_pantalla = nombre
		momento = 1.0
		if t - delta < MOMENTO:
			sacudir(0.4)
			destello(0.5)
	elif t < FIN:
		var k := (t - NOMBRE) / (FIN - NOMBRE)
		_barras = 1.0 - k
		_camara.zoom = Vector2.ONE * lerpf(zoom_momento, 1.0, k)
		_camara.global_position = _camara.global_position.lerp(_en_felipe(), k)
	else:
		_terminar()
		return
	zoom_maximo = maxf(zoom_maximo, _camara.zoom.x)
	_camara.offset = Vector2(_azar.randf_range(-1, 1), _azar.randf_range(-1, 1)) * 6.0 * minf(_sacudida * 3.0, 1.0)


func _terminar() -> void:
	presentando = false
	texto_en_pantalla = ""
	momento = 1.0
	_barras = 0.0
	_camara.offset = Vector2.ZERO
	_felipe.get_node("Camara").make_current()
	if pantallas == null or pantallas.modo == Pantallas.Modo.JUGANDO:
		get_tree().paused = false
	terminada.emit()


func _en_felipe() -> Vector2:
	return _felipe.global_position + Vector2(0, -30)


## Barras de cine, nube de pensamiento, franjas con textos, carteles, barra de vida y destello (en pantalla).
func _dibujar() -> void:
	var c := _interfaz
	var tam := c.get_viewport_rect().size
	var fuente := ThemeDB.fallback_font
	if _barras > 0.0:
		c.draw_rect(Rect2(0, 0, tam.x, 44.0 * _barras), Color.BLACK)
		c.draw_rect(Rect2(0, tam.y - 44.0 * _barras, tam.x, 44.0 * _barras), Color.BLACK)
	if presentando and imaginacion and t >= GIRO and t < MOMENTO:
		var tiempo := Time.get_ticks_msec() / 1000.0
		for i in 22:
			var angulo := i * TAU / 22.0
			var p := tam / 2.0 + Vector2(cos(angulo) * tam.x * 0.56, sin(angulo) * tam.y * 0.62)
			c.draw_circle(p, 38.0 + sin(tiempo * 6.0 + i) * 5.0, Color(Color("f5d0e6"), 0.55))
	if texto_en_pantalla == TEXTO_INICIO:
		var k := clampf((t - ACERCAMIENTO) / 0.15, 0.0, 1.0)
		_banda(c, tam, tam.y * 0.5, color_inicio, -1.0)
		c.draw_set_transform(tam / 2.0 + Vector2(0, 10), -0.06, Vector2.ONE * lerpf(2.6, 1.0, k))
		_texto_con_sombra(c, fuente, TEXTO_INICIO, 30, Color("ffe066"), Color.BLACK, Vector2(2, 2))
		c.draw_set_transform(Vector2.ZERO)
		c.draw_string(fuente, Vector2(20, tam.y - 56), lema_felipe, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	elif presentando and texto_en_pantalla == nombre and nombre != "":
		var k := clampf((t - MOMENTO) / 0.2, 0.0, 1.0)
		var desliza := (1.0 - ease(k, 0.3)) * tam.x
		_banda(c, tam, tam.y * 0.68, color_nombre, 1.0, desliza)
		c.draw_set_transform(Vector2(tam.x * 0.5 + desliza, tam.y * 0.68), 0.05)
		_texto_con_sombra(c, fuente, nombre, 40, Color("ffe066"), color_inicio, Vector2(3, 3), Vector2(0, 3))
		var sub := fuente.get_string_size(titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		c.draw_string(fuente, Vector2(-sub / 2.0, 24), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO)
	if _cartel > 0.0 and _texto_cartel != "":
		var alfa := minf(_cartel * 2.0, 1.0)
		var ancho := fuente.get_string_size(_texto_cartel, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var y := tam.y * 0.38
		c.draw_rect(Rect2(0, y - 22, tam.x, 30), Color(0.08, 0.03, 0.05, 0.8 * alfa))
		c.draw_string(fuente, Vector2((tam.x - ancho) / 2.0, y), _texto_cartel, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(Color("ffe066"), alfa))
	if vida >= 0.0 and not presentando:
		# Arriba a la derecha, lejos de los corazones y la báscula.
		var caja := Rect2(tam.x - 232, 22, 220, 9)
		c.draw_rect(Rect2(caja.position.x - 6, 4, caja.size.x + 12, 34), Color(0.1, 0.05, 0.07, 0.6))
		c.draw_string(fuente, Vector2(caja.position.x, 16), "%s — %s" % [nombre, titulo], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
		c.draw_rect(caja.grow(2), Color(0.1, 0.05, 0.07, 0.85))
		c.draw_rect(Rect2(caja.position, Vector2(caja.size.x * clampf(vida, 0.0, 1.0), caja.size.y)), color_inicio)
		for i in range(1, divisiones):
			var x := caja.position.x + caja.size.x * i / divisiones
			c.draw_line(Vector2(x, caja.position.y), Vector2(x, caja.end.y), Color(0, 0, 0, 0.6), 1.0)
		if escudo > 0.0:
			c.draw_rect(Rect2(caja.position + Vector2(0, caja.size.y - 3), Vector2(caja.size.x * escudo, 3)), Color("7fd0ff"))
	if _flash > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, tam), Color(1, 1, 1, minf(_flash, 1.0) * 0.8))


func _texto_con_sombra(c: Node2D, fuente: Font, texto: String, tamano: int, color: Color, sombra: Color, desfase: Vector2, base := Vector2.ZERO) -> void:
	var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x
	c.draw_string(fuente, base + Vector2(-ancho / 2.0, 0) + desfase, texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, sombra)
	c.draw_string(fuente, base + Vector2(-ancho / 2.0, 0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


## Franja inclinada que cruza la pantalla.
func _banda(c: Node2D, tam: Vector2, y: float, color: Color, inclinacion: float, desliza := 0.0) -> void:
	var alto := 56.0
	var caida := 14.0 * inclinacion
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(desliza - 20, y - alto / 2.0 + caida), Vector2(tam.x + desliza + 20, y - alto / 2.0 - caida),
		Vector2(tam.x + desliza + 20, y + alto / 2.0 - caida), Vector2(desliza - 20, y + alto / 2.0 + caida),
	]), color)
