# Respuesta de Gemini: pelea contra A.S.P.I., versión 3 (2026-10-23)

- **Consulta:** el texto entre las líneas `---` de `siete-vidas/diseno/consulta-ia-pelea-aspi-v3.md`, pegado tal cual.
- **Imagen adjunta:** `capturas/pelea-aspi/v3-capturas.png` (completa, sin partir).
- **Dónde:** gemini.google.com, con la cuenta del creador, en un chat nuevo: "Mejora de jefe en plataforma 2D" (Gemini automático).
- Gemini no dibujó nada.
- La respuesta se copia completa, convertida a markdown. Los textos citados de las capturas van como Gemini los leyó, con sus errores («¡ILLÉNALE», «!Jal»).

---

¡Hola! La idea de **«Felipe: Nueve Vidas, Cero Disculpas»** tiene una personalidad increíble. El concepto de un gato persa aristócrata y malcriado destruyendo el estudio mientras ve la pelea como una obra de arte épica es excelente para enganchar al jugador desde el primer minuto.

Analizando las 16 capturas del prototipo, aquí tienes el diagnóstico punto por punto para elevar esta primera batalla a nivel de joya indie:

## 1. Los 5 cambios de mayor impacto (Ordenados por Impacto / Esfuerzo)

1. **Avisos telegrafiados más dramáticos en el piso (Alto Impacto / Bajo-Medio Esfuerzo):**
   - *Por qué:* En las capturas de embestida y bola de pelo, la marca o advertencia se pierde con el detalle del piso de madera.
   - *Solución:* Usa marcas con contraste brillante (ej. líneas rojas discontinuas estilo arcade o sombras proyectadas bien marcadas que crezcan) 0.5 segundos antes del impacto para que el jugador se sienta hábil al esquivarlas en el último segundo.
2. **Juice & Feedback al caerle encima a A.S.P.I. (Alto Impacto / Medio Esfuerzo):**
   - *Por qué:* El salto sobre la aspiradora debe sentirse como el clímax de cada fase.
   - *Solución:* Además de la sacudida de cámara, añade **frames de congelamiento (*hitstop*)** de 2 a 4 frames en el momento del impacto, estrellas/polvo pixel art volando hacia los lados y un destello blanco instantáneo en la aspiradora.
3. **Silueta y presencia visual de A.S.P.I. (Alto Impacto / Esfuerzo Medio-Alto):**
   - *Por qué:* A.S.P.I. se ve algo pequeña y plana sobre la alfombra.
   - *Solución:* Agrega detalles interactivos mientras se llena: que se infle ligeramente, eche humo de las rendijas, vibre con rabia o sus luces parpadeen más rápido a medida que acumula basura.
4. **Visibilidad y dramatismo del cortocircuito / charcos (Medio-Alto Impacto / Bajo Esfuerzo):**
   - *Por qué:* En la Fase 3, la vulnerabilidad de A.S.P.I. en el agua o con el enchufe debe ser un momento "¡AHORA!" inconfundible.
   - *Solución:* Haz que el agua brille con chispas amarillas/azules animadas e intensas para que el estado `¡EN CORTO!` salte a la vista sin depender únicamente del cartel flotante.
5. **Transición más limpia al apagón de la Fase 3 (Medio Impacto / Bajo Esfuerzo):**
   - *Por qué:* El destello blanco `¡BZZZT!` rompe momentáneamente la estética retro.
   - *Solución:* Cambia el destello blanco completo por un parpadeo de luz tipo "fundido a negro/penumbra" en 3 tiempos rítmicos antes de dejar la habitación a oscuras iluminada por la luz roja.

## 2. Problemas de lectura o claridad visual

- **Sobrecarga de UI en la zona superior central:**
   - Al inicio de las fases aparecen pancartas de texto grande (`FASE 1: ¡ILLÉNALE EL DEPÓSITO!`, `FASE 2: ¡SE REINICIÓ!`) que tapan parte de los estantes e tazas. Sería mejor usar carteles emergentes tipo notificación que desaparezcan rápido o banderas laterales.
- **Tamaño y legibilidad de los globos de diálogo:**
   - Los globitos de Felipe (`!Confeti!`, `!Jal Baile eléctrico.`, `Arte.`) son un gran acierto cómico, pero su fuente es diminuta. Aumenta un 20% el tamaño del texto o bordea los globos con una línea oscura para que se lean fácilmente en movimiento.
