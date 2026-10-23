# Herramientas, servicios y costos (3D)

## Qué problema resuelve

Saber qué es de verdad gratis, qué cobra por descargar, qué licencia queda en el resultado y cómo coordinar el trabajo entre la nube, la PC del creador y los servicios web.

## Servicios de IA 3D (vistos en octubre de 2026)

| Servicio | Gratis | Lo que cobra | Licencia del resultado |
| --- | --- | --- | --- |
| **Meshy** | Plan Free: 100 a 200 créditos al mes y **10 descargas al mes, solo de modelos «Meshy 6 Lite»** (forma 10 + textura 10 créditos) | Meshy 7.1, Meshy 6, rig repetido y descargar animados piden plan. **Starter: 31.000 COP/mes** (24.800 pagando el año) con 20 descargas. **Pro: 62.000 COP/mes** (unos 20 USD), descargas ilimitadas | **CC BY 4.0** en el plan gratis (uso comercial con atribución: «Modelo 3D de X generado con Meshy AI (meshy.ai), CC BY 4.0») |
| Meshy: rig de cuadrúpedo | El primero es gratis **una sola vez** | Los siguientes, PRO | Solo trae «caminar de perro»; con un gato chibi rompió el cuello |
| **Tripo** | Genera y muestra la vista previa | La descarga | — |
| **3D AI Studio** | Genera | La descarga | — |
| **Hugging Face (ZeroGPU)**: TRELLIS, TRELLIS.2, Hunyuan3D-2 | Cuota diaria de GPU | La cuota **se agota rápido** («ZeroGPU quota 0s left»); espacios caídos o con fallas a medias | TRELLIS.2: MIT. Hunyuan: licencia de Tencent |
| **Hunyuan3D-2 mini local** | Ilimitado en la PC propia (solo forma) | — | Tencent Hunyuan 3D 2.0 Community License: excluye UE, Reino Unido y Corea del Sur |
| **HoloPart local** | Ilimitado (5,5 a 7,4 GB de VRAM) | — | Revisar la del repositorio |
| **Mixamo** | Auto-rig y animaciones de humanos en FBX, con cuenta de Adobe | — | Uso libre en juegos; no redistribuir las animaciones sueltas |
| **SpriteCook** | — | Créditos: unos 12 por imagen | Declarar IA |
| **Gemini** | Imágenes con la cuenta personal | — | Declarar IA |

## Herramientas locales

| Herramienta | Notas |
| --- | --- |
| **Blender 5.2** | GPL solo como herramienta; lo que produce es tuyo. **`pip install bpy`** lo instala como módulo de Python, **también en la nube** sin pantalla |
| **Rigify** | Complemento de Blender; se usa su metarig de gato como base |
| **Godot 4.3** | MIT; Forward+ para el contorno |
| **BiRefNet** | Quitar fondos |
| Python: trimesh, numpy, scipy, PIL, skimage | Medir, pintar, segmentar |

**Entorno local que corrió (PC del creador):** RTX 4060 de 8 GB, 16 GB de RAM, Windows, carpeta `C:\IA3D`, Python 3.11, torch 2.6 cu124, **transformers 4.48.3 fijado**, Blender 5.2. Con 16 GB de RAM, **una forma por proceso**.

## Costos reales del prototipo 3D de Felipe

| Gasto | Costo |
| --- | --- |
| 4 imágenes de Felipe de pie en SpriteCook | 48 créditos (de 140) |
| Meshy | Unos 70 créditos del plan gratis (incluye 30 de un intento con Meshy 7.1 que no se pudo descargar) |
| Hunyuan local, HoloPart, Blender, Godot, Mixamo, Gemini, assets CC0 | 0 |
| **Dinero** | **0** |

Lección: el intento con Meshy 7.1 gastó 30 créditos en un modelo que el plan gratis no deja bajar. **Revisa qué se descarga gratis antes de generar.**

## Coordinación (una persona, varias máquinas)

- **La PC del creador manejada por Claude con control remoto** (sesión de Claude Code abierta allá con remote control). Configura la PC para que **no se suspenda**, o la sesión se corta a mitad de una generación.
- **Agentes en paralelo en la nube** para lo que no necesita GPU (Blender por bpy, scripts, informes).
- **Plantillas ortográficas con cuadrícula** (perfil y frente) para que el creador marque a mano huesos y cortes; se leen por script con la misma proyección.
- **Videos y fotos del animal real** como referencia de movimiento y de patrón. Notas por video: «salta con impulso de las traseras», «cola en gancho al explorar».
- **Entregables siempre con antes/después** y en MP4.
- **Plazo de decisión** fijo: en Felipe, decidir 3D o 2D el domingo 2026-10-25.

## Cuándo conviene el 3D (estimación del prototipo)

- **A favor:** luz dinámica gratis, escala real automática, reutilización de escenarios modulares, un solo modelo en vez de muchas hojas de sprites.
- **En contra:** cada personaje animal cuesta de 1 a 2 semanas hasta verse bien; un humano, 2 a 4 días; pasar un juego 2D ya avanzado a 3D, 2 a 3 meses.
- Si el juego ya tiene un 2D aprobado, el 3D solo entra si le gana claramente en una comparación lado a lado.

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Créditos gastados en un modelo que no se puede bajar | Generar con un modelo no gratis | Generar solo con Meshy 6 Lite en el plan gratis |
| Cuota de GPU agotada a mitad de prueba | ZeroGPU anónimo | Correr local o con token propio |
| La sesión remota se corta | La PC se suspendió | Desactivar la suspensión durante el trabajo |
| Licencia incompatible | Hunyuan excluye países | Anotar la licencia junto a cada archivo; regenerar con MIT o CC BY para el juego |

## Fuente o ejemplo

- Meshy, precios y descargas: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/README.md`, `siete-vidas/prototipos/sala-3d-pixel/assets/meshy/LEEME.md`.
- Licencias y créditos: `siete-vidas/prototipos/sala-3d-pixel/CREDITOS.md`, `siete-vidas/prototipos/sala-3d-pixel/assets/local3d/LICENCIA.txt`.
- HoloPart: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_partes/README.md`.
- Estado y plazo: `siete-vidas/memoria/05-estado-actual.md` («En curso»).
