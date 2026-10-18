---
name: prueba-juego
description: Informe de prueba de juego de Felipe (del juego o de un prototipo) con qué se probó, qué sintió el jugador, momentos divertidos y aburridos, errores y problemas de diseño por separado, y acciones. Escribe siete-vidas/diseno/pruebas-de-juego/AAAA-MM-DD-<tema>.md. Úsalo después de que el creador o el bot jueguen algo nuevo.
user-invocable: true
---

# Prueba de juego

Una prueba de juego responde "¿cómo se siente jugarlo?", no "¿pasan las pruebas?". El informe sirve para decidir qué se cambia, así que separa lo que se vio de lo que se cree.

## 1. Qué se prueba

Pregunta al creador (o deduce del contexto):
- **Qué:** el juego (`siete-vidas/juego/`) o un prototipo (`siete-vidas/prototipos/<nombre>/`), y qué parte (una mecánica, una habitación, el nivel completo).
- **Para qué:** la pregunta que se quiere contestar.
- **Quién jugó:** el creador, otra persona (¿conocía el juego?) o el bot `partida.gd`.

Si el creador ya jugó, pídele sus notas en bruto: qué hizo, dónde dudó, de qué se rió, qué lo aburrió. Si no, encarga la prueba al agente `qa-juego` (capturas, video del bot, pruebas headless).

## 2. Juntar evidencia

- Notas del jugador, con sus palabras.
- Capturas o segundos del video para cada momento importante (recortes en `siete-vidas/diseno/pruebas-de-juego/capturas/`).
- Resultado de las pruebas automáticas solo como contexto.

## 3. Escribir el informe

Archivo: `siete-vidas/diseno/pruebas-de-juego/AAAA-MM-DD-<tema>.md` (fecha de hoy, tema corto con guiones).

```markdown
# Prueba de juego: <tema>
Fecha: AAAA-MM-DD · Versión: <commit o carpeta> · Jugó: <quién; conocía el juego sí/no>

## Qué se probó
<qué parte y la pregunta que queríamos responder>

## Resumen en tres líneas
<¿se cumple la pregunta? lo mejor, lo peor>

## Qué sintió el jugador
- <con sus palabras cuando se pueda>

## Momentos divertidos
| Momento | Dónde / segundo | Por qué funcionó |
| --- | --- | --- |

## Momentos aburridos o confusos
| Momento | Dónde / segundo | Qué pasó |
| --- | --- | --- |

## Errores (algo roto)
| Gravedad | Qué pasa | Cómo repetirlo | Esperado |
| --- | --- | --- | --- |

## Problemas de diseño (funciona, pero no se siente bien)
| Problema | Evidencia | Pilar o regla que toca | Pregunta para diseño |
| --- | --- | --- | --- |

## Acciones propuestas
1. <acción> → <quién: disenador-juego, prototipador, director-arte, código>
```

Gravedad de errores: **Bloqueante** (no se puede seguir), **Grave** (se nota y molesta), **Menor**.

## 4. Cerrar

- Muestra el informe y deja que el creador elija qué acciones se hacen (una a la vez).
- Las acciones aprobadas van a `siete-vidas/memoria/04-pendientes.md`; las decisiones que salgan, a 01-decisiones.md.
- Si un hallazgo pide cambiar algo de Felipe, ese trabajo aplica la regla de los tres lugares de `CLAUDE.md`. Si pide arte, el `director-arte` prepara el encargo con costo antes de gastar.
- La revisión de niveles contra sus reglas es otra cosa: la hace el agente `revisor-niveles` en `siete-vidas/diseno/revisiones/`. No escribas ahí.

## Reglas

Un tema por informe, nada inventado (una sospecha se escribe como sospecha), pocas capturas y bien elegidas.
