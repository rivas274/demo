class_name EstadoAccion
extends EstadoFelipe
## Las mañas de un ciclo en el lugar: ZARPAZO (también el manotazo), COMIENDO, ARANANDO y MAULLANDO. Al entrar frena y
## reproduce su animación desde el cuadro 0; el efecto sale en el cuadro de impacto (ManasFelipe); al terminar la
## animación vuelve a SUELO o AIRE. Las cuatro se comportan igual: solo cambia la animación (un estado por dato).

var animacion: String


func _init(de: Felipe, estado: Felipe.Estado, nombre_animacion: String) -> void:
	super(de, estado)
	animacion = nombre_animacion


func entrar(_datos := {}) -> void:
	felipe.velocity.x = 0.0
	felipe.animador.reiniciar(animacion)


func fisica(delta: float, _direccion: float) -> void:
	felipe.frenar(delta)
	felipe.aplicar_gravedad(delta)


func animacion_terminada() -> void:
	felipe.manas.limpiar()
	felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)
