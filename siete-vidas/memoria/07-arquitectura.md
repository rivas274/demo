# Arquitectura del juego: piezas y datos

Actualizado: 2026-10-20 (segunda ronda: Felipe con estados, jefes con conductas en datos, Valeria en partes, carpetas
por responsabilidad y la interfaz con piezas, tema, pila de pantallas, textos traducibles y controles remapeables;
decisión en `01-decisiones.md`, «Forma de construir»).

**Regla:** lo nuevo (un enemigo, un objeto, un jefe, un nivel, una pantalla) se **arma con piezas y se llena con
datos**; no se programa una clase nueva por cosa ni se hereda de otra entidad. Ningún archivo pasa de unas 600 líneas.
La interfaz **solo escucha y muestra**: no decide nada del juego.

## En sencillo (para el creador)

El juego se arma como con **piezas de LEGO**:

- Cada **pieza** hace un solo trabajo: «tiene vida», «recibe zarpazos», «lastima al tocar», «patrulla», «se puede
  tirar», «oye maullidos», «se asusta», «suelta un premio», «tiene sombra».
- Una **entidad** (el ratón, A.S.P.I., la caja, un vaso) es un nodo con las piezas que necesita. El ratón y A.S.P.I.
  son **la misma entidad con otros números**.
- Los **números** viven en archivos de datos (`.tres`) que se cambian en el inspector de Godot, sin tocar código.
- Un **nivel** se arma con un constructor común más sus **datos**, su **guion** y su **arte**.
- Un **jefe** es una pelea común (entrada, carteles, barra, fases) más sus **datos** y sus **ataques**, que también son
  piezas: un jefe nuevo usa los ataques que ya existen y agrega solo los suyos.
- **Felipe** tiene un archivo por cada cosa que puede estar haciendo (en el piso, arañando, en Zoomies, desmayado...):
  para cambiar cómo come, se abre `estado_accion.gd`, no un archivo de 900 líneas.
- **La interfaz** también son piezas: la barra de vida (corazones de Felipe y barra del jefe) se conecta a la vida y se
  mueve sola; los contadores, carteles, menús y el cuadro de diálogo son piezas con su escena. Los colores y letras
  están en **un solo tema** y los textos en **un archivo de traducción** (hoy en español): cambiar «Pausa» o un color
  no toca código.

Por qué importa (pilar 2, «cada maña es llave y travesura»): cuando exista una maña nueva, funcionará con **todo lo
que lleve la pieza**. Intimidar asustará a cualquier cosa con «se asusta»; un coletazo tirará cualquier cosa con «se
puede tirar».

## Patrones usados y por qué

| Patrón | Dónde | Por qué |
| --- | --- | --- |
| **Composición con componentes** (nodos hijos con `class_name`, un trabajo cada uno) | `scripts/componentes/` | Una entidad nueva es juntar piezas que ya funcionan; sin herencia frágil |
| **Observador (señales)** | Las piezas avisan (`Vida.cambio`, `Vida.murio`, `Tirable.caido`, `OyeMaullido.oyo`); el Nivel avisa al guion; Felipe avisa a la interfaz (`vidas_cambiadas`, `collar_cambiado`, `snacks_cambiados`) | Nadie busca a nadie: quien junta las piezas conecta lo que le importa. La interfaz no pregunta en cada cuadro |
| **Datos en recursos** (`.tres`) | `DatosEnemigo`, `DatosObjeto`, `DatosJefe` en `datos/`; el tema en `datos/ui/tema.tres` | Cambiar un número, un color o crear una variante no toca código |
| **Escenas reutilizables** (`.tscn`) + **fábricas** | `escenas/entidades/`, `escenas/ui/`; `Enemigo.desde_escena`, `Objeto.crear`, `Cartel.crear` | Se arman en el editor o se crean con una línea |
| **Constructor + guion** (ganchos con nombre) | `Nivel` llama a `GuionNivel` en un orden fijo | Lo común se escribe una vez; lo propio de cada nivel queda aparte |
| **Estado** (un objeto por estado, con `entrar`, `salir`, `fisica`, `animacion_terminada`) | Felipe: `scripts/entidades/felipe/estados/` | Cada estado en su archivo; las transiciones son explícitas (`felipe.cambiar_estado(Estado.X, datos)`); se limpia al salir (el estambre del ocio, el objetivo del ronroneo) |
| **Estrategia** (conductas intercambiables) | Jefes: `ConductaJefe` y sus ataques (`AtaqueEmbestida`, `AtaqueSoplido`, `AtaqueBolaPelo`, `ConductaLimpiar`) dentro de `DatosJefe.conductas` | El orden de prioridad y desde qué fase se usa cada ataque son datos; un jefe nuevo reutiliza ataques |
| **Pila de pantallas** | `GestorPantallas` (título, pausa, libreta, resumen) | Un solo lugar decide la pausa y qué pantalla responde a las teclas; cerrar la pausa con la libreta abierta no despausa |
| **Tema central + textos con clave** | `datos/ui/tema.tres` (`Estilo`), `traducciones/textos.csv` (`tr()`) | Colores, letras y textos en un solo lugar; traducir es agregar una columna |

