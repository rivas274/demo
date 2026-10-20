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

Arquitectura por piezas y datos (2026-10-20): mapa completo, lista de piezas y recetas en `siete-vidas/memoria/07-arquitectura.md`.

| Carpeta | Contenido |
| --- | --- |
| `escenas/` | `nivel_1.tscn` (escena principal: raíz `Nivel`, `Felipe`, `Interfaz` y el `Guion` del nivel 1) y `felipe.tscn` (con su pieza `Vida`) |
| `escenas/entidades/` | `raton.tscn`, `aspi.tscn`, `caja_carton.tscn`, `comida.tscn`, `objeto_tirable.tscn` |
| `datos/` | Datos en recursos `.tres`: `enemigos/` (ratón, A.S.P.I.) y `objetos/` (vaso, taza, maceta, llaves, tazón, pollo) |
| `scripts/componentes/` | Piezas con un solo trabajo: `Vida`, `RecibeGolpes`, `HaceDano`, `MovimientoPatrulla`, `Tirable`, `Aranable`, `OyeMaullido`, `Asustable`, `SueltaRecompensa`, `SombraContacto`, `Interactivo` y el ayudante `Componentes` |
| `scripts/entidades/` | `Enemigo` (ratón y A.S.P.I.: el mismo script con otros datos), `Apariencia`, `AparienciaAspi`, `Objeto` (lo que se tira) |
| `scripts/datos/` | `DatosEnemigo`, `DatosObjeto` |
| `scripts/nivel/` | Constructor genérico de niveles (`Nivel`), `DatosNivel`, `GuionNivel` (base del guion de cada nivel), `SombrasVivas` |
| `scripts/niveles/nivel_1/` | Nivel 1: `Nivel1` (datos), `GuionNivel1` (eventos y reacciones), `ValeriaPorLaCasa`, `FinalBalcon`, `ArteNivel1`, `DecoradoNivel1` |
| `scripts/felipe.gd`, `scripts/felipe/` | Felipe (estados, movimiento, acciones) y sus partes: `EfectosFelipe`, `AnimadorFelipe`, `ManasFelipe`; `animaciones_felipe.gd` arma las animaciones desde las hojas |
| `scripts/` (resto) | Personajes y sistemas: `valeria.gd`, `batalla_aspi.gd` y `dibujo_batalla_aspi.gd`, `presentacion_jefe.gd`, `ensayo_aspi.gd`, `cajas_mudanza.gd`, `caja_carton.gd`, `comida.gd`, `puerta.gd`, `rascador.gd`, `laser.gd`, `recogible.gd`, `travesuras.gd`, `agenda.gd`, `recompensas.gd`, `libreta.gd`, `hud.gd`, `resumen_dia.gd`, `dialogo.gd`, `frases.gd`, `jugo.gd`, `indicador.gd`, `iconos_botones.gd`, `anuncios.gd`, `capas.gd`, `arte_nivel.gd`, `fondo_apartamento.gd`, `luz_cuarto.gd`, `medidores.gd`, `pantallas.gd` |
| `assets/` | Sonidos provisionales, hojas de Felipe, arte del nivel 1 (`nivel1/`), personajes, luz y Kenney (créditos en `assets/CREDITOS.md`) |
| `pruebas/` | Pruebas automáticas (movimiento, escenario, mecánicas, nivel, reglas de diseño, jefe, acciones, componentes), el bot `partida.gd`, `demo_salto.gd` y capturas (`capturas.gd`, `capturas_sistemas.gd`, `capturas_nivel.gd`, `capturas_luz.gd`) |

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
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_componentes.gd  # las piezas por separado y un enemigo armado solo con datos
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
- **Piezas y datos:** lo nuevo se arma con componentes y datos (`.tres` o constantes del nivel), sin heredar entidades y sin archivos de más de ~600 líneas (`siete-vidas/memoria/07-arquitectura.md`). Animaciones en `AnimacionesFelipe.HOJAS`, niveles en `Nivel1.PIEZAS` y compañía, valores de movimiento como `@export`.
- Resolución base 640×360 con escala entera y filtro nítido; nada de suavizado en sprites.
- Cada cambio de movimiento debe pasar `prueba_movimiento.gd`; si se agrega una mecánica, se agrega su comprobación.
- **El salto del juego debe seguir las reglas de la ficha de concepto** (fases y cuadros en las constantes `CUADRO_*` de `felipe.gd`): sube estirado, arriba recoge las patas, cae en picada con la pose "caer" (delanteras estiradas hacia el suelo), toca primero con las delanteras (pose de contacto), después baja la parte de atrás y se aplasta, con polvo y estela. `prueba_movimiento.gd` comprueba estas reglas; no las quites.
- **Arte provisional:** el escenario es una prueba de concepto dibujada con código. El arte final se cambia después en `FondoApartamento` y en el arte de cada nivel (`ArteNivel1`), sin tocar colisiones ni lógica.
- **Parallax:** el fondo va en capas `Parallax2D` definidas en `FondoApartamento.CAPAS` (cielo 0.05, ciudad lejana 0.2, ciudad cercana 0.45, pared y juego 1.0, primer plano 1.3). `prueba_escenario.gd` comprueba que cada capa siga a la cámara en su proporción y que todos los muebles se puedan alcanzar saltando; al mover muebles, debe seguir pasando.
- **Proporciones:** Felipe mide 67 px de alto (`Felipe.ESCALA_SPRITE` = 0.72) y el mundo va a 1,21 px por cm con muebles de medidas reales (ver los comentarios de `Nivel1.PIEZAS`). Si cambia el tamaño de Felipe, escalar en la misma proporción su colisión, cámara, velocidades y gravedad. `prueba_movimiento.gd` comprueba su altura.
