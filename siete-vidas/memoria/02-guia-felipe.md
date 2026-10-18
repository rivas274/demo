# Guía del personaje: Felipe

Estado: **diseño aprobado: versión A del híbrido v2** (muy Chibi, cabeza grande, cuerpo redondo, vista 3/4). Sprite base sin fondo: `siete-vidas/arte/felipe/felipe-A-base.png` (86×94 px).

## Identidad

- **Nombre:** Felipe Ron con Pasas ("como el sabor de helado que nadie pide").
- **Cómo exige que lo llamen:** Su Majestad Felipe Ron con Pasas I, el Magnífico.
- **Apodo de Valeria:** Pipe. Otras casas le dicen "Michi" o "Don Gato".
- **Personalidad:** ego de rey egipcio, cero cardio, egoísta, sarcástico, secretamente leal a Valeria.
- **Voz:** aristócrata ofendido que aprendió a escribir en los comentarios de internet. Sin actor de voz: maullidos procesados y texto.

## Referencia real

El diseño se basa en el gato real del creador (fotos en la conversación original; no están en el repositorio). Rasgos que deben respetarse siempre:

| Zona | Rasgo |
| --- | --- |
| Pelaje base | Blanco en pecho, vientre, patas, hocico y cara |
| Manchas | Atigrado gris-café con rayas oscuras en el lomo (como una montura) y en la cola |
| Cabeza | "Gorra" o casco atigrado que cubre las orejas y la parte alta de la frente, con una **franja blanca** que baja por el centro de la frente |
| Orejas | Atigradas por fuera, rosadas por dentro |
| Ojos | Verde avellana, párpados a media asta; mirada de reojo, entre desconfiada y ofendida |
| Nariz | Rosada |
| Pelo | Largo y esponjoso; lo hace ver más grande de lo que es |
| Cola | Grande, peluda, atigrada |
| Objeto de apego | Un peluche verde con cara (aparece en la base) |

## Estilo aprobado

- **Proporciones Chibi:** cabeza grande (aprox. 40 % de la altura), cuerpo compacto y redondo, patas cortas. La cara es el centro de la comedia.
- **Acabado Cel-shaded:** sombras planas en 2 tonos por color, contorno oscuro marcado (no negro puro), sin degradados.
- **Solo los gatos son Chibi.** Los humanos usan proporciones normales, en Cel-shaded, y miden **3 Felipes** (Valeria, 1,65 m).
- **Felipe es un gato grande:** el real es un persa de pelo largo de unos 8 kilos; es grande, no obeso. En el juego debe sentirse así: llega casi a la altura de una mesa de comedor.
- **Tamaño en juego (aprobado el 2026-10-18):** resolución base 640×360; Felipe mide **67 px de alto** (las hojas de 106 px se dibujan al 72 %). El mundo va a 1,21 px por cm, así que Felipe "mide" unos 55 cm con la cabeza. Se descartaron el tamaño real (Valeria = 4,3 Felipes, 46 px: parecía un gatito) y la regla anterior del doble (Valeria = 2 Felipes, 100 px: casa de muñecas). Comparación: `siete-vidas/arte/referencias/proporciones-felipe.png`.

## Paleta propuesta (a validar con el diseño generado)

| Uso | Color |
| --- | --- |
| Blanco pelaje | `#F3EFE8` |
| Sombra blanco | `#CFC6BB` |
| Atigrado | `#8B7864` |
| Rayas / sombra atigrado | `#5B4D41` |
| Rosa (nariz, orejas) | `#E59AA2` |
| Ojos | `#A3B06A` |
| Pupila | `#1B1714` |
| Contorno | `#241C1A` |

## Expresiones necesarias

1. **Por defecto:** reojo con párpados a media asta ("no me impresionas").
2. **Ofendido:** orejas hacia atrás, ojos entrecerrados.
3. **Sorprendido:** ojos redondos, pelo erizado (pepinos, aspiradora).
4. **Satisfecho:** ojos cerrados, sonrisa leve (comiendo, ronroneando).
5. **Enamorado:** ojos brillantes (Duquesa), pero intenta disimular.
6. **Furioso:** bufido, pelo erizado, cola esponjada.

## Acciones de Felipe

Lista oficial (la misma de la ficha de concepto). Toda acción nueva se agrega aquí y en la ficha. Los nombres de animación son los de Godot (`AnimacionesFelipe.HOJAS`).

