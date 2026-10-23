# Herramientas, costos y equipo de agentes (2D)

## Qué problema resuelve

Saber qué usar, cuánto cuesta de verdad y cómo organizar el trabajo con Claude cuando una sola persona hace todo el juego.

## Herramientas y costos reales

| Herramienta | Para qué | Costo | Licencia del resultado |
| --- | --- | --- | --- |
| Godot 4.3 | Motor | Gratis | MIT (aviso en los créditos) |
| Gemini (cuenta personal del creador) | Arte fijo y crítica | Gratis | Declarar uso de IA en Steam |
| SpriteCook | Animaciones del protagonista desde su imagen base | Plan de pago «apprentice», 800 créditos | Declarar uso de IA en Steam |
| Kenney | Íconos de botones, sonidos, partículas | Gratis | CC0 |
| Pixel Operator / Silkscreen | Letras pixel | Gratis | CC0 / SIL OFL 1.1 |
| Pixelorama o Aseprite | Retoque a mano | Gratis / pago único | Propio |
| Python (PIL, numpy, scipy) | Preparar arte, texturas de luz, sonidos provisionales | Gratis | Propio |

**Costos de SpriteCook vistos en el proyecto:**
- Animación de 8 cuadros con el modelo por defecto: 20 créditos.
- Con `pixel-engine-v1.5` (poses difíciles): **26 créditos**. Cotiza con el precio del modelo elegido; una vez se cotizó 20 por error.
- Imagen fija: 8 a 12 créditos según el modelo.
- Las 4 imágenes de Felipe de pie para el 3D costaron 48 créditos (de 140).
- Subir imágenes no gasta. Revisa el saldo con `get_credit_balance` antes de gastar.

**Notas de conexión:** SpriteCook se conecta como conector MCP. Para subir una imagen local: `create_asset_upload`, PUT a la URL que devuelve y `finalize_asset_upload`. La red debe permitir el dominio de su API o no se pueden descargar las imágenes.

**Gemini sin API:** se usó la sesión de Claude en la PC del creador con Chrome (control remoto), o el creador como puente manual. Alternativa: una clave de la API de Gemini en el entorno.

## Equipo de agentes por fases

El proyecto avanza por fases y cada fase tiene una puerta de salida con criterios.

```
1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento
```

| Agente | Qué hace |
| --- | --- |
| Director creativo | Guarda la visión y los pilares; da el veredicto creativo en las puertas de fase |
| Diseñador de juego | Mecánicas desde la experiencia del jugador; propone 2 a 4 opciones con recomendación |
| Director de arte | Consistencia visual; prepara encargos a SpriteCook y Gemini **con prompt y costo**, sin llamarlos |
| Prototipador | Prototipos feos y rápidos en una carpeta aparte, para **una** pregunta |
| QA | Juega, saca capturas y separa errores de problemas de diseño |
| Revisor de niveles | Revisa niveles con capturas contra las reglas |
| Revisor de ambientes | Artista de entornos senior: un plan de corrección por cuarto cuando algo «se ve hecho por IA» |

| Comando | Qué hace |
| --- | --- |
| `/pilares` | Fantasía y pilares con ejemplos de sí y no |
| `/prototipo` | Pregunta, alcance mínimo, construcción y veredicto SEGUIR / CAMBIAR / DESCARTAR |
| `/prueba-juego` | Informe de prueba de juego |
| `/revision-diseno` | Revisa un documento contra pilares, reglas y memoria |
| `/puerta-fase` | ¿Se pasa de fase? SEGUIR / CAMBIAR / DETENER |

Base: adaptado de Claude Code Game Studios y GodotPrompter (MIT).

**Para reusarlo:** copia `.claude/agents/` y `.claude/skills/`, cambia el nombre del juego, los pilares y las rutas, y conserva las reglas («no llama a servicios pagos», «una sola pregunta por prototipo», «propone opciones y deja decidir»).

## Memoria del proyecto (para no repetir conversaciones)

| Archivo | Qué guarda |
| --- | --- |
| Estado actual | Dónde vamos y qué sigue; se lee primero en cada chat |
| Decisiones | Lo cerrado, en resumen |
| Guía del personaje | Rasgos, proporciones y tabla de acciones |
| Arte y herramientas | Estilo, servicios, costos, assets con su id |
| Pendientes | Qué falta, en orden |
| Lecciones de arte | Errores que no se repiten |
| Arquitectura | Cómo está armado el código y recetas |

Regla: cada cambio de un personaje se refleja en la memoria, en la ficha visual del personaje y en el juego, con su prueba.

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Créditos perdidos en una animación que no salió | Modelo por defecto para una pose difícil | `pixel-engine-v1.5` con prompt cuadro por cuadro |
| Gasto sin aprobación | El agente llamó al servicio directamente | El director de arte solo prepara el encargo; gasta la sesión principal tras el «sí» |
| Assets de terceros que rompen el estilo | Usar packs para personajes o fondos | Packs gratis solo para interfaz, sonido y partículas |

## Fuente o ejemplo

- Agentes y comandos: `.claude/agents/` y `.claude/skills/`; créditos de la base: `.claude/CREDITOS.md`.
- Costos y assets: `siete-vidas/memoria/03-arte-y-herramientas.md`; estado y créditos restantes: `siete-vidas/memoria/05-estado-actual.md`.
- Memoria del proyecto: `siete-vidas/memoria/README.md`.
