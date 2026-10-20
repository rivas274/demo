class_name EstadoEscalera
extends EstadoFelipe
## SUBIENDO_ESCALON: sube (o baja) escalón por escalón por una lista de peldaños (posiciones de los pies), con un
## saltito por escalón en un ciclo de "subir_escalera". Mientras tanto no lo mueve la física. Bajando usa los cuadros
## de saltar y caer, sin animación nueva (propuesta v4, sección 4). Al terminar, Felipe emite escalera_terminada.

var _peldanos: Array[Vector2] = []
var _desde := Vector2.ZERO
var _hasta := Vector2.ZERO
var _tiempo := 0.0
var _duracion := Felipe.DURACION_ESCALON
var _subidos := 0


## datos: {"peldanos": Array[Vector2], "duracion": float}.
func entrar(datos := {}) -> void:
	if felipe.agachado:
		felipe.agachado_felipe.poner(false)
	felipe.trepando = false
	_peldanos.assign(datos.get("peldanos", []))
	_duracion = maxf(datos.get("duracion", Felipe.DURACION_ESCALON), 0.05)
	_subidos = 0
	felipe.velocity = Vector2.ZERO
	felipe.efectos.detener()
	felipe.sprite.rotation = 0.0
	felipe.sprite.scale = felipe.efectos.escala_base()
	_siguiente()


func salir() -> void:
	felipe.sprite.speed_scale = 1.0
	_peldanos.clear()


func fisica(delta: float, _direccion: float) -> void:
	_tiempo += delta
	var t := clampf(_tiempo / _duracion, 0.0, 1.0)
	var posicion := _desde.lerp(_hasta, t)
	posicion.y -= sin(t * PI) * Felipe.SALTITO_ESCALON
	felipe.global_position = posicion
	if _hasta.y > _desde.y and t > 0.6:
		felipe.animador.poner_cuadro("caer", Felipe.CUADRO_CONTACTO)
	if t < 1.0:
		return
	_subidos += 1
	felipe.escalon_subido.emit(_subidos)
	if _peldanos.is_empty():
		felipe.terminar_escalera()
	else:
		_siguiente()


func _siguiente() -> void:
	var sprite := felipe.sprite
	_desde = felipe.global_position
	_hasta = _peldanos.pop_front()
	_tiempo = 0.0
	if absf(_hasta.x - _desde.x) > 0.5:
		felipe.mirando = signf(_hasta.x - _desde.x)
	sprite.flip_h = felipe.mirando < 0.0
	if _hasta.y > _desde.y:
		sprite.speed_scale = 1.0
		felipe.animador.poner_cuadro("saltar", Felipe.CUADRO_ARRIBA)
		return
	var frames := sprite.sprite_frames
	sprite.speed_scale = frames.get_frame_count("subir_escalera") / (frames.get_animation_speed("subir_escalera") * _duracion)
	felipe.animador.reiniciar("subir_escalera")
