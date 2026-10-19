class_name Anuncios
extends Node
## UNA sola cola para todo lo que se anuncia en pantalla (G5 y M3 de la revisión 3): carteles de travesura del HUD,
## avisos de logro, franjas de fase del jefe y «PODER NUEVO». Antes cada uno tenía su cola y se apilaban (cuatro capas
## de texto al ganar) o tapaban el chiste.
## - Se muestra uno a la vez; nada se monta sobre otro.
## - El lugar se decide AL MOSTRAR (no al encolar): no tapa a Felipe, al cuadro de diálogo, a la barra de arriba ni a
##   los testigos (Valeria, A.S.P.I.: quien reacciona es el chiste). Si no hay hueco, espera la reacción hasta
##   ESPERA_MAXIMA s y después sale en su versión chica, en una esquina libre.
## - Lo urgente (la franja de fase del jefe) pasa adelante y apura la salida del que se está viendo.
## Cada anuncio trae cómo mostrarse: mostrar(rect_en_pantalla, chico) -> duración, y ocultar() (salida rápida).

## Segundos que un anuncio espera un hueco libre antes de salir en chico.
const ESPERA_MAXIMA := 1.5
## Pausa entre un anuncio y el siguiente (que se lea el cambio).
const ENTRE := 0.15
## Margen alrededor de lo que no se tapa.
const MARGEN := 4.0
## Barra de arriba (HUD y barra del jefe): nada se pone encima.
const ALTO_BARRA := 40.0
const PANTALLA := Vector2(640, 360)

var felipe: Felipe
var dialogo: Dialogo
## Nodos que reaccionan (testigos): se tapan solo si no queda otra. Cada uno da rect_dibujado() o rect_indicador().
var testigos: Array[Node2D] = []
## Lo que se mostró: [tipo, texto, rectángulo en pantalla, chico] (para las pruebas).
var mostrados: Array = []
## Lo que se está viendo ahora (vacío si nada): {"tipo", "texto", "rect", ...}.
var actual := {}

var _cola: Array = []
var _restante := 0.0
var _pausa := 0.0


func _init() -> void:
	name = "Anuncios"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Encola un anuncio. `tamano` y `tamano_chico` son su caja en pantalla (el ancho 640 = franja completa).
## `mostrar` recibe (rect, chico) y devuelve los segundos que dura; `ocultar` lo saca antes de tiempo.
## `urgente` pasa adelante de la cola y apura al que se está viendo. `retraso`: espera antes de poder salir.
## `en_esquina`: prueba primero las esquinas (avisos de logro), no el centro.
func anunciar(tipo: String, texto: String, tamano: Vector2, tamano_chico: Vector2, mostrar: Callable, ocultar := Callable(), urgente := false, retraso := 0.0, en_esquina := false) -> void:
	var anuncio := {"tipo": tipo, "texto": texto, "tamano": tamano, "chico": tamano_chico, "mostrar": mostrar,
		"ocultar": ocultar, "listo": retraso, "esperando": 0.0, "esquina": en_esquina}
	if urgente:
		_cola.push_front(anuncio)
		if not actual.is_empty() and actual.get("tipo", "") != "fase":
			_terminar_actual()
	else:
		_cola.append(anuncio)


## Vacía la cola y saca lo que se esté viendo (por ejemplo, al terminar una prueba o una escena).
func limpiar() -> void:
	_cola.clear()
	_terminar_actual()
	_pausa = 0.0


## ¿Hay algo en pantalla o esperando?
func ocupado() -> bool:
	return not actual.is_empty() or not _cola.is_empty()


