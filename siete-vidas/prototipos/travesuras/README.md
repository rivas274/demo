# Prototipo: travesuras (v2: Agenda de Su Majestad)

**Esto no es el juego.** Es un cuarto feo, hecho a propósito, para responder una pregunta.

- **v1:** ¿ser Felipe es divertido por sí solo? Resultado: CAMBIAR. Tirar cosas divierte al principio, pero sin un motivo se agota, y el medidor de CAOS no servía.
- **v2 (esta):** si cada travesura es un objetivo con nombre y una recompensa útil (la Agenda de Su Majestad, como la lista de Untitled Goose Game), ¿el jugador busca y planea travesuras en vez de romper al azar?
  - **v2b, "Teatro para Valeria":** se agregó un rascador nuevo y caro junto al sofá, una tercera secreta y frases nuevas para Valeria.

Ábrelo con Godot 4.3 (abre esta carpeta y presiona F5).

## Controles

| Tecla | Mando | Qué hace |
| --- | --- | --- |
| A / D o flechas | cruceta o palanca | caminar |
| Shift (mantener) | RB | correr |
| Espacio / W / arriba | A | saltar (en el aire, otra vez: doble salto) |
| E | Y | acción: tirar lo más cercano, arañar el sofá o el rascador (desde el piso y mirándolo), comer del plato |
| Q | X | maullar |
| R | B | intimidar (lomo erizado y bufido) |
| S / abajo (mantener) | cruceta abajo | ronronear (cerca de Valeria enojada, la convence) |
| **Tab** | **Select / Back** | **abrir o cerrar la Agenda** (el juego queda en pausa) |
| **F** | **Start** | **terminar el día** (pantalla de resumen) |
| Enter | LB | saltar la frase; en el resumen, seguir jugando |

Las recompensas se recogen pasando por encima.

## La Agenda de Su Majestad

| Travesura | Visible | Recompensa |
| --- | --- | --- |
| Derribar el florero heredado de la abuela | sí | Foto vergonzosa (estaba escondida en el florero y cae flotando) |
| Arañar el sofá nuevo (todavía tiene el plástico) | sí | Calcetín (estaba entre los cojines) |
| Tirar el control mientras Valeria ve su serie | sí | Camino: la persiana sube y el alféizar pasa a ser una plataforma, con un calcetín encima |
| Que Valeria me perdone 2 veces | sí | Un snack por cada perdón (ronroneando o usando el rascador delante de ella) |
| Tirarle algo encima a Valeria | secreta (???) | Snack de emergencia (se le cae del bolsillo) |
| Intimidar a la aspiradora | secreta (???) | Calcetín (se lo había tragado) |
| Arañar el sofá justo al lado del rascador nuevo | secreta (???) | Foto vergonzosa (Valeria arañando el rascador "para enseñarle"; estaba escondida detrás) |

Arriba a la izquierda se ve cuántas van (AGENDA 2/7) y las recompensas: calcetines (2/3), snacks y fotos. Ya no hay CAOS ni puntaje. Al cumplir una sale el cartel "¡TRAVESURA CUMPLIDA!" o "¡TRAVESURA SECRETA!", con el nombre, la recompensa y una frase de Felipe. Con la agenda completa (y nada por recoger), o al apretar F, sale el resumen del día.

## El rascador ("Teatro para Valeria")

Un rascador nuevo y caro (poste con cuerda, base y plataforma; unos 75 cm, 90 px) junto al brazo derecho del sofá, con la etiqueta del precio todavía colgando ($89.990). Se araña con E desde el piso, mirándolo (si Felipe está pegado al brazo del sofá y mira el sofá, araña el sofá).

