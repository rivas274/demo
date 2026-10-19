---
name: godot-felipe
description: Guía técnica corta para tocar el código de Felipe en Godot 4.3 sin romper lo que ya funciona - controlador con sensación de juego (margen al salir del borde, salto recordado, aceleración), máquina de estados con enum Estado, animación sincronizada con su efecto (cuadro de impacto con frame_changed), tweens y cámara. Úsala antes de agregar o cambiar una acción de Felipe, en el juego o en un prototipo.
user-invocable: true
---

# Godot para Felipe (guía práctica)

Antes de tocar nada, lee `siete-vidas/juego/scripts/felipe.gd` en la parte que vas a cambiar y `siete-vidas/juego/README.md` (Reglas de código). Esta guía resume cómo está armado y las recetas que conviene seguir; si algo aquí contradice el código, manda el código y se corrige la guía.

## 1. Cómo está armado Felipe

- `Felipe` es un `CharacterBody2D`. Todo el movimiento va en `_physics_process`: leer entrada → `match estado` → ajustar `velocity` → `move_and_slide()` → `_actualizar_suelo()` → `_actualizar_animacion()`.
- **Estado principal:** `enum Estado { SUELO, AIRE, ZOOMIES, ZARPAZO, COMIENDO, ATERRIZANDO, OCIO, DESMAYADO, ARANANDO, MAULLANDO, SUBIENDO_ESCALON, RONRONEANDO }` (12: el tope de la sección 3 antes de pensar en una máquina por nodos).
- **Habilidades por nivel:** `tiene_doble_salto`, `tiene_zoomies` y `puede_trepar` (`@export`, apagadas por defecto: en el nivel 1 no están). Las pruebas que las usan las prenden explícitamente.
- **Estados paralelos como booleanos:** `agachado` y `trepando` conviven con el enum (se puede estar en SUELO y agachado). Es la forma barata de una máquina paralela: no crees `Estado.AGACHADO`.
- **Perillas** con `@export` (velocidades, gravedad, tiempos) y reglas fijas como `const` (`ESCALA_SPRITE`, `DEFORMACION_MAXIMA`, `CUADRO_*`, `ALTO_DE_PIE`). Nombres en español y tipos en todo.
- **Animaciones:** `AnimatedSprite2D` (`$Sprite`) con el `SpriteFrames` que arma `AnimacionesFelipe.crear()` desde `AnimacionesFelipe.HOJAS` (archivo, fps, bucle, cuadros, rango). Agregar una animación es una línea en `HOJAS`.
- **Señales que ya existen:** `aterrizo(fuerza)` y `sonido(nombre)`; úsalas en vez de llamar al sonido o a la cámara desde Felipe.

## 2. Sensación de juego (ya implementada: ajústala, no la reinventes)

| Idea | En `felipe.gd` | Para qué |
| --- | --- | --- |
| Margen al salir del borde (*coyote time*) | `margen_salto` = 0,1 s, `_tiempo_fuera_del_suelo` | Saltar un instante después de dejar el mueble |
| Salto recordado (*jump buffer*) | `salto_recordado` = 0,12 s, `_tiempo_salto_pedido` | Apretar justo antes de aterrizar cuenta |
| Altura variable | `corte_salto` = 0,45 al soltar | Saltos cortos y largos con un botón |
| Caída más pesada | `gravedad_cayendo` > `gravedad`, `caida_maxima` | Se siente un gato de 8 kilos, no un globo |
| Aceleración y frenado | `aceleracion`, `friccion` con `move_toward` | Arranca y frena con peso, sin patinar |

Al cambiar estos números, corre `prueba_movimiento.gd` (mide altura del salto, tamaño de Felipe y reglas de aterrizaje). Si cambia el tamaño de Felipe, escala en la misma proporción colisión, cámara, velocidades y gravedad (`CLAUDE.md`).

## 3. Agregar una acción nueva (por ejemplo, maullar)

1. **Entrada:** acción en el Input Map de `project.godot` (teclado y mando) y en `Felipe.ACCIONES` (así interrumpe el ocio).
2. **Estado:** si Felipe se queda quieto mientras la hace, agrega `Estado.MAULLANDO` y trátalo como `ZARPAZO`/`COMIENDO` en el `match` (frena y aplica gravedad). Si se puede hacer mientras se mueve, usa un booleano o un temporizador, no un estado.
3. **Entrar:** en `_intentar_acciones()`, con su condición (en el piso, no agachado).
4. **Salir:** en `_al_terminar_animacion()` para acciones de un solo ciclo; nunca dejes un estado sin salida.
5. **Animación:** línea en `AnimacionesFelipe.HOJAS` con una hoja desde Felipe A (la encarga el `director-arte`, con costo y aprobación). Mientras no exista, efectos de código.
6. **Prueba:** una comprobación en `prueba_mecanicas.gd` o `prueba_movimiento.gd`.
7. **Tres lugares:** memoria (tabla **Acciones de Felipe**), ficha de concepto (regenerar y publicar) y juego (`CLAUDE.md`).

**¿Cuándo dejar el enum?** Hoy hay 8 estados y 2 booleanos: el enum con `match` alcanza y se lee en un archivo. Si pasa de unos 12 estados o cada acción necesita su propia entrada y salida larga, conviene una máquina por nodos (un nodo por estado con `entrar()`, `salir()`, `fisica()`). Proponlo al creador antes de cambiar; no lo hagas de paso.

## 4. El efecto en el cuadro justo

Un manotazo que tira el vaso antes de que la pata llegue se siente falso (revisor, punto 2). Usa la señal `frame_changed` del `AnimatedSprite2D` y una constante con el cuadro de impacto:

