# De imagen a modelo 3D con IA

## Qué problema resuelve

Tener un modelo 3D de un personaje propio sin modelador. La IA de imagen a 3D lo hace en minutos, pero el resultado depende sobre todo de **la imagen de entrada** y de **qué servicio deja descargar gratis**.

## Receta paso a paso

### 1. Prepara la imagen de entrada (lo más importante)
- **No uses pixel art plano.** TRELLIS con pixel art dio modelos planos tipo cartel.
- Usa un render con aspecto de **«figura de vinilo 3D coleccionable»**: render limpio de estudio, luz pareja, fondo gris claro liso, sin sombra en el piso, sin base y sin texto. Se hace con Gemini (gratis) o con SpriteCook (modelo `gemini-nano-banana`, `pixel=false`).
- **Cuadrúpedos:** las **4 patas completas y separadas** entre sí y del cuerpo, de largo natural. Si las patas quedan escondidas bajo el pelo, el modelo no podrá caminar.
- **La cabeza alineada con el cuerpo** (no girada en 3/4 hacia la cámara). Los rigs automáticos esperan el cuello recto; con la cabeza girada, el rig de Meshy le rompió el cuello al gato.
- Pide **4 variantes** (2 en 3/4, 1 de perfil exacto, 1 con el cuerpo más largo) y elige la de patas más visibles y cara más fiel.
- Adjunta fotos reales del animal y la imagen base del personaje para los colores.
- Quita el fondo (BiRefNet funcionó bien; también rembg o a mano). Con el fondo mal quitado, Valeria salió solo cabeza y pantuflas.

Prompt que funcionó (resumen): «Figura de vinilo coleccionable en 3D, render limpio de estudio, de un gato persa grande, estilo chibi suave… **de pie sobre las cuatro patas**, las cuatro completas y separadas… cola levantada en curva… vista 3/4 desde el frente, cámara a la altura del lomo, cuerpo entero con margen, fondo gris claro liso, luz pareja, sin sombra, sin base y sin texto.»

### 2. Elige el generador

| Opción | Qué da | Cuándo |
| --- | --- | --- |
| **Meshy 6 Lite** (web, plan gratis) | Forma (10 créditos) + textura PBR (10 créditos), **descargable gratis** en GLB, FBX, OBJ… Licencia CC BY 4.0 | La mejor opción gratis para uso real |
| **Hunyuan3D-2 mini local** | Solo la forma, gratis, ilimitada | Muchas variantes de forma; la textura no corre en 8 GB |
| Meshy 7.1, Tripo, 3D AI Studio | Generan gratis | **Cobran por descargar**: sirven solo para mirar |
| TRELLIS / TRELLIS.2 en Hugging Face | Forma y textura (MIT) | Cuota gratis de GPU (ZeroGPU) se agota rápido; espacios caídos |

### 3. Hunyuan3D-2 mini en la PC propia (receta que corrió)
- Equipo: RTX 4060 de 8 GB, 16 GB de RAM, Windows, carpeta `C:\IA3D`.
- Python 3.11, torch 2.6 con CUDA 12.4 (`cu124`), **transformers fijado en 4.48.3** (las versiones nuevas rompen la carga).
- Modelo `tencent/Hunyuan3D-2mini`, subcarpeta `hunyuan3d-dit-v2-mini`.
- **Con 16 GB de RAM, una forma por proceso:** generar varias en el mismo proceso se queda sin memoria. Un script de lote lanza un proceso por semilla.
- La textura **no** se puede hacer local: pide compilar con nvcc y unos 16 GB de VRAM.
- 5 semillas por imagen como mínimo; revisar con un giro de 360° renderizado en Blender.

### 4. Revisa y elige
- Render del modelo cada 45° (Blender) y un GIF de giro.
- Medida objetiva: ¿patas separadas?, ¿piezas sueltas?, ¿picos en orejas y cola?, ¿la cara se reconoce de frente?
- Licencia anotada junto al archivo.

## Herramientas

| Herramienta | Costo | Licencia del resultado |
| --- | --- | --- |
| Gemini | Gratis | Propia (declarar IA) |
| SpriteCook `gemini-nano-banana` | Unos 12 créditos por imagen | Propia (declarar IA) |
| Meshy 6 Lite | Gratis (100 a 200 créditos al mes, 10 descargas) | CC BY 4.0, con atribución |
| Hunyuan3D-2 mini | Gratis local | Tencent Hunyuan 3D 2.0 Community License: **no vale en la UE, Reino Unido ni Corea del Sur**; licencia aparte sobre 1 millón de usuarios al mes |
| TRELLIS.2 | Gratis con cuota | MIT |
| BiRefNet | Gratis local | Quitar fondo |
| Blender 5.2 | Gratis | Herramienta GPL; lo que produce es tuyo |

## Errores típicos

| Error | Causa | Lo que funcionó |
| --- | --- | --- |
| Modelo plano como cartel | Entrada en pixel art plano | Render tipo figura de vinilo 3D |
| Patas que no existen («bulto») | En la imagen las patas estaban bajo el pelo | Imagen con las 4 patas separadas |
| El rig automático tuerce el cuello | Cabeza girada en la imagen | Cabeza alineada con el lomo, mejor de perfil |
| De perfil el modelo es plano | Una sola vista; la IA inventa los lados | Varias vistas (frente, espalda, lados) si el generador las acepta |
| Sin memoria al generar varias | 16 GB de RAM | Un proceso por forma |
| La textura local no corre | Falta nvcc y VRAM | Forma local + color horneado o Meshy para la textura |
| Generación gratis, descarga paga | Modelo del servicio | Revisar antes qué se descarga gratis |

## Fuente o ejemplo

- Encargo de la imagen: `siete-vidas/prototipos/sala-3d-pixel/encargo-gemini-felipe-3d.md`; entradas: `siete-vidas/prototipos/sala-3d-pixel/assets/local3d/felipe_variantes/`.
- Modelos locales y su licencia: `siete-vidas/prototipos/sala-3d-pixel/assets/local3d/LICENCIA.txt`.
- Meshy (rig de perro, descargas, cola repintada): `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/README.md`.
- Informe con TRELLIS y Hunyuan: `siete-vidas/prototipos/sala-3d-pixel/INFORME.md` («Con modelos propios desde imagen»).
