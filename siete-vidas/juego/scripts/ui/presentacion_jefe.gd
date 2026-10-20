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
## Mientras presenta, todo lo del grupo GRUPO_OCULTAR (el diálogo, el Indicador) se esconde: avisa con
## al_presentar_jefe(true) al empezar y al_presentar_jefe(false) al terminar (M4). La frase del jefe o de Felipe en
## "sin vuelta atrás" la muestra la presentación como subtítulo (frase_sin_vuelta), no el diálogo.
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
## Zooms siempre enteros (B3 de la revisión de consistencia): con 1,3 o 2,6 los pixeles quedaban de tamaños mezclados.
## Entre pasos el zoom cambia con corte seco (estilo Broforce); el encuadre se hace moviendo la cámara.
const ZOOM_FELIPE := 3
const ZOOM_JEFE := 2
const TEXTO_INICIO := "JEFE_BATALLA_INICIADA"
## Lo que se esconde durante la presentación (cada nodo implementa al_presentar_jefe(presentando: bool)).
const GRUPO_OCULTAR := "ocultar_en_presentacion"
const ESCENA_BARRA := "res://escenas/ui/barra_jefe.tscn"
## Barra del jefe arriba a la derecha, lejos de los corazones y del HUD de la Agenda.
const POS_BARRA := Vector2(436, 1)

## Datos del jefe.
var nombre := ""
var titulo := ""
var lema_felipe := "JEFE_LEMA_FELIPE"
## Subtítulo de los pasos 1 y 2 ("…¿Quién cerró?"): [quién, frase]. Vacío = sin subtítulo.
var frase_sin_vuelta: Array = []
## Subtítulo que se está mostrando (para las pruebas; "" si no hay).
var subtitulo_en_pantalla := ""
var texto_rugido := ""
var color_inicio := Estilo.color(&"jefe_rojo")
var color_nombre := Estilo.color(&"jefe_banda")
## Alto del jefe (para la subida de la cámara de las ruedas a la cara).
var alto_jefe := 48.0
## Encuadre al final del momento del jefe (INF: sobre el jefe) y su zoom.
var encuadre_momento := Vector2.INF
var zoom_momento := 1
## El momento es imaginación de Felipe: se enmarca con una nube de pensamiento.
var imaginacion := true
## Pantallas del nivel: al terminar, el juego sigue solo si no se abrió la pausa.
var pantallas: Pantallas
## La cola única de anuncios del nivel (G5): las franjas de fase pasan adelante pero nunca se montan sobre otro aviso.
var anuncios: Anuncios
## Dónde va la franja de fase (y en pantalla), elegida por la cola al mostrarla.
var _y_cartel := -1.0
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
## Zooms que usó la entrada (para las pruebas: todos enteros).
var zooms_usados := {}
## Penumbra del paso "espera" (0 a 1).
var penumbra := 0.0
## Barra de vida del jefe (0 a 1; negativa la oculta), escudo (0 a 1) y marcas entre golpes.
## La barra del jefe (pieza BarraVida conectada a la Vida del jefe con conectar_vida). Se ve durante la pelea
## (mostrar_barra, lo pone la pelea) y, llenándose, en la entrada.
var barra: BarraVida
var mostrar_barra := false
## Lo que muestra la barra (0 a 1), o -1 si no se ve.
var vida: float:
	get:
		return barra.fraccion if barra and mostrar_barra and not presentando else -1.0
## Franja azul bajo la barra (A.S.P.I.: el depósito).
var escudo: float:
	get:
		return barra.escudo if barra else 0.0
	set(valor):
		if barra:
			barra.escudo = valor

