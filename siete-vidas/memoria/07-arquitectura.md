# Arquitectura del juego: piezas y datos

Actualizado: 2026-10-23 (interfaz v2 «A + C» con el kit en el tema (`KitUI`), zonas del layout con zona segura, salud de 9 huellas
(`SaludFelipe`); antes, 2026-10-20: plan de estabilización: capas de humanos y zonas de texto; antes, segunda ronda: Felipe con estados, jefes con conductas en datos, Valeria en partes, carpetas
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
- **La interfaz** también son piezas: la barra de vida (las 9 huellas de Felipe y la barra del jefe) se conecta a la
  vida y se mueve sola; los carteles, menús, el bolsillo y el cuadro de diálogo son piezas con su escena. Los colores,
  letras y **las piezas del kit v2** están en **un solo tema** y los textos en **un archivo de traducción** (hoy en
  español): cambiar «Pausa», un color o una pieza del kit no toca código.

Por qué importa (pilar 2, «cada maña es llave y travesura»): cuando exista una maña nueva, funcionará con **todo lo
que lleve la pieza**. Intimidar asustará a cualquier cosa con «se asusta»; un coletazo tirará cualquier cosa con «se
puede tirar».

## Patrones usados y por qué

| Patrón | Dónde | Por qué |
| --- | --- | --- |
| **Composición con componentes** (nodos hijos con `class_name`, un trabajo cada uno) | `scripts/componentes/` | Una entidad nueva es juntar piezas que ya funcionan; sin herencia frágil |
| **Observador (señales)** | Las piezas avisan (`Vida.cambio`, `Vida.murio`, `Tirable.caido`, `OyeMaullido.oyo`); el Nivel avisa al guion; Felipe avisa a la interfaz (`collar_cambiado`, `snacks_cambiados`; su salud: `SaludFelipe.reaparecio`, `pocas_huellas`, `desmayado`) | Nadie busca a nadie: quien junta las piezas conecta lo que le importa. La interfaz no pregunta en cada cuadro |
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
- **La interfaz dibujada con código** (huellas, diálogo, carteles, libreta, resumen, barra del jefe) pide sus colores
  y letras por nombre a `Estilo` (`Estilo.color(&"ui_texto")`) y sus piezas del kit v2 a `KitUI` (`KitUI.pieza(c,
  "dialogo-marco-valeria", rect)`, con el nombre del PNG); los nodos `Control` (botones) toman el tema solos porque es
  el tema del proyecto. Sin excepciones: el retrato de Valeria dibujado por código se borró (las caras salen de las
  hojas, achicadas a su tamaño por `herramientas/interfaz_v2_caras.py`).

## Mapa de carpetas (`siete-vidas/juego/`)

| Carpeta | Qué hay |
| --- | --- |
| `escenas/nivel_1.tscn` | El nivel 1 (escena principal): `Nivel` + `Felipe` + `Interfaz` + `Guion` (`GuionNivel1`) |
| `escenas/entidades/` | `felipe.tscn` (con su `Vida`), `raton.tscn`, `aspi.tscn`, `caja_carton.tscn`, `comida.tscn`, `objeto_tirable.tscn` |
| `escenas/ui/` | `barra_vida.tscn` (9 huellas), `barra_jefe.tscn`, `menu_pausa.tscn`, `cuadro_dialogo.tscn`, `pantalla_opciones.tscn`, `ficha_su_majestad.tscn`, `barra_estadistica.tscn` |
| `datos/enemigos/`, `datos/objetos/`, `datos/jefes/` | `DatosEnemigo` (ratón, A.S.P.I.), `DatosObjeto` (vaso, taza...), `DatosJefe` (`aspi.tres`: fases, carteles, números por fase y sus conductas) |
| `datos/ui/tema.tres` | El tema: colores (paleta v2: `ui_fondo`, `ui_panel`, `ui_linea`, `ui_texto`, `ui_apagado`, `ui_contorno`, `personaje_felipe`, `personaje_valeria`, `personaje_aspi`, `oportunidad`...), tamaños de letra y medidas con nombre (tipo `Felipe`), **las piezas del kit v2** (`styles/v2_<pieza>` las que se estiran, `icons/v2_<pieza>` las demás y las caras `v2_cara_*`; las pone `herramientas/interfaz_v2_tema.py` desde el README del kit) y los botones `BotonMenu`/`BotonOpcion` |
| `traducciones/textos.csv` | Textos de la interfaz por clave (columna `es`); Godot genera `textos.es.translation` al importar |
| `scripts/componentes/` | Las piezas y el ayudante `Componentes` (tabla abajo) |
| `scripts/entidades/felipe/` | `Felipe` (movimiento, entrada y el inicio de cada acción) y sus partes: `estados/` (un archivo por estado), `SaludFelipe` (las 9 huellas), `AgachadoFelipe`, `TreparFelipe`, `EfectosFelipe`, `AnimadorFelipe`, `ManasFelipe`, `AnimacionesFelipe`, `Chispas` |
| `scripts/entidades/valeria/` | `Valeria` (qué hace y cómo reacciona: actividades, regañar, perdonar, grabar), `AspectoValeria` (poses, fundidos, giro, accesorios) y `RutaValeria` (cruzar puertas, dónde pararse) |
| `scripts/entidades/enemigos/` | `Enemigo` (ratón y A.S.P.I.), `Apariencia` |
| `scripts/entidades/objetos/` | `Objeto` (lo que se tira), `CajaCarton`, `CajasMudanza`, `Comida`, `Rascador`, `Laser`, `Recogible`, `Calcetin` |
| `scripts/jefes/` | `PeleaJefe` (pelea genérica), `ConductaJefe` (base de los ataques) y `aspi/` (`BatallaAspi`, sus cuatro conductas, `DibujoBatallaAspi`, `AparienciaAspi`, `EnsayoAspi`) |
| `scripts/nivel/` | Lo común a todo nivel: `Nivel`, `DatosNivel`, `GuionNivel`, `Puerta`, `ArteNivel`, `SombrasVivas` |
| `scripts/niveles/nivel_1/` | Lo propio del nivel 1: `Nivel1` (datos), `GuionNivel1`, `ValeriaPorLaCasa`, `FinalBalcon`, `ArteNivel1`, `DecoradoNivel1`, `FondoApartamento`, `LuzCuarto` |
| `scripts/sistemas/` | Lo que no se ve pero ordena el juego: `Capas` (tabla única de capas), `Controles` (InputMap, remapeo), `Particulas` (fábrica de polvo), `Travesuras`, `Agenda`, `Recompensas`, `Frases`, `Jugo` |
| `scripts/ui/` | Pantallas y avisos: `Pantallas`, `Hud` (carteles), `Medidores` (salud y logro), `Dialogo`, `GloboDialogo`, `Anuncios`, `Libreta`, `ResumenDia`, `Indicador`, `IconosBotones`, `PresentacionJefe`, `FichaSuMajestad`, `PantallaOpciones` |
| `scripts/ui/base/` | `Estilo` (acceso al tema), `KitUI` (dibuja las piezas del kit v2 con su medida lógica), `ZonasTexto` (zonas del layout y zona segura), `GestorPantallas` (pila), `MenuUI` (menú navegable), `BotonMenu` |
| `scripts/ui/piezas/` | `BarraVida`, `CuadroDialogo`, `Cartel`, `PanelBolsillo`, `BarraEstadistica`, `PiezaKit` |
| `scripts/datos/` | Las clases de los recursos: `DatosEnemigo`, `DatosObjeto`, `DatosJefe` |
| `pruebas/` | Pruebas automáticas (`prueba_componentes.gd` para las piezas del juego, `prueba_interfaz.gd` para las de la interfaz), el bot `partida.gd` y las capturas |

Tamaños: el más grande es `felipe.gd` (≈620 líneas; pendiente partirlo), luego `guion_nivel_1.gd` (572), `presentacion_jefe.gd` (507),
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

**Zonas de texto** (`scripts/ui/base/zonas_texto.gd`, tabla única como `Capas`; pantalla de 640×360; layout v2 aprobado
el 2026-10-23, `diseno/interfaz-v2.md`). **Todo lo que se lee va dentro de la zona segura de títulos** (`ZonasTexto.SEGURA`:
el 90 % del centro, de (32, 18) a (608, 342)):

| Zona | Lugar | Qué va | Quién la usa |
| --- | --- | --- | --- |
| A. Salud | desde (32, 18), 152×20 (grande 304×40) | Cara de Felipe y 9 huellas. Nada más fijo | `Medidores` (`BarraVida` HUELLAS) |
| A2. Jefe | hasta (608, 18), 250×44 | Retrato, nombre en franja (abreviado si no cabe: `BarraVida.titulo_corto`), barra con fases I-II-III y daño reciente. Solo en la pelea; mientras se ve (`ZonasTexto.jefe_visible`), B y C bajan | `PresentacionJefe.POS_BARRA` |
| B. Diálogo | arriba, y 44–103 (grande 64–163); abajo solo si Felipe está muy arriba | Caja de 528 px con retrato de 52 px y franja del nombre; 2 líneas por página | `Dialogo` → `CuadroDialogo` |
| C. Carteles | desde `ZonasTexto.techo()` (y 44; en la pelea, bajo la barra del jefe) | Travesura, fase del jefe, «PODER NUEVO» centrados; el logro, a la derecha (`ZonasTexto.logro`) | `Anuncios` (cola única) |
| D. Palabras | sobre Felipe u objeto, dentro de la zona segura y fuera de A–C | «¡CRÍTICO!», «+1»…: 1 a la vez, 0,9 s, Silkscreen 16/24 con contorno de 1 px; `pegatina` = sobre el panel oscuro | `Jugo.palabra` → `ZonasTexto.colocar_palabra` |
| E. Avisos de botón | burbuja sobre Felipe | «E Degustar» | `Indicador.rect_burbuja()` (D la esquiva) |
| F. Globito y avisos del jefe | sobre el personaje, bajo A y A2 | Globito de Felipe (una línea), «[E] ¡APLASTA!» con borde limón y flecha | `GloboDialogo`, `DibujoBatallaAspi` |

- **Diálogo y carteles se turnan:** un anuncio espera a que termine la frase (hasta `Anuncios.ESPERA_MAXIMA`); mientras se
  ve un anuncio, las frases nuevas esperan en la cola sin envejecer (`Dialogo.esperar`); la fase del jefe (urgente) hace
  ceder la frase (`Dialogo.ceder`), que vuelve después; mientras dura la franja de fase, ni las frases urgentes salen
  (`Dialogo.esperar_urgente`).
- **En tiempo real:** carteles, logro, franja de fase y palabras no se estiran con la cámara lenta de una derrota.
- **Letra:** todo estilo del tema es de 16 px o más (11 px de cuerpo; con texto grande, 32), salvo las marcas del mundo
  que no hace falta leer (`ZonasTexto.ESTILOS_DECORATIVOS`: rótulos, «REC», letra dentro de las teclas). Lo comprueba
  `prueba_interfaz.gd`.
- **Prueba:** `pruebas/prueba_zonas_texto.gd` (rectángulos de todos los anuncios y palabras, HUD, diálogo, nombre del
  jefe, letras y que cada carácter de `textos.csv` exista en las letras del tema). Capturas:
  `pruebas/capturas_estabilizacion.gd -- <carpeta> [textos|luces]`.

**HUD mínimo (interfaz v2, 2026-10-23):** fija solo la salud (`Medidores`); en la pelea, la barra del jefe. Sin
contadores en el HUD (ni snacks, ni vidas, ni agenda): al recoger algo sale «+1» sobre Felipe (`Travesuras._al_sumar`)
y lo que se lleva se mira en la pausa: `PanelBolsillo` (salud, snacks, calcetines, fotos y el collar). La burbuja del
Indicador esquiva caras (`Indicador.testigos`, misma regla que `ZonasTexto.colocar_palabra`).

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
| `Vida` | Máximo, actual, `danar`, `curar`, `llenar`, `morir`, `fijar`, invulnerable; señales `cambio`, `danado`, `murio` | Felipe (18 medias = 9 huellas; las reglas en `SaludFelipe`), A.S.P.I. (3 fases), ratón (1), caja (1) |
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
| `estado_desmayado.gd` | `DESMAYADO` | «Siesta táctica»: 9 gatitos fantasma suben y vuelven; reaparece en el descanso con todo lleno, sin perder nada (`SaludFelipe.desmayarse` / `volver`) |
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
| `BarraVida` (`escenas/ui/barra_vida.tscn`, `barra_jefe.tscn`) | Muestra una `Vida`: `conectar(vida)` y se mueve sola con `Vida.cambio`. Forma `HUELLAS`: la caja de la salud con la cara de Felipe (mueca al golpe) y una huella cada 2 medias en 5 estados (llena, media, vacía, golpe y curando), golpe con destello de 60 ms y rebote, cura de abajo arriba, cascada de 60 ms, latido con 3 o menos, `grande` al doble. Forma `BARRA`: retrato, franja del nombre, 3 segmentos I-II-III (la fase activa en su color), capa de daño reciente que baja 300 ms después, temblor al cambiar de fase y franja de escudo | Salud de Felipe (`Medidores`), barra del jefe (`PresentacionJefe`: la pelea pone en la Vida del jefe las fases que le quedan) |
| `KitUI` (`scripts/ui/base/kit_ui.gd`) | Dibuja las piezas del kit v2 con las medidas de la lámina: `pieza(c, "nombre", rect)` (las que se estiran, con su medida lógica: sombra y contorno caen afuera), `icono`, `textura`, `franja_texto`, `fragmentos`, `escribir(c, x, y_mayus, ...)` (como la lámina: arriba de las mayúsculas) | Todo lo dibujado de la interfaz v2 |
| `PiezaKit` (`scripts/ui/piezas/pieza_kit.gd`) | Una pieza del kit en una escena, al tamaño del nodo, con un texto opcional (franja de título) | Pausa y opciones (panel y franjas) |
| `CuadroDialogo` (`cuadro_dialogo.tscn`) | Caja oscura con la sombra del color del personaje, retrato de 52 px sobre su fondo inclinado con fragmentos, franja del nombre y flecha que late; el texto (%Texto) a 24 px del borde; entra subiendo 10 px; normal o grande, arriba o abajo. `Dialogo` pone las frases y las pagina de a 2 líneas | Diálogos de Felipe, Valeria y A.S.P.I. |
| `GloboDialogo` | Globito de una línea con orejitas, cola con huellita y sombra ámbar sobre Felipe, dentro de la zona segura | Lo que dice Felipe en la pelea |
| `Cartel` (`Cartel.crear`, `Cartel.medida`) | Franja diagonal ámbar con sello en rombo y título en Silkscreen 16, y una segunda línea oscura con el nombre; barrido de 140 ms con rebote de 4 px | Carteles de travesura y «PODER NUEVO» (la cola es `Anuncios`) |
| `MenuUI` (nodo `%Menu` de `menu_pausa.tscn`) | Columna de botones `BotonMenu` con foco: flechas, W/S, cruceta o palanca; Enter o A elige; el foco da la vuelta. Avisa `elegido(nombre)` | Menú de pausa (Continuar, Bolsillo, Ficha, Opciones, Reiniciar, Salir), opciones |
| `BotonMenu` (`scripts/ui/base/boton_menu.gd`; tipo en `datos/ui/boton_menu.tres`, `DatosBoton`) | Botón de menú del kit v2 (19 px; con foco, el bloque diagonal ámbar): al apretar se encoge y vuelve con rebote; entrada opcional barriendo desde la izquierda, escalonada por `MenuUI`. Un tipo nuevo es otro `.tres` y su variación del tema, sin herencia | Pausa y opciones |
| `PanelBolsillo` | Filas del kit con ícono, nombre y valor: salud («6 y media de 9»), snacks, calcetines y fotos; el collar junto al título | Pausa |
| `BarraEstadistica` (`escenas/ui/barra_estadistica.tscn`) | Fila de 17 px: nombre, barra con puntas en diagonal (se llena de a poco) y frase de una línea; `escuchar(señal)` la conecta a una fuente que avisa `{estadistica: [valor, frase]}` | `FichaSuMajestad` |
| `FichaSuMajestad` (`escenas/ui/ficha_su_majestad.tscn`, datos en `datos/ui/ficha.tres`, `DatosFicha`) | Panel del kit con el retrato presumido, «SU MAJESTAD · kilos» y el humor; escucha `Felipe.peso_cambiado`, calcula las estadísticas con la tabla del peso y avisa `estadisticas_cambiadas` a sus barras. **Solo de chiste:** nada del juego lee las estadísticas. Único lugar donde se ve el peso | Pausa |
| `GestorPantallas` | Pila: `abrir(pantalla, pausa)`, `cerrar(pantalla)`, `arriba()`, `es_la_de_arriba(pantalla)`; pausa mientras haya una que pausa | `Pantallas` (título, intro, pausa, fin), `Libreta`, `ResumenDia` |
| `Estilo` | `color(&"nombre", alfa)`, `letra(&"nombre")`, `medida(&"nombre")`, `fuente()`, `texto_con_contorno`, `texto_centrado`, `recortar`; `panel(c, rect, &"panel")` (el panel oscuro genérico o un estilo del tema), `caja(&"nombre")`, `icono(&"nombre")` | Todo lo que se dibuja con código |
| `RecetaJugo` (`scripts/sistemas/receta_jugo.gd`, datos en `datos/jugo/`) | Jugo de una acción con datos: anticipación, líneas de velocidad (`LineasVelocidad`), cámara adelantada, pausa de impacto y sacudida, polvo, pelos, derrape y marca (`MarcaDerrape`) | Zoomies; pausa de impacto de zarpazo, manotazo y arañazo |
| `PantallaOpciones` (`escenas/ui/pantalla_opciones.tscn`) | Opciones desde la pausa, en la pila de pantallas, en una lista que se desplaza y sigue al foco: primero la accesibilidad («Golpes»: normal, suaves o ninguno; «Texto grande»; reducir movimiento y sacudida), volumen, vibración y una fila por acción para remapear (teclado y mando, Esc cancela) (`Opciones`) | Pausa |
| `Controles` | Qué tecla o botón tiene cada acción (leído del InputMap), `etiquetar("{saltar}")`, `remapear`, `guardar`, `cargar` (`user://controles.cfg`, se carga al empezar el nivel) | Avisos, pistas de jefe, íconos (`IconosBotones` busca el ícono por tecla, así sigue al remapeo) |

Textos: todo lo que se lee es una clave de `traducciones/textos.csv` (interfaz `UI_`, frases `FELIPE_`/`VALERIA_`, agenda
`AGENDA_`/`RECOMPENSA_`, primeras frases `LECCION_`, palabras `PALABRA_`, logros `LOGRO_`, verbos `VERBO_`, jefe
`JEFE_`). El código y los datos guardan la clave y se traduce donde se muestra (diálogo, palabras, carteles, logros,
indicador, agenda, presentación del jefe). `prueba_interfaz.gd` revisa que ninguna clave usada falte.

Letra: `Estilo.fuente(&"estilo")` y `Estilo.letra(&"estilo")` dan la fuente pixel y su tamaño (siempre de diseño o
múltiplo); `Estilo.escribir` dibuja con ellas y `Estilo.recortar` corta con «…» lo que no cabe.

## Receta: una pieza nueva del kit v2

1. El PNG va en `assets/ui/v2/` con su fila en el `README.md` del kit (tamaño, medida lógica, ancla y cortes de 3 partes).
2. `python3 siete-vidas/herramientas/interfaz_v2_tema.py`: la pone en el tema (`styles/v2_<pieza>` si se estira; si no,
   `icons/v2_<pieza>`). Las caras: `interfaz_v2_caras.py`.
3. En el código: `KitUI.pieza(c, "<pieza>", Rect2(x, y, ancho_logico, alto))` o `KitUI.icono(c, "<pieza>", pos)`. Nunca un
   color suelto: `Estilo.color(&"ui_texto")`.
4. `prueba_interfaz.gd` (`_probar_kit_v2`) revisa que toda pieza que pide el código exista en el tema.

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

## Profundidad: capas por rol (regla, v5, decisión del creador del 2026-10-23)

«Clasificar todo y definir bien las capas, como el ratón y A.S.P.I.»: **ningún nodo del mundo pone su `z_index` a
mano**. Cada nodo que se dibuja con capa propia lleva la pieza `Profundidad` (`scripts/componentes/profundidad.gd`) con
un **rol** (`Capas.Rol`), y su z sale de **una sola función**, `Capas.z_para(rol, contexto)`, con la tabla de
`capas.gd` como única fuente de verdad. `prueba_capas.gd` lo comprueba (nadie escribe `z_index`, `z_as_relative` ni
`Capas.usar`; todo lo que se dibuja colgado del nivel tiene rol; las reglas se cumplen con Felipe en el piso, en el aire
y sobre cada superficie del nivel).

- **El evento central:** `VigiaSuperficie` (lo crea el Nivel) mira lo que hay bajo las patas de Felipe después de que
  se movió y, solo si cambió, llama a `Profundidad.felipe_cambio(arbol, superficie)` ("piso", el nombre del mueble o
  "aire"). Se recalculan solo los roles que dependen de Felipe (SALTABLE, APOYADO, ENEMIGO_PISO, JUGADOR); nadie
  pregunta cada cuadro.
- **Roles y reglas** (detalle en el encabezado de `capas.gd`):
  - `SALTABLE`: cada mueble donde se sube va en su nodo (`ArteNivel1.crear_fondo`, `Nivel1.superficies_del_arte`) y sube un
    escalón con Felipe encima, salvo que un saltable de delante se le cruce.
  - `APOYADO`: sabe su superficie (`Nivel.superficie_en`). Va delante de Felipe solo si él está en esa misma
    superficie; si no, detrás. Al caer pasa a `OBJETO_JUEGO` y en el piso a `RESTO_PISO`.
  - `ENEMIGO_PISO`: delante de todo mueble; contra Felipe en el piso, según `DatosEnemigo.delante_de_felipe`; con
    Felipe subido o en el aire, detrás de él.
  - `JUGADOR`: Felipe (delante de los humanos e imaginando, como contexto). `HUMANO`: Valeria.
  - Fijos: `FONDO` (con orden), `PARED`, `FACHADA`, `ARTE_PARED`, `ESCALERA`, `PUERTA`, `DECORADO`, `SOMBRA`, `VELO`,
    `TRAS_FELIPE`, `OBJETO_JUEGO`, `MARCA`, `PRIMER_PLANO`, `LUZ`, `ESTELA`, `IMAGINACION`, `EFECTO`, `CENSURA`,
    `INDICADOR`, `CONTORNO` (el z que pide el objeto contorneado), `JUEGO`.
- **Los datos traen el rol:** `DatosObjeto.rol` (APOYADO por defecto) y `DatosEnemigo.rol` (ENEMIGO_PISO).
- Roles nuevos siempre **al final** del enum (los `.tres` guardan el número).

### Cómo agregar algo nuevo al mundo
1. Elige su rol en `Capas.Rol` (¿se sube encima? `SALTABLE`; ¿está apoyado en un mueble? `APOYADO` con su superficie;
   ¿se toca? `OBJETO_JUEGO`; ¿efecto? `EFECTO`...).
2. `Profundidad.poner(nodo, Capas.Rol.<ROL>, superficies)` en su `_ready` o al crearlo (o el rol en sus datos).
3. Nada más: no escribas `z_index`. Corre `prueba_capas.gd`.

**Pelea v5 (2026-10-23):** `AplastarAspi` (acción «Aplastar»: un interactuable con `prioritario(felipe)`, que
`ManasFelipe.objeto_cercano` mira antes que todo lo demás y con su propio alcance; salto dirigido por un arco de Bézier
que corre en `process_physics_priority` alto, después de Felipe, con la máscara de colisión apagada mientras vuela) y
`CalmaAspi` (un solo foco a la vez: velo sobre el decorado, sin motas en el rayo, LED quieta, restos oscuros con menos
pedazos, «+1» chico). Los números, en `DatosJugoJefe` (grupos «Aplastar» y «Ruido»). `FondoApartamento.sin_motas`,
`Objeto.max_pedazos`, `PiezaSuelta.tinte_resto` y `PresentacionJefe.cartel_visible()` son los enganches.

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

1. **Escena:** en `escenas/ui/`, el panel del kit (`PiezaKit` con `pieza = "pausa-panel"` en la zona segura), una
   franja de título (`PiezaKit` con `texto`) y un `VBoxContainer` con el script `scripts/ui/base/menu_ui.gd` y, por
   opción, un `Button` con `boton_menu.gd` y una clave como texto (`MENU_OPCIONES`); `principal = true` en el
   principal. Un tipo de botón nuevo es un `.tres` de `DatosBoton` (y su variación del tema), no un script nuevo.
   Copia `menu_pausa.tscn`. Si la lista es larga, va en un `ScrollContainer` con `follow_focus` (como las opciones).
2. **Textos:** agrega las claves a `traducciones/textos.csv` (columna `es`).
3. **Pantalla:** el nodo que la muestra (un `Control` en una capa de `Capas`) la instancia, conecta `elegido(opcion)` a
   lo que haga cada opción y, al abrirse y cerrarse, llama `GestorPantallas.de(self).abrir(self)` y `.cerrar(self)`.
   Solo responde a teclas propias si `GestorPantallas.de(self).es_la_de_arriba(self)`.
4. **Colores, letras y piezas:** del tema (`Estilo.color(&"...")`, `KitUI.pieza(...)`); si falta uno, se agrega a
   `datos/ui/tema.tres`. Todo dentro de `ZonasTexto.SEGURA` y con letra de 16 px o más.
5. Prueba: como `_probar_menu_y_pausa` en `prueba_interfaz.gd` (foco en la primera opción, elegir, la pausa).

### Cómo traducir un texto

1. En el código, nunca el texto: una clave. `tr("UI_MI_TEXTO")` (en un `Control`, basta poner la clave como texto:
   se traduce solo). Con números: `tr("BOLSILLO_DE") % [snacks, maximo]` y en el archivo `%s de %s`.
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