Decisiones de criterio (sin sobreingeniería):

- **No hay bus de eventos global ni autoloads.** Las señales locales alcanzan. El gestor de pantallas es un nodo del
  nivel que se encuentra por grupo (`GestorPantallas.de(nodo)`).
- **Nunca `preload()` de un `.tres` con script en una constante** de un script que otros usan: Godot 4.3 deja dos
  copias de la clase y los tipos fallan. Se carga con `load()` (ver `Nivel1.RUTA_RATON`, `BatallaAspi.DATOS`).
- **La interfaz dibujada con código** (corazones, libreta, resumen, barra del jefe) pide sus colores y letras por
  nombre a `Estilo` (`Estilo.color(&"rojo")`); los nodos `Control` (botones, cuadro de diálogo) toman el tema solos
  porque es el tema del proyecto. Única excepción: el retrato provisional de Valeria dibujado por código
  (`retrato_valeria.gd`), que es ilustración y desaparece cuando esté su hoja de retratos.

## Mapa de carpetas (`siete-vidas/juego/`)

| Carpeta | Qué hay |
| --- | --- |
| `escenas/nivel_1.tscn` | El nivel 1 (escena principal): `Nivel` + `Felipe` + `Interfaz` + `Guion` (`GuionNivel1`) |
| `escenas/entidades/` | `felipe.tscn` (con su `Vida`), `raton.tscn`, `aspi.tscn`, `caja_carton.tscn`, `comida.tscn`, `objeto_tirable.tscn` |
| `escenas/ui/` | `barra_vida.tscn` (corazones), `barra_jefe.tscn`, `contador_recurso.tscn`, `menu_pausa.tscn`, `cuadro_dialogo.tscn` |
| `datos/enemigos/`, `datos/objetos/`, `datos/jefes/` | `DatosEnemigo` (ratón, A.S.P.I.), `DatosObjeto` (vaso, taza...), `DatosJefe` (`aspi.tres`: fases, carteles, números por fase y sus conductas) |
| `datos/ui/tema.tres` | El tema: colores, tamaños de letra y medidas con nombre (tipo `Felipe`) y estilos de `BotonMenu`, `CuadroDialogo`, `NombreDialogo`, `TextoDialogo` |
| `traducciones/textos.csv` | Textos de la interfaz por clave (columna `es`); Godot genera `textos.es.translation` al importar |
| `scripts/componentes/` | Las piezas y el ayudante `Componentes` (tabla abajo) |
| `scripts/entidades/felipe/` | `Felipe` (movimiento, entrada y el inicio de cada acción) y sus partes: `estados/` (un archivo por estado), `AgachadoFelipe`, `TreparFelipe`, `EfectosFelipe`, `AnimadorFelipe`, `ManasFelipe`, `AnimacionesFelipe`, `Chispas` |
| `scripts/entidades/valeria/` | `Valeria` (qué hace y cómo reacciona: actividades, regañar, perdonar, grabar), `AspectoValeria` (poses, fundidos, giro, accesorios) y `RutaValeria` (cruzar puertas, dónde pararse) |
| `scripts/entidades/enemigos/` | `Enemigo` (ratón y A.S.P.I.), `Apariencia` |
| `scripts/entidades/objetos/` | `Objeto` (lo que se tira), `CajaCarton`, `CajasMudanza`, `Comida`, `Rascador`, `Laser`, `Recogible`, `Calcetin` |
| `scripts/jefes/` | `PeleaJefe` (pelea genérica), `ConductaJefe` (base de los ataques) y `aspi/` (`BatallaAspi`, sus cuatro conductas, `DibujoBatallaAspi`, `AparienciaAspi`, `EnsayoAspi`) |
| `scripts/nivel/` | Lo común a todo nivel: `Nivel`, `DatosNivel`, `GuionNivel`, `Puerta`, `ArteNivel`, `SombrasVivas` |
| `scripts/niveles/nivel_1/` | Lo propio del nivel 1: `Nivel1` (datos), `GuionNivel1`, `ValeriaPorLaCasa`, `FinalBalcon`, `ArteNivel1`, `DecoradoNivel1`, `FondoApartamento`, `LuzCuarto` |
| `scripts/sistemas/` | Lo que no se ve pero ordena el juego: `Capas` (tabla única de capas), `Controles` (InputMap, remapeo), `Particulas` (fábrica de polvo), `Travesuras`, `Agenda`, `Recompensas`, `Frases`, `Jugo` |
| `scripts/ui/` | Pantallas y avisos: `Pantallas`, `Hud`, `Medidores`, `Dialogo`, `Anuncios`, `Libreta`, `ResumenDia`, `Indicador`, `IconosBotones`, `PresentacionJefe`, `RetratoValeria` |
| `scripts/ui/base/` | `Estilo` (acceso al tema), `GestorPantallas` (pila), `MenuUI` (menú navegable) |
| `scripts/ui/piezas/` | `BarraVida`, `ContadorRecurso`, `Cartel` |
| `scripts/datos/` | Las clases de los recursos: `DatosEnemigo`, `DatosObjeto`, `DatosJefe` |
| `pruebas/` | Pruebas automáticas (`prueba_componentes.gd` para las piezas del juego, `prueba_interfaz.gd` para las de la interfaz), el bot `partida.gd` y las capturas |

