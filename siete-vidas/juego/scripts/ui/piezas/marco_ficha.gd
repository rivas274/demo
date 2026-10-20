class_name MarcoFicha
extends NinePatchRect
## Pieza de interfaz: el marco de madera y oro de una ficha (kit «Decreto real»): una ventana para un retrato arriba y
## un cuerpo de pergamino abajo. Se estira en 9 partes (las esquinas y la ventana quedan a su tamaño de pixel; se
## alargan los bordes rectos y el cuerpo), así sirve para fichas de cualquier tamaño. Dice dónde quedan la ventana y
## el cuerpo para poner encima el retrato y el contenido. Escena: escenas/ui/marco_ficha.tscn.

## Ventana del retrato en el dibujo original (120×167): desde la esquina de arriba a la izquierda y hasta el borde
## de la derecha (lo que sobra a la derecha).
const VENTANA_IZQUIERDA := 22.0
const VENTANA_DERECHA := 22.0
const VENTANA_ARRIBA := 21.0
const VENTANA_ALTO := 72.0
## Cuerpo de pergamino: empieza en y = 103 y deja 12 px de marco a los lados y abajo.
const CUERPO_ARRIBA := 103.0
const CUERPO_MARGEN := 12.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## La ventana del retrato, en coordenadas de la pieza.
func ventana() -> Rect2:
	return Rect2(VENTANA_IZQUIERDA, VENTANA_ARRIBA, size.x - VENTANA_IZQUIERDA - VENTANA_DERECHA, VENTANA_ALTO)


## El cuerpo de pergamino, en coordenadas de la pieza.
func cuerpo() -> Rect2:
	return Rect2(CUERPO_MARGEN, CUERPO_ARRIBA, size.x - CUERPO_MARGEN * 2.0, size.y - CUERPO_ARRIBA - CUERPO_MARGEN)