- **Identificación del objeto tirado vs. basura procesada:**
   - Cuesta diferenciar a simple vista los objetos intactos en los estantes de los trozos que quedan en el suelo para que A.S.P.I. los limpie. Añade un pequeño destello o una sombra parpadeante en los objetos interactivos que Felipe puede tirar.
- **Indicador de "Llenado" de A.S.P.I.:**
   - La barra superior `3/5` da contexto, pero el jugador mira la acción en la arena. Añade un medidor analógico o luces sobre el lomo de la propia A.S.P.I. (ej. 3 LEDs verdes que cambian a rojo al llenarse).

## 3. Aprendizaje y reglas del juego (¿Se entiende sin tutorial?)

- **Lo que enseña muy bien:**
   - La mecánica de romper cosas para llenar el depósito es natural en un juego de gatos.
   - Los mensajes de estado como `¡DEPÓSITO LLENO!` guían directamente a la acción de saltar.
- **Lo que puede confundir al jugador primerizo:**
   - **La resistencia al aspirado:** La instrucción *"Si te aspira, mantén [S]"* exige leer texto durante el combate. En lugar de una tecla fija, muestra un ícono animado sobre la cabeza de Felipe cuando esté en el flujo de aire.
   - **Mecánica de maullar:** En la Fase 3, usar el maullido para atraer a A.S.P.I. hacia el charco no es tan evidente si el jugador no ha usado el maullido como habilidad activa antes. Un brevísimo cartel como `[M] Maullar para provocar` la primera vez que ocurre resolverá cualquier duda.

## 4. Cómo potenciar la personalidad aristocrática y juguetona de Felipe

- **Animaciones de reposo (*Idle*) épicas e indolentes:**
   - Si el jugador no mueve a Felipe por 2 segundos, Felipe debería lamerse una pata desinteresadamente, acomodarse las patitas delanteras como un rey en su trono o mirar a la cámara con aire de suficiencia.
- **Pausas dramáticas estilo manga/anime:**
   - Al tirarse a golpear a A.S.P.I. cuando está llena, congela el juego 0.2 segundos con un zoom rápido a la cara de Felipe poniendo ojos de cazador o una pose napoleónica antes de dar el impacto.
- **Animación de "Esparcir pelusa":**
   - Cuando esparce la pelusa con el comando `[E] Esparcir`, que Felipe dé una pirueta en el aire o haga una pose de torero con la cola levantada.
- **Efectos de sonido vocales:**
   - Agrega maullidos con personalidad: un maullido refinado al tirar un cuadro, un maullido de indignación si A.S.P.I. lo empuja y un "miau" grave e imponente al romper el enchufe.

## 5. Referencias de jefes 2D para estudiar

1. **King Dice / Goopy Le Grande (*Cuphead*):**
   - *Qué tomar:* La anticipación caricaturesca. Cada ataque tiene una postura previa exagerada y divertida que te dice exactamente qué va a hacer 1 segundo antes.
2. **Mantis Lords (*Hollow Knight*):**
   - *Qué tomar:* El ritmo tipo "danza". A.S.P.I. debe tener un patrón claro de ataque -> pausa -> limpieza. Cuando el jugador entiende el ritmo, la pelea se vuelve fluida y satisfactoria.
3. **Leshy / Jefes de *Inscryption*:**
   - *Qué tomar:* La atmósfera y el uso de iluminación dramática en fases avanzadas. El cambio a penumbra roja en la Fase 3 evoca esa sensación de cambio de reglas del juego.
4. **Jefes de *Pizza Tower*:**
   - *Qué tomar:* Expresividad y ritmo cómico constante. La interacción entre el protagonista y el jefe se siente como una caricatura de los sábados por la mañana.

## 6. Elementos prescindibles o que distraen

- **Subtítulos informativos bajo las pancartas principales:**
   - Textos como *"Tira cosas: limpiar le llena el depósito"* o *"Si te aspira, mantén [S]"* hacen que parezca un test de prueba. Quítalos de la pantalla principal; la propia jugabilidad e íconos dinámicos en el escenario deben comunicar esto.
- **El cuadro flotante del decreto ("La Gravedad Funciona") en el apagón:**
   - En la captura del apagón aparece un pergamino flotante. Interrumpe la inmersión visual de la penumbra roja. Es preferible que esos títulos aparezcan únicamente al final del nivel o en una esquina más discreta.
- **El aviso de `¡COF!` excesivo:**
   - El aviso flotante `¡COF!` en la bola de pelo recarga la imagen junto con la marca en el piso y el indicador de esparcir. Con la animación de expulsar la bola de pelo y la marca de impacto en el piso es más que suficiente.
