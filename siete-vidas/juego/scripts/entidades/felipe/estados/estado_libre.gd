class_name EstadoLibre
extends EstadoFelipe
## SUELO y AIRE: Felipe se mueve con los controles, salta y puede empezar acciones (zarpazo, maullar, usar lo cercano).
## La diferencia entre los dos la marca la física (is_on_floor); el estado solo dice qué animación toca.


func fisica(delta: float, direccion: float) -> void:
	felipe.mover(direccion, delta)
	felipe.aplicar_gravedad(delta)
	felipe.intentar_saltar()
	felipe.intentar_acciones(direccion, delta)
