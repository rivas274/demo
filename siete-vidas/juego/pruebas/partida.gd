extends SceneTree
## Partida completa del nivel 1 v4 jugada por un bot con los mismos botones que una persona (moverse, saltar,
## agacharse, acción, zarpazo y maullar), SIN doble salto, Zoomies ni trepar: título, sala (sofá, rascador con
## Valeria, vaso y perdón), recibidor (zapatero, maullido, popo táctico, llaves, librero y cajas de la mudanza), cocina (tazón,
## ratones, caja, pollo y calcetín del refrigerador), escalera escalón por escalón, pasillo (ensayo de A.S.P.I.,
## láser, puerta entornada), dormitorio (ropa y cajón), pelea con A.S.P.I. y balcón con el resumen del día.
## Siempre por las puertas. Mira la pantalla (el estado del juego) para decidir, como una persona.
## Sirve como prueba de que el nivel se puede terminar y para grabar el video del gameplay:
##   godot --headless --path siete-vidas/juego --fixed-fps 60 --script res://pruebas/partida.gd
##   xvfb-run -a godot --path siete-vidas/juego --rendering-driver opengl3 --write-movie <carpeta>/c.png --fixed-fps 30 --script res://pruebas/partida.gd
## Termina con código 0 si llega al resumen del día con la agenda casi completa (6 de 8 o más) y los 3 calcetines.

const LIMITE_SEGUNDOS := 480.0

var sala: Nivel
## Lo propio del nivel 1 (Valeria, A.S.P.I., la pelea, las cajas...).
var guion: GuionNivel1
var felipe: Felipe
var _cuadros := 0
var _fps := 60.0
var _pasos: Array[String] = []


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	_fps = float(Engine.physics_ticks_per_second)
	sala = load("res://escenas/nivel_1.tscn").instantiate()
	guion = sala.guion
	root.add_child(sala)
	felipe = sala.get_node("Felipe")
	# Título, introducción y la meta.
	await _segundos(1.6)
	await _tocar("ui_accept")
	await _segundos(2.4)
	await _tocar("ui_accept")
	await _segundos(3.6)
	_paso("Título, introducción y meta (sin doble salto: %s, Zoomies: %s, trepar: %s)" % [felipe.tiene_doble_salto, felipe.tiene_zoomies, felipe.puede_trepar])

	await _sala()
	await _recibidor()
	await _cocina()
	await _librero_y_escalera()
	await _pasillo()
	await _dormitorio()
	await _pelea()
	await _balcon()

	var agenda := sala.travesuras.agenda
	var resumen := _resumen()
	var termino := resumen != null and agenda.cumplidas() >= 6 and sala.calcetines >= 3
	_paso("Resumen del día" if resumen else "No llegó al resumen")
	print("Agenda %d de %d (secretas %d) · calcetines %d · fotos %d · snacks %d · perdones %d · logros: %s · corazones %d · vidas %d · %.0f s" % [
		agenda.cumplidas(), agenda.total(), agenda.secretas_cumplidas(), sala.calcetines, sala.travesuras.recompensas.fotos,
		felipe.snacks, sala.travesuras.perdones, ", ".join(sala.logros), felipe.corazones, felipe.vidas, _cuadros / _fps])
	if resumen:
		# Deja ver el resumen y lo cierra (vuelve al título).
		await _segundos_reales(7.0)
		Input.action_press("ui_accept")
		await _segundos_reales(0.2)
		Input.action_release("ui_accept")
		await _segundos_reales(0.5)
	quit(0 if termino else 1)


# --- Cuartos ------------------------------------------------------------------------------------------------

