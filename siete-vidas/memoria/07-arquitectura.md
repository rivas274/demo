# Arquitectura del juego: piezas y datos

Actualizado: 2026-10-20 (reordenamiento en 4 etapas; decisión en `01-decisiones.md`, «Forma de construir»).

**Regla:** lo nuevo (un enemigo, un objeto, un nivel) se **arma con piezas y se llena con datos**; no se programa una clase nueva por cosa ni se hereda de otra entidad. Ningún archivo pasa de unas 600 líneas si se puede evitar.

## En sencillo (para el creador)

Antes, cada cosa del juego era un bloque de código hecho a mano: el ratón era «una A.S.P.I. más chica» (copiaba su código y le cambiaba pedazos) y un solo archivo, `sala.gd`, tenía 2263 líneas con todo el nivel adentro: dónde va cada mueble, qué hace Valeria, cómo se dibuja la cortina y qué pasa en el balcón.

Ahora el juego se arma como con **piezas de LEGO**:

- Cada **pieza** hace un solo trabajo: «tiene vida», «recibe zarpazos», «lastima al tocar», «patrulla», «se puede tirar», «oye maullidos», «se asusta», «suelta un premio», «tiene sombra».
- Una **entidad** (el ratón, A.S.P.I., la caja, un vaso) es un nodo con las piezas que necesita. El ratón y A.S.P.I. son **la misma entidad con otros números**: el ratón aguanta 1 zarpazo y no persigue; A.S.P.I. aguanta 3, persigue y oye maullidos.
- Los **números** viven en archivos de datos (`.tres`) que se abren y se cambian en el inspector de Godot, sin tocar código.
- Un **nivel** se arma con un constructor que sirve para todos los niveles, más tres cosas propias de ese nivel: sus **datos** (dónde va cada cosa), su **guion** (qué pasa: Valeria, la pelea, las reacciones) y su **arte**.

Por qué importa (pilar 2, «cada maña es llave y travesura»): cuando exista una maña nueva, funcionará con **todo lo que lleve la pieza**. Intimidar asustará a cualquier cosa con «se asusta»; un coletazo tirará cualquier cosa con «se puede tirar»; un ruido nuevo llegará a todo lo que «oye maullidos». No hay que tocar cada objeto.

## Patrones usados y por qué

| Patrón | Dónde | Por qué |
| --- | --- | --- |
| **Composición con componentes** (nodos hijos con `class_name`, un trabajo cada uno) | `scripts/componentes/` | Una entidad nueva es juntar piezas que ya funcionan; sin herencia frágil (el ratón ya no hereda de A.S.P.I.) |
| **Observador (señales)** | Las piezas avisan (`Vida.murio`, `RecibeGolpes.golpeado`, `Tirable.caido`, `OyeMaullido.oyo`); el Nivel avisa al guion (`habitacion_cambiada`, `puerta_cerrada_probada`, `escalera_bajada`) | Las piezas no se conocen entre sí: quien las junta (la entidad, el guion) conecta lo que le importa |
| **Datos en recursos** (`Resource`, archivos `.tres`) | `DatosEnemigo`, `DatosObjeto` en `datos/`; `DatosNivel` creado en código desde las constantes del nivel | Cambiar un número o crear una variante no toca código; se edita en el inspector |
| **Escenas reutilizables** (`.tscn`) + **fábricas** | `escenas/entidades/`; `Enemigo.desde_escena`, `Objeto.crear`, `Comida.crear`, `CajaCarton.crear` | Se arrastran al editor o se crean desde los datos del nivel con una línea |
| **Constructor + guion** (ganchos con nombre) | `Nivel` (genérico) llama a `GuionNivel` en un orden fijo | Lo que sirve para todos los niveles se escribe una vez; lo propio de cada nivel queda aparte |
| **Máquina de estados con enum** | `felipe.gd` (`Estado`) | Se mantiene: 12 estados se leen bien en un archivo (`godot-felipe` §3). Sus partes visuales y sus mañas salieron a ayudantes |

Decisiones de criterio (sin sobreingeniería):

- **No hay bus de eventos global.** Las señales locales alcanzan; un bus no evitaba ningún acoplamiento real.
- **Escenas y datos:** las entidades de composición fija (ratón, A.S.P.I., caja) tienen su `.tscn`; las que solo cambian datos (vaso, taza, maceta, llaves; tazón y pollo) comparten una escena (`objeto_tirable.tscn`, `comida.tscn`) y cada una tiene su `.tres`. Los `.tscn` se escribieron a mano en texto y son mínimos (raíz + datos, o raíz + piezas): el Enemigo crea las piezas que falten con sus datos, así que una escena nunca contradice a sus datos.
- **Nunca `preload()` de un `.tres` con script en una constante** de un script que otros usan: Godot 4.3 deja dos copias de la clase y los tipos fallan. Se carga con `load()` al armar (ver `Nivel1.RUTA_RATON`).
- Se conservan `Capas`, `Anuncios`, `PresentacionJefe`, `Indicador`, `Travesuras` y la interfaz común de lo interactuable (`interactuar`, `verbo`, `disponible`, `punto_para`, `arte_indicador`).

