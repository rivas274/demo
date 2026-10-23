# Flujo 3D: personajes de IA animados y render tipo pixel art

> **Estado (2026-10-23):** el creador descartó el 3D para el juego de Felipe; sigue en 2D. El prototipo `siete-vidas/prototipos/sala-3d-pixel/` que citan estas guías se borró del repositorio. Se recupera con `git checkout 8cc2445 -- siete-vidas/prototipos/sala-3d-pixel`. Las recetas y lecciones de esta carpeta siguen valiendo para otros proyectos. La lista completa de lecciones del rig está en `08-lecciones-rig-felipe.md`.

Cómo pasar de una imagen de un personaje a un modelo 3D animado y mostrarlo en Godot con aspecto de pixel art, sin presupuesto. Sale del prototipo `sala-3d-pixel` de Felipe (2026-10-21 a 2026-10-23).

**Estado en Felipe:** prototipo en evaluación. El plazo para decidir entre 3D y 2D es el domingo 2026-10-25. La sala 3D se ve bien; los personajes llegaron a «aceptable, lo mejor que tenemos» solo con la receta estándar de Blender.

## El flujo que funcionó

```
Imagen tipo «figura de vinilo 3D» (Gemini o SpriteCook), 4 patas separadas, cabeza alineada
        ↓
Imagen a 3D: Meshy 6 Lite (gratis, CC BY) o Hunyuan3D-2 mini local (solo forma)
        ↓
Blender (bpy): cerrar con Voxel Remesh → QuadriFlow → Symmetrize → hornear el color
        ↓
Animal: Rigify (metarig de gato) + pesos automáticos + poses clave a mano
Humano: Mixamo (auto-rig y animaciones gratis)
        ↓
GLB → Godot: cámara ortográfica, SubViewport ×3, luz toon en escalones, contorno
```

## Archivos

| Archivo | Qué resuelve |
| --- | --- |
| [01-de-imagen-a-modelo.md](01-de-imagen-a-modelo.md) | Qué imagen dar y qué generador usar para obtener una malla |
| [02-texturas.md](02-texturas.md) | Color en el modelo: horneado, repintado de manchas y por qué no proyectar |
| [03-rig-y-animacion-cuadrupedo.md](03-rig-y-animacion-cuadrupedo.md) | Retopología, esqueleto de gato, pesos y animación con poses clave |
| [04-humanos-mixamo.md](04-humanos-mixamo.md) | Humanos con Meshy + Mixamo y el error de los codos al revés |
| [05-godot-3d-pixel.md](05-godot-3d-pixel.md) | Render 3D que se ve como pixel art en Godot |
| [06-que-fallo-y-por-que.md](06-que-fallo-y-por-que.md) | Los 8 intentos fallidos de animar y sus causas |
| [07-herramientas-servicios-y-costos.md](07-herramientas-servicios-y-costos.md) | Servicios, planes gratis, precios, licencias y coordinación |

## Resumen en 5 líneas

1. La entrada manda: imágenes tipo figura de vinilo 3D (no pixel art plano), con las 4 patas separadas y la cabeza alineada al cuerpo.
2. Meshy 6 Lite da gratis malla y textura descargables (CC BY 4.0, 10 descargas al mes); Hunyuan3D-2 mini corre local gratis pero solo da la forma.
3. Una malla de IA es una estatua: para animarla hay que retopologizar (Voxel Remesh + QuadriFlow + Symmetrize), hornear el color y ponerle un esqueleto estándar (Rigify o Mixamo).
4. Se anima con poses clave a mano mirando video del animal real; las fórmulas, los pesos por distancia y los cortes en piezas fallaron 8 veces.
5. En Godot se ve como pixel art con cámara ortográfica, render a ×3, luz toon en escalones y contorno café; los bordes interiores muy sensibles ensucian.
