class_name EstadoRonroneando
extends EstadoFelipe
## RONRONEANDO («Encantar»): se frota contra las piernas de alguien (Valeria enojada) un ciclo de "ronronear" y, al
## terminar, ese alguien recibe perdonar(felipe, "frotarse"). Si algo lo interrumpe (un golpe), no hay perdón.

var _tiempo := 0.0
var _objetivo: Node2D


## datos: {"objetivo": Node2D}.
func entrar(datos := {}) -> void:
	felipe.velocity.x = 0.0
	_objetivo = datos.get("objetivo")
	_tiempo = Felipe.DURACION_RONRONEO
	if _objetivo and absf(_objetivo.global_position.x - felipe.global_position.x) > 2.0:
		felipe.mirando = signf(_objetivo.global_position.x - felipe.global_position.x)
	felipe.sprite.flip_h = felipe.mirando < 0.0
	felipe.animador.reiniciar("ronronear")
	felipe.sonido.emit("ronroneo")


func salir() -> void:
	_objetivo = null


func fisica(delta: float, _direccion: float) -> void:
	felipe.frenar(delta)
	felipe.aplicar_gravedad(delta)
	_tiempo -= delta
	if _tiempo <= 0.0:
		_terminar()


func _terminar() -> void:
	var objetivo := _objetivo
	felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)
	felipe.sprite.play("quieto")
	if is_instance_valid(objetivo):
		if objetivo.has_method("perdonar"):
			objetivo.call("perdonar", felipe, "frotarse")
		felipe.ronroneo_terminado.emit(objetivo)
