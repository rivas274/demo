class_name PiezaKit
extends Control
## Pieza de interfaz para armar pantallas en el editor con el kit v2 (assets/ui/v2/): dibuja una pieza que se estira
## (`pieza`, por ejemplo «pausa-panel», «titulo-franja» o «bolsillo-fila») al tamaño del nodo, que es su medida
## lógica; la sombra y el contorno caen solos afuera. Con `texto` (una clave de traducción), lo escribe encima como
## una franja de título: a 8 px del borde y centrado en el alto, y con `ajustar_ancho` el nodo toma el ancho del texto
## más 16 px. Colores y letras, del tema por nombre.

@export var pieza := "titulo-franja":
	set(valor):
		pieza = valor
		queue_redraw()
@export var texto := "":
	set(valor):
		texto = valor
		_ajustar()
@export var estilo_texto := &"cartel_kit"
@export var color_texto := &"ui_contorno"
@export var ajustar_ancho := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ajustar()


func _ajustar() -> void:
	if ajustar_ancho and texto != "" and is_inside_tree():
		size.x = roundf(Estilo.ancho(tr(texto), estilo_texto)) + 16.0
	queue_redraw()


func _notification(que: int) -> void:
	if que == NOTIFICATION_TRANSLATION_CHANGED:
		_ajustar()


func _draw() -> void:
	KitUI.pieza(self, pieza, Rect2(Vector2.ZERO, size))
	if texto != "":
		var y := floorf((size.y - KitUI.alto_mayuscula(estilo_texto)) / 2.0)
		KitUI.escribir(self, 8.0, y, tr(texto), estilo_texto, Estilo.color(color_texto))
