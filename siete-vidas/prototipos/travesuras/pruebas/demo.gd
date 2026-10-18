# PROTOTIPO: no es código del juego.
# Pregunta: ¿hacer travesuras de gato con la voz de Felipe y una respuesta épica es divertido por sí solo?
# Fecha: 2026-10-18
extends "res://pruebas/comun.gd"
## Bot de demostración: juega todas las acciones en unos 80 s con los botones de una persona.
##   xvfb-run -a godot --path . --rendering-driver opengl3 --write-movie c.png --fixed-fps 30 --script res://pruebas/demo.gd
## También corre sin pantalla: godot --headless --path . --fixed-fps 60 --script res://pruebas/demo.gd


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	await cargar()
	await segundos(1.2)
	# 1. Sofá: subir, arañar el respaldo y tirar el control del brazo.
	await saltar_a(90, true)
	await ir_a(90)
	await mirar(-1)
	await tocar("accion")
	await segundos(1.6)
	await ir_a(165)
	await tocar("accion")
	await segundos(1.6)
	# Bajar y patear el control que quedó en el piso.
	await saltar_a(255, false)
	await ir_a(sala.control.position.x - 30.0)
	await mirar(1)
	await tocar("accion")
	await segundos(1.0)
	# 2. Llega Valeria: ronronear cerca de ella hasta que perdona; comer el snack.
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await segundos(1.0)
	await ir_a(sala.valeria.position.x - 55.0)
	await mantener("ronronear", 1.6)
	await segundos(0.8)
	if is_instance_valid(sala.snack):
		await ir_a(sala.snack.position.x - 26.0)
		await mirar(1)
		await tocar("accion")
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 600)
	await segundos(1.0)
	# 3. Mesa: tirar el vaso. Valeria viene; subir a la repisa y tirar el florero en su cara.
	await ir_a(225)
	await saltar_a(290, true)
	await ir_a(312)
	await mirar(1)
	await tocar("accion")
	await segundos(2.0)
	await ir_a(360)
	await saltar_a(420, true)
	await ir_a(442)
	await hasta(func() -> bool: return sala.valeria.presente(), 400)
	await segundos(0.6)
	await mirar(1)
	await tocar("accion")
	await segundos(1.0)
	# Saltarse una frase (Enter) para mostrar que se puede.
	await tocar("saltar_dialogo")
	# No ronronea: Valeria persigue desde abajo, se rinde y se va (y lo repone todo).
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 900)
	await segundos(1.5)
	# 4. Plato: bajar, comer dos veces, maullar e intimidar; Valeria viene y se perdona otra vez.
	await ir_a(532)
	await esperar(30)
	await ir_a(436)
	await mirar(1)
	await tocar("accion")
	await segundos(1.3)
	await tocar("accion")
	await segundos(1.6)
	await mirar(-1)
	await tocar("maullar")
	await segundos(1.6)
	await tocar("intimidar")
	await segundos(2.0)
	await tocar("maullar")
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await segundos(0.8)
	await tocar("intimidar")
	await segundos(1.4)
	await ir_a(sala.valeria.position.x + (55.0 if felipe.global_position.x > sala.valeria.position.x else -55.0))
	await mantener("ronronear", 1.6)
	await segundos(0.8)
	if is_instance_valid(sala.snack):
		await ir_a(sala.snack.position.x + (26.0 if felipe.global_position.x > sala.snack.position.x else -26.0))
		await mirar(signf(sala.snack.position.x - felipe.global_position.x))
		await tocar("accion")
	await hasta(func() -> bool: return sala.valeria.estado == Valeria.Estado.FUERA, 600)
	# 5. Otra vez el vaso (repuesto): la travesura se repite; esta vez espera a Valeria abajo y ronronea.
	await ir_a(230)
	await saltar_a(290, true)
	await ir_a(312)
	await mirar(1)
	await tocar("accion")
	await segundos(1.2)
	await ir_a(262)
	await saltar_a(215, false)
	await hasta(func() -> bool: return sala.valeria.presente(), 600)
	await segundos(0.5)
	await ir_a(sala.valeria.position.x + (55.0 if felipe.global_position.x > sala.valeria.position.x else -55.0))
	await mantener("ronronear", 1.6)
	await segundos(0.8)
	if is_instance_valid(sala.snack):
		await ir_a(sala.snack.position.x + (26.0 if felipe.global_position.x > sala.snack.position.x else -26.0))
		await mirar(signf(sala.snack.position.x - felipe.global_position.x))
		await tocar("accion")
	await segundos(2.0)
	await mirar(1)
	await tocar("maullar")
	await segundos(2.5)
	print("--- Fin de la demo: %.1f s, caos %d, %d eventos ---" % [cuadros / 60.0, sala.jugo.caos, sala.registro.size()])
	quit(0)
