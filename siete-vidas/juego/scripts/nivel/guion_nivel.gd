class_name GuionNivel
extends Node
## Guion de un nivel: lo propio de ese nivel (sus personajes, sus objetos, sus eventos y su arte), separado del
## constructor genérico (Nivel). Va como nodo hijo «Guion» de la escena del nivel; el Nivel lo llama en este orden:
##   datos_del_nivel() → crear_fondo() → (el Nivel pone piezas, sistemas y puertas) → preparar() →
##   al_terminar_de_armar() → y cada cuadro de física, cada_cuadro(delta).
## El guion de cada nivel extiende este (scripts/niveles/nivel_1/guion_nivel_1.gd) y escucha las señales del Nivel
## (habitacion_cambiada, puerta_cerrada_probada, escalera_bajada...). Receta: siete-vidas/memoria/07-arquitectura.md.

## El nivel que lo dirige (lo pone el Nivel antes de llamar a nada).
var nivel: Nivel


## Los datos para armar el nivel (cuartos, piezas, puertas...). Obligatorio.
func datos_del_nivel() -> DatosNivel:
	return DatosNivel.new()


## Antes de las piezas sólidas: el fondo y el arte de las capas de atrás (todo lo que va detrás de las repisas).
func crear_fondo() -> void:
	pass


## Después de las puertas: personajes, objetos, eventos y el resto del decorado.
func preparar() -> void:
	pass


## Al final del armado (la cámara ya está en el primer cuarto): luces y lo que dependa de todo lo demás.
func al_terminar_de_armar() -> void:
	pass


## Cada cuadro de física, después de la cámara, los descansos y las primeras frases (no corre al terminar el nivel).
func cada_cuadro(_delta: float) -> void:
	pass
