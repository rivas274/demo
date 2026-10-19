# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
class_name Agenda
extends RefCounted
## La Agenda de Su Majestad: la lista de travesuras del día (como la lista de Untitled Goose Game).
## 4 visibles y 3 secretas ("???" hasta cumplirlas). Cada una tiene nombre con la voz de Felipe,
## una recompensa útil (no puntos) y la frase que dice al cumplirla.

signal cumplida(travesura: Dictionary)
signal progreso(travesura: Dictionary)

## id, nombre (como lo escribe Felipe), nota (pista chica, opcional), secreta, recompensa, frase [texto, retrato], meta.
const TRAVESURAS := [
	{
		"id": "florero",
		"nombre": "Derribar el florero heredado de la abuela",
		"nota": "",
		"secreta": false,
		"recompensa": "Foto vergonzosa",
		"frase": ["La abuela tenía mal gusto. Lo corregí.", 7],
		"meta": 1,
	},
	{
		"id": "sofa",
		"nombre": "Arañar el sofá nuevo (todavía tiene el plástico)",
		"nota": "",
		"secreta": false,
		"recompensa": "Calcetín",
		"frase": ["Ahora sí parece nuestro.", 4],
		"meta": 1,
	},
	{
		"id": "tele",
		"nombre": "Tirar el control mientras Valeria ve su serie",
		"nota": "la ve cuando está de buenas",
		"secreta": false,
		"recompensa": "Camino: la persiana",
		"frase": ["Spoiler: se cortó la serie.", 7],
		"meta": 1,
	},
	{
		"id": "perdon",
		"nombre": "Que Valeria me perdone 2 veces",
		"nota": "ronronear cerca",
		"secreta": false,
		"recompensa": "Snack por perdón",
		"frase": ["Dos perdones. El carisma no se gasta.", 6],
		"meta": 2,
	},
	{
		"id": "encima",
		"nombre": "Tirarle algo encima a Valeria",
		"nota": "",
		"secreta": true,
		"recompensa": "Snack de emergencia",
		"frase": ["Fue un regalo. Por vía aérea.", 7],
		"meta": 1,
	},
	{
		"id": "aspiradora",
		"nombre": "Intimidar a la aspiradora",
		"nota": "",
		"secreta": true,
		"recompensa": "Calcetín (se lo había tragado)",
		"frase": ["Que te sirva de lección, electrodoméstico.", 8],
		"meta": 1,
	},
	{
		"id": "junto_rascador",
		"nombre": "Arañar el sofá justo al lado del rascador nuevo",
		"nota": "",
		"secreta": true,
		"recompensa": "Foto vergonzosa (tras el rascador)",
		"frase": ["El rascador es para mirarlo. El sofá, para arañarlo.", 7],
		"meta": 1,
	},
]

## id -> cuánto lleva (para las de varias veces) y si está cumplida.
var avance := {}
var orden_cumplidas: Array[String] = []


func _init() -> void:
	for t: Dictionary in TRAVESURAS:
		avance[t["id"]] = 0


func datos(id: String) -> Dictionary:
	for t: Dictionary in TRAVESURAS:
		if t["id"] == id:
			return t
	return {}


func esta_cumplida(id: String) -> bool:
	return orden_cumplidas.has(id)


## Suma un paso a la travesura. Devuelve true si con esto se cumplió (solo la primera vez).
func avanzar(id: String) -> bool:
	if esta_cumplida(id):
		return false
	var t := datos(id)
	avance[id] += 1
	if avance[id] < int(t["meta"]):
		progreso.emit(t)
		return false
	orden_cumplidas.append(id)
	cumplida.emit(t)
	return true


func total() -> int:
	return TRAVESURAS.size()


func cumplidas() -> int:
	return orden_cumplidas.size()


func total_secretas() -> int:
	return TRAVESURAS.filter(func(t: Dictionary) -> bool: return t["secreta"]).size()


func secretas_cumplidas() -> int:
	return orden_cumplidas.filter(func(id: String) -> bool: return datos(id)["secreta"]).size()


func completa() -> bool:
	return cumplidas() == total()
