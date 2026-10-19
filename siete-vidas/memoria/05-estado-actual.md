# Estado actual: dónde vamos

Actualizado: 2026-10-19. **Léelo al empezar un chat nuevo** para retomar sin repetir conversaciones. Al cerrar cada tema, actualiza este archivo (qué se cerró, qué sigue).

## Fase del proyecto

**Fase 3: vertical slice — el nivel 1 tutorial con calidad final** (desde el 2026-10-19). Fases 1 y 2 cerradas. Fases: 1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento (Steam). Para pasar de fase: `/puerta-fase`.

## En curso

- **Nivel 1 v4 con la crítica de Gemini aplicada** (2026-10-19). Documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md` (secciones 12 y 13); qué se aplicó y qué se descartó, punto por punto, en `diseno/revisiones/2026-10-19-critica-gemini.md` ("Qué se aplicó"). Sigue: mostrarle al creador el video `nivel1-v4d.mp4` y la hoja `antes-despues-gemini.png`; decidir si se pide un `caminar` nuevo de Felipe (G9 de fondo), arte de transiciones de Valeria y una letra de pixel para toda la interfaz (diálogo, libreta, HUD y rótulos a la vez); cuarta revisión mirando transiciones.

## Ya cerrado (2026-10-19)

- **Crítica de arte de Gemini aplicada en el nivel 1** (0 créditos; todas las pruebas pasan, `prueba_jefe` 3 de 3 seguidas y el bot 5 de 5 con la agenda 8 de 8):
  - **Cortina** del dormitorio: arte de Gemini (`dormitorio-cortina-alta.png`), dos paños de una barra, sin colisión (como la de código).
  - **Aplicado** (verificado con capturas): Valeria sentada sobre el cojín y no flotando, sombras de contacto, charco de luz de la lámpara, reja crema, vano con hondura, vaso adentro de la consola, reloj más chico, LED de A.S.P.I., macetas oscuras, brillo de la baranda, rótulos con placa de madera, monitor con la serie, vaso en pixeles, luz de borde de la A.S.P.I. gigante y cartela del rugido.
  - **Autocrítica:** costuras transparentes en el azulejo de la cocina, ropa doblada que flotaba sobre la cama y cuadros tapados por el HUD (bajados).
  - **Descartado** (con el porqué en la crítica): ventana de la sala, mover la caja de arena, contorno del mesón, libros, almohada, marco del cuadro, maceta del balcón más chica, grosor de la baranda y una letra de pixel solo para los rótulos.
  - **No se tocó a Felipe:** no aplica la regla de los tres lugares.

- **Arreglos de la revisión 3 del nivel 1** (0 créditos; todas las pruebas pasan, `prueba_jefe` 5 de 5 seguidas y el bot 5 de 5 con la agenda 8 de 8):
  - **Capas:** tabla única `Capas` (`scripts/capas.gd`; memoria 03 y `godot-felipe` §6c). La imaginación de A.S.P.I. tapa todo el escenario y nunca hay dos A.S.P.I. (B1). Título, intro y pausa encima de todo; el fundido de las puertas tapa diálogo y carteles (G7).
  - **Valeria:** caminar de SpriteCook a 110 px/s medido por el pie apoyado (B2), fundidos entre poses decididos al dibujar (G1), cruza las puertas a la vista y no se teletransporta (G2, G3), mascarilla bien puesta (G6), respira y gira con transición (M6).
  - **Anuncios:** una sola cola para carteles, logros, franjas de fase y «PODER NUEVO» (`scripts/anuncios.gd`), que no tapa a Felipe, al diálogo, a los testigos ni el chiste (G5, M3).
  - **Arte de `arriba-extra`** en el juego (baúl, cojín, retrato familiar, ropa, caja de recuerdos, monitor, impresora, papeles); se borraron `aspi_llena.png` y el caminar de Valeria de Gemini.
  - **Felipe (G9):** el ciclo de caminar y correr va al ritmo de la velocidad; desliz ≤ 2 px por cuadro. Tres lugares: memoria (tabla Acciones de Felipe), ficha (plantilla y copia local; **falta publicar**) y juego (`prueba_movimiento`).
  - **Además:** sofá sin plástico al romperlo (G4), tapa de A.S.P.I. por código (G8), contraste de palabras (M1), recompensas al costado (M2), meta con fundidos (M4), fachada simplificada (M5), pizza legible (M7) y `prueba_jefe` estable por causa raíz (M8).

- **Arreglos de la revisión 2 del nivel 1** (solo código, 0 créditos; todas las pruebas pasan y el bot termina 5 de 5 con la agenda 8 de 8):
  - **Balcón (G1, M6):** la cámara sigue el salto final hasta el toldo de la panadería de abajo y el cartel "PODER NUEVO · CAER DE PIE" sale después de aterrizar, sin tapar a Felipe; la baranda ya no tiene maceta donde se sienta (se acicala mientras no haya animación de sentarse).
  - **Valeria (G2):** de pie siempre pisa el piso; al pararse del sofá baja delante de él.
  - **Lugar visto (G3):** la caja de pizza está afuera, tras el vidrio; el alféizar quedó vacío. Frase "Esa pizza es mía. Algún día.".
  - **Cocina (G5):** el pollo pasó al microondas; el ratón patrulla el mesón sin taparlo.
  - **Popo táctico (G6):** da una foto vergonzosa (las tres secretas dan fotos; "Galería Viral" con las tres).
  - **Legibilidad (G7, M1, M2, M5, M7):** teclado 52 × 24 y ropa 52 × 26 dibujados por código (la prueba R8 mide también lo dibujado por código y el tamaño que declara cada interactuable), descanso grueso con faldón, cartel "PIPE: NO" sin pisar el librero, láser de 8 px con halo, verbos distintos (sofá "Firmar", ropa "Desordenar", puerta "Arañar").
  - **Interfaz (M3, M4):** el aviso de logro va sobre el diálogo y fuera de su cuadro; `PresentacionJefe` esconde el diálogo y el Indicador mientras presenta, muestra la frase del portazo como subtítulo y usa una viñeta oscura en vez de discos rosados.
  - **Cortina (G4):** junto a una ventana nueva entre la cómoda y el ropero (hoy con el arte de Gemini).
  - **Escalera:** bajar funciona (prueba nueva en `prueba_nivel`).
  - **No se tocó a Felipe** (ni sprites ni acciones): no aplica la regla de los tres lugares.
  - **Quedan abiertos:** G8 (`entrar_puerta`, el creador decidió no pedirla aún), G9 (intimidar, para el Barrio Viejo), M8 (retrato familiar de Gemini).

- **Ajuste del salto** (video de referencia del creador): cae con más peso (gravedad de caída 2400 = 1,7 × la de subida, antes 1940; tope 740 px/s, antes 600), margen 0,12 s (antes 0,1), salto recordado 0,15 s (antes 0,12) y polvo al aterrizar que crece con la velocidad de caída (8 a 28 granos, más rápidos y grandes). La subida no cambió (altura de unos 80 px); `prueba_escenario` calcula con estos números que todo se sigue alcanzando sin doble salto. Tres lugares: memoria (tabla Acciones de Felipe), ficha local regenerada (**falta publicarla en línea**) y juego (pruebas en `prueba_movimiento` y `prueba_escenario`). Video antes/después con `pruebas/demo_salto.gd` (entrada fija).

- **PARTE B del nivel 1 v4, en el juego** (todas las pruebas pasan; el bot termina con la agenda 8 de 8):
  - **Mapa:** 7 cuartos (sala 1280, recibidor 1200, cocina 960, pasillo 1040, dormitorio 720, estudio 640, balcón 640) con el arte nuevo de Gemini. Cada colisión pisable sale de la fila opaca de su arte (`Sala.PIEZAS`, ±2 px medido por la prueba); puertas de una sola hoja; nada se cruza con una puerta ni con la escalera; ningún hueco sin salida. Sin avisos ni fila de controles: Indicador y primeras frases de Felipe (`Sala.LECCIONES`).
  - **Escalera de fondo con reja anti-fuga** (48 px, colisión fina, cartel "PIPE: NO" por código): librero de 3 repisas, 7 escalones con `subir_escalera`, pasamanos delante al 70 %, pestillo = atajo.
  - **Valeria** (`scripts/valeria.gd`): 4 poses + de pie + caminar a una sola escala (200 px); va al ruido, regaña, perdona al frotarse (acción nueva de Felipe, "Encantar"), graba el rascador de espaldas al sofá, se encierra en la cocina y la abre si Felipe maúlla del otro lado; arriba no oye (audífonos). Cumple las interfaces de testigo y de maullidos.
  - **Agenda del nivel 1** conectada (`Sala.AGENDA_SITIOS`): perdón, sofá, popo táctico, almuerzo, láser, cajón, teclado y desenchufar; el balcón termina con el resumen del día.
  - **Pelea con A.S.P.I.:** `PresentacionJefe` con los 8 pasos como datos (`PASOS`, `PASOS_CORTOS`, señales `paso_empezado` y `empujon`), que empieza después del fundido (B1); embestida anunciada, soplido contra el que acampa, bolas en arco, lo roto vuelve de a uno, papeles del teclado, «¡CLIC!» con congelado y polvo, entrada corta al volver. Ensayo sin daño en el pasillo (`scripts/ensayo_aspi.gd`).
  - **Felipe:** acción nueva **frotarse** (`Felipe.frotarse(objetivo)`, estado `RONRONEANDO`, animación `ronronear`). Tres lugares: memoria (tabla Acciones de Felipe), ficha (plantilla y copia local regenerada; **falta publicar la versión en línea**) y juego (prueba en `prueba_acciones`).
  - **Herramienta de arte:** recorte al borde opaco antes y después de escalar (M1), Valeria a una sola escala con el caminar alineado, patas del zapatero, piezas de la tanda 3C; se borró el arte descartado (puertas con poste, comedor de una pieza, librero viejo, rejas apiladas, plato, lata, juguetes, perchero, escalera vieja).
  - **Pruebas:** reglas (R1–R19 en lo medible, arte contra colisión, lado menor ≥ 24, puertas medidas en la imagen, rectángulo sagrado), escenario (sin doble salto y sin trampas), nivel de punta a punta, jefe, mecánicas, movimiento, acciones y el bot. Capturas de cada cuarto: `pruebas/capturas_nivel.gd`.
  - **No llegó `arriba-extra.png`:** esas piezas van dibujadas por código (ver `nivel-01-gran-fuga.md`, sección 10).
- **PARTE A del nivel 1 v4** (acciones de Felipe y sistemas reutilizables): maullar, arañar, subir escalón, snack del bolsillo, efectos en el cuadro de impacto; Agenda, libreta, HUD, resumen del día, diálogo con retratos, jugo, Indicador (Kenney), recompensas, rascador, arañables. Prueba `prueba_acciones.gd`.

## Ya cerrado (2026-10-18)

- **Reglas de diseño de niveles** (`siete-vidas/diseno/reglas-de-niveles.md`) validadas por `prueba_reglas_nivel.gd`.
- **Revisor de niveles** (`.claude/agents/revisor-niveles.md`) y su primera revisión: `siete-vidas/diseno/revisiones/2026-10-18-nivel1-gran-fuga.md`.
- **Equipo de diseño:** 5 agentes y 6 comandos (`/pilares`, `/prototipo`, `/prueba-juego`, `/revision-diseno`, `/puerta-fase`, `/godot-felipe`), adaptados de Claude Code Game Studios y GodotPrompter (MIT, `.claude/CREDITOS.md`).
- **Pilares aprobados** (`siete-vidas/diseno/pilares.md`): "Es como Hollow Knight, con la ironía de Untitled Goose Game, y además el castigo nunca llega". 1 Un barrio que se descubre · 2 Cada maña es llave y travesura · 3 Siempre te sales con la suya · 4 Tus decisiones tienen peso · 5 Épico en su cabeza (diálogos con retratos, estilo Broforce/Balatro).
- **Peso:** sin formas y sin efecto en el movimiento; sube defensa, carisma y ataque (Ficha de Su Majestad). Los snacks se cargan (comer ya o guardar para la pelea). **Se quitó la báscula** de la interfaz.
- **Prototipo v1: CAMBIAR.** Las acciones, la voz y lo épico funcionan, pero sin incentivo pierden sentido; el puntaje de CAOS no sirve.
- **Guía de jefes en 8 pasos** (entrada épica y "jugo" en la pelea) en `.claude/skills/godot-felipe/SKILL.md` §6b, sacada de un video que pasó el creador.
- **Título: *Nueve Vidas, Cero Disculpas*** (inglés *Nine Lives, Zero Regrets*); la carpeta sigue siendo `siete-vidas/`.
- **Biblia en línea actualizada** (título, pilares, peso, 9 vidas).
- **Reglas R17 a R19** (de los pilares) en `reglas-de-niveles.md`; el nivel 1 se ajusta al rehacerlo.
- **Recursos gratis:** Kenney (CC0) sirve para sonido, partículas e interfaz; nunca personajes ni fondos (consistencia de estilo).

## Para diseñar después

- Ficha de Su Majestad (cuánto sube cada estadística, frases).
- Snacks: dónde se recargan además de las recompensas (el bolsillo de 5 y comer manteniendo la acción ya están).
- Retratos de otros personajes para los diálogos (Gemini, con costo).

## Decisiones abiertas (esperan al creador)

- Ninguna por ahora.


## Cómo trabaja el creador (recordatorio)

Responder **siempre en español**. Un tema a la vez, propuesta antes de ejecutar, cuidar tokens, mostrar costo antes de gastar créditos de SpriteCook. Al terminar un cambio de Felipe, confirmar los tres lugares (memoria, ficha, juego).
