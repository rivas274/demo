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

## Recursos visuales

Todos en `siete-vidas/arte/felipe/` y en la ficha de concepto (`siete-vidas/concepto/felipe-concepto.html`): sprite base, animaciones (quieto, caminar, correr, zarpazo, comer, saltar, ronronear, desmayo), poses de caída (en picada con las delanteras estiradas y contacto con las delanteras), pose agachada y animación de gatear, formas de peso (Flaco y Gordito por código, Modo Buda propio), Collar de la Vergüenza y 9 retratos para diálogos.

## Reglas de movimiento

- **Al bajar, las patas delanteras van primero y tocan el piso primero.** Secuencia del salto: sube estirado, arriba recoge las patas, cae en picada con las delanteras estiradas (pose "caer" 0), toca con las delanteras (pose "caer" 1), baja la parte de atrás y se aplasta.
- El doble salto lleva solo una inclinación leve (~20°); la vuelta completa se descartó por exagerada.
- **Agacharse (2026-10-18):** S, ↓ o palanca abajo. Agachado gatea más lento (55 px/s) y su caja de colisión baja de 52 a 28 px, así que cabe bajo muebles con 30 cm libres (36 px). Bajo un mueble no se para aunque se suelte el botón. Agachado + saltar sobre un mueble que se atraviesa desde abajo (repisas, mesa) lo hace bajar a través de él. Animación "gatear" propia (SpriteCook): agachado y quieto usa su primer cuadro; al bajar se aplasta y al pararse se estira (código).
- **Botón de acción (2026-10-18):** E o Y del mando. Interactúa con el objeto más cercano (hasta 48 px de lado y 40 px de alto); si es comida, se la come. Sin un objeto cerca no hace nada. Ya no existe un botón de comer suelto.

## Formas de peso

| Forma | Silueta |
| --- | --- |
| Flaco | Cuerpo más alargado, patas un poco más largas |
| Normal | Silueta base |
| Gordito | Cuerpo más ancho, panza que cuelga |
| Modo Buda | Casi una esfera; patas apenas visibles |

## Animaciones mínimas (primer prototipo)

Quieto (respirando, mueve la cola), caminar, correr, saltar, caer, aterrizar, zarpazo, comer snack, ronronear, recibir daño. Cada una de 6 a 8 cuadros, con estiramiento y aplastamiento de caricatura.

## Historial de pruebas

| Versión | Fecha | Resultado |
| --- | --- | --- |
| v1 | 2026-10-17 | Hoja con 4 estilos (32-bit, 16-bit, Chibi, Cel-shaded) sin foto de referencia. Archivo: `siete-vidas/arte/referencias/felipe-prueba-estilos-v1.png`. Al creador le gustó Cel-shaded y a su novia Chibi; se decidió el híbrido. |
| v2 | 2026-10-17 | Estilo híbrido con la foto real como referencia y v1 como guía de estilo; dos versiones en una imagen (8 créditos). A: muy Chibi, cabeza grande, cuerpo redondo. B: cuerpo más largo, sombreado más marcado. Archivo: `siete-vidas/arte/referencias/felipe-hibrido-v2.png`. **Elegida la A** por el creador y su novia. |
