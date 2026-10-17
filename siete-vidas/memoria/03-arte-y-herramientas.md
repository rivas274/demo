# Arte y herramientas

## Decisiones visuales

- **Resolución base: 640×360.** Escala exacta a 720p (×2), 1080p (×3) y 4K (×6). Se eligió tras comparar 320×180, 400×240, 480×270 y 640×360 (comparación: https://claude.ai/artifact/LPx28mVsZt5P4zcnoU6nHP).
- **Estilo:** proporciones Chibi para los gatos + acabado Cel-shaded para todo. Ver `02-guia-felipe.md`.
- **Bloques del escenario:** 16×16 px. Fondos con 3 o 4 capas de profundidad (parallax).
- **Paleta por distrito:** Barrio Viejo (terracota y atardecer), Neón (noche azul con magenta y cian), Downtown (gris azulado y dorado), Muelle (verde azulado y óxido), Basurero (oliva, café y verde tóxico), Torres Paradise (blanco, amarillo de obra y rojo).
- **Interfaz:** sátira de redes sociales (afecto = corazones, respeto = garras, peso = báscula; diálogos como burbujas de chat; logros como notificaciones).
- **Música:** un estilo por distrito; sin actores de voz. Aún no se cerró en detalle.

## SpriteCook (generador de arte con IA)

- **Conectado** como conector en claude.ai (`https://mcp.spritecook.ai/mcp/claude`). Plan de pago "apprentice" desde el 2026-10-17 (800 créditos, 4 trabajos a la vez).
- **Subir imágenes locales:** `create_asset_upload`, luego PUT con curl a la URL devuelta, luego `finalize_asset_upload`.
- **Red del entorno:** deben estar permitidos `mcp.spritecook.ai` y `api.spritecook.ai`; sin el segundo no se pueden descargar ni ver las imágenes.
- **Proyecto en SpriteCook:** "Siete Vidas, Cero Disculpas", id `126fcb42-c3f6-40b5-9f75-42715fbdce40`. Pasar siempre `project_id`.
- **Créditos:** 800 del plan de pago; quedan **672** (2026-10-17) tras: quieto, caminar, correr, zarpazo, comer, saltar (20 c/u) y Modo Buda (8). Subir imágenes no gasta créditos. Comprobar con `get_credit_balance` antes de gastar.
- **Regla de oro:** mostrar al creador el prompt, el modelo, los ajustes y el costo, y esperar aprobación antes de cada llamada que gaste créditos.

### Modelos y costos útiles (consultados el 2026-10-17)

| Modelo | Costo 1K | Nota |
| --- | --- | --- |
| `gemini-3.1-flash-lite-image` (Nano Banana 2 Lite) | 8 créditos | El más barato; usado en v1 con buen resultado; hasta 14 referencias |
| `gpt-image-2.5-flare` calidad low | 5 créditos + 8 por imagen de referencia | Soporta transparencia |
| `gemini-nano-banana-2.1` (por defecto) | 12 créditos | |

### Costos de animación (consultados el 2026-10-17)

- `animate_game_art` sobre un asset existente: 20 créditos por animación de 8 cuadros.
- Flujo guiado de personaje (`generate_character` + `generate_character_animations`): 12 por el personaje base, 20 por animación, +12 para preparar las poses de caminar o correr.

### Estrategia de animación (aprobada el 2026-10-17)

- **A + C, y B solo si hace falta:** SpriteCook solo para animaciones estrella; el resto, por piezas (cutout) en Godot con huesos y estiramientos, sin créditos.
- Primera prueba: animación "quieto" de Felipe A con `animate_game_art` (20 créditos, tardó 1 minuto). Resultado bueno: la cola se mece, el cuerpo respira y el estilo se mantiene igual en los 8 cuadros.

### Comparación SpriteCook contra código (2026-10-17)

- **Animación gratis por código:** `siete-vidas/herramientas/animar_felipe.py` separa el sprite en capas (cola, cuerpo, 4 patas) y las mueve pixel por pixel. Resultados en `siete-vidas/arte/felipe/codigo/`.
- **Conclusión:** el código sirve para quieto, saltar, caer, aterrizar, daño, ronronear y formas de peso. Caminar, correr, zarpazo y comer necesitan poses nuevas: mejor con SpriteCook (la caminata de SpriteCook mueve patas y cabeza; la de código parece deslizarse).
- **Ficha visual con las animaciones en movimiento:** https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe (se regenera con `siete-vidas/herramientas/pagina_felipe.py`).

### Formas de peso

- `siete-vidas/herramientas/pesos_felipe.py` genera Flaco (0.84), Normal, Gordito (1.22) y Modo Buda (1.5) a partir de cualquier hoja de animación.
- Solo ensancha el cuerpo, del cuello a la panza, fila por fila; la cabeza y la cola no cambian. (La primera versión estiraba todo el sprite y se veía mal.)
- Resultados en `siete-vidas/arte/felipe/pesos/`.

### Salto (feedback del creador)

- El salto que solo estira y aplasta "se ve mal, tiene que ser más dinámico para enganchar".
- Versión actual: poses de la animación "saltar" de SpriteCook (cuadro por fase: agacharse 1, subir 2, pausa 3, vuelta 4, caer 6, aterrizar 7) más efectos de código: anticipación agachándose, despegue explosivo, pausa arriba, Doble Salto Imposible con una inclinación leve de unos 20° (la vuelta completa de 360° le pareció exagerada al creador), caída más rápida que la subida, aplastón y rebote al aterrizar, estela de imágenes fantasma y polvo al despegar y aterrizar. Implementado en la ficha (`pagina_felipe.template.html`, función `drawJump`); los mismos tiempos sirven para Godot.
- Modo Buda por código "se ve mal": se resolvió editando Felipe A con SpriteCook (8 créditos): bola perfecta con sonrisa satisfecha. Flaco y Gordito siguen por código.

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
| Felipe A base (recortado, sin fondo) | `14b3c27f-798c-4795-84fe-48ed15508247` | `siete-vidas/arte/felipe/felipe-A-base.png` |
| Felipe animación "quieto" (8 cuadros, 106×106, 8 fps) | `af423ca7-92f4-40e6-a26a-1959363e6892` | `siete-vidas/arte/felipe/felipe-idle-sheet.png` y `felipe-idle.webp` |
| Felipe animación "caminar" (8 cuadros, 106×106) | `5890d9bd-c737-471c-ad0d-30169320104e` | `siete-vidas/arte/felipe/felipe-walk-sheet.png` y `felipe-walk.webp` |
| Felipe Modo Buda (pose editada de A) | `a9b8fd39-5976-492e-8b81-235ed49635cd` | `siete-vidas/arte/felipe/felipe-buda-base.png`; respiración por código en `felipe-buda-quieto-sheet.png` |
| Felipe animación "correr / zoomies" | `9de2013a-ffd6-4cb6-a338-63f80c2d5e78` | `siete-vidas/arte/felipe/felipe-run-sheet.png` |
| Felipe animación "comer snack" | `df2345fe-8e80-42c8-ba44-304490802633` | `siete-vidas/arte/felipe/felipe-eat-sheet.png` |
| Felipe animación "saltar" (poses reales) | `2113c9a5-5acc-4289-8fcb-1f167c20d1ea` | `siete-vidas/arte/felipe/felipe-jump-sheet.png` |
| Felipe animación "zarpazo" | `86da320a-f4cb-4269-ab76-b66648db1e20` | `siete-vidas/arte/felipe/felipe-attack-sheet.png` |
| Felipe híbrido v2 (versiones A y B) | `22529bf7-4fcc-4f41-9b17-488d276a206a` | `siete-vidas/arte/referencias/felipe-hibrido-v2.png` |

## Otras herramientas

- **Motor:** Godot 4 (MIT). En las sesiones en la nube se instala con: descargar `Godot_v4.3-stable_linux.x86_64.zip` de los releases de GitHub en `/opt/godot` y enlazarlo a `/usr/local/bin/godot` (se usa en modo `--headless`). SpriteCook puede exportar paquetes de personaje y tilesets listos para Godot 4.
- **Retoque de pixel art:** Pixelorama (gratis, código abierto) o Aseprite.
- **Niveles:** TileMap de Godot y LDtk.
- **Audio:** Furnace o LMMS (música), jsfxr y Audacity (efectos).
