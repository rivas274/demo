class_name BarraVida
extends Control
## Pieza de interfaz que muestra una pieza Vida: los corazones de Felipe o la barra de un jefe. Solo escucha: se
## conecta a la señal `Vida.cambio` y se redibuja cuando cambia (nada de preguntar en cada cuadro). No sabe de quién
## es la vida ni qué pasa al morir.
##
## - CORAZONES: un corazón por punto de vida (llenos en rojo, vacíos apagados), cada `paso` px.
## - BARRA: título arriba ("NOMBRE — título"), barra roja con una división por punto y, debajo, una franja azul
##   opcional (el "escudo": por ejemplo, el depósito de A.S.P.I.).
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
## Ancho y alto de la barra (solo forma BARRA).
@export var tam_barra := Vector2(220, 9)

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


## La barra de un jefe: el rectángulo (0, 0) es la esquina del fondo; la barra va 18 px más abajo y 6 a la derecha.
func _dibujar_barra() -> void:
	var caja := Rect2(Vector2(6, 18), tam_barra)
	draw_rect(Rect2(0, 0, tam_barra.x + 12, 34), Estilo.color(&"jefe_fondo_barra"))
	draw_string(Estilo.fuente(), Vector2(6, 12), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, Estilo.letra(&"jefe_barra"), Estilo.color(&"jefe_texto_barra"))
	draw_rect(caja.grow(2), Estilo.color(&"jefe_marco_barra"))
	draw_rect(Rect2(caja.position, Vector2(caja.size.x * clampf(fraccion, 0.0, 1.0), caja.size.y)), Estilo.color(&"jefe_rojo"))
	for i in range(1, maximo):
		var x := caja.position.x + caja.size.x * i / maximo
		draw_line(Vector2(x, caja.position.y), Vector2(x, caja.end.y), Estilo.color(&"jefe_division"), 1.0)
	if escudo > 0.0:
		draw_rect(Rect2(caja.position + Vector2(0, caja.size.y - 3), Vector2(caja.size.x * escudo, 3)), Estilo.color(&"jefe_escudo"))


func _corazon(centro: Vector2, color: Color) -> void:
	draw_circle(centro + Vector2(-3, -2), 3.5, color)
	draw_circle(centro + Vector2(3, -2), 3.5, color)
	draw_colored_polygon(PackedVector2Array([centro + Vector2(-6.5, -1), centro + Vector2(6.5, -1), centro + Vector2(0, 7)]), color)
