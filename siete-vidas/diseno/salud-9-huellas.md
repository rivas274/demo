# Salud: las 9 huellas (propuesta de diseño)

Actualizado: 2026-10-23. **Estado: propuesta.** Decide el creador. No se tocó el código.

Parte de la decisión cerrada en `interfaz-v2.md` («Decisiones cerradas por el creador», punto 3): **las 9 vidas del título son la salud**. Hay 9 huellas y ningún contador aparte. La huella tiene 5 estados: llena, media, vacía, golpe y curando.

## Qué hay hoy en el juego (leído en el código)

| Pieza | Hoy |
| --- | --- |
| `Vida` de Felipe | `maximo = 5` (corazones, `Felipe.CORAZONES_MAX`). Cuenta en enteros |
| Golpe | `HaceDano.dano = 1` en todo: el roce de A.S.P.I. al embestir, la bola de pelo y los ratones de cuerda. Empuja 220 px/s y deja **1,2 s** invulnerable, parpadeando (`TIEMPO_INVULNERABLE`) |
| Curación | Comer (plato o snack del bolsillo) cura 1 y suma 0,3 kg. El snack se come manteniendo la acción 0,6 s, quieto. El bolsillo guarda 5 y empieza con 3 |
| Descanso (caja de arena, cojín) | Marca dónde reaparece y rellena el bolsillo hasta 3 snacks. **No cura** |
| A 0 | `EstadoDesmayado`: resta 1 de las 9 `vidas`, un gatito fantasma sube, y a los 1,8 s reaparece en el último descanso con todo lleno. Con 0 vidas, vuelven las 9 y se pone el Collar de la Vergüenza |
| Pelea con A.S.P.I. | Al volver, la entrada dura 1 s y **se conserva todo**: fase, manchas, pelusa y depósito. El cojín está junto a la puerta del estudio |
| Pelea, números | Embestida: aviso de 0,5 s y espera de 2,4, 2,0 y 1,7 s según la fase. Bola de pelo desde la fase 2: cada 3,4 s, con 0,5 s de aviso. El soplido y la succión empujan, no lastiman. El bot gana en unos 57 s y termina con 1 a 5 corazones (recibe de 0 a 4 golpes) |

Hoy Felipe aguanta 5 golpes por vida, 45 en total antes del Collar. Con 9 huellas, el colchón queda en **9 golpes**. Eso es casi el doble de un tramo de hoy, pero solo una quinta parte del total.

## Lo que tomamos de los juegos de referencia

Son recuerdos de juego. Conviene verificarlos antes de citarlos afuera.

| Juego | Cómo lo resuelve | Qué tomamos | Qué no |
| --- | --- | --- | --- |
| Hollow Knight | Máscaras enteras; casi todo quita 1 y lo fuerte de más adelante quita 2. Curar (Focus) te deja quieto. El banco llena todo | **Unidades enteras y legibles**, curar quieto como riesgo elegido (ya es nuestro snack), **el descanso llena todo**. El daño por ataque como perilla para jefes futuros | Perder el dinero al morir y la Sombra que hay que ir a buscar |
| Celeste | Sin vida: morir es instantáneo y reapareces en la entrada de la pantalla en un segundo. Cuenta las muertes con orgullo. Su Modo Asistido (invencible, más lento) no juzga | **Morir cuesta segundos.** El contador de desmayos como chiste en el resumen del día. **La asistencia sin culpa** | La muerte de un toque |
| Shovel Knight | La comida de las paredes cura. Al morir pierdes oro en bolsas que puedes recuperar | La comida que cura y se encuentra en el escenario (ya está: el plato) | La pérdida al morir |
| Cuphead | 3 puntos de vida, sin curación. Morir reinicia la pelea y te muestra cuánto te faltaba | Que el jefe se burle al vencerte (en nuestro caso, A.S.P.I. dice una frase) | Reiniciar la pelea desde cero; tan pocos golpes |
| Kirby | Barra generosa y mucha comida que cura. El tono es amable | **Ser generoso con la comida** y que perder sea poco común | — |
| Pizza Tower | No hay vida: el golpe te cuesta ritmo y puntos, y Peppino reacciona de forma exagerada | **El golpe como chiste visual** (la cara de Felipe en el HUD reacciona) y que el castigo sea de ritmo, no de progreso | — |

