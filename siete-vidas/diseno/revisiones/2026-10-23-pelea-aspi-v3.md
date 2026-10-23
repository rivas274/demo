# Pelea con A.S.P.I. v3: lectura, apagón, «Arte gatuno» y sobrecarga (2026-10-23)

Pedido del creador (aprobó las mejoras que propuso Gemini en `2026-10-23-gemini-pelea-aspi.md`, con la maqueta `capturas/pelea-aspi/gemini-maqueta-fase3.png`). Base: la v2 (`2026-10-23-pelea-aspi-sin-reposicion.md`). Estado: **aplicado**, 0 créditos.

## 1. Lectura (los 3 problemas que vio Gemini)

| Problema | Antes | Ahora |
| --- | --- | --- |
| a) Avisos lejos de la acción | «¡DEPÓSITO LLENO!», «¡LO VACIÓ!» y la pista del botón salían en la franja de arriba (zona C), lejos de A.S.P.I. | **Nacen sobre ella:** el cartelito «¡DEPÓSITO LLENO!» (o «¡EN CORTO!») con la flecha hacia abajo va sobre su tapa y se corre adentro si ella está en el borde de la pantalla (lección 23). La **embestida** dibuja en el piso una línea roja de puntos hasta donde va a cargar, que parpadea mientras retrocede (como pidió Gemini). Los carteles de fase siguen en la zona C, con pistas más cortas |
| b) El diálogo tapaba la acción | Cuadro de diálogo con retrato arriba de la pantalla | **En la pelea, Felipe piensa en un globito** sobre su cabeza (`GloboDialogo`), que se va solo en unos 2 s, nunca entra al HUD ni se sale de la pantalla. Fuera de la pelea (y al ganar), el cuadro de siempre |
| c) No se ve venir a A.S.P.I. | Cámara pegada a Felipe | **La cámara mira hacia ella** (`CamaraPelea`): si está fuera de pantalla o avisa un ataque desde lejos, se corre suave hasta 150 px y vuelve suave. Si aun así no se ve, una **flecha en el borde** con su luz roja |

**Por qué no un zoom-out:** el juego se dibuja a 640 × 360 y se agranda en múltiplos enteros (`stretch/scale_mode = integer`). Con un zoom de cámara que no sea entero, unos píxeles salen de 1 y otros de 2, y el pixel art se ensucia. La receta de los juegos de pixel art (Celeste, Dead Cells) es **correr la cámara y marcar el borde**. No hizo falta probar 5 variantes de zoom: con cualquier valor fraccionario pasa lo mismo, y el único zoom entero que aleja (0,5) muestra el doble de cuarto (1280 px, más que el estudio) con Felipe de 33 px.

## 2. Clímax de la fase 3: «Cortocircuito y apagón»

- **Al empezar la fase 3** (cartel «FASE 3: ¡APAGÓN!», pista «Los charcos la fríen. {maullar} la atrae»), A.S.P.I., ya reiniciada, grita «¡ERROR!», pita en reversa y corre a toda velocidad contra el enchufe de la estación de carga. Le siguen chispas, «¡BZZZT!», un destello y una sacudida, y **se corta la luz**: la luz parpadea 3 veces y el cuarto queda en penumbra azulada.
- **Luz en el apagón** (`ApagonEstudio`): `CanvasModulate` del cuarto (el de `LuzCuarto` o uno propio). Iluminan la **luz roja de emergencia** de A.S.P.I., que late, su **LED** verde, la luna por la ventana y un brillo frío alrededor de Felipe (sus ojos de gato). Así siempre se ven Felipe y los muebles: la penumbra no es negra (valor 0,54). Los avisos, las chispas y las bolas de pelo van sin sombrear.
- **Los charcos son la clave:** el agua del vaso y el café de la taza que quedaron en el piso brillan con un reflejo de 1 px. Si A.S.P.I. pasa por uno, chispea y queda **en corto**: inofensiva y vulnerable como con el depósito lleno («¡EN CORTO!» y la flecha), y Felipe le salta encima. Si nadie la apaga, se le pasa (3,5 s sin volver a electrocutarse) y no escupe pelusa. El depósito lleno sigue sirviendo igual.
- **Siempre hay un charco:** el choque sacude el escritorio y, si el vaso o la taza siguen arriba, caen. Si aun así no queda ningún charco, se le sale el agua del tanque junto al enchufe (`Charco`).
- **Maullar la atrae** (ya existía): Felipe se para del otro lado del charco y maúlla; ella gira hacia él y pasa por encima.
- **Bolas de pelo menos seguidas:** cada 3,4 s (antes 2,2).
- **Cierre:** al apagarla por última vez, **vuelve la luz de golpe** con «¡APAGADA!» y la cámara lenta de su derrota.
- **No se hizo** (de la maqueta): el tornado de pelusa en el centro y las «zonas danger». Recargaban la pantalla y competían con los charcos como idea central. Queda como opción si la fase 3 se siente corta.

## 3. Nota de «Arte gatuno» (opcional, no obliga)

Al terminar, después de la frase de Felipe, un cartel en la zona C dice «ARTE GATUNO: N %», donde N es lo tirado sobre todo lo que se podía tirar (14). Debajo va el rango: **Aficionado** (hasta 40 %), **Decorador** (hasta 80 %) u **O B R A   M A E S T R A**. Con más del 85 % se oye un golpe de puerta y Valeria grita desde abajo, fuera de cuadro, «¡¡FELIPE!!». Además sale el logro **«Reestructuración Inmobiliaria»** (`NotaArteGatuno`).

## 4. Sobrecarga antes del «¡BLORP!»

