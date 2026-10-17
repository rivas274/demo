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
| `escenas/` | `apartamento.tscn` (sala de prueba, escena principal) y `felipe.tscn` |
| `scripts/` | `felipe.gd` (movimiento y efectos), `animaciones_felipe.gd` (arma las animaciones desde las hojas), `sala.gd` (sala armada desde datos) |
| `assets/felipe/` | Hojas de animación de Felipe (8 cuadros de 106×106) |
| `pruebas/` | Prueba automática de movimiento, capturas y video |

## Comandos

```bash
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
# Capturas y video (en la nube, con pantalla virtual):
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/video.gd -- /ruta/cuadros
```

## Reglas de código

- GDScript con tipos en todo (`var x := 1.0`, `-> void`), nombres en español.
- Datos separados de la lógica: animaciones en `AnimacionesFelipe.HOJAS`, salas en `Sala.PIEZAS`, valores de movimiento como `@export`.
- Resolución base 640×360 con escala entera y filtro nítido; nada de suavizado en sprites.
- Cada cambio de movimiento debe pasar `prueba_movimiento.gd`; si se agrega una mecánica, se agrega su comprobación.
- Regla de animación del creador: los gatos aterrizan primero con las patas delanteras.
