# Base de conocimiento para hacer juegos (2D y 3D)

Lo aprendido haciendo *Felipe: Nueve Vidas, Cero Disculpas*: un juego en Godot hecho por **una sola persona, con IA y sin presupuesto**. Está escrito en general («cómo hacer X»), para no empezar de cero en el próximo juego. Los ejemplos de Felipe son solo casos concretos.

Sirve al creador y a cualquier Claude que trabaje en otro proyecto.

## Qué hay

| Carpeta | Para qué |
| --- | --- |
| [flujo-2d/](flujo-2d/README.md) | Juego 2D en pixel art: diseño de niveles con reglas medibles, arte provisional por código, crítica y arte con Gemini gratis, animaciones con SpriteCook, Godot 2D por piezas y datos, equipo de agentes por fases |
| [flujo-3d/](flujo-3d/README.md) | Juego 3D con aspecto de pixel art: de imagen a modelo con IA, texturas, rig y animación de un cuadrúpedo en Blender, humanos con Mixamo, render pixel en Godot, qué falló y por qué, y costos reales |

## Cómo usarla en otro proyecto

1. **Copia la carpeta** `conocimiento/` a la raíz del proyecto nuevo, **o enlázala** desde su `CLAUDE.md`, por ejemplo:
   ```
   ## Conocimiento previo
   Antes de proponer un flujo de arte, animación o niveles, lee `conocimiento/README.md`
   y el flujo que corresponda (`flujo-2d/` o `flujo-3d/`).
   ```
2. Copia también los **principios de trabajo** de abajo al `CLAUDE.md` nuevo: son reglas, no sugerencias.
3. Las rutas que empiezan con `siete-vidas/` son del repositorio de Felipe. Sirven de ejemplo; en otro proyecto puede que no existan.
4. **Actualízala** cuando aprendas algo que sirva para cualquier juego (no solo para el actual). Anota el problema, la solución estándar y su fuente.

## Principios de trabajo (generales)

### 1. No reinventar la rueda
- Casi nunca somos los primeros con un problema. **Antes de inventar, busca el método estándar** de la industria: herramientas establecidas (Blender, Rigify, Mixamo, Godot), documentación, tutoriales, foros y juegos que ya lo resolvieron.
- Usa esa receta y adáptala. Si inventas algo propio, dilo y explica por qué la receta estándar no servía.
- **Si algo falla dos veces, para.** Pregúntate qué haría un profesional senior de ese campo. Nombra la causa de fondo y el método estándar antes del tercer intento.
- Caso real: animar un gato 3D hecho con IA tomó 8 intentos con fórmulas propias. Lo que funcionó fue la receta de cualquier artista 3D: retopología, horneado, Rigify, pesos automáticos y poses clave (ver [flujo-3d/06-que-fallo-y-por-que.md](flujo-3d/06-que-fallo-y-por-que.md)).

### 2. Cinco intentos por generación con IA
- Para modelos 3D, piezas, imágenes y animaciones: genera **5 o más variantes** (otras semillas u otras entradas).
- Compáralas con **una medida objetiva** (por ejemplo: cerrada o no, número de trozos, simetría, cuánto patina el pie) **más una revisión visual**, y quédate con la mejor.
- Antes de mostrar el resultado, di cuántos intentos se hicieron.
- Caso real: piezas de HoloPart que salían en 50 a 100 trozos pasaron a piezas cerradas solo cambiando la semilla.

### 3. Avisar el costo antes de gastar
- Si una llamada gasta créditos o dinero, primero muestra **el prompt, el modelo, los ajustes y el costo** (también el de los 5 intentos). Se gasta solo con un «sí» del creador.
- Revisa el saldo antes y anota el gasto después.

### 4. Revisar visualmente antes de mostrar
- Las pruebas en verde son el piso, no la meta. Antes de mostrar algo, **míralo**: capturas al tamaño real y ampliadas, y el video completo revisado en hojas de cuadros (uno cada 2 s).
- Busca la lista de errores ya conocidos (ver [flujo-2d/04-errores-y-lecciones.md](flujo-2d/04-errores-y-lecciones.md)). Si el creador lo vería en 5 segundos, no está terminado.

### 5. Comparar cada versión con la anterior
- Lo que ya estaba aprobado no puede empeorar. Toda versión nueva se muestra **lado a lado con la anterior** (hoja «antes y después» o GIF arriba/abajo).
- Revisa en especial lo que no se tocó a propósito: en Felipe 3D, simetrizar aplanó la cara y una animación aplastó la mano sin que nadie lo pidiera.

### 6. Preferir lo local y gratis
- Primero lo que corre en la PC propia o en la nube sin pagar (Blender, Godot, modelos de IA locales, Gemini con la cuenta propia, Mixamo, assets CC0).
- Los servicios «gratis» suelen cobrar por **descargar**, por **la versión buena** o por **repetir**. Revisa eso antes de invertir tiempo (ver [flujo-3d/07-herramientas-servicios-y-costos.md](flujo-3d/07-herramientas-servicios-y-costos.md)).
- Revisa siempre la **licencia** de lo que se genera (CC0, CC BY, licencias con exclusiones por país).

### 7. Plazos para los prototipos
- Un prototipo responde **una pregunta** y tiene **fecha de cierre**. Al llegar la fecha se decide SEGUIR, CAMBIAR o DESCARTAR, con un informe.
- Tres veces CAMBIAR sobre la misma idea obliga a considerar DESCARTAR.
- Caso real: el prototipo 3D de Felipe tuvo plazo hasta el domingo 2026-10-25 para decidir entre 3D y 2D.

### 8. Videos en MP4, no GIF
- Para mostrar movimiento, entrega **MP4** (más liviano, más nítido, se puede pausar). El GIF solo para un ciclo corto incrustado en un documento.
- Graba con entrada fija (un bot o un guion) para que el antes y el después sean comparables.

### Otros hábitos que funcionaron
- **Un tema a la vez:** propuesta, opinión del creador, cierre y se pasa al siguiente.
- **Memoria escrita del proyecto:** decisiones cerradas, estado actual y lecciones en archivos que toda sesión lee al empezar.
- **Explicar en simple:** frases cortas, sin jerga o explicándola. El creador quiere aprender el criterio, no solo recibir el arreglo.
- **Una sola fuente de verdad:** lo descartado se borra de la guía vigente; no se guarda historial ahí.

## Fuente o ejemplo

- Reglas originales: `CLAUDE.md` (sección «Pilar de trabajo») y `siete-vidas/memoria/01-decisiones.md` («Pilar de trabajo: no reinventar la rueda»).
- Memoria del proyecto: `siete-vidas/memoria/README.md`.
