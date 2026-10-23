class_name Profundidad
extends Node
## Pieza de profundidad (v5, el sistema de capas por rol): TODO nodo del mundo que se dibuja con su propia capa la
## lleva, con un **rol** (Capas.Rol) como dato, y su z sale de `Capas.z_para(rol, contexto)`. Nada pone su z_index a
## mano (lo comprueba `prueba_capas.gd`). Se cuelga del nodo que dibuja (su padre) y le pone el z ABSOLUTO.
## Los roles que dependen de Felipe (SALTABLE, APOYADO, ENEMIGO_PISO, JUGADOR) se recalculan solo cuando Felipe cambia
## de superficie (`felipe_cambio`, lo llama VigiaSuperficie al aterrizar y al despegar), no cada cuadro.
## Cómo agregar algo nuevo al mundo: `Profundidad.poner(nodo, Capas.Rol.<rol>)` (con su superficie si es SALTABLE o
## APOYADO) y listo. Los objetos y enemigos traen el rol en sus datos (DatosObjeto.rol, DatosEnemigo.rol).

const GRUPO := "profundidad"
## Los que cambian cuando Felipe cambia de superficie.
const GRUPO_DEPENDE := "profundidad_depende"
const DEPENDEN := [Capas.Rol.SALTABLE, Capas.Rol.APOYADO, Capas.Rol.ENEMIGO_PISO, Capas.Rol.JUGADOR]

## Dónde está parado Felipe ahora ("piso", el nombre de un mueble o "aire"): lo comparten todos.
static var superficie_felipe := "piso"

var rol: int = Capas.Rol.JUEGO
## SALTABLE: las superficies (piezas) que dibuja; APOYADO: la que lo sostiene.
var superficies := PackedStringArray()
## SALTABLE: si puede subir un escalón con Felipe encima (no, si un saltable de adelante se le cruza).
var puede_subir := true
## ENEMIGO_PISO: delante de Felipe cuando los dos están en el piso (DatosEnemigo.delante_de_felipe).
var delante := false
## JUGADOR: delante de los humanos (lo decide el nivel) y mientras imagina.
var delante_de_humanos := false
var imaginando := false
## FONDO: orden hacia adelante (0 a 10). CONTORNO: el z de lo que contornea.
var orden := 0
var z := 0


func _init() -> void:
	name = "Profundidad"


## Le pone (o le cambia) el rol a `nodo` y le aplica su z ya. Devuelve la pieza.
static func poner(nodo: CanvasItem, nuevo_rol: int, sus_superficies := PackedStringArray(), con_orden := 0) -> Profundidad:
	var pieza: Profundidad = de(nodo)
	if pieza == null:
		pieza = Profundidad.new()
		nodo.add_child(pieza)
	pieza.superficies = sus_superficies
	pieza.orden = con_orden
	pieza.cambiar_rol(nuevo_rol)
	return pieza


## La pieza de profundidad de `nodo` (o null).
static func de(nodo: Node) -> Profundidad:
	if nodo == null:
		return null
	return nodo.get_node_or_null("Profundidad") as Profundidad


## Felipe aterrizó o despegó: se recalculan solo los roles que dependen de él.
static func felipe_cambio(arbol: SceneTree, superficie: String) -> void:
	superficie_felipe = superficie
	for nodo in arbol.get_nodes_in_group(GRUPO_DEPENDE):
		(nodo as Profundidad).aplicar()


func _enter_tree() -> void:
	add_to_group(GRUPO)
	aplicar()


func cambiar_rol(nuevo_rol: int) -> void:
	rol = nuevo_rol
	if rol in DEPENDEN:
		add_to_group(GRUPO_DEPENDE)
	elif is_in_group(GRUPO_DEPENDE):
		remove_from_group(GRUPO_DEPENDE)
	aplicar()


func contexto() -> Dictionary:
	return {
		"superficie_felipe": superficie_felipe, "superficies": superficies, "puede_subir": puede_subir,
		"delante": delante, "delante_de_humanos": delante_de_humanos, "imaginando": imaginando, "orden": orden, "z": z,
	}


## Pone el z del rol en el nodo que dibuja (su padre), como z absoluto.
func aplicar() -> void:
	var item := get_parent() as CanvasItem
	if item == null:
		return
	item.z_as_relative = false
	item.z_index = Capas.z_para(rol, contexto())
