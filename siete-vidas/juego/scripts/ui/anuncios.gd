class_name Anuncios
extends Node
## UNA sola cola para todo lo que se anuncia en pantalla (G5 y M3 de la revisión 3): carteles de travesura, avisos de
## logro, franjas de fase del jefe («¡DEPÓSITO LLENO!») y «PODER NUEVO».
## Plan de estabilización (2026-10-20, decisión 3): todos salen en la ZONA C (ZonasTexto.CARTELES, arriba al centro
## desde y 44; el logro, a la derecha: layout v2), la misma franja que el diálogo:
## - Uno a la vez; nada se monta sobre otro ni sobre el HUD.
## - Si hay diálogo, el anuncio espera su turno. Si espera más de ESPERA_MAXIMA s, sale igual y la frase cede (vuelve
##   a la cola del diálogo). Si llega una frase urgente mientras se ve un anuncio, el anuncio se acorta.
## - Lo urgente (la franja de fase del jefe) pasa adelante, apura al que se está viendo y hace ceder al diálogo.
## - Mientras se ve un anuncio, el diálogo espera (Dialogo.esperar).
## Cada anuncio trae cómo mostrarse: mostrar(rect_en_pantalla) -> duración, y ocultar() (salida rápida).

## Segundos que un anuncio espera a que termine el diálogo antes de salir igual.
const ESPERA_MAXIMA := 4.0
## Pausa entre un anuncio y el siguiente (que se lea el cambio).
const ENTRE := 0.15

var felipe: Felipe
var dialogo: Dialogo:
	set(valor):
		dialogo = valor
		if dialogo:
			dialogo.esperar = func() -> bool: return not actual.is_empty()
			dialogo.esperar_urgente = func() -> bool: return actual.get("tipo", "") == "fase"
## Mientras devuelva true, hay una reacción en camino (Valeria va a salir a ver): los anuncios esperan (hasta
## ESPERA_MAXIMA).
var reaccion_en_curso := Callable()
## Lo que se mostró: [tipo, texto, rectángulo en pantalla] (para las pruebas).
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


## Encola un anuncio. `tamano` es su caja en pantalla (se centra arriba en la zona C; su alto, como mucho el de la
## zona). `mostrar` recibe el rectángulo y devuelve los segundos que dura; `ocultar` lo saca antes de tiempo.
## `urgente` pasa adelante de la cola y apura al que se está viendo. `retraso`: espera antes de poder salir.
func anunciar(tipo: String, texto: String, tamano: Vector2, mostrar: Callable, ocultar := Callable(), urgente := false, retraso := 0.0) -> void:
	var anuncio := {"tipo": tipo, "texto": texto, "tamano": tamano, "mostrar": mostrar, "ocultar": ocultar,
		"listo": retraso, "esperando": 0.0, "urgente": urgente}
	if urgente:
		_cola.push_front(anuncio)
		if not actual.is_empty() and actual.get("tipo", "") != "fase":
			_terminar_actual()
	elif tipo != "logro":
		# Un cartel va antes que los logros que esperan: primero la travesura, después su logro.
		var i := 0
		while i < _cola.size() and _cola[i]["tipo"] != "logro":
			i += 1
		_cola.insert(i, anuncio)
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


func _hay_dialogo() -> bool:
	return dialogo != null and is_instance_valid(dialogo) and dialogo.ocupado()


func _process(delta: float) -> void:
	var real := delta / maxf(Engine.time_scale, 0.001)
	if not actual.is_empty():
		_restante -= real
		# Una frase urgente entró mientras se veía el anuncio (no una fase del jefe): el anuncio se acorta.
		if _restante <= 0.0 or (_hay_dialogo() and actual.get("tipo", "") != "fase"):
			_terminar_actual(_restante > 0.0)
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
	var urgente: bool = siguiente["urgente"]
	var esperar: bool = _hay_dialogo() or (reaccion_en_curso.is_valid() and bool(reaccion_en_curso.call()))
	if esperar and not urgente and siguiente["esperando"] < ESPERA_MAXIMA:
		return
	if _hay_dialogo():
		dialogo.ceder()
	_cola.pop_front()
	# El logro va a la derecha de la zona C; lo demás, centrado (layout v2).
	var rect := ZonasTexto.logro(siguiente["tamano"]) if siguiente["tipo"] == "logro" else ZonasTexto.cartel(siguiente["tamano"])
	actual = siguiente
	actual["rect"] = rect
	mostrados.append([siguiente["tipo"], siguiente["texto"], rect])
	_restante = float((siguiente["mostrar"] as Callable).call(rect))


func _terminar_actual(apurar := true) -> void:
	if actual.is_empty():
		return
	var ocultar: Callable = actual.get("ocultar", Callable())
	if apurar and ocultar.is_valid():
		ocultar.call()
	actual = {}
	_pausa = ENTRE
