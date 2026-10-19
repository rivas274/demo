class_name PresentacionJefe
extends Node2D
## Presentación de jefe reutilizable (estilo Broforce) y su interfaz durante la pelea. Sirve para cualquier jefe:
## la entrada sigue los 8 pasos de la guía (SKILL godot-felipe §6b) como DATOS (PASOS) y cada jefe solo da los suyos:
## nombre, título, colores, el texto de su rugido, y escucha `paso_empezado` y `empujon` para su propio efecto
## (A.S.P.I. cierra la puerta, cambia la luz de la base, crece en la imaginación de Felipe, levanta polvo...).
##   1 sin_vuelta_atras  portazo y sacudida              5 barra    la barra de vida se llena con sonido
##   2 espera            penumbra y retumbo que crece    6 musica   entra la música (señal)
##   3 revelar           «¡BATALLA INICIADA!», la cámara 7 tamano   cámara baja; cada empujón sacude
##                       sube de las ruedas a la cara    8 rugido   texto del rugido, ola de polvo; vuelve el control
##   4 nombre            nombre y título en una franja
## Con el juego congelado. Al reaparecer tras perder una vida, presentar_corta(): portazo y nombre (1 s).
## Después: carteles de fase con su pista de una línea, barra de vida con escudo, destellos y sacudidas.

signal paso_empezado(nombre: String)
## Cada empujón del paso "tamano" (el jefe avanza y la pantalla tiembla).
signal empujon(numero: int)
signal momento_empezado
signal terminada

## Los 8 pasos: [nombre, desde, hasta] en segundos (menos de 5 s: regla R16).
const PASOS := [
	["sin_vuelta_atras", 0.0, 0.4],
	["espera", 0.4, 1.2],
	["revelar", 1.2, 2.2],
	["nombre", 2.2, 2.8],
	["barra", 2.8, 3.4],
	["musica", 3.0, 3.4],
	["tamano", 3.4, 4.0],
	["rugido", 4.0, 4.8],
]
## Entrada corta al volver después de perder una vida (morir cuesta segundos, R5).
const PASOS_CORTOS := [["sin_vuelta_atras", 0.0, 0.3], ["nombre", 0.3, 1.0]]
## Dentro de "revelar": el golpe de cámara a Felipe con «¡BATALLA INICIADA!» dura esto; después sube por el jefe.
const GOLPE := 0.4
const EMPUJONES := [3.5, 3.75]
const ZOOM_FELIPE := 2.6
const ZOOM_JEFE := 3.0
const TEXTO_INICIO := "¡BATALLA INICIADA!"

## Datos del jefe.
var nombre := ""
var titulo := ""
var lema_felipe := "FELIPE · 8 kg de furia"
var texto_rugido := ""
var color_inicio := Color("c81e2a")
var color_nombre := Color("15101a")
## Alto del jefe (para la subida de la cámara de las ruedas a la cara).
var alto_jefe := 48.0
## Encuadre al final del momento del jefe (INF: sobre el jefe) y su zoom.
var encuadre_momento := Vector2.INF
var zoom_momento := 1.15
## El momento es imaginación de Felipe: se enmarca con una nube de pensamiento.
var imaginacion := true
## Pantallas del nivel: al terminar, el juego sigue solo si no se abrió la pausa.
var pantallas: Pantallas
## Los pasos que se están usando (PASOS o PASOS_CORTOS).
var pasos: Array = PASOS

## Estado que leen la pelea y las pruebas.
var presentando := false
var t := 0.0
var paso_actual := ""
## Progreso del momento del jefe (0 a 1), durante "revelar".
var momento := 0.0
var texto_en_pantalla := ""
var zoom_maximo := 1.0
## Penumbra del paso "espera" (0 a 1).
var penumbra := 0.0
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
var _pista := ""
var _avisados := {}
var _llenado := 0.0
var _ola := -1.0
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


## Empieza la entrada completa: congela el juego y toma la cámara. `limites` son los bordes para la cámara.
func presentar(felipe: Felipe, jefe: Node2D, limites: Rect2) -> void:
	_empezar(felipe, jefe, limites, PASOS)


## Entrada corta (portazo y nombre, 1 s): al volver a la pelea después de perder una vida.
func presentar_corta(felipe: Felipe, jefe: Node2D, limites: Rect2) -> void:
	_empezar(felipe, jefe, limites, PASOS_CORTOS)


