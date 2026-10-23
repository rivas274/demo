# Arquitectura del juego: piezas y datos

Actualizado: 2026-10-20 (plan de estabilización: capas de humanos y zonas de texto; antes, segunda ronda: Felipe con estados, jefes con conductas en datos, Valeria en partes, carpetas
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
| `scripts/ui/base/` | `Estilo` (acceso al tema), `ZonasTexto` (zonas fijas de texto), `GestorPantallas` (pila), `MenuUI` (menú navegable) |
| `scripts/ui/piezas/` | `BarraVida`, `ContadorRecurso`, `Cartel` |
| `scripts/datos/` | Las clases de los recursos: `DatosEnemigo`, `DatosObjeto`, `DatosJefe` |
| `pruebas/` | Pruebas automáticas (`prueba_componentes.gd` para las piezas del juego, `prueba_interfaz.gd` para las de la interfaz), el bot `partida.gd` y las capturas |

Tamaños: el más grande es `felipe.gd` (603 líneas), luego `guion_nivel_1.gd` (572), `presentacion_jefe.gd` (507),
`valeria.gd` (494) y `batalla_aspi.gd` (433). Todo lo demás, menos de 500.

## Capas y zonas de texto (plan de estabilización 2026-10-20)

**Capas del mundo** (`scripts/sistemas/capas.gd`, tabla única): de atrás hacia adelante, pared, arte de pared, puertas,
muebles y `TRAS_FELIPE` (−1), `JUEGO` (0: Felipe, enemigos, objetos), `MARCAS` (1), **`PERSONAJES` (2: solo los
humanos)**, `JUEGO_DELANTE` (3: Felipe parado sobre algo que queda delante de los humanos, frotándose, o con Valeria sentada: `Nivel1.ACTIVIDADES_HUMANO_DETRAS`), `PRIMER_PLANO` (4:
pasamanos), luz, estela, imaginación, efectos, censura e Indicador.

- Valeria va **delante** de Felipe. Donde lo tapa se dibuja su contorno de 1 px: pieza `SiluetaTapada`
  (`scripts/componentes/`), hija del humano, que pone `clip_children` en él y copia el cuadro del sprite de Felipe con un
  shader de borde. Otro humano futuro solo agrega la pieza.
- Felipe va delante de Valeria cuando está parado en una superficie de `Nivel1.DELANTE_DE_HUMANOS` (hoy el asiento del
  sofá): `GuionNivel1._actualizar_capa_felipe()` lo decide por la pieza donde se apoya (`superficie_de_felipe()`), no
  con casos sueltos; en el aire conserva la capa. También va delante mientras se frota contra ella (estado `RONRONEANDO`,
  `Nivel1.ESTADOS_DELANTE_DE_HUMANOS`). La pelea con A.S.P.I. solo toca su capa mientras imagina.
- Las palabras del mundo no tapan la cara de Valeria (`Jugo.testigos`).

**Zonas de texto** (`scripts/ui/base/zonas_texto.gd`, tabla única como `Capas`; pantalla de 640×360):

| Zona | Lugar | Qué va | Quién la usa |
| --- | --- | --- | --- |
| A. HUD | y 0–26 | Corazones y vidas, agenda, contadores, barra del jefe (nombre dentro, abreviado si no cabe: `BarraVida.titulo_corto`) | `Medidores`, `Hud`, `PresentacionJefe.POS_BARRA` |
| B. Diálogo | y 30–80 | Cuadro con retrato (abajo solo si Felipe está tan arriba que lo taparía) | `Dialogo` |
| C. Carteles | y 30–90 (misma franja) | Travesura, logro, fase del jefe, «PODER NUEVO»: título y una línea | `Anuncios` (cola única): `ZonasTexto.cartel(tamaño)` |
| D. Palabras | sobre Felipe u objeto, fuera de A–C | «¡CRÍTICO!», «¡POP!»…: 1 a la vez, 0,9 s, Silkscreen 16/24 con contorno de 1 px; `pegatina` = sobre pergamino | `Jugo.palabra` → `ZonasTexto.colocar_palabra` |
| E. Avisos de botón | burbuja sobre Felipe | «E Degustar» | `Indicador.rect_burbuja()` (D la esquiva) |

- **Diálogo y carteles se turnan:** un anuncio espera a que termine la frase (hasta `Anuncios.ESPERA_MAXIMA`); mientras se
  ve un anuncio, las frases nuevas esperan en la cola sin envejecer (`Dialogo.esperar`); la fase del jefe (urgente) hace
  ceder la frase (`Dialogo.ceder`), que vuelve después; mientras dura la franja de fase, ni las frases urgentes salen
  (`Dialogo.esperar_urgente`).
- **En tiempo real:** carteles, logro, franja de fase y palabras no se estiran con la cámara lenta de una derrota.
- **Letra:** los estilos de carteles y palabras (`ZonasTexto.ESTILOS_C_Y_D`) son de 16 px o más.
- **Prueba:** `pruebas/prueba_zonas_texto.gd` (rectángulos de todos los anuncios y palabras, HUD, diálogo, nombre del
  jefe, letras y que cada carácter de `textos.csv` exista en las letras del tema). Capturas:
  `pruebas/capturas_estabilizacion.gd -- <carpeta> [textos|luces]`.

**HUD limpio (2026-10-21):** zona A fija solo con los corazones (`Medidores`) y, en la pelea, la barra del jefe y el
contador de snacks (`Hud.snacks_fijos`). La agenda y los contadores entran deslizando 2 s al cambiar (`Hud.golpear` →
`Hud.mostrando`). Lo que se lleva se mira en la pausa: `PanelBolsillo` (vidas, calcetines, fotos, snacks). La burbuja
del Indicador esquiva caras (`Indicador.testigos`, misma regla que `ZonasTexto.colocar_palabra`).

**Lo roto y lo comido (por datos, `DatosObjeto`):** `piezas_rotura` (PiezaSuelta), `charco_*` y `queda` para lo que se
rompe; `vacio` para el recipiente que queda al comer. Arte: `herramientas/preparar_arte_nivel.py rotos|vacios`.

### Receta: un texto nuevo en pantalla

1. ¿Es un anuncio grande? `anuncios.anunciar(tipo, texto, tamaño, mostrar)`: sale en la zona C cuando le toca; el
   tamaño no pasa de 640 × 60.
2. ¿Es una palabra del mundo? `jugo.palabra_en_mundo(clave, donde, color, tamaño)`: se recoloca sola.
3. Nunca una segunda línea chica; si hace falta detalle, va a la libreta o al diálogo.
4. Corre `prueba_zonas_texto` y mira la captura.

## Las piezas del juego (componentes)

| Pieza | Qué hace | La llevan |
| --- | --- | --- |
| `Componentes` | Ayudante: `Componentes.de(nodo, Vida)` devuelve la pieza o null; `Componentes.nivel(nodo)` da el nivel; grupos `INTERACTUABLES` y `ENEMIGOS` | — |
| `Vida` | Máximo, actual, `danar`, `curar`, `llenar`, `morir`, `fijar`, invulnerable; señales `cambio`, `danado`, `murio` | Felipe (5 corazones), A.S.P.I. (3 fases), ratón (1), caja (1) |
| `RecibeGolpes` | Recibe `recibir_zarpazo` y pasa el daño a la Vida; rebota con escudo; `aturdir(segundos)` | Ratón, A.S.P.I., caja |
| `HaceDano` | Lastima a Felipe al tocarlo (rectángulo o círculo) | Ratón, A.S.P.I., bolas de pelo |
| `MovimientoPatrulla` | Va y viene, persigue si ve a Felipe, va a un destino, retrocede, huye | Ratón, A.S.P.I. |
| `Tirable` | Maña «Tirar»: se ofrece, cae en el cuadro de impacto, se rompe, aturde lo de abajo. Lo caído **queda en el piso** (no hay `reponer`: decisión del 2026-10-23); el soplido de A.S.P.I. lo tira con `soplar()` | Vaso, taza, macetas, llaves, pilas de libros |
| `FuenteDesorden` (datos en `datos/fuentes/`, `DatosFuente`) | Suelta cosas de a una (manotazo o el nivel la activa): cada una cae como `PiezaSuelta`, queda en el piso con sombra y avisa `soltada(pieza, mancha)`; el arte del mueble pasa a su versión con el hueco (`<arte>_<n>`); el contorno del Indicador sigue la silueta de la que va a caer; al acabarse deja de ofrecerse | Corcho (notas), estante del librero (libros), apuntes del teclado |
| `Aranable` | Maña «Arañar»: marcas, pelusa, crítico con garras, se rompe | Sofá, puerta entornada |
| `OyeMaullido` | Maña «Maullar»: oye dentro del radio y avisa con `oyo` | Valeria, A.S.P.I., puerta de la cocina |
| `Asustable` | Maña futura «Intimidar»: `asustar(quien)` → huye | Ratón, A.S.P.I. |
| `SueltaRecompensa` | Al morir la Vida suelta un Recogible | Caja de cartón |
| `SiluetaTapada` | Contorno de 1 px de Felipe solo donde un humano lo tapa (`clip_children` del humano) | Valeria |
| `ReaccionDerrota` (datos en `datos/derrotas/`, `DatosDerrota`) | Al morir la Vida: destello por silueta, congelado y sacudida (`Jugo`), sale volando y rebota (`move_and_collide`), «¡POP!» con piezas sueltas (`PiezaSuelta`: física simple, quedan en el piso, una puede seguir girando) y nube (`Particulas`), cámara lenta solo si sus datos la piden (vuelve siempre a `time_scale` 1), marca al lado, fantasmita y frase de Felipe | Ratón (se desarma), A.S.P.I. (rebota y escupe pelusa) |
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
| `estado_zoomies.gd` | `ZOOMIES` | La carrera en tres fases (anticipa, corre, derrapa) con su receta de jugo (datos `{"direccion"}`) |
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
| `MenuUI` (nodo `%Menu` de `menu_pausa.tscn`) | Columna de botones `BotonMenu` con foco: flechas, W/S, cruceta o palanca; Enter o A elige; el foco da la vuelta. Avisa `elegido(nombre)` | Menú de pausa (Continuar, Opciones, Reiniciar, Salir), opciones |
| Cuadro de diálogo (`cuadro_dialogo.tscn`) | Pergamino del kit con el marco de retrato encima del retrato, nombre en lacre y texto en tinta; `Dialogo` pone las frases | Diálogos de Felipe, Valeria y A.S.P.I. |
| `BotonMenu` (`scripts/ui/base/boton_menu.gd`; tipos en `datos/ui/*.tres`, `DatosBoton`) | Botón de menú: al apretar se encoge y vuelve con rebote; con foco o el mouse encima brilla y, si sus datos lo piden, se mece (vaivén con tween, nunca de golpe); entrada opcional cayendo desde arriba, escalonada por `MenuUI`; `principal` con pulso sutil; `estampar()` estampa el sello de sus datos y avisa `estampado`. **Variantes por datos y tema, sin herencia:** `boton_menu.tres` (el de siempre, variación `BotonMenu`) y `boton_pergamino.tres` (variación `BotonPergamino`, 112 × 44, sin vaivén, con sello; escena `escenas/ui/boton_pergamino.tscn`) | Menú de pausa (pergamino), opciones (el de siempre) |
| `SelloHuella` (`escenas/ui/sello_huella.tscn`) | Sello de lacre: `estampar()` lo deja caer en escalas enteras (3×, 2×, 1×), lo cambia por el lacre aplastado, suelta 3 destellos y espera; con `estampado_de_entrada` aparece ya puesto. Con «reducir movimiento» no cae ni vuelan los destellos | Botones de pergamino, pergamino de la pausa |
| `MarcoFicha` (`escenas/ui/marco_ficha.tscn`) | Marco de madera y oro en 9 partes con ventana de retrato y cuerpo de pergamino; `ventana()` y `cuerpo()` dicen dónde poner el contenido | `FichaSuMajestad` |
| `BarraEstadistica` (`escenas/ui/barra_estadistica.tscn`) | Ícono, nombre, barra (marco del kit y relleno de color, se llena de a poco) y frase de una línea; `escuchar(señal)` la conecta a una fuente que avisa `{estadistica: [valor, frase]}` | `FichaSuMajestad` |
| `FichaSuMajestad` (`escenas/ui/ficha_su_majestad.tscn`, datos en `datos/ui/ficha.tres`, `DatosFicha`) | Retrato, kilos y humor; escucha `Felipe.peso_cambiado`, calcula las estadísticas con la tabla del peso y avisa `estadisticas_cambiadas` a sus barras. **Solo de chiste:** nada del juego lee las estadísticas. Único lugar donde se ve el peso | Pausa |
| `FelipeEnCojin` (`escenas/ui/felipe_en_cojin.tscn`) | Felipe A a 0,72 con sus animaciones sobre el cojín y la corona aparte: mide el tope del cráneo de cada cuadro de la hoja y la apoya ahí | Pausa |
| `GestorPantallas` | Pila: `abrir(pantalla, pausa)`, `cerrar(pantalla)`, `arriba()`, `es_la_de_arriba(pantalla)`; pausa mientras haya una que pausa | `Pantallas` (título, intro, pausa, fin), `Libreta`, `ResumenDia` |
| `Estilo` | `color(&"nombre", alfa)`, `letra(&"nombre")`, `medida(&"nombre")`, `fuente()`, `texto_con_contorno`, `texto_centrado`; kit «Decreto real»: `panel(c, rect, &"panel")` (9 partes), `caja(&"nombre")`, `icono(&"hud_libreta")`, `relleno(c, textura, rect)` (barra sin deformar el pixel) | Todo lo que se dibuja con código |
| `RecetaJugo` (`scripts/sistemas/receta_jugo.gd`, datos en `datos/jugo/`) | Jugo de una acción con datos: anticipación, líneas de velocidad (`LineasVelocidad`), cámara adelantada, pausa de impacto y sacudida, polvo, pelos, derrape y marca (`MarcaDerrape`) | Zoomies; pausa de impacto de zarpazo, manotazo y arañazo |
| `PantallaOpciones` (`escenas/ui/pantalla_opciones.tscn`) | Opciones desde la pausa, en la pila de pantallas: una fila por acción para remapear (teclado y mando, Esc cancela), reducir movimiento y volumen (`Opciones`) | Pausa |
| `Controles` | Qué tecla o botón tiene cada acción (leído del InputMap), `etiquetar("{saltar}")`, `remapear`, `guardar`, `cargar` (`user://controles.cfg`, se carga al empezar el nivel) | Avisos, pistas de jefe, íconos (`IconosBotones` busca el ícono por tecla, así sigue al remapeo) |

Textos: todo lo que se lee es una clave de `traducciones/textos.csv` (interfaz `UI_`, frases `FELIPE_`/`VALERIA_`, agenda
`AGENDA_`/`RECOMPENSA_`, primeras frases `LECCION_`, palabras `PALABRA_`, logros `LOGRO_`, verbos `VERBO_`, jefe
`JEFE_`). El código y los datos guardan la clave y se traduce donde se muestra (diálogo, palabras, carteles, logros,
indicador, agenda, presentación del jefe). `prueba_interfaz.gd` revisa que ninguna clave usada falte.

Letra: `Estilo.fuente(&"estilo")` y `Estilo.letra(&"estilo")` dan la fuente pixel y su tamaño (siempre de diseño o
múltiplo); `Estilo.escribir` dibuja con ellas y `Estilo.recortar` corta con «…» lo que no cabe.

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

### Cómo darle una derrota a un enemigo nuevo

1. `datos/derrotas/` → *Nuevo recurso* → `DatosDerrota` (copia `raton.tres` si se desarma o `aspi.tres` si cae entero).
2. Llena los 5 pasos en el inspector: destello y congelado; impulso, vueltas y rebotes; si se desarma, sus `piezas`
   (nombres de imágenes de `assets/nivel1/`; si falta una, `PiezaSuelta` dibuja un provisional), la que sigue girando
   y la nube; la cámara lenta (solo jefes, en su golpe final; 1 = sin cámara lenta); la marca y el fantasmita; y el
   evento de `Frases.FELIPE` (frases de 1 línea, claves en `traducciones/textos.csv`).
3. En su `DatosEnemigo`, pon ese `.tres` en `derrota`. `Enemigo` arma la pieza `ReaccionDerrota` sola y la conecta a
   `Vida.murio`. Nada más: sin código.
4. Si es jefe, el cartel (tipo Broforce) lo pone su pelea con `PresentacionJefe.cartel` en su «momento»; la cámara lenta
   es de la derrota (no la pongas también en la pelea).
5. Prueba: `_probar_derrotas` en `prueba_componentes.gd` (se dispara con `Vida.murio`, suelta piezas, la llave para y la
   cámara lenta vuelve a 1); capturas con `pruebas/capturas_derrotas.gd`.

### Cómo agregar una fuente de desorden (algo que suelta cosas de a una)

1. Arte: la imagen del mueble y sus versiones con el hueco (`<arte>_1`, `<arte>_2`...) y cada cosa que cae, recombinadas
   del mismo arte (`preparar_arte_nivel.py desorden` es el ejemplo).
2. Datos: duplica `datos/fuentes/corcho.tres`: `arte`, `capa`, `verbo`, `piezas`, `salidas` (base de cada una en su
   lugar), `en_su_lugar` (contorno), `alcance`, `rect` (lado menor ≥ 24) y `mancha` ("" = la pieza es la mancha).
3. Una línea en `Nivel1.FUENTES`; `DesordenEstudio` la crea y la conecta a la pelea (`BatallaAspi.agregar_fuente`).
4. Corre `prueba_municion.gd` (la cuenta de manchas cambia) y mira una captura (`capturas_pelea.gd`).

**Pelea v3 (2026-10-23):** piezas comunes a toda pelea en `PeleaJefe`: `GloboDialogo` (`scripts/ui/`: lo que dice
Felipe durante la pelea va en un globito; `Dialogo.globo`) y `CamaraPelea` (`scripts/jefes/`: corre la cámara de Felipe
hacia el jefe si está fuera de pantalla o `amenaza()`, sin zoom, con flecha de borde). Lo de A.S.P.I.:
`Jugo.temblar(px, segundos, vertical)` (temblor de pantalla en píxeles enteros que decae, en el offset de la cámara del mundo;
respeta `Opciones.reducir_sacudida`), `ReaccionesAspi` (el piso tiembla al apagarla, despertar con «!» y pausa, marcas de aviso en el piso; números en
`DatosJugoJefe`, `datos/jefes/aspi_jugo.tres`, que cuelga de `DatosJefe.jugo`), `ConductaCortocircuito` (fase 3: corre al enchufe, apagón, charcos que la dejan en corto), `ApagonEstudio` (penumbra y
luces), `PelusaAspi` (sobrecarga y montañas), `Charco` (`scripts/entidades/objetos/`), `NotaArteGatuno` y los ganchos de
sonido `DatosJefe.sonidos` → `BatallaAspi.sonar_evento(evento, tono)`. Vulnerable por motivo:
`BatallaAspi.quedar_vulnerable("deposito" | "charco")`.

**Pelea v4 (2026-10-23):** `RemateAspi` (el momento estrella: quedar vulnerable, anticipación con el motor que falla,
`inflado` y humo, silencio con `Nivel.callar()`, pausa de impacto, destello de silueta, estrellas y `apagar()`),
`AyudaAspi` (íconos de botón sobre Felipe la primera vez que sirven), `ReaccionesAspi.marear()` (el 4.º tiempo de cada
ataque), `GloboDialogo.peligro` (la frase espera si hay amenaza), `Nivel.retener_logros` (los logros esperan; lo usa el
apagón) y los colores `peligro` / `oportunidad` del tema. Números nuevos en `DatosJugoJefe` (grupos «Remate» y
«Recuperación»).

**Montaña de pelusa (`MontanaPelusa`, `scripts/entidades/objetos/`):** la escupe la pelea (`BatallaAspi.escupir_pelusa`)
al apagarla (`DatosJefe.devuelve`) o al vaciar el depósito; se esparce con el manotazo («Esparcir») y cada mota avisa
`mota_en_piso`. La pelea lleva la cuenta de toda la suciedad (`suciedad_total`): solo baja al apagarla.

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

### Cómo agregar jugo a una acción

1. **Datos:** en `datos/jugo/` → *Nuevo recurso* → `DatosJugo`, con el nombre de la acción (`zoomies.tres`, `zarpazo.tres`):
   anticipación (segundos y forma, siempre dentro de ±8 %), líneas de velocidad, adelanto de cámara (sin zoom), pausa
   de impacto, sacudida y frase, polvo, pelos, derrape y marca. Lo que quede en 0 no se hace.
2. **Pasos:** en el estado o la pieza que hace la acción, `var receta := RecetaJugo.de(actor, "accion")` y llama sus
   pasos en su momento: `forma_anticipacion()` al entrar (con `felipe.efectos.estirar`), `correr(delta, direccion)`
   mientras va rápido, `adelantar_camara(camara, direccion)`, `polvo_y_pelos(direccion)` y `marca(direccion)` al
   frenar. Ejemplo completo: `scripts/entidades/felipe/estados/estado_zoomies.gd`.
3. **Impacto:** el actor emite su señal `impacto("accion")`; `Travesuras` llama `RecetaJugo.impacto_de(accion, jugo)`
   (pausa y sacudida del sistema `Jugo`) y dice la frase si la receta trae una.
4. **Medida:** sin sobrecargar (pilar 5, pero se tiene que leer): mira una tira de cuadros ampliada
   (`pruebas/capturas_zoomies.gd` es el modelo) y agrega una comprobación en `prueba_componentes.gd`.

### Cómo agregar una pantalla de menú

1. **Escena:** en `escenas/ui/`, un `VBoxContainer` con el script `scripts/ui/base/menu_ui.gd` y, por opción, una
   instancia de `boton_pergamino.tscn` (o un `Button` con `boton_menu.gd`, el de siempre) con una clave como texto
   (`MENU_OPCIONES`); `principal = true` en el principal. Un tipo de botón nuevo es un `.tres` de `DatosBoton` (y su
   variación del tema), no un script nuevo. Copia `menu_pausa.tscn`.
2. **Textos:** agrega las claves a `traducciones/textos.csv` (columna `es`).
3. **Pantalla:** el nodo que la muestra (un `Control` en una capa de `Capas`) la instancia, conecta `elegido(opcion)` a
   lo que haga cada opción y, al abrirse y cerrarse, llama `GestorPantallas.de(self).abrir(self)` y `.cerrar(self)`.
   Solo responde a teclas propias si `GestorPantallas.de(self).es_la_de_arriba(self)`.
4. **Colores y letras:** del tema (`Estilo.color(&"...")`); si falta uno, se agrega a `datos/ui/tema.tres`.
5. **Elegir:** si los botones sellan, la pantalla espera `await boton.estampar()` antes de hacer lo elegido (`Pantallas._al_elegir`).
6. Prueba: como `_probar_menu_y_pausa` en `prueba_interfaz.gd` (foco en la primera opción, elegir, el sello, la pausa).

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

**Giro en pixel art:** el juego se dibuja a 640×360 con snap a píxel (`2d/snap/*`) y se agranda entero; rotar un
botón se ve con dientes (no a saltos de posición: el pivote cae en un píxel entero). Se eligió lo más simple: giro
chico (6°), solo en los menús (con el juego en pausa) y apagable con **reducir movimiento** (`Opciones`, guardado en
`user://opciones.cfg`). Un SubViewport no ayudaba: también rendiría a 640×360.
