class_name AtaqueSoplido
extends ConductaJefe
## Soplido contra el que acampa (G12): si Felipe pasa más de unos segundos arriba de algo alto, va debajo, vibra con la
## luz amarilla (anticipación) y lo saca de un soplido hacia algo bajo, sin daño. Las macetas caen sin romperse.

## Altura que cuenta como «arriba» y segundos que tolera por fase (en la fase 0 no se usa: desde_fase = 1).
@export var altura_acampar := 90.0
@export var tiempo_acampar: PackedFloat32Array = [1000.0, 3.0, 2.0]
## Segundos arriba para empezar a ir debajo de él.
@export var empieza_a_seguir := 1.0
@export var velocidad_a_debajo := 190.0
@export var aviso := 0.6
@export var empuje := 300.0
@export var duracion := 0.45

## Segundos que lleva Felipe arriba de algo.
var acampando := 0.0
## Soplidos dados (para pruebas y el resumen).
var soplidos := 0
var soplando := false
var _reloj := 0.0
var _hacia := 1.0


func nombre() -> String:
	return "soplido"


func al_cambiar_fase(_fase: int) -> void:
	acampando = 0.0


func vigilar(delta: float) -> void:
	var felipe := pelea.felipe
	if felipe.is_on_floor() and pelea.nivel.datos.suelo - felipe.global_position.y > altura_acampar:
		acampando += delta
	elif felipe.is_on_floor() or felipe.global_position.y > pelea.nivel.datos.suelo - altura_acampar:
		acampando = 0.0


func intentar(_delta: float) -> bool:
	var b := pelea as BatallaAspi
	if acampando <= empieza_a_seguir:
		return false
	b.jefe.patrulla.destino = b.felipe.global_position.x
	b.jefe.patrulla.velocidad_persecucion = velocidad_a_debajo
	if acampando >= DatosJefe.por_fase(tiempo_acampar, b.vencidas) and absf(b.jefe.global_position.x - b.felipe.global_position.x) < 16.0:
		b.empezar_ataque(self)
		soplando = false
		_reloj = 0.0
		b.jefe.patrulla.quieta = true
		b.jefe.patrulla.destino = INF
		b.apariencia.vibrando = true
		b.apariencia.luz_aviso = Color("ffd23f")
		b.nivel.sonar("succion")
		b.nivel.travesuras.jugo.palabra_en_mundo("¡FUUU!", b.jefe.global_position + Vector2(0, -60), Color(1.0, 0.9, 0.4), 14)
	return true


func actualizar(delta: float) -> bool:
	_reloj += delta
	if not soplando:
		if _reloj >= aviso:
			_soplar()
		return true
	if _reloj >= duracion:
		pelea.felipe.empuje = Vector2.ZERO
		pelea.terminar_ataque()
		return false
	return true


## Sopla hacia arriba: Felipe sale empujado al piso (sin daño) y las macetas caen sin romperse.
func _soplar() -> void:
	var b := pelea as BatallaAspi
	var felipe := b.felipe
	soplando = true
	_reloj = 0.0
	soplidos += 1
	b.apariencia.vibrando = false
	acampando = 0.0
	# Desde la repisa sale hacia la puerta del balcón; desde el escritorio, hacia la silla: siempre a algo bajo.
	var repisa := b.nivel.pieza("Repisa de las macetas")
	_hacia = 1.0 if repisa and felipe.global_position.x >= repisa.position.x - 4.0 else -1.0
	felipe.velocity = Vector2(_hacia * empuje, -300.0)
	felipe.empuje = Vector2(_hacia * empuje * 0.6, 0.0)
	b.presentacion.sacudir(0.2)
	b.nivel.travesuras.jugo.palabra_en_mundo("¡FIUUU!", felipe.global_position + Vector2(0, -80), Color(0.8, 0.95, 1.0), 16)
	for objeto in b.municion:
		if objeto.tipo == "maceta" and not objeto.tirable.roto and objeto.visible:
			objeto.tirable.caer_sin_romper(_hacia)
