# Pelea con A.S.P.I. v4: el salto estrella, colores con significado y menos texto (2026-10-23)

Pedido del creador: sumar a la tanda v3.1 (temblor de pantalla, libros, estación de carga y cable, que se conservan) 6 mejoras tomadas de las respuestas de ChatGPT y Gemini a la v3. Esas respuestas están en `2026-10-23-chatgpt-pelea-aspi-v3.md` y `2026-10-23-gemini-pelea-aspi-v3.md`. Base: `2026-10-23-pelea-aspi-v3.md`. Estado: **aplicado**, 0 créditos, sin animaciones nuevas de Felipe. Capturas: `capturas/pelea-aspi/v4-capturas.png` y `v4-detalles.png`.

## Fuentes y referencias

| Idea | Quién la propuso | Referencia que citaron |
| --- | --- | --- |
| Ataques en 4 tiempos (preparación, peligro, impacto, recuperación) y ventana de castigo | ChatGPT §1.1 y §5.2 | Cuphead (legibilidad), Shovel Knight (ventanas de castigo) |
| Apagarla como gran momento: el motor falla, el depósito se hincha, pausa de impacto, onda, y **un silencio antes del golpe** | ChatGPT §1.2; Gemini §1.2 (hitstop de 2 a 4 cuadros, estrellas, destello blanco) | The Messenger; Cuphead |
| 3 LED en el lomo de A.S.P.I. que muestran el depósito | Gemini §2 | — |
| Depósito que se infla, echa humo y vibra | Gemini §1.3 | — |
| Un lenguaje estable de peligro y oportunidad; avisos que dicen la acción («¡DEPÓSITO LLENO! ¡A POR ELLA!») | ChatGPT §2.2 y §2.4 | — |
| Iluminación selectiva en el apagón (Felipe, charcos y luz roja) | ChatGPT §1.3 y §2.3 | Inscryption (Gemini §5.3) |
| Chispas animadas en el charco y 3 parpadeos con ritmo en vez del destello blanco | Gemini §1.4 y §1.5 | — |
| Menos texto: sin subtítulos de instrucciones; ícono sobre Felipe; diálogos solo en ventanas seguras | Gemini §3 y §6; ChatGPT §2.6 y §6.1 | Hollow Knight (enseñar sin tutorial), Link's Awakening (descubrir la solución) |
| Quitar «¡COF!»; que el pergamino de un logro no salga en el apagón | Gemini §6 | — |
| Globito más legible (más grande o con borde oscuro) | Gemini §2 | — |
| Distinguir lo que se puede tirar de los restos | Gemini §2 | DKC Tropical Freeze (el escenario como parte del jefe, ChatGPT §5.5) |
| Animaciones de personalidad (lamerse, posar, pirueta, clavar las uñas, alisarse) | Gemini §4; ChatGPT §4 | Pizza Tower |

## 1. El salto como momento estrella (`RemateAspi`)

- **Anticipación (depósito lleno):** el motor falla, con tosidos (sonido `falla`) cada 0,6 s que bajan de tono. El depósito se **hincha en pulsos** cada vez más rápidos, con tope de ±8 % (la misma regla que el estirar y aplastar de Felipe). Echa **humo** cada 0,3 s y **vibra**.
- **Silencio:** si Felipe viene cayendo sobre ella (a menos de 90 px), se cortan los sonidos que estén sonando (`Nivel.callar()`) y no vuelve a toser. El golpe suena sobre ese silencio.
- **Impacto:** hay una **pausa de impacto de 4 cuadros** (0,067 s), un **destello blanco de su silueta** (0,08 s), **6 estrellas** de pixel que saltan y un destello de pantalla suave (0,25). Le siguen la onda de choque, el polvo, lo tirado que brinca, el temblor de 3 px y «¡CLIC!».
- **El golpe final dura más:** 12 cuadros de pausa (0,2 s), 0,2 s de destello, 10 estrellas, temblor de 6 px y onda ×1,6. Después vienen su derrota y la luz que vuelve.
- Todo en `datos/jefes/aspi_jugo.tres` (grupo «Remate»).

## 2. Medidor del depósito

Tiene 3 LED en el lomo, en un hueco oscuro de 5 × 4 con una luz de 3 × 2. Se encienden en verde, uno por mancha, reescalados a la capacidad de la fase (2/3/3): con capacidad 2, una mancha enciende 1 LED y dos manchas, los 3. Lleno, los 3 parpadean en amarillo. La barra azul del HUD sigue igual.

## 3. Colores con significado

| Color | Significa | Dónde |
| --- | --- | --- |
| **Rojo** (`peligro` en el tema) | Peligro | Línea y marca de la embestida, marca de la bola de pelo (antes amarilla), luz de aviso del soplido (antes amarilla), luz de furia, «!» del despertar y su marca, flecha de borde de la cámara (antes roja y amarilla), «¡FUUU!» |
| **Amarillo** (`oportunidad`) | Oportunidad | Cartelito «¡LLENA! ¡SALTA!» / «¡EN CORTO! ¡AHORA!» con borde amarillo, flecha hacia abajo, punto que late sobre el botón, LED llenos, íconos de ayuda |
| Celeste | Información | «+1 · Glup.», brillo de los charcos, reinicio |

## 4. Apagón legible

