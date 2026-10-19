class_name Sala
extends Node2D
## Primer nivel y demo: "La Gran Fuga" v4, la casa de Valeria como tutorial (documento vigente:
## siete-vidas/diseno/nivel-01-gran-fuga.md). Siete cuartos unidos por puertas (fundido a negro; la cámara queda dentro
## del cuarto). Abajo manda Valeria (va al ruido, regaña, perdona si Felipe se frota, graba el rascador); arriba manda
## A.S.P.I. La escalera de fondo está cerrada por una reja anti-fuga: se pasa trepando el librero y saltándola, y desde
## adentro el pestillo es el atajo de vuelta. Cada cuarto tiene una travesura de la Agenda de Su Majestad con su
## reacción (R18). Nada se enseña con carteles: el Indicador (contorno + burbuja con el botón) y las primeras frases de
## Felipe (LECCIONES). La pelea con A.S.P.I. es en el estudio; el balcón es el alivio y cierra con el resumen del día.
## Todo se arma desde datos; el arte es de Gemini (ArteNivel) y cada colisión calza con el borde visible de su arte
## (±2 px, lo mide prueba_reglas_nivel.gd).
## Habilidades: el nivel se juega sin doble salto, Zoomies ni trepar (decisión del creador, 2026-10-19).

## Escala del mundo: 1,21 px por cm (Felipe mide 67 px; Valeria = 3 Felipes). Casa antigua del Barrio Viejo: cuartos
## de 3,5 m (424 px) de alto, todos con el piso a la misma altura.
const TECHO := 24.0
const SUELO := 448.0
const ALTO := SUELO + 30.0
const ANCHO := 7680.0
## Medio ancho del rectángulo sagrado de cada puerta: medio vano (52 px) más 40 px libres a cada lado (B3).
const MEDIO_RECT_PUERTA := 92.0

## Habitaciones en orden de ruta: [rectángulo, nombre, estilo de pared]. Muros de 160 px entre una y otra.
## Ninguna es más angosta que la pantalla (640 px).
const HABITACIONES := [
	[Rect2(0, TECHO, 1280, SUELO - TECHO), "sala", "tapiz"],
	[Rect2(1440, TECHO, 1200, SUELO - TECHO), "recibidor", "tapiz_verde"],
	[Rect2(2800, TECHO, 1040, SUELO - TECHO), "cocina", "azulejo"],
	[Rect2(4000, TECHO, 1040, SUELO - TECHO), "pasillo", "tapiz_azul"],
	[Rect2(5200, TECHO, 880, SUELO - TECHO), "dormitorio", "rosa"],
	[Rect2(6240, TECHO, 640, SUELO - TECHO), "estudio", "tapiz_mostaza"],
	[Rect2(7040, TECHO, 640, SUELO - TECHO), "balcon", "exterior"],
]
## Orden de la ruta (las reglas de diseño lo usan para comprobar que se enseña antes de pedir).
const RUTA := ["sala", "recibidor", "cocina", "pasillo", "dormitorio", "estudio", "balcon"]
## Ventanas recortadas en la pared (se ve la ciudad). La de la sala y la del pasillo son arte con su propia vista.
const VENTANAS := [Rect2(3160, 130, 140, 120), Rect2(5500, 230, 120, 100), Rect2(6440, 90, 140, 100)]

## Puertas: [nombre, posición (al pie, al centro), puerta a la que lleva]. Van de a pares.
const PUERTAS := [
	["sala>recibidor", Vector2(1188, SUELO), "recibidor<sala"],
	["recibidor<sala", Vector2(1532, SUELO), "sala>recibidor"],
	["recibidor>cocina", Vector2(2070, SUELO), "cocina<recibidor"],  # cerrada: Valeria adentro
	["cocina<recibidor", Vector2(2892, SUELO), "recibidor>cocina"],
	["recibidor>pasillo", Vector2(2330, SUELO), "pasillo<recibidor"],  # pie de la escalera de fondo
	["pasillo<recibidor", Vector2(4092, SUELO), "recibidor>pasillo"],  # vano arriba de la escalera
	["pasillo>dormitorio", Vector2(4536, SUELO), "dormitorio<pasillo"],  # entornada: se araña
	["dormitorio<pasillo", Vector2(5292, SUELO), "pasillo>dormitorio"],
	["pasillo>estudio", Vector2(4948, SUELO), "estudio<pasillo"],
	["estudio<pasillo", Vector2(6332, SUELO), "pasillo>estudio"],
	["estudio>balcon", Vector2(6788, SUELO), "balcon<estudio"],  # cerrada hasta desenchufar a A.S.P.I.
	["balcon<estudio", Vector2(7132, SUELO), "estudio>balcon"],
]
const PUERTA_BALCON := "estudio>balcon"
const PUERTA_COCINA := "recibidor>cocina"
const PUERTA_DORMITORIO := "pasillo>dormitorio"
## La escalera de fondo: al pie se "asciende" como por una puerta, escalón por escalón (Felipe.subir_escalera).
const PUERTA_ESCALERA := "recibidor>pasillo"
const ESCALERA_PIE := Vector2(2330, SUELO)
## Pies de Felipe en cada uno de los 7 escalones (arte escalera_peldanos espejado, de 25 px de huella y ~21 de alto).
const PELDANOS := [
	Vector2(2334, SUELO - 23), Vector2(2360, SUELO - 45), Vector2(2386, SUELO - 67), Vector2(2410, SUELO - 88),
	Vector2(2434, SUELO - 107), Vector2(2458, SUELO - 130), Vector2(2490, SUELO - 150),
]
## Arriba de la escalera: el descanso con el vano bajo, por donde se pasa al pasillo.
const ESCALERA_CIMA := Vector2(2567, SUELO - 150)
## Lo que ocupa la escalera (rectángulo sagrado: nada se le cruza).
const ESCALERA_RECT := Rect2(2322, SUELO - 300, 318, 300)

## Arte que se dibuja: [imagen de assets/nivel1/, (x izquierda, base), espejo, capa]. Capas: "pared" (detrás de todo),
## "mueble" (detrás de Felipe) y "escalera" (peldaños y vano, detrás de Felipe).
const ARTE := [
	["ventana_sala", Vector2(170, 298), false, "pared"],
	["retrato", Vector2(792, 230), false, "pared"],
	["silla_v2", Vector2(680, SUELO), false, "mueble"],
	["mesa_v2", Vector2(745, SUELO), false, "mueble"],
	["silla_v2", Vector2(929, SUELO), true, "mueble"],
	["zapatero", Vector2(1626, SUELO), false, "mueble"],
	["caja_arena", Vector2(1832, SUELO), false, "mueble"],
	["lampara", Vector2(1942, SUELO), false, "mueble"],
	["librero_v2", Vector2(2162, SUELO), false, "mueble"],
	["escalera_peldanos", Vector2(2322, SUELO), true, "escalera"],
	["vano", Vector2(2500, SUELO - 150), false, "escalera"],
	["reloj", Vector2(3077, 200), false, "pared"],
	["silla_v2", Vector2(3400, SUELO), false, "mueble"],
	["alacenas", Vector2(3461, SUELO - 182), false, "pared"],
	["meson", Vector2(3464, SUELO), false, "mueble"],
	["microondas", Vector2(3570, SUELO - 109), false, "mueble"],
	["refrigerador", Vector2(3674, SUELO), false, "mueble"],
	["aparador", Vector2(4256, SUELO), false, "mueble"],
	["ventana_pasillo", Vector2(4260, SUELO - 138), false, "pared"],
	["cojin", Vector2(4784, SUELO), false, "mueble"],
	["paisaje", Vector2(5480, 200), false, "pared"],
	["banquito", Vector2(5386, SUELO), false, "mueble"],
	["cama", Vector2(5444, SUELO), false, "mueble"],
	["comoda", Vector2(5650, SUELO), false, "mueble"],
	["ropero", Vector2(5816, SUELO), false, "mueble"],
	["cortina", Vector2(5960, SUELO), false, "mueble"],
	["silla_v2", Vector2(6424, SUELO), false, "mueble"],
	["escritorio", Vector2(6488, SUELO), false, "mueble"],
	["base_carga", Vector2(6600, SUELO), false, "mueble"],
	["maceta_grande", Vector2(7330, SUELO), false, "mueble"],
	["baranda", Vector2(7400, SUELO), false, "mueble"],
]
## Arte que dibujan sus propios nodos (el sofá cambia de imagen; el rascador tiembla al arañarlo): [imagen, (x izquierda, base)].
const ARTE_EXTRA := [["sofa_plastico", Vector2(240, SUELO)], ["rascador", Vector2(RASCADOR_X - 50.0, SUELO)]]
## El pasamanos de la escalera va delante de Felipe (baja a 70 % de opacidad mientras sube).
const PASAMANOS := ["escalera_baranda", Vector2(2322, SUELO - 14), true]
const OPACIDAD_PASAMANOS := 0.7

