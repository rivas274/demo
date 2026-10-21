# Pendientes

Orden acordado: un tema a la vez, con propuesta y aprobación.

- [x] **Ficha de concepto publicada en línea** con la acción «Tirar» (2026-10-19, versión 34).

## Ahora (Fase 1 – Concepto y pilares)

1. [x] **Pilares** (2026-10-18): `siete-vidas/diseno/pilares.md`. Biblia en línea actualizada; las reglas entraron como R17 a R19.
2. [ ] **Prototipo de acciones de gato** (Fase 2): `/prototipo` para responder "¿es divertido ser Felipe?" (botón de acción para comer, tirar y arañar; maullar; intimidar) en `siete-vidas/prototipos/`, sin tocar el nivel.
   - v1 hecha (`siete-vidas/prototipos/travesuras/`): CAMBIAR. Ahora v2 con la Agenda de Su Majestad en lugar del medidor de CAOS.
   - Incluir en el prototipo (pilar 5): cuadro de diálogo con retratos (pensamientos de Felipe) y respuesta jugosa tipo Balatro.
   - Al volver al nivel: **entrada de jefe en 8 pasos** dentro de `PresentacionJefe` (sin vuelta atrás, espera, revelar de abajo arriba, nombre, barra que se llena, música, tamaño, rugido) y jugo en la pelea; lista en `.claude/skills/godot-felipe/SKILL.md` §6b. Recursos gratis CC0 de Kenney (sonidos, partículas, interfaz) como opción, anotando créditos.
   - [x] **Ajuste del salto (2026-10-19):** gravedad de caída de 1,38× a 1,7× (2400; tope 740 px/s), margen 0,12 s, salto recordado 0,15 s, polvo según la velocidad de caída (8 a 28 granos); subida y altura sin cambios, estirar/aplastar en ±8 %. Pruebas de movimiento y escenario ampliadas; video antes/después con `pruebas/demo_salto.gd`.
   - [x] Baño: puerta cerrada en el pasillo de arriba (pasada de ambientes, 2026-10-19).
   - [ ] Baño completo y la maña "Abrir puertas" (Felipe la aprende al ver a otro gato colgarse de una manilla): diseñar el momento y el cuarto; recién ahí entra a la tabla de acciones y a la ficha.
   - Prueba de luz y efectos en la sala al atardecer (después de la pasada del piso); si gusta, receta por cuarto.
3. [ ] **Volver al nivel 1** con lo que el prototipo apruebe (regla de los tres lugares) y seguir hacia el vertical slice. Antes de cada cambio de fase, `/puerta-fase`.

## Nivel 1 v4 (Fase 3)

