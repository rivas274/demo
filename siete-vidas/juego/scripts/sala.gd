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
## Dintel de las puertas (2,05 m): la línea de los cuadros (G8).
const DINTEL := SUELO - 248.0
## Mesita de la sala (S-2, tanda 3E): tablero a 58 px (48 cm), de la columna 6 a la 76 de su arte.
const MESITA_X := 162.0
const ALTO := SUELO + 30.0
const ANCHO := 7880.0
## Medio ancho del rectángulo sagrado de cada puerta: medio vano (52 px) más 40 px libres a cada lado (B3).
const MEDIO_RECT_PUERTA := 92.0

## Habitaciones en orden de ruta: [rectángulo, nombre, estilo de pared]. Muros de 160 px entre una y otra.
## Ninguna es más angosta que la pantalla (640 px).
const HABITACIONES := [
	[Rect2(0, TECHO, 1280, SUELO - TECHO), "sala", "tapiz"],
	[Rect2(1440, TECHO, 1200, SUELO - TECHO), "recibidor", "tapiz_verde"],
	[Rect2(2800, TECHO, 960, SUELO - TECHO), "cocina", "azulejo"],
	[Rect2(4000, TECHO, 1240, SUELO - TECHO), "pasillo", "tapiz_azul"],
	[Rect2(5400, TECHO, 720, SUELO - TECHO), "dormitorio", "rosa"],
	[Rect2(6440, TECHO, 640, SUELO - TECHO), "estudio", "tapiz_mostaza"],
	[Rect2(7240, TECHO, 640, SUELO - TECHO), "balcon", "exterior"],
]
## Orden de la ruta (las reglas de diseño lo usan para comprobar que se enseña antes de pedir).
const RUTA := ["sala", "recibidor", "cocina", "pasillo", "dormitorio", "estudio", "balcon"]
## Ventanas (las cinco de la casa con la misma medida, pedido del creador 2026-10-19): alféizar a 90 cm del piso
## (ALFEIZAR, 109 px), vidrio de unos 150 × 120 px y arriba a 1,90 m: nada bajo la barra del HUD ni pegado al techo.
## La de la sala y la del pasillo son arte con su propia vista; las de la cocina, el dormitorio y el estudio se
## recortan en la pared (se ve la ciudad) y llevan marco, alféizar y tela por código (FondoApartamento).
const ALFEIZAR := SUELO - 109.0
const VENTANA_COCINA := Rect2(3150, ALFEIZAR - 120, 150, 120)
## La del dormitorio va sobre la cama, con la cortina de Gemini a los lados (dos paños desde una barra, hasta el piso).
const VENTANA_DORMITORIO := Rect2(5669, ALFEIZAR - 120, 150, 120)
## La del estudio va sobre el escritorio (el monitor queda delante del vidrio).
const VENTANA_ESTUDIO := Rect2(6655, ALFEIZAR - 120, 150, 120)
const VENTANAS := [VENTANA_COCINA, VENTANA_DORMITORIO, VENTANA_ESTUDIO]
## Cortina del dormitorio: cuánto tapa cada paño de la ventana y dónde termina la tela en el arte (45 px: remate de
## 8 px, tela de 34 y 3 px de barra). La barra queda CORTINA_SOBRE_VENTANA px sobre el marco; lo que sobra de tela
## abajo queda tras el piso (no se dibuja).
const CORTINA_ADENTRO := 9.0
const CORTINA_FIN_TELA := 42.0
const CORTINA_SOBRE_VENTANA := 18.0
## Vidrio de la ventana del pasillo (en el mundo): la caja de pizza del lugar visto queda detrás, sobre el toldo (G3).
## El arte trae el alféizar y el toldo; la ventana se alarga por arriba con código (M7) hasta la altura de las demás.
const VIDRIO_PASILLO := Rect2(4337, SUELO - 224, 86, 106)
## Lo que se agrega arriba del arte de la ventana (marco, panel y vidrio), hasta la fila de arriba del arte.
const VENTANA_PASILLO_ARRIBA := Rect2(4260, SUELO - 229, 180, 80)

## Puertas: [nombre, posición (al pie, al centro), puerta a la que lleva]. Van de a pares.
const PUERTAS := [
	["sala>recibidor", Vector2(1188, SUELO), "recibidor<sala"],
	["recibidor<sala", Vector2(1532, SUELO), "sala>recibidor"],
	["recibidor>cocina", Vector2(2070, SUELO), "cocina<recibidor"],  # cerrada: Valeria adentro
	["cocina<recibidor", Vector2(2892, SUELO), "recibidor>cocina"],
	["recibidor>pasillo", Vector2(2346, SUELO), "pasillo<recibidor"],  # pie de la escalera de fondo
	["pasillo<recibidor", Vector2(4092, SUELO), "recibidor>pasillo"],  # vano arriba de la escalera
	["pasillo>dormitorio", Vector2(4536, SUELO), "dormitorio<pasillo"],  # entornada: se araña
	["dormitorio<pasillo", Vector2(5492, SUELO), "pasillo>dormitorio"],
	["pasillo>estudio", Vector2(5148, SUELO), "estudio<pasillo"],
	["estudio<pasillo", Vector2(6532, SUELO), "pasillo>estudio"],
	["estudio>balcon", Vector2(6988, SUELO), "balcon<estudio"],  # cerrada hasta desenchufar a A.S.P.I.
	["balcon<estudio", Vector2(7332, SUELO), "estudio>balcon"],
]
## Puerta del baño (2.4.1 del plan de ambientes): cerrada, con el marco de las demás, en la capa de puertas. No es
## habitación ni va en PUERTAS (R7): es un lugar insinuado para la maña futura «Abrir puertas».
const BANO := Vector2(4740, SUELO)
## A cuánto dice su frase al acercarse, a cuánto se oye el goteo y a cuánto tiene que quedarse quieto para la manija.
const BANO_FRASE := 90.0
const BANO_GOTEO := 300.0
const BANO_MANIJA := 60.0
const PUERTA_BALCON := "estudio>balcon"
const PUERTA_COCINA := "recibidor>cocina"
const PUERTA_DORMITORIO := "pasillo>dormitorio"
## La escalera de fondo: al pie se "asciende" como por una puerta, escalón por escalón (Felipe.subir_escalera).
const PUERTA_ESCALERA := "recibidor>pasillo"
const ESCALERA_PIE := Vector2(2346, SUELO)
## Pies de Felipe en cada uno de los 7 escalones (arte escalera_peldanos espejado, de 25 px de huella y ~21 de alto).
const PELDANOS := [
	Vector2(2340, SUELO - 23), Vector2(2360, SUELO - 45), Vector2(2386, SUELO - 67), Vector2(2410, SUELO - 88),
	Vector2(2434, SUELO - 107), Vector2(2458, SUELO - 130), Vector2(2490, SUELO - 150),
]
## Arriba de la escalera: el descanso con el vano bajo, por donde se pasa al pasillo.
const ESCALERA_CIMA := Vector2(2567, SUELO - 150)
## Lo que ocupa la escalera (rectángulo sagrado: nada se le cruza).
const ESCALERA_RECT := Rect2(2322, SUELO - 398, 318, 398)  # el vano mide lo que una puerta (G2)

