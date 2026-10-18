# Prototipo: travesuras (v2: Agenda de Su Majestad)

**Esto no es el juego.** Es un cuarto feo, hecho a propósito, para responder una pregunta.

- **v1:** ¿ser Felipe es divertido por sí solo? Resultado: CAMBIAR. Tirar cosas divierte al principio, pero sin un motivo se agota, y el medidor de CAOS no servía.
- **v2 (esta):** si cada travesura es un objetivo con nombre y una recompensa útil (la Agenda de Su Majestad, como la lista de Untitled Goose Game), ¿el jugador busca y planea travesuras en vez de romper al azar?

Ábrelo con Godot 4.3 (abre esta carpeta y presiona F5).

## Controles

| Tecla | Mando | Qué hace |
| --- | --- | --- |
| A / D o flechas | cruceta o palanca | caminar |
| Shift (mantener) | RB | correr |
| Espacio / W / arriba | A | saltar (en el aire, otra vez: doble salto) |
| E | Y | acción: tirar lo más cercano, arañar el sofá, comer del plato |
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
| Que Valeria me perdone 2 veces | sí | Un snack por cada perdón |
| Tirarle algo encima a Valeria | secreta (???) | Snack de emergencia (se le cae del bolsillo) |
| Intimidar a la aspiradora | secreta (???) | Calcetín (se lo había tragado) |

Arriba a la izquierda se ve cuántas van (AGENDA 2/6) y las recompensas: calcetines (2/3), snacks y fotos. Ya no hay CAOS ni puntaje. Al cumplir una sale el cartel "¡TRAVESURA CUMPLIDA!" o "¡TRAVESURA SECRETA!", con el nombre, la recompensa y una frase de Felipe. Con la agenda completa (y nada por recoger), o al apretar F, sale el resumen del día.

Pistas que hay en el cuarto: la etiqueta "NUEVO" en el sofá, la punta de un calcetín que asoma bajo la persiana y la aspiradora que duerme bajo la mesa. Valeria solo ve la tele cuando está de buenas, o sea, después de perdonarte.

## Qué mirar en la v2

1. ¿Abriste la agenda sin que nadie te lo dijera? ¿Cuántas veces? ¿Te detuviste a leerla?
2. ¿Planeaste alguna travesura (por ejemplo, conseguir que Valeria te perdone para que se siente a ver la tele) o seguiste rompiendo al azar?
3. ¿Buscaste las dos secretas? ¿Encontraste alguna sin ayuda? ¿Cuál y cómo?
4. ¿Las recompensas te importaron? ¿Fuiste a buscar el calcetín del alféizar o la foto, o te dio lo mismo?
5. ¿Quisiste completar la lista? ¿Te dieron ganas de jugar otra agenda en otra habitación?
6. El cartel y el resumen: ¿se sienten como premio o estorban?

## Pruebas

```
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_impacto.gd   # v1: efecto en el cuadro de impacto y perdón con ronroneo
godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_agenda.gd    # v2: sin CAOS, agenda, secretas, recompensas, camino y resumen
godot --headless --path . --fixed-fps 60 --script res://pruebas/demo.gd             # bot que completa la agenda (~74 s)
```

Agrega `-- --detalle` al bot para ver cada paso y cada botón.

Los valores ajustables están como `@export` en `scripts/sala.gd` (ruido, congelado, espera del resumen), `scripts/felipe.gd` (movimiento, tiempos de maullar e intimidar), `scripts/valeria.gd` (ruido que la trae, ronroneo que la convence, cuánto rato ve la tele), `scripts/sofa.gd` (arañazos que aguanta el plástico), `scripts/aspiradora.gd` (alcance del bufido, huida), `scripts/hud.gd` (retraso del cartel), `scripts/resumen.gd` (ritmo del conteo) y `scripts/dialogo.gd` (velocidad del texto y caducidad de las frases en cola). Las travesuras están en `scripts/agenda.gd`.
