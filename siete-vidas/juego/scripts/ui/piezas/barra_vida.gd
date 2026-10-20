class_name BarraVida
extends Control
## Pieza de interfaz que muestra una pieza Vida: los corazones de Felipe o la barra de un jefe. Solo escucha: se
## conecta a la señal `Vida.cambio` y se redibuja cuando cambia (nada de preguntar en cada cuadro). No sabe de quién
## es la vida ni qué pasa al morir.
##
## - CORAZONES: un corazón por punto de vida (llenos en rojo, vacíos apagados), cada `paso` px.
## - BARRA: título arriba ("NOMBRE — título"), barra roja en el marco de madera y oro del kit «Decreto real», con una
##   división por punto y, abajo, una franja azul opcional (el "escudo": por ejemplo, el depósito de A.S.P.I.).
## Se arma en el editor con escenas/ui/barra_vida.tscn; los colores y letras salen del tema (Estilo).

## Se redibujó con un valor nuevo (para las pruebas y para quien quiera reaccionar).
signal mostrada(actual: int, maximo: int)

enum Forma { CORAZONES, BARRA }

@export var forma := Forma.CORAZONES:
	set(valor):
		forma = valor
		queue_redraw()
## Distancia entre corazones.
@export var paso := 16.0
## Texto sobre la barra (solo forma BARRA).
@export var titulo := "":
	set(valor):
		titulo = valor
		queue_redraw()
## Ancho y alto de la barra (solo forma BARRA): el ancho del relleno; el marco del kit la rodea.
@export var tam_barra := Vector2(220, 9)
## Relleno de la vida y del escudo (kit «Decreto real», assets/ui/decreto/relleno_*.png).
@export var relleno: Texture2D
@export var relleno_escudo: Texture2D

var actual := 0
var maximo := 0
## 0 a 1: franja azul bajo la barra.
var escudo := 0.0:
	set(valor):
		escudo = valor
		queue_redraw()
## Si es >= 0, muestra esta fracción en vez de la vida (la barra que se llena en la entrada de un jefe).
var forzada := -1.0:
	set(valor):
		forzada = valor
		queue_redraw()

var _vida: Vida


## Lo que se ve (0 a 1).
var fraccion: float:
	get:
		if forzada >= 0.0:
			return forzada
		return float(actual) / maximo if maximo > 0 else 0.0


## Empieza a escuchar esa Vida (deja de escuchar la anterior) y muestra lo que tiene ahora.
func conectar(vida: Vida) -> void:
	if _vida and is_instance_valid(_vida) and _vida.cambio.is_connected(_al_cambiar):
		_vida.cambio.disconnect(_al_cambiar)
	_vida = vida
	if vida == null:
		return
	vida.cambio.connect(_al_cambiar)
	_al_cambiar(vida.actual if vida.actual >= 0 else vida.maximo, vida.maximo)


func _al_cambiar(nuevo: int, de: int) -> void:
	actual = nuevo
	maximo = de
	queue_redraw()
	mostrada.emit(actual, maximo)


func _draw() -> void:
	if forma == Forma.CORAZONES:
		for i in maximo:
			_corazon(Vector2(i * paso, 0), Estilo.color(&"rojo") if i < actual else Estilo.color(&"corazon_vacio"))
		return
	_dibujar_barra()


## Marco de la barra del jefe (marco_barra_jefe, 9 partes): alto y cuánto entra el hueco del relleno desde el borde.
const ALTO_MARCO := 25.0
const HUECO_LADO := 20.0
const HUECO_ARRIBA := 5.0
const HUECO_ALTO := 14.0


## La barra de un jefe: el título arriba (con contorno, sobre el juego) y debajo el marco del kit; el relleno va
## dentro del hueco del marco (se dibuja antes, así el marco tapa sus bordes).
func _dibujar_barra() -> void:
	var marco := Rect2(0, 14, tam_barra.x + HUECO_LADO * 2.0, ALTO_MARCO)
	var hueco := Rect2(marco.position + Vector2(HUECO_LADO, HUECO_ARRIBA), Vector2(tam_barra.x, HUECO_ALTO))
	Estilo.texto_con_contorno(self, Vector2(HUECO_LADO, 10), Estilo.recortar(titulo, &"jefe_barra", marco.size.x - HUECO_LADO), &"jefe_barra", Estilo.color(&"jefe_texto_barra"))
	draw_rect(hueco, Estilo.color(&"jefe_fondo_barra"))
	# El relleno a su alto de pixel (tam_barra.y), centrado en el hueco.
	var alto := minf(tam_barra.y, HUECO_ALTO)
	var lleno := Rect2(hueco.position + Vector2(0, roundf((HUECO_ALTO - alto) / 2.0)), Vector2(roundf(hueco.size.x * clampf(fraccion, 0.0, 1.0)), alto))
	if relleno:
		Estilo.relleno(self, relleno, lleno)
	else:
		draw_rect(lleno, Estilo.color(&"jefe_rojo"))
	for i in range(1, maximo):
		var x := roundf(hueco.position.x + hueco.size.x * i / maximo)
		draw_line(Vector2(x, hueco.position.y), Vector2(x, hueco.end.y), Estilo.color(&"jefe_division"), 1.0)
	if escudo > 0.0:
		var franja := Rect2(Vector2(hueco.position.x, lleno.end.y - 3), Vector2(roundf(hueco.size.x * escudo), 3))
		if relleno_escudo:
			Estilo.relleno(self, relleno_escudo, franja)
		else:
			draw_rect(franja, Estilo.color(&"jefe_escudo"))
	Estilo.panel(self, marco, &"marco_barra_jefe")


func _corazon(centro: Vector2, color: Color) -> void:
	draw_circle(centro + Vector2(-3, -2), 3.5, color)
	draw_circle(centro + Vector2(3, -2), 3.5, color)
	draw_colored_polygon(PackedVector2Array([centro + Vector2(-6.5, -1), centro + Vector2(6.5, -1), centro + Vector2(0, 7)]), color)
