# Consulta a Gemini: el nivel 1 no se ve funcional (video v5, 2026-10-20)

El creador vio el video `nivel1-v5.mp4` y dice: «veo muchos errores, los agentes se perdieron; no lo veo funcional y llevamos días en eso». Pide que Gemini **proponga soluciones** antes de tocar más código.

Imágenes adjuntas, en `diseno/revisiones/capturas/regresiones-v5/`:
- `hoja-v5.png`: 10 cuadros del video actual.
- `hoja-v4h.png`: 3 cuadros del video anterior, como comparación.
- `balcon.png`: el final.

## Problemas que vio el creador

1. **Luces de las lámparas:** se perdieron o no se notan. Una revisión anterior quitó los «halos circulares» porque se veían como un filtro pegado.
2. **Capas mal:** en la cocina Felipe camina sobre el mesón y **atraviesa a Valeria**: se dibuja encima de ella al saltar (cuadro t=116). En el balcón, Felipe se monta sobre la maceta de la baranda.
3. **Textos que no se leen o se montan sobre la interfaz:**
   - letreros chicos sobre la escena («¡CRÍTICO!», «¡PLÁSTICO: 0!», «CONTENIDO SENSIBLE»);
   - el cartel «¡TRAVESURA CUMPLIDA!» flotando sobre los muebles con letra diminuta;
   - «¡FIUU! JJJJJJJ», donde la letra no tiene el símbolo de nota musical;
   - la franja «¡DEPÓSITO LLENO!» que tapa el HUD;
   - el nombre del jefe cortado («N…»).

## Preguntas para Gemini (que responda en español y concreto)

1. **Jerarquía de la interfaz:** propón un sistema de zonas fijas en pantalla de 640×360 para el HUD, el diálogo, los carteles grandes (logros y fases del jefe), los textos cortos del mundo («¡CRÍTICO!») y los avisos de botón. Que nada se tape. ¿Cuántos mensajes a la vez como máximo? ¿Qué se muestra, qué se resume y qué se quita? Dibuja una maqueta de las zonas.
2. **Textos del mundo:** ¿cómo los harías legibles en pixel art a 640×360? Tamaño mínimo, contorno, fondo, duración y cantidad máxima. ¿Cuáles quitarías?
3. **Capas de personajes:** ¿cómo resuelven los juegos 2D de vista lateral que un gato pase delante o detrás de una humana? Por ejemplo, ordenar por profundidad, que Valeria esté siempre delante, o que Felipe la esquive o le salte por encima. ¿Qué recomiendas para este juego?
4. **Luz:** ¿cómo mostrar la luz de las lámparas en pixel art sin el «halo de filtro»? Propón 2 o 3 técnicas concretas (por ejemplo: cono de luz en escalones de color, piso iluminado, brillo en la pantalla de la lámpara, oscurecer el resto) y dibuja un ejemplo sobre una captura de la sala o del recibidor.
5. **Lo más importante:** mirando las capturas, ¿cuáles son los 5 problemas que más hacen que se vea «no funcional» o amateur? Ordénalos.

Guardar la respuesta en `siete-vidas/diseno/revisiones/2026-10-20-gemini-regresiones.md` y las imágenes que dibuje en `capturas/regresiones-v5/`. Subir todo a `claude/split-bill-csubjd`.
