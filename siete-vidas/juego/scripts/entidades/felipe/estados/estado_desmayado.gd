class_name EstadoDesmayado
extends EstadoFelipe
## DESMAYADO: sin huellas («Nueve vidas, ninguna se va», salud de 9 huellas, 2026-10-23). Sus 9 huellas suben como 9
## gatitos fantasma, se detienen a media subida, se miran y vuelven a bajar a él (no les dio permiso). A los
## TIEMPO_DESMAYO s reaparece en el último descanso con las 9 huellas llenas, sin perder nada, y dice «Siesta
## táctica.» (lo dice Travesuras al oír SaludFelipe.reaparecio). Al tercer desmayo del nivel, el Collar de la
## Vergüenza (SaludFelipe.desmayarse). Con «Reducir movimiento», los fantasmas solo aparecen y se desvanecen.

const FANTASMAS := 9
## Subida, pausa (se miran) y vuelta de los fantasmas, en segundos: todo antes de reaparecer.
const SUBIDA := 0.8
const PAUSA := 0.35
const VUELTA := 0.45
const ALTO_SUBIDA := 84.0
const ABANICO := 76.0
const ESCALA_FANTASMA := 0.38

var _tiempo := 0.0


func entrar(_datos := {}) -> void:
	_tiempo = Felipe.TIEMPO_DESMAYO
	felipe.salud.desmayarse()
	felipe.velocity.x = 0.0
	var sprite := felipe.sprite
	sprite.modulate.a = 1.0
	sprite.play("desmayo")
	for i in FANTASMAS:
		_fantasma(i)


## Un gatito fantasma (Felipe A, chico y translúcido) que sube en abanico, se da vuelta y vuelve a Felipe.
func _fantasma(i: int) -> void:
	var sprite := felipe.sprite
	var fantasma := Sprite2D.new()
	fantasma.name = "Fantasma %d" % (i + 1)
	fantasma.texture = sprite.sprite_frames.get_frame_texture("quieto", 0)
	fantasma.scale = Vector2.ONE * Felipe.ESCALA_SPRITE * ESCALA_FANTASMA
	fantasma.flip_h = i % 2 == 1
	var origen := sprite.global_position
	fantasma.global_position = origen
	fantasma.modulate = Color(1, 1, 1, 0.0)
	Profundidad.poner(fantasma, Capas.Rol.ESTELA)
	felipe.get_parent().add_child(fantasma)
	var abanico := (i - (FANTASMAS - 1) / 2.0) / ((FANTASMAS - 1) / 2.0)
	var arriba := origen + Vector2(roundf(abanico * ABANICO), -ALTO_SUBIDA + absf(abanico) * 22.0 - (i % 2) * 10.0)
	var t := fantasma.create_tween()
	if Opciones.reducir_movimiento:
		t.tween_property(fantasma, "modulate:a", 0.7, 0.2)
		t.tween_interval(SUBIDA + PAUSA + VUELTA - 0.4)
		t.tween_property(fantasma, "modulate:a", 0.0, 0.2)
	else:
		t.set_parallel()
		t.tween_property(fantasma, "global_position", arriba, SUBIDA).set_delay(i * 0.03).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.tween_property(fantasma, "modulate:a", 0.75, 0.25)
		t.chain().tween_callback(func() -> void: fantasma.flip_h = not fantasma.flip_h)
		t.chain().tween_interval(PAUSA)
		t.chain().tween_property(fantasma, "global_position", origen + Vector2(0, -20), VUELTA).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.parallel().tween_property(fantasma, "modulate:a", 0.0, VUELTA)
	t.chain().tween_callback(fantasma.queue_free)


func fisica(delta: float, _direccion: float) -> void:
	felipe.frenar(delta)
	felipe.aplicar_gravedad(delta)
	_tiempo -= delta
	if _tiempo <= 0.0:
		_reaparecer()


func _reaparecer() -> void:
	felipe.global_position = felipe.punto_reaparicion
	felipe.velocity = Vector2.ZERO
	felipe.cambiar_estado(Felipe.Estado.SUELO)
	felipe.sprite.play("quieto")
	felipe.vida.restante_invulnerable = Felipe.TIEMPO_INVULNERABLE
	felipe.salud.volver()
