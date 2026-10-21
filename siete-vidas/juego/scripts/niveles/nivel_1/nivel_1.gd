class_name Nivel1
extends RefCounted
## Datos del primer nivel: "La Gran Fuga" v4, la casa de Valeria como tutorial (documento vigente:
## siete-vidas/diseno/nivel-01-gran-fuga.md). Solo números y listas: dónde está cada cuarto, mueble, puerta, objeto,
## personaje y frase. La lógica no está aquí: el Nivel (constructor genérico) arma lo que dicen estos datos y el
## GuionNivel1 pone los eventos propios del nivel; el arte lo dibujan ArteNivel1 y DecoradoNivel1.
## Siete cuartos unidos por puertas. Abajo manda Valeria; arriba, A.S.P.I. Al pie de la escalera de fondo están las cajas
## de la mudanza (se pasa trepando el librero; desde el segundo peldaño se tira la caja de arriba: el atajo de vuelta).
## Cada cuarto tiene una travesura de la Agenda de Su Majestad con su reacción (R18). Nada se enseña con carteles: el
## Indicador y las primeras frases de Felipe (LECCIONES). La pelea con A.S.P.I. es en el estudio; el balcón es el alivio.
## Cada colisión calza con el borde visible de su arte (±2 px, lo mide prueba_reglas_nivel.gd).
## Habilidades: el nivel se juega sin doble salto, Zoomies ni trepar (decisión del creador, 2026-10-19).

