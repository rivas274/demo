# Juego (Godot 4.3)

Demo jugable de **Felipe: Nueve Vidas, Cero Disculpas**: el primer nivel, **"La Gran Fuga"** (v4), la casa de Valeria como tutorial. Título → introducción → siete cuartos con puertas, Valeria en la planta baja y la Agenda de Su Majestad (8 travesuras) → escalera de fondo con reja anti-fuga → A.S.P.I. (jefa) en el estudio → el balcón da Caer de Pie y el resumen del día. Se juega sin doble salto, Zoomies ni trepar. Diseño vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md`.

## Cómo jugarlo

- **Descargar:** en GitHub, pestaña *Actions* → flujo "Juego (pruebas y exportación)" → última ejecución → *Artifacts* → `FelipeSieteVidas-Windows`, `FelipeSieteVidas-Linux` o `FelipeSieteVidas-Web`.
- **Versión web descargada:** descomprimir `FelipeSieteVidas-Web`, abrir una terminal en esa carpeta y correr `python -m http.server 8000`; después abrir http://localhost:8000 en Chrome, Edge o Firefox (abrir `index.html` con doble clic no funciona).
- **Desde el editor:** abrir esta carpeta con Godot 4.3 y presionar F5.

| Acción | Teclado | Mando (Xbox) |
| --- | --- | --- |
| Moverse | A / D o flechas | Palanca izquierda o cruceta |
| Trepar (en la cortina; **apagado en el nivel 1**, se gana con Afilar Garras) | W o ↑ | Palanca arriba o cruceta arriba |
| Aferrarse (cuando A.S.P.I. aspira) | Mantener S o ↓ | Palanca abajo o cruceta abajo |
| Entrar por una puerta o subir la escalera de fondo (escalón por escalón) | E o W/↑ junto a la puerta o al pie de la escalera | Y o arriba |
| Pausa | Esc | Start |
| Agacharse y gatear (agachado + saltar = bajar de una repisa) | S o ↓ | Palanca abajo o cruceta abajo |
| Saltar (dos veces = Doble Salto, **apagado en el nivel 1**) | Espacio | A |
| Correr (mantener); Zoomies al tocar (**apagado en el nivel 1**) | Shift | RB |
| Zarpazo | J | X |
| Acción: usar lo cercano (comer, tirar, arañar, pasar, abrir el pestillo, saquear el cajón); la burbuja sobre Felipe dice qué hace | E | Y |
| Frotarse contra Valeria enojada para que lo perdone («Encantar») | E junto a ella | Y |
| Comer un snack del bolsillo (sin nada cerca) | Mantener E 0,6 s | Mantener Y |
| Maullar | Q | B |
| Agenda de Su Majestad (libreta; pausa el juego) | Tab | View / Select |
| Saltar la frase del diálogo | Enter | LB |
| (Ocio: sin tocar nada 8 s, Felipe se acicala, juega o da vueltas) | — | — |

## Estructura

| Carpeta | Contenido |
| --- | --- |
| `escenas/` | `apartamento.tscn` (apartamento de prueba de 1920×454, escena principal) y `felipe.tscn` |
| `scripts/` | `felipe.gd` (movimiento y efectos), `animaciones_felipe.gd` (arma las animaciones desde las hojas), `sala.gd` (sala armada desde datos, con muebles provisionales), `fondo_apartamento.gd` (fondo provisional en capas con parallax), `comida.gd` (comida que se come con el botón de acción), `vaso.gd` (se tira de la mesa: logro), `aspi.gd` (A.S.P.I., primer enemigo), `medidores.gd` (corazones, vidas, báscula y logros), `pantallas.gd` (título, intro, pausa, final y avisos del tutorial), `raton.gd`, `caja_carton.gd`, `calcetin.gd`, `laser.gd` |
| `assets/sonidos/` | Sonidos provisionales generados con `siete-vidas/herramientas/sonidos_demo.py` |
| `assets/felipe/` | Hojas de animación de Felipe (8 cuadros de 106×106) |
| `scripts/` (nivel 1 v4) | `sala.gd` (datos y armado del nivel: cuartos, puertas, arte medido, colisiones, lecciones, agenda, escalera, balcón), `valeria.gd` (Valeria: poses, caminar, regaña, perdona, graba; testigo y oyente), `ensayo_aspi.gd` (A.S.P.I. limpia el vaso del pasillo sin hacer daño), `batalla_aspi.gd` y `presentacion_jefe.gd` (pelea y entrada de 8 pasos reutilizable), `reja.gd` (reja anti-fuga con pestillo), `puerta.gd` (puertas abierta, cerrada, entornada, vano y balcón), `interactivo.gd` (cajón, ropa), `oido_puerta.gd` (Valeria oye maullar del otro lado de la puerta) |
| `scripts/` (sistemas del nivel) | `travesuras.gd` (los junta y conecta con Felipe), `agenda.gd` (Agenda de Su Majestad, datos del nivel 1), `recompensas.gd` (nido, galería, bolsillo, caminos), `libreta.gd`, `hud.gd` (contadores y carteles), `resumen_dia.gd`, `dialogo.gd` y `frases.gd` (retratos, una sola cola), `retrato_valeria.gd` (provisional), `jugo.gd`, `indicador.gd` e `iconos_botones.gd` (Kenney), `recogible.gd`, `aranable.gd` (sofá, puerta entornada), `rascador.gd` (teatro para Valeria; interfaz de testigo), `chispas.gd` (garras afiladas) |
| `assets/kenney/`, `assets/personajes/` | Íconos de botones (Kenney, CC0; ver `assets/CREDITOS.md`), retratos de Valeria y A.S.P.I., y las poses y el caminar de Valeria (`valeria_*.png`) |
| `pruebas/` | Pruebas automáticas (movimiento, escenario, mecánicas, nivel, reglas de diseño, jefe, acciones y sistemas del nivel), `partida.gd` (un bot que juega el nivel completo con los botones de una persona, sin habilidades extra, y sirve para grabar video), `demo_salto.gd` (tramo corto de la sala con entrada fija para grabar el salto antes y después de un ajuste) y capturas (`capturas.gd`, `capturas_sistemas.gd`, `capturas_nivel.gd`) |

## Comandos

```bash
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_nivel.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_reglas_nivel.gd  # reglas de siete-vidas/diseno/reglas-de-niveles.md
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd  # pelea con A.S.P.I.
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_acciones.gd  # maullar, arañar, snacks, escalera, rascador, agenda, diálogo, indicador
# Capturas a 640×360 del Indicador, el diálogo, la libreta, los carteles y el resumen:
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_sistemas.gd -- /tmp/capturas
# Capturas de cada cuarto (agregar --debug-collisions para ver las colisiones sobre el arte):
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_nivel.gd -- /tmp/cuartos
# Partida completa jugada por un bot (prueba de que el nivel se puede terminar sin doble salto, Zoomies ni trepar):
godot --headless --path siete-vidas/juego --fixed-fps 60 --script res://pruebas/partida.gd
# Video del gameplay (secuencia PNG + WAV a 30 fps con el modo de grabación de Godot, en una pantalla virtual):
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --write-movie /tmp/video/c.png --fixed-fps 30 --script res://pruebas/partida.gd
ffmpeg -framerate 30 -i /tmp/video/c%08d.png -i /tmp/video/c.wav -vf scale=1280:720:flags=neighbor -c:v libx264 -pix_fmt yuv420p -crf 22 -c:a aac partida.mp4
```

## Reglas de código

- GDScript con tipos en todo (`var x := 1.0`, `-> void`), nombres en español.
- Datos separados de la lógica: animaciones en `AnimacionesFelipe.HOJAS`, salas en `Sala.PIEZAS`, valores de movimiento como `@export`.
- Resolución base 640×360 con escala entera y filtro nítido; nada de suavizado en sprites.
- Cada cambio de movimiento debe pasar `prueba_movimiento.gd`; si se agrega una mecánica, se agrega su comprobación.
- **El salto del juego debe seguir las reglas de la ficha de concepto** (fases y cuadros en las constantes `CUADRO_*` de `felipe.gd`): sube estirado, arriba recoge las patas, cae en picada con la pose "caer" (delanteras estiradas hacia el suelo), toca primero con las delanteras (pose de contacto), después baja la parte de atrás y se aplasta, con polvo y estela. `prueba_movimiento.gd` comprueba estas reglas; no las quites.
- **Arte provisional:** el escenario es una prueba de concepto dibujada con código. El arte final se cambia después en `FondoApartamento` y en `Sala._dibujar_mueble`, sin tocar colisiones ni lógica.
- **Parallax:** el fondo va en capas `Parallax2D` definidas en `FondoApartamento.CAPAS` (cielo 0.05, ciudad lejana 0.2, ciudad cercana 0.45, pared y juego 1.0, primer plano 1.3). `prueba_escenario.gd` comprueba que cada capa siga a la cámara en su proporción y que todos los muebles se puedan alcanzar saltando; al mover muebles, debe seguir pasando.
- **Proporciones:** Felipe mide 67 px de alto (`Felipe.ESCALA_SPRITE` = 0.72) y el mundo va a 1,21 px por cm con muebles de medidas reales (ver los comentarios de `Sala.PIEZAS`). Si cambia el tamaño de Felipe, escalar en la misma proporción su colisión, cámara, velocidades y gravedad. `prueba_movimiento.gd` comprueba su altura.