---

## 1. Golpes: cuánto quita cada uno

Pilares: 3 (Siempre te sales con la suya) y el anti-pilar «no castiga». · **Qué siente el jugador:** «me pegaron y entiendo por qué». Ve una huella que se rompe y sabe cuántas le quedan sin contar.

**Opción A: 1 huella por golpe, siempre.** Nueve golpes y te desmayas. Se lee de inmediato: una huella es un golpe.
- A favor: es lo más claro y se parece a Hollow Knight.
- En contra: el estado «media» de la huella no se usaría en el juego normal.
- Costo: cambiar `CORAZONES_MAX` a 9. Sin arte ni animación.

**Opción B: ½ huella por golpe.** Aguanta 18 golpes.
- A favor: usa el estado «media».
- En contra: el jugador tiene que contar medias. Con 18 golpes la pelea casi no tiene tensión.
- Costo: `Vida` en medias (`maximo = 18`).

**Opción C: depende del ataque.** El roce y los ratones quitan ½. La embestida y la bola de pelo, que se anuncian, quitan 1.
- A favor: premia leer el aviso.
- En contra: en el primer jefe hay dos reglas a la vez, y cuesta saber por qué quitó media o una entera.
- Costo: `Vida` en medias y un `dano` distinto en cada `HaceDano`.

**Opción D: el peso amortigua (pilar 4).** Desde unos 9,5 kg, cada golpe quita ½ huella.
- A favor: la barra de «defensa» de la Ficha pasaría a ser verdad.
- En contra: **choca con una decisión cerrada** (2026-10-20: las estadísticas de la Ficha son solo de chiste). Además, engordar haría trivial la pelea.
- Costo: `Vida` en medias más una consulta a `DatosFicha`.

**Recomiendo la A por fuera y medias por dentro.** El jugador ve «1 golpe = 1 huella». El código cuenta en medias (`maximo = 18` y cada golpe quita 2) para que la asistencia y los jefes futuros puedan usar la media sin rehacer `Vida`. Así se cumple el pilar 3: los errores se pagan, pero el pago se entiende al instante.

**Invulnerabilidad:** se mantiene en **1,2 s**, con el parpadeo actual. Es menor que la espera mínima entre embestidas (1,7 s), así que una embestida nunca pega dos veces. Para que el golpe se sienta, sumar al momento del golpe una pausa corta de unos 60 ms, la huella que se agrieta (estado «golpe», 140 a 240 ms) y la cara del HUD con mueca.

**Perillas:** `Felipe.CORAZONES_MAX` (en medias), de 18 a 18; `HaceDano.dano`, de 1 a 4 medias (hoy 2 para todo); `TIEMPO_INVULNERABLE`, de 1,0 a 1,5 s; la pausa del golpe, de 0,04 a 0,08 s.

## 2. Curación

Pilar 4 (Tus decisiones tienen peso). · **Qué siente el jugador:** alivio, y «guardé el snack para esto».

**Opción A: solo snacks (como hoy).** Cada snack devuelve 1 huella.
- A favor: no cambia nada.
- En contra: el descanso no cura. Con 9 huellas, llegar a la pelea con 3 se sentiría injusto.

**Opción B: snacks más un descanso que llena todo.** El snack devuelve 1 huella y el descanso las llena todas, como el banco de Hollow Knight.
- A favor: el cojín junto a la puerta del jefe pasa a significar «aquí estás a salvo» (R5).
- Costo: una línea en `Nivel._physics_process` y el efecto «curando» en cascada (60 ms entre huellas).

**Opción C: la B más el perdón de Valeria.** Cuando Valeria perdona («Encantar»), Felipe recupera 1 huella, una vez por visita.
- A favor: el ciclo del pilar 3 («hacerla, que te pillen, salir con encanto») también cura.
- En contra: hay que revisar que no se pueda abusar de él (ya está limitado a una vez por visita).

**Opción D: la pelusa cura.** No la recomiendo. La pelusa es munición contra A.S.P.I. Si además cura, una misma cosa tiene dos significados.