func _empezar(felipe: Felipe, jefe: Node2D, limites: Rect2, lista: Array) -> void:
	_felipe = felipe
	_jefe = jefe
	pasos = lista
	presentando = true
	t = 0.0
	momento = 0.0
	penumbra = 0.0
	paso_actual = ""
	_avisados.clear()
	_llenado = 0.0
	_ola = -1.0
	_camara.limit_left = int(limites.position.x)
	_camara.limit_top = int(limites.position.y)
	_camara.limit_right = int(limites.end.x)
	_camara.limit_bottom = int(limites.end.y)
	_camara.global_position = _en_felipe()
	_camara.zoom = Vector2.ONE
	_camara.make_current()
	get_tree().paused = true


## Duración de la entrada en curso.
func duracion() -> float:
	var fin := 0.0
	for paso: Array in pasos:
		fin = maxf(fin, paso[2])
	return fin


## Termina la entrada de golpe (para pruebas y depuración).
func saltar() -> void:
	if presentando:
		_terminar()


## Cartel de fase con su pista de una línea debajo (R16).
func cartel(texto: String, segundos := 1.4, pista := "") -> void:
	_texto_cartel = texto
	_pista = pista
	_cartel = segundos


## La pista que se está mostrando bajo el cartel ("" si no hay).
func pista_actual() -> String:
	return _pista if _cartel > 0.0 else ""


func destello(fuerza := 0.5) -> void:
	_flash = maxf(_flash, fuerza)


func sacudir(segundos := 0.25) -> void:
	_sacudida = maxf(_sacudida, segundos)


func _process(delta: float) -> void:
	_flash = maxf(0.0, _flash - delta * 3.0)
	_sacudida = maxf(0.0, _sacudida - delta)
	_cartel = maxf(0.0, _cartel - delta)
	if _ola >= 0.0:
		_ola += delta
		if _ola > 1.2:
			_ola = -1.0
	if presentando:
		_avanzar(delta)
	_interfaz.queue_redraw()


## Rango [desde, hasta] del paso con ese nombre en la entrada actual (vacío si no está).
func _rango(paso: String) -> Array:
	for datos: Array in pasos:
		if datos[0] == paso:
			return [datos[1], datos[2]]
	return []


func _en(paso: String) -> bool:
	var r := _rango(paso)
	return not r.is_empty() and t >= r[0] and t < r[1]


func _avanzar(delta: float) -> void:
	t += delta
	for datos: Array in pasos:
		if t >= datos[1] and not _avisados.has(datos[0]):
			_avisados[datos[0]] = true
			paso_actual = datos[0]
			_al_empezar_paso(datos[0])
	for i in EMPUJONES.size():
		var clave := "empujon %d" % i
		if pasos == PASOS and t >= EMPUJONES[i] and not _avisados.has(clave):
			_avisados[clave] = true
			sacudir(0.2)
			empujon.emit(i + 1)
	if t >= duracion():
		_terminar()
		return
	var en_jefe := _jefe.global_position + Vector2(0, -alto_jefe * 0.5)
	texto_en_pantalla = ""
	if _en("sin_vuelta_atras"):
		_camara.global_position = _en_felipe()
		_camara.zoom = Vector2.ONE * lerpf(1.0, 1.3, (t - _rango("sin_vuelta_atras")[0]) / 0.4)
		_barras = minf(1.0, _barras + delta * 4.0)
	elif _en("espera"):
		var r := _rango("espera")
		var k: float = (t - r[0]) / (r[1] - r[0])
		penumbra = k
		_camara.global_position = _en_felipe().lerp(en_jefe, ease(k, 2.0) * 0.5)
		_camara.zoom = Vector2.ONE * lerpf(1.3, 1.5, k)
		_sacudida = maxf(_sacudida, 0.03 + 0.1 * k)
	elif _en("revelar"):
		var r := _rango("revelar")
		var dentro: float = t - r[0]
		if dentro < GOLPE:
			# Golpe de cámara a la cara de Felipe con «¡BATALLA INICIADA!».
			texto_en_pantalla = TEXTO_INICIO
			_camara.global_position = _en_felipe()
			_camara.zoom = Vector2.ONE * lerpf(1.5, ZOOM_FELIPE, ease(minf(dentro / 0.12, 1.0), 0.3))
		else:
			# Revelar despacio: la cámara empieza en las ruedas y sube hasta el sensor; crece la imaginación.
			var k: float = (dentro - GOLPE) / (r[1] - r[0] - GOLPE)
			if not _avisados.has("momento"):
				_avisados["momento"] = true
				momento_empezado.emit()
			momento = clampf(k, 0.0, 1.0)
			var ruedas := _jefe.global_position + Vector2(0, -4)
			var cara := _jefe.global_position + Vector2(0, -alto_jefe)
			var destino := cara if encuadre_momento == Vector2.INF else encuadre_momento
			_camara.global_position = ruedas.lerp(cara, ease(minf(k * 1.6, 1.0), 0.6)).lerp(destino, ease(maxf(0.0, k * 1.6 - 0.6), 1.0))
			_camara.zoom = Vector2.ONE * lerpf(ZOOM_JEFE, zoom_momento, ease(k, 0.5))
	elif _en("nombre"):
		texto_en_pantalla = nombre
		momento = 1.0 if pasos == PASOS else 0.0
		if pasos == PASOS_CORTOS:
			_camara.global_position = en_jefe
			_camara.zoom = Vector2.ONE * 1.3
	elif _en("barra") or _en("musica"):
		momento = 1.0
		var r := _rango("barra")
		_llenado = clampf((t - r[0]) / (r[1] - r[0]), 0.0, 1.0)
	elif _en("tamano"):
		momento = 1.0
		# Cámara baja: el jefe se ve enorme.
		_camara.global_position = _camara.global_position.lerp(en_jefe + Vector2(0, 26), 0.2)
		_camara.zoom = Vector2.ONE * lerpf(_camara.zoom.x, 1.4, 0.2)
	elif _en("rugido"):
		var r := _rango("rugido")
		var k: float = (t - r[0]) / (r[1] - r[0])
		texto_en_pantalla = texto_rugido
		penumbra = 1.0 - k
		_barras = 1.0 - k
		_camara.zoom = Vector2.ONE * lerpf(1.4, 1.0, ease(k, 0.5))
		_camara.global_position = _camara.global_position.lerp(_en_felipe(), k)
		_sacudida = maxf(_sacudida, 0.15)
	zoom_maximo = maxf(zoom_maximo, _camara.zoom.x)
	_camara.offset = Vector2(_azar.randf_range(-1, 1), _azar.randf_range(-1, 1)) * 6.0 * minf(_sacudida * 3.0, 1.0)