- [x] **PARTE A (2026-10-19):** acciones de Felipe (maullar, arañar, subir escalón, snack del bolsillo de 5, efectos en el cuadro de impacto), habilidades apagadas en el nivel 1 y sistemas reutilizables (Agenda, libreta, HUD y carteles, resumen del día, diálogo con retratos, jugo, Indicador con íconos de Kenney, recompensas, rascador, arañables). Prueba `prueba_acciones.gd`.
- [x] **PARTE B (2026-10-19):** mapa nuevo de 7 cuartos con el arte medido (colisión a ±2 px del borde opaco), Valeria en escena (poses y caminar de Gemini), escalera de fondo con reja anti-fuga y librero, frotarse (ronronear contra Valeria), agenda completa conectada, ensayo de A.S.P.I. en el pasillo, pelea nueva (8 pasos, sin negro, soplido, bolas en arco, entrada corta), balcón con resumen del día, bot sin habilidades (agenda 8 de 8) y video. Documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md`.
- [x] Ficha en línea publicada (2026-10-19) (https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe): la copia local ya tiene las filas de la PARTE A y la de frotarse (lo hace el creador o la sesión principal).
- [x] Revisión 2 del nivel 1 (`revisiones/2026-10-19-nivel1-v4.md`): los hallazgos de código están arreglados (G1, G2, G3, G5, G6, G7, M1–M7; G4 provisional por código) y bajar la escalera tiene prueba. Estado de cada uno en `nivel-01-gran-fuga.md`, sección 11.
- [x] Revisión 3 (`revisiones/2026-10-19-nivel1-v4-revision3.md`): todos los hallazgos arreglados por código y con el arte que mandó el creador (sección "Arreglos" del informe; estado en `nivel-01-gran-fuga.md`, sección 12). Video `nivel1-v4c.mp4`.
- [ ] Arte de Gemini que espera (tanda 3D): `dormitorio-cortina.png` (G4, hoy la cortina va por código). Opcional: A.S.P.I. con la tapa a medio abrir, fachada de la panadería, ventana del pasillo con vista (hoy por código).
- [x] `caminar` nuevo de Felipe con pasos largos (2026-10-19, SpriteCook `pixel-engine-v1.5` desde Felipe A, 26 créditos): pie apoyado 3,6 px del juego por cuadro, el ciclo va a 33 cuadros/s a 120 px/s (antes 1,8 px y tope de 34; G9). La hoja vieja (`felipe-walk-sheet.png`) queda en reserva por pedido del creador.
- [ ] Opcional (Gemini o SpriteCook): transiciones de Valeria (pararse del sofá, agacharse) y "tomar café"; hoy son fundidos cruzados de 0,2 s y respiración por código.
- [ ] Animación `entrar_puerta` (G8): el creador decidió no pedirla todavía; las puertas siguen con fundido.
- [ ] Intimidar (G9): queda para el Barrio Viejo (decisión del creador). La pieza `Asustable` ya está lista en el ratón y A.S.P.I. (`07-arquitectura.md`): la maña solo tiene que llamar `asustar(felipe)` a las que estén cerca.
- [x] Arquitectura por piezas y datos (2026-10-20, `07-arquitectura.md`).
- [x] Partir `valeria.gd` y `batalla_aspi.gd` bajo ~600, Felipe con estados, jefes con conductas en datos e interfaz con piezas, tema, pila de pantallas y textos traducibles (2026-10-20, `07-arquitectura.md`).
- [x] Frases de Felipe y Valeria, agenda, primeras frases, palabras, logros, verbos y textos del jefe por clave en `traducciones/textos.csv` (2026-10-20; una prueba revisa que ninguna clave falte).
- [x] Pantalla de opciones desde la pausa: remapear controles (teclado y mando), reducir movimiento y volumen (2026-10-20; el aspecto llega con el menú Decreto real).
- [x] Letra pixel en toda la interfaz (2026-10-20): Pixel Operator (CC0) y Silkscreen (OFL), sin suavizado, con los tamaños en el tema.
- [ ] Opcional: animación `sentarse` desde Felipe A (SpriteCook, 20 créditos) para la baranda del balcón (M6; hoy se queda quieto y se acicala).
- [ ] Sonidos finales (hoy sintetizados con `sonidos_demo.py`, incluidos maullido, arañar, ronroneo y resorte) y sonido de casa (G13); música de la pelea.
- [ ] Ajustar la dificultad de la fase 3 con una persona (el bot llega con 1 a 5 corazones).

## Diseñar después (de los pilares)

- [ ] **Ficha de Su Majestad** (menú de pausa): retrato, defensa, carisma, ataque y velocidad (chiste) con frases satíricas según el peso; definir cuánto sube cada una.
- [x] Snacks: además de las recompensas, el plato de Felipe recarga 1 y los puntos de descanso rellenan hasta 3 (decisión del creador, 2026-10-20).
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
- Los Zoomies siguen apagados en el nivel 1 (se ganan en Downtown).
- [ ] Rehacer la animación de derrape: hoy se inclina poco y no clava las patas delanteras. Pedirla de nuevo desde Felipe A con `pixel-engine-v1.5` (≈26 créditos), cuadro por cuadro, cuando se activen los Zoomies (Downtown). (Sugerencia del creador, 2026-10-20.)

## Derrotas jugosas (aprobadas por el creador, 2026-10-20)

- [x] **Lógica, datos y pruebas (hechos 2026-10-20):** `ReaccionDerrota` + `DatosDerrota` (`datos/derrotas/raton.tres` y `aspi.tres`), `PiezaSuelta`, frases de Felipe «derrota_raton» y «derrota_aspi», cámara lenta del golpe final de A.S.P.I. movida a su derrota.
- [x] **Arte de Gemini (hecho 2026-10-20):** `herramientas/preparar_arte_nivel.py derrotas` recorta `arte/referencias/gemini/derrotas.png` a la escala del ratón y sin blanco puro: `derrota_carcasa`, `derrota_llave_1` a `_5`, `derrota_resorte`, `derrota_resorte_alma` (sin la sombra ovalada), `derrota_tornillo`, `derrota_engranaje`, `derrota_pelusa`. Se quitaron los provisionales de `PiezaSuelta`. Las nubes de pelusa de la hoja no se usan (la nube son partículas).
- [ ] **Mostrar al creador:** `derrota-raton.gif` y `derrota-aspi.gif`.

## Menú «Decreto real» (elegido por el creador, 2026-10-20)

- [x] **Pausa «Decreto real» (hecha 2026-10-20):** Ficha de Su Majestad a la izquierda (retrato, kilos, humor y barras de defensa, carisma, ataque y peso con su frase; la velocidad, solo chiste), pergamino «Decretos de Su Majestad» con Felipe en su cojín y la corona al centro, y 4 botones de pergamino a la derecha que estampan el sello de lacre con destellos al elegir.
- [x] **Toda la interfaz con el kit (G6/G7, hecha 2026-10-20):** HUD (pergaminos e íconos del kit), diálogo (pergamino y marco de retrato), libreta (pergamino con la foto del unicornio), resumen del día (pergamino con la cinta), aviso de logro (etiqueta con sello), barra del jefe (marco de madera y oro con relleno rojo y escudo azul) y carteles (cinta y pergamino).
- [ ] **Mostrar al creador:** capturas antes y después de la pausa, la ficha, el HUD, el diálogo, los carteles, la libreta, el resumen y la barra del jefe, y el GIF del sello.

## Prototipo pendiente: luz dinámica con mapas de normales (después de cerrar el nivel 1)

- [ ] **Probar Sprite Normals** (https://github.com/Hugo-Dz/spritefusion-sprite-normals, Hugo Duprez, licencia MIT, CLI en Rust, local y sin créditos). Genera mapas de normales para sprites y hojas de animación de pixel art (`--frame-size 106x106` para las hojas de Felipe), para que las luces de Godot (`PointLight2D` y `CanvasTexture` con normales) iluminen a Felipe, Valeria y los muebles con volumen.
  - **Cómo:** prototipo aparte en `siete-vidas/prototipos/luz-normales/` con `/prototipo`, sin tocar el juego. Felipe caminando junto a una lámpara con su mapa de normales y una luz pintada **en escalones** (un shader que cuantiza la luz en 2 o 3 niveles) para que siga viéndose pixel art.
  - **Riesgos:** la luz dinámica tiende a degradados suaves, el «efecto filtro» que rechazó el creador (lección 26), y las normales estimadas desde el color pueden verse raras en el pelo esponjoso.
  - **Veredicto:** si se ve pixel art y suma vida (lámparas, atardecer de la ventana, la imaginación roja de A.S.P.I.), entra en el nivel 2. Si parece un filtro, se descarta.
  - Decidido por el creador el 2026-10-21: queda como prototipo pendiente.
