class_name DatosJugoJefe
extends Resource
## Números del «jugo» de una pelea de jefe (pelea con A.S.P.I. v3, video «How to make enemy spawns feel good» que mandó
## el creador: avisar, hacer temblar el piso y despertar al enemigo con una pausa). Se ajustan en el inspector.

@export_group("Golpe al apagarlo (el piso tiembla)")
## Onda de choque en el piso: radio final (px), cuántos escalones (anillos) y segundos por escalón.
@export var onda_radio := 84.0
@export var onda_escalones := 3
@export var onda_paso := 0.045
## Temblor de pantalla (v3.1), en píxeles ENTEROS de la base 640 × 360 y segundos: golpe normal, golpe final,
## embestida que choca y cortocircuito. Con «Reducir sacudida» se dividen por 3.
@export var temblor_golpe := 3
@export var temblor_golpe_s := 0.2
@export var temblor_final := 6
@export var temblor_final_s := 0.35
@export var temblor_embestida := 2
@export var temblor_embestida_s := 0.15
@export var temblor_corto := 4
@export var temblor_corto_s := 0.3
## Lo tirado cerca (pedazos, papeles, pelusas, libros) brinca: altura (px) y hasta qué distancia.
@export var brinco := 7.0
@export var radio_brinco := 130.0
## Granos de polvo que saltan del piso.
@export var polvo := 16
## El golpe final es más fuerte: multiplica onda, brinco y polvo (el temblor tiene su propio valor).
@export var multiplicador_final := 1.6

@export_group("Remate: el salto estrella (v4)")
## Pausa de impacto (hitstop) al caerle encima: segundos de juego congelado (3 a 4 cuadros a 60 fps); el final, más.
@export var congelado_golpe := 0.067
@export var congelado_final := 0.2
## Destello blanco de su silueta (s) y estrellas que saltan del golpe.
@export var destello_golpe := 0.08
@export var destello_final := 0.2
@export var estrellas := 6
@export var estrellas_final := 10
## Anticipación con el depósito lleno: se hincha (tope ±8 %, como Felipe), echa humo y el motor falla.
@export_range(0.0, 0.08) var inflado := 0.08
@export var humo_cada := 0.3
@export var falla_cada := 0.6
## Silencio antes del impacto: si Felipe cae sobre ella y está a menos de estos px, se callan los sonidos.
@export var silencio_distancia := 90.0

@export_group("Aplastar: el salto dirigido (v5)")
## Alcance de «Aplastar»: en el piso (px de lado) y subido a un mueble (px de lado y hasta qué altura sobre el piso).
@export var alcance_piso := 120.0
@export var alcance_mueble := 190.0
@export var altura_mueble := 200.0
## El arco: cuánto sube sobre el extremo más alto y cuánto dura (base, más por distancia, con tope).
@export var altura_arco := 40.0
@export var aplastar_base := 0.3
@export var aplastar_px_por_s := 700.0
@export var aplastar_maximo := 0.55

@export_group("Ruido: un solo foco a la vez (v5)")
## Velo sobre el fondo durante la pelea (baja el contraste del decorado; lo jugable queda a todo color): color y
## opacidad (0 = sin velo). Va en la capa VELO de Capas: tapa pared, muebles y restos; no lo jugable.
@export var velo_color := Color(0.62, 0.5, 0.4)
@export var velo := 0.0
## Destello de lo que se puede tirar: 0 = nunca, 1 = solo cerca de Felipe, 2 = siempre (v4). Y qué tan cerca.
@export_range(0, 2) var brillo_tirables := 1
@export var brillo_cerca := 110.0
## Motas de polvo que suben por el rayo de la ventana del estudio.
@export var motas_ambiente := false
## Restos del piso: tinte (más oscuro y plano: se funden con el piso) y cuántos pedazos deja algo roto como mucho.
@export var tinte_resto := Color(0.8, 0.78, 0.84)
@export var max_pedazos := 99
## La LED de A.S.P.I. parpadea en reposo (fuera de los avisos).
@export var led_parpadea := true
## Segundos después del «¡CLIC!» en que escupe la montaña (cuando ya se fueron el «¡CLIC!» y el cartel de fase).
@export var espera_escupir := 0.7

@export_group("Recuperación (el cuarto tiempo de cada ataque)")
## Después de chocar con la embestida o de escupir una bola queda mareada: quieta e inofensiva (ventana para pasarla o
## usarla de trampolín).
@export var mareo := 0.6
## Si Felipe le cae encima mientras está mareada, rebota (velocidad hacia arriba).
@export var rebote_mareada := -380.0

@export_group("Despertar (al entrar y al volver de cada fase)")
## Pausa (s) con la luz roja y el «!» antes de moverse.
@export var pausa_despertar := 0.4

@export_group("Avisos en el piso")
## Radio (px) de la marca donde va a cargar o donde va a caer una bola.
@export var radio_marca := 14.0
