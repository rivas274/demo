class_name RecibeGolpes
extends Node
## Pieza para lo que Felipe golpea (hurtbox): el zarpazo llega aquí (`recibir_zarpazo`, la interfaz común de todo lo
## que se golpea) y pasa el daño a la Vida hermana. También la aturde lo que le cae encima (una maceta, la taza de
## café). No mueve ni dibuja nada: avisa con señales y la entidad decide (A.S.P.I. retrocede, el ratón se vuelca).

## El golpe dolió (pasó a la Vida).
signal golpeado(felipe: Felipe)
## El golpe rebotó: la Vida es invulnerable (escudo) o hace falta aturdirla primero.
signal rebotado(felipe: Felipe)
## Algo le cayó encima: queda aturdida `segundos`.
signal aturdido(segundos: float)
## Se le pasó el aturdimiento.
signal se_le_paso

## Solo le duele mientras está aturdida (A.S.P.I.: hay que tirarle algo encima primero).
@export var solo_aturdido := false

var _aturdido := 0.0


func _init() -> void:
	name = "RecibeGolpes"


## El zarpazo de Felipe (en el cuadro en que la pata llega).
func recibir_zarpazo(felipe: Felipe) -> void:
	var vida := _vida()
	if vida and vida.muerto:
		return
	if (vida and vida.invulnerable) or (solo_aturdido and _aturdido <= 0.0):
		rebotado.emit(felipe)
		return
	if vida:
		vida.danar(1)
	golpeado.emit(felipe)


## Algo le cayó encima (Tirable): queda aturdida `segundos` (no si ya cayó).
func aturdir(segundos: float) -> void:
	var vida := _vida()
	if vida and vida.muerto:
		return
	_aturdido = segundos
	aturdido.emit(segundos)


func esta_aturdido() -> bool:
	return _aturdido > 0.0


func _physics_process(delta: float) -> void:
	if _aturdido <= 0.0:
		return
	_aturdido = maxf(0.0, _aturdido - delta)
	if _aturdido <= 0.0:
		se_le_paso.emit()


func _vida() -> Vida:
	return Componentes.de(get_parent(), Vida) as Vida
