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

## Juego en Godot

El proyecto está en `siete-vidas/juego/` (Godot 4.3, GDScript con tipos). Antes de subir cambios al juego, corre la prueba de movimiento (ver `siete-vidas/juego/README.md`). Si Godot no está instalado en la sesión, instálalo como indica `siete-vidas/memoria/03-arte-y-herramientas.md`.
