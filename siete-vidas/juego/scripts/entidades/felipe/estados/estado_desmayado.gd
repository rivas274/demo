class_name EstadoDesmayado
extends EstadoFelipe
## DESMAYADO: sin corazones. Pierde una de sus nueve vidas (sube como gatito fantasma) y, a los TIEMPO_DESMAYO s,
## reaparece en el último punto de descanso. Sin vidas, vuelven las nueve pero con el Collar de la Vergüenza.

var _tiempo := 0.0


func entrar(_datos := {}) -> void:
	_tiempo = Felipe.TIEMPO_DESMAYO
	felipe.vidas -= 1
	felipe.velocity.x = 0.0
	var sprite := felipe.sprite
	sprite.modulate.a = 1.0
	sprite.play("desmayo")
	# Una de sus nueve vidas sube como gatito fantasma.
	var fantasma := Sprite2D.new()
	fantasma.texture = sprite.sprite_frames.get_frame_texture("quieto", 0)
	fantasma.scale = Vector2.ONE * Felipe.ESCALA_SPRITE * 0.6
	fantasma.global_position = sprite.global_position
	fantasma.modulate = Color(1, 1, 1, 0.7)
	Profundidad.poner(fantasma, Capas.Rol.ESTELA)
	felipe.get_parent().add_child(fantasma)
	var subir := fantasma.create_tween().set_parallel()
	subir.tween_property(fantasma, "global_position:y", fantasma.global_position.y - 70.0, 1.4)
	subir.tween_property(fantasma, "modulate:a", 0.0, 1.4)
	subir.chain().tween_callback(fantasma.queue_free)


func fisica(delta: float, _direccion: float) -> void:
	felipe.frenar(delta)
	felipe.aplicar_gravedad(delta)
	_tiempo -= delta
	if _tiempo <= 0.0:
		_reaparecer()


func _reaparecer() -> void:
	if felipe.vidas <= 0:
		felipe.vidas = Felipe.VIDAS_MAX
		felipe.tiene_collar = true
	felipe.vida.llenar()
	felipe.global_position = felipe.punto_reaparicion
	felipe.velocity = Vector2.ZERO
	felipe.cambiar_estado(Felipe.Estado.SUELO)
	felipe.sprite.play("quieto")
	felipe.vida.restante_invulnerable = Felipe.TIEMPO_INVULNERABLE
