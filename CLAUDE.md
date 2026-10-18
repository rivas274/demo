# Instrucciones para Claude

Este repositorio contiene el desarrollo del juego **Felipe: Siete Vidas, Cero Disculpas**.

Antes de proponer o construir algo, lee la memoria del proyecto en `siete-vidas/memoria/README.md` y los archivos que enlaza. Ahí están las decisiones ya cerradas, la guía del personaje, las herramientas y los pendientes.

Al cerrar cualquier decisión nueva, actualiza esos archivos.

## Regla fija: cada cambio de un personaje se refleja en tres lugares

Cuando cambies cualquier cosa de un personaje (sprites, animaciones, reglas de movimiento, rasgos), en el mismo trabajo y sin que te lo pidan:

1. **Memoria:** actualiza `siete-vidas/memoria/` (guía del personaje, arte y herramientas con assets y créditos, pendientes).
2. **Ficha de concepto:** regenera la copia local (`python3 siete-vidas/herramientas/pagina_felipe.py siete-vidas/concepto/felipe-concepto.html`) y vuelve a publicar la versión en línea (https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe). Revisa que tablas y textos de la ficha mencionen el cambio.
3. **Juego:** si afecta al juego, aplícalo en `siete-vidas/juego/`, cúbrelo con una prueba y corre las pruebas.

Al terminar, confirma al creador cuáles de los tres actualizaste.

## Regla fija: proporciones

Felipe es un persa grande (unos 8 kilos), grande y no obeso; en el juego debe sentirse así. Al dibujar, generar o colocar cualquier cosa:

- **Felipe mide 67 px de alto** en la resolución base 640×360 (sin contar la cola levantada). Hoy las hojas de 106 px se dibujan al 72 % (`Felipe.ESCALA_SPRITE`); el arte final de Felipe se genera directamente a ~67 px de alto.
- **Escala del mundo: 1,21 px por cm.** Muebles, puertas y objetos usan medidas reales (sofá 45 cm, mesa 75 cm, mesón 90 cm, refrigerador 1,80 m, puerta 2,05 m). Felipe "mide" unos 55 cm con la cabeza: llega casi a la altura de una mesa de comedor.
- **Humanos: 3 Felipes** (Valeria, 1,65 m ≈ 200 px), con proporciones normales. Solo los gatos son Chibi.
- **Otros gatos** a la misma escala que Felipe según su tamaño real (un gato común, un poco más bajo que él).
- **Casas del Barrio Viejo:** techo alto (3,5 m) para dejar espacio a trepar.
- Si cambia el tamaño de Felipe, escalar en la misma proporción su colisión, cámara, velocidades y gravedad, y mantener la comprobación de altura de `prueba_movimiento.gd`.

Detalle y comparación descartada en `siete-vidas/memoria/02-guia-felipe.md` (sección Estilo aprobado) y `siete-vidas/arte/referencias/proporciones-felipe.png`.

## Juego en Godot

El proyecto está en `siete-vidas/juego/` (Godot 4.3, GDScript con tipos). Antes de subir cambios al juego, corre la prueba de movimiento (ver `siete-vidas/juego/README.md`). Si Godot no está instalado en la sesión, instálalo como indica `siete-vidas/memoria/03-arte-y-herramientas.md`.
