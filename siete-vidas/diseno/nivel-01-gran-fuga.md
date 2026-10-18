# Nivel 1: "La Gran Fuga" (rediseño, propuesta del 2026-10-18)

## Reglas que cumple

Cumple las 16 reglas de [reglas-de-niveles.md](reglas-de-niveles.md); `prueba_reglas_nivel.gd` las valida. Ajustes que hizo falta al aplicarlas: segundo descanso (cojín del dormitorio, junto al atajo y antes de A.S.P.I.: R5 y R6), juguetes y ratones corridos para que la entrada de cada aviso sea segura (R2), A.S.P.I. patrulla desde x 2560 (R2) y repisa de la escalera dentro de la escalera, con su calcetín (R13).

## Crítica del nivel actual

- Es un pasillo plano: todo pasa a la misma altura y de izquierda a derecha.
- Enseña cada mecánica una vez y **nunca la pone a prueba**: no hay giro ni combinación.
- No hay peligro hasta A.S.P.I.; la pelea es quedarse quieto y pegar tres veces.
- Demasiado texto: un cartel por mueble.
- La meta no se ve; el láser es un chiste sin función; los calcetines están casi a la vista.
- No hay atajos, secretos ni regreso: no se siente metroidvania.
- Un solo papel tapiz y muebles de colores planos: no hay hitos para orientarse.

## Nuevo diseño: dúplex de Valeria (casa antigua del Barrio Viejo)

Planta baja (sala y cocina) y planta alta (dormitorio, baño y balcón). Alto total: dos pisos de 3,5 m; la cámara se mueve en vertical.

| Zona | Enseña / prueba | Cómo |
| --- | --- | --- |
| 1. Sofá (despierta) | **Enseñar** caminar y saltar | Sin peligro. Por la ventana del segundo piso se ve el **balcón abierto**: la meta. |
| 2. Mesa del comedor | **Enseñar** botón de acción | El vaso: tirarlo da el primer logro. |
| 3. Alfombra con juguetes | **Probar** el salto | Piezas de juguete en el piso **quitan un corazón**; hay que saltar de silla en silla. |
| 4. Aparador | **Enseñar** agacharse | Detrás, a la vista pero fuera de alcance, un calcetín: se ve la recompensa antes de saber llegar. |
| 5. Ratón de cuerda | **Enseñar** zarpazo | Uno solo, en el piso, con espacio para reaccionar. |
| 6. Caja de arena | Punto de descanso | Hito: la lámpara de pie encendida. |
| 7. Escalera (bloqueada) | — | Una **reja para bebés** cierra la escalera. Hay que buscar otro camino: **girar** la idea de "subir". |
| 8. Cocina | **Probar** zarpazo y doble salto | Dos ratones en el mesón; las alacenas altas llevan al hueco del techo. |
| 9. Cortina del ventanal | **Enseñar** trepar | Sin peligro al principio; arriba, un ratón: **probar** trepar con zarpazo. |
| 10. Hueco del techo (pasa al 2.º piso) | **Girar** agacharse | Se entra gateando por el hueco del entrepiso. |
| 11. Dormitorio de Valeria | **Probar** todo | Cama, cómoda y percheros a distintas alturas; el láser aparece y **lleva a un secreto** (calcetín en el clóset): el chiste se vuelve guía. |
| 12. Atajo | Bucle metroidvania | Desde arriba Felipe empuja la reja para bebés: la escalera queda abierta y lleva de vuelta a la caja de arena. |
| 13. Baño | **Girar** acción | Rollo de papel higiénico: tirarlo desde arriba aturde a un ratón de abajo. Enseña "tirar cosas sobre enemigos". |
| 14. Pasillo al balcón: **A.S.P.I. jefa** | **Examen** | A.S.P.I. persigue por el piso. Solo se le puede pegar después de **tirarle algo encima** desde un mueble (macetas, libros): queda aturdida 3 s. Tres ciclos: tirar → bajar → zarpazo. Mientras persigue, Felipe se esconde debajo de la cama (agacharse). |
| 15. Balcón | Alivio | Atardecer, ciudad de fondo, Felipe salta: **Caer de Pie**. Fin. |

**Calcetines (3):** detrás del aparador (se llega por el atajo de la escalera), en el clóset (siguiendo el láser), sobre el ropero (salto difícil con doble salto).

## Encargo de arte a Gemini (imágenes fijas)

Estilo de todas: el de Felipe A (pixel art chibi cel-shaded, dos tonos planos, contorno café oscuro, sin degradados), paleta del Barrio Viejo (terracota, crema, madera, atardecer), **vista lateral recta de juego de plataformas**, fondo blanco liso, sin texto. Escala: 1,21 px por cm (las medidas reales van en cada pieza). Adjuntar Felipe A y, desde la segunda imagen, la primera aprobada como referencia.

| # | Archivo | Contenido |
| --- | --- | --- |
| 1 | `muebles-sala.png` | Hoja de muebles de la sala: sofá (2 m × 85 cm), mesa de comedor con 2 sillas (75 cm), aparador con patas (81 cm, 30 cm libres debajo), librero (1,80 m), lámpara de pie |
| 2 | `muebles-cocina.png` | Mesón con cajones (90 cm), alacenas altas, refrigerador (1,80 m), banco |
| 3 | `muebles-dormitorio.png` | Cama de Valeria (55 cm, hueco debajo), cómoda, ropero alto, perchero, clóset |
| 4 | `escalera-y-baranda.png` | Escalera de madera antigua de un piso de 3,5 m, reja para bebés, baranda del balcón con macetas |
| 5 | `paredes.png` | Muestras de pared: papel tapiz de la sala, azulejos de cocina, pared del dormitorio, moldura y piso de madera |
| 6 | `objetos.png` | Vaso, plato de croquetas, lata de atún, calcetín, rollo de papel higiénico, maceta pequeña, libro, piezas de juguete en el piso, caja de cartón, ratón de cuerda |
| 7 | `aspi-gemini-1.png` | A.S.P.I. (ya encargado) |


## Pelea con A.S.P.I.: "La Bestia del Pasillo"

Desde la cabeza de Felipe (R16). Entrada tipo Broforce de 4,5 s: congela, acercamiento a Felipe con «¡BATALLA INICIADA!», barrido a la jefa, que crece hasta gigante dentro de una nube de pensamiento, y su nombre en una franja. El pasillo se vuelve el fin del mundo. Fases: succión (agacharse para aferrarse; 3 succiones rompen el escudo), aturdir (maceta y 2 zarpazos), furia (bolas de pelo que se saltan; 2 zarpazos más). Al apagarla, todo vuelve de golpe al pasillo y Felipe se acicala. Código en `siete-vidas/juego/scripts/batalla_aspi.gd`; prueba en `prueba_jefe.gd`.
