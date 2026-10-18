# Prototipo: travesuras

**Esto no es el juego.** Es un cuarto feo, hecho a propósito, para responder una pregunta: ¿ser Felipe es divertido por sí solo, haciendo travesuras de gato con su voz y una respuesta épica?

Ábrelo con Godot 4.3 (abre esta carpeta y presiona F5).

## Controles

| Tecla | Mando | Qué hace |
| --- | --- | --- |
| A / D o flechas | cruceta o palanca | caminar |
| Shift (mantener) | RB | correr |
| Espacio / W / arriba | A | saltar (en el aire, otra vez: doble salto) |
| E | Y | acción: tirar lo más cercano, arañar el sofá, comer del plato o el snack |
| Q | X | maullar |
| R | B | intimidar (lomo erizado y bufido) |
| S / abajo (mantener) | cruceta abajo | ronronear (cerca de Valeria enojada, la convence) |
| Enter / Tab | LB | saltar la frase |

## Qué hay en el cuarto

Sofá (se puede arañar y subir), control remoto en el brazo del sofá, mesa con un vaso, repisa con un florero, plato de comida en el piso. Si haces ruido entra Valeria: si ronroneas cerca, te perdona y te deja un snack; si no, te persigue un rato, se rinde y se va. Al irse repone todo, así que puedes volver a empezar.

## Qué mirar mientras juegas

1. ¿Probaste todas las acciones sin que nadie te lo dijera? ¿Cuál repetiste más?
2. ¿Te reíste con alguna frase de Felipe o de Valeria? ¿Cuál?
3. El golpe: ¿se siente que la pata tira el vaso (efecto en el cuadro en que la pata llega), o que el vaso se cae solo?
4. Maullar e intimidar no tienen animación propia (son efectos de código sobre hojas que ya existen). ¿Se entienden igual o se ven pobres?
5. ¿Rompiste algo a propósito delante de Valeria ("¡EN SU CARA!", vale el doble)?
6. ¿Te dieron ganas de hacerlo en otra habitación?

## Pruebas

```
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://pruebas/prueba_impacto.gd   # efecto en el cuadro de impacto y perdón con ronroneo
godot --headless --path . --fixed-fps 60 --script res://pruebas/demo.gd             # bot que juega todo (~66 s)
```

Los valores ajustables están como `@export` en `scripts/sala.gd` (caos, ruido, congelado), `scripts/felipe.gd` (movimiento, tiempos de maullar e intimidar, distancia para tirar), `scripts/valeria.gd` (cuánto ruido la trae, cuánto ronroneo la convence), `scripts/jugo.gd` (combo, sacudida) y `scripts/dialogo.gd` (velocidad del texto).