**Recomiendo la B, y la C si se prueba bien.** Con la B, la decisión del snack (comerlo ya o guardarlo para el jefe) sigue viva, porque el descanso solo cura donde está. Que comer en la pelea deje a Felipe quieto 0,6 s ya es el riesgo elegido de Hollow Knight.

**Pregunta para prototipar:** «¿Que el descanso cure todo le quita valor a guardar snacks?»

**Perillas:** huellas por snack, de 1 a 2 (hoy 1); cuánto llena el descanso (todo o hasta 6); huellas por perdón, de 0 a 1.

## 3. Al llegar a 0 huellas

Pilar 3, pilar 5 (Épico en su cabeza) y el anti-pilar «sin perder lo que llevas». · **Qué siente el jugador:** «eso no contó». Felipe vuelve ofendido, no derrotado.

**Opción A: «Nueve vidas, ninguna se va».** Usa la animación `desmayo` que ya existe.
- Al desmayarse, las 9 huellas suben como 9 gatitos fantasma (el fantasma de hoy, multiplicado).
- A media subida se detienen, se miran entre ellos y vuelven a bajar a Felipe: él no les dio permiso.
- Reaparece en el último descanso con las 9 huellas llenas, mira a la cámara de reojo y salta una frase en su globito, por ejemplo: «Siesta táctica.», «Eso fue a propósito.» o «Tengo nueve. Las uso cuando quiero.» (con claves en `textos.csv`, sin repetir seguido).
- Costo: solo código (tweens) y textos, sin animación nueva.

**Opción B: igual que la A, más el Collar de la Vergüenza en cada desmayo.**
- Reaparece con el collar puesto y se lo quita frotándose con Valeria («Encantar»). Así el desmayo se vuelve una travesura más del ciclo del pilar 3.
- En contra: en el piso de arriba Valeria no oye (audífonos), así que el collar seguiría puesto en la pelea. En el nivel 1 todavía no hay un respeto que bajar, así que hoy sería solo de adorno.

**Opción C: igual que la A, con el Collar solo después de 3 desmayos en el mismo nivel.**
- Conserva la idea de hoy («al acabarse las vidas, el Collar»), con una cuenta corta que se reinicia en cada nivel.
- En contra: es un contador escondido que el jugador no ve.

**Opción D: reaparecer en la entrada de la habitación, como Celeste.** Es más rápido, pero cambia R5 («reaparece en el descanso»), y eso lo decide el creador. En la pelea no hace falta, porque el cojín ya está junto a la puerta.

**Qué se conserva, en todas las opciones:** el desorden y las manchas, la Agenda, los calcetines y las fotos, el peso, el estado de la pelea (como hoy) y los snacks del bolsillo (el descanso, además, rellena hasta 3). No se pierde nada. A.S.P.I. puede decir una frase, al estilo de Cuphead («Gato retirado. Superficie limpia.»). El resumen del día suma una línea de chiste: «Siestas tácticas: 2».

**Recomiendo la A más la C:** fantasmas que vuelven, frase ofendida y el Collar recién al tercer desmayo del nivel. Desmayarse cuesta unos 3 s (1,8 s de desmayo más la entrada de 1 s) y nunca quita lo ganado (anti-pilar «no castiga»). El chiste del título queda en la animación («nueve vidas, cero disculpas»), no en un número.

**Pregunta para prototipar:** «¿La vuelta de los fantasmas se entiende como un chiste o como un error?»

**Perillas:** `TIEMPO_DESMAYO`, de 1,5 a 2,5 s; desmayos antes del Collar, de 1 a 3 (o nunca); duración de la subida de los fantasmas, de 0,8 a 1,4 s.

## 4. La pelea con A.S.P.I.

Pilar 5 y el desafío moderado. · **Qué siente el jugador:** tensión en la fase 3, pero ganarla en el primer o el segundo intento.

