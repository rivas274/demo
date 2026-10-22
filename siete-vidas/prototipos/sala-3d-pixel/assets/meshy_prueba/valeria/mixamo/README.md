# Valeria animada con Mixamo (2026-10-22, gratis)

1. `valeria_para_mixamo.fbx`: `../valeria_meshy.glb` convertido en Blender con `glb_a_fbx.py`.
   - Textura incrustada, de pie, mirando al frente, escalado a 1,65 m.
2. Mixamo, con la cuenta de Adobe del creador:
   - Auto-rigger con marcadores en mentón, muñecas, codos, rodillas e ingle (simetría activada).
   - Esqueleto estándar de 65 huesos.
3. Descargas gratis en FBX binario a 30 fps, sin reducción de fotogramas clave:

| Archivo | Animación de Mixamo | Piel | Cuadros |
|---|---|---|---|
| `valeria_walking.fbx` | Walking ("Caminando"), sin "En su lugar" | **con piel** (malla, esqueleto y textura) | 32 |
| `valeria_breathing_idle.fbx` | Breathing Idle ("Respiración en reposo") | sin piel | 299 |
| `valeria_sitting_idle.fbx` | Sitting Idle ("Sentado ocioso") | sin piel | 130 |
| `valeria_texting.fbx` | Texting While Standing | sin piel | 708 |
| `valeria_picking_up.fbx` | Picking Up ("Recogiendo") | sin piel | 288 |

4. **`valeria_animada.glb`**: un solo archivo para el juego (Three.js), hecho con `juntar_mixamo.py`.
   - Malla con textura, 1 skin y 5 animaciones con nombre: `walking`, `idle`, `sitting_idle`, `texting`, `picking_up`.
   - Pesa 10,8 MB.
5. `valeria_animaciones_cuadros.png`: 4 cuadros de cada animación, renderizados en Blender desde el GLB.

**Licencias:**
- El modelo es CC BY 4.0, de Meshy (ver `../README.md`).
- Las animaciones de Mixamo se pueden usar gratis en proyectos personales y comerciales, según los términos de Adobe Mixamo.

**Nota:** la caminata no es "in place", así que la raíz avanza. En el juego, o se ancla la raíz o se descarga de nuevo con "En su lugar" activado.
