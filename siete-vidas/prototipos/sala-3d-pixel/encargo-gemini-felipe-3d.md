# Encargo a Gemini: imagen de Felipe para un modelo 3D nuevo

El creador vio a Felipe 3D con las patas estiradas por código y dijo que **se ve amorfo**: mejor pedir un modelo nuevo. El modelo f07 salió de una imagen en la que Felipe tenía las patas escondidas bajo la panza, y por eso no camina bien. Hace falta una imagen nueva en la que las patas se vean desde el principio.

Esta imagen es la entrada de Hunyuan3D-2 mini, en la PC del creador. Lo que mejor funcionó antes fueron las imágenes con aspecto de **figura de vinilo 3D**, no el pixel art plano.

## Prompt (pegar en Gemini, adjuntando las 5 fotos de `arte/referencias/felipe-real/`)

> Figura de vinilo coleccionable en 3D, render limpio de estudio, de un gato persa grande y robusto (unos 8 kilos), estilo chibi suave: cabeza grande y redonda, cara chata de persa, ojos verde claro entrecerrados mirando de reojo con cara de desdén, nariz rosada pequeña.
> **De pie sobre las cuatro patas**, en pose de caminar quieta. Las cuatro patas se ven completas y separadas entre sí y del cuerpo. Son gruesas y peludas, de largo natural de gato (más o menos un tercio de la altura del cuerpo hasta el lomo), no escondidas bajo el pelo.
> Cola esponjada levantada en curva.
> Colores como en las fotos: casi todo blanco (cara, pecho con melena, panza y las cuatro patas). Gorro atigrado gris pardo sobre la cabeza y las orejas, con una V blanca entre los ojos. Dos o tres manchas atigradas grandes en el lomo y los costados. Cola atigrada oscura, casi café negro.
> Vista 3/4 desde el frente, cámara a la altura del lomo, cuerpo entero dentro del cuadro con margen. Fondo gris claro liso, luz pareja suave, sin sombra en el piso, sin base ni pedestal y sin texto.

## Pedir 4 variantes y elegir

- 2 en vista 3/4 y 1 de perfil exacto. La de perfil sirve para comparar las patas.
- 1 igual a la 3/4 pero con el cuerpo un poco más largo.

Se elige la que tenga las cuatro patas más visibles y la cara más parecida a Felipe A.

## Después

1. Guardar las imágenes en `assets/local3d/felipe_variantes/entrada_gemini_v2_*.png` y subirlas a la rama.
2. En la PC (`C:\IA3D`), generar con `generar_lote.py` 3 o 4 semillas por imagen, simplificar y revisar los giros.
3. Pintar el modelo elegido con `colorear_felipe.py` y la proyección de la cara, rehacer el esqueleto (`felipe_animado.gd`) y grabar el GIF y el video de nuevo.
4. Se descartan `felipe_color_patas.glb` y `estirar_patas.py`: el estiramiento por código queda amorfo.
