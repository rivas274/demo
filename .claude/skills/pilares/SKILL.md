---
name: pilares
description: Sesión guiada para definir o revisar los pilares de Felipe y la fantasía del jugador, partiendo de los que ya están en la biblia. Escribe siete-vidas/diseno/pilares.md (fantasía, 3 a 5 pilares con ejemplos de sí y no, anti-pilares, juegos de referencia y qué tomar de cada uno). Úsalo en la fase 1 o cuando una decisión de diseño no se pueda resolver con los pilares actuales.
user-invocable: true
---

# Pilares del juego

Los pilares son lo que **no se negocia**: cuando dos ideas chocan, los pilares desempatan. Esta sesión los deja escritos de forma que sirvan para decidir, no como frases bonitas.

## 0. Preparar (sin preguntar todavía)

- Lee `CLAUDE.md`, `siete-vidas/memoria/README.md` y 01-decisiones.md.
- Lee de `siete-vidas/biblia/01-biblia.md` el Concepto, los **Pilares de diseño** (ya hay cinco) y Tono, humor y voz.
- Si existe `siete-vidas/diseno/pilares.md`, es una **revisión**: parte de ese archivo.
- Resume al creador en cinco líneas lo que ya existe. No se empieza de cero: se afila lo que hay.

## 1. La fantasía (una pregunta a la vez)

Pregunta y espera respuesta antes de la siguiente:

1. "¿Qué es lo que el jugador **es o hace** en Felipe que no puede en otro juego?" Propón tu borrador y que el creador lo corrija.
2. "Termina esta frase: *Es como ___, y además ___*." El "y además" tiene que despertar curiosidad.
3. "¿Qué tiene que sentir el jugador en una partida de 20 minutos?" (de la estética de MDA, elegir dos o tres: fantasía, descubrimiento, expresión, desafío, narrativa, sensación).

## 2. Los pilares (3 a 5)

Para cada pilar de la biblia (y los que surjan), pon a prueba:

- **¿Se puede romper?** Si ninguna decisión real lo violaría, es demasiado vago. "Ser gato es el sistema de juego" se rompe con un nivel de solo saltar plataformas: sirve.
- **¿Desempata?** Escribe la prueba: "si dudamos entre X e Y, este pilar elige ___".
- **¿Vale para todo?** Debe guiar también el arte, el sonido y el texto.
- **¿Choca con otro?** Una tensión sana entre pilares es buena; nómbrala.

Atención con lo abierto en la memoria: el pilar "Tus decisiones tienen peso, literalmente" depende de si el peso afecta el movimiento y de si Felipe carga snacks (04-pendientes.md). Si sigue abierto, dilo en el pilar y no lo cierres sin el creador.

Si el creador quiere, consulta al agente `director-creativo` con el borrador para un veredicto APROBAR / AFILAR / RECHAZAR por pilar.

## 3. Anti-pilares

Tres o más cosas que el juego **no** es, cada una con el porqué. Ejemplos para discutir: "No es un juego de héroe noble", "No castiga con tiempo ni hambre", "No es un soulslike difícil".

## 4. Referencias

Tres a seis juegos con **qué tomar** y **qué no** de cada uno. Reutiliza los de `siete-vidas/diseno/reglas-de-niveles.md` (Mario, Celeste, Hollow Knight, Stray, Broforce, Cuphead) y suma los que pida la fantasía (por ejemplo, Untitled Goose Game para la travesura con un botón).

## 5. Escribir y cerrar

Muestra el borrador completo y espera aprobación. Luego escribe `siete-vidas/diseno/pilares.md`:

```markdown
# Pilares de Felipe
Actualizado: AAAA-MM-DD. Aprobado por el creador.

## Fantasía
<una o dos frases>. Es como <juego>, y además <gancho>.
El jugador siente: <estéticas en orden>.

## Pilares
### 1. <Nombre corto>
<Qué significa en una frase.>
- Sí: <ejemplo concreto de Felipe>
- No: <ejemplo concreto que lo rompe>
- Desempata: si dudamos entre <X> e <Y>, elegimos <___>.
(3 a 5 pilares)

## Anti-pilares
- No es <...>, porque <...>.

## Juegos de referencia
| Juego | Qué tomamos | Qué no |
| --- | --- | --- |
```

Al cerrar:
- Agrega la decisión en `siete-vidas/memoria/01-decisiones.md` y el enlace a `pilares.md` en la tabla de `siete-vidas/memoria/README.md`.
- Actualiza los Pilares de diseño de `siete-vidas/biblia/01-biblia.md`; la biblia en línea (enlace en el README de memoria) se actualiza en la misma sesión o queda como pendiente en 04-pendientes.md.
- Marca el paso en 04-pendientes.md y sugiere el siguiente: `/prototipo` de acciones de gato.

## Reglas

Un tema a la vez, propuesta antes de escribir, respuestas cortas. Si un pilar nuevo cambia algo de Felipe, aplica la regla de los tres lugares de `CLAUDE.md`.
