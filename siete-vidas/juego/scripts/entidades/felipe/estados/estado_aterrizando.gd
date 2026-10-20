class_name EstadoAterrizando
extends EstadoFelipe
## ATERRIZANDO: los 0,24 s de tocar el piso (delanteras primero, después baja la parte de atrás y se aplasta). Se puede
## mover, saltar y actuar; si nada lo interrumpe, vuelve a SUELO.

## Lo que dura el aterrizaje (y lo que le queda, para el animador).
const DURACION := 0.24


func entrar(_datos := {}) -> void:
	felipe.tiempo_aterrizando = DURACION


func fisica(delta: float, direccion: float) -> void:
	felipe.mover(direccion, delta)
	felipe.aplicar_gravedad(delta)
	felipe.intentar_saltar()
	if felipe.estado == id:
		felipe.intentar_acciones(direccion, delta)
	felipe.tiempo_aterrizando -= delta
	if felipe.tiempo_aterrizando <= 0.0 and felipe.estado == id:
		felipe.cambiar_estado(Felipe.Estado.SUELO)
