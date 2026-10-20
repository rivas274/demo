# Encargo a Gemini: menú "Decreto real" y kit de interfaz

Decisión del creador (2026-10-20): el menú de pausa es la idea 1, **Decreto real** (`arte/referencias/gemini/menu-ideas/menu-idea-1.png`). Junto a él va la **Ficha de Su Majestad**, que muestra defensa, carisma, ataque y **peso**, cada uno con una frase graciosa. Toda la interfaz sigue esta misma dirección de arte, así que este encargo **reemplaza la Imagen 2 de `encargo-gemini-consistencia.md`**.

## Texto común

- Mismo estilo que `menu-idea-1.png`, pero en el pixel art del nivel: contorno oscuro de 1 px y paleta cálida (pergamino crema, madera oscura, dorado viejo, rojo terciopelo).
- Fondo blanco puro #FFFFFF y nada blanco puro dentro de las piezas.
- Piezas separadas por 40 px.
- **Sin texto**: el juego pone todas las letras para poder traducirlas.
- Vista de frente, con la luz desde arriba a la izquierda.
- **Felipe no va en estas piezas**: el juego usa sus propios sprites y retratos.

## Imagen 1: `decreto-real.png` (el menú)

1. **Pergamino grande** enrollado arriba y abajo, de proporción 3 : 4, vacío, con los bordes un poco gastados.
2. **Sello de cera** rojo con una huella de gato, en dos estados: entero y recién estampado (aplastado, con salpicaduras de cera).
3. **Botón de pergamino**, un rollito horizontal de proporción 3,2 : 1, en tres estados: normal, resaltado (más claro y con un brillo dorado en los bordes) y apretado (un poco hundido).
4. **Cojín de terciopelo rojo** con ribete y 4 borlas doradas, visto un poco desde arriba, de proporción 2 : 1. Felipe se sienta encima.
5. **Corona dorada pequeña** con tres gemas, para ponerla sobre la cabeza de Felipe por código.
6. **Destello**: una chispa dorada de 4 puntas en 3 tamaños, para cuando se estampa el sello.

## Imagen 2: `kit-interfaz-decreto.png` (resto de la interfaz, misma familia)

1. **Marco de la ficha**, de madera oscura con esquinas doradas, de proporción 2 : 3, con un hueco cuadrado arriba para el retrato y un panel crema abajo para 4 estadísticas. Debe poder estirarse en 9 partes.
2. **Barra de estadística**: un marco vacío horizontal de proporción 8 : 1 con borde oscuro y dorado. Por separado, el relleno en 4 colores: verde, dorado, rojo y azul.
3. **4 íconos de estadística** de 20 × 20, en marquito cuadrado: escudo (defensa), corazón (carisma), espada (ataque) y una **báscula de baño antigua** (peso).
4. **Panel en 9 partes**: pergamino con borde de madera, para el diálogo, la libreta y el resumen del día.
5. **Marco de retrato** para los diálogos, cuadrado y dorado con esquinas.
6. **Etiqueta de logro**: una cinta de pergamino con un sello pequeño.
7. **Marco de la barra de vida del jefe**: horizontal, de proporción 10 : 1, con remates dorados.
8. **Cinta para carteles**: una banda roja con puntas cortadas en V, para los avisos y las fases del jefe.
9. **4 íconos del HUD** de 20 × 20: corazón de vida, libreta o agenda, calcetín y foto vergonzosa.

Referencias: `arte/referencias/gemini/menu-ideas/menu-idea-1.png`, `arte/felipe/felipe-retratos.png` y una captura del nivel.

Guardar en `siete-vidas/arte/referencias/gemini/decreto-real.png` y `kit-interfaz-decreto.png`. Subir en un commit a `claude/split-bill-csubjd` con el mensaje "Arte del menú Decreto real y kit de interfaz, generado con Gemini".