## Arte que se dibuja: [imagen de assets/nivel1/, (x izquierda, base), espejo, capa]. Capas: "pared" (detrás de todo),
## "mueble" (detrás de Felipe) y "escalera" (peldaños y vano, detrás de Felipe).
## Cuadros (G8): el borde de arriba en el dintel de las puertas (DINTEL), salvo los que cuelgan a otra altura a
## propósito (galería asimétrica de la sala) o se apoyan en una repisa (paisaje).
const ARTE := [
	["ventana_sala", Vector2(170, ALFEIZAR + 14.0), false, "pared"],  # el borde del alféizar del arte está 14 px sobre su base
	["retrato", Vector2(660, DINTEL + 100.0), false, "pared"],  # S-1: sobre la silla izquierda y la punta de la mesa
	["marco_foto", Vector2(756, DINTEL + 47.0), false, "pared"],  # S-1: Felipe panza arriba (tanda 3E)
	["marco_huella", Vector2(808, DINTEL + 68.0), false, "pared"],  # S-1: la huella de Felipe en yeso
	["mesita_sala", Vector2(MESITA_X, SUELO), false, "mueble"],  # S-2: rincón de Valeria, pegada al brazo del sofá
	["silla_v2", Vector2(680, SUELO), false, "mueble"],
	["mesa_v2", Vector2(745, SUELO), false, "mueble"],
	["silla_v2", Vector2(929, SUELO), true, "mueble"],
	["perchero", Vector2(1646, SUELO - 140.0), false, "pared"],  # R-1: sobre el zapatero, sin tapar el paso agachado
	["zapatero", Vector2(1626, SUELO), false, "mueble"],
	["zapatillas", Vector2(1794, SUELO), false, "mueble"],  # R-2: tiradas entre el zapatero y la caja de arena
	["marco_viral", Vector2(1866, DINTEL + 59.0), false, "pared"],  # R-3: el video viral, origen de la reja
	["caja_arena", Vector2(1832, SUELO), false, "mueble"],
	["lampara", Vector2(1942, SUELO), false, "mueble"],
	["librero_v2", Vector2(2162, SUELO), false, "mueble"],
	["escalera_peldanos", Vector2(2322, SUELO), true, "escalera"],
	["vano", Vector2(2497, SUELO - 150), false, "escalera"],  # hueco cuadrado con el marco de las puertas (no un arco)
	["reloj", Vector2(3075, DINTEL + 43.0), false, "pared"],  # 41 × 43, con segundero (C-8)
	["lata", Vector2(3044, SUELO), false, "mueble"],  # C-7: la lata de atún abierta, al otro lado del tazón
	["llave_agua", Vector2(3463, SUELO - 110.0), false, "pared"],  # C-5: la llave con el trapo, fuera de la patrulla
	["silla_v2", Vector2(3400, SUELO), false, "mueble"],
	["alacenas", Vector2(3461, SUELO - 182), false, "pared"],
	["meson", Vector2(3464, SUELO), false, "mueble"],
	["microondas", Vector2(3570, SUELO - 109), false, "mueble"],
	["refrigerador", Vector2(3674, SUELO), false, "mueble"],
	["polaroid_1", Vector2(3690, SUELO - 172.0), false, "mueble"],  # C-6: fotos de Felipe entre los imanes
	["polaroid_2", Vector2(3734, SUELO - 150.0), false, "mueble"],
	["polaroid_3", Vector2(3688, SUELO - 106.0), false, "mueble"],
	["baul", Vector2(4186, SUELO), false, "mueble"],
	["aparador", Vector2(4256, SUELO), false, "mueble"],
	["retrato_familiar", Vector2(4900, DINTEL + 80.0), false, "pared"],  # P-4: el trono (cojín) con su retrato
	["ventana_pasillo", Vector2(4260, ALFEIZAR + 12.0), false, "pared"],  # apoyada en la consola; alféizar 12 px sobre su base
	["cojin", Vector2(4984, SUELO), false, "mueble"],
	["paisaje", Vector2(5943, SUELO - 145), false, "pared"],  # D-1: apoyado en la repisa, entre la cómoda y el ropero
	["banquito", Vector2(5586, SUELO), false, "mueble"],
	["libro", Vector2(5598, SUELO - 53.0), false, "mueble"],  # D-3: libro a medio leer, atrás del banquito
	["cama", Vector2(5644, SUELO), false, "mueble"],
	["comoda", Vector2(5850, SUELO), false, "mueble"],
	["ropero", Vector2(6016, SUELO), false, "mueble"],
	["cesta_vacia", Vector2(5947, SUELO), false, "mueble"],
	["silla_v2", Vector2(6624, SUELO), false, "mueble"],
	["escritorio", Vector2(6688, SUELO), false, "mueble"],
	["monitor", Vector2(6746, SUELO - 97), false, "mueble"],
	["impresora", Vector2(6695, SUELO), false, "mueble"],
	["base_carga", Vector2(6800, SUELO), false, "mueble"],
	["corcho", Vector2(6831, SUELO - 202.0), false, "pared"],  # E-2: el tablero de contenido de Valeria (entre el paño y la puerta)
	["regadera", Vector2(7434, SUELO), false, "mueble"],  # B-3: isla de jardinería
	["saco_tierra", Vector2(7466, SUELO), false, "mueble"],
	["maceta_rota", Vector2(7494, SUELO), false, "mueble"],
	["maceta_grande", Vector2(7530, SUELO), false, "mueble"],
	["baranda", Vector2(7600, SUELO), false, "mueble"],
]
## Alfombras (tanda 3E): [imagen, x izquierda], en la franja del piso (después del piso y antes de las sombras).
const ALFOMBRAS := [["alfombra_sala", 232.0], ["alfombra_pasillo", 4370.0], ["alfombra_dormitorio", 5598.0]]
## Fachada del edificio alrededor de la puerta del balcón (B-1): el hueco (x 89 a 221 del arte) queda detrás de la
## puerta-ventana.
const FACHADA_BALCON := Vector2(7177, SUELO)
## Objetos de pared que proyectan sombra (G5): 2 px hacia abajo y 1 px a la derecha (la luz entra por el oeste).
const SOMBRA_PARED := ["retrato", "marco_foto", "marco_huella", "perchero", "marco_viral", "reloj", "alacenas", "llave_agua", "retrato_familiar", "paisaje", "corcho"]
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
	[Rect2(MESITA_X + 6, SUELO - 58, 70, 6), true, "Mesita", "arte", "mesita_sala"],  # 48 cm
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
	[Rect2(4186, SUELO - 47, 70, 47), true, "Baúl", "arte", "baul"],  # 40 cm (arriba-extra); se pasa por delante
	[Rect2(4258, SUELO - 97, 152, 50), false, "Consola", "arte", "aparador"],  # 80 cm, 47 px libres debajo
	[Rect2(4264, ALFEIZAR, 172, 6), true, "Alféizar", "arte", "ventana_pasillo"],  # 90 cm, sobre la consola
	# Dormitorio.
	[Rect2(5591, SUELO - 53, 42, 6), true, "Banquito", "arte", "banquito"],
	[Rect2(5644, SUELO - 65, 197, 65), false, "Cama", "arte", "cama"],  # colchón a 54 cm
	[Rect2(5855, SUELO - 96, 74, 96), false, "Cómoda", "arte", "comoda"],  # 80 cm
	[Rect2(5940, SUELO - 145, 70, 6), true, "Repisa", "repisa", ""],  # 1,20 m, repisa de pared entre la cómoda y el ropero
	[Rect2(6016, SUELO - 185, 104, 185), false, "Ropero", "arte", "ropero"],  # 1,53 m
	[Rect2(5935, SUELO - 290, 80, 6), true, "Repisa alta", "lugar_visto", ""],  # 2,40 m: se vuelve con Afilar Garras
	[Rect2(5954, SUELO - 35, 46, 6), true, "Cesta de ropa", "arte", "cesta_vacia"],  # para salir del hueco entre la cómoda y el ropero
	# Estudio de Valeria (la pelea).
	[Rect2(6637, SUELO - 55, 40, 6), true, "Silla del estudio", "arte", "silla_v2"],
	[Rect2(6705, SUELO - 98, 126, 6), true, "Escritorio", "arte", "escritorio"],  # 81 cm
	[Rect2(6836, SUELO - 151, 60, 6), true, "Repisa de las macetas", "repisa", ""],  # 1,25 m
	# Balcón.
	[Rect2(7535, SUELO - 32, 38, 6), true, "Maceta grande", "arte", "maceta_grande"],
	[Rect2(7601, SUELO - 89, 182, 6), true, "Baranda", "arte", "baranda"],  # 74 cm
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
const CALCETINES := [Vector2(370, SUELO - 49), Vector2(3716, SUELO - 216), Vector2(5892, SUELO - 96)]
const CALCETIN_REFRIGERADOR := Vector2(3716, SUELO - 216)
const TOTAL_CALCETINES := 3
const CAJA_CARTON := Vector2(3360, SUELO)
## Ratones de cuerda: [posición, límite izquierdo, límite derecho]. Uno enseña el zarpazo y otro cuida el pollo.
## El del mesón patrulla entre el borde y el microondas, sin pasar por el pollo (que está sobre el microondas, G5).
const RATONES := [
	[Vector2(3240, SUELO), 3200.0, 3290.0],
	[Vector2(3518, SUELO - 108), 3500.0, 3536.0],
]
const LASER := [Vector2(4900, SUELO), 4840.0, 4980.0]
## Objetos que se tiran con el botón de acción: [posición, tipo].
const TIRABLES := [
	[Vector2(905, SUELO - 91), "vaso"],
	[Vector2(1766, SUELO - 97), "llaves"],
	[Vector2(4378, SUELO - 97), "vaso"],  # bien adentro de la consola (Gemini: rozaba el borde)
	[Vector2(6715, SUELO - 98), "vaso"],
	[Vector2(6814, SUELO - 98), "taza"],  # taza de café de Valeria (reemplazó al rollo de papel higiénico)
	[Vector2(6850, SUELO - 151), "maceta"],
	[Vector2(6882, SUELO - 151), "maceta"],
]
## Comida: [posición, tipo]. El pollo es el almuerzo de Valeria (travesura "almuerzo"): espera sobre el microondas,
## fuera de la patrulla del ratón del mesón (G5).
const POLLO := Vector2(3612, SUELO - 162)
const COMIDA := [[Vector2(3010, SUELO), "tazon"], [POLLO, "pollo"]]
## A.S.P.I.: [base de carga, límite izquierdo, límite derecho] dentro del estudio.
const ASPI := [Vector2(6837, SUELO), 6490.0, 7030.0]
## Puntos de descanso: la caja de arena (recibidor) y el cojín (pasillo, a 2 px del rectángulo de la puerta del jefe).
const DESCANSOS := [Rect2(1852, SUELO - 60, 71, 70), Rect2(4984, SUELO - 40, 70, 50)]
## La meta: la baranda del balcón (sentarse y saltar da Caer de Pie), en el tramo sin maceta (M6).
const SALIDA := 7690.0
## Lo que se ve al saltar del balcón (G1): la cámara baja CAIDA_BALCON px y Felipe aterriza en el toldo de la
## panadería de abajo (solo existe durante el salto final).
const CAIDA_BALCON := 230.0
const TOLDO := Rect2(7580, SUELO + 196, 300, 8)
## Sofá arañable (con el plástico nuevo): [centro de la base, ancho, alto]. Línea "sofa" de la agenda.
const SOFA_ARANABLE := [Vector2(360, SUELO), 240.0, 100.0]
const RASCADOR_X := 570.0
## Valeria: sentada en el sofá viendo la serie, y su lugar en la cocina (preparando café).
const VALERIA_SOFA := Vector2(410, SUELO - 49)
const VALERIA_COCINA := Vector2(3080, SUELO)
## Cajón de los calcetines (en la cómoda), ropa doblada (en la cama) y teclado del escritorio. Lo interactuable
## dibujado por código declara su tamaño (lado menor ≥ 24 px, R8 y G7; prueba_reglas_nivel lo mide).
const CAJON := Vector2(5862, SUELO - 75)
const RECT_CAJON := Rect2(-14, -12, 60, 24)
## La ropa va en el medio de la cama, apoyada en el edredón (ROPA_HUNDIDA): ROPA es donde la alcanza Felipe parado
## en el colchón; el rectángulo cubre la pila tal como se dibuja.
const ROPA := Vector2(5772, SUELO - 65)
const ROPA_HUNDIDA := 9.0
const RECT_ROPA := Rect2(-26, ROPA_HUNDIDA - 48.0, 52, 48)
const TECLADO := Rect2(6740, SUELO - 122, 52, 24)
## Lo interactuable que se dibuja por código: [nombre, rectángulo en el mundo] (G7).
const DIBUJADOS_INTERACTUABLES := [
	["Cajón de los calcetines", Rect2(CAJON + RECT_CAJON.position, RECT_CAJON.size)],
	["Ropa doblada", Rect2(ROPA + RECT_ROPA.position, RECT_ROPA.size)],
	["Teclado de Valeria", TECLADO],
]
## Segundos agachado sobre la caja de arena para el popo táctico, y quieto frente al láser para ignorarlo.
const TIEMPO_POPO := 1.2
## Donde sale la foto vergonzosa del popo táctico (cae flotando al piso, junto a la lámpara).
const FOTO_POPO := Vector2(1962, SUELO - 40)
## Fotos vergonzosas del nivel (las tres secretas): juntarlas todas da «Galería Viral».
const TOTAL_FOTOS := 3
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
	[Rect2(5500, TECHO, 140, SUELO - TECHO), "{saltar} Banquito, cama, cómoda. Escalera real.", 0],
	[Rect2(5800, TECHO, 150, SUELO - TECHO), "{interactuar} El cajón de los calcetines. Botín.", 7],
	[Rect2(7480, TECHO, 140, SUELO - TECHO), "{saltar} La maceta, la baranda… y la libertad.", 0],
]
## Dónde pasa cada travesura de la Agenda y su reacción (R18).
const AGENDA_SITIOS := {
	"perdon": [Vector2(905, SUELO - 91), "«¡GRAVEDAD: 1 · VASO: 0!», Valeria: «¡PIPE!» y después «¿Quién es el bebito más gordito?»"],
	"sofa": [Vector2(370, SUELO - 49), "«¡PLÁSTICO: 0!» y Valeria: «¡Lo estoy pagando en 12 cuotas!»"],
	"popo": [Vector2(1888, SUELO - 45), "Censura irónica, Valeria con mascarilla: «¡ACABO DE LIMPIARLA!» y se le cae una foto"],
	"almuerzo": [POLLO, "«¡EN SU CARA!» y Valeria: «¡ESE ERA MI ALMUERZO!»"],
	"laser": [Vector2(4900, SUELO), "El puntero se apaga de vergüenza"],
	"cajon": [CAJON, "Calcetines volando por todo el cuarto"],
	"teclado": [Vector2(6766, SUELO - 98), "La pantalla dice «jjjjjjjjjj» y la impresora escupe papeles"],
	"desenchufar": [Vector2(6837, SUELO), "«¡APAGADA!» y «Limpieza cancelada.»"],
}
## Lugares que se ven antes de poder alcanzarlos (R17): [qué, dónde, con qué maña se vuelve].
const LUGARES_VISTOS := [
	["Toldo del vecino con la caja de pizza (afuera, tras el vidrio del pasillo)", PIZZA, "Caer de Pie"],
	["Caja de recuerdos de Valeria (repisa alta del dormitorio)", Rect2(5935, SUELO - 300, 80, 10), "Afilar Garras"],
]
## La caja de pizza, sobre el toldo del vecino, del otro lado del vidrio (dentro de VIDRIO_PASILLO).
## Escala de gato (M7): 34 × 24 con la tapa abierta, grasa y vapor; se lee desde el pasillo.
const PIZZA := Rect2(4372, SUELO - 167, 34, 24)
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


