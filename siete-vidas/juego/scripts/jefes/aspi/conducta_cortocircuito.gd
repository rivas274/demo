class_name ConductaCortocircuito
extends ConductaJefe
## Clímax de la fase 3 de A.S.P.I. («Cortocircuito y apagón», maqueta de Gemini, 2026-10-23). Al empezar la fase, ya
## reiniciada y furiosa, A.S.P.I. arranca a toda velocidad contra el enchufe de la estación de carga: chispas,
## «¡BZZZT!», sacudida y se corta la luz (ApagonEstudio). Desde ahí, **los charcos** (el agua del vaso y el café de la
## taza que quedaron en el piso) son la clave: si pasa por uno, chispea y queda aturdida (vulnerable, como con el
## depósito lleno: Felipe le salta encima). Maullar la atrae (gira hacia Felipe): se la lleva al charco.
## Siempre hay al menos un charco: el choque sacude el escritorio (el vaso y la taza que sigan arriba caen) y, si aun así
## no hay ninguno, se le sale el agua del tanque al lado del enchufe (Charco).

## Dónde está el enchufe (x en el mundo) y a qué distancia de él se estrella.
@export var enchufe_x := 7330.0
@export var antes_del_enchufe := 30.0
## Velocidad de la carrera contra el enchufe (veces la de persecución) y tope de tiempo.
@export var multiplicador_velocidad := 3.5
@export var tiempo_maximo := 2.5
## Segundos sin volver a electrocutarse después de un charco (si Felipe no la apagó).
@export var espera_charco := 3.5
## Distancia extra (px) a cada lado del charco que ya cuenta como pisarlo.
@export var margen_charco := 4.0

## Ya chocó (hay apagón).
var hecho := false
var corriendo := false
var reloj_charco := 0.0
## Charcos sueltos que dejó el choque.
var sueltos: Array[Charco] = []
var _pendiente := false
var _reloj := 0.0


func nombre() -> String:
	return "cortocircuito"


func al_cambiar_fase(fase: int) -> void:
	if fase >= desde_fase and not hecho:
		_pendiente = true


func cada_cuadro(delta: float) -> void:
	reloj_charco = maxf(0.0, reloj_charco - delta)
	var b := pelea as BatallaAspi
	if not hecho or b.llena or reloj_charco > 0.0 or b.reinicio > 0.0 or b.ausente or b.fase != PeleaJefe.Fase.PELEA:
		return
	if absf(b.jefe.velocity.x) < 5.0:
		return
	for charco in charcos():
		if absf(b.jefe.global_position.x - charco.x) <= charco.y / 2.0 + margen_charco:
			_electrocutar(Vector2(charco.x, b.nivel.datos.suelo))
			return


## Charcos de agua o café en el piso: (x del centro, ancho).
func charcos() -> Array[Vector2]:
	var b := pelea as BatallaAspi
	var lista: Array[Vector2] = []
	for objeto in b.municion:
		if is_instance_valid(objeto) and objeto.tirable.roto and objeto.datos.conduce and objeto.datos.charco_ancho > 0.0:
			lista.append(Vector2(objeto.global_position.x, objeto.datos.charco_ancho))
	for charco in sueltos:
		if is_instance_valid(charco):
			lista.append(Vector2(charco.global_position.x, charco.ancho))
	return lista


func intentar(_delta: float) -> bool:
	if not _pendiente:
		return false
	var b := pelea as BatallaAspi
	_pendiente = false
	corriendo = true
	_reloj = 0.0
	b.empezar_ataque(self)
	b.apariencia.luz_aviso = Color("e0483b")
	b.apariencia.vibrando = true
	b.jefe.patrulla.quieta = false
	b.jefe.patrulla.velocidad_persecucion = DatosJefe.por_fase(b.datos.velocidad, b.vencidas) * multiplicador_velocidad
	var lado := signf(b.jefe.global_position.x - enchufe_x)
	b.jefe.patrulla.destino = enchufe_x + (lado if lado != 0.0 else -1.0) * antes_del_enchufe
	b.sonar_evento("reversa")
	b.nivel.travesuras.jugo.palabra_en_mundo("PALABRA_ERROR", b.jefe.global_position + Vector2(0, -60), Color(1.0, 0.45, 0.4), 16)
	return true


func actualizar(delta: float) -> bool:
	var b := pelea as BatallaAspi
	_reloj += delta
	if _reloj < tiempo_maximo and absf(b.jefe.global_position.x - b.jefe.patrulla.destino) >= 6.0:
		return true
	_chocar()
	return false


## Se estrella contra el enchufe: chispas, sacudida, se corta la luz y queda (o cae) un charco.
func _chocar() -> void:
	var b := pelea as BatallaAspi
	corriendo = false
	hecho = true
	b.terminar_ataque()
	var enchufe := Vector2(enchufe_x, b.nivel.datos.suelo - 24.0)
	b.chispas(enchufe, 30)
	b.presentacion.destello(0.8)
	b.presentacion.sacudir(0.35)
	b.sonar_evento("cortocircuito")
	b.nivel.travesuras.jugo.palabra_en_mundo("PALABRA_BZZZT", enchufe + Vector2(0, -50), Color(0.7, 0.9, 1.0), 24)
	b.apagon.apagar()
	b.nivel.decir("apagon")
	# El choque sacude el escritorio: lo que tenga agua o café y siga arriba, cae.
	var cayo := false
	for objeto in b.municion:
		if is_instance_valid(objeto) and objeto.datos.conduce and not objeto.tirable.roto and not objeto.tirable.cayendo:
			objeto.tirable.soplar(-1.0)
			cayo = true
	if not cayo and charcos().is_empty():
		var charco := Charco.crear(Vector2(enchufe_x - 64.0, b.nivel.datos.suelo))
		b.nivel.add_child(charco)
		sueltos.append(charco)


func _electrocutar(donde: Vector2) -> void:
	var b := pelea as BatallaAspi
	reloj_charco = espera_charco
	b.chispas(donde + Vector2(0, -6), 22)
	b.sonar_evento("cortocircuito")
	b.quedar_vulnerable("charco")
	b.nivel.travesuras.decir_felipe("en_corto")