## Colisiones: [rectángulo, se atraviesa desde abajo, nombre, estilo, imagen con la que calza]. Cada una sale de medir
## la fila opaca de su arte (prueba_reglas_nivel compara ±2 px). Entre paréntesis, la altura real.
const PIEZAS := [
	[Rect2(0, SUELO, ANCHO, 30), false, "Piso", "invisible", ""],
	[Rect2(0, TECHO - 20, ANCHO, 20), false, "Techo", "invisible", ""],
	# Sala.
	[Rect2(292, SUELO - 49, 154, 6), true, "Asiento del sofá", "arte", "sofa_plastico"],  # 40 cm
	[Rect2(264, SUELO - 102, 169, 6), true, "Respaldo del sofá", "arte", "sofa_plastico"],  # 85 cm
	[Rect2(555, SUELO - 69, 59, 6), true, "Rascador abajo", "arte", "rascador"],
	[Rect2(525, SUELO - 114, 50, 6), true, "Rascador medio", "arte", "rascador"],
	[Rect2(538, SUELO - 165, 54, 6), true, "Rascador arriba", "arte", "rascador"],  # 1,36 m
	[Rect2(693, SUELO - 55, 40, 6), true, "Silla", "arte", "silla_v2"],  # 45 cm
	[Rect2(748, SUELO - 91, 172, 6), true, "Mesa", "arte", "mesa_v2"],  # 75 cm
	[Rect2(935, SUELO - 55, 40, 6), true, "Silla 2", "arte", "silla_v2"],
	# Recibidor.
	[Rect2(1626, SUELO - 97, 160, 57), false, "Zapatero", "arte", "zapatero"],  # 80 cm, 40 px libres debajo
	[Rect2(1852, SUELO - 45, 71, 45), false, "Caja de arena", "arte", "caja_arena"],
	[Rect2(2168, SUELO - 48, 92, 6), true, "Repisa del librero 1", "arte", "librero_v2"],  # repisas cada 45 cm
	[Rect2(2215, SUELO - 103, 45, 6), true, "Repisa del librero 2", "arte", "librero_v2"],
	[Rect2(2168, SUELO - 155, 92, 6), true, "Repisa del librero 3", "arte", "librero_v2"],
	[Rect2(2162, SUELO - 218, 104, 6), true, "Librero", "arte", "librero_v2"],  # 1,80 m
	# Cocina.
	[Rect2(3413, SUELO - 55, 40, 6), true, "Silla de la cocina", "arte", "silla_v2"],
	[Rect2(3472, SUELO - 108, 188, 108), false, "Mesón", "arte", "meson"],  # 90 cm
	[Rect2(3570, SUELO - 162, 98, 54), false, "Microondas", "arte", "microondas"],  # escala de gato
	[Rect2(3682, SUELO - 216, 68, 216), false, "Refrigerador", "arte", "refrigerador"],  # 1,80 m
	# Pasillo de arriba.
	[Rect2(4190, SUELO - 54, 60, 54), false, "Baúl", "baul", ""],  # 45 cm (dibujado: arriba-extra no llegó)
	[Rect2(4258, SUELO - 97, 152, 50), false, "Consola", "arte", "aparador"],  # 80 cm, 47 px libres debajo
	[Rect2(4264, SUELO - 150, 172, 6), true, "Alféizar", "arte", "ventana_pasillo"],  # 1,24 m
	# Dormitorio.
	[Rect2(5391, SUELO - 53, 42, 6), true, "Banquito", "arte", "banquito"],
	[Rect2(5444, SUELO - 65, 197, 65), false, "Cama", "arte", "cama"],  # colchón a 54 cm
	[Rect2(5655, SUELO - 96, 74, 96), false, "Cómoda", "arte", "comoda"],  # 80 cm
	[Rect2(5740, SUELO - 145, 70, 6), true, "Repisa", "repisa", ""],  # 1,20 m
	[Rect2(5816, SUELO - 185, 104, 185), false, "Ropero", "arte", "ropero"],  # 1,53 m
	[Rect2(5950, SUELO - 290, 80, 6), true, "Repisa alta", "lugar_visto", ""],  # 2,40 m: se vuelve con Afilar Garras
	# Estudio de Valeria (la pelea).
	[Rect2(6437, SUELO - 55, 40, 6), true, "Silla del estudio", "arte", "silla_v2"],
	[Rect2(6505, SUELO - 98, 126, 6), true, "Escritorio", "arte", "escritorio"],  # 81 cm
	[Rect2(6636, SUELO - 151, 60, 6), true, "Repisa de las macetas", "repisa", ""],  # 1,25 m
	# Balcón.
	[Rect2(7335, SUELO - 32, 38, 6), true, "Maceta grande", "arte", "maceta_grande"],
	[Rect2(7401, SUELO - 89, 182, 6), true, "Baranda", "arte", "baranda"],  # 74 cm
]
## Sofá cuando ya no tiene plástico (sofa_aranado: más bajo): asiento y respaldo se mueven a su arte.
const SOFA_ARANADO := {"Asiento del sofá": SUELO - 45, "Respaldo del sofá": SUELO - 95}
## Reja anti-fuga sobre el primer escalón (1,5 m; colisión fina de 12 px, dibujo de 48 px).
const REJA := Rect2(2284, SUELO - 182, 12, 182)
## Juguetes que duelen al pisarlos: la sala v4 no tiene nada que haga daño.
const PELIGROS: Array[Rect2] = []
## Nada se trepa en el nivel 1 (trepar se gana con Afilar Garras): la cortina es un lugar visto.
const TREPABLES: Array[Rect2] = []
## Calcetines (R10): del sofá (travesura), arriba del refrigerador (exploración) y de la cómoda (cajón).
const CALCETINES := [Vector2(370, SUELO - 49), Vector2(3716, SUELO - 216), Vector2(5692, SUELO - 96)]
const CALCETIN_REFRIGERADOR := Vector2(3716, SUELO - 216)
const TOTAL_CALCETINES := 3
const CAJA_CARTON := Vector2(3360, SUELO)
## Ratones de cuerda: [posición, límite izquierdo, límite derecho]. Uno enseña el zarpazo y otro cuida el pollo.
const RATONES := [
	[Vector2(3240, SUELO), 3200.0, 3290.0],
	[Vector2(3520, SUELO - 108), 3496.0, 3546.0],
]
const LASER := [Vector2(4700, SUELO), 4640.0, 4780.0]
## Objetos que se tiran con el botón de acción: [posición, tipo].
const TIRABLES := [
	[Vector2(905, SUELO - 91), "vaso"],
	[Vector2(1766, SUELO - 97), "llaves"],
	[Vector2(4395, SUELO - 97), "vaso"],
	[Vector2(6515, SUELO - 98), "vaso"],
	[Vector2(6612, SUELO - 98), "rollo"],
	[Vector2(6650, SUELO - 151), "maceta"],
	[Vector2(6682, SUELO - 151), "maceta"],
]
## Comida: [posición, tipo]. El pollo es el almuerzo de Valeria (travesura "almuerzo").
const COMIDA := [[Vector2(3010, SUELO), "tazon"], [Vector2(3510, SUELO - 108), "pollo"]]
## A.S.P.I.: [base de carga, límite izquierdo, límite derecho] dentro del estudio.
const ASPI := [Vector2(6637, SUELO), 6290.0, 6830.0]
## Puntos de descanso: la caja de arena (recibidor) y el cojín (pasillo, a 2 px del rectángulo de la puerta del jefe).
const DESCANSOS := [Rect2(1852, SUELO - 60, 71, 70), Rect2(4784, SUELO - 40, 70, 50)]
## La meta: la baranda del balcón (sentarse y saltar da Caer de Pie).
const SALIDA := 7490.0
## Sofá arañable (con el plástico nuevo): [centro de la base, ancho, alto]. Línea "sofa" de la agenda.
const SOFA_ARANABLE := [Vector2(360, SUELO), 240.0, 100.0]
const RASCADOR_X := 570.0
## Valeria: sentada en el sofá viendo la serie, y su lugar en la cocina (preparando café).
const VALERIA_SOFA := Vector2(410, SUELO - 49)
const VALERIA_COCINA := Vector2(3800, SUELO)
## Cajón de los calcetines (en la cómoda), ropa doblada (en la cama) y teclado del escritorio.
const CAJON := Vector2(5662, SUELO - 75)
const ROPA := Vector2(5540, SUELO - 65)
const TECLADO := Rect2(6545, SUELO - 104, 42, 8)
## Segundos agachado sobre la caja de arena para el popo táctico, y quieto frente al láser para ignorarlo.
const TIEMPO_POPO := 1.2
const TIEMPO_IGNORAR_LASER := 5.0