## Mapa de carpetas (`siete-vidas/juego/`)

| Carpeta o archivo | Qué hay |
| --- | --- |
| `escenas/nivel_1.tscn` | El nivel 1 (escena principal): raíz `Nivel` + `Felipe` + `Interfaz` + `Guion` (`GuionNivel1`) |
| `escenas/entidades/felipe.tscn` | Felipe, con su pieza `Vida` |
| `escenas/entidades/` | `raton.tscn`, `aspi.tscn`, `caja_carton.tscn`, `comida.tscn`, `objeto_tirable.tscn` |
| `datos/enemigos/` | `raton.tres`, `aspi.tres` (`DatosEnemigo`) |
| `datos/objetos/` | `vaso`, `taza`, `maceta`, `llaves`, `tazon`, `pollo` (`.tres`, `DatosObjeto`) |
| `scripts/componentes/` | Las piezas y el ayudante `Componentes` (tabla abajo) |
| `scripts/entidades/` | `Enemigo` (ratón y A.S.P.I.), `Apariencia` (dibujo de un enemigo), `AparienciaAspi` (tapa, luz y avisos de la jefa), `Objeto` (lo que se tira) |
| `scripts/datos/` | `DatosEnemigo`, `DatosObjeto` |
| `scripts/nivel/` | Lo que sirve para todo nivel: `Nivel` (constructor), `DatosNivel`, `GuionNivel` (base del guion), `SombrasVivas` |
| `scripts/niveles/nivel_1/` | Lo propio del nivel 1: `Nivel1` (solo datos), `GuionNivel1` (eventos y reacciones), `ValeriaPorLaCasa` (sus escenas en cola), `FinalBalcon`, `ArteNivel1` (lienzos y arte por capas), `DecoradoNivel1` (decorado sin colisión) |
| `scripts/entidades/felipe/felipe.gd` + `scripts/felipe/` | Felipe: estados, movimiento y acciones en `felipe.gd`; sus partes `EfectosFelipe` (estirar, polvo, estela), `AnimadorFelipe` (qué animación toca) y `ManasFelipe` (lo que pasa en el cuadro de impacto) |
| `scripts/` (resto) | Sistemas y personajes: `Valeria`, `BatallaAspi` + `DibujoBatallaAspi`, `PresentacionJefe`, `EnsayoAspi`, `CajaCarton`, `CajasMudanza`, `Comida`, `Puerta`, `Rascador`, `Laser`, `Recogible`, `Travesuras`, `Agenda`, `Anuncios`, `Dialogo`, `Indicador`, `Capas`, `ArteNivel` (cargar y dibujar arte, sombras y capas), `FondoApartamento`, `LuzCuarto`... |
| `pruebas/` | Pruebas automáticas (entre ellas `prueba_componentes.gd`), el bot `partida.gd` y las capturas |

Tamaño: el archivo más grande del juego es `felipe.gd` (872 líneas: su máquina de estados y el movimiento quedan juntos a propósito), seguido de `batalla_aspi.gd` (739) y `valeria.gd` (724, sin tocar: ver pendientes). Todo lo demás queda bajo 600.

## Las piezas (componentes)

| Pieza | Qué hace | La llevan |
| --- | --- | --- |
| `Componentes` | Ayudante: `Componentes.de(nodo, Vida)` devuelve la pieza o null; `Componentes.nivel(nodo)` da el nivel; grupos `INTERACTUABLES` y `ENEMIGOS` | — |
| `Vida` | Máximo, actual, `danar`, `curar`, `llenar`, `morir`, invulnerable (escudo y tiempo tras un golpe); señales `cambio`, `danado`, `murio` | Felipe (5 corazones), A.S.P.I. (3), ratón (1), caja (1) |
| `RecibeGolpes` | Hurtbox: recibe `recibir_zarpazo` y pasa el daño a la Vida; rebota si hay escudo o si hace falta aturdirla; `aturdir(segundos)` | Ratón, A.S.P.I., caja |
| `HaceDano` | Hitbox: lastima a Felipe al tocarlo (zona rectangular o círculo); se pausa aturdida y se apaga vencida | Ratón, A.S.P.I., bolas de pelo de la pelea |
| `MovimientoPatrulla` | Va y viene entre límites, persigue si ve a Felipe, va a un destino, retrocede con el golpe, huye si se asusta | Ratón, A.S.P.I. |
| `Tirable` | Maña «Tirar»: se ofrece al botón («Liberar»), espera el cuadro de impacto, cae, se rompe, aturde lo de abajo, se repone | Vaso, taza, macetas, llaves (con `Objeto`) |
| `Aranable` | Maña «Arañar»: marcas, pelusa, crítico con garras afiladas, se rompe | Sofá, puerta entornada |
| `OyeMaullido` | Maña «Maullar»: oye dentro del radio (y de `alcance_x`) y avisa con `oyo` | Valeria, A.S.P.I., puerta de la cocina |
| `Asustable` | Maña futura «Intimidar»: `asustar(quien)` → la entidad huye. Lista, sin maña todavía | Ratón, A.S.P.I. |
| `SueltaRecompensa` | Al morir la Vida, suena y suelta un Recogible (snack, calcetín, foto) | Caja de cartón |
| `SombraContacto` | Pide su sombra de contacto (la dibuja `SombrasVivas`) | Ratón, A.S.P.I., caja, comida, Valeria |
| `Interactivo` | Algo que responde al botón sin clase propia (verbo, contorno, qué hace) | Cajón, ropa doblada |