func _process(delta: float) -> void:
	var real := delta / maxf(Engine.time_scale, 0.001)
	if not actual.is_empty():
		_restante -= real
		if _restante <= 0.0:
			_terminar_actual(false)
		return
	if _pausa > 0.0:
		_pausa -= real
		return
	if _cola.is_empty():
		return
	var siguiente: Dictionary = _cola[0]
	siguiente["listo"] -= real
	if siguiente["listo"] > 0.0:
		return
	siguiente["esperando"] += real
	var rect := lugar_libre(siguiente["tamano"], siguiente["esquina"])
	var chico := false
	if rect == Rect2() and siguiente["esperando"] >= ESPERA_MAXIMA:
		chico = true
		rect = lugar_libre(siguiente["chico"], true)
		if rect == Rect2():
			rect = _esquina_menos_tapada(siguiente["chico"])
	if rect == Rect2():
		return
	_cola.pop_front()
	actual = siguiente
	actual["rect"] = rect
	actual["es_chico"] = chico
	mostrados.append([siguiente["tipo"], siguiente["texto"], rect, chico])
	_restante = float((siguiente["mostrar"] as Callable).call(rect, chico))


func _terminar_actual(apurar := true) -> void:
	if actual.is_empty():
		return
	var ocultar: Callable = actual.get("ocultar", Callable())
	if apurar and ocultar.is_valid():
		ocultar.call()
	actual = {}
	_pausa = ENTRE


## Rectángulos de pantalla que un anuncio no debe tapar: Felipe, el diálogo, la barra de arriba y los testigos
## visibles (Valeria, A.S.P.I.).
func zonas_ocupadas() -> Array[Rect2]:
	var zonas: Array[Rect2] = [Rect2(0, 0, PANTALLA.x, ALTO_BARRA)]
	var vista := get_viewport()
	if vista == null:
		return zonas
	var lienzo := vista.get_canvas_transform()
	if felipe and is_instance_valid(felipe) and felipe.is_inside_tree():
		var pies := lienzo * felipe.global_position
		zonas.append(Rect2(pies + Vector2(-40, -76), Vector2(80, 80)).grow(MARGEN))
	if dialogo and is_instance_valid(dialogo):
		var cuadro := dialogo.rect_en_pantalla()
		if cuadro.has_area():
			zonas.append(cuadro.grow(MARGEN))
	for testigo in testigos:
		if not is_instance_valid(testigo) or not testigo.is_visible_in_tree():
			continue
		var r: Rect2 = testigo.call("rect_dibujado") if testigo.has_method("rect_dibujado") else testigo.call("rect_indicador")
		var en_pantalla := Rect2(lienzo * r.position, r.size * lienzo.get_scale())
		if en_pantalla.intersects(Rect2(Vector2.ZERO, PANTALLA)):
			zonas.append(en_pantalla.grow(MARGEN))
	return zonas


## Primer lugar libre (de arriba hacia abajo) para una caja de ese tamaño; Rect2() si no hay. Las franjas de 640 de
## ancho solo cambian de altura; las chicas prueban también las esquinas (derecha e izquierda).
func lugar_libre(tamano: Vector2, esquinas := false) -> Rect2:
	var zonas := zonas_ocupadas()
	var xs: Array[float] = []
	if tamano.x >= PANTALLA.x:
		xs.append(0.0)
	else:
		if not esquinas:
			xs.append((PANTALLA.x - tamano.x) / 2.0)
		xs.append(PANTALLA.x - tamano.x - 8.0)
		xs.append(8.0)
	var y := ALTO_BARRA + 4.0
	while y + tamano.y <= PANTALLA.y - 4.0:
		for x in xs:
			var caja := Rect2(Vector2(x, y), tamano)
			var libre := true
			for zona in zonas:
				if caja.intersects(zona):
					libre = false
					break
			if libre:
				return caja
		y += 8.0
	return Rect2()


## Si ni la versión chica cabe: la esquina de arriba (bajo la barra) que tape menos.
func _esquina_menos_tapada(tamano: Vector2) -> Rect2:
	var zonas := zonas_ocupadas()
	var mejor := Rect2()
	var menos := INF
	for x: float in [PANTALLA.x - tamano.x - 8.0, 8.0]:
		for y: float in [ALTO_BARRA + 4.0, PANTALLA.y - tamano.y - 8.0]:
			var caja := Rect2(Vector2(x, y), tamano)
			var tapa := 0.0
			for zona in zonas.slice(1):
				tapa += caja.intersection(zona).get_area()
			if tapa < menos:
				menos = tapa
				mejor = caja
	return mejor
