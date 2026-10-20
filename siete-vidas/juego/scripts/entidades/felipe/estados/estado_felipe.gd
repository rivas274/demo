class_name EstadoFelipe
extends RefCounted
## Un estado de Felipe (patrón Estado). Cada estado sabe qué hace al entrar, en cada cuadro de física y al salir; Felipe
## (felipe.gd) solo cambia de uno a otro con `cambiar_estado`. El nombre de cada estado es su valor de Felipe.Estado
## (así `felipe.estado == Felipe.Estado.SUELO` sigue funcionando en todo el juego y en las pruebas).
## Los estados se crean una vez y se reusan: no guardan nada entre una visita y la siguiente salvo lo que pongan al entrar.

var felipe: Felipe
var id: Felipe.Estado


func _init(de: Felipe, estado: Felipe.Estado) -> void:
	felipe = de
	id = estado


## Al entrar (con lo que pida el estado, por ejemplo a quién se frota).
func entrar(_datos := {}) -> void:
	pass


## Al salir (limpiar lo que puso al entrar).
func salir() -> void:
	pass


## Cada cuadro de física, antes de moverse (move_and_slide lo hace Felipe después).
func fisica(_delta: float, _direccion: float) -> void:
	pass


## Terminó una animación sin bucle.
func animacion_terminada() -> void:
	pass
