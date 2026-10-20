# Encargo a Gemini: piezas para las derrotas (ratón de cuerda y A.S.P.I.)

Decisión del creador (2026-10-20): vencer a un enemigo debe sentirse jugoso, con 5 pasos: destello y congelado, salir volando, «¡POP!», cámara lenta solo en el golpe final del jefe y una marca que queda. **Sin sangre ni nada que sufra (anti-pilar):** los enemigos son juguetes y máquinas, así que se desarman con gracia.

## Texto común

- Estilo pixel art del nivel 1: contorno oscuro de 1 px, paleta cálida y la misma densidad de pixel que `juego/assets/nivel1/raton.png` y `aspi.png`.
- Fondo blanco puro #FFFFFF y nada blanco puro dentro de las piezas.
- Piezas separadas 40 px, **sin texto**, vista de frente o 3/4 como el resto.
- Referencias: `juego/assets/nivel1/raton.png`, `juego/assets/nivel1/aspi.png` y `arte/referencias/gemini/objetos.png`.

## Imagen `derrotas.png`

1. **Ratón de cuerda desarmado:** la carcasa gris del mismo ratón de `raton.png`, abierta por la mitad y vacía, tirada de lado con los ojos en X. Mismo tamaño que el ratón.
2. **Llave de cuerda** dorada, la misma que lleva el ratón en la espalda, suelta, en 4 cuadros de giro (de frente, 3/4, de canto y 3/4 al revés) para que gire sola en el piso.
3. **Resorte** metálico plateado, enroscado, en 2 versiones: estirado y comprimido.
4. **Resorte con alma:** el mismo resorte con dos ojitos y una sonrisa tranquila, como un fantasmita. El juego le baja la opacidad.
5. **Tornillos y engranajes:** 3 tornillos pequeños y 2 engranajes chicos, todos distintos.
6. **Montaña de pelusa gris**, para cuando A.S.P.I. escupe todo lo que aspiró al ser derrotada: un montón de polvo y pelos de gato, con un calcetín y una croqueta asomando. Ancho : alto 2 : 1.
7. **Nube de pelusa**, 3 tamaños para partículas.

Guardar en `siete-vidas/arte/referencias/gemini/derrotas.png` y subir en un commit a `claude/split-bill-csubjd` con el mensaje "Arte de derrotas: ratón desarmado y pelusa de A.S.P.I., generado con Gemini".
