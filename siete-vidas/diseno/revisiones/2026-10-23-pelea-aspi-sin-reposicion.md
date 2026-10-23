# Revisión de diseño: la pelea con A.S.P.I. sin reposición mágica (2026-10-23)

Pedido del creador: la pelea con A.S.P.I. es **el gancho del juego** («de ahí depende que las personas sigan o abandonen»). Lo que no le convence: lo que Felipe rompe **vuelve a aparecer en su lugar cada 6 s** (`BatallaAspi._reponer`, `REPOSICION`). Rompe la inmersión: reaparece por arte de magia.

Plan aprobado: **A (la base)** tumbar y que quede donde cae, con más fuentes de desorden; **B (el complemento)** A.S.P.I. devuelve la suciedad como una montaña de pelusa al final de cada fase.

Estado: **aplicado** (ver «Qué se hizo» al final).

## 1. Qué cambia

| Antes | Ahora |
| --- | --- |
| Lo roto vuelve entero a su lugar cada 6 s | **Nada reaparece.** Lo que cae queda en el piso como desorden (tierra, la planta, libros, café, papeles, pedazos del vaso) hasta el final |
| 6 cosas para tirar + papeles infinitos del teclado (uno cada 4 s) | **11 fuentes, 14 manchas** repartidas en las dos islas; el teclado suelta **2** apuntes y se acaba |
| El soplido tiraba las macetas «sin romperse» y desaparecían hasta reponerlas | El soplido las tira y **se rompen** donde caen (A.S.P.I. se ensucia sola) |
| Al apagarla, las manchas del piso desaparecían | Las manchas que quedan en el piso **siguen ahí** en la fase siguiente |
| Si nadie la apagaba a tiempo, «vaciaba el depósito» (se esfumaba) | **Lo vacía en el piso:** escupe una montaña de pelusa con todo lo que tenía |
| Al apagarla, nada | **¡BLORP!** Se le abre la tapa y escupe una **montaña de pelusa** (2 manchas). Felipe: «Devolución aceptada.» |
| Al perder una vida, se borraban las manchas y el depósito | Las manchas, la montaña y el depósito **se conservan**; A.S.P.I. vuelve a su base y espera |
| Al ganar, todo «vuelve a la normalidad» (incluido el estudio) | La **imaginación** vuelve a la normalidad; el **estudio queda destruido** como trofeo y Felipe lo comenta con orgullo |

### Verbo nuevo de la acción (E): Esparcir
Junto a la montaña de pelusa, la burbuja dice **«Esparcir»**: el mismo manotazo de siempre la deshace en una nube (¡FUP!) y quedan **2 motas de pelusa** en el piso, que cuentan como manchas. No es una acción nueva de Felipe, es la acción de siempre con otro objeto (como «Liberar», «Firmar» o «Desordenar»), así que se anota en la fila de la acción en la tabla «Acciones de Felipe». Lo mismo con **«Despegar»** (el corcho) y **«Desordenar»** (el librero).

## 2. Fuentes de desorden (14 manchas, 11 fuentes, todo con arte que ya existía)

Medidas en el mundo (`Nivel1`); el estudio va de x 6820 a 7756, `SUELO` = línea de apoyo.

| # | Fuente | Isla | Dónde | Manchas | Arte | Cómo se tira | Qué queda en el piso |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Vaso | Izq. | Escritorio, x 7095 | 1 | `vaso` (ya estaba) | Liberar | Charco y esquirlas |
| 2 | Taza de café | Izq. | Escritorio, x 7197 | 1 | `taza` (ya estaba) | Liberar | Café y 3 pedazos |
| 3 | Apuntes del teclado | Izq. | Teclado, x 7120–7172 | **2** (antes infinitos) | `papel` (ya estaba) | Pisar el teclado (secreta) | Papel en el piso |
| 4 | Notas del corcho | Izq. | Pizarra, x 7236–7356, se alcanza desde la punta derecha del escritorio | **2** (la rosa, después la amarilla) | Recortes de `pizarra`; la pizarra sin la nota se arma de la misma imagen (`preparar_arte_nivel.py desorden`) | **Despegar** | Nota en el piso |
| 5–6 | 2 macetas | Izq. | Repisa de las macetas (1,40 m) | 2 | `maceta` (ya estaba) | Liberar | Tierra, planta y pedazos |
| 7 | Libros de la repisa del gato | Centro | Repisa del gato (1,14 m), x 7396 | 1 | `libros_pila` (2 libros de `objetos.png`, el de abajo en otro tono) | Liberar | 2 libros tirados |
| 8 | Libros de la mudanza | Der. | Sobre la caja de los libros, x 7424 | 1 | `libros_pila_b` (otra combinación de tonos: no es un clon) | Liberar | 2 libros tirados |
| 9 | Libros del librero bajo | Der. | Estante de arriba, se alcanza desde la caja o el librero | **2** | Recortes del mismo `librero_bajo` (el estante con el hueco se arma de la imagen) y `libro` | **Desordenar** | Libro en el piso |
| 10 | Planta | Der. | Librero bajo | 1 | `planta` (ya estaba) | Liberar | Tierra, hojas y pedazos |
| 11 | Portarretratos | Der. | Librero bajo | 1 | `portarretratos` (ya estaba) | Liberar | El retrato en el piso |

