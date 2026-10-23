class_name Capas
extends RefCounted
## Tabla ÚNICA de capas del juego (B1 y G7 de la revisión 3): qué se dibuja encima de qué. Todo nodo del nivel toma su
## z_index (en el mundo) o su `layer` (CanvasLayer, en pantalla) de aquí; ninguno inventa su número.
## Los z del mundo son ABSOLUTOS: un nodo hijo que usa una capa de la tabla pone `z_as_relative = false`
## (usar() lo hace por él).
##
## **Sistema de profundidad (v5, decisión del creador del 2026-10-23: «clasificar todo, como el ratón y A.S.P.I.»).**
## Ningún nodo del mundo pone su z_index a mano: lleva la pieza `Profundidad` con un **rol** (enum Rol) y
## `Capas.z_para(rol, contexto)` resuelve su z con esta tabla. El contexto dice en qué superficie está Felipe (lo
## avisa `VigiaSuperficie` al aterrizar y al despegar, en el mismo cuadro) y lo propio de cada nodo (su superficie, si
## el enemigo va delante de Felipe en el piso, el orden del fondo). Reglas:
## - **Planos fijos:** fondo y pared < muebles (SALTABLE) < plano de juego (Felipe, A.S.P.I., lo que se toca) < efectos.
## - **SALTABLE** (mueble o superficie donde se sube): MUEBLES; con Felipe encima, SALTABLE_ACTIVO (un escalón más),
##   salvo que otro saltable que va delante se le cruce (`puede_subir` = false).
## - **APOYADO** (vaso, taza, macetas, libros sobre un saltable; guarda su superficie): con Felipe sobre ESA superficie,
##   APOYADO_DELANTE (apenas delante de Felipe: Felipe pasa por detrás); si no (en el piso, saltando delante del
##   mueble, en otra superficie), APOYADO (detrás de Felipe). Al caer pasa a OBJETO_JUEGO y en el piso a RESTO_PISO.
## - **RESTO_PISO:** lo tirado que quedó en el piso (pedazos, libros, notas, motas, charcos, manchas): detrás de
##   Felipe y de A.S.P.I., delante de los muebles.
## - **ENEMIGO_PISO** (A.S.P.I., ratones): siempre delante de todo saltable. Con Felipe en el piso, delante o detrás de
##   él según `DatosEnemigo.delante_de_felipe` (JUEGO_CERCA o ENEMIGO_DETRAS); con Felipe sobre un mueble o en el aire,
##   detrás de él (ENEMIGO_DETRAS).
## - **JUGADOR** (Felipe): JUEGO; JUEGO_DELANTE sobre lo que queda delante de los humanos (asiento del sofá junto a
##   Valeria) o cuando el nivel lo pide; FELIPE_IMAGINANDO mientras imagina (entrada del jefe).
## - **HUMANO** (Valeria): PERSONAJES.
##
## Mundo (z_index), de atrás hacia adelante:
##   FONDO_LEJANO   -40 a -30  cielo y ciudades con parallax (rol FONDO, con su orden)
##   PARED          -20        pared de cada cuarto con las ventanas recortadas
##   FACHADA        -19        fachada y toldo bajo el balcón (salto final)
##   ARTE_PARED     -16        ventanas, cuadros, alacenas, corcho: lo colgado en la pared; contorno del Indicador
##   ESCALERA       -15        peldaños, vano y descanso de la escalera de fondo
##   PUERTAS        -15        puertas (y su luz)
##   MUEBLES        -14        SALTABLE: arte de muebles, sofá, rascador, cajas de la mudanza, repisas
##   SALTABLE_ACTIVO -13       el saltable donde está Felipe
##   DECORADO       -12        lo dibujado sobre los muebles sin colisión (pantalla, teclado, nido, fuentes del desorden)
##   SOMBRAS        -11        sombras de contacto de lo que se mueve
##   RESTO_PISO     -10        lo tirado que quedó en el piso
##   VELO            -9        velo del fondo en la pelea (CalmaAspi): tapa lo de atrás, no lo jugable
##   APOYADO         -8        objeto sobre un saltable donde Felipe NO está
##   TRAS_FELIPE     -7        lo que deja Felipe detrás de sí: estela de fantasmas, líneas de velocidad, polvo del jugo
##   ENEMIGO_DETRAS  -6        enemigo del piso detrás de Felipe
##   OBJETO_JUEGO    -5        lo que se toca y no está apoyado: comida, recompensas, montañas, lo que cae
##   JUEGO            0        Felipe (JUGADOR)
##   APOYADO_DELANTE  1        objeto sobre la misma superficie que Felipe
##   MARCAS           1        arañazos, marcas de derrape, ropa sobre la cama
##   JUEGO_CERCA      2        enemigo del piso delante de Felipe (DatosEnemigo.delante_de_felipe)
##   PERSONAJES       3        SOLO los humanos (Valeria): Felipe pasa DETRÁS de ella y se ve su silueta
##   JUEGO_DELANTE    4        Felipe parado sobre algo que queda delante de los humanos
##   PRIMER_PLANO     5        pasamanos de la escalera (delante de Felipe y de Valeria)
##   LUZ              6        rayos de luz de las ventanas
##   ESTELA          10        estela de Felipe (Zoomies), palabras del ensayo de A.S.P.I.
##   IMAGINACION     25        la imaginación de Felipe (estudio en llamas y A.S.P.I. gigante): tapa TODO el escenario
##   FELIPE_IMAGINANDO 26      Felipe mientras imagina (queda delante de su propia imaginación)
##   EFECTOS         30        viento de la succión, avisos de la pelea, papeles que vuelan, bolas de pelo, polvo
##   CENSURA         40        pegatina de la censura irónica
##   INDICADOR       50        burbuja del Indicador
##
## Pantalla (CanvasLayer.layer), de abajo hacia arriba:
##   INTERFAZ 1 (corazones), JUGO 5 (palabras y destello), HUD 6 (agenda y carteles), DIALOGO 7, AVISOS 8 (logros),
##   LIBRETA 9, RESUMEN 10, FUNDIDO 12 (negro de las puertas: tapa también diálogo, carteles y logros),
##   JEFE 30 (presentación y barra del jefe), PANTALLAS 40 (título, introducción, pausa: tapan todo).

