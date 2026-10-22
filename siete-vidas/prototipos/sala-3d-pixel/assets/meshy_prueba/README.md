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
