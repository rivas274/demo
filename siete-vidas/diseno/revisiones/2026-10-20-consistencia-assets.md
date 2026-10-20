# Revisión de consistencia del arte del nivel 1 (2026-10-20)

Pedido del creador: validar que el arte sea consistente y, si hace falta, regenerarlo con Gemini. La hizo la sesión de Gemini en la Dell, sobre los recortes que ya usa el juego (`juego/assets/nivel1` y `juego/assets/ui`, 236 archivos, rama en `ab48104`). No hay Godot en esa máquina: no se revisó en el juego, solo los PNG.

## 1. Revisión automática (blanco puro y contorno)

**Blanco puro (#FAFAFA o más claro) dentro de la pieza** (la regla es "nada de la pieza en blanco puro"):

| Pieza | % de pixeles opacos en blanco puro |
| --- | --- |
| `aranazo_2.png` | 30,6 |
| `balcon_mini.png` | 22,7 |
| `aspi_gigante.png` | 1,7 (cerdas del cepillo) |
| `visillo_cocina.png` | 1,4 |
| `vaso.png` | 1,3 (reflejo) |
| `comoda.png` | 0,65 |
| `maceta_grande.png` | 0,65 |

Se arregla con código, recoloreando a crema #EDE4D6 en `preparar_arte_nivel.py`. El vaso tiene además un reemplazo en la sección 3.

**Contorno:** los avisos de "sin contorno" en paredes, pisos, cielo, ciudad, cuadros, puertas, polaroids y el hilo del menú son falsos positivos: la pieza llena todo su rectángulo y no tiene borde transparente que medir. `cama.png` (26 % del borde oscuro) se ve bien a ojo.

## 2. Revisión a ojo (hoja de contacto de todas las piezas)

La mayoría del arte es consistente: contorno café oscuro, dos tonos planos y la paleta cálida. Desentonan:

- **`microondas.png`** (de `recibidor-cocina-extra`) y **`monitor.png`** (de `arriba-extra`): sin contorno oscuro, con bordes claros y aspecto plano o vectorial al lado de los muebles.
- **`vaso.png`**: vidrio celeste sin contorno, con un reflejo blanco puro.
- **`pollo.png`** (de `comida-grande`): pintado con más volumen y brillos que el resto.
- **`fin_del_mundo.png`**: mucho más detallada e ilustrada que el resto. Se deja así porque es la escena de la imaginación y el contraste es intencional; lo decide el creador.
- **`escalera_peldanos.png`**: café grisácea y oscura. Va detrás de Felipe a propósito, así que se deja.

## 3. Regenerado con Gemini: `arte/referencias/gemini/correccion-estilo.png`

Una hoja con 4 piezas, con las mismas proporciones que ya usa el juego. Referencias: felipe-A-base, muebles-sala, muebles-cocina, cocina-v2 y consistencia-casa (para que el monitor haga juego con el teclado nuevo). Todas tienen contorno café oscuro y dos tonos planos.

| Pieza | Reemplaza a | Tamaño en el juego | Proporción obtenida |
| --- | --- | --- | --- |
| Microondas crema con puerta oscura y panel | `microondas` (98×54) | 1,8:1 | ≈1,6:1 (pedido de nuevo una vez: el primero salió de 1,3:1) |
| Monitor gris carbón, pantalla azul apagado | `monitor` (44×48) | 0,92:1 | ≈1,07:1 |
| Vaso con agua, vidrio celeste apagado | `vaso` (24×32) | 0,75:1 | ≈0,71:1 |
| Pollo asado en fuente terracota | `pollo` (64×50) | 1,28:1 | ≈1,6:1 |

**Al integrar:** recortar cada pieza a su borde opaco y escalarla sin suavizar a su tamaño, ajustando el alto si la proporción difiere. No se tocó `preparar_arte_nivel.py` ni ningún recorte existente. Gemini entregó JPG; solo se convirtió a PNG.
