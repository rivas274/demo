# Qué falló al animar un personaje de IA y por qué

## Qué problema resuelve

Ahorrar días: estos caminos se probaron en orden con un gato chibi generado por IA y **no funcionaron**. La causa común: **la malla de IA es una estatua** (triángulos sin bucles en las articulaciones). Cortarla o moverla con fórmulas no ataca esa causa. Lo que funcionó está en [03-rig-y-animacion-cuadrupedo.md](03-rig-y-animacion-cuadrupedo.md).

## Lo que se probó, en orden

| # | Intento | Resultado | Por qué falló |
| --- | --- | --- | --- |
| 1 | Malla de IA sin esqueleto, movida en bloque con rebote y balanceo | Un peluche que se desliza | Sin huesos no hay patas que pisen |
| 2 | Estirar las patas por código | «Amorfo» | Se deforma la malla sin estructura; la entrada tenía las patas bajo el pelo |
| 3 | Gato animado de Quaternius (CC0) deformado a chibi | «Lo peor» | Las proporciones de un gato realista no se vuelven chibi escalando |
| 4 | Rig automático de cuadrúpedo de Meshy («perro», gratis una vez) | Cuello roto, cuerpo deformado | Cabeza girada en la imagen y proporciones chibi que no son de perro; solo trae «caminar de perro» |
| 5 | Huesos por código con pesos por distancia (1/d⁴) | «Masa», textura estirada | Los pesos por distancia no respetan la anatomía ni la topología |
| 6 | Esqueleto de Quaternius reubicado en el modelo de Meshy (retargeting) | Se mueve natural, pero la textura se estira | Buen movimiento, malla sin bucles: la piel no sabe doblarse |
| 7 | Piezas rígidas cortadas por planos | Cortes dentados y láminas | Un personaje peludo no es un robot de piezas |
| 8 | Piezas cortadas con máscaras dibujadas por el creador | Mejores cortes, pero se ven las uniones | Mismo problema: piezas rígidas |
| 9 | **HoloPart** local para completar cada pieza | La mitad bien; las piezas chicas se rompen | Completa partes, **no segmenta** (hay que darle la segmentación); piezas de ~600 caras salen en decenas de trozos. Con 5 semillas mejoró: todas cerradas, pero algunas delgadas |
| 10 | Hunyuan3D-Part (segmentar y completar) | No corrió | El demo en línea daba error con sus propios ejemplos; en Windows no compila |

**Datos de HoloPart:** RTX 4060 de 8 GB, 50 pasos, 44 minutos para 15 piezas, 5,5 a 7,4 GB de VRAM. Hubo que cambiar la extracción a marching cubes de skimage (diso no tiene binario para Windows) y saltar un bug de su función principal.

**Lo que funcionó al final (intento 11):** la receta de cualquier artista 3D: Voxel Remesh, QuadriFlow, Symmetrize, horneado, Rigify, pesos automáticos suavizados y poses clave mirando video del animal. El creador: «aceptable… es lo mejor que tenemos».

## Por qué se tardó tanto

- Se inventaron soluciones propias (fórmulas, cortes) **antes** de buscar cómo lo hace un profesional.
- Cada intento parecía «casi» funcionar, y eso invitaba a seguir ajustando el mismo camino.
- **Regla que salió de aquí:** si algo falla dos veces, para, nombra la causa de fondo y busca el método estándar antes del tercer intento.

## Lecciones de dirección de arte (3D)

- **En un personaje estilizado, una mancha simple se lee mejor que el patrón real exacto.** El patrón exacto quedó recargado.
- **Las patas de un gato empiezan dentro del cuerpo** (cadera en la grupa, escápula detrás del cuello). Lo visible es la punta.
- **Las traseras son más largas y grandes**, así que la grupa queda más alta que los hombros.
- **El contorno exterior ayuda a leer la silueta**, pero los umbrales de bordes interiores muy sensibles ensucian el pixel art.
- **Las proporciones chibi limitan poses:** con patas delanteras cortas no se sienta erguido.

## Regresiones vistas (comparar siempre con la versión anterior)

| Regresión | Causa |
| --- | --- |
| La cara se aplanó | Simetrizar y retopologizar con poca densidad |
| La mano se aplastó al animar | Pose nueva no revisada contra la anterior |
| Anillo blanco en la base de la cola | Zona que quedó sin pintar al repintar el cuerpo |
| Patas que no tocan el piso al saltar | Heredaban el aplastar del torso |

## Cómo evitarlo en el próximo proyecto

1. Antes del primer intento: ¿cómo lo hace un artista 3D? (retopología, horneado, rig estándar, pesos, poses clave).
2. Imagen de entrada pensada para animar: patas separadas, cabeza alineada, idealmente varias vistas.
3. Prueba la receta estándar completa en un día, aunque sea tosca, antes de afinar nada.
4. 5 variantes por paso con medida objetiva y revisión visual.
5. Antes/después en cada versión.

## Fuente o ejemplo

- Intentos y resultados: `siete-vidas/prototipos/sala-3d-pixel/INFORME.md` y `siete-vidas/prototipos/sala-3d-pixel/CREDITOS.md` (notas v5 y v6).
- Scripts de los intentos: `siete-vidas/prototipos/sala-3d-pixel/scripts/felipe_pack.gd` (gato de Quaternius), `siete-vidas/prototipos/sala-3d-pixel/scripts/felipe_meshy.gd` (retargeting), `siete-vidas/prototipos/sala-3d-pixel/scripts/felipe_v8.gd` (piezas), `siete-vidas/prototipos/sala-3d-pixel/scripts/auto_piel.gd` (pesos por distancia).
- HoloPart y las 5 semillas: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_partes/README.md` y `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/felipe_partes/comparacion_intentos.json`.
- Rig de Meshy: `siete-vidas/prototipos/sala-3d-pixel/assets/meshy_prueba/README.md`.
- Lección registrada: `siete-vidas/memoria/01-decisiones.md` («Pilar de trabajo: no reinventar la rueda»).