func _sala() -> void:
	var valeria := guion.valeria
	# Arañar el sofá delante de Valeria: lo deja frente al rascador.
	await _ir_a(330)
	await _tocar("interactuar")
	await _hasta(func() -> bool: return absf(felipe.global_position.x - (Nivel1.RASCADOR_X - 46.0)) < 8.0, 3.0)
	await _segundos(1.4)
	_paso("Araña el sofá delante de Valeria: lo deja en el rascador")
	# El rascador con público: snack y Valeria graba de espaldas al sofá.
	await _ir_a(Nivel1.RASCADOR_X - 40.0)
	await _tocar("interactuar")
	await _hasta(func() -> bool: return valeria.actividad == Valeria.Actividad.GRABANDO, 4.0)
	_paso("Rascador con público: Valeria graba (snacks %d)" % felipe.snacks)
	# Garras afiladas: el sofá, crítico.
	await _ir_a(300)
	await _tocar("interactuar")
	await _hasta(func() -> bool: return guion.sofa.esta_roto, 2.0)
	_paso("Rompe el plástico del sofá (crítico)" if guion.sofa.esta_roto else "No rompió el plástico")
	await _segundos(1.0)
	await _ir_a(372)
	await _segundos(0.6)
	_paso("Calcetín del sofá (%d)" % sala.calcetines)
	# Espera a que Valeria vuelva a su serie y sube a la mesa por la silla.
	await _hasta(func() -> bool: return valeria.actividad == Valeria.Actividad.SENTADA, 10.0)
	await _ir_a(700)
	await _subir_a(713, Nivel1.SUELO - 55)
	await _subir_a(800, Nivel1.SUELO - 91)
	await _ir_a(884)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _segundos(1.0)
	_paso("Tira el vaso" + (" (logro)" if "La Gravedad Funciona" in sala.logros else ""))
	await _bajar()
	await _hasta(func() -> bool: return valeria.actividad == Valeria.Actividad.REGANANDO, 6.0)
	# Frotarse contra Valeria enojada: perdón.
	for intento in 4:
		if valeria.actividad != Valeria.Actividad.REGANANDO:
			break
		var lado := signf(felipe.global_position.x - valeria.global_position.x)
		await _ir_a(valeria.global_position.x + (lado if lado != 0.0 else 1.0) * 28.0, 3.0)
		if felipe.objeto_cercano() == valeria:
			await _tocar("interactuar")
			await _segundos(1.4)
	_paso("Se frota contra Valeria: %s" % ("perdón" if sala.travesuras.agenda.esta_cumplida("perdon") else "sin perdón"))
	await _segundos(0.6)
	await _entrar("sala>recibidor")


func _recibidor() -> void:
	# Bajo el zapatero solo se pasa agachado.
	Input.action_press("agacharse")
	await _ir_a(1815, 8.0)
	Input.action_release("agacharse")
	await _segundos(0.4)
	_paso("Pasa agachado bajo el zapatero")
	# Maullar a la puerta de la cocina: Valeria abre.
	# Valeria camina de verdad (sala → puerta → recibidor → puerta de la cocina): se espera a que esté adentro y quieta.
	await _hasta(func() -> bool: return guion.valeria.cuarto == "cocina" and not guion.valeria_en_escena(), 25.0)
	await _ir_a(2060)
	await _tocar("maullar")
	# Ella va a la puerta, la abre y se asoma: se espera la puerta abierta.
	await _hasta(func() -> bool: return not sala.puertas[Nivel1.PUERTA_COCINA].cerrada, 6.0)
	await _segundos(0.6)
	_paso("Maúlla a la puerta de la cocina: %s" % ("abierta" if not sala.puertas[Nivel1.PUERTA_COCINA].cerrada else "cerrada"))
	# Caja de arena: descanso y popo táctico (Valeria sale con mascarilla).
	await _ir_a(1960)
	await _subir_a(1890, Nivel1.SUELO - 45)
	await _segundos(0.6)
	Input.action_press("agacharse")
	await _hasta(func() -> bool: return sala.travesuras.agenda.esta_cumplida("popo"), 3.0)
	Input.action_release("agacharse")
	_paso("Popo táctico en la arena")
	await _segundos(2.4)
	# La foto vergonzosa que se le cayó a Valeria (recompensa del popo) quedó junto a la lámpara.
	var foto := _recogible_en("foto", "recibidor")
	if foto:
		await _ir_a(foto.global_position.x, 3.0)
		var ref: WeakRef = weakref(foto)
		await _hasta(func() -> bool: return ref.get_ref() == null, 1.5)
		await _ir_a(1960, 2.0)
		await _subir_a(1890, Nivel1.SUELO - 45)
	_paso("Recoge la foto del popo (fotos %d)" % sala.travesuras.recompensas.fotos)
	# Desde el borde de la caja, al zapatero: las llaves.
	await _ir_a(1846, 2.0)
	await _subir_a(1770, Nivel1.SUELO - 97)
	await _ir_a(1748)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _segundos(1.2)
	_paso("Tira las llaves")
	await _hasta(func() -> bool: return guion.valeria.cuarto == "cocina" and not guion.valeria_en_escena(), 20.0)
	await _entrar(Nivel1.PUERTA_COCINA)