Reparto: **izquierda 8, centro 1, derecha 5**. Nada nuevo con lado menor bajo 24 px (R8): las pilas de libros miden 42 × 24, la montaña 68 × 26; el corcho y el librero se marcan enteros con el contorno de la pieza que sigue (región del arte).

Objetos que no entraron: **portalápices** (no hay arte; el escritorio ya tiene vaso, taza, laptop y teclado: lección 30, recargar) e **impresora** (se quitó en la pasada única; los apuntes salen del teclado).

## 3. Cuenta de munición por fase

Pide **2 / 3 / 3** manchas (8). La montaña devuelve **2** al terminar las fases 1 y 2 (dato `DatosJefe.devuelve`).

| Fase | Pide | Lo mínimo que hay que tirar | Lo que hay disponible en el peor caso |
| --- | --- | --- | --- |
| 1 | 2 | 2 | 14 manchas de fuentes |
| 2 | 3 | 1 (+2 de la montaña) | ≥ 12 de fuentes + 2 de pelusa + lo que quedó en el piso |
| 3 | 3 | 1 (+2 de la montaña) | ≥ 11 de fuentes + 2 de pelusa + lo que quedó en el piso |
| Total | 8 | **4** | **14 + 4 de pelusa = 18** (más del doble, 225 %) |

**Por qué nunca se acaba (ley de conservación):** la suciedad no desaparece nunca, solo cambia de lugar: fuentes → piso → depósito → montaña → piso. Lo único que la consume es apagarla (de lo que tragó devuelve 2 de 2 en la fase 1 y 2 de 3 en la fase 2). Por eso:

- **Si nadie la apaga a tiempo**, vacía el depósito **en el piso** (montaña con todo lo que tenía): no se pierde nada, se puede fallar infinitas veces.
- **Al perder una vida**, se conservan las manchas, la montaña y el depósito. Al volver, sigue igual que antes: A.S.P.I. vuelve a su base y la pelea retoma la fase.
- La suciedad total mínima al empezar la fase 3 es 14 − 1 = 13 unidades contra 3 que pide. Aun tirando todo en la fase 1, lo que no limpió sigue en el piso.

`prueba_jefe` lo comprueba: ningún objeto reaparece; la suma «fuentes + piso + depósito + montañas» nunca baja salvo al apagarla; con todas las fuentes ya gastadas se puede terminar la pelea solo con la pelusa (peor caso); y al perder una vida en cada fase se sigue ganando.

## 4. Textos (claves en `traducciones/textos.csv`)

| Clave | Texto | Cuándo |
| --- | --- | --- |
| `PALABRA_BLORP` | ¡BLORP! | Escupe la montaña (zona D, sobre ella) |
| `PALABRA_FUP` | ¡FUP! | Felipe esparce la montaña |
| `VERBO_ESPARCIR` | Esparcir | Burbuja junto a la montaña |
| `VERBO_DESPEGAR` | Despegar | Burbuja junto al corcho |
| `FELIPE_DEVOLUCION_1` | Devolución aceptada. | La primera montaña |
| `FELIPE_DEVOLUCION_2` | ¿Me lo devuelves? Qué detalle. | Las siguientes (sin repetirse seguido) |
| `FELIPE_ESTUDIO_DESTRUIDO_1` | Estudio redecorado. Estilo: Su Majestad. | Al final, después de lamerse la pata |
| `JEFE_LO_VACIO` | ¡LO VACIÓ EN EL PISO! | Cartel cuando nadie la apagó a tiempo |

## 5. Contra los pilares

