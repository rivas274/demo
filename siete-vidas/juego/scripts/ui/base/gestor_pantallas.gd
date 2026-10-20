class_name GestorPantallas
extends Node
## Pila de pantallas que tapan el juego (título, pausa, libreta, resumen del día...). Un solo lugar decide:
## - qué pantalla está arriba (solo esa responde a las teclas: es_la_de_arriba);
## - cuándo el juego queda en pausa: mientras haya alguna pantalla que pausa en la pila.
## Cerrar la pausa con la libreta abierta debajo no despausa el juego: queda la libreta.
## Solo pausa y despausa lo que pausó él: si el árbol ya estaba en pausa por otra cosa (la entrada de un jefe), no
## lo toca.
##
## Uso: GestorPantallas.de(self).abrir(pantalla) / .cerrar(pantalla). Hay uno por árbol (grupo GRUPO); si no hay,
## de() crea uno colgado del nodo que lo pide (pruebas sueltas de una pantalla).

## Cambió la pantalla de arriba (null si no queda ninguna).
signal cambio(arriba: Node)

const GRUPO := "gestor_pantallas"

## Pantallas abiertas, de abajo hacia arriba: [{"nodo", "pausa"}].
var pila: Array[Dictionary] = []
var _pauso := false


func _init() -> void:
	name = "GestorPantallas"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _enter_tree() -> void:
	add_to_group(GRUPO)


## El gestor del árbol de `nodo` (lo crea si no hay).
static func de(nodo: Node) -> GestorPantallas:
	var gestor: GestorPantallas = null
	if nodo.is_inside_tree():
		gestor = nodo.get_tree().get_first_node_in_group(GRUPO)
	if gestor == null:
		gestor = GestorPantallas.new()
		nodo.add_child(gestor)
	return gestor


## Pone la pantalla arriba de todo. Con `pausa`, el juego se detiene mientras esté abierta.
func abrir(pantalla: Node, pausa := true) -> void:
	cerrar(pantalla, false)
	pila.append({"nodo": pantalla, "pausa": pausa})
	if not pantalla.tree_exiting.is_connected(_al_salir):
		pantalla.tree_exiting.connect(_al_salir.bind(pantalla))
	_actualizar()


## Saca la pantalla de la pila (esté arriba o no).
func cerrar(pantalla: Node, avisar := true) -> void:
	for i in range(pila.size() - 1, -1, -1):
		if pila[i]["nodo"] == pantalla:
			pila.remove_at(i)
	if avisar:
		_actualizar()


func abierta(pantalla: Node) -> bool:
	return pila.any(func(e: Dictionary) -> bool: return e["nodo"] == pantalla)


func arriba() -> Node:
	return pila[-1]["nodo"] if not pila.is_empty() else null


## ¿Esta pantalla recibe las teclas? (está arriba, o no hay ninguna y la pregunta es para el juego: null).
func es_la_de_arriba(pantalla: Node) -> bool:
	return arriba() == pantalla


func _al_salir(pantalla: Node) -> void:
	if abierta(pantalla):
		cerrar(pantalla)


func _actualizar() -> void:
	var quiere_pausa := pila.any(func(e: Dictionary) -> bool: return e["pausa"])
	if is_inside_tree():
		var arbol := get_tree()
		if quiere_pausa and not arbol.paused:
			arbol.paused = true
			_pauso = true
		elif quiere_pausa and arbol.paused and not _pauso:
			# Ya estaba en pausa por otra cosa: desde ahora la pausa también es nuestra.
			_pauso = true
		elif not quiere_pausa and _pauso:
			arbol.paused = false
			_pauso = false
	cambio.emit(arriba())