## Primeras frases de Felipe (reemplazan los avisos de abajo, M2): [zona, línea con {acción}, ánimo del retrato].
## Salen una sola vez, la primera vez que entra a la zona (R1–R3 se miden sobre esto).
const LECCIONES := [
	[Rect2(0, TECHO, 200, SUELO - TECHO), "{saltar} Los muebles son mi escalera.", 0],
	[Rect2(240, TECHO, 200, SUELO - TECHO), "{interactuar} Ese sofá tiene plástico. Por ahora.", 7],
	[Rect2(500, TECHO, 150, SUELO - TECHO), "{interactuar} Un rascador. Necesito público.", 0],
	[Rect2(680, TECHO, 220, SUELO - TECHO), "{interactuar} Ese vaso está muy cerca del borde. Aún.", 4],
	[Rect2(1600, TECHO, 160, SUELO - TECHO), "Mantén {agacharse}. Es estrategia, no humildad.", 0],
	[Rect2(1820, TECHO, 130, SUELO - TECHO), "Mi trono. Aquí vuelvo si algo sale mal.", 0],
	[Rect2(1980, TECHO, 140, SUELO - TECHO), "{maullar} Servidumbre: abran.", 6],
	[Rect2(2140, TECHO, 140, SUELO - TECHO), "{saltar} El librero es mi escalera.", 7],
	[Rect2(2300, TECHO, 120, SUELO - TECHO), "{interactuar} Escalones. Mi única pasión.", 0],
	[Rect2(2950, TECHO, 130, SUELO - TECHO), "{interactuar} Comida a la vista. Me sacrifico.", 6],
	[Rect2(3110, TECHO, 140, SUELO - TECHO), "{zarpazo} Un ratón de cuerda. Qué insolencia.", 1],
	[Rect2(4460, TECHO, 140, SUELO - TECHO), "{interactuar} Puerta entornada. Qué invitación.", 7],
	[Rect2(5300, TECHO, 140, SUELO - TECHO), "{saltar} Banquito, cama, cómoda. Escalera real.", 0],
	[Rect2(5600, TECHO, 150, SUELO - TECHO), "{interactuar} El cajón de los calcetines. Botín.", 7],
	[Rect2(7280, TECHO, 140, SUELO - TECHO), "{saltar} La maceta, la baranda… y la libertad.", 0],
]
## Dónde pasa cada travesura de la Agenda y su reacción (R18).
const AGENDA_SITIOS := {
	"perdon": [Vector2(905, SUELO - 91), "«¡GRAVEDAD: 1 · VASO: 0!», Valeria: «¡PIPE!» y después «¿Quién es el bebito más gordito?»"],
	"sofa": [Vector2(370, SUELO - 49), "«¡PLÁSTICO: 0!» y Valeria: «¡Lo estoy pagando en 12 cuotas!»"],
	"popo": [Vector2(1888, SUELO - 45), "Censura irónica y Valeria con mascarilla: «¡ACABO DE LIMPIARLA!»"],
	"almuerzo": [Vector2(3510, SUELO - 108), "«¡EN SU CARA!» y Valeria: «¡ESE ERA MI ALMUERZO!»"],
	"laser": [Vector2(4700, SUELO), "El puntero se apaga de vergüenza"],
	"cajon": [CAJON, "Calcetines volando por todo el cuarto"],
	"teclado": [Vector2(6566, SUELO - 98), "La pantalla dice «jjjjjjjjjj» y la impresora escupe papeles"],
	"desenchufar": [Vector2(6637, SUELO), "«¡APAGADA!» y «Limpieza cancelada.»"],
}
## Lugares que se ven antes de poder alcanzarlos (R17): [qué, dónde, con qué maña se vuelve].
const LUGARES_VISTOS := [
	["Toldo del vecino con la caja de pizza (por la ventana del pasillo)", Rect2(4370, SUELO - 186, 60, 20), "Caer de Pie"],
	["Caja de recuerdos de Valeria (repisa alta del dormitorio)", Rect2(5950, SUELO - 300, 80, 10), "Afilar Garras"],
]
## Atajos (R6): [qué, dónde, desde dónde se abre].
const ATAJOS := [["Pestillo de la reja anti-fuga", REJA, "escalera"]]
## Cada maña que el nivel enseña abre un camino y molesta a alguien (R19): maña -> [camino, a quién molesta].
const MANAS := {
	"maullar": ["puerta de la cocina (Valeria la abre)", "Valeria y A.S.P.I."],
	"aranar": ["puerta entornada del dormitorio", "el sofá nuevo de Valeria"],
	"frotarse": ["Valeria deja de regañar y vuelve a su serie", "a nadie: es carisma"],
	"zarpazo": ["ratón del mesón (camino al refrigerador)", "ratones y caja de cartón"],
}

signal logro_desbloqueado(titulo: String)
signal habitacion_cambiada(nombre: String)
## Terminó el fundido de una puerta (la pantalla ya se ve).
signal fundido_terminado


## Nombre de la habitación que contiene el punto, mirando un píxel arriba para que el piso cuente ("" si está fuera).
static func habitacion_de(punto: Vector2) -> String:
	for habitacion: Array in HABITACIONES:
		if (habitacion[0] as Rect2).has_point(punto - Vector2(0, 1)):
			return habitacion[1]
	return ""


## Rectángulo de la habitación con ese nombre.
static func rect_de(nombre: String) -> Rect2:
	for habitacion: Array in HABITACIONES:
		if habitacion[1] == nombre:
			return habitacion[0]
	return Rect2()


## Índice en RUTA de la habitación que contiene el punto (-1 si está fuera).
static func orden_en_ruta(punto: Vector2) -> int:
	return RUTA.find(habitacion_de(punto))


## Rectángulos en el mundo donde se dibuja una imagen (ARTE, ARTE_EXTRA y el pasamanos): para medir arte contra colisión.
static func rects_de_arte(imagen: String) -> Array[Rect2]:
	var lista: Array[Rect2] = []
	var textura := ArteNivel.textura(imagen)
	if textura == null:
		return lista
	var todos: Array = []
	todos.append_array(ARTE)
	todos.append_array(ARTE_EXTRA)
	todos.append(PASAMANOS)
	for datos: Array in todos:
		if datos[0] == imagen:
			lista.append(Rect2(datos[1] - Vector2(0, textura.get_height()), textura.get_size()))
	return lista


## Rectángulo sagrado de la puerta que está al pie en `pie` (B3, G10): nada se le cruza.
static func rect_sagrado(pie: Vector2) -> Rect2:
	return Rect2(pie.x - MEDIO_RECT_PUERTA, pie.y - Puerta.ALTO_MAXIMO, MEDIO_RECT_PUERTA * 2.0, Puerta.ALTO_MAXIMO)


## Muestra la pantalla de título al empezar (las pruebas la apagan).
@export var mostrar_titulo := true
## Entrar al estudio arranca la pelea de jefe (la prueba de mecánicas la apaga para probar a A.S.P.I. sola).
@export var batalla_con_jefe := true
## Las piezas de juguete hacen daño (la prueba de movimiento las apaga; en la v4 no hay).
@export var peligros_activos := true

