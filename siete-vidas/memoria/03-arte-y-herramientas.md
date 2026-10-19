# Arte y herramientas

## Decisiones visuales

- **Resolución base: 640×360.** Escala exacta a 720p (×2), 1080p (×3) y 4K (×6). Se eligió tras comparar 320×180, 400×240, 480×270 y 640×360 (comparación: https://claude.ai/artifact/LPx28mVsZt5P4zcnoU6nHP).
- **Estilo:** proporciones Chibi para los gatos + acabado Cel-shaded para todo. Ver `02-guia-felipe.md`.
- **Bloques del escenario:** 16×16 px. Fondos con 3 o 4 capas de profundidad (parallax).
- **Parallax (aprobado el 2026-10-17, referencia Silksong):** capas `Parallax2D` de Godot. En el apartamento: cielo 0.05, ciudad lejana 0.2, ciudad cercana 0.45 (se ven por las ventanas), pared y juego 1.0, luz de las ventanas encima de Felipe y primer plano de siluetas (plantas, silla, lámpara) a 1.3. Definidas en `siete-vidas/juego/scripts/fondo_apartamento.gd` (`CAPAS`).
- **Arte provisional:** mientras se afina el concepto, escenarios y muebles se dibujan con código con la paleta del distrito; el arte final llega después.
- **Paleta por distrito:** Barrio Viejo (terracota y atardecer), Neón (noche azul con magenta y cian), Downtown (gris azulado y dorado), Muelle (verde azulado y óxido), Basurero (oliva, café y verde tóxico), Torres Paradise (blanco, amarillo de obra y rojo).
- **Interfaz:** sátira de redes sociales (afecto = corazones, respeto = garras; el peso no va en la interfaz; diálogos como burbujas de chat; logros como notificaciones).
- **Música:** un estilo por distrito; sin actores de voz. Aún no se cerró en detalle.

## SpriteCook (generador de arte con IA)

- **Conectado** como conector en claude.ai (`https://mcp.spritecook.ai/mcp/claude`). Plan de pago "apprentice" desde el 2026-10-17 (800 créditos, 4 trabajos a la vez).
- **Subir imágenes locales:** `create_asset_upload`, luego PUT con curl a la URL devuelta, luego `finalize_asset_upload`.
- **Red del entorno:** deben estar permitidos `mcp.spritecook.ai` y `api.spritecook.ai`; sin el segundo no se pueden descargar ni ver las imágenes.
- **Proyecto en SpriteCook:** "Siete Vidas, Cero Disculpas" (nombre antiguo del juego; se deja así en SpriteCook), id `126fcb42-c3f6-40b5-9f75-42715fbdce40`. Pasar siempre `project_id`.
- **Créditos:** 800 del plan de pago; quedan **264** (2026-10-19, tras subir_escalera, maullar y aranar; reserva aprobada de 26 para rehacer). Subir imágenes no gasta créditos. Comprobar con `get_credit_balance` antes de gastar.
- **Regla de oro:** mostrar al creador el prompt, el modelo, los ajustes y el costo, y esperar aprobación antes de cada llamada que gaste créditos.

### Modelos y costos útiles (consultados el 2026-10-17)

| Modelo | Costo 1K | Nota |
| --- | --- | --- |
| `gemini-3.1-flash-lite-image` (Nano Banana 2 Lite) | 8 créditos | El más barato; usado en v1 con buen resultado; hasta 14 referencias |
| `gpt-image-2.5-flare` calidad low | 5 créditos + 8 por imagen de referencia | Soporta transparencia |
| `gemini-nano-banana-2.1` (por defecto) | 12 créditos | |

### Costos de animación (consultados el 2026-10-17)

- `animate_game_art` sobre un asset existente: 20 créditos por animación de 8 cuadros.
- `animate_game_art` con `model="pixel-engine-v1.5"`: **26 créditos** por 8 cuadros (comprobado el 2026-10-18; se había cotizado en 20 por error). Cotizar siempre con el precio del modelo elegido.
- Flujo guiado de personaje (`generate_character` + `generate_character_animations`): 12 por el personaje base, 20 por animación, +12 para preparar las poses de caminar o correr.

### Cómo se hace el arte de Felipe

- **Consistencia primero (regla del creador, 2026-10-18):** toda animación se genera con `animate_game_art` (20 créditos, 8 cuadros) **directamente desde Felipe A**, describiendo el movimiento completo, con `auto_enhance_prompt` apagado y "cat stays in place". No se usan poses editadas como paso intermedio: se comprobó que cambian la vista a perfil, las proporciones y la expresión (pasó con caída, gatear, acicalarse y estambre). Los objetos (estambre, comida) van aparte, por código.
- **Revisión antes de usar:** `python3 siete-vidas/herramientas/comparar_felipe.py <salida.png>` pone a Felipe A junto a un cuadro de cada animación al tamaño del juego. Se muestra al creador antes de integrar.
- **Efectos de código (gratis, en Godot y en la ficha):** estirar y aplastar, estela de imágenes fantasma, polvo, inclinación del Doble Salto, parpadeo de daño, vida fantasma, transición de agacharse.
- **Peso:** no tiene arte de Felipe; es un indicador de la interfaz (ver `02-guia-felipe.md`, sección Peso).
- **Tamaños de hoja:** animando Felipe A salen cuadros de 106×106, que se dibujan todos a 0.72. Las poses editadas salen de otros tamaños (80, 164, 234 px) y obligaban a usar otra escala, por eso la cabeza cambiaba de tamaño: no se usan. La prueba de movimiento comprueba que cada animación tenga cuadros de 106 px.
- **Movimientos difíciles (pegarse al piso, poses poco comunes):** el modelo por defecto no los logra desde Felipe A (gatear salió de pie, 20 créditos perdidos). Con `model="pixel-engine-v1.5"` (26 créditos) sí, si el prompt dice cuadro por cuadro qué pasa ("frames 1-3: la cabeza baja hasta los hombros..."): así salieron agacharse/gatear y la caída.
- **Salto (tiempos de la ficha, iguales en Godot):** se agacha (cuadro 1 de `saltar`), sale estirado (2), recoge las patas arriba (3), Doble Salto con ~20° de inclinación, cae en picada (`caer` 0), toca con las delanteras (`caer` 1), baja la parte de atrás (5) y se asienta (6). No usar el cuadro 4 de `saltar` (viene en diagonal).

### Trucos para ahorrar créditos

- Varias ideas en una sola imagen (hojas comparativas en cuadrícula) en vez de una llamada por idea.
- Usar un asset ya generado como `style_asset_ids` para mantener el estilo sin repetir pruebas.
- Hacer bocetos de poses y composición en texto (o a mano) y solo generar cuando la idea esté aprobada.
- Retocar a mano en Pixelorama o Aseprite en vez de regenerar por detalles pequeños.

### Assets de Felipe (vigentes)

Solo lo que se usa (las formas de peso dibujadas, el Modo Buda, la pose sentado, la pose con estambre y la pose agachada se descartaron el 2026-10-18). Todas salen de Felipe A.

| Asset | Godot | Id SpriteCook | Archivo en `siete-vidas/arte/felipe/` |
| --- | --- | --- | --- |
| Felipe A base (diseño aprobado, sin fondo, 86×94) | — | `14b3c27f-798c-4795-84fe-48ed15508247` | `felipe-A-base.png` |
| Quieto (8 cuadros de 106×106) | `quieto` | `af423ca7-92f4-40e6-a26a-1959363e6892` | `felipe-idle-sheet.png` |
| Caminar | `caminar` | `5890d9bd-c737-471c-ad0d-30169320104e` | `felipe-walk-sheet.png` |
| Correr / Zoomies | `correr` | `9de2013a-ffd6-4cb6-a338-63f80c2d5e78` | `felipe-run-sheet.png` |
| Saltar | `saltar` | `2113c9a5-5acc-4289-8fcb-1f167c20d1ea` | `felipe-jump-sheet.png` |
| Caer (8 cuadros desde Felipe A; se usan 3 = cayendo y 5 = contacto; `pixel-engine-v1.5`) | `caer` | `5c509ac4-58f9-4b3f-8dfe-7bb31529e754` | `felipe-caida-sheet.png` |
| Agacharse + gatear (0 a 3 transición, 4 a 7 gateo; `pixel-engine-v1.5`) | `agacharse`, `gatear` | `6ba3fb59-a7ef-441f-bfab-d269ebc5957e` | `felipe-gatear-sheet.png` |
| Zarpazo | `zarpazo` | `86da320a-f4cb-4269-ab76-b66648db1e20` | `felipe-attack-sheet.png` |
| Comer | `comer` | `df2345fe-8e80-42c8-ba44-304490802633` | `felipe-eat-sheet.png` |
| Ronronear | `ronronear` | `4dbc1380-5c45-4066-858c-f1c03a87fb67` | `felipe-purr-sheet.png` |
| Desmayo (cae boca abajo) | `desmayo` | `0e90281b-f940-4f03-ae52-85e6b9d5254b` | `felipe-faint-sheet.png` |
| Collar de la Vergüenza | — | `1893e4a4-4b92-46b1-8b45-efbd5dbcf7e2` | `felipe-cono.png` |
| 9 retratos para diálogos (3×3, 200×200) | — | `7657f269-815f-451f-a58a-17f2d6b2f014` | `felipe-retratos.png` |
| Ocio: acicalarse (de pie, desde Felipe A) | `acicalarse` | `29d8f43c-5f45-46f4-ab18-0c9d70490343` | `felipe-acicalarse-sheet.png` |
| Ocio: jugar (desde Felipe A) | `jugar` | `b8caf6cf-7c3f-4e9c-bb34-a38833bb4c63` | `felipe-jugar-sheet.png` |
| Bola de estambre (recortada de una pose descartada, se mueve por código) | — | — | `estambre-bola.png` |
| Ocio: perseguirse la cola (desde Felipe A) | `vueltas` | `bc3dbbc7-7d04-446f-ae5c-e05f6b7cfb73` | `felipe-vueltas-sheet.png` |
| Trepar (desde Felipe A, `pixel-engine-v1.5`, 26 créditos) | `trepar` (cuadros 3-7) | `e49fc39b-d07a-4369-a9fa-1d365e95411d` | `felipe-trepar-sheet.png` |
| Subir escalera (ciclo por escalón; desde Felipe A, `v1.5`, 26 créditos, 2026-10-19) | `subir_escalera` | `e21218e8-1723-4e37-898d-b3e853066501` | `felipe-subir-escalera-sheet.png` |
| Maullar (desde Felipe A, por defecto, 20 créditos, 2026-10-19) | `maullar` | `37d30556-b7ab-4b4c-a178-350d8cdcaad6` | `felipe-maullar-sheet.png` |
| Arañar (de pie en dos patas; desde Felipe A, `v1.5`, 26 créditos, 2026-10-19) | `aranar` | `516af3a3-e643-4976-91f3-58aa19940204` | `felipe-aranar-sheet.png` |

Referencias de diseño (no se usan en el juego): foto real de Felipe (`a0fbe97b-61b6-4d6d-8cb3-c5b4afaa6a74`, no está en el repositorio), prueba de 4 estilos v1 (`8868e7a2-…`, `../referencias/felipe-prueba-estilos-v1.png`), híbrido v2 A y B (`22529bf7-…`, `../referencias/felipe-hibrido-v2.png`) y comparación de proporciones (`../referencias/proporciones-felipe.png`).

## Gemini (Nano Banana) para imágenes fijas (2026-10-18)

- **Para qué:** imágenes fijas (fondos, muebles, objetos, iconos de interfaz) sin gastar créditos de SpriteCook. **No para animaciones de Felipe**: esas siguen en SpriteCook desde Felipe A (regla de consistencia).
- **Cómo:** la sesión en la nube no llega a la computadora del creador. Se usa su sesión **"gemini"** (`session_013Ns8eeDU68F9CqcFdrmY54`), abierta en su Dell con `claude --chrome` y luego `/remote-control` dentro de Claude (con `claude remote-control` directo NO se carga Chrome). Tiene el repositorio en `C:/demo`, rama del juego, y puede hacer push. Chrome quedó conectado al perfil "perfil leidy", que también tiene iniciada la cuenta de Google del creador. Esa sesión no tiene `send_message`: se le escribe con `send_message` y su respuesta se lee con `list_events` de su sesión o en el commit que suba.
- **Flujo acordado (opción A):** esa sesión genera la imagen, clona `rivas274/demo` y la sube a la rama del juego; la sesión del juego la revisa e integra. **Antes de generar, el creador le escribe "sí, adelante" en su propio chat**: no acepta el permiso si se lo manda otra sesión.
- **Arte del nivel 1:** tandas 1 y 2 (2026-10-18) y tandas 3A, 3B y 3C (2026-10-19) en `siete-vidas/arte/referencias/gemini/`. Gemini entrega JPEG con fondo blanco y a otro tamaño.
- **Del original al juego:** `python3 siete-vidas/herramientas/preparar_arte_nivel.py` (necesita `pip install numpy scipy`) quita el fondo blanco, separa cada pieza de las hojas, quita el blanco encerrado (entre patas y barrotes) y el halo del JPEG, **recorta cada pieza a su borde opaco antes y después de escalar** (M1: ningún margen transparente, así se apoya exacto en su colisión), quita pixeles sueltos de menos de 4 px, escala sin suavizar (escala de gato: alturas casi reales a 1,21 px por cm; lo que le importa al gato, más grande) y deja 74 imágenes en `juego/assets/nivel1/`. Casos especiales: el zapatero se arma con las patas estiradas a 38 px (hueco de 40 para pasar agachado), al pasamanos de la escalera se le borra el contorno del larguero, la reja anti-fuga usa solo su cara de frente (48 px) y los peldaños se ensanchan al paso del pasamanos (25 px). **Valeria** (poses y caminar) sale a `juego/assets/personajes/valeria_*.png` a **una sola escala** (0,378: de pie mide 200 px, 3 Felipes); su caminar de Gemini se alinea cuadro a cuadro por la línea de los pies y el centro de la cabeza (no tiembla; no hizo falta el balanceo por código). En el juego, `ArteNivel` dibuja cada pieza apoyada por su borde de abajo; `Sala.PIEZAS` guarda la colisión medida en la fila opaca del arte y `prueba_reglas_nivel.gd` la compara a ±2 px.
- **En uso (nivel 1 v4):** tanda 3A (puertas de una sola hoja abierta, cerrada, entornada, puerta-ventana cerrada y abierta; mesa y silla separadas; librero de 3 repisas; escalera en dos capas; reja anti-fuga; tazón, pollo y bolsita de premios, que también es el ícono del snack), tanda 3B (poses y caminar de Valeria; retratos), tanda 3C (rascador; sofá con plástico y arañado; cesta del nido vacía, con 3 y llena; zapatero; llaves; microondas; 4 imanes; ratón volcado; caja rota; ventana de la sala con persiana; balcón chico con la luz roja; ventana del pasillo con el toldo y la caja de pizza) y de antes: aparador (consola del pasillo), escritorio, caja de arena, cojín, base de carga, repisa (estirada), vano, cortina, bolas de pelo, manchas, A.S.P.I. (normal, llena y gigante), cuadros (retrato, paisaje, reloj), lámpara, alacenas, mesón, refrigerador, cama (200 × 90), cómoda, ropero, baranda, maceta (también la grande del balcón), vaso, rollo, calcetín, caja, ratón, banquito (del taburete de la cocina), paredes con un tinte por cuarto, azulejos, piso, cielo, dos capas de ciudad y fin del mundo. **No llegó `arriba-extra.png`:** baúl, retrato familiar, caja de recuerdos, pantalla, teclado e impresora del estudio, ropa doblada, calcetines del cajón y papeles se dibujan por código. **Sin usar todavía:** marcas de arañazo sueltas de la tanda 3C (las marcas son de código).
- **API directa (alternativa):** agregar `GEMINI_API_KEY` en la configuración del entorno (se lee en una sesión nueva). La red de la nube sí llega a `generativelanguage.googleapis.com`.

## Recursos gratis de terceros (créditos y licencias)

Lista completa en `siete-vidas/juego/assets/CREDITOS.md` (también va en los créditos del juego). Kenney (CC0) sirve para sonido, partículas e interfaz; **nunca personajes ni fondos**.

| Paquete | Autor | Licencia | En el juego | Para qué |
| --- | --- | --- | --- | --- |
| Input Prompts Pixel 1.0 | Kenney (kenney.nl) | CC0 1.0 (dominio público; uso comercial; atribución no obligatoria, se acredita igual) | `juego/assets/kenney/input-prompts-pixel.png` (hoja de 16 px, descargada el 2026-10-19) y `LICENCIA-input-prompts-pixel.txt` | Íconos de teclas y botones del mando en el `Indicador`, los diálogos, la libreta y el HUD (`scripts/iconos_botones.gd`; si falta la imagen se dibuja una tecla por código) |

## Retratos de Valeria y A.S.P.I. (2026-10-19)

- Hoja de Gemini (tanda 3B): `arte/referencias/gemini/retratos-valeria-aspi.png`. `python3 siete-vidas/herramientas/preparar_retratos.py` la recorta en `juego/assets/personajes/retratos-valeria-aspi.png` (3 × 2 cuadros de 66 px, como los de Felipe): Valeria neutra, enojada, derretida, grabando; A.S.P.I. normal (luz verde) y en alerta (luz roja). La usa `Dialogo`; si falta, queda un retrato provisional por código (`RetratoValeria`).

## Otras herramientas

- **Sonidos provisionales:** `siete-vidas/herramientas/sonidos_demo.py` sintetiza los WAV de la demo (salto, zarpazo, golpe, comer, vidrio, logro, calcetín, caja, y para la pelea: batalla, succión y puf) en `siete-vidas/juego/assets/sonidos/`. Se reemplazarán por sonidos finales.

- **Motor:** Godot 4 (MIT). En las sesiones en la nube se instala con: descargar `Godot_v4.3-stable_linux.x86_64.zip` de los releases de GitHub en `/opt/godot` y enlazarlo a `/usr/local/bin/godot` (se usa en modo `--headless`). Para exportar hacen falta las plantillas: de `Godot_v4.3-stable_export_templates.tpz` (1 GB) basta extraer `linux_release.x86_64`, `windows_release_x86_64.exe` y `version.txt` en `~/.local/share/godot/export_templates/4.3.stable/`. Para capturas o video: `xvfb-run -a godot ... --rendering-driver opengl3`. Para la versión web hace falta además `web_nothreads_release.zip` del mismo paquete (preset "Web" sin hilos, no necesita cabeceras especiales del servidor; pesa ~35 MB, demasiado para un artifact de Claude).
- **Tamaño de Felipe en el juego:** las hojas son de 106×106 y se dibujan a escala 0.72 (Felipe mide 67 px de alto en 640×360; antes era 0.5 y parecía un gatito). Al 72 % los pixeles quedan algo disparejos: sirve para la prueba de concepto, pero **las hojas finales deben generarse directamente a ~67 px de alto** (cuadros de unos 76×76).
- **Escala del mundo:** 1,21 px por cm; muebles con medidas reales (sofá 45 cm, mesa 75 cm, mesón 90 cm, refrigerador 1,80 m). Las casas antiguas del Barrio Viejo tienen techo alto (3,5 m) para dejar espacio a trepar. SpriteCook puede exportar paquetes de personaje y tilesets listos para Godot 4.
- **Retoque de pixel art:** Pixelorama (gratis, código abierto) o Aseprite.
- **Niveles:** TileMap de Godot y LDtk.
- **Audio:** Furnace o LMMS (música), jsfxr y Audacity (efectos).