## Escala del mundo: 1,21 px por cm (Felipe mide 67 px; Valeria = 3 Felipes). Casa antigua del Barrio Viejo: cuartos
## de 3,5 m (424 px) de alto, todos con el piso a la misma altura.
const TECHO := 24.0
const SUELO := 448.0
## Piso con profundidad (pedido del creador, 2026-10-19): el piso es un plano visto un poco desde arriba. La pared
## (zócalo, puertas, ventanas, cuadros) termina FONDO_PISO px ARRIBA de la línea de apoyo (SUELO): entre la pared y
## SUELO se ve una banda de piso, y bajo SUELO otra hasta el borde de la pantalla (ALTO). Así los pies de Felipe,
## Valeria, A.S.P.I. y las patas de los muebles quedan DENTRO del piso, delante de la pared. Solo se movió el dibujo:
## las colisiones siguen en SUELO. Banda de 14 px (Gemini, pasada única 2026-10-19: de 12 a 16 px de piso detrás de
## los pies).
const FONDO_PISO := Nivel.FONDO_PISO
## Unión pared-piso (borde de abajo del zócalo): todo lo que cuelga de la pared se mide desde aquí.
const PARED_BASE := SUELO - FONDO_PISO
## Dintel de las puertas (2,05 m): la línea de los cuadros (G8).
const DINTEL := PARED_BASE - 248.0
## Mesita de la sala (S-2, tanda 3E): tablero a 58 px (48 cm), de la columna 6 a la 76 de su arte.
const MESITA_X := 162.0
## Superficies (nombres de Nivel1.PIEZAS) que quedan DELANTE de los humanos: Felipe parado ahí (el cojín del asiento
## del sofá, junto a Valeria o en su regazo) se dibuja delante de ella (Capas.JUEGO_DELANTE); en el piso pasa detrás con
## su silueta (plan de estabilización 2026-10-20).
const DELANTE_DE_HUMANOS := ["Asiento del sofá"]
## Estados de Felipe en los que va delante de los humanos aunque esté en el piso: frotarse contra las piernas de
## Valeria («Encantar») es cariño hacia el jugador y tiene que leerse claro.
const ESTADOS_DELANTE_DE_HUMANOS := [Felipe.Estado.RONRONEANDO]
## Actividades de Valeria en las que Felipe va delante de ella esté donde esté (decisión del creador, 2026-10-20):
## sentada en el sofá queda hundida en el mueble, así que el gato se ve sobre ella, en el piso o en el cojín.
const ACTIVIDADES_HUMANO_DETRAS := [Valeria.Actividad.SENTADA]
## Luz de las lámparas encendidas (plan de estabilización 2026-10-20, decisión 4; lección 26: nada de halos redondos).
## Cada una: [cuarto, arte, pantalla (rectángulo en la textura del arte), y del mundo donde cae la luz (tablero o piso),
## ancho de la luz al llegar ahí, alto del cono de ARRIBA, ancho arriba, cuánto de la opacidad de abajo lleva el de
## arriba]. La pantalla es abierta arriba y abajo (decisión del creador, 2026-10-21): tira luz al piso y, más corta y
## tenue, a la pared o el techo. LuzCuarto dibuja con estos datos la pantalla encendida (más clara, con contorno claro),
## los dos conos en 3 escalones de bordes duros y la franja iluminada en lo que tocan.
const LAMPARAS := [
	["sala", "mesita_sala", Rect2(5, 0, 35, 23), SUELO - 57.0, 66.0, 46.0, 52.0, 0.6],
	["recibidor", "lampara", Rect2(0, 16, 34, 34), SUELO, 120.0, 62.0, 70.0, 0.6],
]
## Ambiente del atardecer por cuarto con lámpara (CanvasModulate, oscurecimiento suave para que la luz resalte; R14: lo
## jugable se sigue leyendo). Los demás cuartos van en blanco.
const AMBIENTE_CUARTOS := {"sala": Color(0.84, 0.75, 0.67), "recibidor": Color(0.86, 0.8, 0.74)}
## Luz cálida de las lámparas, transparencia de cada escalón del cono (6 a 10 %) y anchos relativos de los escalones.
const COLOR_LAMPARA := Color(1.0, 0.82, 0.5)
const ALFA_CONO := [0.06, 0.07, 0.08]
const ESCALONES_CONO := [1.0, 0.7, 0.42]
const ALTO := SUELO + 30.0
const ANCHO := 8260.0
## Medio ancho del rectángulo sagrado de cada puerta: medio vano (52 px) más 40 px libres a cada lado (B3).
const MEDIO_RECT_PUERTA := 92.0
## Habitaciones en orden de ruta: [rectángulo, nombre, estilo de pared]. Muros de 160 px entre una y otra.
## Ninguna es más angosta que la pantalla (640 px).
const HABITACIONES := [
	[Rect2(0, TECHO, 1280, SUELO - TECHO), "sala", "tapiz"],
	[Rect2(1440, TECHO, 1200, SUELO - TECHO), "recibidor", "tapiz_verde"],
	[Rect2(2800, TECHO, 1340, SUELO - TECHO), "cocina", "azulejo"],
	[Rect2(4380, TECHO, 1240, SUELO - TECHO), "pasillo", "tapiz_azul"],
	[Rect2(5780, TECHO, 720, SUELO - TECHO), "dormitorio", "rosa"],
	[Rect2(6820, TECHO, 640, SUELO - TECHO), "estudio", "tapiz_mostaza"],
	[Rect2(7620, TECHO, 640, SUELO - TECHO), "balcon", "exterior"],
]
## Orden de la ruta (las reglas de diseño lo usan para comprobar que se enseña antes de pedir).
const RUTA := ["sala", "recibidor", "cocina", "pasillo", "dormitorio", "estudio", "balcon"]
## Ventanas (las cinco de la casa con la misma medida, pedido del creador 2026-10-19): alféizar a 90 cm del piso
## (ALFEIZAR, 109 px), vidrio de unos 150 × 120 px y arriba a 1,90 m: nada bajo la barra del HUD ni pegado al techo.
## La de la sala y la del pasillo son arte con su propia vista; las de la cocina, el dormitorio y el estudio se
## recortan en la pared (se ve la ciudad) y llevan marco, alféizar y tela por código (FondoApartamento).
const ALFEIZAR := PARED_BASE - 109.0
## La ventana del pasillo es la excepción: su alféizar es una repisa honda que se pisa desde la consola (colisión), así
## que queda en el plano de juego.
const ALFEIZAR_PASILLO := SUELO - 109.0
## La de la cocina va sobre el fregadero del mesón (cocina v2: el grifo queda al centro del vidrio).
const VENTANA_COCINA := Rect2(3682, ALFEIZAR - 120, 150, 120)
## La del dormitorio va sobre la cama, con la cortina de Gemini a los lados (dos paños desde una barra, hasta el piso).
const VENTANA_DORMITORIO := Rect2(6049, ALFEIZAR - 120, 150, 120)
## La del estudio va sobre el escritorio (el monitor queda delante del vidrio).
const VENTANA_ESTUDIO := Rect2(7035, ALFEIZAR - 120, 150, 120)
const VENTANAS := [VENTANA_COCINA, VENTANA_DORMITORIO, VENTANA_ESTUDIO]
## Cortina del dormitorio: cuánto tapa cada paño de la ventana y dónde termina la tela en el arte (45 px: remate de
## 8 px, tela de 34 y 3 px de barra). La barra queda CORTINA_SOBRE_VENTANA px sobre el marco; lo que sobra de tela
## abajo queda tras el piso (no se dibuja).
const CORTINA_ADENTRO := 9.0
const CORTINA_FIN_TELA := 42.0
const CORTINA_SOBRE_VENTANA := 18.0
## Vidrio de la ventana del pasillo (en el mundo): el hueco de 150 × 120 del marco de la casa (`ventana_casa`, G2),
## con la vista del toldo y la paloma detrás (`vista_pasillo`, B2). El alféizar del marco queda a 90 cm.
const VIDRIO_PASILLO := Rect2(4639, ALFEIZAR_PASILLO - 132, 150, 120)
## Puertas: [nombre, posición (al pie, al centro), puerta a la que lleva]. Van de a pares.
const PUERTAS := [
	["sala>recibidor", Vector2(1188, SUELO), "recibidor<sala"],
	["recibidor<sala", Vector2(1532, SUELO), "sala>recibidor"],
	["recibidor>cocina", Vector2(2070, SUELO), "cocina<recibidor"],  # cerrada: Valeria adentro
	["cocina<recibidor", Vector2(2892, SUELO), "recibidor>cocina"],
	["recibidor>pasillo", Vector2(2362, SUELO), "pasillo<recibidor"],  # pie de la escalera de fondo, adentro de las cajas
	["pasillo<recibidor", Vector2(4472, SUELO), "recibidor>pasillo"],  # vano arriba de la escalera
	["pasillo>dormitorio", Vector2(4916, SUELO), "dormitorio<pasillo"],  # entornada: se araña
	["dormitorio<pasillo", Vector2(5872, SUELO), "pasillo>dormitorio"],
	["pasillo>estudio", Vector2(5528, SUELO), "estudio<pasillo"],
	["estudio<pasillo", Vector2(6912, SUELO), "pasillo>estudio"],
	["estudio>balcon", Vector2(7368, SUELO), "balcon<estudio"],  # cerrada hasta desenchufar a A.S.P.I.
	["balcon<estudio", Vector2(7712, SUELO), "estudio>balcon"],
]
## Puerta del baño (2.4.1 del plan de ambientes): cerrada, con el marco de las demás, en la capa de puertas. No es
## habitación ni va en PUERTAS (R7): es un lugar insinuado para la maña futura «Abrir puertas».
const BANO := Vector2(5120, SUELO)
## A cuánto dice su frase al acercarse, a cuánto se oye el goteo y a cuánto tiene que quedarse quieto para la manija.
const BANO_FRASE := 90.0
const BANO_GOTEO := 300.0
const BANO_MANIJA := 60.0
const PUERTA_BALCON := "estudio>balcon"
const PUERTA_COCINA := "recibidor>cocina"
const PUERTA_DORMITORIO := "pasillo>dormitorio"
## La escalera de fondo: al pie se "asciende" como por una puerta, escalón por escalón (Felipe.subir_escalera).
const PUERTA_ESCALERA := "recibidor>pasillo"
const ESCALERA_PIE := Vector2(2362, SUELO)
## Pies de Felipe en cada uno de los 7 escalones (arte escalera_peldanos espejado, de 25 px de huella y ~21 de alto).
const PELDANOS := [
	Vector2(2352, SUELO - 23), Vector2(2360, SUELO - 45), Vector2(2386, SUELO - 67), Vector2(2410, SUELO - 88),
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
	["perchero", Vector2(1646, PARED_BASE - 140.0), false, "pared"],  # R-1: sobre el zapatero, sin tapar el paso agachado
	["zapatero", Vector2(1626, SUELO), false, "mueble"],
	["zapatillas", Vector2(1794, SUELO + 8.0), false, "mueble"],  # adelantadas en el piso  # R-2: tiradas entre el zapatero y la caja de arena
	["marco_viral", Vector2(1866, DINTEL + 59.0), false, "pared"],  # R-3: el video viral (por eso le cuidan la escalera)
	["caja_arena", Vector2(1832, SUELO), false, "mueble"],
	["lampara", Vector2(1942, SUELO), false, "mueble"],
	["librero_v2", Vector2(2162, SUELO), false, "mueble"],
	["escoba", Vector2(2590, SUELO), false, "mueble"],  # tanda 3F: apoyada en el armario bajo la escalera, bajo el descanso
	["escalera_peldanos", Vector2(2322, SUELO), true, "escalera"],
	["vano", Vector2(2497, SUELO - 150), false, "escalera"],  # hueco cuadrado con el marco de las puertas (no un arco)
	["reloj", Vector2(3210, DINTEL + 43.0), false, "pared"],  # 41 × 43, con segundero (C-8)
	# Isla de la entrada (segunda pasada, 2026-10-20): repisa de pared a 1,24 m del piso (150 px sobre la pared) con la
	# maceta de Valeria y la reserva de croquetas al doble, en alto y lejos de Felipe; el reloj arriba a la derecha.
	["repisa_cocina", Vector2(3060, REPISA_COCINA_Y + 35.0), false, "pared"],
	["maceta", Vector2(3074, REPISA_COCINA_Y + 2.0), false, "pared"],  # apoyadas en la tabla (2 px hundidas)
	["croquetas_reserva", Vector2(3128, REPISA_COCINA_Y + 2.0), false, "pared"],
	["lata", Vector2(3044, SUELO + 6.0), false, "mueble"],  # adelantada en el piso  # C-7: la lata de atún abierta, al otro lado del tazón
	# Cocina v2 (tanda 3F, 2026-10-19; composición de Gemini a escala de gato): silla → estufa con olla → mesón largo
	# con el fregadero embutido bajo la ventana → microondas con el pollo → refrigerador. Alacenas sobre la estufa.
	["silla_v2", Vector2(3400, SUELO), false, "mueble"],
	["alacenas", Vector2(ALACENAS_X, SUELO - 180.0), false, "pared"],  # 70 cm, a 1,49 m del piso
	["estufa", Vector2(ESTUFA_X, SUELO), false, "mueble"],
	["meson", Vector2(MESON_X, SUELO), false, "mueble"],
	["microondas", Vector2(MICROONDAS_X, SUELO - 109), false, "mueble"],  # 1 px hundido en la cubierta
	["refrigerador", Vector2(REFRIGERADOR_X, SUELO), false, "mueble"],
	["polaroid_1", Vector2(REFRIGERADOR_X + 16.0, SUELO - 172.0), false, "mueble"],  # C-6: fotos de Felipe entre los imanes
	["polaroid_2", Vector2(REFRIGERADOR_X + 60.0, SUELO - 150.0), false, "mueble"],
	["polaroid_3", Vector2(REFRIGERADOR_X + 14.0, SUELO - 106.0), false, "mueble"],
	["baul", Vector2(4566, SUELO), false, "mueble"],
	["aparador", Vector2(4636, SUELO), false, "mueble"],
	["retrato_familiar", Vector2(5280, DINTEL + 80.0), false, "pared"],  # P-4: el trono (cojín) con su retrato
	["ventana_casa", Vector2(4607, ALFEIZAR_PASILLO + 15.0), false, "pared"],  # el marco de la casa (hueco = VIDRIO_PASILLO); alféizar 15 px sobre su base; termina antes del rectángulo de la puerta del dormitorio
	["cojin", Vector2(5364, SUELO), false, "mueble"],
	["paisaje", Vector2(6323, SUELO - 145 - FONDO_PISO + 6.0), false, "pared"],  # D-1: apoyado contra la pared, al fondo de la repisa
	["banquito", Vector2(5966, SUELO), false, "mueble"],
	["libro", Vector2(5970, SUELO - 46.0), false, "mueble"],  # D-3: libro a medio leer, en medio del asiento del banquito
	["cama", Vector2(6024, SUELO), false, "mueble"],
	["comoda", Vector2(6230, SUELO), false, "mueble"],
	["ropero", Vector2(6396, SUELO), false, "mueble"],
	["cesta_vacia", Vector2(6327, SUELO), false, "mueble"],
	["silla_v2", Vector2(7004, SUELO), false, "mueble"],
	["escritorio", Vector2(7068, SUELO), false, "mueble"],
	["monitor", Vector2(7126, SUELO - 89), false, "mueble"],  # en medio de la cubierta (16 px vistos desde arriba), con su sombra
	["base_carga", Vector2(7180, SUELO), false, "mueble"],
	["corcho", Vector2(7211, PARED_BASE - 202.0), false, "pared"],  # E-2: el tablero de contenido de Valeria (entre el paño y la puerta)
	["regadera", Vector2(7814, SUELO + 8.0), false, "mueble"],  # B-3: isla de jardinería
	["saco_tierra", Vector2(7846, SUELO + 4.0), false, "mueble"],
	["maceta_rota", Vector2(7874, SUELO + 11.0), false, "mueble"],
	["maceta_grande", Vector2(7910, SUELO), false, "mueble"],
	["baranda", Vector2(7980, SUELO), false, "mueble"],
]
## Alfombras (tanda 3E): [imagen, x izquierda], en la franja del piso (después del piso y antes de las sombras).
const ALFOMBRAS := [["alfombra_sala", 232.0], ["alfombra_pasillo", 4750.0], ["alfombra_dormitorio", 5978.0]]
## Fachada del edificio alrededor de la puerta del balcón (B-1): el hueco (x 89 a 221 del arte) queda detrás de la
## puerta-ventana.
const FACHADA_BALCON := Vector2(7557, PARED_BASE)
## Borde de arriba de la tabla de la repisa de la entrada de la cocina (decorado de pared, sin colisión).
const REPISA_COCINA_Y := PARED_BASE - 150.0
## Cocina v2: x izquierda de cada mueble (el arte de Gemini, medido).
const ALACENAS_X := 3458.0
const ESTUFA_X := 3462.0
const MESON_X := 3556.0
const MICROONDAS_X := 3926.0
const REFRIGERADOR_X := 4046.0
## Boca del grifo de cuello de cisne del arte del mesón (columna 243, fila 44): de ahí cae la gota.
const GRIFO := Vector2(MESON_X + 243.0, SUELO - 112.0)
## Lo que va encima de un mueble y lleva sombra de contacto (1 px más ancha que su base) sobre la cubierta.
const APOYADOS := ["monitor", "libro", "microondas", "maceta", "croquetas_reserva"]
## Objetos de pared que proyectan sombra (G5): 2 px hacia abajo y 1 px a la derecha (la luz entra por el oeste).
## Fregadero de la cocina (pasada única, 2026-10-19: el de antes era una cajita pegada al borde, desproporcionada): cuba
## de acero embutida en la cubierta de azulejos (filas 3 a 19 del arte del mesón), de un tercio del mesón (62 de 188 px,
## unos 50 cm a escala de gato) y bien adentro del borde. El grifo es de código: cuello de cisne con el caño
## (GRIFO, la boca) sobre el centro de la cuba; el ratón del mesón patrulla por detrás de la cuba (sobre el borde de
## atrás de la cubierta), sin pisarla.
const SOMBRA_PARED := ["retrato", "marco_foto", "marco_huella", "perchero", "marco_viral", "reloj", "alacenas", "retrato_familiar", "paisaje", "corcho", "repisa_cocina"]
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
	# Segundo peldaño de la escalera de fondo: desde ahí («desde arriba») se tira la caja de arriba de la pila.
	[Rect2(2348, SUELO - 45, 24, 6), true, "Peldaño de las cajas", "arte", "escalera_peldanos"],
	# Cocina.
	[Rect2(3413, SUELO - 55, 40, 6), true, "Silla de la cocina", "arte", "silla_v2"],
	[Rect2(ESTUFA_X + 1, SUELO - 109, 86, 109), false, "Estufa", "arte", "estufa"],  # 90 cm, la olla atrás
	[Rect2(MESON_X + 2, SUELO - 109, 470, 109), false, "Mesón", "arte", "meson"],  # 90 cm, con el fregadero embutido
	[Rect2(MICROONDAS_X, SUELO - 163, 98, 54), false, "Microondas", "arte", "microondas"],  # escala de gato
	[Rect2(REFRIGERADOR_X + 8, SUELO - 216, 68, 216), false, "Refrigerador", "arte", "refrigerador"],  # 1,80 m
	# Pasillo de arriba.
	[Rect2(4566, SUELO - 47, 70, 47), true, "Baúl", "arte", "baul"],  # 40 cm (arriba-extra); se pasa por delante
	[Rect2(4638, SUELO - 97, 152, 50), false, "Consola", "arte", "aparador"],  # 80 cm, 47 px libres debajo
	[Rect2(4644, ALFEIZAR_PASILLO, 172, 6), true, "Alféizar", "arte", "ventana_casa"],  # 90 cm, sobre la consola
	# Dormitorio.
	[Rect2(5971, SUELO - 53, 42, 6), true, "Banquito", "arte", "banquito"],
	[Rect2(6024, SUELO - 65, 197, 65), false, "Cama", "arte", "cama"],  # colchón a 54 cm
	[Rect2(6235, SUELO - 96, 74, 96), false, "Cómoda", "arte", "comoda"],  # 80 cm
	[Rect2(6320, SUELO - 145, 70, 6), true, "Repisa", "repisa", ""],  # 1,20 m, repisa de pared entre la cómoda y el ropero
	[Rect2(6396, SUELO - 185, 104, 185), false, "Ropero", "arte", "ropero"],  # 1,53 m
	[Rect2(6315, SUELO - 274, 80, 6), true, "Repisa alta", "lugar_visto", ""],  # 2,26 m (pasada única: la caja de recuerdos quedaba cortada por el borde de arriba): se vuelve con Afilar Garras
	[Rect2(6334, SUELO - 35, 46, 6), true, "Cesta de ropa", "arte", "cesta_vacia"],  # para salir del hueco entre la cómoda y el ropero
	# Estudio de Valeria (la pelea).
	[Rect2(7017, SUELO - 55, 40, 6), true, "Silla del estudio", "arte", "silla_v2"],
	[Rect2(7085, SUELO - 98, 126, 6), true, "Escritorio", "arte", "escritorio"],  # 81 cm
	[Rect2(7216, SUELO - 151, 60, 6), true, "Repisa de las macetas", "repisa", ""],  # 1,25 m
	# Balcón.
	[Rect2(7915, SUELO - 32, 38, 6), true, "Maceta grande", "arte", "maceta_grande"],
	[Rect2(7981, SUELO - 89, 182, 6), true, "Baranda", "arte", "baranda"],  # 74 cm
]
## Sofá cuando ya no tiene plástico (sofa_aranado: más bajo): asiento y respaldo se mueven a su arte.
const SOFA_ARANADO := {"Asiento del sofá": SUELO - 45, "Respaldo del sofá": SUELO - 95}
## Cajas de la mudanza al pie de la escalera, sobre el primer escalón (CajasMudanza): sólidas, 1 m con la cesta (60 × 124: entran enteras entre el librero y el poste del pasamanos).
const CAJAS := Rect2(2262, SUELO - CajasMudanza.ALTO_PILA, CajasMudanza.ANCHO, CajasMudanza.ALTO_PILA)
## Pies de Felipe en el segundo peldaño, desde donde tira la caja de arriba.
const PELDANO_CAJAS := Vector2(2360, SUELO - 45)
## Enemigos (escenas/entidades/ con sus datos en datos/enemigos/): el ratón de cuerda y A.S.P.I. son el mismo Enemigo
## con otros números. Escenas y datos se cargan al armar el nivel con load(), nunca con preload() en una constante:
## precargar un .tres con script desde un script que se compila como dependencia de otro deja dos copias de su clase
## (DatosEnemigo) y fallan los tipos.
const ESCENA_RATON := "res://escenas/entidades/raton.tscn"
const ESCENA_ASPI := "res://escenas/entidades/aspi.tscn"
const RUTA_RATON := "res://datos/enemigos/raton.tres"
const RUTA_ASPI := "res://datos/enemigos/aspi.tres"
## Objetos y comida: datos/objetos/<tipo>.tres.
const DATOS_OBJETO := "res://datos/objetos/%s.tres"
## Juguetes que duelen al pisarlos: la sala v4 no tiene nada que haga daño.
const PELIGROS: Array[Rect2] = []
## Nada se trepa en el nivel 1 (trepar se gana con Afilar Garras): la cortina es un lugar visto.
const TREPABLES: Array[Rect2] = []
## Calcetines (R10): del sofá (travesura), arriba del refrigerador (exploración) y de la cómoda (cajón).
const CALCETINES := [Vector2(370, SUELO - 49), Vector2(REFRIGERADOR_X + 42.0, SUELO - 216), Vector2(6272, SUELO - 96)]
const CALCETIN_REFRIGERADOR := Vector2(REFRIGERADOR_X + 42.0, SUELO - 216)
const TOTAL_CALCETINES := 3
const CAJA_CARTON := Vector2(3360, SUELO)
## Ratones de cuerda: [posición, límite izquierdo, límite derecho]. Uno enseña el zarpazo y otro cuida el pollo.
## El del mesón patrulla entre el fregadero y el microondas (nunca pasa por delante del grifo ni del pollo, G5).
const RATONES := [
	[Vector2(3240, SUELO), 3200.0, 3290.0],
	[Vector2(3868, SUELO - 109), 3846.0, 3890.0],  # entre el fregadero y el microondas
]
const LASER := [Vector2(5280, SUELO), 5220.0, 5360.0]
## Objetos que se tiran con el botón de acción: [posición, tipo, cuánto se hunde el dibujo en la cara de arriba del
## mueble]. Apoyados en el medio de la cubierta (lección 29): la base baja de la línea de atrás al medio de la cara de
## arriba que se ve en el arte (mesa 5, consola 4, zapatero 2, escritorio 9: su cubierta se ve de 16 px) y lleva sombra de contacto; en la repisa
## dibujada (14 px de tabla vista desde arriba) sube 6 px desde el canto.
const TIRABLES := [
	[Vector2(905, SUELO - 91), "vaso", 5.0],
	[Vector2(1766, SUELO - 97), "llaves", 2.0],
	[Vector2(4758, SUELO - 97), "vaso", 4.0],  # bien adentro de la consola (Gemini: rozaba el borde)
	[Vector2(7095, SUELO - 98), "vaso", 9.0],
	[Vector2(7194, SUELO - 98), "taza", 9.0],  # taza de café de Valeria (reemplazó al rollo de papel higiénico)
	[Vector2(7230, SUELO - 151), "maceta", -6.0],
	[Vector2(7262, SUELO - 151), "maceta", -6.0],
]
## Comida: [posición, tipo]. El pollo es el almuerzo de Valeria (travesura "almuerzo"): espera sobre el microondas,
## fuera de la patrulla del ratón del mesón (G5).
## Hundido 3 px en la tapa del microondas (se ve su cara de arriba): apoyado, no en el borde de atrás.
const POLLO := Vector2(MICROONDAS_X + 49.0, SUELO - 160)
const COMIDA := [[Vector2(3010, SUELO), "tazon"], [POLLO, "pollo"]]
## A.S.P.I.: [base de carga, límite izquierdo, límite derecho] dentro del estudio.
const ASPI := [Vector2(7217, SUELO), 6870.0, 7410.0]
## Puntos de descanso: la caja de arena (recibidor) y el cojín (pasillo, a 2 px del rectángulo de la puerta del jefe).
const DESCANSOS := [Rect2(1852, SUELO - 60, 71, 70), Rect2(5364, SUELO - 40, 70, 50)]
## La meta: la baranda del balcón (sentarse y saltar da Caer de Pie), en el tramo sin maceta (M6).
const SALIDA := 8070.0
## Tramo de la baranda donde Felipe se sienta: a la derecha de la única maceta de la baranda (8002–8040), con aire
## para su cola. Fuera de este tramo no se sienta (plan de estabilización 2026-10-20: al lado de la maceta, no encima).
const ASIENTO_BARANDA := Vector2(8068, 8150)
## Lo que se ve al saltar del balcón (G1): la cámara baja CAIDA_BALCON px y Felipe aterriza en el toldo de la
## panadería de abajo (solo existe durante el salto final).
const CAIDA_BALCON := 230.0
const TOLDO := Rect2(7960, SUELO + 196, 300, 8)
## Sofá arañable (con el plástico nuevo): [centro de la base, ancho, alto]. Línea "sofa" de la agenda.
const SOFA_ARANABLE := [Vector2(360, SUELO), 240.0, 100.0]
const RASCADOR_X := 570.0
## Valeria: sentada en el sofá viendo la serie, y su lugar en la cocina (preparando café).
const VALERIA_SOFA := Vector2(410, SUELO - 49)
## En la cocina v2 prepara el café frente a la estufa: desde ahí ve el microondas (el pollo, «¡EN SU CARA!»).
const VALERIA_COCINA := Vector2(3500, SUELO)
## Cajón de los calcetines (en la cómoda), ropa doblada (en la cama) y teclado del escritorio. Lo interactuable
## dibujado por código declara su tamaño (lado menor ≥ 24 px, R8 y G7; prueba_reglas_nivel lo mide).
const CAJON := Vector2(6242, SUELO - 75)
const RECT_CAJON := Rect2(-14, -12, 60, 24)
## La ropa va en el medio de la cama, apoyada en el edredón (ROPA_HUNDIDA): ROPA es donde la alcanza Felipe parado
## en el colchón; el rectángulo cubre la pila tal como se dibuja.
const ROPA := Vector2(6148, SUELO - 65)
## La pila va en medio de la cama, hundida en el edredón (pedido del creador, 2026-10-19): su base queda 22 px bajo el
## borde de arriba del colchón, sobre el frente del edredón, con la tela que se hunde alrededor.
const ROPA_HUNDIDA := 22.0
const RECT_ROPA := Rect2(-26, ROPA_HUNDIDA - 48.0, 52, 48)
const TECLADO := Rect2(7120, SUELO - 113, 52, 24)
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
	[Rect2(0, TECHO, 200, SUELO - TECHO), "LECCION_SALTAR_LOS_MUEBLES_SON", 0],
	[Rect2(240, TECHO, 200, SUELO - TECHO), "LECCION_INTERACTUAR_ESE_SOFA_TIENE", 7],
	[Rect2(500, TECHO, 150, SUELO - TECHO), "LECCION_INTERACTUAR_UN_RASCADOR_NECESITO", 0],
	[Rect2(680, TECHO, 220, SUELO - TECHO), "LECCION_INTERACTUAR_ESE_VASO_ESTA", 4],
	[Rect2(1600, TECHO, 160, SUELO - TECHO), "LECCION_MANTEN_AGACHARSE_ES_ESTRATEGIA", 0],
	[Rect2(1820, TECHO, 130, SUELO - TECHO), "LECCION_MI_TRONO_AQUI_VUELVO", 0],
	[Rect2(1980, TECHO, 140, SUELO - TECHO), "LECCION_MAULLAR_SERVIDUMBRE_ABRAN", 6],
	[Rect2(2140, TECHO, 140, SUELO - TECHO), "LECCION_SALTAR_EL_LIBRERO_ES", 7],
	[Rect2(2300, TECHO, 120, SUELO - TECHO), "LECCION_INTERACTUAR_ESCALONES_MI_UNICA", 0],
	[Rect2(2950, TECHO, 130, SUELO - TECHO), "LECCION_INTERACTUAR_COMIDA_A_LA", 6],
	[Rect2(3110, TECHO, 140, SUELO - TECHO), "LECCION_ZARPAZO_UN_RATON_DE", 1],
	[Rect2(4840, TECHO, 140, SUELO - TECHO), "LECCION_INTERACTUAR_PUERTA_ENTORNADA_QUE", 7],
	[Rect2(5880, TECHO, 140, SUELO - TECHO), "LECCION_SALTAR_BANQUITO_CAMA_COMODA", 0],
	[Rect2(6180, TECHO, 150, SUELO - TECHO), "LECCION_INTERACTUAR_EL_CAJON_DE", 7],
	[Rect2(7860, TECHO, 140, SUELO - TECHO), "LECCION_SALTAR_LA_MACETA_LA", 0],
]
## Dónde pasa cada travesura de la Agenda y su reacción (R18).
const AGENDA_SITIOS := {
	"perdon": [Vector2(905, SUELO - 91), "«¡GRAVEDAD: 1 · VASO: 0!», Valeria: «¡PIPE!» y después «¿Quién es el bebito más gordito?»"],
	"sofa": [Vector2(370, SUELO - 49), "«¡PLÁSTICO: 0!» y Valeria: «¡Lo estoy pagando en 12 cuotas!»"],
	"popo": [Vector2(1888, SUELO - 45), "Censura irónica, Valeria con mascarilla: «La acabo de limpiar.» y se le cae una foto"],
	"almuerzo": [POLLO, "«¡EN SU CARA!» y Valeria: «Ese era mi almuerzo.»"],
	"laser": [Vector2(5280, SUELO), "El puntero se apaga de vergüenza"],
	"cajon": [CAJON, "Calcetines volando por todo el cuarto"],
	"teclado": [Vector2(7146, SUELO - 98), "La pantalla dice «jjjjjjjjjj» y los apuntes de Valeria vuelan"],
	"desenchufar": [Vector2(7217, SUELO), "«¡APAGADA!» y «Limpieza cancelada.»"],
}
## Lugares que se ven antes de poder alcanzarlos (R17): [qué, dónde, con qué maña se vuelve].
const LUGARES_VISTOS := [
	["Toldo del vecino con la paloma (afuera, tras el vidrio del pasillo)", PALOMA, "Caer de Pie"],
	["Caja de recuerdos de Valeria (repisa alta del dormitorio)", Rect2(6315, SUELO - 284, 80, 10), "Afilar Garras"],
]
## La paloma, parada sobre la tela del toldo del vecino, del otro lado del vidrio (dentro de VIDRIO_PASILLO; decisión
## del creador, 2026-10-21: reemplaza a la caja de pizza). Los pies en la fila 42 de la vista (arriba de la tela, bajo la
## barra), en el paño derecho: el parante del marco no la corta). 3 poses de Gemini (`paloma_quieta`, `paloma_picotea`, `paloma_inflada`) que anima ArteNivel1.
const PALOMA := Rect2(VIDRIO_PASILLO.position.x + 94, VIDRIO_PASILLO.position.y + 42 - 31, 32, 31)
## La paloma: cada cuánto picotea (s) y cuánto dura el picotazo; se infla si Felipe está en el alféizar.
const PALOMA_PICOTEA_CADA := 3.4
const PALOMA_PICOTEA_DURA := 0.5
## Atajos (R6): [qué, dónde, desde dónde se abre].
const ATAJOS := [["Caja de arriba de la pila de la mudanza", CAJAS, "escalera"]]
## Cada maña que el nivel enseña abre un camino y molesta a alguien (R19): maña -> [camino, a quién molesta].
const MANAS := {
	"maullar": ["puerta de la cocina (Valeria la abre)", "Valeria y A.S.P.I."],
	"aranar": ["puerta entornada del dormitorio", "el sofá nuevo de Valeria"],
	"frotarse": ["Valeria deja de regañar y vuelve a su serie", "a nadie: es carisma"],
	"zarpazo": ["ratón del mesón (camino al refrigerador)", "ratones y caja de cartón"],
}
## Estado inicial de las puertas (las dos caras de un par se ven igual) y cuáles son puertas-ventana.
const PUERTAS_CERRADAS := [PUERTA_BALCON, PUERTA_COCINA]
const PUERTAS_ENTORNADAS := [PUERTA_DORMITORIO]
const PUERTAS_BALCON := [PUERTA_BALCON]
## Lo que va encima de una repisa dibujada (lugar visto, R17).
const ADORNOS_DE_PIEZAS := {"Repisa alta": "caja_recuerdos"}
## La meta que se muestra al empezar (R4).
const CUARTO_META := "balcon"
const ROTULO_META := "N1_EL_BALCON_ARRIBA_AL"

