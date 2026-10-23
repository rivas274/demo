class_name CamaraPelea
extends CanvasLayer
## Cámara de la pelea (pelea con A.S.P.I. v3, crítica de Gemini: «si la cámara está muy pegada a Felipe, se pierde de
## vista a la jefa cuando embiste desde el otro extremo»). Pieza de PeleaJefe: sirve para cualquier jefe.
## - **Mirar hacia el jefe:** si el jefe está fuera de pantalla, o avisa un ataque desde lejos (`pelea.amenaza()`), la
##   cámara de Felipe se corre suave hacia él (hasta MIRADA px, a la mitad del camino) y vuelve suave cuando pasa.
## - **Indicador de borde:** si aun así no se ve, una flecha en el borde de la pantalla, a su altura, con su luz.
## Por qué no un zoom-out: el juego se dibuja a 640 × 360 y se agranda en múltiplos enteros (`stretch/scale_mode =
## integer`); un zoom de cámara que no sea entero reparte los píxeles de forma despareja (unos de 1, otros de 2) y el
## pixel art se ensucia. Correr la cámara y marcar el borde es la receta de los juegos de pixel art (Celeste, Dead Cells).

## Cuánto se corre como mucho y a qué velocidad (px/s).
const MIRADA := 150.0
const VELOCIDAD := 260.0
## Margen desde el borde de la pantalla para decidir que el jefe «se ve».
const MARGEN := 28.0

var pelea: PeleaJefe
var _camara: Camera2D
var _base := Vector2.ZERO
var _lienzo: Node2D
## Para las pruebas: cuánto está corrida la cámara ahora y si se ve la flecha del borde.
var corrida := 0.0
var flecha := 0.0


func _init(de_pelea: PeleaJefe) -> void:
	name = "Cámara de la pelea"
	pelea = de_pelea
	layer = Capas.CAPA_HUD


func _ready() -> void:
	_camara = pelea.felipe.get_node_or_null("Camara")
	if _camara:
		_base = _camara.position
	_lienzo = Node2D.new()
	_lienzo.name = "Flecha del borde"
	_lienzo.draw.connect(_dibujar)
	add_child(_lienzo)


func _physics_process(delta: float) -> void:
	if _camara == null or not is_instance_valid(_camara):
		return
	var activa := pelea.fase == PeleaJefe.Fase.PELEA and not pelea.ausente and is_instance_valid(pelea.jefe)
	var objetivo := 0.0
	flecha = 0.0
	if activa:
		var dx := pelea.jefe.global_position.x - pelea.felipe.global_position.x
		var centro := _camara.get_screen_center_position()
		var fuera := absf(pelea.jefe.global_position.x - centro.x) > 320.0 - MARGEN
		if fuera or (pelea.amenaza() and absf(dx) > 200.0):
			objetivo = clampf(dx * 0.5, -MIRADA, MIRADA)
		if fuera:
			flecha = signf(pelea.jefe.global_position.x - centro.x)
	corrida = move_toward(corrida, objetivo, VELOCIDAD * delta)
	_camara.position = _base + Vector2(roundf(corrida), 0.0)
	_lienzo.queue_redraw()


## Al terminar la pelea, la cámara vuelve a su lugar.
func soltar() -> void:
	corrida = 0.0
	flecha = 0.0
	if _camara and is_instance_valid(_camara):
		_camara.position = _base


func _dibujar() -> void:
	if flecha == 0.0 or not is_instance_valid(pelea.jefe):
		return
	var en_pantalla := pelea.jefe.get_viewport().get_canvas_transform() * (pelea.jefe.global_position + Vector2(0, -16))
	var y := clampf(roundf(en_pantalla.y), ZonasTexto.CARTELES.end.y + 12.0, ZonasTexto.PANTALLA.size.y - 14.0)
	var x := ZonasTexto.PANTALLA.size.x - 10.0 if flecha > 0.0 else 10.0
	var parpadeo := int(Time.get_ticks_msec() / 160) % 2 == 0
	var punta := Vector2(x, y)
	var atras := punta - Vector2(flecha * 12.0, 0)
	var forma := PackedVector2Array([punta, atras + Vector2(0, -8), atras + Vector2(0, 8)])
	var borde := PackedVector2Array([punta + Vector2(flecha, 0), atras + Vector2(-flecha, -10), atras + Vector2(-flecha, 10)])
	_lienzo.draw_colored_polygon(borde, Estilo.color(&"indicador_trazo"))
	_lienzo.draw_colored_polygon(forma, Color("e0483b") if parpadeo else Color("ffd23f"))
