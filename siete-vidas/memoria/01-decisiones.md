# Decisiones cerradas

Actualizado: 2026-10-17. Detalle completo en la biblia (ver README.md).

## Producto

- **Título:** *Felipe: Siete Vidas, Cero Disculpas* (inglés: *Nine Lives, Zero Regrets*).
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

## Mecánicas

- **Tres medidores:** afecto humano (por casa), respeto felino, peso. No hay medidor de hambre.
- **Snacks = curación:** Felipe carga 3 al inicio; cada uno cura y suma peso. Sin daño por hambre ni temporizadores. *(Pendiente de revisar con el botón de acción: hoy la comida se come del mundo.)*
- **Botón de acción (2026-10-18):** un solo botón para interactuar con objetos; si el objeto es comida, Felipe la come. No hay botón de comer suelto ("comer sin comida no tiene sentido").
- **Agacharse (2026-10-18):** Felipe se agacha y gatea para pasar bajo muebles; agachado + saltar baja a través de repisas.
- **Peso (2026-10-18):** no cambia el dibujo de Felipe, por el límite de cuadros de las animaciones. Es un indicador en la parte de arriba, junto a la barra de vida. *(Abierto: si el peso cambia algo del movimiento, como la biblia pedía para Flaco, Gordito y Modo Buda, y cómo queda el Final Buda.)*
- **Siete vidas** por partida; al perderlas, Felipe despierta en casa con el **Collar de la Vergüenza** (baja el respeto hasta reconquistar a Valeria).
- **Poderes (moverse y pelear), en orden:** Zarpazo, Caer de Pie (apartamento), Afilar Garras (Barrio Viejo), Doble Salto (Neón), Zoomies (Downtown), Licuado (Muelle). La puerta final pide respeto y afecto altos.
- **Mañas:** 17 equipables con ventaja y precio; 2 ranuras al inicio, hasta 6 (10 calcetines = 1 ranura).
- **Acciones de gato:** pedir comida, infiltrarse, popo táctico, tirar cosas de la mesa, meterse en cajas, peleas en los techos, casas paralelas.
- **Combate:** enemigos comunes fáciles y graciosos; jefes con reto. Felipe nunca golpea humanos (los vence con trampas); los animales derrotados huyen ofendidos.
- **Jefes:** A.S.P.I., Hermanos Callejeros, Michi-Star, Tanque, el Patrón, Rey Rata, Kaiser, A.S.P.I. MAX (final).
- **Guía anti-frustración:** tutorial jugando, "El Manual de Su Majestad", pistas tras 3 muertes, mapa con iconos de poder faltante, rascador de entrenamiento.
- **Accesibilidad:** controles reasignables, subtítulos ajustables, modo daltónico, modo asistido que no bloquea logros.
- **Logros:** 40 en Steam (lista en la biblia); coleccionables: 50 calcetines, 30 fotos vergonzosas, lagartijas.

## Demo: primer nivel "La Gran Fuga" (2026-10-18)

- **La demo es el tutorial del apartamento**, como dice la biblia: cada mueble enseña un movimiento con un aviso de una línea y la tecla o el botón del mando en uso. Recorrido: caminar → sofá (saltar) → vaso (E, logro) → aparador (agacharse, calcetín) → ratón de cuerda (zarpazo) → caja de arena (punto de descanso) → caja de cartón (zarpazo, calcetín) → librero (doble salto) → cocina (comer, puntero láser imposible de atrapar) → alacena y refrigerador → cortina (trepar) → **A.S.P.I. jefa** frente a la puerta del balcón → balcón: gana **Caer de Pie** y termina la demo.
- Pantallas de título, introducción (el video viral; "Me voy de esta casa"), pausa y final (tiempo, calcetines 3, logros, vidas perdidas). Logros de la demo: La Gravedad Funciona, Desenchufada, Coleccionista de Calcetines, Caer de Pie.
- **Peso con personalidad:** báscula con aguja y humor de Felipe (Atlético, Esponjoso, Modo Invierno, Modo Buda).

## Prototipo jugable (2026-10-18)

- **Vida:** 5 corazones por vida y 7 vidas; al perderlas todas, vuelven las 7 con el Collar de la Vergüenza. Comer cura 1 corazón y suma 0,3 kg.
- **A.S.P.I.** es el primer enemigo: patrulla, persigue a Felipe si lo ve a su altura, quita 1 corazón al tocarlo y se apaga con 3 zarpazos.
- **Interfaz** con estilo de red social: corazones como "me gusta", vidas, báscula en kilos y logros como notificaciones.

## Forma de construir (2026-10-17)

- **Primero la prueba de concepto, después el arte final.** Los escenarios, enemigos e interfaz se arman con arte provisional dibujado por código (gratis) para afinar la jugabilidad; cuando el concepto esté cerrado, se reemplazan las texturas por las finales. No se gastan créditos de SpriteCook en escenarios hasta entonces.
- **Proporciones (2026-10-18):** Felipe es un gato grande (persa de 8 kilos, grande y no obeso): Valeria mide 3 Felipes y Felipe ocupa 67 px de alto en pantalla. El mundo usa medidas reales a 1,21 px por cm.
- **Profundidad con parallax en capas (como Silksong):** cada escena tiene capas lejanas que se mueven menos que la cámara, la capa de juego, y un primer plano de siluetas oscuras que se mueve más. La cámara se mueve en horizontal y en vertical.

## Legal (Steam)

- Cero marcas reales dentro del juego (ya se cambiaron: R-00MBA → A.S.P.I., Garfield → Buda, Gato con Botas → Ojos de Súplica, WhatsApp/TikTok → "los chats"/"internet").
- Cero personas reales, cero gatos famosos, cero imágenes de memes.
- Licencias comerciales para cada recurso; aviso MIT de Godot en créditos; contrato de cesión con colaboradores.
- **Arte con IA:** declararlo en Steam. El arte final debe estar retocado o unificado a mano; la IA sirve para bocetos y bases.
- Pregunta abierta: ¿Valeria está basada en una persona real? Si sí, cambiar nombre o pedir permiso escrito.