Tamaños: el más grande es `felipe.gd` (603 líneas), luego `guion_nivel_1.gd` (572), `presentacion_jefe.gd` (507),
`valeria.gd` (494) y `batalla_aspi.gd` (433). Todo lo demás, menos de 500.

## Las piezas del juego (componentes)

| Pieza | Qué hace | La llevan |
| --- | --- | --- |
| `Componentes` | Ayudante: `Componentes.de(nodo, Vida)` devuelve la pieza o null; `Componentes.nivel(nodo)` da el nivel; grupos `INTERACTUABLES` y `ENEMIGOS` | — |
| `Vida` | Máximo, actual, `danar`, `curar`, `llenar`, `morir`, `fijar`, invulnerable; señales `cambio`, `danado`, `murio` | Felipe (5 corazones), A.S.P.I. (3 fases), ratón (1), caja (1) |
| `RecibeGolpes` | Recibe `recibir_zarpazo` y pasa el daño a la Vida; rebota con escudo; `aturdir(segundos)` | Ratón, A.S.P.I., caja |
| `HaceDano` | Lastima a Felipe al tocarlo (rectángulo o círculo) | Ratón, A.S.P.I., bolas de pelo |
| `MovimientoPatrulla` | Va y viene, persigue si ve a Felipe, va a un destino, retrocede, huye | Ratón, A.S.P.I. |
| `Tirable` | Maña «Tirar»: se ofrece, cae en el cuadro de impacto, se rompe, aturde lo de abajo | Vaso, taza, macetas, llaves |
| `Aranable` | Maña «Arañar»: marcas, pelusa, crítico con garras, se rompe | Sofá, puerta entornada |
| `OyeMaullido` | Maña «Maullar»: oye dentro del radio y avisa con `oyo` | Valeria, A.S.P.I., puerta de la cocina |
| `Asustable` | Maña futura «Intimidar»: `asustar(quien)` → huye | Ratón, A.S.P.I. |
| `SueltaRecompensa` | Al morir la Vida suelta un Recogible | Caja de cartón |
| `SombraContacto` | Pide su sombra de contacto | Ratón, A.S.P.I., caja, comida, Valeria |
| `Interactivo` | Responde al botón sin clase propia | Cajón, ropa doblada |

