# Juego (Godot 4.3)

Prototipo jugable de **Felipe: Siete Vidas, Cero Disculpas**.

## Cómo jugarlo

- **Descargar:** en GitHub, pestaña *Actions* → flujo "Juego (pruebas y exportación)" → última ejecución → *Artifacts* → `FelipeSieteVidas-Windows` o `FelipeSieteVidas-Linux`.
- **Desde el editor:** abrir esta carpeta con Godot 4.3 y presionar F5.

| Acción | Teclado | Mando (Xbox) |
| --- | --- | --- |
| Moverse | A / D o flechas | Palanca izquierda o cruceta |
| Saltar (dos veces = Doble Salto) | Espacio | A |
| Zoomies (tocar = impulso; mantener = correr) | Shift | RB |
| Zarpazo | J | X |
| Acción de gato | E | Y |
| Comer snack | Q | LB |

## Estructura

| Carpeta | Contenido |
| --- | --- |
| `escenas/` | `apartamento.tscn` (apartamento de prueba de 1920×540, escena principal) y `felipe.tscn` |
| `scripts/` | `felipe.gd` (movimiento y efectos), `animaciones_felipe.gd` (arma las animaciones desde las hojas), `sala.gd` (sala armada desde datos, con muebles provisionales), `fondo_apartamento.gd` (fondo provisional en capas con parallax) |
| `assets/felipe/` | Hojas de animación de Felipe (8 cuadros de 106×106) |
| `pruebas/` | Pruebas automáticas de movimiento y de escenario, capturas y video |

## Comandos

```bash
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
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
