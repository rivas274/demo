# Decisiones cerradas

Actualizado: 2026-10-19 (PARTE B del nivel 1 v4). Detalle completo en la biblia (ver README.md).

## Producto

- **Título (2026-10-18):** *Felipe: Nueve Vidas, Cero Disculpas* (inglés: *Nine Lives, Zero Regrets*). Antes era *Siete Vidas*; se cambió para que coincida con las 9 vidas en todos los idiomas. La carpeta del repositorio sigue llamándose `siete-vidas/` para no romper rutas.
- **Género:** metroidvania 2D en pixel art, con equipables al estilo Blasphemous.
- **Tono:** sátira picante, clasificación +16. Lo explícito siempre tapado con "censura irónica" (narrador de documental, pegatina de pescadito, aviso de "contenido sensible" que muestra una papa).
- **Duración:** 6 a 10 horas. **Alcance completo:** seis distritos y cinco finales. Dividir en etapas queda solo como plan B.
- **Plataformas:** PC primero (Steam). Consolas después, con un estudio de port.
- **Idiomas:** español latino e inglés al lanzar; el humor se adapta por idioma, no se traduce literal.
- **Motor y herramientas:** Godot 4 con GDScript con tipos; todo de código abierto donde se pueda.

## Historia

- **Protagonista:** Felipe Ron con Pasas, basado en el gato real del creador. Se hace llamar *Su Majestad Felipe Ron con Pasas I, el Magnífico*. Valeria, su dueña, le dice "Pipe".
- **Premisa:** un video viral de Felipe atorado en una caja de pizza lo humilla; Valeria además le pone dieta y compra una aspiradora robot. Felipe escapa ("No me escapo. Me autoexilio").
- **Ciudad:** Puerto Algoritmo, ciudad internacional inventada donde todo vale lo que valen sus likes.
- **Felipe es egoísta, no héroe:** se une a la resistencia contra Torres Paradise porque van a tumbar su techo de sol de 2 a 4.
- **Corazón:** Felipe vigila en secreto a Valeria desde los techos. **Final verdadero:** Duquesa confiesa que ella subió el video, por celos; Valeria pasó semanas buscándolo.
- **Finales:** Hijo Pródigo, Rey de los Tejados, Gato de Tres Familias, Final Buda (peso al máximo), Final Verdadero.

## Mundo (seis distritos)

1. **Barrio Viejo** (inicio): casa de Valeria (base), La Cuadra (centro), tienda de Don Chucho, casa de Doña Gertrudis.
2. **Distrito Neón:** estilo Tokio/Seúl nocturno; café de gatos que trabajan por likes.
3. **Downtown Hustle:** rascacielos; penthouse de Duquesa, casa de El Fit.
4. **El Muelle:** mafia de gatos piratas, el Patrón.
5. **El Basurero:** Ratópolis, esquema piramidal del Rey Rata.
6. **Torres Paradise** (final): la obra, la perrera, A.S.P.I. MAX.

## Pilares (2026-10-18)

- **Fantasía y pilares aprobados** en `siete-vidas/diseno/pilares.md`: "Es como Hollow Knight, con la ironía de Untitled Goose Game, y además el castigo nunca llega". Pilares: 1 Un barrio que se descubre, 2 Cada maña es llave y travesura, 3 Siempre te sales con la suya, 4 Tus decisiones tienen peso, 5 Épico en su cabeza. Con anti-pilares y juegos de referencia. Desempatan toda decisión.

## Prototipos

- **Travesuras v1 (2026-10-18): CAMBIAR.** Tirar, arañar, maullar e intimidar con la voz de Felipe y respuesta épica divierten al principio, pero sin incentivo pierden sentido; el medidor de CAOS y el puntaje no sirven. Se prueba en v2 la **Agenda de Su Majestad**: lista de 5 a 8 travesuras con nombre por nivel (algunas secretas), cada una con recompensa útil (calcetín, snack por perdón, foto vergonzosa o un camino nuevo) y resumen al final del nivel; sin contador de puntos.

- **Travesuras v2 (2026-10-19): SEGUIR.** La Agenda de Su Majestad, el rascador (teatro para Valeria) y la voz de Valeria (lo trata de "bebito gordito", vive para sus redes) funcionan. Pasan al nivel 1.
- **Fase 3 (2026-10-19):** el creador decide pasar al nivel 1 tutorial con calidad final y mejorar el arte. Primero se rediseña el nivel en papel, se aprueba y después se construye.