## Lo que el constructor (Nivel) necesita para armar este nivel.
static func datos() -> DatosNivel:
	var d := DatosNivel.new()
	d.techo = TECHO
	d.suelo = SUELO
	d.alto = ALTO
	d.ancho = ANCHO
	d.habitaciones = HABITACIONES
	d.ruta = RUTA
	d.piezas = PIEZAS
	d.adornos_de_piezas = ADORNOS_DE_PIEZAS
	d.puertas = PUERTAS
	d.puertas_cerradas = PUERTAS_CERRADAS
	d.puertas_entornadas = PUERTAS_ENTORNADAS
	d.puertas_con_sombra_detras = [PUERTA_COCINA]
	d.puertas_balcon = PUERTAS_BALCON
	d.puerta_escalera = PUERTA_ESCALERA
	d.peldanos.assign(PELDANOS)
	d.escalera_pie = ESCALERA_PIE
	d.escalera_cima = ESCALERA_CIMA
	d.lecciones = LECCIONES
	d.descansos = DESCANSOS
	d.cuarto_meta = CUARTO_META
	d.rotulo_meta = ROTULO_META
	d.agenda = Agenda.NIVEL_1
	return d


## Nombre de la habitación que contiene el punto, mirando un píxel arriba para que el piso cuente ("" si está fuera).
static func habitacion_de(punto: Vector2) -> String:
	return DatosNivel.buscar_habitacion(HABITACIONES, punto)


## Rectángulo de la habitación con ese nombre.
static func rect_de(nombre: String) -> Rect2:
	return DatosNivel.buscar_rect(HABITACIONES, nombre)


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
	return datos().estilo_puerta(nombre)


## Rectángulo sagrado de la puerta que está al pie en `pie` (B3, G10): nada se le cruza.
static func rect_sagrado(pie: Vector2) -> Rect2:
	return Rect2(pie.x - MEDIO_RECT_PUERTA, pie.y - Puerta.ALTO_MAXIMO, MEDIO_RECT_PUERTA * 2.0, Puerta.ALTO_MAXIMO)


## Rectángulo de una pieza de PIEZAS por su nombre (vacío si no está).
static func rect_pieza(nombre: String) -> Rect2:
	for pieza: Array in PIEZAS:
		if pieza[2] == nombre:
			return pieza[0]
	return Rect2()
