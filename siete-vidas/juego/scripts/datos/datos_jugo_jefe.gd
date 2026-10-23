class_name DatosJugoJefe
extends Resource
## Números del «jugo» de una pelea de jefe (pelea con A.S.P.I. v3, video «How to make enemy spawns feel good» que mandó
## el creador: avisar, hacer temblar el piso y despertar al enemigo con una pausa). Se ajustan en el inspector.

@export_group("Golpe al apagarlo (el piso tiembla)")
## Onda de choque en el piso: radio final (px), cuántos escalones (anillos) y segundos por escalón.
@export var onda_radio := 84.0
@export var onda_escalones := 3
@export var onda_paso := 0.045
## Sacudida VERTICAL de cámara: segundos y fuerza (× Jugo.sacudida_maxima).
@export var sacudida := 0.16
@export var fuerza := 1.3
## Lo tirado cerca (pedazos, papeles, pelusas, libros) brinca: altura (px) y hasta qué distancia.
@export var brinco := 7.0
@export var radio_brinco := 130.0
## Granos de polvo que saltan del piso.
@export var polvo := 16
## El golpe que termina una fase es más fuerte: multiplica onda, sacudida, brinco y polvo.
@export var multiplicador_final := 1.6

@export_group("Despertar (al entrar y al volver de cada fase)")
## Pausa (s) con la luz roja y el «!» antes de moverse.
@export var pausa_despertar := 0.4

@export_group("Avisos en el piso")
## Radio (px) de la marca donde va a cargar o donde va a caer una bola.
@export var radio_marca := 14.0
