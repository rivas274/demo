# Flujo 2D: juego en pixel art con IA y sin presupuesto

Cómo hacer un juego 2D de plataformas en pixel art con Godot, una sola persona y Claude, gastando casi nada. Es el flujo que se usó en el nivel 1 de Felipe y que el creador llamó «ingenioso y económico».

## El ciclo en 4 pasos

```
1. Claude diseña el nivel en papel, con reglas medibles
        ↓
2. Claude lo arma en Godot con arte provisional dibujado por código (gratis)
        ↓
3. Capturas y video → Gemini (gratis, cuenta del creador) critica el nivel
   y genera el arte con encargos exactos (fondo blanco, piezas separadas, sin texto)
        ↓
4. Claude integra el arte, revisa con capturas contra la lista de lecciones
   y vuelve a grabar  ──→ vuelve al paso 3 hasta que el creador apruebe
```

Por qué funciona:
- **Primero se juega, después se pinta.** El arte final no se paga hasta que el nivel divierte.
- **Las reglas son medibles**, así que una prueba automática las revisa en cada cambio.
- **Gemini es gratis** con la cuenta personal y sirve para dos cosas: crítica de arte con ojos frescos y piezas fijas (muebles, fondos, interfaz).
- **SpriteCook (pago, por créditos)** se usa solo para lo que Gemini no hace bien: animaciones del protagonista siempre iguales a una imagen base.

## Archivos

| Archivo | Qué resuelve |
| --- | --- |
| [01-diseno-de-niveles-con-gemini.md](01-diseno-de-niveles-con-gemini.md) | Diseñar un nivel con reglas medibles, armarlo provisional y usar a Gemini como crítico |
| [02-arte-y-animacion.md](02-arte-y-animacion.md) | Arte fijo con Gemini, animaciones consistentes con SpriteCook, escala y proporciones |
| [03-godot-2d.md](03-godot-2d.md) | Godot 2D por piezas y datos, sensación de juego, pruebas, capturas y video sin pantalla |
| [04-errores-y-lecciones.md](04-errores-y-lecciones.md) | Los errores que el creador vio en segundos y la regla que los evita |
| [05-herramientas-y-costos.md](05-herramientas-y-costos.md) | Herramientas, licencias, costos reales y el equipo de agentes por fases |

## Resumen en 5 líneas

1. Diseña el nivel en papel con reglas medibles (enseñar → probar → girar, escala del personaje, descansos, atajos) y una prueba automática que las valide.
2. Arma el nivel jugable con arte provisional por código; no pagues arte hasta que el nivel divierta.
3. Saca capturas y video, y pásaselos a Gemini (gratis) para la crítica y para el arte fijo, con encargos de prompt exacto, fondo blanco, piezas separadas y sin texto.
4. Las animaciones del protagonista salen siempre de una sola imagen base (SpriteCook, unos 26 créditos cada una) y se comparan con ella antes de usarlas.
5. Integra, revisa con capturas contra la lista de lecciones, graba el video y muéstralo antes y después; repite.
