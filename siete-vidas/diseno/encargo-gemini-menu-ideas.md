# Encargo a Gemini: ideas para el menú de pausa (el creador elige)

El creador vio el menú de estambre (`revisiones/capturas/menu-pausa-actual.png` y `menu-manotazo-actual.png`) y dice que **se ve plano, simple y sin carácter**. Queremos 4 alternativas para que él decida.

## Qué tiene que transmitir

- **Felipe, un gato persa consentido con ego de dios.** No pide perdón y se cree el dueño del barrio. Ver `diseno/pilares.md`.
- **"Épico en su cabeza":** todo se ve épico, como Broforce y Balatro (franjas, letras grandes con contorno, destellos, respuesta jugosa). El chiste está en el choque entre esa epicidad y la realidad cotidiana de un gato.
- **El menú de pausa también será la "Ficha de Su Majestad"** (pilar 4): el retrato de Felipe y sus barras de defensa, carisma y ataque, con una frase satírica cada una, más la velocidad como chiste ("Un rey no corre: lo esperan"). Las alternativas deben dejar sitio para esa ficha junto a los botones Continuar, Opciones, Reiniciar y Salir.
- **Pixel art** con el mismo estilo y la misma paleta cálida del nivel: contorno oscuro de 1 px, resolución base de 640×360. Se juega con teclado y con mando.

## Qué pedirle a Gemini

1. **Primero, ideas en texto:** 6 conceptos distintos de menú de pausa, de 2 líneas cada uno, que cumplan lo de arriba. Incluye estos 4 y propón al menos 2 propios:
   - **Decreto real:** el menú es un pergamino o decreto sellado con la huella de Felipe ("Decretos de Su Majestad"), sobre un cojín de terciopelo, con Felipe coronado al lado.
   - **Pantalla épica tipo Broforce o Balatro:** franjas diagonales, un retrato grande de Felipe de reojo, botones como cartas o placas con contorno grueso y destellos.
   - **Caja de cartón:** Felipe está dentro de una caja de mudanza y el menú está escrito con plumón en las tapas, con arañazos.
   - **Collar y placa:** cada botón es una placa dorada de collar con cascabel, sobre una almohadilla.
2. **Después, maquetas:** que dibuje como imagen las **4 mejores** (las que mejor transmiten carácter y la epicidad de Felipe). Cada una en 16:9, pixel art, como se vería en pantalla: el menú encima del living de Valeria oscurecido, con Felipe (gato persa gris atigrado y blanco, ojos verdes de reojo, ver `arte/felipe/felipe-A-base.png`), los 4 botones con texto en español (Continuar, Opciones, Reiniciar, Salir) y un espacio para la Ficha de Su Majestad.

Referencias que se adjuntan:
- `arte/felipe/felipe-A-base.png`
- `arte/felipe/felipe-retratos.png`
- `diseno/revisiones/capturas/menu-pausa-actual.png`
- una captura del nivel

Guarda en `siete-vidas/arte/referencias/gemini/menu-ideas/`:
- `menu-idea-1.png` a `menu-idea-4.png`;
- `ideas.md`, con los 6 conceptos en texto y cuál es cada maqueta.

Sube todo en un commit a `claude/split-bill-csubjd` con el mensaje "Ideas de menú de pausa, generadas con Gemini".
