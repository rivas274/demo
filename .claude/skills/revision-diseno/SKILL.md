---
name: revision-diseno
description: Revisa un documento de diseño de Felipe (mecánica, nivel, sistema, jefe, pilares) contra los pilares, las reglas de niveles, CLAUDE.md y la memoria del proyecto, y da un veredicto APROBADO / CON CAMBIOS / RECHAZADO con hallazgos concretos. Úsalo antes de construir algo diseñado en papel o cuando un documento cambió mucho.
user-invocable: true
---

# Revisión de un documento de diseño

Revisar en papel es barato; descubrir en Godot que algo no encaja es caro. Esta revisión compara un documento con lo ya decidido y dice qué choca, qué falta y qué está bien.

## 1. Qué se revisa

- El creador indica el archivo (por ejemplo `siete-vidas/diseno/nivel-01-gran-fuga.md`). Si no lo dice, pregunta; no revises todo a la vez.
- Lee el documento completo.

## 2. Contra qué se compara

Lee solo lo que aplique:

| Fuente | Qué buscar |
| --- | --- |
| `siete-vidas/diseno/pilares.md` (o pilares de la biblia) | ¿Sirve a la fantasía y a cada pilar? ¿Cae en un anti-pilar? |
| `siete-vidas/memoria/01-decisiones.md` | ¿Contradice algo cerrado (botón de acción único, 9 vidas, peso como indicador, Felipe nunca golpea humanos, legal)? |
| `siete-vidas/memoria/02-guia-felipe.md` | ¿Usa acciones que existen (tabla **Acciones de Felipe**) o pide nuevas? ¿Respeta rasgos y medidas? |
| `CLAUDE.md` | Consistencia de Felipe, proporciones, escala de gato, `PresentacionJefe` para jefes |
| `siete-vidas/diseno/reglas-de-niveles.md` | Si es un nivel: ¿dice cómo cumple cada regla R1 a R16? |
| `siete-vidas/memoria/04-pendientes.md` | ¿Depende de una pregunta abierta sin decirlo? |

## 3. Opiniones de los agentes (opcional, según el tema)

Para no gastar de más, consulta solo a quien aporte:
- `director-creativo`: si hay duda de tono o de pilares.
- `disenador-juego`: si la mecánica es nueva o el bucle no queda claro.
- `revisor-niveles`: si es un nivel (en papel; la revisión con capturas es aparte).
- `director-arte`: si pide arte o animaciones nuevas (que traiga el costo).

## 4. Hallazgos

Para cada uno: qué dice el documento, contra qué choca (cita la fuente y la regla o pilar), por qué importa para el jugador y qué cambiar. Ordénalos:

- **Bloqueante:** rompe un pilar, una regla de `CLAUDE.md`, una regla de niveles o una decisión cerrada.
- **Importante:** falta algo para poder construirlo (perillas, cómo se enseña, qué animación usa, cómo se prueba).
- **Sugerencia:** mejora opcional.

Señala también **lo que está bien** (dos o tres puntos): sirve para saber qué no tocar.

## 5. Veredicto

```markdown
## Revisión: <documento> (AAAA-MM-DD)
Veredicto: APROBADO | CON CAMBIOS | RECHAZADO
<dos líneas con el porqué>

| Gravedad | Hallazgo | Choca con | Cambio propuesto |
| --- | --- | --- | --- |

Lo que está bien: ...
Decisiones para el creador: <tensiones entre pilares o reglas, con 2 o 3 opciones y recomendación>
Costo de arte (si aplica): <animaciones o imágenes y créditos estimados>
```

- **APROBADO:** se puede construir (o prototipar).
- **CON CAMBIOS:** se arreglan los bloqueantes y se vuelve a mirar solo eso.
- **RECHAZADO:** choca con la visión; se replantea con el `disenador-juego`.

Entrega la revisión en el chat. Si el creador quiere guardarla, agrégala al final del propio documento revisado en una sección "Revisión" (no uses `siete-vidas/diseno/revisiones/`, que es del revisor de niveles).

## 6. Cerrar

- Si una regla no se cumple, se cambia el diseño, no la regla; cambiar una regla lo decide el creador.
- Las decisiones que el creador tome van a `siete-vidas/memoria/01-decisiones.md` y los pasos a 04-pendientes.md.
- Si el cambio toca a Felipe, recuerda la regla de los tres lugares de `CLAUDE.md`.

## Reglas

Un documento por revisión, propuesta de cambios (no reescribir el documento sin permiso), respuestas cortas.
