# Juego (Godot 4.3)

Demo jugable de **Felipe: Siete Vidas, Cero Disculpas**: el primer nivel, **"La Gran Fuga"**, el apartamento de Valeria como tutorial. Título → introducción → cada mueble enseña un movimiento → A.S.P.I. (jefa) cuida la puerta del balcón → escapar por el balcón da Caer de Pie → pantalla final.

## Cómo jugarlo

- **Descargar:** en GitHub, pestaña *Actions* → flujo "Juego (pruebas y exportación)" → última ejecución → *Artifacts* → `FelipeSieteVidas-Windows`, `FelipeSieteVidas-Linux` o `FelipeSieteVidas-Web`.
- **Versión web descargada:** descomprimir `FelipeSieteVidas-Web`, abrir una terminal en esa carpeta y correr `python -m http.server 8000`; después abrir http://localhost:8000 en Chrome, Edge o Firefox (abrir `index.html` con doble clic no funciona).
- **Desde el editor:** abrir esta carpeta con Godot 4.3 y presionar F5.

| Acción | Teclado | Mando (Xbox) |
| --- | --- | --- |
| Moverse | A / D o flechas | Palanca izquierda o cruceta |
| Trepar (en la cortina) | W o ↑ | Palanca arriba o cruceta arriba |
| Aferrarse (cuando A.S.P.I. aspira) | Mantener S o ↓ | Palanca abajo o cruceta abajo |
| Pausa | Esc | Start |
| Agacharse y gatear (agachado + saltar = bajar de una repisa) | S o ↓ | Palanca abajo o cruceta abajo |
| Saltar (dos veces = Doble Salto) | Espacio | A |
| Zoomies (tocar = impulso; mantener = correr) | Shift | RB |
| Zarpazo | J | X |
| Acción: usar el objeto cercano; si es comida, comerla | E | Y |
| (Ocio: sin tocar nada 8 s, Felipe se acicala, juega o da vueltas) | — | — |

## Estructura

| Carpeta | Contenido |
| --- | --- |
| `escenas/` | `apartamento.tscn` (apartamento de prueba de 1920×454, escena principal) y `felipe.tscn` |
| `scripts/` | `felipe.gd` (movimiento y efectos), `animaciones_felipe.gd` (arma las animaciones desde las hojas), `sala.gd` (sala armada desde datos, con muebles provisionales), `fondo_apartamento.gd` (fondo provisional en capas con parallax), `comida.gd` (comida que se come con el botón de acción), `vaso.gd` (se tira de la mesa: logro), `aspi.gd` (A.S.P.I., primer enemigo), `medidores.gd` (corazones, vidas, báscula y logros), `pantallas.gd` (título, intro, pausa, final y avisos del tutorial), `raton.gd`, `caja_carton.gd`, `calcetin.gd`, `laser.gd` |
| `assets/sonidos/` | Sonidos provisionales generados con `siete-vidas/herramientas/sonidos_demo.py` |
| `assets/felipe/` | Hojas de animación de Felipe (8 cuadros de 106×106) |
| `pruebas/` | Pruebas automáticas de movimiento, escenario y mecánicas, capturas y video |

## Comandos

```bash
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_nivel.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_reglas_nivel.gd  # reglas de siete-vidas/diseno/reglas-de-niveles.md
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd  # pelea con A.S.P.I.
# Capturas y video (en la nube, con pantalla virtual):
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/video.gd -- /ruta/cuadros
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