var logros: Array[String] = []
var tiempo := 0.0
var terminado := false
var pantallas: Pantallas
var batalla: BatallaAspi
var aspi: Aspi
var valeria: Valeria
var ensayo: EnsayoAspi
var reja: Reja
var sofa: Aranable
var rascador: Rascador
var habitacion := ""
var puertas := {}
var tirables: Array[Vaso] = []
## Sistemas reutilizables del nivel: agenda, libreta, HUD, diálogo, jugo e indicador.
var travesuras: Travesuras
## El balcón: se sentó en la baranda, saltó.
var sentado_en_baranda := false
var salto_final := false

var _piezas := {}
var _sonidos: Array[AudioStreamPlayer] = []
var _lecciones_vistas := {}
var _fundido: ColorRect
var _cruzando := false
var _pasamanos: Node2D
var _sofa_roto := false
var _visitados := {}
var _tiempo_popo := 0.0
var _tiempo_laser := 0.0
var _laser: Laser
var _teclado_pisado := false
var _espera_papel := 0.0
var _cajon_abierto := false
var _calcetines_volando: Array[Vector3] = []
var _ropa_firmada := false
var _dijo := {}
var _decorado: Node2D
var _cesta: Node2D
var _tiempo_baranda := 0.0

@onready var felipe: Felipe = $Felipe


## Calcetines del día (van al nido de Su Majestad).
var calcetines: int:
	get:
		return travesuras.recompensas.calcetines if travesuras else 0


func _ready() -> void:
	add_child(FondoApartamento.new(ANCHO, ALTO))
	_crear_arte()
	for pieza: Array in PIEZAS:
		_crear_pieza(pieza[0], pieza[1], pieza[2], pieza[3])
	# Paredes de cada habitación: no se sale de un cuarto si no es por una puerta.
	for datos: Array in HABITACIONES:
		var cuarto: Rect2 = datos[0]
		_crear_pieza(Rect2(cuarto.position.x - 20, 0, 20, ALTO), false, "Pared izquierda de %s" % datos[1], "invisible")
		_crear_pieza(Rect2(cuarto.end.x, 0, 20, ALTO), false, "Pared derecha de %s" % datos[1], "invisible")
	felipe.sonido.connect(sonar)
	for i in 5:
		var reproductor := AudioStreamPlayer.new()
		add_child(reproductor)
		_sonidos.append(reproductor)
	pantallas = Pantallas.new()
	pantallas.reiniciar.connect(func() -> void: get_tree().reload_current_scene())
	pantallas.empezar.connect(_mostrar_meta)
	$Interfaz.add_child(pantallas)
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
	medidores.pantallas = pantallas
	travesuras = Travesuras.new(felipe, Agenda.NIVEL_1)
	add_child(travesuras)
	travesuras.recompensas.camino_abierto.connect(_abrir_camino)
	travesuras.recompensas.cambio.connect(_al_cambiar_recompensas)
	_crear_puertas()
	_crear_objetos()
	_crear_valeria()
	_crear_aspi()
	_fundido = ColorRect.new()
	_fundido.name = "Fundido"
	_fundido.color = Color.BLACK
	_fundido.modulate.a = 0.0
	_fundido.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sigue en pausa (B1: la presentación del jefe pausa el árbol; el fundido nunca se queda a medias).
	_fundido.process_mode = Node.PROCESS_MODE_ALWAYS
	_fundido.set_anchors_preset(Control.PRESET_FULL_RECT)
	$Interfaz.add_child(_fundido)
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	_actualizar_camara()


func _crear_puertas() -> void:
	for datos: Array in PUERTAS:
		var puerta := Puerta.new(datos[0], datos[1], datos[2], datos[1].y - TECHO)
		puerta.cerrada = datos[0] in [PUERTA_BALCON, PUERTA_COCINA]
		puerta.entornada = datos[0] == PUERTA_DORMITORIO
		puerta.escalera = datos[0] == PUERTA_ESCALERA
		puerta.sombra_detras = datos[0] == PUERTA_COCINA
		puerta.estilo = "balcon" if "balcon" in datos[0] else ("vano" if datos[0] == "pasillo<recibidor" else "")
		puerta.cruzada.connect(cruzar)
		add_child(puerta)
		puertas[datos[0]] = puerta
	# La puerta entornada del dormitorio se abre arañándola (R19: arañar es llave).
	var entornada := Aranable.new("Puerta entornada", 70.0, 200.0)
	entornada.position = (puertas[PUERTA_DORMITORIO] as Puerta).position
	entornada.aranazos_para_romper = 1
	entornada.verbo_indicador = "Arañar"
	entornada.roto.connect(func(_o: Aranable) -> void:
		var puerta: Puerta = puertas[PUERTA_DORMITORIO]
		puerta.entornada = false
		puerta.queue_redraw()
		_decir("puerta_abierta")
		sonar("caja"))
	add_child(entornada)


func _crear_objetos() -> void:
	reja = Reja.new(REJA)
	reja.abierta.connect(func() -> void:
		desbloquear_logro("Atajo de Gato")
		_decir("pestillo", true))
	reja.empujada.connect(func() -> void: _decir("reja", true))
	add_child(reja)
	for comida: Array in COMIDA:
		var objeto := Comida.new(comida[1])
		objeto.position = comida[0]
		objeto.comido.connect(_al_comer)
		add_child(objeto)
	for tirable: Array in TIRABLES:
		var objeto := Vaso.new(SUELO, tirable[1])
		objeto.position = tirable[0]
		objeto.caido.connect(_al_caer_tirable.bind(objeto))
		add_child(objeto)
		tirables.append(objeto)
	for datos: Array in RATONES:
		var raton := Raton.new(datos[1], datos[2])
		raton.position = datos[0]
		add_child(raton)
	var caja := CajaCarton.new()
	caja.position = CAJA_CARTON
	caja.rota.connect(_romper_caja)
	add_child(caja)
	_laser = Laser.new(LASER[1], LASER[2])
	_laser.position = LASER[0]
	add_child(_laser)
	# Calcetín 2: arriba del refrigerador (exploración, no es de la agenda).
	var calcetin := travesuras.soltar("calcetin", CALCETIN_REFRIGERADOR, Vector2.ZERO)
	calcetin.quieto = true
	# Rascador (teatro para Valeria) y sofá con plástico.
	rascador = Rascador.new()
	rascador.position = Vector2(RASCADOR_X, SUELO)
	rascador.z_index = -1
	add_child(rascador)
	travesuras.conectar_rascador(rascador)
	sofa = Aranable.new("Sofa arañable", SOFA_ARANABLE[1], SOFA_ARANABLE[2])
	sofa.position = SOFA_ARANABLE[0]
	sofa.aranado.connect(_al_aranar_sofa)
	add_child(sofa)
	travesuras.conectar_aranable(sofa, "sofa", AGENDA_SITIOS["sofa"][0] + Vector2(0, -20))
	sofa.roto.connect(_romper_plastico)
	# Cajón de los calcetines (cómoda) y ropa doblada (cama).
	var cajon := Interactivo.new("Cajon", "Saquear", Rect2(-14, -12, 60, 24))
	cajon.position = CAJON
	cajon.al_usar = func(f: Felipe) -> void: f.dar_manotazo(_abrir_cajon.bind(cajon))
	add_child(cajon)
	var ropa := Interactivo.new("Ropa doblada", "Firmar", Rect2(-24, -14, 48, 14))
	ropa.position = ROPA
	ropa.al_usar = func(f: Felipe) -> void:
		f.acicalarse()
		_ropa_firmada = true
		ropa.queue_redraw()
		_decir("ropa", true)
	ropa.dibujo = _dibujar_ropa
	add_child(ropa)
	# Quien oye maullidos del otro lado de la puerta de la cocina (Valeria está adentro).
	var oido := OidoPuerta.new()
	oido.position = (puertas[PUERTA_COCINA] as Puerta).position + Vector2(0, -40)
	oido.oido.connect(_maullido_en_la_puerta_de_la_cocina)
	add_child(oido)
	_decorado = Node2D.new()
	_decorado.name = "Decorado"
	_decorado.z_index = -1
	_decorado.draw.connect(_dibujar_decorado)
	add_child(_decorado)
	_cesta = Node2D.new()
	_cesta.name = "Nido"
	_cesta.z_index = -1
	_cesta.draw.connect(_dibujar_nido)
	add_child(_cesta)


