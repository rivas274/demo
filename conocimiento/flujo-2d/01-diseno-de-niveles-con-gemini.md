# Diseño de niveles con reglas medibles y crítica de Gemini

## Qué problema resuelve

Un nivel diseñado «a ojo» se rehace muchas veces y nadie sabe si cumple lo pedido. Con reglas escritas y medibles, el diseño se revisa en papel, se valida con una prueba automática y la crítica visual llega gratis desde Gemini.

## Receta paso a paso

### 1. Escribe las reglas de niveles una sola vez (para todo el juego)
- Tómalas de juegos que ya lo resolvieron y anota de cuál sale cada una. Ejemplos que funcionaron:

| Juego | Qué tomar | Regla |
| --- | --- | --- |
| Super Mario (1-1, 3D World) | Enseñar sin texto en un lugar seguro; *kishōtenketsu*: presentar, desarrollar, girar, cerrar | Enseñar → probar → girar |
| Celeste | Mecánicas de a una; morir cuesta segundos | Una idea a la vez; reaparecer inmediato |
| Hollow Knight | Bancos cerca de los jefes; atajos que vuelven | Descanso cerca del peligro; atajo que se abre desde el lado lejano |
| Stray | El mundo visto desde el animal; los muebles son el camino | Verticalidad del personaje; guía ambiental, sin flechas |
| Zelda, Mega Man | El jefe se gana con lo que el nivel enseñó | El jefe es un examen |
| Broforce, Cuphead | El jefe se presenta (congelado, nombre en franja, fases) | Presentación reutilizable para todo jefe |

- Marca cada regla como **✔ medible** (la valida una prueba) o **👁 de capturas**.
- Ejemplos medibles: «los avisos de un mismo piso a 150 px o más», «nada que haga daño en los primeros 80 px de una zona de enseñanza», «nada interactuable menor de 24 px», «hueco para pasar agachado de 36 px o más», «al menos 3 coleccionables y uno fuera del camino».
- Regla de oro: si el nivel no cumple una regla, **se cambia el nivel, no la regla**. Cambiar una regla lo decide el creador.

### 2. Escribe los pilares antes del primer nivel
- Fantasía en una frase («Es como X, con Y, y además Z») y 3 a 5 pilares con ejemplos de **sí** y de **no**.
- Los pilares desempatan decisiones y algunos se vuelven reglas de nivel (por ejemplo, «cada habitación tiene una travesura con reacción»).

### 3. Diseña el nivel en papel
- Un documento por nivel con: propósito, recorrido, mapa con medidas en píxeles y **una línea por regla que diga cómo la cumple**.
- Medidas con la escala del personaje: el protagonista es la medida de todo (alto, salto, hueco mínimo).
- Que lo revise un agente revisor (o `/revision-diseno`) y el creador lo apruebe **antes de construir**.

### 4. Arma el nivel con datos y arte provisional por código
- El nivel se describe con datos (habitaciones, ruta, piezas con su colisión, avisos, descansos, atajos, coleccionables) para que la prueba de reglas los lea.
- Muebles y fondos dibujados por código con la paleta de la zona: es gratis y se cambia en segundos.
- Un **bot** recorre el nivel con los mismos botones que una persona y debe terminarlo.

### 5. Captura y graba
- Capturas de cada cuarto al tamaño real (640×360) y ampliadas ×2 a ×4.
- Video del bot jugando entero (MP4). Hojas de cuadros cada 2 s para revisar rápido.

### 6. Pide la crítica a Gemini (gratis)
- Adjunta capturas o hojas y escribe un prompt con rol y referencias. **Pide concreto desde el principio**: la primera respuesta suele salir genérica.
- Prompt que funcionó en la segunda vuelta:
  > «Mira la primera imagen: son los cuartos del nivel en este orden: sala, recibidor, cocina… Para CADA cuarto dame de 2 a 4 cambios concretos, nombrando el objeto que ves y qué cambiar: color, tamaño, posición, capa o detalle. Después dime los 3 objetos que más desentonan en estilo y por qué.»
- Para problemas de sistema (textos que se montan, capas, luz) pregunta «¿cómo lo resuelven los juegos 2D de vista lateral?» y pide 2 o 3 técnicas y una maqueta.
- **Verifica cada punto contra la imagen:** Gemini inventa nombres de objetos. Anota qué se aplicó y qué se descartó, con el porqué.

### 7. Aplica en una sola pasada con plan
- No se corrigen detalles sueltos. Se arma **un plan por cuarto** y se aplica de una vez.
- Después: todas las pruebas en verde, el bot termina, capturas revisadas contra la lista de lecciones y hoja antes/después para el creador.

## Herramientas

| Herramienta | Costo | Para qué |
| --- | --- | --- |
| Godot 4 (MIT) | Gratis | Nivel, bot, pruebas, capturas y video sin pantalla |
| Gemini (gemini.google.com, cuenta personal) | Gratis | Crítica de capturas y arte fijo |
| Claude Code con agentes | Plan de Claude | Diseño en papel, construcción, revisiones |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| El nivel pasa las pruebas pero se ve mal | Se midieron datos, no lo que ve el jugador | Revisar capturas y video entero contra la lista de lecciones |
| Gemini responde con consejos genéricos | Prompt abierto | Pedir por cuarto, nombrando objetos, con cantidad fija de cambios |
| Gemini nombra cosas que no están | Alucina sobre la imagen | Verificar cada punto en la captura antes de aplicarlo |
| Arreglos sueltos que rompen otra cosa | Sin plan | Un plan por cuarto, aplicado de una vez, con antes/después |
| El nivel se rediseña mientras se construye | No se cerró en papel | Aprobar el documento antes de tocar el motor |

## Fuente o ejemplo

- Reglas: `siete-vidas/diseno/reglas-de-niveles.md`; pilares: `siete-vidas/diseno/pilares.md`.
- Nivel en papel: `siete-vidas/diseno/nivel-01-gran-fuga.md`.
- Críticas de Gemini y qué se aplicó: `siete-vidas/diseno/revisiones/2026-10-19-critica-gemini.md`, `siete-vidas/diseno/consulta-gemini-regresiones-v5.md` y `siete-vidas/diseno/revisiones/2026-10-20-gemini-regresiones.md`.
- Prueba de reglas: `siete-vidas/juego/pruebas/prueba_reglas_nivel.gd`; bot: `siete-vidas/juego/pruebas/partida.gd`.
