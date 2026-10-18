---
name: prototipo
description: Prototipo rápido de concepto para responder UNA pregunta de diseño de Felipe ("¿es divertido tirar cosas?"). Plantea la pregunta y el alcance mínimo, lo construye con el agente prototipador en siete-vidas/prototipos/<nombre>/ sin tocar el juego, lo prueba y cierra con un veredicto SEGUIR / CAMBIAR / DESCARTAR en INFORME.md.
user-invocable: true
---

# Prototipo de concepto

Un prototipo responde **una** pregunta con lo mínimo. Es feo a propósito, vive aparte del juego y lo que se guarda es lo aprendido. Fase 2 del proyecto se trata de esto: **¿es divertido ser Felipe?**

## 1. La pregunta

- Lee `siete-vidas/diseno/pilares.md` (o los pilares de la biblia) y la tabla **Acciones de Felipe** de `siete-vidas/memoria/02-guia-felipe.md`.
- Con el creador, escribe la hipótesis:
  > Si el jugador **<hace X>**, va a sentir **<Y>**, y lo notaremos en **<Z>**.
- Nombra **la suposición más arriesgada** (lo que, si es falso, tumba la idea).
- Si la pregunta no está clara o hay varias formas de hacerlo, consulta antes al agente `disenador-juego` para 2 a 4 variantes con recomendación.
- ¿Hace falta prototipo? No, si el diseño es obvio o un boceto en papel lo responde. Dilo.

## 2. Alcance mínimo (aprobación del creador)

Propón en 3 a 5 puntos qué se construye, y qué **no**. Ejemplo para acciones de gato:
- Una habitación de una pantalla con mesa, repisa y piso, dibujados por código.
- Felipe con su movimiento y sus hojas actuales.
- Botón de acción: tirar 3 objetos que caen, se rompen y suenan.
- Un humano provisional (rectángulo) que reacciona ("¡FELIPE!").
- Sin menús, sin vidas, sin música.

Nombre de la carpeta: `siete-vidas/prototipos/<nombre-corto>/` (por ejemplo `acciones-gato`). Espera el "sí" antes de construir.

## 3. Construir

Encarga la construcción al agente `prototipador` con: la hipótesis, el alcance aprobado, la carpeta y qué observar. Recuerda en el encargo:
- Proyecto de Godot propio en esa carpeta; no tocar `siete-vidas/juego/`.
- Arte provisional por código o hojas de Felipe copiadas; escala de siempre (67 px) y escala de gato.
- Sin SpriteCook ni Gemini. Si falta una animación, efectos de código y anotarlo.

Límite: si en un par de vueltas no hay algo jugable, simplifica la pregunta.

## 4. Probar

- El agente `qa-juego` (o el prototipador) graba capturas o video y anota lo que vio.
- El creador lo juega (abre la carpeta con Godot 4.3 y F5) con una lista corta de qué mirar.
- Pregunta al creador: ¿qué hiciste sin que te lo pidiéramos? ¿Te reíste? ¿Qué te aburrió? ¿Lo harías en cada habitación?

## 5. Informe y veredicto

Escribe `siete-vidas/prototipos/<nombre>/INFORME.md` y muéstralo antes de cerrarlo:

```markdown
# Prototipo: <nombre>
Fecha: AAAA-MM-DD · Carpeta: siete-vidas/prototipos/<nombre>/

## Pregunta
Si el jugador <X>, sentirá <Y>; lo notaremos en <Z>.
Suposición más arriesgada: <...>

## Qué se construyó
- <3 a 5 puntos; qué quedó fuera a propósito>

## Qué pasó
- <observaciones concretas: qué hizo el jugador, en qué segundo, cuántas veces>
- Capturas: <rutas>

## Qué aprendimos
- <qué suposición se confirmó o se cayó, qué sorprendió>

## Veredicto: SEGUIR | CAMBIAR | DESCARTAR
<por qué, con la evidencia de arriba>

## Si seguimos
- Diseño a cerrar: <...>
- Animaciones o arte que pediría (para el director-arte, con costo): <...>
- Valores que funcionaron: <perillas>
```

Si el creador quiere, consulta al agente `director-creativo` sobre si lo aprendido encaja con los pilares.

- **SEGUIR:** se diseña y se construye desde cero en el juego. Ese trabajo aplica la regla de los tres lugares de `CLAUDE.md` (memoria, ficha y juego con prueba) y entra a la tabla **Acciones de Felipe**.
- **CAMBIAR:** se define la variante y se hace otro prototipo. Tres CAMBIAR sobre la misma idea: considerar DESCARTAR.
- **DESCARTAR:** con aprobación, se borra la carpeta; queda solo la decisión.

## 6. Cerrar en la memoria

- `siete-vidas/memoria/01-decisiones.md`: la pregunta y el veredicto aprobado (una línea con fecha).
- `siete-vidas/memoria/04-pendientes.md`: el siguiente paso.

## Reglas

Una pregunta por prototipo, propuesta antes de construir, nada de créditos, respuestas cortas.
