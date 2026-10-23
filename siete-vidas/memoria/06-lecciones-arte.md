# Lecciones de arte y ambientes (errores que el creador vio a simple vista)

Léelas **antes** de diseñar, construir o revisar cualquier escenario. Cada una es un error real que se nos pasó y que el creador encontró en segundos. Si una revisión no los busca, no sirve.

## Cómo revisar

- **Mira el juego como lo ve un jugador:** capturas a 640×360 y ampliadas ×2–×4, cuadro por cuadro en cada transición (el cuadro anterior, el del cambio y el siguiente). Medir datos no basta; las pruebas en verde no significan que se vea bien.
- **Pregúntate en cada cuarto:** "¿esto lo dibujó alguien con cariño o parece montado?". Si dudas, pásale la captura a Gemini con las correcciones del creador y verifica su respuesta contra la imagen (Gemini inventa nombres de objetos).
- **Una pasada con plan:** no se corrigen detalles sueltos. Se arma un plan por cuarto y se aplica de una vez.

## Errores que no se repiten

| # | Error | Regla |
| --- | --- | --- |
| 1 | Puertas con un poste en el medio; marcos de puerta de 4 anchos; puerta cuadrada por un lado y arco por el otro | Un solo marco para toda la casa; cada par se ve igual por los dos lados |
| 2 | Lámpara o caja de arena delante de una puerta | Nada tapa una puerta ni una interacción |
| 3 | Sillas torcidas, mesa y sillas fundidas en una pieza | Cada mueble derecho y en su pieza |
| 4 | Felipe, ratones y objetos flotando sobre los muebles; margen transparente en las imágenes | La colisión calza con el borde del arte (±2 px); el arte se recorta a su borde opaco |
| 5 | Comida diminuta | Lo que le importa al gato se ve grande (lado menor ≥ 24 px) |
| 6 | Barreras sin sentido (dos rejas apiladas) | Toda barrera se explica sola en el mundo |
| 7 | Subir la escalera deslizando la pose de caminar | Cada desplazamiento tiene su animación |
| 8 | El escenario (escritorio) dibujado encima de la imaginación del jefe; dos A.S.P.I. a la vez | Una sola tabla de capas (memoria 03) |
| 9 | Valeria y Felipe con los pies patinando; Valeria sin alternar las piernas | El ciclo de caminar se mide (pie apoyado = velocidad ÷ fps) antes de aceptar el arte |
| 10 | Poses que cambian de golpe; Valeria hundida en el piso; atraviesa puertas cerradas; se teletransporta | Transición en cada cambio de pose; los personajes abren puertas y caminan por el recorrido |
| 11 | Carteles que tapan el chiste o se apilan | Una sola cola de anuncios |
| 12 | Ventanas a distintas alturas, pegadas al techo o diminutas | Todas las ventanas con el alféizar a 90 cm (109 px) y el mismo estilo |
| 13 | Papel higiénico en el estudio | Cada objeto pertenece a su cuarto y cuenta algo de quien vive ahí |
| 14 | Ropa flotando en el borde de la cama | Las cosas se apoyan en el centro de su superficie, hundidas si es blando |
| 15 | Bajo la escalera, un bloque que no se entiende | Todo volumen se explica (armario con su puerta, estructura) |
| 16 | Todo pegado a la pared, el piso como tira de adorno, nadie lo pisa | El piso es un plano: se ve detrás de los pies, todo se apoya en él con su sombra |
| 17 | Piso hecho por código con líneas oscuras y perspectiva torpe: "apresurado, montado" | Superficies grandes (piso, pared) con arte de verdad, no con relleno por código |
| 18 | Grifo sin lavaplatos; después, un lavaplatos desproporcionado | Si agregas un objeto, agrega lo que lo hace tener sentido, **a escala**, y míralo junto a los muebles de al lado |
| 19 | Rectángulo blanco alrededor del sofá (el contorno del aviso) que parece un recorte pegado | Nada de cajas o rectángulos de depuración a la vista; el resalte sigue la silueta |
| 20 | Simetría perfecta, objetos en fila como catálogo, clones (seis zapatillas iguales) | Islas con intención, alturas variadas, nada clonado |
| 21 | Nada se mueve; sin desgaste ni historias | Algo vive en cada cuarto; pelos, arañazos y objetos personales |
| 22 | Muebles sin sombra de contacto | Sombra de 2 px de alto bajo cada pata y 1 px de oclusión detrás de los muebles grandes (Gemini) |
| 23 | Objetos cortados al ras del borde de la pantalla | Nada importante se corta en el borde: o entra entero o sale claramente |
| 24 | Luces y sombras sin una dirección común | Una dirección de luz por cuarto (por defecto arriba a la izquierda, o la ventana); sombras y brillos la siguen |
| 25 | Puertas abiertas sin grosor de muro | Toda abertura muestra el grosor del muro (jamba con 2 tonos) |
| 26 | Halo circular de luz pegado en la pared (efecto "filtro") | La luz cae en superficies (mesa, piso) en escalones; nada de círculos suaves sobre el tapiz |
| 27 | El resalte de un mueble dibujado encima de todo cruzaba a Valeria sentada en él | El resalte va detrás de muebles y personajes: solo se ve donde hay pared o piso detrás (o sobre su apoyo, si está encima de otro mueble) |
| 28 | El grifo nuevo quedaba tapado por el ratón que patrulla el mesón | Al agregar un detalle, mira qué pasa por delante (patrullas, personajes, carteles) en todo su recorrido y dale su capa |
| 29 | Vaso, taza y monitor flotando en el borde de atrás del escritorio; un libro diminuto flotando en el taburete | Lo que va sobre un mueble se apoya en el CENTRO de la superficie, con sombra, al doble del tamaño real (escala de gato) y con pocos objetos por mueble |
| 30 | Una impresora y un ratón de cuerda sobre la mesa que recargan todo | Cada objeto se gana su lugar: si no cuenta nada ni sirve al juego, se quita |
| 31 | Cocina estrecha con un lavaplatos diminuto, por querer que todo quepa en una pantalla | La cámara se mueve: un cuarto puede ser más ancho que la pantalla para que los muebles tengan su tamaño |
| 32 | Escoba mal dibujada, por código, junto a arte de Gemini | Ningún objeto de código al lado del arte si se nota; mejor arte de Gemini o quitarlo |
| 33 | La reja "PIPE: NO" se veía mal y Felipe la atravesaba aunque las pruebas pasaban | Toda barrera bloquea de verdad (una prueba empuja a Felipe contra ella) y se explica sola en el mundo |
| 34 | Vaso, taza y monitor hundidos 1–2 px seguían viéndose en el borde de atrás del escritorio, cuya cubierta se ve de 16 px | Mide en el arte cuánto se ve la cara de arriba de cada mueble y apoya el objeto en su medio (escritorio 9 px, mesa 5, consola 4), con sombra 1 px más ancha que la base |
| 35 | Una captura puso a Felipe dentro del mesón y salió hundido bajo el piso | Antes de revisar una captura, mira que cada personaje esté parado en algo (los puntos de captura y de prueba van en lugares libres, no dentro de un mueble sólido) |
| 36 | El poste del pasamanos (primer plano) tapaba 6 px del costado de la pila de cajas, y la pila no cabía entre él y el librero | Al encajar una pieza entre otras, mide el hueco con las máscaras de pixeles del arte (no con rectángulos) antes de moverla; si no cabe, se cambia la pieza o el lugar, nunca se deja cruzada con algo de primer plano |
| 37 | **Las pruebas pasaban pero se veía mal** (video v5: luces perdidas, Felipe atravesando a Valeria, textos montados en el HUD) | Ningún cambio se da por bueno sin **mirarlo**: capturas ampliadas de lo que cambió y el video completo revisado en hojas cada 2 s, buscando textos tapados, capas cruzadas, cosas flotando, lámparas sin luz y cortes. Las pruebas en verde son el piso, no la meta |
| 38 | Textos que se leían mal o se montaban: cartel con letra diminuta, «¡DEPÓSITO LLENO!» sobre el HUD, nombre del jefe cortado («N…»), «♪» como «J», dos palabras a la vez | **Zonas fijas** (`ZonasTexto`): A HUD y 0–26, B diálogo y 30–80, C carteles y 30–90 (uno a la vez, después del diálogo), D palabras del mundo (1 a la vez, 0,9 s, fuera de A–C) y E burbuja. Letra de 16 px o más en carteles y palabras, contorno de 1 px, sin segundas líneas chicas. `prueba_zonas_texto` revisa rectángulos y que todo carácter de `textos.csv` exista en las letras |
| 39 | Felipe se dibujaba encima de Valeria y parecía un fantasma que la atravesaba | Los humanos (200 px) van **delante** (`Capas.PERSONAJES`) y donde tapan a Felipe se ve su contorno (`SiluetaTapada`). Si Felipe está sobre algo que queda delante de ella (el asiento del sofá: `Nivel1.DELANTE_DE_HUMANOS`), va delante. Revisa cada cruce (sofá, comedor, cocina, puertas, frotarse) en capturas |
| 40 | Las lámparas «se apagaron»: se quitó el halo y no quedó nada que se leyera como luz | Cada lámpara encendida tiene **pantalla encendida** (más clara, contorno claro de 1 px), **cono en 3 escalones** de bordes duros (6–10 %) y **franja iluminada en escalones** donde cae, con el cuarto algo oscurecido (`Nivel1.LAMPARAS`, `AMBIENTE_CUARTOS`). Nunca un círculo (lección 26); compara siempre con la captura de antes: tiene que notarse **más** |
| 42 | Lo roto desaparecía («se evaporó») y comer se llevaba el plato | Todo lo que se rompe deja su marca (pedazos que quedan, charco o tierra) y lo que se come deja su recipiente vacío; los pedazos se leen como esquirlas en ángulo, no como recortes rectos del objeto |
| 43 | Un HUD lleno de contadores fijos tapaba la pantalla | Fijo solo lo que se decide a cada segundo (corazones; en la pelea, snacks); lo demás aparece al cambiar y vive en la pausa |
| 44 | La pizarra «diminuta y lejos» no cabía al lado de la ventana | Antes de achicar algo que cuenta la historia, ensancha el cuarto (lección 31) y mide con el marco real, no con el vidrio |
| 45 | Lo roto volvía entero a su lugar cada 6 s para que no faltara munición: «reaparece por arte de magia» y rompe la inmersión | Nada reaparece. Si un recurso de juego se acaba, se resuelve **dentro del mundo** (más fuentes que tienen sentido en el cuarto; el jefe devuelve lo que tragó, como Birdo con sus huevos) y lo que cae queda en el piso con su sombra hasta el final |
| 41 | Felipe sentado encima de una maceta de la baranda | Donde un personaje se sienta o se para, no hay decorado sin colisión debajo: el punto se limita a un tramo libre (`Nivel1.ASIENTO_BARANDA`) y la prueba lo mide con el arte |

## Antes de dar por terminado un escenario

1. Recorre todas las filas de arriba contra capturas reales.
2. Si dudas de alguna, pásale la captura a Gemini.
3. Pregúntate si el creador lo vería en 5 segundos. Si la respuesta es sí, no está terminado.