| Pilar | Cómo cumple |
| --- | --- |
| 1. Un barrio que se descubre | El estudio cuenta su historia con lo que queda: Valeria que lee (libros), teletrabaja (apuntes, notas) y se mudó hace poco (caja). Al final, el cuarto destruido es el relato de la pelea, sin texto |
| 2. Cada maña es llave y travesura | Tirar es la llave de la pelea y además destruye el estudio de Valeria. La montaña convierte la limpieza de A.S.P.I. en munición: la travesura se recicla |
| 3. Siempre te sales con la suya | No hay forma de quedarse sin munición ni de perder lo hecho al perder una vida. Fallar la apagada no castiga: la suciedad vuelve al piso |
| 4. Peso | Sin cambios (snacks fijos en la pelea) |
| 5. Épico en su cabeza | ¡BLORP!, nube, la tapa que se abre y «Devolución aceptada.»; el final con el estudio destruido como trofeo y Felipe orgulloso |

## 6. Contra las reglas de niveles (R1–R19)

| Regla | Cómo cumple |
| --- | --- |
| R1 Enseñar → probar → girar | Tirar se enseñó en la sala; la fase 1 lo pone a prueba; el giro es la montaña: lo limpiado vuelve y se esparce |
| R2 Enseñar sin peligro | Sin cambios (las frases del estudio ya cumplían) |
| R3 Mostrar antes que decir | La montaña se lee sola (¡BLORP!, nube, burbuja «Esparcir»); no hay aviso nuevo. Felipe la comenta |
| R4 Meta a la vista | Sin cambios |
| R5 Descanso cerca | Cojín del pasillo, sin cambios. Al volver no se pierde nada |
| R6 Atajos | Sin cambios |
| R7 Verticalidad | Más motivos para subir: corcho desde el escritorio, libros desde la caja y la repisa del gato |
| R8 Escala y huecos | Todo lo nuevo interactuable ≥ 24 px de lado menor (pilas 42 × 24, montaña 68 × 26); nada nuevo con colisión: lo caído es decorado y no estorba. `prueba_reglas_nivel` lo mide |
| R9 Hito por zona | Sin cambios |
| R10 Exploración | Sin cambios |
| R11 Ritmo | Sin cambios; el «reinicio» de 1,5 s tras cada fase coincide con el ¡BLORP! (pausa con algo que mirar) |
| R12 El jefe es un examen | Tirar, agacharse, muebles como escalera (ahora en las dos islas y el centro), saltar. ≥ 3 cosas para tirar: 11 |
| R13 Con qué jugar | Más que antes |
| R14 Lectura clara | Lo caído va en el piso con sombra; las manchas que A.S.P.I. limpiará se distinguen (mancha, papel, pelusa) del desorden que queda (charco, pedazos, libros). Se revisa con capturas |
| R15 Felipe se ve igual | Sin animaciones nuevas (el manotazo de siempre) |
| R16 El jefe se presenta | `PresentacionJefe` sin cambios. «Al ganar todo vuelve a la normalidad» sigue siendo cierto para la **imaginación**; el estudio real queda destruido (es lo que pasó de verdad) |
| R17–R19 | Sin cambios; R19 se refuerza (tirar abre la pelea y molesta a Valeria) |

## 7. Contra las lecciones de arte (`06-lecciones-arte.md`)

- **4 / 29 / 34 (flotar, apoyar en el centro):** las pilas se apoyan en el medio de la cara de arriba de la repisa (sube 6 px, como las macetas) y de la caja; se revisa en capturas ampliadas.
- **5 / R8 (lado menor ≥ 24):** cumplido.
- **13 (cada objeto en su cuarto):** libros, apuntes, notas y café son de Valeria que teletrabaja y lee.
- **16 / 22 (sombra en el piso):** los pedazos, libros, notas y la montaña llevan sombra de contacto de 2 px.
- **20 (clones):** las dos pilas usan tonos distintos; los libros del librero salen de su propio estante.
- **30 (cada objeto se gana su lugar):** ningún objeto nuevo sin función: todos son munición y cuentan algo.
- **32 (código junto al arte):** nada dibujado por código; todo es arte de Gemini recortado o recombinado.
- **38 (zonas de texto):** ¡BLORP! y ¡FUP! son palabras del mundo (zona D, una a la vez); «Devolución aceptada.» va al diálogo; el cartel «¡LO VACIÓ EN EL PISO!» a la zona C.
- **42 (lo roto deja su marca):** ahora se cumple siempre: nada se borra.

## 8. Juegos de referencia (escalar 3 fases con recursos limitados)

