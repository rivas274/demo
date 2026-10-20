class_name FinalBalcon
extends Node
## El balcón del nivel 1: alivio y final (M5, G1). Felipe sube por la maceta a la baranda (en el tramo libre de
## macetas), se queda quieto y se acicala mientras la cámara se abre a la ciudad (no hay animación de sentarse todavía:
## M6). Al saltar (salto real): cámara lenta con la cámara pegada a él, que baja hasta el toldo de la panadería de abajo;
## aterriza a la vista con el polvo grande y recién ahí sale el cartel "PODER NUEVO · CAER DE PIE", sin taparlo, y el
## resumen del día.

## Se sentó en la baranda; saltó.
var sentado_en_baranda := false
var salto_final := false
var _tiempo_baranda := 0.0
var _tiempo_cayendo := 0.0
var _aterrizo_final := false
var _toldo: StaticBody2D

var guion: GuionNivel1
var nivel: Nivel
var felipe: Felipe:
	get:
		return nivel.felipe
var travesuras: Travesuras:
	get:
		return nivel.travesuras
var habitacion: String:
	get:
		return nivel.habitacion


func _init(de: GuionNivel1) -> void:
	guion = de
	nivel = de.nivel
	name = "Final del balcon"


func sonar(nombre: String, tono := 1.0) -> void:
	nivel.sonar(nombre, tono)


func _decir(evento: String, urgente := false) -> void:
	nivel.decir(evento, urgente)


## Felipe sube por la maceta a la baranda (en el tramo libre de macetas), se queda quieto y se acicala mientras la
## cámara se abre a la ciudad, y suspira (no hay animación de sentarse todavía: M6). Al saltar (salto real): cámara
## lenta con la cámara pegada a él, que baja hasta el toldo de la panadería de abajo; aterriza a la vista con el
## polvo grande y recién ahí sale el cartel "PODER NUEVO · CAER DE PIE", sin taparlo, y el resumen del día.
func cada_cuadro(delta: float) -> void:
	if habitacion != "balcon":
		return
	if salto_final:
		_actualizar_caida(delta)
		return
	var en_baranda := felipe.is_on_floor() and absf(felipe.global_position.y - (Nivel1.SUELO - 89.0)) < 3.0
	if not sentado_en_baranda:
		_tiempo_baranda = _tiempo_baranda + delta if en_baranda and absf(felipe.velocity.x) < 1.0 else 0.0
		if _tiempo_baranda > 0.3:
			sentado_en_baranda = true
			_decir("balcon", true)
			felipe.acicalarse()
			var camara: Camera2D = felipe.get_node("Camara")
			var abrir := create_tween()
			abrir.tween_property(camara, "offset", Vector2(0, -70), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		return
	if not felipe.is_on_floor() and felipe.velocity.y < 0.0 and felipe.global_position.y < Nivel1.SUELO - 89.0:
		_saltar_del_balcon()


func _saltar_del_balcon() -> void:
	salto_final = true
	_tiempo_cayendo = 0.0
	# Sale por encima de la baranda: no lo detiene nada hasta pasar el piso del balcón.
	felipe.set_collision_mask_value(1, false)
	felipe.set_collision_mask_value(Felipe.CAPA_ATRAVESABLE, false)
	felipe.tiene_caer_de_pie = true
	# El toldo de la panadería de abajo (con paredes a los lados para que nadie se salga del cuadro).
	_toldo = StaticBody2D.new()
	_toldo.name = "Toldo de la panaderia"
	for rect: Rect2 in [Nivel1.TOLDO, Rect2(Nivel1.TOLDO.position.x - 20, Nivel1.ALTO, 20, Nivel1.CAIDA_BALCON + 60), Rect2(Nivel1.TOLDO.end.x, Nivel1.ALTO, 20, Nivel1.CAIDA_BALCON + 60)]:
		var forma := CollisionShape2D.new()
		var caja := RectangleShape2D.new()
		caja.size = rect.size
		forma.shape = caja
		forma.position = rect.get_center()
		_toldo.add_child(forma)
	nivel.add_child(_toldo)
	# La cámara lo sigue hacia abajo: se abre el límite de abajo del balcón y vuelve a centrarse en él.
	var camara: Camera2D = felipe.get_node("Camara")
	camara.limit_bottom = int(Nivel1.ALTO + Nivel1.CAIDA_BALCON)
	var bajar := create_tween()
	bajar.tween_property(camara, "offset", Vector2(0, 20), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	Engine.time_scale = 0.4
	felipe.aterrizo.connect(_aterrizar_en_el_toldo, CONNECT_ONE_SHOT)


func _actualizar_caida(delta: float) -> void:
	if _aterrizo_final:
		return
	_tiempo_cayendo += delta
	# Pasado el piso del balcón, vuelve a chocar (solo queda el toldo abajo).
	if felipe.global_position.y > Nivel1.ALTO + 62.0 and not felipe.get_collision_mask_value(1):
		felipe.set_collision_mask_value(1, true)
	# Seguro: si algo falla, el final llega igual.
	if _tiempo_cayendo > 2.5:
		_aterrizar_en_el_toldo(1.0)


func _aterrizar_en_el_toldo(_fuerza: float) -> void:
	if _aterrizo_final:
		return
	_aterrizo_final = true
	Engine.time_scale = 1.0
	travesuras.jugo.sacudir(0.2, 0.6)
	sonar("golpe")
	# El cartel sale después de verlo aterrizar y a una altura que no lo tapa.
	await get_tree().create_timer(0.35).timeout
	travesuras.hud.cartel("CARTEL_PODER_NUEVO", "CARTEL_CAER_DE_PIE", "CARTEL_SIEMPRE_ATERRIZAS_CON_ESTILO", false)
	nivel.desbloquear_logro("LOGRO_CAER_DE_PIE")
	_decir("aterrice", true)
	await get_tree().create_timer(1.2).timeout
	nivel.terminado = true
	felipe.set_physics_process(false)
	await get_tree().create_timer(1.6).timeout
	var resumen := travesuras.mostrar_resumen()
	resumen.cerrado.connect(func() -> void:
		if get_tree().current_scene:
			get_tree().reload_current_scene())
