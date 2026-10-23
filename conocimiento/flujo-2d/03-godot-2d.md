# Godot 2D: piezas, datos, sensación y pruebas

## Qué problema resuelve

Que el código de un juego hecho con IA no se vuelva un archivo gigante imposible de tocar, que el personaje se sienta bien al controlarlo y que cada cambio se pueda comprobar sin abrir el editor (también desde la nube).

## Receta: arquitectura por piezas y datos

1. **Componentes** (nodos hijos con `class_name`, un trabajo cada uno): «tiene vida», «recibe golpes», «hace daño», «patrulla», «se puede tirar», «oye sonidos», «se asusta», «suelta premio». Una entidad es un nodo con las piezas que necesita.
2. **Sin herencia entre entidades:** dos enemigos distintos son la misma entidad con otros datos.
3. **Datos en recursos `.tres`** (`DatosEnemigo`, `DatosObjeto`, `DatosJefe`): cambiar un número no toca código.
4. **Señales (observador):** las piezas avisan (`murio`, `caido`); quien las junta conecta lo que le importa. Sin bus global ni autoloads si no hacen falta.
5. **Patrón Estado** para el protagonista: un archivo por estado con `entrar`, `salir`, `fisica`. Lo que un estado crea se limpia en `salir`.
6. **Patrón Estrategia** para jefes: una pelea común + datos + ataques intercambiables.
7. **Nivel = constructor común + datos + guion + arte.**
8. **Interfaz que solo escucha y muestra:** tema central (colores y letras), textos por clave con `tr()` en un CSV, pila de pantallas, controles leídos del InputMap con remapeo.
9. **Ningún archivo de más de ~600 líneas.** Si crece, se parte.
10. **Una tabla única de capas** (z_index): nada inventa su número.

## Receta: llevar un kit de interfaz pixel art al tema de Godot (2026-10-23)

1. **Cada pieza en el tema, por nombre:** las que se estiran como `StyleBoxTexture` (`texture_margin_left/right` = sus
   cortes; arriba y abajo 0 si los lados son diagonales y el alto es fijo), las demás como íconos. Un script las genera
   desde la tabla del kit (tamaño, medida lógica, ancla, cortes): nadie las escribe a mano.
2. **La sombra y el contorno van como `expand_margin_*`:** así el código dibuja la caja con la medida del layout (la de
   la lámina) y el PNG, con su sombra de 3 px, cae solo en su lugar. Sin esto, cada pantalla suma y resta sombras.
3. **Escribir el texto por la parte de arriba de las mayúsculas** (como la lámina), no por la base: se mide una vez el
   alto de mayúscula de cada letra pixel (Pixel Operator 16: 9 px; Silkscreen 16: 10 px).
4. **Caras y retratos chicos, achicados antes** (caja + alfa de corte duro, con contorno), no escalados en el juego.
5. **Zonas con números de las guías públicas:** zona segura de títulos del 90 % (Xbox), letra de 26 px a 1080p en
   consola (en base 640×360 escalada ×3, 9 px de cuerpo: usar 11), texto grande ×2 con letras pixel a múltiplos de su
   tamaño. Una prueba revisa que ningún estilo del tema baje del mínimo y que toda pieza pedida exista.
6. **Comparar con capturas reales** del juego al lado de la lámina, no con la lámina sola.

**Trampa de Godot 4.3:** no hagas `preload()` de un `.tres` con script en una constante de un script compartido; deja dos copias de la clase y los tipos fallan. Usa `load()`.

## Receta: sensación de juego del plataformas

| Idea | Valor que funcionó | Para qué |
| --- | --- | --- |
| Margen al salir del borde (*coyote time*) | 0,12 s | Saltar un instante después de dejar el borde |
| Salto recordado (*jump buffer*) | 0,15 s | Apretar justo antes de aterrizar cuenta |
| Altura variable | cortar la subida a 0,45 al soltar | Saltos cortos y largos con un botón |
| Caída más pesada | gravedad de caída 1,7 × la de subida, tope de velocidad | Se siente pesado, no un globo |
| Aceleración y frenado | `move_toward` | Arranca y frena con peso |
| Efecto en el cuadro de impacto | señal `frame_changed` + constante del cuadro | El vaso cae cuando la pata llega, no antes |
| Tweens | uno solo por personaje; mátalo antes de crear otro; `TRANS_BACK` o `TRANS_CUBIC` | Sin temblores ni movimiento robótico |