Al apagarla (o al vaciar el depósito) hay 0,6 s de **sobrecarga**: vibra, se atraganta (sonido), echa humo y chispas. Recién después se le abre la tapa y **escupe con fuerza** la montaña (arco más alto, destello, sacudida mayor y «¡BLORP!» más grande) (`PelusaAspi`).

## 5. Sonido (ganchos preparados)

`DatosJefe.sonidos` asocia cada momento a un sonido: el **motor**, que sube de tono con cada mancha (`tono_por_mancha` = 0,12), la **reversa** antes de embestir y de correr al enchufe, el **atragantamiento** antes del «¡BLORP!», el **blorp** y el **cortocircuito**. Hay provisionales sintetizados (`herramientas/sonidos_demo.py <carpeta> motor reversa atragantar cortocircuito`). El encargo de música y sonidos finales está en `memoria/05-estado-actual.md`.

## 6. Contra los pilares, las reglas y las lecciones

- **Pilar 5 (épico en su cabeza):** apagón, luz de emergencia, «¡BZZZT!» y la nota de obra maestra, con Felipe orgulloso.
- **Pilar 3 (siempre te sales con la suya):** siempre hay charco y la suciedad nunca se pierde; la nota no obliga.
- **Pilar 2 (cada maña es llave y travesura):** maullar, que es una maña enseñada en el recibidor, ahora es llave del clímax.
- **R12 (el jefe es un examen):** usa tirar, agacharse, muebles, saltar y, ahora, maullar.
- **R14 (lectura clara):** penumbra de valor 0,54, no negra; Felipe con su brillo; avisos sin sombrear.
- **R16:** sin cambios en `PresentacionJefe`.
- **Lecciones:** 23 (nada se corta en el borde: el cartelito se corre adentro), 26 (las luces en escalones, sin halo suave), 38 (zonas de texto: el globito queda fuera del HUD y dentro de la pantalla; las palabras siguen siendo una a la vez) y 40 (las luces se notan).

## 7. Crítica honesta (desde el jugador)

1. **El apagón es el mejor momento de la pelea**, pero dura poco con un bot que la apaga rápido. Una persona va a vivirlo más.
2. **Lo de los charcos se entiende por la pista del cartel y el brillo**, pero el primer «¡EN CORTO!» puede pasar por casualidad, sin que el jugador lo provoque. Si en la prueba de juego no lo entienden, Felipe podría decir algo al ver el primer charco brillar.
3. **El globito es mucho mejor que el cuadro**, pero las frases largas ocupan 2 o 3 líneas. Conviene tener frases de pelea más cortas.
4. **La nota de «Arte gatuno»** casi nunca da obra maestra si no se busca: la pelea se gana tirando 4 cosas. Está bien que sea un desafío opcional, pero el creador debería decidir si muestra la nota también en el resumen del día.
5. **Sin música real**, la fase 3 no llega a sentirse «metal».

## 8. Agregado: aparición y golpes que se sienten (video «How to make enemy spawns feel good», del creador)

De los 5 pasos del video (avisar con un círculo, abrir un portal, dejar caer, hacer temblar el piso y despertar con un «!» y una pausa) se tomó lo que encaja, sin pasarse:

- **A. Cuando Felipe le salta encima, el piso tiembla:** onda de choque tendida en el piso (un óvalo de pixel que crece en 3 escalones), polvo que salta y **lo tirado cerca brinca** (pedazos, papeles, notas, libros y motas; `PiezaSuelta.brincar`, sin dejar otra mancha). La cámara hace una **sacudida vertical** corta (`Jugo.sacudir(..., vertical)`), además del congelado de 0,1 s. El **golpe final** (el que la apaga del todo) es 1,6 veces más fuerte.
- **B. Despertar** (al entrar y al volver de cada fase, después del «¡BLORP!»): pitido, la luz pasa a roja, un «!» sobre ella (zona D) y **0,4 s de pausa** antes de moverse, con una marca roja en el piso hacia donde va (Felipe). El reinicio entre fases sube a 2,2 s para que entre la sobrecarga, el «¡BLORP!» y el despertar sin pisarse.
- **C. Embestida:** a la línea roja del piso se le suma el **círculo** donde termina la carga (el tramo «telegrafiado»), que también se lee en la penumbra.
- **D. Bolas de pelo:** una **marca amarilla en el piso** donde va a caer cada bola, desde la tos hasta que llega. La bola cae ahí, donde estaba Felipe al toser: es justo.
- **Lo que no se tomó:** el portal con remolino y «dejar caer» al enemigo, porque A.S.P.I. ya está en el cuarto y su entrada es la presentación de 8 pasos.
- **Datos:** `datos/jefes/aspi_jugo.tres` (`DatosJugoJefe`): radio, escalones y duración de la onda, sacudida, brinco, polvo, multiplicador del golpe final, pausa del despertar y radio de las marcas.
- **Felipe alegre y juguetón** (nota del creador): celebra cada apagado con un maullido al aterrizar, si el jugador no lo está moviendo, y al ganar juega con el estambre (animaciones que ya existían). Las frases de la pelea suenan a que se divierte: «¡Confeti!» al esparcir, «¡Ja! Baile eléctrico.» en el charco, «¡Se fue la luz! Hora de las escondidas.» y, según la nota, «¡Mi obra maestra! Firmada con pelos.» o «¿Ya? Era el calentamiento. ¡Quiero revancha!».

## 9. Encargo opcional a Gemini (no hace falta)

«Una regleta/enchufe de pared quemado con marca negra de hollín y una chispa, pixel art del mismo estilo de `estudio-v2.png`, 16 × 16 px en el juego, sobre fondo blanco». Hoy el choque se ve con chispas y destello, sin marca que quede.