## Roles (Profundidad.rol y los datos de objetos y enemigos). Nuevos SIEMPRE al final (los .tres guardan el número).
enum Rol {
	FONDO, PARED, FACHADA, ARTE_PARED, ESCALERA, PUERTA, SALTABLE, DECORADO, SOMBRA, RESTO_PISO, VELO, APOYADO,
	TRAS_FELIPE, ENEMIGO_PISO, OBJETO_JUEGO, JUGADOR, MARCA, HUMANO, PRIMER_PLANO, LUZ, ESTELA, IMAGINACION, EFECTO,
	CENSURA, INDICADOR, CONTORNO, JUEGO,
}

const FONDO_LEJANO := -40
const PARED := -20
const FACHADA := -19
const ARTE_PARED := -16
const ESCALERA := -15
const PUERTAS := -15
const MUEBLES := -14
const SALTABLE_ACTIVO := -13
const DECORADO := -12
const SOMBRAS := -11
const RESTO_PISO := -10
const VELO := -9
const APOYADO := -8
const TRAS_FELIPE := -7
const ENEMIGO_DETRAS := -6
const OBJETO_JUEGO := -5
const JUEGO := 0
const APOYADO_DELANTE := 1
const MARCAS := 1
const JUEGO_CERCA := 2
const PERSONAJES := 3
const JUEGO_DELANTE := 4
const PRIMER_PLANO := 5
const LUZ := 6
const ESTELA := 10
const IMAGINACION := 25
const FELIPE_IMAGINANDO := 26
const EFECTOS := 30
const CENSURA := 40
const INDICADOR := 50

