# Pelea con A.S.P.I. v5: «Aplastar» y un solo foco a la vez (2026-10-23)

Pedido del creador después de jugar y ver la v4 (`2026-10-23-pelea-aspi-v4.md`). Estado: **aplicado**, 0 créditos, sin animaciones nuevas. Comparación: `capturas/pelea-aspi/v5-ruido-antes-despues.png`.

## 1. Acción nueva «Aplastar» (`AplastarAspi`)

- **Problema:** con tantos muebles cerca, a veces Felipe caía en la silla en vez de sobre A.S.P.I.
- **Receta:** un atajo con el botón de acción, un salto dirigido que siempre llega. Es lo que hacen los juegos con «lock-on» para un golpe clave. El salto manual sigue valiendo.
- **Cuándo:** con A.S.P.I. vulnerable (llena o en corto) y al alcance:
  - en el piso, a 120 px o menos;
  - subido a un mueble del estudio (silla, escritorio, repisa de las macetas, repisa del gato, caja de los libros o librero bajo), a 190 px o menos de lado y hasta 200 px de altura.
- **Prioridad:** `ManasFelipe.objeto_cercano` pregunta primero `prioritario(felipe)`, así que «Aplastar» le gana a tirar, despegar o esparcir.
- **Qué se ve:**
  - El Indicador marca el contorno de A.S.P.I.
  - El aviso amarillo sobre ella dice el botón: **«[E] ¡APLASTA!»** (antes «¡LLENA! ¡SALTA!» y «¡EN CORTO! ¡AHORA!»).
  - Para no tener dos avisos a la vez, el Indicador no repite su burbuja sobre Felipe (`burbuja_propia()`).
  - El aviso se ve cada vez que ella está vulnerable, no solo la primera, porque es el único aviso de ese momento.
- **El salto:**
  - Es el `saltar` de siempre (sonido, estado y animación), sin animación nueva.
  - Su recorrido es un arco de Bézier de 0,3 a 0,55 s que lleva los pies a la tapa aunque ella se corra.
  - Mientras vuela, la colisión se apaga: atraviesa lo que haya en medio, como el soplido o bajar agachado. Al llegar vuelve a chocar con el piso y los muebles sólidos, y los atravesables recién cuando toca el piso.
  - Al 60 % del arco se hace el silencio; al llegar viene el golpe de siempre (`RemateAspi.apagar`: pausa, destello, estrellas, onda, temblor y «¡CLIC!»).
- **Pruebas** (`prueba_aplastar.gd`, nueva):
  - aterriza sobre la tapa (±2 px) y la apaga desde el piso y desde cada uno de los 6 muebles;
  - le gana a la taza o al vaso del escritorio;
  - no se ofrece si ella no está vulnerable o si está lejos.
- **El bot** la usa (`bot_pelea._aplastar`).

## 2. Un solo foco a la vez (`CalmaAspi`)

El creador dijo: «La batalla es confusa, mucho ruido visual». Las referencias son Cuphead y Hollow Knight: el fondo calmado y lo jugable con contraste.

### Qué se quitó o se bajó, y por qué

| Cambio | Antes (v4) | Ahora (v5) | Por qué |
| --- | --- | --- | --- |
| Destello de lo tirable | Todo lo tirable, todo el tiempo | Solo lo que está a 110 px de Felipe | 10 a 14 destellos por la pantalla competían con los avisos. Cerca de Felipe es cuando importa |
| Motas de polvo del rayo de la ventana | 5 motas que suben | Ninguna en la pelea (vuelven al ganar) | Era movimiento que no significaba nada |
| LED de A.S.P.I. en reposo | Parpadea cada 1,1 s | Quieta; solo parpadea con un aviso | Un parpadeo debe querer decir algo |
| Polvo del golpe | 16 granos | 8 | A la mitad (pedido) |
| Lo tirado que brinca | Hasta 130 px | Hasta 65 px | A la mitad (pedido) |
| Onda de choque | 84 px, 3 anillos | 56 px, 2 anillos | Más corta (pedido) |
| Pedazos de lo roto | Todos los de sus datos (3 o 4) | 2 como mucho | Menos piezas sueltas que compitan |
| Restos del piso | Tinte 80 % | Tinte 62 / 56 / 54 % (oscuro y cálido) | Se funden con el piso |
| «+1 · GLUP» | Palabra grande de 16 px | «+1» de 8 px, celeste, sobre los LED, 0,6 s | Los LED ya cuentan |
| «REINICIANDO...» | Texto sobre ella | Solo la barra | Coincidía con el cartel de fase y el «¡BLORP!» |
| Montaña de pelusa | 0,7 s después del «¡CLIC!» | 2,4 s después, cuando ya se fue el cartel | En la v4 coincidían el «¡CLIC!», el cartel, el «¡BLORP!» y el globito; ahora salen en fila |
| Globito de Felipe | Esperaba peligros y el aviso | También espera al cartel de fase | Un texto a la vez |
| Burbuja del Indicador con A.S.P.I. vulnerable | «Aplastar» además del aviso | Solo el aviso «[E] ¡APLASTA!» | Un aviso a la vez |
| Fondo | A todo contraste | Velo del color del cuarto (22 %) sobre pared, cuadros, ventana, corcho y muebles | El decorado baja; Felipe, A.S.P.I., lo tirable y los avisos van delante, a todo color |