## Felipe: estados

`felipe.estado` sigue siendo el enum `Felipe.Estado` (lo leen las pruebas y el resto del juego), pero detrás hay un
objeto por estado (`EstadoFelipe`, en `scripts/entidades/felipe/estados/`):

| Archivo | Estados | Qué hace |
| --- | --- | --- |
| `estado_libre.gd` | `SUELO`, `AIRE` | Moverse, gravedad, saltar, empezar acciones |
| `estado_aterrizando.gd` | `ATERRIZANDO` | La pausa corta al caer fuerte |
| `estado_accion.gd` | `ZARPAZO`, `COMIENDO`, `ARANANDO`, `MAULLANDO` | Frena, su animación desde el cuadro 0, vuelve al terminar (un estado por dato) |
| `estado_zoomies.gd` | `ZOOMIES` | La carrera (datos `{"direccion"}`) |
| `estado_ronroneando.gd` | `RONRONEANDO` | Frotarse con Valeria (datos `{"objetivo"}`; al salir lo suelta) |
| `estado_desmayado.gd` | `DESMAYADO` | Pierde una vida y reaparece |
| `estado_ocio.gd` | `OCIO` | Se lame o juega con el estambre (datos `{"nombre"}`; al salir quita el estambre) |
| `estado_escalera.gd` | `SUBIENDO_ESCALON` | Sube peldaño a peldaño (datos `{"peldanos", "duracion"}`) |

Cambiar de estado: `felipe.cambiar_estado(Felipe.Estado.ZOOMIES, {"direccion": -1.0})` (llama `salir()` del actual y
`entrar(datos)` del nuevo). **La futura pieza de jugo de las acciones (`RecetaJugo`: anticipación, estela, líneas,
pausa de impacto, polvo y derrape; ver `04-pendientes.md`)** se cuelga de aquí: cada estado llama a su receta en
`entrar()` y en `salir()`, sin tocar los demás.

## La interfaz

**Regla:** la interfaz solo escucha (señales) y muestra. No cambia nada del juego salvo pedir pausa a la pila de
pantallas o avisar lo que eligió el jugador en un menú (señal `elegido`).

| Pieza | Qué hace | Se usa en |
| --- | --- | --- |
| `BarraVida` (`escenas/ui/barra_vida.tscn`, `barra_jefe.tscn`) | Muestra una `Vida`: `conectar(vida)` y se mueve sola con `Vida.cambio`. Forma `CORAZONES` o `BARRA` (con título, divisiones por punto y franja de escudo) | Corazones de Felipe (`Medidores`), barra del jefe (`PresentacionJefe`: la pelea pone en la Vida del jefe las fases que le quedan) |
| `ContadorRecurso` (`contador_recurso.tscn`) | Ícono + número; `fijar(texto, tiene)` con golpe al cambiar | Calcetines, fotos y snacks del HUD |
| `Cartel` (`Cartel.crear`) | Franja o tarjeta con título, nombre y recompensa; entra, espera y sale | Carteles de travesura y «PODER NUEVO» (la cola es `Anuncios`) |
| `MenuUI` (`menu_pausa.tscn`) | Columna de botones `BotonMenu` con foco: flechas, W/S, cruceta o palanca; Enter o A elige; el foco da la vuelta. Avisa `elegido(nombre)` | Menú de pausa (Continuar, Reiniciar, Salir) |
| Cuadro de diálogo (`cuadro_dialogo.tscn`) | Panel con marco, retrato, nombre y texto, con el estilo del tema; `Dialogo` pone las frases | Diálogos de Felipe, Valeria y A.S.P.I. |
| `GestorPantallas` | Pila: `abrir(pantalla, pausa)`, `cerrar(pantalla)`, `arriba()`, `es_la_de_arriba(pantalla)`; pausa mientras haya una que pausa | `Pantallas` (título, intro, pausa, fin), `Libreta`, `ResumenDia` |
| `Estilo` | `color(&"nombre", alfa)`, `letra(&"nombre")`, `medida(&"nombre")`, `fuente()`, `texto_con_contorno`, `texto_centrado` | Todo lo que se dibuja con código |
| `Controles` | Qué tecla o botón tiene cada acción (leído del InputMap), `etiquetar("{saltar}")`, `remapear`, `guardar`, `cargar` (`user://controles.cfg`, se carga al empezar el nivel) | Avisos, pistas de jefe, íconos (`IconosBotones` busca el ícono por tecla, así sigue al remapeo) |

