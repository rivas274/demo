class_name Agenda
extends RefCounted
## La Agenda de Su Majestad: la lista de travesuras de un nivel (un "día"), como la lista de Untitled Goose Game.
## Cada travesura tiene nombre con la voz de Felipe, cuarto, si es secreta ("???" hasta cumplirla), una recompensa
## útil (nunca puntos) y la frase que dice al cumplirla. El nivel llama avanzar(id) cuando pasa la travesura;
## la agenda avisa con `cumplida` y quien escucha entrega la recompensa (Recompensas) y muestra el cartel.
##
## Formato de cada travesura:
##   id, nombre, cuarto, secreta (bool), meta (veces, 1 por defecto), nota (pista chica, opcional),
##   recompensa: {"tipo": "snack" | "calcetin" | "foto" | "camino", "cantidad": int, "id": String (camino), "texto": String}
##   frase: [texto, ánimo del retrato de Felipe]

signal cumplida(travesura: Dictionary)
## Sumó un paso a una travesura de varias veces, sin cumplirla todavía.
signal progreso(travesura: Dictionary)

## Nivel 1, "La Gran Fuga" (propuesta v4, sección 3): 8 líneas, 3 secretas.
const NIVEL_1 := [
	{"id": "perdon", "nombre": "AGENDA_ROMPER_ALGO_Y_QUE", "cuarto": "sala", "secreta": false,
		"recompensa": {"tipo": "snack", "cantidad": 1, "texto": "RECOMPENSA_SNACK_GUARDADO"},
		"frase": ["FELIPE_AGENDA_CARISMA_1_CONSECUENCIAS_0", 7]},
	{"id": "sofa", "nombre": "AGENDA_ARANAR_EL_SOFA_NUEVO", "cuarto": "sala", "secreta": false,
		"recompensa": {"tipo": "calcetin", "cantidad": 1, "texto": "RECOMPENSA_CALCETIN"},
		"frase": ["FELIPE_AGENDA_AHORA_SI_PARECE_NUESTRO", 4]},
	{"id": "popo", "nombre": "AGENDA_POPO_TACTICO_EN_LA", "cuarto": "recibidor", "secreta": true,
		"recompensa": {"tipo": "foto", "cantidad": 1, "texto": "RECOMPENSA_FOTO_VERGONZOSA"},
		"frase": ["FELIPE_AGENDA_ARTE_CONCEPTUAL_ELLA_NO", 7]},
	{"id": "almuerzo", "nombre": "AGENDA_ROBAR_EL_ALMUERZO_DE", "cuarto": "cocina", "secreta": false,
		"recompensa": {"tipo": "snack", "cantidad": 2, "texto": "RECOMPENSA_2_SNACKS"},
		"frase": ["FELIPE_AGENDA_DIETA_CANCELADA_POR_FUERZA", 6]},
	{"id": "laser", "nombre": "AGENDA_IGNORAR_EL_LASER", "cuarto": "pasillo", "secreta": true,
		"recompensa": {"tipo": "foto", "cantidad": 1, "texto": "RECOMPENSA_FOTO_VERGONZOSA"},
		"frase": ["FELIPE_AGENDA_NO_PERSIGO_PUNTITOS_LOS", 0]},
	{"id": "cajon", "nombre": "AGENDA_SAQUEAR_EL_CAJON_DE", "cuarto": "dormitorio", "secreta": false,
		"recompensa": {"tipo": "calcetin", "cantidad": 1, "texto": "RECOMPENSA_CALCETIN"},
		"frase": ["FELIPE_AGENDA_INVENTARIO", 7]},
	{"id": "teclado", "nombre": "AGENDA_PISAR_EL_TECLADO_DE", "cuarto": "estudio", "secreta": true,
		"recompensa": {"tipo": "foto", "cantidad": 1, "texto": "RECOMPENSA_MANCHAS_EXTRA_EN_LA"},
		"frase": ["FELIPE_AGENDA_JJJJJJJJJJ_MI_MEJOR_OBRA", 7]},
	{"id": "desenchufar", "nombre": "AGENDA_DESENCHUFAR_A_A_S", "cuarto": "estudio", "secreta": false,
		"recompensa": {"tipo": "camino", "id": "balcon", "texto": "RECOMPENSA_CAMINO_EL_BALCON"},
		"frase": ["FELIPE_AGENDA_LIMPIEZA_CANCELADA", 7]},
]

var travesuras: Array = []
## id -> veces que lleva.
var avance := {}
## ids cumplidos, en el orden en que se cumplieron.
var orden_cumplidas: Array[String] = []


func _init(lista: Array = NIVEL_1) -> void:
	travesuras = lista
	for t: Dictionary in travesuras:
		avance[t["id"]] = 0


func datos(id: String) -> Dictionary:
	for t: Dictionary in travesuras:
		if t["id"] == id:
			return t
	return {}


func esta_cumplida(id: String) -> bool:
	return orden_cumplidas.has(id)


func es_secreta(id: String) -> bool:
	return bool(datos(id).get("secreta", false))


func meta(id: String) -> int:
	return int(datos(id).get("meta", 1))


## Lo que se lee en la libreta: "???" si es secreta y no se ha cumplido (al cumplirla se revela).
func nombre_visible(id: String) -> String:
	if es_secreta(id) and not esta_cumplida(id):
		return "???"
	return TranslationServer.translate(String(datos(id).get("nombre", "")))


func texto_recompensa(id: String) -> String:
	if es_secreta(id) and not esta_cumplida(id):
		return "???"
	return TranslationServer.translate(String((datos(id).get("recompensa", {}) as Dictionary).get("texto", "")))


## Suma un paso a la travesura. Devuelve true si con esto se cumplió (solo la primera vez).
func avanzar(id: String) -> bool:
	if esta_cumplida(id) or not avance.has(id):
		return false
	avance[id] += 1
	var t := datos(id)
	if avance[id] < meta(id):
		progreso.emit(t)
		return false
	orden_cumplidas.append(id)
	cumplida.emit(t)
	return true


func total() -> int:
	return travesuras.size()


func cumplidas() -> int:
	return orden_cumplidas.size()


func total_secretas() -> int:
	return travesuras.filter(func(t: Dictionary) -> bool: return bool(t.get("secreta", false))).size()


func secretas_cumplidas() -> int:
	return orden_cumplidas.filter(func(id: String) -> bool: return es_secreta(id)).size()


func completa() -> bool:
	return cumplidas() == total()


## Cuartos en el orden en que aparecen (la libreta agrupa por cuarto).
func cuartos() -> Array[String]:
	var lista: Array[String] = []
	for t: Dictionary in travesuras:
		var cuarto := String(t.get("cuarto", ""))
		if not lista.has(cuarto):
			lista.append(cuarto)
	return lista