| Juego | Qué hace | Qué tomamos |
| --- | --- | --- |
| **Super Mario Bros. 2 (Birdo)** | El jefe escupe los huevos que el jugador le devuelve | **El jefe trae su propia munición:** la montaña de pelusa es el huevo de Birdo |
| **Cuphead** | Los objetos rosados para el «parry» los genera la pelea; las fases suben la presión, no la escasez | La munición nunca es el límite; la dificultad sube con ataques (soplido, bolas) y con limpiar más rápido |
| **Hollow Knight** | El alma (para curarse) se recarga golpeando al jefe; morir no borra lo aprendido | El recurso sale de la pelea misma; perder una vida no borra el progreso de la fase |
| **Untitled Goose Game** | Lo que el ganso tira queda tirado; el mundo recuerda el desorden | **El desorden persiste** y cuenta la historia del caos al final |
| **Celeste** | Reaparecer es inmediato y sin castigo | Al volver del cojín, todo sigue como estaba |

## 9. Crítica desde el jugador (diversión, ritmo, claridad)

No se pudo lanzar el agente `disenador-juego` desde esta sesión (no hay herramienta para lanzar agentes). Crítica hecha a mano, con su misma pauta (2 a 4 opciones con recomendación), honesta:

1. **Riesgo: la fase 3 se gana sola si la montaña devuelve 3.** Con 3 motas en el piso, A.S.P.I. se llena sin que el jugador tire nada y el clímax se vuelve esperar. **Opciones:** (a) devuelve todo lo que tragó (2 y 3); (b) devuelve siempre 2; (c) devuelve 1. **Recomendación: (b)**, cada fase pide tirar al menos una cosa y la montaña es ayuda, no el todo. **Aplicado.**
2. **Riesgo: si el jugador tira todo en la fase 1, las fases 2 y 3 son solo pelusa.** Está bien que pueda hacerlo (es su travesura), y la pelusa y las manchas que quedan alcanzan. No se limita.
3. **Claridad: ¿qué limpia A.S.P.I. y qué queda?** Si los charcos quedan pero «ya los limpió», puede confundir. **Opciones:** (a) borrar el charco al limpiar; (b) dejar el charco y que la mancha que limpia se vea distinta encima (mancha oscura, papel o pelusa) con la anticipación del cepillo; **Recomendación: (b)**, la mancha que va a limpiar es la que se mueve (el viento de la succión la arrastra) y el desorden de fondo queda como trofeo. Se revisa en el video.
4. **Ritmo: el ¡BLORP! no debe pisar al ¡CLIC!.** El ¡CLIC! dura 1,3 s; la montaña sale a los 0,7 s del apagado, cuando A.S.P.I. ya cayó, y la palabra espera su turno (una palabra a la vez). **Aplicado:** la montaña sale en el reinicio.
5. **Diversión: esparcir con un manotazo es poco.** Es la misma pata de siempre (pilar 5: lo pequeño se siente enorme): nube grande, motas que vuelan en arco, sacudida leve y ¡FUP!. Bien para el slice; si en la prueba de juego se siente plano, dar la opción de esparcirla con el zarpazo (J) también.
6. **Peor caso que se buscó y no existe:** quedarse sin nada que tirar. La conservación lo impide; la prueba lo fuerza (todas las fuentes gastadas, sin nada en el piso).

## 10. Qué se hizo (2026-10-23)

- **Juego:** se quitó `REPOSICION`, `_reponer`, `Tirable.reponer` y la caída «sin romper». Pieza nueva `FuenteDesorden` (corcho, librero; datos `DatosFuente` en `datos/fuentes/`), entidad `MontanaPelusa` (cuántas motas: `DatosJefe.devuelve`), `DesordenEstudio` (corcho, librero y teclado), dos pilas de libros (`datos/objetos/libros_pila*.tres`), apuntes finitos (`Nivel1.APUNTES_TECLADO`), mancha «pelusa», sombra en lo que queda en el piso y la frase final. Arte recombinado con `preparar_arte_nivel.py desorden` (0 créditos).
- **Pruebas:** ver `prueba_jefe.gd` (conservación, nada reaparece, montaña, peor caso, perder una vida por fase), `prueba_componentes.gd` (`FuenteDesorden`, `MontanaPelusa`), `prueba_reglas_nivel.gd` (R8 de lo nuevo) y el bot `partida.gd` (esparce la montaña y usa las fuentes nuevas).
- **Encargo opcional a Gemini (no hace falta para jugar):** «un libro abierto caído en el piso, boca abajo con las hojas abiertas, y una hoja suelta, pixel art del mismo estilo que `objetos.png`, sobre fondo blanco, 2 variantes de color de tapa (rojo y verde oscuro)». Hoy los libros caen cerrados.
