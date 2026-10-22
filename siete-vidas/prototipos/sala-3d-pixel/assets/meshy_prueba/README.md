# Prueba de animación en Meshy: Felipe (2026-10-22)

- **Entrada:** `../local3d/felipe_variantes/entrada_gemini_v2_1.jpg`, generada con Meshy 7.1 y textura. Costó 30 créditos (de 145 a 115).
- **Rigging:** "Perro Cuadrúpedo", con altura de 1 m y los 11 marcadores puestos a mano. No costó créditos.
  - Un segundo rigging del mismo modelo aparece con el sello **PRO**, así que no se pudo repetir gratis.
- **Animaciones para cuadrúpedos:** solo hay una, "Caminando", la caminata de perro.
- **Resultado: se ve mal.**
  - La cabeza gira hacia atrás y el cuerpo se deforma.
  - La causa es que el modelo tiene la cabeza girada en 3/4 hacia la cámara, como en la imagen de Gemini. El hueso del cuello del rig de perro espera la cabeza alineada con el lomo.
  - Además, las proporciones chibi (cabeza enorme, patas cortas) no corresponden a un perro.
- **Descarga:** el botón Descargar lleva el sello **PRO**.
  - Formatos ofrecidos: fbx, glb y usdz.
  - Opciones: personaje con rig, animación "Actual" o "Todo agregado", y archivo único.
  - No se descargó nada.

Archivos:
- `felipe_caminar_intento1_pantalla.gif`: grabación de la vista previa en 3/4 y de perfil, pantalla completa.
- `felipe_caminar_perfil_intento1.gif`: 8 cuadros de perfil, recortados.
- `felipe_caminar_perfil_cuadro.png`: un cuadro donde se ve la cabeza girada.

Conclusión: para animar con un rig de cuadrúpedo, la entrada debe ser un perfil puro con la cabeza recta. Para el prototipo, una animación procedural en Three.js (rebote, cola, respiración) sobre el GLB local es gratis y más controlable.

## Modelo descargable gratis: `felipe_meshy.glb` (2026-10-22)

- **Plan Free de Meshy:** permite **10 descargas al mes, solo de modelos hechos con "Meshy 6 Lite"**.
  - Meshy 7.1 y Meshy 6 piden suscripción: Starter cuesta COP 31.000 al mes (24.800 al mes pagando el año), con 20 descargas al mes. Pro cuesta COP 62.000 al mes y tiene descargas ilimitadas.
  - La ventana "Suscríbete para descargar" ofrece FBX, OBJ, GLB, USDZ, STL, BLEND, 3MF y DXF una vez suscrito.
- **Cómo se hizo:** con la misma entrada (`entrada_gemini_v2_1.jpg`), forma en Meshy 6 Lite (10 créditos) y luego textura en Meshy 6 Lite con mapas PBR (10 créditos). Las dos descargas fueron gratis y dejaron el cupo en 8 de 10.
- **Archivos:**
  - `felipe_meshy.glb`: con textura PBR, 88.912 caras, 6 MB.
  - `felipe_meshy_sin_textura.glb`: solo la forma, 1,6 MB.
  - `felipe_meshy_vistas.png`: render en Blender cada 45°.
  - Otros formatos ofrecidos en el plan Free: fbx, obj, glb, usdz, stl, blend.
- **Licencia: CC BY 4.0** (plan Free). Permite uso comercial **con atribución**. En los créditos del juego: "Modelo 3D de Felipe generado con Meshy AI (meshy.ai), CC BY 4.0".

## Cola atigrada (repintada en local, 0 créditos)

En la imagen de Gemini la cola de Felipe salía casi negra, y Meshy la dejó de un solo color oscuro. El Felipe real tiene la cola atigrada.

`pintar_cola.py` repinta la textura sin regenerar nada:

1. La cola es el grupo conectado más grande de caras oscuras.
2. Calcula una línea central de la cola, con tramos de distancia geodésica desde la punta.
3. Pinta 5 anillos con el gris atigrado y el tono de raya de la cabeza, y deja la punta oscura. Conserva el sombreado original.

Archivos:
- `felipe_meshy.glb`: con la cola repintada.
- `felipe_meshy_original.glb`: tal como salió de Meshy.
- `felipe_meshy_vistas.png` y `felipe_meshy_original_vistas.png`: render de cada uno.

Comando: `python pintar_cola.py felipe_meshy_original.glb felipe_meshy.glb 5 42` (anillos, umbral de oscuro).
