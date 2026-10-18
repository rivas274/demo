# Estado actual: dónde vamos

Actualizado: 2026-10-18. **Léelo al empezar un chat nuevo** para retomar sin repetir conversaciones. Al cerrar cada tema, actualiza este archivo (qué se cerró, qué sigue).

## Fase del proyecto

**Fase 1 → 2: prototipo de concepto** ("¿es divertido ser Felipe?"). Fases: 1 Concepto y pilares → 2 Prototipo de concepto → 3 Vertical slice → 4 Producción → 5 Pulido y lanzamiento (Steam). Para pasar de fase: `/puerta-fase`.

## En curso

- **Prototipo "travesuras" v2 con la Agenda de Su Majestad** (`siete-vidas/prototipos/travesuras/`, ver su `INFORME.md` y `README.md`). Reemplaza el medidor de CAOS por 6 travesuras con nombre (2 secretas) y recompensas útiles (calcetín, snack por perdón, foto vergonzosa, un camino que se abre) y un resumen tipo Balatro al final. Cuando esté listo: mandar el video al creador, que lo juega (Godot 4.3, F5) y da el veredicto SEGUIR / CAMBIAR / DESCARTAR.

## Ya cerrado (2026-10-18)

- **Reglas de diseño de niveles** (`siete-vidas/diseno/reglas-de-niveles.md`) validadas por `prueba_reglas_nivel.gd`.
- **Revisor de niveles** (`.claude/agents/revisor-niveles.md`) y su primera revisión: `siete-vidas/diseno/revisiones/2026-10-18-nivel1-gran-fuga.md`.
- **Equipo de diseño:** 5 agentes y 6 comandos (`/pilares`, `/prototipo`, `/prueba-juego`, `/revision-diseno`, `/puerta-fase`, `/godot-felipe`), adaptados de Claude Code Game Studios y GodotPrompter (MIT, `.claude/CREDITOS.md`).
- **Pilares aprobados** (`siete-vidas/diseno/pilares.md`): "Es como Hollow Knight, con la ironía de Untitled Goose Game, y además el castigo nunca llega". 1 Un barrio que se descubre · 2 Cada maña es llave y travesura · 3 Siempre te sales con la suya · 4 Tus decisiones tienen peso · 5 Épico en su cabeza (diálogos con retratos, estilo Broforce/Balatro).
- **Peso:** sin formas y sin efecto en el movimiento; sube defensa, carisma y ataque (Ficha de Su Majestad). Los snacks se cargan (comer ya o guardar para la pelea). **Se quitó la báscula** de la interfaz.
- **Prototipo v1: CAMBIAR.** Las acciones, la voz y lo épico funcionan, pero sin incentivo pierden sentido; el puntaje de CAOS no sirve.
- **Guía de jefes en 8 pasos** (entrada épica y "jugo" en la pelea) en `.claude/skills/godot-felipe/SKILL.md` §6b, sacada de un video que pasó el creador.
- **Recursos gratis:** Kenney (CC0) sirve para sonido, partículas e interfaz; nunca personajes ni fondos (consistencia de estilo).

## Pendiente, en orden

1. **Jugar la v2 y dar veredicto.**
2. **Si sigue:** animaciones de maullar e intimidar (unos 20 créditos cada una, desde Felipe A; mostrar prompt y costo antes de gastar). Opcional: probar sonidos y partículas de Kenney.
3. **`/puerta-fase`** para pasar a la fase 3.
4. **Volver al nivel 1** con la lista del revisor:
   - Bloqueantes: entrada del jefe en negro, puertas con un poste en medio (arte de 176 px para un hueco de 104), lámpara y caja de arena delante de puertas, Felipe flotando sobre la mesa, manotazo desincronizado.
   - Graves: ratones flotando, comida diminuta, escalera sin sentido y sin animación de subir, interacciones sin aviso, pelea que se gana sentado en la repisa, nada reacciona a Felipe.
   - Nuevo: Agenda de Su Majestad, diálogos con retratos, jugo épico, entrada de jefe en 8 pasos.
   - Pruebas nuevas: arte contra colisión, tamaño de la comida (lado menor ≥ 24 px), entrar al jefe por la puerta.

## Para diseñar después

- Ficha de Su Majestad (cuánto sube cada estadística, frases).
- Snacks cargados: cuántos, uso en pelea, dónde se recargan.
- Retratos de otros personajes para los diálogos (Gemini, con costo).

## Decisiones abiertas (esperan al creador)

- ¿Entran a `reglas-de-niveles.md` las 3 reglas que salen de los pilares? (lugar visto antes de alcanzarlo + atajo + historia por zona; una travesura con reacción por habitación; cada maña abre camino y sirve para molestar).
- ¿Se actualiza la biblia en línea con los pilares nuevos?
- Título: ¿sigue *Siete Vidas* con 9 vidas o cambia?

## Cómo trabaja el creador (recordatorio)

Responder **siempre en español**. Un tema a la vez, propuesta antes de ejecutar, cuidar tokens, mostrar costo antes de gastar créditos de SpriteCook. Al terminar un cambio de Felipe, confirmar los tres lugares (memoria, ficha, juego).
