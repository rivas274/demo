class_name AtaqueEmbestida
extends ConductaJefe
## Embestida: si Felipe está en el piso, a su altura y cerca, se echa atrás 10 px con la luz roja que parpadea y un
## chirrido (anticipación), y después carga hasta pasarlo. Solo durante la carga lastima.

## Anticipación, carrera y espera entre una y otra (por fase).
@export var aviso := 0.5
@export var duracion := 0.6
@export var espera: PackedFloat32Array = [2.4, 2.0, 1.7]
@export var distancia := 170.0
## Velocidad de la carga: tantas veces la de persecución de la fase.
@export var multiplicador_velocidad := 3.0

## Segundos que faltan para poder embestir otra vez.
var reloj_espera := 0.0
var cargando := false
var _reloj := 0.0
## Hasta dónde va a cargar (lo marca la línea roja del piso durante el aviso).
var destino := 0.0


func nombre() -> String:
	return "embestida"


func al_cambiar_fase(fase: int) -> void:
	reloj_espera = DatosJefe.por_fase(espera, fase)


func cada_cuadro(delta: float) -> void:
	reloj_espera = maxf(0.0, reloj_espera - delta)


func intentar(_delta: float) -> bool:
	var b := pelea as BatallaAspi
	var felipe := b.felipe
	var distancia_a_felipe := felipe.global_position - b.jefe.global_position
	if reloj_espera > 0.0 or not felipe.is_on_floor() or absf(distancia_a_felipe.y) >= 30.0 or absf(distancia_a_felipe.x) >= distancia:
		return false
	# Se echa atrás 10 px, luz roja que parpadea y un chirrido.
	b.empezar_ataque(self)
	cargando = false
	_reloj = 0.0
	b.jefe.patrulla.quieta = true
	b.jefe.patrulla.destino = INF
	b.apariencia.luz_aviso = Color("e0483b")
	var hacia := signf(felipe.global_position.x - b.jefe.global_position.x)
	var atras := b.create_tween()
	atras.tween_property(b.jefe, "position:x", b.jefe.position.x - hacia * 10.0, 0.15)
	destino = clampf(felipe.global_position.x + hacia * 70.0, b.jefe.patrulla.limite_izquierdo, b.jefe.patrulla.limite_derecho)
	# Pitido de reversa de camión (gancho de sonido) mientras se echa atrás.
	b.sonar_evento("reversa")
	return true


func actualizar(delta: float) -> bool:
	var b := pelea as BatallaAspi
	_reloj += delta
	if not cargando:
		if _reloj >= aviso:
			cargando = true
			_reloj = 0.0
			b.jefe.patrulla.quieta = false
			b.jefe.dano.activo = true
			b.jefe.patrulla.velocidad_persecucion = DatosJefe.por_fase(b.datos.velocidad, b.vencidas) * multiplicador_velocidad
			b.jefe.patrulla.destino = destino
		return true
	if _reloj >= duracion or absf(b.jefe.global_position.x - destino) < 6.0:
		# Frena de golpe: la pantalla tiembla un poco (v3.1).
		b.nivel.travesuras.jugo.temblar(b.reacciones.datos.temblor_embestida, b.reacciones.datos.temblor_embestida_s)
		b.terminar_ataque()
		reloj_espera = DatosJefe.por_fase(espera, b.vencidas)
		return false
	return true