Entrada de jefe en 8 pasos (del video «5 ways to make your boss entry feel EPIC»): sin vuelta atrás, la espera, revelar de abajo arriba, nombre y título, la barra se llena, entra la música, vender el tamaño, el rugido. Durante la pelea: anticipación antes de cada ataque y congelado de 0,1 s + destello + sacudida al golpear.

## Receta: recepción del arte por script

- Una herramienta en Python (PIL, numpy, scipy) que, para cada hoja recibida:
  1. quita el fondo blanco y el halo del JPEG, y el blanco encerrado (entre patas o barrotes);
  2. separa las piezas por componentes conectados;
  3. recorta cada pieza a su borde opaco, escala sin suavizar y vuelve a recortar;
  4. quita pixeles sueltos de menos de 4 px;
  5. guarda con nombre fijo en la carpeta del juego.
- Se vuelve a correr entera cada vez que llega arte: el resultado es reproducible.

## Receta: pruebas, capturas y video sin pantalla

1. Godot en la nube: descargar el binario de los releases de GitHub y correrlo con `--headless`.
2. Pruebas como scripts: `godot --headless --path <juego> --script res://pruebas/prueba_x.gd`. Cubrir movimiento (altura del salto, tamaño del personaje), reglas del nivel, nivel de punta a punta, jefe, interfaz.
3. **Bot** que juega el nivel con los botones de una persona y debe terminarlo.
4. Capturas y video: `xvfb-run -a godot ... --rendering-driver opengl3`; video a MP4 con ffmpeg.
5. **Una prueba inestable se arregla por su causa**, no repitiéndola. Correr varias veces seguidas para confirmar.
6. **Pruebas en verde no bastan**: revisar capturas y video (ver [04-errores-y-lecciones.md](04-errores-y-lecciones.md)).

## Herramientas

| Herramienta | Licencia | Para qué |
| --- | --- | --- |
| Godot 4.3 | MIT (aviso en créditos) | Motor, GDScript con tipos |
| xvfb, ffmpeg | Libres | Capturas y video sin pantalla |
| Python + PIL, numpy, scipy | Libres | Herramientas de arte |
| Kenney (íconos de botones, sonidos, partículas) | CC0 | Interfaz y efectos; nunca personajes ni fondos (rompen el estilo) |
| Pixel Operator (CC0), Silkscreen (OFL) | Libres | Letra pixel sin suavizado, a su tamaño de diseño |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Archivo de 2.000 líneas que nadie entiende | Todo en un script | Reordenar en piezas, datos y estados, con pruebas en verde en cada etapa |
| Prueba que falla 1 de cada 4 | Condición de carrera o posición de inicio mala | Buscar la causa (el personaje caía en otro mueble) y corregirla |
| El personaje tiembla al estirarse | Dos tweens pelean por `scale` | Un solo tween, se detiene antes de crear otro |
| Textos montados en el HUD | Cada sistema pone su texto donde quiere | Zonas fijas de texto y una sola cola de anuncios |
| Capas cruzadas (personaje encima de otro) | z_index sueltos | Tabla única de capas y revisión de cada cruce |

## Fuente o ejemplo

- Arquitectura y recetas: `siete-vidas/memoria/07-arquitectura.md`.
- Guía técnica del personaje (sensación, estados, tweens, jefes, cámara): `.claude/skills/godot-felipe/SKILL.md`.
- Herramienta de recepción del arte: `siete-vidas/herramientas/preparar_arte_nivel.py`.
- Pruebas: `siete-vidas/juego/pruebas/` (por ejemplo `prueba_movimiento.gd`, `prueba_reglas_nivel.gd`, `partida.gd`).
- Instalar Godot en la nube: `siete-vidas/memoria/03-arte-y-herramientas.md` («Otras herramientas»).
