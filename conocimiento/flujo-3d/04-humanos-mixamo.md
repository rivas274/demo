# Humanos: Meshy + Mixamo

## Qué problema resuelve

Tener un personaje humano propio, reconocible y animado (caminar, sentarse, recoger algo) sin animar a mano. Para humanos, el rig y las animaciones ya existen gratis: **Mixamo**.

## Receta paso a paso

### 1. Modelo
- Imagen de entrada de frente, en pose A (brazos un poco separados), fondo quitado, sin otras figuras en la imagen (recorta si Gemini puso varias expresiones lado a lado).
- **Meshy 6 Lite** (plan gratis): forma 10 créditos + textura PBR 10 créditos; descarga gratis. Licencia CC BY 4.0.
- El rig de Meshy para humanos y descargar modelos animados piden plan PRO: no hace falta.

### 2. Pasar a FBX
- Convierte el GLB a FBX en Blender (script), con la **textura incrustada**, de pie, mirando al frente y a su altura real (1,65 m).

### 3. Mixamo (gratis con cuenta de Adobe)
1. Sube el FBX. En el auto-rigger pon los marcadores: mentón, muñecas, codos, rodillas e ingle, con simetría.
2. Elige animaciones (Walking, Breathing Idle, Sitting Idle, Texting, Picking Up…).
3. Descarga en **FBX binario a 30 fps**, sin reducir fotogramas clave.
4. **Baja cada animación «con piel»** (with skin). Ver el error de abajo.
5. Para caminar: o «In Place» activado, o ancla la raíz en el motor y mueve el nodo a la velocidad medida de la animación.

### 4. En Godot
- Carga los FBX directo (Godot 4.3 los importa; también con `FBXDocument` sin abrir el editor).
- La malla y el esqueleto salen de un FBX con piel; las pistas de los demás se copian a ese esqueleto (nombres `mixamorig`).
- **Sin patinar:** ancla la raíz y avanza el nodo a la velocidad medida (1,41 m/s en la animación; 1,33 m/s medida en los pies).
- **Sentarse de verdad:** lleva la cadera del clip sentado a unos 10 cm sobre el asiento.
- Mezclas: 0,25 s entre clips; 0,6 s para sentarse y pararse si no hay clips de transición.
- Objetos en la mano (pelota, celular): Mixamo no los trae; se pegan al hueso de la mano por código.

## El error de los codos al revés

- **Qué se vio:** al juntar las animaciones en un solo GLB en Blender, en reposo, sentada y escribiendo los codos iban hacia adentro, delante de la panza, y los antebrazos hacia afuera. Caminar estaba bien.
- **Causa:** en Blender una acción guarda la pose **relativa al reposo** de cada hueso. La pose de reposo de los FBX **sin piel** no es la misma que la del FBX **con piel** (cambian sobre todo los brazos). Al pasar la acción de uno al otro, la diferencia se suma.
- **No era** el auto-rig de Mixamo ni la copia de pistas.
- **Solución:**
  - cargar los FBX directo en Godot (sus curvas son poses locales absolutas y se copian bien), **o**
  - bajar de Mixamo **cada animación con piel** (todas comparten reposo), **o**
  - en Blender, convertir cada acción al reposo del esqueleto con piel antes de juntarla.
- **Cómo se diagnosticó:** frente y perfil de cada animación en cuatro variantes (GLB tal cual, GLB con la copia, FBX con piel, FBX con pistas copiadas). Comparar fuentes lado a lado aisla la causa rápido.

## Otra opción sin servicios (peor)
- Esqueleto CC0 (Quaternius) reajustado a las proporciones del personaje y pesos por código a los 2 huesos más cercanos. Camina y se sienta, pero queda encorvado (animaciones de otro cuerpo) y con lados manchados. Blender con pesos automáticos daría mejor resultado. Mixamo fue claramente mejor.

## Herramientas

| Herramienta | Costo | Licencia |
| --- | --- | --- |
| Meshy 6 Lite | Gratis (20 créditos por modelo con textura) | CC BY 4.0 con atribución |
| Mixamo (Adobe) | Gratis con cuenta de Adobe | Uso libre en juegos personales y comerciales; no se redistribuyen sueltas como paquete |
| Blender | Gratis | GLB ↔ FBX por script |
| Quaternius Universal Animation Library | Gratis | CC0 |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Codos al revés al juntar clips | Reposo distinto entre FBX con y sin piel | FBX directos o cada animación con piel |
| Pies que patinan | La caminata avanza la raíz | Anclar la raíz y mover el nodo a la velocidad medida |
| Postura encorvada | Animaciones de un cuerpo con otras proporciones | Auto-rig sobre el propio modelo (Mixamo) |
| Al agacharse solo se ve la coronilla | Cámara alta y clip genérico | Revisar el clip en el ángulo de cámara del juego |

## Fuente o ejemplo

- Pasos y descargas: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/valeria/mixamo/README.md` (`glb_a_fbx.py`, `juntar_mixamo.py`).
- Modelo de Meshy: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/valeria/README.md`.
- Carga en Godot: `siete-vidas/prototipos/sala-3d-pixel/scripts/mixamo_carga.gd` y `siete-vidas/prototipos/sala-3d-pixel/scripts/valeria_mixamo.gd`; diagnóstico: `siete-vidas/prototipos/sala-3d-pixel/pruebas/valeria_brazos.gd`.
- Informe: `siete-vidas/prototipos/sala-3d-pixel/INFORME.md` («Valeria de Meshy con animaciones de Mixamo»).
