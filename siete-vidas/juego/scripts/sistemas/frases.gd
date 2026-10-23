class_name Frases
extends RefCounted
## La voz de Felipe (aristócrata ofendido que aprendió a escribir en los comentarios de internet) y las réplicas
## de Valeria (seca y cansada: teletrabaja y lo malcría igual; «bebito gordito» solo al perdonarlo; redes, de pasada;
## reglas de su voz en memoria/02-guia-felipe.md, «Voz de Valeria»). Del prototipo de travesuras aprobado.
## Cada frase: [texto, ánimo del retrato] (ver Dialogo.PERSONAJES). Todas caben en 1 o 2 líneas (la prueba lo mide).

const FELIPE := {
	"derrota_raton": [
		["FELIPE_DERROTA_RATON_1", 7],
		["FELIPE_DERROTA_RATON_2", 7],
		["FELIPE_DERROTA_RATON_3", 4],
		["FELIPE_DERROTA_RATON_4", 0],
	],
	"derrota_aspi": [
		["FELIPE_DERROTA_ASPI_1", 7],
		["FELIPE_DERROTA_ASPI_2", 4],
	],
	"zoomies_choque": [
		["FELIPE_ZOOMIES_CHOQUE_1", 1],
		["FELIPE_ZOOMIES_CHOQUE_2", 5],
		["FELIPE_ZOOMIES_CHOQUE_3", 7],
	],
	"tirar": [
		["FELIPE_TIRAR_1", 7],
		["FELIPE_TIRAR_2", 4],
		["FELIPE_TIRAR_3", 0],
		["FELIPE_TIRAR_4", 7],
	],
	"aranar": [
		["FELIPE_ARANAR_1", 7],
		["FELIPE_ARANAR_2", 4],
		["FELIPE_ARANAR_3", 0],
	],
	"aranar_critico": [
		["FELIPE_ARANAR_CRITICO_1", 7],
	],
	"comer": [
		["FELIPE_COMER_1", 3],
		["FELIPE_COMER_2", 0],
	],
	"snack": [
		["FELIPE_SNACK_1", 6],
		["FELIPE_SNACK_2", 3],
	],
	"sin_snacks": [
		["FELIPE_SIN_SNACKS_1", 2],
		["FELIPE_SIN_SNACKS_2", 1],
	],
	"bolsillo_lleno": [
		["FELIPE_BOLSILLO_LLENO_1", 0],
	],
	"maullar": [
		["FELIPE_MAULLAR_1", 0],
		["FELIPE_MAULLAR_2", 3],
		["FELIPE_MAULLAR_3", 6],
	],
	"recoger_calcetin": [
		["FELIPE_RECOGER_CALCETIN_1", 7],
		["FELIPE_RECOGER_CALCETIN_2", 4],
		["FELIPE_RECOGER_CALCETIN_3", 6],
	],
	"recoger_snack": [
		["FELIPE_RECOGER_SNACK_1", 3],
		["FELIPE_RECOGER_SNACK_2", 7],
	],
	"recoger_foto": [
		["FELIPE_RECOGER_FOTO_1", 6],
	],
	"rascador_publico": [
		["FELIPE_RASCADOR_PUBLICO_1", 7],
		["FELIPE_RASCADOR_PUBLICO_2", 4],
	],
	"rascador_solo": [
		["FELIPE_RASCADOR_SOLO_1", 1],
		["FELIPE_RASCADOR_SOLO_2", 0],
		["FELIPE_RASCADOR_SOLO_3", 5],
	],
	"rascador_bis": [
		["FELIPE_RASCADOR_BIS_1", 5],
	],
	"garras_afiladas": [
		["FELIPE_GARRAS_AFILADAS_1", 7],
	],
	"ranura": [
		["FELIPE_RANURA_1", 7],
	],
	"agenda_completa": [
		["FELIPE_AGENDA_COMPLETA_1", 7],
	],
	# Nivel 1 v4 (propuesta, sección 2): una por momento, casi todas salen una sola vez.
	"meta": [["FELIPE_META_1", 0]],
	"inicio": [["FELIPE_INICIO_1", 0]],
	"cajas": [["FELIPE_CAJAS_1", 4]],
	"cajas_arriba": [["FELIPE_CAJAS_ARRIBA_1", 7]],
	"cajas_tiradas": [["FELIPE_CAJAS_TIRADAS_1", 7]],
	"tazon": [["FELIPE_TAZON_1", 2]],
	"cocina_cerrada": [["FELIPE_COCINA_CERRADA_1", 1]],
	"balcon_cerrado": [["FELIPE_BALCON_CERRADO_1", 1]],
	"robot": [["FELIPE_ROBOT_1", 0]],
	"robot_registra": [["FELIPE_ROBOT_REGISTRA_1", 0]],
	"puerta_abierta": [["FELIPE_PUERTA_ABIERTA_1", 7]],
	"ropa": [["FELIPE_ROPA_1", 7]],
	"paloma": [["FELIPE_PALOMA_1", 4]],
	# La puerta del baño (lugar insinuado para la maña futura «Abrir puertas»).
	"bano": [["FELIPE_BANO_1", 4]],
	"bano_manija": [["FELIPE_BANO_MANIJA_1", 1]],
	"laser_visto": [["FELIPE_LASER_VISTO_1", 1]],
	"cojin": [["FELIPE_COJIN_1", 7]],
	"cortina": [["FELIPE_CORTINA_1", 2]],
	"quien_cerro": [["FELIPE_QUIEN_CERRO_1", 2]],
	"balcon": [["FELIPE_BALCON_1", 0]],
	"aterrice": [["FELIPE_ATERRICE_1", 7]],
	"limpieza": [["FELIPE_LIMPIEZA_1", 7]],
	## A.S.P.I. escupe la montaña de pelusa (revisión 2026-10-23): la primera vez, la frase de siempre.
	"devolucion": [["FELIPE_DEVOLUCION_1", 7]],
	"devolucion_otra": [["FELIPE_DEVOLUCION_2", 4], ["FELIPE_DEVOLUCION_3", 7]],
	## Se corta la luz en la fase 3 (cortocircuito de A.S.P.I.).
	"apagon": [["FELIPE_APAGON_1", 7]],
	## Esparce la montaña de pelusa / la deja en corto en un charco: se divierte (alegre y juguetón, 2026-10-23).
	"esparcir": [["FELIPE_ESPARCIR_1", 6], ["FELIPE_ESPARCIR_2", 6]],
	"en_corto": [["FELIPE_EN_CORTO_1", 6], ["FELIPE_EN_CORTO_2", 6]],
	## Al ganar, mira lo que hizo con orgullo, según la nota de «Arte gatuno».
	"arte_aficionado": [["FELIPE_ARTE_AFICIONADO_1", 6]],
	"arte_obra": [["FELIPE_ARTE_OBRA_1", 6]],
	## Al ganar, mira el estudio destruido con orgullo.
	"estudio_destruido": [["FELIPE_ESTUDIO_DESTRUIDO_1", 0]],
}

