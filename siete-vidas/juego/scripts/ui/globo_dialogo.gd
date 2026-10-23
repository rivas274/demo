class_name GloboDialogo
extends CanvasLayer
## Globito de cómic sobre la cabeza de Felipe para lo que piensa durante una pelea (pelea con A.S.P.I. v3, crítica de
## Gemini: el cuadro de diálogo de arriba tapaba la acción). Una frase a la vez (la nueva reemplaza a la anterior),
## sin retrato, que se va sola en unos 2 s (más un poco si es larga). Sigue a Felipe en pantalla, nunca entra al HUD
## (ZonasTexto.HUD) ni se sale de la pantalla, y queda más arriba que la burbuja del Indicador. Va en la capa del
## diálogo (pantalla): la luz del cuarto (el apagón) no lo oscurece.
## Lo conecta PeleaJefe al Dialogo (`Dialogo.globo`) mientras dura la pelea; fuera de la pelea, el diálogo es el de siempre.
## v4 (Gemini y ChatGPT): nunca en pleno peligro (`peligro`: la frase espera hasta ESPERA_MAXIMA s a que pase; si no,
## se descarta; y si el peligro empieza, el globito se va), y se lee mejor: letra negrita y contorno oscuro de 2 px.

## Segundos que dura una frase: base más un poco por letra.
const DURA_BASE := 1.6
const DURA_POR_LETRA := 0.02
## Ancho máximo del texto, margen interior y altura sobre los pies de Felipe (encima de la burbuja del Indicador).
const ANCHO_MAXIMO := 240.0
const MARGEN := Vector2(6, 4)
const ALTURA := 104.0
const LETRA := &"globo_texto"
## Segundos que una frase espera a que pase el peligro antes de descartarse.
const ESPERA_MAXIMA := 2.5
const ALTO_LINEA := 14.0

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
	_lineas = _partir(texto)
	_queda = DURA_BASE + DURA_POR_LETRA * texto.length()
	_aparecer = 0.0
	_lienzo.queue_redraw()


func visible_ahora() -> bool:
	return _queda > 0.0 and texto != ""


## Rectángulo del globito en pantalla (vacío si no se ve): para las pruebas de zonas de texto.
func rect_en_pantalla() -> Rect2:
	if not visible_ahora() or felipe == null or not is_instance_valid(felipe) or not felipe.is_inside_tree():
		return Rect2()
	var ancho := 0.0
	for linea in _lineas:
		ancho = maxf(ancho, Estilo.ancho(linea, LETRA))
	var tam := Vector2(ancho, _lineas.size() * ALTO_LINEA) + MARGEN * 2.0
	var pies := felipe.get_viewport().get_canvas_transform() * felipe.global_position
	var caja := Rect2((pies + Vector2(-tam.x / 2.0, -ALTURA - tam.y)).round(), tam.round())
	caja.position.x = clampf(caja.position.x, ZonasTexto.BORDE, ZonasTexto.PANTALLA.size.x - ZonasTexto.BORDE - caja.size.x)
	caja.position.y = maxf(caja.position.y, ZonasTexto.HUD.end.y + 2.0)
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


## Parte la frase en líneas de ANCHO_MAXIMO como mucho (por palabras).
func _partir(frase: String) -> PackedStringArray:
	var lineas: PackedStringArray = []
	var actual := ""
	for palabra in frase.split(" ", false):
		var prueba := palabra if actual == "" else actual + " " + palabra
		if actual != "" and Estilo.ancho(prueba, LETRA) > ANCHO_MAXIMO:
			lineas.append(actual)
			actual = palabra
		else:
			actual = prueba
	if actual != "":
		lineas.append(actual)
	return lineas


func _dibujar() -> void:
	var caja := rect_en_pantalla()
	if not caja.has_area():
		return
	var c := _lienzo
	caja.position.y += roundf((1.0 - _aparecer) * 3.0)
	var pies := felipe.get_viewport().get_canvas_transform() * felipe.global_position
	var punta := Vector2(clampf(roundf(pies.x), caja.position.x + 8.0, caja.end.x - 8.0), caja.end.y)
	var trazo := Estilo.color(&"indicador_trazo")
	var fondo := Estilo.color(&"globo_fondo")
	# Sombra dura, contorno oscuro de 2 px con esquinas recortadas, papel crema y el piquito hacia Felipe.
	c.draw_rect(Rect2(caja.position + Vector2(3, 3), caja.size), Estilo.color(&"indicador_sombra"))
	c.draw_rect(Rect2(caja.position.x, caja.position.y - 2, caja.size.x, caja.size.y + 4), trazo)
	c.draw_rect(Rect2(caja.position.x - 2, caja.position.y, caja.size.x + 4, caja.size.y), trazo)
	c.draw_rect(Rect2(caja.position.x - 1, caja.position.y - 1, caja.size.x + 2, caja.size.y + 2), trazo)
	c.draw_rect(caja, fondo)
	c.draw_colored_polygon(PackedVector2Array([punta + Vector2(-6, -1), punta + Vector2(4, -1), punta + Vector2(-5, 8)]), trazo)
	c.draw_colored_polygon(PackedVector2Array([punta + Vector2(-4, -1), punta + Vector2(2, -1), punta + Vector2(-3, 4)]), fondo)
	for i in _lineas.size():
		Estilo.escribir(c, caja.position + MARGEN + Vector2(0, ALTO_LINEA * (i + 1) - 3.0), _lineas[i], LETRA, Estilo.color(&"texto_oscuro"))
