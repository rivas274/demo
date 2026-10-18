# Instrucciones para Claude

Este repositorio contiene el desarrollo del juego **Felipe: Siete Vidas, Cero Disculpas**.

Antes de proponer o construir algo, lee la memoria del proyecto en `siete-vidas/memoria/README.md` y los archivos que enlaza. Ahí están las decisiones ya cerradas, la guía del personaje, las herramientas y los pendientes.

Al cerrar cualquier decisión nueva, actualiza esos archivos.

## Regla fija: cada cambio de un personaje se refleja en tres lugares

Cuando cambies cualquier cosa de un personaje (sprites, animaciones, reglas de movimiento, rasgos), en el mismo trabajo y sin que te lo pidan:

1. **Memoria:** actualiza `siete-vidas/memoria/` (guía del personaje con la tabla **Acciones de Felipe**, arte y herramientas con assets y créditos, pendientes).
2. **Ficha de concepto:** regenera la copia local (`python3 siete-vidas/herramientas/pagina_felipe.py siete-vidas/concepto/felipe-concepto.html`) y vuelve a publicar la versión en línea (https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe). Revisa que tablas y textos de la ficha mencionen el cambio.
3. **Juego:** si afecta al juego, aplícalo en `siete-vidas/juego/`, cúbrelo con una prueba y corre las pruebas.

Además:

- **Toda acción nueva o cambiada** (controles, qué hace, animación, estado) se registra en la tabla "Acciones de Felipe", que existe igual en la ficha y en `02-guia-felipe.md`.
- **La ficha y la memoria son la guía vigente** para el desarrollador, el diseñador y Claude: muestran solo lo aprobado y en uso. Lo descartado se quita de ambas (y sus archivos se borran del repositorio); no se guarda historial ahí.

Al terminar, confirma al creador cuáles de los tres actualizaste.

## Regla fija: consistencia del personaje (prioridad máxima)

Felipe debe verse siempre como el mismo gato. Esto pesa más que ahorrar créditos o tener una pose exacta.

- **Toda animación nueva se genera directamente desde Felipe A** (`14b3c27f-798c-4795-84fe-48ed15508247`) con `animate_game_art`, describiendo el movimiento completo (por ejemplo, "se sienta y se lame la pata"). No se edita una pose intermedia: las poses editadas cambian la vista (quedan de perfil), las proporciones y la expresión.
- **Vista 3/4 como Felipe A**, cabeza cerca del 40 % de la altura, rasgos de la guía y expresión por defecto de reojo, salvo que la acción pida otra.
- **Objetos que no están en Felipe A** (estambre, comida, juguetes) se dibujan aparte y se mueven por código; no se piden dentro de la animación.
- **Antes de usar una animación**, se compara con `python3 siete-vidas/herramientas/comparar_felipe.py <salida.png>` (Felipe A junto a un cuadro de cada animación, al tamaño del juego) y se muestra al creador. Si no es el mismo gato, no entra.

## Regla fija: proporciones

Felipe es un persa grande (unos 8 kilos), grande y no obeso; en el juego debe sentirse así. Al dibujar, generar o colocar cualquier cosa:

- **Felipe mide 67 px de alto** en la resolución base 640×360 (58 px de las orejas a las patas). Todas sus hojas son de 8 cuadros de 106×106 hechas desde Felipe A y se dibujan a **una sola escala, 0.72** (`Felipe.ESCALA_SPRITE`). No se usa otra escala por animación: si una hoja sale de otro tamaño, se rehace.
- **Cabeza: 56 % de la altura de las orejas a las patas.** En el cuadro de 106 px va de la fila 25 a la 70 (45 × 55 px); en el juego, 32 × 40 px. Tiene que medir lo mismo en todas las animaciones.
- **Estirar y aplastar: como mucho ±8 %** (`Felipe.DEFORMACION_MAXIMA`), en el juego y en la ficha. Más deforma la cabeza y se ve antinatural.
- **Agachado mide 52 px** (la cabeza no se aplasta): los huecos para pasar agachado son de al menos 45 cm (54 px). De pie, la colisión mide 58 px; agachado, 50.
- **Transiciones:** entre poses muy distintas (de pie a agachado, salto a caída) hace falta una animación de transición desde Felipe A, no un cambio brusco de hoja ni un estirón de código.
- **Escala del mundo: 1,21 px por cm.** Muebles, puertas y objetos usan medidas reales (sofá 45 cm, mesa 75 cm, mesón 90 cm, refrigerador 1,80 m, puerta 2,05 m). Felipe "mide" unos 55 cm con la cabeza: llega casi a la altura de una mesa de comedor.
- **Humanos: 3 Felipes** (Valeria, 1,65 m ≈ 200 px), con proporciones normales. Solo los gatos son Chibi.
- **Otros gatos** a la misma escala que Felipe según su tamaño real (un gato común, un poco más bajo que él).
- **Casas del Barrio Viejo:** techo alto (3,5 m) para dejar espacio a trepar.
- Si cambia el tamaño de Felipe, escalar en la misma proporción su colisión, cámara, velocidades y gravedad, y mantener la comprobación de altura de `prueba_movimiento.gd`.

Detalle y comparación descartada en `siete-vidas/memoria/02-guia-felipe.md` (sección Estilo aprobado) y `siete-vidas/arte/referencias/proporciones-felipe.png`.

## Juego en Godot

El proyecto está en `siete-vidas/juego/` (Godot 4.3, GDScript con tipos). Antes de subir cambios al juego, corre la prueba de movimiento (ver `siete-vidas/juego/README.md`). Si Godot no está instalado en la sesión, instálalo como indica `siete-vidas/memoria/03-arte-y-herramientas.md`.
