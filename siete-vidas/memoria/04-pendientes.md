# Pendientes

Orden acordado: un tema a la vez, con propuesta y aprobación.

- [x] **Ficha de concepto publicada en línea** con la acción «Tirar» (2026-10-19, versión 34).
- [ ] **Mostrar al creador** la cocina de 1340 px y las cajas de la mudanza (`cocina-escalera-antes-despues.png`, `cocina-escalera-detalles.png`, `nivel1-v4h.mp4`).

## Ahora (Fase 1 – Concepto y pilares)

1. [x] **Pilares** (2026-10-18): `siete-vidas/diseno/pilares.md`. Biblia en línea actualizada; las reglas entraron como R17 a R19.
2. [ ] **Prototipo de acciones de gato** (Fase 2): `/prototipo` para responder "¿es divertido ser Felipe?" (botón de acción para comer, tirar y arañar; maullar; intimidar) en `siete-vidas/prototipos/`, sin tocar el nivel.
   - v1 hecha (`siete-vidas/prototipos/travesuras/`): CAMBIAR. Ahora v2 con la Agenda de Su Majestad en lugar del medidor de CAOS.
   - Incluir en el prototipo (pilar 5): cuadro de diálogo con retratos (pensamientos de Felipe) y respuesta jugosa tipo Balatro.
   - Al volver al nivel: **entrada de jefe en 8 pasos** dentro de `PresentacionJefe` (sin vuelta atrás, espera, revelar de abajo arriba, nombre, barra que se llena, música, tamaño, rugido) y jugo en la pelea; lista en `.claude/skills/godot-felipe/SKILL.md` §6b. Recursos gratis CC0 de Kenney (sonidos, partículas, interfaz) como opción, anotando créditos.
   - [x] **Ajuste del salto (2026-10-19):** gravedad de caída de 1,38× a 1,7× (2400; tope 740 px/s), margen 0,12 s, salto recordado 0,15 s, polvo según la velocidad de caída (8 a 28 granos); subida y altura sin cambios, estirar/aplastar en ±8 %. Pruebas de movimiento y escenario ampliadas; video antes/después con `pruebas/demo_salto.gd`.
   - [x] Baño: puerta cerrada en el pasillo de arriba (pasada de ambientes, 2026-10-19).
   - [ ] Baño completo y la maña "Abrir puertas" (Felipe la aprende al ver a otro gato colgarse de una manilla): diseñar el momento y el cuarto; recién ahí entra a la tabla de acciones y a la ficha.
   - [ ] Mostrar al creador la hoja `ambientes-antes-despues.png` y el video `nivel1-v4e.mp4`, y mandar la hoja a Gemini con la pregunta de `revisiones/2026-10-19-ambientes-gemini.md`.
   - Prueba de luz y efectos en la sala al atardecer (después de la pasada del piso); si gusta, receta por cuarto.
3. [ ] **Volver al nivel 1** con lo que el prototipo apruebe (regla de los tres lugares) y seguir hacia el vertical slice. Antes de cada cambio de fase, `/puerta-fase`.

## Nivel 1 v4 (Fase 3)