| Acción | E | Y | Usa el objeto más cercano (hasta 48 px de lado y 40 px de alto): si es comida se la come (cura 1 corazón y suma 0,3 kg); si es el vaso, lo tira de un manotazo (logro "La Gravedad Funciona"); sin objeto no hace nada. No hay botón de comer suelto | `comer`, `zarpazo` (manotazo) | En el juego |
| --- | --- | --- | --- | --- | --- |
| Quieto | — | — | Respira y mece la cola | `quieto` | En el juego |
| Caminar | A / D o ← / → | Palanca izquierda o cruceta | 120 px/s | `caminar` | En el juego |
| Correr | Mantener Shift | Mantener RB | 190 px/s | `correr` | En el juego |
| Zoomies | Tocar Shift | Tocar RB | Impulso de 380 px/s durante 0,18 s con estela; espera de 0,45 s | `correr` + estirón | En el juego |
| Saltar | Espacio | A | ~79 px; soltar corta el salto; margen de 0,1 s al salir de un borde; salto recordado de 0,12 s | `saltar` (cuadros 1, 2, 3) | En el juego |
| Doble Salto | Espacio en el aire | A en el aire | ~140 px en total; inclinación leve (~20°); se recupera al tocar el piso | `saltar` (cuadro 3) | En el juego |
| Caer y aterrizar | — | — | Delanteras primero: cae en picada, toca con las delanteras, baja la parte de atrás y se aplasta, con polvo | `caer` 3 (cayendo) y 5 (contacto), `saltar` 5 y 6 | En el juego |
| Agacharse y gatear | S o ↓ | Palanca abajo o cruceta abajo | Transición dibujada al bajar y al pararse (al revés); gatea a 55 px/s con la panza al piso y patas alternadas; colisión de 32 px (de pie, 58); cabe bajo muebles con 30 cm libres (36 px); bajo un mueble no se para aunque se suelte el botón | `agacharse` (cuadros 0 a 3 de la hoja), `gatear` (4 a 7) | En el juego |
| Trepar | W o ↑ (en una cortina) | Palanca o cruceta arriba | Sube a 90 px/s y baja con abajo; saltar lo suelta; al llegar arriba da un saltito para pasar al otro lado | Provisional: `saltar` cuadro 2 (falta animación propia desde Felipe A) | En el juego |
| Pausa | Esc | Start | Pausa con continuar, reiniciar (R) y salir (Q) | — | En el juego |
| Bajar de una repisa | S + Espacio | Abajo + A | Atraviesa hacia abajo los muebles que se atraviesan desde abajo (repisas, mesa, estantes) | — | En el juego |
| Zarpazo | J | X | Ataque con la pata: golpea a los enemigos enfrente (hasta 56 px). El ratón de cuerda cae de 1, A.S.P.I. con 3; rompe cajas de cartón | `zarpazo` | En el juego |
| Acción | E | Y | Usa el objeto más cercano (hasta 48 px de lado y 40 px de alto); si es comida, se la come; sin objeto no hace nada. No hay botón de comer suelto | `comer` (con comida) | En el juego |
| Ronronear | — | — | Con humanos, sube el afecto | `ronronear` | Animación lista; falta la mecánica |
| Recibir daño | — | — | Quita 1 de 5 corazones, lo empuja lejos del golpe y queda 1,2 s invulnerable, parpadeando | Efecto de código | En el juego |
| Perder una vida | — | — | Sin corazones se desmaya, una de sus 7 vidas sube como fantasma y a los 1,8 s reaparece en el punto de descanso con los corazones llenos. Sin vidas, vuelven las 7 con el Collar de la Vergüenza | `desmayo` + código | En el juego |
| Peso | — | — | Empieza en 8,0 kg; cada comida suma 0,3 kg. No cambia el dibujo: báscula con aguja en la interfaz y el humor de Felipe según los kilos: Atlético (< 8,5), Esponjoso (< 9,5), Modo Invierno (< 11), Modo Buda | — | En el juego (indicador) |
| Ocio | Nada durante 8 s (`espera_ocio`) | — | Elige al azar: sentarse y acicalarse, jugar con estambre o perseguirse la cola; repite el ciclo 2 o 3 veces y vuelve a quieto; cualquier botón lo interrumpe | `acicalarse` (de pie), `jugar` (+ bola de estambre por código), `vueltas` | En el juego |

## Proporciones medidas (Felipe A, cuadro de 106 px)

| Medida | En la hoja (106 px) | En el juego (×0.72) |
| --- | --- | --- |
| Punta de la cola | fila 12 | — |
| Cabeza (orejas a barbilla) | filas 25 a 70: 45 px de alto, 55 de ancho | 32 × 40 px |
| Orejas a patas | filas 25 a 105: 80 px | 58 px |
| Con la cola | 93 px | 67 px |
| Agachado (orejas a patas) | 46 px | 33 px |
| Cabeza / altura | 56 % | 56 % |

Todas las animaciones deben respetar estas medidas: misma hoja de 106 px, misma escala, deformación máxima ±8 %.

## Consistencia

Felipe es siempre el mismo gato: vista 3/4 como Felipe A, cabeza cerca del 40 % de la altura, rasgos de la tabla de arriba y reojo por defecto. Las animaciones se generan directamente desde Felipe A (ver `CLAUDE.md`). Desde el 2026-10-18 todas las animaciones salen de Felipe A y cumplen (lo comprueba la prueba de movimiento).

## Reglas de movimiento

- **Al bajar, las patas delanteras van primero y tocan el piso primero.** Inclinar una pose de pie no basta: se usan los cuadros 3 (inclinado con la nariz hacia abajo) y 5 (contacto) de la animación "caer", hecha desde Felipe A. La prueba del juego mide que el punto más bajo del dibujo esté del lado al que mira Felipe.
- El Doble Salto lleva solo una inclinación leve (~20°).
- Toda corrección de animación aprobada en la ficha se aplica también en el juego y queda cubierta por una prueba.

## Recursos visuales

Todos en `siete-vidas/arte/felipe/` y en la ficha de concepto (`siete-vidas/concepto/felipe-concepto.html`). La lista de archivos, ids de SpriteCook y costos está en `03-arte-y-herramientas.md` (Assets de Felipe).

## Peso

El peso **no cambia el dibujo de Felipe** (decisión del 2026-10-18): con 8 cuadros por animación no se pueden hacer todas las animaciones en varias formas. Se muestra como un indicador arriba, junto a la barra de vida. Las formas Flaco, Gordito y Modo Buda dibujadas se descartaron.