func _al_empezar_paso(paso: String) -> void:
	match paso:
		"sin_vuelta_atras":
			sacudir(0.3)
			destello(0.25)
		"revelar":
			sacudir(0.35)
			destello(0.6)
		"nombre":
			sacudir(0.4)
			destello(0.5)
		"rugido":
			_ola = 0.0
			sacudir(0.6)
	paso_empezado.emit(paso)


func _terminar() -> void:
	presentando = false
	texto_en_pantalla = ""
	paso_actual = ""
	penumbra = 0.0
	_barras = 0.0
	_camara.offset = Vector2.ZERO
	_felipe.get_node("Camara").make_current()
	if pantallas == null or pantallas.modo == Pantallas.Modo.JUGANDO:
		get_tree().paused = false
	terminada.emit()


func _en_felipe() -> Vector2:
	return _felipe.global_position + Vector2(0, -30)


## Penumbra, barras de cine, nube de pensamiento, franjas con textos, rugido, ola de polvo, carteles, barra de vida y
## destello (en pantalla).
func _dibujar() -> void:
	var c := _interfaz
	var tam := c.get_viewport_rect().size
	var fuente := ThemeDB.fallback_font
	if presentando and penumbra > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, tam), Color(0.05, 0.02, 0.08, 0.45 * penumbra))
	if _barras > 0.0:
		c.draw_rect(Rect2(0, 0, tam.x, 44.0 * _barras), Color.BLACK)
		c.draw_rect(Rect2(0, tam.y - 44.0 * _barras, tam.x, 44.0 * _barras), Color.BLACK)
	if presentando and imaginacion and momento > 0.0 and momento < 1.0:
		var tiempo := Time.get_ticks_msec() / 1000.0
		for i in 22:
			var angulo := i * TAU / 22.0
			var p := tam / 2.0 + Vector2(cos(angulo) * tam.x * 0.56, sin(angulo) * tam.y * 0.62)
			c.draw_circle(p, 38.0 + sin(tiempo * 6.0 + i) * 5.0, Color(Color("f5d0e6"), 0.55))
	if _ola >= 0.0:
		# Ola de polvo del rugido: cruza la pantalla de un lado al otro.
		var x := _ola / 1.2 * (tam.x + 200.0) - 100.0
		for i in 18:
			var y := tam.y - 40.0 - fmod(i * 37.0, 160.0)
			c.draw_circle(Vector2(x - fmod(i * 53.0, 120.0), y), 10.0 + fmod(i * 7.0, 12.0), Color(0.85, 0.8, 0.72, 0.35))
	if texto_en_pantalla == TEXTO_INICIO:
		var k := clampf((t - _rango("revelar")[0]) / 0.15, 0.0, 1.0)
		_banda(c, tam, tam.y * 0.5, color_inicio, -1.0)
		c.draw_set_transform(tam / 2.0 + Vector2(0, 10), -0.06, Vector2.ONE * lerpf(2.6, 1.0, k))
		_texto_con_sombra(c, fuente, TEXTO_INICIO, 30, Color("ffe066"), Color.BLACK, Vector2(2, 2))
		c.draw_set_transform(Vector2.ZERO)
		c.draw_string(fuente, Vector2(20, tam.y - 56), lema_felipe, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	elif presentando and texto_en_pantalla == nombre and nombre != "":
		var k := clampf((t - _rango("nombre")[0]) / 0.2, 0.0, 1.0)
		var desliza := (1.0 - ease(k, 0.3)) * tam.x
		_banda(c, tam, tam.y * 0.68, color_nombre, 1.0, desliza)
		c.draw_set_transform(Vector2(tam.x * 0.5 + desliza, tam.y * 0.68), 0.05)
		_texto_con_sombra(c, fuente, nombre, 40, Color("ffe066"), color_inicio, Vector2(3, 3), Vector2(0, 3))
		var sub := fuente.get_string_size(titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		c.draw_string(fuente, Vector2(-sub / 2.0, 24), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		c.draw_set_transform(Vector2.ZERO)
	elif presentando and texto_rugido != "" and texto_en_pantalla == texto_rugido:
		var temblor := Vector2(_azar.randf_range(-2, 2), _azar.randf_range(-2, 2)).round()
		c.draw_set_transform(Vector2(tam.x * 0.5, tam.y * 0.3) + temblor, -0.03)
		_texto_con_sombra(c, fuente, texto_rugido, 18, Color("ff6a5a"), Color.BLACK, Vector2(2, 2))
		c.draw_set_transform(Vector2.ZERO)
	if presentando and (_en("barra") or _en("musica") or _en("tamano") or _en("rugido")) and pasos == PASOS:
		_barra_de_vida(c, tam, fuente, _llenado if not (_en("tamano") or _en("rugido")) else 1.0, 0.0)
	if _cartel > 0.0 and _texto_cartel != "":
		var alfa := minf(_cartel * 2.0, 1.0)
		var ancho := fuente.get_string_size(_texto_cartel, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
		var y := tam.y * 0.38
		c.draw_rect(Rect2(0, y - 22, tam.x, 30 + (18 if _pista != "" else 0)), Color(0.08, 0.03, 0.05, 0.8 * alfa))
		c.draw_string(fuente, Vector2((tam.x - ancho) / 2.0, y), _texto_cartel, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(Color("ffe066"), alfa))
		if _pista != "":
			var texto := _etiquetar(_pista)
			var ancho_pista := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
			c.draw_string(fuente, Vector2((tam.x - ancho_pista) / 2.0, y + 18), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, alfa))
	if vida >= 0.0 and not presentando:
		_barra_de_vida(c, tam, fuente, vida, escudo)
	if _flash > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, tam), Color(1, 1, 1, minf(_flash, 1.0) * 0.8))


## Barra arriba a la derecha (lejos de los corazones y del HUD de la Agenda, a la izquierda).
func _barra_de_vida(c: Node2D, tam: Vector2, fuente: Font, valor: float, azul: float) -> void:
	var caja := Rect2(tam.x - 232, 22, 220, 9)
	c.draw_rect(Rect2(caja.position.x - 6, 4, caja.size.x + 12, 34), Color(0.1, 0.05, 0.07, 0.6))
	c.draw_string(fuente, Vector2(caja.position.x, 16), "%s — %s" % [nombre, titulo], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
	c.draw_rect(caja.grow(2), Color(0.1, 0.05, 0.07, 0.85))
	c.draw_rect(Rect2(caja.position, Vector2(caja.size.x * clampf(valor, 0.0, 1.0), caja.size.y)), color_inicio)
	for i in range(1, divisiones):
		var x := caja.position.x + caja.size.x * i / divisiones
		c.draw_line(Vector2(x, caja.position.y), Vector2(x, caja.end.y), Color(0, 0, 0, 0.6), 1.0)
	if azul > 0.0:
		c.draw_rect(Rect2(caja.position + Vector2(0, caja.size.y - 3), Vector2(caja.size.x * azul, 3)), Color("7fd0ff"))


## "{agacharse}" -> "[S]" (o el botón del mando) para la pista del cartel.
func _etiquetar(texto: String) -> String:
	for accion: String in IconosBotones.TEXTO:
		texto = texto.replace("{%s}" % accion, "[%s]" % IconosBotones.texto(accion))
	return texto


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