## Estilo de marco de una puerta de PUERTAS: "balcon" (puerta-ventana), "vano" (hueco cuadrado sin hoja, arriba de la
## escalera de fondo) o "" (puerta de madera). Las dos caras de un par usan el mismo (prueba_reglas_nivel lo mide); el
## pie de la escalera no dibuja puerta: su otra cara es el vano del descanso (ARTE "vano"), con el mismo marco.
static func estilo_puerta(nombre: String) -> String:
	for datos: Array in PUERTAS:
		if datos[0] == nombre:
			var caras := [datos[0], datos[2]]
			if PUERTA_BALCON in caras:
				return "balcon"
			if PUERTA_ESCALERA in caras:
				return "vano"
	return ""


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
var _tiempo_cayendo := 0.0
var _aterrizo_final := false
var _toldo: StaticBody2D
## Lienzos del arte por capa ("pared", "escalera", "mueble"): se redibujan cuando algo cambia de imagen (G4).
var _lienzos := {}
## Mientras la cámara muestra la meta, Felipe no dice sus lecciones (se pisaban con «La libertad está allá arriba»).
var _mostrando_meta := false
## Imagen del sofá que se dibujó por última vez (las pruebas ven que cambió al romper el plástico).
var sofa_dibujado := ""
## Puerta del baño y cuánto lleva Felipe quieto cerca de ella; goteos.
var bano: Puerta
var _quieto_bano := 0.0
var _goteo_bano := 0.0
var _goteo_cocina := 0.0
## Detalles que se mueven o cuentan quién vive aquí (G9, G10): pelos, arañazos, polvo, cables, segundero, gotas.
var _ambiente: Node2D
var _paso_brisa := -1
## Bases opacas del arte (sombras de contacto, G5): imagen -> [x0, x1, patas [[x]...]].
var _bases := {}
## Jirones de plástico que vuelan al romperlo: [posición, velocidad, giro].
var _jirones: Array = []

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
	# Capas de pantalla de la tabla única (Capas): título, intro y pausa tapan todo (G7).
	$Interfaz.layer = Capas.CAPA_INTERFAZ
	var capa_pantallas := CanvasLayer.new()
	capa_pantallas.name = "Capa de pantallas"
	capa_pantallas.layer = Capas.CAPA_PANTALLAS
	add_child(capa_pantallas)
	pantallas = Pantallas.new()
	pantallas.reiniciar.connect(func() -> void: get_tree().reload_current_scene())
	pantallas.empezar.connect(_mostrar_meta)
	pantallas.modo_cambiado.connect(_al_cambiar_modo)
	capa_pantallas.add_child(pantallas)
	var medidores := Medidores.new()
	medidores.felipe = felipe
	logro_desbloqueado.connect(medidores.mostrar_logro)
	$Interfaz.add_child(medidores)
	medidores.pantallas = pantallas
	travesuras = Travesuras.new(felipe, Agenda.NIVEL_1)
	add_child(travesuras)
	medidores.dialogo = travesuras.dialogo
	medidores.anuncios = travesuras.anuncios
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
	# El negro de las puertas tapa también el diálogo, los carteles y los logros (G7).
	var capa_fundido := CanvasLayer.new()
	capa_fundido.name = "Capa del fundido"
	capa_fundido.layer = Capas.CAPA_FUNDIDO
	add_child(capa_fundido)
	capa_fundido.add_child(_fundido)
	if mostrar_titulo:
		pantallas.mostrar_titulo()
	_al_cambiar_modo(pantallas.modo)
	_actualizar_camara()