**Cuentas con la recomendación** (1 huella por golpe y un descanso que cura):
- Felipe entra con **9 huellas y 3 snacks** (el cojín rellena), o hasta 5 si guardó. Aguanta entre **12 y 14 golpes** antes de desmayarse, si come entre medio.
- **El bot** recibe de 0 a 4 golpes en 57 s: termina con 5 a 9 huellas y nunca se desmaya.
- **Un jugador nuevo** tarda, a ojo, entre 90 y 120 s y recibe entre 6 y 10 golpes. Así le quedan de 0 a 3 huellas o tiene que comer un snack: hay tensión y casi nunca se desmaya.
- En la fase 3 puede venir, como mucho, una embestida cada 1,7 s y una bola cada 3,4 s. Las dos tienen 0,5 s de aviso, así que se esquivan si uno presta atención.

**Opción A: todo quita 1 y no se toca A.S.P.I.** Es lo más simple. Riesgo: que se sienta trivial, si los jugadores terminan con 7 o más huellas.

**Opción B: la embestida quita 2 huellas.** Es el ataque más anunciado (línea roja y pitido de reversa). Un novato podría desmayarse una vez, lo que cuesta unos 3 s y no pierde nada.

**Opción C: aviso de huellas bajas.** Con 3 huellas o menos, las que quedan laten y Felipe dice una vez «Esto es un empate técnico.». Sube la tensión sin subir la dificultad. Se puede sumar a la A o a la B.

**Recomiendo la A más la C, y medir.** El objetivo es que un jugador nuevo termine la pelea con **2 a 5 huellas** y que se desmaye como mucho una vez. Si en la prueba con personas la mayoría termina con 7 o más, se pasa a la B (un solo número: el `dano` de la embestida). El pendiente «ajustar la dificultad de la fase 3 con una persona» queda como esta medición.

**Pregunta para prototipar:** «Con 9 huellas, ¿la fase 3 todavía da nervios?»

**Perillas:** el `dano` de la embestida (2 a 4 medias) y de la bola (1 a 2 medias); el umbral del aviso de huellas bajas (2 a 3); `espera` de la embestida (hoy 2,4, 2,0 y 1,7 s).

## 5. Accesibilidad

Decisión que ya existe (01-decisiones): «modo asistido que no bloquea logros». · **Qué siente el jugador:** «puedo ver el final y el chiste sin pelear contra mis manos».

**Opción A: «Golpes» en la pestaña Accesibilidad,** con tres valores:
- **Normal:** 1 huella por golpe.
- **Suaves:** ½ huella. Aquí se ve el estado «media» de la huella.
- **Ninguno:** el golpe empuja y suena, pero no quita huellas.

Es el Modo Asistido de Celeste, sin juicio y sin bloquear logros. Cuesta un ajuste en `Opciones` y multiplicar el `dano` de Felipe al recibirlo.

**Opción B: lo mismo, más «Invulnerable más tiempo»** (2,4 s en vez de 1,2 s), para quien no ve bien los avisos.

**Opción C: solo «Suaves».** Es la opción mínima.

**Recomiendo la A.** Pilar 3: nadie se queda afuera del chiste. El texto de la opción lo dice Felipe: «Un rey no recibe golpes. Los recibe con elegancia.».

**Perillas:** multiplicador de golpes (1; 0,5; 0); invulnerabilidad en modo asistido (1,2 a 2,4 s).

---

## Costo total de lo recomendado

- **Código:** `Vida` de Felipe en medias (18); `HaceDano.dano = 2` por omisión; el snack cura 2; el descanso llena todo; `EstadoDesmayado` sin `vidas` y con los 9 fantasmas que vuelven, el Collar después de 3 desmayos por nivel y la frase de vuelta; el aviso de huellas bajas; la opción «Golpes». También hay que actualizar `BarraVida` (huellas), `PanelBolsillo` (ya no muestra vidas), las claves `FIN_VIDAS` y las del desmayo en `textos.csv`, y las pruebas que cuentan corazones.
- **Animaciones nuevas:** ninguna (se usan `desmayo` y `quieto`, más tweens). Créditos de SpriteCook: 0.
- **Arte:** la huella en sus 5 estados, que ya está encargada en `interfaz-v2.md`.
- **Al aprobar:** se anotan las decisiones en `01-decisiones.md` y se actualizan las filas «Recibir daño», «Perder una vida» y «Comer un snack» de la tabla **Acciones de Felipe** en la guía y en la ficha (regla de los tres lugares), además de `05-estado-actual.md`.