Textos: toda la interfaz usa claves (`tr("PAUSA_TITULO")`) de `traducciones/textos.csv`. Las frases de Felipe y
Valeria (`Frases`) y los textos de los niveles y jefes **están preparados, no traducidos**: el diálogo, los carteles
y las pistas pasan por `tr()`, que hoy devuelve el mismo español; para traducirlos se mueve cada frase a una clave.

## Recetas

### Cómo agregar un enemigo nuevo (sin programar)

1. En Godot, `datos/enemigos/` → *Nuevo recurso* → `DatosEnemigo`. Guárdalo como `pelusa.tres`.
2. Llénalo en el inspector: nombre, imagen (`arte`), tamaño, golpes, velocidades, visión, daño, si oye maullidos, si se
   asusta, sonido y frase al vencerlo, sombra.
3. Duplica `escenas/entidades/raton.tscn` como `pelusa.tscn` y cámbiale `datos` por `pelusa.tres`.
4. Ponlo en el nivel: una línea en sus datos y en el guion `Enemigo.desde_escena("res://escenas/entidades/pelusa.tscn", izquierda, derecha)`.
5. Si necesita un dibujo especial, un script de apariencia en `DatosEnemigo.apariencia`. Si necesita un comportamiento
   nuevo, primero pregunta si es una **pieza nueva** que otros puedan llevar.
6. Prueba: `prueba_componentes.gd` tiene un ejemplo («Pelusa malvada») armado solo con datos.

### Cómo agregar un objeto tirable

1. Duplica `datos/objetos/taza.tres` como `florero.tres`: `tipo` (imagen en `assets/nivel1/`, lado menor ≥ 24 px),
   verbo, si aturde, si se rompe, logro y sonido.
2. Una línea en `Nivel1.TIRABLES`: `[posición, "florero", hundido]`.
3. Si roto se dibuja distinto, su caso en `Objeto._draw`.
4. Corre `prueba_reglas_nivel.gd` y mira una captura.

### Cómo agregar un jefe

1. **Entidad:** un `DatosEnemigo` para su cuerpo (`golpes` = número de fases: la barra muestra esa Vida) y su escena
   (como `aspi.tscn`).
2. **Datos de la pelea:** en `datos/jefes/` → *Nuevo recurso* → `DatosJefe`: nombre y título (franja de la entrada),
   rugido, fases, carteles y pistas por fase, números por fase (`velocidad`, `capacidad`...: la lista usa el último si
   faltan fases).
3. **Ataques:** en `conductas`, agrega en orden de prioridad los que ya existen (embestida, soplido, bola de pelo,
   limpiar) y ajusta sus números y `desde_fase` en el inspector. Un ataque nuevo es un script
   `extends ConductaJefe` con `nombre()`, `intentar(delta)` (si ataca: `pelea.empezar_ataque(self)` y true),
   `actualizar(delta)` (false al terminar) y, si hace falta, `cada_cuadro`, `vigilar`, `al_cambiar_fase`. Sus números
   van con `@export` para verlos en el inspector.
