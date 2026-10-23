# Errores de arte y niveles que el creador vio en segundos

## Qué problema resuelve

Las pruebas pasaban y el creador igual encontraba errores a simple vista en el video. Esta lista convierte cada error real en una regla, para buscarlo **antes** de mostrar un nivel.

## Receta: cómo revisar

1. Mira el juego como un jugador: capturas a tamaño real y ampliadas ×2 a ×4, **cuadro por cuadro en cada transición** (el anterior, el del cambio y el siguiente).
2. Revisa el **video completo** en hojas de cuadros cada 2 s.
3. Pregunta en cada cuarto: «¿esto lo dibujó alguien con cariño o parece montado?».
4. Antes de revisar una captura, mira que cada personaje esté parado sobre algo (los puntos de captura deben estar en lugares libres).
5. Compara siempre con la captura de la versión anterior: lo aprobado no puede empeorar.
6. Si el creador lo vería en 5 segundos, no está terminado.

## Lista de errores y su regla

### Escala y apoyo
| Error | Regla |
| --- | --- |
| Personajes y objetos flotando sobre los muebles | La colisión calza con el borde opaco del arte (±2 px); el arte se recorta a su borde |
| Comida diminuta | Lo que le importa al personaje se ve grande (lado menor ≥ 24 px) |
| Objetos flotando en el borde de atrás de un mueble | Se apoyan en el **centro** de la superficie, con sombra; mide cuánto se ve la cara de arriba del mueble |
| Cuarto estrecho con muebles diminutos para que todo quepa | La cámara se mueve: el cuarto puede ser más ancho que la pantalla |
| Un objeto agregado sin su contexto, o desproporcionado | Si agregas algo, agrega lo que le da sentido, a escala, y míralo junto a lo de al lado |

### Coherencia del lugar
| Error | Regla |
| --- | --- |
| Puertas o ventanas distintas en cada cuarto | Un solo marco para toda la casa; cada par se ve igual por los dos lados |
| Algo tapa una puerta o una interacción | Nada tapa una puerta ni una interacción |
| Barreras sin sentido que además se atraviesan | Toda barrera se explica sola y una prueba empuja al personaje contra ella |
| Un bloque que no se entiende | Todo volumen se explica (armario con su puerta) |
| Objeto fuera de su cuarto | Cada objeto pertenece a su cuarto y cuenta algo de quien vive ahí |
| Simetría perfecta, objetos en fila, clones | Islas con intención, alturas variadas, nada clonado |
| Nada se mueve, sin desgaste | Algo vive en cada cuarto: pelos, arañazos, objetos personales |
| Lo roto desaparece | Lo que se rompe deja su marca; lo que se come deja el plato |

### Luz, sombra y piso
| Error | Regla |
| --- | --- |
| Todo pegado a la pared, el piso como tira de adorno | El piso es un plano: se ve detrás de los pies y todo se apoya con su sombra |
| Piso o pared rellenados por código «a la rápida» | Superficies grandes con arte de verdad |
| Muebles sin sombra de contacto | Sombra de 2 px bajo cada pata y 1 px de oclusión detrás |
| Luces sin dirección común | Una dirección de luz por cuarto; sombras y brillos la siguen |
| Halo circular de luz pegado en la pared («filtro») | La luz cae en superficies, en escalones de borde duro |
| Al quitar el halo, las lámparas «se apagaron» | Pantalla encendida, cono en 3 escalones y franja iluminada; tiene que notarse **más** que antes |
| Puertas abiertas sin grosor de muro | Toda abertura muestra el grosor (jamba en 2 tonos) |

### Personajes y capas
| Error | Regla |
| --- | --- |
| Pies que patinan, piernas que no alternan | El ciclo de caminar se mide antes de aceptar el arte |
| Subir una escalera deslizando la pose de caminar | Cada desplazamiento tiene su animación |
| Poses que cambian de golpe, personajes que se teletransportan | Transición en cada cambio de pose; los personajes cruzan las puertas a la vista |
| El protagonista dibujado encima de un humano, como un fantasma | Los humanos van delante y donde tapan se ve el contorno del protagonista; revisar cada cruce |
| Escenario dibujado encima de la imaginación del jefe | Una sola tabla de capas |
| Un resalte rectangular alrededor de un objeto | Nada de cajas de depuración; el resalte sigue la silueta y va detrás |

### Textos e interfaz
| Error | Regla |
| --- | --- |
| Carteles que tapan el chiste o se apilan | Una sola cola de anuncios |
| Textos diminutos, cortados o montados en el HUD | Zonas fijas de texto; letra de 16 px o más en carteles; contorno de 1 px; una prueba revisa rectángulos y caracteres |
| HUD lleno de contadores | Fijo solo lo que se decide a cada segundo; lo demás aparece al cambiar y vive en la pausa |
| Objeto de código junto a arte de Gemini | Si se nota la diferencia, arte de verdad o quitarlo |

## La lección de fondo

**Las pruebas en verde son el piso, no la meta.** El video v5 de Felipe pasaba todas las pruebas y el creador lo vio «no funcional»: luces perdidas, el gato atravesando a la humana y textos montados. Desde entonces ningún cambio se da por bueno sin mirarlo.

## Fuente o ejemplo

- Lista completa con los casos reales: `siete-vidas/memoria/06-lecciones-arte.md`.
- Plan que arregló el video v5: `siete-vidas/diseno/revisiones/2026-10-20-plan-estabilizacion.md`.
- Agentes que revisan con esta lista: `.claude/agents/revisor-niveles.md` y `.claude/agents/revisor-ambientes.md`.