**HUD:** se revisó y no tiene nada que parpadee sin motivo. Corazones, agenda, calcetín y barra de la jefa solo cambian cuando cambia el valor. La flecha del borde parpadea porque avisa a A.S.P.I. fuera de pantalla.

### 5 variantes del velo, comparadas a ×1 (`pruebas/capturas_ruido.gd`)

| Variante | Velo | Contraste del fondo (desv. de luminancia, fase 1 / fase 2) | Lectura a ×1 |
| --- | --- | --- | --- |
| v4 | — | 56,5 / 54,7 | Todo compite |
| A | sin velo (solo lo que se quitó) | 55,9 / 55,4 | Menos movimiento, mismo contraste |
| B | 15 %, pared y cuadros | 51,1 / 51,0 | Apenas se nota |
| C | 25 %, pared y cuadros | 48,2 / 48,8 | La pared baja, pero los muebles siguen a todo contraste |
| **D** | **20 %, pared, cuadros y muebles** | **48,0 / 46,7** | **El fondo entero baja y lo jugable resalta** |
| E | 20 %, pared, sin destellos, restos más oscuros | 49,6 / 48,7 | Sin destello no se distingue lo tirable |

**Elegida: D, a 22 %.** Es la que más baja el contraste del fondo sin tapar lo jugable. Los objetos tirables, Felipe y A.S.P.I. van en capas delante del velo.

### Medida: elementos animados a la vez (máximo en 20 cuadros)

| Momento | v4 | v5 |
| --- | --- | --- |
| 1. Fase 1, limpiando el desorden | 9 | 3 |
| 2. Justo después del primer «¡CLIC!» | 13 | 6 |
| 3. Fase 2, llena, con desorden | 9 | 3 |
| 4. Fase 3 (apagón), bola en camino | 7 | 1 |

- **Qué se cuenta:** sistemas de partículas activos, piezas en el aire, palabra, globito, cartel, aviso, barra de reinicio, bolas, motas, LED que parpadea y burbuja del Indicador.
- **Pantalla que cambia por cuadro, en el momento 2:** 15–17 % en la v4 y 3–4 % en la v5. En el momento 3 las dos versiones dan alrededor de 50 %, porque ahí se mueve la cámara de la pelea; no es ruido del dibujo.
- **Contraste del fondo:** baja de 56 a 47–49 en los momentos con luz.

## 3. Lo que no se hizo

- **Juntar los restos en 2 o 3 montoncitos:** habría que mover piezas que ya cayeron (lo que cae queda donde cae, regla de la v2). En su lugar: 2 pedazos como mucho y tinte oscuro.
- **Que los textos del mundo esperen en una cola general:** cada caso se resolvió en su lugar (montaña tras el cartel, globito que espera, sin burbuja del Indicador).

## 4. Crítica honesta

- «Aplastar» quita la frustración de caer en la silla. Puede sentirse demasiado fácil en la fase 3; si pasa, se achica el alcance desde los muebles (`alcance_mueble`).
- A ×1 el velo es sutil a propósito. Se nota más en conjunto que en una captura sola. Si el creador lo quiere más marcado, 0,3 sigue sin tapar lo jugable.
- El momento después del «¡CLIC!» sigue siendo el más cargado (6). Es el clímax de cada fase y está bien que lo sea, pero ahora va en fila.
