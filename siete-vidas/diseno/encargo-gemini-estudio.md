# Encargo a Gemini: estudio de Valeria y A.S.P.I. (rehacer)

Opinión del creador (2026-10-21) sobre el estudio, donde está A.S.P.I.: «la laptop se ve mal, la pizarra con apuntes diminuta y muy lejos; se puede hacer más grande, nadie dijo que tenía que tener esas proporciones; A.S.P.I. se ve mal, creo que es la perspectiva o la falta de animación». Captura: `diseno/revisiones/capturas/regresiones-v5/estudio-v6.png`.

Decisiones de Claude:
- A.S.P.I. hoy es un disco visto desde arriba en una escena vista de lado: por eso se ve plano. Se rehace **de lado, en 3/4 como el resto de la casa**, con sus partes separadas para animarla por código. No se gastan créditos.
- Lo que cuenta la vida de Valeria (teletrabajo, redes, amor por Felipe) se ve **grande, a escala de gato** (CLAUDE.md).

## Texto común

- Estilo pixel art del nivel 1, igual que `arte/referencias/gemini/consistencia-casa.png` y `muebles-sala.png`: contorno oscuro de 1 px, paleta cálida y luz desde arriba a la izquierda.
- Vista lateral en 3/4, como los muebles de la casa.
- Fondo blanco puro #FFFFFF, nada blanco puro dentro de las piezas, piezas separadas 40 px y **sin letras ni números** (los iconos y dibujos sí van).

## Imagen 1: `estudio-v2.png`

1. **Laptop abierta**, vista de lado en 3/4. Pantalla con un fondo de escritorio de un gato persa gris y blanco (Felipe), stickers en la tapa (una huella y un corazón) y una taza de café al lado como pieza aparte. Proporción 1,4 : 1. Al menos el doble de grande que un vaso.
2. **Pizarra de corcho grande** con marco de madera, proporción 3 : 2, llena de cosas de Valeria:
   - 3 fotos polaroid de Felipe en poses ridículas;
   - post-its de colores con dibujitos (sin letras);
   - un calendario con días tachados;
   - un hilo rojo que une dos fotos;
   - chinches.

   Que se vea desde lejos.
3. **Estación de carga de A.S.P.I.**, de lado: una base gris oscura con una luz verde y un enchufe con cable.

## Imagen 2: `aspi-lateral.png`

A.S.P.I. (Aspiradora de Succión Perfecta Inteligente) es un robot aspirador redondo y gris oscuro, con una franja plateada, un sensor rojo como un ojo arrogante y una luz verde. **Vista de lado en 3/4**: se ve el costado (alto, parachoques y rueda) y un poco la tapa. Mismo estilo que `arte/referencias/gemini/aspi-gemini-1.png`, pero de lado. Piezas separadas:

1. **El cuerpo sin rueda ni cepillo**, con el ojo rojo encendido. Proporción 2,2 : 1 (ancho : alto).
2. El mismo cuerpo con el **ojo enojado** (rojo más intenso y la «ceja» del sensor inclinada).
3. El cuerpo con la **tapa del depósito abierta** y la pelusa asomando: depósito lleno.
4. **Rueda** en 2 cuadros de giro.
5. **Cepillo lateral** (3 cerdas) en 3 cuadros de giro.
6. **Luz LED** encendida y apagada.
7. El cuerpo **apagado**: ojo gris, sin luces y con unas espirales de mareo.

Guardar en `siete-vidas/arte/referencias/gemini/estudio-v2.png` y `aspi-lateral.png`, y subir en un commit a `claude/split-bill-csubjd` con el mensaje «Arte: estudio v2 y A.S.P.I. de lado, generado con Gemini».
