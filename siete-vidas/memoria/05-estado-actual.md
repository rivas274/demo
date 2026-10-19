# Estado actual: dónde vamos

Actualizado: 2026-10-19. **Léelo al empezar un chat nuevo** para retomar sin repetir conversaciones. Al cerrar cada tema, actualiza este archivo (qué se cerró, qué sigue).

## Fase del proyecto

**Fase 3: vertical slice — el nivel 1 tutorial con calidad final** (desde el 2026-10-19). Fases 1 y 2 cerradas. Fases: 1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento (Steam). Para pasar de fase: `/puerta-fase`.

## En curso

- **Nivel 1 v4 construido** (PARTE A y PARTE B, 2026-10-19). Documento vigente: `siete-vidas/diseno/nivel-01-gran-fuga.md`. Sigue: mostrarle al creador el video y las capturas, y una revisión nueva con `revisor-niveles`.

## Ya cerrado (2026-10-19)

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
