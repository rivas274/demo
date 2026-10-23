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
| Pausa (menú: Continuar, Reiniciar, Salir; se elige con flechas o W/S y Enter) | Esc | Menu (Start); cruceta y A en el menú |
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
| `escenas/` | `nivel_1.tscn` (escena principal: raíz `Nivel`, `Felipe`, `Interfaz` y el `Guion` del nivel 1) |
| `escenas/entidades/` | `felipe.tscn` (con su pieza `Vida`), `raton.tscn`, `aspi.tscn`, `caja_carton.tscn`, `comida.tscn`, `objeto_tirable.tscn` |
| `escenas/ui/` | Piezas de interfaz: `barra_vida.tscn`, `barra_jefe.tscn`, `contador_recurso.tscn`, `menu_pausa.tscn`, `cuadro_dialogo.tscn` |
| `datos/` | Recursos `.tres`: `enemigos/`, `objetos/`, `jefes/` (`aspi.tres`: fases y ataques) y `ui/tema.tres` (colores, letras y estilos de la interfaz) |
| `traducciones/` | `textos.csv`: textos de la interfaz por clave (español de base) |
| `scripts/componentes/` | Piezas con un solo trabajo: `Vida`, `RecibeGolpes`, `HaceDano`, `MovimientoPatrulla`, `Tirable`, `Aranable`, `OyeMaullido`, `Asustable`, `SueltaRecompensa`, `SombraContacto`, `Interactivo` y el ayudante `Componentes` |
| `scripts/entidades/` | `felipe/` (Felipe, un archivo por estado en `estados/` y sus partes), `valeria/` (comportamiento, aspecto y ruta), `enemigos/` (`Enemigo`, `Apariencia`), `objetos/` (`Objeto`, cajas, comida, rascador, láser, recogibles) |
| `scripts/jefes/` | `PeleaJefe`, `ConductaJefe` y `aspi/` (la pelea con A.S.P.I., sus ataques y su dibujo) |
| `scripts/datos/` | `DatosEnemigo`, `DatosObjeto`, `DatosJefe` |
| `scripts/nivel/` | Lo común a todo nivel: `Nivel`, `DatosNivel`, `GuionNivel`, `Puerta`, `ArteNivel`, `SombrasVivas` |
| `scripts/niveles/nivel_1/` | Nivel 1: datos, guion, `ValeriaPorLaCasa`, `FinalBalcon`, arte, decorado, fondo y luz |
| `scripts/sistemas/` | `Capas`, `Controles` (InputMap y remapeo), `Particulas`, `Travesuras`, `Agenda`, `Recompensas`, `Frases`, `Jugo` |
| `scripts/ui/` | Pantallas, HUD, medidores, diálogo, anuncios, libreta, resumen, indicador, íconos y `PresentacionJefe`; `base/` (`Estilo`, `GestorPantallas`, `MenuUI`) y `piezas/` (`BarraVida`, `ContadorRecurso`, `Cartel`) |
| `assets/` | Sonidos provisionales, hojas de Felipe, arte del nivel 1 (`nivel1/`), personajes, luz y Kenney (créditos en `assets/CREDITOS.md`) |
| `pruebas/` | Pruebas automáticas (movimiento, escenario, mecánicas, nivel, reglas de diseño, jefe, acciones, componentes, interfaz), el bot `partida.gd` (la pelea la juega `bot_pelea.gd`), `demo_salto.gd` y capturas (`capturas.gd`, `capturas_sistemas.gd`, `capturas_nivel.gd`, `capturas_luz.gd`) |

## Comandos

```bash
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_escenario.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_nivel.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_reglas_nivel.gd  # reglas de siete-vidas/diseno/reglas-de-niveles.md
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_jefe.gd  # pelea con A.S.P.I.
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_municion.gd  # munición de la pelea: nada reaparece, la suciedad nunca se pierde, peor caso (unos 3 min)
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_acciones.gd  # maullar, arañar, snacks, escalera, rascador, agenda, diálogo, indicador
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_componentes.gd  # las piezas por separado, estados de Felipe, conductas de jefe y un enemigo armado solo con datos
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_interfaz.gd  # barra de vida, pila de pantallas, menú, textos, controles y tema
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_zonas_texto.gd  # zonas fijas de texto (HUD, diálogo, carteles, palabras) y caracteres de las letras
# Capturas de los cruces Felipe–Valeria y el balcón; con «textos», cada texto en su zona; con «luces», las lámparas:
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_estabilizacion.gd -- /tmp/estab [textos|luces]
# Capturas a 640×360 del Indicador, el diálogo, la libreta, los carteles y el resumen:
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_sistemas.gd -- /tmp/capturas
# Capturas de la pelea con A.S.P.I.: el estudio entero, cada fase, la montaña de pelusa y el estudio destruido al final:
xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --script res://pruebas/capturas_pelea.gd -- /tmp/pelea
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
- **Parallax:** el fondo va en capas `Parallax2D` definidas en `FondoApartamento.CAPAS` (cielo 0.05, ciudad lejana 0.2, ciudad cercana 0.45, pared y juego 1.0; sin primer plano borroso desde el 2026-10-20). `prueba_escenario.gd` comprueba que cada capa siga a la cámara en su proporción y que todos los muebles se puedan alcanzar saltando; al mover muebles, debe seguir pasando.
- **Proporciones:** Felipe mide 67 px de alto (`Felipe.ESCALA_SPRITE` = 0.72) y el mundo va a 1,21 px por cm con muebles de medidas reales (ver los comentarios de `Nivel1.PIEZAS`). Si cambia el tamaño de Felipe, escalar en la misma proporción su colisión, cámara, velocidades y gravedad. `prueba_movimiento.gd` comprueba su altura.