## Recetas

### Cómo agregar un enemigo nuevo (sin programar)

1. En Godot, `datos/enemigos/` → clic derecho → *Nuevo recurso* → `DatosEnemigo`. Guárdalo como `pelusa.tres`.
2. Llénalo en el inspector: nombre, imagen (`arte`, de `assets/nivel1/`), ancho y alto, golpes que aguanta, velocidades, visión (0 = no persigue), daño (0 = inofensivo), si oye maullidos, si se asusta, sonido y frase al vencerlo, sombra.
3. Duplica `escenas/entidades/raton.tscn` como `pelusa.tscn` y cámbiale `datos` por `pelusa.tres`.
4. Ponlo en el nivel: una línea en los datos del nivel (por ejemplo, una lista como `Nivel1.RATONES` con posición y límites) y en el guion `Enemigo.desde_escena("res://escenas/entidades/pelusa.tscn", izquierda, derecha)` con `nivel.add_child(...)`. O arrástralo al editor dentro de la escena del nivel.
5. Si necesita un dibujo especial (como la tapa de A.S.P.I.), haz un script de apariencia y ponlo en `DatosEnemigo.apariencia`. Si necesita un comportamiento nuevo, primero pregunta si es una **pieza nueva** que otros puedan llevar.
6. Prueba: `prueba_componentes.gd` tiene un ejemplo («Pelusa malvada») armado solo con datos.

### Cómo agregar un objeto tirable

1. Duplica `datos/objetos/taza.tres` como `florero.tres`: `tipo` = nombre de la imagen en `assets/nivel1/` (lado menor ≥ 24 px, escala de gato), verbo, si aturde, si se rompe, logro y sonido.
2. En los datos del nivel, una línea en la lista de tirables (`Nivel1.TIRABLES`: `[posición, "florero", hundido]`). El guion ya crea cada uno con `Objeto.crear(...)` y escucha `tirable.caido` para la reacción.
3. Si al romperse se dibuja distinto, agrega su caso en `Objeto._draw` (el roto se dibuja por código).
4. Corre `prueba_reglas_nivel.gd` (lado menor, que no tape puertas) y mira una captura.

### Cómo empezar el nivel 2

1. **Datos:** copia `scripts/niveles/nivel_1/nivel_1.gd` a `scripts/niveles/nivel_2/nivel_2.gd`, cambia `class_name Nivel2` y deja solo lo que el nivel 2 tenga: cuartos (`HABITACIONES`, `RUTA`), piezas sólidas (`PIEZAS`), puertas, escalera si hay, primeras frases (`LECCIONES`), descansos, meta y la agenda. `datos()` arma el `DatosNivel`.
2. **Guion:** crea `guion_nivel_2.gd` con `class_name GuionNivel2 extends GuionNivel`. Mínimo: `datos_del_nivel()` devuelve `Nivel2.datos()`. Después llena `crear_fondo()` (fondo y lienzos de arte), `preparar()` (personajes, objetos, enemigos) y `cada_cuadro()` (eventos que se miran cada cuadro). Escucha las señales del Nivel.
3. **Arte:** un `ArteNivel2` con sus lienzos, usando `ArteNivel.dibujar_capa`, `sombras_de_pared` y `sombras_de_contacto`.
4. **Escena:** duplica `escenas/nivel_1.tscn` como `nivel_2.tscn` y cambia el script del nodo `Guion` por `guion_nivel_2.gd`.
5. **Reglas:** antes de diseñar, lee `06-lecciones-arte.md` y `diseno/reglas-de-niveles.md`; el documento del nivel dice cómo cumple cada regla. Copia las comprobaciones de `prueba_reglas_nivel.gd` para el nivel 2.

## Cómo se verificó que nada cambió

Cada etapa terminó con todas las pruebas en 0 fallos, el bot `partida.gd` completando el nivel (agenda 8 de 8) y las capturas de cada cuarto (`pruebas/capturas_nivel.gd`) comparadas píxel a píxel contra cinco tandas del código original: solo cambian partículas, rótulos que giran al azar y cosas animadas.
