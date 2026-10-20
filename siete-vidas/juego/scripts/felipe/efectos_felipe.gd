class_name EfectosFelipe
extends RefCounted
## Efectos de caricatura de Felipe: estirar y aplastar (siempre dentro de ±8 %, Felipe.DEFORMACION_MAXIMA), inclinar,
## el aterrizaje con las patas delanteras primero, el polvo que crece con la caída y la estela de imágenes fantasma.
## Es una parte de Felipe (felipe.efectos): no decide nada del movimiento ni de los estados, solo cómo se ve. Hay un solo
## tween de efectos y se mata antes de crear otro, o dos tweens pelean por `scale` y Felipe tiembla (godot-felipe §5).

## Polvo al aterrizar: los granos y su empuje crecen con la velocidad de caída (al cubo: un saltito levanta poco, una
## caída desde lo alto levanta una nube).
const POLVO_ATERRIZAJE_MIN := 8
const POLVO_ATERRIZAJE_MAX := 28
const EMPUJE_POLVO_MAXIMO := 1.8

var felipe: Felipe
## El tween de efectos (estirar, inclinar, aterrizar).
var tween: Tween
## Velocidad y tamaño de los granos de polvo del dibujo (mínimo, máximo), para escalarlos según el golpe.
var _velocidad_polvo := Vector2.ZERO
var _tamano_polvo := Vector2.ONE
var _tiempo_estela := 0.0


func _init(de: Felipe) -> void:
	felipe = de
	_velocidad_polvo = Vector2(de.polvo.initial_velocity_min, de.polvo.initial_velocity_max)
	_tamano_polvo = Vector2(de.polvo.scale_amount_min, de.polvo.scale_amount_max)


## Tamaño normal del dibujo (incluye ESCALA_SPRITE): toda deformación se multiplica por esto, nunca por 1.
func escala_base() -> Vector2:
	return Vector2.ONE * Felipe.ESCALA_SPRITE


## Corta el efecto en curso (antes de otro, o al cambiar de pose).
func detener() -> void:
	if tween:
		tween.kill()


func corriendo() -> bool:
	return tween != null and tween.is_running()


func estirar(forma: Vector2, duracion: float) -> void:
	detener()
	var base := escala_base()
	tween = felipe.create_tween()
	forma = forma.clamp(Vector2.ONE * (1.0 - Felipe.DEFORMACION_MAXIMA), Vector2.ONE * (1.0 + Felipe.DEFORMACION_MAXIMA))
	tween.tween_property(felipe.sprite, "scale", base * forma, duracion * 0.3)
	tween.tween_property(felipe.sprite, "scale", base, duracion * 0.7)


func inclinar(angulo: float, duracion: float) -> void:
	detener()
	tween = felipe.create_tween()
	tween.tween_property(felipe.sprite, "rotation", angulo * felipe.mirando, duracion * 0.5)
	tween.tween_property(felipe.sprite, "rotation", 0.0, duracion * 0.5)


## Un gato aterriza primero con las patas delanteras: llega inclinado con la nariz hacia abajo, se endereza sobre ellas
## y después se aplasta con un rebote. `fuerza` va de 0 a 1 (velocidad de caída / caída máxima).
func aterrizar(fuerza: float) -> void:
	if fuerza > 0.25:
		soltar_polvo(polvo_al_aterrizar(fuerza), lerpf(1.0, EMPUJE_POLVO_MAXIMO, pow(fuerza, 3.0)))
	detener()
	tween = felipe.create_tween()
	tween.tween_property(felipe.sprite, "rotation", 0.0, 0.08).from(felipe.sprite.rotation)
	var base := escala_base()
	tween.tween_property(felipe.sprite, "scale", base * Vector2(1.0 + Felipe.DEFORMACION_MAXIMA * fuerza, 1.0 - Felipe.DEFORMACION_MAXIMA * fuerza), 0.05)
	tween.tween_property(felipe.sprite, "scale", base, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Granos de polvo al aterrizar con esta fuerza (0 a 1: velocidad de caída / caida_maxima).
func polvo_al_aterrizar(fuerza: float) -> int:
	return int(round(lerpf(POLVO_ATERRIZAJE_MIN, POLVO_ATERRIZAJE_MAX, pow(clampf(fuerza, 0.0, 1.0), 3.0))))


func soltar_polvo(cantidad: int, empuje := 1.0) -> void:
	var polvo := felipe.polvo
	polvo.amount = maxi(cantidad, 1)
	polvo.initial_velocity_min = _velocidad_polvo.x * empuje
	polvo.initial_velocity_max = _velocidad_polvo.y * empuje
	# Granos un poco más grandes en los golpes fuertes (hasta 1,34 veces con el empuje máximo).
	polvo.scale_amount_min = _tamano_polvo.x * sqrt(empuje)
	polvo.scale_amount_max = _tamano_polvo.y * sqrt(empuje)
	polvo.restart()
	polvo.emitting = true


## Estela de imágenes fantasma mientras está en el aire o haciendo Zoomies.
func actualizar_estela(delta: float) -> void:
	if felipe.is_on_floor() and felipe.estado != Felipe.Estado.ZOOMIES:
		return
	_tiempo_estela += delta
	if _tiempo_estela < 0.035:
		return
	_tiempo_estela = 0.0
	var sprite := felipe.sprite
	var fantasma := Sprite2D.new()
	fantasma.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	fantasma.global_position = sprite.global_position
	fantasma.global_rotation = sprite.global_rotation
	fantasma.scale = sprite.scale
	fantasma.flip_h = sprite.flip_h
	fantasma.modulate.a = 0.28
	fantasma.z_index = Capas.PERSONAJES
	felipe.get_parent().add_child(fantasma)
	var desvanecer := fantasma.create_tween()
	desvanecer.tween_property(fantasma, "modulate:a", 0.0, 0.22)
	desvanecer.tween_callback(fantasma.queue_free)
