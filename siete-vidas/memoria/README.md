# Memoria del proyecto: Nueve Vidas, Cero Disculpas

Esta carpeta guarda lo que ya se decidió, para que cualquier sesión nueva retome el desarrollo sin repetir conversaciones. Léela completa antes de proponer algo.

## Por dónde empezar

| Archivo | Qué contiene |
| --- | --- |
| [05-estado-actual.md](05-estado-actual.md) | **Dónde vamos:** fase, lo que está en curso, pendientes en orden y decisiones abiertas. Empieza por aquí en un chat nuevo |
| [06-lecciones-arte.md](06-lecciones-arte.md) | **Errores de arte y ambientes que no se repiten** (leer antes de diseñar, construir o revisar un escenario) |
| [01-decisiones.md](01-decisiones.md) | Todas las decisiones de diseño cerradas, en resumen |
| [02-guia-felipe.md](02-guia-felipe.md) | Guía del personaje principal (model sheet en texto) |
| [03-arte-y-herramientas.md](03-arte-y-herramientas.md) | Resolución, estilo visual, SpriteCook, créditos y assets generados |
| [04-pendientes.md](04-pendientes.md) | Qué falta y en qué orden |
| [07-arquitectura.md](07-arquitectura.md) | **Cómo está armado el juego:** piezas (componentes), datos y escenas, estados de Felipe, jefes con conductas, la interfaz (tema, pila de pantallas, textos traducibles, controles); recetas para un enemigo, un objeto, un jefe, una pantalla de menú, traducir un texto o el nivel 2 |
| [../diseno/pilares.md](../diseno/pilares.md) | **Fantasía y pilares del juego** (aprobados): desempatan toda decisión |
| [../diseno/reglas-de-niveles.md](../diseno/reglas-de-niveles.md) | Reglas para diseñar niveles (se validan con `prueba_reglas_nivel.gd`) |

## Equipo de diseño (agentes y comandos)

**Fase actual: Fase 3 – Vertical slice** (desde el 2026-10-19): el nivel 1 tutorial con calidad final. Fases 1 y 2 cerradas (pilares aprobados; prototipo de travesuras con veredicto SEGUIR). Fases: 1 Concepto y pilares → 2 Prototipo de concepto (¿es divertido ser Felipe?) → 3 Vertical slice (nivel 1 con calidad final) → 4 Producción → 5 Pulido y lanzamiento (Steam). El nivel 1 ya construido queda como base; se vuelve a él después del prototipo de acciones de gato. Pasar de fase se decide con `/puerta-fase`.

Adaptado de Claude Code Game Studios y GodotPrompter (MIT; créditos en `.claude/CREDITOS.md`). Agentes en `.claude/agents/`, comandos en `.claude/skills/`.

| Nombre | Tipo | Qué hace |
| --- | --- | --- |
| `director-creativo` | Agente | Guarda la visión y los pilares; decide si algo encaja con el tono; opina en las puertas de fase |
| `disenador-juego` | Agente | Mecánicas y bucle principal; propone 2 a 4 opciones con recomendación |
| `prototipador` | Agente | Prototipos feos y rápidos en `siete-vidas/prototipos/<nombre>/` para una sola pregunta |
| `qa-juego` | Agente | Prueba como jugador (capturas, bot, pruebas) y separa errores de problemas de diseño |
| `director-arte` | Agente | Consistencia visual de Felipe y del mundo; prepara encargos a SpriteCook/Gemini con costo |
| `revisor-niveles` | Agente | Revisa niveles con capturas contra las reglas de niveles |
| `/pilares` | Comando | Define o revisa fantasía y pilares → `siete-vidas/diseno/pilares.md` |
| `/prototipo` | Comando | Pregunta, alcance, construcción y veredicto → `siete-vidas/prototipos/<nombre>/INFORME.md` |
| `/prueba-juego` | Comando | Informe de prueba de juego → `siete-vidas/diseno/pruebas-de-juego/` |
| `/revision-diseno` | Comando | Revisa un documento de diseño contra pilares, reglas y memoria |
| `/puerta-fase` | Comando | ¿Se pasa de fase? SEGUIR / CAMBIAR / DETENER; actualiza la fase aquí |
| `/godot-felipe` | Comando | Guía técnica corta para tocar `felipe.gd` (sensación, estados, animación, tween, cámara) |

## Concepto visual de personajes

- **Felipe:** `../concepto/felipe-concepto.html` (copia local) y https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe (en línea). Al cambiar algo de Felipe, regenerar ambas con `../herramientas/pagina_felipe.py` y volver a publicar la versión en línea.

## Documento maestro

La biblia completa del juego (historia, personajes, mundo, mecánicas, logros, revisión editorial y legal) está en dos lugares:

- **Copia en el repositorio:** [`../biblia/`](../biblia/) (`01-biblia.md`, `02-revision-editorial.md`, `03-revision-legal.md`). Las fotos de Felipe y el mapa interactivo solo están en la versión en línea.
- **Versión en línea (la que se edita):** https://claude.ai/code/artifact/bcd05221-e2ce-4971-969b-8cc982606828

Si la biblia en línea cambia, vuelve a exportarla a `../biblia/`. Si algo de esta carpeta contradice la biblia, gana la decisión más reciente. Anota aquí cualquier cambio.

## Cómo trabaja el creador del juego

- **Un tema a la vez.** Se presenta una propuesta, el creador opina, se cierra y se pasa al siguiente.
- **Propuesta antes de gastar.** Nunca llamar a SpriteCook (créditos limitados) sin mostrar antes el prompt, los ajustes y el costo, y recibir aprobación.
- **Claude es la guía del creador** (su primer juego indie): si una idea no tiene sentido, sobrecarga o arruina el juego, decirlo claro y proponer la alternativa. La meta: que se sienta vivo, hecho con cariño y bien hecho, sin sobrecargar.
- **Idioma:** español. Explicaciones claras, sin jerga técnica innecesaria.
- **Cuidado legal:** el juego se publicará en Steam. Nada de marcas, personajes ni personas reales (ver 01-decisiones.md, sección Legal).
- Al cerrar un tema, actualizar esta carpeta y la biblia.