func _crear_puertas() -> void:
	for datos: Array in PUERTAS:
		var puerta := Puerta.new(datos[0], datos[1], datos[2], datos[1].y - TECHO)
		# Las dos caras de una puerta se ven igual (el creador, 2026-10-19): mismo estado a cada lado.
		var caras := [datos[0], datos[2]]
		puerta.cerrada = PUERTA_BALCON in caras or PUERTA_COCINA in caras
		puerta.entornada = PUERTA_DORMITORIO in caras
		puerta.escalera = datos[0] == PUERTA_ESCALERA
		puerta.sombra_detras = datos[0] == PUERTA_COCINA
		puerta.estilo = estilo_puerta(datos[0])
		puerta.cruzada.connect(cruzar)
		add_child(puerta)
		puertas[datos[0]] = puerta
	# Puerta del baño: cerrada siempre; «Probar» la hace temblar y Felipe dice su frase (no lleva a ningún cuarto).
	bano = Puerta.new("Puerta del baño", BANO, "", BANO.y - TECHO)
	bano.cerrada = true
	bano.bano = true
	bano.cruzada.connect(_probar_bano)
	add_child(bano)
	# Las dos caras de una misma puerta se abren y se cierran juntas (Valeria abre de un lado, se ve del otro).
	for nombre: String in puertas:
		var puerta: Puerta = puertas[nombre]
		puerta.par = puertas.get(puerta.destino)
	# La puerta entornada del dormitorio se abre arañándola (R19: arañar es llave).
	var entornada := Aranable.new("Puerta entornada", 70.0, 200.0)
	entornada.position = (puertas[PUERTA_DORMITORIO] as Puerta).position
	entornada.aranazos_para_romper = 1
	entornada.verbo_indicador = "Arañar"
	entornada.roto.connect(func(_o: Aranable) -> void:
		for cara: Puerta in [puertas[PUERTA_DORMITORIO], (puertas[PUERTA_DORMITORIO] as Puerta).par]:
			cara.entornada = false
			cara.queue_redraw()
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
	rascador.z_index = Capas.MUEBLES
	add_child(rascador)
	travesuras.conectar_rascador(rascador)
	sofa = Aranable.new("Sofa arañable", SOFA_ARANABLE[1], SOFA_ARANABLE[2])
	sofa.position = SOFA_ARANABLE[0]
	sofa.aranado.connect(_al_aranar_sofa)
	add_child(sofa)
	travesuras.conectar_aranable(sofa, "sofa", AGENDA_SITIOS["sofa"][0] + Vector2(0, -20))
	sofa.roto.connect(_romper_plastico)
	# Cajón de los calcetines (cómoda) y ropa doblada (cama).
	var cajon := Interactivo.new("Cajon", "Saquear", RECT_CAJON)
	cajon.position = CAJON
	cajon.al_usar = func(f: Felipe) -> void: f.dar_manotazo(_abrir_cajon.bind(cajon))
	add_child(cajon)
	# La ropa se desordena (Felipe se acicala encima): un verbo distinto del sofá («Firmar») y de la puerta («Arañar»), M7.
	var ropa := Interactivo.new("Ropa doblada", "Desordenar", RECT_ROPA)
	ropa.position = ROPA
	ropa.al_usar = func(f: Felipe) -> void:
		f.acicalarse()
		_ropa_firmada = true
		ropa.queue_redraw()
		_decir("ropa", true)
	ropa.dibujo = _dibujar_ropa
	# Detrás de Felipe: se acicala encima de la ropa, no detrás de la pila.
	ropa.z_index = Capas.MUEBLES
	add_child(ropa)
	# Quien oye maullidos del otro lado de la puerta de la cocina (Valeria está adentro).
	var oido := OidoPuerta.new()
	oido.position = (puertas[PUERTA_COCINA] as Puerta).position + Vector2(0, -40)
	oido.oido.connect(_maullido_en_la_puerta_de_la_cocina)
	add_child(oido)
	# Bajo el balcón: la fachada y el toldo de la panadería (solo se ven en el salto final, G1).
	var fachada := Node2D.new()
	fachada.name = "Fachada"
	fachada.z_index = Capas.FACHADA
	fachada.draw.connect(_dibujar_fachada.bind(fachada))
	add_child(fachada)
	_decorado = Node2D.new()
	_decorado.name = "Decorado"
	_decorado.z_index = Capas.MUEBLES
	_decorado.draw.connect(_dibujar_decorado)
	add_child(_decorado)
	_ambiente = Node2D.new()
	_ambiente.name = "Ambiente"
	_ambiente.z_index = Capas.MUEBLES
	_ambiente.draw.connect(_dibujar_ambiente)
	add_child(_ambiente)
	_cesta = Node2D.new()
	_cesta.name = "Nido"
	_cesta.z_index = Capas.MUEBLES
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
	travesuras.anuncios.testigos.append(valeria)
	# Si Valeria va a salir a reaccionar en el cuarto de Felipe, el cartel espera a que salga (G5).
	travesuras.anuncios.reaccion_en_curso = func() -> bool: return _en_escena and habitacion == "recibidor" and _escenas_valeria_actual in ["bolsas", "maullido"] and not (valeria.cuarto == "recibidor" and valeria.visible)


func _crear_aspi() -> void:
	aspi = Aspi.new(ASPI[1], ASPI[2])
	aspi.position = ASPI[0]
	aspi.necesita_aturdir = true
	aspi.apagado.connect(_abrir_balcon)
	add_child(aspi)
	travesuras.anuncios.testigos.append(aspi)
	if batalla_con_jefe:
		batalla = BatallaAspi.new(aspi, felipe, self)
		add_child(batalla)
		batalla.presentacion.anuncios = travesuras.anuncios
		for objeto in tirables:
			if Sala.habitacion_de(objeto.position) == "estudio":
				batalla.agregar_municion(objeto)
	# Ensayo sin riesgo en el pasillo: A.S.P.I. sale a limpiar lo que Felipe tira (R1, R12).
	ensayo = EnsayoAspi.new(self, Vector2((puertas["pasillo>estudio"] as Puerta).position.x, SUELO))
	add_child(ensayo)
	# Detrás de la puerta del estudio, el pasamanos y lo demás encima.
	_pasamanos = Node2D.new()
	_pasamanos.name = "Pasamanos"
	_pasamanos.z_index = Capas.PRIMER_PLANO
	_pasamanos.draw.connect(func() -> void:
		var datos: Array = PASAMANOS
		var textura := ArteNivel.textura(datos[0])
		if textura:
			ArteNivel.dibujar(_pasamanos, datos[0], datos[1].x + textura.get_width() / 2.0, datos[1].y, datos[2])
		# Arañazos viejos en el poste de arranque, a la altura de Felipe (G9).
		ArteNivel.dibujar(_pasamanos, "aranazo_3", 2333.0, SUELO - 24.0, false, Color(1, 1, 1, 0.7)))
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
	_actualizar_frases_de_lugar()
	_actualizar_bano(delta)
	_actualizar_goteo_cocina(delta)
	_ambiente.queue_redraw()
	# La cortina con brisa (D-4) y las plantas de la baranda (B-4) se mecen cada 0,5 s.
	var paso := int(tiempo * 2.0)
	if paso != _paso_brisa and habitacion in ["dormitorio", "balcon"]:
		_paso_brisa = paso
		(_lienzos["mueble"] as Node2D).queue_redraw()
	var en_escalera := felipe.en_escalera() or (habitacion == "recibidor" and felipe.global_position.x > ESCALERA_RECT.position.x and felipe.global_position.y < SUELO - 4.0)
	_pasamanos.modulate.a = OPACIDAD_PASAMANOS if en_escalera else 1.0
	if habitacion == "pasillo":
		# El vapor de la pizza se mueve.
		(_lienzos["pared"] as Node2D).queue_redraw()
	if not _calcetines_volando.is_empty() or habitacion == "estudio":
		# En el estudio la serie del monitor titila.
		_decorado.queue_redraw()
	if not _jirones.is_empty():
		for j: Array in _jirones:
			j[1].y += 600.0 * delta
			j[0] += j[1] * delta
		_jirones = _jirones.filter(func(j: Array) -> bool: return j[0].y < SUELO)
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
		_escena_valeria("a_la_cocina")
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


## Opacidad del negro de las puertas (0 a 1).
func fundido_alfa() -> float:
	return _fundido.modulate.a


## Título, introducción, pausa o final: la interfaz del juego (HUD, diálogo, palabras, avisos) no se ve (G7).
func _al_cambiar_modo(modo: Pantallas.Modo) -> void:
	var jugando := modo == Pantallas.Modo.JUGANDO
	if travesuras:
		travesuras.mostrar_interfaz(jugando)


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
		if zona.grow_individual(0, 0, 0, 4).has_point(felipe.global_position) and not _cruzando and not _mostrando_meta:
			_lecciones_vistas[i] = true
			travesuras.dialogo.decir("felipe", LECCIONES[i][1], LECCIONES[i][2])


## Al empezar, la cámara muestra un momento el balcón: la meta (R4). Felipe lo dice y arranca la dieta. Sin cortes
## duros (M4): del negro de la introducción se abre al balcón, y del balcón se funde a la sala.
func _mostrar_meta() -> void:
	_mostrando_meta = true
	_fundido.modulate.a = 1.0
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
	await _fundir(0.0, 0.4)
	travesuras.jugo.palabra("EL BALCÓN · ARRIBA, AL FONDO", Vector2(320, 150), Color(1.0, 0.85, 0.45), 14)
	_decir("meta", true)
	await get_tree().create_timer(1.6).timeout
	await _fundir(1.0, 0.3)
	felipe.get_node("Camara").make_current()
	camara_meta.queue_free()
	await _fundir(0.0, 0.35)
	_mostrando_meta = false
	_decir("inicio")


func sonar(nombre: String, tono := 1.0) -> void:
	var ruta := "res://assets/sonidos/%s.wav" % nombre
	if not ResourceLoader.exists(ruta):
		return
	for reproductor in _sonidos:
		if not reproductor.playing:
			reproductor.stream = load(ruta)
			reproductor.pitch_scale = tono
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
				# Sobre la mesa de donde cayó (no a la altura del mueble), en un celeste fuerte con contorno (M1).
				travesuras.jugo.palabra_en_mundo("¡GRAVEDAD: 1 · VASO: 0!", Vector2(donde.x, SUELO - 120), Color(0.45, 0.85, 1.0), 15)
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
	travesuras.anuncios.marcar_chiste(Rect2(240, SUELO - 130, 240, 130), 1.5)
	# El sofá se redibuja sin plástico ni etiqueta (G4) y los jirones del plástico salen volando.
	(_lienzos["mueble"] as Node2D).queue_redraw()
	for i in 10:
		var x := SOFA_ARANABLE[0].x + randf_range(-90.0, 90.0)
		_jirones.append([Vector2(x, SUELO - randf_range(40.0, 95.0)), Vector2(randf_range(-80.0, 80.0), randf_range(-220.0, -120.0)), randf_range(-8.0, 8.0)])
	_decorado.queue_redraw()


func _al_comer(comida: Comida) -> void:
	if comida.tipo == "tazon":
		_decir("tazon", true)
	elif comida.tipo == "pollo":
		var en_su_cara := valeria.ve(comida.global_position)
		# Los snacks caen en el mesón, al lado del microondas: no sobre la cara de Felipe (M2).
		travesuras.cumplir("almuerzo", Vector2(POLLO.x - 70.0, SUELO - 120.0))
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
		# La recompensa es una foto vergonzosa (G6): la que Valeria tenía lista para subir se le cae del bolsillo
		# al ver la arena. Las tres secretas dan fotos; la galería completa da «Galería Viral».
		travesuras.cumplir("popo", FOTO_POPO)
		if valeria.cuarto == "cocina" and not valeria.audifonos:
			_escena_valeria("bolsas")


func _censura_ironica() -> void:
	travesuras.anuncios.marcar_chiste(Rect2(felipe.global_position + Vector2(-40, -110), Vector2(80, 110)), 2.0)
	travesuras.jugo.palabra_en_mundo("CONTENIDO SENSIBLE", felipe.global_position + Vector2(0, -70), Color(1.0, 1.0, 1.0), 14)
	var pegatina := Node2D.new()
	pegatina.name = "Censura"
	pegatina.z_index = Capas.CENSURA
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


## Frases que salen una vez al ver algo: la pizza del lugar visto (desde el alféizar) y el láser (la primera vez).
func _actualizar_frases_de_lugar() -> void:
	if not felipe.is_on_floor():
		return
	var pies := felipe.global_position
	var alfeizar: Rect2 = _rect_pieza("Alféizar")
	if absf(pies.y - alfeizar.position.y) < 3.0 and pies.x > alfeizar.position.x and pies.x < alfeizar.end.x:
		_decir("pizza", true)
	if habitacion == "pasillo" and _laser and not _laser.apagado and absf(_laser.global_position.x - pies.x) < 200.0 and pies.y > SUELO - 4.0:
		_decir("laser_visto")


## La puerta del baño (2.4.1): al acercarse la primera vez, su frase; si después se queda quieto cerca 2 s, la manilla
## da un destello, Felipe la mira de reojo y dice la segunda. El goteo solo se oye a BANO_GOTEO px o menos.
func _actualizar_bano(delta: float) -> void:
	if habitacion != "pasillo" or bano == null:
		_quieto_bano = 0.0
		return
	var pies := felipe.global_position
	var distancia := absf(pies.x - BANO.x)
	var en_el_piso := felipe.is_on_floor() and pies.y > SUELO - 4.0
	_goteo_bano += delta
	if _goteo_bano >= 2.6:
		_goteo_bano = 0.0
		if distancia <= BANO_GOTEO:
			sonar("goteo", 0.8)
	if en_el_piso and distancia <= BANO_FRASE and not _cruzando:
		_decir("bano", true)
	if not _dijo.has("bano") or _dijo.has("bano_manija"):
		return
	if en_el_piso and distancia <= BANO_MANIJA and absf(felipe.velocity.x) < 1.0:
		_quieto_bano += delta
	else:
		_quieto_bano = 0.0
	if _quieto_bano >= 2.0:
		bano.destellar()
		if distancia > 1.0:
			felipe.mirando = signf(BANO.x - pies.x)
			felipe.sprite.flip_h = felipe.mirando < 0.0
		_decir("bano_manija", true)


## Probar la puerta del baño: la hoja tiembla 1 px y no cede.
func _probar_bano(_puerta: Puerta) -> void:
	bano.temblar()
	sonar("golpe", 1.4)
	_decir("bano", true)


## Goteo de la llave de la cocina (C-5): una gota cada 3 s con su «plic» (anticipa el del baño).
func _actualizar_goteo_cocina(delta: float) -> void:
	_goteo_cocina += delta
	if _goteo_cocina >= 3.0:
		_goteo_cocina = 0.0
		if habitacion == "cocina" and ArteNivel.textura("llave_agua"):
			sonar("goteo")


## Rectángulo de una pieza de PIEZAS por su nombre (vacío si no está).
static func _rect_pieza(nombre: String) -> Rect2:
	for pieza: Array in PIEZAS:
		if pieza[2] == nombre:
			return pieza[0]
	return Rect2()


## Pisar el teclado de Valeria: "jjjjjjjjjj" (secreta). En la pelea, la impresora escupe papeles: manchas extra.
func _actualizar_teclado(delta: float) -> void:
	_espera_papel = maxf(0.0, _espera_papel - delta)
	var encima := felipe.is_on_floor() and TECLADO.grow_individual(0, 6, 0, 6).has_point(felipe.global_position)
	if not encima:
		return
	if not _teclado_pisado:
		_teclado_pisado = true
		_decorado.queue_redraw()
		travesuras.jugo.palabra_en_mundo("jjjjjjjjjj", Vector2(6810, SUELO - 150), Color(0.7, 0.9, 1.0), 14)
		# La pantalla con «jjjjjj» es el chiste: el cartel no la tapa (G5).
		travesuras.anuncios.marcar_chiste(Rect2(6730, SUELO - 160, 110, 70), 3.0)
		travesuras.cumplir("teclado", Vector2(6766, SUELO - 120))
	if batalla and batalla.fase == BatallaAspi.Fase.PELEA and _espera_papel <= 0.0:
		_espera_papel = 4.0
		var papel := Vector2(6717 + randf_range(-40, 60), SUELO)
		travesuras.jugo.palabra_en_mundo("¡BRRRT!", Vector2(6717, SUELO - 40), Color(1, 1, 1), 11)
		batalla.agregar_mancha(papel, "papel")


func _abrir_cajon(cajon: Interactivo) -> void:
	_cajon_abierto = true
	travesuras.anuncios.marcar_chiste(Rect2(CAJON.x - 60, CAJON.y - 110, 160, 120), 1.8)
	cajon.marcar_usado()
	sonar("caja")
	for i in 7:
		_calcetines_volando.append(Vector3(CAJON.x + randf_range(-20, 40), CAJON.y, randf_range(0.0, 1.0)))
	var vuelo := create_tween()
	vuelo.tween_interval(1.6)
	vuelo.tween_callback(func() -> void:
		_calcetines_volando.clear()
		_decorado.queue_redraw())
	travesuras.cumplir("cajon", Vector2(5892, SUELO - 140))
	_decorado.queue_redraw()


# --- Valeria por la casa ------------------------------------------------------------------------------------

## Escenas de Valeria por la casa: una a la vez, en cola (una escena nunca pisa a otra). Valeria camina de verdad,
## abre cada puerta antes de pasar y no cambia de cuarto sin cruzar una (G2, G3 de la revisión 3).
var _escenas_valeria: Array[String] = []
var _en_escena := false
var _escenas_valeria_actual := ""


func _escena_valeria(nombre: String) -> void:
	if nombre in _escenas_valeria:
		return
	_escenas_valeria.append(nombre)
	if _en_escena:
		return
	_en_escena = true
	while not _escenas_valeria.is_empty():
		var escena: String = _escenas_valeria.pop_front()
		_escenas_valeria_actual = escena
		match escena:
			"a_la_cocina":
				await _valeria_a_la_cocina()
			"maullido":
				await _valeria_abre_la_cocina()
			"bolsas":
				await _valeria_sale_por_bolsas()
	_en_escena = false
	_escenas_valeria_actual = ""


## ¿Hay una escena de Valeria en curso o esperando?
func valeria_en_escena() -> bool:
	return _en_escena


## Espera (en cuadros de física) a que se cumpla algo, como mucho `segundos`.
func _esperar_que(condicion: Callable, segundos: float) -> void:
	var t := 0.0
	while t < segundos and not condicion.call() and is_inside_tree():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


## Valeria camina hasta x en su cuarto y espera a llegar.
func _valeria_camina(x: float) -> void:
	valeria.caminar_a(x)
	await _esperar_que(func() -> bool: return valeria.actividad != Valeria.Actividad.CAMINANDO, 30.0)


## Valeria sale por una puerta (camina, la abre, entra al vano) y espera a que haya salido.
func _valeria_sale(puerta: Puerta, soltar := false) -> void:
	valeria.salir_por(puerta, Callable(), soltar)
	await _esperar_que(func() -> bool: return valeria.actividad == Valeria.Actividad.FUERA, 30.0)


## Valeria entra por una puerta a ese cuarto y espera a que esté afuera del vano.
func _valeria_entra(puerta: Puerta, cuarto: String, hacia: float) -> void:
	await valeria.entrar_por(puerta, cuarto, hacia)


## Felipe sale al recibidor: Valeria deja la serie, camina a la puerta de la sala, entra al recibidor detrás de él
## («Y tú no entras: dieta.»), cruza a la cocina abriendo y cerrando la puerta, y se queda adentro (G2, G3).
func _valeria_a_la_cocina() -> void:
	valeria.interrumpir()
	await _valeria_sale(puertas["sala>recibidor"])
	await _valeria_entra(puertas["recibidor<sala"], "recibidor", 1.0)
	travesuras.decir_valeria("cocina_dieta", true)
	await _valeria_sale(puertas[PUERTA_COCINA])
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	await _valeria_camina(VALERIA_COCINA.x)
	valeria.fijar_casa()


## Maullar del otro lado de la puerta de la cocina: Valeria la abre (R19: maullar es llave).
func _maullido_en_la_puerta_de_la_cocina(_felipe_que_maulla: Felipe) -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	if not puerta.cerrada or valeria.cuarto != "cocina" or valeria.audifonos:
		return
	_escena_valeria("maullido")


## Valeria va a la puerta, la abre y se asoma en el vano (la puerta se ve abrirse con ella adentro, no sola) para
## decir su frase; deja la puerta abierta y vuelve a su café (G2).
func _valeria_abre_la_cocina() -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	if not puerta.cerrada or valeria.cuarto != "cocina":
		return
	await _valeria_sale(puertas["cocina<recibidor"])
	await valeria.asomarse(puerta, "recibidor", -1.0 if felipe.global_position.x < puerta.global_position.x else 1.0)
	travesuras.decir_valeria("cocina_abre", true)
	_abrir_cocina()
	await get_tree().create_timer(1.4, false).timeout
	await valeria.volver_adentro(puerta)
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	await _valeria_camina(VALERIA_COCINA.x)
	valeria.fijar_casa()


## Popo táctico: Valeria sale con mascarilla por la puerta, mira la caja y vuelve a la cocina por bolsas... dejando la
## puerta abierta (es un efecto, no la recompensa: la recompensa es la foto, G6).
func _valeria_sale_por_bolsas() -> void:
	if valeria.cuarto != "cocina" or valeria.audifonos:
		return
	valeria.mascarilla = true
	await _valeria_sale(puertas["cocina<recibidor"])
	await _valeria_entra(puertas[PUERTA_COCINA], "recibidor", -1.0)
	travesuras.decir_valeria("popo", true)
	await _valeria_camina(valeria.lugar_seguro(DESCANSOS[0].end.x + 70.0))
	valeria.girar(-1.0, true)
	await get_tree().create_timer(1.2, false).timeout
	await _valeria_sale(puertas[PUERTA_COCINA])
	_abrir_cocina()
	await _valeria_entra(puertas["cocina<recibidor"], "cocina", 1.0)
	valeria.mascarilla = false
	await _valeria_camina(VALERIA_COCINA.x)
	valeria.fijar_casa()


func _abrir_cocina() -> void:
	var puerta: Puerta = puertas[PUERTA_COCINA]
	puerta.cerrada = false
	puerta.sombra_detras = false
	puerta.queue_redraw()
	(puertas["cocina<recibidor"] as Puerta).cerrada = false
	(puertas["cocina<recibidor"] as Puerta).queue_redraw()


## Recompensa de camino: el balcón (A.S.P.I. desenchufada).
func _abrir_camino(id: String) -> void:
	match id:
		"balcon":
			_abrir_balcon()


func _al_cambiar_recompensas(tipo: String) -> void:
	if tipo == "calcetin":
		_cesta.queue_redraw()
		if calcetines >= TOTAL_CALCETINES:
			desbloquear_logro("Coleccionista de Calcetines")
	elif tipo == "foto" and travesuras.recompensas.fotos >= TOTAL_FOTOS:
		desbloquear_logro("Galería Viral")


func _abrir_balcon() -> void:
	var puerta: Puerta = puertas.get(PUERTA_BALCON)
	if puerta and puerta.cerrada:
		for cara: Puerta in [puerta, puerta.par]:
			cara.cerrada = false
			cara.queue_redraw()
	desbloquear_logro("Desenchufada")


# --- Balcón: alivio y final (M5, G1) ------------------------------------------------------------------------

## Felipe sube por la maceta a la baranda (en el tramo libre de macetas), se queda quieto y se acicala mientras la
## cámara se abre a la ciudad, y suspira (no hay animación de sentarse todavía: M6). Al saltar (salto real): cámara
## lenta con la cámara pegada a él, que baja hasta el toldo de la panadería de abajo; aterriza a la vista con el
## polvo grande y recién ahí sale el cartel "PODER NUEVO · CAER DE PIE", sin taparlo, y el resumen del día.
func _actualizar_balcon(delta: float) -> void:
	if habitacion != "balcon":
		return
	if salto_final:
		_actualizar_caida(delta)
		return
	var en_baranda := felipe.is_on_floor() and absf(felipe.global_position.y - (SUELO - 89.0)) < 3.0
	if not sentado_en_baranda:
		_tiempo_baranda = _tiempo_baranda + delta if en_baranda and absf(felipe.velocity.x) < 1.0 else 0.0
		if _tiempo_baranda > 0.3:
			sentado_en_baranda = true
			_decir("balcon", true)
			felipe.acicalarse()
			var camara: Camera2D = felipe.get_node("Camara")
			var abrir := create_tween()
			abrir.tween_property(camara, "offset", Vector2(0, -70), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		return
	if not felipe.is_on_floor() and felipe.velocity.y < 0.0 and felipe.global_position.y < SUELO - 89.0:
		_saltar_del_balcon()


func _saltar_del_balcon() -> void:
	salto_final = true
	_tiempo_cayendo = 0.0
	# Sale por encima de la baranda: no lo detiene nada hasta pasar el piso del balcón.
	felipe.set_collision_mask_value(1, false)
	felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, false)
	felipe.tiene_caer_de_pie = true
	# El toldo de la panadería de abajo (con paredes a los lados para que nadie se salga del cuadro).
	_toldo = StaticBody2D.new()
	_toldo.name = "Toldo de la panaderia"
	for rect: Rect2 in [TOLDO, Rect2(TOLDO.position.x - 20, ALTO, 20, CAIDA_BALCON + 60), Rect2(TOLDO.end.x, ALTO, 20, CAIDA_BALCON + 60)]:
		var forma := CollisionShape2D.new()
		var caja := RectangleShape2D.new()
		caja.size = rect.size
		forma.shape = caja
		forma.position = rect.get_center()
		_toldo.add_child(forma)
	add_child(_toldo)
	# La cámara lo sigue hacia abajo: se abre el límite de abajo del balcón y vuelve a centrarse en él.
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_bottom = int(ALTO + CAIDA_BALCON)
	var bajar := create_tween()
	bajar.tween_property(camara, "offset", Vector2(0, 20), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	Engine.time_scale = 0.4
	felipe.aterrizo.connect(_aterrizar_en_el_toldo, CONNECT_ONE_SHOT)


func _actualizar_caida(delta: float) -> void:
	if _aterrizo_final:
		return
	_tiempo_cayendo += delta
	# Pasado el piso del balcón, vuelve a chocar (solo queda el toldo abajo).
	if felipe.global_position.y > ALTO + 62.0 and not felipe.get_collision_mask_value(1):
		felipe.set_collision_mask_value(1, true)
	# Seguro: si algo falla, el final llega igual.
	if _tiempo_cayendo > 2.5:
		_aterrizar_en_el_toldo(1.0)


func _aterrizar_en_el_toldo(_fuerza: float) -> void:
	if _aterrizo_final:
		return
	_aterrizo_final = true
	Engine.time_scale = 1.0
	travesuras.jugo.sacudir(0.2, 0.6)
	sonar("golpe")
	# El cartel sale después de verlo aterrizar y a una altura que no lo tapa.
	await get_tree().create_timer(0.35).timeout
	travesuras.hud.cartel("PODER NUEVO", "CAER DE PIE", "Siempre aterrizas con estilo", false)
	desbloquear_logro("Caer de Pie")
	_decir("aterrice", true)
	await get_tree().create_timer(1.2).timeout
	terminado = true
	felipe.set_physics_process(false)
	await get_tree().create_timer(1.6).timeout
	var resumen := travesuras.mostrar_resumen()
	resumen.cerrado.connect(func() -> void:
		if get_tree().current_scene:
			get_tree().reload_current_scene())


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
	if estilo in ["repisa", "lugar_visto"]:
		var dibujo := Node2D.new()
		dibujo.z_index = Capas.MUEBLES
		dibujo.draw.connect(_dibujar_pieza.bind(dibujo, rect.size, estilo))
		cuerpo.add_child(dibujo)
	add_child(cuerpo)


## Cuerpo sólido de una pieza (para las pruebas): su rectángulo actual en el mundo.
func pieza(nombre: String) -> StaticBody2D:
	return _piezas.get(nombre)


## Dibuja todo el arte de ARTE en tres nodos (pared, escalera y muebles).
func _crear_arte() -> void:
	for capa: Array in [["pared", Capas.ARTE_PARED], ["escalera", Capas.ESCALERA], ["mueble", Capas.MUEBLES]]:
		var lienzo := Node2D.new()
		lienzo.name = "Arte (%s)" % capa[0]
		lienzo.z_index = capa[1]
		lienzo.draw.connect(_dibujar_arte.bind(lienzo, capa[0]))
		add_child(lienzo)
		_lienzos[capa[0]] = lienzo


func _dibujar_arte(c: Node2D, capa: String) -> void:
	if capa == "mueble":
		# La cortina va detrás de la cómoda, la cesta y el ropero.
		_dibujar_cortina(c)
	elif capa == "pared":
		# Sombra de lo colgado en la pared (G5): la silueta, 1 px a la derecha y 2 px abajo, al 20 %.
		for datos: Array in ARTE:
			if datos[3] == "pared" and datos[0] in SOMBRA_PARED:
				var t := ArteNivel.textura(datos[0])
				if t:
					ArteNivel.dibujar(c, datos[0], datos[1].x + t.get_width() / 2.0 + 1.0, datos[1].y + 2.0, datos[2], Color(0, 0, 0, 0.2))
		_dibujar_zocalo_escalera(c)
	for datos: Array in ARTE:
		if datos[3] != capa:
			continue
		if datos[0] == "baranda":
			_dibujar_baranda(c, datos[1])
			continue
		var textura := ArteNivel.textura(datos[0])
		if textura == null:
			continue
		ArteNivel.dibujar(c, datos[0], datos[1].x + textura.get_width() / 2.0, datos[1].y, datos[2])
	if capa == "escalera":
		_dibujar_descanso(c)
	elif capa == "pared":
		_dibujar_ventana_pasillo(c)
		# Alfombras sobre la franja del piso (antes de las sombras de contacto).
		for alfombra: Array in ALFOMBRAS:
			var t := ArteNivel.textura(alfombra[0])
			if t:
				c.draw_texture(t, Vector2(alfombra[1], SUELO))
		_dibujar_sombras_de_contacto(c)
	elif capa == "mueble":
		_dibujar_sofa(c)
		# Imanes del refrigerador.
		for iman: Array in [["iman_manzana", Vector2(3700, SUELO - 150)], ["iman_foto", Vector2(3722, SUELO - 166)], ["iman_pez", Vector2(3708, SUELO - 128)], ["iman_naranja", Vector2(3730, SUELO - 140)]]:
			ArteNivel.dibujar(c, iman[0], iman[1].x, iman[1].y)


## Sombras de contacto (crítica de Gemini): cada mueble que se apoya en el piso deja una sombra dura de pixel en su
## base (dos franjas, la de abajo más angosta), así no parece pegado sobre la madera. Va en la capa de la pared:
## debajo de los muebles y de Felipe. La lámpara del recibidor además deja un charco de luz cálida en el piso.
const SIN_SOMBRA := ["escalera_peldanos", "vano"]


func _dibujar_sombras_de_contacto(c: Node2D) -> void:
	var piezas: Array = []
	for datos: Array in ARTE:
		if datos[3] == "mueble" and is_equal_approx(datos[1].y, SUELO) and not datos[0] in SIN_SOMBRA:
			piezas.append(datos)
	piezas.append_array(ARTE_EXTRA)
	# G5: franja de 3 px al 45 % con el ancho de la base opaca real, otra de 2 px al 28 % debajo y un bloque de 2 × 2
	# más oscuro bajo cada pata.
	for datos: Array in piezas:
		var nombre: String = datos[0]
		var base := _base_opaca(nombre)
		if base.is_empty():
			continue
		var x: float = datos[1].x
		var ancho := float(ArteNivel.textura(nombre).get_width())
		var espejo: bool = datos.size() > 2 and datos[2]
		var x0: float = x + (ancho - base[1] if espejo else base[0])
		var x1: float = x + (ancho - base[0] if espejo else base[1])
		c.draw_rect(Rect2(x0 - 2.0, SUELO - 1.0, x1 - x0 + 4.0, 3.0), Color(0.12, 0.05, 0.03, 0.45))
		c.draw_rect(Rect2(x0 + 2.0, SUELO + 2.0, maxf(x1 - x0 - 4.0, 2.0), 2.0), Color(0.12, 0.05, 0.03, 0.28))
		for pata: Array in base[2]:
			var centro: float = x + (ancho - pata[0] if espejo else pata[0])
			c.draw_rect(Rect2(roundf(centro) - 1.0, SUELO, 2.0, 2.0), Color(0.08, 0.03, 0.02, 0.55))
	# Charco de luz de la lámpara de pie, en franjas (no un degradado suave).
	var lampara := Vector2(1959, SUELO)
	for franja: Vector3 in [Vector3(70, 0, 0.07), Vector3(50, 2, 0.08), Vector3(30, 4, 0.1)]:
		c.draw_rect(Rect2(lampara.x - franja.x / 2.0, lampara.y + franja.y, franja.x, 8.0 - franja.y), Color(1.0, 0.85, 0.5, franja.z))


## Base opaca de una imagen: [x0, x1 de las 3 filas de abajo, patas [[centro], ...] de la fila de abajo] (en cache).
func _base_opaca(nombre: String) -> Array:
	if _bases.has(nombre):
		return _bases[nombre]
	var textura := ArteNivel.textura(nombre)
	var base: Array = []
	if textura:
		var imagen := textura.get_image()
		var x0 := imagen.get_width()
		var x1 := 0
		for y in range(imagen.get_height() - 3, imagen.get_height()):
			for x in imagen.get_width():
				if imagen.get_pixel(x, y).a > 0.5:
					x0 = mini(x0, x)
					x1 = maxi(x1, x + 1)
		var patas: Array = []
		var desde := -1
		var abajo := imagen.get_height() - 1
		for x in imagen.get_width() + 1:
			var opaco := x < imagen.get_width() and imagen.get_pixel(x, abajo).a > 0.5
			if opaco and desde < 0:
				desde = x
			elif not opaco and desde >= 0:
				if x - desde <= 16:
					patas.append([(desde + x) / 2.0])
				desde = -1
		if x1 > x0:
			base = [float(x0), float(x1), patas]
	_bases[nombre] = base
	return base


## R-6: el zócalo sube con la escalera, en escalones de pixel bajo el larguero (el borde de abajo del arte de los
## peldaños), hasta el faldón del descanso.
var _zocalo_escalera: Array = []


func _dibujar_zocalo_escalera(c: Node2D) -> void:
	var t := ArteNivel.textura("escalera_peldanos")
	if t == null:
		return
	if _zocalo_escalera.is_empty():
		var imagen := t.get_image()
		var ancho := imagen.get_width()
		var x := 0
		while x < ancho:
			# Tramos de 24 px: el escalón de zócalo arranca a la altura del larguero en el lado alto del tramo (lo que
			# queda bajo el larguero, detrás de la escalera, no se ve).
			var abajo := imagen.get_height()
			for k in range(x, mini(x + 24, ancho)):
				var columna := ancho - 1 - k  # el arte va en espejo
				for y in range(imagen.get_height() - 1, -1, -1):
					if imagen.get_pixel(columna, y).a > 0.5:
						abajo = mini(abajo, y)
						break
			_zocalo_escalera.append(Vector3(2322 + x, mini(x + 24, ancho) - x, SUELO - t.get_height() + abajo + 1))
			x += 24
	for tramo: Vector3 in _zocalo_escalera:
		if tramo.z > SUELO - 20.0 or tramo.x >= 2536.0:
			continue
		var ancho_tramo := minf(tramo.y, 2536.0 - tramo.x)
		c.draw_rect(Rect2(tramo.x, tramo.z, ancho_tramo, 18), Color("9a5b3c"))
		c.draw_rect(Rect2(tramo.x, tramo.z, ancho_tramo, 2), Color("c98a5e"))
		c.draw_rect(Rect2(tramo.x, tramo.z + 17, ancho_tramo, 1), Color("6e3a26"))


## Baranda del balcón con sus plantas que se mecen 1 px (B-4), cada maceta con su fase.
func _dibujar_baranda(c: Node2D, pos: Vector2) -> void:
	var t := ArteNivel.textura("baranda")
	if t == null:
		return
	var arriba := pos.y - t.get_height()
	var corte := 38.0
	var paso := int(tiempo * 2.0)
	c.draw_texture_rect_region(t, Rect2(pos.x, arriba + corte, t.get_width(), t.get_height() - corte), Rect2(0, corte, t.get_width(), t.get_height() - corte))
	for maceta: Vector3 in [Vector3(0, 95, 0), Vector3(95, t.get_width() - 95, 1)]:
		var vaiven := 1.0 if (paso + int(maceta.z)) % 2 == 0 else 0.0
		c.draw_texture_rect_region(t, Rect2(pos.x + maceta.x + vaiven, arriba, maceta.y, corte), Rect2(maceta.x, 0, maceta.y, corte))


## Descanso de la escalera (M1): un rellano grueso, como un escalón ancho, con el faldón cerrado hasta el piso
## (un armario bajo la escalera, de tablas como los peldaños). Sin poste suelto.
func _dibujar_descanso(c: Node2D) -> void:
	var arriba := SUELO - 150.0
	var rellano := Rect2(2532, arriba, 108, 14)
	var faldon := Rect2(2536, arriba + 14, 104, 150 - 14)
	var oscuro := Color("241c1a")
	# Faldón: tablas verticales con un marco y una puertita de armario.
	c.draw_rect(faldon, Color("6e4630"))
	for i in 7:
		var x := faldon.position.x + 6.0 + i * 14.0
		c.draw_rect(Rect2(x, faldon.position.y, 1, faldon.size.y), Color("5a3626"))
	c.draw_rect(Rect2(faldon.position.x, faldon.position.y, 4, faldon.size.y), Color("8a5a3c"))
	var puertita := Rect2(2566, SUELO - 96, 44, 96)
	c.draw_rect(puertita.grow(2), oscuro)
	c.draw_rect(puertita, Color("7d5038"))
	c.draw_rect(Rect2(puertita.position + Vector2(4, 4), Vector2(36, 40)), Color("8a5a3c"))
	c.draw_rect(Rect2(puertita.position + Vector2(4, 50), Vector2(36, 42)), Color("8a5a3c"))
	c.draw_rect(Rect2(puertita.position.x + 34, puertita.position.y + 46, 4, 4), Color("c9a24a"))
	c.draw_rect(Rect2(faldon.position.x, SUELO - 8, faldon.size.x, 8), Color("5a3626"))
	# Rellano: tabla gruesa con canto claro y sombra abajo.
	c.draw_rect(rellano.grow(1), oscuro)
	c.draw_rect(rellano, Color("8a5a3c"))
	c.draw_rect(Rect2(rellano.position, Vector2(rellano.size.x, 3)), Color("b07a52"))
	c.draw_rect(Rect2(rellano.position.x, rellano.end.y - 3, rellano.size.x, 3), Color("6e3a26"))
	c.draw_rect(Rect2(faldon.position.x, faldon.position.y, faldon.size.x, 3), Color(0, 0, 0, 0.3))


## Pantalla del monitor (en el mundo): ahí sale «jjjjjj» al pisar el teclado.
const PANTALLA_MONITOR := Rect2(6746 + 6, SUELO - 97 - 48 + 6, 33, 28)


## Ventana del pasillo (G3): la caja de pizza está AFUERA, sobre el toldo del vecino, detrás del vidrio (el arte de
## Gemini la traía sobre el alféizar; la herramienta la borra). El vidrio con reflejos va encima de la caja.
func _dibujar_ventana_pasillo(c: Node2D) -> void:
	# Parte de arriba de la ventana (M7): sigue las columnas del arte hacia arriba (contorno, marco del muro, marco de
	# madera, panel de la izquierda, parante y vidrio), así la ventana es una sola y no una caja encima del arte.
	var arriba := VENTANA_PASILLO_ARRIBA
	var izq := arriba.position.x
	var oscuro := Color8(31, 8, 4)
	var columnas := [
		[4, 10, Color8(210, 179, 150)], [12, 2, Color8(222, 194, 173)], [14, 4, Color8(186, 124, 80)],
		[18, 48, Color8(212, 181, 152)], [66, 10, Color8(199, 157, 135)], [162, 4, Color8(149, 86, 51)],
		[167, 9, Color8(210, 179, 150)],
	]
	for columna: Array in columnas:
		c.draw_rect(Rect2(izq + columna[0], arriba.position.y, columna[1], arriba.size.y), columna[2])
	var cielo := Rect2(VIDRIO_PASILLO.position.x, arriba.position.y + 5, VIDRIO_PASILLO.size.x - 1, arriba.size.y - 3)
	for i in 6:
		c.draw_rect(Rect2(cielo.position.x, cielo.position.y + i * cielo.size.y / 6.0, cielo.size.x, cielo.size.y / 6.0 + 1), Color(0.98, 0.86, 0.66).lerp(Color(0.95, 0.72, 0.6), i / 6.0))
	# Techos lejanos del vecindario, pálidos.
	for techo: Vector3 in [Vector3(4340, 24, 14), Vector3(4362, 18, 22), Vector3(4392, 30, 10), Vector3(4404, 20, 18)]:
		c.draw_rect(Rect2(techo.x, arriba.end.y - techo.z, techo.y, techo.z), Color(0.83, 0.6, 0.55))
	# Contornos oscuros (afuera, junto al parante y al marco derecho) y el dintel de madera arriba.
	for x: float in [4.0, 76.0, 166.0, 175.0]:
		c.draw_rect(Rect2(izq + x, arriba.position.y, 1, arriba.size.y), oscuro)
	c.draw_rect(Rect2(izq + 4, arriba.position.y, 172, 5), Color8(185, 122, 81))
	c.draw_rect(Rect2(izq + 4, arriba.position.y + 4, 172, 1), Color8(143, 86, 57))
	c.draw_rect(Rect2(izq + 4, arriba.position.y, 172, 1), oscuro)
	# Caja de pizza AFUERA, sobre el toldo del vecino (G3), abierta: tapa levantada con la mancha de grasa, la pizza
	# adentro y vapor que sube (un poco azulada: está lejos y tras el vidrio).
	var caja := PIZZA
	var lejos := Color(0.9, 0.92, 1.0)
	var base := Rect2(caja.position.x, caja.end.y - 9, caja.size.x, 9)
	var tapa := PackedVector2Array([base.position + Vector2(3, 0), base.position + Vector2(caja.size.x - 3, 0), Vector2(caja.end.x - 6, caja.position.y + 3), Vector2(caja.position.x + 6, caja.position.y + 3)])
	c.draw_colored_polygon(tapa, Color("d9b074") * lejos)
	c.draw_polyline(tapa + PackedVector2Array([tapa[0]]), Color("6e4a2a") * lejos, 1.0)
	c.draw_circle(Vector2(caja.position.x + 13, caja.position.y + 9), 4.0, Color("a8763c") * lejos)
	c.draw_circle(Vector2(caja.position.x + 21, caja.position.y + 7), 2.5, Color("a8763c") * lejos)
	c.draw_rect(base, Color("e0b878") * lejos)
	c.draw_rect(Rect2(base.position.x + 2, base.position.y + 1, base.size.x - 4, 4), Color("f2c14e") * lejos)
	for p: Vector2 in [Vector2(7, 2), Vector2(15, 3), Vector2(24, 2), Vector2(11, 4), Vector2(28, 4)]:
		c.draw_rect(Rect2(base.position + p, Vector2(2, 2)), Color("c0392b") * lejos)
	c.draw_rect(Rect2(base.position.x, base.position.y + 5, base.size.x, 4), Color("b98a50") * lejos)
	c.draw_rect(Rect2(base.position.x, base.end.y, base.size.x, 1), Color(0, 0, 0, 0.35))
	var t := tiempo
	for i in 3:
		var x0 := caja.position.x + 8.0 + i * 9.0
		var puntos := PackedVector2Array()
		for k in 6:
			var y := caja.position.y - 2.0 - k * 3.0 - fmod(t * 6.0 + i * 4.0, 3.0)
			puntos.append(Vector2(x0 + sin(k * 1.3 + t * 3.0 + i) * 2.0, y))
		c.draw_polyline(puntos, Color(1, 1, 1, 0.55), 1.0)
	# Vidrio: tinte frío y dos reflejos en diagonal por encima de la caja y del toldo.
	var vidrio := VIDRIO_PASILLO
	c.draw_rect(vidrio, Color(0.75, 0.88, 1.0, 0.14))
	# Los reflejos quedan dentro del vidrio (no cruzan al panel de la izquierda).
	for desde: float in [34.0, 76.0]:
		c.draw_colored_polygon(PackedVector2Array([
			vidrio.position + Vector2(desde, 0), vidrio.position + Vector2(desde + 8, 0),
			vidrio.position + Vector2(desde - 22, vidrio.size.y), vidrio.position + Vector2(desde - 30, vidrio.size.y),
		]), Color(1, 1, 1, 0.16))


## Cortina del dormitorio (arte de Gemini, `dormitorio-cortina-alta`): dos paños, el derecho en espejo, colgados de
## una sola barra con un remate en cada punta, a los lados de la ventana que está sobre la cama; el tramo de barra entre
## los paños se estira desde una columna de la misma barra (`cortina_barra`). La barra va CORTINA_SOBRE_VENTANA px
## sobre el marco y la tela baja hasta el piso (lo que sobra del arte no se dibuja), detrás de la cama y la cómoda.
## Sin colisión: en el nivel 1 no se trepa (con Afilar Garras se subirá por la tela hasta la barra y, de ahí, a la
## repisa alta con la caja de recuerdos).
func _dibujar_cortina(c: Node2D) -> void:
	var textura := ArteNivel.textura("cortina")
	if textura == null:
		return
	var ancho := float(textura.get_width())
	var arriba := VENTANA_DORMITORIO.position.y - 3.0 - CORTINA_SOBRE_VENTANA
	var alto := minf(SUELO - 1.0 - arriba, float(textura.get_height()))
	var izquierda := VENTANA_DORMITORIO.position.x + CORTINA_ADENTRO - CORTINA_FIN_TELA
	var derecha := VENTANA_DORMITORIO.end.x - CORTINA_ADENTRO + CORTINA_FIN_TELA
	var barra := ArteNivel.textura("cortina_barra")
	if barra:
		var desde := izquierda + ancho
		c.draw_texture_rect(barra, Rect2(desde, arriba + 1.0, derecha - ancho - desde, barra.get_height()), false)
	# Brisa (D-4): la mitad de abajo de cada paño se corre 1 px de forma alterna cada 0,5 s, con otra fase en cada
	# paño (el derecho va en espejo).
	var medio := roundf(alto * 0.55)
	var paso := int(tiempo * 2.0)
	for pano in 2:
		var vaiven := 1.0 if (paso + pano) % 2 == 0 else 0.0
		if pano == 1:
			c.draw_set_transform(Vector2(derecha, 0.0), 0.0, Vector2(-1, 1))
		var x := izquierda if pano == 0 else 0.0
		c.draw_texture_rect_region(textura, Rect2(x, arriba, ancho, medio), Rect2(0, 0, ancho, medio))
		c.draw_texture_rect_region(textura, Rect2(x + vaiven, arriba + medio, ancho, alto - medio), Rect2(0, medio, ancho, alto - medio))
		c.draw_set_transform(Vector2.ZERO)


func _dibujar_sofa(c: Node2D) -> void:
	var nombre := "sofa_aranado" if _sofa_roto else "sofa_plastico"
	sofa_dibujado = nombre
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
				# Caja de recuerdos de Valeria (arriba-extra), sobre la repisa alta.
				ArteNivel.dibujar(c, "caja_recuerdos", tamano.x / 2.0, 0.0)


## Decorado sin colisión: lámpara del descanso, retrato familiar, pantalla, teclado e impresora, calcetines que vuelan.
func _dibujar_decorado() -> void:
	var c := _decorado
	# Escritorio de Valeria: el monitor y la impresora son arte (arriba-extra); la pantalla cambia al pisar el teclado.
	if not _teclado_pisado:
		_dibujar_serie(c)
	if _teclado_pisado:
		c.draw_rect(PANTALLA_MONITOR, Color("dfe8f2"))
		for fila in 3:
			c.draw_string(ThemeDB.fallback_font, PANTALLA_MONITOR.position + Vector2(2, 9 + fila * 8), "jjjjjj", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("2f2f6f"))
	_dibujar_teclado(c)
	# Jirones del plástico del sofá (G4): tiras brillantes que giran y caen.
	for j: Array in _jirones:
		c.draw_set_transform(j[0], j[2] * tiempo)
		c.draw_rect(Rect2(-5, -2, 10, 4), Color(0.85, 0.93, 1.0, 0.85))
		c.draw_rect(Rect2(-5, -2, 10, 1), Color(1, 1, 1, 0.95))
		c.draw_set_transform(Vector2.ZERO)
	# Calcetines que vuelan del cajón.
	for v in _calcetines_volando:
		var t := fmod(v.z + tiempo * 1.2, 1.0)
		var punto := Vector2(v.x + (t - 0.5) * 80.0, v.y - sin(t * PI) * 90.0)
		ArteNivel.dibujar(c, "calcetin", punto.x, punto.y + 12)
	if _cajon_abierto:
		c.draw_rect(Rect2(CAJON.x - 8, CAJON.y - 8, 30, 10), Color("6e3a26"))
		c.draw_rect(Rect2(CAJON.x - 6, CAJON.y - 10, 26, 4), Color("e59aa2"))


## Pantalla del monitor de Valeria (crítica de Gemini: era un rectángulo azul plano). Su serie, en pixeles: noche
## azul en franjas, una lámpara, dos siluetas que se miran y un corazón que late; brillo que titila como una pantalla
## de verdad, un reflejo duro arriba a la izquierda y un poco de luz azul sobre el escritorio. El teclado (delante)
## tapa la mitad de abajo.
func _dibujar_serie(c: Node2D) -> void:
	var r := Rect2(PANTALLA_MONITOR.position + Vector2(0, 1), Vector2(PANTALLA_MONITOR.size.x - 1, 17))
	var bandas := [Color("1d2547"), Color("26355c"), Color("30486e"), Color("3a5a7c")]
	for i in bandas.size():
		c.draw_rect(Rect2(r.position.x, r.position.y + i * 4.0, r.size.x, 4.0 if i < bandas.size() - 1 else r.size.y - i * 4.0), bandas[i])
	# Lámpara de la escena y su halo.
	c.draw_rect(Rect2(r.position + Vector2(26, 3), Vector2(4, 4)), Color(1.0, 0.85, 0.45, 0.35))
	c.draw_rect(Rect2(r.position + Vector2(27, 4), Vector2(2, 2)), Color("ffe08a"))
	# Dos siluetas que se miran (cabeza, cuello y hombros), oscuras contra la noche.
	var sombra := Color("0d1020")
	for persona: Vector3 in [Vector3(7, 6, 1), Vector3(17, 5, -1)]:
		var p := r.position + Vector2(persona.x, persona.y)
		c.draw_rect(Rect2(p, Vector2(4, 4)), sombra)
		c.draw_rect(Rect2(p + Vector2(1 + persona.z, 1), Vector2(1, 1)), sombra)
		c.draw_rect(Rect2(p + Vector2(1, 4), Vector2(2, 1)), sombra)
		c.draw_rect(Rect2(p + Vector2(-1, 5), Vector2(6, 8)), sombra)
	# Corazón entre las dos (late con la escena).
	if int(tiempo * 2.0) % 2 == 0:
		var h := r.position + Vector2(13, 3)
		c.draw_rect(Rect2(h, Vector2(1, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(2, 0), Vector2(1, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(0, 1), Vector2(3, 1)), Color("ff7a9a"))
		c.draw_rect(Rect2(h + Vector2(1, 2), Vector2(1, 1)), Color("ff7a9a"))
	# Brillo de pantalla que titila y reflejo duro arriba a la izquierda.
	c.draw_rect(r, Color(0.7, 0.9, 1.0, 0.06 + 0.04 * sin(tiempo * 7.0)))
	c.draw_rect(Rect2(r.position + Vector2(1, 1), Vector2(6, 1)), Color(1, 1, 1, 0.45))
	c.draw_rect(Rect2(r.position + Vector2(1, 2), Vector2(2, 1)), Color(1, 1, 1, 0.3))
	# Luz azul de la pantalla sobre el escritorio, delante del monitor.
	c.draw_rect(Rect2(r.position.x - 6.0, SUELO - 98.0, r.size.x + 12.0, 2.0), Color(0.6, 0.85, 1.0, 0.12))


## Teclado de Valeria (G7): en perspectiva, del tamaño declarado en TECLADO (52 × 24), con cuatro filas de teclas.
func _dibujar_teclado(c: Node2D) -> void:
	var r := TECLADO
	var oscuro := Color("241c1a")
	var tapa := PackedVector2Array([r.position + Vector2(6, 0), r.position + Vector2(r.size.x - 6, 0), r.position + Vector2(r.size.x, r.size.y - 6), r.position + Vector2(0, r.size.y - 6)])
	c.draw_colored_polygon(tapa, Color("3a3d44"))
	c.draw_rect(Rect2(r.position + Vector2(0, r.size.y - 6), Vector2(r.size.x, 6)), Color("26282d"))
	c.draw_polyline(tapa + PackedVector2Array([tapa[0]]), oscuro, 1.0)
	var tecla := Color("c9ced6") if not _teclado_pisado else Color("8f96a3")
	for fila in 4:
		var y := r.position.y + 3.0 + fila * 4.5
		var margen := 7.0 - fila * 1.3
		var x := r.position.x + margen
		while x < r.end.x - margen - 4.0:
			c.draw_rect(Rect2(x, y, 4, 3), tecla)
			c.draw_rect(Rect2(x, y + 3, 4, 1), Color(0, 0, 0, 0.4))
			x += 5.5
	# Barra espaciadora.
	c.draw_rect(Rect2(r.position.x + 16, r.end.y - 8, 20, 2), tecla)


## Ropa doblada de la cama (arriba-extra, 52 × 48): limpia y, después de que Felipe se acicala encima, con pelos.
## El arte está en 3/4 y termina en una punta (la esquina de adelante): apoyada en el borde del colchón se veía
## flotando (el creador, 2026-10-19). Se hunde ROPA_HUNDIDA px, así la fila ancha de abajo de la pila queda sobre el
## edredón y la punta, delante.


func _dibujar_ropa(c: Interactivo) -> void:
	ArteNivel.dibujar(c, "ropa_pelos" if _ropa_firmada else "ropa_limpia", 0.0, ROPA_HUNDIDA)


## Fachada bajo el balcón y el toldo rayado de la panadería donde aterriza Felipe al saltar (G1). Simplificada al
## estilo del resto (M5): ladrillo terracota con hiladas suaves, ventanas con marco, alféizar y cortina, contorno oscuro
## como las piezas de Gemini, y el letrero PANADERÍA en el faldón del toldo (Felipe aterriza arriba: no lo tapa).
func _dibujar_fachada(c: Node2D) -> void:
	var balcon := rect_de("balcon")
	# El tramo de fachada del edificio de Valeria alrededor de la puerta-ventana (B-1, tanda 3E).
	var fachada := ArteNivel.textura("fachada_balcon")
	if fachada:
		ArteNivel.dibujar(c, "fachada_balcon", FACHADA_BALCON.x + fachada.get_width() / 2.0, FACHADA_BALCON.y)
	var abajo := ALTO + CAIDA_BALCON + 40.0
	var oscuro := Color("241c1a")
	var muro := Rect2(balcon.position.x, ALTO, balcon.size.x, abajo - ALTO)
	c.draw_rect(muro, Color("a65a45"))
	# Hiladas de ladrillo, apenas marcadas (no compiten con Felipe, R14).
	var y := ALTO + 16.0
	var fila := 0
	while y < abajo:
		c.draw_rect(Rect2(muro.position.x, y, muro.size.x, 1), Color("94503d"))
		var x := muro.position.x + (0.0 if fila % 2 == 0 else 14.0)
		while x < muro.end.x:
			c.draw_rect(Rect2(x, y - 9, 1, 9), Color("94503d"))
			x += 28.0
		y += 10.0
		fila += 1
	# Losa del balcón (canto grueso) y su sombra.
	c.draw_rect(Rect2(balcon.position.x, ALTO, balcon.size.x, 12), Color("7d3f3f"))
	c.draw_rect(Rect2(balcon.position.x, ALTO, balcon.size.x, 2), Color("9a5b4c"))
	c.draw_rect(Rect2(balcon.position.x, ALTO + 12, balcon.size.x, 6), Color(0, 0, 0, 0.25))
	# Ventanas del piso de abajo: marco de madera, vidrio con luz, cortinas y alféizar.
	for x0: float in [7286.0, 7426.0]:
		var ventana := Rect2(x0, ALTO + 56, 70, 84)
		c.draw_rect(ventana.grow(6), oscuro)
		c.draw_rect(ventana.grow(5), Color("6e3a26"))
		c.draw_rect(ventana.grow(2), Color("8a5232"))
		c.draw_rect(ventana, Color("ffcf7a"))
		c.draw_rect(Rect2(ventana.position, Vector2(ventana.size.x, 20)), Color("ffe3a3"))
		c.draw_rect(Rect2(ventana.position.x, ventana.position.y, 14, ventana.size.y), Color("c0603f"))
		c.draw_rect(Rect2(ventana.end.x - 14, ventana.position.y, 14, ventana.size.y), Color("c0603f"))
		c.draw_rect(Rect2(ventana.position.x + 33, ventana.position.y, 4, ventana.size.y), Color("6e3a26"))
		c.draw_rect(Rect2(ventana.position.x, ventana.position.y + 40, ventana.size.x, 3), Color("6e3a26"))
		var alfeizar := Rect2(ventana.position.x - 10, ventana.end.y + 5, ventana.size.x + 20, 7)
		c.draw_rect(alfeizar.grow(1), oscuro)
		c.draw_rect(alfeizar, Color("c9b49a"))
		c.draw_rect(Rect2(alfeizar.position.x, alfeizar.end.y, alfeizar.size.x, 3), Color(0, 0, 0, 0.25))
	# Toldo de la panadería: rayas verdes y crema, faldón con el letrero y borde ondulado.
	var t := TOLDO
	var alto_rayas := 16.0
	var faldon := Rect2(t.position.x, t.position.y + alto_rayas, t.size.x, 16)
	for i in int(t.size.x / 20.0):
		var x := t.position.x + i * 20.0
		c.draw_rect(Rect2(x, t.position.y, 20, alto_rayas), Color("4f8a5b") if i % 2 == 0 else Color("efe4d0"))
	c.draw_rect(faldon, Color("efe4d0"))
	for i in int(t.size.x / 20.0):
		var x := t.position.x + i * 20.0
		c.draw_circle(Vector2(x + 10, faldon.end.y), 9.0, Color("4f8a5b") if i % 2 == 0 else Color("efe4d0"))
	c.draw_rect(Rect2(t.position.x, t.position.y, t.size.x, 3), Color("2e5a38"))
	c.draw_rect(Rect2(faldon.position.x, faldon.position.y, faldon.size.x, 1), oscuro)
	var letrero := "PANADERÍA"
	var fuente := ThemeDB.fallback_font
	var ancho := fuente.get_string_size(letrero, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	c.draw_string(fuente, Vector2(t.get_center().x - ancho / 2.0, faldon.end.y - 3), letrero, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("2e5a38"))
	c.draw_rect(Rect2(t.position.x, faldon.end.y + 10, t.size.x, 2), Color(0, 0, 0, 0.25))


## El nido de Su Majestad (la cesta de la sala): se llena a la vista con los calcetines del día.
func _dibujar_nido() -> void:
	var nombre := "cesta_vacia"
	if calcetines >= 3:
		nombre = "cesta_llena"
	elif calcetines >= 1:
		nombre = "cesta_3"
	ArteNivel.dibujar(_cesta, nombre, 70.0, SUELO)


## Lo que cuenta quién vive aquí y lo que se mueve en cada cuarto (G9, G10 y las filas de cada cuarto del plan de
## ambientes). Todo es decorado sin colisión y de menos de 24 px; nada entra en un rectángulo sagrado.
const PELO_CREMA := Color("e8dccb")
const PELO_GRIS := Color("7a7470")
const POLVO := Color(0.55, 0.49, 0.43, 0.75)


func _dibujar_ambiente() -> void:
	var c := _ambiente
	# Recibidor: halo de la lámpara junto a la caja de arena, que parpadea una vez cada 9 s.
	var parpadeo := fmod(tiempo, 9.0) < 0.12
	c.draw_circle(Vector2(1959, SUELO - 140), 30.0, Color(1.0, 0.9, 0.5, 0.05 if parpadeo else 0.15))
	# Pelos de Felipe (crema y gris, nunca blanco): sofá, edredón, cojín y alfombras.
	var asiento := pieza("Asiento del sofá")
	var y_sofa := asiento.position.y if asiento else SUELO - 49.0
	for x: float in [298.0, 318.0, 352.0, 384.0, 428.0, 440.0]:
		_pelo(c, Vector2(x, y_sofa), int(x) % 3)
	for x: float in [5660.0, 5690.0, 5732.0, 5818.0, 5834.0]:
		_pelo(c, Vector2(x, SUELO - 65.0), int(x) % 3)
	for x: float in [4994.0, 5008.0, 5032.0, 5044.0]:
		_pelo(c, Vector2(x, SUELO - 20.0), int(x) % 3)
	for alfombra: Array in ALFOMBRAS:
		var t := ArteNivel.textura(alfombra[0])
		if t:
			for k in 3:
				_pelo(c, Vector2(alfombra[1] + t.get_width() * (0.2 + k * 0.3), SUELO + 4.0), k)
	# Arañazos viejos a la altura de Felipe (marcas sueltas de la tanda 3C, al 70 %).
	var marca := Color(1, 1, 1, 0.7)
	var entornada: Puerta = puertas.get(PUERTA_DORMITORIO)
	if entornada:
		ArteNivel.dibujar(c, "aranazo_1", entornada.position.x - 63.0, SUELO - 22.0, false, marca)
	ArteNivel.dibujar(c, "aranazo_2", 6026.0, SUELO - 22.0, false, marca)
	ArteNivel.dibujar(c, "aranazo_3", 754.0, SUELO - 20.0, false, marca)
	# Polvo en lo alto: ropero, refrigerador, librero y alacenas, y una pelusa sobre el refrigerador.
	for linea: Vector3 in [Vector3(6018, 6118, SUELO - 186), Vector3(3684, 3748, SUELO - 217), Vector3(2164, 2264, SUELO - 219), Vector3(3463, 3576, SUELO - 249)]:
		c.draw_rect(Rect2(linea.x, linea.z, linea.y - linea.x, 1), POLVO)
	_pelo(c, Vector2(3741, SUELO - 217), 2)
	# Sala (S-4): enchufe en el zócalo y el cable del cargador del portátil, con su luz que late.
	_enchufe(c, Vector2(140, SUELO - 13))
	_cable(c, Vector2(143, SUELO - 7), Vector2(208, SUELO - 2), 5.0)
	c.draw_rect(Rect2(210, SUELO - 4, 2, 1), Color(0.4, 1.0, 0.5, 0.35 + 0.35 * sin(tiempo * 3.0)))
	# Cocina: croquetas regadas junto al tazón (C-7), segundero del reloj (C-8) y la gota de la llave (C-5).
	for croqueta: Vector2 in [Vector2(3031, SUELO - 2), Vector2(3036, SUELO - 1), Vector2(3039, SUELO - 3), Vector2(2990, SUELO - 1), Vector2(2996, SUELO - 2)]:
		c.draw_rect(Rect2(croqueta, Vector2(2, 2)), Color("9a6a3a"))
		c.draw_rect(Rect2(croqueta, Vector2(1, 1)), Color("c08a52"))
	var angulo := floorf(tiempo) / 60.0 * TAU - PI / 2.0
	var centro := Vector2(3095, DINTEL + 22.0)
	c.draw_line(centro, centro + Vector2(cos(angulo), sin(angulo)) * 8.0, Color("c0392b"), 1.0)
	if ArteNivel.textura("llave_agua"):
		var caida := fmod(tiempo, 3.0)
		var gota := Vector2(3466, SUELO - 128.0)
		if caida < 0.8:
			c.draw_rect(Rect2(gota.x, gota.y + 1.0, 1, 2), Color(0.6, 0.85, 1.0, caida / 0.8))
		elif caida < 1.0:
			var t := (caida - 0.8) / 0.2
			c.draw_rect(Rect2(gota.x, gota.y + 1.0 + t * t * 18.0, 1, 2), Color(0.6, 0.85, 1.0))
	# Estudio (E-3, E-4): enchufe y cable de la base de carga, regleta bajo el escritorio y post-its en el monitor.
	_enchufe(c, Vector2(6880, SUELO - 13))
	_cable(c, Vector2(6868, SUELO - 4), Vector2(6883, SUELO - 7), 3.0)
	c.draw_rect(Rect2(6716, SUELO - 6, 26, 6), Color("2b2622"))
	c.draw_rect(Rect2(6717, SUELO - 5, 24, 3), Color("e6e0d4"))
	for k in 3:
		c.draw_rect(Rect2(6720 + k * 7, SUELO - 4, 2, 1), Color("2b2622"))
		_cable(c, Vector2(6721 + k * 7, SUELO - 6), Vector2(6700 + k * 22, SUELO - 98), 6.0 + k * 2.0)
	for nota: Array in [[Vector2(6786, SUELO - 143), Color("ffd95a")], [Vector2(6787, SUELO - 137), Color("f29ab0")], [Vector2(6744, SUELO - 144), Color("ffd95a")]]:
		c.draw_rect(Rect2(nota[0], Vector2(4, 4)), nota[1])
		c.draw_rect(Rect2(nota[0] + Vector2(0, 3), Vector2(4, 1)), (nota[1] as Color).darkened(0.25))


## Mechón de pelo de 3 a 5 px en los dos tonos de Felipe.
func _pelo(c: CanvasItem, p: Vector2, forma: int) -> void:
	var y := p.y - 1.0
	match forma:
		0:
			c.draw_rect(Rect2(p.x, y, 3, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 1, y - 1, 2, 1), PELO_GRIS)
		1:
			c.draw_rect(Rect2(p.x, y, 4, 1), PELO_GRIS)
			c.draw_rect(Rect2(p.x + 2, y - 1, 2, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 4, y - 2, 1, 1), PELO_CREMA)
		_:
			c.draw_rect(Rect2(p.x, y, 2, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 2, y - 1, 3, 1), PELO_CREMA)
			c.draw_rect(Rect2(p.x + 1, y - 1, 1, 1), PELO_GRIS)


## Enchufe de 6 × 8 px en el zócalo.
func _enchufe(c: CanvasItem, p: Vector2) -> void:
	c.draw_rect(Rect2(p, Vector2(6, 8)), Color("3a2a22"))
	c.draw_rect(Rect2(p + Vector2(1, 1), Vector2(4, 6)), Color("e6e0d4"))
	c.draw_rect(Rect2(p + Vector2(2, 2), Vector2(1, 1)), Color("3a2a22"))
	c.draw_rect(Rect2(p + Vector2(2, 5), Vector2(1, 1)), Color("3a2a22"))


## Cable de 1 px en dos tonos (oscuro con un brillo cada tanto) que cuelga entre dos puntos.
func _cable(c: CanvasItem, desde: Vector2, hasta: Vector2, caida: float) -> void:
	var puntos := PackedVector2Array()
	for i in 9:
		var t := i / 8.0
		puntos.append(desde.lerp(hasta, t) + Vector2(0, sin(t * PI) * caida))
	c.draw_polyline(puntos, Color("2b2622"), 1.0)
	for i in range(1, 8, 3):
		c.draw_rect(Rect2(puntos[i].round(), Vector2(1, 1)), Color("6a5e56"))
