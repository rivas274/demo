class_name SombraContacto
extends Node
## Pieza para lo que se mueve y debe apoyarse en el piso con su sombra de contacto (ratones, A.S.P.I., la caja de
## cartón, la comida, Valeria). No dibuja: la dibuja el nodo «Sombras» del nivel (SombrasVivas), que recorre esta lista
## cada cuadro, en la capa de los muebles. La sombra va bajo los pies de quien la lleva y solo si se ve.

const GRUPO := "sombras_de_contacto"

## Ancho de la sombra en px.
@export var ancho := 44.0
@export var alfa := 0.36
## Si está puesta, decide cuándo se dibuja (Valeria no la tiene sentada ni fuera de la casa).
var mostrar := Callable()
## Si está puesta, cuánto se corre la sombra respecto de los pies (Vector2): la de A.S.P.I. va con su dibujo.
var desfase := Callable()


func _init(ancho_sombra := 44.0, alfa_sombra := 0.36) -> void:
	name = "SombraContacto"
	ancho = ancho_sombra
	alfa = alfa_sombra


func _ready() -> void:
	add_to_group(GRUPO)


## ¿Se dibuja ahora? (quien la lleva está visible y, si hay condición, la cumple).
func se_ve() -> bool:
	var dueno := get_parent() as CanvasItem
	if dueno == null or not dueno.visible:
		return false
	return not mostrar.is_valid() or bool(mostrar.call())


## Dónde va: los pies de quien la lleva.
func centro() -> Vector2:
	var pies := (get_parent() as Node2D).global_position
	return pies + (desfase.call() as Vector2) if desfase.is_valid() else pies