- **Con público** (Valeria en la sala y mirando hacia el rascador, incluso sentada viendo la tele): cuenta como perdón al instante, igual que ronronear. Suma a "perdóname 2 veces" y da su snack. Valeria dice "¡Mira, sí lo usa!" y saca el celular para la foto (flash), y sale "¡OVACIÓN!". Solo una vez por visita: si lo repite, ella dice "Sí, mi amor, ya te vi" y no hay premio.
- **Sin público:** Felipe se queja ("¿Para quién actúo?", "Arte desperdiciado. Nadie miró.") y no hay premio.
- **Garras afiladas:** después de usarlo, con o sin público, las garras quedan afiladas 6 s (chispitas en las patas, que parpadean al final). El siguiente arañazo al sofá es "¡CRÍTICO!" y, si todavía tiene el plástico, lo rompe de un golpe.
- **Secreta:** arañar el brazo del sofá pegado al rascador mientras Valeria mira hacia él. Ella grita "¡Pipe! ¡El rascador está AHÍ! ¡A diez centímetros!" y sube la foto a sus historias.

## Valeria

Habla con la voz de la biblia: teletrabaja, sube todo a redes, lo adora y le habla como a un bebé ("Pipe"). Felipe se cree un dios y ella lo trata de bebito gordito, y el enojo se le pasa en cuanto piensa en sus seguidores. Cuando perdona (o cuando pasa algo muy gracioso) saca el celular y hace una foto con flash. Es solo efecto y frase, no hay mecánica nueva.

Pistas que hay en el cuarto: la etiqueta "NUEVO" en el sofá, la punta de un calcetín que asoma bajo la persiana y la aspiradora que duerme bajo la mesa. Valeria solo ve la tele cuando está de buenas, o sea, después de perdonarte.

## Qué mirar en la v2

1. ¿Abriste la agenda sin que nadie te lo dijera? ¿Cuántas veces? ¿Te detuviste a leerla?
2. ¿Planeaste alguna travesura (por ejemplo, conseguir que Valeria te perdone para que se siente a ver la tele) o seguiste rompiendo al azar?
3. ¿Buscaste las tres secretas? ¿Encontraste alguna sin ayuda? ¿Cuál y cómo?
4. ¿Las recompensas te importaron? ¿Fuiste a buscar el calcetín del alféizar o la foto, o te dio lo mismo?
5. ¿Quisiste completar la lista? ¿Te dieron ganas de jugar otra agenda en otra habitación?
6. El cartel y el resumen: ¿se sienten como premio o estorban?
7. El rascador: ¿lo usaste solo para que Valeria te viera? ¿La queja sin público te dio risa o te pareció un castigo? ¿Afilaste antes de ir al sofá a propósito?
8. Valeria: ¿sus frases te hicieron reír? ¿Se entiende el contraste (él se cree un rey, ella le dice bebito)?

## Pruebas

```
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_impacto.gd   # v1: efecto en el cuadro de impacto y perdón con ronroneo
godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_agenda.gd    # v2: sin CAOS, agenda, secretas, recompensas, camino, rascador y resumen
godot --headless --path . --fixed-fps 60 --script res://pruebas/demo.gd             # bot que completa la agenda de 7 (~78 s de juego)
```

Agrega `-- --detalle` al bot para ver cada paso y cada botón.

Los valores ajustables están como `@export` en `scripts/sala.gd` (ruido, congelado, espera del resumen), `scripts/felipe.gd` (movimiento, tiempos de maullar e intimidar), `scripts/valeria.gd` (ruido que la trae, ronroneo que la convence, cuánto rato ve la tele), `scripts/sofa.gd` (arañazos que aguanta el plástico), `scripts/felipe.gd` (`duracion_garras`: segundos de garras afiladas), `scripts/sala.gd` (`ruido_rascador`), `scripts/aspiradora.gd` (alcance del bufido, huida), `scripts/hud.gd` (retraso del cartel), `scripts/resumen.gd` (ritmo del conteo) y `scripts/dialogo.gd` (velocidad del texto y caducidad de las frases en cola). Las travesuras están en `scripts/agenda.gd`.
