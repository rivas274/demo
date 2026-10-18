---
name: puerta-fase
description: Decide si Felipe pasa a la siguiente fase del proyecto (1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento en Steam). Revisa los criterios de salida de la fase actual, consulta a los agentes que correspondan y da un veredicto SEGUIR / CAMBIAR / DETENER. Si el creador aprueba, actualiza la fase actual en la memoria.
user-invocable: true
---

# Puerta de fase

Pasar de fase es comprometerse: lo que se salta ahora se paga después con retrabajo. Esta puerta mira lo que **existe** (archivos, prototipos, el juego) contra los criterios de salida, sin dar por hecho nada que no se pueda abrir y ver.

## 1. Dónde estamos

- Lee la fase actual en `siete-vidas/memoria/README.md` (sección "Equipo de diseño"). Si el creador pide revisar otra fase, usa esa.
- Lee `CLAUDE.md`, `siete-vidas/memoria/01-decisiones.md` y 04-pendientes.md.

## 2. Criterios de salida por fase

Marca cada uno con ✔ (existe y lo viste), ✘ (falta) o ~ (a medias), con la ruta que lo prueba.

### Fase 1 – Concepto y pilares → pasa a Prototipo
- `siete-vidas/diseno/pilares.md` aprobado: fantasía, gancho "es como ___, y además ___", 3 a 5 pilares con sí/no y prueba de desempate, anti-pilares y referencias.
- Biblia y memoria coherentes con los pilares (o la diferencia anotada como pendiente).
- Lista corta de preguntas para prototipar, en orden (la primera: acciones de gato).
- Las preguntas abiertas que afectan al prototipo están identificadas (peso, snacks).

### Fase 2 – Prototipo de concepto (¿es divertido ser Felipe?) → pasa a Vertical slice
- Al menos un prototipo de acciones de gato con `INFORME.md` y veredicto SEGUIR aprobado.
- El creador lo jugó: hizo travesuras sin que se lo pidieran y hubo al menos un momento de risa (anotado en una prueba de juego).
- Decididas las preguntas que cambian el bucle principal (botón de acción y qué hace, maullar, intimidar, peso, snacks).
- Lista de animaciones y arte que pide lo aprobado, con costo estimado por el `director-arte`.

### Fase 3 – Vertical slice (nivel 1 con calidad final) → pasa a Producción
- Nivel 1 con las acciones de gato aprobadas, arte final (no provisional), hojas finales de Felipe y sonido propio.
- Todas las pruebas pasan, `partida.gd` lo termina y la última revisión del `revisor-niveles` no tiene bloqueantes.
- Una prueba de juego con alguien que no conoce el juego, sin bloqueantes.
- Medido cuánto costó el nivel (tiempo, créditos) para estimar los seis distritos; el alcance o el plan B (por etapas) revisado con esa cifra.

### Fase 4 – Producción → pasa a Pulido y lanzamiento
- El juego se juega de principio a fin: seis distritos, jefes, poderes y los cinco finales.
- Afecto, respeto, mañas, logros y coleccionables funcionan.
- Español latino e inglés completos; accesibilidad de 01-decisiones.md.
- Sin errores bloqueantes abiertos.

### Fase 5 – Pulido y lanzamiento (Steam)
- Lista legal de 01-decisiones.md cumplida (sin marcas ni personas reales, licencias, aviso MIT de Godot, arte con IA declarado y retocado a mano).
- Exportación a Windows y Linux estable; rendimiento revisado.
- Página de Steam, demo y redes de Felipe listas.

## 3. Consultar a los agentes

Consulta solo a los que correspondan, en paralelo y con la lista de criterios y archivos:

| Paso | Agentes |
| --- | --- |
| 1 → 2 | `director-creativo`, `disenador-juego` |
| 2 → 3 | `director-creativo`, `disenador-juego`, `qa-juego`, `director-arte` |
| 3 → 4 | los anteriores y `revisor-niveles` |
| 4 → 5 y lanzamiento | `director-creativo`, `qa-juego`, `director-arte` |

Cada uno responde LISTO / CON RESERVAS / NO LISTO. Un criterio que no corresponde a esta fase no es un hallazgo.

## 4. Veredicto

```markdown
## Puerta de fase: <fase actual> → <siguiente> (AAAA-MM-DD)
Veredicto: SEGUIR | CAMBIAR | DETENER

| Criterio | Estado | Prueba (ruta) |
| --- | --- | --- |

Agentes: director-creativo LISTO · ...
Lo que bloquea: ...
Pasos para la próxima revisión (en orden): 1. ... 2. ...
```

- **SEGUIR:** todos los criterios ✔ (o ~ sin riesgo) y ningún agente NO LISTO.
- **CAMBIAR:** faltan cosas concretas; se hacen y se vuelve a revisar. Se puede seguir trabajando en la fase actual.
- **DETENER:** algo de fondo no funciona (por ejemplo, tres prototipos sin diversión); se replantea con el `director-creativo` antes de invertir más.

El veredicto lo propone la puerta; **pasar de fase lo decide el creador**.

## 5. Cerrar

Si el creador aprueba pasar:
- Cambia la **fase actual** en `siete-vidas/memoria/README.md` (sección "Equipo de diseño") y en la línea de fase de `CLAUDE.md`.
- Anota en `siete-vidas/memoria/01-decisiones.md`: "Fase N cerrada (fecha), se pasa a N+1".
- Pon en `siete-vidas/memoria/04-pendientes.md` los primeros pasos de la nueva fase.

Si no pasa, anota los pasos que faltan en 04-pendientes.md.

## Reglas

Una puerta a la vez, nada se da por hecho sin abrir el archivo, consultas solo a quien aporte (cuida tokens) y sin gastar créditos.