4. **Pelea:** un script `extends PeleaJefe` solo con lo que lo hace único (A.S.P.I.: el depósito que se llena y la
   hace vulnerable). La entrada, los carteles de fase y la barra son de `PresentacionJefe` (nunca una presentación
   propia: regla de CLAUDE.md). Para bajar la barra: `vencidas += 1` (la Vida del jefe se ajusta sola).
5. **Nivel:** el guion crea la pelea con `TuPelea.new(datos, jefe, felipe, nivel, arena)` y la agrega al nivel.
6. Prueba: copia lo que hace `prueba_jefe.gd` con A.S.P.I. y la prueba de conductas de `prueba_componentes.gd`.

### Cómo agregar una pantalla de menú

1. **Escena:** en `escenas/ui/`, un `VBoxContainer` con el script `scripts/ui/base/menu_ui.gd` y un `Button` por
   opción, cada uno con *Theme Type Variation* `BotonMenu` y como texto una clave (`MENU_OPCIONES`). Copia
   `menu_pausa.tscn`.
2. **Textos:** agrega las claves a `traducciones/textos.csv` (columna `es`).
3. **Pantalla:** el nodo que la muestra (un `Control` en una capa de `Capas`) la instancia, conecta `elegido(opcion)` a
   lo que haga cada opción y, al abrirse y cerrarse, llama `GestorPantallas.de(self).abrir(self)` y `.cerrar(self)`.
   Solo responde a teclas propias si `GestorPantallas.de(self).es_la_de_arriba(self)`.
4. **Colores y letras:** del tema (`Estilo.color(&"...")`); si falta uno, se agrega a `datos/ui/tema.tres`.
5. Prueba: como `_probar_menu_y_pausa` en `prueba_interfaz.gd` (foco en la primera opción, elegir, la pausa).

### Cómo traducir un texto

1. En el código, nunca el texto: una clave. `tr("UI_MI_TEXTO")` (en un `Control`, basta poner la clave como texto:
   se traduce solo). Con números: `tr("UI_VIDAS") % vidas` y en el archivo `%d vidas`.
2. En `traducciones/textos.csv`, una fila `UI_MI_TEXTO,"Mi texto"` (comillas si lleva comas).
3. Otro idioma: una columna nueva (`en`) con cada texto; Godot genera `textos.en.translation` al importar y hay que
   agregarlo en *Proyecto → Configuración → Localización*. El español es el de respaldo (`locale/fallback="es"`).
4. `prueba_interfaz.gd` revisa que toda clave tenga su texto en español.

### Cómo empezar el nivel 2

1. **Datos:** copia `scripts/niveles/nivel_1/nivel_1.gd` a `scripts/niveles/nivel_2/nivel_2.gd` (`class_name Nivel2`)
   con sus cuartos, piezas, puertas, frases, meta y agenda.
2. **Guion:** `guion_nivel_2.gd` con `class_name GuionNivel2 extends GuionNivel`: `datos_del_nivel()`, `crear_fondo()`,
   `preparar()`, `cada_cuadro()`.
3. **Arte:** un `ArteNivel2` con `ArteNivel.dibujar_capa`, `sombras_de_pared` y `sombras_de_contacto`.
4. **Escena:** duplica `escenas/nivel_1.tscn` como `nivel_2.tscn` y cambia el script del nodo `Guion`.
5. **Reglas:** lee `06-lecciones-arte.md` y `diseno/reglas-de-niveles.md`; copia las comprobaciones de
   `prueba_reglas_nivel.gd`.

## Cómo se verificó

Cada etapa terminó con todas las pruebas en 0 fallos, el bot `partida.gd` completando el nivel (agenda 8 de 8) y las
capturas de cada cuarto (`pruebas/capturas_nivel.gd`) comparadas píxel a píxel contra cinco tandas del código
original. Cambios visibles a propósito (2026-10-20): la pausa ahora es un menú con botones (antes, una línea de
texto con las teclas R y Q).
