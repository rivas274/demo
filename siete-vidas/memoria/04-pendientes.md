# Pendientes

Orden acordado: un tema a la vez, con propuesta y aprobación.

## En curso

- [x] **Diseño final de Felipe:** versión A del híbrido v2.
- [x] **Animaciones base de Felipe:** quieto, caminar, correr, zarpazo, comer, saltar, ronronear, desmayo (SpriteCook) + daño y efectos de salto (código). Ficha: https://claude.ai/artifact/K5fwEzUpr1sNjAggysCmPe
- [x] Pendientes de Felipe: ronronear, desmayo (+ vida fantasma por código), Collar de la Vergüenza, 9 retratos para diálogos.
- [x] Animación de agacharse y gatear (SpriteCook, 28 créditos, 2026-10-18).
- [x] Animaciones de ocio (2026-10-18, 76 créditos): acicalarse, jugar con estambre y perseguirse la cola, en el juego tras 8 s sin tocar nada.
- [x] Acicalarse y jugar rehechos desde Felipe A (40 créditos); estambre como objeto por código; una sola escala; deformación máxima ±8 %.
- [x] Gatear desde Felipe A con `pixel-engine-v1.5` (26 créditos): consistente, con transición al bajar y al pararse; huecos para pasar agachado de 45 cm.
- [x] Agacharse (baja la cabeza al piso) y caída rehechos desde Felipe A con `v1.5` (52 créditos). Todas las animaciones son consistentes.
- [ ] Decidir si Felipe sigue cargando 3 snacks para curarse o si toda la comida se toma del mundo con el botón de acción.
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
- [ ] Falta arte de Gemini para: caja de arena, cortina, escalera de 14 escalones, cuadros de la pared, cojín, láser y bolas de pelo (hoy siguen dibujados por código).
- [ ] Siguiente después de la demo: La Cuadra, afecto y respeto, música.
- [ ] Hojas finales de Felipe generadas a ~67 px de alto (hoy se reducen al 72 % y los pixeles quedan disparejos).
- [ ] Arte final de escenarios (tileset, fondos por capa, muebles) cuando el concepto esté afinado.
- [ ] Prototipo jugable: Felipe moviéndose en el apartamento de Valeria.
- [ ] Lanzamiento: redes de Felipe, página de Steam, demo, lista legal.

## Preguntas abiertas

- Título con 9 vidas: el juego ahora da 9 vidas, pero el título en español dice *Siete Vidas*. ¿Se cambia a *Nueve Vidas, Cero Disculpas* o se deja como guiño?

- Gemini (Nano Banana) directo: falta que el creador agregue `GEMINI_API_KEY` al entorno (se lee en una sesión nueva). Sirve para imágenes fijas, no animaciones.

- Peso como indicador: ¿afecta el movimiento (salto, velocidad, vida) o es solo informativo? ¿Vuelve el medidor de hambre? ¿Cómo queda el Final Buda?

- ¿Valeria está basada en una persona real?
