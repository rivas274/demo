# Godot: 3D que se ve como pixel art

## Qué problema resuelve

Usar escenas y personajes 3D (luz dinámica, escala real, animación por huesos) y que el resultado se lea como pixel art pintado, sin bordes que bailen ni degradados de 3D genérico.

## Receta paso a paso

### 1. Cámara y resolución
1. Renderizador **Forward+** (necesita Vulkan). El renderizador Compatibility de Godot 4.3 no da la profundidad y las normales que pide el contorno interior.
2. **Cámara ortográfica** de lado, inclinada unos 18°.
3. La escena 3D se dibuja en un **SubViewport chico** y se muestra en pantalla con **escala entera** y filtro **nearest**.
4. Tamaño del pixel: **×3** (render de 427×240 para salida de 1280×720) fue el mejor.
   - ×2 (640×360): se nota «3D a baja resolución», muchas diagonales finas.
   - ×4 (320×180): caras y detalles se rompen.
5. **MSAA, FXAA y TAA apagados**; sombras sin suavizado.
6. **La cámara se mueve solo en múltiplos de 1 pixel de render**: así los bordes no tiemblan.
7. Encuadre fijo en metros, independiente del tamaño del pixel (el personaje mide siempre lo mismo en pantalla).

### 2. Luz toon en escalones
- Shader propio: el sol y el relleno cortados en **2 tonos**, la lámpara en **3** (cortes en 0,12 y 0,55).
- Sombra ambiente plana, algo violeta (0,26, 0,22, 0,34).
- Resultado: **3 a 4 tonos por material**, sin degradados.
- La luz dinámica (una lámpara cálida con sombra en anillos, el sol entrando por una persiana) fue **la mayor ganancia** del 3D y es gratis.
- Una paleta global por post-proceso es opcional: corre los colores de lo que ya tiene paleta propia.

### 3. Contorno
- **Contorno exterior** de 1 pixel de render donde salta la profundidad. Color: el tono del objeto oscurecido y mezclado con un **café profundo** (`#29140f`), nunca negro puro.
- **Contorno interior** más claro donde cambian las normales (brazos sobre el cuerpo, cojines, la cola sobre el lomo).
- Umbrales duros, sin medios pixeles. Valores de la sala: profundidad 0,12 m, normal 0,45.
- **Casco invertido** de 1 px (caras traseras empujadas hacia afuera en pixeles de pantalla) como segunda pasada del material del personaje: da una silueta limpia y es lo que más ayuda a leerlo a ×3.
- **Cuidado:** bajar mucho los umbrales del post-proceso (por ejemplo 0,03) o usar casco de 2 px **ensucia el pixel art** con manchas oscuras en todo el escenario. Si un personaje necesita umbrales más finos, aplícalos solo a él.
- El contorno marca también el ruido de la malla (picos en orejas y cola): el modelo tiene que estar limpio.

### 4. Personajes en la escena
- Importa el GLB animado; el material toon usa la textura como color.
- El nodo avanza a la velocidad medida del ciclo; mezclas de 0,2 s entre animaciones.
- Capas extra por código, aditivas: resorte en la cola, respiración, mirada.
- Para ver un GLB o FBX sin abrir el editor: `GLTFDocument` / `FBXDocument` en tiempo de ejecución.

### 5. Escenario
- Kits CC0 (Kenney Furniture Kit) recoloreados con la paleta del juego.
- Alturas reales de los muebles: la escala sale sola.
- La cámara ortográfica no da paralaje: la profundidad se lee por solapamiento e inclinación.

## Herramientas

| Herramienta | Costo | Licencia |
| --- | --- | --- |
| Godot 4.3 Forward+ | Gratis | MIT |
| Kenney Furniture Kit | Gratis | CC0 |
| Quaternius (maniquí animado, animales) | Gratis | CC0 |
| xvfb + ffmpeg | Gratis | Capturas y MP4 sin pantalla |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Bordes que tiemblan al moverse | Cámara en posiciones fraccionarias | Mover la cámara en pasos de 1 pixel de render |
| Contorno interior no aparece | Renderizador Compatibility | Forward+ |
| Escenario lleno de manchas oscuras | Umbrales de bordes muy sensibles | Umbrales de la sala; finos solo en el personaje |
| Se ve «3D genérico» | Muchos tonos y antialias | Luz en 2 a 3 escalones, sin antialias, pixel ×3 |
| Colores corridos a violeta | Paleta global aplicada a todo | Paleta opcional, apagada por defecto |
| Sprite 2D junto a volúmenes 3D choca | Dos estilos distintos | Elegir uno: todo 3D o todo 2D |

## Fuente o ejemplo

- Shaders: `siete-vidas/prototipos/sala-3d-pixel/shaders/toon.gdshader`, `siete-vidas/prototipos/sala-3d-pixel/shaders/bordes.gdshader`, `siete-vidas/prototipos/sala-3d-pixel/shaders/contorno.gdshader`, `siete-vidas/prototipos/sala-3d-pixel/shaders/paleta.gdshader`.
- Escena y cámara: `siete-vidas/prototipos/sala-3d-pixel/scripts/principal.gd` y `siete-vidas/prototipos/sala-3d-pixel/scripts/sala.gd`.
- Valores que funcionaron: `siete-vidas/prototipos/sala-3d-pixel/INFORME.md` («Si se reabre el 3D» y, en la sección v4, «Contorno de dibujo»).
- Créditos de assets: `siete-vidas/prototipos/sala-3d-pixel/CREDITOS.md`.
