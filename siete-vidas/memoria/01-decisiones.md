# Decisiones cerradas

Actualizado: 2026-10-18. Detalle completo en la biblia (ver README.md).

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

## Mecánicas

- **Tres medidores:** afecto humano (por casa), respeto felino, peso. No hay medidor de hambre.
- **Snacks = curación (2026-10-18):** Felipe carga snacks (3 al inicio): los come ya o los guarda para una pelea; también come la comida del mundo con el botón de acción. Cada uno cura y suma peso. Sin daño por hambre ni temporizadores.
- **Botón de acción (2026-10-18):** un solo botón para interactuar con objetos; si el objeto es comida, Felipe la come. No hay botón de comer suelto ("comer sin comida no tiene sentido").
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

## Demo: primer nivel "La Gran Fuga" (2026-10-18)

- **Pelea con A.S.P.I., "La Bestia del Estudio" (2026-10-18, depósito lleno):** en su propio cuarto (el estudio de Valeria, una pantalla). Al entrar, A.S.P.I. despierta y la presentación de jefe (Broforce: congela, acercamiento, «¡BATALLA INICIADA!», nombre en franja) muestra la imaginación de Felipe: la bestia gigante en un estudio en llamas. **La imaginación solo se ve en la entrada**; después el estudio se ve normal. Los zarpazos rebotan (carcasa de titanio). **Ensuciar el piso** (maceta, rollo, vaso) deja manchas que ella va a limpiar aspirando (de pie arrastra; agachado se aferra); **cada mancha le llena el depósito**. Lleno, se detiene pitando «¡DEPÓSITO LLENO!», inofensiva, y **Felipe le cae encima para apretarle el botón de apagado** (rebota alto, como un pisotón; con el doble salto vuelve a la repisa). Si no llega a tiempo, lo vacía. Tres apagados: depósito de 2, 3 y 3 manchas, 4, 3,5 y 3 s detenida; tras cada uno se reinicia 1,5 s (quieta e inofensiva) y vuelve más rápida; en la fase 3 escupe bolas de pelo. Al tercero: «¡APAGADA!», Felipe se lame la pata y se abre el balcón (logro "Desenchufada"). Excepción a las proporciones: **las imaginaciones de Felipe** (solo decorado de fondo, sin colisión) pueden tener cualquier tamaño.
- **Reglas de diseño de niveles (2026-10-18):** todo nivel cumple `siete-vidas/diseno/reglas-de-niveles.md` (15 reglas sacadas de Mario, Celeste, Hollow Knight, Stray y otros); se aplican al diseñar y `prueba_reglas_nivel.gd` valida las medibles. Aplicadas al nivel 1: el segundo descanso es el cojín del pasillo, junto a la puerta del jefe.
- **Escala de gato (2026-10-18, decisión del creador):** el juego es una sátira desde la perspectiva de un gato, no una casa 100 % real. Felipe (67 px) es la medida; alturas de muebles casi reales (deciden los saltos); muebles y puertas gruesos (puertas de 104 px); lo que le importa al gato, grande (ratones a la mitad de Felipe, comida, calcetines, vasos y macetas al doble, A.S.P.I. más grande); nada interactuable menor a 24 px. Regla en CLAUDE.md.
- **Nivel 1, rediseño 3 (2026-10-18): habitaciones con puertas.** Cada habitación es un espacio aparte (cámara dentro del cuarto) y se pasa por **puertas** con el botón de acción o arriba (fundido a negro). Ruta: sala → recibidor (caja de arena, librero, dos rejas para bebés apiladas y la escalera) → cocina opcional → pasillo de arriba (cojín) → dormitorio opcional → estudio (A.S.P.I.) → balcón. **Se sube por la escalera de fondo** (dibujada en la pared; al pie, arriba o E y Felipe sube en diagonal, como una puerta), no por una cortina ni por escalones en primer plano: las rejas (1,5 m) se cruzan trepando el librero y se abren desde la escalera (atajo). La cortina queda en el dormitorio para un calcetín secreto. Diseño en `siete-vidas/diseno/nivel-01-gran-fuga.md`.
- **La demo es el tutorial del apartamento**, como dice la biblia: cada mueble enseña un movimiento con un aviso de una línea y la tecla o el botón del mando en uso. Recorrido vigente: sala → recibidor → (cocina) → escalera → pasillo → (dormitorio) → estudio con A.S.P.I. → balcón, donde gana **Caer de Pie** y termina la demo; detalle por zona en `siete-vidas/diseno/nivel-01-gran-fuga.md`.
- Pantallas de título, introducción (el video viral; "Me voy de esta casa"), pausa y final (tiempo, calcetines 3, logros, vidas perdidas). Logros de la demo: La Gravedad Funciona, Desenchufada, Coleccionista de Calcetines, Caer de Pie.
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