func _cocina() -> void:
	await _ir_a(2975)
	await _tocar("interactuar")
	await _segundos(1.0)
	_paso("Come del tazón")
	await _cazar_raton(3100, 3320)
	# La caja de cartón: un zarpazo, snack.
	await _ir_a(3300)
	felipe.mirando = 1.0
	await _tocar("zarpazo")
	await _segundos(0.8)
	await _ir_a(3390, 3.0)
	_paso("Rompe la caja de cartón (snacks %d)" % felipe.snacks)
	# Silla → estufa → mesón (cocina v2): el ratón que cuida el microondas, y el pollo en la cara de Valeria.
	await _ir_a(3433)
	await _subir_a(3433, Nivel1.SUELO - 55)
	await _subir_a(3500, Nivel1.SUELO - 109)
	await _ir_a(3800, 6.0)
	await _cazar_raton(3790, 3925)
	# El pollo espera sobre el microondas, fuera de la patrulla del ratón.
	await _ir_a(3905)
	await _subir_a(3950, Nivel1.SUELO - 163)
	await _ir_a(Nivel1.POLLO.x + 30.0)
	felipe.mirando = -1.0
	await _tocar("interactuar")
	await _segundos(1.2)
	_paso("Roba el pollo de Valeria" if sala.travesuras.agenda.esta_cumplida("almuerzo") else "No pudo con el pollo")
	# Microondas → refrigerador: el calcetín.
	await _subir_a(Nivel1.CALCETIN_REFRIGERADOR.x, Nivel1.SUELO - 216)
	await _segundos(0.5)
	_paso("Calcetín del refrigerador (%d)" % sala.calcetines)
	await _ir_a(3900, 4.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	await _ir_a(3600, 6.0)
	await _ir_a(3380, 6.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	await _entrar("cocina<recibidor")


func _librero_y_escalera() -> void:
	# El librero es la escalera del gato: tres repisas de ~50 px y, desde la de arriba, se pasa por encima de las cajas
	# de la mudanza (sólidas: desde el piso no se pasan).
	await _ir_a(2240)
	await _subir_a(2240, Nivel1.SUELO - 48)
	await _subir_a(2240, Nivel1.SUELO - 103)
	await _subir_a(2240, Nivel1.SUELO - 155)
	await _ir_a(2252)
	await _saltar(1.0, INF)
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 2.0, 3.0)
	await _ir_a(Nivel1.CAJAS.end.x + 40.0, 2.0)
	_paso("Pasa las cajas de la mudanza desde el librero (x %.0f)" % felipe.global_position.x)
	# Desde el segundo peldaño («desde arriba»), un manotazo tira la caja de arriba: atajo de vuelta.
	await _subir_a(Nivel1.PELDANO_CAJAS.x, Nivel1.PELDANO_CAJAS.y)
	if felipe.objeto_cercano() == guion.cajas:
		felipe.mirando = -1.0
		await _tocar("interactuar")
		await _segundos(1.4)
	_paso("Tira la caja de arriba (atajo)" if guion.cajas.tirada_ya else "No tiró la caja")
	# Baja del peldaño al piso, al pie de la escalera.
	await _ir_a(Nivel1.ESCALERA_PIE.x + 44.0, 2.0)
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 2.0, 1.5)
	await _entrar(Nivel1.PUERTA_ESCALERA)


