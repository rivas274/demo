# Arte y animación 2D con IA

## Qué problema resuelve

Conseguir arte de calidad sin dibujante y sin presupuesto, y que el protagonista **se vea siempre como el mismo personaje** en todas sus animaciones. Con IA, cada generación tiende a cambiar la vista, las proporciones o la cara.

## Reparto de herramientas

| Qué | Con qué | Por qué |
| --- | --- | --- |
| Arte fijo: muebles, fondos, pisos, puertas, interfaz, retratos | **Gemini** (gratis, cuenta personal) | Buena calidad en piezas sueltas, sin costo |
| Animaciones del protagonista | **SpriteCook** (`animate_game_art`, por créditos) | Anima desde una imagen base y mantiene el personaje |
| Efectos: estirar y aplastar, polvo, parpadeo, estela | **Código** en el motor | Gratis y ajustable |
| Objetos que el personaje usa (estambre, comida) | Dibujo aparte + movimiento por código | La IA los deforma si van dentro de la animación |

## Receta: arte fijo con Gemini

1. **Guía de estilo fija desde el día 1:** resolución base, paleta por zona, tipo de contorno, cuántos tonos por color, dirección de la luz. Escríbela en un texto común que va al inicio de cada encargo.
2. **Texto común que funcionó** (adáptalo):
   > «Pixel art chibi cel-shaded, dos tonos planos por color, contorno café oscuro cerrado de 1 px, sin degradados, sin antialias, sin sombra proyectada en el piso, paleta [la de la zona]. Vista lateral recta de juego de plataformas. **Fondo blanco puro #FFFFFF liso**; cada pieza separada de las demás por al menos 40 px de blanco; **sin texto, sin letras, sin números**. Nada de la pieza en blanco puro (lo blanco va en crema #EDE4D6). Cada pieza grande, ocupando su celda. Respetar las proporciones alto : ancho indicadas.»
3. **Adjunta referencias:** la imagen base del protagonista y una hoja ya aprobada (para el estilo).
4. **Pide en tandas grandes** (una hoja con muchas piezas), con una tabla: archivo, contenido, proporción, tamaño en el juego y qué problema arregla.
5. **Letreros en blanco:** el texto lo pone el código con la fuente pixel. Gemini escribe mal y no se corrige sin regenerar.
6. **Recepción automática:** un script quita el fondo blanco y el halo del JPEG, separa las piezas, **recorta cada una a su borde opaco antes y después de escalar**, quita pixeles sueltos y escala sin suavizar (vecino más cercano). Ver [03-godot-2d.md](03-godot-2d.md).
7. **Mide la colisión en el arte:** la superficie que se pisa sale de la fila opaca de la imagen y una prueba la compara a ±2 px.

## Receta: animaciones consistentes con SpriteCook

1. **Aprueba una imagen base** del protagonista (en Felipe, «Felipe A»). Todo sale de ella.
2. **Cada animación se genera directo desde la imagen base**, describiendo el movimiento completo («se sienta y se lame la pata»). **Nunca** desde una pose editada intermedia: cambian la vista (quedan de perfil), las proporciones y la cara.
3. Ajustes que funcionaron: `auto_enhance_prompt` apagado, «the cat stays in place», 8 cuadros.
4. **Movimientos difíciles** (pegarse al piso, poses raras): el modelo `pixel-engine-v1.5` (26 créditos) los logra si el prompt dice **cuadro por cuadro** qué pasa («cuadros 1 a 3: la cabeza baja hasta los hombros…»). El modelo por defecto falló y se perdieron 20 créditos.
5. **Una sola escala para todas las hojas.** Si una hoja sale de otro tamaño de cuadro, se rehace; no se compensa con otra escala (la cabeza cambia de tamaño entre animaciones).
6. **Compara antes de usar:** una hoja con la imagen base junto a un cuadro de cada animación, al tamaño del juego. Si no es el mismo personaje, no entra.
7. **Mide el ciclo de caminar:** el pie apoyado debe retroceder lo que avanza el personaje por cuadro (velocidad ÷ cuadros por segundo). Si no, patina.
8. **Transiciones:** entre poses muy distintas (de pie a agachado) hace falta una animación de transición, no un cambio brusco de hoja.

## Proporciones y escala (lo que decide los saltos)

- **El protagonista es la medida de todo.** En Felipe: 67 px de alto en 640×360; humanos de 3 Felipes (200 px).
- **Alturas de muebles casi reales** (guía de 1,21 px por cm), porque deciden los saltos.
- **Lo que le importa al personaje se ve grande** (comida, juguetes al doble); **nada interactuable menor de 24 px**.
- **Estirar y aplastar como mucho ±8 %**: más deforma la cabeza.
- **Excepción:** lo imaginado por el personaje puede tener cualquier tamaño, solo como decorado sin colisión.

## Trucos para ahorrar créditos

- Varias ideas en una sola imagen (cuadrícula comparativa).
- Usar un asset aprobado como referencia de estilo.
- Bocetos en texto o a mano; generar solo lo aprobado.
- Retocar a mano (Pixelorama, Aseprite) en vez de regenerar por un detalle.

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| El personaje queda de perfil o con otra cara | Se animó desde una pose editada | Animar siempre desde la imagen base |
| La cabeza cambia de tamaño entre animaciones | Hojas de distinto tamaño con escalas distintas | Una sola escala; rehacer la hoja que no calce |
| Muebles que flotan | Margen transparente en la imagen | Recortar al borde opaco y medir la colisión en el arte |
| Halos blancos alrededor de las piezas | JPEG con fondo blanco | Quitar halo y blanco encerrado por script |
| Letreros con faltas | Gemini escribe mal | Pedirlos en blanco; el texto lo pone el código |
| Arte de otra escala o perspectiva | Encargo sin proporciones | Proporción alto : ancho y tamaño final en cada encargo |
| Pies que patinan | Ciclo no medido | Medir el pie apoyado y sacar el ritmo de la velocidad |

## Fuente o ejemplo

- Reglas de consistencia y proporciones: `CLAUDE.md` (secciones «consistencia del personaje» y «proporciones»).
- SpriteCook, costos y tabla de assets: `siete-vidas/memoria/03-arte-y-herramientas.md`.
- Encargos a Gemini: `siete-vidas/diseno/nivel-01-plan-arte.md` (§3, texto común), `siete-vidas/diseno/encargo-gemini-estudio.md`, `siete-vidas/diseno/encargo-gemini-decreto-real.md`.
- Comparar con la imagen base: `siete-vidas/herramientas/comparar_felipe.py`; medir pasos: `siete-vidas/juego/pruebas/medir_pasos.gd`.