- **Nivel 1 v4 aprobado (2026-10-19)** (construido; documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md`): doble salto, Zoomies y trepar apagados en el nivel 1; snacks en bolsillo de 5, calcetines al nido (10 = una ranura de maña), fotos a la galería; animaciones nuevas de arañar y maullar (intimidar, después); Valeria con 4 poses de Gemini y caminar; escalera de fondo con reja y librero, con animación de subir.

- **Controles nuevos (2026-10-19, al construir la parte A):** maullar con **Q** (mando **B**, el único libre); la Agenda con **Tab** (mando **View/Select**); saltar la frase del diálogo con **Enter** (mando **LB**). Comer un snack: mantener la acción 0,6 s sin nada cerca. El diálogo va arriba cuando Felipe está en el piso y abajo cuando está arriba, para no taparlo nunca.

- **Plan de arte del nivel 1 aprobado (2026-10-19)** (`siete-vidas/diseno/nivel-01-plan-arte.md`): Valeria inventada (moño castaño, sudadera verde azulado, buzo gris, pantuflas de gato); su caminar con hoja de Gemini; SpriteCook 72 créditos (subir_escalera, aranar, maullar) + 26 de reserva; encargo a Gemini tanda 3 (3A primero).

- **Baño (2026-10-19, idea del creador):** la casa tendrá baño, como lugar visto que se desbloquea con una maña más adelante (pilar 1). En el nivel 1: puerta cerrada en el pasillo de arriba con luz bajo la puerta, goteo y frase de Felipe ("El trono de porcelana. Algún día será mío."). Se abre con una **acción nueva que Felipe aprende viendo a otro gato** (más adelante ve a un gato colgarse de una manilla y desde ese momento puede "Abrir puertas"): siempre pudo, pero no lo había descubierto. Adentro: rollo para desenrollar, tina, cajón con foto vergonzosa y calcetín. Se arma cuando exista ese momento en el juego. **En el juego desde el 2026-10-19 (pasada de ambientes):** puerta cerrada en x 4740 del pasillo (ensanchado 200 px), con el marco de las demás, luz fría bajo la puerta que titila, goteo solo sonoro, la frase al acercarse o al «Probar» (tiembla y no cede) y, quieto 2 s cerca, el destello de la manilla con «Esa manija me mira raro.». No es habitación ni lugar visto; «Abrir puertas» todavía no existe y no va en la tabla de acciones ni en la ficha.

- **Luz y efectos (2026-10-19, aprobado como prueba):** sí, con poco y con estilo: ambiente por cuarto (CanvasModulate), luces puntuales con textura en escalones (no degradado suave), partículas sutiles (polvo en rayos, vapor, pelusas), brillo solo en lo que emite luz, viñeta y gradación solo en momentos épicos. No: mapas de normales, sombras dinámicas realistas, bloom fuerte, filtros VHS. Primero un prototipo en la sala al atardecer (antes/después + clip); si gusta, receta de luz por cuarto en una pasada.

## Mecánicas

- **Tres medidores:** afecto humano (por casa), respeto felino, peso. No hay medidor de hambre.
- **Snacks = curación (2026-10-18):** Felipe carga snacks (3 al inicio): los come ya o los guarda para una pelea; también come la comida del mundo con el botón de acción. Cada uno cura y suma peso. Sin daño por hambre ni temporizadores.
- **Botón de acción (2026-10-18):** un solo botón para interactuar con objetos; si el objeto es comida, Felipe la come. No hay botón de comer suelto ("comer sin comida no tiene sentido").
- **Ajuste del salto (2026-10-19, aprobado por el creador):** cae con más peso que sube (gravedad de caída 1,7 × la de subida, tope 740 px/s), margen de 0,12 s, salto recordado de 0,15 s y más polvo cuanto más fuerte cae; la subida y la altura no cambian y estirar/aplastar sigue en ±8 %.
- **Agacharse (2026-10-18):** Felipe se agacha y gatea para pasar bajo muebles; agachado + saltar baja a través de repisas.
- **Peso (2026-10-18):** no cambia el dibujo ni el movimiento de Felipe (para mantenerlo simple). **Las formas (Flaco, Gordito, Modo Buda) se descartan.** El peso sube de verdad la **defensa, el carisma y el ataque**; la velocidad aparece solo como chiste y no cambia. Se ve en la **"Ficha de Su Majestad"** del menú de pausa (retrato, barras y una frase satírica por estadística, como "Así se ve un rey"); no hay báscula en la interfaz.
- **Diálogos con retratos (2026-10-18):** los pensamientos y ocurrencias de Felipe salen en un cuadro con su retrato (las 9 caras); en las conversaciones sale también el del otro personaje. Es el gancho del humor (pilar 5).
- **Estilo épico (2026-10-18):** todo se ve y se siente épico como Broforce y Balatro (carteles, cámara lenta, palabras y números que saltan, sacudidas): Felipe es el más pro en su cabeza.
- **Nueve vidas** por partida (2026-10-18; antes 7: se pasa a 9 para que sea internacional, como en inglés).; al perderlas, Felipe despierta en casa con el **Collar de la Vergüenza** (baja el respeto hasta reconquistar a Valeria).
- **Poderes (moverse y pelear), en orden:** Zarpazo, Caer de Pie (apartamento), Afilar Garras (Barrio Viejo), Doble Salto (Neón), Zoomies (Downtown), Licuado (Muelle). La puerta final pide respeto y afecto altos.
- **Mañas:** 17 equipables con ventaja y precio; 2 ranuras al inicio, hasta 6 (10 calcetines = 1 ranura).
- **Acciones de gato:** pedir comida, infiltrarse, popo táctico, tirar cosas de la mesa, meterse en cajas, peleas en los techos, casas paralelas.
- **Combate:** enemigos comunes fáciles y graciosos; jefes con reto. Felipe nunca golpea humanos (los vence con trampas); los animales derrotados huyen ofendidos.
- **Jefes:** A.S.P.I., Hermanos Callejeros, Michi-Star, Tanque, el Patrón, Rey Rata, Kaiser, A.S.P.I. MAX (final).
- **Guía anti-frustración:** tutorial jugando, "El Manual de Su Majestad", pistas tras 3 muertes, mapa con iconos de poder faltante, rascador de entrenamiento.
- **Accesibilidad:** controles reasignables, subtítulos ajustables, modo daltónico, modo asistido que no bloquea logros.
- **Logros:** 40 en Steam (lista en la biblia); coleccionables: 50 calcetines, 30 fotos vergonzosas, lagartijas.

## Demo: primer nivel "La Gran Fuga" (v4, construido el 2026-10-19)

Documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md` (recorrido, agenda, mapa con medidas y cumplimiento R1–R19).

- **Siete cuartos con puertas** (cámara dentro de cada cuarto, fundido a negro, ninguno de menos de 640 px): sala → recibidor → (cocina) y escalera → pasillo → (dormitorio) y estudio → balcón. Se juega **sin doble salto, Zoomies ni trepar**; todo escalón obligatorio mide 60 px o menos.
- **Nada se enseña con carteles:** sin avisos ni fila de controles (M2). Enseñan el `Indicador` (contorno + burbuja con el botón y el verbo) y las primeras frases de Felipe (`Sala.LECCIONES`, una vez por zona).
- **Valeria en escena (planta baja):** sentada en el sofá con el portátil; va al ruido y regaña 5 s con un corazón roto; Felipe se frota ("Encantar") y lo perdona; con el rascador delante graba 8 s de espaldas al sofá; si Felipe araña el sofá delante de ella, lo deja frente al rascador. Al salir Felipe al recibidor se encierra en la cocina; maullar del otro lado (o el popo táctico) la hace abrir. Arriba no oye: audífonos.
- **Escalera de fondo con reja anti-fuga** (48 px de dibujo, colisión fina, cartel "PIPE: NO. Con amor, mamá" por código): se pasa por el librero (repisas a 48/103/155) saltando la reja; se sube escalón por escalón con `subir_escalera` y el pasamanos delante al 70 %; el pestillo desde adentro es el atajo.
- **Agenda del nivel:** 8 travesuras (3 secretas) conectadas a su sitio y reacción (`Sala.AGENDA_SITIOS`); el balcón termina con el **resumen del día** (ya no hay pantalla final).
- **Pelea con A.S.P.I. ("La Bestia del Estudio", depósito lleno):** entrada de 8 pasos en `PresentacionJefe` (pasos como datos; cada jefe da sus datos), que empieza después del fundido de la puerta. Ensuciar llena el depósito; lleno, se le cae encima («¡CLIC!» con congelado, destello, sacudida y polvo). Ataques siempre anunciados: embestida (luz roja 0,5 s), soplido contra el que acampa desde la fase 2 (luz amarilla 0,6 s; más de 3 s arriba de algo de más de 90 px), bolas de pelo en arco en la fase 3 (tos 0,5 s). Lo roto vuelve de a uno cada 6 s; los papeles del teclado son manchas extra. Al perder una vida conserva la fase y la entrada corta dura 1 s. Ensayo sin daño en el pasillo (A.S.P.I. limpia el vaso de la consola).
- **Diferencias con la propuesta (decididas al construir):** un solo ratón cuida el pollo; la cama no se pasa agachado (es sólida); microondas de 98 × 54 para un escalón de 54 px; dormitorio de 720 px y cocina de 960 px para no dejar huecos sin salida; baúl atravesable.
- **Reglas de diseño de niveles (2026-10-18):** todo nivel cumple `siete-vidas/diseno/reglas-de-niveles.md` (R1–R19); `prueba_reglas_nivel.gd` valida las medibles (también arte contra colisión a ±2 px, lado menor ≥ 24 px y puertas medidas en la imagen).
- **Escala de gato (2026-10-18, decisión del creador):** el juego es una sátira desde la perspectiva de un gato, no una casa 100 % real. Felipe (67 px) es la medida; alturas de muebles casi reales (deciden los saltos); muebles y puertas gruesos; lo que le importa al gato, grande; nada interactuable con lado menor de menos de 24 px. Regla en CLAUDE.md. Excepción: **las imaginaciones de Felipe** (solo decorado de fondo, sin colisión) pueden tener cualquier tamaño.
- Pantallas de título, introducción (el video viral; "Me voy de esta casa") y pausa. Logros de la demo: La Gravedad Funciona, Atajo de Gato, Coleccionista de Calcetines, Galería Viral, Desenchufada, Caer de Pie.
- **Peso con personalidad:** humor de Felipe según los kilos (Atlético, Esponjoso, Modo Invierno, Modo Buda). La báscula de la interfaz se quitó (2026-10-18: "se ve mal").

## Prototipo jugable (2026-10-18)

- **Vida:** 5 corazones por vida y 9 vidas; al perderlas todas, vuelven las 9 con el Collar de la Vergüenza. Comer cura 1 corazón y suma 0,3 kg.
- **A.S.P.I.** es el primer enemigo: patrulla, persigue a Felipe si lo ve a su altura, quita 1 corazón al tocarlo y se apaga con 3 zarpazos.
- **Interfaz** con estilo de red social: corazones como "me gusta", vidas y logros como notificaciones.

## Forma de construir (2026-10-17)

- **Método por fases y equipo chico (2026-10-18, decisión del creador):** el desarrollo avanza por fases (1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento) con un equipo chico de agentes y comandos de Claude Code adaptado de Claude Code Game Studios y GodotPrompter (MIT, créditos en `.claude/CREDITOS.md`). Se empieza por los pilares y un prototipo de las acciones de gato; el nivel 1 queda como base y se vuelve a él después. Detalle y fase actual en `README.md` (Equipo de diseño).
- **Primero la prueba de concepto, después el arte final.** Los escenarios, enemigos e interfaz se arman con arte provisional dibujado por código (gratis) para afinar la jugabilidad; cuando el concepto esté cerrado, se reemplazan las texturas por las finales. No se gastan créditos de SpriteCook en escenarios hasta entonces.
- **Proporciones (2026-10-18):** Felipe es un gato grande (persa de 8 kilos, grande y no obeso): Valeria mide 3 Felipes y Felipe ocupa 67 px de alto en pantalla. El mundo usa medidas reales a 1,21 px por cm.
- **Profundidad con parallax en capas (como Silksong):** cada escena tiene capas lejanas que se mueven menos que la cámara, la capa de juego, y un primer plano de siluetas oscuras que se mueve más. La cámara se mueve en horizontal y en vertical.

## Legal (Steam)

- Cero marcas reales dentro del juego (ya se cambiaron: R-00MBA → A.S.P.I., Garfield → Buda, Gato con Botas → Ojos de Súplica, WhatsApp/TikTok → "los chats"/"internet").
- Cero personas reales, cero gatos famosos, cero imágenes de memes.
- Licencias comerciales para cada recurso; aviso MIT de Godot en créditos; contrato de cesión con colaboradores.
- **Arte con IA:** declararlo en Steam. El arte final debe estar retocado o unificado a mano; la IA sirve para bocetos y bases.
- Pregunta abierta: ¿Valeria está basada en una persona real? Si sí, cambiar nombre o pedir permiso escrito.
- **Sistema de la casa (2026-10-19, plan de ambientes):** un solo marco de puerta (140 × 248) en todos los estados, una sola ventana (la de la sala, en 9 partes), zócalo y cornisa iguales en los 6 cuartos, cuadros con el borde de arriba en el dintel (`Sala.DINTEL`), luz del oeste hacia la derecha con el tono de cada cuarto, y la regla de islas para la decoración (pegada a un mueble, fuera de los rectángulos sagrados, menos de 24 px si no se pisa).