## z fijo de cada rol que no depende de nada.
const Z_FIJO := {
	Rol.PARED: PARED, Rol.FACHADA: FACHADA, Rol.ARTE_PARED: ARTE_PARED, Rol.ESCALERA: ESCALERA, Rol.PUERTA: PUERTAS,
	Rol.DECORADO: DECORADO, Rol.SOMBRA: SOMBRAS, Rol.RESTO_PISO: RESTO_PISO, Rol.VELO: VELO,
	Rol.TRAS_FELIPE: TRAS_FELIPE, Rol.OBJETO_JUEGO: OBJETO_JUEGO, Rol.MARCA: MARCAS, Rol.HUMANO: PERSONAJES,
	Rol.PRIMER_PLANO: PRIMER_PLANO, Rol.LUZ: LUZ, Rol.ESTELA: ESTELA, Rol.IMAGINACION: IMAGINACION,
	Rol.EFECTO: EFECTOS, Rol.CENSURA: CENSURA, Rol.INDICADOR: INDICADOR, Rol.JUEGO: JUEGO,
}

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
	["MUEBLES", MUEBLES], ["SALTABLE_ACTIVO", SALTABLE_ACTIVO], ["DECORADO", DECORADO], ["SOMBRAS", SOMBRAS],
	["RESTO_PISO", RESTO_PISO], ["VELO", VELO], ["APOYADO", APOYADO], ["TRAS_FELIPE", TRAS_FELIPE],
	["ENEMIGO_DETRAS", ENEMIGO_DETRAS], ["OBJETO_JUEGO", OBJETO_JUEGO], ["JUEGO", JUEGO],
	["APOYADO_DELANTE", APOYADO_DELANTE], ["MARCAS", MARCAS], ["JUEGO_CERCA", JUEGO_CERCA], ["PERSONAJES", PERSONAJES],
	["JUEGO_DELANTE", JUEGO_DELANTE], ["PRIMER_PLANO", PRIMER_PLANO],
	["LUZ", LUZ], ["ESTELA", ESTELA], ["IMAGINACION", IMAGINACION],
	["FELIPE_IMAGINANDO", FELIPE_IMAGINANDO], ["EFECTOS", EFECTOS], ["CENSURA", CENSURA], ["INDICADOR", INDICADOR],
]
## La tabla de la pantalla en orden: [nombre, capa].
const PANTALLA := [
	["INTERFAZ", CAPA_INTERFAZ], ["JUGO", CAPA_JUGO], ["HUD", CAPA_HUD], ["DIALOGO", CAPA_DIALOGO], ["AVISOS", CAPA_AVISOS],
	["LIBRETA", CAPA_LIBRETA], ["RESUMEN", CAPA_RESUMEN], ["FUNDIDO", CAPA_FUNDIDO], ["JEFE", CAPA_JEFE], ["PANTALLAS", CAPA_PANTALLAS],
]


## LA función de la profundidad: el z de un rol según el contexto (Profundidad.contexto()):
## - "superficie_felipe": dónde está parado Felipe ("piso", el nombre de un mueble o "aire");
## - "superficies": las del nodo (SALTABLE: las suyas; APOYADO: la que lo sostiene);
## - "puede_subir" (SALTABLE), "delante" (ENEMIGO_PISO: DatosEnemigo.delante_de_felipe),
##   "delante_de_humanos" e "imaginando" (JUGADOR), "orden" (FONDO: 0 a 10 hacia adelante), "z" (CONTORNO),
##   "z_felipe" (APOYADO en la superficie de Felipe: uno más que él).
static func z_para(rol: int, contexto := {}) -> int:
	if Z_FIJO.has(rol):
		return Z_FIJO[rol]
	var donde: String = contexto.get("superficie_felipe", "piso")
	var mias: PackedStringArray = contexto.get("superficies", PackedStringArray())
	match rol:
		Rol.FONDO:
			return FONDO_LEJANO + int(contexto.get("orden", 0))
		Rol.SALTABLE:
			return SALTABLE_ACTIVO if donde in mias and contexto.get("puede_subir", true) else MUEBLES
		Rol.APOYADO:
			# Con Felipe en su misma superficie, apenas delante de él (esté en la capa que esté).
			return maxi(APOYADO_DELANTE, int(contexto.get("z_felipe", JUEGO)) + 1) if donde in mias else APOYADO
		Rol.ENEMIGO_PISO:
			return JUEGO_CERCA if donde == "piso" and contexto.get("delante", false) else ENEMIGO_DETRAS
		Rol.JUGADOR:
			if contexto.get("imaginando", false):
				return FELIPE_IMAGINANDO
			return JUEGO_DELANTE if contexto.get("delante_de_humanos", false) else JUEGO
		Rol.CONTORNO:
			return int(contexto.get("z", ARTE_PARED))
	return JUEGO


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