func _crear_valeria() -> void:
	valeria = Valeria.new()
	valeria.travesuras = travesuras
	for datos: Array in PUERTAS:
		valeria.puertas_x.append(datos[1].x)
	add_child(valeria)
	valeria.poner(VALERIA_SOFA, "sala", 1.0, Valeria.Actividad.SENTADA)
	valeria.fijar_casa()
	valeria.perdono.connect(_al_perdonar)


func _crear_aspi() -> void:
	aspi = Aspi.new(ASPI[1], ASPI[2])
	aspi.position = ASPI[0]
	aspi.necesita_aturdir = true
	aspi.apagado.connect(_abrir_balcon)
	add_child(aspi)
	if batalla_con_jefe:
		batalla = BatallaAspi.new(aspi, felipe, self)
		add_child(batalla)
		for objeto in tirables:
			if Sala.habitacion_de(objeto.position) == "estudio":
				batalla.agregar_municion(objeto)
	# Ensayo sin riesgo en el pasillo: A.S.P.I. sale a limpiar lo que Felipe tira (R1, R12).
	ensayo = EnsayoAspi.new(self, Vector2((puertas["pasillo>estudio"] as Puerta).position.x, SUELO))
	add_child(ensayo)
	# Detrás de la puerta del estudio, el pasamanos y lo demás encima.
	_pasamanos = Node2D.new()
	_pasamanos.name = "Pasamanos"
	_pasamanos.z_index = 2
	_pasamanos.draw.connect(func() -> void:
		var datos: Array = PASAMANOS
		var textura := ArteNivel.textura(datos[0])
		if textura:
			ArteNivel.dibujar(_pasamanos, datos[0], datos[1].x + textura.get_width() / 2.0, datos[1].y, datos[2]))
	add_child(_pasamanos)


func _physics_process(delta: float) -> void:
	if terminado:
		return
	tiempo += delta
	_actualizar_camara()
	# Puntos de descanso: la caja de arena y el cojín.
	for descanso: Rect2 in DESCANSOS:
		if descanso.has_point(felipe.global_position) and felipe.is_on_floor():
			var punto := Vector2(descanso.get_center().x, descanso.position.y + 10)
			if felipe.punto_reaparicion != punto:
				felipe.punto_reaparicion = punto
				sonar("logro")
	_actualizar_lecciones()
	_actualizar_popo(delta)
	_actualizar_laser(delta)
	_actualizar_teclado(delta)
	_actualizar_balcon(delta)
	var en_escalera := felipe.en_escalera() or (habitacion == "recibidor" and felipe.global_position.x > ESCALERA_RECT.position.x and felipe.global_position.y < SUELO - 4.0)
	_pasamanos.modulate.a = OPACIDAD_PASAMANOS if en_escalera else 1.0
	if not _calcetines_volando.is_empty():
		_decorado.queue_redraw()


## La cámara queda dentro de la habitación donde está Felipe (también después de una puerta o de reaparecer).
func _actualizar_camara() -> void:
	var actual := habitacion_de(felipe.global_position)
	if actual == "" or actual == habitacion:
		return
	habitacion = actual
	var cuarto := rect_de(actual)
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_left = int(cuarto.position.x)
	camara.limit_right = int(cuarto.end.x)
	camara.limit_top = 0
	camara.limit_bottom = int(ALTO)
	camara.reset_smoothing()
	# El salto de cámara se completa en el cuadro siguiente, ya con los límites nuevos.
	camara.reset_smoothing.call_deferred()
	_al_entrar_a(actual)
	habitacion_cambiada.emit(actual)


## Lo que pasa al entrar a un cuarto: Valeria cuenta la visita, se va a la cocina, se pone audífonos...
func _al_entrar_a(cuarto: String) -> void:
	var primera := not _visitados.has(cuarto)
	_visitados[cuarto] = true
	if valeria and valeria.cuarto == cuarto:
		valeria.visita += 1
	if cuarto == "recibidor" and primera and valeria.cuarto == "sala":
		_valeria_a_la_cocina()
	elif cuarto == "pasillo" and primera:
		valeria.audifonos = true
		travesuras.decir_valeria("audifonos", true)
		_decir("robot")
	elif cuarto == "cocina" and primera:
		valeria.visita += 1


## Cruza una puerta: funde a negro, lleva a Felipe a la puerta del otro lado y vuelve a mostrar.
## La escalera se sube (y se baja) escalón por escalón antes (o después) del fundido.
func cruzar(puerta: Puerta) -> void:
	if _cruzando or terminado:
		return
	if puerta.cerrada:
		_decir("balcon_cerrado" if puerta.name == PUERTA_BALCON else "cocina_cerrada", true)
		return
	if puerta.entornada:
		return
	var otra: Puerta = puertas.get(puerta.destino)
	if otra == null:
		return
	_cruzando = true
	sonar("salto")
	if puerta.escalera:
		await _subir_escalera()
	felipe.set_physics_process(false)
	await _fundir(1.0, 0.15)
	felipe.global_position = ESCALERA_CIMA if otra.escalera else otra.global_position
	felipe.velocity = Vector2.ZERO
	var centro := rect_de(habitacion_de(felipe.global_position)).get_center().x
	felipe.mirando = -1.0 if otra.escalera else (1.0 if felipe.global_position.x < centro else -1.0)
	felipe.sprite.flip_h = felipe.mirando < 0.0
	_actualizar_camara()
	await _fundir(0.0, 0.2)
	if otra.escalera:
		await _bajar_escalera()
	felipe.set_physics_process(true)
	_cruzando = false
	fundido_terminado.emit()


## ¿Hay un fundido de puerta en curso? (la pelea espera a que termine: arregla B1).
func cruzando() -> bool:
	return _cruzando or _fundido.modulate.a > 0.01


func _fundir(alfa: float, segundos: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fundido, "modulate:a", alfa, segundos)
	await tween.finished


## Sube los 7 escalones (animación subir_escalera, un saltito por escalón) y camina al vano del descanso.
func _subir_escalera() -> void:
	var peldanos: Array[Vector2] = []
	peldanos.assign(PELDANOS)
	felipe.subir_escalera(peldanos)
	await felipe.escalera_terminada
	felipe.set_physics_process(false)
	await _caminar_a(ESCALERA_CIMA, 0.55)


## Al volver del pasillo: aparece en el descanso, camina al último escalón y baja escalón por escalón.
func _bajar_escalera() -> void:
	await _caminar_a(PELDANOS[-1], 0.5)
	felipe.set_physics_process(true)
	var peldanos: Array[Vector2] = []
	for i in range(PELDANOS.size() - 2, -1, -1):
		peldanos.append(PELDANOS[i])
	peldanos.append(ESCALERA_PIE)
	felipe.subir_escalera(peldanos)
	await felipe.escalera_terminada


## Camina por el descanso (sin piso de colisión: la escalera es de fondo).
func _caminar_a(destino: Vector2, segundos: float) -> void:
	felipe.mirando = signf(destino.x - felipe.global_position.x) if absf(destino.x - felipe.global_position.x) > 1.0 else felipe.mirando
	felipe.sprite.flip_h = felipe.mirando < 0.0
	felipe.sprite.play("caminar")
	var paso := create_tween()
	paso.tween_property(felipe, "global_position", destino, segundos)
	await paso.finished
	felipe.sprite.play("quieto")


## Primeras frases de Felipe, una sola vez por zona (en lugar de los avisos de abajo).
func _actualizar_lecciones() -> void:
	for i in LECCIONES.size():
		if _lecciones_vistas.has(i):
			continue
		var zona: Rect2 = LECCIONES[i][0]
		if zona.grow_individual(0, 0, 0, 4).has_point(felipe.global_position) and not _cruzando:
			_lecciones_vistas[i] = true
			travesuras.dialogo.decir("felipe", LECCIONES[i][1], LECCIONES[i][2])


