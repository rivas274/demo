# Arte y herramientas

## Decisiones visuales

- **Resolución base: 640×360.** Escala exacta a 720p (×2), 1080p (×3) y 4K (×6). Se eligió tras comparar 320×180, 400×240, 480×270 y 640×360 (comparación: https://claude.ai/artifact/LPx28mVsZt5P4zcnoU6nHP).
- **Estilo:** proporciones Chibi para los gatos + acabado Cel-shaded para todo. Ver `02-guia-felipe.md`.
- **Bloques del escenario:** 16×16 px. Fondos con 3 o 4 capas de profundidad (parallax).
- **Paleta por distrito:** Barrio Viejo (terracota y atardecer), Neón (noche azul con magenta y cian), Downtown (gris azulado y dorado), Muelle (verde azulado y óxido), Basurero (oliva, café y verde tóxico), Torres Paradise (blanco, amarillo de obra y rojo).
- **Interfaz:** sátira de redes sociales (afecto = corazones, respeto = garras, peso = báscula; diálogos como burbujas de chat; logros como notificaciones).
- **Música:** un estilo por distrito; sin actores de voz. Aún no se cerró en detalle.

## SpriteCook (generador de arte con IA)

- **Conectado** como conector en claude.ai (`https://mcp.spritecook.ai/mcp/claude`), cuenta gratuita.
- **Subir imágenes locales:** `create_asset_upload`, luego PUT con curl a la URL devuelta, luego `finalize_asset_upload`.
- **Red del entorno:** deben estar permitidos `mcp.spritecook.ai` y `api.spritecook.ai`; sin el segundo no se pueden descargar ni ver las imágenes.
- **Proyecto en SpriteCook:** "Siete Vidas, Cero Disculpas", id `126fcb42-c3f6-40b5-9f75-42715fbdce40`. Pasar siempre `project_id`.
- **Créditos:** 40 iniciales; quedan **24** tras las pruebas v1 y v2 (2026-10-17). Subir imágenes de referencia no gasta créditos. Comprobar con `get_credit_balance` antes de gastar.
- **Regla de oro:** mostrar al creador el prompt, el modelo, los ajustes y el costo, y esperar aprobación antes de cada llamada que gaste créditos.

### Modelos y costos útiles (consultados el 2026-10-17)

| Modelo | Costo 1K | Nota |
| --- | --- | --- |
| `gemini-3.1-flash-lite-image` (Nano Banana 2 Lite) | 8 créditos | El más barato; usado en v1 con buen resultado; hasta 14 referencias |
| `gpt-image-2.5-flare` calidad low | 5 créditos + 8 por imagen de referencia | Soporta transparencia |
| `gemini-nano-banana-2.1` (por defecto) | 12 créditos | |

### Trucos para ahorrar créditos

- Varias ideas en una sola imagen (hojas comparativas en cuadrícula) en vez de una llamada por idea.
- Usar un asset ya generado como `style_asset_ids` para mantener el estilo sin repetir pruebas.
- Hacer bocetos de poses y composición en texto (o a mano) y solo generar cuando la idea esté aprobada.
- Retocar a mano en Pixelorama o Aseprite en vez de regenerar por detalles pequeños.

### Assets generados

| Asset | Id SpriteCook | Archivo local |
| --- | --- | --- |
| Felipe, prueba de 4 estilos v1 | `8868e7a2-dd1c-4ab4-a823-9d8b184f5f87` | `siete-vidas/arte/referencias/felipe-prueba-estilos-v1.png` |
| Foto real de Felipe (referencia, no se publica) | `a0fbe97b-61b6-4d6d-8cb3-c5b4afaa6a74` | No está en el repositorio |
| Felipe híbrido v2 (versiones A y B) | `22529bf7-4fcc-4f41-9b17-488d276a206a` | `siete-vidas/arte/referencias/felipe-hibrido-v2.png` |

## Otras herramientas

- **Motor:** Godot 4 (MIT). SpriteCook puede exportar paquetes de personaje y tilesets listos para Godot 4.
- **Retoque de pixel art:** Pixelorama (gratis, código abierto) o Aseprite.
- **Niveles:** TileMap de Godot y LDtk.
- **Audio:** Furnace o LMMS (música), jsfxr y Audacity (efectos).