var _felipe: Felipe
var _jefe: Node2D
var _camara: Camera2D
var _interfaz: Node2D
var _flash := 0.0
var _destello: Node2D
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
	capa.layer = Capas.CAPA_JEFE
	add_child(capa)
	_interfaz = Node2D.new()
	_interfaz.name = "Interfaz del jefe"
	_interfaz.draw.connect(_dibujar)
	capa.add_child(_interfaz)
	barra = (load(ESCENA_BARRA) as PackedScene).instantiate()
	barra.titulo = "%s — %s" % [nombre, titulo]
	barra.titulo_corto = nombre
	barra.position = POS_BARRA
	barra.visible = false
	capa.add_child(barra)
	# El destello va encima de todo, también de la barra.
	_destello = Node2D.new()
	_destello.name = "Destello"
	_destello.draw.connect(_dibujar_destello)
	capa.add_child(_destello)


## La barra muestra esta Vida (la del jefe): se mueve sola con sus señales.
func conectar_vida(vida_jefe: Vida) -> void:
	barra.conectar(vida_jefe)


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
	get_tree().call_group(GRUPO_OCULTAR, "al_presentar_jefe", true)


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
	texto = tr(texto)
	pista = tr(pista) if pista != "" else ""
	if anuncios:
		anuncios.anunciar("fase", texto, Vector2(640, _alto_cartel(pista)), func(rect: Rect2) -> float:
			_mostrar_cartel(texto, segundos, pista, rect.position.y)
			return segundos, func() -> void: _cartel = 0.0, true)
		return
	_mostrar_cartel(texto, segundos, pista, ZonasTexto.CARTELES.position.y)


## Alto de la franja de fase: el título (Silkscreen 24) y, si hay, la pista de una línea. Cabe en la zona C.
func _alto_cartel(pista: String) -> float:
	return 32.0 + (20.0 if pista != "" else 0.0)


func _mostrar_cartel(texto: String, segundos: float, pista: String, y: float) -> void:
	_texto_cartel = texto
	_pista = pista
	_cartel = segundos
	_y_cartel = y


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
	_actualizar_barra()
	_interfaz.queue_redraw()
	_destello.queue_redraw()


