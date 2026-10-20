class_name TreparFelipe
extends RefCounted
## Trepar tela (cortinas; se gana con Afilar Garras, apagado en el nivel 1): dentro de una zona trepable, mantener arriba
## sube y abajo baja; saltar se suelta. Al llegar arriba da un saltito para pasar al otro lado. Es una postura paralela a
## los estados (felipe.trepando) y una parte de Felipe (felipe.trepar). Animación "trepar" desde Felipe A (quieto en la
## cortina, se queda en su primer cuadro).

## Estados en que no se puede empezar a trepar.
const OCUPADO := [Felipe.Estado.DESMAYADO, Felipe.Estado.OCIO, Felipe.Estado.ZARPAZO, Felipe.Estado.COMIENDO, Felipe.Estado.ARANANDO, Felipe.Estado.MAULLANDO, Felipe.Estado.RONRONEANDO]

var felipe: Felipe
var _tiempo_sin_trepar := 0.0


func _init(de: Felipe) -> void:
	felipe = de


## Devuelve true si este cuadro estuvo trepando (Felipe ya se movió: no hace nada más).
func actualizar(direccion: float) -> bool:
	_tiempo_sin_trepar = maxf(0.0, _tiempo_sin_trepar - felipe.get_physics_process_delta_time())
	var zona := _zona()
	if not felipe.puede_trepar or zona == Rect2() or felipe.agachado or felipe.estado in OCUPADO:
		felipe.trepando = false
		return false
	if not felipe.trepando:
		if _tiempo_sin_trepar > 0.0 or not Input.is_action_pressed("mover_arriba"):
			return false
		felipe.trepando = true
	if Input.is_action_just_pressed("saltar"):
		felipe.trepando = false
		felipe.saltar(felipe.velocidad_salto)
		return false
	var vertical := Input.get_axis("mover_arriba", "agacharse")
	if direccion != 0.0:
		felipe.mirando = signf(direccion)
	# Colgado de la cortina se mantiene centrado en ella (así pasa limpio por huecos angostos).
	felipe.velocity = Vector2((zona.get_center().x - felipe.global_position.x) * 8.0, vertical * felipe.velocidad_trepar)
	felipe.cambiar_estado(Felipe.Estado.AIRE)
	felipe.doble_salto_disponible = true
	felipe.move_and_slide()
	if felipe.global_position.y - 20.0 < zona.position.y + 4.0:
		# Llegó arriba: se pasa hacia el lado al que mira y se suelta un momento de la cortina.
		felipe.trepando = false
		_tiempo_sin_trepar = 0.5
		felipe.move_and_collide(Vector2(felipe.mirando * 40.0, 0.0))
		felipe.velocity = Vector2(felipe.mirando * 60.0, -120.0)
	elif felipe.is_on_floor() and vertical > 0.0:
		felipe.trepando = false
	felipe.sprite.flip_h = felipe.mirando < 0.0
	if vertical != 0.0:
		felipe.animador.reproducir("trepar")
	else:
		felipe.animador.poner_cuadro("trepar", 0)
	return true


func _zona() -> Rect2:
	for zona in felipe.zonas_trepables:
		if zona.grow_individual(12, 0, 12, 0).has_point(felipe.global_position + Vector2(0, -20)):
			return zona
	return Rect2()
