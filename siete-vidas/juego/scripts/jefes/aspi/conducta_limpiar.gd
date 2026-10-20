class_name ConductaLimpiar
extends ConductaJefe
## Lo que A.S.P.I. hace cuando no ataca: va a la mancha más vieja, gira el cepillo (anticipación) y la aspira. Mientras
## aspira, de pie Felipe se desliza hacia ella; agachado se aferra. Cada mancha le llena el depósito; lleno, queda
## vulnerable (BatallaAspi). Sin manchas, se queda en reposo y deja pasar a la embestida.

@export var aviso := 0.6
## Segundos para limpiar una mancha y radio de la succión, por fase.
@export var tiempo_limpieza: PackedFloat32Array = [2.6, 2.2, 1.8]
@export var radio_succion: PackedFloat32Array = [200.0, 200.0, 260.0]
## Más que caminar (120 px/s): de pie no se escapa; hay que agacharse.
@export var fuerza_succion := 150.0

var limpiando := false
## Segundos del giro del cepillo antes de aspirar (la anticipación).
var reloj_aviso := 0.0
var _reloj := 0.0


func nombre() -> String:
	return "limpiar"


func al_cambiar_fase(_fase: int) -> void:
	_reloj = 0.0


func intentar(delta: float) -> bool:
	var b := pelea as BatallaAspi
	b.jefe.patrulla.velocidad_persecucion = DatosJefe.por_fase(b.datos.velocidad, b.vencidas)
	if b.manchas.is_empty():
		limpiando = false
		reloj_aviso = 0.0
		b.jefe.patrulla.destino = INF
		return false
	var mancha := b.manchas[0]
	b.jefe.patrulla.destino = mancha
	if absf(b.jefe.global_position.x - mancha) >= 6.0:
		return true
	if not limpiando:
		reloj_aviso += delta
		b.apariencia.vibrando = true
		if reloj_aviso < aviso:
			return true
		b.apariencia.vibrando = false
		limpiando = true
		_reloj = 0.0
		b.nivel.sonar("succion")
	_reloj += delta
	b.succionando = true
	_aspirar()
	if _reloj >= DatosJefe.por_fase(tiempo_limpieza, b.vencidas):
		b.manchas.pop_front()
		b.tipos_mancha.pop_front()
		limpiando = false
		reloj_aviso = 0.0
		_reloj = 0.0
		b.llenar_deposito()
	return true


## Mientras limpia aspira: de pie, Felipe se desliza hacia ella; agachado se aferra.
func _aspirar() -> void:
	var b := pelea as BatallaAspi
	var felipe := b.felipe
	var distancia := b.jefe.global_position.x - felipe.global_position.x
	var radio: float = DatosJefe.por_fase(radio_succion, b.vencidas)
	if absf(distancia) < radio and absf(distancia) > 6.0 and absf(felipe.global_position.y - b.jefe.global_position.y) < 40.0:
		felipe.empuje = Vector2(signf(distancia) * fuerza_succion, 0.0)
