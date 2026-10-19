class_name Interactivo
extends Node2D
## Algo del nivel que responde al botón de acción sin necesitar una clase propia (el cajón de los calcetines, la
## ropa doblada): da un verbo para el Indicador, un rectángulo para su contorno y qué hace al usarlo.
## La posición es el punto donde Felipe lo alcanza (lo compara con su alcance de 48 × 40 px).

## Felipe lo usó (después de la animación que pida `al_usar`).
signal usado(objeto: Interactivo)

## Verbo de Felipe en la burbuja del Indicador.
@export var verbo_indicador := "Usar"
## Rectángulo del contorno, relativo a la posición.
@export var rect_local := Rect2(-16, -24, 32, 24)
## Se puede usar una sola vez.
@export var una_vez := true

## Lo que hace al usarlo: recibe a Felipe (por ejemplo, felipe.dar_manotazo(...)). Si no hay, emite `usado` al tiro.
var al_usar := Callable()
## Dibujo propio (recibe este nodo como lienzo).
var dibujo := Callable()
var usado_ya := false


func _init(nombre := "Interactivo", verbo_felipe := "Usar", rect := Rect2(-16, -24, 32, 24)) -> void:
	name = nombre
	verbo_indicador = verbo_felipe
	rect_local = rect


func _ready() -> void:
	add_to_group(Comida.GRUPO)


func disponible(_felipe: Felipe) -> bool:
	return not (una_vez and usado_ya)


func interactuar(felipe: Felipe) -> void:
	if not disponible(felipe):
		return
	usado_ya = true
	if al_usar.is_valid():
		al_usar.call(felipe)
	else:
		marcar_usado()


## Lo llama quien termina la acción (por ejemplo, el cuadro de impacto del manotazo).
func marcar_usado() -> void:
	usado.emit(self)
	queue_redraw()


func verbo(_felipe: Felipe) -> String:
	return verbo_indicador


## Arte para el contorno del Indicador (lo pone el nivel): devuelve lo mismo que arte_indicador().
var arte := Callable()


func arte_indicador() -> Dictionary:
	return arte.call() if arte.is_valid() else {}


func rect_indicador() -> Rect2:
	return Rect2(global_position + rect_local.position, rect_local.size)


func _draw() -> void:
	if dibujo.is_valid():
		dibujo.call(self)
