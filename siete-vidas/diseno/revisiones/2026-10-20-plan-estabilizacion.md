# Plan de estabilización del nivel 1 (2026-10-20)

El creador vio `nivel1-v5.mp4` y dijo que no se ve funcional: se perdieron las luces de las lámparas, las capas están mal (en la cocina Felipe atraviesa a Valeria) y los textos no se leen o se montan sobre la interfaz. Pide que Claude decida y lo resuelva de forma autónoma. Este plan lo decidió Claude; si llega la respuesta de Gemini (`2026-10-20-gemini-regresiones.md`), se usa para afinar los detalles, no para cambiar de rumbo.

**Regla de esta pasada:** no se agrega nada nuevo. Cada cambio se comprueba **mirando** el juego (capturas y video), no solo con las pruebas.

## Decisiones

### 1. Capas: Valeria delante de Felipe, con silueta cuando lo tapa
- Valeria es una humana de 200 px y está más cerca de la cámara que el escenario. Cuando Felipe pasa por donde está ella, en el piso o sobre el mesón detrás de ella, **queda detrás de Valeria**. Así se lee como profundidad y no como un fantasma que la atraviesa.
- Para que el jugador nunca pierda a Felipe, cuando Valeria lo tapa se dibuja su **silueta**: un contorno de 1 px en un color claro de la paleta, solo en la parte tapada. Es la técnica de oclusión de muchos juegos 2D.
- En la tabla de capas, `PERSONAJES` pasa a quedar por encima de `JUEGO` solo para los humanos. A.S.P.I., los ratones y los objetos se quedan como están.
- Hay que revisar todos los lugares donde Felipe y Valeria coinciden: el sofá, el comedor, la cocina, la puerta del recibidor y el frotarse. El frotarse tiene que seguir viéndose: Felipe pasa entre sus piernas y se le ve la silueta.

### 2. Balcón
- Felipe se sienta **al lado** de la maceta de la baranda, no encima. Hay que mover la maceta o el punto donde se sienta.
- La planta oscura y borrosa del primer plano se quita, o se cambia por una planta de Gemini en silueta nítida (sin desenfoque, en pixel art). Si no hay arte, se quita.

### 3. Textos: zonas fijas en la pantalla de 640×360

| Zona | Lugar | Qué va | Regla |
|---|---|---|---|
| A. HUD | Franja de arriba, y de 0 a 26 | Corazones, agenda, contadores y barra del jefe a la derecha | Nada más entra en esta franja. El nombre del jefe se abrevia o se achica hasta que quepa entero. |
| B. Diálogo | Debajo del HUD, y de 30 a 80 | Cuadro de diálogo con retrato | Mientras hay diálogo, la zona C espera su turno. |
| C. Carteles | Centro arriba, y de 30 a 90, **misma franja que el diálogo** | Logros, «¡TRAVESURA CUMPLIDA!», fases del jefe, «¡DEPÓSITO LLENO!», «PODER NUEVO» | Uno a la vez, por la cola única de `Anuncios`. Si hay diálogo, espera o se acorta. Letra mínima de 8 px de alto en el juego, con fondo del kit. Nunca encima del HUD. |
| D. Palabras del mundo | Sobre Felipe o sobre el objeto | «¡CRÍTICO!», «¡PLÁSTICO: 0!», «¡POP!», «¡FIUU!» | Como máximo 1 a la vez y 0,9 s. Letra grande (Silkscreen, 8 px o más), contorno oscuro de 1 px y sin texto chico debajo. Se recoloca para no entrar en las zonas A, B y C ni salirse de la pantalla. |
| E. Avisos de botón | Burbuja del Indicador sobre Felipe | «E Degustar» | Igual que ahora. No choca con la zona D: si coinciden, D va más arriba. |

- Se quitan los textos chicos de segunda línea en el mundo. «CONTENIDO SENSIBLE» queda solo como pegatina grande y legible.
- Se arreglan los símbolos que la letra no tiene: «♪» aparece como «J». O se dibuja como ícono o se cambia el texto. Hay que revisar todos los textos de `textos.csv` contra los caracteres de las letras.
- Una prueba nueva, `prueba_zonas_texto`, recorre todos los anuncios, carteles y palabras posibles y comprueba que sus rectángulos no se solapen con las zonas prohibidas ni se salgan de 640×360. También comprueba que todos los caracteres de `textos.csv` existan en las letras usadas.

### 4. Luz de las lámparas, sin halo de filtro (lección 26)
Cada lámpara encendida de la casa (la de la sala, la de pie del recibidor y las demás) tiene tres cosas:
- **pantalla encendida:** la pantalla de la lámpara con un tono más claro y cálido;
- **cono en escalones:** de 2 a 3 franjas de luz cálida con bordes duros de pixel, transparencia de 6 a 10 %, que bajan desde la pantalla y se abren hacia el piso o la mesa;
- **luz en lo que toca:** una franja iluminada en el piso o en la mesa, en escalones, nunca un círculo suave sobre el tapiz.

Una sola dirección de luz por cuarto, como ya está. Se compara con las capturas de antes (`hoja-v4h.png`) para que se note **más** que antes, no menos.

### 5. Revisar lo congelado (derrotas y mandos)
Se mantienen, pero pasan por la misma revisión visual: la derrota del ratón y la de A.S.P.I. cumplen las zonas de texto, y la cámara lenta no rompe los carteles.

## Cómo se comprueba antes de mostrarlo al creador

1. Todas las pruebas, más `prueba_zonas_texto`, en 0 fallos. El bot completa el nivel.
2. Capturas de cada momento con texto (cada anuncio, cartel y palabra) y de cada cruce entre Felipe y Valeria, ampliadas, revisadas una por una contra `06-lecciones-arte.md`.
3. Video completo nuevo (`nivel1-v6.mp4`). Claude lo mira entero en hojas de cuadros cada 2 s y busca: textos tapados o ilegibles, capas cruzadas, cosas flotando, lámparas sin luz y cortes. Si encuentra algo, se arregla y se graba otra vez. Solo después se le muestra al creador.
