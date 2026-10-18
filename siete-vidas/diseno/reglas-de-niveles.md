# Reglas para diseñar niveles

Rigen para todos los niveles de *Felipe*. **Al diseñar**, cada nivel nuevo explica en su documento (`nivel-XX-*.md`) cómo cumple cada regla. **Al probar**, `siete-vidas/juego/pruebas/prueba_reglas_nivel.gd` valida las medibles sobre los datos del nivel; lo que no se puede medir se revisa con capturas antes de mostrar el nivel al creador. Si una regla no se cumple, se cambia el nivel, no la regla (cambiar una regla es una decisión del creador).

Salen de lo que pidió el creador (consistencia, proporciones reales, humor, un primer nivel "de calidad") y de juegos parecidos que funcionaron.

## Qué tomamos de cada juego

| Juego | Qué hace bien | Regla que inspira |
| --- | --- | --- |
| Super Mario Bros. (1-1) y Super Mario 3D World | Enseña sin texto en un lugar seguro. Cada nivel sigue *kishōtenketsu*: presenta una idea, la desarrolla, le da un giro y la cierra. Una idea por nivel. | R1, R2, R3 |
| Celeste | Suma las mecánicas de a una. Hay un punto de control al entrar a cada pantalla y morir cuesta segundos. | R1, R5 |
| Hollow Knight | Bancos cerca de los jefes. Atajos que se abren desde el otro lado y vuelven al banco. Cada zona tiene su identidad visual. Los jugadores critican los jefes lejos de un banco. | R5, R6, R9 |
| Stray | El mundo se ve desde un gato: los muebles y los tubos son el recorrido. La verticalidad viene de lo que haría un gato. La guía es ambiental (luces y carteles), sin flechas. | R7, R8, R13 |
| Zelda y Mega Man | El jefe se gana con lo que la mazmorra acaba de enseñar. | R12 |
| Broforce y Cuphead | El jefe se presenta: todo se congela, la cámara se acerca de golpe y aparece su nombre en una franja. La pelea cambia la pantalla y va por fases. | R16 |
| Ori y Hollow Knight | Secretos que premian mirar y trepar, fuera del camino principal. | R10 |
| Diseño clásico de ritmo | Alternar tensión y calma. Tras el jefe, un alivio. | R11 |

## Reglas

Una ✔ indica que `prueba_reglas_nivel.gd` la valida; 👁 que se revisa con capturas.