```gdscript
## Cuadro de la hoja "zarpazo" en que la pata toca (mirarlo en la hoja).
const CUADRO_IMPACTO_ZARPAZO := 3
var _objeto_pendiente: Node2D

func _ready() -> void:
	# ...
	sprite.frame_changed.connect(_al_cambiar_cuadro)

func _al_cambiar_cuadro() -> void:
	if sprite.animation == "zarpazo" and sprite.frame == CUADRO_IMPACTO_ZARPAZO:
		_golpear()
		if is_instance_valid(_objeto_pendiente):
			_objeto_pendiente.call("salir_volando", self)
		_objeto_pendiente = null
		sonido.emit("zarpazo")
```

Así está hecho desde el 2026-10-19 (`Felipe._al_cambiar_cuadro`): zarpazo y manotazo en el cuadro 4 (`dar_manotazo(al_impacto)` recibe lo que pasa cuando la pata llega), comer en el 3 (la comida desaparece con `al_comido()`), arañar en el 3 y el 5 (`al_aranar(felipe)` del objetivo) y maullar en el 3. La señal `impacto(tipo)` sirve para el congelado del `Jugo`. `prueba_acciones.gd` comprueba que nada pase antes de su cuadro.

Otras reglas: `animation_finished` solo para animaciones sin bucle; no llames `play()` cada cuadro (usa `_reproducir()`, que ya lo evita); para poses sueltas, `_poner_cuadro()`.

## 5. Tweens (estirar, aplastar, inclinar)

- Hay un solo tween de efectos, `_efecto`: **mátalo antes de crear otro** (`if _efecto: _efecto.kill()`), o dos tweens pelean por `scale` y Felipe tiembla.
- Toda deformación pasa por el límite: `forma.clamp(Vector2.ONE * (1.0 - DEFORMACION_MAXIMA), Vector2.ONE * (1.0 + DEFORMACION_MAXIMA))`. Más de ±8 % deforma la cabeza.
- Multiplica por `_escala_base()` (incluye 0.72), nunca por 1.
- Movimiento natural: `set_trans(Tween.TRANS_BACK)` o `TRANS_CUBIC` con `set_ease(Tween.EASE_OUT)`; lineal se ve robótico.
- En pausa: los nodos con `PROCESS_MODE_ALWAYS` (pantallas, medidores, `PresentacionJefe`) siguen animando; si un tween debe correr en pausa, créalo desde uno de ellos.
- Para hacer algo al terminar, `tween_callback()` en vez de `await` si el nodo puede desaparecer antes.

## 6b. Jefes: entrada y "jugo"

Toda pelea usa `PresentacionJefe`; la entrada sigue estos 8 pasos (del video "5 ways to make your boss entry feel EPIC", @motionbykrit), que están como datos en `PresentacionJefe.PASOS` (y `PASOS_CORTOS`, 1 s, al volver tras perder una vida). Cada jefe solo pone sus datos (nombre, título, `texto_rugido`, colores) y escucha `paso_empezado(nombre)` y `empujon(n)` para sus efectos; la presentación empieza recién cuando terminó el fundido de la puerta:
1. **Sin vuelta atrás:** se cierra la puerta detrás de Felipe (con una frase suya).
2. **La espera:** cuarto vacío, retumbo grave que crece, polvo o pelusa que tiembla.
3. **Revelar despacio:** la cámara empieza abajo (ruedas, pies) y sube hasta la cara.
4. **Nombre y título** grandes, de golpe.
5. **La barra se llena** delante del jugador, con sonido.
6. **Entra la música**, grave y lenta.
7. **Vender el tamaño:** cámara baja; cada paso sacude la pantalla.
8. **El rugido:** una ola de polvo y todo el escenario reacciona (cortinas, papeles, pelusas).

Durante la pelea: **anticipación** antes de cada ataque (se echa atrás, vibra, la luz cambia), **congelar 0,1 s + destello + sacudida** al golpearlo, **polvo y escombros** en cada impacto, **sonido en capas** (grave + crujido + eco). Ningún jefe se gana desde un lugar seguro sin moverse.

## 6. Cámara

- `Camara` (`Camera2D`) es hija de Felipe, con suavizado (`position_smoothing_speed = 7`). `Sala` le pone los límites de cada habitación al cruzar una puerta: la cámara nunca muestra otro cuarto.
- Los jefes usan la cámara y la sacudida de `PresentacionJefe` (`sacudir(segundos)`); no hagas otra presentación ni otra sacudida por jefe (`CLAUDE.md`).
- Si una acción pide temblor (un objeto pesado que cae), suma una sacudida corta y pequeña (pocos px, menos de 0,3 s); en pixel art, desplazamientos enteros para no emborronar.
- Mirar adelante (*look-ahead*): desplazar `offset.x` hacia donde mira Felipe, en `_process`, con un tope pequeño. Proponlo antes; cambia cómo se leen los saltos.

## 7. En un prototipo

Mismas recetas, pero en `siete-vidas/prototipos/<nombre>/` con archivos copiados, sin tocar el juego y sin pruebas obligatorias. Lo que el veredicto apruebe se reescribe en el juego siguiendo esta guía.

## 8. Antes de dar por terminado un cambio del juego

```
godot --headless --path siete-vidas/juego --import
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_movimiento.gd
godot --headless --path siete-vidas/juego --script res://pruebas/prueba_mecanicas.gd
godot --headless --path siete-vidas/juego --fixed-fps 60 --script res://pruebas/partida.gd
```

y las demás pruebas de `siete-vidas/juego/README.md` si tocaste el nivel o el jefe. Pasar las pruebas no significa que se vea bien: mira capturas (agente `qa-juego`).