func _pasillo() -> void:
	# Baúl → consola: el vaso; sale A.S.P.I. a limpiar y Felipe se aferra.
	await _ir_a(4548)
	await _subir_a(4600, Nivel1.SUELO - 47)
	await _subir_a(4680, Nivel1.SUELO - 97)
	await _ir_a(4762)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _segundos(1.0)
	await _ir_a(4850, 3.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	await _hasta(func() -> bool: return guion.ensayo.paso == EnsayoAspi.Paso.LIMPIA, 10.0)
	Input.action_press("agacharse")
	await _hasta(func() -> bool: return guion.ensayo.paso != EnsayoAspi.Paso.LIMPIA, 6.0)
	Input.action_release("agacharse")
	_paso("Ensayo: A.S.P.I. aspira el vaso y Felipe se aferra")
	await _hasta(func() -> bool: return guion.ensayo.paso == EnsayoAspi.Paso.LISTO, 8.0)
	# El láser: quieto, sin perseguirlo.
	await _ir_a(5190)
	await _hasta(func() -> bool: return sala.travesuras.agenda.esta_cumplida("laser"), 8.0)
	_paso("Ignora el láser (%s)" % ("se apaga" if sala.travesuras.agenda.esta_cumplida("laser") else "no"))
	# La foto vergonzosa se cayó del cajón de la consola: vuelve caminando (el pasillo es 200 px más ancho), pasa
	# agachado bajo la consola y sube por el baúl a buscarla.
	await _ir_a(4830, 4.0)
	Input.action_press("agacharse")
	await _ir_a(4605, 6.0)
	Input.action_release("agacharse")
	await _segundos(0.3)
	await _ir_a(4548)
	await _subir_a(4600, Nivel1.SUELO - 47)
	await _subir_a(4680, Nivel1.SUELO - 97)
	await _ir_a(4715, 2.0)
	await _segundos(0.4)
	_paso("Recoge la foto vergonzosa (fotos %d)" % sala.travesuras.recompensas.fotos)
	await _ir_a(4820, 3.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	# La puerta entornada del dormitorio se abre arañándola.
	await _ir_a(4885)
	await _tocar("interactuar")
	await _segundos(1.0)
	_paso("Araña la puerta entornada")
	await _entrar(Nivel1.PUERTA_DORMITORIO)


func _dormitorio() -> void:
	await _ir_a(5992)
	await _subir_a(5992, Nivel1.SUELO - 53)
	await _subir_a(6050, Nivel1.SUELO - 65)
	await _ir_a(Nivel1.ROPA.x)
	await _tocar("interactuar")
	await _segundos(1.0)
	_paso("Desordena la ropa doblada" if guion.ropa_firmada else "No pudo desordenar la ropa")
	await _ir_a(6206)
	felipe.mirando = 1.0
	await _tocar("interactuar")
	await _segundos(1.5)
	await _subir_a(6272, Nivel1.SUELO - 96)
	await _segundos(0.6)
	_paso("Saquea el cajón (calcetines %d)" % sala.calcetines)
	await _ir_a(6180, 4.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	await _ir_a(6000, 4.0)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
	await _entrar("dormitorio<pasillo")
	await _ir_a(Nivel1.DESCANSOS[1].get_center().x)
	await _segundos(0.5)
	_paso("Descansa en el cojín")
	await _entrar("pasillo>estudio")


## Pelea: la juega `bot_pelea.gd` (ensuciar en las dos islas, esparcir la pelusa, aplastarla con el botón de acción).
func _pelea() -> void:
	await load("res://pruebas/bot_pelea.gd").new(self).jugar()


func _balcon() -> void:
	if felipe.global_position.y < Nivel1.SUELO - 2.0:
		await _bajar()
	await _entrar(Nivel1.PUERTA_BALCON)
	await _ir_a(8186)
	await _subir_a(8226, Nivel1.SUELO - 32)
	await _subir_a(8356, Nivel1.SUELO - 89)
	await _ir_a(8391)
	await _hasta(func() -> bool: return guion.balcon.sentado_en_baranda, 3.0)
	_paso("Se sienta en la baranda y mira la ciudad")
	await _segundos(2.4)
	Input.action_press("mover_derecha")
	Input.action_press("saltar")
	await _segundos(0.25)
	Input.action_release("saltar")
	await _segundos(0.8)
	Input.action_release("mover_derecha")
	_paso("Salta del balcón: Caer de Pie" if felipe.tiene_caer_de_pie else "No saltó")
	await _hasta_real(func() -> bool: return _resumen() != null, 10.0)


# --- Movimiento con los botones -----------------------------------------------------------------------------

## Cruza la puerta con ese nombre (camina hasta ella y aprieta el botón de acción).
func _entrar(nombre: String) -> void:
	var puerta: Puerta = sala.puertas[nombre]
	await _ir_a(puerta.global_position.x)
	await _hasta(func() -> bool: return felipe.is_on_floor(), 1.5)
	await _ir_a(puerta.global_position.x, 1.0)
	await _tocar("interactuar")
	await _cuadro()
	await _hasta(func() -> bool: return not sala.cruzando(), 8.0)
	await _segundos(0.3)
	_paso("Entra a %s" % sala.habitacion)


## Baja de un mueble atravesable (agachado + saltar).
func _bajar() -> void:
	Input.action_press("agacharse")
	await _tocar("saltar")
	Input.action_release("agacharse")
	await _hasta(func() -> bool: return felipe.is_on_floor() and felipe.global_position.y > Nivel1.SUELO - 2.0, 1.5)


func _cazar_raton(desde: float, hasta: float) -> void:
	for hijo in sala.get_children():
		if is_instance_valid(hijo) and (hijo is Enemigo and hijo.datos.nombre == "Raton") and not hijo.vida.muerto and hijo.global_position.x > desde and hijo.global_position.x < hasta \
				and absf(hijo.global_position.y - felipe.global_position.y) < 20.0:
			await _cazar(hijo)
	_paso("Caza ratones entre %d y %d" % [desde, hasta])


## Se acerca y lo golpea apenas lo tiene al alcance del zarpazo (el golpe sale en el cuadro de impacto, 0,25 s
## después de apretar: se anticipa como una persona).
func _cazar(enemigo: Enemigo) -> void:
	for i in int(6.0 * _fps):
		if not is_instance_valid(enemigo) or enemigo.vida.muerto:
			break
		var dx := enemigo.global_position.x - felipe.global_position.x
		var acercandose := signf(enemigo.velocity.x) == -signf(dx)
		if absf(dx) < (64.0 if acercandose else 42.0):
			await _golpear(signf(dx))
		else:
			_soltar_direcciones()
			Input.action_press("mover_derecha" if dx > 0.0 else "mover_izquierda")
			await _cuadro()
	_soltar_direcciones()


func _golpear(lado: float) -> void:
	_soltar_direcciones()
	felipe.mirando = lado
	await _tocar("zarpazo")
	await _segundos(0.3)


## Si un ratón se acerca a su altura, lo golpea primero.
func _raton_cerca() -> Enemigo:
	for hijo in sala.get_children():
		if is_instance_valid(hijo) and (hijo is Enemigo and hijo.datos.nombre == "Raton") and not hijo.vida.muerto and felipe.is_on_floor() and not felipe.agachado:
			var d: Vector2 = hijo.global_position - felipe.global_position
			if absf(d.x) < 50.0 and absf(d.y) < 14.0:
				return hijo
	return null


## Camina hasta x; si un mueble bajo lo frena (la caja de arena), lo salta, como una persona.
func _ir_a(x: float, limite := 10.0) -> void:
	for i in int(limite * _fps):
		var dx := x - felipe.global_position.x
		if absf(dx) < 4.0:
			break
		var raton := _raton_cerca()
		if raton:
			await _golpear(signf(raton.global_position.x - felipe.global_position.x))
			continue
		if felipe.is_on_floor() and felipe.is_on_wall() and not felipe.agachado and absf(dx) > 20.0 and i > 2:
			await _saltar(signf(dx), x)
			continue
		_soltar_direcciones()
		Input.action_press("mover_derecha" if dx > 0.0 else "mover_izquierda")
		_esquivar_bolas()
		await _cuadro()
	_soltar_direcciones()


## Salta hacia x hasta quedar parado en la altura y (un solo salto por intento: no hay doble salto).
func _subir_a(x: float, y: float) -> void:
	for intento in 4:
		if absf(felipe.global_position.y - y) < 3.0 and felipe.is_on_floor():
			break
		await _hasta(func() -> bool: return felipe.is_on_floor(), 1.0)
		await _saltar(signf(x - felipe.global_position.x), x)
		if OS.get_cmdline_user_args().has("--detalle"):
			print("        salto %d hacia (%.0f, %.0f): quedó en (%.0f, %.0f)" % [intento + 1, x, y, felipe.global_position.x, felipe.global_position.y])
	await _ir_a(x, 1.5)


func _saltar(lado: float, x_objetivo := INF) -> void:
	var accion := "mover_derecha" if lado > 0.0 else "mover_izquierda"
	if lado != 0.0 and absf(x_objetivo - felipe.global_position.x) > 3.0:
		Input.action_press(accion)
	Input.action_press("saltar")
	await _segundos(0.23)
	Input.action_release("saltar")
	for i in int(2.0 * _fps):
		if x_objetivo != INF and absf(felipe.global_position.x - x_objetivo) < 5.0:
			Input.action_release(accion)
		if felipe.is_on_floor() and i > 4:
			break
		await _cuadro()
	Input.action_release(accion)


func _esquivar_bolas() -> void:
	if guion.batalla == null:
		return
	for bola in guion.batalla.bolas:
		var dx := bola.global_position.x - felipe.global_position.x
		if absf(dx) < 60.0 and felipe.is_on_floor():
			Input.action_press("saltar")
			return
	Input.action_release("saltar")


func _soltar_direcciones() -> void:
	Input.action_release("mover_derecha")
	Input.action_release("mover_izquierda")


## Una recompensa suelta de ese tipo en ese cuarto (null si no hay).
func _recogible_en(tipo: String, cuarto: String) -> Recogible:
	for hijo in sala.get_children():
		if hijo is Recogible and hijo.tipo == tipo and Nivel1.habitacion_de(hijo.global_position) == cuarto:
			return hijo
	return null


func _resumen() -> ResumenDia:
	for hijo in sala.travesuras.get_children():
		if hijo is ResumenDia:
			return hijo
	return null


# --- Tiempo -------------------------------------------------------------------------------------------------

func _hasta(condicion: Callable, segundos: float) -> void:
	for i in int(segundos * _fps):
		if condicion.call():
			return
		_esquivar_bolas()
		await _cuadro()
	Input.action_release("saltar")


## Con el juego en pausa (resumen del día) los cuadros de física no avanzan: espera con cuadros de proceso.
func _hasta_real(condicion: Callable, segundos: float) -> void:
	for i in int(segundos * _fps):
		if condicion.call():
			return
		await process_frame


func _segundos_reales(segundos: float) -> void:
	for i in int(segundos * _fps):
		await process_frame


func _tocar(accion: String) -> void:
	Input.action_press(accion)
	await _cuadro()
	await _cuadro()
	Input.action_release(accion)
	await _cuadro()


func _segundos(segundos: float) -> void:
	for i in int(segundos * _fps):
		await _cuadro()


var _corazones_antes := 5


func _cuadro() -> void:
	_cuadros += 1
	_reflejos()
	if felipe.corazones < _corazones_antes and OS.get_cmdline_user_args().has("--detalle"):
		print("        ¡golpe! %.1f s en (%.0f, %.0f)" % [_cuadros / _fps, felipe.global_position.x, felipe.global_position.y])
	_corazones_antes = felipe.corazones
	if _cuadros > LIMITE_SEGUNDOS * _fps:
		print("Se acabó el tiempo")
		quit(1)
	await physics_frame


## Reflejo de persona en la pelea: cuando A.S.P.I. avisa una embestida cerca (luz roja), salta en el lugar y la deja
## pasar por debajo.
var _saltando_embestida := 0


func _reflejos() -> void:
	var batalla := guion.batalla if sala else null
	if _saltando_embestida > 0:
		_saltando_embestida -= 1
		if _saltando_embestida == 0:
			Input.action_release("saltar")
		return
	if batalla == null or batalla.fase != BatallaAspi.Fase.PELEA or not felipe.is_on_floor() or felipe.agachado:
		return
	var aspi := guion.aspi
	var dx := felipe.global_position.x - aspi.global_position.x
	var en_el_piso := absf(felipe.global_position.y - aspi.global_position.y) < 30.0
	var viene := signf(aspi.velocity.x) == signf(dx) and absf(aspi.velocity.x) > 1.0
	var saltar := en_el_piso and batalla.ataque == BatallaAspi.Ataque.EMBESTIDA and viene and absf(dx) < 95.0
	# Bola de pelo que viene hacia él: salta un momento antes (va hacia donde estaba).
	for bola in batalla.bolas:
		var hacia := (felipe.global_position + Vector2(0, -24)) - bola.global_position
		var velocidad: Vector2 = bola.get_meta("velocidad")
		if hacia.length() < 100.0 and hacia.dot(velocidad) > 0.0:
			saltar = true
	if saltar:
		Input.action_press("saltar")
		_saltando_embestida = 14


func _dijo_felipe(texto: String) -> bool:
	for linea: Array in sala.travesuras.dialogo.historial:
		if linea[0] == "felipe" and texto in String(linea[1]):
			return true
	return false


func _paso(texto: String) -> void:
	_pasos.append(texto)
	print("%5.1f s  %s  (x %.0f, y %.0f, corazones %d, agenda %d)" % [_cuadros / _fps, texto, felipe.global_position.x, felipe.global_position.y, felipe.corazones, sala.travesuras.agenda.cumplidas()])
