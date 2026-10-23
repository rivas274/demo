# Texturas de un modelo de IA

## Qué problema resuelve

Que el modelo tenga su color bien puesto después de cambiarle la malla (retopología), que los costados no salgan estirados y que el patrón del pelaje se lea en un estilo simplificado.

## Receta paso a paso

### 1. Si el generador no dio textura: no proyectes de frente
- Proyectar la imagen de frente sobre los vértices pinta bien la cara, pero **los costados y la espalda repiten el frente estirado** y quedan manchas oscuras.
- Sirve solo como prueba rápida o para clasificar zonas (colores planos por zona con una paleta corta).
- Mejor: generar con textura (Meshy 6 Lite, gratis) o hornear desde un modelo que sí la tenga.

### 2. Horneado «Selected to Active» (el método estándar)
Cuando cambias la malla (retopología), el color se pasa de la malla vieja (alta) a la nueva (baja):
1. Malla nueva con **UV nuevas**: Smart UV Project con margen entre islas.
2. Imagen vacía de 2048 px en el material de la malla nueva.
3. En **Cycles**, tipo de horneado **Diffuse**, solo **Color** (sin luz directa ni indirecta).
4. Selecciona la malla alta, luego la baja (activa), activa **Selected to Active**, con una pequeña **extrusión** (1,2 cm) y **distancia de rayo** (4 cm) a la escala del modelo.
5. Revisa que ningún texel quede sin dato y rellena el margen de las islas (padding).
- Antes, **suelda la malla alta**: si viene en pedazos con grietas, el horneado pinta líneas blancas por ahí.

### 3. Repintar manchas que la IA no entendió
- Si la textura de IA no tiene el patrón real (puso una «montura» gris), **limpiarla no lo arregla**: los filtros de cierre y apertura dejan siempre un bloque.
- Se dibuja el patrón en un **mapa del cuerpo** (largo a lo largo del eje × ángulo alrededor) y se evalúa en cada texel. Así las costuras UV no lo cortan y, con malla simétrica, queda espejado.
- Bordes con mechones (puntas en dos frecuencias, como pelo), no recortes geométricos.
- Prueba 5 a 7 variantes y mídelas: número de manchas, huecos, simetría, área. Revisa a la resolución del juego.

### 4. Dirección de arte del color (lecciones)
- **En un personaje estilizado, una mancha simple se lee mejor que el patrón real exacto.** El patrón exacto del gato real (dos pares de manchas y bandas) quedó recargado en 3D; el creador pidió volver a una sola montura.
- Revisa a la resolución final (en Felipe, ×3): lo que se ve de cerca puede desaparecer o ensuciarse.
- Las uniones (base de la cola con la grupa) suelen quedar fuera de toda zona pintada y conservan la textura vieja: cúbrelas a propósito.
- Las líneas de pliegue pintadas (donde la pata entra al cuerpo) ayudan de cerca, pero a ×3 casi no se notan; ahí ayuda más el contorno.
- **El cuerpo usa el mismo tono y las mismas rayas que la cabeza.** Muestrea el color de la gorra (claro y oscuro) en la textura de la IA y repite sus rayas, finas (~25 % del período) y en la dirección del cuerpo. Una mancha oscurecida "a ojo" no combina con la cabeza. La cola también lleva rayas (anillos), no un bloque liso.
- **Rasgos chicos a pixel ×3** (boca, nariz): engruesa la línea que ya existe 1 o 2 texels y oscurécela, sin cambiar su forma. Elige el grosor más sutil que deje al menos 1 px oscuro en la resolución final.
- **Volumen toon en los ojos:** un brillo chico y una sombra leve bajo el párpado superior, pintados en la textura. Es reversible y no toca la geometría.
- **Al muestrear colores por percentil,** usa `<=` y no `<`: con valores repetidos la muestra queda vacía, el color sale NaN y toda la textura se pone negra.

## Herramientas

| Herramienta | Costo | Para qué |
| --- | --- | --- |
| Blender (bpy por pip, también en la nube) | Gratis | UV, horneado en Cycles, todo por script |
| Python con numpy, PIL, scipy, trimesh | Gratis | Rasterizar en UV, pintar manchas, medir variantes |
| Meshy 6 Lite | Gratis (10 créditos la textura) | Textura PBR de partida |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Costados y espalda estirados | Color proyectado de frente | Textura generada + horneado a la malla nueva |
| Línea blanca en el lomo | Malla alta en 83 pedazos con grietas | Soldar la malla alta antes de hornear |
| Anillo blanco en la base de la cola | Zona fuera del cuerpo y de la cola al pintar | Que la cola nazca del color del cuerpo |
| Manchas con escalones en las costuras | Pintar directo en la imagen UV | Pintar en un mapa del cuerpo y evaluar por texel |
| Lomo «recargado» | Copiar el patrón real exacto | Una mancha simple y legible |
| Parches negros al achicar una parte de la malla | Los rayos del horneado salen por dentro de la original | Aplicar la misma deformación a la malla de alta antes de hornear |
| Se pierde el relieve fino del pelo | La malla nueva es más lisa que la de IA | Aceptarlo o hornear también un mapa de normales |

## Fuente o ejemplo

- Horneado: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_rig/scripts/02_textura.py`.
- Repintado del lomo con variantes: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_rig/scripts/02b_lomo.py`.
- Cola atigrada repintada sin regenerar: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/pintar_cola.py`.
- Resultados y decisiones (v3 a v6): `siete-vidas/prototipos/sala-3d-pixel/INFORME.md`.
