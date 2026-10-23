class_name GloboDialogo
extends CanvasLayer
## Globito de cómic sobre la cabeza de Felipe para lo que piensa durante una pelea (pelea con A.S.P.I. v3, crítica de
## Gemini: el cuadro de diálogo de arriba tapaba la acción). Una frase a la vez (la nueva reemplaza a la anterior),
## sin retrato, que se va sola en unos 2 s (más un poco si es larga). Sigue a Felipe en pantalla, nunca entra al HUD
## (ZonasTexto.HUD) ni se sale de la pantalla, y queda más arriba que la burbuja del Indicador. Va en la capa del
## diálogo (pantalla): la luz del cuarto (el apagón) no lo oscurece.
## Lo conecta PeleaJefe al Dialogo (`Dialogo.globo`) mientras dura la pelea; fuera de la pelea, el diálogo es el de siempre.
## v4 (Gemini y ChatGPT): nunca en pleno peligro (`peligro`: la frase espera hasta ESPERA_MAXIMA s a que pase; si no,
## se descarta; y si el peligro empieza, el globito se va).
## Interfaz v2 («A + C», kit assets/ui/v2/): caja oscura de una línea con las esquinas cortadas, línea crema, sombra
## ámbar (el color de Felipe), dos orejitas de gato arriba y la cola con huellita que baja hacia él. Salta 3 px al
## aparecer (con «Reducir movimiento», no). Siempre dentro de la zona segura y fuera de la salud y la barra del jefe.

## Segundos que dura una frase: base más un poco por letra.
const DURA_BASE := 1.6
const DURA_POR_LETRA := 0.02
## Ancho máximo del texto (una línea, dentro de la zona segura), alto de la caja y altura sobre los pies de Felipe
## (encima de la burbuja del Indicador).
const ANCHO_MAXIMO := 420.0
const ALTO_CAJA := 18.0
const MARGEN_TEXTO := 8.0
const ALTURA := 104.0
const LETRA := &"globo_texto"
## Segundos que una frase espera a que pase el peligro antes de descartarse.
const ESPERA_MAXIMA := 2.5

var felipe: Node2D
var texto := ""
var _lineas: PackedStringArray = []
var _queda := 0.0
var _aparecer := 0.0
var _lienzo: Node2D
## Si devuelve true hay peligro en curso (un ataque anunciado): no se muestra nada.
var peligro: Callable
## Frase que espera a que pase el peligro y cuánto lleva esperando.
var pendiente := ""
var _espera := 0.0


func _init(de_felipe: Node2D = null) -> void:
	name = "Globo de Felipe"
	felipe = de_felipe
	layer = Capas.CAPA_DIALOGO


func _ready() -> void:
	_lienzo = Node2D.new()
	_lienzo.name = "Lienzo"
	_lienzo.draw.connect(_dibujar)
	add_child(_lienzo)


## Muestra la frase (ya traducida o como clave) en el globito; reemplaza la que hubiera.
func decir(frase: String) -> void:
	if _hay_peligro():
		pendiente = frase
		_espera = 0.0
		return
	_mostrar(frase)


func _hay_peligro() -> bool:
	return peligro.is_valid() and peligro.call()


func _mostrar(frase: String) -> void:
	pendiente = ""
	texto = tr(frase)
	# {acción} → [tecla] (en el globito no van íconos).
	for accion: String in Controles.ACCIONES:
		texto = texto.replace("{%s}" % accion, "[%s]" % IconosBotones.texto(accion))
	# Una sola línea (layout v2): lo que no cabe se corta con «…» (las frases de la pelea son cortas).
	texto = Estilo.recortar(texto, LETRA, ANCHO_MAXIMO)
	_lineas = [texto]
	_queda = DURA_BASE + DURA_POR_LETRA * texto.length()
	_aparecer = 0.0
	_lienzo.queue_redraw()


func visible_ahora() -> bool:
	return _queda > 0.0 and texto != ""


## Rectángulo del globito en pantalla (vacío si no se ve): para las pruebas de zonas de texto.
func rect_en_pantalla() -> Rect2:
	if not visible_ahora() or felipe == null or not is_instance_valid(felipe) or not felipe.is_inside_tree():
		return Rect2()
	var tam := Vector2(roundf(Estilo.ancho(texto, LETRA)) + MARGEN_TEXTO * 2.0, ALTO_CAJA)
	var pies := felipe.get_viewport().get_canvas_transform() * felipe.global_position
	var caja := Rect2((pies + Vector2(-tam.x / 2.0, -ALTURA - tam.y)).round(), tam)
	var segura := ZonasTexto.SEGURA
	caja.position.x = clampf(caja.position.x, segura.position.x, segura.end.x - caja.size.x)
	# Las orejitas suben 7 px: la caja queda bajo la salud y bajo la barra del jefe (si se ve).
	caja.position.y = maxf(caja.position.y, ZonasTexto.techo(Opciones.texto_grande) + 8.0)
	return caja


func _process(delta: float) -> void:
	# Tiempo real (sin el congelado ni la cámara lenta).
	delta = delta / maxf(Engine.time_scale, 0.001)
	if pendiente != "":
		_espera += delta
		if not _hay_peligro():
			_mostrar(pendiente)
		elif _espera >= ESPERA_MAXIMA:
			pendiente = ""
	if _queda <= 0.0:
		return
	if _hay_peligro():
		# Empezó un peligro: el globito se va.
		_queda = 0.0
		texto = ""
		_lienzo.queue_redraw()
		return
	_queda -= delta
	_aparecer = minf(1.0, _aparecer + delta * 8.0)
	if _queda <= 0.0:
		texto = ""
	_lienzo.queue_redraw()


func _dibujar() -> void:
	var caja := rect_en_pantalla()
	if not caja.has_area():
		return
	var c := _lienzo
	if not Opciones.reducir_movimiento:
		caja.position.y += roundf((1.0 - _aparecer) * 3.0)
	var pies := felipe.get_viewport().get_canvas_transform() * felipe.global_position
	var cola_x := clampf(roundf(pies.x), caja.position.x + 10.0, caja.end.x - 14.0)
	KitUI.pieza(c, "globito-caja", caja)
	KitUI.icono(c, "globito-cola", Vector2(cola_x - 5.0, caja.end.y))
	KitUI.icono(c, "globito-oreja-izq", Vector2(caja.position.x + 6.0, caja.position.y - 7.0))
	KitUI.icono(c, "globito-oreja-der", Vector2(caja.end.x - 18.0, caja.position.y - 7.0))
	var y := caja.position.y + ceilf((ALTO_CAJA - KitUI.alto_mayuscula(LETRA)) / 2.0)
	KitUI.escribir(c, caja.position.x + MARGEN_TEXTO + KitUI.inclinacion(ALTO_CAJA) / 2.0, y, texto, LETRA, Estilo.color(&"ui_texto"))
