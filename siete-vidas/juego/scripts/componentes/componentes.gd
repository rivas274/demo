class_name Componentes
extends RefCounted
## Ayudante para las piezas (componentes) de una entidad. Una entidad (el ratón, A.S.P.I., la caja, un vaso) es un nodo
## con hijos que hacen un solo trabajo cada uno: Vida, RecibeGolpes, HaceDano, MovimientoPatrulla, Tirable,
## OyeMaullido, Asustable, SueltaRecompensa, SombraContacto. Quien necesita una pieza la pide con
## `Componentes.de(nodo, Vida)` en vez de preguntar `has_method(...)`: si la entidad no la lleva, devuelve null.
## Arquitectura completa: siete-vidas/memoria/07-arquitectura.md.

## Grupo de todo lo que responde al botón de acción (comer, tirar, arañar, abrir...). Felipe busca aquí lo que tiene
## al alcance y el Indicador muestra su verbo.
const INTERACTUABLES := "interactuables"
## Grupo de las entidades que reciben zarpazos y a las que les puede caer algo encima (ratones, A.S.P.I., la caja).
const ENEMIGOS := "enemigos"


## La pieza del tipo pedido: el nodo mismo si es de ese tipo, o su primer hijo que lo sea; null si no la lleva.
## Ejemplo: `var vida := Componentes.de(aspi, Vida) as Vida`.
static func de(nodo: Node, tipo: Script) -> Node:
	if nodo == null or not is_instance_valid(nodo):
		return null
	if is_instance_of(nodo, tipo):
		return nodo
	for hijo in nodo.get_children():
		if is_instance_of(hijo, tipo):
			return hijo
	return null


## El nivel que contiene a `nodo` (el que suena, da logros y suelta recompensas); null fuera de un nivel.
static func nivel(nodo: Node) -> Sala:
	var actual := nodo
	while actual != null:
		if actual is Sala:
			return actual
		actual = actual.get_parent()
	return null