## En la entrada la barra se llena (pasos barra, música, tamaño y rugido); en la pelea muestra la Vida del jefe.
func _actualizar_barra() -> void:
	var en_entrada := presentando and (_en("barra") or _en("musica") or _en("tamano") or _en("rugido")) and pasos == PASOS
	barra.visible = en_entrada or (mostrar_barra and not presentando)
	var forzada := -1.0
	if en_entrada:
		forzada = _llenado if not (_en("tamano") or _en("rugido")) else 1.0
	if barra.forzada != forzada:
		barra.forzada = forzada


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
	subtitulo_en_pantalla = ""
	if frase_sin_vuelta.size() >= 2 and (_en("sin_vuelta_atras") or _en("espera")) and pasos == PASOS:
		subtitulo_en_pantalla = tr(String(frase_sin_vuelta[1]))
	if _en("sin_vuelta_atras"):
		_camara.global_position = _en_felipe()
		_poner_zoom(1)
		_barras = minf(1.0, _barras + delta * 4.0)
	elif _en("espera"):
		var r := _rango("espera")
		var k: float = (t - r[0]) / (r[1] - r[0])
		penumbra = k
		_camara.global_position = _en_felipe().lerp(en_jefe, ease(k, 2.0) * 0.5)
		_poner_zoom(2)
		_sacudida = maxf(_sacudida, 0.03 + 0.1 * k)
	elif _en("revelar"):
		var r := _rango("revelar")
		var dentro: float = t - r[0]
		if dentro < GOLPE:
			# Golpe de cámara a la cara de Felipe con «¡BATALLA INICIADA!».
			texto_en_pantalla = TEXTO_INICIO
			_camara.global_position = _en_felipe()
			_poner_zoom(ZOOM_FELIPE)
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
			_poner_zoom(ZOOM_JEFE if k < 0.5 else zoom_momento)
	elif _en("nombre"):
		texto_en_pantalla = nombre
		momento = 1.0 if pasos == PASOS else 0.0
		if pasos == PASOS_CORTOS:
			_camara.global_position = en_jefe
			_poner_zoom(1)
	elif _en("barra") or _en("musica"):
		momento = 1.0
		var r := _rango("barra")
		_llenado = clampf((t - r[0]) / (r[1] - r[0]), 0.0, 1.0)
	elif _en("tamano"):
		momento = 1.0
		# Cámara baja: el jefe se ve enorme.
		_camara.global_position = _camara.global_position.lerp(en_jefe + Vector2(0, 26), 0.2)
		_poner_zoom(2)
	elif _en("rugido"):
		var r := _rango("rugido")
		var k: float = (t - r[0]) / (r[1] - r[0])
		texto_en_pantalla = texto_rugido
		penumbra = 1.0 - k
		_barras = 1.0 - k
		_poner_zoom(1)
		_camara.global_position = _camara.global_position.lerp(_en_felipe(), k)
		_sacudida = maxf(_sacudida, 0.15)
	zoom_maximo = maxf(zoom_maximo, _camara.zoom.x)
	_camara.global_position = _camara.global_position.round()
	_camara.offset = (Vector2(_azar.randf_range(-1, 1), _azar.randf_range(-1, 1)) * 6.0 * minf(_sacudida * 3.0, 1.0)).round()


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
	subtitulo_en_pantalla = ""
	_felipe.get_node("Camara").make_current()
	get_tree().call_group(GRUPO_OCULTAR, "al_presentar_jefe", false)
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
	if presentando and penumbra > 0.0:
		c.draw_rect(Rect2(Vector2.ZERO, tam), Estilo.color(&"jefe_penumbra", 0.45 * penumbra))
	if _barras > 0.0:
		c.draw_rect(Rect2(0, 0, tam.x, 44.0 * _barras), Estilo.color(&"negro"))
		c.draw_rect(Rect2(0, tam.y - 44.0 * _barras, tam.x, 44.0 * _barras), Estilo.color(&"negro"))
	if presentando and imaginacion and momento > 0.0 and momento < 1.0:
		_vineta(c, tam, minf(momento * 4.0, 1.0) * minf((1.0 - momento) * 4.0, 1.0))
	if subtitulo_en_pantalla != "":
		var quien := String(frase_sin_vuelta[0]).to_upper()
		var linea := "%s: %s" % [quien, subtitulo_en_pantalla]
		var pos := Vector2((tam.x - Estilo.ancho(linea, &"jefe_subtitulo")) / 2.0, tam.y - 14.0)
		Estilo.escribir(c, pos + Vector2(1, 1), linea, &"jefe_subtitulo", Estilo.color(&"negro"))
		Estilo.escribir(c, pos, linea, &"jefe_subtitulo", Estilo.color(&"jefe_subtitulo"))
	if _ola >= 0.0:
		# Ola de polvo del rugido: cruza la pantalla de un lado al otro.
		var x := _ola / 1.2 * (tam.x + 200.0) - 100.0
		for i in 18:
			var y := tam.y - 40.0 - fmod(i * 37.0, 160.0)
			# Granos de pixel en escalones (cuadrados de 4 a 8 px), no círculos difusos (G5, lección 26).
			var lado := 4.0 + 2.0 * float(i % 3)
			c.draw_rect(Rect2(Vector2(x - fmod(i * 53.0, 120.0), y).round(), Vector2(lado, lado)), Estilo.color(&"jefe_polvo"))
	if texto_en_pantalla == TEXTO_INICIO:
		var k := clampf((t - _rango("revelar")[0]) / 0.15, 0.0, 1.0)
		_banda(c, tam, tam.y * 0.5, color_inicio, -1.0)
		# El golpe de entrada va en escalones enteros (3×, 2×, 1×) y sin girar: la letra pixel no se deforma (B1, B3).
		var escala := 3.0 if k < 0.34 else (2.0 if k < 0.67 else 1.0)
		c.draw_set_transform((tam / 2.0 + Vector2(0, 10)).round(), 0.0, Vector2.ONE * escala)
		_texto_con_sombra(c, tr(TEXTO_INICIO), &"jefe_inicio", Estilo.color(&"jefe_amarillo"), Estilo.color(&"negro"), Vector2(2, 2))
		c.draw_set_transform(Vector2.ZERO)
		Estilo.escribir(c, Vector2(20, tam.y - 56), tr(lema_felipe), &"jefe_lema", Estilo.color(&"blanco"))
	elif presentando and texto_en_pantalla == nombre and nombre != "":
		var k := clampf((t - _rango("nombre")[0]) / 0.2, 0.0, 1.0)
		var desliza := (1.0 - ease(k, 0.3)) * tam.x
		_banda(c, tam, tam.y * 0.68, color_nombre, 1.0, desliza)
		c.draw_set_transform(Vector2(tam.x * 0.5 + desliza, tam.y * 0.68).round())
		_texto_con_sombra(c, nombre, &"jefe_nombre", Estilo.color(&"jefe_amarillo"), color_inicio, Vector2(3, 3), Vector2(0, 8))
		Estilo.escribir(c, Vector2(-roundf(Estilo.ancho(titulo, &"jefe_titulo") / 2.0), 26), titulo, &"jefe_titulo", Estilo.color(&"blanco"))
		c.draw_set_transform(Vector2.ZERO)
	elif presentando and texto_rugido != "" and texto_en_pantalla == texto_rugido:
		var temblor := Vector2(_azar.randf_range(-2, 2), _azar.randf_range(-2, 2)).round()
		c.draw_set_transform((Vector2(tam.x * 0.5, tam.y * 0.3) + temblor).round())
		# Caja oscura detrás: el rojo no se pierde en el fondo en llamas (M1).
		var ancho_rugido := roundf(Estilo.ancho(texto_rugido, &"jefe_rugido"))
		# Cartela de alerta (crítica de Gemini): fondo semitransparente con marco rojo de 1 px y esquinas marcadas,
		# para que el texto no compita con el contorno del jefe.
		var cartela := Rect2(-ancho_rugido / 2.0 - 12, -20, ancho_rugido + 24, 28)
		c.draw_rect(cartela.grow(2), Estilo.color(&"jefe_cartela_sombra"))
		c.draw_rect(cartela, Estilo.color(&"jefe_cartela"))
		c.draw_rect(cartela.grow(-2), Estilo.color(&"jefe_alerta"), false, 1.0)
		for esquina: Vector2 in [cartela.position, Vector2(cartela.end.x - 5, cartela.position.y), Vector2(cartela.position.x, cartela.end.y - 5), cartela.end - Vector2(5, 5)]:
			c.draw_rect(Rect2(esquina, Vector2(5, 5)), Estilo.color(&"jefe_alerta"))
		_texto_con_sombra(c, texto_rugido, &"jefe_rugido", Estilo.color(&"jefe_rugido"), Estilo.color(&"negro"), Vector2(1, 1))
		c.draw_set_transform(Vector2.ZERO)
	if _cartel > 0.0 and _texto_cartel != "":
		var alfa := minf(_cartel * 2.0, 1.0)
		var ancho := Estilo.ancho(_texto_cartel, &"jefe_cartel")
		# La franja de fase va en la zona C (ZonasTexto: y 30–90), nunca sobre el HUD ni la barra del jefe (M4).
		var arriba := maxf(_y_cartel, ZonasTexto.CARTELES.position.y)
		var y := arriba + 24.0
		c.draw_rect(Rect2(0, arriba, tam.x, _alto_cartel(_pista)), Estilo.color(&"jefe_cartel_fondo", 0.8 * alfa))
		Estilo.escribir(c, Vector2((tam.x - ancho) / 2.0, y), _texto_cartel, &"jefe_cartel", Estilo.color(&"jefe_amarillo", alfa))
		if _pista != "":
			var texto := _etiquetar(_pista)
			var ancho_pista := Estilo.ancho(texto, &"jefe_pista")
			Estilo.escribir(c, Vector2((tam.x - ancho_pista) / 2.0, y + 20), texto, &"jefe_pista", Estilo.color(&"blanco", alfa))