- [x] **PARTE A (2026-10-19):** acciones de Felipe (maullar, arañar, subir escalón, snack del bolsillo de 5, efectos en el cuadro de impacto), habilidades apagadas en el nivel 1 y sistemas reutilizables (Agenda, libreta, HUD y carteles, resumen del día, diálogo con retratos, jugo, Indicador con íconos de Kenney, recompensas, rascador, arañables). Prueba `prueba_acciones.gd`.
- [x] **PARTE B (2026-10-19):** mapa nuevo de 7 cuartos con el arte medido (colisión a ±2 px del borde opaco), Valeria en escena (poses y caminar de Gemini), escalera de fondo con reja anti-fuga y librero, frotarse (ronronear contra Valeria), agenda completa conectada, ensayo de A.S.P.I. en el pasillo, pelea nueva (8 pasos, sin negro, soplido, bolas en arco, entrada corta), balcón con resumen del día, bot sin habilidades (agenda 8 de 8) y video. Documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md`.
- [x] Ficha en línea publicada (2026-10-19) (https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe): la copia local ya tiene las filas de la PARTE A y la de frotarse (lo hace el creador o la sesión principal).
- [x] Revisión 2 del nivel 1 (`revisiones/2026-10-19-nivel1-v4.md`): los hallazgos de código están arreglados (G1, G2, G3, G5, G6, G7, M1–M7; G4 provisional por código) y bajar la escalera tiene prueba. Estado de cada uno en `nivel-01-gran-fuga.md`, sección 11.
- [x] Revisión 3 (`revisiones/2026-10-19-nivel1-v4-revision3.md`): todos los hallazgos arreglados por código y con el arte que mandó el creador (sección "Arreglos" del informe; estado en `nivel-01-gran-fuga.md`, sección 12). Video `nivel1-v4c.mp4`.
- [ ] Mostrar al creador el video `nivel1-v4c.mp4`; cuarta revisión con `revisor-niveles` mirando transiciones.
- [ ] Arte de Gemini que espera (tanda 3D): `dormitorio-cortina.png` (G4, hoy la cortina va por código). Opcional: A.S.P.I. con la tapa a medio abrir, fachada de la panadería, ventana del pasillo con vista (hoy por código).
- [x] `caminar` nuevo de Felipe con pasos largos (2026-10-19, SpriteCook `pixel-engine-v1.5` desde Felipe A, 26 créditos): pie apoyado 3,6 px del juego por cuadro, el ciclo va a 33 cuadros/s a 120 px/s (antes 1,8 px y tope de 34; G9). La hoja vieja (`felipe-walk-sheet.png`) queda en reserva por pedido del creador.
- [ ] Opcional (Gemini o SpriteCook): transiciones de Valeria (pararse del sofá, agacharse) y "tomar café"; hoy son fundidos cruzados de 0,2 s y respiración por código.
- [ ] Animación `entrar_puerta` (G8): el creador decidió no pedirla todavía; las puertas siguen con fundido.
- [ ] Intimidar (G9): queda para el Barrio Viejo (decisión del creador). La pieza `Asustable` ya está lista en el ratón y A.S.P.I. (`07-arquitectura.md`): la maña solo tiene que llamar `asustar(felipe)` a las que estén cerca.
- [x] Arquitectura por piezas y datos (2026-10-20, `07-arquitectura.md`).
- [x] Partir `valeria.gd` y `batalla_aspi.gd` bajo ~600, Felipe con estados, jefes con conductas en datos e interfaz con piezas, tema, pila de pantallas y textos traducibles (2026-10-20, `07-arquitectura.md`).
- [ ] Traducir las frases de Felipe y Valeria (`Frases`) y los textos de niveles y jefes a claves en `traducciones/textos.csv` (hoy pasan por `tr()` en español: preparado, no hecho).
- [ ] Pantalla de opciones para remapear controles (la base ya está: `Controles.remapear`, `guardar` y `cargar`).
- [ ] Una letra de pixel para toda la interfaz: se pone una vez en `datos/ui/tema.tres` (`default_font`) y la toman todos (`Estilo.fuente()`). Los tamaños de letra de la libreta, el resumen, el indicador y la presentación del jefe siguen como números en su dibujo: pasarlos al tema al elegir la letra.
- [ ] Opcional: animación `sentarse` desde Felipe A (SpriteCook, 20 créditos) para la baranda del balcón (M6; hoy se queda quieto y se acicala).
- [ ] Sonidos finales (hoy sintetizados con `sonidos_demo.py`, incluidos maullido, arañar, ronroneo y resorte) y sonido de casa (G13); música de la pelea.
- [ ] Ajustar la dificultad de la fase 3 con una persona (el bot llega con 1 a 5 corazones).

## Diseñar después (de los pilares)

- [ ] **Ficha de Su Majestad** (menú de pausa): retrato, defensa, carisma, ataque y velocidad (chiste) con frases satíricas según el peso; definir cuánto sube cada una.
- [ ] Snacks cargados: dónde se recargan además de las recompensas (bolsillo de 5 y comer manteniendo la acción, hechos el 2026-10-19).
- [ ] Retratos de otros personajes para los diálogos (Valeria, gatos del techo): encargo a Gemini con costo.

## En curso

- [x] **Diseño final de Felipe:** versión A del híbrido v2.
- [x] **Animaciones base de Felipe:** quieto, caminar, correr, zarpazo, comer, saltar, ronronear, desmayo (SpriteCook) + daño y efectos de salto (código). Ficha: https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe
- [x] Pendientes de Felipe: ronronear, desmayo (+ vida fantasma por código), Collar de la Vergüenza, 9 retratos para diálogos.
- [x] Animación de agacharse y gatear (SpriteCook, 28 créditos, 2026-10-18).
- [x] Animaciones de ocio (2026-10-18, 76 créditos): acicalarse, jugar con estambre y perseguirse la cola, en el juego tras 8 s sin tocar nada.
- [x] Acicalarse y jugar rehechos desde Felipe A (40 créditos); estambre como objeto por código; una sola escala; deformación máxima ±8 %.
- [x] Gatear desde Felipe A con `pixel-engine-v1.5` (26 créditos): consistente, con transición al bajar y al pararse; huecos para pasar agachado de 45 cm.
- [x] Agacharse (baja la cabeza al piso) y caída rehechos desde Felipe A con `v1.5` (52 créditos). Todas las animaciones son consistentes.
- [ ] Opcional de Felipe: daño con pose propia; desmayo patas arriba con ojos en X (el actual cae boca abajo).

## Siguientes

- [ ] Dirección artística completa: paleta final por distrito, diseño de humanos y de los demás gatos.
- [ ] Diseño de personajes secundarios (Valeria, Duquesa, Don Chucho, el Patrón, Rey Rata, A.S.P.I.).
- [ ] Música y sonido en detalle.
- [ ] Guion del primer acto (la fuga, La Cuadra, jefe A.S.P.I.).
- [x] Proyecto de Godot montado en `siete-vidas/juego/` (2026-10-17): Felipe jugable (caminar, correr, salto con margen y salto recordado, altura variable, doble salto, Zoomies, zarpazo, comer, aterrizaje con patas delanteras), sala de prueba del apartamento, prueba automática, capturas/video y exportación automática a Windows y Linux con GitHub Actions.
- [x] Escenario provisional del apartamento (2026-10-17; escala corregida el 2026-10-18): 1920×454 con techo de 3,5 m, Felipe de 67 px, 13 muebles con medidas reales y alcanzables, fondo del Barrio Viejo en 4 capas de parallax más pared, luz y primer plano; prueba `prueba_escenario.gd`.
- [x] Mecánicas del prototipo (2026-10-18, arte provisional): corazones y vidas (hoy 9) con desmayo y reaparición, comer cura y suma peso, báscula en la interfaz, A.S.P.I. (patrulla, persigue, 3 zarpazos), vaso con el logro "La Gravedad Funciona" y notificaciones de logros. Prueba `prueba_mecanicas.gd`.
- [x] **Demo jugable: primer nivel "La Gran Fuga"** (2026-10-18): tutorial completo con título, avisos, ratón, caja de cartón, calcetines, láser, cortina para trepar, A.S.P.I. jefa, balcón con Caer de Pie, pausa, final y sonidos provisionales. Prueba `prueba_nivel.gd`.
- [ ] Arte de A.S.P.I. con Gemini (encargado a la sesión "gemini" de la Dell; integrar al llegar a `siete-vidas/arte/referencias/gemini/`).
- [x] Animación de trepar desde Felipe A (2026-10-18, `pixel-engine-v1.5`, 26 créditos).
- [x] Nivel 1 rediseñado como dúplex de dos pisos (2026-10-18): trepar, atajo del dormitorio, A.S.P.I. que se aturde; las 4 pruebas pasan.
- [x] Pelea con A.S.P.I. con entrada tipo Broforce, imaginación gigante y tres fases (2026-10-18); prueba `prueba_jefe.gd`.
- [x] Presentación de jefe reutilizable (`PresentacionJefe`) y bot que juega el nivel completo (`partida.gd`, también graba el video del gameplay) (2026-10-18).
- [ ] Música de la pelea (coro épico) y arte final de la bestia gigante y del fin del mundo (pedir a Gemini).
- [x] Arte de Gemini integrado en el nivel 1 (2026-10-18): muebles, paredes, piso, objetos, A.S.P.I., cielo y ciudad en parallax, fin del mundo y A.S.P.I. gigante (`preparar_arte_nivel.py`).
- [x] Rediseño 3 del nivel 1 (2026-10-18): habitaciones con puertas, escalera con rejas y librero, pelea en el estudio (ensuciar y desenchufar), imaginación solo en la entrada, arte sin partes blancas. Un bot (`partida.gd`) lo termina con los 3 calcetines.
- [x] Escala de gato, escalera de fondo y pelea de depósito lleno (2026-10-18); el bot termina sin recibir golpes.
- [ ] Falta arte para el punto del láser (hoy dibujado por código). La tanda 2 de Gemini ya está en el juego.
- [ ] Siguiente después de la demo: La Cuadra, afecto y respeto, música.
- [ ] Hojas finales de Felipe generadas a ~67 px de alto (hoy se reducen al 72 % y los pixeles quedan disparejos).
- [ ] Arte final de escenarios (tileset, fondos por capa, muebles) cuando el concepto esté afinado.
- [ ] Prototipo jugable: Felipe moviéndose en el apartamento de Valeria.
- [ ] Lanzamiento: redes de Felipe, página de Steam, demo, lista legal.

## Preguntas abiertas


- Gemini (Nano Banana) directo: falta que el creador agregue `GEMINI_API_KEY` al entorno (se lee en una sesión nueva). Sirve para imágenes fijas, no animaciones.



## Jugo de las acciones (después del reordenamiento, 2026-10-20)

Idea tomada de un video sobre cómo hacer que un dash se sienta bien (5 pasos). Encaja con el pilar 5 (respuesta jugosa, como Balatro).

- [x] **Zoomies: polvo y derrape al frenar (aprobado por el creador; hecho 2026-10-20 con efectos de código, `EstadoZoomies` + `datos/jugo/zoomies.tres`).** Al terminar el impulso, Felipe patina unos px con nube de polvo y pelos y una marca de derrape en el piso: da sensación de más velocidad y concuerda con el humor (un gato de 8 kg que no sabe frenar). Primero con efectos de código; una animación de derrape desde Felipe A (≈26 créditos) solo si el creador la aprueba.
- [x] **Zoomies, resto de la receta (hecho 2026-10-20):** anticipación de 0,05 s (aplastar y estirar dentro de ±8 %), líneas de velocidad pixel art, pausa corta y sacudida si choca con un mueble (con frase de Felipe). Ya tiene estela. Sin zoom de cámara (deforma el pixel art): adelantar la cámara hacia donde corre.
- [x] **Pieza reutilizable `RecetaJugo` (hecha 2026-10-20; salto, zarpazo, tirar y arañar ya tenían lo suyo: solo se pasó a datos la pausa de impacto de zarpazo, manotazo y arañazo)** (anticipación, estela, líneas, pausa de impacto, polvo) con sus números por acción, y revisar con ella salto, zarpazo, tirar y arañar del nivel 1.
- Cuándo: los Zoomies están apagados en el nivel 1 (se ganan en Downtown); se hace al terminar el reordenamiento del código, no antes.

## Menú con estambre (aprobado por el creador, 2026-10-20)

- [x] **Botones colgando de estambre:** cada botón es un letrero que cuelga de un hilo y se balancea (comportamiento ya pedido en el botón base: apretar 90 % con rebote, balanceo hasta 6° con foco, entrada que cae con rebote, opción «reducir movimiento»). **Hecho (2026-10-20)** en `BotonMenu` con el arte de Gemini (`07-arquitectura.md`).
- [x] **Manotazo de Felipe:** al elegir un botón, Felipe asoma por el costado del menú y le da un manotazo con la animación `zarpazo` (sin créditos); el letrero se columpia más fuerte y suelta pelusa. **Preparado:** `BotonMenu.golpear(fuerza)` (columpio + señal `golpeado` para la pelusa) y `MenuUI.colocar_hueco(boton)` (nodo `HuecoFelipe` al costado); **hecho** con `FelipeAsomado` en el menú de pausa (única pantalla con botones; el título, la intro y el final siguen con «[Enter] …»).
- [x] **Arte:** encargo a Gemini en `siete-vidas/diseno/encargo-gemini-menu-estambre.md` (letreros, letrero principal con coronita, hilo, ovillo, pelusa).
