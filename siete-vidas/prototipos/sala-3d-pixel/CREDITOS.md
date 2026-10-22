# Créditos del prototipo sala-3d-pixel

Assets de terceros con licencia CC0 (las licencias originales están junto a cada archivo) y dos modelos generados por IA desde arte del proyecto (ver abajo).

| Asset | Autor | Licencia | Origen | Archivos |
|---|---|---|---|---|
| Furniture Kit 2.0 (sofá, mesita, lámpara, alfombra, librero, libros, plantas) | Kenney | CC0 1.0 | https://kenney.nl/assets/furniture-kit | `assets/kenney/*.glb`, `assets/kenney/LICENCIA-furniture-kit.txt` |
| Universal Animation Library [Standard] (maniquí con Walk, Idle, Sitting_Enter, Sitting_Idle, Sitting_Exit) | Quaternius | CC0 1.0 | https://opengameart.org/content/universal-animation-library (también quaternius.com) | `assets/quaternius/AnimationLibrary_Godot_Standard.glb`, `assets/quaternius/LICENCIA-universal-animation-library.txt` |
| Felipe IA (`assets/felipe_ia/felipe_hunyuan.glb`) | Generado con **Hunyuan3D-2** (Tencent) desde `siete-vidas/arte/felipe/felipe-A-base.png` | Modelo de IA: Tencent Hunyuan 3D 2.0 Community License (ver nota) | https://huggingface.co/spaces/tencent/Hunyuan3D-2 (solo forma, 2026-10-21); reducido a ~8.900 caras y pintado por proyección de la imagen con `trimesh` | `assets/felipe_ia/` |
| Valeria IA (`assets/valeria_ia/valeria_hunyuan.glb`) | Generado con **Hunyuan3D-2** desde la primera pose de `siete-vidas/arte/referencias/gemini/valeria-poses.png` (fondo quitado) | igual que arriba | igual que arriba; ~12.000 caras | `assets/valeria_ia/` |
| Animal Pack Vol.2: Cat (Idle, Walking) | Quaternius | CC0 1.0 | https://opengameart.org/content/animated-animales-low-poly (también quaternius.com) | `assets/pack/gato_quaternius.glb` (Cat.fbx convertido a glTF con el importador FBX de Godot 4.3, sin cambios), `assets/pack/LICENCIA-animal-pack-vol2.txt` |
| Hojas de Felipe (quieto, caminar largo, sentarse) | Proyecto Felipe (copia de `siete-vidas/arte/felipe/`) | del proyecto | — | `assets/felipe/*.png` |

Notas:
- Valeria es el maniquí de Quaternius recoloreado por código (sudadera, pantalón, piel, zapatos) con pelo y moño de esferas.
- Felipe 3D está hecho con primitivas por código: no usa ningún asset externo.
- Mixamo no se usó (requiere cuenta de Adobe). Los paquetes de Quaternius en Google Drive no se pudieron bajar (cuota excedida); se usó la copia oficial en OpenGameArt.
- **Modelos IA:** el espacio pedido, `microsoft/TRELLIS.2` (MIT), respondió pero rechazó cada intento por la cuota gratuita de GPU agotada para usuarios anónimos ("ZeroGPU quota 0s left"); `microsoft/TRELLIS` estaba caído (CONFIG_ERROR). Se usó el respaldo `tencent/Hunyuan3D-2`, cuya generación de textura falló en el servidor, así que solo se bajó la forma y el color se puso por proyección frontal de la imagen original.
- **Ojo con la licencia de Hunyuan3D-2:** no es MIT. La "Tencent Hunyuan 3D 2.0 Community License" excluye la Unión Europea, el Reino Unido y Corea del Sur, y pide licencia aparte sobre 1 millón de usuarios activos al mes. Tencent no reclama los resultados, pero antes de usar algo así en el juego hay que revisarla o regenerar con TRELLIS.2 (MIT) con un token gratis de Hugging Face, o con Meshy (CC BY).
- **Valeria IA con esqueleto (v3):** usa el esqueleto y las animaciones CC0 de Quaternius; los pesos se calculan por código (`scripts/auto_piel.gd`), sin herramientas ni servicios externos.
- **Felipe sobre el gato del pack (v5):** forma, colores, cara, capas de movimiento y salto se hacen por código (`scripts/felipe_pack.gd`, `shaders/felipe_pack.gdshader`); el pack no trae correr, saltar ni otras poses, solo Idle y Walking.