## Al empezar, la cámara muestra un momento el balcón: la meta (R4). Felipe lo dice y arranca la dieta.
func _mostrar_meta() -> void:
	var balcon := rect_de("balcon")
	var camara_meta := Camera2D.new()
	camara_meta.name = "Camara de la meta"
	camara_meta.position = Vector2(balcon.get_center().x, SUELO - 120)
	camara_meta.limit_left = int(balcon.position.x)
	camara_meta.limit_right = int(balcon.end.x)
	camara_meta.limit_top = 0
	camara_meta.limit_bottom = int(ALTO)
	add_child(camara_meta)
	camara_meta.make_current()
	_decir("meta", true)
	await get_tree().create_timer(1.6).timeout
	felipe.get_node("Camara").make_current()
	camara_meta.queue_free()
	_decir("inicio")


func sonar(nombre: String) -> void:
	var ruta := "res://assets/sonidos/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	for reproductor in _sonidos:
		if not reproductor.playing:
			reproductor.stream = load(ruta)
			reproductor.play()
			return


func desbloquear_logro(titulo: String) -> void:
	if titulo in logros:
		return
	logros.append(titulo)
	logro_desbloqueado.emit(titulo)
	sonar("logro")


## Felipe dice una frase de Frases.FELIPE (cada evento con `una_vez` sale solo la primera vez).
func _decir(evento: String, urgente := false, una_vez := true) -> void:
	if una_vez and _dijo.has(evento):
		return
	_dijo[evento] = true
	travesuras.decir_felipe(evento, urgente)


# --- Travesuras y reacciones (R18) -------------------------------------------------------------------------

## Algo cayó: el vaso de la sala hace saltar a Valeria; las llaves, que se asome; en el pasillo sale A.S.P.I.
func _al_caer_tirable(donde: Vector2, objeto: Vaso) -> void:
	var cuarto := habitacion_de(donde)
	match objeto.tipo:
		"vaso":
			if cuarto == "sala":
				travesuras.jugo.congelar(0.08)
				travesuras.jugo.palabra_en_mundo("¡GRAVEDAD: 1 · VASO: 0!", donde + Vector2(0, -60), Color(0.75, 0.9, 1.0), 15)
				if valeria.cuarto == "sala":
					valeria.reganar(felipe, "rotura", "vaso")
			elif cuarto == "pasillo":
				ensayo.empezar(donde.x)
			_decir("tirar", false, false)
		"llaves":
			travesuras.jugo.palabra_en_mundo("¡CLINK CRÍTICO!", donde + Vector2(0, -50), Color(1.0, 0.9, 0.4), 16)
			travesuras.jugo.sacudir(0.12, 0.5)
			if valeria.cuarto == "cocina" and not valeria.audifonos:
				travesuras.decir_valeria("llaves", true)


func _al_perdonar(motivo: String) -> void:
	if motivo == "rotura":
		# "Romper algo y que me perdone igual": el snack sale a los pies de Felipe.
		travesuras.cumplir("perdon", felipe.global_position + Vector2(0, -24))


## Arañar el sofá delante de Valeria: a los dos arañazos lo deja frente al rascador (y el plástico aguanta).
func _al_aranar_sofa(objeto: Aranable, critico: bool) -> void:
	if objeto.esta_roto or critico:
		return
	if valeria.ve(Vector2(felipe.global_position.x, SUELO - 20)) and objeto.aranazos >= 2:
		objeto.aranazos = 0
		valeria.llevar_al_rascador(felipe, RASCADOR_X - 46.0)


func _romper_plastico(_objeto: Aranable) -> void:
	_sofa_roto = true
	travesuras.jugo.palabra_en_mundo("¡PLÁSTICO: 0!", SOFA_ARANABLE[0] + Vector2(0, -120), Color(1.0, 0.6, 0.4), 18)
	for nombre: String in SOFA_ARANADO:
		var pieza: StaticBody2D = _piezas[nombre]
		pieza.position.y = SOFA_ARANADO[nombre]
	if valeria.cuarto == "sala":
		travesuras.decir_valeria("sofa_roto", true)
	_decorado.queue_redraw()


func _al_comer(comida: Comida) -> void:
	if comida.tipo == "tazon":
		_decir("tazon", true)
	elif comida.tipo == "pollo":
		var en_su_cara := valeria.ve(comida.global_position)
		travesuras.cumplir("almuerzo", comida.global_position + Vector2(0, -10))
		if en_su_cara:
			travesuras.jugo.palabra_en_mundo("¡EN SU CARA!", comida.global_position + Vector2(0, -70), Color(1.0, 0.4, 0.5), 20)
			valeria.reganar(felipe, "almuerzo", "almuerzo")
		elif valeria.cuarto == "cocina":
			travesuras.decir_valeria("almuerzo", true)


func _romper_caja() -> void:
	sonar("caja")
	travesuras.soltar("snack", CAJA_CARTON + Vector2(0, -30), Vector2(30, -140))


## Popo táctico: agachado sobre la caja de arena recién limpiada (travesura secreta, con censura irónica).
func _actualizar_popo(delta: float) -> void:
	var caja: Rect2 = DESCANSOS[0]
	if travesuras.agenda.esta_cumplida("popo") or not (felipe.agachado and felipe.is_on_floor() and caja.has_point(felipe.global_position)):
		_tiempo_popo = 0.0
		return
	_tiempo_popo += delta
	if _tiempo_popo >= TIEMPO_POPO:
		_tiempo_popo = 0.0
		_censura_ironica()
		travesuras.cumplir("popo")
		if valeria.cuarto == "cocina" and not valeria.audifonos:
			_valeria_sale_por_bolsas()


func _censura_ironica() -> void:
	travesuras.jugo.palabra_en_mundo("CONTENIDO SENSIBLE", felipe.global_position + Vector2(0, -70), Color(1.0, 1.0, 1.0), 14)
	var pegatina := Node2D.new()
	pegatina.name = "Censura"
	pegatina.z_index = 40
	pegatina.global_position = felipe.global_position + Vector2(0, -20)
	pegatina.draw.connect(func() -> void:
		# Pegatina de pescadito y un aviso que muestra... una papa.
		pegatina.draw_rect(Rect2(-22, -20, 44, 24), Color(0.2, 0.55, 0.85))
		pegatina.draw_colored_polygon(PackedVector2Array([Vector2(-12, -8), Vector2(6, -14), Vector2(12, -8), Vector2(6, -2)]), Color(1.0, 0.65, 0.35))
		pegatina.draw_colored_polygon(PackedVector2Array([Vector2(12, -8), Vector2(18, -13), Vector2(18, -3)]), Color(1.0, 0.55, 0.3))
		pegatina.draw_circle(Vector2(-14, -40), 9.0, Color(0.72, 0.55, 0.32)))
	add_child(pegatina)
	var irse := pegatina.create_tween()
	irse.tween_interval(1.4)
	irse.tween_property(pegatina, "modulate:a", 0.0, 0.3)
	irse.tween_callback(pegatina.queue_free)


## Ignorar el láser: 5 s quieto en el pasillo con el punto rojo cerca, sin perseguirlo (secreta).
func _actualizar_laser(delta: float) -> void:
	if travesuras.agenda.esta_cumplida("laser") or habitacion != "pasillo" or _laser == null:
		_tiempo_laser = 0.0
		return
	var quieto := felipe.is_on_floor() and absf(felipe.velocity.x) < 1.0 and not felipe.en_escalera()
	if quieto and absf(_laser.global_position.x - felipe.global_position.x) < 260.0 and felipe.global_position.y > SUELO - 4.0:
		_tiempo_laser += delta
	else:
		_tiempo_laser = 0.0
	if _tiempo_laser >= TIEMPO_IGNORAR_LASER:
		_laser.apagar()
		travesuras.jugo.palabra_en_mundo("*se apaga de vergüenza*", _laser.global_position + Vector2(0, -24), Color(1.0, 0.5, 0.5), 11)
		# La foto vergonzosa se cae del cajón de la consola.
		travesuras.cumplir("laser", Vector2(4330, SUELO - 97))


