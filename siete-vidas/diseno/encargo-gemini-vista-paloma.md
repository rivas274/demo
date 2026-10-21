# Encargo a Gemini: vista del pasillo sin pizza, con una paloma

El creador (2026-10-21): «no tiene sentido que esté una pizza en el techo de otra casa». Se reemplaza por algo que un gato de verdad miraría por la ventana y que tenga sentido en el toldo de un vecino: **una paloma gorda y engreída**. Sigue siendo el lugar visto del pasillo, al que se vuelve con «Caer de Pie».

## Texto común

Estilo pixel art del nivel 1, contorno oscuro de 1 px, paleta cálida del Barrio Viejo, sin texto y sin blanco puro. Referencias: `juego/assets/nivel1/vista_pasillo.png` (la vista actual) y `arte/referencias/gemini/consistencia-casa.png`.

## Imagen `vista-paloma.png` (2 piezas)

1. **La misma vista del pasillo, SIN la caja de pizza**, proporción 5 : 4 (ancho : alto):
   - pared de ladrillo de la casa de enfrente y el toldo a rayas del vecino, con las rayas claras en crema, no blancas;
   - todo plano, sin degradados;
   - con el toldo despejado para poner la paloma por código.
2. **Paloma gris** de ciudad, gordita, con el cuello tornasol verde y morado y la mirada altanera, de perfil, parada. En 3 poses separadas por 40 px:
   - quieta;
   - picoteando, con la cabeza abajo;
   - inflada, con las plumas del pecho erizadas.

   Tamaño relativo: alto de la paloma de 1/4 del alto de la vista.

Fondo blanco puro #FFFFFF alrededor de las piezas. Guardar en `siete-vidas/arte/referencias/gemini/vista-paloma.png` y subir en un commit a `claude/split-bill-csubjd` con el mensaje «Arte: vista del pasillo sin pizza y paloma, generado con Gemini».
