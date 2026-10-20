class_name AnimadorFelipe
extends RefCounted
## Qué animación muestra Felipe en cada momento: la elige según su estado (sin cambiarlo), lleva el ritmo del caminar
## con la velocidad (las patas no patinan) y pone las fases del salto con los cuadros de la ficha de concepto. Es una parte
## de Felipe (felipe.animador): la máquina de estados vive en felipe.gd; aquí solo se mira. Las hojas las arma
## AnimacionesFelipe.crear().

## Duración de la transición "agacharse" (4 cuadros a 12 fps), también al pararse.
const DURACION_TRANSICION := 0.33

var felipe: Felipe
var sprite: AnimatedSprite2D
## Segundos que le quedan a la transición de pararse (agacharse al revés).
var _tiempo_levantandose := 0.0


func _init(de: Felipe) -> void:
	felipe = de
	sprite = de.sprite


## Se está parando: la transición de agacharse al revés.
func levantarse() -> void:
	sprite.play_backwards("agacharse")
	_tiempo_levantandose = DURACION_TRANSICION


func actualizar(direccion: float) -> void:
	var estado := felipe.estado
	sprite.flip_h = felipe.mirando < 0.0
	if estado in [Felipe.Estado.ZARPAZO, Felipe.Estado.COMIENDO, Felipe.Estado.OCIO, Felipe.Estado.DESMAYADO, Felipe.Estado.ARANANDO, Felipe.Estado.MAULLANDO, Felipe.Estado.SUBIENDO_ESCALON, Felipe.Estado.RONRONEANDO]:
		# La escalera fija su propio ritmo (Felipe.subir_escalon); lo demás va a su velocidad normal.
		if estado != Felipe.Estado.SUBIENDO_ESCALON:
			sprite.speed_scale = 1.0
		return
	_sincronizar_pasos()
	if estado == Felipe.Estado.ZOOMIES:
		# Al derrapar, EstadoZoomies pone «derrape» y se queda hasta salir del estado.
		if sprite.animation != &"derrape":
			reproducir("correr")
	elif estado == Felipe.Estado.ATERRIZANDO:
		# Primero tocan las delanteras, después baja la parte de atrás y se aplasta.
		if felipe.tiempo_aterrizando > 0.16:
			poner_cuadro("caer", Felipe.CUADRO_CONTACTO)
		elif felipe.tiempo_aterrizando > 0.08:
			poner_cuadro("saltar", Felipe.CUADRO_ATERRIZAJE)
		else:
			poner_cuadro("saltar", Felipe.CUADRO_ASENTARSE)
	elif not felipe.is_on_floor():
		_animar_aire()
	elif felipe.agachado:
		# Primero termina de agacharse; después gatea, o se queda pegado al piso en el primer cuadro.
		if sprite.animation == "agacharse" and sprite.is_playing():
			pass
		elif direccion != 0.0:
			reproducir("gatear")
		else:
			poner_cuadro("gatear", 0)
	elif _tiempo_levantandose > 0.0:
		# Se está parando: la transición de agacharse al revés.
		_tiempo_levantandose -= felipe.get_physics_process_delta_time()
	elif absf(felipe.velocity.x) > felipe.velocidad_caminar + 5.0:
		reproducir("correr")
	elif direccion != 0.0:
		reproducir("caminar")
	else:
		reproducir("quieto")


## Las patas no patinan (G9 de la revisión 3): caminando o corriendo, la animación va al ritmo de la velocidad
## horizontal. Cada cuadro de la hoja adelanta el pie apoyado AnimacionesFelipe.PASO px (medido); a velocidad v hay que
## mostrar v / PASO cuadros por segundo, con tope en AnimacionesFelipe.FPS_MAXIMO (más rápido se ve borroso). Con el
## tope, el pie se desliza menos de 2 px por cuadro (antes, ~10). Además el cuerpo sube 1 px en el paso.
func _sincronizar_pasos() -> void:
	var nombre := sprite.animation
	if nombre in AnimacionesFelipe.PASO and sprite.is_playing() and felipe.is_on_floor():
		var fps := minf(absf(felipe.velocity.x) / float(AnimacionesFelipe.PASO[nombre]), AnimacionesFelipe.FPS_MAXIMO)
		sprite.speed_scale = maxf(fps, 2.0) / sprite.sprite_frames.get_animation_speed(nombre)
		sprite.offset.y = -2.0 if sprite.frame in [1, 2, 5, 6] else 0.0
	else:
		sprite.speed_scale = 1.0
		sprite.offset.y = 0.0


## Fases del salto: despegue agachado, subida estirada, pausa arriba con las patas recogidas y caída en picada con las
## patas delanteras estiradas hacia el suelo (la pose "caer" ya viene inclinada, así que no se rota el sprite).
func _animar_aire() -> void:
	if felipe.tiempo_desde_salto < 0.06:
		poner_cuadro("saltar", Felipe.CUADRO_AGACHADO)
	elif felipe.velocity.y < -85.0:
		poner_cuadro("saltar", Felipe.CUADRO_SUBIENDO)
	elif felipe.velocity.y < 85.0:
		poner_cuadro("saltar", Felipe.CUADRO_ARRIBA)
	else:
		poner_cuadro("caer", Felipe.CUADRO_CAYENDO)
		# La caída manda sobre cualquier giro anterior (por ejemplo, el del doble salto).
		if felipe.efectos.corriendo():
			felipe.efectos.detener()
			sprite.scale = Vector2.ONE * Felipe.ESCALA_SPRITE
		sprite.rotation = lerpf(sprite.rotation, 0.0, 0.3)


## Una pose suelta (un cuadro quieto de una hoja).
func poner_cuadro(animacion: String, cuadro: int) -> void:
	sprite.stop()
	sprite.animation = animacion
	sprite.frame = cuadro


## Reproduce sin reiniciar si ya estaba puesta (no llamar play() cada cuadro).
func reproducir(nombre: String) -> void:
	if sprite.animation != nombre or not sprite.is_playing():
		sprite.play(nombre)


## Reproduce una animación desde el cuadro 0 aunque ya estuviera puesta (para repetir una acción).
func reiniciar(nombre: String) -> void:
	sprite.stop()
	sprite.animation = nombre
	sprite.frame = 0
	sprite.play(nombre)