## Pisar el teclado de Valeria: "jjjjjjjjjj" (secreta). En la pelea, la impresora escupe papeles: manchas extra.
func _actualizar_teclado(delta: float) -> void:
	_espera_papel = maxf(0.0, _espera_papel - delta)
	var encima := felipe.is_on_floor() and TECLADO.grow_individual(0, 6, 0, 6).has_point(felipe.global_position)
	if not encima:
		return
	if not _teclado_pisado:
		_teclado_pisado = true
		_decorado.queue_redraw()
		travesuras.jugo.palabra_en_mundo("jjjjjjjjjj", Vector2(6610, SUELO - 150), Color(0.7, 0.9, 1.0), 14)
		travesuras.cumplir("teclado", Vector2(6566, SUELO - 120))
	if batalla and batalla.fase == BatallaAspi.Fase.PELEA and _espera_papel <= 0.0:
		_espera_papel = 4.0
		var papel := Vector2(6517 + randf_range(-40, 60), SUELO)
		travesuras.jugo.palabra_en_mundo("¡BRRRT!", Vector2(6517, SUELO - 40), Color(1, 1, 1), 11)
		batalla.agregar_mancha(papel, "papel")


func _abrir_cajon(cajon: Interactivo) -> void:
	_cajon_abierto = true
	cajon.marcar_usado()
	sonar("caja")
	for i in 7:
		_calcetines_volando.append(Vector3(CAJON.x + randf_range(-20, 40), CAJON.y, randf_range(0.0, 1.0)))
	var vuelo := create_tween()
	vuelo.tween_interval(1.6)
	vuelo.tween_callback(func() -> void:
		_calcetines_volando.clear()
		_decorado.queue_redraw())
	travesuras.cumplir("cajon", Vector2(5692, SUELO - 140))
	_decorado.queue_redraw()


# --- Valeria por la casa ------------------------------------------------------------------------------------

## Felipe sale al recibidor: Valeria pasa detrás de él a la cocina por un café y cierra la puerta.
func _valeria_a_la_cocina() -> void:
	var puerta_sala: Puerta = puertas["recibidor<sala"]
	var puerta_cocina: Puerta = puertas[PUERTA_COCINA]
	valeria.poner(puerta_sala.position, "recibidor", 1.0, Valeria.Actividad.DE_PIE)
	puerta_sala.abrir_un_momento()
	valeria.caminar_a(puerta_cocina.position.x, func() -> void:
		puerta_cocina.abrir_un_momento()
		valeria.poner(VALERIA_COCINA, "cocina", -1.0, Valeria.Actividad.DE_PIE)
		valeria.fijar_casa())
	await get_tree().create_timer(0.2, false).timeout
	travesuras.decir_valeria("cocina_dieta", true)


## Maullar del otro lado de la puerta de la cocina: Valeria la abre (R19: maullar es llave).
func _maullido_en_la_puerta_de_la_cocina(_felipe_que_maulla: Felipe) -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	if not puerta.cerrada or valeria.cuarto != "cocina" or valeria.audifonos:
		return
	travesuras.decir_valeria("cocina_abre", true)
	_abrir_cocina()


## Popo táctico: Valeria sale con mascarilla, mira la caja y vuelve a la cocina por bolsas... dejando la puerta abierta.
func _valeria_sale_por_bolsas() -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	puerta.abrir_un_momento()
	valeria.mascarilla = true
	valeria.poner(puerta.position, "recibidor", -1.0, Valeria.Actividad.DE_PIE)
	travesuras.decir_valeria("popo", true)
	valeria.caminar_a(valeria.lugar_seguro(DESCANSOS[0].end.x + 70.0), func() -> void:
		valeria.mirando = -1.0
		await get_tree().create_timer(1.2, false).timeout
		valeria.caminar_a(puerta.position.x, func() -> void:
			valeria.mascarilla = false
			valeria.poner(VALERIA_COCINA, "cocina", -1.0, Valeria.Actividad.DE_PIE)))


func _abrir_cocina() -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	puerta.cerrada = false
	puerta.sombra_detras = false
	puerta.queue_redraw()
	(puertas["cocina<recibidor"] as Puerta).cerrada = false


## Recompensa de camino: la puerta de la cocina (popo) o el balcón (A.S.P.I. desenchufada).
func _abrir_camino(id: String) -> void:
	match id:
		"puerta_cocina":
			_abrir_cocina()
		"balcon":
			_abrir_balcon()


func _al_cambiar_recompensas(tipo: String) -> void:
	if tipo == "calcetin":
		_cesta.queue_redraw()
		if calcetines >= TOTAL_CALCETINES:
			desbloquear_logro("Coleccionista de Calcetines")
	elif tipo == "foto" and travesuras.recompensas.fotos >= 2:
		desbloquear_logro("Galería Viral")


func _abrir_balcon() -> void:
	var puerta: Puerta = puertas.get(PUERTA_BALCON)
	if puerta and puerta.cerrada:
		puerta.cerrada = false
		puerta.queue_redraw()
	desbloquear_logro("Desenchufada")


# --- Balcón: alivio y final (M5) ----------------------------------------------------------------------------

## Felipe sube por la maceta a la baranda, se sienta, la cámara se abre a la ciudad y suspira. Al saltar (salto real):
## cámara lenta, "PODER: CAER DE PIE" y el resumen del día (en lugar de la pantalla final).
func _actualizar_balcon(delta: float) -> void:
	if habitacion != "balcon":
		return
	var en_baranda := felipe.is_on_floor() and absf(felipe.global_position.y - (SUELO - 89.0)) < 3.0
	if not sentado_en_baranda:
		_tiempo_baranda = _tiempo_baranda + delta if en_baranda and absf(felipe.velocity.x) < 1.0 else 0.0
		if _tiempo_baranda > 0.3:
			sentado_en_baranda = true
			_decir("balcon", true)
			var camara: Camera2D = felipe.get_node("Camara")
			var abrir := create_tween()
			abrir.tween_property(camara, "offset", Vector2(0, -70), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		return
	if not salto_final and not felipe.is_on_floor() and felipe.velocity.y < 0.0 and felipe.global_position.y < SUELO - 89.0:
		_saltar_del_balcon()


func _saltar_del_balcon() -> void:
	salto_final = true
	# Sale por encima de la baranda: ya no lo detiene nada (cae al patio).
	felipe.set_collision_mask_value(1, false)
	felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, false)
	felipe.tiene_caer_de_pie = true
	Engine.time_scale = 0.35
	travesuras.hud.cartel("PODER NUEVO", "CAER DE PIE", "Siempre aterrizas con estilo", false, 104.0)
	desbloquear_logro("Caer de Pie")
	await get_tree().create_timer(0.6 * 0.35, true, false, false).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(1.0).timeout
	_decir("aterrice", true)
	terminado = true
	felipe.set_physics_process(false)
	await get_tree().create_timer(1.6).timeout
	var resumen := travesuras.mostrar_resumen()
	resumen.cerrado.connect(func() -> void: get_tree().reload_current_scene())


# --- Armado y dibujo ----------------------------------------------------------------------------------------

func _crear_pieza(rect: Rect2, atravesable: bool, nombre: String, estilo: String) -> void:
	var cuerpo := StaticBody2D.new()
	cuerpo.name = nombre
	_piezas[nombre] = cuerpo
	cuerpo.position = rect.position
	var forma := CollisionShape2D.new()
	var caja := RectangleShape2D.new()
	caja.size = rect.size
	forma.shape = caja
	forma.position = rect.size / 2.0
	forma.one_way_collision = atravesable
	if atravesable:
		cuerpo.collision_layer = 0
		cuerpo.set_collision_layer_value(Felipe.CAPA_ATRAVESABLE, true)
	cuerpo.add_child(forma)
	if estilo in ["repisa", "baul", "lugar_visto"]:
		var dibujo := Node2D.new()
		dibujo.z_index = -1
		dibujo.draw.connect(_dibujar_pieza.bind(dibujo, rect.size, estilo))
		cuerpo.add_child(dibujo)
	add_child(cuerpo)


## Cuerpo sólido de una pieza (para las pruebas): su rectángulo actual en el mundo.
func pieza(nombre: String) -> StaticBody2D:
	return _piezas.get(nombre)


## Dibuja todo el arte de ARTE en tres nodos (pared, escalera y muebles).
func _crear_arte() -> void:
	for capa: Array in [["pared", -3], ["escalera", -2], ["mueble", -1]]:
		var lienzo := Node2D.new()
		lienzo.name = "Arte (%s)" % capa[0]
		lienzo.z_index = capa[1]
		lienzo.draw.connect(_dibujar_arte.bind(lienzo, capa[0]))
		add_child(lienzo)


