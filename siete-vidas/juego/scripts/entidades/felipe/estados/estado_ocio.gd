class_name EstadoOcio
extends EstadoFelipe
## OCIO: tras unos segundos quieto y sin tocar nada, se acicala, juega con estambre, da vueltas persiguiéndose la cola
## o se sienta.
## Cualquier acción lo corta (Felipe.ACCIONES). La bola de estambre es un objeto aparte (la animación es solo Felipe)
## que rueda frente a él.

var _tiempo := 0.0
var _estambre: Sprite2D


## datos: {"nombre": "acicalarse" | "jugar" | "vueltas" | "sentarse"}. «sentarse» es la transición y sigue con el bucle
## «sentado» (la misma hoja desde Felipe A).
func entrar(datos := {}) -> void:
	var nombre: String = datos.get("nombre", "acicalarse")
	var sprite := felipe.sprite
	felipe.efectos.detener()
	sprite.rotation = 0.0
	sprite.scale = felipe.efectos.escala_base()
	sprite.position = felipe.posicion_sprite
	sprite.play(nombre)
	if nombre == "jugar":
		_estambre = Sprite2D.new()
		_estambre.name = "Estambre"
		_estambre.texture = Felipe.BOLA_ESTAMBRE
		_estambre.scale = Vector2.ONE * Felipe.ESCALA_SPRITE
		felipe.add_child(_estambre)
		_rodar_estambre()
	var frames := sprite.sprite_frames
	if nombre == "sentarse":
		if not sprite.animation_finished.is_connected(_quedar_sentado):
			sprite.animation_finished.connect(_quedar_sentado)
		_tiempo = _duracion(frames, "sentarse") + _duracion(frames, "sentado") * Felipe.OCIO[nombre]
		return
	_tiempo = _duracion(frames, nombre) * Felipe.OCIO[nombre]


func _duracion(frames: SpriteFrames, nombre: String) -> float:
	return frames.get_frame_count(nombre) / frames.get_animation_speed(nombre)


## Terminó de sentarse: queda sentado en bucle.
func _quedar_sentado() -> void:
	if felipe.estado == Felipe.Estado.OCIO and felipe.sprite.animation == &"sentarse":
		felipe.sprite.play("sentado")


func salir() -> void:
	if felipe.sprite.animation_finished.is_connected(_quedar_sentado):
		felipe.sprite.animation_finished.disconnect(_quedar_sentado)
	felipe.reiniciar_espera_ocio()
	felipe.sprite.scale = felipe.efectos.escala_base()
	felipe.sprite.position = felipe.posicion_sprite
	felipe.sprite.play("quieto")
	if _estambre:
		felipe.remove_child(_estambre)
		_estambre.queue_free()
		_estambre = null


## Antes de todo lo demás del cuadro: cuenta el tiempo y termina si toca algo, se acabó o ya no está en el piso.
func seguir(delta: float, tocando: bool) -> void:
	_tiempo -= delta
	_rodar_estambre()
	if tocando or _tiempo <= 0.0 or not felipe.is_on_floor():
		felipe.cambiar_estado(Felipe.Estado.SUELO if felipe.is_on_floor() else Felipe.Estado.AIRE)


func fisica(delta: float, _direccion: float) -> void:
	felipe.frenar(delta)
	felipe.aplicar_gravedad(delta)


## El estambre va y viene frente a Felipe al ritmo de los golpes de la pata, girando al rodar.
func _rodar_estambre() -> void:
	if not _estambre:
		return
	var vaiven := sin(Time.get_ticks_msec() * 0.006) * 6.0
	_estambre.position = Vector2(felipe.mirando * (Felipe.DISTANCIA_ESTAMBRE + vaiven), -Felipe.BOLA_ESTAMBRE.get_height() * 0.3)
	_estambre.rotation = vaiven / 7.0