- **Entrada:** sin destello blanco. La luz parpadea 3 veces con ritmo (tramos de 0,12 a 0,18 s) y queda en penumbra (`ApagonEstudio.RITMO`).
- **Luz selectiva:** los ojos de Felipe brillan más (0,75 antes 0,45), cada charco tiene un brillo celeste propio y A.S.P.I. tiene su luz roja que late. El HUD es una capa aparte y no se oscurece.
- **En corto:** saltan rayitos de pixel amarillos y celestes sobre el charco, que cambian 12 veces por segundo mientras dura.
- **Marcas de ataque:** trazo de 3 × 2 con borde oscuro, sin sombrear. Se leen sobre cualquier piso y a oscuras.
- **Logros:** si se gana uno en el apagón, el pergamino espera a que vuelva la luz (`Nivel.retener_logros`).

## 5. Menos texto

- **Carteles de fase en una línea**, sin subtítulo (`aspi.tres`: `pistas` vacío). La regla R16 se actualizó por decisión del creador.
- **Íconos sobre Felipe, solo la primera vez** (`AyudaAspi`): mientras la succión lo arrastra de pie, el botón de agacharse con una flecha hacia abajo; en el apagón, cerca de un charco y con A.S.P.I. libre, el botón de maullar con ondas. Se van cuando lo hace (o a los 4 s) y no vuelven.
- **Globito:** no sale en pleno peligro (embestida, bola en el aire, carrera al enchufe) ni mientras se ve el aviso de oportunidad (para no taparlo; la frase sale después del golpe). La frase espera hasta 2,5 s y, si no, se descarta; si un peligro empieza, el globito se va. Usa letra negrita (PixelOperator Bold 16) y contorno oscuro de 2 px, dentro de ZonasTexto.
- **Sin «¡COF!»:** la tos se ve (vibra, se hincha) y se oye (`atragantar`).

## 6. Lo que se puede tirar y los restos

- **Destello:** cada objeto entero y cada fuente con algo por soltar muestra una cruz de pixel blanca en su esquina de arriba. Dura 0,4 s cada 2,2 s, cada uno desfasado para que no titilen juntos.
- **Restos más apagados:** pedazos, libros, notas y motas en el piso, y lo que queda de un objeto roto, se tiñen con `PiezaSuelta.RESTO` (80 %). El charco no se apaga: en el apagón es la clave.

## 7. Ataques en 4 tiempos

| Ataque | Preparación | Peligro | Impacto | Recuperación |
| --- | --- | --- | --- | --- |
| Embestida | Se echa atrás, luz roja, reversa, línea y marca roja | Carga (solo entonces daña) | Frena: polvo y temblor de 2 px | **Mareada 0,6 s:** quieta, inofensiva, estrellitas |
| Bola de pelo | Tos: vibra, se hincha, marca roja donde va a caer | La bola en arco | Cae: polvo y temblor de 1 px | **Mareada 0,6 s** |

**Ventana vulnerable, honesta:** mareada no se la puede apagar, porque eso sigue siendo el depósito o el charco (el ciclo de la pelea). Si Felipe le cae encima mareada, **rebota como en un trampolín**: es la recompensa de esquivar y sirve para subir a la repisa o al escritorio. Se eligió así para no romper el ciclo «ensuciar → se llena → salto».

## 8. Lo que no se hizo

- **Animaciones nuevas de Felipe:** no se hicieron (pedido del creador). Las sugeridas quedan como pedido a SpriteCook pendiente de aprobación, unos 26 créditos cada una (ver `memoria/05-estado-actual.md`): lamerse, posar, pirueta al esparcir, clavar las uñas al ser arrastrado y alisarse el pelaje.
- **Zoom a la cara de Felipe antes del golpe** (Gemini §4): rompería la regla del zoom entero en la pelea y alargaría el golpe. Queda como opción con la animación «posar».
- **Icono de aspiradora en el HUD** (ChatGPT §2.5): los LED del lomo ya cumplen esa función y no suman nada nuevo arriba.

## 9. Contra los pilares, las reglas y las lecciones

- **Pilar «no castiga»:** la ventana mareada es segura y el apagón no es negro.
- **R16:** cartel de una línea; la presentación sigue siendo la misma (`PresentacionJefe`).
- **±8 %:** el hinchado del depósito y de la tos usa el mismo tope.
- **Zonas de texto:** el globito sigue dentro de su zona; el cartelito de oportunidad se corre adentro del borde (lección 23).
- **Lecciones nuevas:** 50 (un color, un significado), 51 (iluminación selectiva y parpadeos con ritmo), 52 (íconos en vez de subtítulos, diálogos en ventanas seguras) y 53 (lo usable destella, lo usado se apaga).

## 10. Crítica honesta (desde el jugador)

- El golpe ahora **se siente**: el silencio antes y la pausa de impacto hacen que el «¡CLIC!» pese. El golpe final, con 0,2 s congelado, se nota distinto.
- Los LED se leen de cerca. A 1× son chicos (3 × 2 px) y se leen más por el parpadeo amarillo al llenarse que por la cuenta.
- El destello de lo que se puede tirar es sutil a propósito. Si el creador no lo ve, se puede subir a un contorno completo.
- El trampolín sobre A.S.P.I. mareada es una regla nueva que nadie explica. Es opcional: si no se descubre, no estorba.
- Sin las animaciones de personalidad, Felipe sigue con las de siempre en los momentos grandes (maullido al apagarla, estambre al final). Es lo que más falta para que el remate sea «estrella» del todo.