| # | Regla | Cómo se valida |
| --- | --- | --- |
| R1 | **Enseñar → probar → girar.** Toda mecánica que el nivel exige se enseña antes en la ruta (`Sala.RUTA`) con su aviso. Se enseña una idea a la vez: los avisos de un mismo piso quedan a 150 px o más. Después se pone a prueba con poco riesgo y, más adelante, se usa de otra forma. | ✔ aviso antes de la exigencia y separación entre avisos. 👁 el "giro". |
| R2 | **Enseñar sin peligro.** Los primeros 80 px de la zona de cada aviso no tienen nada que haga daño (juguetes, ratones, A.S.P.I.). | ✔ |
| R3 | **Mostrar antes que decir.** El espacio enseña. El texto se limita a la tecla o el botón en uso, en una línea de 48 caracteres o menos (sin contar las teclas), y aparece una sola vez. | ✔ largo. `prueba_nivel` valida que aparezca una sola vez. |
| R4 | **Meta a la vista.** La salida queda al final del recorrido y se muestra al empezar (la cámara la enseña) aunque todavía no se pueda alcanzar. | ✔ posición. `prueba_nivel` valida que se muestre. |
| R5 | **Descanso cerca del peligro.** Toda zona de daño queda a 700 px o menos (horizontal más vertical) de un punto de descanso, y hay un descanso antes del jefe. Reaparecer es inmediato. | ✔ |
| R6 | **Atajos que vuelven.** El nivel tiene al menos un atajo. Se abre solo desde el lado lejano y termina a 200 px o menos de un descanso. El camino de ida no es el de vuelta. | ✔ |
| R7 | **Verticalidad de gato.** Hay más de un piso, algo que trepar y muebles que hacen de camino. Toda superficie se alcanza con doble salto o trepando. | ✔ (`prueba_escenario` valida el alcance) |
| R8 | **Medidas reales y huecos legibles.** Se usan 1,21 px por cm y las medidas reales de CLAUDE.md. Bajo un mueble sólido no hay hueco, o hay uno de 36 px o más para pasar agachado. Nunca un hueco que parece pasable y no lo es. | ✔ huecos. 👁 medidas en capturas. |
| R9 | **Un hito por zona.** Cada habitación tiene su pared, su color y un objeto reconocible, para orientarse sin mapa. | ✔ pared distinta. 👁 el hito. |
| R10 | **Exploración premiada.** Hay al menos 3 calcetines. Cada uno descansa sobre algo donde Felipe se puede parar, y al menos uno pide subir o mirar fuera del camino. | ✔ |
| R11 | **Ritmo.** Entre dos zonas de daño fuertes (juguetes, A.S.P.I.) de una misma habitación hay al menos una pantalla (640 px) de calma. Los ratones son práctica. El nivel cierra con un alivio (el balcón). | ✔ calma. 👁 alivio. |
| R12 | **El jefe es un examen.** El jefe pide al menos dos mecánicas enseñadas antes: con A.S.P.I., agacharse (aferrarse a la succión), tirar cosas (aturdirla), zarpazo y saltar (bolas de pelo). | ✔ |
| R13 | **Cada habitación tiene con qué jugar**, y con humor de gato: algo que tirar, perseguir, romper o comer. | ✔ hay algo. 👁 el chiste. |
| R14 | **Lectura clara.** Lo que se pisa, lo que hace daño y el fondo contrastan. Las siluetas del primer plano nunca tapan a Felipe ni lo que hay que leer. | 👁 capturas de cada zona |
| R15 | **Felipe se ve siempre igual.** Las reglas de consistencia y proporciones de CLAUDE.md valen dentro de cualquier nivel. | ✔ `prueba_movimiento` (altura) y 👁 `comparar_felipe.py` |
| R16 | **El jefe se presenta y cambia el mundo.** Una entrada de menos de 5 s congela el juego: acercamiento, «¡BATALLA INICIADA!» y el nombre del jefe. El escenario se transforma según la imaginación de Felipe (lo absurdo va en el fondo, sin colisión). La pelea tiene fases que se anuncian con un cartel y una pista de una línea, y al ganar todo vuelve de golpe a la normalidad. Todo jefe usa la misma presentación reutilizable, `PresentacionJefe` (`scripts/presentacion_jefe.gd`): cada pelea solo da nombre, título, colores y su propio "momento". | ✔ `prueba_jefe` (incluye un segundo jefe de prueba) |

## Al diseñar un nivel nuevo

1. Escribir `nivel-XX-*.md` con el propósito del nivel, la ruta y una línea por regla que diga cómo la cumple.
2. Armarlo desde datos en el script del nivel (como `Sala`: `HABITACIONES`, `RUTA`, `PIEZAS`, `AVISOS`, `DESCANSOS`, etc.) para que la prueba de reglas pueda leerlo.
3. Correr `prueba_reglas_nivel.gd` (y las demás) y revisar las reglas 👁 con capturas de cada zona.
4. Comprobar que un bot lo termina con los botones de una persona (como `pruebas/partida.gd` en el nivel 1) y grabar el video del gameplay para el creador.

## Fuentes

- Koichi Hayashida (Nintendo) sobre *kishōtenketsu* en Super Mario 3D Land/World (entrevista en Gamasutra, 2012).
- [Análisis de Celeste: mecánicas graduales y un punto de control por pantalla](https://game-wisdom.com/analysis/celeste).
- [El diseño de niveles de Hollow Knight](https://sites.utulsa.edu/csg/?p=23) y [quejas de jugadores sobre jefes lejos de un banco](https://steamcommunity.com/app/367520/discussions/0/2741975115079018344/).
- [Cómo diseñar un buen mapa metroidvania (PC Gamer, con Team Cherry)](https://pcgamer.com/how-to-design-a-great-metroidvania-map).
- [Avance de Stray en Engadget: verticalidad y caminos de gato](https://www.engadget.com/stray-preview-cat-game-ps5-ps4-pc-160025422.html) y [La arquitectura de Stray](https://journals.ed.ac.uk/ear/article/view/8958).
