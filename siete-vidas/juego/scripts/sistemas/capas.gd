class_name Capas
extends RefCounted
## Tabla ÚNICA de capas del juego (B1 y G7 de la revisión 3): qué se dibuja encima de qué. Todo nodo del nivel toma su
## z_index (en el mundo) o su `layer` (CanvasLayer, en pantalla) de aquí; ninguno inventa su número.
## Los z del mundo son ABSOLUTOS: un nodo hijo que usa una capa de la tabla pone `z_as_relative = false`
## (usar() lo hace por él).
##
## Mundo (z_index), de atrás hacia adelante:
##   FONDO_LEJANO   -40 a -30  cielo y ciudades con parallax (FondoApartamento.CAPAS)
##   PARED          -20        pared de cada cuarto con las ventanas recortadas
##   FACHADA        -19        fachada y toldo bajo el balcón (salto final)
##   ARTE_PARED      -3        ventanas, cuadros, alacenas: lo colgado en la pared
##   ESCALERA        -2        peldaños, vano y descanso de la escalera de fondo
##   PUERTAS         -2        puertas (y su luz)
##   MUEBLES         -1        arte de muebles, sofá, rascador, cajas de la mudanza, decorado, nido, piezas dibujadas
##   TRAS_FELIPE     -1        lo que deja Felipe detrás de sí: estela de fantasmas, líneas de velocidad, polvo del jugo
##   JUEGO            0        Felipe, A.S.P.I., ratones, vasos, comida, recompensas, manchas del piso
##   MARCAS           1        arañazos sobre lo arañable
##   JUEGO_CERCA      1        lo del piso más cerca de la cámara que Felipe (A.S.P.I.: DatosEnemigo.delante_de_felipe)
##   PERSONAJES       2        SOLO los humanos (Valeria): 200 px, más cerca de la cámara que el escenario. Felipe pasa
##                             DETRÁS de ella y se ve su silueta (SiluetaTapada) en la parte que ella tapa (plan 2026-10-20)
##   JUEGO_DELANTE    3        Felipe parado sobre algo que queda delante de los humanos (el asiento del sofá junto a
##                             Valeria: Nivel1.DELANTE_DE_HUMANOS); en el piso vuelve a JUEGO
##   PRIMER_PLANO     4        pasamanos de la escalera (delante de Felipe y de Valeria)
##   LUZ              5        rayos de luz de las ventanas
##   ESTELA          10        estela de Felipe (Zoomies), palabras del ensayo de A.S.P.I.
##   IMAGINACION     25        la imaginación de Felipe (estudio en llamas y A.S.P.I. gigante): tapa TODO el escenario
##   FELIPE_IMAGINANDO 26      Felipe mientras imagina (queda delante de su propia imaginación)
##   EFECTOS         30        viento de la succión, «¡LLENO!», papeles que vuelan, bolas de pelo, polvo
##   CENSURA         40        pegatina de la censura irónica
##   INDICADOR       50        contorno y burbuja del Indicador
##
## Pantalla (CanvasLayer.layer), de abajo hacia arriba:
##   INTERFAZ 1 (corazones), JUGO 5 (palabras y destello), HUD 6 (agenda y carteles), DIALOGO 7, AVISOS 8 (logros),
##   LIBRETA 9, RESUMEN 10, FUNDIDO 12 (negro de las puertas: tapa también diálogo, carteles y logros),
##   JEFE 30 (presentación y barra del jefe), PANTALLAS 40 (título, introducción, pausa: tapan todo).

const FONDO_LEJANO := -40
const PARED := -20
const FACHADA := -19
const ARTE_PARED := -3
const ESCALERA := -2
const PUERTAS := -2
const MUEBLES := -1
const TRAS_FELIPE := -1
const JUEGO := 0
const MARCAS := 1
const JUEGO_CERCA := 1
const PERSONAJES := 2
const JUEGO_DELANTE := 3
const PRIMER_PLANO := 4
const LUZ := 5
const ESTELA := 10
const IMAGINACION := 25
const FELIPE_IMAGINANDO := 26
const EFECTOS := 30
const CENSURA := 40
const INDICADOR := 50

const CAPA_INTERFAZ := 1
const CAPA_JUGO := 5
const CAPA_HUD := 6
const CAPA_DIALOGO := 7
const CAPA_AVISOS := 8
const CAPA_LIBRETA := 9
const CAPA_RESUMEN := 10
const CAPA_FUNDIDO := 12
const CAPA_JEFE := 30
const CAPA_PANTALLAS := 40

## La tabla del mundo en orden (para la prueba y la memoria): [nombre, z].
const MUNDO := [
	["PARED", PARED], ["FACHADA", FACHADA], ["ARTE_PARED", ARTE_PARED], ["ESCALERA", ESCALERA], ["PUERTAS", PUERTAS],
	["MUEBLES", MUEBLES], ["TRAS_FELIPE", TRAS_FELIPE], ["JUEGO", JUEGO], ["MARCAS", MARCAS], ["JUEGO_CERCA", JUEGO_CERCA], ["PERSONAJES", PERSONAJES],
	["JUEGO_DELANTE", JUEGO_DELANTE], ["PRIMER_PLANO", PRIMER_PLANO],
	["LUZ", LUZ], ["ESTELA", ESTELA], ["IMAGINACION", IMAGINACION],
	["FELIPE_IMAGINANDO", FELIPE_IMAGINANDO], ["EFECTOS", EFECTOS], ["CENSURA", CENSURA], ["INDICADOR", INDICADOR],
]
## La tabla de la pantalla en orden: [nombre, capa].
const PANTALLA := [
	["INTERFAZ", CAPA_INTERFAZ], ["JUGO", CAPA_JUGO], ["HUD", CAPA_HUD], ["DIALOGO", CAPA_DIALOGO], ["AVISOS", CAPA_AVISOS],
	["LIBRETA", CAPA_LIBRETA], ["RESUMEN", CAPA_RESUMEN], ["FUNDIDO", CAPA_FUNDIDO], ["JEFE", CAPA_JEFE], ["PANTALLAS", CAPA_PANTALLAS],
]


## Pone a un nodo en una capa del mundo (z absoluto, sin importar su padre).
static func usar(nodo: CanvasItem, z: int) -> void:
	nodo.z_as_relative = false
	nodo.z_index = z


## z con el que se dibuja de verdad un nodo (sumando los padres mientras sea relativo).
static func z_efectivo(nodo: CanvasItem) -> int:
	var z := 0
	var actual: Node = nodo
	while actual is CanvasItem:
		var item := actual as CanvasItem
		z += item.z_index
		if not item.z_as_relative:
			break
		actual = actual.get_parent()
	return z
