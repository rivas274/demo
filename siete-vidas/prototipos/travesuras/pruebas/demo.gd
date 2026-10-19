# PROTOTIPO: no es código del juego.
# Pregunta (v2): si cada travesura es un objetivo con nombre y recompensa útil (la Agenda de Su Majestad), ¿el jugador busca y planea travesuras en vez de romper al azar?
# Fecha: 2026-10-18
extends "res://pruebas/comun.gd"
## Bot de demostración v2: completa la Agenda de Su Majestad (7, incluidas las 3 secretas) con los botones
## de una persona, abre la agenda con Tab un par de veces y termina en el resumen. v2b: usa el rascador sin
## público (queja y garras afiladas), hace el CRÍTICO al sofá, gana un perdón con público y cumple la
## secreta nueva (arañar el sofá junto al rascador con Valeria mirando).
##   xvfb-run -a godot --path . --rendering-driver opengl3 --write-movie c.png --fixed-fps 30 --script res://pruebas/demo.gd
## También corre sin pantalla: godot --headless --path . --fixed-fps 60 --script res://pruebas/demo.gd


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	await cargar()
	await segundos(1.0)
	# 0. Mirar la agenda antes de empezar (como un jugador nuevo).
	paso("0")
	await ver_agenda(3.2)
	# 1. Rascador nuevo, sin público: Felipe se queja, pero las garras quedan afiladas.
	paso("1")
	await ir_a(254)
	await mirar(-1)
	await tocar("accion")
	await segundos(1.0)
	# Con las garras afiladas, al sofá nuevo: el primer arañazo es ¡CRÍTICO! y rompe el plástico.
	await ir_a(232)
	await saltar_a(100, true)
	await ir_a(100)
	await mirar(-1)
	await tocar("accion")
	await segundos(1.4)
	await recoger_todo()
	# 2. Llamar a Valeria con maullidos y ronronear para que perdone (perdón 1, foto con flash).
	paso("2")
	for i in 4:
		if sala.valeria.estado != Valeria.Estado.FUERA:
			break
		await tocar("maullar")
		await segundos(1.4)
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await segundos(1.6)
	await ronronear_a_valeria()
	await recoger_todo()
	# 3. De buenas, se sienta a ver su serie: tirar el control del brazo del sofá.
	paso("3")
	await hasta(func() -> bool: return sala.valeria.viendo_tele(), 600)
	await segundos(1.6)
	await ir_al_asiento(165)
	await mirar(1)
	await tocar("accion")
	await segundos(1.5)
	# Se para a regañar: en vez de ronronear, función en el rascador delante de ella (perdón 2).
	await hasta(func() -> bool: return sala.valeria.presente(), 300)
	await segundos(0.8)
	await saltar_a(256, false)
	await ir_a(254)
	await mirar(-1)
	await tocar("accion")
	await segundos(2.5)
	await recoger_todo()
	await hasta(func() -> bool: return not sala.hud.ocupado(), 400)
	# 3b. Secreta nueva: con Valeria mirando hacia el rascador, arañar el sofá pegado a él.
	paso("3b")
	await hasta(func() -> bool: return sala.valeria.viendo_tele(), 600)
	await segundos(1.0)
	await ir_a(220)
	await mirar(-1)
	await tocar("accion")
	# Como un jugador, mira la reacción completa (Valeria, la frase de Felipe y la foto con flash).
	await segundos(7.5)
	await recoger_todo()
	await hasta(func() -> bool: return not sala.hud.ocupado(), 400)
	# 4. La persiana subió: saltar al alféizar por el calcetín.
	paso("4")
	await ir_al_asiento(110)
	await saltar_a(SalaProto.CALCETIN_ALFEIZAR_X, true)
	await ir_a(SalaProto.CALCETIN_ALFEIZAR_X)
	await segundos(1.0)
	await ver_agenda(2.6)
	# 5. Bajar y bufarle a la aspiradora que duerme bajo la mesa (secreta).
	paso("5")
	await saltar_a(150, false)
	await saltar_a(250, false)
	await ir_a(240)
	await mirar(1)
	await tocar("intimidar")
	await hasta(func() -> bool: return sala.aspiradora.estado == Aspiradora.Estado.VOLVIENDO, 300)
	await segundos(0.4)
	await recoger_todo()
	# 6. Florero heredado: mesa, repisa y manotazo. La foto vergonzosa cae flotando.
	paso("6")
	await ir_a(225)
	await saltar_a(290, true)
	await ir_a(330)
	await saltar_a(420, true)
	await ir_a(434)
	await mirar(1)
	# Espera a que Valeria no esté cruzando bajo la repisa (si no, el florero le cae encima).
	await hasta(func() -> bool: return sala.valeria.estado != Valeria.Estado.SALIENDO, 600)
	await tocar("accion")
	await segundos(2.0)
	await recoger_todo()
	await ver_agenda(2.6)
	# 7. Tirarle el vaso encima a Valeria (secreta): esperar a que esté libre, llamarla con un maullido
	#    desde la mesa y, con ella al lado, manotazo al vaso.
	paso("7")
	if not sala.agenda.esta_cumplida("encima"):
		await tirar_vaso_a_valeria()
	# 8. Agenda completa: el resumen sale solo cuando no queda nada por recoger.
	paso("8")
	await recoger_todo()
	await hasta(func() -> bool: return is_instance_valid(sala.resumen) and sala.resumen.terminado, 900)
	await segundos(4.0)
	print("--- Fin de la demo: %.1f s, agenda %d/%d, secretas %d/%d, calcetines %d, snacks %d, fotos %d, perdones %d ---" % [cuadros / 60.0, sala.agenda.cumplidas(), sala.agenda.total(), sala.agenda.secretas_cumplidas(), sala.agenda.total_secretas(), sala.hud.calcetines, sala.hud.snacks, sala.hud.fotos, sala.perdones])
	quit(0)


func tirar_vaso_a_valeria() -> void:
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 1200)
	await ir_a(225)
	await saltar_a(290, true)
	await ir_a(306)
	await mirar(1)
	for i in 4:
		if sala.valeria.estado != Valeria.Estado.FUERA:
			break
		await tocar("maullar")
		await segundos(1.4)
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await hasta(func() -> bool: return absf(sala.valeria.position.x - felipe.global_position.x) < 75.0, 120)
	await ir_a(306)
	await mirar(1)
	await tocar("accion")
	await segundos(1.5)
	await recoger_todo()