func _dibujar_destello() -> void:
	if _flash > 0.0:
		_destello.draw_rect(Rect2(Vector2.ZERO, _destello.get_viewport_rect().size), Estilo.color(&"destello", minf(_flash, 1.0) * 0.8))


## Viñeta oscura con polvo (el "momento" es imaginación de Felipe): bordes que se oscurecen hacia afuera y motas
## que flotan, en vez de discos planos (M4).
func _vineta(c: Node2D, tam: Vector2, fuerza: float) -> void:
	if fuerza <= 0.0:
		return
	var bandas := 10
	var ancho_banda := 7.0
	for i in bandas:
		var alfa := 0.6 * fuerza * (1.0 - float(i) / bandas)
		var color := Estilo.color(&"jefe_vineta", alfa)
		var d := i * ancho_banda
		c.draw_rect(Rect2(d, d, tam.x - d * 2.0, ancho_banda), color)
		c.draw_rect(Rect2(d, tam.y - d - ancho_banda, tam.x - d * 2.0, ancho_banda), color)
		c.draw_rect(Rect2(d, d + ancho_banda, ancho_banda, tam.y - d * 2.0 - ancho_banda * 2.0), color)
		c.draw_rect(Rect2(tam.x - d - ancho_banda, d + ancho_banda, ancho_banda, tam.y - d * 2.0 - ancho_banda * 2.0), color)
	var tiempo := Time.get_ticks_msec() / 1000.0
	for i in 26:
		var borde := fmod(i * 0.37, 1.0)
		var p := Vector2(fmod(i * 97.0 + tiempo * 18.0, tam.x), fmod(i * 53.0 - tiempo * 9.0, tam.y))
		var al_centro := (p - tam / 2.0) / (tam / 2.0)
		if maxf(absf(al_centro.x), absf(al_centro.y)) < 0.7:
			continue
		c.draw_rect(Rect2(p.round(), Vector2(2, 2)), Estilo.color(&"jefe_mota", 0.5 * fuerza * (0.5 + borde * 0.5)))