const VALERIA := {
	## Desde abajo, al oír el estudio destruido (más del 85 % de «Arte gatuno»). Fuera de cuadro.
	"grito_estudio": [["VALERIA_GRITO_ESTUDIO_1", 1]],
	## Rascador con público: perdón al instante (y graba en silencio).
	"rascador": [["VALERIA_RASCADOR_1", 3]],
	## Rascador otra vez en la misma visita (el bis no se cobra).
	"rascador_bis": [["VALERIA_RASCADOR_BIS_1", 0]],
	"perdona": [
		["VALERIA_PERDONA_1", 2],
		["VALERIA_PERDONA_2", 2],
	],
	"regana": [
		["VALERIA_REGANA_1", 1],
		["VALERIA_REGANA_2", 1],
	],
	# Nivel 1 v4.
	"vaso": [["VALERIA_VASO_1", 1]],
	"sofa_atrapado": [["VALERIA_SOFA_ATRAPADO_1", 1]],
	"sofa_roto": [["VALERIA_SOFA_ROTO_1", 1]],
	"cocina_dieta": [["VALERIA_COCINA_DIETA_1", 0]],
	"cocina_abre": [["VALERIA_COCINA_ABRE_1", 0]],
	"popo": [["VALERIA_POPO_1", 1]],
	"llaves": [["VALERIA_LLAVES_1", 1]],
	"cajas": [["VALERIA_CAJAS_1", 1]],
	"cajas_audifonos": [["VALERIA_CAJAS_AUDIFONOS_1", 1]],
	"almuerzo": [["VALERIA_ALMUERZO_1", 1]],
	"audifonos": [["VALERIA_AUDIFONOS_1", 0]],
	"maullido": [["VALERIA_MAULLIDO_1", 2]],
}

var _ultima := {}


## Elige una frase del evento sin repetir la anterior. Devuelve [texto, ánimo] o [] si no hay.
func elegir(quien: String, evento: String) -> Array:
	var tabla: Dictionary = FELIPE if quien == "felipe" else VALERIA
	if not tabla.has(evento):
		return []
	var lista: Array = tabla[evento]
	var clave := quien + ":" + evento
	var indice := randi() % lista.size()
	if lista.size() > 1 and _ultima.get(clave, -1) == indice:
		indice = (indice + 1 + randi() % (lista.size() - 1)) % lista.size()
	_ultima[clave] = indice
	return lista[indice]
