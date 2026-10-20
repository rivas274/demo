class_name Vida
extends Node
## Pieza de vida: cuánto aguanta algo antes de caer. Felipe la usa para sus corazones (5), A.S.P.I. para sus apagados
## (3), el ratón de cuerda y la caja de cartón para su único golpe. No sabe quién la lleva ni qué pasa al morir: avisa
## con señales (`cambio`, `danado`, `murio`) y cada entidad decide (Felipe se desmaya, el ratón queda patas arriba, la
## caja se rompe y suelta un snack). No confundir con las nueve `vidas` de Felipe: eso son intentos, no salud.

## Cambió lo que le queda (golpe, curación o vuelta a llenarse).
signal cambio(actual: int, maximo: int)
## Recibió un golpe que dolió.
signal danado(cantidad: int)
## Llegó a cero.
signal murio

## Cuánto aguanta.
@export var maximo := 1
## Segundos sin recibir más daño después de un golpe (Felipe: 1,2 s, mientras parpadea).
@export var tiempo_invulnerable := 0.0

## Lo que le queda (-1 hasta que entra al árbol: ahí se llena).
var actual := -1
var muerto := false
## Mientras sea true ningún golpe le hace daño (el escudo de A.S.P.I. en la entrada).
var invulnerable := false
## Segundos de invulnerabilidad que quedan después del último golpe.
var restante_invulnerable := 0.0


func _init(maximo_inicial := 1, segundos_invulnerable := 0.0) -> void:
	name = "Vida"
	maximo = maximo_inicial
	tiempo_invulnerable = segundos_invulnerable


func _ready() -> void:
	if actual < 0:
		actual = maximo


func _physics_process(delta: float) -> void:
	avanzar(delta)


## Descuenta el tiempo invulnerable. Felipe lo llama él mismo al empezar su cuadro (apaga el de esta pieza con
## set_physics_process(false)): así se congela mientras cruza una puerta, como siempre.
func avanzar(delta: float) -> void:
	restante_invulnerable = maxf(0.0, restante_invulnerable - delta)


## ¿Un golpe ahora le haría daño?
func puede_recibir() -> bool:
	return not muerto and not invulnerable and restante_invulnerable <= 0.0


## Quita `cantidad`. Devuelve true si dolió (no estaba muerta ni invulnerable). Al llegar a cero emite `murio`; si no,
## empieza el tiempo invulnerable.
func danar(cantidad := 1) -> bool:
	if not puede_recibir():
		return false
	actual = maxi(actual - cantidad, 0)
	danado.emit(cantidad)
	cambio.emit(actual, maximo)
	if actual == 0:
		muerto = true
		murio.emit()
	else:
		restante_invulnerable = tiempo_invulnerable
	return true


func curar(cantidad := 1) -> void:
	if muerto:
		return
	actual = mini(actual + cantidad, maximo)
	cambio.emit(actual, maximo)


## Vuelve a estar entera (Felipe al reaparecer).
func llenar() -> void:
	muerto = false
	actual = maximo
	cambio.emit(actual, maximo)


## Cae de una vez, aunque sea invulnerable (el tercer «¡CLIC!» de la pelea apaga a A.S.P.I.).
func morir() -> void:
	if muerto:
		return
	actual = 0
	muerto = true
	cambio.emit(actual, maximo)
	murio.emit()


## Pone lo que le queda sin pasar por un golpe (las pruebas, o una recompensa que cura de golpe).
func fijar(valor: int) -> void:
	actual = clampi(valor, 0, maximo)
	cambio.emit(actual, maximo)