## "{agacharse}" -> "[S]" (o el botón del mando) para la pista del cartel.
func _etiquetar(texto: String) -> String:
	return Controles.etiquetar(texto)


func _texto_con_sombra(c: Node2D, texto: String, estilo: StringName, color: Color, sombra: Color, desfase: Vector2, base := Vector2.ZERO) -> void:
	var ancho := roundf(Estilo.ancho(texto, estilo))
	Estilo.escribir(c, base + Vector2(-ancho / 2.0, 0) + desfase, texto, estilo, sombra)
	Estilo.escribir(c, base + Vector2(-ancho / 2.0, 0), texto, estilo, color)


## Franja inclinada que cruza la pantalla.
func _banda(c: Node2D, tam: Vector2, y: float, color: Color, inclinacion: float, desliza := 0.0) -> void:
	var alto := 56.0
	var caida := 14.0 * inclinacion
	c.draw_colored_polygon(PackedVector2Array([
		Vector2(desliza - 20, y - alto / 2.0 + caida), Vector2(tam.x + desliza + 20, y - alto / 2.0 - caida),
		Vector2(tam.x + desliza + 20, y + alto / 2.0 - caida), Vector2(desliza - 20, y + alto / 2.0 + caida),
	]), color)


## Zoom entero (1, 2 o 3), con corte seco.
func _poner_zoom(veces: int) -> void:
	_camara.zoom = Vector2.ONE * float(maxi(veces, 1))
	zooms_usados[maxi(veces, 1)] = true