func _dibujar_arte(c: Node2D, capa: String) -> void:
	for datos: Array in ARTE:
		if datos[3] != capa:
			continue
		var textura := ArteNivel.textura(datos[0])
		if textura == null:
			continue
		ArteNivel.dibujar(c, datos[0], datos[1].x + textura.get_width() / 2.0, datos[1].y, datos[2])
	if capa == "escalera":
		# Descanso de la escalera, bajo el vano (madera, como los peldaños).
		var y := SUELO - 150.0
		c.draw_rect(Rect2(2540, y, 100, 8), Color("8a5a3c"))
		c.draw_rect(Rect2(2540, y, 100, 2), Color("b07a52"))
		c.draw_rect(Rect2(2540, y + 8, 100, 1), Color("241c1a"))
		# Viga que sostiene el descanso.
		c.draw_rect(Rect2(2546, y + 8, 6, 142), Color("6e3a26"))
	elif capa == "mueble":
		_dibujar_sofa(c)
		# Imanes del refrigerador.
		for iman: Array in [["iman_manzana", Vector2(3700, SUELO - 150)], ["iman_foto", Vector2(3722, SUELO - 166)], ["iman_pez", Vector2(3708, SUELO - 128)], ["iman_naranja", Vector2(3730, SUELO - 140)]]:
			ArteNivel.dibujar(c, iman[0], iman[1].x, iman[1].y)


func _dibujar_sofa(c: Node2D) -> void:
	var nombre := "sofa_aranado" if _sofa_roto else "sofa_plastico"
	var textura := ArteNivel.textura(nombre)
	if textura:
		ArteNivel.dibujar(c, nombre, ARTE_EXTRA[0][1].x + textura.get_width() / 2.0, SUELO)
	if not _sofa_roto:
		_etiqueta_nuevo(c, Vector2(262, SUELO - 66))
	_etiqueta_nuevo(c, Vector2(RASCADOR_X + 22, SUELO - 130))


## Etiqueta "NUEVO" (rascador y sofá; el texto lo pone el código).
func _etiqueta_nuevo(c: CanvasItem, pos: Vector2) -> void:
	var caja := Rect2(pos, Vector2(30, 11))
	c.draw_rect(caja.grow(1), Color(0.45, 0.12, 0.12))
	c.draw_rect(caja, Color(0.98, 0.95, 0.85))
	c.draw_string(ThemeDB.fallback_font, pos + Vector2(2, 9), "NUEVO", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.1, 0.1))


func _dibujar_pieza(c: Node2D, tamano: Vector2, estilo: String) -> void:
	match estilo:
		"repisa", "lugar_visto":
			# La repisa con ménsulas de Gemini, estirada al ancho de la pieza.
			var arte := ArteNivel.textura("repisa")
			var ancho := tamano.x + 8.0
			c.draw_texture_rect(arte, Rect2(-4, 0, ancho, ancho * arte.get_size().y / arte.get_size().x), false)
			if estilo == "lugar_visto":
				# Caja de recuerdos de Valeria (dibujada: arriba-extra no llegó).
				c.draw_rect(Rect2(22, -24, 40, 24), Color("8f5a3a"))
				c.draw_rect(Rect2(20, -28, 44, 6), Color("b0613f"))
				c.draw_rect(Rect2(36, -18, 12, 6), Color("e8c86a"))
		"baul":
			# Baúl de madera con herrajes (dibujado: arriba-extra no llegó).
			c.draw_rect(Rect2(0, 0, tamano.x, tamano.y), Color("241c1a"))
			c.draw_rect(Rect2(1, 1, tamano.x - 2, tamano.y - 2), Color("8a5232"))
			c.draw_rect(Rect2(1, 1, tamano.x - 2, 14), Color("a8653d"))
			c.draw_rect(Rect2(1, 15, tamano.x - 2, 2), Color("241c1a"))
			for x in [8.0, tamano.x - 12.0]:
				c.draw_rect(Rect2(x, 1, 4, tamano.y - 2), Color("c9a24a"))
			c.draw_rect(Rect2(tamano.x / 2.0 - 4, 13, 8, 8), Color("c9a24a"))


## Decorado sin colisión: lámpara del descanso, retrato familiar, pantalla, teclado e impresora, calcetines que vuelan.
func _dibujar_decorado() -> void:
	var c := _decorado
	# Halo de la lámpara junto a la caja de arena (hito del descanso).
	c.draw_circle(Vector2(1959, SUELO - 140), 30.0, Color(1.0, 0.9, 0.5, 0.15))
	# Retrato familiar del pasillo: Felipe tapa a todos (dibujado).
	var marco := Rect2(4660, 150, 64, 50)
	c.draw_rect(marco.grow(3), Color("6e3a26"))
	c.draw_rect(marco, Color("e8d9c4"))
	for i in 3:
		c.draw_circle(Vector2(marco.position.x + 14 + i * 18, marco.position.y + 16), 6.0, Color("d9a27c"))
	var gato := ArteNivel.textura("retrato")
	if gato:
		c.draw_texture_rect(gato, Rect2(marco.position + Vector2(10, 6), Vector2(44, 44)), false)
	# Escritorio de Valeria: pantalla y teclado; la impresora, en el piso bajo el escritorio (dibujados: arriba-extra no llegó).
	var mesa := SUELO - 98.0
	c.draw_rect(Rect2(6560, mesa - 30, 28, 22), Color("241c1a"))
	c.draw_rect(Rect2(6562, mesa - 28, 24, 18), Color("2f6fb0") if not _teclado_pisado else Color("dfe8f2"))
	if _teclado_pisado:
		c.draw_string(ThemeDB.fallback_font, Vector2(6562, mesa - 15), "jjjj", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("2f2f6f"))
	c.draw_rect(Rect2(6571, mesa - 8, 6, 8), Color("241c1a"))
	c.draw_rect(Rect2(TECLADO.position.x, mesa - 4, TECLADO.size.x, 4), Color("3a3d44"))
	for i in 6:
		c.draw_rect(Rect2(TECLADO.position.x + 2 + i * 6.5, mesa - 3, 4, 1), Color("9aa0a8"))
	c.draw_rect(Rect2(6500, SUELO - 18, 34, 18), Color("241c1a"))
	c.draw_rect(Rect2(6501, SUELO - 17, 32, 16), Color("d8d2c4"))
	c.draw_rect(Rect2(6505, SUELO - 21, 24, 4), Color("f4f1ea"))
	# Calcetines que vuelan del cajón.
	for v in _calcetines_volando:
		var t := fmod(v.z + tiempo * 1.2, 1.0)
		var punto := Vector2(v.x + (t - 0.5) * 80.0, v.y - sin(t * PI) * 90.0)
		ArteNivel.dibujar(c, "calcetin", punto.x, punto.y + 12)
	if _cajon_abierto:
		c.draw_rect(Rect2(CAJON.x - 8, CAJON.y - 8, 30, 10), Color("6e3a26"))
		c.draw_rect(Rect2(CAJON.x - 6, CAJON.y - 10, 26, 4), Color("e59aa2"))


func _dibujar_ropa(c: Interactivo) -> void:
	var colores := [Color("5fa8d3"), Color("f2d36b"), Color("e59aa2")]
	for i in 3:
		c.draw_rect(Rect2(-22, -4 - i * 4, 44, 4), colores[i])
		c.draw_rect(Rect2(-22, -4 - i * 4, 44, 1), colores[i].lightened(0.3))
	if _ropa_firmada:
		for i in 9:
			c.draw_line(Vector2(-18 + i * 4.5, -12 + (i % 3) * 3), Vector2(-15 + i * 4.5, -10 + (i % 3) * 3), Color(0.55, 0.52, 0.5), 1.0)


## El nido de Su Majestad (la cesta de la sala): se llena a la vista con los calcetines del día.
func _dibujar_nido() -> void:
	var nombre := "cesta_vacia"
	if calcetines >= 3:
		nombre = "cesta_llena"
	elif calcetines >= 1:
		nombre = "cesta_3"
	ArteNivel.dibujar(_cesta, nombre, 70.0, SUELO)
