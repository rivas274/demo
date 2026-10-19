# Estado actual: dónde vamos

Actualizado: 2026-10-19. **Léelo al empezar un chat nuevo** para retomar sin repetir conversaciones. Al cerrar cada tema, actualiza este archivo (qué se cerró, qué sigue).

## Fase del proyecto

**Fase 3: vertical slice — el nivel 1 tutorial con calidad final** (desde el 2026-10-19). Fases 1 y 2 cerradas. Fases: 1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento (Steam). Para pasar de fase: `/puerta-fase`.

## En curso

- **Construcción del nivel 1 v4** (`siete-vidas/diseno/nivel-01-propuesta-v4.md`, aprobado; plan de arte en `nivel-01-plan-arte.md`). Se hace en dos partes:
  - **PARTE A (hecha, 2026-10-19): sistemas reutilizables y acciones de Felipe.** Ver "Ya cerrado (2026-10-19)".
  - **PARTE B (sigue): el nivel en sí.** Mapa nuevo (sección 10), escalera de fondo con reja y librero, Valeria en escena (4 poses + caminar de Gemini, ya en `arte/referencias/gemini/`), pelea nueva con A.S.P.I., balcón y video. Lo que necesita de la parte A está en "Para la PARTE B" abajo.

## Ya cerrado (2026-10-19)

- **PARTE A del nivel 1 v4, en el juego** (todas las pruebas pasan; bot completo):
  - **Felipe:** `maullar` (Q / B; el maullido sale en el cuadro 3 y lo oyen los nodos del grupo `oyen_maullidos`), `aranar` (acción frente a sofá, rascador o puerta entornada; marcas y pelusa en los cuadros 3 y 5; garras afiladas → CRÍTICO), `subir_escalera` (función `subir_escalera(peldaños)` / `subir_escalon(destino)`, un ciclo por escalón con saltito; bajar con cuadros de saltar y caer), comer un snack del bolsillo (mantener acción 0,6 s sin nada cerca; bolsillo de 5, empieza con 3), y **todo efecto en su cuadro de impacto** (zarpazo y manotazo en el 4, comer en el 3: arregla B5 en vaso, reja y comida). Doble salto, Zoomies y trepar **apagados** (`tiene_doble_salto`, `tiene_zoomies`, `puede_trepar`).
  - **Sistemas (scripts nuevos):** `Travesuras` (los junta), `Agenda` (8 travesuras del nivel 1, 3 secretas), `Recompensas` (nido con ranura cada 10, galería, bolsillo, caminos), `Libreta` (Tab / View), `Hud` (contadores arriba y carteles «¡TRAVESURA CUMPLIDA!» / «¡TRAVESURA SECRETA!»), `ResumenDia` (tipo Balatro), `Dialogo` + `Frases` (retratos de Felipe, Valeria y A.S.P.I.; una sola cola; no repite; descarta lo viejo; nunca tapa a Felipe), `Jugo`, `Indicador` (contorno + burbuja con ícono del botón y verbo), `IconosBotones` (Kenney Input Prompts Pixel, CC0), `Recogible`, `Aranable`, `Rascador` (teatro para Valeria con interfaz de testigo), `Chispas`.
  - **En el nivel viejo (v3), mínimo:** el sofá ya se araña (línea "sofa" de la agenda: el plástico se rompe y sale un calcetín). El bot prende doble salto, Zoomies y trepar porque el mapa viejo los necesita; `prueba_nivel` comprueba que sin Afilar Garras la cortina no se trepa.
  - **Arte nuevo en el juego:** hojas `maullar`, `aranar`, `subir_escalera` (escala única 0,72), retratos de Valeria y A.S.P.I. recortados de la tanda 3B (`herramientas/preparar_retratos.py`), íconos de Kenney.
  - **Prueba nueva:** `prueba_acciones.gd` (85 comprobaciones), también en GitHub Actions. Capturas: `pruebas/capturas_sistemas.gd` y `diseno/revisiones/capturas/2026-10-19-parte-a-*.png`.
  - **Ficha:** copia local regenerada con las filas nuevas; **falta volver a publicar la versión en línea** (lo hace el creador o la sesión principal).

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

## Para la PARTE B (lo que dejó lista la parte A)

- `sala.travesuras` (un `Travesuras` con `Agenda.NIVEL_1`): llamar `travesuras.cumplir(id, donde)` cuando pase cada travesura (`perdon`, `sofa`, `popo`, `almuerzo`, `laser`, `cajon`, `teclado`, `desenchufar`); `donde` = sobre algo pisable. `Recompensas.camino_abierto(id)` avisa los caminos (`puerta_cocina`, `balcon`). Al final, `travesuras.mostrar_resumen()` en el balcón (en lugar de la pantalla final actual).
- **Valeria** debe cumplir la interfaz de testigo del rascador: grupo `Rascador.GRUPO_TESTIGOS`, `ve(punto) -> bool`, `visita: int` (sube al volver a entrar al cuarto) y `perdonar(felipe, motivo)`; y oír maullidos: grupo `Felipe.GRUPO_OYENTES` con `oir_maullido(felipe)`. Sus frases van con `travesuras.decir_valeria(evento)` (agregar eventos en `Frases.VALERIA`) y retratos 0 neutra, 1 enojada, 2 derretida, 3 grabando. Contar perdones con `travesuras.contar_perdon()`.
- **Escalera:** `felipe.subir_escalera(peldaños)` (7 escalones de unos 21 px; 0,2 s cada uno) y la señal `escalera_terminada`; dibujar el pasamanos delante. La reja nueva usa `dar_manotazo(_abrir)` como la actual.
- **Objetos:** `Aranable` para el sofá con plástico (`aranazos_para_romper`) y la puerta entornada del dormitorio (`aranazos_para_romper = 1`, señal `roto`); `Rascador` en la sala (sus plataformas, si las tiene, son piezas del nivel). Todo interactuable puede dar `verbo()`, `arte_indicador()` o `rect_indicador()` y `primera_frase()` para el Indicador (la primera vez sale la línea de Felipe con el ícono, en vez de los avisos de abajo).
- Quitar los `AVISOS` y la fila de controles de abajo (M2): ahora los reemplazan el Indicador y las primeras frases. Que el bot vuelva a jugar **sin** doble salto, Zoomies ni trepar.
- Pendiente de antes (sigue valiendo para la PARTE B): B1 (entrada del jefe en negro), B2–B4, G1–G13, M1–M5 de la revisión del 2026-10-18; R17–R19 en `prueba_reglas_nivel.gd`; pruebas nuevas de arte contra colisión, comida ≥ 24 px y entrar al jefe por la puerta.


## Para diseñar después

- Ficha de Su Majestad (cuánto sube cada estadística, frases).
- Snacks: dónde se recargan además de las recompensas (el bolsillo de 5 y comer manteniendo la acción ya están).
- Retratos de otros personajes para los diálogos (Gemini, con costo).

## Decisiones abiertas (esperan al creador)

- Ninguna por ahora.


## Cómo trabaja el creador (recordatorio)

Responder **siempre en español**. Un tema a la vez, propuesta antes de ejecutar, cuidar tokens, mostrar costo antes de gastar créditos de SpriteCook. Al terminar un cambio de Felipe, confirmar los tres lugares (memoria, ficha, juego).
